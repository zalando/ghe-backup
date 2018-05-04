#!/bin/bash

# clean up test files (before-convert-kms-private-ssh-key.sh)
rm -rf ./ghe-backup-test

sshkey="./ssh/id_rsa_test"
if [ -f $sshkey ]; then
  rm -f $sshkey
else
   echo "cleanup: $sshkey does not exists"
fi

echo -e "cleanup script finished.\n"
