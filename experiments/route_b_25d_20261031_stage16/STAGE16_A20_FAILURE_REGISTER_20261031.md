# Stage16 A20 — Failure/Improvement Register
2026-10-31 | Native reference-conditioned model API PASS; complete ground3 art FAIL; Formal Seal NO.

F-A20-01: Prior A19 had authentic FS grass 64px + sand48px style image but insufficient texture; A20 changed the endpoint to generate-with-style-v2 and used 3 128px original FS reference crops. Different endpoint + input set, so output gain cannot be causally attributed to one change alone.

F-A20-02: Each 128x128 ground reference crop has minor source contamination (tree/canopy/cliff at edges). Model-generated heavy outlines, vegetation clusters and ground sprouts can partly reflect this. Future A21 must curate pure semantic ground samples; no standing PAR objects in output.

F-A20-03: The generated output is indeed original 128x128 from specialist model, not a resize; improvement in recognizable plants does NOT imply native 544x416 full ground generation or acceptable source ground3 art.

F-A20-04: 1x view and 32px nearest sampling reveal stylized dark leaf outlines, uniformly saturated grass and strongly contrasting road edges. Actual ground3 has finer, richer, more organically distributed texture. Art FAIL pending user's approval.

F-A20-05: 128px style samples trigger **4 variants** on one request, as official API docs say. This was a single POST and charged 10 generations total, not four separate paid requests. Balance 1990->1980; USD credits remain 0. Do not generate again unless user agrees.

F-A20-06: Cold QA is for original PNG bytes, crops, dimensions and SHA; do not re-run paid API to assert reproducibility.

F-A20-07: No PAR layer, collision, Godot or native VX Game.exe; Formal Seal NO. Do not replace production FS Ground.

F-A20-08: Old launcher stores secret-shaped text; never include token value in logs, Github, or user-visible documents. Recommend rotating token and moving credentials to secured local manager.

Final: ENGINEERING PASS / STYLE_REFERENCE_PROOF PASS / FULL_ART_FAIL / 544x416_NOT_RUN / FormalSeal_NO.
