#!/usr/bin/env python3

import os
import os.path
import nose.tools as nt
import delete_instuck_progress
import shutil

def create_test_files(abs_folder='~/tmp', filename='in-progress'):
    if not os.path.exists(os.path.join(abs_folder, filename)):
        if not os.path.isdir(abs_folder):
            os.makedirs(abs_folder)
        with open(os.path.join(abs_folder, filename), 'a'):
            os.utime(os.path.join(abs_folder, filename), None)


def test_drop_file(abs_folder='~/3456', filename='test.txt'):
    create_test_files(abs_folder, filename)
    res = delete_instuck_progress.drop_file(abs_folder, filename)
    nt.assert_equal(True, res)


def test_drop_outdated_inprogress_file(abs_folder='~', filename='in-progress'):
    create_test_files('~', 'in-progress')
    res = delete_instuck_progress.drop_outdated_inprogress_file(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)


def cleanup_test_files():
    if os.path.exists('~'):
        shutil.rmtree('~')