#!/usr/bin/env python3

"""
@attention: inspired by
- https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/parse-yaml.py on 2015 11 16
- https://github.com/zalando/kmsclient on 2015 10 15
- https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/decrypt_kms.py on 2015 10 15
"""

import argparse
import yaml
import boto3
import base64
# import pprint


def extract_kms_string(arguments):
    """
    Prints value of provided key based on given yml file
    :param arguments: file taupage yml and kms key within yml details
    :return: the kms string identified by the kms key
    """

    data = yaml.safe_load(arguments.file)
    # pp = pprint.PrettyPrinter(indent=1)
    # print("----data-----")
    # pp.pprint(data)
    # print("---/data-----")

    if arguments.key in data.keys():
        result = data[arguments.key]
        if result.startswith('aws:kms:'):
            result = result.replace('aws:kms:', '', 1)
        return result


def aws_kms_client(region_name):
    return boto3.client(service_name='kms', region_name=region_name)


def aws_encrypt(key_id, to_encrypt, region):
    client = aws_kms_client(region)
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

    kms_string = extract_kms_string(args)

    print(aws_encrypt(key_id=kms_string, region=args.region))
