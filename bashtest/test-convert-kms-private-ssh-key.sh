#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# start with clean setup
./cleanup-tests.sh

./prepare-tests.sh
echo "-----------------"
./test-replace-convert-properties.sh
if [ $? -eq 0 ]
then
  echo "test 'test-replace-convert-properties.sh' succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/o error.
else
  echo "test 'test-replace-convert-properties.sh' NOT succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
fi

../convert-kms-private-ssh-key.sh /mymeta test

if [ $? -eq 0 ]
then
  echo "test conversion 'convert-kms-private-ssh-key.sh' succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/o error.
else
  echo "test conversion 'convert-kms-private-ssh-key.sh' NOT succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
fi
echo "-----------------"

# clean up
#./cleanup-tests.sh
