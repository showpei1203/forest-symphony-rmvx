# FS A57 R2｜Failure Log｜2026-11-18

## FL-A57-001：把武器與盾牌當成 Body 動畫工作內容
- 使用者明確更正：武器／盾牌 Sprite 本來就由 Godot 程式碼控制。A56 盾牌與劍尖像素候選不得再算作人物動作進度。
- 修復：A57 Body 只存人物全身姿勢與右手握持錨點；`Weapon`, `Shield`, `Effects` 是独立節點，無貼圖。左手盾牌錨點沒有可靠來源，在正式裝備前不得自動宣稱位置驗證。
- 防再發：16 Action registry 全面標記 `equipment_art=EXTERNAL_RUNTIME_ONLY`，Godot 與 manifest QA fail closed。

## FL-A57-002：16 動作清單 ≠ 16 個完成 Sprite Sheets
- A57 已登記原版 FS 16 類，包括 `Nothing` 空動作。這不等於 16 類都已經具備相同人物真正的 64px 實用動作。
- 修復：每動作獨立 `status` 與 `source`，A62 歷史 User PASS、A63/A64/A65 美術待驗、A53 A57 目前候選、Dodging 之前曾失敗。找不到真圖就是 NOT_STARTED。

## FL-A57-003：Waiting 硬套舊的垂直呼吸會違反原生動作語意
- A63 W2 vertical breathing 曾被使用者否決；目前 Waiting 參照 A63 W3B 0→1→2→1 水平左右小擺，不應假設所有 loop 同一個動作。
- A57 本次用 A53 原始 F0 直接產生三個新來源像素姿勢，頭部原位／+1／+2px、雙腳 y>=40 像素不變；但腰肩動作可讀性尚未使用者核准。
- 後續若肉眼不自然，修「動作姿勢來源／骨架」而不是反覆修改一兩個像素後宣稱已量產。

## FL-A57-004：CI 第一次擴充 Waiting fixture 提前失敗
- GitHub Actions run 44189816222 失敗：
  - `ci_fixture_builder.py` 已擴充為必須替換 Waiting 原始圖 SHA，但 workflow 當時仍複製舊單攻擊 GDScript；故找不到 Waiting SHA、退出 1。
  - **這是測試部署版本不同步，不是人物美術或 Godot 引擎失敗。**
- 修正 workflow 改為讀 `r2` action_catalog/player/native_smoke、合成等待圖 fixture，再跑 4.7.2 原生回歸。
- 修復後 run 44189852401 `conclusion=success`、讀到完整 Waiting + Attack PASS。
- 防再發：CI fixture 與 manifest/script 需同版本、錯誤 SHA fail closed；正確 source 不可為過關而移除原始 SHA Gate。

## FL-A57-005：不要用合成 GitHub CI 取代真實私有圖 Godot Native
- 私有完整 A57 R2 ZIP 真實角色素材在 Drive。GitHub repo 公開，只上 code/metadata，CI 生成 synthetic Body + Waiting 來測播放器。
- 本次真實 A53 12f、Waiting 3 pose 均跑 Python 真像素 SHA / alpha / position QA；但私有真圖 **Godot GPU 尚未跑**。
- 存續舊 A54 95s GPU timeout；不得宣稱本輪已修復。

## FL-A57-006：判斷動作品質不能只依 changed-pixel 數
- Waiting 各姿勢與原始 F0 差 263 / 345 RGBA 像素、頭部 centroid +1/+2，這是可重複的來源像素位移，不代表肩／髖／手自然。
- 正式 ART 仍 HOLD，必須原生 1× 動畫看出行為，檢查肩腰接縫、腳跟鎖定與角色 45° 方向。
