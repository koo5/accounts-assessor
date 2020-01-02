#!/usr/bin/env python3

import threading, json, time, click, subprocess, shlex, shutil, ntpath, os



class AtomicInteger():
	""" https://stackoverflow.com/questions/23547604/python-counter-atomic-increment """
	def __init__(self, value=0):
		self._value = value
		self._lock = threading.Lock()

	def inc(self):
		with self._lock:
			self._value += 1
			return self._value

	def dec(self):
		with self._lock:
			self._value -= 1
			return self._value


	@property
	def value(self):
		with self._lock:
			return self._value

	@value.setter
	def value(self, v):
		with self._lock:
			self._value = v
			return self._value




server_started_time = time.time()
client_request_id = AtomicInteger()




def files_in_dir(dir):
	result = []
	for filename in os.listdir(dir):
		filename2 = '/'.join([dir, filename])
		if os.path.isfile(filename2):
			result.append(filename2)
	return result

@click.command()
@click.argument('request_files', nargs=-1)
def run(request_files):
	server_url = 'http://localhost:8080'
	request_files = [os.path.abspath(f) for f in request_files]
	tmp_directory_name, tmp_directory_absolute_path = create_tmp()
	files = request_files
	if len(request_files) == 1:
		f = request_files[0]
		if not os.path.isfile(f):
			files = files_in_dir(f)
	files2 = []
	for f in files:
		tmp_fn = os.path.abspath('/'.join([tmp_directory_absolute_path, ntpath.basename(f)]))
		shutil.copyfile(f,tmp_fn)
		files2.append(tmp_fn)
	call_rpc(server_url = server_url, tmp_directory_name=tmp_directory_name, request_files_in_tmp=files2)

def call_rpc(server_url, tmp_directory_name, request_files_in_tmp):
	cmd = shlex.split("swipl -s ../lib/dev_runner.pl --problem_lines_whitelist ../misc/problem_lines_whitelist -s ../lib/debug_rpc.pl") + [] + ["-g lib:process_request_rpc_cmdline"]
	print(' '.join(cmd))

	input = json.dumps({
		"method":"calculator",
		"params":{
			"server_url":server_url,
			"tmp_directory_name":tmp_directory_name,
			"request_files":request_files_in_tmp}
	})
	print(input)

	p = subprocess.Popen(cmd, universal_newlines=True, stdin=subprocess.PIPE)
	(stdout_data, stderr_data) = p.communicate(input = input)

def create_tmp_directory_name():
	return str(server_started_time) + '.' + str(client_request_id.inc())

def get_tmp_directory_absolute_path(name):
	return os.path.abspath('../server_root/tmp/' + name)

def create_tmp():
	name = create_tmp_directory_name()
	path = get_tmp_directory_absolute_path(name)
	os.mkdir(path)
	subprocess.call(['rm', get_tmp_directory_absolute_path('last')])
	subprocess.call(['ln', '-s', get_tmp_directory_absolute_path(name), get_tmp_directory_absolute_path('last')])
	return name,path



if __name__ == '__main__':
	run()


