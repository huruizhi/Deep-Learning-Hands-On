from transformers import LlamaForCausalLM, LlamaTokenizer, LlamaConfig


if __name__ == "__main__":

    base_model_path = "/data/models/llama-alpaca-plus-7B"
    config = LlamaConfig.from_pretrained(base_model_path)

    model = LlamaForCausalLM.from_pretrained(base_model_path)
    print(model)



