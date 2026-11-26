# T-C CURRENT｜2026-11-26 D23 ART-FIRST 真新獨立物件來源／Whiteplate 備援／Godot 4.7.2 Native PASS／美術 HOLD

**最新施工結果（優先於下方 D22/D21 歷史）：**以 D17 **不變**的 `1280×928` Ground 為世界基準（SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`），**真正重新生成**一張 `1474×1067 RGB` 火山工坊、吊車、完整橋樑、路燈與岩柱等**全非地表**物件來源（SHA `cf13df206f06847f7b95815b25b571b16b01fa21ecdbb93794f85e3a13eb6301`）。模型原圖實際是 **RGB 有棋盤格背景，不是真透明**；僅因它是獨立純非地表 plate，才依正式白底備援改採受控 neutral-white/grey-key 轉成 RGBA（SHA `627aaeb545123b56d256c11b2395516dfccedacb6c761604c48b4f95fb02e988`）。另一次生成結果是 **Ground＋房屋混合 Master，明確拒收**，未逆向切成 PAR。這輪不修改任何原 D22 PNG。

經完整物件連通群 **1×** 重排十組物件，D23 A/B/C 三套完整畫面實測：source 前景 overlap **A 3489／B 5305／C 259px**，因此保存 **D23-C** 技術候選；1280×928 真 RGBA `COMPLETEPAR` SHA `6d53adde4ed2bac8f5a5a030006f1e0d40098306d61c8b907042b76ca42296e7`、真 Alpha0 **710596**，最外 5px 高不透明物件 0；PIL 靜態合成 SHA `d58afa632e6b66d684043eaca2cfe61224e7dc3a933dd98c9270c8e08f87c0d4`。從完全空的新資料夾冷建全程三份 SHA 一致。**不是模型直接原生 1280×928 PAR**，只是在 1× 世界作完整物件重佈局。

以已核准來源的官方 **Godot 4.7.2** Linux binary 對真正 D17 Ground＋D23-C 私有 PNG 雙 SHA 驗證、兩張獨立 Sprite2D 同原點、原生 1280×928 開啟 Native screenshot **PASS**；截圖 SHA `9ca2316fb9ab4b266335d6d3ac736b0bc6363941f77fb3e096687d0209663cc3`，和 PIL 靜態合成**逐像素完全一致（diff 0）**。Source original RGB/棋盤格 matte 是下游 fallback，有 1× 邊緣硬度風險；新工坊偏大、短橋世界腳點與原風格尚未通過人眼；**正式 ART PASS 0/12，VISUAL ART HOLD，不覆蓋 D22**。不要再做橋梁碰撞、角色遮擋或存讀與美術無關的工程。

- [**D23 新真獨立原來源／keyed RGBA／全完整 PAR／A/B/C／真 Godot Native／QA／可重建程式與拒收 Master 20 檔私人 ZIP，30,087,017 bytes，CRC PASS**](https://drive.google.com/file/d/1k5q1KZsgOGmfwHGVOU7bBTdUNsy6g_Qx/view)，owner-only readback。
- [D23-C Godot 真原生 PNG](https://drive.google.com/file/d/1puTw6b_oTCApmAh_hSbJPPOnl5noaAu-/view)、[D22／D23 真原生整張 1× A/B](https://drive.google.com/file/d/14tZB-xXEMhg7jn5eTimrp3wyxeCgD4n0/view)、[來源 QA JSON](https://drive.google.com/file/d/10VqzdSwbE9GLR4T1CI7slE_Ldv-UuOoC/view)。
- [D23 完整真來源／Gate／Failure Log Handoff](TC_D23_ART_FIRST_FS_04_MAZE_NEW_WHITEPLATE_TRUE_NATIVE_QA_20261126.md)、[D23 source-locked 1× 生成工廠](../../tc_factory/biomes/fs_tc_d23_art_first_independent_whiteplate.py)。保留原 T-C 主分支與 T-A/T-B，隔離 Draft PR #17 未合併；使用者 Windows E: 未修改、Desktop Remote／Codex／PC Bridge 0。

**下一施工單位仍是整張地圖美術**：比較 D22／D23 兩張原生 1× 是否達 Style DNA；不能僅因 D23 overlap 較少就當成 ART PASS；若新 RGB 去底的煙霧／建築白邊或主工坊比例不合格，應改成**一張真正原生透明、與 D17 Ground 世界座標契合的完整 PAR 新生成**，最多兩輪非致命小修，禁止回去做玩家遮擋和碰撞研究。

---

# T-C CURRENT｜D22 ART-FIRST 新獨立非地表 PAR 候選已實際生成＋原生 Godot PASS｜2026-11-25

**本輪回到美術產出，最新優先於下面 D21 碰撞／遮擋／D20 舊圖的歷史段落**。以凍結 D17 火山迷宮 Ground 1280×928 RGB SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` 為地圖基礎，**新獨立生成 Ground 不含其中的全非地表透明 PAR 原始圖** `1473×1068 RGBA` SHA `7ab52f35107f468439436ff23e43ae879df6a90d9d55039e0fb761273fe32828`。這不是混合 Ground Master，也不是角色遮擋遮罩。原圖10組主要完整連通物件以**1× 無縮放、無 polygon 截斷**重新配進 `1280×928 RGBA` 完整 PAR：D22-B SHA `a7cf732989afe88be6860a2cc1d27092ee9c2e94e696f315aa5bc4ce62033b95`、真 Alpha0 **847,920**；新真靜態合成 SHA `54acc8aa0ce8197ea8a7e1e68d9fc1b9ea4f4c157fb4736a574c8d4fa780be80`。

**D22 真正美術進展**：把擁擠的 D18 鍛造/橋梁家族改成左上大工坊、右上吊車、右側獨立橋、左下小工坊，保留中心更大完整道路空間；前景物件互相重疊 D18 **868px → D22-B 617px**，外緣高不透明貼邊 D18 250 → D22-B 0。先試 A/B 宏觀位置與 raw/matte 四候選，A overlap 2713 故拒收，採 B。Matte 僅移除 556 source 紅色外緣污染像素並清 alpha<=8 / >=240，保留原始無編修來源；**不能說原始 Alpha 完全一致**。

**真 Godot4.7.2 私人素材 1× Native PASS**：來源雙 SHA 驗證、1280×928 NEAREST 原生截圖，PNG SHA `add99e8071f50e002b8c5696deb68a0a6a06a7a0a94d67c67610c36fbb13e105`，對新 PIL 合成有 7862 個像素 RGB 取整差異，最大每通道1／255。生成原圖仍 1473×1068，採整物件 1× re-layout，**不是**模型直接原生 1280×928 一次完成。房屋比例/橋頭實際接地/視角風格/32px 遊戲美術相容，仍 **USER ART HOLD，十二圖 0/12**；完整遊戲整合/ACTOR01/碰撞全部 NOT_RUN，T-C 不再延伸 D21 runtime blocker。

