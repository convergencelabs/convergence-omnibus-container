FROM openjdk:8u191-jdk-alpine3.8

MAINTAINER Convergence Labs, Inc (sysadmin@convergencelabs.com)

RUN apk add --update supervisor tar curl nginx bash && \
    rm  -rf /tmp/* /var/cache/apk/*

##
## Orient DB
##

ENV ORIENTDB_VERSION 3.0.15
ENV ORIENTDB_DOWNLOAD_MD5 ae67b025b5799b55248078cd80b8c9be
ENV ORIENTDB_DOWNLOAD_SHA1 93c97ea94c3c9beff8fa075011374be34c6e5c2b

ENV ORIENTDB_DOWNLOAD_URL http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz

# download distribution tar, untar and delete databases
RUN mkdir /orientdb && \
  wget  $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1 \
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*

COPY orientdb-server-config.xml /orientdb/config/

##
## Proxy
##

RUN adduser -D -g 'www' www  && \
    mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

COPY index.html /www/index.html
COPY nginx.conf /etc/nginx/nginx.conf

COPY supservisord.conf /etc/supervisord.conf

##
## Convergence Admin console
##

COPY admin-console /www/console
COPY convergence-admin-console.config.js /www/console/convergence-admin-console.config.js

##
## Convergence Client
##
COPY client /www/client

##
## Convergence Server
##

COPY convergence-server-node.tgz /tmp/convergence-server-node.tgz
RUN mkdir /convergence && \
    tar -zxvf /tmp/convergence-server-node.tgz -C /convergence --strip-components=1
COPY log4j2.xml /convergence/etc/log4j2.xml
COPY convergence-server.conf /convergence/etc/convergence-server.conf


EXPOSE 80
EXPOSE 2480

VOLUME /orientdb/databases

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
