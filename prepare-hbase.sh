#!/bin/sh -xe

. /build/config-hbase.sh

apt-get update -y

apt-get install $minimal_apt_get_args $HBASE_BUILD_PACKAGES

cd /opt

curl -SL $HBASE_DIST/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -x -z && mv hbase-${HBASE_VERSION} hbase
