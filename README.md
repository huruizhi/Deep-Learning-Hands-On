# Deep Learning Hands-On

一个以 Notebook 为核心的深度学习与大模型实践仓库，包含从基础神经网络到 LLM 微调、LangChain 应用的分阶段学习内容。

## 项目结构

- [01_动手学习深度学习](./01_动手学习深度学习): 线性回归、Softmax、基础训练流程
- [02_动手学BERT_T5_GPT](./02_动手学BERT_T5_GPT): BERT/Transformer/GPT/T5 与知识蒸馏
- [03_LLMs实践](./03_LLMs实践): LoRA/PEFT 与 LLM 相关实践
- [04_llama-alpaca实践](./04_llama-alpaca实践): LLaMA/Alpaca 推理与训练
- [05_GLM_p-tuning](./05_GLM_p-tuning): ChatGLM 与 p-tuning 探索
- [06_Langchain实战](./06_Langchain实战): LangChain、向量检索、知识图谱
- [07-提示词工程](./07-提示词工程): 提示词工程实践
- [深度学习汇报.ipynb](./深度学习汇报.ipynb): 汇总型学习笔记

## 环境要求

- 推荐系统: macOS / Linux
- 推荐 Python: `3.11` (兼容性最好)
- 最低 Python: `>=3.10`

## 快速开始（venv + pip）

```bash
cd /Users/rzhu/Documents/Workplace/Deep-Learning-Hands-On
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
python -m ipykernel install --user --name dl-handson --display-name "Python (dl-handson)"
jupyter lab
```

启动后在浏览器中打开 Jupyter，按目录进入对应 notebook。

如需运行 LangChain / TRL / BertViz / W&B 等扩展 notebook，再额外安装：

```bash
pip install -r requirements-optional.txt
```

说明：扩展依赖较多，首次解析会明显更慢。

## Conda 启动方式（可选）

```bash
cd /Users/rzhu/Documents/Workplace/Deep-Learning-Hands-On
conda env create -f environment.yml
conda activate dl-handson
pip install -r requirements-optional.txt  # 可选
python -m ipykernel install --user --name dl-handson --display-name "Python (dl-handson)"
jupyter lab
```

## 推荐学习顺序

1. `01_动手学习深度学习`
2. `02_动手学BERT_T5_GPT/01_BERT`
3. `02_动手学BERT_T5_GPT/02_Transformers`
4. `03_LLMs实践`
5. `04_llama-alpaca实践`
6. `05_GLM_p-tuning`
7. `06_Langchain实战`
8. `07-提示词工程`

## 常见问题

- `ModuleNotFoundError`: 确认已激活环境并执行 `pip install -r requirements.txt`
- Jupyter 内核不显示: 执行 `python -m ipykernel install --user --name dl-handson`
- `torch` 安装慢: 可使用官方源或清华镜像（按本地网络环境选择）
- 部分 notebook 依赖在线模型/API（OpenAI/Hugging Face），需自行配置对应凭据

## 说明

- 本仓库以教学和实验为主，不同 notebook 可能依赖不同模型版本。
- 如需严格复现实验结果，建议固定具体模型与数据集版本，并在单独环境中运行。
