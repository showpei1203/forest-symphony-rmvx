# Stage16 A08 Delivery Receipt (2026-10-31)
**Formal status: REAL COMBINED CONDITIONAL PNG PASS; GROUND3 ART FAIL; Godot NOT RUN; RPG Maker VX native NOT RUN; Formal Seal NO.**

## Authenticated private Drive files
Folder: https://drive.google.com/drive/folders/1GUw7uY82LbJ7YG171HVnJ4-remVRafsl
ZIP: https://drive.google.com/file/d/1-XWxiB_7ffgbk4qR6Irt3EPCd31LmEaR/view
Handoff: https://drive.google.com/file/d/1Omct3qC_WeeE33Xf62_nU8pYYup3LD0V/view
Failure register: https://drive.google.com/file/d/1ZwlD2DUk8Dy4JM1Ynw65t5xdI4pJhLF0/view
A07 vs A08 real full-resolution comparison: https://drive.google.com/file/d/10AVMw-eIiqt5iVR8mWFbhhSbju8WGjEg/view
Ground3 original 32px vs A07/A08 nearest-neighbor 8x: https://drive.google.com/file/d/1a0JumsjIxDoeeI19zBhpqsybOL7P_ceF/view
A08 new RGB copy PNG: https://drive.google.com/file/d/1hgL1t3FJGB64LPJvaGIfYvUSIHR0MN0n/view
Pixel QA: https://drive.google.com/file/d/1sLboD6fjsmKtNEDyrtI0n3eCC3YLOgys/view

## Independent integrity
ZIP `FS_STAGE16_A08_COMBINED_CONTROL_PRIVATE_20261031.zip`, size 1,810,658 bytes, sha256 9525f6b7573e655b734e6c4f0bce1d8349da803be4647328d87c46f67b71a92b. ZIP CRC PASS, extracted 20/20 source hashes matched, manifest 21st entry, independently re-executed offline Python QA from cold unpack PASS. Private mounted Google Drive copies 8/8 original SHA256 readback PASS. Live Google Drive connector server file listing confirms final ZIP/docs/images.

## Strict gate
CPU combined SD1.5 + ControlNet Segmentation + IPAdapter workflow successfully generated real 384x384 original source PNG. Same 28,818 road pixels changed, outside 0. Mean road RGB moved closer to 48px Ground3 reference but cobble/stone artifacts became worse; source-ground3 aesthetic is FAIL, no user signoff. Native A08 source PNG SHA256 44da9c703de1bba22985510a5d1ff342c0f67e68388ab80231133cd36083620a. No native VX/engine testing and no formal production seal.