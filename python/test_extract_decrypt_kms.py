#!/usr/bin/env python3
import nose.tools as nt

import os
import binascii
import extract_decrypt_kms
import unittest
import sys


class Test(unittest.TestCase):

    kms = None

    @classmethod
    def setupAll(cls):
        cls.kms = extract_decrypt_kms.Kms(file="/meta/taupage.yaml", key="kms_private_ssh_key", region="eu-west-1")

    @classmethod
    def teardownAll(cls):
        cls.kms = None

    @classmethod
    def test_several_aws_decrypt(cls, s=44, t=47):
        for i in range(s,t):
            print("\nrandomword({}): {}\n".format(i, cls.random_word(i)))
            cls.test_aws_decrypt(cls.random_word(i))

    @classmethod
    def random_word(cls, length):
        return binascii.b2a_hex(os.urandom(length)).decode('ascii')

    @classmethod
    def test_aws_decrypt(cls, to_encrypt="BCDE"):
        encryption_res = None
        try:
            encryption_res = cls.kms.aws_encrypt(key_id="b44f5008-cebc-4cba-b677-02c938f7a197", to_encrypt=to_encrypt)
        except Exception as nfe:
            if str(nfe).find("NotFoundException") > 0:
                # KMS operation can't be executed properly because either boto client
                # can't connect to an AWS account or the wrong one
                sys.stderr.write('\nExpected boto client error due to misconfigured AWS account: %s\n' % str(nfe))
            elif str(nfe).find("ExpiredToken") > 0:
                # KMS operation can't be executed properly because either AWS token exprired.
                sys.stderr.write('\nExpected boto client error due to expired token: %s\n' % str(nfe))
            elif str(nfe).find("credentials") > 0:
                # no boto client credentials in CI environment
                sys.stderr.write('\nExpected boto client error due to missing credentials: %s\n' % str(nfe))
            else:
                raise
        if encryption_res:
            decryption_res = cls.kms.aws_decrypt(to_decrypt=encryption_res)
            nt.assert_equal(to_encrypt, decryption_res)

    @classmethod
    def test_aws_decrypt_with_method_file_key_parameter(cls, to_encrypt="BCDE"):
        encryption_res = None
        try:
            encryption_res = cls.kms.aws_encrypt(key_id="b44f5008-cebc-4cba-b677-02c938f7a197", to_encrypt=to_encrypt)
        except Exception as nfe:
            if str(nfe).find("NotFoundException") > 0:
                # KMS operation can't be executed properly because either boto client
                # can't connect to an AWS account or the wrong one
                sys.stderr.write('\nExpected boto client error due to misconfigured AWS account: %s\n' % str(nfe))
            elif str(nfe).find("ExpiredToken") > 0:
                # KMS operation can't be executed properly because either AWS token exprired.
                sys.stderr.write('\nExpected boto client error due to expired token: %s\n' % str(nfe))
            elif str(nfe).find("credentials") > 0:
                # no boto client credentials in CI environment
                sys.stderr.write('\nExpected boto client error due to missing credentials: %s\n' % str(nfe))
            else:
                raise
        if encryption_res:
            decryption_res = cls.kms.aws_decrypt(to_decrypt=cls.kms.extract_kms_string(file="dummy_file", key="dummy_string"))
            nt.assert_not_equal(to_encrypt, decryption_res)

    @classmethod
    def test_aws_kms_client(cls):
        nt.assert_equal(str(cls.kms.aws_kms_client()._endpoint),
                        str(cls.kms.aws_kms_client(region="eu-west-1")._endpoint))