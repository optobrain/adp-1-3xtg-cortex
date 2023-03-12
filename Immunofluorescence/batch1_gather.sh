#!/bin/bash 
#SBATCH -J 1-p1a
#SBATCH --array=1-70
#SBATCH -n 2
#SBATCH --mem=8G 
#SBATCH -t 1:00:00 
#SBATCH -e /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.err 
#SBATCH -o /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.out 
module load matlab/R2021a 
matlab-threaded -batch "app1_gather('p1a', $SLURM_ARRAY_TASK_ID);  exit;" 
