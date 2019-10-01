This workflow uses Qiime2 and some other software installed in USF's CIRCE/RRA servers. 

### Step 1: Quality assessment and trimming

This is an example bash script to automate 1) quality assessment of pre- and post-trimmed fastq files and 2) fastq trimming using a Q25 threshold. These are performed using the fastqc and cutadapt packages in TrimGalore!

Change the working directory (variable **DIR**) containing all fastq files accordingly. Also, look at patterns in your file names and change the suffix (e.g. _R1_001.fastq.gz) accordingly.

```

#!/bin/bash
#SBATCH --job-name=trim
#SBATCH --time=5:00:00
#SBATCH --partition=rra
#SBATCH --qos=rra

module add apps/trimgalore/0.4.4

DIR="/work/j/jeanlim/Adetola_Plate6"

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


