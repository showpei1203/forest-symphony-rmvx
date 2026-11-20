# Forest Symphony｜總監控台中央狀態（只由總監控台維護）
更新日期：2026-11-21
本表是計畫啟動時的快照，**不是即時看板**；以執行「總控同步」後回讀三條分支與雲端證據為準。

| 線 | Linear | 分支 | Handoff（預設路徑，可能尚未建立） | 現況 | 下一宏觀單位 |
|---|---|---|---|---|---|
| T-C 地圖 | SHO-39 | `feat/fs-pixellab-tc-map-20261121` | `godot_port/docs/handoff/PIXELLAB_TC_CURRENT_HANDOFF.md` | 新實驗 NOT_RUN；舊 FS_01_VILLAGE/MAZE ART HOLD | 完整可觀賞 Master + 四層候選 + Godot 原生遮蔽 |
| T-A 角色 | SHO-38 | `feat/fs-pixellab-ta-actor-20261121` | `godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md` | 新實驗 NOT_RUN；既有 A52/A54 成果須沿用 | ACTOR01 RUN + ATTACK 12 幀實際 Godot 動畫 |
| T-B 怪物 | SHO-37 | `feat/fs-pixellab-tb-monster-20261121` | `godot_port/docs/handoff/PIXELLAB_TB_CURRENT_HANDOFF.md` | 新實驗 NOT_RUN；PMD0001 舊參考須查核 | 三形態熔岩蛙 + 母體 Idle / Attack + Godot |

狀態定義及同步規格：`FS_CONTROL_TOWER_PROTOCOL.md`。

## 前次核對
- 來源：2026-11-21 三項已建立於 Linear 正式里程碑，GitHub Roadmap 完成。
- 新三線 PixelLab 生成／Godot 原生 QA：均未執行，**沒有原生美術 PASS**。
- 創建獨立分支和 Prompt 只是協作架構，**不能當施工成果**。
- 下一次「總控同步」請將每條線的 HEAD SHA、Handoff 連結、Drive QA source 與判定時間寫到本節，並驗證後更新本表；任何缺失都明確標 NOT RUN / UNVERIFIED。
