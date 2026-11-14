# A34–A35｜Actor01 核准雙關鍵影格 → PixelLab V3 雙向 Interpolate → 八幀 RUN 技術候選
日期：2026-11-14。**A34/A35 provider PASS；完整八幀技術候選 PASS；美術 ART HOLD；正式 VX/Godot battle import NOT_RUN；不覆蓋 A62/main。**

## 真正執行的生成工作與花費
- A18 owner-only 私有原始封包 `FS_A18_ACTOR01_RUN_PROVIDER_READY_PRIVATE_20261109.zip` 內的 A62 核准 `ACTOR01_A62_APPROVED_RUN_1/2/3.png` 是本階段唯一本體來源，三張皆 **48×48 RGBA**，在 64×64 透明畫布 offset (8,8) 一次整張貼上，**沒有重描、拉伸、縮放**。原始 SHA256：
  - RUN_1 `6b25abb1dd702701716844a2ad36dfb8bfb8e3eccaf87fe7b15b2b85a41d101d`
  - RUN_2 `a96d6d4df959f66cb5cc08aa78e7b8f7a22f9e37140584b0fb3c928bc5b37029`
  - RUN_3 `84a8edb267bea9608d40de9f3af9b20050d7e85ef2293f0cd4d4199045107b79`.
- A34：使用者已登入的 Chrome PixelLab Creator → **Interpolate V3**，First frame = approved RUN_2_64，Last frame = approved RUN_3_64，Frame count 4，action 提醒固定 45°、同一白髮綠甲、腿從一個領先位置切換另一個位置。UI 顯示 **Generate · 1 generation**，實際執行；Gallery **97→98**，真實下載原始 GIF **64×64、5 frames、3,734 bytes**，原始 sheet PNG **192×128、6,200 bytes**；原始 SHA `ad2bc8b7cd145968e0b427c99d7a87ba2857b838d8a210de8ccd7abb551ea970` (GIF)、`5100c86346b7e73548e275a6deb677440a409263579ec02b16391fee2da76c6e` (PNG)。
- A35：在 review A34 真實原始輸出後，用相反的核准端點 **RUN_3_64→RUN_2_64** 再提交 **一次 V3 Interpolate**、Frame count 4，UI **1 generation**、Gallery **98→99**；真實下載 64×64、5-frame GIF **3,704 bytes**（SHA `199d481c0b16b3d664dbeaf2506f3be8bbe5146b87e850c10b2faa4be869463b`）、原生 192×128 PNG sheet **5,877 bytes**（SHA `6c139a22c105876d26c42af3f4d88c3ed00cf6f8dd9774340abb11d1ad40de8a`）。兩筆測試合計使用 **2 次既有訂閱內 generation**，沒有購買額外 Credits。

## 機器判定
- **A34**：起點對核准 RUN_2 **0 RGBA pixel diff**；尾幀對核准 RUN_3 **10 pixel diff**。5/5 frame 互異，Alpha 僅 0/255；RGB 色數 `[33,39,36,48,34]`，相鄰畫素差 `[279,515,446,509]`。
- **A35**：起點對核准 RUN_3 **0 pixel diff**；尾幀對核准 RUN_2 **18 pixel diff**。5/5 互異；Alpha 僅 0/255，色數 `[34,40,40,42,33]`，相鄰差 `[458,377,368,420]`。
- **雙向八幀跑步候選**：在不修改模型新姿勢的條件下，將每段 5 幀的近似終點以**完全核准 A62 端點**替代，避免模型對端點的 10/18 px 漂移。八張畫格依次為 `APPROVED_RUN2, A34_F1, A34_F2, A34_F3, APPROVED_RUN3, A35_F1, A35_F2, A35_F3`，**兩張 A62 核准端點＋六張獨立 PixelLab AI 生成中間幀**。生成真實 256×128 RGBA Sheet、64×64 8-frame loop GIF (120ms/格)；8/8 RGB frame SHA 各異，含首尾相連的相鄰 pixel diffs `[279,515,446,512,458,377,368,422]`。此證明**真的取得雙向新影格且可組成完整循環**，不表示動作美術已過。
- 生成輸出與運行：原生 sheets 為主。GIF 只作預覽，使用原始 RGBA 直接組排 PNG，沒有 AI 換衣、RBF 關節拉絲、舊 A62 幀假冒全部新生成。未實際進入 RMVX Tankentai 或 Godot battle，因此 **Engine NOT_RUN**。

