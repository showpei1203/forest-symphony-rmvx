# A28 FINAL HANDOFF - Real PixelLab six action review (2026-11-01)

## Approved baseline
- A25 PMD0001 orange volcanic monster concept = USER PASS.
- A26 PMD0001 Idle and Walk native candidate sheets = USER PASS.
- A26 FS $actor01 white-haired short teal-armored swordsman original 1:1 head/body, native 40x40 Pixen = USER PASS.
- Never overwrite originals nor return to A24 flat one-color shoulders/black floating species.

## Completed new animation work
- PMD 6 action Southeast-facing generated from approved source by A27, four new actions (Attack Charge Hurt Faint) remain for batch review.
- FS A27 Idle + A28 Walk, Cast, Hurt, Death, and **Attack via pose-driven animate-with-skeleton-v3** all generated.
- A28 first 40x40 skeleton Attack has sword at right edge. Superseded by 64x64 transparent padded 40px approved art, **no rescaling**, 18 joints estimated and hand skeleton animated. 6 real returned frames; sword visible F2/F3/F4; no right/bottom touching. User visual gate pending.
- FS other four actions each 5 real PixelLab frames, from same exact approved 40x40 character.
- A28 PMD Faint source width33 was repaired in a copy by removing one distal tail pixel (15,43) in final generated 64px frame; native 32x24 cell now fits with 0 clipped pixels. Other seven direction rows unchanged.
- PMD XML eight-direction full art not ready. FS original SBS _1/_2/_3 not updated. No sealed originals overwritten. Not a formal engine PASS.

## Provider IDs and quota
- FS estimate-skeleton completed: charged ~0.1 generations.
- FS skeleton40 job 81c4a263-5e0f-45cc-b5e8-a6c446ed6116 charged ~3, quality had right-edge clipping.
- FS skeleton64 padded job 39464b94-de99-4232-827b-163ca4c382ec charged ~3, preferred Attack candidate.
- FS Walk job 27125a7b-1821-40d8-b63e-6b6da6791e9a 1 gen.
- FS Cast job ef24d67a-5eac-4539-a01b-88761bd08269 1 gen.
- FS Hurt job 79446ea9-4f2c-4cc8-854e-8aa621d2553c 1 gen.
- FS Death job 95d1969f-5f73-4146-ab47-480affa2b4e1 1 gen.
- Live balance 1843.9/2000, A28 spent ~10.1 gens (1854 prior).
No repeated payment on transient parser error; recovered the previously completed 40px skeleton job by ID.

## Preview for user on mobile
- A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png: all six PMD and six FS actions; original 1:1 pixel nearest scaling.
- A28_PMD_SIX_ACTIONS_MOBILE.png and A28_FS_SIX_ACTIONS_MOBILE.png: separate larger previews.
- A28_PREVIEW_LL.webp: compact lossless preview to transfer into this chat.
- Per-action FS_*.gif, source PNG and provider logs in private ZIP.

## Next handoff requirements
Wait for batch art acceptance. After acceptance, continue PMD eight-direction 34-action XML-compatible source-consistent conversion and FS Tankentai SBS action frame integration. Explicitly review generated off-axis action and 1:1 head/body stability. Never claim engine PASS before VX/Godot visual test. Third party PMD sprite files stay private on E drive, not public GitHub.
