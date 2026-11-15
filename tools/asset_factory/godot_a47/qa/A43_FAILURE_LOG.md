# FS A43 failure log | 2026-11-15
A43-F01: Windows G virtual-drive root was not a normal writable folder. Resolved by using existing private Drive directory as durable output; transient scripts on C: only.
A43-F02: FX-only candidate did not fix core goal. Replaced by revised Body/Weapon/FX atlases.
A43-F03: A42 runtime filename used dynamically formatted Godot path; simple text replacement missed it. Located actual loader and wired A43 Weapon/FX explicitly.
A43-F04: Initial A43 F4 arm altered head row33. Pixel QA caught it. Corrected wrist/elbow; all heads now exact unchanged y0..33.
A43-F05: GPU raw RGB comparisons failed F4-F8 due OpenGL premultiplied-alpha for semitransparent FX. Example source (251,201,113,110) becomes GPU (108,87,49,110). QA changed to exact alpha with +/-1 premultiplied RGB tolerance; 12x0 divergent pixels.
A43-F06: Formal FS migrated ATB/damage combat integration NOT RUN. Do not claim PASS.
ART: HOLD until manual 1x review of torso pivot, sword and action.
