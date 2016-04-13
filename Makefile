HBASE_VERSION=$(shell awk '/^ENV HBASE_VERSION/ {print $3}' Dockerfile)

build:
	@echo "Building hbase-docker $(HBASE_VERSION)"
	docker build -t dajobe/hbase .
