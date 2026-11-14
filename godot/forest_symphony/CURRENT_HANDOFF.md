# Forest Symphony | CURRENT_HANDOFF A34 (2026-11-14)

**Single current map production rule:** Active Master v1.3 Ground-first, followed by independent full transparent PAR sources and Godot YSort/native gameplay, 1x visual acceptance comparable to free generated scene. **Never re-adopt flattened Master crop** by default.

**CURRENT ENGINE AND SCENE:** Godot 4.7.2; `project.godot` opens `res://scenes/a34_groundfirst_full_houses_scene.tscn`; A33 and A32 scene baseline retained.

- Unmodified original high-quality 1280x928 Ground source SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`.
- Independent complete A34 main house/workshop 288x282 and residential atelier 252x252, original full transparent image-gen sources, do not crop from Master; 2/146 nodes changed, other 144 original SHA+footpoints unaffected. 27 independent source families, 4 A33 complete lamps, 140 unchanged candidate root colliders.
- Godot 4.7.2 real private native `1036/1036 PASS`, old A33 `760/760 PASS`, old A32 `734/734 PASS`, source-only clean `744/744 PASS`. Real 1280x928 4 screenshots. A33->A34 framebuffer changed 80256 RGB pixels, outside both house ROIs 0.
- **ART HOLD:** New houses unapproved, existing forest trees too coarse, door collision and animation NOT validated. Collision map remains root candidate, not a walkable village nav seal. No native Windows export, no NPC/Event/ATB conversion. No paid PixelLab, no owner PC writes, no changes to VX production or GitHub main.
- Private files are in Drive ONLY, public GitHub only code/test/scene/manifest with SHA/provenance.

**NEXT:** (1) author new house doorway paths/collision/door triggers from actual source artwork; test native actors walking into doors, not merely spawn there, (2) align independent tree family color and pixel density to the new houses and Ground, (3) add a playable village NPC / event and independent stream/light layers.

Detailed Failure Log and steps: `docs/A34_INDEPENDENT_COMPLETE_HOUSES_HANDOFF.md`.

## A34 Cloud links & reproducibility
- **Owner-only full project ZIP**: https://drive.google.com/file/d/1VskVH2ghTgv7HYAaanLBYikjLLQhKw6A/view; 184 files; 79,844,278 bytes; SHA256 `ed15669314d59bee9d3fa16c9ced09855c153be090ac6795b8568f0455a550bc`; raw Drive download -> SHA256+ZIP CRC **PASS**.
- **Native full render**: https://drive.google.com/file/d/1ReUpQHR6Y8PC0i2H27Hh6gDMlDCl3ErV/view. **Native true two-house A/B crop**: https://drive.google.com/file/d/1vd5Yk5ft5_kAD_UEnTYenmVSq_HvBG7b/view.
- **GitHub Draft PR #16**: https://github.com/showpei1203/forest-symphony-rmvx/pull/16, no merge to `main`. New house source code + test + document changes pending this turn's final GitHub push. Private original art never published.
- Distinct code rebuild of private source originals in fresh directory: house A/B full PNG, manifest, native Godot scene, A34 world script 5/5 SHA match. New A34 cold real 1036/1036 PASS.
