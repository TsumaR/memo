#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import os
import pandas as pd
import subprocess
import sys

FOUT = 'count_matrix.txt'
FBAM = 'cln*.bam'

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('gtf', help='GTF file')
    ap.add_argument('smpl', help='sample information file')
    ap.add_argument('-b', '--bam', dest='fbam', action='store',
                    metavar='FILE', default=FBAM,
                    help='bam file name, default=%s' % FBAM)
    ap.add_argument('-o', '--output', dest='fout', action='store',
                    metavar='FILE', default=FOUT,
                    help='output file path, default=%s' % FOUT)
    ap.add_argument('-p', '--paired-end', dest='pair',
                    action='store_true', default=False,
                    help='paired end read')
    ap.add_argument('-T', '--thread', dest='t',
                    metavar='INT', action='store', default=1,
                    help='number of thread, default=1')
    ap.add_argument('--version', action='version', version='%(prog)s ' + __version__)
    args = ap.parse_args()

    smpl = pd.read_csv(args.smpl, sep='\t')
    fout = args.fout
    ftmp = args.fout + '.tmp'
    fsum = fout + '.summary'

    # exec featureCounts
    bams = list(map(lambda s: '%s/%s' % (s, args.fbam), smpl.sequence_id))
    cmds = ['featureCounts',
            '-o %s' % fout,
            '-a %s' % args.gtf,
            '-T %s' % args.t]
    if args.pair:
        cmds.extend(['-p'])
    cmds.extend(bams)
    cmd = ' '.join(cmds)
    print(cmd, file=sys.stderr)