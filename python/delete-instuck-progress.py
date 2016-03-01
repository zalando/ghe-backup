#!/usr/bin/env python3
'''
delete in-progress file in case it exists
'''

import os
import os.path

def dropfile(abs_folder, filename):
    os.remove(os.path.join(abs_folder, filename))

if __name__ == "__main__":
    try:
        dropfile('/data/ghe-production-data', 'in-progress')
    except FileNotFoundError as e:
        pass
        #print("error: file does not exists: %s" % e.message)
