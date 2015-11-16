#!/bin/bash

# clean up test files (before-convert-kms-private-ssh-key.sh)
files=("/kms/extract-kms-str.py" "/kms/decryptkms.py" "/meta/taupage.yaml" )
for file in "${files[@]}"
do
   :
   if [ -f "$file" ]; then
     echo -n "" > $file
   else
      echo "cleanup: $file does not exists"
   fi
done
