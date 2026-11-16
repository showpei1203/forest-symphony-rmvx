# FS A37 | Godot-first Actor01 RUN Animation Pilot

**Scope:** Isolated Godot 4.7.2 project. Uses an A35 real PixelLab 8-frame Sprite Sheet 256×128, 64px frames with an unscaled 48px actor inside. No RMVX 3-frame adapter. **ART HOLD** pending refinement of F6/F7; not production-signoff.

Open `project.godot` in Godot 4.7.2 and run `scenes/battle_run_preview.tscn` (F6) or main project (F5). AnimatedSprite2D with exact native sheet. Keyboard `1` uniform raw 8fps; `2` pacing tuned 10fps (F6/F7 brief); `SPACE` pause; `+/-` speed.

Reusable node `scenes/actor01.tscn` owns `FSBattleActorAnimator`, a data-driven SpriteFrames loader. `assets/actor01_animation_manifest.json` records exact size, durations, source and approval status. Only RUN is implemented: idle, attack, cast, hurt, death intentionally return unsupported rather than displaying substitute art.

Repro graphics check on authorized desktop with real OpenGL renderer:
```
Godot_v4.7.2-stable_win64_console.exe --path <project-folder> --script res://qa/qa_run_animation.gd --rendering-method gl_compatibility --resolution 1024x720
```

**Privacy:** art and binary output must be kept in private Google Drive, scripts/QA mirrored to the FS GitHub draft branch. No FS main/old VX files touched.
