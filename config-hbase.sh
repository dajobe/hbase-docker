# This file intended to be sourced

# . /build/config.sh

function get_closest_site() {

DISPATCHER_SITE="http://www.apache.org/dyn/closer.cgi/hbase/"

echo $(curl -s $DISPATCHER_SITE | grep strong | head -n 1 | sed 's|.*href="\(.\+\?\)".*|\1|')

}


# This is the definitive site and incredibly slow
HBASE_ORIG_DIST="http://archive.apache.org/dist/hbase"
HBASE_DIST=$HBASE_ORIG_DIST
# This is a mirror site and faster but every new release breaks all
# existing links.
# HBASE_DIST="https://www-us.apache.org/dist/hbase"
# Uncomment this line to download from the closest site:
#export USE_DISPATCHER=1

# Prevent initramfs updates from trying to run grub and lilo.
export INITRD=no
export DEBIAN_FRONTEND=noninteractive
export JAVA_HOME=/usr/lib/jvm/default-jvm


## Build time dependencies ##

HBASE_BUILD_PACKAGES="curl gnupg"

# Core list from docs
#HBASE_BUILD_PACKAGES="$HBASE_BUILD_PACKAGES "

# Optional:
#HBASE_BUILD_PACKAGES="$HBASE_BUILD_PACKAGES "

## Run time dependencies ##
HBASE_RUN_PACKAGES="openjdk-8-jre-headless"
