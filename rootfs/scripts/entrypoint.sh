#!/bin/bash

set -euo pipefail

if [ ${MODE} == "dev" ]; then
    set -x
fi

# Waiting for services...
for host in ${WAIT_FOR}; do
    wait-for -t 0 ${host}
done

exec "$@"