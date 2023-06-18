#!/usr/bin/env python3


import subprocess, fire, shlex, io, libtmux, logging, datetime
#logging.getLogger('libtmux').setLevel(logging.WARNING)


def run(compose_events_cmd, tmux_session_name: str):
	tmux_session_name = str(tmux_session_name)

	tmux_server = libtmux.Server()
	print(tmux_session_name.__repr__())
	print(tmux_server.sessions)
	
	# this seems to be broken, it doesn't list all sessions
	#tmux_session = tmux_server.sessions.filter(session_name=tmux_session_name)[0]
	#tmux_session = tmux_server.find_where({'session_name': tmux_session_name})
	tmux_session = tmux_server.new_session(session_name='robust_up_'+str(datetime.datetime.utcnow().timestamp()).replace('.', '_'))
	
	cmd = shlex.split('stdbuf -oL -eL ' + compose_events_cmd + ' events')
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	for line in io.TextIOWrapper(proc.stdout, encoding="utf-8"):
		if 'container start' in line or 'container die' in line:
			print(line)
		if 'container start' in line:
			s = line.split()
			container_id = s[4]
			line_quoted = shlex.quote(line)
			tmux_session.new_window(window_name='X'+container_id, window_shell=f'echo {line_quoted}; docker logs -f ' + container_id + ' | cat; cat')
		# we kinda might rather want docker-compose -f ../generated_stack_files/last.yml -p robust logs -f <service name>
		# but as it is, this does pop up a new tmux window when a container is restarted etc, and brings it to the front, and there's always a bit of the old log and then the new. Does it ever happen that the log stops being printed while a container is running?


if __name__ == '__main__':
  fire.Fire(run)
