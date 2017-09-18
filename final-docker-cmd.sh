#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

#echo $PATH
#env
#echo "======================================================"
#which python3
#echo "run /delete-instuck-backups/delete_instuck_progress.py"
python3 /delete-instuck-backups/delete_instuck_progress.py
#echo "run /kms/convert-kms-private-ssh-key.sh"
/kms/convert-kms-private-ssh-key.sh
#echo "run cron"
# do the actual backups via cron
cron
tail -F /var/log/ghe-prod-backup.log