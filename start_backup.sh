#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# don't start if process is running
pidof -o $$ -x "$0" >/dev/null 2>&1 && exit 1
# execute the backup and redirects logs to stdout and logfile
/backup/backup-utils/bin/ghe-backup -v |& tee /var/log/ghe-prod-backup.log # http://stackoverflow.com/a/29163890