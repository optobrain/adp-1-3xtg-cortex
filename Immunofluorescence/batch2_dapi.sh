#!/bin/bash 
#SBATCH -J p1a-p2c
#SBATCH --array=1-59
#SBATCH -n 2
#SBATCH --mem=16G 
#SBATCH -t 1:00:00 
#SBATCH -e /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.err 
#SBATCH -o /users/jlee123/scratch/job/adp-1-3xtg-cortex/Immunofluorescence/%J--%a.out 
module load matlab/R2021a 
matlab-threaded -batch "app2_dapi('p1a', 'p2c', $SLURM_ARRAY_TASK_ID);  exit;" 
