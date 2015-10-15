FROM zalando/ubuntu:14.04.2-1
MAINTAINER lothar.schulz@zalando.de

USER root
# folder structure and user
RUN \
  useradd -d /backup -u 998 -o application && \
  mkdir -p /data/ghe-production-data/ && mkdir -p /backup/backup-utils/ && \
  mkdir -p /kms && mkdir -p /var/log/
WORKDIR /backup

# read package lists
# update w/ latest security patches
# install python pip boto pyyaml & english & git
# clone backup-utils
RUN \
  apt-get update -y && \
  apt-get install -y unattended-upgrades python3 python3-dev python3-pip python3-yaml language-pack-en git && \
  pip3 install --upgrade boto boto3 && \
  rm -rf /var/lib/apt/lists/* && \
  git clone -b stable https://github.com/github/backup-utils.git

# copy predefined backup config
COPY backup.config /backup/backup-utils/backup.config

# copy scm-source.json
COPY scm-source.json /scm-source.json

# copy files to decrypt private ssh key using kms
COPY python/decryptkms.py /kms/decryptkms.py
COPY python/parseyaml.py /kms/parseyaml.py
COPY convert-kms-private-ssh-key.sh /kms/convert-kms-private-ssh-key.sh

# copy cron job
COPY cron-ghe-backup /etc/cron.d/ghe-backup

# change mode of files
RUN \
  chown -R application: /data && \
  chown -R application: /backup && \
  chown -R application: /kms && \
  chmod 0700 /kms/parseyaml.py && \
  chmod 0700 /kms/convert-kms-private-ssh-key.sh && \
  chmod 0644 /etc/cron.d/ghe-backup && \
  mkfifo /var/log/ghe-prod-backup.log

CMD /kms/convert-kms-private-ssh-key.sh && cron && tail -F /var/log/ghe-prod-backup.log
#CMD cron && tail -f /var/log/ghe-prod-backup.log && /kms/convert-kms-private-ssh-key.sh
