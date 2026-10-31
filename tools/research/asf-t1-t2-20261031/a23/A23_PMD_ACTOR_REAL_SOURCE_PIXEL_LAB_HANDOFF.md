# A23 — REAL source-locked PMD0001 and Forest Symphony $actor01 -> PixelLab (2026-11-01)

## Correction of former error
The user required modification of their REAL sprites and making action sprite sheets using PixelLab, NOT generating unrelated frog/white-haired AI concept illustrations, NOT asking to reupload existing Drive/PC files. Sources were actually located and verified on connected Windows.

## Sources found and inspected
1. PMD original `E:\CG_PMD_Source\0001`, original `AnimData.xml` + all 34 original native per-action atlases.
2. Existing user-approved P3_G9 lava-frog 0001 (orange-grey basalt juvenile) `E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025\outputs\P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027\0001`. Original original XML and all offsets/shadow unchanged. Source XML SHA256 `c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162`. The complete 34 native action atlas PNG, 34 Offsets, 34 Shadows, 1 XML: **103 files byte-for-byte copied and SHA verified**. Do NOT force 32x32: Idle 32x40, Walk 40x40, Attack 64x72, Charge 32x40, Hurt 40x56, Faint 32x24. Eight directions except special 1-row actions.
3. FS actual game project `E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9`; actual `Game.ini` title Forest Symphony. Own `Graphics\Characters\$actor01.png` 96x128 (3x4 native 32x32), with `$actor01_1.png`, `$actor01_2.png`, `$actor01_3.png`. Original hashes: $actor01.png SHA256 df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5. Lunar Wish sample $Actor01, generic Actor1 RTP and separate game copies were deliberately NOT substituted. Right-facing row2 is a starter view; precise southeast 45° view not yet validated.
4. Authenticated PixelLab paid account from already authorized local Windows setup returned HTTP 200; "Tier 1: Pixel Apprentice", active, 1960 / 2000 units at the time of A23 PMD trial. No credentials were printed, uploaded or committed.

## Actual prepared native source
`E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST`
- `PMD0001_FULL_XML_COMPATIBLE_AUTHORITY`: all 103 original PMD action/metadata files, no content changed, SHA pass.
- `PMD0001_XML_NATIVE`: six action references Idle / Walk / Attack / Charge (cast) / Hurt / Faint (death), eight-row southeastern 45° sample row1 (provisional mapping).
- `FS_ACTOR01_NATIVE`: original four graphics sheets byte-identical.
- `PIXELLAB_INPUTS`: action-specific references from those exact original sprites. PMD original native 32x40 extracted and centered into 64x64 no resampling. FS right-facing 32x32 actor padded to 64x64, and one manually edited sword-bearing source candidate. This pixel edit uses the FS original sprite; not an image-generated character. Candidate art G7 NOT REVIEWED.
- Action text specs for idle / walk / attack / cast / hurt / death. PMD output integration requires native XML-defined atlas dimensions / action durations, shadow/offsets unchanged, seven untouched directions retained. Four PixelLab output frames must not be naively treated as source XML's three or eleven frames. FS actors keep native 3x4 sheet plus Tankentai/Kaduki action mapping after art gate.

## One real PixelLab request underway
- A23 `a23_one_paid_spritesheet_trial.py PMD_IDLE`, actual POST /v2/animate-with-text-v3 accepted with HTTP 200, status=processing and background ID `7ba06998-bff4-4e75-be90-08ca60e63c19`.
- Source 64x64 PNG SHA256 `af1657376947910a2378dcf0b10bb54452ca114eccfa470dbd1a54b7fee95806`. 4 frames (official example ~1 generation), transparent background, enhance_prompt false. Before balance 1960/2000. Anti-double-POST lock saved. Read-only polling not yet completed at time of this handoff text.
- **Do not claim usable Sprite Sheet, G7 PASS, native PMD XML import, FS formal SBS action, or quota delta until actual returned images + QA are checked.**
- Actor attack API submission is on hold until PMD first test is visually assessed; shared PixelLab credits with separate map-development chat. On failure do not burn all six actions.

## 6 target actions
Walk, Idle, Attack, Cast, Hurt, Death. PMD legacy XML names Walk/Idle/Attack/Charge/Hurt/Faint. 45° facing PMD: provisional original row1 southeast. FS $actor01 source row2 right side (3/4 illusion), true 45° direction needs PixelLab Rotate or manual redraw before production; do not claim official 45° acceptance yet.

## Previous mistakes not to repeat
No prompt-only concept art. Do not ask for already-accessible source files. Do not conflate unrelated RPG character examples with Forest Symphony. No 32x32 forced PMD atlas cuts. No fabricated complete sprite sheets from a single still. No model usage before per-asset permission and hard budget cap.
