#### This is a simple script to filter an input fasta file by length
#### Fasta file should be chomped, i.e. one header line and only one sequence line

#!/usr/bin/env python

import sys
import os
from os import path
import re

input=str("all.dedup.fa")
output=open('3000.fa','w')

with open(input,'r') as infile:
	for inline in infile.readlines():
		if re.search(">",inline):
			header=inline.rsplit("\n")
			contig=header[0]
			print(contig)
				
		else:
			sequence=inline.rsplit("\n")
			seq=sequence[0]

			if (len(seq)<3000):
				output.write(contig)
				output.write("\n")
				output.write(seq)
				output.write("\n")

