# Forest 17x13 VX isolated benchmark | Human acceptance 2026-10-24

Status: HUMAN ACCEPTANCE PASS (ISOLATED VX BENCHMARK ONLY).

User explicitly reported 驗收pass after testing the FS_FOREST_NATIVE_PLAYABLE_FIXED_FINAL_20261024 executable project.

Scope: 17x13 tiles, 544x416, six independent sprites and independent RPG Maker VX Project1-based executable. Native automated movement test logged MOVE_BEFORE=8,6; MOVE_AFTER=8,7; MOVE_TEST_PASS=true. Earlier initial builds failed due to nil sprite initialization and inherited template passability, which were corrected.

Human acceptance was reported as PASS. The user did not separately enumerate individual collision/occlusion cases; do not invent individual human observations.

Source ZIP on authorized Windows machine: E:\GameAssetToolLab_20261023\FS_FOREST_NATIVE_PLAYABLE_FIXED_FINAL_20261024\FS_FOREST_17x13_VX_PLAYABLE.zip

NOT verified: integration with sealed Forest Symphony production Runtime. Preserve FS v3.2 Gate A-F and sealed scripts. Next: preserve this regression fixture, test sealed runtime compatibility, then expand to elf village/castle town.
