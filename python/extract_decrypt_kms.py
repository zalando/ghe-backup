#!/usr/bin/env python3

"""
@attention: inspired by
- https://github.com/zalando/kmsclient on 2015 10 15
- https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/decrypt_kms.py on 2015 10 15
"""

import argparse
import yaml
import boto3
import base64
# import pprint


class Kms:
    service_name = 'kms'
    aws_kms_str = 'aws:kms:'

    @classmethod
    def __init__(cls,
                 file: str,
                 key: str,
                 region: str):
        cls.file = file
        cls.key = key
        cls.region = region

    @classmethod
    def extract_kms_string(cls, file: __file__, key: str) -> str:
        """
        Prints value of provided key based on given yml file
        :param file: taupage yml file
        :param key: kms key string
        :return: the kms string identified by the kms key
        """

        data = yaml.safe_load(file if file is not None else cls.file)
        # pp = pprint.PrettyPrinter(indent=1)
        # print("----data-----")
        # pp.pprint(data)
        # print("---/data-----")

        kms_key = key if key is not None else cls.key
        if type(dict) is type(data) and kms_key in data.keys():
            result = data[kms_key]
            if result.startswith(cls.aws_kms_str):
                result = result.replace(cls.aws_kms_str, '', 1)
            return result
        return None

    @classmethod
    def aws_kms_client(cls, region: str = None) -> str:
        return boto3.client(service_name=cls.service_name, region_name=region if region is not None else cls.region)

    @classmethod
    def aws_decrypt(cls, to_decrypt: str) -> str:
        if type(None) is type(to_decrypt):
            return None
        client = cls.aws_kms_client()
        response = client.decrypt(
            CiphertextBlob=base64.b64decode(to_decrypt)
        )
        return str(response['Plaintext'], "UTF-8")

    @classmethod
    def aws_encrypt(cls, key_id: str, to_encrypt: str) -> str:
        if type(None) is type(key_id) or type(None) is type(to_encrypt):
            return None
        client = cls.aws_kms_client()
        response = client.encrypt(
            KeyId=key_id,
            Plaintext=to_encrypt
        )
        return str(base64.b64encode(response['CiphertextBlob']), "UTF-8")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', help="taupage yml file", required=True, type=argparse.FileType('r'))
    parser.add_argument('-k', '--key', help="taupage yml 'key'", required=True)
    parser.add_argument('-r', '--region', help="aws region", required=True)

    args = parser.parse_args()

    kms = Kms(file=args.file, key=args.key, region=args.region)
    print(kms.aws_decrypt(to_decrypt=kms.extract_kms_string(args)))
