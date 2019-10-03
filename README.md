This workflow uses Qiime2 and some other software installed in USF's CIRCE/RRA servers. 

## Step 1: Quality assessment and trimming

Documentation on CIRCE/RRA cluster: https://wiki.rc.usf.edu/index.php/Main_Page

### Submit a job to the cluster

Identify the directory containing all your input fastq files. You can go to any directory using the change directory **cd** command followed by the directory name, e.g. **cd folder_name**. To go one level up, e.g. from /work/x/xxx to /work/x, use the **cd ..** command. Always, check the current working directory using the **pwd** command, e.g.

```
cd /work/x/xxx
pwd
```
In your working directory, e.g. /work/x/xxx, make a subfolder for your fastqc output files with the **mkdir** command:

```
cd /work/x/xxx
mkdir fastqc_orig
```

This will create a new folder at **/work/x/xxx/fastqc_orig**.

Modify the bash script template below to automate 1) quality assessment of pre- and post-trimmed fastq files and 2) fastq trimming using a Q25 threshold. These functions are performed using the fastqc and cutadapt packages in TrimGalore!

#### Required modifications: 
1. Change variable **DIR** (line 9 below) to point to your own working directory that contains your fastq files, e.g. if your working directory is /work/a/aaa/fastq instead of /work/x/xxx, change that.
2. If your fastq files have other file extensions, e.g. **.fastq** or **.fq** instead of **.fastq.gz**, change that in line 11 below.
3. Look for patterns in your fastq file names. If your fastq files all end with other suffixes instead of **_R1_001.fastq.gz**, change that in lines 13 and 15 below.
4. Change job name in line 2 from **trim** to something more intuitive to you (optional)
5. Remove lines 4 and 5 if not using RRA partition (optional)

