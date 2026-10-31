#!/usr/bin/env python3
import torch, torch_directml
names=[torch_directml.device_name(k) for k in range(torch_directml.device_count())]
assert any('AMD Radeon RX 6700 XT' in s for s in names),names
d=torch_directml.device()
a=torch.ones((16,16),dtype=torch.float32).to(d)
b=torch.full((16,16),2.0,dtype=torch.float32).to(d)
assert (a+b).mean().cpu().item()==3.0
c=(a@b).cpu()
assert torch.allclose(c,torch.full((16,16),32.0))
print('DIRECTML_BASIC_GPU_OPERATORS_PASS',names,str(a.device))