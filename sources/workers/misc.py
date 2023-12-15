import logging, shlex, os
from pathlib import PurePath

import requests


def convert_request_files(files):
	return list(filter(None, map(convert_request_file, files)))


def make_converted_dir(file):
	converted_dir = PurePath('/'.join(PurePath(file).parts[:-1] + ('converted',)))
	os.makedirs(converted_dir, exist_ok=True)
	return converted_dir


def convert_request_file(file):
	logging.getLogger().info('convert_request_file?: %s' % file)

	if file.endswith('/.htaccess'):
		return None
	if file.endswith('/request.json'):
		return None # effectively hide the file from further processing
	if file.endswith('/request.xml'):
		converted_dir = make_converted_dir(file)
		converted_file = Xml2rdf().xml2rdf(input_file, converted_dir)
		if converted_file is not None:
			return converted_file
	if file.lower().endswith('.xlsx'):
		converted_dir = make_converted_dir(file)
		converted_file = str(converted_dir.joinpath(str(PurePath(file).name) + '.n3'))
		convert_excel_to_rdf(file, converted_file)
		return converted_file
	else:
		return file


def convert_excel_to_rdf(uploaded, to_be_processed, root="ic_ui:investment_calculator_sheets"):
	"""run a POST request to csharp-services to convert the file"""
	logging.getLogger().info('xlsx_to_rdf: %s -> %s' % (uploaded, to_be_processed))
	requests.post(os.environ['CSHARP_SERVICES_URL'] + '/xlsx_to_rdf', json={"root": root, "input_fn": str(uploaded), "output_fn": str(to_be_processed)}).raise_for_status()




def uri_params(tmp_directory_name):
	# comment(RDF_EXPLORER_1_BASE, comment, 'base of uris to show to user in generated html')
	rdf_explorer_base = 'http://dev-node.uksouth.cloudapp.azure.com:10036/#/repositories/a/node/'
	rdf_explorer_base = 'http://localhost:10055/#/repositories/a/node/'
	#rdf_namespace_base = 'http://dev-node.uksouth.cloudapp.azure.com/rdf/'
	rdf_namespace_base = 'https://rdf.tmp/'
	request_uri = rdf_namespace_base + 'requests/' + tmp_directory_name
	return {
		"request_uri": request_uri,
		"rdf_namespace_base": rdf_namespace_base,
		"rdf_explorer_bases": [rdf_explorer_base]
	}


def env_string(dict):
	r = ""
	for k,v in dict.items():
		r += f"""{k}={shlex.quote(v)} \\\n"""
	return r

