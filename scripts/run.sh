#!/usr/bin/env sh

# Run the docker image
docker run --rm \
  --name convergence-omnibus \
  --publish 8000:80 \
  convergencelabs/convergence-omnibus