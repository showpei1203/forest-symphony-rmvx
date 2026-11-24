# Forest Symphony｜T-B R21｜2026-11-24｜三階真實 PixelLab TAUNT 8F／Godot 4.7.2 正式交接

## 1. 權威與範圍
- 本輪 T-B 怪物 TAUNT 美術量產，唯一改動分支 `feat/fs-pixellab-tb-monster-20261121`。依使用者最新「繼續」、`PIXELLAB_TB_CURRENT_HANDOFF.md`、正式 Roadmap、Failure Log、雲端素材規範及 GitHub/Drive 實際證據接續。不重裝工具、不回 VX，只使用 Godot 4.7.2。
- 已從私有 Bridge GitHub 正式來源重新讀取 AI_PC_CONTROL_TOOL_ROUTING_PROTOCOL、README、AGENTS、Handoff、工作流、Invoke-BridgeTask.ps1、四項 Skills fs-monster-evolution / fs-godot-testing / fs-handoff-qa / ai-pc-routing，並確認最新白名單。未宣稱 Windows 本機 Skills 已自動載入。
- GitHub 僅保存原始程式、Handoff/Failure；不提交任何 owner-private PixelLab PNG/GIF 至公開倉庫。私人美術、原始 Job 回傳與正式ZIP 存在 owner-only Google Drive。嚴禁觸動 main/T-A/T-C/FSBattle/ATB/ACT/Events 或原始 E:，無 Codex、無 Desktop Remote。
- 本輪完整原始上一版：[R20 正式 484-entry ZIP](https://drive.google.com/file/d/12Z3zyqKuRtIwqBAYs0MaBotcroQBlow6/view)，14,871,599 bytes，SHA256 `99ef8ab4e12239f32dfbf9573035b149834ac0bcd48243c09ff4b15b69a34b2a`；原始所有 PNG 依 SHA 逐檔保持不變。

## 2. M1｜真正三階 8F TAUNT [SOURCE PASS]
- 規格：霜晶狼 Glacier Jackal Pup 128×128、Crystal Wolf Guardian 160×160、Ancient Glacier Fenrir 192×192，固定東南 3/4 視角、四足一致、嘲諷時抬頭露齒、挺胸／前腳挑釁、F0/F7 exact original source，TAUNT **一次性、不循環**；與 ATTACK 跳撲、SKILL 冰晶魔法、STUN 失衡和 KO 倒地分開。
- 單階僅一次正式 PixelLab `animate-with-text-v3` POST，13? **實際每階回傳 9 個真 Provider 原始影格**，取樣選出 8 個來源鎖定 sprite slots，總計 27 個 original provider frames／24 exported slots；沒有靠程式假生成人物動作。Provider 用量依真實帳本合計 **11 generations**，不推估未知 USD 成本。

| 形態 | Job ID（真 Provider） | 實際 gens | 官方 Windows Issue／Actions | owner-private 原始 ZIP SHA |
|---|---|---:|---|---|
| Pup | `33061749-b39d-4c68-84d8-79b36a0af90f` | 2.0 | [#124 SUCCESS 45309925037](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45309925037) | [72,199B ZIP](https://drive.google.com/file/d/1Ys-YZlKfjJ3fl9Gaa208xm89KWxc0EJG/view) `f20cf6c2cc77392f2b64a9ceb3422dfbca1639dd68355a8b36edaf2f81e1362b` |
| Guardian | `38fcfa48-8b28-4aa5-905e-9b2428541fb8` | 4.0 | [#125 SUCCESS 45310189940](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45310189940) | [117,262B ZIP](https://drive.google.com/file/d/1MUWxF8e3vlWEYUO_tUTdydVgAQxs9L8Y/view) `d9c4c9c856a111e2890644d30b58328d969d01a76c65eb29929951aff10a5432` |
| Fenrir | `692feff1-d77d-4a00-9794-bf37d7d146fe` | 5.0 | [#126 SUCCESS 45310194554](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45310194554) | [222,636B ZIP](https://drive.google.com/file/d/1jm0aaKshEt0uu3bkaLIDqeL7QeJXMyqU/view) `89a3d9ec6d8bf8f07a2cd9aa4cb5fd6f5f55e282aa737e56033bef8d8811831d` |

- 三階各保存獨立 Job ID/Seed/Prompt/原始 provider response/paid ledger/每幀 PNG SHA。私人 Drive 上付費 Job 在初次 poll 前寫 journal，完整 raw Provider 回傳在任何 QA 前保存。POST 不自動重試；已完成 Stage1/2/3 **嚴禁再啟動付費工作**。
- R21 離線正式 PixelLab preflight [Issue #123](https://github.com/showpei1203/chatgpt-pc-bridge/issues/123) [Actions SUCCESS 45309733394](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45309733394)，三階 prompt 字數 473/476/477，完整 stage archive/schema/最後回報函式均於 0 paid generations 通過；extra `command` 負測 [#122](https://github.com/showpei1203/chatgpt-pc-bridge/issues/122) 正確拒絕。隔離 mock 組合完整 Godot 新 scene/manifest/108 clip/982 slot QA PASS；mock 只作離線測試，**沒有拿它當真實美術交付**。
- 三階真實來源 [24 幀 Contact](https://drive.google.com/file/d/1imIE-pINBOwxTLiMUJn16aZLLS22lnkh/view)｜[Pup GIF](https://drive.google.com/file/d/1xBGFRBtGVbnjq_Vx5NsJe0doKKN87x6i/view)｜[Guardian GIF](https://drive.google.com/file/d/1rFUg8gAFjtIx0TauusZroeuOw8x1KHLB/view)｜[Fenrir GIF](https://drive.google.com/file/d/1ZThC2eAhdUF0zqXsU84lUquXpGv29Yq4/view)。目視 Stage2 露齒更明確，Stage1/Stage3 挑釁幅度較含蓄；**OWNER_ART_REVIEW_PENDING**，不保證美術語意完美。
- 真三階 M1 [500-entry／15,776,632-byte private source ZIP](https://drive.google.com/file/d/1ANDr3iSLtvx5gM_qJefxS2qje4aIbeoy/view)，SHA256 `b2d5e56798a2e0f01773bd1ff95178ab14a48d46689bf4a347f3908e8ced5580`；M1 技術來源/CRC/舊 PNG byte equality/108 clips/982 slots PASS，native gate 初始 `NATIVE_NOT_RUN`。

## 3. M2｜官方 Windows Godot 4.7.2 獨立 TAUNT 原生測試 [PASS]
- 專屬窄權限 Bridge `fs_tb_r21_taunt_native`，Issue 唯一允許 `{"schema":1,"task":"fs_tb_r21_taunt_native"}`。Windows 安裝的官方 Godot 4.7.2 僅執行 hash-pinned 原始 500-entry M1 ZIP 之 editor import + `res://tests/test_tb21_frost_taunt_native.gd`；獨立檢查三階 8F Texture/Atlas/正確狀態/`not get_animation_loop("taunt")`，記錄真實原生 QA 並清除 run-specific TEMP。無 PixelLab、Codex、Desktop Remote。
- 故意帶未核准欄位的 [native negative #127](https://github.com/showpei1203/chatgpt-pc-bridge/issues/127) 正確拒絕，預期 FAILED Actions 即安全 PASS。
- **真正 native [Issue #128 Actions 45310921904 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45310921904)**，Godot `4.7.2.stable.official.ed1daf0bf` EditorExitCode=0 / ArtTestExitCode=0，精確標記 `FS_TB_R21_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=102 evolutions=6 clips=108 frames=982 frost_taunt=3`。
- [真正 Windows QA log](https://drive.google.com/file/d/11PWmkXPahDdBctUaYGTl8zWV4kVAeecs/view)，607 bytes SHA256 `7eec4cb2d7716f0a2bc3910502d68129dcdeead7b9230df57f39f745953df7b5`；已讀回確認引擎版本、M1 SHA、500 entries、108 clips/982 slots 與 11 generations。獨立 art-only native PASS，**不等於 GPU 實機戰鬥演出、正式戰鬥／ATB／ACT／存讀檔已整合**。

## 4. M3｜最終原始雲端保存／WRITE→READBACK [PASS]
- [**R21 正式 owner-private 502-entry ZIP／15,778,189 bytes**](https://drive.google.com/file/d/1OZvzPtYRRdOyVBVjM2K6tq-Fh8zaj45V/view)，SHA256 `c023670d8d2f0ac2b4045af0edf46edaf8ea52b5fed429254092942ca40563f0`。[正式 Release Proof](https://drive.google.com/file/d/1m8eCQW4a278RB8DgSWCTyA0s2gugxoc5/view)。保存原 R20 PNG、三階新 TAUNT 真 PixelLab atlas、原始三個付費 Provider ZIP、GIF/Contact、完整 Godot scene/native script、真正原生 log/evidence/正式 manifest。
- Google Drive 原始 owner-only folder `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`，live metadata `shared=false`、唯一 `user:owner`。**上傳後重新完整 raw authenticated ZIP 下載**並與本地原始正式檔 bit-for-bit equality；502 entries CRC PASS、完整 SHA、原始 R20 所有 PNG byte match、3 原始 provider ZIP、原生 log SHA、3 TAUNT 非循環及真成本 2/4/5 全 PASS。原生與 Promotion 額外 0 generations。

## 5. QA gates、量產狀態、下一階段
| Gate | Status |
|---|---|
| 真 PixelLab 原始 jobs/Prompt/Seed/素材來源/報告 11 generations | PASS |
| 8F 三階 Atlas/alpha/cell/來源 SHA 與 R20 原版 PNG 不變 | PASS |
| 官方 Windows Godot 4.7.2 獨立三階 one-shot native | PASS |
| Cloud owner-only 502-file SHA/CRC/權限/全包 readback | PASS |
| 1× 人工 TAUNT 動作語意和造型美術 | **AWAIT_USER_ART** |
| 非 headless GPU 與正式 FSBattle/ATB/ACT/事件/存檔整合 | **NOT_RUN_ART_ONLY** |

- T-B 現有 **3 家族／9 形態／102 base action atlases + 6 EVO FX =108 total clips／982 frame slots**；霜晶狼每階達 **10/12 動作類型**。剩餘 **CHARGE 與 RELEASE** 兩類×三階=6組真動作；別把 TAUNT 判成攻擊或暈眩。
- **NEXT R22：三階真 PixelLab CHARGE 8F（能量聚集、停在預備施放，絕不提前發射；與最終 RELEASE 另階分開）**。先沿用已批准 R21 502-file 正式來源 SHA 鎖定，先離線完整帳本/封包/一筆最多一次付費 POST；後續 Godot472 separate native、私人 Drive full readback、owner 1× ART gate。**禁止重送已付費 R17 Guard/R18 RUN/R19 SKILL/R20 STUN/R21 TAUNT。**

[CURRENT_HANDOFF](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_CURRENT_HANDOFF.md)｜[R21 Failure Log](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_R21_FAILURE_LOG_20261124.md)｜[R21 producer](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/produce_tb21_taunt_stage.py)｜[R21 M1 builder](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/build_tb21_taunt_m1.py)｜[R21 native promoter](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/promote_tb21_taunt_native.py)