#!/usr/bin/env bash

rm -rf docker-build

mkdir docker-build
cp -a docker/* docker-build

npm i
cp -a node_modules/@convergence-internal/admin-console/www/ docker-build/admin-console

mkdir docker-build/client
cp -a node_modules/@convergence-internal/convergence/umd/convergence-all.min.js docker-build/client
cp -a node_modules/@convergence-internal/convergence/umd/convergence.min.js docker-build/client

sbt fetchServerNode

docker build -t convergencelabs/convergence-de docker-build
