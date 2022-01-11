######## NCBI now contains Contamination Screen that will remove sequences 
######## marked to exclude and/or trimmed contamination from the ends of sequence (see the 
######## FixedForeignContaminations.txt file). If the contamination is on either 
######## side of a run of N's, the N's were also removed.
######## However, NCBI could not remove the contamination in the 
######## RemainingContamination.txt file.  NCBI cannot remove contamination that 
######## is in the middle of a sequence. The sequence may need to be split 
######## at the contamination and the sequence on either side of the contamination 
######## submitted as a separate sequence.


######## This script trims off reamining contaminations from a fasta file, given a list of contig, start position(s), and end position(s)

# Input (list.tsv):
# Contig name, start position 1, end position 1, start position 2, end position 2
# NODE_1856_length_17883_cov_4.208997	17832	17883
# NODE_1316_length_11040_cov_10.030223	1	19	11016	11040

# Input FASTA file has to be chomped

#!/usr/bin/env python

import sys
import os
from os import path
import re

directory = r'/Volumes/GoogleDrive/My Drive/NOAA/iceworm/Assemblies/'
contam=str("guthiseq.contam.tsv")

def matchme(query):

	with open(contam,'r') as listfile:
		for line in listfile.readlines():
			col=line.rsplit("\t")
			contig=str(col[0])
			
			status=str("No match")
			start1=0
			end1=0	
			start2=0
			end2=0

			if query in line:
				status=str("Match")
				start1=int(col[1])-1
				end1=int(col[2])
				
				if (len(col)>3):
					start2=int(col[3])-1
					end2=int(col[4])

				else:
					start2=0
					end2=0
				return status,start1,end1,start2,end2
				break

		return status,start1,end1,start2,end2

for filename in os.listdir(directory):
	if filename.endswith("-fixed-NCBI.chomp.fa"):

		out_path=str(filename+"_nocontam.fa")
		in_filename=str(directory+"/"+filename)

		if path.exists(out_path):
			sys.exit("Error: Output FASTA file exists! Please rename output FASTA file and try again!")

		output=open(out_path,'a')

		with open(in_filename,'r') as infile:
			for inline in infile.readlines():
				if re.search(">",inline):
					header=re.sub(">","",inline)
					hname=header.rsplit("\n")
					contigname=hname[0]
					print("Now searching <%s> in <%s>...") % (contigname,filename)
					status,start1,end1,start2,end2=matchme(query=contigname)
					print(status,start1+1,end1,start2+1,end2)
					output.write(inline)
				
				else:
					sequence=inline.rsplit("\n")
					seq=sequence[0]

					if re.search("Match",status):

						if(end2>0):
							substring1=seq[0:start2]
							substring2=seq[end2:]
							string=str(substring1+substring2)
						else:
							string=str(seq)

						substring3=string[0:start1]
						substring4=string[end1:]
						output.write(substring3)
						output.write("\n")
						output.write(">"+contigname+"_1")
						output.write("\n")
						output.write(substring4)
						output.write("\n")

					else:
						output.write(seq)
						output.write("\n")

	else:
		continue
