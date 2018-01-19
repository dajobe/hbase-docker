#!/bin/sh -xe

. /build/config-hbase.sh

apk update
apk add bash $HBASE_BUILD_PACKAGES

mkdir -p /opt
cd /opt

if [ -n $USE_DISPATCHER ]
then
  HBASE_DIST=$(get_closest_site)
fi

# download package
curl -SLO $HBASE_DIST/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz 
# download PGP keys
curl -SLO $HBASE_ORIG_DIST/KEYS 
# download checksum
curl -SL $HBASE_ORIG_DIST/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz.asc -o download.asc

# validate the version
gpg --import KEYS
gpg --verify download.asc hbase-$HBASE_VERSION-bin.tar.gz

# finally unpack and cleanup
tar xzf hbase-$HBASE_VERSION-bin.tar.gz && mv hbase-${HBASE_VERSION} hbase
rm -f hbase-$HBASE_VERSION-bin.tar.gz KEYS download.asc
