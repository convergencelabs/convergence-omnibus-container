#!/usr/bin/env sh

set -e

# Configs
SNAPSHPOT_REPO_URL=https://oss.sonatype.org/content/repositories/snapshots
RELEASE_REPO_URL=https://repo1.maven.org/maven2
REALTIVE_URL=com/convergencelabs/convergence-server-universal/$SERVER_VERSION/convergence-server-universal-$SERVER_VERSION.tgz

case "$SERVER_VERSION" in
    *SNAPSHOT* ) REPO_BASE_URL=$SNAPSHPOT_REPO_URL;;
    * ) REPO_BASE_URL=$RELEASE_REPO_URL;;
esac

SERVER_URL=$REPO_BASE_URL/$REALTIVE_URL
echo "Downloading the Convergence Server Universal Distribution $SERVER_VERSION from: $DOWNLOAD_URL"
curl --insecure $SERVER_URL --output $SERVER_TMP_DIR/convergence-server.tgz

echo "Verifying Convergence Server Universal Distribution download"
echo "$SERVER_MD5 *$SERVER_TMP_DIR/convergence-server.tgz" | md5sum -c -
echo "$SERVER_SHA1 *$SERVER_TMP_DIR/convergence-server.tgz" | sha1sum -c -