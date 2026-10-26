# FS AI MAP PRODUCTION V5 — 2026-10-26
狀態：工作流程更新 / ART NOT PROMOTED。只新增隔離 SOP 與 QA，不修改 FS 已封版、其他對話目前施工檔、F1R1 A04 等原資產。
現行權威：FS v3.2 Scene Manifest + fail-closed Gate A-F；Style-first v4；2026-10-25 v2.8 Ground passability/ART SOP；2026-10-26 F2 G5R3 actor-scale/plant semantics；新需求若衝突以最近、更具體者優先。

## 實際現況（從 Windows 與 Drive 檢查）
- F1R1 A04 已由使用者視覺驗收，SEALED，保持唯讀。v2.1 水井使用者 PASS，v22 神聖樹可玩測試 OK，不能擴張為全部精靈村正式通過。
- F2 G4 45×34 / 1530 格，真 RGSS2 Game.exe 碰撞及關門/門前通行技術 PASS。但 full Ground donor patch 路面接縫美術 FAIL，人眼未過。
- F2 G5R3 320×256，80 個 32×32 tiles，原始 RGB 重組差 0；從實際 Actors.rvdata 找到 Actor1 RTP，frame 32×32，visible 28×32；右下 9/80 格來源需獨立植物物件語義審查。目前花叢不是精確 Alpha，只是 96×96 review ROI，源圖邊界裁掉部分花。Ground ART FAIL，需 F2 G5R4。
- FS v2.5/2.6/2.7 即使截圖非角色 0px drift，使用者因道路、Ground 自然度、屋根接地否決。v3.1 處理房屋上下材質不一、木樁缺像素、門前1格被堵；有部分 native TECH，但 ART 未過。不能把科技檢查當成藝術肯定。

## 五組技能分工
1. router 先定任務與載入少量技能；RPG Maker VX/RGSS2 未列在第三方 engine map，禁止 router 默認用 Godot 改寫 VX。
2. level-design：32px world grid、玩家實際可見尺寸與 footbox、spawn/exits、連通、門前空位、攝影機。先只做幾何白盒，不以泥路畫法決定可走區。
3. create-game-assets：Drive 六張 Style DNA 參考、角色1x相對尺寸、素材家族/完整輪廓/表面細節/陰影/版權/明確 Manifest；不合美術不能靠拼接技術洗白。
4. generate2dmap + generate2dmedia：僅在有真實生圖路由或可合法重用 source 時製作高品質 Ground-only 與單件透明物件。無 image API/CLI 時停在 brief 或整理來源，禁止用 codeart 色塊冒充完成的參考級 Ground。generate2dmap map_bundle 可作驗證/adapter，FS Scene Manifest 仍是唯一座標權威。
5. procedural-gen（僅輔助有種子的地形/密度參數，不亂用 donor quilt）；Tiled/Pillow 兩個獨立編譯驗證；Godot-tilemap 僅測 Godot adapter，Windows VX Game.exe 才是 RGSS2 引擎事實。

## 全新地圖流程：P0～P7，前一關不過不能晉級
P0「權威＋來源」：先讀最新 CURRENT_HANDOFF、原始素材 170 項索引、六張 STYLE 基準、成功案例 F1R1 A04/水井/神聖樹，以及失敗的花叢/房屋/道路。保存每個原檔 SHA256、來源權利與引用位置；原始圖、SEALED 不覆寫。LICENSE_PENDING 的素材僅私有測試。

P1「遊玩幾何＋真實玩家比例」：取得真正使用中的 1× VX 角色 PNG 及腳點，不能僅假設角色恰好一個 cell。以角色 28×32 的本次實際值審查房屋、草叢、石頭大小，標源截斷物件。宣告世界長寬（多個 32px 格；544×416 是可視視窗非世界上限）、出入口、門前至少一格可站、spawn、路線；純 Ground 草泥草花全部可走，只有明確的水/洞/崖缺口例外。

P2「先讓 Ground 本身美術通過」：從一致 Style DNA 製作原創/合法單一 coherent Ground-only：草土路、自然邊緣、地表小花、泥路彎曲與交叉，不含完整房、樹、石、巨大花叢或立面、也不含裁斷的植物殘影。現在的污染 G5R2 不能直接因來源80格0 drift而當可交付 Ground。Ground-under-object 不存在乾淨原始 source 時，就新製作完整連續 Ground；不得模糊、貼 donor 方塊、Bayer/dither 強行掩蓋接縫。提交全地 Ground-only 1×/nearest 2×與 3×3 重複/十字路檢視，沒有方塊切邊、巨型地花、糊化。ART 視覺 FAIL 立即停，不製作整村 PAR。

P3「所有立體物件整體 Source」：房屋、樹、石、花、井、木樁及橋都單獨做完整透明 Source；原圖 parent ROI/Sheet SHA、完整屋頂與屋簷/煙囪/外牆/窗門/木樁/台階/花瓣、真正 Alpha、邊緣沒有截斷及鄰物污染。只加透明 padding 不能修復缺掉的源像素；largest connected component 不能直接刪附件。房屋上部下部同材質，獨立 1× actor 比對，源素材被截斷就重製或 Source 修復，不靠下層遮罩掩蓋。

