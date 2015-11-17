#!/usr/bin/env python3
'''
inspired by https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/parse-yaml.py
Prints value of provided key based on given yaml file.
'''

import argparse
import yaml
#import pprint

def flatten_data(data: dict, prevkeys: list, flatten_vars: dict):
    for key, val in data.items():
        key = str(key)
        previouskeys = prevkeys.copy()
        previouskeys.append(key)
        if isinstance(val, dict):
            flatten_data(val, previouskeys, flatten_vars)
        elif isinstance(val, list):
            for i, item in enumerate(val):
                if isinstance(item, dict):
                    flatten_data(item, previouskeys, flatten_vars)
                else:
                    flatten_vars['{}'.format("-".join(previouskeys))] = val
        else:
            flatten_vars['{}'.format("-".join(previouskeys))] = val

def main(args):

    data = yaml.safe_load(args.file)
    #pp = pprint.PrettyPrinter(indent=1)
    #pp.pprint(data)

    flatten_vars = {}
    flatten_data(data, [], flatten_vars)
    #pp.pprint(flatten_vars)
    for key in flatten_vars.keys():
        if args.key in key:
            print(flatten_vars[key])
            break

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', type=argparse.FileType('r'))
    parser.add_argument('-k', '--key', help="taupage yaml 'key'", required=True)

    args = parser.parse_args()

    main(args)
