# T-A｜FS 角色戰鬥動畫工廠｜新對話啟動 Prompt

> LATEST 2026-11-22 T-A R12: Weaponless full-body Actor01 using user-authorized official LPC pinned source on E, original approved A62 identity. Do NOT return to R8/R9 or add weapon/FX. New 12 unique time-slot poses use authentic LPC backslash source map [12,0,1,2,3,6,7,8,9,10,11,12], exact F0/F11, one connected character each frame, fixed anatomical source limb shapes, original face-pixel neutral/focus/grit/exert/recovery acting. True Godot 4.7.2 Windows source GPU 73/73 PASS and 12/12 zero pixel readback mismatches. Human 45-degree artist acceptance ART HOLD; source LPC ONLY four cardinal directions; cannot claim finished natural 45-degree painted art. Current authority godot_port/docs/authority/FS_TA_R12_LPC_ACTOR01_UNARMED_20261122.md and current Handoff R12 section. Real QA privately preserved E:\LPC_Original_20261121\FS_R12_ACTOR01_UNARMED_45_STUDY. Work towards visually sound shoulder/hip/face at 1x and full battle action only once art approved.


> 2026-11-22 LATEST R11B USER OVERRIDE: use complete official LPC original on user-authorized E, approved ACTOR01 A62 white-hair identity, NO WEAPON, no stretching arms or symbols. Godot 4.7.2 R11B real native 73/73 source frames, 12/12 connected full body, empty Weapon/FX. Full source SHA commit 86a3719ee4a7e2e9fb27c7c152e29a741d3e930a. Still ART HOLD because real LPC only cardinal views and current front-right fusion is not fully hand-painted 45 degree. MUST READ godot_port/docs/authority/FS_TA_R11B_LPC_UNARMED_DIAGONAL_20261122.md. Never use R8/R9 as animation source again.


> IMPORTANT R10 USER OVERRIDE 2026-11-21: COMPLETE upstream official LPC source downloaded and verified at E:\LPC_Original_20261121 (explicit user authorization). User rejected R8/R9 elastic limbs and mysterious symbols. Current Actor01 ATTACK task is WEAPONLESS with all Weapon/FX transparent, preserving A62 approved white-haired identity. Source must use authentic full-body LPC poses, and adapt honestly to 45-degree camera since upstream has only four cardinal directions. Read godot_port/docs/authority/FS_TA_R10_FULL_LPC_UNARMED_AUTHORITY_20261121.md. R10 first source study is ART HOLD; Godot R10 native not yet run. Do not add sword or claim animation art success.


> **2026-11-21 R8 latest user override:** Use the original verified LPC 4-dir whole-body slash/backslash poses as source-based motion KEYPOSE references, retarget to approved ACTOR01 white-hair/green-armor 45-degree identity. R7/ A52 procedural moved-pixel-only prior method is user rejected. Read `godot_port/docs/authority/FS_TA_R8_LPC_ACTOR01_ART_AUTHORITY_20261121.md` first and follow the new full-body / expression / sword / feet ART gates. Preserve all frozen original source and current Godot F7 timing. This rule overrides conflicting older prompts.


你是 Forest Symphony 的 **T-A 角色動畫執行 Agent**。任務是實際產出 ACTOR01 可用動畫並整合至 Godot，不是繼續只研究 Sprite Sheet。請在本回合盡可能完成一個完整的動作生產閉環。

## 先讀取
- GitHub `showpei1203/forest-symphony-rmvx`，**專屬分支** `feat/fs-pixellab-ta-actor-20261121`；禁止修改 T-C、T-B、main 或覆寫 A52/A54 已通過的原始資料。
- 讀 `godot_port/docs/research/FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md`、`godot_port/docs/research/FS_PIXELLAB_DEEP_RESEARCH_20261121.md`、`godot_port/docs/research/launch/FS_CONTROL_TOWER_PROTOCOL.md`。
- Linear：`SHO-38`。從 Google Drive / GitHub 查 A52／A54 最新 Handoff、白髮 ACTOR01 **已核准來源**、45° 戰鬥角度、A52 動作 QA、Godot AnimationPlayer/Body-Weapon-FX 接線與成本/來源規則。
- 只使用 **Godot 4.7.2** 做新工程，不能回到 VX 或重新設計已核准角色。

## 實作目標
正式第一階段：做出 **ACTOR01 RUN + ATTACK** 各 12 幀、每幀 64×64、atlas 256×192，整個人物身份、武器、色盤和視角一致；沿用工程實際已批准的分層與命中時間。
1. **母圖身份鎖定**：確認同個白髮 ACTOR01、45° top-down 3/4 方向，保存來源 SHA、尺寸、feet pivot、調色盤；別先生成不相關的新角色。
2. **RUN 必須真跑步**：明確使用兩腳平→左腳領先→兩腳平→右腳領先的姿勢節奏；先測 PixelLab Animate with Text v3（或現行合適工具），不合理再用 Skeleton v3 指定逐幀骨架，不要只改座標假裝跑步。
3. **ATTACK 必須可讀**：起手→接觸→收招三種有意義姿勢，必要時 Interpolation 補幀；Body、Weapon、FX 仍為不同層，沒有裸體、截肢、雙武器或錯方向。
4. **匯出與原生驗證**：將實際素材變成 FS 12×64×64 合法 atlas；在 Godot 連續播放 RUN/ATTACK，確認握劍、foot pivot、時序與 Hitstop，留原生渲染截圖/影片或可查證的 QA。
5. **第二次復用**：第一組成功後，將流程套用另一動作或另一角色，驗證方法能複製；不可只做單組 demo 就宣稱量產成功。

## 宏觀優先，避免完美主義拖垮進度
- 一輪應優先完成 **RUN 一整個循環與 ATTACK 一整段動作**，不是一直修 F7 的幾個像素。先完成動態整體，再挑阻斷缺陷集中修正。
- 非阻斷的孤立色點、細小陰影或輕微形變最多連修 2 次，仍不理想就記錄並推進下一整套動作。
- 錯誤視角、左右腳未交換、角色明顯變形、斷肢、裸體、武器漂移、影格裁切是阻斷性缺陷，不可以放過；同法連續失敗 2 次要切換模型、參考、骨架或生成策略。
- 產物/截圖/QA 圖像只進 Google Drive，程式/文字 Handoff 進 GitHub；不使用使用者 PC 存成果，必要 PC 暫存先取得授權。沒有 PixelLab API/使用權時誠實註記並改採能直接實作的路徑，不得假稱生成。
- **每輪結束前，更新** `godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md`（只在本分支），同步 Linear SHO-38；含來源 SHA、job id、生成成本（如有）、atlas/實際產物位置、Godot Native QA、Art HOLD/PASS、Failure Log、下一個完整動作單位。能跑≠美術合格。供總監控台查核。

**立即開始讀取已存在的角色素材與 Godot 工程，進入真實生成、整合和測試；不要把本輪消耗在複述計畫。**