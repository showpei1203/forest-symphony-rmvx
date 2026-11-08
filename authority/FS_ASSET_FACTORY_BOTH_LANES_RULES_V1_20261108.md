> **SUPERSEDED_METHOD｜A11**：本 A08 方法保留供研究與程式驗證。現行作畫優先順序已由 [FS 唯一現行總規範](FS_ASSET_FACTORY_ACTIVE_MASTER.md) 覆寫。Template-first 為備選 M-B，不再自動壓過高品質 Master/F0 保真優先。

# FS Asset Factory | Shared authority for Sprite + Ground/PAR — A08
Effective: 2026-11-08. User-requested 22-page PixelLab-led report review, actual FS source overrides illustrative examples. No main override; active feature branch PR #15.

## Read first
1. FS P0 Cloud Only, P1 provenance and native source, Master-first P2 and FS original project mapping.
2. [22-page evidence audit](../docs/asset_factory/A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md) — SOURCE REPORT CLAIM vs verified FS vs UNRESOLVED, page by page.
3. [Sprite SOP](../docs/asset_factory/FS_SPRITE_FACTORY_SOP_V1_20261108.md), [Map SOP](../docs/asset_factory/FS_MAP_FACTORY_SOP_V1_20261108.md).
4. [Execution queue](../docs/asset_factory/A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md), [active Handoff](../docs/asset_factory/CURRENT_HANDOFF.md).

## Factory contract shared by both
approved source + style bible + canonical template + semantic or rig skeleton + bounded generation + automated QA -> one exception repair -> genuine FS native export -> 1x ART + native Game.exe -> cloud delivery.
No batch art from unapproved reference, no fake "8 direction" or copied bridge ground, no claiming technical static tests seal artwork.
Any repeated issue in 2 assets is a TEMPLATE failure; stop asset-level micro-edits. Keep 2 scene pilots and 2 sprite archetypes visible as outcomes.

## Critical native format scope correction
Older "each action 3 frames" instruction applies to the user-approved THREE STORED keyframe loop/sequence for FS Actor and certain intermediate PMD pose production. **It is NOT a rule for every native PMD AnimData.xml atlas.** Authentic XML determines per-action counts/durations, e.g. PMD0001 Idle=3, Walk=6, Attack=11; PMD0002/3 Idle/Walk=4 and attacks 9/11. Never pack 3 frames into six by duplication or ignore CopyOf/Offsets/Shadow.
V3 Master-first: Runtime FullGround = entire frozen Master, Runtime PAR = semantic source-owned true foreground, never blanket CompletePAR. Deck grass/flower/water stay ground, rail front occlusion generated as distinct object identity before mask.
A25 approved monster LOOK only; A26 five-frame Idle/Walk were candidate and source artifact missing; no implied art approval.
Source report's 64px example, 8-12fps proposed baseline and provisional API costs are not FS source authority.

## Machine and review gates
Source SHA & rights / style approval / generator budget / action template / map semantic object ownership / artifact normalization / technical QA / user Art / actual Native VX / cloud readback all separate.
Public code config/asset_factory, tools/asset_factory/production_gate.py and run_a08_pilot.py. Current four manifests are dry-run and explicitly held; no generated/new accepted art. Synthetic CI and pilot tests merely protect rules.
User's PC only allowed necessary installs and separately explicitly approved short-lived native VX test scratch with cleanup. Orca read-only authorization must be verified before new agents. Private artwork in owner-only Google Drive, public GitHub source/docs only.

## Priority
If A06 bridge V2 manual color/GrabCut cropping or A05 "more CI instead of art" instructions conflict with this latest user order, STOP those tasks. Use new semantic source + repeatable templates. Continue only after native/visual outcomes have been planned and measured.
