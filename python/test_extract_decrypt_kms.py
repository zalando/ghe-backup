#!/usr/bin/env python3
import nose.tools as nt

import os,binascii
import extract_decrypt_kms
import unittest


class Test(unittest.TestCase):

    kms = None

    @classmethod
    def setupAll(cls):
        cls.kms = extract_decrypt_kms.Kms(file="/meta/taupage.yaml", key="kms_private_ssh_key", region="eu-west-1")

    @classmethod
    def teardownAll(cls):
        cls.kms = None

    @classmethod
    def test_several_aws_decrypt(cls, s=42, t=47):
        for i in range(s,t):
            print("\nrandomword({}): {}\n".format(i, cls.random_word(i)))
            cls.test_aws_decrypt(cls.random_word(i))

    @classmethod
    def random_word(cls, length):
        return binascii.b2a_hex(os.urandom(length)).decode('ascii')

    @classmethod
    def test_aws_decrypt(cls, to_encrypt="BCDE"):
        print("\nto_encrypt: {}\n".format(to_encrypt))
        encryption_res = cls.kms.aws_encrypt(key_id="b44f5008-cebc-4cba-b677-02c938f7a197", to_encrypt=to_encrypt)
        print("encryption_res: ", encryption_res)
        decryption_res = cls.kms.aws_decrypt(to_decrypt=encryption_res)
        print("decryption_res: ", decryption_res)
        nt.assert_equal(to_encrypt, decryption_res)

    @classmethod
    def test_aws_decrypt_with_method_file_key_parameter(cls, to_encrypt="BCDE"):
        print("\nto_encrypt: {}\n".format(to_encrypt))
        encryption_res = cls.kms.aws_encrypt(key_id="b44f5008-cebc-4cba-b677-02c938f7a197", to_encrypt=to_encrypt)
        print("encryption_res: ", encryption_res)
        decryption_res = cls.kms.aws_decrypt(to_decrypt=cls.kms.extract_kms_string(file="dummy_file", key="dummy_string"))
        print("decryption_res: ", decryption_res)
        nt.assert_not_equal(to_encrypt, decryption_res)

    @classmethod
    def test_aws_kms_client(cls):
        nt.assert_equal(str(cls.kms.aws_kms_client()._endpoint),
                        str(cls.kms.aws_kms_client(region="eu-west-1")._endpoint))