#!/usr/bin/env python3
'''
deletes file in case it exists
'''

import os
import os.path
from datetime import datetime
from datetime import date


def drop_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        os.remove(os.path.join(abs_folder, filename))
        return True
    return False


def drop_outdated_inprogress_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        modification_time = os.stat(os.path.join(abs_folder, filename)).st_mtime
        modification_time_year = int(datetime.fromtimestamp(modification_time).strftime('%Y'))
        modification_time_month = int(datetime.fromtimestamp(modification_time).strftime('%m'))
        modification_time_day = int(datetime.fromtimestamp(modification_time).strftime('%d'))

        today = date.today()
        modification_day = date(modification_time_year, modification_time_month, modification_time_day)

        if (today - modification_day).days > 1:
            os.remove(os.path.join(abs_folder, filename))
            return True
    return False

if __name__ == "__main__":
    try:
        drop_file('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        # print("error: file does not exists: %s" % e.message)
