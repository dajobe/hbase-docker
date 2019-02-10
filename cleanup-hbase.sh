#!/bin/sh -xe

. /build/config-hbase.sh

apk del $HBASE_BUILD_PACKAGES

rm -rf /tmp/* /var/tmp/*

rm -rf /var/lib/apt/lists/*
