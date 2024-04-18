import ntpath
import time,os,datetime
import agraph
import shutil
from pathlib import PurePath
from auth import write_htaccess
from tmp_dir_path import get_tmp_directory_absolute_path, git


from atomic_integer import AtomicInteger
server_started_time = time.time()
client_request_id = AtomicInteger()



def get_unique_id():
	"""
	https://github.com/lodgeit-labs/accounts-assessor/issues/25
	"""
	return 'x'+str(agraph.agc().createBNode().getId()[2:])


def create_tmp_directory_name():
	""" create a unique name """
	return '.'.join([
		'UTC' + datetime.datetime.utcnow().strftime('%Y_%m_%d__%H_%M_%S'),
		str(os.getpid()),
		str(client_request_id.inc()),
		get_unique_id()])


def create_tmp(name=None, exist_ok=False):
	if name is None:
		name = create_tmp_directory_name()
	full_path = get_tmp_directory_absolute_path(name)
	os.makedirs(full_path, exist_ok=exist_ok)
	return name, full_path


def create_tmp_for_user(user):
	name, path = create_tmp()
	write_htaccess(user, path)
	return name, path



def copy_request_files_to_tmp(tmp_directory_absolute_path, files):
	# request file paths, as passed to prolog
	files2 = []
	for f in files:
		# create new path where request file will be copied, copy it
		tmp_fn = os.path.abspath('/'.join([tmp_directory_absolute_path, ntpath.basename(f)]))
		shutil.copyfile(f,tmp_fn)
		files2.append(tmp_fn)
	return files2




def make_converted_dir(file):
	#log.info('make_converted_dir for conversion of: %s' % file)
	converted_dir = PurePath('/'.join(PurePath(file).parts[:-1] + ('converted',)))
	os.makedirs(converted_dir, exist_ok=True)
	return converted_dir
	


def copy_repo_status_txt_to_result_dir(result_tmp_path):
	shutil.copyfile(
		os.path.abspath(git('sources/static/git_info.txt')),
		os.path.join(result_tmp_path, 'git_info.txt'))


