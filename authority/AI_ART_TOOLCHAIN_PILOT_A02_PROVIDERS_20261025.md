# A02: Provider Clients and Commercial Gates | 2026-10-25

A01 baseline: [Authority](./AI_ART_TOOLCHAIN_PILOT_20261025.md).

## New verified environment changes
- PixelLab Python SDK **1.0.5** installed inside the isolated virtual environment. Imported successfully. No API credential configured; zero generation requests.
- Official `spritecook-mcp` npm package **0.2.17** staged inside the isolated `providers/spritecook` directory with install scripts disabled. No account authorization or live MCP tool call yet.
- MagicPixel `https://magicpixel.art/mcp`: browser OAuth connection needed; do not confuse with magicpixels.ai.
- AutoSprite `https://www.autosprite.io/api/mcp`: paid subscription/key required. Not connected.
- PixelLab remote MCP `https://api.pixellab.ai/mcp`; v2 API `https://api.pixellab.ai/v2/docs`. Credentials only via user-approved local secret store.
- Tiled 1.12.2 portable extract PASS (official signed binary), GUI export FAIL/PENDING; ASF Tiled writer/verifier internal zero-pixel PASS.
- Godot 4.7.2 reused from existing isolated tests; LDtk optional secondary editor remains not installed.

## Art gates
Actual P1G A47 six-frame 288x192 => 2x3 (three Idle + three Attack). Idles: QA WARN; Attacks: QA FAIL, second attack head ratio 0.92 vs permitted 0.95..1.05. Preserve exact PNG and inspect before any visual sign-off.

## Deliverable
- Private A02 ZIP: https://drive.google.com/file/d/12ERaejLXmqkffFGv8dnJ24tN6UEhqsBZ/view?usp=drivesdk
- 69 files, 206,671 bytes; local and G: mounted Drive SHA256 **1df1887ad09d57bd6c92ab478d9d8214c009095c87a8a710f11ca2a18a1c9141** and ZIP CRC PASS. Drive provider confirms title and size.
- This ZIP is a diagnostic/QA artifact and source scripts, not a full standalone Godot/VX playable build. Source pinned in local installation.
- Payment / art generation: **none**.
- Next: true Tiled GUI import/export, FS scene 32px source-based adapter, one original 3-stage chibi monster production test, full native VX/SBS and human visual gates, no sealed changes.
