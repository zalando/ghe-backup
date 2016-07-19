#!/usr/bin/env python3

import nose.tools as nt
import deleteInstuckProgress


def test_drop_file(abs_folder='~', filename='test.txt'):
    res = deleteInstuckProgress.drop_file(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)

def test_drop_outdated_inprogress_file(abs_folder='~', filename='in-progress'):
    res = deleteInstuckProgress.drop_outdated_inprogress_file(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)
