IMAGE_NAME=dajobe/hbase
IMAGE_TAG=latest

HBASE_VERSION=$(shell awk '/^ENV HBASE_VERSION/ {print $3}' Dockerfile)

build:
	@echo "Building hbase docker image $(HBASE_VERSION)"
	docker build -t $(IMAGE_NAME) .

# This won't work unless you have already set up the repository config
push:
	@echo "Pushing image to https://hub.docker.com/"
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
