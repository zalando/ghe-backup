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

# - use https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/ to check if container runs on K8s
#  - Motivation for the Downward API
#  - "you can see that the labels and annotations files are in a temporary subdirectory"
#  - pod fields and container fields (symbolic links"
#  - "Using symbolic links enables dynamic atomic refresh of the metadata; updates are written to a new temporary directory"
# - https://lukemarsden.github.io/docs/user-guide/downward-api/
#  - "Downward API volume permits to store more complex data like metadata.labels and metadata.annotations"
# - if K8s
# - mount secrets
# - read secret file and write the public key
# - else

# running as pod that gets labels file via downward-api-volume
if [ -f /details/labels ]
then
  echo "File /details/labels exists. cat /details/labels: "
  cat /details/labels
  echo "check for /meta/ghe-backup-secret file. cat /meta/ghe-backup-secret: "
  ls -lisa /meta/ghe-backup-secret
  exit 1
else
  echo "File /details/labels does not exist."
fi

if [ -f $folder/taupage.yaml ]
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
    # assumption: file does not exists on new created docker container
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key."
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written."
    exit 0
  fi
else
  echo "File $folder/taupage.yaml does not exist."
fi

exit 1
