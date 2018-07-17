FROM registry.opensource.zalan.do/stups/python:3.6.5-20
MAINTAINER lothar.schulz@zalando.de

# folder structure and user
RUN \
# read package lists
  apt-get update -y && \
  apt-get install -y sudo && \
# create application user
  useradd -d /backup -u 998 -o -c "application user" application && \
# allow su
  echo "application ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/application && \
  chmod 0440 /etc/sudoers.d/application && \
# update w/ latest security patches
# install python pip3 & english, git, screen etc
  apt-get install -y --no-install-recommends unattended-upgrades python3 python3-dev && \
  apt-get install -y --no-install-recommends python3-pip python3-yaml && \
  apt-get install -y --no-install-recommends language-pack-en git && \
  apt-get install -y --no-install-recommends ssh && \
  apt-get install -y --no-install-recommends bash && \
  apt-get install -y --no-install-recommends rsync && \
  apt-get install -y --no-install-recommends cron && \
# install boto3
  pip3 install --upgrade boto boto3 && \
# clean apt-get lists
  rm -rf /var/lib/apt/lists/* && \
# create directories
  mkdir -p /backup/backup-utils/ && \
  mkdir -p /kms && mkdir -p /var/log/ && mkdir /delete-instuck-backups
WORKDIR /backup

RUN \
# clone backup-utils
  git clone -b stable https://github.com/github/backup-utils.git && \
  git -C /backup/backup-utils pull

# copy predefined backup config
COPY backup.config /backup/backup-utils/backup.config

# copy files to decrypt private ssh key using kms
COPY python/extract_decrypt_kms.py /kms/extract_decrypt_kms.py
COPY convert-kms-private-ssh-key.sh /kms/convert-kms-private-ssh-key.sh
COPY start_backup.sh /start_backup.sh

# copy file to drop in stuck backup
COPY python/delete_instuck_progress.py /delete-instuck-backups/delete_instuck_progress.py

# copy cron job
COPY cron-ghe-backup /etc/cron.d/ghe-backup

# copy finale CMD commands
COPY final-docker-cmd.sh /backup/final-docker-cmd.sh
COPY replace-convert-properties.sh /backup/replace-convert-properties.sh


#PLACEHOLDER_4_COPY_SCM_SOURCE_JSON

RUN \
# change mode of files
  chown -R application: /backup && \
  chown -R application: /kms && \
  chown -R application: /delete-instuck-backups && \
  chown -R application: /start_backup.sh && \
  chmod 0700 /kms/extract_decrypt_kms.py && \
  chmod 0700 /kms/convert-kms-private-ssh-key.sh && \
  chmod 0644 /etc/cron.d/ghe-backup && \
  chmod 0700 /delete-instuck-backups/delete_instuck_progress.py && \
  chmod 0700 /start_backup.sh && \
  chmod 0700 /backup/replace-convert-properties.sh && \
  chmod 0700 /backup/final-docker-cmd.sh && \
  mkfifo /var/log/ghe-prod-backup.log && \
  chown -R application: /var/log/ghe-prod-backup.log && \
  touch /var/log/ghe-delete-instuck-progress.log && \
  chown -R application: /var/log/ghe-delete-instuck-progress.log

USER application

# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user mentions to avoid sudo,
# however cron as part of the final-docker-cmd.sh has to run as
CMD "/backup/final-docker-cmd.sh"

