#!/usr/bin/env python3

import nose.tools as nt
import delete_instuck_progress


def test_drop_file(abs_folder='~', filename='test.txt'):
    res = delete_instuck_progress.drop_file(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)

def test_drop_outdated_inprogress_file(abs_folder='~', filename='in-progress'):
    res = delete_instuck_progress.drop_outdated_inprogress_file(abs_folder, filename)
    # nt.assert_equal(True, res)
    nt.assert_equal(False, res)
