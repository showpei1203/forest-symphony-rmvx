# T-A Failure Log / 2026-11-21

## R3 Native GPU evidence and blocking gates

- TA-04 R1 'no private Godot GPU proof': **RESOLVED for per-frame native GPU rendering**. 24 actual source frames imported and rendered in official Godot 4.7.2; 24/24 PNG generated, EXIT0. **Still NOT RUN: full original private continuous gameplay loop/ATB hit-time integration.** Owner-private QA ZIP https://drive.google.com/file/d/1iNuBTTvC0Zyfs3yHp1Lovobu8vnMU0CF/view
- TA-08 FX color delta: 59 RGB pixels across ATTACK F5-F9 differ from CPU Pillow composite (mainly alpha blend differences), 0 alpha mismatches; nonblocking for silhouette, flag for 1× art inspection. No unverified claim of zero pixel difference.
- TA-09 official engine retrieval: earlier download from GitHub in local container failed due outbound network restriction. Switched strategy to **public GitHub Actions engine-only artifact**, downloaded through authorized connector, no user PC changes. One strategy change, **RESOLVED**.
- Remaining blocking art: A35 RUN F6/F7 original defect, new V3 RUN not yet generated, 4 optical-flow frames awaiting motion art QA. Zero frame-only cosmetic repair loops. Status ART HOLD, not an engine blockage.

---

## R2 後續驗證及阻斷變化（下面保留 R1 歷史問題表）

- TA-02 R1 空白 RUN Weapon：**幾何問題已解除**。R2 已建立 A52 真實來源剛性手部對位的 12 幀 Weapon，12/12 與 Body alpha 相接、12/12 無裁切，像素 SHA 可重製。**整體美術／持劍姿勢仍 ART HOLD，未完成原圖原生 Godot 動態驗收**。
- TA-07 透明武器錯誤通行：Godot rig 現新增 Body/Weapon 可見像素驗證，4.7.2 headless CI PASS（mock images）。https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44833193171
- TA-01 原 A35 RUN F6/F7 腿部缺陷：**未修，阻斷美術 PASS**。
- TA-03 無可呼叫 PixelLab V3、TA-04 私人真正 GPU 原生 1×、TA-05 A54 最新權威：**仍待補，不能冒稱 PASS**。
- 工具第一次本地 self-test 曾因 grayscale overlap Image 沒有 A channel 失敗；已改用依圖像頻道取 alpha / histogram 計數，重新跑 12/12 synthetic + 12/12 真來源自動檢查皆 PASS。紀錄 1 輪，未在細節無限迴圈。
- 新增 PixelLab 付費 0，新 job NONE；已通過的 A52 ATTACK 不重做。

---
Only record genuine issues; never conflate construction QA with ART PASS.

| ID | Gate | Severity | Finding | Attempts | Next macro action |
| --- | --- | --- | --- | --- | --- |
| TA-01 | ART | BLOCKER | Old A35 RUN frame F6/F7 pose previously on ART HOLD; optical flow preserving those poses cannot eliminate source pose drift | 0 new repair iterations | Rebuild one **entire** RUN12 by PixelLab Text V3 with reference identity, use Skeleton V3 keyed gait if needed |
| TA-02 | ART | BLOCKER | RUN candidate independent Weapon/FX atlases are all-transparent **placeholders**; no sword-to-hand contact proved during run | 0 | Full RUN12 complete equipped sword layer at 45° view |
| TA-03 | MODEL | BLOCKER | No PixelLab paid endpoint available to this agent; fresh Text V3/Skeleton V3 generation NOT RUN; additional cost 0 | 0 | Obtain connected PixelLab provider authority or run same exact source in authorized provider tool |
| TA-04 | NATIVE ART | BLOCKER | New native GitHub CI has synthetic memory atlas proof, not original Drive asset runtime/GPU screenshot | 0 | Secure private, authorized Godot asset staging for 1× screenshot/video and contact play |
| TA-05 | SOURCE | NOTICE | A54 updated handoff not located by this round's Drive/GitHub name/path searches | 0 | Confirm A54 authoritative link before replacing legacy approved baselines |
| TA-06 | ENGINE | RESOLVED | 12-frame rig timing/3-layer structure needed independent validation; added Godot 4.7.2 CI; first run success | 1 | Keep CI green after preview scene and do full original-art validation later |

Nonblocking isolated pixels/soft shadow tuning: 0 cycles; no endless single-frame loop. The demonstrated initial RUN frame count and technical 256×192 atlas check are not art acceptance.
