#!/bin/bash 
#SBATCH -J res
#SBATCH --array=1-12
#SBATCH -n 4
#SBATCH --mem=128G 
#SBATCH -t 1:00:00 
#SBATCH -e /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.err 
#SBATCH -o /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.out 
module load matlab/R2021a 
matlab-threaded -batch "res_batch($SLURM_ARRAY_TASK_ID);  exit;" 
