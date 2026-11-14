# A22｜Agent Sprite Forge 0.6.0 對 FS Asset Factory 的評估與受限試驗交接
日期：2026-11-13。類型：UPSTREAM SOURCE INSPECTION / ADOPTION CANDIDATE / NO GENERATED ASSET。

## 0. 權威與來源
- 上游：https://github.com/0x0funky/agent-sprite-forge
- 讀取時最新 GitHub commit SHA：`25203d03900b46b444bdd72a75768c33d1895ad6`；實驗時應固定此 SHA，升版另作差異審查，不要無聲追 main。
- 上游 `CHANGELOG.md` 宣告 0.6.0（2026-11-13）及 Pixel Looks；其 `docs/known-limitations.md` 仍以 0.4.0 為標題，不能拿它代表 0.6.0 全部已驗證。
- 查閱的真實上游程式/文檔：`skills/generate2dsprite/SKILL.md`、`skills/generate2dsprite/references/pixel-looks.md`、`skills/video2dsprite/scripts/pixel_motion.py`、`CHANGELOG.md`、`docs/known-limitations.md`。
- FS 執行唯一方法權威仍是 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`；安全 `docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md`；進度 `docs/asset_factory/CURRENT_HANDOFF.md`。A22 不修改這些規範。
- A21 原有 148/148 synthetic CI PASS 只對既有 FS 程式；A18 PixelLab 真新三幀 0、1x ART HOLD、原生 VX NOT_RUN，A22 不得被算作新素材產量。

## 1. 上游真正提供什麼
1. `generate2dsprite / pixel_look.py`：以一張喜歡的參考像素圖訂下角色畫風與像素比例，再以相同 master 做新角色、局部 pose、view；`ask-pose`/ `pose` 只保留修改區域，降低全身重繪漂移。
2. `video2dsprite / pixel_motion.py`：prepare → image-to-video model → frames → measure/finish，將影片每格讀回原 master 色盤、格線；可鎖頭、測足部節奏、選擇關鍵格；不是 3 幀原生輸出器。
3. `sprite_set.py`：一母圖多動作，品質 gate、失敗重試、費用 ledger、export；有成本上限功能但預設不啟用。上游的 Image-to-Video 是「一個動作一部影片」，不是免費的必然運算。
4. `generate2dmap`：ground-only、dressed reference、props、footprint/navigation 和 Godot/Tiled/LDtk 格式；不原生保證 FS 的 `Runtime_FullGround = 完整 MASTER` 加同 XY 原 RGB `Runtime_OcclusionPAR`。
5. 內建 exporter **沒有 FS 原生** `Actor _1/_2/_3`、Tankentai RGSS2 或 PMD `AnimData.xml`。上游的 Godot/Aseprite 輸出亦明言 editor-import 尚未實機完整驗證。需要 FS Adapter + VX gate。

## 2. 對接與技術風險
| 上游功能 | FS 角色/怪物 | FS 地圖 | 結論 |
| --- | --- | --- | --- |
| Pixel Looks master/pose/view | 可直接沿用「核准原版 F0 是唯一身份來源」原則 | 不適用 | **優先試驗**，但不得把 F0 重新生成的新圖當作自動核准原版 |
| pixel_motion 的原格線/色盤/足部/loop | 可作 45° 三影格候選擷取；姿勢視角及左右腿人眼驗收必須另做 | 不適用 | **優先試驗**，不是直接 PASS |
| 生成影片擷取動作 | 對 Run/Attack 可試，但高速肢體、視角漂移與變身失敗需限制重試 | 不適用 | **限額候選**；未經核准不啟用付費通道 |
| maps/scene props/collision | 不適用 | 可輔助物件布局、mask、語意或碰撞審查 | **輔助**；禁止獨立生 PAR 覆蓋同源四圖法 |
| Godot/Tiled/Aseprite export | 僅為中間素材 | 僅供 QA | **不能替代 RGSS2/VX 原生驗證** |

**重要差異**：上游展示的 33×55（48 色）角色、21 張攻擊影格、14 組/168 個圖樣是作者自己的示範，不是 FS 48×48 45° 的測試結果；FS 角色色盤依來源和已核准 16 色系統，不要用預設 48 色覆寫既有角色。PMD 怪物尺寸不限 32×32，且 AnimData.xml 原生幀數不是統一 3 張。

## 3. 最短、可判斷價值的 FS 試驗（勿再造純紙上演算）
### T1：Actor01 RUN，與 A62/A18 既有資源同源 A/B
- 輸入必須從 owner-only Drive 重新 READBACK：核准 F0 48×48 的 SHA256 = `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`；既有 A62 三幀作動作與外觀基準。私人 PNG/base64 不進公開 GH。
- 優先 **現有 F0 → Pixel Looks / pixel_motion**；不要另創人物，且必須固定 45° SW 鏡頭、同身分、同根足點；確認 `--colors` 與來源實際色盤相容。沒有適合的影片 provider 或使用者明確的費用上限，則只做免費環節並標 `PAID_ROUTE_BLOCKED`。
- 擷取三張 **真正不同姿勢**：F0 中立、F1 左腳前、F2 右腳前；在 RGSS2 用 `0→1→0→2` LOOP。測頭/甲/披風/雙腳/手臂位置、45°、輪替/反擺、第一/末格接縫、Alpha 與 1x 觀感，真正圖 PNG+GIF 存私人 Drive。
- 與已存在 A62 與 PixelLab A18 單筆實驗以 **同輸入、同場景、同 1x 規範** 比較，不拿不同設計圖做不公平比較。
- 成本與修正次數分開記錄：`provider_calls, charge_usd, new_provider_frames, frame_art_pass, loop_motion_pass, native_vx_pass, manual_minutes`。若首次新出圖依然不像 F0，停止重試，先定身份/方向/時間/格線 failure class。

### T2：再做 Waiting 3 幀與 PMD native 單物種
- Waiting 可先用 `pixel_motion breath` 作免費機械基準，但只兩格且動作不一定自然：不可聲稱已是 FS 3 幀。
- PMD 用原版 `AnimData.xml` 路由到實際動作/方向/幀數，例如 PMD0001 Idle3、Walk6、Attack11，嚴禁只把三個 Actor keyframe 複製湊數。
- 同一套處理能在 **第二個 Actor** 重現，且 PMD 原生至少一動作真正通過，才進入量產討論。

### T3：地圖限配角
- 從 FS 已核准 `MASTER` 和來源物件 mask 建 `Authoring_GroundOnly / Authoring_CompletePAR / Runtime_FullGround / Runtime_OcclusionPAR`，RGB 從同一 Master XY 提取；可借用上游 map 的 object、nav、collision 介面做語意提議，不能借用其獨立重畫 PAR 作正式上層。
- 評估對原 A21 樹冠過度遮蔽是否能提出**更準確的每物件 mask**，使用 Actor 合法腳點、屋簷/橋負例、Native Switch203 比對。若沒有正確來源 mask，T3 保持 HOLD。

## 4. 上線前操作保護
- 只在 **GitHub Draft PR #15** 下另增 A22 候選文件/程式，或在雲端隔離 runner 暫存；不得覆寫 FS `main`、A62/A18 sealed 來源或私有素材。
- Github public 僅存授權合規的程式/規格/去識別 QA；PNG/video/原版來源及大檔進 owner-only Drive，WRITE→READBACK→SHA。
- 不以安裝 Agent Skill 等於實測成功。上游驗證主要在 Windows 11，其他系統與 Godot 編輯器匯入有限制；需單獨測 Python 依賴、ffmpeg 與付費 API 可用性。
- 預設不使用者 PC 建工作檔、不遠端登入也不修改既有 Orca/Codex MCP 權限。若要在 PC 動工須先獲得相應臨時檔授權；付費 model call 需另有確定費用上限與單筆核准，不讀取/暴露 token。
- 上游 MIT 只涵蓋 code/docs；輸出媒體商用權仍依各模型供應商條款。
- 若實施 ASF，應 Pin source SHA，並隔離第三方執行程式，不直接把整套 Skill 放到既有使用者 PC 常駐工作區。

## 5. 此輪 QA / Failure Log / Handoff（真實狀態）
- `UPSTREAM_GITHUB_SOURCE_READ`: PASS（README、CHANGELOG 0.6.0、pixel_motion.py、Pixel Looks、Known Limitations）。
- `FS_CURRENT_RULES_AND_A21_HANDOFF_READ`: PASS（GitHub Draft branch，加讀 Drive 全球 P0/共同生成規範）。
- `FS_ADAPTER_IMPLEMENTED`: **NOT_RUN**。
- `UPSTREAM_TESTS_EXECUTED_HERE`: **NOT_RUN**（本環境無外部 Git clone 網路；透過 GitHub Connector 讀取程式碼，不假裝已安裝或跑 Pytest）。
- `REAL_F0_PASSED_TO_ASF`: **NOT_RUN**。
- `PAID_IMAGE_OR_VIDEO_CALLS`: **0**；費用 0。
- `NEW_FS_SPRITE_PNG`: **0**，`USER_ART_PASS`: **NOT_RUN**，`NATIVE_VX_PASS`: **NOT_RUN**。
- `GROUND_PAR_NEW_ART`: **0**；A21 過度遮蔽問題尚未解決。
- `MAIN_MODIFIED`: **NO**。本檔是候選研究，不能當成功的產線或替代既有 F0/MASTER。
- **Next atomic execution**：先驗上游 SHA/工具可執行性 + 取得唯一 F0 來源；在雲端 run 一個不付費的 `pixel_motion breath` 與來源保真 QA；再決定是否值得用一次限額 image-to-video 產生 Run 3 keyframes。這才是「有新圖才推進」，不是新增更多抽象骨架報告。
