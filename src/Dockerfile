FROM alpine:3.9 as builder

LABEL maintainer="Convergence Labs, Inc."

RUN apk add --update tar curl jq

ENV TMPDIR=/tmp/convergence
RUN mkdir $TMPDIR

###
### Convergence Client Download
###
ENV CLIENT_VERSION 1.0.0-rc.4
ENV CLIENT_NPM_PACKAGE @convergence/convergence
ENV CLIENT_SHASUM c98e36501a23428f55127d7986b950896ea028af

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
ENV CONSOLE_VERSION 1.0.0-rc.4
ENV CONSOLE_NPM_PACKAGE @convergence/admin-console
ENV CONSOLE_SHASUM 23caf8526eb35fe459f174dee2773a6d3ee22a06

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
ENV SERVER_VERSION 1.0.0-SNAPSHOT
ENV SERVER_TMP_DIR=$TMPDIR/server
RUN mkdir $SERVER_TMP_DIR

COPY download-convergence-server.sh $SERVER_TMP_DIR
RUN chmod 755 $SERVER_TMP_DIR/download-convergence-server.sh && $SERVER_TMP_DIR/download-convergence-server.sh
RUN mkdir $SERVER_TMP_DIR/convergence-server
RUN tar -zxvf $SERVER_TMP_DIR/convergence-server.tgz -C $SERVER_TMP_DIR/convergence-server --strip-components=1


##
## Orient DB Download
##
ENV ORIENTDB_VERSION 3.0.26
ENV ORIENTDB_DOWNLOAD_MD5 411b7545efb31ad91b2320ab1d5f9bc9
ENV ORIENTDB_DOWNLOAD_SHA1 c4b2d4d95ed7730b91a3bb8145a37eecc1b51c36

ENV ORIENTDB_DOWNLOAD_URL http://central.maven.org/maven2/com/orientechnologies/orientdb-community/$ORIENTDB_VERSION/orientdb-community-$ORIENTDB_VERSION.tar.gz

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

RUN apk add --update supervisor nginx bash jq && \
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

CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]