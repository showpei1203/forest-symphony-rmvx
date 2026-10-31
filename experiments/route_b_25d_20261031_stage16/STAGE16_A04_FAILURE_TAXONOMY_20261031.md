# Stage16 A04 technical failure and preventive rules
F-A04-01: current ComfyUI comfy-kitchen0.2.40 and torch2.4.1 DirectML env incompatible at torch custom-op inference on list[int]. Isolate old pinned ComfyUI v0.3.40, do not alter user's AMD driver or sealed FS.
F-A04-02: missing optional ComfyUI modules (spandrel, torchaudio, workflow templates) were explicitly logged. Core model/LoadImage/IPAdapter nodes passed, not full app suite.
F-A04-03: initial v0.3.40 import missing trampoline from --no-deps torchsde; dependency installed. Keep all dependency constraints in isolated venv.
F-A04-04: DirectML+IPAdapter application caused native python/torch_cpu.dll c0000005 APPCRASH EventID1000. No catchable Python exception. GPU IPAdapter unresolved; CPU full run passed, so separate DirectML edge from model/image input correctness.
F-A04-05: CLIPVision CPU isolation harness used wrong config first, then corrected comfy.options.enable_args_parsing() and proper output indexing. Feature encode PASSED.
F-A04-06: Image model reference control works technically but sample texture geometry fails Ground3 fidelity. Do not conflate channel-byte mismatch (94.5697%) with quality, and do not claim visual PASS.
F-A04-07: Long positive prompt triggered SD15 CLIP 77-token overlength in early smoke. Shorten prompt and track token truncation; shared AB settings preserve same prompt even if truncated.
F-A04-08: Private source and weights remain out of public GitHub. Private transport ZIP excludes multi-GB weights and full ground3 source. ZIP CRC and 30/30 source SHA readback, Formal Seal NO.
Next: A05 tests real ground-semantic road masks/region generation with fixed art reference; refuse no-op repeated prompts, enforce game-character readability at native 32px before PAR/Godot/VX.