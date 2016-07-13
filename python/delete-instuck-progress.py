#!/usr/bin/env python3
'''
delete in-progress file in case it exists
'''

import os
import os.path

def dropfile(abs_folder, filename):
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
    os.remove(os.path.join(abs_folder, filename))

if __name__ == "__main__":
    try:
        dropfile('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        #print("error: file does not exists: %s" % e.message)
