# Stage16 A35C R1 / R2 failure register
2026-11-02, executed on remote DESKTOP-90VT437.

F01 A35 mistakenly converted ALL 217 cliff-color masked chunks into PAR, falsely occluding valid legal actors. A35B removed them all temporarily but that was not the final rule; user clarified 1-2 tile cliff TOP rear-edge cover depending on cliff height.
F02 A35C R1 four explicit ledges were correctly anchored and six dynamic source-alpha depth sprites produced, but R1 20px mask made actor behind rim show only ~223-228/627 pixels. Real VX screenshot showed detached/floating head, so FAIL. Kept R1 independent failed clone and 22 native frames.
F03 A35C R2 lip thickness reduced to 9px for each eligible depth tile, original A35 Ground RGB SHA identical. 5 late-game back positions hide 154-159 of 627; four front / unrelated locations have ZERO changed pixels. Runtime overdraw only when actor FOOT tile in allowlist. Source static Ground and no-actor full composite unaffected.
F04 Initial no-PAR reference screenshot runner replaced A35C_ globally including literal disk paths: FileNotFoundError. Fixed exact file paths. Reference game log had double A35C_REF_REF prefix, so first numeric QA exact-string assert failed. Fixed assertion to check true MAP_OBJECTS count=0 instead; retained original logs.
F05 Native screen first two cases have title fade, exclude them from strict face comparison; 5 positive/4 negative supported, NOT claim all 6 behind strict.
F06 Height tiers use handpicked four zones and a provisional original 40x29 collision map. Only 695/746 legal candidates connected; steps/cave not solved, all cliff boundaries not covered.
F07 Original art was direct generated at 1473x1068 and resampled NEAREST to 1280x928, not authored tile-by-tile. Top-edge masks are 9px approximations with small contour variation, not a complete hand-approved cliff architecture. Four curated zones only.
F08 Test-only script483 dynamic $game_player-dependent visibility; NPC/followers and production BattleRegression not verified. SHADOW/LIGHT separate. Formal Seal NO.


## Verified Google Drive A35C R2 delivery (2026-11-02)
These are **actual IDs returned from Drive folder listing**. Local ZIP CRC, per-member SHA256 and independent full extract SHA PASS; remote ZIP Drive metadata readback confirms title/byte length, not a separate full remote ZIP download hash.
- **Most useful: actual native VX Game.exe 8 pairs front/behind noPAR vs R2 lip closeup:** https://drive.google.com/file/d/1w7JLfLrbmbOeSyg0oj28C_BRtDp182UE/view
- **Actual cliff top ledge layout and height 1–2 foot grid test plan:** https://drive.google.com/file/d/1elKuJFHTj6d3vF3TKJYhGsY9NB6iIAoI/view
- Locked original direct-style full 1280x928 Ground: https://drive.google.com/file/d/1aTfPCt4t0fGkwssh4LK_ImV-7FFnf_1M/view
- Full transparent STATIC preview PAR50 (runtime actually uses six conditional-foot depth sprites): https://drive.google.com/file/d/1Jpn--T80jh5t1dgb91u8IJxTYGTH-bfO/view
- Source composed full-size Ground+PAR preview: https://drive.google.com/file/d/11b5vonbwCCMbpYTMPErWWCRq7QEvZm-w/view
- Six RGB+alpha images + exact tile/depth manifest: https://drive.google.com/file/d/1hoF-5lzV_52ENMETXvubVYxLGs1TNaC2/view
- True VX independent Game.exe positive 5/negative4 numeric strict QA: https://drive.google.com/file/d/1O9etEt5tpro0fjpVvl01zOGqI4ukmql8/view
- Godot AMD GPU 19 real 1280x928 frames, behind positive/front zero QA: https://drive.google.com/file/d/1leJNhc4-O9QFxqUA1ZlJZIlvnAjOkd4x/view
- Cold native 3635/3635 files, six active source sprites Game.exe, no RGSS error: https://drive.google.com/file/d/1VzXTuYAeAdRssI7nCevKm97EUF23KDeB/view
- Final cross-engine QA: https://drive.google.com/file/d/1Z0r5oGQt_xJPl6S-65ucQXFz5OggR1t5/view
- **FULL PRIVATE R2 source/QA archive**, 146 members, **94,481,296 bytes** including 22 true R2 VX frames, 22 true noPAR control frames, 19 real full-size GPU frames, 22 failed R1 screenshots, source and scripts, no main production binaries: https://drive.google.com/file/d/1PdVFDZpN6pCdkOOUBnje0tmtGvMYZqN0/view
- Package ZIP QA record: https://drive.google.com/file/d/11hBZJMzM6d7tYXupIrbhaDJ2wBU-Y-be/view
- Permanent v2 PAR source/foot/elevation rule: https://drive.google.com/file/d/1u47yzdoEUpfku16locDKTVTBEP5rdKJz/view
- R1 excessive overlay + path/log bug Failure Register: https://drive.google.com/file/d/1fGQgjLAnpUE1sx5bU9Q55epLH5lT7Hix/view
- Detailed A35C R2 Handoff: https://drive.google.com/file/d/1xSLab_L-RQ0u_TxqSSoQjKX1GgVcjuj3/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/16PXa-YIeUJb5lhXv4OlAqG4-kdeIiaEi/view
- Stage folder: https://drive.google.com/drive/folders/1WHfweiXoEZgTxhTM5Xgy3rXEHuO4qXyJ

R2 representative lip engineering **PASS**; not all cliff segments and multi-actor/height passages verified; user visual signoff PENDING and **Formal Seal NO**.
