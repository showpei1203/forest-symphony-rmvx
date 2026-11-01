# A33 R1 Handoff: human 16 actions direct pose control real PixelLab — 2026-11-01

## User instruction and authoritative source
Continue A32 rules and PixelLab testing; upload rules; start immediately, no user reconfirmation.
Google Docs formal rules: https://docs.google.com/document/d/1qGJi0QhDrGZC3P_AzVWakEwUpSHjNmKSkvZlToGLh7E/edit
GitHub branch test/asf-a33-humanoid-pose-direct-control-20261101, rules and source scripts.
Original 16 action screenshot reference was split into four private 96x128 transparent PNGs in the chat. EXACT row09 Dodging and row05 Damage original 32x32 poses were palette-losslessly transferred into PC via base64 zip. Each native pose padded exactly (x4, y6) into 40x40 transparent. No pose painted, re-illustrated or interpolated.

## REAL outputs
Waiting: A31 real native neutral Idle copy, one static frame, 0 paid generations, no artificial shoulder tremor.
Dodging A: old A32 text baseline e1d05e30-8541-4c94-8bce-a1e89f18405f FAIL, no repeat.
Dodging B /transfer-outfit-v2 job 9b24c4b7-17de-4f98-a3a0-538356202384 generated 3 real frames directly from screenshot pose images + approved white-haired unarmed FS character identity. 10 generations. Visual: whole body ducks, recovers, clearly more distinct than A32 text-only dodge; 45° and exact character/style user art review pending.
Dodging C /edit-animation-v2 job 0e30620e-df8d-445b-914c-2da293cacba5 adjusted the B 3 actual frames jointly to southeast 45. 10 generations. Compared to B, only subtle changes; cannot confirm actual more accurate 45°, NOT PASS.
Damage B /transfer-outfit-v2 job e51526e0-9904-4f24-88ad-add0c2120d05 generated 3 real frames from screenshot Damage row exact poses, 10 generations. No weapons embedded. Visual candidate pending user review.
Damage C intentionally STOPPED after C Dodge marginal benefit: don't waste generations on identical text-only revision.

## QA and safe gates
B/C generated sprites are native 40x40 transparent; original screenshot reference poses are exact 32x32 palette/alpha images.
One shot frames, not seamless loops. PixelLab provider job success is NOT aesthetic success; actual 45° is pending; SBS paper doll weapon overlay, FS VX/Godot rendering not tested.
Original FS $actor01/$actor01_1/_2/_3, A26 approved character, PMD XML/source, SBS _1/_2/_3 all unchanged.
Start balance 1811.8, end balance 1781.8 /2000. Exact 30.0 generations, 3 jobs with locked submissions, no uncertain retries.
Private project E:\GameAssetToolLab_20261023\A33_HUMANOID_DIRECT_POSE_20261101

## Next stage
Direct pose conditioning is preferable to description-only. Fix 45° via actual native battle-view image source (actor01_1/_2/_3) instead of repeating text prompt on C. After art approval, benchmark Critic Damaged and Jump; no nonhuman PMD anatomy copying.
