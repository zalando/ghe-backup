FROM registry.opensource.zalan.do/stups/python:3.6.3-15
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
# install python pip3 pyyaml & english, git, screen
  apt-get install -y --no-install-recommends unattended-upgrades python3=3.5.1-3 python3-dev=3.5.1-3 && \
  apt-get install -y --no-install-recommends python3-pip=8.1.1-2ubuntu0.4 python3-yaml=3.11-3build1 && \
  apt-get install -y --no-install-recommends language-pack-en=1:16.04+20161009 git=1:2.7.4-0ubuntu1.3 && \
  apt-get install -y --no-install-recommends ssh=1:7.2p2-4ubuntu2.2 && \
  apt-get install -y --no-install-recommends bash=4.3-14ubuntu1.2 && \
  apt-get install -y --no-install-recommends rsync=3.1.1-3ubuntu1 && \
  apt-get install -y --no-install-recommends cron=3.0pl1-128ubuntu2 && \
# install boto3
  pip3 install --upgrade boto==2.48.0 boto3==1.4.7 && \
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
  chmod 0700 /backup/final-docker-cmd.sh && \
  mkfifo /var/log/ghe-prod-backup.log && \
  chown -R application: /var/log/ghe-prod-backup.log && \
  touch /var/log/ghe-delete-instuck-progress.log && \
  chown -R application: /var/log/ghe-delete-instuck-progress.log

USER application

# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user mentions to avoid sudo,
# however cron as part of the final-docker-cmd.sh has to run as
CMD "/backup/final-docker-cmd.sh"
