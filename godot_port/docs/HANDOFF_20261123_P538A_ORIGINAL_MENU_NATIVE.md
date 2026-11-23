# Forest Symphony｜P538A 原版 MENU 施工交接，2026-11-23

工作線：Godot 4.7.2 / feature/fs-godot-phase1；T-A 角色、T-B 怪物、T-C 地圖各自隔離。最新使用者優先：戰鬥系統、選單系統與 UI 原始美術優先，不能重啟 P536，也不能倒退 VX。上階段 P539F 所有 #381/462 原始戰鬥來源修正保留。

## M1 原版完整主選單候選
- 新 FSOriginalMenuOverlay：原版 Menu01–08 50×20；MenuBack_b 544×416；01物品／02狀態／03技能／04裝備／05隊伍與既有 FSMenuModel/FSScreen 真操作連接；06任務／07儲存／08系統因原邏輯未移植故 DISABLED，不冒充已完成。
- FSUIArtLibrary 對 19 個新增原始 UI 檔案做獨立 SHA 鎖；圖像仍在私人 Drive，GitHub 沒有原始像素。STATUS/Skill/Item/Equip 四類原始 60×20 子頁 tab 圖展示，未移植的功能保持灰化。
- 真正已驗證來源 UI 202 PNG，8,371,041 bytes，SHA256 c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6，私人 https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view。

## M2 Godot 4.7.2 原生執行
- 202 私人原始 PNG 在 ChatGPT 隔離雲端本機工作區 stage + Godot 官方 Linux 4.7.2 editor import 成功；原生 Godot OpenGL Mesa llvmpipe 軟體渲染，非使用者 AMD RX6700XT 實卡驗證。
- Native 544x416 與 1088x832，每組 MENU/STATUS/SKILLS/ITEMS/EQUIPMENT/FORMATION/第二位米亞 STATUS 七畫面，14/14 實際 Godot viewport PNG；兩角色原始角色肖像是喬伊與米亞，但 DB 數值明確 synthetic fixture。
- 私人 QA 封包：Google Drive https://drive.google.com/file/d/19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B/view；1,965,809 bytes，SHA256 c3fdeff4d3558231a7c6217ebbd1e95a05ffdc814a58f262803c71a519050001，ZIP CRC PASS，Drive metadata readback owner-only shared=false；14張 PNG＋manifest＋log 不在 GitHub。
- 新 native test_fs_p538a_original_menu.gd：驗證 8 source art 尺寸、5 真路由、3 disabled、source 安全缺省、原始 actor 資料不受 UI 操作破壞、4 子頁 tabs；原有 P537C enemy stage 與 FSMenuModel/menu_battle_ui native 回歸 PASS。
- 完整正式 GitHub Godot 4.7.2 CI #45101720647 SUCCESS，97/97 steps，0 failures：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45101720647

## M3 兩次真 FAIL→修復
- 初版 6fb4247 在 FSScreen._clear_body 強制 status_label.visible=true，導致舊 Battle source HUD 顯示錯誤，官方 CI #45101117251 FAIL P537C。commit 8b44b26 限制 view_name!=BATTLE 才還原 status，官方 CI #45101429156 SUCCESS；既有 BATTLE/ACT/Enemy 不能被 MENU 改壞。
- 第二角色來源 GPU fixture 初版誤取不存在的 synthetic Actors[2]；commit 6d09937 建立明確複製的測試用 actor2(id2,name米亞)，來源肖像使用私人真正原版 PNG 而非假立繪，544/1088 第二樣本 PASS。

## M4 第二獨立原圖樣本
- 原版喬伊＋米亞兩人物肖像各經 Godot native scene 展示；雙解析度 14 張來源原圖畫面。第二角色數值是 synthetic，不是原版 FS boot-final after FS_DB_AUTOSET.apply_all。
- 程式 commit 6fb4247a9e92d013881f24eaeda1bd9a8b8e5e2f、8b44b2639332f10fb9e143c6b724297ce4142e50、6d0993736b1d6e3bcd42524f8128068f922c7064。

## 權威與 HOLD
- 讀過 GitHub AGENTS、FS Current Rules Index、FS 專用 Skill（GitHub .agents/skills/fs-rmvx-router/SKILL.md）、P0 Cloud-only、Asset Precheck、Roadmap、最新 P539F Handoff/FailureLog、Drive 來源；也讀過已裝的 Google Drive/Docs Skills、私人 PC Bridge AI 遠端工具路由規範/README/Handoff/白名單。Windows Skills 沒有自動載入，正式 FS Skill 是明確自 GitHub 讀取。
- 工具：GitHub Connector、Drive Connector、隔離雲端 Godot 4.7.2。Desktop Remote 0、Codex 0、PC Bridge 任務 0、使用者 PC 寫入 0。原始 E: VX 保持唯讀。
- 視覺原始同狀態 VX vs Godot 1:1、用戶 AMD 實體 GPU 本輪、完整子頁布局、未移植 Quest/Save/System、11 postApply boot-final 表格、505 RGSS2 effective alias 全運行都 HOLD。ART HOLD；Phase1 SEAL NO。
- 下一完整施工單位 P538B：原版 STATUS/Skill/Item/Equip/Formation 全頁與 Windows skin 組圖，操作沿用現有 MenuModel，native 544/1088 畫面檢視，兩組來源樣本，真正 VX 相同狀態比圖，並獨立處理 boot-final witness。禁止把小 HUD 補丁當作 P538 完成。
