#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

folder=""
private_key_path="~/.ssh/id_rsa"
kms_base="/kms"
set +u
if [ ! -z $1 ];
then
  folder=$1
else
  folder="/meta"
fi

if [ ! -z $2 ];
then
  # @TODO: go for ./ssh/id_rsa_test for test case
  private_key_path="~/.ssh/id_rsa_test"
  folder="~/ghe-backup-test/mymeta"
  kms_base="~/ghe-backup-test/kms"
fi

# Treat unset variables as an error when substituting.
set -u

if [ -f $private_key_path ]
then
  # @TODO: separate function parameter would be private key content ($SSHKEY /meta/ghe-backup-secret/kms_private_ssh_key)
  if [ -f $private_key_path ]
  then
    echo "The file $private_key_path exists already. Won't be overridden." >&2
    exit 0
  else
    echo "The file $private_key_path does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    cp $folder/ghe-backup-secret/kms_private_ssh_key $private_key_path
    chmod 0600 $private_key_path
    echo "Private ssh key file written."
    exit 0
  fi
  ### end of separate function
  exit 1
elif [ -f $folder/taupage.yaml ]
then
  echo "File $folder/taupage.yaml exists."
  SSHKEY=$(python3 $kms_base/extract_decrypt_kms.py -f "$folder/taupage.yaml" -k "kms_private_ssh_key" -r "###REGION###")
  if [[ $SSHKEY == "Invalid KMS key." ]]
  then
    echo "KMS key or KMS string is invalid."
    echo "Expected KMS string format: aws:kms:<BASE64STRING>"
    echo "KMS key must be usable via Host-IAM-Profile"
    exit 1
  fi

  if [ -f $private_key_path ]
  then
    echo "The file $private_key_path exists already. Won't be overridden." >&2
    exit 0
  else
    echo "The file $private_key_path does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> $private_key_path
    chmod 0600 $private_key_path
    echo "Private ssh key file written."
    exit 0
  fi
else
  echo "Neither /details/labels nor $folder/taupage.yaml exist."
fi

exit 1
