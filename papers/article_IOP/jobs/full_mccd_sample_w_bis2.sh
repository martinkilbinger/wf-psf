#!/bin/bash
#SBATCH --job-name=mccd_sample_w_bis2_    # nom du job
##SBATCH --partition=gpu_p2          # de-commente pour la partition gpu_p2
#SBATCH --ntasks=1                   # nombre total de tache MPI (= nombre total de GPU)
#SBATCH --ntasks-per-node=1          # nombre de tache MPI par noeud (= nombre de GPU par noeud)
#SBATCH --gres=gpu:1                 # nombre de GPU par n?~Sud (max 8 avec gpu_p2)
#SBATCH --cpus-per-task=10           # nombre de coeurs CPU par tache (un quart du noeud ici)
#SBATCH -C v100-32g 
# /!\ Attention, "multithread" fait reference a l'hyperthreading dans la terminologie Slurm
#SBATCH --hint=nomultithread         # hyperthreading desactive
#SBATCH --time=20:00:00              # temps d'execution maximum demande (HH:MM:SS)
#SBATCH --output=mccd_sample_w_bis2_%j.out  # nom du fichier de sortie
#SBATCH --error=mccd_sample_w_bis2_%j.err   # nom du fichier d'erreur (ici commun avec la sortie)
#SBATCH -A ynx@gpu                   # specify the project
##SBATCH --qos=qos_gpu-dev            # using the dev queue, as this is only for profiling
#SBATCH --array=0-3

# nettoyage des modules charges en interactif et herites par defaut
module purge

# chargement des modules
module load tensorflow-gpu/py3/2.4.1

# echo des commandes lancees
set -x

opt[0]="--id_name _sample_w_bis2_2c --train_dataset_file train_Euclid_res_200_TrainStars_id_001.npy --n_epochs_param 30 30 --n_epochs_non_param 300 300"
opt[1]="--id_name _sample_w_bis2_5c --train_dataset_file train_Euclid_res_500_TrainStars_id_001.npy --n_epochs_param 30 30 --n_epochs_non_param 200 150"
opt[2]="--id_name _sample_w_bis2_1k --train_dataset_file train_Euclid_res_1000_TrainStars_id_001.npy --n_epochs_param 20 20 --n_epochs_non_param 150 100"
opt[3]="--id_name _sample_w_bis2_2k --train_dataset_file train_Euclid_res_2000_TrainStars_id_001.npy --n_epochs_param 15 15 --n_epochs_non_param 100 50"

cd $WORK/repo/wf-psf/long-runs/

srun python -u ./train_eval_plot_script_click.py \
    --model mccd \
    --d_max_nonparam 3 \
    --graph_features 10 \
    --l_rate_param 0.01 0.004 \
    --l_rate_non_param 0.1 0.06 \
    --saved_model_type checkpoint \
    --saved_cycle cycle2 \
    --total_cycles 2 \
    --use_sample_weights True \
    --l2_param 0. \
    --base_id_name _sample_w_bis2_ \
    --suffix_id_name 2c --suffix_id_name 5c --suffix_id_name 1k --suffix_id_name 2k \
    --star_numbers 200 --star_numbers 500 --star_numbers 1000 --star_numbers 2000 \
    --plots_folder plots/mccd_sample_w_bis2/ \
    ${opt[$SLURM_ARRAY_TASK_ID]} \
