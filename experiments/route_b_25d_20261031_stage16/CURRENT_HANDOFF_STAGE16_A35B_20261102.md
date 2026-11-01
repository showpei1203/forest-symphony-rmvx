# FS CURRENT_HANDOFF Stage16 A35B, 2026-11-02
Latest branch = **A35B semantic redefinition of terrain PAR, not visual cliff outline**.

**STOP RULE:** A35 old 217 cliff-face color mask PAR not approved. A35B preserved A35 direct-image generated Ground1280x928 SHA478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00. New deliberately empty alpha terrain PAR50 SHA3ddfa14f3ff633edcbe37d2a8d022608d374dbb5ef1698cfa408c54ca4e25c16 pending any physically behind actor-foot entry. Active real terrain PAR 0 until actual front/behind tile pair.

User explained: **PAR exists specifically to hide an actor walking into the appropriate tile**, not trace cliff contour. Ground includes all cliff pixels; only independently sourced semantic overhang/bridge/roof/cave front pixels in front of an actually walkable BEHIND foot tile get PAR. Must specify tile, elevation, foot depth and actual VX FRONT/BACK actor screenshot before activation.

True native VX measured: previous cliff masks covered legal actors (west valley 550 vs corrected627 actor pixels; 77 falsely hidden). 9 native case2..10 hidden background screenshots source identical; A35B 11 positions/22 real 544x416 cases no modal, native move block and road retained. Real Godot full1280 6 +6 native crop actual frames 0 RGB diff. Source A35 remains untouched. 291 provisional walkable actor bbox overlaps cliff-color pixels (flag for collision QA not foreground). A35 pending 746 walkable/414 blockers, largest component695. Cave mouth NOT active until map entry and actual behind/walkable tile.

Read order:
1. authority/FS_TERRAIN_PAR_WALKABLE_FOOT_OCCLUSION_SEMANTIC_GATE_V1_20261102.md
2. experiments/route_b_25d_20261031_stage16/STAGE16_A35B_TRUE_TERRAIN_PAR_WALKABLE_FOOT_VX_QA_HANDOFF_20261102.md
3. experiments/route_b_25d_20261031_stage16/STAGE16_A35B_TERRAIN_OCCLUSION_WRONG_MASK_FAILURE_REGISTER_20261102.md
4. A35 source direct art current handoff / original A34 40x29 size authority.

Remote DESKTOP-90VT437 online, local source E:\FS_STAGE16_A35B_TERRAIN_OCCLUSION_SEMANTICS_20261102, isolated VX E:\FS_STAGE16_A35B_SEMANTIC_OCCLUSION_VX_NATIVE_20261102, Godot source in above\GODOT_A35B_TERRAIN_OCCLUSION_GATED, independent cold VX clone path recorded in cold QA. Formal Seal NO, user A35B screenshots awaiting visual signoff. Continue A35C height graph/real traversable behind-foot occlusion + native test, NOT 217 color contour masks.
