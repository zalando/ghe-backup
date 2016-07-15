#!/usr/bin/env python3

import nose.tools as nt
import deleteInstuckProgress


def testdropfile(abs_folder='~', filename='test.txt'):
    res = deleteInstuckProgress.dropfile(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)


def testdropinprogress(abs_folder='~', filename='in-progress'):
    res = deleteInstuckProgress.dropinprogress(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)


def testdropinprgressfileallowed(abs_folder='~', filename='in-progress'):
    res = deleteInstuckProgress.dropinprgressfileallowed(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)
