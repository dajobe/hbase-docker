# HBase
#
# Version 0.1

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu
MAINTAINER Dave Beckett <dave@dajobe.org>

# make sure the package repository is up to date
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

# Install build requirements
RUN apt-get update
RUN apt-get install -y build-essential curl openjdk-6-jdk

# Download and Install HBase
ENV HBASE_VERSION 0.94.11

RUN mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://www.apache.org/dist/hbase/hbase-$HBASE_VERSION/hbase-$HBASE_VERSION.tar.gz"
RUN cd /opt && tar xvfz /opt/downloads/hbase-$HBASE_VERSION.tar.gz
RUN mv /opt/hbase-$HBASE_VERSION /opt/hbase

# Data will go here (see hbase-site.xml)
RUN mkdir -p /data/hbase /opt/hbase/logs

ENV JAVA_HOME /usr/lib/jvm/java-6-openjdk-amd64
ENV HBASE_SERVER /opt/hbase/bin/hbase

ADD ./hbase-site.xml /opt/hbase/conf/hbase-site.xml

ADD ./hbase-server /opt/hbase-server


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
