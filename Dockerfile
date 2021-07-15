FROM registry.opensource.zalan.do/library/python-3.8:latest
MAINTAINER team-code@zalando.de

ARG BACKUP_UTILS_VERSION=stable

# folder structure and user
RUN \
# read package lists
  apt-get update -y && \
# update w/ latest security patches
# install python pip3 & english, git, screen etc
  apt-get install -y --no-install-recommends unattended-upgrades python3 python3-dev python3-pip python3-yaml && \
  apt-get install -y --no-install-recommends git && \
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
  git clone https://github.com/github/backup-utils.git && \
  git -C /backup/backup-utils checkout $BACKUP_UTILS_VERSION

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
  chmod 0644 /etc/cron.d/ghe-backup && \
  chmod +x /kms/extract_decrypt_kms.py && \
  chmod +x /kms/convert-kms-private-ssh-key.sh && \
  chmod +x /delete-instuck-backups/delete_instuck_progress.py && \
  chmod +x /start_backup.sh && \
  chmod +x /backup/replace-convert-properties.sh && \
  chmod +x /backup/final-docker-cmd.sh

USER root

# cron must run as root
CMD "/backup/final-docker-cmd.sh"
