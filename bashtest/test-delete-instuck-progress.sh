#!/bin/bash

./prepare-tests.sh
python3 ../python/delete-instuck-progress.py

file='/data/ghe-production-data/in-progress'
if [ -e $file ]
then
  echo "Error: $file should not exist."
  false
else
  echo "Test succesfully passed."
fi
