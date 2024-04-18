"""

frontend (or other caller) imports this file.

"""
import json
import logging, sys
import ntpath
import os
from pathlib import Path, PurePath

import requests, time

from agraph import repo_by_user
from fs_utils import files_in_dir, find_report_by_key
from tasking import remoulade
from tmp_dir_path import get_tmp_directory_absolute_path, symlink, ln
from tmp_dir import create_tmp_for_user, create_tmp, make_converted_dir, copy_repo_status_txt_to_result_dir
from app.untrusted_task import *

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../common/libs/sdk/src/')))
import robust_sdk.xml2rdf

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../actors/')))

#import tasking
import trusted_workers
#tasking.remoulade.set_broker(tasking.broker)


# def trigger_remote__call_prolog(msg, queue='default'):
# 	log.debug('trigger_remote__call_prolog: ...')
# 	return call_prolog.send_with_options(kwargs={'msg':msg}, queue_name=queue)

# def trigger_remote__call_prolog_calculator(**kwargs):
# 	log.debug('trigger_remote__call_prolog_calculator: ...')
# 	return call_prolog_calculator.send_with_options(kwargs=kwargs)



log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)
log.debug("debug from manager_actors.py")




class RobustException(Exception):
	pass



@remoulade.actor(alternative_queues=["health"], priority=1)
def call_prolog_rpc(msg, worker_options=None):
	log.debug('manager_actors: call_prolog: ...')
	return do_untrusted_task(Task(
		proc='call_prolog',
		args=dict(
			msg=msg, 
			worker_tmp_directory_name=create_tmp('rpc', exist_ok=True)[0]
		),
		worker_options=worker_options,
		input_files=[],
		output_path=None
	))


def url_file(url):
	return url.split('/')[-1]
def url_base(url):
	return '/'.join(url.split('/')[:-1]) + '/'
	

def frame_results(result, tmp_path, result_uri):
	
	reports = result.get('reports', [])

	# we should start adding something like "server_identifier" into report dicts, but there's also a twist with isolated workers. So maybe after all, it should be just file name, and directory is implicitly tmp_dir?

	doc_result_sheets = find_report_by_key(reports, 'result_sheets')
	if doc_result_sheets:

		doc_result_sheets_file_path = Path(tmp_path) / url_file(doc_result_sheets)			

		params = dict(
			input_file_path=str(doc_result_sheets_file_path),
			destination_dir_path=str(tmp_path),
			frame_root_uri=result_uri
		)
		log.debug(str(params))
		
		r = requests.post(os.environ['JS_SERVICES_URL'] + '/frame', json=params)
		r.raise_for_status()
		framed = r.json()['output_file_path']
		
		reports.append(dict(
			key='doc_result_sheets_framed',
			title='doc_result_sheets_framed',
			val=dict(url=url_base(doc_result_sheets) + ntpath.basename(framed))
		))
	
	


@remoulade.actor(time_limit=1000*60*60*24*365)
def call_prolog_calculator(
	request_directory: str,
	public_url='http://localhost:8877',
	worker_options=None,
	request_format=None,
	xlsx_extraction_rdf_root=None
):

	log.debug('manager_actors: call_prolog_calculator(%s, %s, %s, %s, %s)' % (request_directory, public_url, worker_options, request_format, xlsx_extraction_rdf_root))


	if xlsx_extraction_rdf_root is None:
		xlsx_extraction_rdf_root = "https://rdf.lodgeit.net.au/v1/calcs/ic/ui#investment_calculator_sheets"


	# create a tmp directory for results files created by this invocation of the calculator
	result_tmp_directory_name, result_tmp_directory_path = create_tmp_for_user(worker_options['user'])

	original_input_files = files_in_dir(get_tmp_directory_absolute_path(request_directory))	
	
	# potentially convert request files to rdf (this invokes other actors)
	try:
		converted_request_files = preprocess_request_files(original_input_files, xlsx_extraction_rdf_root)
	except RobustException as e:
		log.error('preprocess_request_files failed: %s' % e)
		return dict(alerts=[str(e)])


	# the params that will be passed to the prolog calculator
	params=dict(
		request_files = converted_request_files,
		request_format=request_format,
		request_tmp_directory_name=request_directory,
		result_tmp_directory_name=result_tmp_directory_name,
		public_url=public_url,
		rdf_explorer_base='/static/rdftab/rdftab.html?node=' 
	)


	params['final_result_tmp_directory_name'] = CurrentMessage.get_current_message().message_id
	if params['final_result_tmp_directory_name'] is None:
		params['final_result_tmp_directory_name'] = 'cli'
	params['final_result_tmp_directory_path'] = get_tmp_directory_absolute_path(params['final_result_tmp_directory_name'])
	Path(params['final_result_tmp_directory_path']).mkdir(parents=True, exist_ok=True)


	# only useful in single-user use, but still useful:
	symlink('last_request', request_directory)
	symlink('last_result', result_tmp_directory_name)


	# more reproducibility:
	copy_repo_status_txt_to_result_dir(result_tmp_directory_path)
	
	
	# establish a relation from job to calculator result directory
	ln('../'+result_tmp_directory_name, params['final_result_tmp_directory_path'] + '/' + result_tmp_directory_name)


	result = do_untrusted_task(Task(
		proc='call_prolog',
		args=dict(
			msg=dict(
				method='calculator', 
				params=params
			),
			worker_tmp_directory_name=result_tmp_directory_name
		),
		worker_options=worker_options,
		input_files=converted_request_files,
		output_path=result_tmp_directory_path,		
	))


	result_uri = public_url + '/rdf/results/' + result_tmp_directory_name + '/'
	result_graph = public_url + '/rdf/results/' + result_tmp_directory_name+'/default'

	frame_results(result, result_tmp_directory_path, result_uri)
	
	
	# mark this calculator result as finished, and the job as completed
	ln('../' + result_tmp_directory_name, params['final_result_tmp_directory_path'] + '/completed')
	
	
	log.info('postprocess(%s, %s, %s)' % (result_tmp_directory_path, result, worker_options['user']))
	trusted_workers.postprocess.send_with_options(
		kwargs=dict(
			job=params['final_result_tmp_directory_name'],
			request_directory=request_directory,
			converted_request_files=converted_request_files,
			tmp_name=result_tmp_directory_name,
			tmp_path=result_tmp_directory_path,
			result=result,
			user=worker_options['user'],
			public_url=public_url,
			result_uri=result_uri,
			result_graph=result_graph
		),
		queue_name='postprocessing',
		on_failure=print_actor_error
	)

	json.dump(result, open(result_tmp_directory_path + '/result.json', 'w'), indent=2)
	return result



