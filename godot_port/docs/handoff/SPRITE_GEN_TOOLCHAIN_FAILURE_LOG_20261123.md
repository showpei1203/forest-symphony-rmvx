# FS Sprite-gen Toolchain | Failure / Prevention Log | 2026-11-23

- Expected security FAIL #107: caller submitted third JSON field command. Bridge refused before any install, PASS for allowlist protection.
- First isolated FS branch creation call returned RemoteProtocolError / server disconnected; readback showed no branch; retry succeeded. No data lost.
- Initial tooling-document create_file client-side JS template syntax error from unescaped markdown backticks; no GitHub write occurred; corrected text and committed document successfully.
- Upstream version drift: stale public web snapshot described older v1.58.0 / Python 3.10 while live pinned GitHub source has v4.3.0 / Python >=3.11 / Pillow 13. The exact GitHub SHA and pyproject SKILL take precedence; Windows installation reports Python 3.11.0 and v4.3.0.
- Existing T-A R23 source-visible layers have missing hidden underpaint; sprite-gen curation, compression or scaling CANNOT repair missing independently poseable artwork. ART HOLD unchanged.
- No evidence of Godot 4.7.2 execution of the newly authored importer at time of initial report; status NOT_RUN. Do not inherit older unrelated T-B native markers.
- External source dependencies are a fixed SHA repository with PyPI constrained Pillow/NumPy/setuptools ranges, NOT fully hashed transitive lock. For future supply-chain hardening, add a requirements lock with hashes before updating/upgrading.
- No reported inadvertent game source changes or paid AI API use, per Bridge run.
