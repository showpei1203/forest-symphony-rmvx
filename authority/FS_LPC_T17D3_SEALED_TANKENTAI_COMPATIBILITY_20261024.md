# Forest Symphony Toolchain T17D-3｜已封版 Tankentai v0.6 整合契約（唯讀）

日期：2026-10-24

**狀態：METADATA / FORMAT COMPATIBLE；FORMAL BINARY INTEGRATION = PENDING。**

## 來源
正式官方：
- Tankentai v0.6 Formal seal：https://github.com/showpei1203/tankentai-sbs-godot/blob/main/authority/LPC_MILITARY_V06_FORMAL_SEAL_20260826.md ，2026-08-26 FORMAL PASS / SEALED。
- v0.6 recipes：https://github.com/showpei1203/tankentai-sbs-godot/blob/main/authority/LPC_MILITARY_EQUIPMENT_RECIPES_V0_6_20260825.md 。
- v0.6 sealed complete binary `TSG_LPC_MILITARY_V06_FULL_VISUAL_ARROW_FACING_FIX_HANDOFF_20260826.zip`，SHA256 `b5420632efa5c7abff23bff1686c9edab97ba6eea055aef2729574fb7255610b`，Drive ID `1u7I2mYpW7D7ddN1eNE66CvUct-gieJZj`。

## 封版對照
| 項目 | TSG v0.6 正式基準 | 本輪 T17D-1/-2 | 整合結論 |
|---|---|---|---|
| 原生動作名稱 | `custom:slash_128` | 128px arming sword foreground+background | **語義名稱映射候選** |
| 布局 | 6 frames × 4 directions × 128px cell | 24 frames、768×512，128px cell | **尺寸/幀列 PASS** |
| 人物/武器疊圖 | 正式 LPC 選配 + Steel Arming Sword, 可用裝備盾牌 | Base/Head/Buzzcut/Sword with 64px body embedded (32,32) | **層級概念相容，**但非同一套正式裝備與角色圖像，不能把它當已通過的 v0.6 Binary |
| 角色情緒/裝備 | male/light/neutral + plate/steel + nasal helm + kite | 男性模組化 body/head/buzzcut，**無 plate/helm/shield** | **視覺配裝未等價** |
| 戰鬥時序 | 原 v0.5 sealed semantic HIT/FINISH owner，不允許新命中事件 | GPU 逐格 rendering 24/24 / 並無 Hit-Tick | **BINARY HIT TIMING PENDING，嚴禁冒稱時序 PASS** |
| 箭矢與槍兵 | v0.6正式Arrow和槍兵配方 | 本輪沒有 Bow / Arrow / Spear | **完全不在本輪範圍** |

TSG 正式事實：`LPC_MILITARY_V06=PASS outcome=MUTUAL_DEFEAT tick=1000 parity=29/29 swordshield=6 archer=10 spear=4 custom_attack=178 arrow_launches=94 arrow_samples=1496 arrow_arrivals=90 arrow_facing=1498/0 bow_hit_bridges=90 timing_mismatch=0 failures=0`，且 Human Visual PASS。**這項正式紀錄屬既有 v0.6 binary，而非本次 T17D candidate 新增實測。**

## 未來正確整合方式（不准在這次強行升版）
1. 用 Drive 完整 binary hash 驗證 2026-08-26 正式 v0.6 基準，絕不以 structural stub 替代完整 visual candidate。
2. 從正式 v0.6 中查出 `custom:slash_128` 所需 texture+layer manifest 及實際 signal/hit/finish seam，於正式未封版 feature branch 的隔離 clone 添加一種 **新外觀配方**；不可回寫/覆蓋已SEALED v0.6內容。
3. 接入 T17D 64px 頭+髮/128px Weapon 圖層時，保留 role equipment、z-layer、anchor，做逐格同座標 positive、1px/Z 錯誤 negative Gate。
4. 測試既有 `attack_hit`、`attack_finished` 事件總量和原 v0.6 timing 完全一致（以正式 v0.6 為唯一 HIT authority），**不得自行設定或發送新 hit tick**。
5. GitHub/Drive/Linear 寫入候選與真實 binary screenshot 才能人眼 Gate。未拿到 binary/許可前停在 `COMPATIBILITY_RESEARCH_ONLY`，不可宣稱 v0.6 增量 PASS。

## 检驗邊界
本輪 T17D-1/2：`T17D1_T17D2_REAL_GPU_5_OF_5_PASS`；Godot 真GPU 24畫面逐RGB差0；正式 FS N5 505 SEALED script unchanged。正式T17D3 binary parity 尚未執行。
