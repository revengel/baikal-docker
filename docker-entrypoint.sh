#!/bin/bash
set -eo pipefail

if ! [ -d /var/www/baikal/Specific/db ]; then
  mkdir -p /var/www/baikal/Specific/db
fi

exec "$@"
