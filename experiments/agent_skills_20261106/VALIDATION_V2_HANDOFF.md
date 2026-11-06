# Forest Symphony | Agent Skills 第二輪驗證 Handoff (2026-11-06)

## 0. 最重要的結論
- **FS Agent Skills v2 規格修正已導入隔離測試；沒有改動 A36F R1、A36G R5 或 PMD 原件。**
- 原始 FS `ground3` 含完整畫面，`par3` 是對應地面像素的局部角色遮擋；不能把「語意 Ground-only + 全部物件 PAR」直接當成 Hanzo Native Runtime Overlay。
- A36F R1 與 A36G R5 的舊版輸出，雖然能合成，也曾進入遊戲做 Sprite Smoke，**不能宣稱通過原版 203 前景層機制**。
- A36F R2 保守版真實 VX `Game.exe` 在 **3 個固定座標 Case 4、6、8**，以 203 OFF/ON 確認前景遮擋差異，**Native ParSwitch Gate = PASS (3/3 sampled cases only)**。
- PMD 三幀尺寸、Alpha 等技術問題已核對，但**跑步左右腳交替、45° 全身動態、原版 XML/SBS 整合及美術驗收均未 PASS**。Formal Seal = NO。

## 1. 五組 Ground／PAR 像素診斷（同日新執行）
| 類別 | PAR alpha>0覆蓋率 | PAR alpha>=200和Ground相同RGB比例 | 符合原版 runtime 像素重疊初篩 |
| 原版 Ground3 / Par3 | 13.8563% | 97.5685% | YES |
| A36F R1 Ground-only / complete PAR | 64.3505% | 0.0887% | NO |
| A36G R5 Ground-only / complete PAR | 76.5090% | 0.0327% | NO |
| A36F R2 完整Ground + 保守 Occlusion PAR | 33.0029% | 100% | YES / MASK ART UNVERIFIED |
| A36F R2 完整Ground + 擴大 Occlusion PAR | 46.4017% | 100% | YES / MASK ART UNVERIFIED |

注意：覆蓋率不是任意場景通用閾值，不應用「接近原版 13.85%」作為硬門檻。需角色行進和畫面行為驗證。兩種輸出契約必須用不同名稱：
1. AUTHORING_GROUND_ONLY + AUTHORING_COMPLETE_PAR（全部非地面物件、來源與 Manifest）。
2. RUNTIME_FULL_SCENE_GROUND + RUNTIME_OCCLUSION_PAR（同源同像素、局部遮擋），由 Hanzo `$game_switches[203]` 控制。

診斷：`validation_v2/GROUND_PAR_RUNTIME_CONTRACT_V2.json`；可視化 `GROUND_PAR_RUNTIME_CONTRACT_5_CASES.png`；程式 `fs_runtime_contract_v2.py`。

## 2. 真正原生 VX 遮擋測試
- 測試源：`E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST`（已將獨立 Overlay 個別物件清空，只保留完整 Ground + 部分重疊 Occlusion PAR）。
- 測試只在 `E:\FS_AGENT_SKILLS_PILOT_20261106\validation_v2` **隔離複本**執行，每個位置另有全新複本。各來源檔 SHA256 完全未變。
- 進入 VX `Game.exe`，確實控制 `$game_switches[203]`，RGSS `@par` Sprite `visible=false/true`，擷取實際 544×416 截圖。
- V2 第一輪動態 11 案位置：Case 4、8 局部遮擋有效；Case 6 拍照切到另一個位置，不能作 PASS（這次應保持 FAIL）。
- V3 複本先改程式碼但在「不相等 SHA」檢查誤將預期的腳本補丁算作來源異動而中止，已留 log，不可稱通過。
- V4 把 ON 時間提前後，Case 4、6 沒有像素變化（缺少可比較人物），測試 FAIL；不隱藏紀錄。
- **V5 修正方法**：每個 Case 獨立 Game.exe、腳本內 `slot` 鎖 4 或 6 或 8、`frame_step=100000` 防鏡頭自動輪轉；不覆寫原測試原件。
- V5 Case 4: 627 changed pixels、差異包圍框 [261,188,286,220] (25×32) PASS。
- V5 Case 6: 627 changed pixels、差異包圍框 [261,188,286,220] (25×32) PASS。
- V5 Case 8: 471 changed pixels、差異包圍框 [389,254,412,284] (23×30) PASS。
- Native Gate = **PASS for 3 deliberately sampled positions**, **NOT full map**, **NOT collision/traversal QA**, **NOT art pass**。
- 檔案：`validation_v2/VX203_LOCKED_CASES_QA.json`、`VX203_LOCKED_CASE_{4,6,8}_OFF_ON.png`、`fs_vx203_locked_cases_v5.py`。

## 3. PMD0001～0003 動作實測
- 三系列的 Moving_to_Close_Attack _1/_2/_3 均 128×128，實際存在。
- G23 baseline 底部 bounding box jitter 為 6/6/8 px。
- R1 footlock 強制底界後 jitter 0/0/0 px，但 F3→F1 逐像素差異由 12.158/19.257/29.437% 增到 21.954/35.767/51.508%；不能因此宣稱 Loop 更順。
- R2 Pareto 修正 jitter=3/5/7 px；F3→F1 差異返回 12.158/19.257/29.437%。只是折衷，仍無法證明左右腳交替或人物 45° 方向。
- 已重新產出 9 幀實際 PNG 預覽 `validation_v2/PMD_R2_9FRAME_GAIT_REVIEW.png`，未消耗 PixelLab API 額度。
- PMD 視覺／動作 Gate：**PENDING**。不得把外觀連續性直接當作正確的交替步法或最終 SpriteSheet 驗收。

## 4. 已更新 FS Agent Skill
- GitHub `.agents/skills/fs-rmvx-router/SKILL.md` 新增 Authoring vs Runtime 分離，以及 FS ground3/par3 實際 203 Gate。
- Codex 等 AI 代理進入 FS 任務，必須先讀最新 FS 專屬 Router 與 FS Drive v3.2 Authority，再載入通用 Skills。
- 不覆寫現有 Main；先以獨立 branch 提交與核驗，再合併；本交接會附 GitHub URL。

## 5. 後續工序
1. A36F R2 保守版，在完全固定鏡頭與 203 內生圖像擷取環境，擴增「角色走到樹後、走出樹、房屋入口、牆與樹根碰撞」全圖語意測試；遮擋 Mask 範圍仍待人工美術驗收。
2. PMD0001 不消耗 PixelLab 額度，使用現有原圖及動作重新作骨架/左右腳深度辨別，可先輸出 1 動作 3 幀可覆用實驗，逐格對比、人工判斷。
3. A36G 美術尚未過關，不再用 203 改良宣稱房屋風格或密林完整；若開始新美術施工，一定先讀所有 FS Precheck + Ground/PAR authority。
4. 保留 Before/After、Source SHA、native QA 與 failure log。不要把技術/美術混在一起標為 PASS。

**Total verdict:** Skills v2 檢查機制已抓到根本性的模式差異，且完成 203 三案例 native PASS；PMD 美術與完整地圖仍未通過正式驗收。Formal Seal NO。