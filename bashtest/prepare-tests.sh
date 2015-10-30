#!/bin/bash

# clean possible left overs
./cleanup-tests.sh

# create folder and file structure
# call this script from folder above
mkdir -p /kms/
cp ../python/parseyaml.py /kms/parseyaml.py
chmod 744 /kms/parseyaml.py
cp ../python/decryptkms.py /kms/decryptkms.py
chmod 744 /kms/decryptkms.py
mkdir -p /meta/
touch /meta/ghe-backup.yaml
chmod 744 /meta/ghe-backup.yaml

# create a dummy senza yaml file
# http://stups.readthedocs.org/en/latest/components/senza.html
cat <<EOT >> /meta/taupage.yaml
# basic information for generating and executing this definition
SenzaInfo:
  StackName: hello-world
  Parameters:
    - ApplicationId:
        Description: "Application ID from kio"
    - ImageVersion:
        Description: "Docker image version of hello-world."
    - MintBucket:
        Description: "Mint bucket for your team"
    - GreetingText:
        Description: "The greeting to be displayed"
        Default: "Hello, world!"
# a list of senza components to apply to the definition
SenzaComponents:
  # this basic configuration is required for the other components
  - Configuration:
      Type: Senza::StupsAutoConfiguration # auto-detect network setup
      AvailabilityZones: [eu-west-1a] # use EBS volume's AZ
  # will create a launch configuration and auto scaling group with scaling triggers
  - AppServer:
      Type: Senza::TaupageAutoScalingGroup
      InstanceType: t2.micro
      SecurityGroups:
        - app-{{Arguments.ApplicationId}}
      IamRoles:
        - app-{{Arguments.ApplicationId}}
      AssociatePublicIpAddress: false # change for standalone deployment in default VPC
      TaupageConfig:
        application_version: "{{Arguments.ImageVersion}}"
        runtime: Docker
        source: "stups/hello-world:{{Arguments.ImageVersion}}"
        mint_bucket: "{{Arguments.MintBucket}}"
        kms_private_ssh_key: "aws:kms:myAWSregion:123456789:key/myrandomstringwithnumbers123456567890"
        volumes:
          ebs:
            /dev/sdf: ghe-backup-volume
        mounts:
          /data:
            partition: /dev/xvdf
EOT
