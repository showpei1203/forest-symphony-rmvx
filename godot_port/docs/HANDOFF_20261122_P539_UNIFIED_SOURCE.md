# Forest Symphony P539｜整份 505 RGSS2 原始程式與 11 RVData 一次性整合

日期 2026-11-22。只使用 Godot 4.7.2，不回 RPG Maker VX。
優先目標：整份 FS 程式作為唯一來源，再同步移植 BATTLE / MENU / UI；取消先猜一個功能、做一個按鈕、再回去查原始碼的微施工模式。

## 已存在的完整原始碼來源
- 原始 E: FS project/Data/Scripts.rvdata：2,457,490 bytes，SHA256 d398178135c5b41622b0e6da763d58af1fbf770c9d24a360a23508800015809a，505 個 RGSS2 load-order 原生段落（包含原樣 zlib Ruby 源碼）。
- 原始全部 11 組 RVData 有源 SHA，與 Data/Scripts.rvdata 同時驗證。
- 原始 505 Ruby 直接執行於 Godot 不可能，因為 RGSS2 依賴 VX Ruby 與 Window、Bitmap、Scene 等 API。不能假裝把原碼放進資料夾就是 port 完成。

## 這次新增的真正整體入口
1. tools/fs_unified_source_bridge.py 從原始 Scripts.rvdata **一次解壓所有 505 腳本而非抽選**，依序保留原 bytes 與 Script ID/name；一併讀取並 SHA 鎖定 11 個原始 Data 資料表，不修改原始 E:；將源程式完整檔 + 11 表封存到 owner-only G: Google Drive ZIP（禁止在 PC 其他路徑輸出，也不得進公開 repo）。
2. 同一次來源解析生成 fs_unified_source_registry.json：每一節真載入次序、hash、類別重開、方法 def 候選、alias 所在行、Cache system/menu/parallax 等靜態資源字串。所有東西都能按 section 追到真正源碼，避免反覆手動翻 505 個檔案。
3. scripts/source/FSUnifiedSourceRegistry.gd 是給 Godot 使用的統一索引查詢入口；缺任何來源、hash、505 次序、11 資料就 fail closed。**這不會執行 Ruby，也絕不宣稱來源腳本已全部翻成 GDScript**。真正動態 alias、boot FS_DB_AUTOSET.apply_all 與 runtime 依序執行仍需要 VX witness。
4. Python 合成 fixture 及 Godot 4.7.2 原生測試已加入 .github/workflows/fs-godot-phase1.yml。

## 用整份程式找到的可行直接更正
- #268 BattleCommandVisual 中目前的有效來源示例是 **5 個縱向 Battle01..Battle05 指令**，原作於 y=230 起向下錯位，依索引調整，而非目前 Godot 暫時 2×2 Grid。不能繼續把 2×2 稱作原版排版。
- #264 BattleScape 有 map_id、area、變數 1000、Troop 的**優先決議順序**，實際原圖來自 Cache.parallax；不是任意背景貼圖。
- #269 原版 BATTLE Status HUD 是更複雜的多個 Sprite 組成；#193/#196 MENU 經多次重開與覆寫，必須從全序列確定生效版本。
- Script #481 是大量 AI/戰鬥邊界 Fixture，絕不能只看名字就假設它不是 Runtime。完整 alias load-time 證據尚需 VX 實際執行。
- 以上是 source 靜態證據，不假裝已完成所有 UI 視覺 parity 或實際 505 runtime override 解決。

## 接下來單位
來源全集先完成 GitHub 工具、私人 Drive 真 505 Ruby + 11 Data ZIP、完整 machine-readable index、GitHub 4.7.2 CI。下一單位直接**依來源全集與 VX 畫面整批處理 BATTLE Scene / Window / BattleScape**，然後同一批處理完整 MENU，避免重複微修按鈕。P537D 已通過的原圖 GPU 6/6 證據保留，但目前 2×2 是實用 interim，不是原版 UI。完全移植的 ART/GAMEPLAY HOLD 不因索引就自動解除。


