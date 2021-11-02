# Deprecation Notice 
This repository is deprecated.
No further engineering work or support will happen.
If you are interested in further development of the code please feel free to fork it.


# Github Enterprise Backup

[![Build Status](https://travis-ci.org/zalando/ghe-backup.svg?branch=master)](https://travis-ci.org/zalando/ghe-backup)
[![Code Climate](https://codeclimate.com/github/zalando/ghe-backup/badges/gpa.svg)](https://codeclimate.com/github/zalando/ghe-backup)
[![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://github.com/zalando/ghe-backup/blob/master/LICENSE.txt)   

[Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup approach.

## Overview
[Github Enterprise](https://enterprise.github.com/) at Zalando Tech is a
[high availability](https://help.github.com/enterprise/2.11/admin/guides/installation/configuring-github-enterprise-for-high-availability/)
setup running master and replica instances on AWS.
The AWS account that runs the [high availability](https://help.github.com/enterprise/2.11/admin/guides/installation/configuring-github-enterprise-for-high-availability/)
setup also runs one backup host.
[Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup
can also run as a [POD](https://kubernetes.io/docs/concepts/workloads/pods/pod/#what-is-a-pod)
inside a [Kubernetes](https://kubernetes.io/) cluster.

We believe this backup approach provides reliable backup data even in case one AWS account or Kubernetes cluster is compromised.

![overview](/ZalandoGithubEnterprise.jpg "backup approach overview")

Basically [Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup
wraps github's [backup-utils](https://github.com/github/backup-utils) in a
[Docker](https://www.docker.com/) container.

If running on Kubernetes, a [stateful set](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
including [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) and
[volume claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) stores the actual backup data.
See a sample [statefulset below]()https://github.com/zalando/ghe-backup/blob/master/README.md#kubernetes-stateful-set,-volume,-volume-claim)
[Zalando Kubernetes](https://github.com/zalando-incubator/kubernetes-on-aws#kubernetes-on-aws) is based on AWS, so [volume claims
 are based on EBS](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#aws).

If running on AWS, an [EBS volume](https://aws.amazon.com/de/ebs/) stores the actual backup data.
This way one can access the data even if the regarding backup host is down.



## Local docker development

### create a ghe-backup docker image
```docker build --rm -t [repo name]:[tag] . ```  
e.g.  
```docker build --rm -t pierone.stups.zalan.do/machinery/ghe-backup:0.0.7 . ```

#### run the image  
```docker run -d --name [repo name]:[tag] ```  
e.g.  
```docker run -d --name ghe-backup pierone.stups.zalan.do/machinery/ghe-backup:0.0.7 ```

or with connected bash:  
```docker run -it --entrypoint /bin/bash --name [repo name]:[tag] ```    
e.g.  
```docker run -it --entrypoint /bin/bash --name ghe-backup pierone.stups.zalan.do/machinery/ghe-backup:0.0.7 ```

##### attach to the running local container
```docker attach --sig-proxy=false [repo name] ```  
###### detach from the running local container (does not stop the container)
```CTRL+C ```  

##### run bash in running docker container
```sudo docker exec -i -t [ContainerID] bash ```
###### exit bash
```exit ```


### IAM [policy](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html) settings

[Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup hosts contain
private ssh keys that have to match with public ssh keys registered on the Github Enterprise main instance.
Private ssh keys should not be propagated unencrypted with deployments.
AWS KMS allows to encrypt any kind of data, so this service is used to encrypt the private ssh key for both,
[Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) backup running on AWS and Kubernetes.
KMS actions are managed by policies to make sure only configured tasks can be performed.

A kms policy similar to the one shown below is needed to:   
* allow kms decryption of the encrypted ssh key
* access s3 bucket
* use EBS volume
```  
...
            "Resource": [  
                "arn:aws:s3:::[yourMintBucket]/[repo name]/*"  
            ]  
...
            "Effect": "Allow",  
            "Action": [  
                "ec2:DescribeVolumes",  
                "ec2:AttachVolume",  
                "ec2:DetachVolume"  
            ],  
            "Resource": "*"  
...
```   
You can find a full policy sample here in the [gist "ghe-backup-kms-policy-sample" ](https://gist.github.com/lotharschulz/725026cfdd599cf6243d)

Make sure you have an according [role](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) that allows managing your policy.

### Configure an [EBS](https://aws.amazon.com/de/ebs/) volume for backup data  

Backup data shall be saved on an [EBS](https://aws.amazon.com/de/ebs/) volume to persist backups even if the backup instance goes down. The creation of such an ebs volume is described in [creating-ebs-volume guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html).  
After creating an EBS volume, you have to make sure you can use it as described in [ebs-using-volumes](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html).

Pls note: You need to format the EBS volume before you use it, otherwise you may experience issues like:  
[_You must specify the file type_](https://forums.aws.amazon.com/thread.jspa?messageID=450413).  


## Tests
There are two kinds of tests available:
* python nose tests
* bash tests

Both can be run with ```./run-tests.sh```.  
Pls note:

* tests leveraging kms require aws logins e.g. via aws cli. Thats why those don not run on ci environments out of the box. The `run-tests.sh` script uses _zaws_ (a zalando internal tool that is the successor of the former open source tool mai)
* *make sure* you run ```bashtest/cleanup-tests.sh```  in order to clean up afterwards.

### Nosetest

#### decrypt test
* precondition: you are logged in with AWS e.g. using [mai](https://stups.io/mai)  
```mai login [awsaccount-role]```  
* test run:  
```nosetests -w python -v --nocapture test_extract_decrypt_kms.py```  

#### delete in stuck in progress files
```nosetests -w python -v --nocapture test_delete_instuck_progress.py```  

#### run all test minimum output
```nosetests -w python```

### Bash tests
Pls go to bashtest directory:
``` cd bashtest ``` and run the tests:  
``` ./test-convert-kms-private-ssh-key.sh ```  

### Running in an additional AWS account
Please adapt the cron tab definitions when running in another AWS account e.g. to the values in cron-ghe-backup-alternative.
This lowers the load on the Github Enterprise master with respect to backup attempts.


### Restore

Restoring backups is based on github's _(using the backup and restore commands)[https://github.com/github/backup-utils#using-the-backup-and-restore-commands]_.
The actual _ghe-restore_ command gets issued from the backup host. Please note: the backup restore can run for several hours.
(Nohup)[https://en.wikipedia.org/wiki/Nohup] is recommended to keep the restore process running even if the shell connection is lost.

sample steps include:
```
put ghe instance to restor to into maintenance mode
# ssh into your ec2 instance and exec into your container
# docker exec -it [container label or ID] bash/sh
# or
# exec into your pod
# kubectl exec -it [your pod e.g. statefulset-ghe-backup-0] bash/sh
nohup /backup/backup-utils/bin/ghe-restore -f [IP address of the ghe master to restore] &
# monitor the backup progress
tail -f nohup.out
```

## Contribution
pls refer to [CONTRIBUTING.md](CONTRIBUTING.md)

## Zalando specifics

### [Taupage AMI](https://github.com/zalando-stups/taupage)
The [Taupage AMI](https://github.com/zalando-stups/taupage) is mandatory for backup hosts of [Zalando Tech's ](https://tech.zalando.com/) [Github Enterprise](https://enterprise.github.com/) for compliance reasons.
As [Taupage AMI](https://github.com/zalando-stups/taupage) is part of [Stups](https://stups.io/), other [Stups](https://stups.io/) technologies like [Senza](https://github.com/zalando-stups/senza) are also used for local development.

### Upload Docker images to [pierone](https://github.com/zalando-stups/pierone) (a Zalando docker registry) would be:
```docker push [repo name]:[tag]```  
e.g.  
```docker push pierone.stups.zalan.do/machinery/ghe-backup:cdp-master-38```

### Senza yaml file
[Stups](https://stups.io/) requires a [senza yaml file](http://docs.stups.io/en/latest/components/senza.html#senza-info)
to deploy an artefact to AWS. Such a yaml file gets basically translated to
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


### EBS volumes with Senza
Please follow these instructions: [senza's storage guild](https://docs.stups.io/en/latest/user-guide/storage.html) to create a EBS volume the stups way.

### Kubernetes stateful set, volume, volume claim

The statefulset resource definition is the main kubernetes configuration file:
```
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
      name: statefulset-ghe-backup
spec:
  serviceName: deploy-ghe-backup
  replicas: 1
  template:
    metadata:
      labels:
        app: ghe-backup
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      containers:
      - name: container-{ghe-backup}
        image: pierone.stups.zalan.do/machinery/ghe-backup:cdp-master-38
        resources:
          requests:
            cpu: 100m
            memory: 1Gi
          limits:
            cpu: 400m
            memory: 4Gi
        volumeMounts:
        - name: data-{ghe-backup}
          mountPath: /data
        - name: {ghe-backup}-secret
          mountPath: /meta/ghe-backup-secret
          readOnly: true
        - name: podinfo
          mountPath: /details
          readOnly: false
      volumes:
      - name: {ghe-backup}-secret
        secret:
          secretName: {ghe-backup}-secret
      - name: podinfo
        downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
  volumeClaimTemplates:
  - metadata:
      name: data-ghe-backup
      annotations:
        volume.beta.kubernetes.io/storage-class: standard
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1000Gi
```

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
