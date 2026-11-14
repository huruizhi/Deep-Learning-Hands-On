# Clef-Flash 在 Mac 上的部署选型

调研日期：2026-11-13。目标模型为 **Cloudflare/clef-flash**，即 Qwen3.5-9B 衍生的决策模型。它通过 backbone 加 joint schema head 为指定选项打分。部署时必须保留这个 head 及其输入编码；仅运行 Qwen3.5 backbone 的聊天能力不能验证 Clef 决策能力。[Cloudflare 模型卡](https://huggingface.co/Cloudflare/clef-flash)

## 建议

**先用 Ollama 跑通本机短文本决策，再考虑 CSGLite 集成。** Ollama 已有官方 Clef-Flash 模型、Mac Metal 支持和 `/v1/systemone` 决策 API；无需自行移植 joint head。不要依据较早的通用 GGUF 导入经验判断它不支持 Clef。[官方模型页](https://ollama.com/library/clef-flash)、[决策能力文档](https://github.com/ollama/ollama/blob/main/docs/capabilities/decision.mdx)、[Apple Metal 支持](https://docs.ollama.com/gpu)

本机现场检查为 Apple M6 Mac mini、32GB 统一内存、macOS 27.2。此机器信息来自本轮本地检查，不代表官方支持列表。目前没有下载完整模型，以下部署命令没有进行完整权重实测，不提供本机延迟或准确率承诺。

| 路径 | 已确认的能力 | 适用情况与限制 |
| --- | --- | --- |
| Ollama | 官方 Clef-Flash 模型；System One 决策 API；文本、JSON 和图片；Mac Metal 加速 | 本机首选。Clef 至少需要 v0.35.1。先用短文本和显式量化标签验收 |
| CSGLite | 当前源码将 Clef 列为 llama.cpp 原生 decision model，通过 `/v1/decisions` 转发至 `/v1/systemone` | 适合后续接 CSGHub、Web UI 和统一服务。当前决策入口拒绝图片；具体 Flash GGUF、转换及安装版本仍需验收 |
| 官方 PyTorch + MPS | 原始 joint head 可保留，能够观察隐藏状态和模型结构 | 适合学习、研究；完整权重运行尚未验证，内存余量较小 |
| 自行移植 MLX | 本轮未实现 | Ollama 已提供 MLX 格式，普通部署无需先做移植；研究自定义 head 时才需要另立工程 |

来源：[Ollama 模型页](https://ollama.com/library/clef-flash)、[CSGLite 固定版本决策文档](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/docs/guides/typed-decisions.md)。

## Ollama 最小部署与验收

从 [Ollama 官方 macOS 下载页](https://ollama.com/download/mac)安装或更新后，启动应用。下面是待执行步骤，本轮未安装、更新或下载模型。

```sh
ollama --version
ollama pull clef-flash:9b-q8_0
```

官方标签页当前提供约 11GB 的 `9b-q8_0`、约 12GB 的 MLX `9b-mxfp8`、约 19GB 的 MLX `9b-mlx-bf16`。先固定 `9b-q8_0`，便于复现；后续可在相同输入下比较 MLX 版本。这里是下载体积，不能当作运行时峰值内存。[官方标签页](https://ollama.com/library/clef-flash/tags)

待下载完成后，以普通 HTTP 请求验证实际 decision head，避开聊天接口及 SDK 版本差异：

```sh
curl http://localhost:11434/v1/systemone \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "clef-flash:9b-q8_0",
    "state": "My order was charged twice. Please refund the duplicate payment.",
    "questions": {
      "route": {
        "type": "choice",
        "instructions": "Which team should handle this request?",
        "criteria": {
          "billing": "Payments, duplicate charges, and refunds",
          "technical": "Software errors and configuration",
          "shipping": "Delivery and tracking"
        }
      },
      "refund": {
        "type": "noul",
        "instructions": "Is the customer requesting a refund?"
      }
    },
    "keep_alive": "5m"
  }'
```

验收应检查 `answers.route.probabilities` 有全部三个选项、概率有限且归一化，以及 `answers.refund.noul` 在 0 到 1 之间。更换为软件故障、物流查询等对照输入后，再观察路由是否合理变化；单个样例通过不足以证明准确率或校准质量。API 字段和调用形式依据 [Ollama 官方 System One 说明](https://github.com/ollama/ollama/blob/main/docs/capabilities/decision.mdx)。

图片通过顶层 `images` 数组传入 base64 编码 PNG/JPEG/WebP，仍需提供 `state`；不接受 URL 或 data URL。[官方图片决策说明](https://github.com/ollama/ollama/blob/main/docs/capabilities/decision.mdx)

官方资料存在更新不同步：模型页仍有“CLI 和 SDK 尚未支持”的文字，当前能力文档已展示 CLI `--ask`；模型页摘要与正文的上下文长度也不一致。首次验收使用上述 API 和短输入，不依赖这些冲突项。当前能力文档还给出 choice 为 2–26 个选项、score 为 2–10 个等级；本例均远低于上限。[模型页](https://ollama.com/library/clef-flash)、[当前能力文档](https://github.com/ollama/ollama/blob/main/docs/capabilities/decision.mdx)

## CSGLite 实际支持到了哪里

本轮读取的 `main` 固定为 `a021eaad9eb5827e3951b08b4e490d1c401ecc5a`。其决策文档明确区分两条路线：JEV adapter 的 token logprobs 路线，以及 llama.cpp 原生 decision head 路线。**Clef 被列在后者**，读取 hidden states，并标为 `decision_only`；聊天请求应被拒绝并提示使用 `/v1/decisions`。因此不能把 CSGLite 的 Clef 支持描述成普通聊天加 JSON 解析。[固定版本文档](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/docs/guides/typed-decisions.md)

源码 `PrepareNativeOpenAI` 把 predicate 转成 noul、保留 choice 选项语义、把 score 等级传给 System One；它处理的是协议适配。`NativeType` 检查 GGUF 的 `<arch>.decision.type`。这为原生执行路线提供了代码证据，但不等于任意 safetensors 下载后都会自动保留 Clef joint head。[native.go](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/internal/decision/native.go)

当前安装脚本固定 llama.cpp `b11541`，并选择 macOS arm64 包。CSGLite 的转换器另由版本化 `llama-cpp-assets` 提供。本轮没有完成具体 Clef-Flash checkpoint → 含决策 head GGUF 的转换验证，也没有运行该发布包，所以暂不提供声称已可用的 `csghub-lite pull Cloudflare/clef-flash` 命令。[安装脚本](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/scripts/install.sh)、[转换器来源](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/internal/convert/bundled_converter.go)

当前决策文档明确拒绝 `input_image`：尚未把图片传给 native decision models。以后如选择 CSGLite，应确认安装版本、llama-server 版本、模型 GGUF decision metadata，并用同一组文本验证概率；图片使用须重新核验版本支持。[限制说明](https://github.com/OpenCSGs/csglite/blob/a021eaad9eb5827e3951b08b4e490d1c401ecc5a/docs/guides/typed-decisions.md)

## 为结构学习保留的 MPS 路线

Cloudflare 的正式示例用 `load_release_model` 加载 backbone 和 joint head，官方记录的测试环境是 torch 2.11、transformers 5.10.2、单张 H200；这不是 Mac 性能保证。固定模型 revision 为 `22b75507981345858dd152fbd9a6f8c0c4068b0a`。[固定模型卡](https://huggingface.co/Cloudflare/clef-flash/blob/22b75507981345858dd152fbd9a6f8c0c4068b0a/README.md)、[官方实现](https://huggingface.co/Cloudflare/clef-flash/blob/22b75507981345858dd152fbd9a6f8c0c4068b0a/joint_schema_model.py)

本轮本地检查与小规模探针结果：

- 现有 `.venv-clef` 为 torch 2.11、transformers 5.10.2，MPS 可用；系统报告 MPS 建议上限约 24.96GiB。
- checkpoint 的 backbone 权重 metadata 为 18,819,627,488 bytes，约 17.527GiB；joint head 121,762,820 参数，16bit 约 0.227GiB；合计权重约 17.754GiB。另需激活、缓冲区、视觉输入和系统内存，32GB 不能据此视为任意上下文都足够。
- 使用官方 `ClefModel` 和 `JointSchemaHead`、随机初始化的缩小 Qwen3.5 backbone，保留 3 层 linear attention + 1 层 full attention，8 token 合成输入，在 MPS 上以 float16 和 bfloat16、eager attention 均完成 forward，并输出归一化的两个选项概率。

这些结果只验证了缩小配置的算子兼容性，**没有加载训练后的完整权重，没有验证本机速度、模型质量或校准**。探针由本轮主任务执行；原始完整模型权重没有下载。

后续完整 checkpoint 实验可从以下加载配置起步，它是待验证配置，不是本轮成功部署记录：

```python
import sys
import torch
from huggingface_hub import snapshot_download

path = snapshot_download(
    "Cloudflare/clef-flash",
    revision="22b75507981345858dd152fbd9a6f8c0c4068b0a",
)
sys.path.insert(0, path)
from joint_schema_model import load_release_model, systemone

model, processor = load_release_model(
    path,
    device="mps",
    dtype=torch.bfloat16,
    attn_implementation="eager",
)
# 按固定模型卡的 systemone 调用方式传入 state/questions；
# 首轮只测短文本、batch 1，并把 max_length 设为 1024。
```

若目标仅为使用决策能力，先完成 Ollama API 验收；若目标是学习 backbone、head、打分与校准，再继续官方 PyTorch 路线，避免把运行平台选型与模型结构实验混在一起。
