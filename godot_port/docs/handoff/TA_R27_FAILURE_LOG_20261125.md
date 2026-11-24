# FS T-A R27 Failure / limitations 2026-11-25

- No generation, inpaint, edit-animation, Aseprite-MCP invocation, native Godot new render or R26 pixel edits in this research turn. Status: RESEARCH_COMPLETE, HEAD_MODEL_DRYRUN_PASS, NEW_ART_NOT_RUN.
- Third-party skills are SOURCE-REVIEWED, not installed or automatically loaded. Several tools depend on unverified Aseprite/Scenario/SpriteCook plugins. Do not claim any succeeded on owner's Windows.
- R26 verified provider face landmark positions (NOSE/EYES/EARS) unchanged across 4 target keyframes; NECK X changed. This supports a missing authored head motion and does not imply PixelLab cannot produce expression changes.
- R27 delta model is a PROPOSAL: rigid face group +/-1px and half NECK delta may preserve point spacing but no model render or 1x art validation has happened; rotational head turns/expression cannot be inferred from coordinate arithmetic alone.
- PixelLab's editor ``fixed head`` setting is NOT proven to be a REST v3 schema field; no fabricated field added.
- Existing R26 generated poses still owner ART HOLD due F03 arm reach, F07 ambiguity, F09 sword below boots. No art pass inferred from this dryrun.
- Existing R26 paid provider job was already completed (#135, #136, 3.1 generations total). DO NOT POST these tasks again or modify paid job journal.
- Third-party skills use other canvas defaults (96x160, 32px), palette caps and Unity/Aseprite requirements. Only digest applicable principles; never silently override A62 64x64 visual identity.
