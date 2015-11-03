#!/bin/bash

# clean up test files (before-convert-kms-private-ssh-key.sh)
files=("/kms/parseyaml.py" "/kms/decryptkms.py" "/meta/taupage.yaml" )
for file in "${files[@]}"
do
   :
   #echo $file
   if [ -f "$file" ]; then
     #echo "$file does exists"
     echo -n "" > $file
   else
      echo "$file does not exists"
   fi
done
