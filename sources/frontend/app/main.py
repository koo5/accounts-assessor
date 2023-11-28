import logging
import os, sys
import urllib.parse
import json
import datetime
import ntpath
import shutil
import re
from pathlib import Path as P

import requests

from typing import Optional, Any, List, Annotated
from fastapi import FastAPI, Request, File, UploadFile, HTTPException, Form, status, Query, Header

from fastapi.exceptions import RequestValidationError
from fastapi.responses import PlainTextResponse, JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.responses import RedirectResponse, PlainTextResponse, HTMLResponse
from pydantic import BaseModel
from fastapi.templating import Jinja2Templates


from xml.etree import ElementTree
from xml.dom import minidom
from xml.dom.minidom import getDOMImplementation
impl = getDOMImplementation()


templates = Jinja2Templates(directory="templates")


sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../workers')))
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../common')))
import worker



from agraph import agc
import invoke_rpc
from tasking import remoulade
from fs_utils import directory_files, find_report_by_key
from tmp_dir_path import create_tmp, get_tmp_directory_absolute_path
import call_prolog_calculator




class UploadedFileException(Exception):
	pass


class ChatRequest(BaseModel):
	type: str
	current_state: list[Any]

class RpcCommand(BaseModel):
	method: str
	params: Any

class Div7aPrincipal(BaseModel):
	principal: float
class Div7aOpeningBalanceForCalculationYear(BaseModel):
	opening_balance: float

class Div7aRepayment(BaseModel):
	date: datetime.date
	amount: float

class Div7aRepayments(BaseModel):
	relevant_repayments: list[Div7aRepayment]
	


logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# set root logger level to DEBUG and output to console
ch = logging.StreamHandler()

# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)





# @csrf_exempt
# def sparql_proxy(request):
# 	if request.method == 'POST':
# 		return JsonResponse({"x":agc().executeGraphQuery(request.body)})


import base64

def get_user(request: Request):
	# get user from header coming from caddy, which is Authorization: Basic <base64-encoded username:password>
	authorization = request.headers.get('Authorization', None)
	if authorization is not None:
		authorization = authorization.split(' ')
		if len(authorization) == 2 and authorization[0] == 'Basic':
			token = base64.b64decode('cm9idXN0OjQ3YjViYzE3ZTlmZjAzZjJjM2ZiYTg1MjAyMjFkNzM0MmY3ZTJkN2I3ZmZiZWZkNzFmODcxOGFj').decode()
			token.split(':')
			if len(token) == 2:
				return token[0] + '@basicauth'

	authorization = request.headers.get('X-Forwarded-Email', None)
	if authorization is not None:
		return authorization

	return 'nobody'




app = FastAPI(
	title="Robust API",
	summary="invoke accounting calculators and other endpoints",
	servers = [dict(url=os.environ['PUBLIC_URL'][:-1])],
	
)

import app.ai2 as ai2
import app.ai3 as ai3

app.mount('/ai2', ai2.app)
app.mount('/ai3', ai3.app)



def create_tmp_for_user(request: Request):
	user = get_user(request)
	name, path = create_tmp(user=user)
	write_htaccess(path)
	return name, path

def write_htaccess(path):
	with open(path / '.htaccess', 'w') as f:
		f.write("""\n""")
	

@app.get("/", include_in_schema=False)
async def read_root():
	"""
	nothing to see here
	"""
	return {"Hello": "World"}


#@app.get("/status")
#some status page for the whole stack here? like queue size, workers, .. 


@app.post("/health_check")
def post(request: Request):
	"""
	run an end-to-end healthcheck, internally invoking chat endpoint.
	"""
	r = json_prolog_rpc_call(request, {
		"method": "chat",
		"params": {"type":"sbe","current_state":[]}
	}, queue_name='health')
	if r == {"result":{"question":"Are you a Sole trader, Partnership, Company or Trust?","state":[{"question_id":0,"response":-1}]}}:
		return "ok"
	else:
		raise HTTPException(status_code=500, detail="self-test failed")


