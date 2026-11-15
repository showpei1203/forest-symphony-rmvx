# Forest Symphony | A35 R8 R3 Failure Log | 2026-11-16

Status ENGINE PASS / NAV PASS / REAL GPU 4/4 PASS / PIXEL QA PASS / ART HOLD.

1. Cottage glare from R8 R2. Old lamp at (1090,280), energy 0.66 and scale 3.4 caused 65,972 changed east-cottage native GPU pixels. Moved to forest canopy (805,90), reduced to energy .29/scale 2.2/fill .14. Exactly 0 affected cottage pixels, 43,667 changed in forest. FIXED in tested fixed night view.
2. R8 R2 zero-energy PointLight2D ghost regression. Explicitly disabled real secondary PointLight2D objects on OFF. Original R8 R2 fill-only vs R3 grove OFF: 0 changed pixels, peak delta 0. PASS.
3. Light locality. 45,608 changed pixels inside 190px new light radius, none outside. Confirms physical scene-local effects, not global tint.
4. Ground/PAR preservation. 187 original PAR objects, 175 trunk and 175 canopy LightOccluder2D, anchor/source SHA and CollisionShape2D unchanged. Original Ground SHA 3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000. Navigation 8/8 and four protected routes PASS.
5. Scope limitation. Night only, fixed 1280x928 viewport. Need distinct day/dusk tests; no validated 3D volumetrics, depth-of-field or physically accurate foliage semitransparency. Original conifer edge spikes ART HOLD.
6. Source/release integrity. Godot editor import, actual source/physics nav and original four GPU frame capture all Exit 0. Full private native ZIP 398 members, 199,988,204 bytes, ZIP CRC PASS SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830.
7. Drive sync. R8 R3 source ZIP confirmed private by provider. Final full QA ZIP written to Google Drive mount, exact provider file ID must be read back before claiming cloud upload complete.

Next: native day/dusk original GPU and 1:1 art review, then real Ground3 only after foliage gate. No work in A36C or older VX.
