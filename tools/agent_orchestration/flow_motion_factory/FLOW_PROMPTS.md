# Forest Symphony | Flow Body-only pose-sheet generation contract

Use the exact approved single-character reference image as the input image, not the existing eight-pose sheet. One image per action, not video. No weapon, FX, animation interpolation or paperdoll underpainting inferred. Keep generation cost under owner control. All new outputs remain ART HOLD until whole-motion review.

## Shared prefix (copy with exactly one action below)
Create ONE pixel-art pose strip with EXACTLY EIGHT distinct full-body poses of this SAME reference character, in a single horizontal row, chronological order from left to right. Use the identical white hair, face, dark teal outfit, body proportions, pixel size, colors, silhouette and southeast 45-degree three-quarter facing screen right. Keep the camera completely fixed and use the same native pixel grid across all poses. The character is unarmed: NO sword, other weapon, magic effect, text, labels or additional objects. Keep arms, hands, chest, pelvis and legs anatomically coherent, and preserve head identity while allowing natural head movement. Flat pure magenta #FF00FF backdrop with generous outer margins and equal-width pose slots; every silhouette must have a clear magenta gap from its neighbors, even hair and outstretched hands. Do not touch or overlap adjacent poses. Use hard square pixels, no gradients, blur, antialiasing, perspective changes, drop shadows or decoration. Align grounded feet to a shared horizontal baseline; explicitly raised feet are allowed only in specified airborne poses. Do not make eight copies of one pose. Draw full distinct key poses with readable motion, no cropping. Return just the sheet.

## RUN
In-place eight-frame running loop: 1 right foot front contact, left trailing; 2 compression; 3 passing pose; 4 flight/extension; 5 left foot front contact, right trailing; 6 compression; 7 passing pose; 8 flight/extension transitioning naturally back to pose 1. Opposite arm and leg rhythm, visible chest/pelvis rotation and restrained head bob. Keep the two strides distinct. Maintain common origin and facing, no screen travel. Candidate loop, 80ms each; airborne indices 3 and 7 (zero based) only if genuinely visible and reviewed.

## DAMAGE
Eight-frame unarmed recoil: 1 ready with tension; 2 sudden head/chest recoil; 3 shoulders retract and arms guard; 4 maximal backward weight shift with bent knees; 5 stabilizing step or weight shift; 6 torso returns; 7 guard recovers; 8 settled posture close to the reference. No blood, attacker, hit flash or weapon. Keep at least one foot grounded. Candidate one-shot ms: 80,70,90,130,100,100,90,140.

## DODGE
Eight-frame in-place evasive body animation, keeping original 45-degree screen-right view: 1 alert; 2 compress knees; 3 push off; 4 low airborne shift with clear raised feet; 5 low landing; 6 absorb impact; 7 straighten; 8 ready posture. Preserve recognizable proportions and hands; avoid flips or new objects. Use the common baseline and leave visible ground clearance in pose 4, no translation baked into world coordinates. Candidate one-shot ms: 80,100,80,100,100,100,110,130. Airborne index 3 only if reviewed.

## CAST
Eight-frame unarmed casting body performance: 1 alert; 2 raise hands toward chest; 3 gather hands; 4 open shoulders and focus; 5 extend hands with clear gesture; 6 hold the gesture with distinct weight transfer; 7 release and relax; 8 recover to ready. NO magic orb, particles, weapon, aura or glow: later effects remain independent. Candidate one-shot ms: 100,120,150,150,100,140,110,130.

## Intake
Save the original image without rescaling. Calibrate each sheet separately: source SHA256, dimensions, slot cuts, roots_x, pitch search range, reference_y, target_bottom_y. Do not reuse ATTACK8 calibration blindly. For flight, choose the target foot height only after reviewing ground contact. Extract -> inspect actual poses at 1x/4x -> pack with explicit SHA pins -> stage into motions/<action>/ -> native and ART review. Timings and phases are candidate defaults, not combat balance or damage authority. No automatic gameplay events.
