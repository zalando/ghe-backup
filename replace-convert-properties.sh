#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

usage="$(basename "$0") searchstring replacement file-to-replace-the-strings-into"

# $1 - string to replace
# $2 - replacement string
# $3 - file to replace the strings into

if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  echo "Usage: $usage"
  exit 0
fi

if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ] ;
then
  # Mac: use gnu-sed - brew install gnu-sed - http://daoyuan.li/a-normal-sed-on-mac/
  echo "1: $1"
  echo "2: $2"
  echo "3: $3"
  sed -i "s;$1;$2;g" "$3"
fi
