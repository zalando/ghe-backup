#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

pidof -o $$ -x "$0" >/dev/null 2>&1 && exit 1
if [ "root"  ==  "`stat -c '%U' /data`" ]
then
    sudo chown -R application: /data
fi
/backup/backup-utils/bin/ghe-backup 1>> /var/log/ghe-prod-backup.log 2>&1