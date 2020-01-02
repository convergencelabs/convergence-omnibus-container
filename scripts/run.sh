#!/usr/bin/env sh

# Run the docker image
docker run --rm \
  --publish 8000:80 \
  convergencelabs/convergence-omnibus