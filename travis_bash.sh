#!/bin/bash
set +e

cd bashtest
sudo ./prepare-tests.sh

SSHKEY=$(python3 /kms/extract_decrypt_kms.py -f "/mymeta/taupage.yaml" -k "kms_private_ssh_key" -r "eu-west-1")
if [[ $SSHKEY == "Invalid KMS key." ]]
    then
    echo "KMS key or KMS string is invalid."
    echo "KMS string must be formated: aws:kms:<BASE64STRING>"
    echo "KMS key must be usable via Host-IAM-Profile"
    exit 1
fi

if [ -f ~/.ssh/id_rsa ]
    then
    echo "The file ~/.ssh/id_rsa exists already. Won't be overridden." >&2
    exit 0
    else
    # assumption: file does not exists on new created docker container
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written."
    exit 0
fi

echo "This is expected. Test successfully passed."
exit 0
