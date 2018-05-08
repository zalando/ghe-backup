#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

folder=""
private_key_folder="~/.ssh"
private_key_path="$private_key_folder/id_rsa"
private_key_folder_test="./ssh"
private_key_path_test="$private_key_folder_test/id_rsa_test"
kms_base="/kms"
aws_region_placeholder="###REGION###"

set +u
if [ ! -z $1 ];
then
  folder=$1
else
  folder="/meta"
fi

if [ ! -z $2 ];
then
  private_key_path="$private_key_path_test"
  private_key_folder="$private_key_folder_test"
  folder="./ghe-backup-test/mymeta"
  kms_base="./ghe-backup-test/kms"
  aws_region_placeholder="eu-west-1"
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
    mkdir -p $private_key_folder
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
  echo "python3 $kms_base/extract_decrypt_kms.py -f $folder/taupage.yaml -k kms_private_ssh_key -r $aws_region_placeholder)"
  SSHKEY=$(python3 $kms_base/extract_decrypt_kms.py -f "$folder/taupage.yaml" -k "kms_private_ssh_key" -r "$aws_region_placeholder")
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
    mkdir -p $private_key_folder
    printf "%s" "$SSHKEY" >> $private_key_path
    chmod 0600 $private_key_path
    echo "Private ssh key file written."
    exit 0
  fi
else
  echo "Neither /details/labels nor $folder/taupage.yaml exist."
fi

exit 1
