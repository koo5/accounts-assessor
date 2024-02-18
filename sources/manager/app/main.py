#!/usr/bin/env python3

import os
from pathlib import PosixPath

if os.environ.get('PYDEVD'):
	import pydevd_pycharm
	pydevd_pycharm.settrace('localhost', port=int(os.environ.get('PYDEVD_PYCHARM_PORT')), suspend=False)

"""
Manager, also called proxy. Connects to rabbitmq to accept jobs. Declares remoulade actors (which follow remoulade semantics, returning results through postgres, etc), and relays them to workers. There are three deployment scenarios that we'll try to support:

## trusted workers in docker stack
id is generated by docker

## untrusted workers in fly.io machines
id and auth token generated in manager.

## untrusted workers connecting over public internet
These would be set up by user in frontend, id and auth token would be generated for each.

Manager has two outer-facing parts:
	* the api, which workers connect to
	* remoulade_thread, the remoulade actors, and the connection to rabbitmq

parallelization:
	* manager could be deployed across multiple containers, or uvicorn could spawn multiple worker processes. In both cases, care would have to be taken that a given (robust) worker would always connect to the same manager process (balancer affinity).	
"""



import logging
import os, sys
import threading
import time, asyncio
from typing import Optional
from fastapi.security import OAuth2PasswordBearer
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../common/libs/misc')))
from tasking import remoulade
from fastapi import FastAPI, Request, Depends, HTTPException
from app.isolated_worker import *
from app.untrusted_task import *
import app.manager_actors
import app.tokens
import app.machine



logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)
#log.addHandler(logging.StreamHandler(sys.stderr))

loop_log = logging.getLogger('loop')
loop_log.setLevel(logging.INFO)

#logging.config.fileConfig('logging.yaml', defaults=None, disable_existing_loggers=False, encoding=None)



app = FastAPI(
	title="Robust API",
	summary="invoke accounting calculators and other endpoints",
)



# misnomer, but it works
worker_auth_scheme = OAuth2PasswordBearer(tokenUrl="dummy_worker_auth", scopes={'a':'be_worker'}, auto_error=False)



@app.get("/")
async def read_root():
	return {"Hello": "World"}



@app.get("/health")
async def read_root():
	return "ok"



# @app.post("/dummy_worker_auth")
# async def read_root():
# 	return "ok"
# 



@app.post("/worker/{worker_id}/heartbeat")
def post_heartbeat(worker_id: str, task_id: str = None, token: str = Depends(worker_auth_scheme)):
	"""
	While worker is processing a task, it should take care to call /worker/{id}/heartbeat every minute. - it can also do this the whole time, even when there's no task.
	"""

	#if fly:
	#	token = tokens.decode_token(token)
	#	if token is None:
	#		raise HTTPException(status_code=400, detail="Invalid authentication credentials")
	# ^ we use basicauth atm

	log.debug('heartbeat %s %s', worker_id, task_id)
	worker = get_worker(worker_id, last_seen=datetime.datetime.now())
	worker.last_reported_task = task_id
	worker.last_reported_task_ts = datetime.datetime.now()



def stats():
	active_tasks = [w.task for w in workers.values() if w.task]
	log.info(f'{len(pending_tasks)=}, len(workers)={len(workers)}, {len(active_tasks)=}')