def preprocess_request_files(files, xlsx_extraction_rdf_root):
	files = list(filter(None, map(lambda f: preprocess_request_file(xlsx_extraction_rdf_root, f), files)))
	return files
	
	

def preprocess_request_file(xlsx_extraction_rdf_root, file):
	log.info('convert_request_file?: %s' % file)

	if file is None:
		return None
	if file.endswith('/.access'):
		return None # hide the file from further processing
	if file.endswith('/.htaccess'):
		return None # hide the file from further processing
	if file.endswith('/request.json'):
		return None
		
	if file.endswith('/request.xml'):
		converted_dir = make_converted_dir(file)
		converted_file_path = robust_sdk.xml2rdf.Xml2rdf().xml2rdf(file, converted_dir)
		if converted_file_path is not None:
			log.info('converted_file_path: %s' % converted_file_path)
			return converted_file_path
			
	if file.lower().endswith('.xlsx'):
		converted_dir = make_converted_dir(file)
		converted_file_path = str(converted_dir.joinpath(str(PurePath(file).name) + '.n3'))
		log.info('convert_excel_to_rdf: %s' % file)
		convert_excel_to_rdf(file, converted_file_path, root=xlsx_extraction_rdf_root)
		log.info('converted_file_path: %s' % converted_file_path)
		return converted_file_path

	if file.lower().endswith('.jsonld'):
		converted_dir = make_converted_dir(file)
		r = requests.post(os.environ['JS_SERVICES_URL'] + '/request_jsonld_to_rdf', json=dict(
			input_file_path=str(file),
			destination_dir_path=str(converted_dir)))
		r.raise_for_status()
		return r.json()['output_file_path']
	
	return file



def convert_excel_to_rdf(uploaded, to_be_processed, root):
	"""run a POST request to csharp-services to convert the file.
	We should really turn csharp-services into an untrusted worker at some point.	
	"""
	log.info('xlsx_to_rdf: %s -> %s (root: %s)' % (uploaded, to_be_processed, root))
	start_time = time.time()
	r = requests.post(os.environ['CSHARP_SERVICES_URL'] + '/xlsx_to_rdf', json={"root": root, "input_fn": str(uploaded), "output_fn": str(to_be_processed)})
	r.raise_for_status()
	r = r.json()
	if r.get('error'):
		raise RobustException(r.get('error'))
	
	log.info('xlsx_to_rdf: %s -> %s done in % seconds' % (uploaded, to_be_processed, time.time() - start_time))




@remoulade.actor
def print_actor_error(actor_name, exception_name, message_args, message_kwargs):
  log.error(f"Actor {actor_name} failed:")
  log.error(f"Exception type: {exception_name}")
  log.error(f"Message args: {message_args}")
  log.error(f"Message kwargs: {message_kwargs}")



remoulade.declare_actors([print_actor_error, call_prolog_rpc, call_prolog_calculator])







#doc_result_sheets_file_path = Path(tmp_path) / '000000_doc_result_sheets.turtle'
#if doc_result_sheets_file_path.exists():
