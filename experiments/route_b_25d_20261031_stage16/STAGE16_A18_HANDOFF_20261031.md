# Forest Symphony Stage 16 A18 — Native Pixel Provider Integration Gate

Date: 2026-10-31. **Verified input provenance PASS / offline client and validator PASS / PixelLab native generation NOT RUN (no authenticated API token or paid authorization) / Retro Diffusion NOT RUN / Ground3 art NOT TESTED / Godot NOT RUN / native RPG Maker VX NOT RUN / Formal Seal NO.**

## Authority preserved

The last genuinely executed model test was A17, pretrained PXG-Tiny, whose two 16×16 originals succeeded but were far too crude for Ground3. A16's high-resolution generic output failed the native pixel-art gate. No production Forest Symphony Ground, PAR, collision, Game.exe, or previous stage baseline has been changed. Avoid using synthetic or mock outputs as vendor results.

## Original inputs recovered from verified private source archives

- A10 Ground3 grass-only native 64×64 crop: `A10_GROUND3_GRASS_SOURCE_64.png`, SHA256 `b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407`.
- A10 Ground3 sand-only native 48×48 crop: `A10_GROUND3_SAND_SOURCE_48.png`, SHA256 `ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb`.
- These are genuine PRIVATE user source reference crops, not newly generated images. This private ZIP may contain the crops, but public GitHub must not include their binary bytes.

## Research and corrected API assumptions

[PixelLab official v2 API](https://api.pixellab.ai/v2/docs): `POST /create-image-pixen` fast direct pixel generation; `POST /generate-image-v2` stronger model with optional style image; Pro calls are asynchronous and support `GET /background-jobs/{id}`. Bearer token is required. PixelLab's own [Free trial page](https://www.pixellab.ai/) lists 40 quick generations plus five daily slower ones after that, ordinary images up to 200×200, **API Access**, but **no map tools**. Free trial usability is **not** the same as confirmed user-account token or remaining credits; no session verified. Different official pages describe Pixen upper limits as 512 vs 768; therefore do not promise 544×416 direct native output until an authenticated capability check, or an actual response, confirms it.

The [PixelLab price table](https://www.pixellab.ai/pixellab-api) lists a small per-image estimate for Pixen and a larger estimate for Pro; amounts can change. The offline `--max-cost-usd` argument is a *local estimate guard*, NOT a hard server spending cap. Actual paid generation needs explicit user consent and account verification.

[Retro Diffusion official API](https://github.com/Retro-Diffusion/api-examples) has a new v2 style selector, credit preflight, and an `X-RD-Token` authorization. RD Pro topdown is an appropriate style candidate with a smaller maximum native canvas (official style catalog is authoritative). **Retro inferences are intentionally disabled** in our script until style selection and free cost-estimate response are authenticated; no calls were made.

## Actual completed technical work

- Authored a provider-agnostic `a18_native_trial.py` with three source-documented payload plans: `pixellab_pro` (128×128 with original Ground3 grass style image), `pixellab_pixen` (128×128 no-reference baseline), and `retro_pro` (RD Pro top-down, 128×128, 1 image, fixed seed). Each `preflight` writes a redacted, verifiable DRY_RUN manifest without network access or charging.
- Prevalidated the original source dimensions and SHA256. Defined 128×128 **exact native output gate**: model result must be genuine PNG RGB, RGBA or indexed P, returned at 128×128 as-is; no up/downscaling or synthesized substitute accepted.
- Added provenance receipt for a future authenticated response, byte SHA256, background-job polling, no raw tokens in logs, 32px native NEAREST×8 three-way art comparison, and explicit human verification for botanical shape, natural soil boundaries, pixel crispness, and exclusion of standing PAR objects.
- Five offline unit tests PASS: exact reference provenance, three no-network dry runs, paid-request approval gate before any API call, PNG decode/size/empty-response rejection, and a 32px visual auditor that **never** marks aesthetic PASS. One marked `MOCK_FIXTURE_NOT_GENERATED` exercises only the validators; it must NOT be presented as PixelLab image output.
- No PixelLab or Retro paid generation and no new vendor-generated PNG. Any claim of actual provider art PASS at this stage is false.

## Gates and next action

| Gate | Result |
|---|---|
| Original Ground3 grass/sand bytes recovered and cryptographic hash checked | PASS |
| Provider request drafting, 5 offline tests and test PNG structural validation | PASS |
| Authenticated PixelLab account/token and remaining credit check | NOT RUN AUTH |
| Actual PixelLab / Retro native 128×128 generation | NOT RUN AUTH |
| Ground3 human aesthetic comparison | NOT TESTED |
| 544×416 native source model output | NOT RUN |
| PAR, Godot, VX Game.exe, collision, Formal Seal | NOT RUN / NO |

**Required external prerequisite:** user securely connects a PixelLab account token in the local execution environment and explicitly authorizes the first possible credit-consuming call. Never ask the user to paste the token into a chat. The preflight scripts are ready for a single authorized, limited experiment, not an indefinite background task. PixelLab account settings and the official free-trial option are the preferred starting points.

Once authorized: first perform only `GET /balance` and schema check, then at most one 128×128 actual pixel model response. No follow-up spending until exact native 32px review. A18 does not alter FS formal baseline.
