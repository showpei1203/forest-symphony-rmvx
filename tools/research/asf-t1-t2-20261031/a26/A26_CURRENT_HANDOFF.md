# A26 — Real PMD approved concept Sprite Sheets + FS proportional repair (2026-11-01)

PMD A25 user approved approved design used as immutable first frame for PixelLab native animation.
Generated ACTUAL 5-frame Idle and Walk using /v2/animate-with-text-v3, no repeats.
PMD Idle RAW animation includes unacceptable invented tail/black particles. FAIL. A deterministic source-locked cleanup masks all non-source silhouette pixels beyond 2px, exporting corrected first candidate; still requires user art review.
PMD Walk real five-frame animation has mild leg motion, no mask cleanup; requires user art review.
Native cell candidate frames exported Idle 32x40 x5 and Walk 40x40 x5. XML NOT modified; PMD 8 orientations and native original durations NOT verified, Attack/Cast/Hurt/Death remain ungenerated.
FS first reference-based 64x64 attempt failed to restore 1:1 proportions and clipped feet; job f40e6fc4-5be0-4848-9a83-52c700309716.
FS SECOND Pixen test uses REAL 32x32 actor frame padded inside 40x40 and exact 1:1 head/body prompt; job 0dec7a58-fcbc-44a2-a826-46a751a75daf, completed. Output 40x40 bbox (9,4,32,38) no bottom-edge alpha, and 64x64 centered preview. USER ART GATE REQUIRED.
Technical integration is NOT formal PASS. Do not treat any candidate as approved 6-action sheets. Credits and job cost in A26_QA_AND_USAGE.json.
Authoritative source originals and all PMD XML/Offsets/Shadow and FS existing sealed files remain untouched.
Private PNG and GIF stay on user's E drive. GitHub/Drive contain only text, QA and source scripts, avoiding publication of 3rd party sprites.
