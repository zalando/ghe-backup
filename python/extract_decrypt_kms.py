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

    def __init__(self,
                 file: str,
                 key: str,
                 region: str):
        self.file = file
        self.key = key
        self.region = region
        self.service_name = 'kms'

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
        return boto3.client(service_name=cls.service_name, region_name=cls.region_name)

    @classmethod
    def aws_decrypt(cls, data2decrypt) -> str:
        client = cls.aws_kms_client()
        response = client.decrypt(
            CiphertextBlob=base64.b64decode(data2decrypt)
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
    print(kms.aws_decrypt(data2decrypt=kms.extract_kms_string(args)))
