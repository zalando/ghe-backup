#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

ghe_backup_test_base_folder="./ghe-backup-test"
string_replace_test="$ghe_backup_test_base_folder/region-replacement"
kms_base_folder="$ghe_backup_test_base_folder/kms"
ghe_production_data_base_folder="$ghe_backup_test_base_folder/data/ghe-production-data"
ghe_data_in_progress_file="$ghe_production_data_base_folder/in-progress"
mymeta_base_folder="$ghe_backup_test_base_folder/mymeta"

# create folder and file structure for region replacement test
mkdir -p $string_replace_test
cp ../convert-kms-private-ssh-key.sh $string_replace_test/convert-kms-private-ssh-key.sh

# create folder and file structure for decryption test
mkdir -p $kms_base_folder
cp ../python/extract_decrypt_kms.py $kms_base_folder/extract_decrypt_kms.py

######
mkdir -p $ghe_production_data_base_folder
cat <<EOT1 >> $ghe_data_in_progress_file
foo bla fasel
EOT1

######
mkdir -p $mymeta_base_folder
# create a dummy senza yaml file
# http://stups.readthedocs.org/en/latest/components/senza.html
# kms_private_ssh_key should be decryptable via kms,
# otherwise the decryption test may fail
cat <<EOT2 >> $mymeta_base_folder/taupage.yaml
application_id: ghe-backup
application_version: 0.0.0
instance_logs_url: https://my.logs.url
kms_private_ssh_key: aws:kms:AQECAHjZzNgloNStoxLGlW7zt1M3wLRLUhgdzHy+BTQzoMJMgQAAAL4wgbsGCSqGSIb3DQEHBqCBrTCBqgIBADCBpAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAyfjtZRzn/hG79GjSQCARCAd2NFtV7NFy+WnDnFvJaWn3v4MNMtKWYR+e28dLl/JphJ4ube4X08TKSypKWL2U6ASBy4X32V8ee5mNk+0AFCKll6xC7NV18rsIDWU5vZhY2hqiVL098bqCBRY17vBaDxRPaEKqwJ5z9kPxC/RAJUhFZWH/0oMzuX=
logentries_account_key: mylogentriesaccoutnkey
mint_bucket: amintbucket
mounts:
    /data:
        partition: /dev/xvdf
notify_cfn:
    resource: AppServer
    stack: mystack
oauth_access_token_url: anoauthaccesstokenurl
root: true
runtime: Docker
scalyr_account_key: myscalyraccoutnkey
source: dockerreghost/reponame:tag
token_service_url: https://my.token.service.url
volumes:
    ebs:
        /dev/sdf: abackupvolume
EOT2

echo -e "Prepare tests script finished.\n"
