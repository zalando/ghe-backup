#!/usr/bin/env python3
import subprocess
import sys
import typing


def get_pid(name: str) -> typing.List[int]:
    """Returns a list of pids, can be empty.
    @attention: inspired by http://stackoverflow.com/a/26688998 on 09/02/2017
    @author on stackoverflow: Padraic Cunningham"""
    if name:
        return [int(pid) for pid in subprocess.check_output(["pidof", name]).split()]
    return []


def start_ghe_backup(name: str) -> None:
    """
    Spawns process specified by given name
    :param name: process to be spawned
    """
    try:
        subprocess.Popen([name, '-v', '1>>', '/var/log/ghe-prod-backup.log', '2>&1'])
    except Exception as err:
        sys.stderr.write('ERROR: %sn' % str(err))


def trigger_backup(name: str, test: bool) -> str:
    """
    Check if there is a pid for the given name. If not, process after last space gets spawned.
    :param name: process thats pid will be requested
    :param test: does not start a process if false
    :return: string either empty or the executable that shall be spawned
    """
    res = get_pid(name)
    # process not running
    if not res:
        name2start = name[name.rfind(" ")+1:]
        if not test:
            start_ghe_backup(name2start)
        return name2start
    return ""


if __name__ == "__main__":
    trigger_backup("bash /backup/backup-utils/bin/ghe-backup", False)
