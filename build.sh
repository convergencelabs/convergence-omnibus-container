#!/usr/bin/env bash

mkdir docker-build
cp -a docker/* docker-build

npm i
cp -a node_modules/@convergence-internal/admin-console/www/ docker-build/admin-console

sbt fetchServerNode

docker build -t convergencelabs/convergence-de docker-build
