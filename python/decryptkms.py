#!/usr/bin/env python3
'''
@attention: This helper is inspired by https://github.com/zalando/kmsclient &
https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/decrypt-kms.py on 2015 10 15
'''

import boto3
import base64
import requests
import sys

# so far use ireland only
region_name = "eu-west-1"


def aws_kms_client(region_name, aws_access_key, aws_secret_key):
    return boto3.client(service_name='kms', region_name=region_name,
                        aws_secret_access_key=aws_access_key,
                        aws_access_key_id=aws_secret_key
                        )


def aws_encrypt(key_id, to_encrypt, region=region_name, aws_access_key=None, aws_secret_key=None):
    client = aws_kms_client(region, aws_access_key, aws_secret_key)
    response = client.encrypt(
        KeyId=key_id,
        Plaintext=to_encrypt
    )
    return str(base64.b64encode(response['CiphertextBlob']), "UTF-8")


def aws_decrypt(to_decrypt, region=region_name, aws_access_key=None, aws_secret_key=None):
    client = aws_kms_client(region, aws_access_key, aws_secret_key)
    response = client.decrypt(
        CiphertextBlob=base64.b64decode(to_decrypt)
    )
    return str(response['Plaintext'], "UTF-8")

if __name__ == "__main__":
    for arg in sys.argv[1:]:
        try:
            print(aws_decrypt(arg, region_name, aws_access_key=None, aws_secret_key=None))
        except ValueError:
            print("Invalid KMS key.")
