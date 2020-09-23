#!/usr/bin/env python3
#
# Script to start hbase-docker and update the /etc/hosts file to
# point to the hbase-docker container
#
# hbase thrift and master server logs are written to the
# startup-relative 'data/logs' directory
#

import json
import logging
import os
import os.path
from shutil import (rmtree)
from subprocess import (check_output, run)


# Image
IMAGE_NAME = 'dajobe/hbase'

# Docker container name to use
CONTAINER_NAME = 'hbase-docker'

# Maps to $PWD/data
DATA_DIR_IN_CONTAINER = '/data'

# List of Tuples of (Label, Port number, use: api or web)
CONFIG = [
  ('REST API', 8080, 'api'),
  ('REST UI', 8085, 'web'),
  ('Thrift API', 9090, 'api'),
  ('Thrift UI', 9095, 'web'),
  ('Zookeeper API', 2181, 'api'),
  ('Master UI', 16010, 'web'),
]



def main():
  ''' Start HBase in docker '''

  logging.basicConfig()
  #logging.basicConfig(level=logging.DEBUG)

  cwd = os.getcwd()
  data_dir = os.path.join(cwd, 'data')

  # Set up data directory
  if os.path.exists(data_dir):
    rmtree(data_dir, ignore_errors=False)
  if not os.path.exists(data_dir):
    os.makedirs(data_dir)

  # force kill any existing container
  cmd = ['docker', 'rm', '-f', CONTAINER_NAME]
  logging.debug(cmd)
  # Do not care about output (or exit code)
  run(cmd, check=False)

  print('Starting HBase container')
  cmd = ['docker', 'run',
	 f'--name={CONTAINER_NAME}', '-h', CONTAINER_NAME,
	 '-d', '-P', '-v', f'{data_dir}:{DATA_DIR_IN_CONTAINER}', IMAGE_NAME]
  logging.debug(cmd)
  container_id = check_output(cmd, encoding='utf-8').strip()

  print(f'Container has ID {container_id}')

  # Get the container configuration
  cmd = ['docker', 'inspect', container_id]
  logging.debug(cmd)
  config_json = check_output(cmd, encoding='utf-8')
  logging.debug(config_json)
  config = json.loads(config_json)
  logging.debug(json.dumps(config))

  docker_hostname = config[0]['Config']['Hostname']
  docker_ip = config[0]['NetworkSettings']['IPAddress']

  hosts_hbase_docker_ip = ''
  with open('/etc/hosts') as hosts_file:
    for line in hosts_file.readlines():
      fields = line.split()
      if len(fields) > 2 and fields[1] == docker_hostname:
        hosts_hbase_docker_ip = fields[0]
        break

  if hosts_hbase_docker_ip == docker_ip:
    print(f'/etc/hosts already contains {docker_hostname} hostname and IP')
  else:
    print(f'Updating /etc/hosts to make {docker_hostname} point to {docker_ip} ({docker_hostname})')
    print('Running sudo - expect to type your password')
    if hosts_hbase_docker_ip == '':
      cmd_input = f'docker_ip {CONTAINER_NAME} {docker_hostname}'
      cmd = ['sudo', 'tee', '-a', '/etc/hosts']
      run(cmd, input=cmd_input, check=True)
    else:
      sed_script = \
        f's/^.*{CONTAINER_NAME}.*$/{docker_ip} {CONTAINER_NAME} {docker_hostname}/'
      cmd = ['sudo', 'sed', '-i.bak', sed_script, '/etc/hosts']
      run(cmd, check=True)

  hostname = 'localhost'
  print(f'\nConnect to HBase at {hostname} on these endpoints')
  for cfg in CONFIG:
    (label, port, typ) = cfg

    mapped_port = config[0]['NetworkSettings']['Ports'][f'{port}/tcp'][0]['HostPort']
    key = f'{hostname}:{mapped_port}'
    if typ == 'web':
      key = f'http://{key}/'
    print(f'  {label:<15} {key}')

  hostname = docker_hostname
  print(f'\nOR Connect to HBase on container {hostname} at these endpoints')
  for cfg in CONFIG:
    (label, port, typ) = cfg

    key = f'{hostname}:{port}'
    if typ == 'web':
      key = f'http://{key}/'
    print('  {0:<15s} {1:s}'.format(label, key))

  print('\nFor docker status:')
  print(f'$ id={container_id}')
  print('$ docker inspect $id')


if __name__ == '__main__':
  main()
