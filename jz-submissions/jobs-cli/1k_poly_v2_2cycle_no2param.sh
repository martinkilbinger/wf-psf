#!/bin/bash
#SBATCH --job-name=1k_poly_v2_2cycle_n2p    # nom du job
##SBATCH --partition=gpu_p2          # de-commente pour la partition gpu_p2
#SBATCH --ntasks=1                   # nombre total de tache MPI (= nombre total de GPU)
#SBATCH --ntasks-per-node=1          # nombre de tache MPI par noeud (= nombre de GPU par noeud)
#SBATCH --gres=gpu:1                 # nombre de GPU par n?~Sud (max 8 avec gpu_p2)
#SBATCH --cpus-per-task=10           # nombre de coeurs CPU par tache (un quart du noeud ici)
#SBATCH -C v100-32g 
# /!\ Attention, "multithread" fait reference a l'hyperthreading dans la terminologie Slurm
#SBATCH --hint=nomultithread         # hyperthreading desactive
#SBATCH --time=20:00:00              # temps d'execution maximum demande (HH:MM:SS)
#SBATCH --output=1k_poly_v2_2cycle_n2p%j.out  # nom du fichier de sortie
#SBATCH --error=1k_poly_v2_2cycle_n2p%j.err   # nom du fichier d'erreur (ici commun avec la sortie)
#SBATCH -A xdy@gpu                   # specify the project
##SBATCH --qos=qos_gpu-dev            # using the dev queue, as this is only for profiling

# nettoyage des modules charges en interactif et herites par defaut
module purge

# chargement des modules
module load tensorflow-gpu/py3/2.4.1

# echo des commandes lancees
set -x

cd $WORK/repo/wf-psf/jz-submissions/slurm-logs/

srun python -u ./../../long-runs/alternative_train_eval_script.py \
    --model poly \
    --id_name _chkp_1k_poly_v2_2cycle_no2param \
    --train_dataset_file train_Euclid_res_1000_TrainStars_id_001.npy \
    --n_epochs_param 20 2 \
    --n_epochs_non_param 150 200 \
    --l_rate_param 0.01 0.001 \
    --l_rate_non_param 0.1 0.01 \
    --d_max_nonparam 5 \
    --saved_model_type checkpoint \
    --saved_cycle cycle2 \
    --total_cycles 2 \