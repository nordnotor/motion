#!/bin/bash

set -euo pipefail

if [ ${MODE} == "dev" ]; then
    set -x
fi

if [ ! `id -un` == "root" ]; then
    echo >&2 " => error: Please run container only by root user!" && exit 1;
fi

# Waiting for services...
for host in ${WAIT_FOR}; do
    wait-for -t 0 ${host}
done

exec "$@"