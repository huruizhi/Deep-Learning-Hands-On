from transformers import AutoTokenizer, AutoConfig, AutoModel
from torch import nn
import torch

decoder_layer = nn.TransformerDecoderLayer(d_model=512, nhead=8)
# s1, b, h1
# from encoder output (last encoder layer output)
memory = torch.rand(10, 32, 512)
# s2, b, h2, from decoder input
tgt = torch.rand(20, 32, 512)

decoder_layer.multihead_attn(tgt, memory)




