# A65-V1 ACTUAL PIXELLAB GENERATION HANDOFF - 2026-11-02

## Tested result
PixelLab v3 job 409b4884-2936-446f-abff-cdad2d78afe0 generated three real transparent 48x48 frames, from A62 APPROVED F0 and three full 18-joint pose data sets. Source reference ACTOR native 32px three-frame animation was used as OFFLINE motion-analysis input but NOT directly sent to v3 as a second visual image. This limitation must not be hidden.
Original reference SHA 992f32546a4f2806cb241efc0aab7fe0e71ca8c6561af99297e8635bcea3e515
A62 source SHA a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba
Pixel output background-composited pixel differences F0/F1=312, F0/F2=1, F1/F2=312. F0 versus approved A62 input differ by 6 pixels.
V1 technical distinct-frame gate FAIL because F2 collapses to F0, despite differing F2 source skeleton. F1 generated head, shoulder, and arm movement, but no art success is assumed. A62 run user PASS remains SEALED. Old A65 C2/C3 pixel scanline approach USER REJECTED, not a pass. A63 Waiting/A64 Critical not user accepted.
No separate v3 direct original ACTOR input; to truly drive motion from original source, use PixelLab editor Animate with Skeleton / Animation to animation: import source original ACTOR 3 PNG frames as animation, Set animation to estimate its skeletons, set accepted A62 F0 as Reference and correct 3 frame full-body skeletons. Then only generate another controlled job after actual source-driven joints pass human/camera/limb checks. Do not blind retry the same prompt. See https://www.pixellab.ai/docs/tools/animate-with-skeleton .
Retain all original FX separate: weak F0, strongest F1, none F2. No native VX testing by user request, no original project modification, no uncontrolled paid retry.
## Evidence files
- A65_V1_PIXELLAB_PROVIDER_F0.png
- A65_V1_PIXELLAB_PROVIDER_F1.png
- A65_V1_PIXELLAB_PROVIDER_F2.png
- A65_V1_PIXELLAB_REAL_3FRAME_144x48.png
- A65_V1_REAL_PIXELLAB_BODY_8X.gif
- A65_V1_REAL_PIXELLAB_WITH_SEPARATE_FX_8X.gif
- A65_V1_ORIGINAL_C2FAIL_NEW_SYNCHRONIZED.gif
- A65_V1_REAL_ORIGINAL_A62_FAILED_C2_NEW_CONTACT.png
- A65_V1_REAL_PIXEL_LAB_QA.json
- A65_V1_PIXEL_LAB_SINGLE_JOB_LOCK.json
## Permanent original-source folders
https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe
