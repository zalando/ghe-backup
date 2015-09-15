# ghe-backup
docker stups AWS based backup for github enterprise at zalando

## create scm-source.json
create a bash script ('create-scm-source.sh') as described in   http://docs.stups.io/en/latest/user-guide/application-development.html  
make the script executable: chmod +x create-scm-source.sh  
run create-scm-source.sh e.g. ./create-scm-source.sh that produces a scm-source.json  

## create docker image
docker build --rm -t [repo name]:[tag] .  
e.g.  
docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:0.0.2 .  

## run the image
docker run -d --name [repo name]:[tag]  
e.g.  
docker run -d --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.2  

### attach to the running container
docker attach --sig-proxy=false ghe-backup
### detach from the running container (does not stop the container) 
CTRL+C

## upload to pierone
docker push [repo name]:[tag]  
e.g.  
docker push pierone.stups.zalan.do/bus/ghe-backup:0.0.2  
