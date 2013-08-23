# HBase
#
# Version 0.1

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu
MAINTAINER Dave Beckett <dave@dajobe.org>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install build requirements
# DEBIAN_FRONTEND=noninteractive
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl build-essential openjdk-6-jdk

RUN mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://www.apache.org/dist/hbase/hbase-0.94.10/hbase-0.94.10.tar.gz"
RUN cd /opt && tar xvfz /opt/downloads/hbase-0.94.10.tar.gz

# Data will go here (see hbase-site.xml)
RUN mkdir -p /data/hbase

ADD root-profile /root/.profile

RUN mkdir -p /opt/hbase-0.94.10/conf
ADD hbase-site.xml /opt/hbase-0.94.10/conf/hbase-site.xml

ADD hbase-server /opt/hbase-server

# HBase uses it's own internal zookeeper; no need to expose it?
# EXPOSE 2181
# HBase Master status at :60010/master-status
EXPOSE 60010
# HBase Region server at :60030/rs-status
EXPOSE 60030

CMD ["/opt/hbase-server"]
