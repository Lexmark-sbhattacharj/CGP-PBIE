import docker
import tarfile
import time
import os
import subprocess 
from subprocess import Popen, PIPE
from io import BytesIO
import pgdumplib

################################################################
# Source DB
################################################################
SOURCE_HOST=os.environ['SOURCE_HOST']
SOURCE_PORT=os.environ['SOURCE_PORT']
SOURCE_DBNAME=os.environ['SOURCE_DBNAME']
SOURCE_USERNAME=os.environ['SOURCE_USERNAME']
SOURCE_PASSWORD=os.environ['SOURCE_PASSWORD']
SOURCE_POSTGRES_DOCKER_IMAGE=os.environ['SOURCE_POSTGRES_DOCKER_IMAGE']

################################################################
# Destination DB
################################################################
DESTINATION_HOST=os.environ['DESTINATION_HOST']
DESTINATION_PORT=os.environ['DESTINATION_PORT']
DESTINATION_DBNAME=os.environ['DESTINATION_DBNAME']
DESTINATION_USERNAME=os.environ['DESTINATION_USERNAME']
DESTINATION_PASSWORD=os.environ['DESTINATION_PASSWORD']
DESTINATION_POSTGRES_DOCKER_IMAGE=os.environ['DESTINATION_POSTGRES_DOCKER_IMAGE']

PG_DUMPFILE=os.environ['PG_DUMPFILE']

def write_file_to_container(container, file_name, file_data, dest_path):
  pw_tarstream = BytesIO()
  pw_tar = tarfile.TarFile(fileobj=pw_tarstream, mode='w')
  tarinfo = tarfile.TarInfo(name=file_name)
  tarinfo.size = len(file_data)
  tarinfo.mtime = time.time()
  pw_tar.addfile(tarinfo, BytesIO(file_data))
  pw_tar.close()
  pw_tarstream.seek(0)
  container.put_archive(dest_path, pw_tarstream)

def pg_dump():
  docker_client = docker.from_env()
  pg_pass = f"echo '{SOURCE_HOST}:{SOURCE_PORT}:{SOURCE_DBNAME}:{SOURCE_USERNAME}:{SOURCE_PASSWORD}' > ~/.pgpass && chmod 600 ~/.pgpass"
  command = f"{pg_pass} && pg_dump -Fc -v --host={SOURCE_HOST} --username={SOURCE_USERNAME} --port={SOURCE_PORT} --dbname={SOURCE_DBNAME} -f {PG_DUMPFILE}"
  env=["POSTGRES_PASSWORD=mysecretpassword", "PGSSLMODE=require"]
  container = docker_client.containers.run(SOURCE_POSTGRES_DOCKER_IMAGE, environment=env, detach=True)

  write_file_to_container(container, 'run.sh', command.encode('utf8'), "/root/")
  resp = container.exec_run(cmd=["/bin/sh", "run.sh"], workdir="/root/")
  print(resp)

  process = subprocess.Popen(["docker", "cp", f"{container.id}:/root/{PG_DUMPFILE}", "."], stdout=subprocess.PIPE)
  stdout = process.communicate()[0]
  print(stdout)
  container.stop()

def pg_restore():
  docker_client = docker.from_env()

  pg_pass = f"echo '{DESTINATION_HOST}:{DESTINATION_PORT}:{DESTINATION_DBNAME}:{DESTINATION_USERNAME}:{DESTINATION_PASSWORD}' > ~/.pgpass && chmod 600 ~/.pgpass"
  command = f"{pg_pass} && pg_restore -v --host={DESTINATION_HOST} --clean --no-acl --no-owner --username={DESTINATION_USERNAME} --port={DESTINATION_PORT} --dbname={DESTINATION_DBNAME} {PG_DUMPFILE}"
  env=["POSTGRES_PASSWORD=mysecretpassword", "PGSSLMODE=disable"]
  container = docker_client.containers.run(DESTINATION_POSTGRES_DOCKER_IMAGE, environment=env, detach=True)

  resp = subprocess.call(["docker", "cp", PG_DUMPFILE, f"{container.id}:/root/{PG_DUMPFILE}"], stdin=PIPE, stdout=PIPE, stderr=PIPE)
  print(resp)

  write_file_to_container(container, 'run.sh', command.encode('utf8'), "/root/")

  resp = container.exec_run(cmd=["/bin/sh", "run.sh"], workdir="/root/")
  print(resp)
  container.stop()


if os.path.exists(PG_DUMPFILE):
  pg_restore()
else:
  pg_dump()
