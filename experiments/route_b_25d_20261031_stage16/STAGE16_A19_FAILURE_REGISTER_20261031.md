# Stage 16 A19 — Failure register and security note
A19-01: Earlier assistant claimed no direct local computer/API tools in this conversation. Corrected: Desktop Commander is online, existing Windows API authorization works; GET /v2/balance HTTP 200, POST succeeded.
A19-02: The old one-shot launcher uses a process-scoped env token, so ordinary follow-on shells show no PIXELLAB_API_KEY. Distinguish missing inherited environment variable from missing authorized credential. Avoid sharing or logging API secrets.
A19-03: Actual native model 128x128 source PNG proves generation endpoint and image format, not Ground3-grade detailed ground. 34 colors, mostly flat grass, broad pale path; 1x / 32px detail aesthetic FAIL.
A19-04: The expensive operation was executed ONE TIME only. Server reports 10 subscription generations used, before 2000 -> after 1990; US$ separate credits remained $0. Polling job state was read-only and did not re-submit.
A19-05: No native 544x416 model output or Golden Ground/PAR/Collision/Godot/VX test, no formal project replacements. Formal Seal NO.
A19-06: Do NOT cold-regenerate via PixelLab API since that charges again. Cold archive integrity and local QA re-execution are sufficient reproducibility for provider provenance, with job id and original raw bytes recorded.
A19-07: Local old secure launcher includes credential-shaped text in its prompt. It should be cleaned and key rotated or moved to a protected local store by the user's choice; never commit or upload that launcher or any token string.
Next step only after user visual judgment and provider usage check: one alternate style-conditioning trial or stop.
