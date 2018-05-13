#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

test_file="./ghe-backup-test/region-replacement/convert-kms-private-ssh-key.sh"

../replace-convert-properties.sh "###REGION###" "eu-west-1" $test_file

if grep -Fxq "###REGION###" "$test_file"
then
    exit 1 # NO success
else
    exit 0 # success
fi
