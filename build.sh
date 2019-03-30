#!/usr/bin/env bash

rm -rf docker-build

mkdir docker-build
cp -a docker/* docker-build

npm i
cp -a node_modules/@convergence-internal/admin-console/www/ docker-build/admin-console

mkdir docker-build/client
cp -a node_modules/@convergence/convergence/convergence.global.js docker-build/client/convergence.js
cp -a node_modules/@convergence/convergence/convergence.amd.js docker-build/client/convergence.amd.js
cp -a node_modules/rxjs/bundles/* docker-build/client/

cp -a node_modules/@convergence/convergence/docs docker-build/api

sbt fetchServerNode

docker build -t convergencelabs/convergence-de docker-build
