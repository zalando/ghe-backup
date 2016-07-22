#!/usr/bin/env python3
'''
deletes file in case it exists
'''

import os
import os.path
from datetime import date


def drop_outdated_inprogress_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        modification_time = os.stat(os.path.join(abs_folder, filename)).st_mtime
        today = date.today()
        modification_day = date.fromtimestamp(modification_time)
        if today > modification_day:
            os.remove(os.path.join(abs_folder, filename))
            return True
    return False

if __name__ == "__main__":
    try:
        drop_outdated_inprogress_file('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        # print("error: file does not exists: %s" % e.message)
