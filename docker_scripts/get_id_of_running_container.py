#!/usr/bin/env python3

try:
	import docker
	import click
except:
	print('please install: python3 -m pip install --user -U click docker')
	exit(1)


@click.command()
@click.option('-pp', '--port_postfix', type=str, required=True)
def run(port_postfix):

	client = docker.from_env()
	cs = [c for c in client.containers.list() if (c.status == 'running')]
	
	for c in cs:
		if c.attrs['Config']['Image'].startswith('koo5/internal-workers' + port_postfix):
			print(c.attrs['Id'])
			exit()
	exit(1)
	
if __name__ == '__main__':
    run()