**實際私人備份**：
- [D22 17檔完整 Ground、獨立 PAR 原始圖、新 PAR、Godot Native PNG、全部 A/B、QA + 可重建工廠 Python 封包（13,986,396 bytes ZIP CRC PASS）](https://drive.google.com/file/d/1LJtjHRHl5f8F5FtGBK5uep_f6f243mGQ/view)
- [D22 真 PAR 1280×928](https://drive.google.com/file/d/1cFR_YREdTCd82uNWyI3RxYbfIoo8FRha/view)／[真 Godot native](https://drive.google.com/file/d/1R7KnV8-1cgChPaOMnFoblvU97j6X3v8X/view)／[D18 vs D22 native 整張 A/B](https://drive.google.com/file/d/1nIMAztQ5SEJ4g1upb6vVTsQkT3F470w4/view)／[完整 QA](https://drive.google.com/file/d/1Xla2K_Ty5Te-fKuR7r92OTit79nl5LHD/view)。已 metadata READBACK，私人 owner-only，不會把 PNG/ZIP 放公開 GitHub。
- [D22 真來源／失敗與保留風險／驗收 Gate Handoff](TC_D22_ART_FIRST_FS_04_MAZE_NEW_COMPLETEPAR_NATIVE_QA_20261125.md)；[冷重建的 D22 Python 程式](../../tc_factory/biomes/fs_tc_d22_art_first_independent_par_layout.py)。以 [2026-11-25 ART-FIRST SOP](../production/T_C_ART_FIRST_GROUND_COMPLETEPAR_METHOD_20261125.md) 為最高製圖方法來源，**不改舊資料**。

**下一完整美術單位**：對真正 **D18 vs D22 原生全景**先做整體 ART Review，若 D22 尚未達標，優先改**整張獨立 PAR 原生世界構圖**或回到完整 Ground 作者化，不做欄杆／碰撞／角色深度。至少第一張經使用者美術核准前，**ART 仍 0/12**。本輪 Desktop Remote／Codex／Windows PC Bridge 0，不動 Windows 原始專案、A35、T-A/T-B。

---

# T-C CURRENT｜2026-11-25 ART-FIRST 正式回歸製圖目標（方法更新，非新增美術 PASS）

**這一節是最新使用者指示優先權，覆蓋下方 D21「下一階段投入碰撞／遮擋／存讀」的工作優先序；D21 已完成的 Godot QA 證據照樣保留，不覆寫歷史。**

- **正式方法**：[`T_C_ART_FIRST_GROUND_COMPLETEPAR_METHOD_20261125.md`](../production/T_C_ART_FIRST_GROUND_COMPLETEPAR_METHOD_20261125.md)；[Google Drive 同版 ART-FIRST 方法](https://docs.google.com/document/d/1ao0YyDWoa6CbpTzVojLfifK60DDUuZhjxt2cqZ0fNbA/edit)；已補進 [Drive Ground-first SOP](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)。
- **真正有效的製圖原因**：D17 **一張連續 Ground-only** 比 D16 貼片自然；D18 **另生成獨立真透明完整非地表圖**、主要六組完整物件無 polygon 裁斷，比 D17 切掉 16,915 有意義來源像素更可靠。其前提是**同一 Blueprint/Style Lock/光向/視角/世界原點、Ground 先 SHA 凍結、全部非地表物件完整保留、只做原生 1× 靜態／Godot QA 合成**。
- **不得過度宣稱**：D18/D19 **真私人 Godot Native PASS 是工程結果，不是美術核准**；D19 邊緣較乾淨但重疊 868→1596；房屋／橋梁接地、風格豐富度、自然群落及畫布邊界仍有 ART HOLD。正式十二圖 `formally_art_sealed=0`，不能稱已有「美術達標」的量產模板。
- **下一個完整單位（最新指定）**：以 FS_04_MAZE **D17 鎖定 Ground＋D18 完整 PAR＋D20 真 Godot 1×** 作整張美術基準，只施工完整構圖／世界視覺阻斷，最多兩輪非阻斷微調；若不合格換完整 Ground／PAR 出圖方法。**先取得一張人眼明確 ART PASS，再複製製程至同色系村莊及其餘六地形**。T-C 不再開發 D22 暫定碰撞、角色前後層、事件、戰鬥或存讀；交另一條 Godot gameplay workline。兩張正式來源原圖保持 Drive owner-only，GitHub 僅保存 SOP／Manifest／QA。
- **此回合是方法整理／交接，不是新圖片產出**。新對話必須先讀這一節與 ART-FIRST SOP，歷史 D21 可參考但不得覆蓋美術優先目標。保持 T-A／T-B／主線資產不變。

---

# T-C CURRENT｜D21 FS_04_MAZE 真私人 Godot 4.7.2 橋梁雙向物理／角色深度測試｜2026-11-24

**D21 最新施工結果（優先於下方 D20/D19 歷史）**：沿用 D20 已鎖 D17 Ground `1280×928 RGB` SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`、D18 完整 PAR SHA `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e` 和 D19 完整 PAR SHA `cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1`，**一個源圖像素也未修改**。本輪已使用真官方 Godot 4.7.2 stable 在隔離 Linux x86_64+Mesa 以真私人 PNG 建立 `CharacterBody2D`＋兩條人工暫定 `StaticBody2D` 欄杆碰撞原型；兩版於臨時橋面 centerline y=500 各西→東、東→西 **74 物理步、零碰撞**，向北、向南離橋的碰撞都真正返回欄杆實體。來源雙 SHA／錯版本、錯 Ground 的原生 fail-close 測試 PASS。

**本次真正發現的畫面阻斷：**由於橋面是 **CompletePAR 全非地表的完全不透明物件**，真 Godot 渲染角色在 PAR 下方時和沒有角色的截圖 SHA **完全相同（0 個可見像素）**；測試角色依**臨時橋面區域**切換至 PAR 前方後，兩版皆出現 **225** 個實際角色像素。第一輪 y=530 原生截圖顯示角色踩在前欄杆上，VISUAL FAIL，已依實圖調整到 y=500 重跑成功。這證明需要 Godot runtime 橋面角色深度邏輯，而**不改最新「Ground FIRST → 全部非地表 ONE 完整 PAR」美術規則**。臨時提高 z 仍存在前欄杆遮擋問題，**不是正式 ACTOR01 或整場景 ART PASS**。

- [**D21 真私人 32 檔原生 2D Physics + 原始 Ground/PAR + 影格／負面／Failure Log 全 ZIP，50,695,229 bytes，CRC PASS**](https://drive.google.com/file/d/1ojoEcCcZ2lndkR8JOEl4G18qys-HC4vW/view)。[D18/D19 四圖真原生跨橋/欄杆 QA](https://drive.google.com/file/d/1AnnshQIzgvl1XeyVHV7eCqnCQLvvPgjl/view)、[角色 under-PAR vs above-PAR 真原生圖](https://drive.google.com/file/d/1HShCa_attT1UXI4kIBNcQkiqH6lXVeqz/view)、[暫定兩條欄杆圖層只供 QA](https://drive.google.com/file/d/18Vy0YUcaJq969F1-ASBeAUjTk4S8QIVh/view)、[完整 JSON](https://drive.google.com/file/d/1ka5u3-sTD3y5s9NMjOi7HOlJbtXpZ7I3/view)；正式私人 Drive metadata 讀回確認 owner-only。**圖片不進公開 GitHub**。
- [D21 原生腳本 `native_bridge_walk_probe.gd`](../../tc_factory/native_bridge_walk_probe.gd)；[D21 全來源／QA／Handoff](TC_D21_FS_04_MAZE_PRIVATE_NATIVE_BRIDGE_COLLISION_DEPTH_QA_20261124.md)；[D21 獨立 Failure Log](TC_D21_BRIDGE_PHYSICS_FAILURE_LOG_20261124.md)。
- **真正 Gate：** SOURCE SHA／Ground+PAR 同 XY **PASS**；真正 Godot 4.7.2 私人雙版本原生載入 **PASS**；**局部人工作者碰撞 corridor 的雙向 CharacterBody2D 橋梁走位／越欄阻擋 PASS（暫定幾何）**；橋面角色 `z=1` 遮擋 **FAIL**，橋面 `z=3` **暫定 workaround PASS**；正式全圖 collision / lava / ACTOR01 / 角色遮擋前側欄杆 / 原正式 Godot game-project scene integration **NOT_RUN／HOLD**；人工 VISUAL ART **HOLD**、12 圖正式 **0/12**。
- **下一個完整施工單位 D22：**改用正式 FS Godot 地圖/角色系統，以作者明確核准的橋面行走範圍、前欄杆／熔岩／斷崖 collision 與角色動態深度建立 `FS_04_MAZE` 遊玩測試，對真 ACTOR01 做入橋/離橋/走位/讀存 smoke。別把本次 QA 兩條固定矩形自動當正式碰撞，也不要重生已凍結的 Ground／PAR。
- GitHub 仍同隔離 T-C Draft PR #17，不覆蓋 T-A/T-B；**PC Bridge 0、Desktop Remote 0、Codex 0**，無 Windows E: 修改。

---

# T-C CURRENT｜D20 FS_04_MAZE 真私人素材 Godot 4.7.2 原生 1× 雙版本 PASS｜2026-11-24

**最高優先最新成果（以下 D19/D18 為歷史）**：已解決此前 GitHub source-only synthetic CI 無法驗證私有美術的阻斷！D17 鎖定 RGB Ground `1280×928` SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` + **兩份真正 owner-private 完整 RGBA PAR**：
- **D18 PAR** SHA `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e`。
- **D19 PAR** SHA `cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1`。

實際使用官方 Godot 4.7.2 stable（4.7.2.stable.official.ed1daf0bf），於隔離 Linux x86_64/Xvfb/Mesa OpenGL llvmpipe 環境跑**真正的私人 PNG**，各產一張 **1280×928 1× SubViewport framebuffer 截圖**，雙 SHA、Alpha 及獨立世界原點全部 PASS。截圖對照原先 PIL Alpha 合成：D18 有 15367 個像素、D19 有 15372 個像素 RGB 不同，**最大每通道差異僅 1/255**，無尺寸/整圖對位偏移。真正引擎負面測試：錯 PAR SHA、不透明 Master、全透明空白 PAR 均 exit=2、不產截圖。此前 M2 的「真私有素材 Godot NOT_RUN」狀態**已過時**，現在 M2 原生雙圖渲染 **PASS for D18 and D19**；Game full-project map traversal/collision/ATB／事件／存讀仍 **NOT_RUN**，User ART **HOLD，0/12**。

- [**D20 真私人原生 QA 22檔完整 ZIP，15,378,529 bytes／CRC PASS／OWNER ONLY**](https://drive.google.com/file/d/19H-CgMvpgA1iFYODCYpW2PuYTmtJ9EQY/view)
- [D18 Godot 原生 1280×928 截圖](https://drive.google.com/file/d/1eDyr2FwOk8Mdv3WEjiOe5isYkiWoU2qA/view)、[D19 Godot 原生 1280×928 截圖](https://drive.google.com/file/d/1KsAW1TktV0Weq-gx9u5s-nk5D3y6m8wS/view)、[真原生 1× 雙版本 A/B](https://drive.google.com/file/d/1XRgnE30gIznle8Ca2EAG7SSbwJTGYoz0/view)、[完整證據 QA JSON](https://drive.google.com/file/d/18Gs6WeRVPhGJFOSIy1svz9SbCk7_pSgT/view)。已 Google Drive metadata READBACK `shared=false` 且僅擁有者。
- [D20 真來源、Godot 證據、Failure Log 及門檻詳表](TC_D20_FS_04_MAZE_REAL_PRIVATE_GODOT472_NATIVE_1X_QA_20261124.md)。
- [Godot 官方 binary-only 暫存搬運 CI #45300766962 PASS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45300766962)：不含任何私人圖片；官方 Linux 執行檔由 GitHub Connector 收到隔離容器（SHAs/版本重驗），然後**於容器內讀 owner-private mounted images 真正渲染**。無需 Win Bridge 改白名單、無 Desktop Remote 或 Codex。
- **美術阻斷仍真實存在**：D19 四側 4px 高不透明貼邊 250→0，前景互相交疊 D18 868→D19 1596；橋頭兩岸是否可走、煙霧頂部畫布接觸、底部建築足點、32×32 地圖視覺節奏、人眼 ART 未核准。D19 **不覆蓋** D18，兩套原圖和 Godot 截圖都保留。**ART PASS 仍0/12**。
- **下一完整單位：**以這批**已成功真正原生**的兩圖截圖建立 FS_04_MAZE 遊戲內 1× 走位／橋梁落點與碰撞／角色圖層 smoke QA（盡量沿用既有 Godot 工程，不重寫），之後 A/B 視覺驗收。不要再在同一 blocker 上反覆安裝或重做 Ground。

---

# T-C CURRENT｜D19 FS_04_MAZE 原生 1× 全景安全邊界 PAR + 雙 SHA Godot QA｜2026-11-23

**最新真成果（優先於以下 D18／D17 紀錄）**：在**完全不修改** D17 Ground SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` 和 D18 原作者完整獨立非地表來源 SHA `a0c0f71b9db96d18ec4c8cbddee5f16366609206ec09bc474bbbe714a4dc7780` 的前提下，保留六個完整連通物件群、不裁 Polygon、不 resize，做整張 `1280×928 RGBA` CompletePAR 的新世界配置。鐵橋 `(554,334)` **固定**；D18 四邊 4px 高不透明貼邊 **250→0**，六組重要來源像素 **641682 全保留**。新的 PAR SHA `cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1`，真 Ground+PAR 靜態合成 SHA `c9da92ee753970cbcf528a96cefbec2b8fe7088a0bb80ddffbb528b0cef9428a`。但六物件交疊 **868→1596**，不能直接升級美術；官方 **ART 仍0/12 HOLD**。

- [**D19 私人十二檔完整 QA/來源 ZIP，14,432,637 bytes，CRC PASS**](https://drive.google.com/file/d/1osgVoSOLtuWua-7jUnVebD_XsdlLIqNk/view)；[D19 新原生 PAR](https://drive.google.com/file/d/1QvEN7_DxSB3pvlDW70TDmIeCTD44I6XL/view)／[Ground+PAR 靜態合成](https://drive.google.com/file/d/1vRH8svAtheYP_-UbB_WUjNh0sI0A0xAW/view)／[完整 32px Grid+六群 BBox 視覺 QA](https://drive.google.com/file/d/1k06RyynDHhcA2Ait_HUnVZSWRskahvIk/view)／[D18/D19 對照](https://drive.google.com/file/d/1K59hTfpDrl-I_Fqj_n03gw0cb-qrw5eI/view)。已 metadata **READBACK：shared=false owner-only**。
- [D19 完整來源、補強 Godot 原生、Failure Log 與真 Gate](TC_D19_FS_04_MAZE_SAFE_EDGE_1X_NATIVE_PROBE_QA_20261123.md)。沿用 D18 renderer 的 **可選** placements，D18 default 不變。[D19 CI #45133395097 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45133395097) 回歸涵蓋 D18 預設、D19 六物件、SHA、錯來源拒收。
- 既有 `native_complete_par_probe.gd` 已補 `--par-sha` 第二原圖鎖定、Alpha 全域統計和不透明 Master/空白 PAR 拒收；[**Godot 4.7.2 真原生引擎測試 CI #45133019030 SUCCESS**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45133019030) 已實際啟動引擎/cold-import/兩張 **SYNTHETIC** PNG 原生渲染及三種錯誤拒收。**不能稱 D19 私人美術 Godot 原生 PASS**。
- **M2 D19 私人素材 Godot 原生仍 NOT_RUN/HOLD**：此隔離環境沒有 Godot 4.7.2 bin、官方下載 DNS 不通，現有私人 PC Bridge 白名單沒有 T-C 私人 Drive PNG → Windows 隔離原生 QA 的核准任務。**不擅自越權傳輸圖片或執行任意 Windows 指令**。下個完整宏觀施工單位：審核安全、窄白名單的私人來源導入／Godot 4.7.2 真正 D18/D19 同源原生對照；之後人工評估邊界 vs 交疊取捨以及橋頭足點，才做 ART PASS。
- **正式工作線規則不變**：Ground FIRST → 所有非地表獨立 CompletePAR，不判斷角色遮擋，不逆切 Master、不動 T-A/T-B；D18 私人原圖與舊版 PAR 均保留。Desktop Remote 0、Codex 0、Windows E: 未改。

---

# T-C CURRENT｜D18 FS_04_MAZE 完整獨立非地表 PAR｜六組完整輪廓、零多邊形裁除｜2026-11-23

**最新本輪真施工（優先於 D17/D16/D15 歷史）**：D17 原生 1280×928 Ground RGB 不動，SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`。新生成獨立非地表 RGBA 原作者 1474×1067，SHA `a0c0f71b9db96d18ec4c8cbddee5f16366609206ec09bc474bbbe714a4dc7780`，包含完整工坊/市場、獨立鐵橋、南方工坊、熔爐與兩組獨立裝飾。依 Alpha 連通輪廓 **原始 1× 不縮放** 把六組完整物件配置到 D17 世界，**不從 Master 反切、不裁 Polygon、不按遮人選 PAR**。實際輸出 `1280×928 RGBA CompletePAR` SHA `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e`；獨立 Ground+PAR 真靜態合成 SHA `2e618991676241471271640c7641679857a23b857a7b0048b8338ea991dff620`。

- **M1 真來源＋結構 TECH PASS**：六個最大前景來源 alpha>8 共 **641682** 個像素全保留，無任何 Polygon trimming（**D17 16915 → D18 0**），出圖 Alpha=0 **547026**；物件互相覆蓋 **868**px，原來源其餘 138 個微小 alpha>8 孤立雜訊沒有編入，alpha1..8 邊緣雜訊歸零，保留原圖供追查；並未宣稱「所有原始像素完全不變」。Ground 冷建 SHA 不變，原生冷建與第一次合成 **逐像素一致**。
- **PRIVATE Drive [D18 完整10檔ZIP，10478887 bytes，ZIP CRC PASS](https://drive.google.com/file/d/1pHr699q2mqtI8TPrtb3trX2z0h5cYLUH/view)**。單檔：[獨立新原始 PAR](https://drive.google.com/file/d/1Rdo7WObmlwx4zicWRdS3wpO8T6SAMayO/view)、[新完整 1280×928 PAR](https://drive.google.com/file/d/1HbMxtnvKQMif4V_r7jOX7UyLRUpznCbd/view)、[合成](https://drive.google.com/file/d/14Ws84SnxYSLjOsPVTahT7B86UTCy0Ael/view)、[與 D17 的 AB](https://drive.google.com/file/d/1fyGgF2GuQpmHR9iOhPExTNvBUPJr25Xa/view)、[QA JSON](https://drive.google.com/file/d/1-0zc1cKXvpzRCmycV7uaOjHVKbgcgQCB/view)。已 metadata READBACK owner-only / `shared=false`。私人 PNG 不入公開 GitHub。
- [D18 完整來源、六物件座標、Failure Log](TC_D18_FS_04_MAZE_INTACT_COMPLETEPAR_SOURCE_QA_20261123.md)，[D18 synthetic GitHub Actions #45129375477 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45129375477)。此 CI 僅 code/合成來源契約，不等於私有來源 Godot Native。
- **M2 真私有 D18 Godot 4.7.2：NOT_RUN/HOLD**（現有私人 Windows PC Bridge allowlist 只有 T-A/T-B Godot task，**沒有**核准的 Drive 私人美術 → T-C 1× 原生渲染任務，不能擅自使用非白名單任意指令）。**M3 主要 D17 Polygon 物件截斷阻斷技術修復 PASS，但新原作者頂部煙霧貼邊、下緣建築緊貼畫布、橋頭精確接地與 868 前景重疊等視覺項目 ART HOLD。M4 FS_04_MAZE 第二技術樣本完成，正式 ART 0/12。遊戲整合 NOT_RUN。**
- **下一完整單位**：在維持 D17 Ground SHA 的前提下，先於可授權、可讀取真私有 PNG 的 Godot 4.7.2 環境執行 D18 1× 原生畫面與整張視覺對位驗證，進入 USER ART Gate；若私有來源路由未批准，先按 AI Remote 安全規範設計審核專用只讀工作流程與防錯測試，不能自行開 GUI 或下載私人檔到未核准 Windows 目錄。
- GitHub 仍保留 T-C 隔離分支 `feat/fs-tc-d12-chroma-par-20261122` Draft PR #17，未合併、不碰 T-A/T-B；Desktop Remote 0，Codex 0，使用者 Windows E: 未動。

---

# T-C CURRENT｜D17 FS_04_MAZE 原生 40×29 新連續 Ground＋全非地表 PAR 真雙圖｜2026-11-23

**D17 最新來源成果（優先於以下 D16/D15 舊交接）**：針對 D16 地表有人工羽化拼接與重複紋理的宏觀缺陷，新創作**完整 Ground-only** 火山地表 `1474×1067 RGB`，只做 `(90,70,1370,998)` 1× 等像素裁切，先凍結 Ground `1280×928 RGB` SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`。使用**獨立 D15 非地表原圖**且沿用 D16 工廠工具，以 1× 不拉伸重佈六組工坊、熔爐、旗幟、吊車、燈、右側熔岩橋梁，生成全場景 `1280×928 RGBA PAR` SHA `e455aa491415b453235a11ca0eade3ef2578c937ec7d1f4a6613ccb02bf96334`，alpha-zero **862818**；靜態合成 SHA `0213f24d428d00ffa2a7cf233b33ea09e5367270bded24529c9f639edcda3144`。原 D11/D15/D16 原件與正式來源均未改。

- [**D17 完整原圖／Ground／PAR／真靜態合成／QA／程式 13 檔 ZIP（17,262,967 bytes，CRC PASS）**](https://drive.google.com/file/d/1mxfxme7PZbdFd7XmwwVGOclSClL1lyls/view)；[新 Ground](https://drive.google.com/file/d/1fHMcvGb6W3AaZvI07uN-GsSrLe0h5c2k/view)、[新 PAR](https://drive.google.com/file/d/1syxXfi7ykoO_s8m4KoE-R6WhnYD-2xb2/view)、[真實合成](https://drive.google.com/file/d/1QU0MOktXjbYnQ3Iwf5OLXlRtiNtvQ5r0/view)、[D16/D17 A/B](https://drive.google.com/file/d/1CG_g2voyl8sL7agIqHTSQHgm2dXHH1d-/view)。重要 Drive 項目均已 READBACK：shared=false，權限僅 owner。
- [D17 完整 Handoff + Failure Log](TC_D17_FS_04_MAZE_GROUND_FIRST_COMPLETEPAR_SOURCE_QA_20261123.md)；[D17 GitHub Actions #45115468630](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45115468630) **SUCCESS：SYNTHETIC Ground-first / 1× 來源驗證**，不等於 D17 私有圖真正 Godot native。
- **Gate：** SOURCE/STRUCTURE 及 Python 真實靜態 QA **TECH PASS**；D17 真私有素材 Godot4.7.2 原生 **NOT_RUN/HOLD**（未通過授權私有素材進入現有 Godot 原生執行環境）；VISUAL ART **HOLD**（沿用 D16 Polygon 物件裁邊仍損失 16915 source-positive pixels、867 同一畫布不透明重疊像素、橋與工坊足點尚未 ART Gate）；INTEGRATION **NOT_RUN**；正式 ART **0/12**。
- **規範優先：** 使用者最新 Ground FIRST → 所有非地表獨立 CompletePAR，拒絕混合 Master 逆切及角色遮蔽子集。額外圖片生成器這輪產生錯誤全景 Master，已拒收，不以自動化流程回收其建築。下一完整單位：讓此**已鎖 D17 Ground**配到真正一次創作、原生 1280×928、無切斷建物的完整 PAR，接著由經核准管道執行真 Godot 4.7.2 1× 截圖與人工 ART，禁止把 synthetic CI 當真人工/原生通過。
- GitHub 仍使用同一 T-C 隔離 `feat/fs-tc-d12-chroma-par-20261122` Draft PR #17，不影響 T-A/T-B/另一條 T-C；正式圖片只在私人 Drive，沒有 Windows 檔案修改，也沒有 Codex／Desktop Remote 呼叫。

---

# T-C CURRENT｜D16 FS_04_MAZE「熔脈裂橋」第二場景 1280×928 Ground-first + PAR 技術候選｜2026-11-23

**最新真成果（覆蓋下面 D15/D14 歷史的進度，未覆寫舊成果）：** 因 D15 原始 1474×1067 全物件 PAR 不能只靠刪除透明 seam 直接無損壓入 1280×928（寬最多 71/194px，高 0/139px），依宏觀 Roadmap 開展第二火山樣本 FS_04_MAZE。已實際創建 **Ground-first 1280×928 RGB**（D11 Ground-only 來源的全場景再配置）→ 鎖 Ground SHA → 使用 D15 *已獨立生成的所有非地表美術* 批量 1× 重排六組全物件於 **獨立 1280×928 RGBA PAR** → 真正 Image.alpha_composite 靜態 QA，無 Master 逆切、無拉伸到目標假裝原生、原 D11/D15 source 完全不動。

**工程 SOURCE/STRUCTURE 技術 PASS，VISUAL ART HOLD。** D16 原地圖道路拼接痕、素材多邊形截斷、鐵橋與熔岩岸接點不一致；這是 **現有素材技術重組**，不是一次式 AI 在原生畫布完整生成成功。**D16 真私有素材 Godot 4.7.2 Native NOT_RUN；正式 ART 仍 0/12。**

- [D16 10 檔私有素材、Ground、PAR、合成、SHA / 物件台帳 / Failure Log / 重建程式 ZIP](https://drive.google.com/file/d/14Tk-mbngKeENcFfdF3vdIE9OMVifchfm/view)：11,296,467 bytes、ZIP CRC PASS，私人 owner-only READBACK。
- [新 Ground](https://drive.google.com/file/d/1lyl6X9dDOeeNL0xToShRX1NzgYUd-DGN/view) SHA `6c5f9d8bfbeeb96ec8da2c43cd19cc74159208853ace4963affe1f31e03136a9`， [新 PAR](https://drive.google.com/file/d/1_CjVpdp4aXUxGGzqnULrk_P-OgRGwXpg/view) SHA `fc3333e32f80fb980fbeaabcae02bf6fa942a5079b13eca2fa906a06b1715e6a`， [靜態合成](https://drive.google.com/file/d/1eB0mGISovFixesr18xspquONdjCaD9GX/view) SHA `83f7a3275a4f02bd111dae99020f1d5df1ed8fdc7ea667f9f34831bbd46ee78c`。
- [GitHub Actions #45112426928](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45112426928) SUCCESS（**synthetic 結構回歸**，不是這批私有美術 Godot native）；[D16 完整 Handoff / Failure Log](TC_D16_FS_04_MAZE_COMPLETE_PAIR_TECH_QA_20261123.md)。
- D15 FS_04_VILLAGE 原 Ground / 第三版 PAR 均保留、不合併 Draft PR #17；新素材僅私人 Drive。舊 Master-first Roadmap 條目與最新使用者 Ground-first + ALL NON-GROUND PAR 規範衝突，以後者為準。
- 下一完整單位：針對 FS_04_MAZE 生成**真正原生世界 1280×928、美術自然連續、橋路/熔岩精確接點**的獨立高品質 Ground/PAR 兩圖，拒絕繼續裁拼掉物件；再使用經授權的私有素材路由跑真 Godot 4.7.2 1× QA，修正阻斷後才評 USER ART Gate。M4 現為第二場景技術候選，不是量產 PASS。

---

# T-C CURRENT｜D15 灰鑄工坊城 CompletePAR 封閉白底島修復、私人來源及 QA｜2026-11-23

**本輪實際新成果（優先於 D14/D13/D11 歷史）**：重用 D14 獨立全非地表白底 RGB 原圖，不重做 Ground，不從 Master 逆切，修正原 white-key 演算法漏掉的**五塊大型封閉白底**，D15 另存真透明 `1474×1067 RGBA` PAR，SHA `1063c9bd0180e771da32ffffbcc5c00b6e409bffbc603524c17001010ae0c3a9`，Alpha=0 **734965 → 776139**。右側橋區合成近白色像素 **20781 → 336**，主要火山道路與熔岩露出。Ground 原 `1280×928` SHA `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d` **完全未改動**。

**正式限制：PAR 仍是 1474×1067 原尺寸，不是符合 40×29 的 1280×928 原作者新圖。** 目前整張 1280×928 預覽採 LANCZOS 下縮且明確標 TECH ONLY；強裁會切掉 106197 個高不透明物件像素。**D15 私有圖片 Godot 4.7.2 真原生 NOT_RUN，VISUAL ART HOLD、正式 ART PASS 仍 0/12。** M1 真完整 PAR 技術修正版 PASS；M2 私有 Godot NOT_RUN；M3 白洞阻斷修正 TECH PASS；M4 第二樣本 NOT_RUN。

- [D15 8 檔私人來源、真 PAR、前後對照與 QA ZIP](https://drive.google.com/file/d/1E8bf_o8UquJQYP3UoayzibCks6f4phKW/view)，13,580,705 bytes，CRC PASS，SHA `76523e688a050abb956ad8dda9e71bcb47d4171bd474c1e810bc385f18220571`。
- [D15 新真透明原尺寸 PAR](https://drive.google.com/file/d/1aOF1RIUpHjyJdXnB30bxD3XxEtZZ3kEV/view)；[真合成 TECH 預覽](https://drive.google.com/file/d/1O4CiQ_K5PHKyFDht_BfSJTz25Wi2GcRt/view)；[D14/D15 視覺對照](https://drive.google.com/file/d/1b2Y7bfikStctKgZR6geR0VcOoenZHmeD/view)；[完整來源 QA JSON](https://drive.google.com/file/d/1C3HD6mAfqt-V2rv7fxhypFybO4vMiGoO/view)。
- 更新既有 `fs_tc_white_plate_to_complete_par.py` 的可選 `--repair-large-enclosed-background`，沒有重寫已通過工具；新增大型背景 vs 小型白色裝飾反例測試。[新白底透明化 CI #45101082116：SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45101082116)，[初次測試資料設計錯誤 #45100966246：FAIL](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45100966246) 已明確記錄，實際暗部物件像素與 Ground 保留。
- [D15 完整 Handoff／來源／Failure Log／後續施工規格](TC_D15_FS_04_VILLAGE_WHITE_VOID_REPAIR_SOURCE_QA_20261123.md)。正式圖檔保存 Drive，非公開 GitHub；私人 Drive readback owner-only。
- **最高規則差異記錄**：舊 PixelLab Roadmap 含 Master-first 四層的過時方案；使用者最新 + Drive 正式 SOP 優先 `先獨立 Ground → 同世界座標全部非地表獨立透明 PAR`，不反切 Master、不判斷遮擋玩家、不要用 NAV/事件當施工進度。
- **下一完整單位**：不重生 Ground，真正取得**原生 1280×928、完整物件不裁邊、1× 像素對位**的 PAR；再利用既有 Godot 4.7.2 native probe 在可授權私有來源的路由跑真渲染，做人工 ART Gate。沒有核准的私有來源傳輸／Bridge 任務則標 M2 HOLD，不能把 synthetic Godot CI 借來。

---

# T-C CURRENT｜D14 FS_04_VILLAGE 第二張獨立真透明完整 PAR + Godot 4.7.2 Native 工具實測｜2026-11-22

**最新成果（優先於以下 D13/D12/D11 歷史）：** 在 D11 原 Ground 不變下，D14 重新生成整張工坊城**只有非地表物件**的 `1474×1067 RGB` 白底來源。新的 deterministic white-background matte 已成功轉成真正 `1474×1067 RGBA`（Alpha=0 **734965** pixels、Alpha255 **830440**），不從含 Ground 的 Master 反切。新全圖物件風格更清晰，已製作和 D13 的完整 Ground+PAR 靜態合成對照；已實際封存 7 檔 ZIP 和來源、預覽、QA 至私人 Drive，readback owner-only。

**品質狀態：原尺寸仍未達 1280×928／40×29 原生 1x。** 白底 source 1474×1067，強裁會失去 **106197（12.785%）** 高不透明物件像素；完整縮小版只是 TECH PREVIEW。**D14 真人工 ART HOLD；十二圖 0/12；這批私有美術的 Godot 4.7.2 native NOT_RUN。**

- [D14 私人 7 檔完整來源 QA ZIP（11706995 bytes，CRC PASS）](https://drive.google.com/file/d/1oZU9YY02lZTK5Vd3vlP60e_j6252tf_v/view)
- [D14 原始白底非地表](https://drive.google.com/file/d/16dnEC5xXPlPZOJ7dY5J4LCQ8blXI80Pu/view)，[D14 新全物件真透明 PAR](https://drive.google.com/file/d/1z4jFTtpQ5MGOmMeAI7k-qtWmku_XtMF9/view)，[Ground+PAR 合成技術預覽](https://drive.google.com/file/d/12MCDzxl3NcOPrV8mAK6aLdgTG-bWrqrO/view)
- [D14 D13/D14 四圖對比](https://drive.google.com/file/d/14cM9AwYzHiC7G5GImBQA3mx4yBmUMah6/view)，[詳細新來源／Alpha／Godot／Failure Log](TC_D14_FS_04_VILLAGE_WHITE_PLATE_TRUE_RGBA_NATIVE_PROBE_QA_20261122.md)
- **真 Godot 4.7.2 引擎測試**：[原生 1× 雙圖層合成 CI #44997754667 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44997754667)，不過僅用 synthetic 圖，不是 D13/D14 私有圖片，勿誤稱新美術 native PASS。既有 D1 雙圖設計沿用、不新造另一套地圖框架。
- [白底轉透明背景防錯 CI #44998273527 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44998273527)，可維持原 RGB 白底來源、真 Alpha、拒收 RGB 全景 Master／空白及 Ground SHA 篡改；此工具並不負責原生畫布或美術驗收。
- **D13 SHA 錯誤已修正**：原 1× crop `5ba2083578b9acdc3c4e2c58208420c4900de4258420a9f47c177ef3e7db6d4f`，縮圖 `0bc33afa55684df60c0301391e945f182a30776cb2b7fae4db7f1f99081a4aff`，同 Drive 真 source QA，原圖均未改動。
- 下個完整單位：依同一 FS_04_VILLAGE Blueprint 一次性生成 **native 1280×928、完整、無裁物件、真透明** PAR，參照 D14 整城風格與 D11 Ground 世界座標，再用 D14 native probe 對真 source 在 Godot 4.7.2 驗收。不要反切 Master、不要判斷角色遮蔽、不要以 TECH 預覽當 ART PASS。

---

# T-C CURRENT｜D13 FS_04_VILLAGE 已生成真正透明完整非地表 PAR 美術候選｜2026-11-22

**最新真成果（優先於 D12/D11 歷史）：** 新獨立工坊城全物件 PAR 圖檔已生成，原生來源 `1474×1067 RGBA`，**alpha=0 真透明像素 715393**，非 Ground/Master 逆切，涵蓋工坊、熔爐、煙囪、鐵橋、礦車、吊車、石柱、旗幟、路燈。原 D11 1280×928 RGB Ground 維持 SHA `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d` 不變。

**正式 ART 仍 0/12 HOLD，Godot 4.7.2 原生 NOT_RUN。** 新 PAR 來源不是正式 1280×928（40×29）1× 尺寸；真 1× 裁切雖可配對但截建築邊緣，整圖下縮技術候選雖能保留全物件並與原 Ground 靜態合成，但不符合 native 1× 原生美術要求。Raw PAR 有 alpha1..8=121578、alpha240..254=641638；另存 clean-alpha 候選，未修改原圖。世界落點仍需人工/原生 Godot 驗證，不把靜態合成當 ART PASS。

- [D13 私人真來源、兩種 1280×928 PAR 候選、合成圖、完整 QA 十二檔 ZIP（22,036,770 bytes、CRC PASS）](https://drive.google.com/file/d/18IkobPFjRE4XqRFXZBLpX5-aqbz8H8IY/view)；私人 owner-only metadata READBACK 完成。
- [獨立原圖 PAR](https://drive.google.com/file/d/1NuEbPwE4nJXZ1r6KLCaChxyAh4Pr58P-/view)，[1280×928 靜態合成](https://drive.google.com/file/d/15VgqAHsx_CNVMDdfc-TABZsx5tnfR2Wp/view)，[完整來源及 Failure Log](TC_D13_FS_04_VILLAGE_INDEPENDENT_RGBA_PAR_SOURCE_QA_20261122.md)。
- D12 [可控 Alpha 備援程式及合成保護 CI](TC_D12_INDEPENDENT_CHROMA_COMPLETEPAR_ALPHA_BRIDGE_20261122.md)、[GitHub Actions #44995939096](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44995939096) PASS，為 synthetic tests，**不是 D13 native／ART PASS**。D13 已直接生成真透明 RGBA，不須從 Master key-out。
- 下一完整美術單位：參照既有 Ground 及 D13 完整工坊城風格，取得**原生 1280×928 且邊緣物件不裁斷、對位準確**的第二階段獨立 CompletePAR；QA 後才跑 Godot 4.7.2 原生、美術確認。Ground 不重新生成；不分析遮擋角色、不反切 Master、不修單顆樹。

---

# T-C CURRENT｜D11 赤焰火山「灰鑄工坊城」真 Ground-only 候選出圖｜2026-11-22

> **D11 封存後增補（透明模式最後一次再試）：仍 FAIL。** 第六張輸出 `1477×1065 RGBA`，alpha min/max `209/248`、**alpha=0 count 0**，SHA `4fb03231f912096edb4f4b6496cb0bd628f95d42a881c9387d8e8ad3b946fcf1`，仍是整張全景火山城而非透明 PAR。拒收，不納入先前 5 次失敗的六檔私人 QA ZIP（該 ZIP 維持原核驗 SHA），不冒稱已有 CompletePAR。此出圖方式在本輪停止重試；下個單位須使用確實可控透明背景、同來源 XY 的另一條生成流程。\n\n**實際施工新成果：FS_04_VILLAGE「灰鑄工坊城」已新生成真正火山玄武岩／熔岩 Ground，原始 1477×1065 與不縮放 1280×928（40×29）及 46×33 全構圖備份已上傳私人 Drive。完整透明 PAR 連續五次失敗（RGB一張、RGBA四張皆沒有任何 Alpha=0），全部拒收，正式 ART HOLD、Godot 4.7.2 NATIVE NOT_RUN；十二張地圖正式 ART 仍 0／12。** 此段優先於下面較早 D11 首次沙漠誤圖及 D10 歷史。

- 使用者最高規則：**先獨立生成純 GROUND，再用同一場景完整生成含所有非地表物件的透明 PAR；不判斷是否遮人、不逆切 MASTER，也不因角色碰撞細節阻礙整圖製作。**
- 真火山 Ground：原始 RGB 1477×1065，SHA `ecd256d48aaa7c4fc33b0c0f19bd5b516c998239c779e927468aa4ebc3d33af4`。黑色玄武岩、灰色火山灰鋪面、熔岩裂隙、放射式道路與中央圓形廣場，沒有主要房屋、煙囪、熔爐或鐵橋。精確 crop `[98,68,1378,996]` 得 1280×928／40×29，原生不縮放，SHA `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d`。Ground 邊緣岩層高度感尚待美術純度審核，**不是最終 ART PASS**。
- 完整 PAR 失敗 5 次：一張 RGB 不透明 Master，另外四張雖 RGBA，但 alpha range `144–249`、`184–248`、`218–249`、`156–248`，全部 **alpha=0 pixels 0**，仍是畫滿地面、熔岩、建築的整張火山城。錯圖拒收、不交付為 PAR、不反切 MASTER、沒有合成 PASS。
- **Google Drive 私人封存並 READBACK**：[D11 六檔 Ground原圖／40×29／46×33／Grid QA／Failure Log ZIP](https://drive.google.com/file/d/11jWGIU54Lk8eyfwLGJs-YbKZU1W6ezIM/view)，11,777,655 bytes、6 files ZIP CRC PASS、SHA `80e74d17f3db3b0af26a523339a85fae23e6eae4ed1f1058114a63a3b59107f0`；[Ground 40×29](https://drive.google.com/file/d/1O8lKij4P8JgxczP2Q1Ykt-RKnhyk56RL/view)、[原始 1477×1065](https://drive.google.com/file/d/1fmrna0wMmv24LRxokUNn3b6mNEOd1aRb/view)、[46×33 參考](https://drive.google.com/file/d/1BKyxcOfGPglyw-0pnChwVXUhYjsD0siN/view)。四項均 readback `shared=false`、user owner only；圖只存 Drive，不碰使用者 PC。
- 實際 [D11 詳細來源、失敗與完整下一施工單位](TC_D11_FS_04_VILLAGE_VOLCANO_GROUND_FIRST_SOURCE_QA_20261122.md)，[場景 Blueprint](../../tc_factory/biomes/FS_04_VILLAGE_GROUND_FIRST_BLUEPRINT_20261122.json)、[12 地圖台帳](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) 均已更新，正式封版 **0/12**。
- 防重複畫錯地形：既有 `fs_biome_identity_guard.py` 新增火山玄武岩/熔岩粗辨識，和 `test_fs_biome_identity_guard.py` **8/8 synthetic PASS**，真 [GitHub Actions #44994736999](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44994736999) completed/success；**只辨地形，不能冒稱 Art PASS**。
- 下一完整單位：**保留這張 Ground**，改用真正可控 Alpha=0、參照同一 Ground 位置／風格的生成來源，產生一張「所有非地表物件一次生成」的獨立 transparent PAR（工坊、熔爐、煙囪、鐵橋、岩柱、旗幟、燈柱、礦車等）。若新工具仍只產全景 Master，拒收並換路線；不修單顆樹、不拆玩家遮擋。等真雙圖才能做原生 Godot4.7.2 QA。其後同色盤 FS_04_MAZE 熔脈裂橋及 05水澤/06星晶。

---

# T-C CURRENT｜D10 FS_03_MAZE 風沙裂谷獨立真透明 CompletePAR 已完成雙圖候選｜2026-11-22

**新成果：D10 真正產出有 Alpha=0 透明背景的 PAR，與 D9 不變的砂岩迷宮 Ground 依同一像素裁切合成成功，46×33 來源候選已存私人 Google Drive、原圖 SHA／四圖預覽／完整 QA 已驗證；正式 80×58 尚未達成、Alpha 雜點／橋樑落點與角色通路待美術驗收，ART HOLD、Godot 4.7.2 NATIVE NOT_RUN。** 最新權威，後面 D9/D8 為歷史。

## D10 真實完整雙圖階段與來源

- Ground first：原來源 D9 真 RGB 1477×1065 SHA `b9ddee18bf3eb4386363a2d6321b0ad745c64cb1149b862489d4160defaa9e59`，46×33 Ground SHA `2e78610422ff373f07382b2bcb4980d3f11bf63c3e078cf489e2bc42f55b66fd`，這輪沒有重新產 Ground。
- 獨立第二階段 **真正透明完整 PAR**，原圖 1477×1065 RGBA SHA `2c71dae5d32b9ff0465d9863f5de74fc6561f58e6f1e84f00141696cd4426768`；包含立體砂岩柱、整棵棕櫚、仙人掌、拱門、橋、遺跡、化石與旗幟，不依是否遮玩家而抽選；不是從 Master 逆切。
- Ground/PAR 以 **同一 crop [2,4,1474,1060]** 不縮放產出 1472×1056／46×33；PAR raw crop SHA `811cebe3a1e57b9fd470e412dbd382e8310e5e4ace536bdb7ec1be146ce5cb37`、獨立 alpha clean candidate SHA `149bee6b2d3ed8b2b6687fbd769523908a2e885610d5774205904843a351a174`、真原像素合成 clean SHA `873303bdd35095ab230c0f7ac07355b957b146cb0fa6e64217337e3bed50a169`。
- 原生真透明 pixels **883,411 alpha=0**，證明不再是 D9 三次無透明像素的整張 Master；但 **206,896 alpha1..8** 雜色及 **364,768 alpha240..254** 近全透明／不透明轉換，ART HOLD。alpha clean 只將 ≤8 歸0、≥240 歸255，不改 RGB，原始 PAR 保留。
- 靜態合成與四圖對照已實測；**落點不保證**：即使同畫布、同 crop，因兩張是分別生成的圖，橋樑可能沒有真正跨過 Ground 裂谷／接到道路，不能將同尺寸當語義 registration PASS。邊緣不透明物件 alpha≥225 pixel hits top250/bottom461/left319/right688，可能截掉完整物件。**正式迷宮仍要 80×58／2560×1856 原生，不能最近鄰拉大。**
- Google Drive **[十檔 Ground／真 PAR／合成／QA 私人 ZIP](https://drive.google.com/file/d/1JG8UpKDYCvMlxWghZSxxk1sKvnlvdpxa/view)** 20,827,804 bytes／ZIP CRC PASS／SHA `eaca8acea98383897433cbdc21c5c14b96f97ac611c93184566dd30bc655c2d0`。個別 [raw PAR](https://drive.google.com/file/d/182WGOsWuA0cPO106lLS1I2O3uq9hTCqI/view)、[clean PAR](https://drive.google.com/file/d/1x0AoC0-qJy3N2Q34WMcs6C7KXEWyfftf/view)、[全圖合成](https://drive.google.com/file/d/1jhTW5JeNQkjRJY-r0B1tfXqAFD4bXTIL/view)、[四圖對照](https://drive.google.com/file/d/1ykZHCfxt9mm-eSMFrIAkmk7hl_x1_8WM/view)，五檔 Google API readback 均 `shared=false`／only user owner。未把 PNG 上傳公開 GitHub，沒有操作使用者 PC。
- 詳細 [D10 完整 QA＋Failure Log](TC_D10_FS_03_MAZE_GROUND_FIRST_COMPLETE_PAR_PAIR_20261122.md)，[12-scene 台帳](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) 已從 D9 PAR NOT_GENERATED 更新 D10 實際真 RGBA 來源＋靜態合成候選，正式 Art-Sealed **0/12**，Godot 4.7.2 Native **NOT_RUN**。

## D10 接續赤焰火山／灰鑄工坊城第一輪拒收（FS_04_VILLAGE）

- 已真正請求新生成 `FS_04_VILLAGE` 灰鑄工坊城的**黑色玄武岩、灰白火山灰、熔岩岸、礦渣**純 Ground-only 場景，應**不含立體屋舍／熔爐／鐵橋**（這些需後續完整 PAR），官方 size 40×29。
- 圖像生成器錯誤輸出原沙漠迷宮的 **1477×1065 RGB 金黃砂岩圖，包含仙人掌、紫晶、遺跡、橋樑和礦洞**，完全沒有熔岩與火山地貌，源 SHA256 `c730e9138043668c1ea1d745a8efab0024e3b065fa29bf4489d0bd253f13b208`。**FAIL_WRONG_BIOME_AND_NOT_GROUND**，拒收；不把它上傳正式私人資產，**FS_04_VILLAGE 仍 NOT_GENERATED**。
- [十二張圖 T-C 狀態表](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) 已登記 D11 這次生成失敗與 SHA，而非新增一張「完成」的火山地圖。D10 真正完成的風沙裂谷 Ground＋PAR 候選／私人 Drive 不受影響。
- 原生 Godot 4.7.2 D10/D11 **NOT_RUN**；正式 12 圖 Art-Sealed **0/12**。真正下個單位要能可靠切換場景地形，始終以**先純 Ground，再全非地表 PAR**方法兩次完整生成，不能將沙漠色盤硬當火山使用。

## 下一宏觀施工單位（避開錯誤的微修模式）

開始 **04 赤焰火山**，FS_04_VILLAGE「灰鑄工坊城」先獨立 Ground，再 CompletePAR 所有非地表，與沙漠完全不同的火山玄武岩／火山灰／熔岩岸／礦渣、熔爐／工坊屋／鍛造設施；再 FS_04_MAZE「熔脈裂橋」，接著 05 幽霧水澤、06 星晶浮島。每一張都按同一 Source-first Ground→all-non-ground PAR，不篩選遮角色、不以靜態合成 PASS 冒充 12圖 Art Passed。等有真正 80×58 來源／世界對位方案再處理迷宮正式封版，不要重修個別屋頂或樹冠。

---

# T-C CURRENT｜D9「風沙裂谷」真正 Ground source 及 PAR 失敗診斷｜2026-11-22

**本輪確實產生風沙裂谷 FS_03_MAZE 的獨立砂谷 Ground 原始 PNG，原圖＋46×33 原像素候選＋QA 六檔私人封存；PAR 連續三次輸出非透明全場景，全部拒收。正式 80×58／2560×1856 未達成，正式 ART HOLD 0/12，Godot 4.7.2 native NOT_RUN。** 這一段優先於下方 D8/D7 的歷史交接。

## 真 Ground 生產與 QA

- 新原生 Ground-only 構圖：蜿蜒砂路、多個岔口、迴路、裂紋、砂岩臺地；沒有綠洲村房屋、噴泉、市集或棕櫚。**來源 RGB 1477×1065** SHA256 `b9ddee18bf3eb4386363a2d6321b0ad745c64cb1149b862489d4160defaa9e59`。
- 原圖 crop `[2,4,1474,1060]` 後 **1472×1056／46×33 格、32px 不縮放**，SHA256 `2e78610422ff373f07382b2bcb4980d3f11bf63c3e078cf489e2bc42f55b66fd`。這不是正式 FS_03_MAZE 的 80×58 source，美術純度仍有峽谷立體崖壁混入 Ground 的待辦，不能以技術截圖冒充 Art PASS。
- 三個新 PAR imagegen 嘗試全 FAIL：各自 RGBA 1477×1065，alpha extrema **(205,249)／(181,248)／(214,249)**，**三張 alpha=0 像素均為 0**，且畫的是整張不同峽谷場景，並非與 locked Ground 同源 XY 的透明全非地表 PAR。拒收、不 Master 逆切、不冒稱合成成功。
- 已寫 [正式 D9 六檔 QA／Failed PAR 完整紀錄](TC_D9_FS_03_MAZE_GROUND_FIRST_SOURCE_QA_20261122.md)，更新 [十二張正式地圖進度表](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json)。
- **[Google Drive D9 原圖、Ground-only、Grid QA、Failure Log 六檔 ZIP](https://drive.google.com/file/d/1HC6r2i0Dcd3mLizGZRG9HzGUtMSh8Yc4/view)**：10,819,294 bytes、ZIP CRC PASS、SHA `3cf8250c084b9498233748eccaff664b9bfd1f63a50976ddbbf5ad6bc56c5227`；[原始 RGB Ground](https://drive.google.com/file/d/1LUumF1zF--hjBfREqpAlNoMUHQtbzMs-/view)；[46×33 裁切候選](https://drive.google.com/file/d/1KoPtJ47HDSDtYEmt2s_sMd0pwh7jdC16/view)。三件均 Google Drive metadata READBACK **shared=false、permissions user owner only**。沒有操作使用者 PC，沒有把私有 PNG 上傳公開 Github。
- **施工規則不變**：先完整 Ground，後將**所有非地表物件**生成為獨立、透明的 CompletePAR，不判斷角色遮擋，不從 Master 反切。現在的瓶頸是要換/連接能真支援 Alpha=0／同一 Blueprint／指定尺寸的完整生圖供應者；沒有接通不得說有新 PixelLab/fal API job。

## 下一完整單位

取得能成功分離 Ground+完整 PAR 的真正圖像生成來源，先完成 FS_03_MAZE 對 80×58 原生世界格的輸出和真正透明 PAR。若生成器再返回全景 RGBA 但沒有透明背景，立即 Gate FAIL，不再重複同一失敗。此後按 04 火山、05 水澤、06 星晶兩張場景每系量產；只有圖片實出且 1× Godot/Art gate 通過才可宣布封版。正式目前 0/12。

---

# T-C CURRENT｜D8 星井綠洲 Ground-first＋真透明完整 PAR 已成功合成｜2026-11-22

**這一輪有實際全新美術來源：FS_03_VILLAGE 星井綠洲 D8 的獨立透明 CompletePAR 生成成功，與既有 D7 沙漠 Ground 來源在相同世界座標合成為 1280×928／40×29 完整村莊候選。兩圖 Pixel Alpha 合成 TECH PASS，正式全圖 ART HOLD，Godot 4.7.2 native NOT_RUN。** 本段最新權威優於下方歷史 D7。仍嚴守使用者 Ground-only first、再 ALL_NON_GROUND PAR；不推理何物會遮擋角色，也不從 Master 反切。

## 真新產圖／可驗證原檔

- Ground 不變：D7 先生成 1477×1065 RGB 原圖 SHA `8f8c0ac66359bf8bc47e00beb889a4e66c5f2c9d339b00f9cf05957818556f91`；本輪再驗 byte-level，40×29 原裁 Ground SHA `ac3688112874cd45a38f484b8c37dbc0b8f6abd41b67cc0c578bc95f0935aa97`，未覆寫 Ground。
- D8 獨立新 ImageGen 真透明沙漠 PAR，1477×1065 **RGBA** SHA `47e3225ddb6399b19647265220783197d06d57729e15c4ca13a2fbf182929988`，有不同砂岩房、完整棕櫚、藍紅布棚、市集、燈柱、水井、招牌、岩柱與全部非地表裝飾。原生 Alpha=0 真背景存在，不是 D7 兩張錯誤冰雪圖。
- 同原世界座標 `crop=(98,68,1378,996)` 得 1280×928／40×29，無重採樣；真 raw PAR SHA `4fe7eacf0ba79f123963de2d03e15d14f4e2980287c0213d6744d3833c78c4b6`，另 clean-alpha 技術候選 SHA `16e9b4ba8ecf201fd43185ac7092fe1603433069b86eb1ecc213797b696f85f2`，真 CLEAN COMPOSITE SHA `bd616d80613727233037b6c5f4baf28e22d009772ff979fc3147afa1eda757ba`。
- 46×33、1472×1056 的原場景「少量裁邊視覺參考」也已保存，避免忘記完整原始物件構圖；**這不是 FS_03_VILLAGE 正式大小**。

## 真 Alpha／Art Gate

- raw 40×29 PAR：alpha0 `548,678` pixels、alpha1..8 `185,051`、alpha240..254 `357,713`、alpha255 `206`。**原圖 Alpha 不乾淨**，只製作可溯源的 alpha≤8→0、alpha≥240→255 技術後製，未覆寫原始圖、未改 RGB。
- 40×29 來源裁邊 alpha≥225 的像素分布 top402、bottom164、left485、right265。樹木、屋緣可能被截斷，**ART HOLD**；另 D7 Ground 本就含本應在 PAR 的直立砂岩崖壁／大灌木，**Ground 純度 ART HOLD**。
- D8 真 Ground+CompletePAR 逐像素 PIL 合成 PASS，眼見暖色風格與不同建築搭配良好，但**沒有獨立 source owner Manifest 證明逐物件全數可編輯，也沒有 Godot 4.7.2 真 native 審核**。不能把靜態合成 PASS 說成 ART PASS。正式十二圖 0/12。
- [D8 詳細 QA、失敗記錄與後續規格](TC_D8_FS_03_VILLAGE_GROUND_FIRST_COMPLETE_PAR_PAIR_20261122.md) 已寫入專屬 GitHub 分支；[12-map 進度](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) 和 [風蝕金砂 Blueprint](../../tc_factory/biomes/FS_03_VILLAGE_GROUND_FIRST_BLUEPRINT_20261122.json) 現登記 D8 TRUE RGBA PAR，而非舊的 D7 PAR NULL。

## 私人雲端 WRITE→READBACK

- **[D8 完整十三檔圖片／原始 Ground＋PAR／兩版合成／Alpha QA／Failure Log ZIP](https://drive.google.com/file/d/1SO1aVJu3KNDZIlAmgcOHc5nosSwJ0Q4w/view)**，25,638,287 bytes／13 files／ZIP CRC PASS，SHA256 `84cdd9771c8fd2ebaf68378b218fcee324c79f7b5fa0c0159797777cfc5d9410`。
- [D8 原始 PAR 真 RGBA](https://drive.google.com/file/d/1ojHRduBZIFyyys21Fz8irKNTLNV3I3C5/view)、[PAR 技術 Alpha 清理候選](https://drive.google.com/file/d/18v6Tnr-vomNMVgyUGjQz2LVLZF6lssez/view)、[整圖真合成 1280×928](https://drive.google.com/file/d/1eJPmH9j4c_DjkKM8Bkx2bRQmzGznObfU/view)、[46×33 參考](https://drive.google.com/file/d/1Zet8TxzEEYDg_NjWac-apIo6UJvExj0G/view)。五件檔案皆 Google provider metadata `shared=false`、user owner only。新私有圖像不進公共 GitHub，未操作 user PC。

## D8 接續 FS_03_MAZE 真 Ground 初試失敗（未接受為素材）

- 已實際嘗試生成同一地形另一張圖 **FS_03_MAZE「風沙裂谷」**的純 Ground：正式要求是彎曲砂岩峽谷通道／分岔／乾涸河道等平面地貌，**不可有房子／噴泉／攤位／完整樹等非地表物件**。
- 生成器錯回 **1477×1065 RGB 的完整星井綠洲村莊 Master 風格畫面**，有屋、噴泉、市集、棕櫚和立體建築，SHA `6aa8bf06e5e934e709ed1583f8e0be9216288306265ed02d9fc8eafd70afa25c`；FAIL_WRONG_SCENE_AND_NOT_GROUND。
- 此錯圖不會提交為合法 Ground，也沒有上傳雲端作為地圖源，更不會生成假的 PAR 配對；已記入 12-map tracker `FS_03_MAZE` 的 **REJECTED**。D8 真正成功的 **FS_03_VILLAGE 地表＋透明完整 PAR** 不受影響。
- 為避免再繞回微修，下一個真正工程單位需要更嚴格的 **Ground-only scene-type control** 或改用可維持同 Blueprint/獨立 source 輸出的生圖工具，不能用本輪錯 Master 原圖反切 PAR 或 Ground。

## 下一個完整施工單位

開始 **FS_03_MAZE 風沙裂谷** 的獨立全圖 Ground-only → 同場景完整透明 PAR，迷宮必須是沙岩斷層、蜿蜒岔路/環線，不能又生成村莊中央石板廣場，且 Ground 裡不能混入高聳岩柱/整棵棕櫚/建築。正式大地圖目標 80×58／2560×1856，低解析來源不能拉伸假稱原生完成。其後 04 火山、05 水澤、06 星晶浮島；現階段聚焦大量美術 Ground/CompletePAR 生產，不再重複個別樹冠遮擋微修。所有失敗按實際 Gate 記錄。

---

# T-C CURRENT｜D7 風蝕金砂「星井綠洲」Ground-first 新來源｜2026-11-22

**本輪新增實體藝術來源：FS_03_VILLAGE 砂漠 Ground 1280×928 候選已產出，原始 1477×1065 圖、32px grid 與 source QA 已完整存入私人 Drive；PAR 錯畫成雪原且完全無 Alpha＝0 透明區，兩次均拒收。Ground 裡有直立崖壁與灌木，正式 Art HOLD、Godot 4.7.2 NOT_RUN、12 張正式封版仍 0／12。** 此節為最新權威，後方 D6/D5 為歷史。

## Ground-first 真成果

- 世界官方 [六地形 World Bible](https://docs.google.com/document/d/1SjVPK3J5exwp0fC3bRMHjoWo2vne_pck/edit)：FS_03_VILLAGE 星井綠洲，地形風蝕金砂，Ground 沙丘／砂岩／乾河道／礫地，完整 PAR 所有非地表岩柱／整棵棕櫚／砂岩房屋／布棚／路燈／立體岩石。**先 Ground、再完整 PAR，不判斷哪些會遮人物**。
- 新 Ground 原圖 1477×1065 RGB SHA `8f8c0ac66359bf8bc47e00beb889a4e66c5f2c9d339b00f9cf05957818556f91`；1× 精確裁 `(98,68,1378,996)` 得 1280×928（40×29），SHA `ac3688112874cd45a38f484b8c37dbc0b8f6abd41b67cc0c578bc95f0935aa97`，不插值/放大；另出格線 QA，原 Ground RGB 不被後續改寫。
- 視覺內容有中央砂岩廣場、綠洲池、砂地道路與乾涸河道；粗略地形身分 warm fraction 0.949892、cool fraction 0.039116，成功與雪原區分。**但地面出現高聳直立砂岩崖壁與立體灌木，正式 GroundOnly purity ART HOLD**，不能叫符合正式全部非地表去 PAR。
- 新完整 **PAR NOT_GENERATED**：兩次工具都錯輸出全新冰雪迷宮，且兩張 RGBA alpha 分別 (51..250)、(1..251)，**完全沒有 alpha=0 透明像素**，不符合透明 desert PAR 與同 Ground 地形。這兩張錯圖已拒收，沒有上傳為私有正式素材，也沒有做 Master 逆切。
- Google Drive 私人 **[D7 Ground/source/QA ZIP](https://drive.google.com/file/d/1tFCb_V0VaxWFgKrewGIs3sIEcZ-DN7yi/view)** 8,009,029 bytes／5 entries／ZIP CRC PASS、SHA `c491c51279ee558371893df95a5b8a32a346ed35092bb371a0d7297b1e6603b6`；[原始圖](https://drive.google.com/file/d/1OQmMo0pBq7WE0RwcsRkALqDDaLXrThjA/view)、[Ground 40×29 候選](https://drive.google.com/file/d/1dYmk2I49wp0gCCWxAh5k0JiStzwNtCM4/view)，三檔 Google provider metadata readback `shared=false` / user owner only。沒有操作 user PC、沒有在公開 Github 上傳私有 PNG。
- 新 [正式 D7 詳細 QA](TC_D7_FS_03_VILLAGE_GROUND_FIRST_SOURCE_20261122.md)、[D7 FS_03_VILLAGE Blueprint](../../tc_factory/biomes/FS_03_VILLAGE_GROUND_FIRST_BLUEPRINT_20261122.json)、[12-map 登記](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json)；地形防錯 `fs_biome_identity_guard.py` 搭配 `test_fs_biome_identity_guard.py` 與 Github Actions run [44987584378](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44987584378)，4/4 synthetic QA SUCCESS。顏色匹配不能解除 Art HOLD。

## 下一完整施工單位

**將「星井綠洲」同一張地圖生成真正純地表 1280×928 Ground，之後生成真透明完整 PAR，才能正式合成。** 現在圖像工具反覆回傳冰雪來源或合成圖；先改善/更換能指定兩個獨立 source、控制原生尺寸、真透明 Alpha 的生成供應者，不用人工局部抽遮蔽修補。若工具權限未接通就記錄 NOT_RUN，絕不虛構 PixelLab 或其他 API 成功。此工作線只做美術圖層與必要原生 QA，事件/戰鬥/NPC 交其他線；六地形既有進度照史實維護。

---

# T-C CURRENT｜D6 冰脊迷谷 Ground-first + 真完整透明 PAR 完成候選｜2026-11-22

**D6 實際成果：冰脊迷谷 FS_02_MAZE 新的真透明完整 PAR 已生成，已和前輪獨立 Ground 以相同 1472×1056 世界原點合成。技術配對／逐像素原生尺寸 PNG PASS；正式 80×58／2560×1856 尚未達到，Art HOLD，Godot 4.7.2 native 本輪 NOT_RUN。** 這是最新權威，後方 D5/D4 為歷史。使用者不變要求：**Ground 先生成，全部非 Ground 的完整物件再產生 PAR，不辨識遮住角色與否。**

## 這次真的產出哪些圖片（不是資訊圖）

- 原 Ground：D5 獨立新生成 1473×1068 RGB SHA `140dfdc865a7ed299e5bbc8ec8045b2c865ff16ccdc1b7125aa9f0ef6d27071c`，無變動，純雪谷地表、岔路及凍湖。
- **D6 真正第二階段 imagegen RGBA 非地表 PAR**：原始 1473×1068，SHA `7273b56dc7343d7ad5bd8318e1149e2a4ba2cf4603dcd16b2bfb60f81c62b041`，有整棵冷杉、冰柱、立體岩壁、木橋、石質遺跡、雪岩與圍籬。**不依是否遮擋人物篩選素材**。
- 兩來源都採同 `crop=(0,6,1472,1062)` 無縮放，輸出 1472×1056＝**46×33 格** `GROUND.png` 和 `PAR_RAW.png`。 Ground SHA `3b5dd011b38213ff5d6f2fe82c2d2d5dcae26204f0f64d2a98ebc05772188b4c`，原 PAR SHA `aa3f537ecd2a7b5172886d89922c8bc5127d43c2b6fd1b56f6c937a708da562f`，技術清理 Alpha 候選 SHA `497a7bedf36ef3f2d0ac7771b9326cb5422eb0c78315d3dd7e4b2bbae35ea5fb`。以 Pillow 真逐像素合成 RAW + CLEAN 並驗 RGB 完全一致，合成 CLEAN SHA `87ff1af3e395b79bbebd8464beb31dee4bad365e88800f6a8e21eacce0b1b9e3`。
- 真實合成圖完整雪谷風格宏觀相容，沒有因老式部件逐棵拚貼造成顯著屋樹風格不一。然而 **原 PAR Alpha 1..8 雜點 633,931 pixels**、近全不透明 240..254 有 422,111 pixels，另外已保留 RAW 及清理候選（alpha≤8 歸0、≥240 歸255，不能說原素材自然乾淨）。
- 高 Alpha 裁邊碰觸 top711 / bottom101 / left587 / right595 像素，可能屬自然延續森林，也可能截斷樹木。沒有原生精確物件 manifest，不可宣稱每棵根部與木橋完美對位，沒有原生 Godot 測試。
- 本輪**清楚超越 D5 PAR NOT_GENERATED**：它是真 RGBA，不是之前兩張把假 QA PASS 畫在畫面裡的資訊圖。正式整圖仍是 **46×33 模型／風格候選**，不是現有 FS_02_MAZE **80×58** 的完整交付。

## D6 私人雲端 WRITE→READBACK 已證實

- **[正式十檔 Ground／兩份 PAR／兩份合成／原來源／QA ZIP](https://drive.google.com/file/d/1p6idITcOncKfiGxfUZYINM6nbtq4q99J/view)**，21,989,010 bytes／10 entries／ZIP CRC PASS，SHA256 `c985c746b67f8d565e29df34ffbbcff8b327cebb7288ada0a9353880d3899dae`。
- [Ground 單檔](https://drive.google.com/file/d/1HUH0EBXxkoPMjE8hteTgVxf600cQ7j_s/view)、[PAR 原始真 RGBA](https://drive.google.com/file/d/15Tf49Fkntu9Jlc2VT1Ns696bW_MsogoC/view)、[PAR Alpha 修正候選](https://drive.google.com/file/d/138rGgGh7Xv3_yiWRMsVOqYE2CP6ul7lC/view)、[完整合成圖](https://drive.google.com/file/d/1sIBHnqNnNgKRmHlW7oMK14k0yypYEonU/view)。五個檔案均 Google provider metadata READBACK `shared=false`、user owner-only，未向公用 GitHub 公開 PNG，也沒碰 user PC。
- [D6 詳細資料／Failure Log／後續 QA](TC_D6_FS_02_MAZE_GROUND_FIRST_COMPLETE_PAR_PAIR_20261122.md)，[T-C 十二場景追蹤表](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) 已登記 FS_02_MAZE Ground＋PAR 真配對 static-pass、Art HOLD。
- 這輪沒有新的 PixelLab API 付費作業，純 imagegen D6 新來源；PAR 完整非地表是 AI 目視整組而不是 192 個獨立來源物件。D1 old 192/192 CI 不是 D6 新圖 QA 的證明，Godot native 4.7.2 **NOT_RUN**。

## D6 後續尺寸輸出兩次阻斷（2026-11-22）

- **80×58 / 2560×1856 全新純 Ground 的工具嘗試 FAIL**：圖像生成器改產出標有 Ground/PAR/QA PASS 的資訊圖，實際下載是 1473×1068 RGB **資訊海報**，沒有獨立原生尺寸 Ground 文件；拒收，不上傳私人 Drive、不替換已封存 D6 Ground/PAR。
- **下一地形風蝕金砂 FS_03_VILLAGE 純 Ground 嘗試 FAIL**：生成器依然產出冰脊迷谷的資訊圖而非砂地原生地表，拒收，正式十二圖狀態仍以 D6 為最新確實素材。不可把這些畫在圖上的 PASS、上傳文字當作真測試或真 Drive 寫入。
- 新的外部生圖整合尚未**連接**，不能假稱已可藉此執行正式生成。可以選擇串接能控制 output size/alpha 的專業圖像模型工具後重試；原 Ground-first／CompletePAR 規則、私人 Drive 圖像保存及 GitHub 文檔交接仍維持。
- **D6 46×33 真 RAW PNG/QA 已確實存放 Private Drive，狀態維持 Candidate 技術 PASS、Art HOLD；不因後續尺寸嘗試錯誤而退回 D5 PAR 未生成。**

## 下一個完整施工單位（不再修單獨樹葉）

要繼續真正 **80×58 / 2560×1856** 之 Ground-first 全圖原生生成與 CompletePAR 配對，使用 D6 雪谷「兩圖整體風格」作 style reference，不能直接把 46×33 整圖 nearest 放大當原生地圖。兩張 Ground/PAR 必須可獨立檢查出畫、Alpha、畫布對位後才標完成。之後按世界設定走 03 風蝕金砂、04 赤焰火山、05 幽霧水澤、06 星晶浮島各一村一迷宮。正式 ART 仍 **0/12**，新圖技術測試過關不解除。

---

# T-C CURRENT｜D5 冰脊迷谷 Ground-first 新雪谷來源｜2026-11-22（台北）

**進度真實：本輪成功新生成 FS_02_MAZE 真雪谷 Ground 地表，原圖及不縮放 46×33 候選已存私人 Drive；正式 80×58 未達標，CompletePAR NOT_GENERATED，Godot 4.7.2 Native NOT_RUN，ART 0/12 HOLD。** 此段優先於下方歷史 D4/D3/C8；使用者最新 Ground first → ALL non-ground Complete PAR 規則不可再偏離。

## D5 已完成（真 PNG，不是進度示意圖）

- `FS_02_MAZE 冰脊迷谷` 地形凜霜雪原，正式目標 **80×58 @32px = 2560×1856**。新的 Ground-only 真生成圖 1473×1068 RGB **SHA256 `140dfdc865a7ed299e5bbc8ec8045b2c865ff16ccdc1b7125aa9f0ef6d27071c`**，純雪路、彎曲分支、凍湖與冰裂，未見村莊房屋、樹木、路燈、中央噴泉等非地表物件。這次改正前兩次誤生成「雪村 Master」失敗。
- 只裁 `(0,6,1472,1062)` 原像素成 **1472×1056／46×33 格**可檢視候選，零重採樣，SHA256 `3b5dd011b38213ff5d6f2fe82c2d2d5dcae26204f0f64d2a98ebc05772188b4c`。**不是正式 80×58 來源；不能 nearest 放大稱作真正 32px 美術。**
- 三份 Google Drive 私人來源已 **WRITE→READBACK metadata**，均 `shared=false`／owner-only：[原始 Ground 1473×1068](https://drive.google.com/file/d/1_pjneuKesT8_5EELIn2nX9xuFW4YsTia/view)、[46×33 Ground 候選](https://drive.google.com/file/d/17mUgD3av2eNfUJPYX01gOUfGzazfK1sT/view)、[原圖＋Grid QA＋Failure Log 全封包](https://drive.google.com/file/d/1hLXgbMYBG0lawzZwTOb_Iv4i8Ju3GtsS/view)。ZIP **9,050,368 bytes／5 entries／CRC PASS／SHA256 `ff87c0a1443de3cae930886a8351ec301b8529376bd57a81fd9592a6198b7199`**。GitHub 不存私有 PNG，不操作使用者 PC。
- 詳細 [D5 source QA 和後續完整施工](TC_D5_FS_02_MAZE_GROUND_FIRST_SOURCE_20261122.md)。已更新 [T-C 12-map 状態表](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json)：FS_02_MAZE `D5_GROUND_46x33_CANDIDATE`，原正式 80×58 `NOT_MET`，PAR null，正式 ART `HOLD`。
- **D5 新 PAR 嘗試兩次均失敗**：圖像生成器輸出「標記 QA PASS/Drive 上傳完成」的圖文資訊圖，不是透明 RGBA 遊戲素材，不能當真正 PAR；無任何新 FS_02_MAZE 完整透明 PAR、無同圖合成，勿偽造 PASS。這次 D5 不執行角色遮蔽／碰撞分解，符合使用者完整 Ground＋全部非地表 PAR 生產規範。

## 下一個宏觀施工單位

優先將雪谷完整 Ground **原生產出到 2560×1856／80×58 格**，能保留蜿蜒雪路與分岔，不以 46×33 比例拉大假冒；再以同一來源／Blueprint 真正生成透明 ALL_NON_GROUND PAR（冷杉完整樹、岩柱、冰柱、巨石、棧橋等），不挑遮人素材。不再產生 QA 資訊圖，不再拼裝個別樹木。QA 只在真 Ground 與真 PAR 存在後進行圖層配對、32px 格對齊、Alpha、Godot 4.7.2 1×，最後人工 ART Gate。正式目前 0/12 地圖美術封版。

---

# T-C CURRENT｜D4 雪原霜燈聚落完整 Ground＋PAR；十二地圖共用 Gate｜2026-11-21

**真實新增：FS_02_VILLAGE D4 新 PAR 成功單獨生成、與 D3 Ground 獨立合成，來源完整私人 Drive 保存，12 圖 QA 共用程式 + GitHub Actions PASS；正式藝術 0/12 仍 HOLD。FS_02_MAZE Ground 新生成兩次不合規已拒收。**
最高優先規則：**先生 Ground，再生完整透明 PAR；PAR 是非地表的一切，不問會不會擋角色**。不 Master 逆切、也不局部選屋簷或樹冠遮罩。

## 實際成功的 D4 雪原村莊全新來源

- Ground D3 先獨立生成、已鎖定 RGB 1280×928 SHA `475f7883c1fe23245198198029da3ac37dc479176e3dc8ddc8a81aba4054f5ea`，這輪實際未修改。
- D4 **真正新生成**獨立透明 RGBA 全非地表 PAR：原圖 1473×1068，source SHA `f8799684c508c9f4bb8047e21eee98cecfe246b50d3397521325e26da1636895`；同 D3 原地表 `(95,71,1375,999)` 像素裁切到 1280×928（40×29，32px），無 resize。原始 PAR 中含三棟完整不同雪屋、完整冷杉、冰柱、岩塊、木柵、旗幟、路燈、石拱及村莊雜物，沒有因角色遮蔽語義剔除。
- Pillow 真逐像素 `Image.alpha_composite(Ground, PAR)`：1280×928 靜態合成與視覺對照 PASS，色彩風格與雪地路網整體協調，**非 Godot native GPU**。透明原版與技術清理版分開封存，不覆蓋原圖。
- D4 原始 crop PAR SHA `3717e0a4076d788befa1b2afb85f786b2abdc99e4a6c4fa8792e4d3024aa257a`，alpha 清理候選 SHA `44aee78ef02329018237e9750ee22012c08cea443ae4bf6f977bfc8af36238f3`，合成 QA 圖 SHA `62baac926a41178edd072ed3d977b7225fdbe83a2516e8e7689a0b64efbc4378`。

## D4 Failure Log：不造假通過

- Alpha raw 原始技術問題：alpha=0 482,226 px；1..8 雜點 **190,971 px**；240..254 約 **419,163 px**；255 僅 **46 px**。另存 alpha≤8 歸零、alpha≥240 變255 的技術修正版，**不能改報原圖已完美透明**。
- 世界裁切邊緣真 opaque PAR 像素：上731、下357、左593、右480（alpha>224）。**PAR 完整物件可能有裁邊**，Art HOLD。視覺品相改善不等於每件屋/樹均封版、也不等於獨立物件 source manifest 192/192（D1 舊來源的 192/192 不能借到 D4）。
- D4 Godot 4.7.2 **NOT_RUN**。D1/C8 早先的 native CI 不可冒稱 D4 Native PASS。FS_02_VILLAGE source pairing TECH PASS，formal ART HOLD。
- 兩次嘗試 **FS_02_MAZE「冰脊迷谷」真正 GroundOnly 生圖**，image generation 都生成有村屋、樹、晶泉的「雪村完整 Master」，違反 Ground-only，已拒收不作迷宮來源、不上傳為進度。FS_02_MAZE 仍 PLANNED，需真正雪谷岔路而非雪村十字廣場。

## D4 Private Google Drive WRITE→READBACK

- **[正式 D4 完整來源＋QA 14.19MB ZIP](https://drive.google.com/file/d/1ZNxOAya0UZe8y8DC1KEfhOCJXDCSo9Uh/view)**，14,185,535 bytes、9 entries ZIP CRC PASS，SHA256 `32d0ca6354e09408aba1a5edc1b94b05f1c4b3ea6ded9664550b9648dd4580ef`。
- **[獨立原始透明 PAR](https://drive.google.com/file/d/13p62_ZjVAS7FvZKzBj1XydCwqrKLmULn/view)**、**[Alpha 修正版 PAR](https://drive.google.com/file/d/1-H6ZO1eRhRpy27DdJYwh35ywIq-0l5ym/view)**、**[Ground＋PAR 完整合成](https://drive.google.com/file/d/1C3pw0Xn5BTGCTNbIuoPZ6S-VNpxPulNw/view)**。四項讀回都 `shared=false`、僅 user owner；舊 Ground 繼續保存在 [D3 Drive](https://drive.google.com/file/d/1YQt0dkI2AR9VFYMMrFYP3h4KUPJ_ka9T/view)。
- 新共用 Gate 真實跑 D4 source，獨立 QA JSON：https://drive.google.com/file/d/1ygi9H6kQglXJJEiSyL-k4_19z0B1bvJN/view，1x 雙圖對比：https://drive.google.com/file/d/18QjB6mT2WvevN8g5SzMrPdlBFzIGw3D-/view；全部私人。
- GitHub [D4 原生來源／Alpha QA 完整紀錄](TC_D4_FS_02_VILLAGE_GROUND_COMPLETEPAR_NEW_SOURCE_QA_20261121.md)。專屬 branch `feat/fs-pixellab-tc-map-20261121`；沒有操作或存檔至 user PC；沒有把任何新的私有圖像上傳公開 GitHub。

## 十二張共同自動 QA 真工程，不再依賴主觀假 PASS

- 真程式 `godot_port/tc_factory/biomes/fs_validate_ground_complete_par.py`：任何六大地形、12 場景一律接受獨立 Ground+CompletePAR，驗 SHA lock、32px 整數網格、原生世界尺寸、RGBA alpha histogram、四邊非透明物件裁切風險、逐像素 Ground+PAR 合成。**不做 actor occlusion/subset，不依據技術合成就解開 ART HOLD**。
- 單元測試 `godot_port/tc_factory/biomes/test_fs_validate_ground_complete_par.py` 確實在 GitHub Actions [run **44921313899**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44921313899) **completed/success**；檢查 6 biome／12 scene ID、SHA fail-close、alpha 及正式 0/12 ART PASS。
- 使用者正式 SOP Google Drive：https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit；已追加 D4 完整來源和兩次失敗解釋，readback verified 55 段。專屬 [12-map tracker](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json) + [FS_02_VILLAGE Blueprint](../../tc_factory/biomes/FS_02_VILLAGE_GROUND_FIRST_BLUEPRINT_20261121.json) 已更新，正式 ART PASS **0/12**。

## 下一個完整藝術單位

**不要重開雪村遮擋或修單顆冷杉**。要解決的是可靠地按指定場景生成 **FS_02_MAZE 冰脊迷谷的一次性完整 Ground-only**：曲折雪路、冰裂、背風坡、分岔、環線，沒有房屋/冷杉/石拱/水晶祭壇；先通過 Ground source audit，再使用同 Blueprint 生成含所有非地表物件的完整透明 PAR。迷宮尺寸正式目標 **80×58 tile，2560×1856**，絕不能把低解析度原圖直接非均勻 nearest 放大稱為原生 32px 高品質場景。若圖像工具繼續生成雪村 Master，就 fail-close 換生成器或 Style Lock，不把失敗圖充當成品。後續地形按世界設定 03 風蝕金砂、04 赤焰火山、05 幽霧水澤、06 星晶浮島各一村一迷宮逐一施工。

---

# T-C CURRENT｜D3 六地形×迷宮／村莊十二圖生產啟動｜2026-11-21（Asia/Taipei）

**本輪已實際上傳 SOP + 六地形追蹤檔 + 新雪原 Ground 候選；02_VILLAGE PAR 尚未成功，正式所有地圖仍 ART HOLD。** 最高規則不變：**先生完整 Ground，再生同世界座標 CompletePAR；PAR 收納所有非 Ground 物件，與是否遮擋角色無關。** 不從 Master 逆向裁層、不在本工廠處理 NPC/事件/戰鬥或角色遮擋細節。

## 本輪確實完成

1. **SOP 已在兩處正式保存**：GitHub [FS_TC_GROUND_FIRST_COMPLETE_PAR_12_MAP_SOP_20261121.md](FS_TC_GROUND_FIRST_COMPLETE_PAR_12_MAP_SOP_20261121.md)；Drive [可編輯正式文件](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)，Google Docs API 寫入後已讀回 46 段、標題與章節及 GitHub 來源連結。包含 D2 46×33 真透明 PAR 與 Ground 實際配對方法、Alpha 色彩污染、40×29 裁切失敗、完整新圖輸出限制、正式 Handoff 及雲端 SHA 原則。
2. **已重新讀 Drive 2026-11-14 正式世界設定** [FS_SIX_BIOMES_WORLD_ART_PLAN_20261114](https://docs.google.com/document/d/1SjVPK3J5exwp0fC3bRMHjoWo2vne_pck/edit)，及 [2026-11-16 12-map Active Master](https://docs.google.com/document/d/11SzPGsNakKL7U0Gzo0LFN806gJU_82sP/edit)，原名／場景 ID 固定不換：蒼翠精靈林 FS_01_MAZE 幽葉迴廊／FS_01_VILLAGE 苔光村；凜霜雪原 FS_02_MAZE 冰脊迷谷／FS_02_VILLAGE 霜燈聚落；風蝕金砂 FS_03_MAZE 風沙裂谷／FS_03_VILLAGE 星井綠洲；赤焰火山 FS_04_MAZE 熔脈裂橋／FS_04_VILLAGE 灰鑄工坊城；幽霧水澤 FS_05_MAZE 泥潭迷水／FS_05_VILLAGE 蘆燈水上村；星晶浮島 FS_06_MAZE 星盤斷空／FS_06_VILLAGE 虹晶臺地村。
3. T-C GitHub 新文字台帳 [TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json)，是六大地形十二圖的施工追蹤檔，**不是另一套可覆蓋舊正式設定的 canonical Scene Manifest**。已明確保留森林兩圖既有技術候選／ART HOLD、雪原第一張 Ground 候選、其餘十張未造；**正式 ART SEALED = 0/12**。
4. 新獨立雪原圖片：FS_02_VILLAGE「霜燈聚落」**GROUND-FIRST 候選**，原始新生成 RGB 圖 1470×1070 SHA256 `bb2bdbc0a50fab85689180669b36b59b858a98863d44d9a127aa26e628dbc9b3`；用 `(95,71,1375,999)` 原像素裁切出 1280×928／40×29 32px 格，**無縮放**，Ground 候選 SHA256 `475f7883c1fe23245198198029da3ac37dc479176e3dc8ddc8a81aba4054f5ea`。保存 40×29 32px 格線 QA，5 檔 source/ground/grid/QA/blueprint ZIP CRC PASS，source+PNG READBACK。
5. 私人 Drive 檔： [Ground 1280×928](https://drive.google.com/file/d/1YQt0dkI2AR9VFYMMrFYP3h4KUPJ_ka9T/view)（2,075,805 bytes）、[未裁原始圖 1470×1070](https://drive.google.com/file/d/11TWOaksX413DsIMCN5Nmm1TfCCQRlYyK/view)（2,912,203 bytes）、[32px 格線 QA](https://drive.google.com/file/d/174ytM0lTie-i1YINZVg364_A62dYlbql/view)（2,024,066 bytes）、[完整 Source QA ZIP](https://drive.google.com/file/d/1d4LoyX3FSYRA9iy9aCU5WJ_N0RYz8XOY/view)（6,982,939 bytes，SHA256 `d21c285a8915dd51e5db7ff53a9f3a8cae3409a6523e091df3bd3590c0e1b154`，CRC PASS）。Google Drive API 四項 readback 全部 `shared=false`／user owner-only。圖片不放公共 GitHub，也未碰使用者 PC。
6. 專屬雪原藝術規格在 [FS_02_VILLAGE_GROUND_FIRST_BLUEPRINT_20261121.json](../../tc_factory/biomes/FS_02_VILLAGE_GROUND_FIRST_BLUEPRINT_20261121.json)：世界 ID／材質／非地表物件規定／Ground 初稿 SHA／PAR 預期完整物件家族、來源座標、驗收狀態。依 2026-11-14 世界美術設定，Ground=積雪、凍土、碎冰、冷色岩地面、雪路；PAR=全部冷杉、冰柱、覆雪房、暖爐煙囪、岩塊、燈柱、欄杆、橋梁、裝飾，不因 blocking/occlusion 移除。

## Failure Log 及誠實 Gate

- **D3 PAR 仍 NOT_GENERATED**：嘗試生成完整雪村透明 PAR 時，圖像工具錯誤輸出「進度海報／資訊圖」，不是 RGBA 遊戲素材，已拒收，不能為圖面內容背書或當地圖 QA。下一輪需使用可可靠輸出原生同尺寸透明圖層的工具／製程；不把海報冒稱 source。
- **D3 Ground SOURCE CANDIDATE，不是 Ground ART PASS**：圖中若干小型立體岩塊／立體灌木疑似不該留 Ground，需要以成圖規則確認、必要時重生 Ground，不可在整張圖做 Master 逆切。新圖片只有 RGB、尺寸、裁切、SHA、存儲 PASS，**沒有**完成嚴格 Ground purity 人工藝術驗收。
- **新雪原尚無完整 PAR / 新雪原 Godot 4.7.2 native NOT_RUN**。先前 D1 全物件 192／192 CI 不是 D3 的 native 結果；不得互相移花接木。雪原 1/2 圖層只是 Ground 候選，不宣稱完整場景通過。
- 過去 FS_01_VILLAGE D2 46×33 Ground + CompletePAR 同圖合成 TECH PASS，美術/真正原 40×29 裁切 ART HOLD；FS_01_MAZE 技術場景 ART HOLD，不覆蓋。
- 六地形正式完成地圖數 **0/12**，新 D3 雪原 source 候選 **1張**；不要把工程追蹤、SOP、進度海報算作美術完成。

## 下一個宏觀單位（保持六地形12圖，不糾結單棵樹）

先把已封存雪原 **FS_02_VILLAGE** Ground 語義純淨度審核並以**同一張已產生 Ground**生成真正獨立、透明、完整非地表 PAR（所有屋舍、完整冷杉、冰柱、路燈等），一次美術驗收；若上游工具只出海報，停止假輸出，改來源/模型/流程，不再微調遮蔽。配對完成後，直接開始同地形 **FS_02_MAZE 冰脊迷谷** 的完整 80×58 Ground-first，繼續地形 03 風蝕金砂、04 赤焰火山、05 幽霧水澤、06 星晶浮島。所有階段只有圖片實出、SHA、Drive WRITE→READBACK、Art/Engine 各自 QA 才能升級狀態。

---
# T-C CURRENT｜D2 真正新生成 Ground＋透明完整 PAR 之合成與 QA｜2026-11-21

**新 Ground／PAR 真實合成成功，宏觀美術評估方向正面；46×33 source pair TECH COMPOSITE PASS，但透明 Alpha 原圖有污染、1280×928 裁切物件，正式 ART HOLD。Godot 4.7.2 原生 NOT_RUN。** 使用者最新唯一規則：Ground 獨立先生成，完整 PAR 後生成，收納除 Ground 之外的所有非地表物件，絕不篩選角色遮蔽物。

- 完整紀錄：[`TC_D2_GROUND_PAR_NEW_GENERATION_PAIR_QA_20261121.md`](../handoff/TC_D2_GROUND_PAR_NEW_GENERATION_PAIR_QA_20261121.md)；包括原圖 SHA、兩個 PAR 版本、Alpha 分佈、像素同尺寸原點、32×32 全圖、失敗紀錄和 Gate。GitHub 只保存 code＋QA＋Handoff，素材在私人 Drive，無使用者 PC 寫入。
- **原始兩張生成畫布各 1473×1068**，同一 XY、不混入 Master；為保留全部房屋樹木、不縮放，作為 46×33（1472×1056）完整地圖候選，僅從 Ground 及 PAR 同時裁右 1 px、下 12 px。Ground.png 46×33 SHA `226a0733dc92cd0023ddcd4a86afff9d8a469cc658b0a5e884c5667bcce36af1`；原生 PAR SHA `0a52c590e85086b29af37754bdbc9206d2aab96ec9d98e0c82f5d4d4dbd2f574`。
- 技術 Alpha 清理試驗：原 PAR 大量 alpha 1..8 的紅黃綠雜色；新增候選修正 alpha≤8→0、alpha≥240→255，不改可見 RGB，原 PAR 原封不動保留。清理後 SHA `80b6aee06908c3e8160881af28a3faa9cf0d3d09c85bac3f0b538de45e9e406c`，完整合成 SHA `09137573db960dead52bc599e859a7f5134b65366f13e371df39a1cd3f91e7a8`。Pillow 真逐像素 alpha composite PASS；原生 Godot 4.7.2 NOT_RUN，不能誤寫 PASS。
- Google Drive READBACK owner-only：**[Ground](https://drive.google.com/file/d/1zop1sxdXiTfee_rpiSQCJXu5Uotikt4y/view)**、**[原始完整 PAR](https://drive.google.com/file/d/17lUUXnCCNk4pQGWUGiRciSJW9qAVGbrl/view)**、**[Alpha 技術清理 PAR](https://drive.google.com/file/d/1nywEe4sG-KTtWFTpPC7VCoQjD_ANa6Lv/view)**、**[完整合成圖](https://drive.google.com/file/d/1cASgC0jbjiXbFOf_HSJPTanjgBHUfUrU/view)**。四個檔案均 verified shared=false/user owner。
- **1280×928（40×29）只算裁切展示，非正式藝術過關**：來源同座標中央裁切會讓原 PAR 上緣 872、左 544、右 654 個近全不透明像素撞到邊界，切斷完整森林／房屋物件。故正常新完整地圖保留 46×33，既有 FS_01_VILLAGE 若必須 40×29，應在產圖最開始建立 1280×928 World Blueprint 再一起生 Ground→PAR，不要硬裁合格的完整場景。
- 視覺檢查：原新 Ground 地表、兩棟獨立精靈屋、中央水晶噴泉與森林色調協調，符合「一次生成同風格」的大方向。但未逐個源物件驗 alpha 完整、原 FS ground3 風格匹配、Game native，保留 ART HOLD。
- **下一完整單位**：直接沿用這套整圖 Ground-first→CompletePAR 兩階段製程，針對原生 1280×928 世界格一次生成同座標新 Ground＋乾淨透明 PAR；或確認 46×33 作為真正新地圖。不要做個別屋簷、樹冠選擇性遮蔽，不重開 C4～C8 微修。必要才安排 Godot 4.7.2 原生導入，不能讓碰撞設定反客為主。

---

# T-C NOW｜D1 使用者糾正後的唯一 Ground → CompletePAR 路線｜2026-11-21

**路線權威：使用者 2026-11-21 當次糾正高於全部歷史實驗。先獨立生成 GROUND.png，鎖 SHA，後以同一場景與風格生成包含所有非 Ground 物件的完整 PAR.png。不能先合成 Master 再逆向切圖，不能把 PAR 限縮為角色遮蔽區，也不應以分辨 actor-occlusion/collision 阻礙產圖。**

Drive 已直接重讀：SHARED_GAME_ASSET_GENERATION_AUTHORITY 文內 7 Map authoring split model 清楚規定 PAR / All Non-Ground Objects，包含 houses / trees / shrubs / rocks / lanterns / bridges / fences 等，不問是否遮人；Actor-Occlusion Mask optional, NOT required complete PAR。另已讀 FS_GROUND_ONLY_PIPELINE_V2_執行規格_20261030 及 R17_DIRECT_GROUND_PAR_AUTHORITY，以及現行 A11 (其中舊 Master-first 過程依這次使用者最新修正覆寫 T-C 產線方式)。

## 已實做 D1 整張 40×29 / 1280×928 兩階段產線 TEST PASS
- 新程式 godot_port/tc_factory/fs_ground_first_all_par_factory.py。獨立 CLI `ground --out ...` 僅從早已獨立的 FS A36G R4 Ground-only 源圖產出 RGB GROUND.png 並寫入 01_GROUND_LOCK.json（當時 PAR 尚不存在）；第二個 CLI `par --out ...` 必先驗 GROUND Lock SHA，才從完整 A36G R4 scene manifest 的每個非地表 source RGBA 產出透明全圖 PAR.png。禁止從混合 Master 當 Ground；完整 PNG 合成 COMPOSITE_PREVIEW.png 僅供畫面 QA。
- 原 A36G R4 192／192 件原始獨立來源全部加入 PAR（森林群 44、樹 59、灌木 83、路標等 4、房屋 2）。逐一驗 id、filename、size、source SHA；包含非阻擋岩石與灌木，**零件因角色遮擋語意被排除**。這是直接全物件 PAR 而非原 C4～C8 selective occlusion。
- 新 Godot 場景 godot_port/tc_factory/DirectGroundParPair.tscn、direct_ground_par_pair.gd、capture_direct_ground_par_native.gd，只載入兩張 PNG 全尺寸、同 [0,0]、Nearest，沒有 actor occlusion list/collider。真正 Godot 4.7.2 OpenGL3 Native 1× GPU framebuffer PASS。
- 新 .github/workflows/fs-tc-ground-first-full-par.yml 將 Ground 與 PAR 分成**兩個單獨 GitHub Actions STEP**。第一步檢查 PAR/Composite 都不存在；第二步只接受原鎖定 Ground 並驗 192/192 PAR 全物件，接著正式 Godot 4.7.2 1× 顯示。
- 最終 GitHub Actions https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44915862594 ，status=completed/conclusion=success，實測 code commit a6746663bd456776a5866ada20b457ce21c66141。
- 正式 QA D1 原 Ground 與 PAR 都 1280×928 同座標；GROUND RGB、PAR RGBA alpha extrema(0,255)。完整二階段源物件 ledger、逐項 SHA、source manifest、1× Native 截圖均在 Drive。這是**現有來源的整張產線驗證**，不是新的 AI 地圖生成／PixelLab API job。
- **私人 Google Drive D1 ZIP** https://drive.google.com/file/d/1Nh8oHQ5H2amZTe_eHBav_f_ePe-hIz2d/view ：Google provider metadata readback 8,959,782 bytes、shared=false、owner only；外層 1 ZIP + 內層 8 entries，雙層 CRC PASS；內層 ZIP SHA256 1d742d2e03d7a0a900d8aba9618fa90f237a8ae8fc081d39980079164d4733ee。長期保存於私人 Drive，Github artifact 14712270367 只暫存一天，使用者 PC 不被操作。

## 新 AI Ground 嘗試（與真正 D1 正式技術驗證嚴格分開）
- 已利用 in-chat image generation NEW 生成一張**獨立純地表 Ground**（無樹／房屋／路標），來源尺寸 1473×1068 RGB；在工作容器中只做同像素中心裁切 [96,70,1376,998] 得 1280×928 RGB Ground Art Candidate，無 resize、無反向挖物件。
- 已實際儲存僅供這次對話審查之 Ground/原來源/QA ZIP，狀態 ART_PENDING；由於圖像工具接連將後續 PAR 指令誤生成**兩張美術流程 infographic**，並非透明可編輯 PAR，已嚴格拒收。**該新 Ground 的 PAR = NOT_GENERATED，新地圖可交付雙圖 = HOLD，不能把 infographic 的假 checkmark 當成正式生成成功或假稱上傳 Drive。** 由於該 imagegen Ground candidate 是本對話生成的容器檔案、目前此工具集未提供直接從容器 bytes 上傳 owner-only Drive 的路由，尚未獲長期雲端保存 readback；它不能冒充已完整交接的 D1 Drive 包。

## 下一個大單位 D2：不是修樹／碰撞
- 直接研究/串接能按**兩次獨立原生圖像生成**輸出可編輯 PNG 的 PixelLab Ground-only → PAR-all workflow，使用同一 World Blueprint / Style Lock；如果 Pixellab paid API connector/額度未接入，保持 NOT_RUN，不猜 job ID、不扣款。
- 目標先成功交付單張獨立新 Ground + 真透明全物件 PAR，兩圖同一 32px 世界座標、相同風格／門口／樹位；User visual approval 才升級 FS_01_VILLAGE；然後 FS_01_MAZE 80×58 全圖按相同兩階段輸出。只驗 Ground/Par 源純度、對位、全物件包含、1× 全圖，不再在產圖階段逐棵樹選遮擋範圍。
- 正式 ART HOLD 未解除；任何舊 C8 的 2 house / 17 occlusion owners 等視為歷史實驗，不是現在的產線方法。務必先讀更新過的 T_C_MAP_LAUNCH_PROMPT.md。每輪 Handoff、Failure Log、Linear SHO-39、Drive WRITE→READBACK→VERIFY。

---
# T-C CURRENT | C8 兩棟真正不同的完整木造精靈屋 | 2026-11-21 TPE

**C8 實際施工與 Godot 4.7.2 1× 原生 GPU／碰撞／遮蔽 PASS；正式 FS_01_VILLAGE + FS_01_MAZE 仍 ART HOLD。** 專屬 feat/fs-pixellab-tc-map-20261121。以本段為當輪最新權威，C7/C6/C5 留在下方不刪除。

## C8 真施工內容與原始完整美術
- 新檔：godot_port/tc_factory/build_tc_village_house_c8.py、TCVillageIndependentHouseC8.tscn、capture_tc_house_c8_native.gd、.github/workflows/fs-pixellab-tc-c8.yml。保留 C7 全村 1280×928 的真 FS 樹、路燈、草地、道路、左屋，不回 VX，不更動已封版 A35／MAZE／Phase1／NAV／存讀檔。
- 重要發現：歷史 A36G R5 R2（2026-11-04）有原始獨立完整 PixelLab SINGLE GABLE 右屋來源：experiments/route_b_25d_20261031_stage16/A36G_R5_R2_HOUSE_STYLE_20261104/SOURCE_INDEPENDENT_RGBA/A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png，**SHA256 4794a89cb06029112e6581c85a47bdcf6a84b7f636e05755825a989793585206**，尺寸 256×272，完整 alpha bbox [21,23,188,220]，真獨立完整單屋頂設計，並非左屋翻轉。
- 並未重新啟動/重複付費生成 PixelLab，新 API job NOT RUN。特別警戒：R5 過去 TRUE FS GROUND/PAR 與整體原版美術 STYLE FAIL，不可把 R5 失敗的整套 Ground/PAR 拿來當成功來源。本輪只取該原始 PNG 與舊 R5 documented author-footprint，重新從 C7 已驗證的正確 Master-first 同源產線重建。
- 移除 C5 右側鏡像整棟 owner 及對應遮蔽，加入真正來源 R5 單棟完整源 PNG，在 C8 新位置 (791,371)，author foot (917,591)、屋基碰撞 [826,530,969,583]。保留左屋原始完整 source 與 2 棟真 StaticBody2D；原 C7 17 owners 數維持，因為以一棟真右屋取代原鏡像屋，而不是把兩棟疊在一起。C7 兩新樹的根部 collider 完整保留。
- 正式五圖仍 1280×928：MASTER／Authoring_GroundOnly／Authoring_CompletePAR／Runtime_FullGround／Runtime_OcclusionPAR；GroundOnly 不變，僅換完整第二屋 PAR 與 RGB Master 同源 occlusion；相對 C7 changed RGB = **26,655 pixels**，bbox 僅 [805,394,1014,591]，原森林/道路與第一棟屋保持。來源 SHA 與靜態重組 all PASS。

## 真 Godot 4.7.2 原生及私人雲端封存
- **正式 CI 成功** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44874487911 ，GitHub status=completed/conclusion=success，tested original code commit **c08c55ae50e0cf659b71c2229877d7ebf2f6a132**。真正 Godot 4.7.2-stable official/OpenGL3 1280×928 native framebuffer：TC_C8_GODOT472_NATIVE_FULL_1X.png，以及同位置 actor uncovered 原生對照、右屋原比例 crop。
- TC_C8_GODOT_NATIVE_QA.json：原獨立屋舍2真 body、C7 原始樹根2 body、總17 source occlusion owners；七項 point-query：左屋1、全新獨立右屋1、兩樹根1/1、路燈0、道路0、屋前空地0，all PASS。真正右屋 roof 遮蔽及 uncovered A/B 同足點 ROI 差 **204px**；人物移至屋前遮蔽正確消失。這不是只拿 HTML 截圖或靜態 PNG 檢查。
- **私人正式 Drive C8 ZIP** https://drive.google.com/file/d/1xYFx6Mmx4PeSP4zMLdiYm1ZeF0J4bVbn/view ，Google provider metadata readback **82,042,571 bytes、shared=false、owner-only**。外層 GitHub artifact ZIP 1 entry、內層 **49 entries**，兩層 ZIP CRC PASS；內層 SHA256 **3acee1e1a233b68348557231946d299f36cf131973337ab0dc30718c59569a9e**。GitHub artifact id 14695765704 僅 1 日傳輸，長期只有私人 Drive；只往 GitHub 寫程式、Scene、Handoff，無操作使用者 PC。
- 全場主觀 1× 現場目測：相較 C7 左右同一棟屋鏡像，C8 兩間現在具有真正不同結構（左屋帶側邊工坊、右屋單棟），屋頂與材質同風格更自然。仍不能宣稱正式 FS 兩圖美術通過。

## Failure Log、持續 HOLD 與下個大單位
- 歷史 R5 失敗風格不能因新 C8 engine success 就洗白：R5 原版完全不同的 Ground/PAR Layer scheme 曾被使用者拒絕。C8 只復用原始 R5 完整 RGBA 物件，明確保留 ART HOLD，尚未和原始 FS Graphics/Parallaxes/ground3.png SHA ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13 做直接美術批准；True FS Ground/Par 遮蔽契約仍是正式最終 Gate。
- 原始193棵樹根部全域移動/NAV 非本次測試；MAZE 原始 1478×1064 nearest 放大到 2560×1856 的原生32px美術欠缺也尚未處理。不冒充完整 Art PASS。
- 新 PixelLab Object Creator/Create Tiles Pro/Map Workshop/Style References 本輪均 NOT RUN：僅使用歷史真來源且有 SHA，無虛構新支出／job id。
- 下一完整 C9：**正式 FS_01_VILLAGE 與原 approved ground3/par3 全圖 style-source 及語意對齊 Gate**，以已保存 Ground3/Par3 hash 及最新原生 Godot 1× 視覺核對，維持真正 original fullground copy only required occlusion，而非將 76.5% 的失敗 R5 CompletePAR 當 runtime occlusion。對重要阻斷直接換一整個來源單位，無需修葉片。之後進入 MAZE 80×58 真 native 32px Ground，而非繼續拉伸源圖；每段都 QA、Failure Log、Handoff、Drive、Linear。正式 Godot 4.7.2，絕不回 VX。

---
# T-C CURRENT | C7 真正 FS 獨立源美術整組替換 | 2026-11-21 TPE

**C7 施工/Godot 4.7.2 真實 GPU 1×、遮蔽及 source-semantic collision PASS。正式 FS_01_VILLAGE、FS_01_MAZE 仍 ART HOLD。** 專屬分支 feat/fs-pixellab-tc-map-20261121；這一節比下方歷史 C6/C5 紀錄新。

## 實際新檔與來源核對
- 程式：godot_port/tc_factory/build_tc_village_source_c7.py、TCVillageSourceC7.gd/.tscn、capture_tc_source_c7_native.gd、.github/workflows/fs-pixellab-tc-c7.yml；沒有變動原 A35、MAZE R12/R14、VX、NAV、傳送/存讀檔或 Phase1 主工程。
- 舊 C6 手工卡通樹石全部替換為五件原 FS A36G R4 完整獨立 RGBA：A36F_west_waymarker_ORIGINAL_RGBA.png、A36F_DENSE_TREE_143_RGBA.png、A36F_DENSE_TREE_071_RGBA.png、A36F_north_rock_ORIGINAL_RGBA.png、A36F_UNDERSTORY_028_RGBA.png。
- 正式原始文件在 public GitHub experiments/route_b_25d_20261031_stage16/A36G_R4_R3_6REGIONS_20261104/SOURCE_INDEPENDENT_RGBA；真 A36G_R4_SCENE_MANIFEST.json SHA256 4334c82e263fc2917ed640eb7ef433016523690a13e3104ce3bc745ee5f438dd。逐一核對 source id、filename、sha256、原尺寸、footpoint、blocking。
- 完整村落 1280×928 (40×29 tiles)，替換單位仍 8×8／256×256 [640,160,896,416]。保留 C6 Ground 及 C5 CompletePAR，重新構造 MASTER/Authoring_GroundOnly/Authoring_CompletePAR/Runtime_FullGround/Runtime_OcclusionPAR；C6 手繪藝術 0 remaining，區域外 bit-exact，C6→C7 改變 7317 RGB pixels；source registration STATIC PASS。
- 原 14 個 C5 owner + 3 個真正 C7 原始 source occluder = 17。2 棵樹 source.blocking true，窄 10×10 腳跟 root collider；路標/石塊/灌木 source.blocking false 不會被誤當成牆。原兩屋舍 body 保留。此測試並非 193 原樹完整 collision/NAV。

## Verified Godot 4.7.2 原生測試與私人存檔
- 最終 GitHub Actions run 44873943982 : https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44873943982  status=completed, conclusion=success, tested commit 38c0d3e238a2e9c6e11f496bc3beab02cacc6038。
- 真原生 GPU 1× framebuffer [1280,928]、Godot 4.7.2-stable official/opengl3。原屋碰撞 hit=(1,1)、新來源兩樹根 hit=(1,1)、路標/石/既有道路空點 hit=(0,0,0)，全部 7 項 point-query PASS。原燈柱同位置 actor 遮蔽/未遮蔽 A/B 真 GPU 改變 229 px；actor 移到前方不被擋。整村圖 TC_C7_GODOT472_NATIVE_FULL_1X.png；區域裁切與 3× nearest 預覽另附，預覽不是原生 3×。
- 正式私人 Drive C7 ZIP：https://drive.google.com/file/d/19ez90LzcrGfJGV-ezh2xmUkf-djQ4dh0/view ；Drive id 19ez90LzcrGfJGV-ezh2xmUkf-djQ4dh0，provider metadata READBACK size=78698410 bytes、shared=false、user owner only。外層 GH transfer ZIP + 內層 44 entries 兩層 CRC PASS；內層 SHA256 1d8722c6349db7b5ec98ac16b55135fa01c82733e1acd1ec8336e7b852849ca2。GitHub artifact 14694707796 僅 1 日轉送；正式圖片/QA 在私人 Drive，無操作 user's PC。

## Failure Log、ART HOLD 與下一個整體單位
- 首輪 CI run 44873757489 的 Godot 原生 7 項結果已 PASS，但之後 Python check 誤以為 Godot JSON Dictionary values 保留固定排序，使報表 assertion false-negative；改按 key 逐欄比對後 CI run 44873943982 全成功。
- C7 真原生 1× 人工審查：源自 FS 的葉片/松形/路燈/石塊遠比 C6 簡化卡通物件融入原森林，屬有效整組來源替換。然而不代表村落全圖已 ART PASS。
- Village ART HOLD：右側 C5 屋舍仍是左屋完整 source 的 mirror+nearest 變體，缺乏真正不同完整建築；歷史 193 原 tree 並未全部做完整 root/NAV。Maze ART HOLD：R12 原 1478×1064 Ground 放大到 2560×1856 的 native 32px 著色/紋理仍未重建。
- PixelLab new Map Workshop / Object Creator / Create Tiles Pro / Style References jobs 本次皆 NOT RUN。原始舊 FS 美術來源可核實，不可誤稱新 API 生成/收費。
- 下一個 C8 宏觀施工：右側一整棟真正獨立且同風格 FS 屋舍與工坊，使用已驗私人 R12 完整 A34 source 或確實接通的 PixelLab 新生成。保留 C7 全圖與兩屋碰撞骨架，完成後 full Godot 4.7.2 1× native A/B、遮蔽/碰撞、私人 Drive、Github QA+Handoff、Linear。村落主要藝術解鎖後，再完成 Maze native 32×32 Ground。小瑕疵最多兩修，重大問題換來源。

---
# T-C C6 CURRENT｜8×8 林間道路過渡區｜2026-11-21（Asia/Taipei）

**C6 已真正施工／Godot 4.7.2 1× GPU + 物件根部碰撞／條件遮蔽 PASS；最終 ART 仍 HOLD。**  
工作分支 feat/fs-pixellab-tc-map-20261121。這節為最新權威，後方 C5 內容保留歷史證據。原正式 A35 R2/R3、A35 R8 R3、MAZE R12/R14，以及事件、戰鬥、傳送、NAV、存讀檔均不修改；只用 Godot。

## 已完成工程
- 實作：godot_port/tc_factory/build_tc_village_region_c6.py、TCVillageRegionC6.gd、TCVillageRegionC6.tscn、capture_tc_region_c6_native.gd、.github/workflows/fs-pixellab-tc-c6.yml。僅 GH generator/scene/test/Handoff，真正 PNG 只存私人 Drive。
- **完整 8×8 tile／256×256 pixel 區段** [640,160,896,416]，tile origin [20,5]，保留完整 1280×928（40×29）村落和全部既有屋舍／主要森林來源。
- MASTER / Authoring_GroundOnly / Authoring_CompletePAR / Runtime_FullGround / Runtime_OcclusionPAR 在相同 XY、RGB 來源重組；C5 其餘區域 bit-exact；C6 5,823 RGB changed pixels。新增林間微地形、47 road-edge tufts、41 flowers、踏腳石。保留 C5 14 原有 owners，新增 C6 3 source independent masks，17 owners。
- 五個可重建 1× 獨立 RGBA 物件：一個森林石碑、兩種不同尺寸幼樹、兩個低石塊。其中 3 個真根部碰撞由 TC_C6_ROOT_FOOTPRINTS.json source 來；C5 2 屋舍 collider 原樣保留。**這些 1× 物件是程式手繪，不是新的 PixelLab API 正式生成。**
- ART review 的 C6 8×8 區段不是全村正式 ART PASS：新手繪幼樹/石碑 **風格過度簡化且與既有細緻森林不一致**。屬重大風格阻斷，禁止宣稱美術完成。

## WRITE → READBACK → VERIFY 已完成
- Godot Actions **[run 44872886638](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872886638)**：GitHub provider status=completed, conclusion=success；實測程式 commit **f68bfe8d216a59adc31e8191d87638ccf396bb4c**。
- 真 Godot 4.7.2 official GPU 1280×928 全村 native framebuffer：TC_C6_GODOT472_NATIVE_FULL_1X.png；依 native framebuffer 精確裁切的 TC_C6_GODOT472_NATIVE_REGION_1X.png；TC_C6_GODOT472_NATIVE_REGION_3X_REVIEW.png 是最近鄰放大的人工審查圖，不是原生 3× 截圖。
- 原生 QA TC_C6_GODOT_NATIVE_QA.json：engine=4.7.2-stable (official)，region 256×256，17 semantic owners、2 C5 house StaticBody2D、3 C6 sprite-root StaticBody2D；waystone hit=1、alder hit=1、rowan hit=1、原道路 hit=0、兩原房屋仍 hit=1。**同一足點石碑擋角與不擋角的真原生畫面差 204 pixels**；角色到石碑前方遮蔽關閉 PASS。並未驗證原 193 棵樹逐棵根部/NAV。
- **[私人 Drive C6 美術＋Godot QA ZIP](https://drive.google.com/file/d/1Hx77deDCUJe3JstjnOKJ4mm-2Uj1jXLu/view)**。Drive id 1Hx77deDCUJe3JstjnOKJ4mm-2Uj1jXLu；Google metadata readback size=69,755,419 bytes、shared=false、user owner only。外層 GH transfer ZIP 與內層 **40 files** 已雙層 ZIP CRC PASS；內層 SHA256 **425bc8bdf4c8bd156daa05a903d6b9748d91fca844e0bb69757c8aaf6729b08d**；artifact id 14694881670 保留一天，只作傳送。不使用 owner's PC。

## FAILURE LOG：含修復與真 ART 阻斷
1. 首次 native test GitHub [run 44872615732](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872615732) 失敗：腳本將 Texture2D.get_size() 的 Vector2 與 Vector2i 比較，拋錯並超時 124。已將比較改為 Vector2(1280,928)，新 CI run 44872886638 完整成功。非藝術問題。
2. **重大美術 HOLD：** C6 程式繪製的幼樹、石碑是平面像素色塊，與原本精緻 A36G/FS 森林在深度、光源、葉片有明顯不協調。這不是小細節，禁止以 5,823 px 修改或原生 QA 綠燈冒稱 Art PASS。**下一輪替換「整組」新物件源材，不在卡通葉片上打轉。**
3. 歷史 193 tree 真獨立 alpha 資產仍多在私人來源，不將 flattened PAR 裁出來假冒真 tree owner。新 3 個 1× 原生 root passed 不等於全森林 collision PASS。
4. C5 右屋依舊是原完整木屋 mirror+resize，ART HOLD。幽葉迴廊原 1478×1064 Ground nearest 拉伸至 2560×1856 舊問題仍 ART HOLD，本輪未動它。

## 下一完整 C7 施工單位
**整套 8×8 林間道路物件的同風格來源替換**。以核准的 FS 32×32、3/4 Style References 與真正獨立大樹／石物件，進行 PixelLab Object Creator / Map Workshop 真實生成或從已核准私人獨立來源直接整組替換。沒有可用 PixelLab API 時如實標示 NOT RUN，不偽造 job ID。保留這次已 PASS 的同源五圖與原生遮蔽/碰撞管線，換整組素材再跑全村真正 Godot 4.7.2 1× 與視覺 ART review。未核准前不合併 A35。

---

# T-C CURRENT｜C5 全村建築風格統一候選｜2026-11-21（Asia/Taipei）

**狀態：真正施工＋Godot 4.7.2 原生 GPU/屋舍碰撞/條件遮蔽 PASS；正式兩張地圖仍 ART HOLD。**  
**只使用指定分支：** `feat/fs-pixellab-tc-map-20261121`。不覆寫 A35 R2/R3、A35 R8 R3、Maze R12/R14 原始場景及素材；Godot，不回 VX。GitHub 只提交程式與紀錄，Drive 保存 PNG / 原始 QA ZIP，不存使用者 PC。

## C5｜當輪已交付的可觀察成果

- **新全圖 1280×928／40×29 格**：`godot_port/tc_factory/build_tc_village_style_c5.py`。從 A36G 歷史真正 PixelLab 來源 `A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png` SHA256 `964fe9bf9fe4048bc4b96fab573285cc9a2042faeefe38f1fde9501a23ccb699`，對**完整單棟** 284×259 source 作水平鏡像、Nearest resize 至 229×209 以及節制色調變化（不拼屋頂），生成一個真正獨立、可驗來源的右側木造精靈屋 candidate：`TC_C5_INDEPENDENT_WHOLE_HOUSE_RGBA.png` SHA256 `d9e970f9ce794861cd12a6a317856339e0e3e114093f64721cd9436aea0cf1c1`。
- 右側舊異風格建築 `A36F_ELF_COTTAGE_B` 的原有 PAR 位置在**獨立 C5 分支**以人工定義清除 mask 取代，新屋整棟位於 `origin=(795,390)`；保持原 C4 Ground／自然道路不變。C4 與 Production 底圖 source 並未覆寫。幾何相容完整 1280×928。
- 同源輸出 `MASTER.png`、`Authoring_GroundOnly.png`、`Authoring_CompletePAR.png`、`Runtime_FullGround.png`、`Runtime_OcclusionPAR.png`；新屋獨立 `occlusion_owners/owner_c5_whole_cottage.png`，所有舊 owner 的 RGB 依新 MASTER 重取樣，未拿錯舊 MASTER 做新屋遮蔽。STATIC compositor RGB 完全一致；修正 C4 `world_grid` metadata 誤植為 **[40,29]**。
- 右側木屋正式形狀使用整體來源之 `blocking_footprint_px` 作**幾何縮放+鏡像**得到新碰撞 `[810,535,1003,588]`，Godot Native 兩個真 `StaticBody2D` footprint；源段不偷用早已不含獨立 PNG 的舊右側屋舍。新屋周遭 PAR 以清除舊房屋及保留原始 Ground 手段過渡，消除原本嚴重的圓形青綠色屋頂與左側木造房屋錯配。
- 工程：`godot_port/tc_factory/TCVillageStyleC5.tscn`、`capture_tc_style_c5_native.gd`、`build_tc_village_style_c5.py`；CI `.github/workflows/fs-pixellab-tc-map.yml` 完全獨立於 Phase1，仍跑 C1/C4 regression，新增 C5 真 Godot 1× scene、碰撞及角色遮蔽、C4/C5 原生 A/B 比較。
- GitHub 本輪實測 commit **`d6f2ec817bd76c2fc36f395587fd3fe41d6f80a6`**（僅更動 artifact packaging，C5 工程來源與 `e5e50c447fd0b02885761133667a7a78522f5b72` 測試相同）。正式成功 [Godot Actions run 44835522347](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44835522347)，`completed/success`，包含 **Godot 4.7.2** 原生 1280×928 full framebuffer、兩棟屋舍及 path point-query。
- 原生 QA `TC_C5_GODOT_NATIVE_QA.json`：`engine=4.7.2-stable (official)`; renderer `opengl3`; `real_framebuffer=[1280,928]`; `occlusion_owners=14`; `independent_house_static_bodies=2`; `original_cottage_hit=1`; `new_harmonized_house_hit=1`; `road_open_hit=0`; `roof_behind_actor_roi_changed_pixels=204`; `front_footpoint_clear=true`; `native_C4_C5_roi_changed_px=37699`. 不將點查詢稱為完整角色導航測試。
- 真 Godot 原生 `TC_C5_VILLAGE_GODOT472_NATIVE_BEHIND_1X.png` 與 `TC_C5_VILLAGE_GODOT472_NATIVE_UNCOVERED_1X.png`；`TC_C4_C5_TWO_NATIVE_FRAMES_AB.png` 只是兩張真 Godot 1× 圖的衍生左右比較，不是單張原生 framebuffer。
- 原始 C1 / C4 已在歷史獨立私有 Drive 保存。本輪不修改舊 A35 R2/R3、Godot Phase1 系統、事件、戰鬥、傳送、存讀檔、迷宮 NAV。

## C5 私人 Drive 上傳及雙重驗證（雲端權威）

**[FS_TC_C5_WHOLE_BUILDING_HARMONIZED_VILLAGE_GODOT472_QA_PRIVATE_20261121.zip](https://drive.google.com/file/d/1rTW2Qm8qnphSlFfJ80TyTEUhEMCjp6PL/view)**。  
Drive id `1rTW2Qm8qnphSlFfJ80TyTEUhEMCjp6PL`，provider metadata readback **62,982,114 bytes、shared=false、user owner only**。外層 Github artifact ZIP CRC PASS；內層 `FS_TC_C5_PRIVATE_DRIVE_TRANSFER.zip` **47 entries，ZIP CRC PASS，SHA256 `a2294bddaf378a24cf501ee4542357ef53c536b9f566f2d0ea51275457824180`**。GitHub artifact `14677734959` 僅保留 1 天，是傳送渠道，不是最後留存位置；因 Drive 單次傳輸限制 100MB，僅封存 C5 full candidate + 全部 QA，舊 C4 封包另外留存，不重複囤積。

## C5 美術驗收及 Failure Log｜絕不假 PASS

1. **TECH PASS**：1280×928 尺寸與五圖來源、47文件寫入、兩棟屋舍原生碰撞、同位置角色屋頂遮蔽與未遮蔽的 native 1× 計算皆完成；C4→C5 真原生 37,699 changed ROI pixels。
2. **ART HOLD（重大）**：C5 已解除「圓形青綠屋頂 VS 木造屋頂」的明顯風格衝突，但兩棟木屋仍來自同一 PixelLab 歷史屋舍影像的全棟鏡像／縮放。建築獨立性與同源風格的多樣化 **尚未**符合正式封版標準。視角 3/4、光照方向與屋舍重複性需整體審美核准；不能僅因綠燈 CI 宣稱正式 FS_01_VILLAGE ART PASS。
3. **ART HOLD（森林）**：歷史 193 樹 owner 的獨立 PNG 多數只在私人 A35/R12 完整來源，公開 A36G branch 只有 3 個 SOURCE_INDEPENDENT_RGBA。現階段已在場的連續森林深度 12 strips 都是受控真來源，卻未逐樹驗證 physics/occlusion。**禁止從 flatten map 切出假樹**，只記錄限制並轉到下一個完整施工單位。
4. **ART HOLD（迷宮）**：FS_01_MAZE R12 真私人 2560×1856 工程依舊未本輪改動；其 Ground 曾由 1478×1064 NEAREST 放大，有比例及森林重複紋理問題。新 32×32 原生正規 Master 必須另開不可覆寫候選再 native QA；不能拿這次 1280×928 村落成績冒充迷宮 PASS。
5. **PIXELLAB_NEW_JOB_NOT_RUN**：本輪沒有新的 PixelLab Map Workshop / Create Tiles Pro / Object Creator / Style References API 實際生成或扣款；C5 只使用已封存的真 PixelLab 歷史來源，沒有新 job ID、seed、費用。獨立設計的完整右側房子最終應由一致 Style References 生成，而非依靠第一棟屋子的鏡像永久封版。
6. **非阻斷：老屋清除區少量剩餘植被 alpha**，影像觀察需下一輪 1× ROI 人體遮蔽評估。清除的是舊建築源區域，其餘地面完整。遵守小瑕疵最多兩修，不要在葉子上消耗整個路線。

## 下一個完整施工單位（不是重新研究）

**C6：森林／村落真正多樣化一整塊 8×8（256×256）相接區域**。鎖定 FS 核准色盤與 32×32，使用已保留 source anchors 完成原生地表、自然道路邊緣、完整不同樹型、通透前後遮蔽。優先換**整塊**自然過渡而非糾結樹葉尖角，固定同源 MASTER→四圖→真 Godot 1×+物理 QA。若 PixelLab 付費工具仍無已接入操作，不能冒稱生成；先利用原已封存且可核實的獨立素材，並把 PixelLab 真新設計列為 blocker。與 C5 同時保留完整村落候選，C6 通過後才推進 FS_01_MAZE 原生 32×32 Ground 整區段替換。所有正式 Art Seal 暫 HOLD。

---

## C4 VERIFIED｜2026-11-21 06:55 TPE｜新於以上 M1 紀錄，以下結果優先

**C4 COMMIT (HEAD AS TESTED):** `0de4ef85e1555622edeee3a078f2acbd8f18f7f9`
**C4 GODOT 4.7.2 CI:** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44832598287 ，GitHub provider `status=completed`, `conclusion=success`，包含原生真實 GPU 全圖與遮蔽/碰撞測試。不覆寫現有正式 A35/R12/R14。
**C4 PRIVATE ART + QA ZIP:** https://drive.google.com/file/d/1O9ooTnyg-sVeWSW514u2fgQ2JRbdK1uD/view
- Drive id: `1O9ooTnyg-sVeWSW514u2fgQ2JRbdK1uD`; 實際 Google Drive readback `size=60349840`, `shared=false`，`user owner only`，私人 My Drive/root。
- 上述檔案含外層 GitHub artifact ZIP 和內層完整 art/QA ZIP；已在雲端 container 做雙層 ZIP CRC 驗證，內層 **81 項**（含 Godot 原生 screenshot）。
- GitHub Actions 暫存 transfer artifact `14677561436`（1 日保留），並非正式存檔。正式私人資產為上述 Drive。

### 本輪完整產物：Village C1 小樣 + C3/C4 全村候選

| 施工單位 | Source Master | GroundOnly | CompletePAR | Runtime FullGround | Runtime OcclusionPAR | 原生 QA |
|---|---:|---:|---:|---:|---:|---|
| C1/C2 test pilot | 544×416 | PASS 靜態 | PASS 靜態 | PASS 靜態 | PASS 靜態 | Godot **4.7.2 PASS** |
| C3/C4 `FS_01_VILLAGE` **全圖候選** | **1280×928** | PASS 靜態 | PASS 靜態 | PASS 靜態 | PASS 靜態 | Godot **4.7.2 GPU 1× PASS** |
| FS_01_MAZE 原生 R12 基準（未改動） | 2560×1856 | 舊基準 | 舊基準 | 舊基準 | 舊基準 | 既有 R12 舊測 PASS，**本輪未重測** |

- `generated/TC_GODOT_NATIVE_QA.json`: `engine=4.7.2-stable (official)`, `framebuffer_px=[544,416]`, `owners_loaded=12`, `behind_visible=1`, `front_visible=0`, `actor_roi_changed=true`。同座標 1× 真原生 A/B 實圖變化 **204px**，來源於 Godot GPU 原生 screenshot，非合成插畫。
- `generated/TC_PILOT_SOURCE_QA.json`: `world_grid=[17,13]`、`STATIC_PASS_RECOMPOSE_RGB_IDENTICAL`，房屋 1 + 真 PixelLab 連續森林 11 depth strips，沒有偽造獨立樹木 source masks。
- `generated_full/TC_PILOT_SOURCE_QA.json`: `canvas=[1280,928]`，`STATIC_PASS_RECOMPOSE_RGB_IDENTICAL`，房屋 1 + 真森林 12 depth strips，完整 Master／Ground／PAR 五圖供美術驗收。注意此 JSON 的 `world_grid=[17,13]` 目前是第一版未同步的 metadata 殘值，**全圖實際 40×29 tiles**（1280／32=40、928／32=29），列入非阻斷資料缺陷，待下一宏觀區段一併改正。
- `generated_full/TC_FULL_VILLAGE_NATIVE_QA.json`: `real_framebuffer=[1280,928]`, `gate=FULL_SCENE_GPU_1X_PASS_NOT_ART_PASS`，`owners_loaded=13`，獨立場景真正運行；`house_collision_hits=1`, `open_road_collision_hits=0`。
- 兩種解析度均使用**既有真來源**屋舍 `blocking_footprint_px=[379,389,618,454]` 創建 `StaticBody2D` + `CollisionShape2D`，Godot 原生 physics-space point-query PASS；**森林樹幹、水域和全區 path collision 未在新 T-C 證明**，不能拿房屋 PASS 冒充全圖 collision PASS。
- 程式擴展實績：`build_tc_village_full.py`, `TCVillageFullCandidate.tscn`, `capture_tc_full_village_native.gd`、`TC_PILOT_COLLISION.json`，新 CI 同時跑 C1 小樣與 C3 full 1× GPU；沒有碰傳送、存讀檔或既有 Godot Phase1 遊戲主線。
- **PixelLab 新工作：NOT RUN，沒有 API job、seed、模型、新料金。** 現成 A36G 的房屋與森林是歷史上真 PixelLab 成品；本輪新建的是組圖、美術來源遮罩、背景植被、引擎分層及驗證，而非假冒 Create Tiles Pro/Map Workshop 新模型生成。

### Visual Art Review（有讀取真 Godot 圖，非虛構 QA）

- **G2 靜態像素來源 / 1× 完圖：已 PASS TECH**，可復現。
- **G3 條件屋頂遮蔽：sample PASS TECH**，full scene GPU 載入與 footprint physical check PASS。未將森林每棵樹 alpha 冒名聲稱通過（193 tree records 的獨立素材絕大多數只在私人來源，未輸入本 GitHub T-C builder）。
- **G1/G6 美術：ART HOLD**。原生 full screenshot 視覺檢查指出右側圓形的青綠巨屋頂與左側木造屋舍材質、視角、建築語法不一致，屬**重大風格錯誤**；亦有樹冠重複/過密拼貼，不因 CI success 升 Art PASS。
- **舊 A35 R8 R3、迷宮 R12/R14 的正式美術狀態一律 ART HOLD。** T-C 全圖是獨立候選，不可自動替換正式 Godot map。
- Maze 既存真工程已成功從私人 Drive 複查來源：`FS_01_MAZE_R12_LIVE_ROAD_NAV_FULL_GODOT_PRIVATE_20261116.zip`，113,804,051 bytes、241 entries、ZIP CRC GOOD，原生 1× 圖 2560×1856；沒有覆寫或編輯，R14 較新的候選也尚未 native GPU PASS。

### 追加根因：FS_01_MAZE 原生來源 Ground 規格（已實讀私人 R12 工程）

私人 R12 ZIP `data/fs_01_maze_a36c_r7_reconciled_manifest.json` 明列：`source_ground.size=[1478,1064]`、`runtime_ground.size=[2560,1856]`、轉換為 `PIL.Image.resize NEAREST`，且 **非等比例縮放約 0.7%**，原紀錄已標註 `ART HOLD`。所有 326 個場景 PAR 由 `res://private_assets/independent_par/*.png` 裝配，保有原生腳點、資產 SHA、310 棵樹、2 屋、6 燈、1 井、7 石，原始 Godot 角色/水碰撞/導航既有通過證據不宜重做。這是讀取真 ZIP Manifest 和 scene/script 所得，不是猜測。

**施工決策**：迷宮 GROUND_ART_ROOT 必須使用 PixelLab Map Workshop/Create Tiles Pro 的連續同源 32×32 native tile 素材方案重做大區段，禁止把 1478×1064 再拉大當成合格 pixel-perfect 2560×1856；PAR 326 個真獨立源保留並先校準到新 Ground，不從整張合成圖去切假 sprites。所有全域 NAV 與原生碰撞證據保留，改動只針對美術。

### FAILURE LOG 決策與下一個「完整施工單位」

1. `TC_MAJOR_ARCHITECTURE_STYLE_CONFLICT`：**BLOCKER**。停止局部拼房；用一致的 FS 核准參考調用 PixelLab Object Creator + Style References，輸出**整棟**右側屋/工坊、獨立源 alpha 和精確 pivot，整體替換右側風格錯誤建築；禁止拼不同屋頂塊。沒有 PixelLab 工具/API 連線時不得偽稱已完成生成。
2. `TC_FOREST_ECOLOGY_CLONE`：**BLOCKER**。改用 PixelLab Create Tiles Pro 的自然草/路 32×32 與 Map Workshop 語意地形，跨區使用連續森林場景來源，避免 193 棵重複複製樹。重製整個樹林過渡區，而非反覆微調單個像素。
3. `TC_TREE_PRIVATE_ALPHA_MISSING`：森林全區的源 alpha/物理 root tree 來源不完整，獨立真文件 only 3 in public GitHub；不可由 flattened PAR 估計冒充真正 mask。下一輪改用已下載私人 FS 原生 Maze、A35 scene 的獨立 alpha，先校驗 source hashes，並在 Drive 保存。
4. `TC_FULL_WORLD_GRID_METADATA`：**non-blocking**，全圖 QA `world_grid` 舊值誤報 17×13，真尺寸 40×29；下一輪一起修正，不消耗專門美術迭代。
5. **最高下一完整單位**：完成「**整個右側屋舍與周圍 8×8 格地表／森林過渡**」同一構圖、同一來源、四圖契約＋原生角色遮蔽＋collision；接著延伸至迷宮完整森林區段，保留所有 2560×1856 既存導航工程。每項非阻斷小瑕疵最多兩修，大面積視覺錯誤換方法，不封 Art PASS。

### SHO-39 / storage

- Linear SHO-39 已實際寫入第一個 T-C 施工同步 comment，id `b87e0242-2b50-41ca-8e70-ceaebfd10825`。C4 完整成果需再更新 comment。
- GitHub code `0de4ef85...` 與此 handoff；資產在 owner-only 私人 Drive `1O9ooTny...`，GitHub temporary one-day CI artifacts 僅供傳送；**未存至使用者 PC**。

---

# Forest Symphony｜T-C 地圖美術工廠｜CURRENT HANDOFF

- Date: 2026-11-21 Asia/Taipei
- TARGET: T-C / FS_01_VILLAGE 苔光村 → FS_01_MAZE 幽葉迴廊
- STAGE: M1 完整可檢查樣本 + M2 Godot 4.7.2 原生驗證啟動
- STATUS: ACTIVE / ART_HOLD
- BRANCH: `feat/fs-pixellab-tc-map-20261121`
- PREVIOUS BRANCH HEAD: `4a2a50e3aacb3115dbb3418b6e229b8a34c430d0`
- SOURCE CODE COMMITS: `d7f2ade886fd180a3617cc40aae4a6bf62e1c359` → `ad6e8e1d2892b28875577206385cd6b550287b1c`
- ACTIVE RUN: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44830675005
- FORMAL ART SEAL: **NO**. 此工作未改變原 A35 R2/R3、FS_01_MAZE R12/R14 或任何 VX 正式來源。

## Baseline 權威、Drive Handoff

1. 正式 [T-C launch prompt](../research/launch/T_C_MAP_LAUNCH_PROMPT.md) 與 [3 experiments roadmap](../research/FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md)。
2. 原始 Ground3 正式身份：`Graphics/Parallaxes/ground3.png`，SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`，不是 `Overlays/ground3.png`。
3. 苔光村 A35 R8 R3 已有 187 PAR / 175 canopies，Godot 4.7.2 native + nav 舊測 PASS、藝術 HOLD。完整私人 Drive: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view。
4. 幽葉迴廊 R12，80×58 tiles，326 complete PAR / 310 trees，來源原生 + 231 foot sweeps 舊測 PASS，藝術 HOLD。私人 Drive: https://drive.google.com/file/d/1VikZtZc0YWhHFNMjylNGXFEbN2_oW6qR/view。
5. Nov18 R14 對迷宮 PAR 樹型及 Ground 做候選修改，但 native GPU 未驗證；ART HOLD。私人 Drive Handoff: https://docs.google.com/document/d/1iibkZ2MSgwEoWZUpUKTpNUTuaDRXgpcs/edit。
6. 本輪 SOURCE：公開既有 A36G PixelLab 村落整圖來源 `experiments/route_b_25d_20261031_stage16/a36g_pixellab_r3b_20261104/` 的 `A36G_GROUND_1280x928.png`, `A36G_PAR50_RGBA_1280x928.png`, `A36G_SCENE_MANIFEST.json`，而非原 A35 私人編輯工作圖。這些來源屬歷史 PixelLab 成果，不是本輪新生成。裁切起點 (256,115)，尺寸 544×416 = 17×13 格。

## DELTA：已真正提交的程式與工作單位

- [build_tc_village_pilot.py](../../tc_factory/build_tc_village_pilot.py)：用真實 A36G Ground+PAR+Manifest 生成獨立 544×416 T-C 候選及小範圍原生像素花草變化；嚴格來源驗證，缺檔直接失敗，不生成合成偽原圖。輸出單一 MASTER、同源四層：
  - `MASTER.png`
  - `Authoring_GroundOnly.png`
  - `Authoring_CompletePAR.png`
  - `Runtime_FullGround.png`
  - `Runtime_OcclusionPAR.png`
  - `occlusion_owners/owner_*.png`、兩項 JSON QA/owner manifests
- [TCVillagePilot.tscn](../../tc_factory/TCVillagePilot.tscn) + [TCVillagePilot.gd](../../tc_factory/TCVillagePilot.gd)：專屬非正式地圖場景，544×416，Nearest，Ground 與精靈屋/樹冠分離，依測試角色足點條件顯示局部遮蔽物。測試角色為佔位畫像，**不是**已認可的 FS 正式角色。
- [test_tc_village_native.gd](../../tc_factory/test_tc_village_native.gd)：使用 Godot 4.7.2，啟動場景並採集真正 SubViewport 1× 幀，移動測試角色驗證 roof/canopy 的前後遮蔽，原始 framebuffer PNG 和執行 JSON。
- [.github/workflows/fs-pixellab-tc-map.yml](../../../.github/workflows/fs-pixellab-tc-map.yml)：在獨立 T-C 分支由 GitHub Linux runner 完成 Pillow source/layer 產出、Godot 4.7.2 原生匯入、xvfb GPU screenshot QA、生成 ZIP 供私人 Drive 轉存。原專案正式 main/Phase1 CI 不變。

## QA 最新、不得提前升版

| Gate | Status | 實際證據 |
|---|---|---|
| T-C source generator | **PASS，GitHub runner** | run 44830675005 build step completed success，實際圖像保存在 runner 暫存空間 |
| Godot 4.7.2 editor import | **PASS，GitHub runner** | 同 run，editor import step completed success |
| Godot 原生畫面、測試角色遮蔽 | **NOT YET VERIFIED** | CI 正在執行時記錄；需取得獨立 framebuffer PNG 及 JSON，驗證才可 PASS |
| collision/footpoint source-independent semantic QA | **HOLD** | 目前測試中 actor 不是完整 CharacterBody2D 碰撞驗證，且 owner masks 暫採 combined PAR crop |
| overall FS art / house / forest ecological diversity | **ART HOLD** | 完整小樣尚待原生 1× 整圖 review，不能把可輸出等於藝術可接受 |
| FS_01_VILLAGE/MAZE full-map artist approval | **NOT RUN** | 這是 17×13 pilot，不是兩張全圖交付 |
| PixelLab Create Tiles Pro / Map Workshop / Object Creator new job | **NOT RUN** | 本輪重用 A36G 已有 PixelLab image，沒有呼叫新的 API、無 job ID / seed / actual charge |
| Drive new candidate / native QA | **PENDING VERIFIED UPLOAD** | CI 原始 art 和 QA 必須轉存 owner-only Drive，並讀回 size/shared |

## FAILURE LOG（不得假 PASS）

- `TC_SOURCE_OWNER_MASK_OVERLAP` **BLOCKER**：第一版為各獨立 source owner bbox 在已合成的 CompletePAR 取 alpha，可能含其它樹/屋物件的重疊像素。改善方法：下一版使用同名 `SOURCE_INDEPENDENT_RGBA` 的每個 owner 真正獨立 alpha/mask，再依 frozen MASTER 取 RGB，不從整張 CompletePAR 估計個體。
- `TC_OLD_ART_STILL_HOLD` **BLOCKER**：歷史 A36G 的森林與建築先前未取得 ART PASS；此 pilot **不能**消除既有視覺缺陷。換方法需重新生成具有統一材質的完整屋舍和自然森林 Master。
- `TC_PIXELLAB_NEW_JOB_UNAVAILABLE` **DEPENDENCY**：目前可用 connector 未曝露 PixelLab 直接生圖/Map Workshop 操作，本輪只可合法重用 A36G 現成來源。若日後接通，記錄精確 job/model/seed/cost 並封存私人 Drive。
- `TC_DRIVE_TRANSFER` **PENDING**：GitHub Actions 1 天暫存 artifact 僅為轉送用，必須轉私人 Drive 並驗證，不當正式雲端來源。

## NEXT MACRO UNIT

**先完成 1 個真的可審核「完整視覺場景」**：通過 Native QA 後，使用每個獨立屋頂/樹冠 alpha 重建遮蔽所有權；在私人 Drive 保存全部五圖＋兩張 1× 原生幀與 Source Manifest；做第一輪 1× 視覺評分，若整體樣式不合格換完整樹型/屋舍素材，不對像素尖角連改超過兩次。接著擴大至苔光村真實 1280×928 完整區段，再依同源四層及風格規則延伸至幽葉迴廊的 2560×1856 完整森林區段。**禁止碰傳送、存讀檔或 NAV 重構。**

## P0 Storage/Sync

- GitHub 只保存公開程式、QA 計畫、Manifest/Handoff 文本；二進位生成圖片及真正 source QA 必須在私人 Google Drive 保存。
- 不在使用者 PC 建立工程/素材庫。GitHub CI runner 是暫時工作空間。
- 本輪 GitHub first write OK，CI build+editor import readback OK。Drive WRITE/READBACK 與 Linear SHO-39 本輪操作須另行驗證後填寫。
