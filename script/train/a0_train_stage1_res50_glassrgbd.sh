# Fail the script if there is any failure
set -e

if [[ $# -eq 0 ]] ; then
    echo 'Require Experiment Name'
    exit 1
fi

# The name of this experiment.
name=$1

# Save logs and models under snap/gqa; make backup.
output=exp/$name
if [ ! -d "$output"  ]; then
    echo "folder not exist"
    mkdir -p $output/src
    cp -r src/* $output/src/
    cp $0 $output/run.bash

    PYTHONPATH=$PYTHONPATH:./src python -m torch.distributed.launch \
    --master_port=$((1000 + RANDOM % 9999)) --nproc_per_node=1 --use_env  src/main_glassrgbd.py \
    --output_dir $output --backbone resnet50 --resume https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth \
    --batch_size 1 --epochs 150 --lr_drop 50 --num_queries 100  --num_gpus 1 \
    --dataset_args_file ./script/train/arguments_train_glassrgbd.txt \
    --with_center --with_dense | tee -a $output/history.txt

else
    echo "folder already exist"
fi



