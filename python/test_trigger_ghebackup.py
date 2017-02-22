#!/usr/bin/env python3

import trigger_ghebackup
import nose.tools as nt
import nose.tools as nottest


def test_trigger_backup(pname="bash /backup/backup-utils/bin/ghe-backup"):
    nt.assert_true("/backup/backup-utils/bin/ghe-backup" == trigger_ghebackup.trigger_backup(pname, True),
                   "'" + pname + "' should have been started.")

# does not work with travis-ci.org
@nottest
def test_trigger_nano(pname="nano"):
    nt.assert_true(pname == trigger_ghebackup.trigger_backup(pname, True),
                   "'" + pname + "' should have been started.")


def test_trigger_bash(pname="bash"):  # assuming tests run on *nix
    nt.assert_false(pname == trigger_ghebackup.trigger_backup(pname, True),
                    "'" + pname + "' should have been _not_ started.")
