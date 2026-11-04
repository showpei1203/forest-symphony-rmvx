# FS G18 — PMD0003 REAL PixelLab API four-action experiment (2026-11-04)

**Status: real PixelLab jobs confirmed, artifact engineering PASS, formal art PENDING / partly FAIL, native PMD/VX engine NOT TESTED.**

## Scope and source
- User requested continuation of the PMD0001–0003 lava-frog evolution pipeline, but this experimental branch is **PMD0003 only**. A68 actor remains paused; G11/G12 original native PMD graphics, XML, Offsets and Shadow are untouched.
- The stage-3 lava toad ImageGen concept is a design reference only. The G13–G17 animation outputs here are **actually produced by the user's authenticated PixelLab API**, not generated animation montages.
- Direction fixed at **south-east 45°**, source 128×128 RGBA, independent three-key animation semantics `_1/_2/_3`. They are *not yet* native PMD animation atlas cell dimensions.
- G15 auto-skeleton from PixelLab successfully returned 18 true anatomical points. Before skeleton generation removed exactly 33 orphan alpha pixels from the concept input, preserving the main body. Template: `bear`, direction `south-east`, view `low top-down`.

## Actual jobs and gates

| Stage | Semantic | API | Actual job | Job provider usage | Frames | Gate |
|---|---|---|---|---:|---:|---|
| G13 | Waiting | animate-with-text-v3 | `0b6aceb9-c121-4ac4-9da6-705cf9cfb209` | 1 gen | 5→3 | candidate, source stray pixels |
| G14 | Moving to Close Attack | animate-with-text-v3 | `8d3294bf-6934-46e7-9846-6e1425380a6b` | 1 gen | 5 | ART FAIL, poor leg alternation/detached alpha |
| G15 | Moving to Close Attack | animate-with-skeleton-v3 | `b8ed2211-54f4-481a-b0cd-8576aeb4182f` | 2 gens | 3 | candidate, 3 frames each one alpha connected component |
| G16 | Close Attack | animate-with-skeleton-v3 | `543a0aee-661c-4621-a7fd-4bca6b304816` | 2 gens | 3 | ART FAIL, weak strike motion |
| G17 | Magic Skill Use | animate-with-text-v3 | `d5f36755-abe1-4197-9951-03266f5ea605` | 1 gen | 5→3 | candidate, consistent lava brightness and opening mouth |

G15 skeleton detection is one separate `estimate-skeleton` provider call; charging for that endpoint should not be confused with actual animation jobs. In G16 the total account balance fell 12 generations during the call, but the **specific provider Job's `usage.generations` is 2**, so do not attribute the other 10 to this job.

## Actual deliverables / verified
- [Google Drive G18 folder](https://drive.google.com/drive/folders/1EkAT1y7mrPLW6YS4S9fkGp7VkcCzS2Hr)
- [Complete verified archive (2,060,246 bytes)](https://drive.google.com/file/d/14-iKXETBtjgXCS98jDfick8KoVsByX_F/view)
- [Real PixelLab provider 4-action 3-key contact](https://drive.google.com/file/d/13OPOYe_V00WJCcGaAFBJKkcwfKhKXV4y/view)
- [True 384×512 transparent 3×4 TEST sheet, with failed Attack](https://drive.google.com/file/d/1tpPxOZNlGhJqLVkNqECqN9rE4SWGaaF-/view)
- [Full detailed Handoff MD](https://drive.google.com/file/d/13ZZ_jGjI1nrHM5WnW8kxtekH-UNwt78m/view)
- Outer ZIP SHA256 `5d9c2dafd9b240086ba6147d3fe6e2e0679da4e7c4f78de66fec718ea1adcf95`; 14 entries; ZIP CRC PASS and 13/13 internal SHA256 PASS. Includes stage G13/G14/G15/G16/G17 original provider result archives, three actual GIFs, per-pixel provenance map, scripts, run-state logs, source contacts and error records.

## Failure prevention and next
- G14 shows why pure text-guided walk fails: forelegs not alternating, foot morphing and extra alpha components. Retain G14 FAIL as negative test, do not mark PASS.
- G15 is better because all 18 four-legged joints are explicitly driven; no independent edge debris; still needs human approval and loop continuity inspection.
- G16 peak strike remains visually weak despite an extended front-limb skeleton; next target G19 MUST explicitly enhance forward head/torso acceleration, foreleg strike and recovery in three different poses. Do not silently accept or substitute the weak frames.
- G17 is a promising cast candidate with body-baked glow. If the engine requires separately controllable FX, split effects after visual approval.
- **Critical:** 384×512 sprite sheet is a *candidate inspection artifact*, not the final native XML sprite sheet. Do not downscale or overwrite approved original PMD atlases until user approves artwork and an RPG Maker VX engine test passes. PMD0001/0002 were not regenerated here.
