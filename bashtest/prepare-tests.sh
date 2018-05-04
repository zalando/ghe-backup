#!/bin/bash

kms_base_folder="./ghe-backup-test/kms"
ghe_production_data_base_folder="./ghe-backup-test/data/ghe-production-data"
ghe_data_in_progress_file="$ghe_production_data_base_folder/in-progress"
mymeta_base_folder="./ghe-backup-test/mymeta"

# create folder and file structure
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
cat <<EOT2 >> $mymeta_base_folder/taupage.yaml
application_id: ghe-backup
application_version: 0.0.0
instance_logs_url: https://my.logs.url
kms_private_ssh_key: aws:kms:myAWSregion:123456789:key/myrandomstringwithnumbers123456567890
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

echo -e "prepare tests script finished.\n"
