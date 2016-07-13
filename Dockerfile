FROM registry.opensource.zalan.do/stups/python:3.5.1-21
MAINTAINER lothar.schulz@zalando.de

USER root
# folder structure and user
RUN \
  useradd -d /backup -u 998 -o application && \
  mkdir -p /data/ghe-production-data/ && mkdir -p /backup/backup-utils/ && \
  mkdir -p /kms && mkdir -p /var/log/ && mkdir /delete-instuck-backups
WORKDIR /backup

# read package lists
# update w/ latest security patches
# install python pip3 boto3 pyyaml & english & git
# clone backup-utils
RUN \
  apt-get update -y && \
  apt-get install -y unattended-upgrades python3 python3-dev python3-pip python3-yaml language-pack-en git && \
  pip3 install --upgrade boto boto3 && \
  rm -rf /var/lib/apt/lists/* && \
  git clone -b stable https://github.com/github/backup-utils.git && \
  git -C /backup/backup-utils pull

# copy predefined backup config
COPY backup.config /backup/backup-utils/backup.config

# copy files to decrypt private ssh key using kms
COPY python/decryptkms.py /kms/decryptkms.py
COPY python/extract-kms-str.py /kms/extract-kms-str.py
COPY convert-kms-private-ssh-key.sh /kms/convert-kms-private-ssh-key.sh

# copy file to drop in stuck backup
COPY python/delete-instuck-progress.py /delete-instuck-backups/delete-instuck-progress.py

# copy cron job
COPY cron-ghe-backup /etc/cron.d/ghe-backup

# change mode of files
RUN \
  chown -R application: /data && \
  chown -R application: /backup && \
  chown -R application: /kms && \
  chown -R application: /delete-instuck-backups && \
  chmod 0700 /kms/extract-kms-str.py && \
  chmod 0700 /kms/convert-kms-private-ssh-key.sh && \
  chmod 0644 /etc/cron.d/ghe-backup && \
  chmod 0700 /delete-instuck-backups/delete-instuck-progress.py && \
  mkfifo /var/log/ghe-prod-backup.log

# delete-instuck-progress log
RUN \
  touch /var/log/ghe-delete-instuck-progress.log && \
  chown -R application: /var/log/ghe-delete-instuck-progress.log

CMD python3 /delete-instuck-backups/delete-instuck-progress.py && \
    /kms/convert-kms-private-ssh-key.sh && \
    cron && \
    tail -F /var/log/ghe-prod-backup.log
