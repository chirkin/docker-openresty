#!/bin/bash
set -e

if [ "$1" = 'nginx' ]; then
  # Copy a default configuration into place if not present
  if ! [ -f $NGX_CONFIG/nginx.conf ]; then
    cp -upR "/usr/local/openresty/nginx/conf/." "${NGX_CONFIG}"/
    echo "daemon off;" >> "${NGX_CONFIG}"/nginx.conf
  fi

	exec nginx -c "${NGX_CONFIG}"/nginx.conf
fi

exec "$@"
