# FS A37｜T4 使用者選定 + Damage 真正 PixelLab 施工規格
日期：2026-11-01
## User decision
User explicitly selected the FOURTH alternative in A36 Dodging 3-frame preview: T4_ANTICIPATE_ROLL_LAND. Do not substitute earlier T3 just because assistant had recommended it. User selection is authority for the action variant. User has not approved SBS runtime or per-frame camera subtleties yet.
## Deliverable
- Exactly 3 frames per action: native 40x40 source cells, 120x40 single-row RGBA sheet. Never output official 14/18/28-frame.
- Dodging T4 frame sources: genuine PixelLab A35 interpolation A02 -> A06 -> B07, exact source pixels, unchanged. Three phases: anticipate, forward tumble, land/recover. Original Forest Symphony and A31/A34/A35 assets untouched.
- Dodging T4 playback: one-shot (no GIF loop extension), 3 frames. Tankentai SBS actor and weapon icon/overlay stay separate, no embedded swords/hilts/shields/bows.
- User chose T4. The engine layer and exact east-southeast 45° head/shoulders/hips/feet of each frame remain separate gates. Do not claim formal engine PASS without VX run.
## New Damage production
- A33 prior Damage B had three genuine source-posed frames but a 90° side-facing risk.
- A37 inputs: F0 and F2 from actual PixelLab-created A34 FS actor01_1 authoritative battle camera chibi unarmed reference; F1 from A33 genuine PixelLab damage reaction frame01, screenshot pose-driven. Full 3-frame PixelLab /transfer-outfit-v2 once, native battle reference image, hit recoil prompt, real job id, billing, three actual 40px PNG results.
- Results must be inspected before additional paid calls. If camera stays 90° in any frame or motion resembles walking, mark art FAIL; no blind regeneration.
## Gates
A source SHA, provider job/billing, no duplicate submit.
B exactly three RGBA frames, 120x40.
C each frame SE 45° battle view, face plane, shoulders, hips, feet, big white-haired 1:1 chibi.
D distinct damage recoil vs walking.
E empty hands, SBS weapon layer independent.
F no limb duplication, clipping or identity drift.
G user visual approval, then actual SBS/VX engine test.
## Repository hygiene
Only scripts, rules, QA and handoffs on public GitHub; private FS/user sprite files stay in private Windows E: and ZIP. Never overwrite authoritative source.
