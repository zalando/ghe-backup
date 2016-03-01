# Github Enterprise Backup

[![Build Status](https://travis-ci.org/zalando/ghe-backup.svg?branch=master)](https://travis-ci.org/zalando/ghe-backup)        [![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://github.com/zalando/ghe-backup/blob/master/LICENSE.txt)   

[Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup approach.

## Overview
[Github Enterprise](https://enterprise.github.com/) master and replica instances run on an AWS account. The same AWS account runs also a backup host. There is another backup host running in a different AWS account.

![overview](/Slide1.PNG "backup approach overview")

The [Taupage AMI](https://github.com/zalando-stups/taupage) is mandatory for backup hosts of [Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) for compliance reasons.
As [Taupage AMI](https://github.com/zalando-stups/taupage) is part of [Stups](https://stups.io/),  
other [Stups](https://stups.io/) technologies like [Senza](https://github.com/zalando-stups/senza) are also used.

Basically github's [backup-utils](https://github.com/github/backup-utils) are wrapped in a [Docker](https://www.docker.com/) container. An [EBS volume](https://aws.amazon.com/de/ebs/) stores the actual backup data.

### Create a docker image
```docker build --rm -t [repo name]:[tag] . ```  
e.g.  
```docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:0.0.7 . ```

#### run the image  
```docker run -d --name [repo name]:[tag] ```  
e.g.  
```docker run -d --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.7 ```

or with connected bash:  
```docker run -it --entrypoint /bin/bash --name [repo name]:[tag] ```    
e.g.  
```docker run -it --entrypoint /bin/bash --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.7 ```

##### attach to the running local container
```docker attach --sig-proxy=false [repo name] ```  
###### detach from the running local container (does not stop the container)
```CTRL+C ```  

##### run bash in running docker container
```sudo docker exec -i -t [ContainerID] bash ```
###### exit bash
```exit ```

#### upload Docker images to [pierone](https://github.com/zalando-stups/pierone) (a Zalando docker registry)
```docker push [repo name]:[tag]```  
e.g.  
```docker push pierone.stups.zalan.do/bus/ghe-backup:0.0.7```

### IAM [policy](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html) settings

A kms policy similar to the one shown below is needed to:   
* allow kms decryption of the encrypted ssh key
* access stups s3 bucket
* use EBS volume
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

### configure an [EBS](https://aws.amazon.com/de/ebs/) volume for backup data  

Backup data shall be saved on an [EBS](https://aws.amazon.com/de/ebs/) volume to persist backups even if the backup instance goes down. Creation of such an ebs volume is described in Please follow these instructions: [senza's storage guild](https://docs.stups.io/en/latest/user-guide/storage.html) to create a regarding volume.  
Pls note: You need to format ([ebs-using-volumes](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html)) the EBS volume before you use it, otherwise you may experience issues like:  
[_You must specify the file type_](https://forums.aws.amazon.com/thread.jspa?messageID=450413).  

### Senza yaml file
[Stups](https://stups.io/) requires a [senza yaml file](http://docs.stups.io/en/latest/components/senza.html#senza-info)
to deploy something to AWS. This yaml file gets basically translated to
[AWS CloudFormation templates ](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-guide.html)
that causes a stack being deployed.

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
_If you copy/paste the template above, make sure your details replace the dummy values_  


### Create scm-source.json
Ghe-backup uses a bash script similar to
[stups application-development](http://docs.stups.io/en/latest/user-guide/application-development.html) to generate a scm-source.json file.   
Make sure the bash script is executable:  
```chmod +x create-scm-source.sh ```  
and run it like:  
```./create-scm-source.sh ```  


## Tests
There are two kinds of tests available:
* python nose tests
* bash tests

Both can be run with ```./run-tests.sh ```.  
Pls note:

* kms tests don't run on ci environments as it requires aws logins e.g. via mai
* *make sure* you run ```bashtest/cleanup-tests.sh```  in order to clean up afterwards.

### nosetest
* precondition: you are logged in with AWS e.g.  
```mai login [awsaccount-role] ```  
* test run:  
```nosetests -w python -v --nocapture testdecryptkms.py ```  

### bash tests
Pls go to bashtest directory:
``` cd bashtest ``` and run the tests:  
``` ./test-convert-kms-private-ssh-key.sh ```  
``` ./test-delete-instuck-progress.sh ```  

*Make sure* you run ```./cleanup-tests.sh ``` in order to clean up afterwards.  

===
### License


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
