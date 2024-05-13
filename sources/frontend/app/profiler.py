import datetime
import os
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)


from pyinstrument import Profiler
from pyinstrument.renderers.html import HTMLRenderer
from pyinstrument.renderers.speedscope import SpeedscopeRenderer


profile_type_to_ext = {"html": "html", "speedscope": "speedscope.json"}
profile_type_to_renderer = {
	"html": HTMLRenderer,
	"speedscope": SpeedscopeRenderer,
}


class ProfilingContextManager:
	def __init__(self, profile_type='html'):
		self.profile_type = profile_type


	def __enter__(self):
		print("Entering the context...")

		self.profiler_cm = Profiler(interval=0.001, async_mode="enabled")
		self.profiler_cm.__enter__()
					
	
	def __exit__(self, exc_type, exc_value, exc_tb):
		print("Leaving the context...")
		print(exc_type, exc_value, exc_tb, sep="\n")
		self.profiler_cm.__exit__(exc_type, exc_value, exc_tb)
		extension = profile_type_to_ext[self.profile_type]
		renderer = profile_type_to_renderer[self.profile_type]()
		
		fn = '.'.join([
			'/app/server_root/tmp/profile',
			'UTC' + datetime.datetime.utcnow().strftime('%Y_%m_%d__%H_%M_%S'),
			str(os.getpid()),
			extension])
		
		logger.info(f"writing profile to {fn}")
		
		with open(fn, "w") as out:
			out.write(self.profiler_cm.output(renderer=renderer))
