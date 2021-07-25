FROM alpine:3.9 as builder

RUN apk add --update tar curl jq

ENV TMPDIR=/tmp/convergence
RUN mkdir $TMPDIR

###
### Convergence Client Download
###

## npm view @convergence/convergence to get SHASUM
ENV CLIENT_VERSION 1.0.0-rc.12
ENV CLIENT_NPM_PACKAGE @convergence/convergence
ENV CLIENT_SHASUM b71a5bfa00cd6dfa012cb586d118203b98358674

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
ENV CONSOLE_VERSION 1.0.0-rc.12
ENV CONSOLE_NPM_PACKAGE @convergence/admin-console
ENV CONSOLE_SHASUM b1e0271dfb4f5467be75df8d15b10d1de98e18c8

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
ENV SERVER_VERSION 1.0.0-rc.12
ENV SERVER_MD5 0c3829216bee4fc49b9eca2d1823110d
ENV SERVER_SHA1 985c2c762be51bfe3e015614f4c01a741df6c968
ENV SERVER_TMP_DIR=$TMPDIR/server
RUN mkdir $SERVER_TMP_DIR

COPY download-convergence-server.sh $SERVER_TMP_DIR
RUN chmod 755 $SERVER_TMP_DIR/download-convergence-server.sh && $SERVER_TMP_DIR/download-convergence-server.sh
RUN mkdir $SERVER_TMP_DIR/convergence-server
RUN tar -zxvf $SERVER_TMP_DIR/convergence-server.tgz -C $SERVER_TMP_DIR/convergence-server --strip-components=1


##
## Orient DB Download
##
ENV ORIENTDB_VERSION 3.0.37
ENV ORIENTDB_DOWNLOAD_MD5 da01fdb3fae076fca4879b563b4b8f53
ENV ORIENTDB_DOWNLOAD_SHA1 0f7ac76daf691b4723bde9cfbe637c3ef36b3657

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


FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine

LABEL maintainer="Convergence Labs, Inc."

RUN addgroup -S convergence && adduser -S convergence -G convergence

RUN apk --no-cache --update add \
      supervisor \
      nginx \
      bash \
      gettext

##
## Orient DB
##
COPY --from=builder /tmp/convergence/orientdb /orientdb
COPY orientdb-server-config.xml /orientdb/config/
RUN chown -RL convergence:convergence /orientdb

VOLUME /orientdb/database

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
RUN chown -RL convergence:convergence /convergence-server


##
## Proxy
##
COPY nginx.conf /etc/nginx/nginx.conf.template
RUN mkdir -p /run/nginx && \
    mkdir -p /var/tmp/nginx/client_body && \
    chown -RL convergence:convergence /var/tmp/nginx/client_body && \
    chown -RL convergence:convergence /var/lib/nginx && \
    chown -R convergence:convergence /www && \
    chown -R convergence:convergence /etc/nginx/nginx.conf


##
## Supervisor
##
COPY supservisord.conf /etc/supervisord.conf
RUN mkdir /supservisord && \
    chown -R convergence:convergence /supservisord


##
## Boot Script
##
COPY boot.sh /boot.sh
RUN chmod 755 /boot.sh && \
    chown convergence:convergence /boot.sh

USER convergence

EXPOSE 80

CMD ["./boot.sh"]
