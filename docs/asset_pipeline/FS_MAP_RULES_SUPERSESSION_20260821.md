# FS Map Rules Supersession — 2026-08-21

Project: Forest Symphony / RPG Maker VX
Related: SHO-39

## Current new-map authority

For NEW FS maps, use in this order:
1. `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_0.md`
2. `FS_MAP_ASSET_PROMPT_WORKFLOW_V1.md`
3. `FS_MAP_DIARAMA_FIELD_STYLE_DNA_V2.md`
4. `FS_MAP_BENCHMARK_WORKFLOW_V2.md`
5. non-conflicting shared asset-generation rules

## Production decision

The default map-production model is now:

`AI produces reusable terrain/transition/prop/architecture/landmark assets -> QA -> Asset Kit -> user manually assembles final map -> runtime derivatives -> RMVX acceptance`

A flattened full-scene Master is optional reference material only.

## Historical documents retained

The following remain stored and valid as history / recovery tools, but are no longer default new-map production authority:
- `FS_MAP_BENCHMARK_WORKFLOW_V1.md`
- `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and inherited v2.x extraction rules
- Castle Town NORTH/MID/SWJ/SWC extraction QA reports and manifests
- previous SAM2 decomposition handoffs

Use those only when the user explicitly chooses `Legacy Reconstruction Mode` for an already-existing flattened Master.

Existing sealed extraction assets are not invalidated and must not be silently deleted or modified.

## Rules NOT superseded

This production change does not alter:
- RPG Maker VX 32x32 world-scale readability basis;
- high top-down / three-quarter projection;
- FS palette/material/style evidence from existing tilesets/scenes;
- pixel-crisp and nearest-neighbor rules;
- map readability / walkable-space / focal-hierarchy requirements;
- runtime script authority;
- Drive/GitHub/Linear/Windows authority boundaries.

## Current Castle Town effect

The in-progress Castle Town reverse-extraction line is paused as the default production path.

Do not continue extracting South Wall West / later Castle Town structures unless the user explicitly asks to resume Legacy Reconstruction Mode.

The Castle Town image may instead be used as style/composition evidence to define a Castle Town modular Asset Kit.

## Shared-authority interaction

Do not edit the cross-project `SHARED_GAME_ASSET_GENERATION_AUTHORITY` merely to encode this FS-specific production decision.

Where shared wording conflicts with this later FS-specific new-map authority, the explicit FS v3.0 production authority controls Forest Symphony new-map production. Global non-conflicting shared rules remain inherited.