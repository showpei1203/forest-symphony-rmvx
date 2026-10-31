# Stage16 A09 Private Delivery Receipt — 2026-10-31
**Status: VAE SOURCE AUDIT PASS (lossy) / BASE LOW-DENOISE SAMPLER PASS but gray-road ART FAIL / combined ControlNet+IPAdapter low-denoise two native crashes / Formal Seal NO.**

## Private Google Drive confirmed by live connector
Folder https://drive.google.com/drive/folders/1As87Ljo8DUxy5wKfn2wItFBn18hzhL8W
Complete ZIP https://drive.google.com/file/d/1R1ku7DFwYk92hvmB4c7I2vl88pdI84J8/view
Handoff https://drive.google.com/file/d/1cfMZAtDa9049kaP1nSeQleym5InP4XUE/view
Failure register https://drive.google.com/file/d/1XYq6ygILpYkqT7gSYyJ37_XiVbxedIre/view
Original 32px four-method visual comparison https://drive.google.com/file/d/1RdIWRK3LXx39Y4Te-tMqHCLqhjhpF7v4/view
Three full 384px images comparison https://drive.google.com/file/d/1xDCejQTfJNXJJ2cvpGKsjVSFTiO7A-8r/view
Ground3 original 48px vs native VAE image https://drive.google.com/file/d/1UGk2bq7Uthqvo5HN5gR9jsDxhudYzuyE/view
Pixel/scale metrics https://drive.google.com/file/d/1mwmDhnAMBtIKCdiNwKLWFcNdM1lgZu0w/view

## Cold backup
ZIP: FS_STAGE16_A09_TEXTURE_SCALE_PRIVATE_20261031.zip, bytes 1,531,969, SHA256 099f027b7aa115b89d81ad7689f96fe7f6fe546e9ee1383c217baa2ce91c70d5. ZIP CRC PASS; 32 entries total, 31/31 original SHA256 validated against fresh cold extraction; 8/8 G Drive Desktop mounted copies SHA256 re-read PASS. Live Drive connector independently lists exact uploaded files and sizes.
Contains original ground3 48px crop only, synthetic 384px material input, VAE output, base model gray-road PNG, Python generation and validation scripts, the combined graph, two failure JSON records, Windows crash events, QA and cross-comparison figures. Excludes complete Ground3 source and multi-GB checkpoints.

## Failure classes
Comfy combined graph enqueued but no valid new native image on either denoise=.28 trial; Windows torch_cpu.dll access violations 0xc0000005. Isolated VAE 384px and basic SD1.5 low-denoise 6-step output both passed, narrowing but not conclusively determining interaction cause.
Original 48px Ground3 direct VAE roundtrip RGB MAE 22.5049, PSNR 19.2745dB; no source-grain fidelity PASS. Minimal sampler masked road becomes flat gray; not suitable for game. Masked preservation strategy corrected from VAEEncodeForInpaint to VAEEncode+SetLatentNoiseMask, but corrected combined graph also crashed.
Packaging regression during first local run: Windows Python default CP950 could not decode UTF-8 error JSON. Fixed by explicit encoding='utf8' in JSON reads; final ZIP CRC/SHA readback passed. All next QA scripts should explicitly read/write UTF-8.

## Final
Stage16 A09: Engineering research partial PASS, actual full combined low-denoise FAIL_NATIVE_CRASH; ART FAIL; 544×416 true Ground NOT RUN; Godot GPU NOT RUN; native VX Game.exe NOT RUN; Formal Seal NO.
Next Stage A10 must test pixel-space texture preservation with non-donor material stats or a model deliberately capable of pixel-level ground detail, and separate any CPU compatibility research from art generation. No same-graph blind retry.