#!/usr/bin/env bash

mkdir docker-build
cp -a docker/* docker-build

npm i
cp -a node_modules/@convergence/admin-console/app/ docker-build/admin-console

sbt fetchServerNode

docker build -t convergence docker-build
