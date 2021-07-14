#!/usr/bin/env python
"""Verify that a vcf file contains the same regions and samples found in the respective regions and samples files."""
import os
import argparse

from terra_notebook_utils import vcf
from terra_notebook_utils.blobstore.copy_client import blob_for_url


parser = argparse.ArgumentParser()
parser.add_argument("vcf_file", type=str)
parser.add_argument("--samples-file", type=str)
parser.add_argument("--samples-should-not-match", dest="samples_should_match", action="store_false")
parser.add_argument("--regions-file", type=str)
parser.add_argument("--regions-should-not-match", dest="regions_should_match", action="store_false")
args = parser.parse_args()

class VCF(vcf.VCFInfo):
    def __init__(self, fileobj):
        super().__init__(fileobj)
        self._get_regions(fileobj)

    def _get_regions(self, fileobj):
        self.regions = [self.pos]
        for line in fileobj:
            line = line.decode("utf-8").strip()
            if line:
                chrom, pos, _ = line.split("\t", 2)
                self.regions.append(pos)

vcf = VCF.with_blob(blob_for_url(args.vcf_file))

if args.samples_file:
    with open(args.samples_file) as fh:
        samples = [line.strip() for line in fh]
    assert args.samples_should_match == (samples == vcf.samples)

if args.regions_file:
    with open(args.regions_file) as fh:
        regions = [line.strip().split("\t")[1] for line in fh]
    assert args.regions_should_match == (regions == vcf.regions)
