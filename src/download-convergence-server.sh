#!/usr/bin/env sh

set -e

# Configs
SNAPSHPOT_REPO_URL=https://oss.sonatype.org/content/repositories/snapshots
RELEASE_REPO_URL=https://repo1.maven.org/maven2
REALTIVE_URL=com/convergencelabs/convergence-server_2.12/$SERVER_VERSION/convergence-server_2.12-$SERVER_VERSION.tgz

case "$SERVER_VERSION" in
    *SNAPSHOT* ) REPO_BASE_URL=$SNAPSHPOT_REPO_URL;;
    * ) REPO_BASE_URL=$RELEASE_REPO_URL;;
esac

SERVER_URL=$REPO_BASE_URL/$REALTIVE_URL
echo Downloading the Convergence Server $SERVER_VERSION from: $SERVER_URL
curl --insecure $SERVER_URL --output $SERVER_TMP_DIR/convergence-server.tgz
