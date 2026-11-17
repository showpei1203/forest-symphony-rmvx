# Forest Symphony P537 BATTLE Original Icons FAILURE LOG (2026-11-18)
- 原版來源 BATTLE01 Attack／02 Skill／03 Defend／04 Item／05 Escape，各 54×48 及灰色 a 版（owner-only Drive 202 PNG source）。所有 10 個 SHA metadata 在 `FSUIArtLibrary`，私有 PNG 不在 GitHub。
- 第一輪 source icon mapping commit a33e3eab8a8c841eb86c229cd1ada919b6260d49 已在真 Godot 私有 Source Native test PASS：未就緒灰圖 disabled／合法 ATB READY 彩圖 enabled／原先 ACT attack/select target 邏輯不破壞。未新增沒有來源的 Escape 功能。
- **視覺 Regression 發現**：第一輪按鈕採 54x48 垂直四個，真 544×416 OpenGL screenshot 只看得到最上兩個，第三、四個需要捲動。不是測試 PASS 就可稱好看。
- **已修復**：commit c7d2b49555a9d2bba34215bba1e6c82d369efe04 改 Godot `GridContainer(columns=2)` 真 2x2 源圖，HP/MP summary 高度減少，全部四個同畫面可見。Godot 4.7.2 native CI #44192136418 SUCCESS，84 steps 0 fail。
- 再提交 [db8a8ee](https://github.com/showpei1203/forest-symphony-rmvx/commit/db8a8eea07885da2178574c09a41617de90e5491) 建立正式 PRIVATE GPU capture test 與 2x2 native gate。其最新完整 CI #44192518222 狀態以 provider readback 為準，不先杜撰 success。
- **真 202 原始 PNG staged**、官方 Godot 4.7.2 editor import、私人 native source icon test PASS、OpenGL true 544x416 & 1088x832（disabled、enabled、selected target）6/6 screenshots PASS，原圖和手動戰鬥 AI fixture 非 Source last-wins DB。
- 私人 Drive QA 封存：id 1CM3cQRXFT_-9TJm4v0t_Z2qDE58lvXiE，415,866 bytes，SHA256 68823205ea662501b097715c25e6131dc2036866ab842481799bb3ad00fce30f；Google Drive readback `shared=false`。
- **NOT RUN / HOLD**：真正 BattleScape/背景、動作 A52/A54、多幀武器與敵人貼圖、ATB/ACT 每幀原版視覺時間/原 VX 同狀態 screenshot parity、原 post-Apply 11 tables + 505 dynamic aliases、玩家 RX6700XT 本機 GPU 性能。保留 P532 完整可玩流程基準；Phase1 SEAL=NO，ART HOLD。
- 原始 VX E: readonly，私有原圖 owner-only Drive；public GitHub 只有文字程式與證據、不能公開 PNG。
