# Forest Symphony T-A R10 — Full LPC original source + UNARMED ACTOR01 AUTHORITY
Updated 2026-11-21. User latest direction supersedes R8/R9 bad-body/weapon workflows. Godot 4.7.2 ONLY.

## Original upstream download (owner explicitly authorized E drive or private Drive)
Repo: https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator
Pinned master commit 86a3719ee4a7e2e9fb27c7c152e29a741d3e930a, 2026-11-20.
Saved full immutable source ZIP on authorized owner PC:
E:\LPC_Original_20261121\Universal_LPC_FULL_86a3719e.zip
ZIP size 150940625 bytes; SHA256 C3E73FAFE062A80DCABA6CEF3DCA367B988F6E09D983AA5C9AB3FF05673185DC.
ZIP 95613 total entries / 89359 files; Python ZipFile.testzip() None; extracted 89359 files including 88130 PNG; README.md, LICENSE, CREDITS.csv, spritesheets, sheet_definitions, palette_definitions, sources, package.json verified present.
Extracted full snapshot:
E:\LPC_Original_20261121\Universal-LPC-Spritesheet-Character-Generator-86a3719ee4a7e2e9fb27c7c152e29a741d3e930a
Verification: E:\LPC_Original_20261121\VERIFIED_SOURCE_REPORT.txt and SOURCE_DOWNLOAD_SHA256.txt.
Source archive is complete pinned GitHub source, not historical Git history. Source assets have mixed upstream credits/licenses; never push raw LPC PNGs to public FS repository. This specific full-original E: storage is user-authorized exception to default cloud-only policy, not blanket permission for future unrelated projects.

## Unarmed source-based FULL BODY
User explicitly rejected prior R8/R9 elastic arms and visual markers and asked for a weaponless LPC-based 45-degree ACTOR01 attack, preserving the approved character identity.
- Use original unmodified LPC full-body attack poses, not custom linear interpolated limbs, weapon-angle hacks, fake support dots, or deformations.
- ACTOR01 approved white hair/face and green outfit identity has independent original A62 SHA256 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e. No LPC replacement actor.
- No sword, no shield, no dagger, no FX arc and NO weapon anywhere until user changes this specification. Weapon and FX independent 256x192 atlases are all transparent by design, not missing work.
- LPC base has only FOUR CARDINAL orientations, NOT true diagonal 45 degrees. Right-facing LPC original poses with approved 3/4 Actor01 head is only a source study, not native 45-degree pose art. A genuine diagonal keyframe redraw needs independent ART acceptance.
- Godot 4.7.2 rig may preserve original 12x64x64 / 256x192 Body/Weapon/FX format, F7 presentation contact 0.630 seconds only, no impact art. Do not imply battle animation, skill HP/MP or actor queue have been integrated.
- Quality gates: arm joint lengths must be visually fixed with no stretching, full body must shift organically, ACTOR01 head identity unaltered, face expression changes must be human-reviewed, no anomalous symbols, and no weapon content. Test animation at real 1x size; engineering tests never automatically confer ART PASS.

## Actually constructed R10 weaponless source study
Reproducer: godot_port/tools/ta_r10_lpc_actor01_unarmed.py
E:\LPC_Original_20261121\FS_R10_ACTOR01_UNARMED_SOURCE_STUDY
Source official male slash ROW RIGHT, SIX unmodified original complete body/arm/leg poses mapped into 12 timing slots with holds; no warped or newly illustrated extra poses. Approved A62 original head/hair pixels layered with a source palette-mapped tunic/pants/boots. No weapons.
Body atlas 256x192 SHA256 819313100674a1c55a6bd93a250a2ab07df4c0b2fbca4126331b439b46d2d33f.
R10_SOURCE_LOCKED_MANIFEST.json includes source file SHA and frame map; QA preview 4x and GIF saved in same directory. No new PixelLab job. Godot R10 native test NOT RUN, HUMAN ART HOLD. Next work is genuine new 45-degree 12-pose animation with these verified real LPC sources.

## No other branch affected
Do not change T-C, T-B, phase1 battle, main, sealed VX or historical A52 files. Latest direct user instruction about unarmed R10 is binding until superseded.