## owner-private complete import verification, 2026-11-22
The real original source importer has been executed against the user's read-only original E: FS project, with explicit G: cloud-only output. **505/505** source scripts decompressed without loss (10,616,419 raw bytes); original 11/11 RVData source SHAs verified (three initially mistyped expected hash literals were caught and corrected before publication). The bundle has **9,724** lexical Ruby method declarations, **1,604** alias statements and **203** literal Cache image accesses. Original private source ZIP SHA256 a7089ef45dfe4c92260932ffc4c0f21934b43ac0b296eb8ca53c828e4af2e106, bytes 5,342,988; private registry JSON SHA256 d99295658df950382b5e6960c1a7c5d62e8e58c1c3ef5c7552985f57d7889b25, bytes 2,634,464. Drive folder https://drive.google.com/drive/folders/1eIQICCV3QvsMqvs9On8awj5EfML7mtEG, ZIP https://drive.google.com/file/d/1wYjxv4CZ7NUv2axlrjWqNplT_tA6Rug0/view . All original scripts and database data are **OWNER-ONLY**, no GitHub code source leak. Original source is *not* the boot-final dynamic Apply dataset, and all alias semantics remain unverified until actual runtime witnesses. The native owner-private Godot test tests/test_fs_unified_source_private_539.gd checks a real 505 sections and 14 UI/Battle class sections, with source SHA locks; GitHub public CI tests the synthetic source contract only.


## P539 FINAL SOURCE READBACK 2026-11-22
- Original 505 ordered zlib-unpacked RGSS2 Ruby scripts + exact original 11 RVData source tables imported once from E: FS project READ ONLY, into owner-only G: Google Drive. Source SHA checked, no source code/RVData sent to public GitHub.
- Owner-only PRIVATE actual source ZIP: https://drive.google.com/file/d/1wYjxv4CZ7NUv2axlrjWqNplT_tA6Rug0/view . Google Drive provider confirms 5,342,988 bytes, shared=false, owner permission. SHA256 a7089ef45dfe4c92260932ffc4c0f21934b43ac0b296eb8ca53c828e4af2e106. Independently read ZIP 518 entries CRC PASS.
- Owner-only machine readable index: https://drive.google.com/file/d/1bTNctpT-zWbppNVw1i66yUdmJTyCK9rf/view, 2,634,464 bytes, SHA256 d99295658df950382b5e6960c1a7c5d62e8e58c1c3ef5c7552985f57d7889b25.
- Source metrics: 505/505 section order, 10,616,419 raw Ruby bytes, 11/11 RVData SHA locks, 9,724 lexical method declarations, 1,604 alias declarations, 203 static Cache resource literals.
- REAL private Godot 4.7.2.stable.official.ed1daf0bf Windows native test res://tests/test_fs_unified_source_private_539.gd was RUN against staged original full 505 source registry; exit=0, confirms original battle/ATB/BattleScape/MENU method candidates and source section provenance. Public native full CI #44986992752: completed SUCCESS 90/90 steps, no source code exposed in GitHub CI.
- Full source lookup reveals Scene_Battle#update_actor_command_selection candidate defs at #89, #232, #268, #312. Source #312 wraps the previous definition with an action-seal check and alias, so merely copying #268 would miss runtime behavior. Scene_Battle#start appears in 19 candidate positions, execute_action in 15, Scene_Menu#create_command_window in 8. This is exactly why per-method copy/paste is wrong; batch port must preserve alias order/conditions.
- P539 source intake VERIFIED and Godot source Registry PASS, but NOT 505 scripts executed as GDScript, NOT full original combat/DB runtime parity and NOT source-perfect UI layout. Source #268 originally has 5 vertically arranged Battle command icons, current Godot 2x2 interim is NOT original source UX. Next unit should translate whole BATTLE Scene+Windows+ATB+BattleScape from this full index, then MENU as one batch, with actual VX runtime witnesses and GPU. Phase1 ART HOLD and SEAL NO remain.
