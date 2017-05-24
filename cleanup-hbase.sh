#!/bin/sh -xe

. /build/config-hbase.sh

AUTO_ADDED_PACKAGES=`apt-mark showauto`

apt-get remove --purge -y $HBASE_BUILD_PACKAGES $AUTO_ADDED_PACKAGES

# Install the run-time dependencies
apt-get install $minimal_apt_get_args $HBASE_RUN_PACKAGES

# . /build/cleanup.sh
rm -rf /tmp/* /var/tmp/*

apt-get clean
rm -rf /var/lib/apt/lists/*
