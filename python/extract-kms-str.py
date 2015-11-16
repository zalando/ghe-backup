#!/usr/bin/env python3
'''
inspired by https://github.com/zalando-stups/taupage/blob/master/runtime/opt/taupage/bin/parse-yaml.py
Generate script output to given reg exp
'''


import argparse
import re
import shlex
import yaml
import re

VALID_KEY_PATTERN = re.compile('^[a-zA-Z0-9_]+$')


def collect_env_vars(data: dict, env_vars: dict):
    for key, val in data.items():
        key = str(key)
        if VALID_KEY_PATTERN.match(key):
            if isinstance(val, dict):
                collect_env_vars(val, env_vars)
            else:
                env_vars['{}'.format(key)] = val


def main(args):
    data = yaml.safe_load(args.file)

    env_vars = {}
    collect_env_vars(data, env_vars)

    result = ""

    for key, val in sorted(env_vars.items()):
        findings = re.findall(args.regexp, str(val))
        if findings:
                result += findings[0] # only first one
                break
    if args.prefix2remove:
        result = result[len(args.prefix2remove):len(result)]
    if args.suffix2remove:
        result = result[0:len(args.suffix2remove)*-1]
    print(result)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', type=argparse.FileType('r'))
    parser.add_argument('-r', '--regexp', help="regular expression to ", required=True)
    parser.add_argument('-p', '--prefix2remove')
    parser.add_argument('-s', '--suffix2remove')

    args = parser.parse_args()

    main(args)
