FROM registry.opensource.zalan.do/stups/python:3.5-cd26
MAINTAINER lothar.schulz@zalando.de

#USER root
# folder structure and user
RUN \
  apt-get install -y sudo && \
  useradd -d /backup -u 998 -o -c "application user" application && \
  echo "application ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/application && \
  chmod 0440 /etc/sudoers.d/application && \
  mkdir -p /data/ghe-production-data/ && mkdir -p /backup/backup-utils/ && \
  mkdir -p /kms && mkdir -p /var/log/ && mkdir /delete-instuck-backups
WORKDIR /backup

# read package lists
# update w/ latest security patches
# install python pip3 boto3 pyyaml & english & git
# clone backup-utils
RUN \
  apt-get update -y && \
  apt-get install -y  --no-install-recommends unattended-upgrades python3=3.4.6 python3-dev=3.3.2 python3-pip=1.4.1 && \
  python3-yaml=3.10 language-pack-en=13.10+20131012 git=2.14.3 screen=4.6.2 && \
  pip3 install --upgrade boto==1.4.7 boto3==1.4.7 && \
  rm -rf /var/lib/apt/lists/* && \
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

# change mode of files
RUN \
  chown -R application: /data && \
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
  mkfifo /var/log/ghe-prod-backup.log

# delete_instuck_progress log
RUN \
  touch /var/log/ghe-delete-instuck-progress.log && \
  chown -R application: /var/log/ghe-delete-instuck-progress.log

CMD ["su", "-", "application", "-c", "/backup/final-docker-cmd.sh"]
