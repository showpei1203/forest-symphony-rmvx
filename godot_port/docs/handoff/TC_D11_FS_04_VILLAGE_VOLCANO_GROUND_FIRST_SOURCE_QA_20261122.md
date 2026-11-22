# Forest Symphony | T-C D11 | FS_04_VILLAGE 灰鑄工坊城 | Ground-first 成功，完整 PAR HOLD

**日期：2026-11-22（Asia/Taipei）｜正式引擎 Godot 4.7.2｜分支 `feat/fs-pixellab-tc-map-20261121`**

## 一、真正的新火山 Ground

這次**真的生成了赤焰火山純地表 Ground 候選**，不是 D10 接續失敗的砂漠誤圖：玄武岩/火山灰鋪地、中央圓形工坊廣場、道路、熔岩流與岩漿裂隙都已呈現在一張**不帶房屋、熔爐、鐵橋的獨立圖**。原始圖 **1477×1065 RGB**，SHA256 `ecd256d48aaa7c4fc33b0c0f19bd5b516c998239c779e927468aa4ebc3d33af4`。

依事先既定正式村莊世界座標 **40×29格@32px**，僅用原生 crop `[98,68,1378,996]` 得 **1280×928 RGB Ground**，SHA256 `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d`。未縮放、未插值、未從 Master 反切。另存 `[2,4,1474,1060]` 之 **1472×1056／46×33** 全構圖參考，不擅自更改原村莊 40×29 正式尺寸。

Ground-only 純度初步畫面檢查：無主要立體工坊／煙囪／鐵橋／NPC/路標，但邊界自然玄武岩臺地有少量側壁高度感，**正式 ART HOLD**。本輪只確認來源與 32px 格尺寸，不能聲稱完成 FS_04_VILLAGE 美術封版。

## 二、CompletePAR 生成：五次全數 FAIL，不可充數

使用者明訂之唯一作者層規則：**先 Ground，後透明 CompletePAR；房屋、熔爐、煙囪、鐵橋、岩柱、燈、旗、礦車等全部非地表物件都在 PAR，無論是否遮住玩家。** 全景 Master 不可當 PAR，更不可從已合成圖逆向切前景。

本輪輸出五張「城鎮第二階段候選」但實際檔案不符：
- 第一張 **RGB、1477×1065**，不是 RGBA，也是一整張含熔岩和路面之火山城 Master，SHA `a3d4dacb0225aabdf21b0b014fbcb23df029c81679a2daf84d55722d97eb5512`。
- 第二張 **RGBA alpha min/max=144/249**，完全透明背景像素 **0**，SHA `015f456710e7b0f7e9e7abd1511125ca9757b96097b2b651ede39b189415715d`。
- 第三張 **RGBA alpha min/max=184/248**，alpha=0 **0**，SHA `bdc7a0c02c5ddf7f8938b3e6577f9013e1c5e9522476785d4cbf07dfc251dc8b`。
- 第四張 **RGBA alpha min/max=218/249**，alpha=0 **0**，SHA `4087865cd127ed244ecf2dbd03b1a8849907b152de7f1797d7cc2378f2585a52`。
- 第五張 **RGBA alpha min/max=156/248**，alpha=0 **0**，SHA `47325b1b87ce418e37647ca6a381bb3a623cc2012c293c384b4048cf2bcd72f3`。

五張均包含大面積地面、熔岩和立體建築，不是獨立透明全非地表 PAR，已**全部拒收**，不做虛假 alpha composite，不上傳為 PAR 正式素材。**本次 CompletePAR = NOT_GENERATED；Ground+PAR 靜態配對 = NOT_RUN；Godot 4.7.2 Native = NOT_RUN；正式 ART 0/12。**

## 三、實際像素地形身份驗證與共用工程

已延伸 `godot_port/tc_factory/biomes/fs_biome_identity_guard.py`，新增 `CRIMSON_VOLCANO` 粗辨識，採「大片深灰玄武岩 + 少量亮橘熔岩」而不是單看暖色：
- 真火山樣本 160×116 sampling：玄武岩暗色比例約 **0.857**、熔岩比例 **0.030**、暖色 **0.048**。
- 前一輪錯誤砂岩來源：玄武岩暗色比例約 **0.036**、砂金暖色比例 **0.982**，不准被認定是火山。
- `test_fs_biome_identity_guard.py` 新增 volcanic synthetic 及交叉拒收，8／8 測試通過；**[GitHub Actions run 44994736999](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44994736999) completed/success**。
- 這只是地形防錯與基本來源 QA，**不判 Ground 層語意、PAR 完整度、橋路位置、美術好壞**。

## 四、Google Drive 私人來源封存，WRITE → READBACK

**[D11 六檔完整 Ground 原圖／40×29 PNG／46×33 參考／Grid QA／JSON／Failure Log ZIP](https://drive.google.com/file/d/11jWGIU54Lk8eyfwLGJs-YbKZU1W6ezIM/view)**，**11,777,655 bytes**，6 entries、ZIP CRC PASS，SHA256 `80e74d17f3db3b0af26a523339a85fae23e6eae4ed1f1058114a63a3b59107f0`。這是最終包含 5 次 rejected PAR 檢查的版本。

獨立可檢視：
- **[Ground 正式尺寸候選 1280×928](https://drive.google.com/file/d/1O8lKij4P8JgxczP2Q1Ykt-RKnhyk56RL/view)**，2,484,856 bytes。
- **[Ground 原始未裁 1477×1065](https://drive.google.com/file/d/1fmrna0wMmv24LRxokUNn3b6mNEOd1aRb/view)**，3,668,004 bytes。
- **[Ground 全構圖參考 1472×1056](https://drive.google.com/file/d/1BKyxcOfGPglyw-0pnChwVXUhYjsD0siN/view)**，3,219,381 bytes。

以上四項 Google Drive metadata API 均 readback `shared=false`、only `user owner`。原始私有圖像只在 Drive，不放公開 GitHub，未操作使用者 PC。GitHub 僅保留 Blueprint、QA 與 Handoff。

## 五、下一個完整單位，不走偏

**繼續完成這張 FS_04_VILLAGE 的真正透明 COMPLETEPAR**：同一張鎖定 1280×928 Ground 世界 Blueprint，整張一次生成完整工坊、熔爐、煙囪、鐵橋、立體岩柱與裝飾，真 Alpha=0 透明底；**不可輸出另一張全景城鎮 Master**。完整兩張圖先同原點合成作整體風格與落點 QA，再由 Godot 4.7.2 原生渲染測試及人工 ART Gate 驗收。新 imagegen 反覆不尊重透明輸出時，應改成能確實提供獨立透明畫布/風格參考的可控生成服務，**不應把不合格圖人工反切偽造 PAR**。

其後同色盤 FS_04_MAZE 熔脈裂橋 Ground-first + completePAR，再沿已核准世界表 05 幽霧水澤、06 星晶浮島各村莊/迷宮。正式 ART PASS 仍 0/12。
