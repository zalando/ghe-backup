#!/usr/bin/env python3
'''
deletes file in case it exists
'''

import os
import os.path
import time


def drop_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        os.remove(os.path.join(abs_folder, filename))
        return True
    return False


def drop_outdated_inprogress_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        mtime = os.stat(os.path.join(abs_folder, filename)).st_mtime
        now = time.gmtime()
        # TODO
        # check last modification of os.path.join(abs_folder, filename)
        #  smth like os.stat(os.path.join(abs_folder, filename)).st_mtime
        # check current time
        #  smth like now = time.gmtime()
        # compare both timestamps
        #  smth like
        #   nowvalue = datetime.datetime.fromtimestamp(calendar.timegm(now))
        #   mtimevalue = datetime.datetime.fromtimestamp(calendar.timegm(mtime))
        #   if datetime.timedelta(seconds=t2-t1) > one day:
        #     go delete
        return True
    return False

if __name__ == "__main__":
    try:
        drop_file('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        # print("error: file does not exists: %s" % e.message)
