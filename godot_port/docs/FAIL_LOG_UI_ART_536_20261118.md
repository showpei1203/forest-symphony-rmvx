# P536 Failure Log｜Forest Symphony Godot 原版 UI 美術｜2026-11-18
- 已驗證私人來源：202 張原本 VX PNG（Menu 40、System 141、Windows 21），Drive id 1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT；來源 ZIP SHA c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6，CRC PASS，provider shared=false。
- 初輪原生 Godot private screenshot 發現：STATUS 頁原版肖像與角色數值垂直疊在同一捲軸位置，文字 overflow；BATTLE HUD 把原 GaugeHP/MP 120×48 全圖直接當圖片顯示，因原圖有多層 frame 不符原格式。這是**真畫面捕捉後發現的錯誤**，不是單元測試假設。
- 工程 `FSUIOriginalVitals.gd` 正確抽取原圖 72×6 色條；STATUS 改為左右排版。源 IMG PNG 沒有重新繪製或 recolor。
- 第一版 commit cc4717c97f20fb038e00a74f5d5945416f242d00 / CI 44189126860 FAIL：Godot GDScript draw_texture_rect_region() 第四參數是 Color 而非 bool，造成 compile fail。後續 67987383cb84b36b17cbfe767316d8fdf04c6903 修正並加入已驗證的私有原生雙尺寸 capture script。
- 完整官方 CI 44189891079 SUCCESS，83/83 steps、0 fail；同時在私有隔離 Godot 4.7.2 載入 **真 202 PNG**，headless Editor import PASS、native data/UI test PASS，Mesa llvmpipe OpenGL captured original MENU/STATUS/BATTLE × 544 & 1088 => 6/6 PNG PASS。
- Private QA final ZIP id 17BwXCHAlhAEDZBUyH8fntmhPZiAyBGV5，536,708 bytes，SHA aa51669780d209ccad894a3e6d5ce882b6bc52efe99ce828b0ebbef523db6d55，Drive shared=false；原始 frame SHA/engine logs 有完整紀錄。初輪 A/B ZIP id 1PjNCtNBix-gRYWtq8ItP5YNFwcrOAZdc 保留。
- **NOT RUN / HOLD**：與真 VX 相同角色戰鬥／同狀態 1:1 畫面比對；完整原 FS BATTLE 背景／動作／怪物／特效、原始主選單完整裝飾、原版 Windows 9-slice、原始 post-Apply 11 DB 與 505 最終 alias parity；真硬體 RX6700XT GPU 測速也 NOT RUN。不可稱正式美術合格。Phase1 SEAL NO。
- 必須繼續 BATTLE / MENU art first，A35 map integration 延後；保留原 VX E: read-only，原圖只在 owner-only Drive，public GitHub 只有可重現程式與非敏感 QA 文本。
