#sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../common/libs/misc')))
import subprocess
import sys, os
import time
import urllib
from pathlib import Path, PosixPath
from shutil import make_archive

import rdflib
import rdflib.plugins.serializers.nquads
import requests

import agraph
from fs_utils import find_report_by_key
from tasking import remoulade
import logging

from tmp_dir_path import get_tmp_directory_absolute_path, ln

log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)
log.debug("debug from trusted_workers.py")
log.info("info from trusted_workers.py")
log.warning("warning from trusted_workers.py")




class RobustException(Exception):
	pass



@remoulade.actor(priority=1, time_limit=1000*60*60*24*365, queue_name='postprocessing')
def postprocess(job, request_directory, tmp_name, tmp_path, result, user, public_url):
	log.info('postprocess...')

	tmp_path = Path(tmp_path)
	uris = result.get('uris', {})
	reports = result.get('reports', [])
	alerts = result.get('alerts', ['internal error'])
	result_tmp_directory_name = uris.get('result_tmp_directory_name', '???')
	result_tmp_directory_url = find_report_by_key(reports, 'task_directory')
	
	
	sections = {}
	
	reports_dict = {}
	for key in  ['alerts_html', 'crosschecks_html', 'balance_sheet.html', 'profit_and_loss.html', 'cashflow_html', 'investment_report_html', 'gl_html']: 
		for r in reports:
			if r['key'] == key:
				reports_dict[r['title']] = r['val']['url']
				break
	sections['Reports'] = reports_dict
	

	g = load_doc_dump(tmp_path)
	if g:
		nq_fn = generate_doc_nq_from_trig(g, tmp_path)
		put_doc_dump_into_triplestore(nq_fn, uris, user)
		#generate_yed_file(g, tmp_path)
		#generate_gl_json(g)
		

	result_sheets_fn = tmp_path / '000000_doc_result_sheets.turtle'
	if result_sheets_fn.is_file():
		generate_result_xlsx(tmp_path)
		reports_dict['Excel sheets'] = result_tmp_directory_url + '/result.xlsx'


	sections['Job']=dict(
			Archive=f'../../view/archive/{job}/{tmp_name}',
			Result=find_report_by_key(reports, 'task_directory'),
			Inputs=f'../{request_directory}',
			Rdftab='/static/rdftab/rdftab.html?'+urllib.parse.urlencode(
					{
						'node':						'<'+	public_url + '/rdf/results/' + result_tmp_directory_name+'/>',
						'focused-graph':				public_url + '/rdf/results/' + result_tmp_directory_name+'/default'
					}
				),
			Job=f'../{job}',
			)
		
			
	html_content = f"""
	<!DOCTYPE html>
	<html>
	<body>"""
		
	html_content += f"""<h3>Alerts</h3>""" + str(len(alerts)) + ' alerts.'
	
	for section_name, section_dict in sections.items():
		html_content += f"""<h3>{section_name}</h3>"""
		for k,v in section_dict.items():
			if v is not None:
				html_content += f"""<a href="{v}">{k}</a><br>"""
				
	html_content += """</body>
	</html>
	"""
	with open(tmp_path/'job.html', 'w') as file:
		file.write(html_content)



def generate_result_xlsx(tmp_path):
	f = tmp_path / '000000_doc_result_sheets.turtle'
	if f.is_file():
		# g=rdflib.graph.ConjunctiveGraph()
		# log.debug(f"load {f} ...")
		# g.parse(f, format='turtle')
		# log.debug(f"load {f} done.")

		# call CSharpServices to generate xlsx
		start_time = time.time()
		r = requests.post(os.environ['CSHARP_SERVICES_URL'] + '/rdf_to_xlsx', json={'output_directory': str(tmp_path), 'input_file': str(f)})
		r.raise_for_status()
		r = r.json()
		if r.get('error'):
			raise RobustException(r.get('error'))
		
		




@remoulade.actor
def print_actor_error(actor_name, exception_name, message_args, message_kwargs):
  log.error(f"Actor {actor_name} failed:")
  log.error(f"Exception type: {exception_name}")
  log.error(f"Message args: {message_args}")
  log.error(f"Message kwargs: {message_kwargs}")



remoulade.declare_actors([print_actor_error, postprocess])



def load_doc_dump(tmp_path):
	trig_fn = tmp_path / '000000_doc_final.trig'
	# or: trig_fn = report_by_key(response, 'doc.trig')

	if trig_fn.is_file():
		g=rdflib.graph.ConjunctiveGraph()
		log.debug(f"load {trig_fn} ...")
		g.parse(trig_fn, format='trig')
		log.debug(f"load {trig_fn} done.")
		return g


def generate_doc_nq_from_trig(g, tmp_path):
	nq_fn = tmp_path / 'doc.nq'
	log.debug(f"write {nq_fn} ...")
	g.serialize(nq_fn, format='nquads')
	return nq_fn



def put_doc_dump_into_triplestore(nq_fn, uris, user):
	log.debug("agc(nq_fn=%s, uris=%s, user=%s)...", nq_fn, uris, user)
	
	c = agraph.agc(agraph.repo_by_user(user))
	if c:
		log.debug("c.addFile(nq_fn)...")
		c.addFile('../static/kb.trig')
		c.addFile(str(nq_fn))
		log.debug("c.addFile(nq_fn) done.")

		if uris:
			# add prefixes
			result_prefix = uris['result_tmp_directory_name'].split('.')[-1]
			# ^see create_tmp_directory_name
			prx = result_prefix, uris['result_data_uri_base']
			log.debug("c.setNamespace(%s)...", prx)
			c.setNamespace(*prx)



def report_by_key(response, key):
	for i in response['reports']:
		if i['key'] == key:
			return i['val']['url']