@app.post("/chat")
def post(body: ChatRequest, request: Request):
	"""
	invoke chat endpoint
	"""
	return json_prolog_rpc_call(request, {
		"method": "chat",
		"params": body.dict(),
	})


def json_prolog_rpc_call(request, msg, queue_name=None):
	msg["client"] = request.client.host
	return worker.call_remote_rpc_job(msg, queue_name).result.get(block=True, timeout=1000 * 1000)




def tmp_file_url(public_url, tmp_dir_name, fn):
	return public_url + '/tmp/' + tmp_dir_name + '/' + urllib.parse.quote(fn)



@app.get("/view/job/{job_id}", response_class=HTMLResponse)
async def views_limbo(request: Request, job_id: str, redirect:bool=True):
	"""
	job html page
	"""
	user = get_user(request)
	
	job = await get_job_by_id(job_id)
	if job is not None:
		if isinstance(job, str):
			job = dict(json=job)

		if redirect and job.get('status') == 'Success' and 'reports' in job.get('result'):
			return RedirectResponse(find_report_by_key(job['result']['reports'], 'task_directory'))
		else:
			mem_txt,mem_data = write_mem_stuff(job.get('message_id'))
			server_info_url = os.environ['PUBLIC_URL'] + '/static/git_info.txt'

			# it turns out that failures are not permanent
			return templates.TemplateResponse("job.html", {
				"server_info": server_info_url, 
				"mem_txt": mem_txt, 
				"mem_data":mem_data, 
				"request": request, 
				"job_id": job_id, 
				"json": json.dumps(job, indent=4, sort_keys=True), 
				"refresh": (job.get('status') not in [ 'Success']), 
				'status': job.get('status', 'internal error')})


def write_mem_stuff(message_id):
	if message_id is None:
		return '',[]
	else:
			mem_txt = ''
			for f in P(get_tmp_directory_absolute_path(job['message_id'])).glob('*/mem_prof.txt'):
				if str(f).endswith('/completed/mem_prof.txt'):
					continue
				logger.info('f: %s' % f)
				with open(f) as f2:
					mem_txt += f2.read()

			#logger.info(mem_txt)
			mem_data = []
			
			
			mmm = mem_txt.splitlines()
			for line in mmm:
				if line.startswith('MEM '):
					#logger.info(line)
					mem = float(line.split()[1])
					ts = float(line.split()[2])
					mem_data.append(dict(x=ts*1000,y=mem))
			return mem_txt,mem_data



@app.get('/api/job/{id}')
async def get_job_by_id(id: str):
	"""
	get job json
	"""
	r = requests.get(os.environ['REMOULADE_API'] + '/messages/states/' + id)
	if not r.ok:
		return None
	message = r.json()
	if message['actor_name'] not in ["local_calculator"]:
		return None

	#'2012-05-29T19:30:03.283Z'
	#"2023-09-21T10:16:44.571279+00:00",
	import dateutil.parser
	enqueued_datetime = dateutil.parser.parse(message['enqueued_datetime'])
	end_datetime = message.get('end_datetime', None)
	if end_datetime is not None:
		end_datetime = dateutil.parser.parse(end_datetime)
		message['duration'] = str(end_datetime - enqueued_datetime)

	# a dict with either result or error key (i think...)
	result = requests.get(os.environ['REMOULADE_API'] + '/messages/result/' + id, params={'max_size':'99999999','raise_on_error':False})
	try:
		result = result.json()
	except Exception as e:
		logger.info('nonsense received from remoulade api:')
		logger.info('result: %s' % result.text)
		logger.info('error: %s' % e)

	if 'result' in result:
		try:
			message['result'] = json.loads(result['result'])
		except:
			return result['result']
	else:
		message['result'] = {}
		
	return message