@app.post("/worker/{worker_id}/messages")
async def post_messages(request: Request, worker_id: str, inmsg: dict):
	"""
	Hangs until a message is available. Worker calls this in a loop.
	
	Always at most one message in the queue. The messages are:
		"ping" - worker should respond with "pong"
		a task - worker should start processing the task, and when it's done submit task_result in next call to /worker/{id}/messages
	
	If the manager has been reset while worker is processing a task:
		* this task_result will be ignored, worker will go on to the next task.
		* the remoulade task will eventually get marked as failed.
	
	IF the worker has been reset while processing a task:
		manager detects this because it expects a task_result, but gets none. The remoulade task will be made to return with failure.
		
	It might be possible that a client issues two requests to /messages with some overlap. This might happen if the connection breaks or client disconnects, and immediately connects again (as it should), but the first request is still waiting on toworker.get(1).
	In this case, the message will be lost. This is the same as if the worker never connected back again.
	
	 Concievably, the events pushed here can be pushed multiple times, the client can invoke this multiple times, if a connection error occurs during handling
	 
	"""

	task_result = inmsg.get('task_result')
	worker_info = inmsg.get('worker_info')


	loop_log.debug('')
	loop_log.debug('')
	loop_log.info('/messages worker_id=%s task_result=%s', worker_id, task_result)

	worker = get_worker(worker_id, last_seen=datetime.datetime.now())
	worker.info = worker_info

	outmsg = {}

	if task_result:
		outmsg |= on_task_result(worker=worker, result=task_result)
	else:
		if worker.task and worker.task_given_ts:
			time_since_task_sent_to_worker = datetime.datetime.now() - worker.task_given_ts
			#log.debug(f'{time_since_task_sent_to_worker=}')
			if time_since_task_sent_to_worker > datetime.timedelta(seconds=15):
				# grace period, because in the loop below, we may think that we sent a response with task, but the worker might have been already disconnected. But we only record task_given_ts the first time we relay the task, so, if a worker keeps disconnecting, we eventually ...do...something?
				loop_log.warn(f"""{worker.id} should be working on {worker.
						 task_id} and sending heartbeats, but it's coming back without result... {time_since_task_sent_to_worker=}""")
				# there doesnt seem much point in purging it, because it will just come back again. The situation here implies a programming error or a problem with network / oom / etc..
				#put_event(dict(type='forget_worker', worker=worker))
		else:
			put_event(dict(type='worker_available', worker=worker))
			# give synchronization_thread some time to assign task to worker. todo this doesn't need to happen in a separate thread, can happen synchronously.
			await asyncio.sleep(2)


	counter = 0
	loop_log.debug(f'begin loop {worker_id=}')

	stats()
	
	while not await request.is_disconnected():
	
		loop_log.debug(f'begin loop2 {worker_id=} {counter=}')
		counter += 1


		heartbeat(worker)
		loop_log.debug(f'begin loop3 {worker_id=}')
		
		

		#loop_log.debug('id(workers)=%s', id(workers))
		loop_log.debug(f'{len(workers)=} :>')
		#for _,v in workers.items():
		#	loop_log.debug('worker %s', v)
		#loop_log.debug('worker %s not disconnected', worker_id)


		loop_log.debug(f'{len(pending_tasks)=}')
		for v in pending_tasks:
			loop_log.debug('%s', v)


		if worker.task:
			loop_log.debug('give task: %s', worker.task)
			if not worker.task_given_ts:
				worker.task_given_ts = datetime.datetime.now()
			return outmsg | dict(task=dict(id = worker.task.id, proc=worker.task.proc, args=worker.task.args, worker_options=worker.task.worker_options, input_files=worker.task.input_files))


		loop_log.debug('sleep')
		loop_log.debug('')
		
		try:			
			# this is effectively how often we check if worker disconnected, in absence of tasks. But also how often we refresh last_seen. See also is_alive().
			await asyncio.wait_for(worker.handler_wakeup.wait(), timeout=heartbeat_interval)
		except asyncio.exceptions.TimeoutError:
			pass
		

		# give some time for actors to relay the result, but then let's not keep the worker hanging around with result indefinitely, because it always timeouts first, and we never actually send him a message. So let's send him the ack.

		if not worker.task and task_result:
			loop_log.debug('%s',(outmsg))
			return outmsg


	loop_log.info('hangup %s', worker_id)
	loop_log.debug('')



# async def handler_wakeup_wait_timeout(handler_wakeup):
# 	log.debug('handler_wakeup_wait_timeout')
# 	try:
# 		await asyncio.wait_for(handler_wakeup.wait(), timeout=10)
# 	except asyncio.TimeoutError:
# 		pass



def remoulade_thread():
	"""
	this is a copy of remoulade.__main__.start_worker that works inside a thread.
	Spawn a remoulade worker and periodically check if it's still running.
	"""
	logger = logging.getLogger('remoulade')

	broker = remoulade.get_broker()
	broker.emit_after("process_boot")

	# i'm afraid there isnt a good way to healthcheck manager in the same way that we healthcheck the (trusted) workers container. I mean, we could run two manager processes, and devise one worker to serve it....idk
	worker = remoulade.Worker(broker, queues=[os.environ['QUEUE']], worker_threads=int(os.environ.get('REMOULADE_WORKER_THREADS',30)), prefetch_multiplier=1)
	worker.start()

	running = True
	while running and not shutdown_event.is_set():
		if worker.consumer_stopped or worker.worker_stopped:
			running = False
			logger.info("Worker thread is not running anymore, stopping Worker.")
		else:
			time.sleep(1)

	worker.stop(5 * 1000)
	broker.emit_before("process_stop")
	broker.close()



threading.Thread(target=remoulade_thread, daemon=True).start()
threading.Thread(target=synchronization_thread, daemon=True).start()




# @app.on_event("startup")
# async def startup_event():
#     # Start the background thread
#     threading.Thread(target=background_task, daemon=True).start()


@app.on_event("shutdown")
async def shutdown():
	shutdown_event.set()
	events.put(dict(type='nop'))



@app.post("/worker/{worker_id}/get_file")
async def get_file(request: Request, worker_id: str, file: dict):
	"""
	Worker calls this to get a file from manager. The file is in manager's filesystem, and the worker needs to download it.
	"""
	log.debug('get_file %s', file)
	worker = get_worker(worker_id, last_seen=datetime.datetime.now())
	path = file['path']
	if worker.task:
		if path in worker.task.input_files:
			with open(path, 'rb') as f:
				# todo, not sure if we can send any bytes here
				return f.read()
		else:
			raise Exception('file not in worker.task.input_file')
	else:
		raise Exception('worker has no task')



@app.post("/worker/{worker_id}/put_file")
async def put_file(request: Request, worker_id: str, file: dict):
	"""
	Worker calls this to put a file in manager's filesystem. The file is in worker's filesystem, and the manager needs to download it.
	"""
	log.debug('put_file %s', file)
	worker = get_worker(worker_id, last_seen=datetime.datetime.now())
	path: PosixPath = PosixPath(file['path'])
	if worker.task:
		if worker.task.output_path and (path.parent == worker.task.output_path):
			with open(path, 'wb') as f:
				f.write(file['content'])
			return 'ok'
		else:
			raise Exception('file not in worker.task.output_path')
	else:
		raise Exception('worker has no task')
		
