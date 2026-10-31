# Stage16 A18 Failure Register — 2026-10-31

F18-01 — **Authorization boundary**: PixelLab/Retro tokens were absent in the A17 authorized Windows environment and A18 assistant container. A18 neither authenticated a live account nor submitted any billable generation. `NOT_RUN_AUTH` is not `MODEL_FAIL`.

F18-02 — **Conflicting model size descriptions**: PixelLab's public API intro describes Pixen as 16–768px; its public pricing page lists a 512×512 cap; Pro style-oriented models commonly cap at 512px. Treat 544×416 FS native direct output as **unverified** until a live capability probe and accepted model response. Do not prematurely promise native full-map output.

F18-03 — **Free trial versus free credits**: official free-trial page lists API access, but no specific user's account status, usable token, or credit balance has been checked. Free trial may allow testing; it does not certify this user's entitlement.

F18-04 — **No mock art misrepresentation**: `A18_MOCK_FIXTURE_NOT_GENERATED.png` exists ONLY to validate the PNG decoding and 32px comparison renderer. It is not AI output and cannot satisfy any art or model-generation gate.

F18-05 — **Human visual gate**: color count, RGB similarity, pixel-grid correctness and lack of alpha holes cannot prove Ground3 botanical fidelity. Independently examine 1×/32px native aesthetic and semantic Ground/PAR distinction before declaring any art PASS.

F18-06 — **Paywall/cost control**: scripts contain explicit `--approve-paid` and conservative local cost-estimate guard; this is not a provider-enforced hard limit. No user payment consent received this turn, so no live POST is allowed.

F18-07 — **Code not yet service-certified**: the live request schema, async response fields and 422 handling have NOT passed a live provider API test. The client is a source-documented adapter draft that passed offline unit tests only. The Retro live action is deliberately disabled pending authenticated free estimate.

F18-08 — **Project scope**: No new AI-generated ground PNG, no user-approved native material, no native VX map test, no Godot, no PAR/collision changes and Formal Seal NO. Avoid repeating A10–A17 art-fail generations while waiting for service access.