@app.post("/reference")
def reference(request: Request, fileurl: str = Form(...)):#: Annotated[str, Form()]):
	"""
	Trigger a calculator by submitting an URL of an input file.
	"""
	# todo, we should probably instead implement this as a part of "preprocessing" the uploaded content, that is, there'd be a "reference" type of "uploaded file", and the referenced url should then also be retrieved in a unified way along with retrieving for example xbrl taxonomies referenced by xbrl files.

	url = urllib.parse.urlparse(fileurl)
	netloc = url.netloc
	logger.info('/reference url: ' + str(url))
	logger.info('netloc: ' + str(netloc))

	# is this a onedrive url? 5dd1qg.dm.files.1drv.com
	#if not netloc.endswith(        "db.files.1drv.com"):
	
	#if not netloc.endswith(".files.1drv.com"):
	#	return {"error": "only onedrive urls are supported at this time"}

	r = requests.get(fileurl)
	request_tmp_directory_name, request_tmp_directory_path = create_tmp_for_user(request)
	
	# save r into request_tmp_directory_path
	fn = request_tmp_directory_path + '/file1.xlsx' # hack! we assume everything coming through this endpoint is an excel file
	with open(fn, 'wb') as f:
		f.write(r.content)

	r = process_request(request, request_tmp_directory_name, request_tmp_directory_path)[1]

	jv = find_report_by_key(r['reports'], 'job_view_url')
	if jv is not None:
		return RedirectResponse(jv, status_code=status.HTTP_303_SEE_OTHER)

	return r

	


@app.post("/upload")
def upload(request: Request, file1: Optional[UploadFile]=None, file2: Optional[UploadFile]=None, request_format:str='rdf', requested_output_format:str='job_handle'):
	"""
	Trigger a calculator by uploading one or more input files.
	"""
	
	request_tmp_directory_name, request_tmp_directory_path = create_tmp_for_user(request)

	for file in filter(None, [file1, file2]):
		logger.info('uploaded: %s' % file.filename)
		uploaded = save_uploaded_file(request_tmp_directory_path, file)

	return process_request(request, request_tmp_directory_name, request_tmp_directory_path, request_format, requested_output_format)[0]




def process_request(request, request_tmp_directory_name, request_tmp_directory_path, request_format='rdf', requested_output_format = 'job_handle'):
	
	public_url=os.environ['PUBLIC_URL']

	request_json = os.path.join(request_tmp_directory_path, 'request.json')
	if os.path.exists(request_json):
		with open(request_json) as f:
			options = json.load(f).get('worker_options', {})
	else:
		logger.info('no %s' % request_json)
		options = None
	logger.info('options: %s' % str(options))

	user = get_user(request)

	job = worker.trigger_remote_calculator_job(
		request_format=request_format,
		request_directory=request_tmp_directory_name,
		public_url=public_url,
		worker_options=options | dict(user=user)  
	)

	logger.info('requested_output_format: %s' % requested_output_format)

	# the immediate modes should be removed, they are only legacy excel plugin stuff
	if requested_output_format == 'immediate_xml':
			reports = job.result.get(block=True, timeout=1000 * 1000)
			logger.info(str(reports))
			# was this an error?
			if reports['alerts'] != []:
				if 'reports' in reports:
					taskdir = '<task_directory>' + find_report_by_key(reports['reports'], 'task_directory') + '</task_directory>'
				else:
					taskdir = '<job_id>'+job.message_id+'</job_id>'
				error_xml_text = (
						'<error>' +
						'<message>' + '. '.join(reports['alerts']) + '</message>' +
						taskdir +
						'</error>')
				return PlainTextResponse(error_xml_text, status_code=500), error_xml_text
			return RedirectResponse(find_report_by_key(reports['reports'], 'result')), None
	elif requested_output_format == 'immediate_json_reports_list':
			reports = job.result.get(block=True, timeout=1000 * 1000)
			return RedirectResponse(find_report_by_key(reports['reports'], 'task_directory') + '/000000_response.json.json'), reports
	elif requested_output_format == 'job_handle':
		jsn = {
			"alerts": ["job scheduled."],
			"reports":
				[{
					"title": "job URL",
					"key": "job_tmp_url",
					"val": {"url": job_tmp_url(job)}},
					{
						"title": "job API URL",
						"key": "job_api_url",
						"val": {"url": public_url + '/api/job/' + job.message_id}},
					{
						"title": "job view URL",
						"key": "job_view_url",
						"val": {"url": public_url + '/view/job/' + job.message_id}},
				]
		}
		return JSONResponse(jsn), jsn
	else:
		raise Exception('unexpected requested_output_format')


