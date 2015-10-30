#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

#read senza yaml file (taupage.yaml)
eval $(/kms/parseyaml.py --export /meta/taupage.yaml "configuration")
SSHKEY=$(echo "$configuration_SenzaComponents" | python -c 'import sys;stuff=sys.stdin.read(1000);kmsstuff=stuff[stuff.find("aws:kms:"):len(stuff)];kmsstr=kmsstuff[0:kmsstuff.find(",")-1];print(kmsstr + "\n")')

if [[ $SSHKEY == "aws:kms:"* ]]; then
  SSHKEY=${SSHKEY##aws:kms:}
  SSHKEY=`python3 /kms/decryptkms.py $SSHKEY`
  if [[ $SSHKEY == "Invalid KMS key." ]]
  then
    echo "KMS key or KMS string is invalid."
    echo "KMS string must be formate: aws:kms:<BASE64STRING>"
    echo "KMS key must be usable via Host-IAM-Profile"
    exit 1
  fi

  if [ -f ~/.ssh/id_rsa ]
  then
    echo "The file ~/.ssh/id_rsa exists already. Won't be overridden." >&2
    exit 0
  else
    # assumption: file does not exists on new created docker container
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key.".
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written.".
    exit 0
  fi
fi
exit 1
