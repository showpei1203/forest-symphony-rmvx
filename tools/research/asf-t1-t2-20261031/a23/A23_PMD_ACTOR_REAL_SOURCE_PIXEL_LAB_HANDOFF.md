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

## POST-PREFLIGHT REAL A23 RESULTS 2026-11-01
PixelLab T1 paid API authenticated via existing authorized local token, with safe sanitized balance and no credential disclosure.

**PMD0001 Lava Frog Idle**: one accepted POST /animate-with-text-v3, job ID `7ba06998-bff4-4e75-be90-08ca60e63c19`. PixelLab returned FIVE 64x64 PNGs, frame0 exactly matches input. Per-frame pixel RGBA differences versus input: [0,73,191,259,271]. Balance 1960 -> 1959: **1 generation**. Human art review: original orange-gray lava frog remains recognizable; subtle motion but a few pale yellow stray trailing pixels. Candidate only, NOT sealed.

**FS actual $actor01 Sword Attack**: one accepted POST job ID `ff02f858-08bd-4969-8e78-2b430fb01264`. FIVE 64x64 PNGs, exact original first frame. Differences [0,633,627,548,431]. Balance 1959 -> 1958: **1 generation**. Original white hair, leather outfit and right-facing body readable, action shows sword swing. But sword duplicates/ghosts in some frames, vanishes in another; **G7 FAIL for formal game use**. Source seed is real Forest Symphony $actor01.png right-facing center frame plus explicitly identified 78-pixel hand-drawn sword attachment, source actor unchanged.

**Actual native PMD XML atlas round-trip**: generated frames indices [0,2,4] were placed into the 45° provisional row1 of a full 96x320 original Idle-Anim.png. First frame RGBA changed 0 pixels. The other seven original direction rows are byte pixel-identical. `AnimData.xml`, `Idle-Offsets.png`, `Idle-Shadow.png` hashes remain identical. Other 33 action atlases and all PMD original metadata are present in candidate folder, copied byte-identically. This proves native geometry and XML structural compatibility for this candidate, NOT full PMD in-game animation or visual acceptance.

**Actual private Windows deliverable**: `E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST\A23_REAL_PIXEL_LAB_TWO_ACTIONS_AND_XML_PRIVATE.zip`
346 unique files, 997,693 bytes, CRC PASS, SHA256 `88bb074b74617f4e5153bd1300b58c1a59812f82935d5e2ac8c8c186480191a9`.
Includes full native PMD 34-action 8-direction source, unchanged XML/Offsets/Shadow, real FS actor01 original 4 native sheets, transparently modified sword seed, both REAL PixelLab five-frame output sets, actual provider sprite sheets, GIFs, 5X comparisons, rebuilt native PMD Idle atlas, QA and source scripts. **Private image ZIP resides on user's Windows; not uploaded to GitHub/Drive.**

Budget used **2 of 2000 generation units** in this experiment. Final two-test budget stopped. Walking, casting, hurt and death for both, and PMD attack/FS idle are **NOT YET GENERATED**: action prompts and real reference inputs prepared, but no additional quota spent pending G7 fixes. Do not assert six complete sprite sheets or true 45° Actor01 view. 0001 PMD row1 southeast classification is provisionally based on original 8-row layout, not confirmed by actual loader direction semantics.
