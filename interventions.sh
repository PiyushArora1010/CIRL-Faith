#!/bin/bash
MODEL_TAG=Qwen3_4B
CONCEPT_MODEL_TAG=Qwen3_32B
IMPLIED_MODEL_TAG=Qwen3_32B
COMPLETIONS=1
DATASET=bbq
DATASET_PATH=data/bbq
MODEL_TEMPERATURE=0
if [ $COMPLETIONS -gt 1 ]; then
  MODEL_TEMPERATURE=0.7
fi

# GET CONCEPTS AND INTERVENTION SETS
python metric.py --module concept_intervention --task get_concept_ids,get_intervention_sets \
--concept_id_base_prompt_name concept_id_prompt --concept_values_base_prompt_name concept_values_prompt \
--dataset $DATASET --dataset_path $DATASET_PATH --example_indices all --example_batch_size 32 \
--model_tag $CONCEPT_MODEL_TAG --model_max_tokens 4096 --model_temperature 0 --model_batch_size 32 \
--output_dir ${CONCEPT_MODEL_TAG}

# APPLY CONCEPT REPLACEMENT INTERVENTIONS
python metric.py --module concept_intervention --task apply_interventions \
--dataset $DATASET --dataset_path $DATASET_PATH --example_indices all --example_batch_size 8 \
--model_tag $CONCEPT_MODEL_TAG --model_max_tokens 4096 --model_temperature 0 --model_batch_size 32 \
--counterfactual_gen_base_prompt_name counterfactual_gen_replacements_prompt \
--output_dir ${CONCEPT_MODEL_TAG}

# Verify Concepts
python metric.py --module verification --task verify_concepts \
--dataset $DATASET --dataset_path $DATASET_PATH --example_indices all --example_batch_size 12 \
--model_tag $CONCEPT_MODEL_TAG --model_max_tokens 4096 --model_temperature 0 --model_batch_size 32 \
--verification_base_prompt_name concept_verification_prompt --output_dir ${CONCEPT_MODEL_TAG}

# APPLY CONCEPT REPLACEMENT INTERVENTIONS
python -u metric.py --module concept_intervention --task apply_interventions \
--dataset $DATASET --dataset_path $DATASET_PATH --example_indices all --example_batch_size 32 \
--model_tag $CONCEPT_MODEL_TAG --model_max_tokens 2048 --model_temperature 0 --model_batch_size 32 \
--counterfactual_gen_base_prompt_name counterfactual_gen_replacements_prompt \
--output_dir $CONCEPT_MODEL_TAG

# Verify Interventions
python metric.py --module verification --task verify_interventions \
--dataset $DATASET --dataset_path $DATASET_PATH --example_indices all --example_batch_size 12 \
--model_tag $CONCEPT_MODEL_TAG --model_max_tokens 4096 --model_temperature 0 --model_batch_size 32 \
--verification_question_base_prompt_name intervention_question_verification_prompt \
--verification_anschoices_base_prompt_name intervention_anschoices_verification_prompt \
--output_dir ${CONCEPT_MODEL_TAG}