FROM zalando/ubuntu:14.04.2-1
MAINTAINER lothar.schulz@zalando.de

USER root
# folder structure
WORKDIR /backup
RUN mkdir -p /data/ghe-production-data/
RUN mkdir -p /backup/backup-utils/
RUN mkdir -p /var/log/

# backup-utils
# read package lists // update w/ latest security patches // install english // install git
RUN apt-get update -y && sudo apt-get install -y unattended-upgrades && sudo apt-get install -y language-pack-en && apt-get install -y git

RUN git clone -b stable https://github.com/github/backup-utils.git
COPY backup.config /backup/backup-utils/backup.config

# cron
COPY cron-ghe-backup /etc/cron.d/ghe-backup
RUN chmod 0644 /etc/cron.d/ghe-backup
RUN touch /var/log/ghe-prod-backup.log
CMD cron && tail -f /var/log/ghe-prod-backup.log
