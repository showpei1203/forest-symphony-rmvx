# A36C R10 | Forest navigation source-to-runtime candidate
Date 2026-11-14. Source: verified A36B R2 original private Godot ZIP (Ground SHA ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911). Original source scene and 326 PAR unchanged.
## Actual delivered
- 148 32x32 water candidates from existing data/a36_terrain_semantic_candidates.json, converted into runtime StaticBody2D + RectangleShape2D nodes with opt-in collision.
- Complete additive native Godot scene in private project ZIP, retaining all 326 independent PAR owners and original player.
- Full-size 1x original Ground + 148 cell water QA overlay.
- BFS from player tile (41,32): 4488 reachable candidate tiles out of 4492 walkable candidate tiles, connected components 4488/2/1/1. No claimed walkability/bridge PASS.
## Owner-only source
[Full 58,827,067-byte Godot project ZIP](https://drive.google.com/file/d/1rZtAEdy2-vxfQSkr5xl6qqGTX2m7DS8i/view), SHA256 `61cfe0470ad63ec68578752b8bd311e3bc3e2d50f98426b69e042ec3017d8b63`. Private art must remain off public GitHub.
## QA / Failure Log
Source Ground SHA PASS; JSON candidate 148 PASS; BFS PASS as static graph only. **Godot 4.7.2 native parse/render NOT_RUN**, waterbank/bridge visual approval HOLD, physical navigation NOT_RUN, user art HOLD, formal seal NO. Collision defaults OFF specifically to prevent unapproved bridge blocking.
## Priority
Native Godot validation and actual high-quality Ground-first native-pixel riverbank/road repaint. Do not call filter sharpening or movement of trees a genuine art improvement. No main/VX overwrite.
