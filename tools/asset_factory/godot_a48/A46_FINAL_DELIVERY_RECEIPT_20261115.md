# Forest Symphony A46 V2｜交付驗證與自動美術攔截紀錄
2026-11-15

## 核心交付
- A46 修正已知 A45 腰部剪接：12 幀 Body/Weapon/FX；腰部／骨盆恢復使用 A62 核准的連續紋理，加入 ±1px 的上半身起手與收招位移。
- A45 已知問題 F06–F08 由新腰部檢查正確判為 FAIL；A62 和 A46 V2 在來源圖與 Godot 原生截圖均 PASS。
- V2 F6 劍尖命中錨點 (30,9)，同一 AnimationPlayer 控制 Body/Weapon/FX 和命中事件，0.55s 命中與 70ms Hitstop。
- Godot 4.7.2 原生 OpenGL RX 6700 XT 12／12 幀零圖像差異、真正練習靶 HP100→75→50，範圍與取消／2x 播放防重複傷害全部 PASS。
- 來源圖集與產線腳本可再生並 SHA 一致；A46 的新版本不會破壞 A42–A45 舊素材。
- A46 **不是** 完整骨架系統，屬修復過的像素姿勢鏈。肩胸轉體僅限 1px，整體 **ART HOLD**；真正完整 FS ATB 戰鬥系統仍 **NOT RUN**。

## 直接檢視和使用
- **正式工程 ZIP**：https://drive.google.com/file/d/1AjzLvSgwOaH7hq8i3qDFg6VNvU-5tSFp/view
- **A46 原生 Godot 攻擊動畫 GIF**：https://drive.google.com/file/d/1ryitfPsOTDdpquY0LvPO0RHJLC6xjwjW/view
- **A45 與 A46 V2 完整 12 幀對照**：https://drive.google.com/file/d/1ieZ_b5fBjhJPBrh2o_he6xD-Ho9uQO6-/view
- **A46 文字 Handoff**：https://drive.google.com/file/d/1O8i3JxHOQ5esFv89n2kboevXEGhM1CSq/view
- **GitHub 專案**：showpei1203/forest-symphony-rmvx，branch feat/fs-asset-factory-v1-20261107，子目錄 tools/asset_factory/godot_a46

## 最終可核對數值
- ZIP：FS_A46_GODOT_CONNECTED_TORSO_NATIVE_GPU_PASS_ART_HOLD_20261115.zip
- 213 files，811,678 bytes，CRC PASS。
- SHA256：7134ccaeb719cc198abd589fae67fbfe86e15cfd07fd61f66ceff397801f14c9。
- ZIP 冷解壓逐 SHA：212／212 個來源檔零不符。
- 從 ZIP 重新生成 A46 V1、V2：三圖集 SHA 一致。
- 從 ZIP 原生 Godot Editor import／12 幀 GPU／命中扣血 QA：全部 EXIT 0。
- A62 waist gate EXIT0；A45 EXIT1（預期的負例）；A46 V2 EXIT0，Godot PNG 同步 PASS。
- QA 原始紀錄 `qa/A46_ZIP_COLD_QA_RECEIPT.json` 及 `qa/A46_NATIVE_COLD_QA_RESULT.json`，在同名私人 Drive 工程資料夾。
- 私人 Drive ZIP owner-only，禁止公開原始素材。
- 遠端施工的暫存用 C 槽複本皆為一次性，正式工程保留 Drive／GitHub，E 槽 RPG Maker VX 原始檔未改。
