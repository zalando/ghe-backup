FROM zalando/ubuntu:14.04.2-1
MAINTAINER lothar.schulz@zalando.de

ADD cron-ghe-backup /etc/cron.d/ghe-backup

RUN chmod 0644 /etc/cron.d/ghe-backup

RUN touch /var/log/ghe-backup.log 

CMD cron && tail -f /var/log/ghe-backup.log
