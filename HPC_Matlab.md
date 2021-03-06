# Running Matlab code at High Performance Computing (HPC) cluster at NYU.

Step-1: Use Git-Bash in Windows (or terminal in Linux) and login to hpc
```
$ ssh ikj211@prince.hpc.nyu.edu
ikj211@prince.hpc.nyu.edu's password:
```

(Optional): Check your Quota
```
$ myquota

Filesystem   Environment   Backed up?   Allocation       Current Usage
Space        Variable      /Flushed?    Space / Files    Space(%) / Files(%)

/scratch    $SCRATCH       No/Yes        5.0TB/1.0M       0.00GB(0.00%)/4(0.00%)
/beegfs     $BEEGFS        No/Yes        2.0TB/3.0M        0.00GB(0.00%)/0(0.00%)
```

Step-2: Use `$SCRATCH` folder to run your commands from. It offers huge space 4Tb/user but get deleted in 60 days, so move all the content to `$ARCHIVE` after running the code. More details [here](https://wikis.nyu.edu/display/NYUHPC/Clusters+-+Prince).
```
$ cd $SCRATCH
$ pwd
```

Step-3: Clone the code from my repository 
```
$ git clone https://github.com/ishjain/mmWave.git
$ cd mmWave
```

(Optional): Edit the batch file. The content of `mybatch.sbatch` is pasted here. 
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=2GB
#SBATCH --job-name=myTest
#SBATCH --mail-type=END
#SBATCH --mail-user=ishjain@nyu.edu
#SBATCH --output=ish_%j.out
  
module purge
module load matlab/2017b

RUNDIR=$SCRATCH/mmWave/
cd $RUNDIR

matlab -nodisplay -nodesktop -r "run Simulation_Feb20.m"
```
(Optional): Check the modules. You will find matlab/2017b
```
$ module avail
```

Step-4: Submit the job
```
$ sbatch mybatch.sbatch
Submitted batch job 4605025
```
(Optional): Check the job queue
```
$ squeue -u ikj211
JOBID   PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
4605025    c32_38   myTest   ikj211  R       0:14      1 c32-01
```
Step-5: Check the results in local directory
```
$ ls -lastr

```

Step-6: When running the same code many times (atmost 400), use a `wrapper.m` file. In this file we first get the environment variable `aID = getenv('SLURM_ARRAY_TASK_ID')`. Every run time it gives a different id. So, you can use these id to seed the random generator and use them to name the output file. Note: `aID` is an array, so first convert to int for seed.
```
sbatch --array=1-100 mybatch.sbatch
```
