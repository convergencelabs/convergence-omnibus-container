FROM alpine:3.9 as builder

RUN apk add --update tar curl jq

ENV TMPDIR=/tmp/convergence
RUN mkdir $TMPDIR

###
### Convergence Client Download
###

## npm view @convergence/convergence to get SHASUM
ENV CLIENT_VERSION 1.0.0-rc.7
ENV CLIENT_NPM_PACKAGE @convergence/convergence
ENV CLIENT_SHASUM 1b68fbb952b12c1daf956039691cbd46904337f3

ENV CLIENT_TMP_DIR=$TMPDIR/client
RUN mkdir $CLIENT_TMP_DIR

RUN wget -O - https://registry.npmjs.org/$CLIENT_NPM_PACKAGE/ | jq ".versions[\"$CLIENT_VERSION\"].dist" > $CLIENT_TMP_DIR/version.json

RUN TARBALL=`cat $CLIENT_TMP_DIR/version.json | jq .tarball -r` && \
    wget $TARBALL --output $CLIENT_TMP_DIR/convergence.tgz && \
    echo "$CLIENT_SHASUM *$CLIENT_TMP_DIR/convergence.tgz" | sha1sum -c - && \
    tar -zxvf $CLIENT_TMP_DIR/convergence.tgz -C $CLIENT_TMP_DIR


###
### Convergence Admin Console Download
###

## npm view @convergence/admin-console to get SHASUM
ENV CONSOLE_VERSION 1.0.0-rc.7
ENV CONSOLE_NPM_PACKAGE @convergence/admin-console
ENV CONSOLE_SHASUM d7e8436d5865812ed684719f6fb73868a9837fb8

ENV CONSOLE_TMP_DIR=$TMPDIR/console
RUN mkdir $CONSOLE_TMP_DIR

RUN wget -O - https://registry.npmjs.org/$CONSOLE_NPM_PACKAGE/ | jq ".versions[\"$CONSOLE_VERSION\"].dist" > $CONSOLE_TMP_DIR/version.json

RUN TARBALL=`cat $CONSOLE_TMP_DIR/version.json | jq .tarball -r` && \
    wget $TARBALL --output $CONSOLE_TMP_DIR/admin-console.tgz && \
    echo "$CONSOLE_SHASUM *$CONSOLE_TMP_DIR/admin-console.tgz" | sha1sum -c - && \
    tar -zxvf $CONSOLE_TMP_DIR/admin-console.tgz -C $CONSOLE_TMP_DIR


##
## Convergence Server Download
##
ENV SERVER_VERSION 1.0.0-rc.7
ENV SERVER_MD5 b2fdd4b79a3cf6243b05d4bb03ea92e3
ENV SERVER_SHA1 6ae601b469ab7466b11e5eced32068e37c4e7250
ENV SERVER_TMP_DIR=$TMPDIR/server
RUN mkdir $SERVER_TMP_DIR

COPY download-convergence-server.sh $SERVER_TMP_DIR
RUN chmod 755 $SERVER_TMP_DIR/download-convergence-server.sh && $SERVER_TMP_DIR/download-convergence-server.sh
RUN mkdir $SERVER_TMP_DIR/convergence-server
RUN tar -zxvf $SERVER_TMP_DIR/convergence-server.tgz -C $SERVER_TMP_DIR/convergence-server --strip-components=1


##
## Orient DB Download
##
ENV ORIENTDB_VERSION 3.0.31
ENV ORIENTDB_DOWNLOAD_MD5 c37f5fd887ef552d1673af3a754a7bf8
ENV ORIENTDB_DOWNLOAD_SHA1 08f2b6dfcfdcd33bbe9f2be8c50be8c1f507efff

ENV ORIENTDB_DOWNLOAD_URL https://repo1.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz

ENV ORIENTDB_TMP_DIR=$TMPDIR/orientdb
RUN mkdir $ORIENTDB_TMP_DIR

# download distribution tar, untar and delete databases
RUN wget $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-community-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C $ORIENTDB_TMP_DIR --strip-components=1 \
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  && rm -rf $ORIENTDB_TMP_DIR/databases/*


FROM openjdk:12-jdk-alpine3.9

LABEL maintainer="Convergence Labs, Inc."

RUN apk add --update supervisor nginx bash && \
    rm -rf /var/cache/apk/*

##
## Orient DB
##
COPY --from=builder /tmp/convergence/orientdb /orientdb
COPY orientdb-server-config.xml /orientdb/config/
RUN chown root:root /orientdb

VOLUME /orientdb/databases


##
## Convergence Admin console
##
COPY --from=builder /tmp/convergence/console/package/build /www/console
COPY convergence-admin-console.config.js /www/console/convergence-admin-console.config.js


##
## Convergence Client
##
COPY --from=builder /tmp/convergence/client/package /www/client


##
## Convergence Server
##
COPY --from=builder /tmp/convergence/server/convergence-server /convergence-server
COPY log4j2.xml /convergence-server/conf/log4j2.xml
COPY convergence-server.conf /convergence-server/conf/convergence-server.conf


##
## Proxy
##
RUN adduser -D -g 'www' www  && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

COPY nginx.conf /etc/nginx/nginx.conf


##
## Supervisor
##
COPY supservisord.conf /etc/supervisord.conf

EXPOSE 80
EXPOSE 25520

CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
