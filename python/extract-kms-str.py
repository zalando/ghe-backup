#!/usr/bin/env python3
'''
inspired by https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/parse-yaml.py
Prints value of provided key based on given yaml file.
'''

import argparse
import yaml
# import pprint


def main(args):

    data = yaml.safe_load(args.file)
    # pp = pprint.PrettyPrinter(indent=1)
    # print("----data-----")
    # pp.pprint(data)
    # print("---/data-----")

    if args.key in data.keys():
        result = data[args.key]
        if result.startswith('aws:kms:'):
            result = result.replace('aws:kms:', '', 1)
        print(result)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', type=argparse.FileType('r'))
    parser.add_argument('-k', '--key', help="taupage yaml 'key'", required=True)

    args = parser.parse_args()

    main(args)
