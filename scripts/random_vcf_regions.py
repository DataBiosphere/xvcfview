#!/usr/bin/env python
import os
import sys
import random

from terra_notebook_utils import vcf
from terra_notebook_utils.blobstore.copy_client import blob_for_url


class VCF(vcf.VCFInfo):
    def __init__(self, fileobj):
        super().__init__(fileobj)
        self._get_regions(fileobj)

    def _get_regions(self, fileobj):
        self.regions = [self.pos]
        for line in fileobj:
            line = line.decode("utf-8").strip()
            if random.random() > 0.999:
                chrom, pos, _ = line.split("\t", 2)
                self.regions.append(pos)
            if 25 == len(self.regions):
                break

vcf = VCF.with_blob(blob_for_url(sys.argv[1]))

with open("regions.txt", "w") as fh:
    for pos in vcf.regions:
        fh.write(f"{vcf.chrom}\t{pos}{os.linesep}")
