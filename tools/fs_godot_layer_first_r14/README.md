# R14 FS Layer First Pilot in native Godot 4

Open LayeredPilot.tscn in Godot 4.7.2. Source objects exist as individual Sprite2D nodes in GROUND, CONTACT, PAR and ACTOR.

- Ground and contact root tiles are never in PAR.
- All raised trees, house, lanterns, fences are separate RGBA Sprite2D in PAR.
- Ground FULL export is the whole scene without actor (original FS complete Ground style).
- PAR export is PAR nodes only, transparent background, same pixel canvas/position.
- Actor back/front preview uses z = world foot Y, not a flat always-on-top picture.
- Do not claim scene art equals ground3 quality. This is a compositing and occlusion proof-of-concept.
- For reproduction run Godot 4.7.2: --headless --path <folder> --editor --quit then --headless --path <folder> --script res://export.gd.