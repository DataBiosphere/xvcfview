#!/usr/bin/env python
import os
import sys

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
            chrom, pos, _ = line.split("\t", 2)
            self.regions.append(pos)

vcf = VCF.with_blob(blob_for_url(sys.argv[1]))
for pos in vcf.regions:
    print(pos)
