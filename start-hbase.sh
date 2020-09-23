#!/bin/bash -e
#
# Script to start docker and update the /etc/hosts file to point to
# the hbase-docker container
#
# hbase thrift and master server logs are written to the local
# logs directory
#

IMAGE_NAME="dajobe/hbase"
CONTAINER_NAME="hbase-docker"

program=$(basename "$0")

echo "$program: Starting HBase container"
data_dir="$PWD/data"
rm -rf "$data_dir"
mkdir -p "$data_dir"

# force kill any existing container
docker rm -f "${CONTAINER_NAME}" >/dev/null

id=$(docker run --name=${CONTAINER_NAME} -h ${CONTAINER_NAME} -d -P -v "$data_dir:/data" "$IMAGE_NAME")

echo "$program: Container has ID $id"

# Get the hostname and IP inside the container
docker inspect "$id" > config.json

trap "rm -f config.json; exit 0" INT QUIT

docker_hostname=$(python -c 'from __future__ import print_function; import json; c=json.load(open("config.json")); print(c[0]["Config"]["Hostname"])')
docker_ip=$(python -c 'from __future__ import print_function; import json; c=json.load(open("config.json")); print(c[0]["NetworkSettings"]["IPAddress"])')

hosts_hbase_docker_ip=$(awk "{if(\$2 == \"${docker_hostname}\") { print \$1 }}" /etc/hosts)
if [ "$hosts_hbase_docker_ip" == "$docker_ip" ]; then
  echo "$program: /etc/hosts already contains ${docker_hostname} hostname and IP"
else
  echo "$program: Updating /etc/hosts to make ${docker_hostname} point to $docker_ip ($docker_hostname)"
  echo "$program: Running sudo - expect to type your password"
  if [ "$hosts_hbase_docker_ip" == "" ]; then
    echo "docker_ip ${CONTAINER_NAME} $docker_hostname" | \
      sudo tee -a /etc/hosts > /dev/null
  else
    sudo sed -i.bak "s/^.*${CONTAINER_NAME}.*\$/$docker_ip ${CONTAINER_NAME} $docker_hostname/" /etc/hosts
  fi
fi

declare -a config=(
  "REST API@8080@api"
  "REST UI@8085@web"
  "Thrift API@9090@api"
  "Thrift UI@9095@web"
  "Zookeeper API@2181@api"
  "Master UI@16010@web"
)

echo "$program: Connect to HBase at localhost on these ports"
for config_data in "${config[@]}"; do
  IFS=@ read -r label port type <<< "$config_data"

  mapped_port=$(python -c "from __future__ import print_function; import json; c=json.load(open(\"config.json\")); print(c[0][\"NetworkSettings\"][\"Ports\"][\"${port}/tcp\"][0][\"HostPort\"])")
  key="127.0.0.1:$mapped_port"
  if [ "$type" == "web" ]; then
    key="http://${key}/"
  fi
  printf "  %-15s %s\n"  "$label" "$key"
done
echo ""
echo "$program: OR Connect to HBase on container ${docker_hostname}"
for config_data in "${config[@]}"; do
  IFS=@ read -r label port type <<< "$config_data"

  key="${docker_hostname}:$port"
  if [ "$type" == "web" ]; then
    key="http://${key}/"
  fi
  printf "  %-15s %s\n"  "$label" "$key"
done
echo ""
echo "$program: For docker status:"
echo "$program: $ id=$id"
echo "$program: $ docker inspect \$id"
