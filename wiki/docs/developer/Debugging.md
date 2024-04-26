
## debugging

### monitoring

### portainer
http://localhost:9000

* for debugging docker/containers
* not part of the stack, but recommended to spin up separately

### RabbitMQ console
http://localhost:15672
* guest / guest (RABBITMQ_DEFAULT_USER and RABBITMQ_DEFAULT_PASS...)
* monitor all messagess and queues

### superbowl
http://localhost:1238/
* monitor remoulade tasks

### agraph
http://0.0.0.0:10035/#
* secrets/AGRAPH_SUPER_USER, secrets/AGRAPH_SUPER_PASSWORD

### test runner (luigi)
http://localhost:8082/


..

### swipl
* https://swi-prolog.discourse.group/t/bug-hunting-toolbox/710
* https://swi-prolog.discourse.group/t/trace-on-error/1333/2


### debugging checklist:

### container startup
`--container_startup_sequencing True` for debugging issues manifesting at container startup


### `robust run` flags:
	
* `--mount_host_sources_dir true` - this ensures that all source etc directories are mounted rather than copied. This means that you can always just modify any prolog source file and re-run a request.
	
* `--django_noreload false` - applies only to some services, makes django watch for and reload files on modification.

### exceptions
there are two general cases:
* our code calls `throw_string`/`throw_value`. `DONT_GTRACE` and `DISPLAY` applies.
* something else throws an exception, like a division by zero: `DISABLE_GRACEFUL_RESUME_ON_UNEXPECTED_ERROR` controls if it gets converted into an alert or caught by swipl toplevel, possibly causing gtrace to be invoked.

not sure if, at this point, it still makes sense to have the option to invoke gtrace in `throw_string`, as opposed to having it just throw the exception, and letting it propagate like "normal" exceptions do, controlled by `DISABLE_GRACEFUL_RESUME_ON_UNEXPECTED_ERROR`.   


### `sources/config/worker_config.json`:
	this is loaded by call_prolog on every request.
    
* "DEBUG" : pass `--debug true` to dev_runner. Causes SWIPL_NODEBUG to be off, --debug to be passed to swipl, and `debug` called as a goal.  

If unset:
		* run_last_request_in_docker scripts have debugging on
		* internal-workers as a service has debugging off

* "DONT_GTRACE" : invoke (gui)tracer when throw_string is called? (if $DISPLAY is available)
    
* "DISABLE_GRACEFUL_RESUME_ON_UNEXPECTED_ERROR" : 
		* true: let exceptions propagate to toplevel so that gtrace pops up
		* false: catch exceptions and convert them into alerts, finish producing reports - this should be the default in production


### gtrace	

configuration: `sources/swipl/xpce/Defaults`: adjust font size as needed.

gtrace is useful, although it gets confused often. In some swipl versions it's better than in others. Swipl also seems to hang for a long time after aborting out of gtrace lately.
* https://github.com/SWI-Prolog/swipl-devel/issues/757
* https://github.com/SWI-Prolog/swipl-devel/issues/774

gtrace is enabled by running 'guitracer'. Robust does this if 'have_display' succeeds.
	
'have_display' succeds if DISPLAY env var is set and nonempty. 
	
take care of prolog 'debug' flag. This is set by '--debug' parameter on swipl command line. It's set to true when running requests on the command line (`invoke_rpc_cmdline.py`), but not when running in the webserver. 
	
if 'guitracer' was previously invoked, 'gtrace' will kick in when the repl catches an uncaught exception. Unfortunately, 'process_request' catches exceptions to produce alerts and return response to client instead. This means that normal exceptions (not thrown with `throw_string`) in Robust code dont cause gtrace to run - unless you set the debugging flag 'disable_graceful_resume_on_unexpected_error'. But it could be done with prolog_exception_hook, which we already use anyway.
- not exactly, prolog_exception_hook runs every time any exception is thrown, and you get a lot of that for example when using guitracer. But it would be handy to be able to set a flag to run guitracer in the exception hook.

guitracer - remember to disable "cluster variables" in settings
- can we make this permanent?
see config_example/debug/worker_config.json for also setting "dev_runner_options": ["--toplevel", "true"],
this makes it possible to get guitracer once an exceptions propagates all the way up. But you then have to killall -9 swipl.


```Failed to connect to X-server at `:0.0 ```: This is a permission error, because docker is running under different user. Run `xhost +local:docker` to fix this for a session.

If gtrace shows up on `process_multifile_request`, do a redo followed by a skip and you'll get a readable stack trace in terminal. (?)
	

### python
various parts use various levels of logging severity, eg.: `logging.getLogger().info(msg)`. We don't yet have a method to control current severity (when spawning django server, or when running a worker from the command line).

### apache
adjust `LogLevel` in httpd.conf, for example `trace6`

### fastapi / pydantic
* ```sudo tcpdump -i lo  -A -s 0 'tcp port 7788'```
* `debug.py`

### network
 watch http trafic from and to endpoint:
```sudo tcpdump -A -s 0 'tcp port 7778 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'```

### git

given you are on a commit with some tests failing, find last commit with no tests failing:
		(tests need fixing right now)
```git bisect start; git bisect bad HEAD; git bisect good master; git bisect run ./bisect_helper.sh```


### test requests/responses

overwrite differing response files:
swipl -s ../tests/endpoint_tests/endpoint_tests.pl  -g "set_flag(overwrite_response_files, true), run_tests."



### determinancy_checker
`DETERMINANCY_CHECKER__USE__ENFORCER` env var applies.


### running `workers` outside docker for debugging
run all services except workers, under compose
`./develop.sh --omit_service workers`

setup venv
```
virtualenv -p /usr/bin/python3.10 venv
. venv/bin/activate.fish
pip install -r requirements.txt
pip install -r requirements-dev.txt
```
grab the env vars as printed by develop.sh:
```
 RABBITMQ_URL='localhost:5672' \
 REDIS_HOST='redis://localhost' \
 AGRAPH_HOST='localhost' \
 AGRAPH_PORT='10035' \
 REMOULADE_PG_URI='postgresql://remoulade@localhost:5433/remoulade' \
 SERVICES_URL='http://localhost:17788' \
```
and do what start.sh does:
```
remoulade --threads 1 invoke_rpc
```

### running requests manually in swipl toplevel in docker
1) grab the envvars as printend when stack is brought up. Maybe we should save it alongside last.yml.

```
PP='' DISPLAY='' RABBITMQ_URL='localhost:5672' REDIS_HOST='redis://localhost' AGRAPH_HOST='localhost' AGRAPH_PORT='10035' REMOULADE_PG_URI='postgresql://remoulade@localhost:5433/remoulade' REMOULADE_API='http://localhost:5005' SERVICES_URL='http://localhost:17788' CSHARP_SERVICES_URL='http://localhost:17789' FLASK_DEBUG='0' FLASK_ENV='production' WATCHMEDO='' \

 


## docker

### gtrace

first you must run `xhost +local:docker` on your host.
after that, make sure you have this in your docker stack declaration:

    environment:
      DISPLAY: ":0.0"
    volumes:
      - "/tmp/.X11-unix:/tmp/.X11-unix:rw"

you should be good to go.

doing the same without docker-stack:
    http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/



### inotify limit reached
https://www.suse.com/support/kb/doc/?id=000020048







