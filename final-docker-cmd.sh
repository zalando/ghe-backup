#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

python3 /delete-instuck-backups/delete_instuck_progress.py 2>&1
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
# fall back to Ireland AWS region if REGION is unset or set to the empty string
if [ -z "$REGION" ]
then
  REGION="eu-west-1"
fi
/backup/replace-convert-properties.sh "###REGION###" "$REGION" /kms/convert-kms-private-ssh-key.sh
/kms/convert-kms-private-ssh-key.sh
# do the actual backups via cron
# everything in sbin directory needs to be executed as privileged user
sudo /usr/sbin/cron -f
