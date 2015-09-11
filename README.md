# ghe-backup
github enterprise backup

## create docker image
docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:[tag] .  
e.g.  
docker build --rm -t pierone.stups.zalan.do/bus/ghe-backup:0.0.1 .  

## run the image
docker run -dit --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:[tag]  
e.g.  
docker run -dit --name ghe-backup pierone.stups.zalan.do/bus/ghe-backup:0.0.1  
