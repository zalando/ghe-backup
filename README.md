# ghe-backup
Docker [stups](https://stups.io/) [AWS](https://aws.amazon.com) based backup for
[Github Enterprise](https://enterprise.github.com/) at
[Zalando Tech](https://tech.zalando.com/)

## create scm-source.json
creates a bash script ('create-scm-source.sh') as described in
[stups application-development](http://docs.stups.io/en/latest/user-guide/application-development.html)  
make the script executable: ```chmod +x create-scm-source.sh```  
run create-scm-source.sh e.g. ./create-scm-source.sh that produces a scm-source.json  

## create docker image
docker build --rm -t [repo name]:[tag] .  
e.g.  
docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:0.0.3 .  

## run the image locally
docker run -d --name [repo name]:[tag]  
e.g.  
docker run -d --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.3  

or with connected bash:
docker run -it --entrypoint /bin/bash --name [repo name]:[tag]  
e.g.  
docker run -it --entrypoint /bin/bash --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.3  

### attach to the running container
docker attach --sig-proxy=false ghe-backup
### detach from the running container (does not stop the container)
CTRL+C

## upload to [pierone](https://github.com/zalando-stups/pierone)
docker push [repo name]:[tag]  
e.g.  
docker push pierone.stups.zalan.do/bus/ghe-backup:0.0.3  

## iam (policy)[http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html] settings
a kms policy is needed to:   
* allow kms decrpytion
* access stups s3 bucket
* use EBS volumes
```{  
    "Version": "2012-10-17",  
    "Statement": [  
        {  
            "Sid": "Stmt1441892073456",  
            "Effect": "Allow",  
            "Action": [  
                "kms:Decrypt"  
            ],  
            "Resource": [  
                "*"  
            ]  
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::[yourMintBucket]/[repo name]/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": "*"
        }  
    ]  
}```   
Make sure you have a (role)[http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html] managing your policy

## senza yaml file to deploy using
[senza](http://docs.stups.io/en/latest/components/senza.html#senza-info)  

```  
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
```

## Tests
See below 2 sections about
* python nose tests
* bash bats tests

Both can be run with
```  
./run-tests.sh  
```  
note:
* kms tests don't run on ci environments as it requires aws logins e.g. via mai
* *make sure* you run
```  
bashtest/cleanup-tests.sh  
```  
in order to clean up afterwards

### nosetest
* make sure you are logged in with AWS e.g. mai login bus-PowerUser
* (sudo pip3 install -r python/test_requirements.txt --upgrade )
* nosetests -w python -v --nocapture testdecryptkms.py

### bash tests
* cd bashtest
* ./test-convert-kms-private-ssh-key.sh
* ./cleanup-tests.sh
* *make sure* you run ./cleanup-tests.sh in order to clean up afterwards