P4「分層與接地語義」：對同一原始物件分出 PAR_COMPLETE、BASE、ACTOR_OCCLUSION、FOOT_CONTACT_COLLISION、GROUND_CONTACT_TRANSITION、CONTACT_SHADOW、HEIGHT。花叢可以是 PAR 但仍屬 SOFT/WALK，屋簷/樹冠只遮擋不封路；樹幹/房牆/實物腳點擋路。接地過渡與陰影需分層、局部 100% 正負對照，不能把底層材質切斷。Ground terrain exceptions 和 PAR footprint blockers 各自單獨 Mask，再由單一 Scene Manifest 合併碰撞。

P5「唯一 Manifest 的編譯」：Source Asset / Semantic Masks / Manifest 皆帶 Instance ID、原 SHA、world XY、foot anchor、z、height、尺寸及權利。決定性輸出 Ground opaque、COMPLETE PAR alpha、BASE、Occlusion、PixelOwner、Collision、Events、Tiled、Godot、VX。不能在另一輪 AI 對完成 Ground 獨立生 PAR；不能各圖層手拉位置。嚴格RGBA四通道 byte diff，故意 +1px、失去木樁、錯誤門前碰撞、花叢殘影、Alpha0 RGB、場景source SHA竄改都必須被 gate 擋下。0diff 僅技術通過。

P6「雙引擎真實驗證」：先在獨立副本編譯，更新實際 RGSS2 Scripts.rvdata/MapX collision 而不是僅 Collision.png，真 Game.exe 實走測試門前站位→門關擋、樹冠前後、花叢 soft、屋右/上下、camera scroll。抓真 Game.exe screenshot 並記 loaded file SHA 以排除 Chrome/舊版畫面冒名；native 実際 PNG 來源與同源重組可比對。Godot另行測接地/遮擋，但不代替 VX。

P7「人眼視覺＋封包/交接」：使用者必須逐項看到 Ground-only、每件透明 Source、局部接地與整場 1×、2×、Native Game.exe 實機，明示接受的 scope、版本、來源 SHA。機器無法自行簽署 HUMAN PASS。封包 Source/Manifest/Masks/Blueprint/Ground/PAR/Collision/Godot+VX Test/CMD/LOG/negative tests/README/CURRENT_HANDOFF；Private ZIP 上傳 Drive 讀回 SHA/CRC；GitHub 僅合法 code，Linear SHO-39 留狀態。不因其他對話施工而修改其封版或 CURRENT_HANDOFF。

## 下一個最小施工單：F2 G5R4，暫不擴村
(1) 從 G5R3_UNCUT_WIDER_FLORA_SOURCE_CONTEXT.png 回溯原圖，隔離完整花叢 pixel-tight 真 Alpha，含花/莖/葉與真腳點；9個 flagged cells 只是 screening，不是完整物件。
(2) 建立 320×256 coherent 草泥 Ground-only（整片乾淨、角色 1× 尺度合適、不能仍包含高花叢）。首個關卡就是 P2 地表 1×、2× 人眼與自然紋理，不合就退回編修 Ground Source。
(3) 通過後只加 1 組透明可走花叢、1 棟輪廓完整且同材質房屋。按來源所有權分出 contact/depth/collision。先測門前格及多方位角色，再加其他物件。
(4) 用既有 FS v3.2 確定性 Compiler 統一輸出，真 native VX＋Godot、負面回歸，最後使用者 Gate。人工前不可往完整精靈村、城堡鎮或多高度擴張。
(5) 註：目前遠端 Forge Doctor 未找到 Image Generation API / 正常登入的 CLI 路由，僅可準備 Style DNA、原資源處理、驗收腳本；不可假裝已完成新的高品質 AI 生圖。

## 防止重犯：缺陷登記
FS-ART-101 Ground blur / low-detail；102 房屋上下材質不連續；103 木樁、簷角、花瓣 crop；104 donor-block 地面接縫；105 高花叢佔據 Ground / player scale；FS-COL-201 門前可走格被擋；FS-RUN-202 Collision Mask 和 Scripts.rvdata 不一致；FS-QA-301 TECH PASS 冒充 ART PASS。每次 CHANGE_LOG：問題、before、根因、修改的 SOURCE ID/SHA、after、正測/負測、尚存風險、判定、下一步。

## 維護與權限
本 V5 不覆寫 FS v3.2/v4、v2.8、最新場景 CURRENT_HANDOFF，也不取得使用者對未展示的新圖的「藝術核准」。新對話先讀當日場景 Handoff，再讀 V5 補充 SOP，兩者共同適用。新 Gate 程式在 E:\GameAssetToolLab_20261023\MAP_PIPELINE_V5_20261026，唯讀稽核，current fixture 預期 BLOCKED_VISUAL(exit2)，不是執行失敗。完成新地圖的 P0–P7 全有證據且人工核准才正式 PASS。

Drive copy: https://docs.google.com/document/d/108VSYMZ0ptdF_H8VID25VHCBBGlj9_mMfG5RnHUsiz4/edit
