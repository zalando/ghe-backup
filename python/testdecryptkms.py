#!/usr/bin/env python3
import nose.tools as nt

import decryptkms
import os,binascii


def test_several_aws_decrypt(s=10, t=25):
    for i in range(s,t):
        print("\nrandomword({}): {}\n".format(i, randomword(i)))
        test_aws_decrypt(randomword(i))


def randomword(length):
    return binascii.b2a_hex(os.urandom(length)).decode('ascii')


def test_aws_decrypt(toencrypt="BCDE"):
    print("\ntoencrypt: {}\n".format(toencrypt))
    encryption_res = decryptkms.aws_encrypt(key_id="b44f5008-cebc-4cba-b677-02c938f7a197", to_encrypt=toencrypt)
    print("encryption_res: ", encryption_res)
    decryption_res = decryptkms.aws_decrypt(to_decrypt = encryption_res)
    print("decryption_res: ", decryption_res)
    nt.assert_equal(toencrypt, decryption_res)
