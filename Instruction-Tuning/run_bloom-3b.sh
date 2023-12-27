llm='bloom-3b'
dataset='react'
train_batch_size=1
eval_batch_size=1
accumulation_steps=32
node=1
max_length=2500

lr=1e-4
lora_rank=64
lora_alpha=128
lora_trainable="query_key_value"
lora_dropout=0.05
pretrained_model=../pretrain/${llm}
chinese_tokenizer_path=../pretrain/${llm}
per_device_train_batch_size=${train_batch_size}
per_device_eval_batch_size=${eval_batch_size}
gradient_accumulation_steps=${accumulation_steps}
dataset_dir=${dataset}/train/
output_dir=output-${dataset}/${llm}
validation_file=${dataset}/dev.json

deepspeed_config_file=ds_zero2_no_offload.json

torchrun --master_port 29678 --nnodes 1 --nproc_per_node ${node} run_bloom.py \
    --deepspeed ${deepspeed_config_file} \
    --model_name_or_path ${pretrained_model} \
    --tokenizer_name_or_path ${chinese_tokenizer_path} \
    --dataset_dir ${dataset_dir} \
    --validation_split_percentage 0.001 \
    --per_device_train_batch_size ${per_device_train_batch_size} \
    --per_device_eval_batch_size ${per_device_eval_batch_size} \
    --do_train \
    --do_eval \
    --seed $RANDOM \
    --fp16 \
    --num_train_epochs 10 \
    --lr_scheduler_type cosine \
    --learning_rate ${lr} \
    --warmup_ratio 0.03 \
    --weight_decay 0 \
    --logging_strategy steps \
    --logging_steps 10 \
    --save_strategy epoch \
    --save_total_limit 2 \
    --evaluation_strategy epoch \
    --gradient_accumulation_steps ${gradient_accumulation_steps} \
    --preprocessing_num_workers 8 \
    --max_seq_length ${max_length} \
    --output_dir ${output_dir} \
    --overwrite_output_dir \
    --ddp_timeout 30000 \
    --logging_first_step True \
    --lora_rank ${lora_rank} \
    --lora_alpha ${lora_alpha} \
    --trainable ${lora_trainable} \
    --lora_dropout ${lora_dropout} \
    --torch_dtype float16 \
    --validation_file ${validation_file} \
    --gradient_checkpointing \
    --ddp_find_unused_parameters False \
    --load_best_model_at_end True \
    --report_to none
