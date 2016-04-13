# This file intended to be sourced

# . /build/config.sh

# Prevent initramfs updates from trying to run grub and lilo.
export INITRD=no
export DEBIAN_FRONTEND=noninteractive
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

minimal_apt_get_args='-y --no-install-recommends'


## Build time dependencies ##

HBASE_BUILD_PACKAGES="curl"

# Core list from docs
#HBASE_BUILD_PACKAGES="$HBASE_BUILD_PACKAGES "

# Optional:
#HBASE_BUILD_PACKAGES="$HBASE_BUILD_PACKAGES "

## Run time dependencies ##
HBASE_RUN_PACKAGES="openjdk-7-jdk"
