#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

folder=""
set +u
if [ ! -z $1 ];
then
  folder=$1
else
  folder="/meta"
fi
set -u

if [ -f /details/labels ]
then
  # @TODO: separate function parameter would be private key content ($SSHKEY /meta/ghe-backup-secret/kms_private_ssh_key)
  if [ -f ~/.ssh/id_rsa ]
  then
    echo "The file ~/.ssh/id_rsa exists already. Won't be overridden." >&2
    exit 0
  else
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    cp /meta/ghe-backup-secret/kms_private_ssh_key ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written."
    exit 0
  fi
  ### end of separate function
  exit 1
elif [ -f $folder/taupage.yaml ]
then
  echo "File $folder/taupage.yaml exists."
  SSHKEY=$(python3 /kms/extract_decrypt_kms.py -f "$folder/taupage.yaml" -k "kms_private_ssh_key" -r "eu-west-1")
  if [[ $SSHKEY == "Invalid KMS key." ]]
  then
    echo "KMS key or KMS string is invalid."
    echo "Expected KMS string format: aws:kms:<BASE64STRING>"
    echo "KMS key must be usable via Host-IAM-Profile"
    exit 1
  fi

  if [ -f ~/.ssh/id_rsa ]
  then
    echo "The file ~/.ssh/id_rsa exists already. Won't be overridden." >&2
    exit 0
  else
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written."
    exit 0
  fi
else
  echo "Neither /details/labels nor $folder/taupage.yaml exist."
fi

exit 1