## 視覺美術 Gate，不能被技術 PASS 蓋過
- **優點**：首尾幾乎鎖定核准關節姿勢，白髮、深綠戰鬥服及整體像素風格較 A32/A33 自由 V3 穩定；中段開始有可辨別的兩側腿交替。
- **缺點**：第二段合併結果 **F6 的大跨步幅度略誇張**，**F7 的手與步伐還有扭曲風險**；中間影格在視線與頭頂髮形尚有幾像素漂移。整段八格尚未達自然順暢、沒有截圖的實機 Tankentai 動作驗收，故 **ART HOLD**、不覆寫核准版本。
- **FS 正式規格三幀動作**：本 8-frame 是新技術/美術驗證資源，不可未經挑格或重訂輸出 semantics 就當成 FS `_1/_2/_3` 正式資源。**後續把成功動作相位映射回 3-frame**，原核准 RUN1/2/3 保留。

## Owner-only Google Drive 實體素材
A34 來源與原始生成：
- [A34 核准三姿勢 7x contact](https://drive.google.com/file/d/1rENpSzkpqolpUOjYdvbB6FAp8eyNwjU2/view)
- [A34 Interpolate 原生五格 Sprite Sheet](https://drive.google.com/file/d/1x0Kcfqnd79wF5GGhkgsnVD9qD6-ahq9Q/view)、[原生 GIF](https://drive.google.com/file/d/1zs_Xjjv9URLkbauE7gmIM2aIy7SvZcnB/view)
- [A34 五幀 7x 預覽](https://drive.google.com/file/d/1qsZCqAcJveRHSfd3bvUb23lljV217uxf/view)、[A34 對 A33 同源逐格](https://drive.google.com/file/d/1We6g8qYDy6CVUJ46Wrt9Em7LS_Ea-63l/view)
- [A34 完整 16 檔 ZIP](https://drive.google.com/file/d/1LUMLCSt9kK4nO9ztkA-goeEbNd_-JE5t/view) **60,285 bytes／SHA256 `5540cfd7032156b7322aef56cd427a0a84e1874db19966ca42c1a01a92affdf4`**。
A35 反向與完整循環：
- [A35 反向原生五格 Sprite Sheet](https://drive.google.com/file/d/1v0hYC2csSlpu_h7UPbyMjdvfkxycKQlb/view)、[原生 GIF](https://drive.google.com/file/d/1vHYNMuSWasZGnawEhTCjLMdufFgmGh51/view)
- [A35 **完整八幀 256×128 透明 PNG**](https://drive.google.com/file/d/1y6SgxUsTdDSgR7-SBaeVU2ZgMWBZCbk8/view)、[8-frame loop GIF 預覽](https://drive.google.com/file/d/1lhnPAjpXrkLX1-frl9v122wGLbRGLIg6/view)、[8-frame 6x 靜態 QA](https://drive.google.com/file/d/1vyNLQA6p9e-I-g36o-Ts35xUt-pBSk1x/view)
- [A35 完整 12 檔 ZIP](https://drive.google.com/file/d/1thdLcIKrhP3mNkXMC8yiF_RChcr0PPqw/view) **39,640 bytes／SHA256 `6f3901415d5d5ee5909054eadbdb9f965717b15dd0e693a529843f952471f910`**。
- 上述兩個 owner-only Drive archives 已從 connector 下載核對與來源一致，ZIP CRC `testzip() = None`（無損壞）。Drive metadata `shared=false`。所有 PixelLab 下載原始 GIF/PNG 已由 `E:\Downloads` **移到 G: restricted owner-only Drive**；Windows TEMP 上傳兩組中間檔 `FS_A34_UPLOAD_*.png`／`FS_A35_UPLOAD_*.png` 均已刪除。

## Failure Log / Next Actions
1. `ART_MOTION_OVERSHOOT_A35_F6`：雙向 Interpolate 終於保住兩端，卻在 F6 新姿勢跨步過大；下一階段優先研究**有局部限制的中間幀修正／選幀**，不再重複改 Prompt 生成整套角色。
2. `ART_ARM_SILHOUETTE_DRIFT_A35_F7`：手臂輪廓有不自然風險；只局部重繪或修正受影響的中間幀，保留兩個核准 keyframe 不動。
3. `FS_3_FRAME_FORMAT_NOT_YET_SEALED`：動畫 8 幀可以預覽，但需另外產生 FS 正式 3-frame `_1/_2/_3` 映射並在真正 RMVX／Godot 戰鬥場景做動作與角度驗收；美術 PASS 之前不可替換封版 A62。
4. `PROVIDER_BIDIRECTIONAL_CONTROL_SUCCESS`：已驗證 **64px approved RUN2/RUN3 → V3 Interpolate first/last frame → genuine RGBA 5frame forward + reverse → composed 8frame full loop** 可以重複運用於 Actor／PMD 的動作量產（受 art gate 管制）。這條工法比 A29 無約束 RBF 或 A33 文字 Prompt 更好。

**Seal：provider PASS / source+cloud integrity PASS / 8 distinct frames PASS / ART HOLD / engine NOT_RUN / main unchanged。**
