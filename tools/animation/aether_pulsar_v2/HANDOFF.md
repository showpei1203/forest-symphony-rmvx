# Aether Pulsar V2 | T-A candidate integration | 2026-11-24

Status: ADAPTER_LOGIC_TECH_PASS / AUTH_BLOCKED / ORCA_NOT_BOUND / PROVIDER_NOT_RUN / ART_HOLD / GODOT_NOT_RUN / GAMEPLAY_NOT_RUN.
This is an independent provider pilot, NOT R26 and NOT a replacement for R25 source-bound Bone2D or the approved original art. Current R25 source authority must remain intact.

## Actual work and evidence
- Read current FS unified control, routing manifest, tool inventory, FS router SKILL.md, project P0, precheck, current T-A Handoff and R25 authority, global Drive storage P0, private R25 Drive folder metadata and PC Bridge routing. Legacy unarmed ATTACK launch text superseded by current R25 large sword direction.
- Official REST: https://api.aetherforgeai.com/endpoints/sprite-pulsar-v2 ; MCP: https://api.aetherforgeai.com/zh-Hant/getting-started/mcp ; status: https://api.aetherforgeai.com/endpoints/get-job-status
- Adapter commit 6b6f673280390fe167cbc9152c33d493b2b589b6, source blob 8500f7d4c024eb9b2d318078b1068030f9c5a7a8. Exact content readback PASS.
- 17/17 pure JS helper assertions actually executed in ChatGPT isolated JS runtime: IDLE cost, RUN pixel flag, provider length, bad SHA, wrong canvas, disallowed ATTACK, status URL, invalid UUID, Pending, Failed, Succeed, empty outputs, wrong job, unknown status, 12 frame contract, duplicate selection, out-of-range selection. These used synthetic status payloads, not a real provider job; Node CLI HTTP/PNG path NOT_RUN.
- No account key in isolated environment, DNS resolution to api.aetherforgeai.com failed (curl 6, HTTP 000); no Aether-specific installed connector found. No actual MCP binding, no provider image upload, no credits spent. No owner PC writes, no Codex, no Desktop Remote. No raw private sprite or credentials published.
- No actual 36-frame output, no selection/atlas image generation, no Godot test, no paper-doll approval. 12-frame selection validator returns ART HOLD intentionally.

## Integration route
Use authenticated Aether MCP via a supported active agent in Orca (host binding must be verified, not inferred), or direct REST adapter. Aether endpoint https://api.aetherforgeai.com/mcp, Streamable HTTP, OAuth preferred where supported. First call get_credit (free), list tools, confirm sprite_pulsar_v2 exists; record actual tool invocation. Do not log secrets. Do not bypass PC Bridge allowlist or create owner PC workspace. ChatGPT MCP UI availability depends on account; official instructions require user OAuth authorization.

Direct adapter: Node >=20, environment AETHER_API_KEY supplied securely by operator in approved execution host; never commit key, never paste key into an Issue. Use only an approved private Drive source, original A62 64x64 F0 exact SHA256 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e as specified by R25. Source rights and provider processing approval must be confirmed before upload. No paid automatic retry, even on HTTP timeout. Record actual provider job ID and balance before/after in private ledger. Adapter is an executable candidate, not yet authenticated.
```sh
node adapter.mjs selftest
node adapter.mjs dry-run IDLE SOURCE.png
node adapter.mjs submit IDLE SOURCE.png --approve-3-credits
node adapter.mjs status UUID
```
Paid submit must only be run once per approved sample, after source hash check and balance check. On ambiguous network result inspect provider history before any new paid submit. RUN is second distinct test, another 3 credits. No ATTACK submit until separately specified after IDLE/RUN results.

## Next macro unit
M1 real IDLE provider job, then distinct RUN if justified; archive raw 36 frames, true provider receipt and cost in private Drive. Visually select 12 ordered frames, preserve motion/foot anchor, no checkerboard, no lossy resampling masquerading as source pixel art. Sprite Gen / Python atlas curation candidate to 256x192, 4x3 64px; prove true alpha, exact frame dimensions, no clipping, original identity at 1x. Do not silently claim generated flattened output is real independent sleeve/hand/underpaint or discard R25 Body/Weapon/FX contract. M2 actual Godot 4.7.2 run with explicit preview and logs. M3 fix failures, M4 distinct RUN with same workflow. Keep ART and gameplay gates independent. Private Drive write/readback, actual job IDs and source/output SHA, no auto-promote. Central control inventory is not changed by this lane.
