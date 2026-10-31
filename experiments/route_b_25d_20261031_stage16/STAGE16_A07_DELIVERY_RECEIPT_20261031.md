# Stage16 A07 authenticated private delivery and cold QA receipt
2026-10-31 | ControlNet ADE20K material recognition technical PASS | Ground3 Art FAIL | Godot/VX NOT RUN | Formal Seal NO.

Private cloud folder: https://drive.google.com/drive/folders/1_qDs1rgr78yl-EV8mBEyyqqLGgRGE1Jr
Full private A07 ZIP: https://drive.google.com/file/d/16pKIWfLgB-IXMxlVEM2nTNOV4tTaSfbD/view
Actual A07 1x comparison: https://drive.google.com/file/d/1WRYfPlDg91R-CNjvY7IXs49oX4wQaC-j/view
Original Ground3 vs A05 R3 vs A07 native 32px zoom: https://drive.google.com/file/d/113FmJ4eUlSl2M1Mp_d55zS0K_52FP2xo/view
A07 original RGB gameplay-sized TEST output: https://drive.google.com/file/d/1J1HVei9B-rwaXOMk_sO9hxJowViffTtE/view
Private Handoff: https://drive.google.com/file/d/1ZDIFpXzCFHdVN61zTnj5cFIS0YmPajt6/view
Failure classes: https://drive.google.com/file/d/1VkZnycYazqPS1fpIVmQGiLjTM7LJ1uTt/view
Raw QA report: https://drive.google.com/file/d/1XaW5293C8L6Osd9JwA6VSCwlFCHyxBO7/view

ZIP FS_STAGE16_A07_CONTROLNET_SEMANTIC_PRIVATE_20261031.zip, size 2,006,161 bytes, SHA256 f053cadcbecc72ed7c7b9a0c65dc16a44111f854a11f05046aeda1fa05a851b9, total 30 entries including manifest; 29/29 source SHA256 matched from cold extract, ZIP CRC PASS and independent Python verifier PASS. Google Drive for Desktop mounted-copy exact bytes SHA256 readback PASS; live Drive connector server list verifies ZIP, MD, image and QA files exist.

Controls: 384x384 source, 28,818 road pixels; exact no-change outside mask; one actual SD1.5 ControlNet v1.1 seg model CPU 14-step generated independent PNG and 96.29% sand-like RGB heuristic. Dark brown flat road and two invented white boulders -> Ground3 art FAIL.
Large model safetensors SHA256 acd4dd3df2da2f1f2b9dd00f4504cc0d98b20afb608e25f1789a95c0ccdba14a (722,601,100 bytes) retained locally, not included in ZIP or GitHub. Source full Ground3 composite likewise private and not included.

NO False Seal: MODEL_LEVEL_SEMANTICS_PASS / MASK_PIXEL_ISOLATION_PASS / ART_FAIL / VX_NOT_RUN / FORMAL_SEAL_NO.