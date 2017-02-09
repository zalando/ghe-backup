#!/usr/bin/env python3
from subprocess import check_output
from subprocess import Popen
import os


def get_pid(name):
    """Returns a list of pids, can be empty.
    @attention: inspired by http://stackoverflow.com/a/26688998 on 09/02/2017
    @author: Padraic Cunningham"""
    return list(map(int,check_output(["pidof",name]).split()))


def start_backup(name):
    pass
    #Popen(['sudo', name, '-v 1>> /var/log/ghe-prod-backup.log 2>&1'])


def trigger_backup(name):
    res = get_pid(name)
    if len(res) == 0: # process not running
        name2start = name[name.find(" ")+1:]
        start_backup(name2start)
        return name2start
    return ""


if __name__ == "__main__":
    trigger_backup("bash /backup/backup-utils/bin/ghe-backup")