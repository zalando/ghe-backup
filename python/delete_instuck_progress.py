#!/usr/bin/env python3
'''
deletes file in case it exists
'''

import os
import os.path
from datetime import datetime
from datetime import date
# import time
# from datetime import timedelta


def drop_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        os.remove(os.path.join(abs_folder, filename))
        return True
    return False


def drop_outdated_inprogress_file(abs_folder, filename):
    if os.path.isfile(os.path.join(abs_folder, filename)):
        # modification_time = os.stat(os.path.join(abs_folder, filename)).st_mtime
        # now = time.gmtime()
        # print("\nmtime: " + str(modification_time))
        # print("now: " + str(now))
        # dtnow = datetime.fromtimestamp(time.mktime(now))
        # print("dtnow: " + str(dtnow))
        # dtnow2 = datetime.now()
        # print("dtnow2: " + str(dtnow2))
        # dtnow2_days = datetime.strptime(str(dtnow2), '%Y-%m-%d')
        # print("dtnow2_days: " + str(dtnow2_days))
        #
        # modification_datetime=datetime.fromtimestamp(modification_time).strftime('%Y-%m-%d %H-%M-%S.%f')
        # print("modification_datetime: " + modification_datetime)

        modification_time = os.stat(os.path.join(abs_folder, filename)).st_mtime
        modification_time_year = int(datetime.fromtimestamp(modification_time).strftime('%Y'))
        modification_time_month = int(datetime.fromtimestamp(modification_time).strftime('%m'))
        modification_time_day = int(datetime.fromtimestamp(modification_time).strftime('%d'))
        print("\nmodification_time_year: " + str(modification_time_year))
        print("modification_time_month: " + str(modification_time_month))
        print("modification_time_day: " + str(modification_time_day))

        today = date.today()
        # modification_day = date(2008, 12, 25)
        modification_day = date(modification_time_year, modification_time_month, modification_time_day)

        print("\ndiff.days: " + str((today - modification_day).days))
        if (today - modification_day).days > 1:
            print("\nabout to remove: " + os.path.join(abs_folder, filename))
            os.remove(os.path.join(abs_folder, filename))
            print("\nos.path.isfile(os.path.join(abs_folder, filename)): " + str(os.path.isfile(os.path.join(abs_folder, filename))))

        # delta = dtnow2 - modification_datetime
        # print("delta" + str(delta))
        # print("delta.days" + str(delta.days))

        # http://stackoverflow.com/questions/8022161/python-converting-from-datetime-datetime-to-time-time
        # http://stackoverflow.com/questions/12400256/python-converting-epoch-time-into-the-datetime

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

        #return True
        return False
    return False

if __name__ == "__main__":
    try:
        drop_file('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        # print("error: file does not exists: %s" % e.message)
