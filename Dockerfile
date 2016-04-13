# HBase in Docker
#
# Version 0.3

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu
MAINTAINER Dave Beckett <dave@dajobe.org>

COPY *.sh /build/

ENV HBASE_VERSION 1.1.4

RUN /build/prepare-hbase.sh && \
    cd /opt/hbase && /build/build-hbase.sh \
    cd / && /build/cleanup-hbase.sh && rm -rf /build

VOLUME /data

ADD ./hbase-site.xml /opt/hbase/conf/hbase-site.xml

ADD ./zoo.cfg /opt/hbase/conf/zoo.cfg

ADD ./hbase-server /opt/hbase-server

# REST API
EXPOSE 8080
# Thrift API
EXPOSE 9090
# Thrift Web UI
EXPOSE 9095
# HBase's zookeeper - used to find servers
EXPOSE 2181
## HBase Master API port ??
#EXPOSE 16000
# HBase Master web UI at :15010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010
# Region server API port
EXPOSE 16020
# HBase Region server web UI at :16030/rs-status
EXPOSE 16030

CMD ["/opt/hbase-server"]
