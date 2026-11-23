# FS Godot｜P538C 原版 MENU 來源窗格校正與操作驗證｜2026-11-23

主線：`feature/fs-godot-phase1`，Godot 4.7.2；T-A／T-B／T-C 獨立不動，原 VX 唯讀。

## 本輪真正新成果（M1）
直接沿用原 `FSOriginalMenuPage`／`FSScreen`／`FSMenuModel`，沒有重寫戰鬥/DB/背包系統。
1. 使用私人 **202 張真正原版 UI** ZIP 及前輪 P538A 真 Godot 原圖截圖檢視了原版：Source `MenuBack_status_a`、`MenuBack_skill`、`MenuBack_item`、`MenuBack_equip`、`MenuBack_party` 的底圖各有不同的內建框，**P538B 通用白色 Panel 在不同頁蓋住原版窗格，視覺不合格**。
2. 修正 `FSOriginalMenuPage.gd`：在原圖 544×416 座標註冊 `SOURCE_ROW_RECTS`，把 STATUS 數字區放在原大框；SKILLS 的下方全寬列表；ITEM/EQUIP 的左側列表並保留右側資訊框；FORMATION 不再產生通用面板，而是置入原畫的 3 個 Current Squad 欄位和分離 Reserve Squad 區；角色頭像/選取列移出下方原窗格。原始背景和 tabs 仍透過原 `FSUIArtLibrary` SHA 確認。不在公開 GitHub 推送原 PNG。
3. 修正 `FSScreen._show_log`：原頁面隱藏開發用 log，過去「物品不支援/裝備不合法」可能是無聲拒絕；現在用 source-page 可見 feedback 提示。不改 `FSBattle.use_item`／`FSMenuModel` 的安全門檻。
4. 新 `test_fs_p538c_source_window_geometry.gd`：使用**程式現場生成的單色尺寸 Fixture（非原畫）**做每頁真 Control layout/native signal 自動測試，涵蓋 STATUS/SKILLS/ITEMS/EQUIPMENT/FORMATION、544×416／1088×832、四個不同主角/等級、物品拒絕且不扣數、裝備選項取消、Current/Reserve 交換並同步 GameState。測試框圖不是美術 PASS。

## M2 真正 Godot 4.7.2 native QA
- GitHub **最終完整 Actions #45129180313，99／99 steps SUCCESS**，原始碼在 `074c8e2209dda5f7b4d4f5fb97df04fc0d683762`；含新 P538C fixture 實際 engine test，以及 P538A/B、BATTLE、ATB、ACT、Boss、元素、UI、事件、故事/地圖的全部原有 regression。https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45129180313
- 99 steps 是官方 Workflow step 數，非 99 個遊戲功能已移植、非 99 張真原版截圖。私有原圖尚未跟本輪 CI 渲染同一畫面，故 P538C 的私人原圖 Godot native GPU **NOT RUN**，不能稱 source-art native PASS。
- Owner-only source ZIP `FS_GODOT_UI_ORIGINAL_PRIVATE_20261118.zip`，8,371,041 bytes，SHA256 `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`，202 原始 PNG、ZIP CRC PASS；從 Drive 真正下載到獨立隔離環境重新 SHA 計算，無使用者 PC。

## M3 真 FAIL → 修正（不能偷換為 art PASS）
- **CI R1 FAIL**：#45128951564，在 `P538C source-authentic page rectangles...` 的 native test 出現 `status screen 1x/2x centered source window`。這是新測試在 SceneTree 內調整 root viewport 尺寸後未把尺寸同步至 FSScreen Control，再核對 overlay 的 fixture setup 問題，**不是觀察到原圖 RGBA 渲染故障**。
- 修正測試：改在切換 544/1088 時同步 `screen.size` 並呼叫既有 `_layout_source_menu()`；保留完整座標斷言。Commit `074c8e2`，最終 CI #45129180313 PASS 99/99。
- Source original 檢查實際也揭露 P538B 的通用白色 panel 錯誤；commit `db31135` 修正版面，`1d2d8a0` 修正隱藏錯誤提示，沒有捏造「VX 與 Godot 已逐像素相同」。

## M4 第二來源與私人 Drive QA 交付
- 四位不同姓名/ID 的 source-shaped synthetic fixture「喬伊／米亞／艾薇／泰勒」，二種實際 native viewport 尺寸；玩家隊伍第 1 與 Reserve 第 4 成員交換後 `world.party_actor_ids==[4,2,3,1]`，native 自動驗收。
- 私人原版 UI 來源 202 PNG 真下載／逐檔 hash，原生尺寸 544×416，另驗證 10 個 source 60×20 tabs。離線檔案有 **5 頁 source-native 544** 上下框位置標記、**5 頁 1088 最近鄰參考放大**、Manifest/FailureLog：共 12 件。**這不是新的 Godot 視埠截圖，不能當 native ART PASS**。
- 新 Drive QA ZIP **已直接上傳並立即回讀 byte-for-byte SHA256**，723,848 bytes、ZIP CRC PASS，SHA256 `78a0313020038deeb90e5a7978753b7a37d40616f6d3a42f29d42486fa04216d`，owner-only shared=false：
  https://drive.google.com/file/d/13EQhnMU8iYBDsjMEdO3A9Mp0iFjwb0SE/view
- 真原始 source ZIP 同樣仍保存：https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view；P538A native source 14 張截圖留原 link：https://drive.google.com/file/d/19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B/view；本輪獨立來源檢查沒有竄改原始圖片。

## 明確 HOLD／工程範圍
- 沒有取得可在隔離容器中運行的官方 Godot 4.7.2 executable；官方 Github-hosted CI 本輪只有**真 Godot 原生程式測試 + 合成尺寸圖片**，無私有原畫在同一原生執行環境中的 P538C 10～20 張畫面；**PRIVATE SOURCE NATIVE SCREENSHOTS HOLD**。離線像素 Overlay 絕不代替 Godot 真截圖。
- 原 VX 同狀態 Menu/Status/Skills/Items/Equipment/Formation 比圖、MenuBack 狀態/字型/WindowSkin 精準配置、原 source #505 effective runtime、11 表 post-`FS_DB_AUTOSET.apply_all`、使用者 Art Gate、RX6700XT 原生畫面仍 HOLD。PHASE1 SEAL NO。
- 共用 Skills：透過 GitHub `.agents/skills/fs-rmvx-router/SKILL.md` 實際載入，不假裝 Windows Skill 自動匯入。以使用者要求 Godot 為主；舊 Skill 的「VX 為正式主引擎」、「Ground-first/3 幀」不可覆寫新的 FS Godot 移植與 T-C 現行規則；只沿用資料來源、雲端、QA Fail-closed。
- GitHub/Drive Connector + GitHub CI + 內部隔離 Python/Pillow；Codex 0、Desktop Remote 0、PC Bridge 0、Windows PC 寫入 0；私人 PNG 不曾提交公開倉庫。

## 下一完整工程單位 P538D
(1) 在**隔離且可讀原始私人 ZIP**的官方 Godot 4.7.2 環境實跑 `capture_fs_p538b_private.gd` 擴至 P538C 每頁 10x544 + 10x1088 原圖；(2) 採 source 原版 VX 來源窗框和兩角色實際狀態作 1:1 視覺對照，修正不是來源的 Godot 控制元件；(3) 將真原生 PNG+manifest、SHA、failure diff 留 owner-only Drive，回讀；(4) 並行分離 11-table postApply witness。沒有新的授權 Windows 任務不要借用 T-A Bridge 白名單跑本主線；不能把離線幾何圖稱成已封版。
