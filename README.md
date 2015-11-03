# ghe-backup

[![Build Status](https://travis-ci.org/zalando/ghe-backup.svg?branch=master)](https://travis-ci.org/zalando/ghe-backup)   [![Build Status](https://buildhive.cloudbees.com/job/zalando/job/ghe-backup/badge/icon)](https://buildhive.cloudbees.com/job/zalando/job/ghe-backup/)   [![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://github.com/zalando/ghe-backup/blob/master/LICENSE.txt)   

Backup for [Github Enterprise](https://enterprise.github.com/).
Ghe-backup is based on [Stups](https://stups.io/), [Docker](https://www.docker.com/), [AWS](https://aws.amazon.com).
Github's [backup-utils](https://github.com/github/backup-utils) are wrapped in a
Docker container and configured with an
[EBS volume](https://aws.amazon.com/de/ebs/) to store the backup files in.

## Create a docker image
```docker build --rm -t [repo name]:[tag] . ```  
e.g.  
```docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:0.0.5 . ```

### run the image  
```docker run -d --name [repo name]:[tag] ```  
e.g.  
```docker run -d --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.5 ```

or with connected bash:
```docker run -it --entrypoint /bin/bash --name [repo name]:[tag] ```    
e.g.  
```docker run -it --entrypoint /bin/bash --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.5 ```

#### attach to the running local container
```docker attach --sig-proxy=false [repo name] ```  
##### detach from the running local container (does not stop the container)
```CTRL+C ```  

#### run bash in running docker container
```sudo docker exec -i -t [ContainerID] bash ```
##### exit bash
```exit ```

### upload to [pierone](https://github.com/zalando-stups/pierone)
```docker push [repo name]:[tag]```  
e.g.  
```docker push pierone.stups.zalan.do/bus/ghe-backup:0.0.5```

## IAM [policy](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html) settings

A kms policy similar to the one shown below is needed to:   
* allow kms decrpytion of the ssh key
* access stups s3 bucket
* use EBS volumes
```  
{  
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
}  
```   

Make sure you have an according [role](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) managing your policy.

## EBS volume for backup data
Backup data shall be saved on an EBS volume to persist them even if the backup
instance goes down. You can create such an ebs volume as described in [senza's storage guild](https://docs.stups.io/en/latest/user-guide/storage.html) .  
Pls note: You need to format ( [ebs-using-volumes](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html) ) the EBS volume before you use it otherwise you may experience issues like:  
[_You must specify the file type_](https://forums.aws.amazon.com/thread.jspa?messageID=450413).  

## Senza yaml file
[Stups](https://stups.io/) requires a [senza yaml file](http://docs.stups.io/en/latest/components/senza.html#senza-info)
to deploy to AWS. It gets translates to
[AWS CloudFormation templates ](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-guide.html)
that cause a stack be deployed.

A sample senza yaml file would be:  
```  
# basic information for generating and executing this definition   
SenzaInfo:  
  StackName: hello-world  
  Parameters:  
    - ImageVersion:
        Description: "Docker image version of hello-world."
# a list of senza components to apply to the definition
SenzaComponents:
  # this basic configuration is required for the other components
  - Configuration:
      Type: Senza::StupsAutoConfiguration # auto-detect network setup
      AvailabilityZones: [myAZ] # use EBS volume's AZ
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
            /dev/sdf: my-volume
        mounts:
          /data:
            partition: /dev/xvdf  
```
_If you copy/paste, make sure your details replace the dummy values_  


## Create scm-source.json
Create a bash script (e.g. 'create-scm-source.sh') as described in
[stups application-development](http://docs.stups.io/en/latest/user-guide/application-development.html).  
Make the script executable: ```chmod +x create-scm-source.sh ```  
run create-scm-source.sh  
```./create-scm-source.sh that produces a scm-source.json ```  


## Tests
See below 2 sections about
* python nose tests
* bash tests

Both can be run together with ```./run-tests.sh```.  
Pls note:

* kms tests don't run on ci environments as it requires aws logins e.g. via mai
* *make sure* you run ```bashtest/cleanup-tests.sh```  in order to clean up afterwards.

### nosetest
* make sure you are logged in with AWS e.g. ```mai login [awsaccount-role]```  
* ```nosetests -w python -v --nocapture testdecryptkms.py```  

### bash tests
``` cd bashtest ```  
``` ./test-convert-kms-private-ssh-key.sh ```  
``` ./cleanup-tests.sh ```  
*make sure* you run ```./cleanup-tests.sh``` in order to clean up.  

===
#### License


Copyright © 2015 Zalando SE

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
