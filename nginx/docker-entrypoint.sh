#!/bin/sh
set -e

# default if not set
: "${PHPFPM_HOST:=127.0.0.1}"

# replace environment variables in template and write final config
envsubst '$PHPFPM_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

# start nginx
exec "$@"

