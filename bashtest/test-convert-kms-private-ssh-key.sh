#!/bin/bash

./prepare-tests.sh
../convert-kms-private-ssh-key.sh /mymeta

if [ $? -eq 1 ]
then
  echo "This is expected. Test succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
else
  echo " This is NOT expected." # ../convert-kms-private-ssh-key.sh executed w/o error.
fi
