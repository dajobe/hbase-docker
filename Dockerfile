# HBase
#
# Version 0.1

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu
MAINTAINER Dave Beckett <dave@dajobe.org>

# make sure the package repository is up to date
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install build requirements
# DEBIAN_FRONTEND=noninteractive
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl build-essential openjdk-6-jdk

RUN mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://www.apache.org/dist/hbase/hbase-0.94.11/hbase-0.94.11.tar.gz"
RUN cd /opt && tar xvfz /opt/downloads/hbase-0.94.11.tar.gz

# Data will go here (see hbase-site.xml)
RUN mkdir -p /data/hbase

ADD root-profile /root/.profile

ADD hbase-site.xml /opt/hbase-0.94.11/conf/hbase-site.xml

ADD hbase-server /opt/hbase-server

# Thrift API
EXPOSE 9090
# Thrift Web UI
EXPOSE 9095
# HBase uses it's own internal zookeeper; no need to expose it?
# EXPOSE 2181
# HBase Master API port
EXPOSE 60000
# HBase Master web UI at :60010/master-status;  ZK at :60010/zk.jsp
EXPOSE 60010
# Region server API port
EXPOSE 60020
# HBase Region server web UI at :60030/rs-status
EXPOSE 60030

CMD ["/opt/hbase-server"]
