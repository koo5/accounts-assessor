import os,logging
# what this really controls is how many times it should try to reconnect gracefully before it starts reconnecting in an uncontrolled DOS-style loop (still true?)
os.environ['remoulade_restart_max_retries']='99999999'
import remoulade
from remoulade.brokers.rabbitmq import RabbitmqBroker
import remoulade.results.backends
from remoulade.state.backends import PostgresBackend
from remoulade.results import Results
from remoulade.state.middleware import MessageState
from remoulade.cancel import Cancel
import remoulade.cancel.backends
from remoulade.middleware import CurrentMessage
from remoulade.scheduler import ScheduledJob, Scheduler

redis_url=os.environ['REDIS_HOST']
result_time_limit_ms = 10 * 12 * 31 * 24 * 60 * 60 * 1000
broker_url="amqp://"+os.environ['RABBITMQ_URL']+"?timeout=15"
#print(broker_url)
broker = RabbitmqBroker(url=broker_url, confirm_delivery=True, delivery_mode=2, max_priority=10)

broker.add_middleware(Results(
	backend=remoulade.results.backends.RedisBackend(url=redis_url), 
	store_results=True, 
	result_ttl=result_time_limit_ms))
broker.add_middleware(MessageState(PostgresBackend(url=os.environ['REMOULADE_PG_URI']), state_ttl=result_time_limit_ms))
broker.add_middleware(Cancel(backend=remoulade.cancel.backends.RedisBackend(url=redis_url)))
broker.add_middleware(CurrentMessage())

print(broker)
remoulade.set_broker(broker)
scheduler = Scheduler(broker, [])
#scheduler = Scheduler(broker, [ScheduledJob(actor_name="ping", args=(), interval=100)])
remoulade.set_scheduler(scheduler)

#@remoulade.actor
#def ping():
#	return "pong"
#remoulade.declare_actors([ping])
#print('scheduler.start...')
#scheduler.start()

logging.getLogger('amqpstorm').setLevel(logging.INFO)
print('tasking loaded')
print()

