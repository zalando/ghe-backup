#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

python3 /delete-instuck-backups/delete_instuck_progress.py
/kms/convert-kms-private-ssh-key.sh
# do the actual backups via cron
# everything in sbin directory needs to be executed as privileged user
sudo /usr/sbin/cron
tail -F /var/log/ghe-prod-backup.log