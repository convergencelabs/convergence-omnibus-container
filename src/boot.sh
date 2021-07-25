#!/usr/bin/env bash

set -e

if [ -z "${HTTP_PORT}" ]; then
  # This is for Heroku compatability
  HTTP_PORT="${PORT:-80}"
fi

export HTTP_PORT

echo "Convergence Omnibus Container"
echo "HTTP Endpoint on port: $HTTP_PORT"

envsubst '${HTTP_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec supervisord --nodaemon --configuration /etc/supervisord.conf