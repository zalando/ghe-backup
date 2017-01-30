#!/bin/bash

# clean possible left overs
./cleanup-tests.sh

# create folder and file structure
# call this script from folder above
mkdir -p /kms/
cp ../python/extract_decrypt_kms.py /kms/extract_decrypt_kms.py
chmod 744 /kms/extract_decrypt_kms.py
cp ../python/decrypt_kms.py /kms/decrypt_kms.py
chmod 744 /kms/decrypt_kms.py
mkdir -p /mymeta/

mkdir -p /data/ghe-production-data
#touch /data/ghe-production-data/in-progress
cat <<EOT1 >> /data/ghe-production-data/in-progress
a
EOT1

# create a dummy senza yaml file
# http://stups.readthedocs.org/en/latest/components/senza.html
cat <<EOT2 >> /mymeta/taupage.yaml
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
