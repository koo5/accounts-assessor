import json, os



#def env_or(json, key):
	#print(key, '=', os.environ.get(key), ' or ', json.get(key))
#	return os.environ.get(key) or json.get(key)

def secret(name):
	with open('/run/secrets/' + name, 'r') as x:
		return x.read()


def agc():
	AGRAPH_SECRET_HOST = secret('AGRAPH_SECRET_HOST')
	AGRAPH_SECRET_PORT = secret('AGRAPH_SECRET_PORT')
	AGRAPH_SECRET_USER = secret('AGRAPH_SUPER_USER')
	AGRAPH_SECRET_PASSWORD = secret('AGRAPH_SUPER_PASSWORD')

	if AGRAPH_SECRET_USER != None and AGRAPH_SECRET_PASSWORD != None:
		from franz.openrdf.connect import ag_connect
		#print(f"""ag_connect('a', host={AGRAPH_SECRET_HOST}, port={AGRAPH_SECRET_PORT}, user={AGRAPH_SECRET_USER},password={AGRAPH_SECRET_PASSWORD})""")
		r = ag_connect('a', host=AGRAPH_SECRET_HOST, port=AGRAPH_SECRET_PORT, user=AGRAPH_SECRET_USER, password=AGRAPH_SECRET_PASSWORD)
		r.setDuplicateSuppressionPolicy('spog')
		r.setNamespace('selftest', 'https://rdf.lodgeit.net.au/v1/selftest#')
		return r
	else:
		print('agraph user and pass must be provided')
		exit(1)
