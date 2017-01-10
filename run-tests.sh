#!/bin/bash

# http://stackoverflow.com/questions/19622198/what-does-set-e-mean-in-a-bash-script
set -e

# do mai login if you are _not_ in AWS environment
# won't work in CI environment
# (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
link="http://169.254.169.254/latest/meta-data/"
if ! curl --max-time 2 --output /dev/null --silent --head --fail "$link"; then
  mai login bus-PowerUser
fi
nosetests -w python
# uncomment for verbose output:
#nosetests -w python -vv --nocapture test_decrypt_kms.py

cd bashtest
./test-convert-kms-private-ssh-key.sh

# make sure you run bashtest/cleanup-tests.sh in order to clean up afterwards
