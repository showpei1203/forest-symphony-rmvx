# A45 failure log and learned QA

1. A44 visually revealed 7 disconnected pixels near F6 body right side (bbox x55-56,y40-43). A44's old QA checked no border crop, not silhouette connectedness. A45 removes the isolated component and requires exactly one 8-connected Body alpha component for every frame (12/12 PASS).
2. A44 foot pose overextended: separate feet x30 vs x~44-46 combined with long shin outlines; A45 resets original-proportion stance to 10..14 px separation with rear supporting foot anchored (1..10) and front plant holds F3/F4 and F6/F7. Independent image-color foot detector confirms positions, not only the generator input.
3. A44 FX had a long amber L-shaped trail. A45 replaces it with <=130 alpha micro-glints within 7px of the tip, avoiding a second rigid silhouette.
4. Initial independent shoe-color verifier assumed brown pixels extend to y49. Actual brown interior ends y48 while dark outline extends to y49. Corrected measurement and reran PASS, documented as QA test-only error.
5. A45 contact QA originally bulk-replaced FSA44PracticeTarget with nonexistent FSA45PracticeTarget. Kept previous target class because A45 uses the inherited isolated demo. Re-ran after fixing class: PASS.
6. First console log print failed under Windows cp950 because decoded Godot import output contains replacement chars. Switched printed tail to ASCII-safe while keeping full UTF-8 logs; Godot itself imported correctly.
7. Corrected inadvertently non-ASCII K in first GIF filename. Source generator made Python Pillow 12+ API compatible by replacing deprecated getdata with get_flattened_data.
8. REVIEW LIMIT: alpha component continuity, foot centers and native GPU exact pixels cannot prove smooth organic shoulder/torso rotation. Upper-body attack weight remains aesthetics HOLD. Do not declare ART PASS automatically.
9. All source A44 assets preserved, no GitHub main/migration/map edits; E: RMVX unchanged. No PixelLab billing.
