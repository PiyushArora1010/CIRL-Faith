#/bin/bash
MODEL_TAG="Qwen/Qwen3-8B"
python train_grpo.py --dataset bbq --dataset_path "data/bbq" --max_examples 100000000 \
--counterfactual_data_path "double_verify/Qwen3_32B" --response_data_path "random" \
--model_tag $MODEL_TAG --model_temperature 0.7 --model_max_tokens 2048 --model_batch_size 16 \
--run_name qwen_8b_grpo \
--output_dir qwen_8b_grpo --implied_model_tag Qwen/Qwen3-32B \
--eval_steps 200 --save_steps 100 \
--learning_rate 1e-5 --epochs 1 --gradient_accumulation_steps 2 --completions_per_prompt 16 --seed 1 \
--lora --lora_rank 32 --lora_layers q_proj k_proj v_proj o_proj gate_proj up_proj down_proj \
--cot