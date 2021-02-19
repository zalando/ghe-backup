#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# exit if the same process runs already
pidof -o $$ -x "$0" >/dev/null 2>&1 && exit 1

if [ ! -d "/data/ghe-production-data/" ]; then
    mkdir -p /data/ghe-production-data/
fi
/backup/backup-utils/bin/ghe-backup