def save_uploaded_file(tmp_directory_path, src):
	logger.info('src: %s' % src.filename)
	dest = os.path.abspath('/'.join([tmp_directory_path, ntpath.basename(src.filename)]))
	with open(dest, 'wb+') as dest_fd:
		shutil.copyfileobj(src.file, dest_fd)
	return dest





	


# also: def fill_workbook_with_template():
	# either generate a xlsx file and return it to client, to be saved to onedrive (or to overwrite the selected onedrive xlsx file)
	# or run a direct request to msft graph api here


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
	return PlainTextResponse(str(exc), status_code=400)



def job_tmp_url(job):
	public_url = os.environ['PUBLIC_URL']
	return tmp_file_url(public_url, job.message_id, '')



@app.get('/.well-known/ai-plugin.json')
async def ai_plugin_json():
	return {
    "schema_version": "v1",
    "name_for_human": "Div7A",
    "name_for_model": "Div7A",
    "description_for_human": "Plugin for calculating loan summary, including minimum repayment and loan balance, under Division 7A.",
    "description_for_model": "Plugin for calculating loan summary, including minimum repayment and loan balance, under Division 7A.",
    "auth": {
      "type": "none"
    },
    "api": {
      "type": "openapi",
      "url": os.environ['PUBLIC_URL'] + "openapi.json"
    },
    "logo_url": os.environ['PUBLIC_URL'] + "static/logo.png",
    "contact_email": "ook519951@gmail.com",
    "legal_info_url": "https://github.com/lodgeit-labs/accounts-assessor/"
  }



#  >> curl -H "Content-Type: application/json" -X GET "http://localhost:7788/div7a?loan_year=2000&full_term=7&enquiry_year=2005&lodgement_date=2001-04-23" -d '{"starting_amount":{"principal":10000},"repayments":[]}'
#  {"OpeningBalance":13039.97419956,"InterestRate":7.05,"MinYearlyRepayment":4973.4437243,"TotalRepayment":0.0,"RepaymentShortfall":4973.4437243,"TotalInterest":919.31818107,"TotalPrincipal":0.0,"ClosingBalance":13039.97419956}⏎
#

# starting_amount: Annotated[Div7aOpeningBalanceForCalculationYear | Div7aPrincipal, Query(title="Either loan principal amount, as of loan start year, or the opening balance as of enquiry_year")],
# repayments: list[Div7aRepayment],
#repayments: Annotated[Div7aRepayments, Query(title="exhaustive list of repayments performed in enquiry year")],
# repayments: Annotated[Div7aRepayments, Query(title="exhaustive list of repayments performed in enquiry year")],


