# Forest Symphony｜T-C D22 ART-FIRST｜FS_04_MAZE 新獨立完整 PAR 原生美術候選｜2026-11-25

**D22 新增真素材；原生 Godot 4.7.2 1× PASS；Human ART HOLD；12/12 中正式 0/12。** 最新 user 指令「回到完整 Ground＋PAR 美術」優先於舊 D21 下一輪碰撞／遮擋規劃，沒有繼續延伸物理系統。

## 真實雲端產物與 source-of-truth
- [D22 **17 檔完整私人 ZIP**：原始獨立透明來源、未改 Ground、完整 PAR 1×、原生 Godot 截圖、四版本 A/B、QA JSON、生成來源鎖、冷重建程式、Failure Log](https://drive.google.com/file/d/1LJtjHRHl5f8F5FtGBK5uep_f6f243mGQ/view)。**13,986,396 bytes，ZIP CRC PASS；SHA `812d2045044dfe830ee191cf21bfd8d25aa28b9fa4d3de9fec21eb1c78294558`**。
- [真正新獨立、無 Ground 的作者 PAR 原始 `1473×1068 RGBA`](https://drive.google.com/file/d/1ubIk8bkztE9Bq61HmFt7p5lhtwRZ3mvp/view)，SHA `7ab52f35107f468439436ff23e43ae879df6a90d9d55039e0fb761273fe32828`。來源 `alpha=0` **1,166,479**，具完整獨立物件而非混合 Ground+物件 Master；生成器沒有直接輸出 1280×928。
- [D22-B 新完整非地表 `1280×928 RGBA PAR`](https://drive.google.com/file/d/1cFR_YREdTCd82uNWyI3RxYbfIoo8FRha/view)：SHA `a7cf732989afe88be6860a2cc1d27092ee9c2e94e696f315aa5bc4ce62033b95`；`alpha=0` **847,920**。
- [實際 Ground+PAR 靜態整圖](https://drive.google.com/file/d/1tvAlc_GCm8zUYPTYKtLRVZzMObgwSDOg/view)，SHA `54acc8aa0ce8197ea8a7e1e68d9fc1b9ea4f4c157fb4736a574c8d4fa780be80`。
- [**D22-B 真 Godot 4.7.2 1× 原生圖片**](https://drive.google.com/file/d/1R7KnV8-1cgChPaOMnFoblvU97j6X3v8X/view)，SHA `add99e8071f50e002b8c5696deb68a0a6a06a7a0a94d67c67610c36fbb13e105`。
- [真原生 D18／D22 整張對照](https://drive.google.com/file/d/1nIMAztQ5SEJ4g1upb6vVTsQkT3F470w4/view)；[精確來源＋合成＋Godot QA JSON](https://drive.google.com/file/d/1Xla2K_Ty5Te-fKuR7r92OTit79nl5LHD/view)；[原圖／新 PAR 私人重建程式](https://drive.google.com/file/d/1yXnn-bUVJz2yw42ASuzdwbTVbpfbrObC/view)。所有私人影像不得放入公開 GitHub。

## 真正 native／完整證據與美術判定
來源固定 Ground SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，全程未更動 D17 Ground。以先前隔離驗證之**官方 Godot 4.7.2 stable**（官方 Linux binary SHA `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e`）讀入真私人 D22 來源，兩張 Sprite2D 世界 (0,0)、NEAREST、1280×928 framebuffer，雙 SHA/Alpha PASS。與 PIL 真 Ground+PAR 合成相較，**7,862 個 RGB 像素不同，最大單通道誤差 1/255**，不應視為整張對位失敗；有原生 log、QA JSON 和確切 PNG。

**10 組完整非地表連通群**，不切屋舍/橋梁 polygon、不對來源縮放，照 D17 地形版圖配置鍛造廠、礦石吊車、右側鐵橋、南方工坊、岩柱、燈與旗。由於輸出源為 1473×1068，使用 1× 完整連通物件群重排到 1280×928，必須誠實標為 **source re-layout，不是生成器原生同畫布一次成功**。A 版重疊 2,713px，B 版 617px，**故選 B**；D18 868px。四周 5px 高不透明貼邊為 0（D18 上輪最外 4px 共250）；中央路徑留白更多。

Matte correction 不是原作者原 Alpha：Source Alpha<=8 清0，>=240 變255，特殊亮紅色外緣污染刪去 **556px**，保留來源 PNG；不能聲稱所有源 pixel 100% unchanged。D22 主要10群 Alpha>64 source 計數約332,094，不表示全部 Alpha>8 雜訊都保留。

**美術尚未通過：**仍須 1× 真視覺審核房舍/吊車尺寸、橋頭真接地、色彩微細紅邊、岩壁語意、與既有 A35/A36 pixel style 及遊戲可辨認道路。沒有經使用者明確美術核准，不調正式12圖 ART 封版。下一個完整施工不是角色碰撞或累積更多工具，而是**對整張 D22 1× 藝術品質判斷，若需要就重新作者化同世界的完整 PAR**（不是反覆移動旗幟）。全圖 Ground 依新問題才考慮換，須先新 Blueprint 並 preserve 原件。

---

# Forest Symphony | T-C D22 ART-FIRST | CompletePAR new authoring and native 1x
Date: 2026-11-25 Asia/Taipei; Workline: T-C; official formal ART PASS = **0/12 HOLD**.

## Scope and authority
Re-read 2026-11-25 ART-FIRST reset, current T-C handoff and Drive Ground-first SOP. This round **changes no Ground, no ACTOR01, no collision, no gameplay, no Windows E:**. Objective: author a less cluttered independent all-non-ground PAR for FS_04_MAZE and judge its compositional merits against D18, not restart D21 bridge physics.

## Actual source and improved whole-scene composition
- Previous Ground `D17 RGB 1280x928` stays frozen, SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`.
- A **new independently generated non-ground-only RGBA source** was created; no source Ground, lava bed or terrain was composited into the PAR input. Original source **1473x1068**, NOT direct native 1280x928; SHA `7ab52f35107f468439436ff23e43ae879df6a90d9d55039e0fb761273fe32828`. Alpha 0 exists: 1,166,479 pixels. Do not pretend generated output was native.
- Whole alpha-island identity segmentation over source Alpha>64 yields ten significant standalone item groups, including 2 forge buildings, complete bridge, crane with ore station, lamps and flags and two basalt pillar clusters. Each is kept in a rectangular 1x bounding crop (no polygon object truncation); groups rearranged to match Ground's top-left forge plateau, northern crane platform, right-hand lava crossing, open center lane and southern workshop.
- Tested 2 layout macros (A/B), each with raw vs opt-in matte edge correction (4 genuine full-scene previews). Reject Layout A because source-alpha item overlaps = 2713; Layout B = **617**. Previous D18 item overlap **868**, so B reduces overlap without the D19 tradeoff.
- Optional MATTE visually removes color-contaminated neon-red pixels **only on the detected outer island edge**: 556 pixels, and thresholds low alpha <=8 to 0 and >=240 to 255. This is explicitly corrected output, **not identical original source**; original RGBA source preserved. No object polygon trim. Rejected original alpha-noise and model-edge glow remain quantifiable QA issues.
- D22-B full **1280×928** PAR includes true Alpha=0 847,920 pixels and all 10 selected main object groups. All major groups fit within canvas; high opacity in outer 5px=0. Combined Ground+PAR exhibits a less congested central space.

## Real 4.7.2 private native evidence
Official Linux Godot binary from prior verified D20 artifact, SHA `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e`; script operates on these actual private PNGs in isolated runtime. 1280x928 Nearest-neighbor separate Sprite2Ds same (0,0) world origin. Source double SHA lock, valid PAR alpha: **PASS**. Native vs PIL image: 7862 RGB pixels differ, channel difference maximum 1/255; no evidence of layer shift. **This is image renderer only**, not a game map, ACTOR01, physics, save/load, or user art acceptance.

## Human ART HOLD and known blockers
- Positive: clearer center path, far fewer crowding/overlaps, bridge visually positioned across right lava, main structures more coherent, no cut buildings or source group scaling.
- Blocker 1: generated asset source is 1473x1068, then re-layout 1x; not one-step native 1280x928 independently composed world coordinates. The authoring world needs stronger generated exact-output geometry.
- Blocker 2: AI plate original exhibited red/magenta edge glow and alpha noise. Corrected 556 neon pixels only on perimeter; must inspect lantern and plume edges at true 1x.
- Blocker 3: visual judgement still required on true bridge bank contact, raised lava cliff semantics, natural paths, forge building scale, color/style compared to A35/A36 original established benchmark. A clean render does not prove 32px authored game-art style or human ART success.
- Ground has artist-drawn raised cliff-face relief; whether cliff walls are considered Ground terrain or all-non-ground raised rocks needs source-rule interpretation. Do not silently re-slice.
- Formal ART remains **0/12**, native renderer PASS, in-game full scene NOT_RUN. Gameplay/collision work stays outside T-C per latest user priority.

## Next complete art unit
Show D18 vs D22-B native 1x to owner for visual ART review. If globally insufficient, **regenerate complete PAR with exact native world layout and smaller forge/bridge footprints** rather than repairing individual lamps and rails. If art approved, only then use this locked style/blueprint to author full paired same-biome village Ground→CompletePAR. A/B is QA only, never an official art asset. All new private PNGs/QA ZIP in owner-only Drive; script and handoff metadata in isolated T-C GitHub branch and current handoff, no binary art in public GitHub.
