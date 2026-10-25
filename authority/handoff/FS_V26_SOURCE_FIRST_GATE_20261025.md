# FS v2.6 Source-first gate

Private candidate ZIP: https://drive.google.com/file/d/1ktcJzp-AMashOsvAXaZ2Q-iBw_FXzsYV/view

SHA256: 05c4e1ee82707b7d787f5ab48ffdd4da0cc9e93d35a794478258540761110ebc. 6,038,517 bytes, 99 entries.

Technical candidate gate PASS. Formal release gate intentionally BLOCKED: three art assets pending, scene human approval pending, native screenshot equality evidence missing.

Seven mutation tests detected: ground hash, stale Game.ini title, missing PAR, duplicated instance, visible alpha at source border, one PAR pixel alteration, and Ground alpha contamination. Fixed an actual QA error in PIL RGBA difference inspection by checking all four difference channels independently. Do not treat pixel recomposition as proof of artistic source completeness.

The complete executable validators and test evidence are in the private Drive ZIP. No restricted sprites are in this public authority document. Formal FS sealed baseline and prior v2.1, v2.2 and v2.3.3 packages remain unchanged.

Next: unobstructed real VX native screenshots and full camera/actor masking and per-channel pixel comparison; human source/scene approval before release.