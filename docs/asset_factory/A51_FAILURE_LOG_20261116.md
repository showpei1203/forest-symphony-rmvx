# A51 Failure Log | 2026-11-16

1. Actual PixelLab job b997be06-c1fa-4741-8fb9-bcedf6fc9a39: 10 new 64px Body frames, one 3.0 generation provider call, job lock, zero retries. No Body pixel patches.
2. A51 new fullbody chest motion 401->617 pixels and hips 218->272 vs R4, BUT aligned head residual 141->273. Head stability art gate FAILED; keep R4 instead of force-promoting a worse-identity fullbody.
3. Initial new blade FX crossed x63 at F7, native Godot GPU crop detector FAIL as designed. Error log preserved, corrected 64px palette stamping to 1<=x,y<=62; F7 FX pixels 43->38; reran real GPU + contact tests PASS.
4. First Pillow preview contact script had malformed draw.text argument TypeError; corrected and regenerated actual original native Godot source screenshot GIF.
5. Stable R4+FX GDScript QA path auto substitution accidentally renamed unchanged old R4 Body and Weapon resources. Pre-native source inspection corrected paths to real asset names; reran and verified 12 native GPU frame consistency and contact PASS.
6. Real nonlinear F6 0.560 to F7 0.620 timing is now checked by Godot Animation track actual key time gates, not just JSON. Old 0.55s early-hit negative, F7 0.63 only-hit and 70ms hitstop tests PASS.
7. Three native isolated test projects (new Body, new Body + FX, stable R4 Body + FX) all PASS clean editor/GPU/damage. Each is still an isolated standalone practice target; FULL FS Godot battle integration NOT RUN. User visual art still HOLD.
8. No more paid PixelLab calls until evaluating gameplay-scale animations. Actual provider artifacts and model source remain owner-only Drive; no local permanent computer files, unrelated branches and originals untouched.