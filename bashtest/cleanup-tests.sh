#!/bin/bash

# clean up test files (before-convert-kms-private-ssh-key.sh)
files=("/kms/extract_kms_str.py" "/kms/decrypt_kms.py" "/mymeta/taupage.yaml" "/data/ghe-production-data/in-progress" )
for file in "${files[@]}"
do
   :
   if [ -f "$file" ]; then
     echo -n "" > $file
   else
      echo "cleanup: $file does not exists"
   fi
done

if [ -f ~/.ssh/id_rsa ]; then
  rm -f ~/.ssh/id_rsa
fi
