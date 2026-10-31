# A18 Native Ground API Benchmark — private reproducible runbook

Requirements: Python 3.11, Pillow, NumPy. `preflight` uses no network, secrets or paid calls.

```
python a18_native_trial.py preflight --provider pixellab_pro
python a18_native_trial.py preflight --provider pixellab_pixen
python a18_native_trial.py preflight --provider retro_pro
python test_a18_offline.py
```

`A18_MOCK_FIXTURE_NOT_GENERATED.png` and its 32px audit are unit-test fixtures, **not new model art**.

For a future *separately approved* first account-backed call, the user should enter their PixelLab token into the local `PIXELLAB_API_KEY` environment variable without placing it in ChatGPT, commits or plaintext artifacts. The implementation will first call the no-cost account balance endpoint and then submit at most one Pro image-generation request. The user must specifically approve any credits or charges; public cost estimates can change. Only then:

```
python a18_native_trial.py run --provider pixellab_pro --approve-paid --max-cost-usd 0.20
```

`--max-cost-usd` compares against a public-cost estimate, **not a provider hard cap**. Do not execute this command on a shared or production machine without explicit authorization. Retro live code remains intentionally blocked until style/cost readback has been added. A successful response still needs actual PNG provenance and native human art acceptance, not just format checks.

To inspect a real provider output (not a resize):

```
python a18_native_trial.py validate --file A18_ACTUAL_pixellab_pro_NATIVE128_MODEL_ORIGINAL.png --provider pixellab_pro
```

Do not replace the A10–A17 formal baseline, do not bypass `art=NOT_TESTED`, and do not generate PAR until an authentic Ground image has passed the visual gate.