```
#!/bin/bash
#SBATCH --job-name=trim
#SBATCH --time=5:00:00
#SBATCH --partition=rra
#SBATCH --qos=rra

module add apps/trimgalore/0.4.4

DIR="/work/x/xxx/"

fastqc $DIR/*.fastq.gz -o $DIR/fastqc_orig

for i in `ls $DIR/*R1_001.fastq.gz | sed "s/_R1_001.fastq.gz//g"`
do
trim_galore -q 25 --paired --fastqc --nextera -o $DIR "$i"_R1_001.fastq.gz "$i"_R2_001.fastq.gz
done
```
Save the script as for example, **trim.sh** and change the permission of the file so that it is executable:

```
chmod +x trim.sh
```

Submit the job to the server:

```
sbatch trim.sh
```
Once successful, you will see something like:
```
Submitted batch job 24994320
```

Check job status. Change xxx to your username on the cluster.
```
squeue -u xxx
```
You will see statuses like the ones below. "PD" indicates that the job is pending; "R" indicates that the job is running. If you don't see your job anymore, that most likely means it has finished running.

Pending:

```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          24994320       rra     trim  xxx PD       0:00      1 (None)
```

Running:
```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          24994320       rra     trim  xxx  R       0:53      1 mdc-1057-24-14
```

Log files of all completed jobs will be saved as **slurm-xxxx.out**. Check your log files and output files once everything is done.

#### Output files:
1. fastqc_orig/zip files - FastQC output in zipped format, not essential, you can remove them
2. fastqc_orig/html files - FastQC output in HTML format. Download and open them to look at a summary of the quality of each fastq files.
3. val_1.fq/val_1.fq.gz files - Trimmed forward fastq files
4. val_2.fq/val_2.fq.gz files - Trimmed reverse fastq files
5. trimming report text files - Summary of trimming proces e.g. how many reads were retained after quality filtering. Move them to a subfolder if you wish
6. fastqc related zip and html files - See points #1 and #2

How to read FastQC output: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

## Step 2: Create the QIIME2 manifest file 

### Manifest file format for Qiime2 2017.8 on USF server
This is how a manifest file looks like for Qiime2 2017.8. It is typically tab-separated, and basically tells Qiime2 where to locate your fastq files, and what unique sample IDs you are assigning to them. 

Qiime2 requires **absolute** filepaths e.g. with full directory paths for its manifest file. You can do that e.g. /work/x/xxx/fastq/yyy.R1.fastq or the easiest way to do is to just use "$PWD" to denote your current working directory. 

Qiime2 takes fastq files and gunzipped (.gz) fastq files.

```
sample-id      absolute-filepath       direction
TGH-001B  $PWD/TGH-001B_S88_L001_R1_001_val_1.fq.gz forward
TGH-001B  $PWD/TGH-001B_S88_L001_R2_001_val_2.fq.gz reverse
TGH-001E  $PWD/TGH-001E_S89_L001_R1_001_val_1.fq.gz forward
TGH-001E  $PWD/TGH-001E_S89_L001_R2_001_val_2.fq.gz reverse
```

#### Should I use raw or trimmed fastq files?
You can specify raw, untrimmed fastq files to Qiime2, and trim them within the Qiime2 environment, e.g. using DADA2. Alternatively, you can also use pre-trimmed fastq files so that you only have to process them minimally in Qiime2. 

#### How do I create the manifest file (Qiime2 2017.8)?

You can create this file on Microsoft Excel and upload or copy and paste it to the server. 

If your sample IDs are already part of your fastq file names, you can use some simple bash one-liners to generate some or all parts of the manifest file. 

For example, if your sample IDs are before the first underscore (_) in your file names, e.g. TGH-001B_S88 in TGH-001B_S88_L001_R1_001_val_1.fq.gz, you can parse them out and save them to a file e.g. sampleIDheader with the one-liner below. Here, | pipes the output of one command (e.g. ls) to another command (e.g. awk). The awk command separates the listed file names into different columns by underscore (-F "_") and prints out only the first column ($1):

```
ls *R1*fq.gz | awk -F "_" '{print $1}' >sampleIDheader
```

Check the output using the **cat** or **more** command:

```
cat sampleIDheader
more sampleIDheader
```

Example output (e.g. sampleIDheader). Check output with **cat** or **more** command:
```
TGH-001B
TGH-001E
```
For Qiime2 2017.8, you can generate the list of files with the **ls** command, and add in the filepaths and direction (forward/reverse) using a bunch of **sed** commands. The first sed command replaces the beginning of each line, specified by ^, with **$PWD/**. The second sed command replaces **1.fq.gz** at the end of each line with itself (&) and adds a tab (\t), followed by the string **forward**. Similarly, the third sed command replaces **2.fq.gz** at the end of each line with itself (&) and adds a tab (\t), followed by the string **reverse**. In unix, $ and * are special characters that have to be escaped using the backward slash. We can save this list to a file, e.g. filelist

```
ls *fq.gz | sed "s/^/\$PWD\//" | sed "s/1.fq.gz/&\tforward/" | sed "s/2.fq.gz/&\treverse/"
```
Example output (e.g. filelist). Check output with **cat** or **more** command:
```
$PWD/TGH-001B_S88_L001_R1_001_val_1.fq.gz forward
$PWD/TGH-001B_S88_L001_R2_001_val_2.fq.gz reverse
$PWD/TGH-001E_S89_L001_R1_001_val_1.fq.gz forward
$PWD/TGH-001E_S89_L001_R2_001_val_2.fq.gz reverse
```

Then, combine the files **sampleIDheader** and **filelist** into a tab-separated table using the **paste** command. We save this table as **table.noheader.txt**. Note that the output file does not contain any header yet:

```
paste -d "\t" sampleIDheader filelist >table.noheader.txt
```
Example output (without header). Check output with **cat** or **more** command:
```
TGH-001B  $PWD/TGH-001B_S88_L001_R1_001_val_1.fq.gz forward
TGH-001B  $PWD/TGH-001B_S88_L001_R2_001_val_2.fq.gz reverse
TGH-001E  $PWD/TGH-001E_S89_L001_R1_001_val_1.fq.gz forward
TGH-001E  $PWD/TGH-001E_S89_L001_R2_001_val_2.fq.gz reverse
```
Now you can add the header line below easily using a text editor in Unix (e.g. nano) or save the header line as a file and concatenate header and table files together.

Header line for Qiime2 2017.8:
```
sample-id      absolute-filepath       direction
```

Final output should look like the example manifest file above.

### Manifest file format for Qiime2 2018.9 on other server/own computer

```
sample-id	forward-absolute-filepath	reverse-absolute-filepath
01bas	$PWD/TGH-001B_S88_L001_R1_001_val_1.fq.gz	$PWD/TGH-001B_S88_L001_R2_001_val_2.fq.gz
01end	$PWD/TGH-001E_S89_L001_R1_001_val_1.fq.gz	$PWD/TGH-001E_S89_L001_R2_001_val_2.fq.gz
```

For Qiime2 2018.9, using similar one-liners in the previous section, you can generate a list of sample IDs, if they are already part of the fastq file names:

```
ls *R1*fq.gz | awk -F "_" '{print $1}' >sampleIDheader
```

You can also use a slightly different one-liner to extract the file names of all forward fastq files, e.g.

```
ls *R1*fq.gz | sed "s/^/\$PWD\//" >forwardfilelist
```

Similarly, you can extract the file names of all reverse fastq files, e.g.

```
ls *R2*fq.gz | sed "s/^/\$PWD\//" >reversefilelist
```

Then, combine the sample IDs, forward fastq file paths, and reverse fastq filepaths into a tab-separated table using the **paste** command. We save this table as **table.noheader.txt**. Note that the output file does not contain any header yet:

```
paste -d "\t" sampleIDheader forwardfilelist reversefilelist >table.noheader.txt
```
Example output (without header):
```
01bas	$PWD/TGH-001B_S88_L001_R1_001_val_1.fq.gz	$PWD/TGH-001B_S88_L001_R2_001_val_2.fq.gz
01end	$PWD/TGH-001E_S89_L001_R1_001_val_1.fq.gz	$PWD/TGH-001E_S89_L001_R2_001_val_2.fq.gz
```
Now you can add the header line below easily using a text editor in Unix (e.g. nano) or save the header line as a file and concatenate header and table files together.

Header line for Qiime2 2018.9:
```
sample-id	forward-absolute-filepath	reverse-absolute-filepath
```

Final output should look like the example manifest file above.

## Step 3: Import data specified in the manifest file to Qiime2

```
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path $DIR/manifest --output-path $DIR/q25.qza --input-format PairedEndFastqManifestPhred33V2
```

**A note on Phred offset used for positional quality scores:**
Newer Illumina software uses Phred33 and older Illumina software uses Phred64. See: http://scikit-bio.org/docs/latest/generated/skbio.io.format.fastq.html#quality-score-variants. Don't worry if you are not sure about this. If set incorrectly, the command will throw an error and you can change the parameter accordingly. 

## Step 4: Create the metadata file

Metadata file is in tab-separated format.  Best way is to create this in Excel then upload/copy and paste into server. 

First row and first column must be sample-id. Subsequent columns is based on your metadata.
Second row must start with #q2:types. Subsequent columns specify whether the corresponding column in the first row is categorical or numeric.

```
sample-id       gender  age           
#q2:types       categorical     numeric 
01bas   m       65     
01end   m       65      
01mid   m       65     
02bas   f       65      
02mid   f       65     
04end   f       58  
04mid   f       58      
```




