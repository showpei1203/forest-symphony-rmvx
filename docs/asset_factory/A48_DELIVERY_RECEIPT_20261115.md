# Forest Symphony A48｜正式交付驗證紀錄（2026-11-15）

## 完成內容
對 A47 多處頭頸、肩臂、軀幹分離的 ART FAIL 回報，實際重新製作了獨立 A48 的完整 12 幀 Body 圖集：A62 核准人物全身做共同母體，重新連續繪製肩→肘→持劍手的動作；頭部、腰、腳、另一隻手不再被各自變形。既有 Weapon/FX 獨立圖層與 F6 (30,9) 動態錨點保留。初版 F3–F5 頭髮被覆蓋、F8 腳底像素被改動的失敗亦已修好。

## 真正驗證
- Source 12/12 Body 各只有一組 8-neighbor 連通輪廓、11 種不同動作。
- 核准 A62 的頭髮/臉、骨盆/雙腳、非持劍手 RGBA：各 12/12 完全相同。
- 10/10 活動幀肩、肘、腕連續，沿骨骼 5×5 取樣最低 16 個不透明像素。歷史 A47 身體漂移負例會 FAIL。
- Godot 4.7.2 AMD RX6700XT 原生 GPU 12 幀 0 像素差，命中 F6 0.55s、Hitstop 70ms、練習靶 HP100→75→50、取消/範圍外不扣血/2x 速度 PASS。
- ZIP 296 檔（295 source）、1,398,892 bytes，SHA256 `0fd8d5c81def1c04f2a9170bcbad991012961dd8a85ff0ae57b924027612bb77`；完整 CRC PASS，從 ZIP 冷解壓原始檔 SHA 零不符，重製 Body SHA 相同，Godot editor/GPU/contact QA 原生測試 Exit0。
- 兩份誤因遠端讀取仍在執行而寫入讀取狀態的 GitHub 文件和額外幾份 QA JSON，已**實際更正成原始檔位元組**，在 GitHub 重新讀取確認不再含錯誤狀態文字。
- C: 測試執行檔、冷啟動資料夾已清除；重複的 Drive ZIP 和根目錄暫存腳本亦已清除。正式完整 ZIP 保留於 A48 私人 Drive 工程資料夾。

## 官方存放位置（已讀回確認）
- 完整 Godot 工程 ZIP（私人、僅 owner）：https://drive.google.com/file/d/1qNdsdXmVhcf8zqgGsdn9ewUmo2zyHyu7/view
- 私人 Drive A48 工作目錄：https://drive.google.com/drive/folders/1AdeWiO-nLICKj3qzTJOlHrQAEyaVkDTK
- 真正 Godot A47/A48 同步 GIF：https://drive.google.com/file/d/1EvZWZ1Rjh9rg-tnQOfYIuTUqfIOWFkLF/view
- A48 native Godot 單獨攻擊 GIF：https://drive.google.com/file/d/1mm2j-5Ch5wDQ2sdqdMe9clB0AamiWVn3/view
- 12 幀 3× 比較：https://drive.google.com/file/d/1jieYHtB7FkHhUoCn3b80qROKO6t-9RLF/view
- Drive 詳細 Handoff：https://drive.google.com/file/d/1u5KMPMgmnMpVNaxrIiveDKpUw5F7az8j/view
- GitHub 完整程式與檢查：https://github.com/showpei1203/forest-symphony-rmvx/tree/feat/fs-asset-factory-v1-20261107/tools/asset_factory/godot_a48

## 正式門檻
**A48 ENGINE PASS／已知身體連結缺陷的結構驗證 PASS／完整美術 ART HOLD。** 姿勢的力量感與胸肩旋轉幅度仍需改善，不可因為 GPU 像素合成 0 差異而冒稱美術完成。完整 FS ATB、技能、敵人傷害移植 NOT RUN。未動 E: RPG Maker VX、GitHub main、地圖與其他 Godot 移植分支。PixelLab 本輪未付費呼叫。
