#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

import sys
import argparse
import pexpect

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('cmd', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    run(args)

def run(args):
    child = pexpect.spawn(args.cmd[0], args.cmd[1:], encoding='utf-8')
    child.logfile = sys.stdout
    child.expect('TEST_PASS', timeout=3)

if __name__ == '__main__':
    main()
