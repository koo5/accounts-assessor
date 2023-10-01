import os, sys, subprocess, logging
import urllib.parse
import json
import datetime
import ntpath
import shutil, shlex, subprocess
from typing import Optional, Any
from fastapi import FastAPI, Request, File, UploadFile
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import requests

log = logging.getLogger(__name__)

app = FastAPI()


from . import account_hierarchy


@app.post("/arelle_extract")
def arelle_extract(taxonomy_locator: str):
	return account_hierarchy.ArelleController().run(taxonomy_locator)


@app.get("/")
def index():
	return "ok"



from pydantic import BaseModel


class ShellRequest(BaseModel):
    cmd: list[str]

@app.post("/shell")
def shell(shell_request: ShellRequest):
	cmd = [shlex.quote(x) for x in shell_request.cmd]
	print(cmd)
	#p = subprocess.Popen(cmd, universal_newlines=True)  # text=True)
	p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,universal_newlines=True)#text=True)
	(stdout,stderr) = p.communicate()
	if p.returncode == 0:
		status = 'ok'
	else:
		status = 'error'
	return JSONResponse({'status':status,'stdout':stdout,'stderr':stderr})



import xmlschema
schemas = {}

def parse_schema(xsd):
	return xmlschema.XMLSchema(xsd)

def get_schema(xsd):
	if xsd in schemas:
		schema = schemas[xsd]
	else:
		schema = parse_schema(xsd)
		schemas[xsd] = schema
	return schema

@app.post('/xml_xsd_validator')
def xml_xsd_validator(xml: str, xsd:str):
	""" fixme: limit these to some directories / hosts... """
	schema = get_schema(xsd)
	response = {}
	try:
		schema.validate(xml)
		response['result'] = 'ok'
	except Exception as e:
		response['error_message'] = str(e)
		response['error_type'] = str(type(e))
		response['result'] = 'error'
	return JSONResponse(response)


@app.post('/fetch_remote_file')
def fetch_remote_file(tmp_dir_path: str, url: str):
	path = tmp_dir_path / 'remote_files'
	path.mkdir(exist_ok=True)
	path = path / str(len(glob.glob(path + '/*')))

	proc = subprocess.run(['wget', url], cwd=path, stdout=PIPE, stderr=subprocess.STDOUT, text=True)
	files = path.glob('*')

	if len(files) == 1:
		return JSONResponse(dict(result = 'ok', file_name=str(path / files[0])))
	else:
		return JSONResponse(dict(result = 'error', error_message = proc.stdout))
