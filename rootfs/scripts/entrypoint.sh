#!/bin/bash

set -euo pipefail

if [ ${MODE} == "dev" ]; then
    set -x
fi

if [ ! `id -un` == "root" ]; then
    echo >&2 " => error: Please run container only by root user!" && exit 1;
fi

# Change user UID/GID and UID/GID in files.

OGID=`id -g www-data`
if [ ${PGID} -ne ${OGID} ]; then
    groupmod -g ${PGID} www-data | (find / -group ${OGID} -print 2> /dev/null; exit 0) | xargs chown -R :${PGID} || true
fi

OUID=`id -u www-data`
if [ ${PUID} -ne ${OUID} ]; then
     usermod -u ${PUID} www-data | (find / -user ${OUID} -print 2> /dev/null; exit 0) | xargs chown -R ${PGID} || true
fi

# Waiting for services...
for host in ${WAIT_FOR}; do
    wait-for -t 0 ${host}
done

exec "$@"