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

    @classmethod
    def __init__(cls,
                 file: str = None,
                 key: str = None,
                 region: str = None):
        cls.file = file
        cls.key = key
        cls.region = region
        cls.service_name = 'kms'

    @classmethod
    def extract_kms_string(cls) -> str:
        """
        Prints value of provided key based on given yml file
        :param arguments: file taupage yml and kms key within yml details
        :return: the kms string identified by the kms key
        """

        data = yaml.safe_load(cls.file)
        # pp = pprint.PrettyPrinter(indent=1)
        # print("----data-----")
        # pp.pprint(data)
        # print("---/data-----")

        if cls.key in data.keys():
            result = data[cls.key]
            if result.startswith('aws:kms:'):
                result = result.replace('aws:kms:', '', 1)
            return result

    @classmethod
    def aws_kms_client(cls) -> str:
        return boto3.client(service_name=cls.service_name, region_name=cls.region)

    @classmethod
    def aws_decrypt(cls, to_decrypt) -> str:
        client = cls.aws_kms_client()
        response = client.decrypt(
            CiphertextBlob=base64.b64decode(to_decrypt)
        )
        return str(response['Plaintext'], "UTF-8")

    @classmethod
    def aws_encrypt(cls, key_id, to_encrypt) -> str:
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
