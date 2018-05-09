#!/bin/bash

# start with clean setup
./cleanup-tests.sh

./prepare-tests.sh
echo "-----------------"
../convert-kms-private-ssh-key.sh /mymeta test

if [ $? -eq 0 ]
then
  echo "Test succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/o error.
else
  echo "Tests NOT succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
fi
echo "-----------------"

# clean up
./cleanup-tests.sh