@app.post('/div7a')
async def div7a(
	loan_year: Annotated[int, Query(title="The income year in which the amalgamated loan was made")],
	full_term: Annotated[int, Query(title="The length of the loan, in years")],
	enquiry_year: Annotated[int, Query(title="The income year to calculate the summary for")],
	
	opening_balance: Annotated[float, Query(title="Opening balance of enquiry_year")],
	#opening_balance_year: int,
	
	# hack, OpenAI does not like a naked list for body
	repayments: Div7aRepayments,
	lodgement_date: Annotated[Optional[datetime.date], Query(title="Date of lodgement of the income year in which the loan was made. Required for calculating for the first year of loan.")]

):
	
	"""
	calculate Div7A loan summary
	"""

	request_tmp_directory_name, request_tmp_directory_path = create_tmp()

	with open(request_tmp_directory_path + '/ai-request.xml', 'wb') as f:

		# if isinstance(starting_amount, Div7aOpeningBalanceForCalculationYear):
		# 	ob = starting_amount.opening_balance
		# 	principal = None
		# elif isinstance(starting_amount, Div7aPrincipal):
		# 	ob = None
		# 	principal = starting_amount.principal
		principal=None
		ob=opening_balance

		logger.info('rrrr %s' % repayments)
		
		x = div7a_request_xml(loan_year, full_term, lodgement_date, ob, principal, repayments.relevant_repayments, enquiry_year)
		f.write(x.toprettyxml(indent='\t').encode('utf-8'))

	reports = process_request(request_tmp_directory_name, request_tmp_directory_path, request_format='xml', requested_output_format = 'immediate_json_reports_list')[1]

	if reports['alerts'] != []:
		e = '. '.join(reports['alerts'])
		if 'reports' in reports:
			e += ' - ' + find_report_by_key(reports['reports'], 'task_directory')
		else:
			e += ' - ' + job.message_id
		return JSONResponse(dict(error=e))

	result_url = find_report_by_key(reports['reports'], 'result')
	expected_prefix = os.environ['PUBLIC_URL'] + '/tmp/'
	if not result_url.startswith(expected_prefix):
		raise Exception('unexpected result_url prefix: ' + result_url)

	xml = ElementTree.parse(get_tmp_directory_absolute_path(result_url[len(expected_prefix):]))
	j = {}
	for tag in ['OpeningBalance','InterestRate','MinYearlyRepayment','TotalRepayment','RepaymentShortfall','TotalInterest','TotalPrincipal','ClosingBalance']:
		j[tag] = float(xml.find(tag).text)
	
	return j


def div7a_request_xml(
		income_year_of_loan_creation,
		full_term_of_loan_in_years,
		lodgement_day_of_private_company,
		opening_balance,
		principal,
		repayment_dicts,
		income_year_of_computation
):
	"""
	create a request xml dom, given loan details.	 
	"""

	doc = impl.createDocument(None, "reports", None)
	loan = doc.documentElement.appendChild(doc.createElement('loanDetails'))

	agreement = loan.appendChild(doc.createElement('loanAgreement'))
	repayments = loan.appendChild(doc.createElement('repayments'))

	def field(name, value):
		field = agreement.appendChild(doc.createElement('field'))
		field.setAttribute('name', name)
		field.setAttribute('value', str(value))

	field('Income year of loan creation', income_year_of_loan_creation)
	field('Full term of loan in years', full_term_of_loan_in_years)
	if lodgement_day_of_private_company is not None:
		field('Lodgement day of private company', (lodgement_day_of_private_company))
	field('Income year of computation', income_year_of_computation)

	if opening_balance is not None:
		field('Opening balance of computation', opening_balance)
	if principal is not None:
		field('Principal amount of loan', principal)

	for r in repayment_dicts:
		repayment = repayments.appendChild(doc.createElement('repayment'))
		repayment.setAttribute('date', python_date_to_xml(r.date))
		repayment.setAttribute('value', str(r.amount))

	return doc


def python_date_to_xml(date):
	y = date.year
	m = date.month
	d = date.day
	if not (0 < m <= 12):
		raise Exception(f'invalid month: {m}')
	if not (0 < d <= 31):
		raise Exception(f'invalid day: {d}')
	if not (1980 < y <= 2050):
		raise Exception(f'invalid year: {y}')
	return f'{y}-{m:02}-{d:02}' # ymd

