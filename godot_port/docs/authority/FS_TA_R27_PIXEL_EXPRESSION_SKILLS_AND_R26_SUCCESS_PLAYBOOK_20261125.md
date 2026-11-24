# FS T-A R27｜像素表情 Skills 吸收及 R26 成功路線交接

2026-11-25｜本輪狀態：**官方與開源 Skills 研究完成、模型設計 Dry-run PASS、沒有美術修改、PixelLab 新收費 0**。未新增 Godot 4.7.2 測試或真正 12-frame sheet。

## 來源、Skills 與適用性評估

| 來源 | 具體吸收 | 不照搬／阻斷 |
|---|---|---|
| [ForestSenYT Concept-to-Pixel Assets](https://github.com/ForestSenYT/concept-to-pixel-assets/blob/main/SKILL.md) / [character pipeline](https://github.com/ForestSenYT/concept-to-pixel-assets/blob/main/references/character-pipeline.md) | 原生 1× 鎖定角色身份、頭部整塊移動、眨眼瞬間切換表情、頭髮只受動作驅動、切換時要回到指定 Idle 姿勢 | 預設 96×160、Unity、8–13 表情包，不適用 A62 64×64 的 3/4 東南戰鬥小臉，不自動安裝此 Skill |
| [willibrandon Pixel Art Animator](https://github.com/willibrandon/pixel-plugin/blob/main/skills/pixel-art-animator/SKILL.md) | Aseprite Linked Cels、防止靜止臉跨幀跳動、分別控制幀時長和 tags | 需要 `mcp__aseprite__...`，我們尚未驗證此 connector 可用；只吸收理念 |
| [ervareza Pixel Art](https://github.com/ervareza/agent-skill-pixel-art/blob/v4.3.0/skills/pixel-art/SKILL.md) / [animation principles](https://github.com/ervareza/agent-skill-pixel-art/blob/v4.3.0/skills/pixel-art/references/animation_principles.md) | 色盤與透明度 QA、姿勢先行、動作弧線、1×輪廓辨識、避免一像素閃爍、導出 GIF/atlas | 通用 palette cap 和 SNES 分類不是 A62 核准色盤，不強制套色或重新繪畫 |
| [Scenario Sprite Animation](https://github.com/scenario-labs/skills/blob/main/skills/scenario-sprite-animation/SKILL.md) | 不把一張多宮格 AI「概念畫」當真正分幀，需檢查每幀角色、原生大小、順序、格線與 GIF | 依賴 Scenario MCP / 另一供應商，不替代已成功 PixelLab 路由 |
| [tachikomared Game Character Sprites](https://github.com/tachikomared/character-animation-creator-skill/blob/main/SKILL.md) | 原生 64px、固定格子、逐向 QA、真實 1× / nearest 4× / GIF、逐格獨立審查 | 含未驗證 imagegen 工具依賴，不能假設已接入 Windows |
| [PixelLab 官方 Skeleton](https://www.pixellab.ai/docs/tools/animate-with-skeleton) + [v2 API](https://api.pixellab.ai/v2/docs) | 先 estimate skeleton，真正模型重新生成每個姿勢；必要時修正 18 landmark；固定頭部有助穩定角色臉部 | 官方 `fixed head` 是編輯器指引，**不可擅自假設 REST v3 接受同名參數** |
| [PixelLab Inpaint](https://www.pixellab.ai/docs/tools/inpaint) / [Edit Animation Pro](https://www.pixellab.ai/docs/tools/edit-animation-pro) | 只局部修臉部／袖口，跨幀調整須身份與透明度 QA | 不是免費；官網編輯器價格與 REST API 價格需各自核實，這次不呼叫 |

沒有直接找到「專門針對 **A62 尺寸的 PixelLab 表情 Skill** 且可在當前工具環境立刻使用」的現成選項。因此創立 FS 專用的 `fs-ta-pixel-expression/SKILL.md`，以**文件 Skill／未驗證自動安裝**方式保存規範，不照抄第三方完整程式。

## R26 真正成功，千萬不能重新來過

- 原始 A62 F00 是核准 64×64 來源 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`，白髮、深綠／炭灰服裝、東南 45°。
- 已驗證的遠端工作路由：**PRIVATE GitHub PC Bridge → Windows self-hosted Runner → 固定允許清單腳本 → PixelLab 官方 REST → owner-private Drive journal/art**。即使 Orca CLI `runtime_unavailable`，也不必重新安裝。Desktop Remote 額度當時 0%，所以沒有使用它。密鑰保留在 Windows 環境，不上傳或輸出。
- [Bridge #133](https://github.com/showpei1203/chatgpt-pc-bridge/issues/133)：來源存在且 SHA 符合、token 存在、balance GET HTTP200；[Bridge #134](https://github.com/showpei1203/chatgpt-pc-bridge/issues/134)：零收費自測過；[Bridge #135](https://github.com/showpei1203/chatgpt-pc-bridge/issues/135)：`estimate-skeleton` 真實 18 關節成功，用量 **0.1 generations**；[Bridge #136](https://github.com/showpei1203/chatgpt-pc-bridge/issues/136)：`animate-with-skeleton-v3` 真生成四張新 A62 姿勢 F03/F05/F07/F09，用量 **3.0 generations**。合計本批 **3.1 generations**，不是美元；**不重送這兩筆 POST**。
- 實際五幀 F00（原圖不變）、F03、F05、F07、F09，RGB/alpha 64×64，五幀 SHA 不同；預覽 1×/4×/GIF 通過技術 QA。供應商 job ID、seed、圖片和 receipt 在 [R26 PRIVATE Drive](https://drive.google.com/drive/folders/10r8kphLlS0ludVAN0uPzMPdVpGd8eRYL)；[真實模型素材 63,216B ZIP](https://drive.google.com/file/d/12RpDnEbKBxv-3c3ULW7b6X6r4D7XAjOt/view)，SHA256 `43e30061006960d5ad4052335ff3eda810eb105117c6dbf20890562780e717ef`。
- [五姿勢美術預覽](https://drive.google.com/file/d/1YLgLubUxuqFE02ZEQ60a6kozJkOaixBN/view)、[實際 320×64 atlas](https://drive.google.com/file/d/16gqSecMji0HIiqffZlsamyCCp9E_WNMu/view)、[GIF](https://drive.google.com/file/d/1_vfLFuPD24_u2-mpnlKZFo0WL6aihkr5/view)、[獨立 A52 劍合成](https://drive.google.com/file/d/1jXbfhbaOxt2Cl9fNiJjyGcI_ZliT3nmq/view)。劍合成不是 Godot 動態測試。
- **藝術狀態仍 HOLD**：F03 手臂過度伸展、F07 命中像空手、F09 劍尖落到腳下，需使用者挑選修正。真正新圖的 Godot 4.7.2 native、正式 FS Battle/ATB/HP 和完整 12 幀都 NOT RUN。前 R19–R25 已遭使用者否決的美術不得復活。
- **防重複扣點是關鍵實務**：先鎖定 job journal 再 POST，錯誤或不明結果永不自動重試付費請求；完成查 job ID 而非再生成；輸出來源 SHA、model、幀 SHA、實際用量和失敗原因，先回讀 PRIVATE Drive 再回報；另寫 T-A CURRENT_HANDOFF 和 Linear SHO-38。

## 頭部／表情正式納入「下一版模型規格」，不改既有 R26 圖

實際讀取 R26 PRIVATE 供應商 job receipt 的 18 個 skeleton joints 和四個 frame：**NOSE、LEFT/RIGHT EYE、LEFT/RIGHT EAR 在 F03/F05/F07/F09 都與原 F00 完全相同**；只改 NECK X（四張各約 -0.88、-0.48、+1.52、+0.8 個源像素）。這表示**生成模型沒有收到特定頭部移動計畫**，而不代表 AI 模型完全沒有改畫臉部像素。

**新 HeadPose 設計（待實際模型驗收）**：保持 18-label 骨架合同、身份及 F00 完全不變。相對現有四姿勢，五官 `NOSE/EYES/EARS` 作剛性群偏移：F03 (-1,+1) 低頭專注，F05 (0,-1) 加速抬視線，F07 (+1,0) 頭跟隨斬擊，F09 (0,+1) 收招放鬆；NECK 只加半幅群位移，其他 12 body joint 原狀。**只是未提交模型的保守 1px 候選**，不是保證能改變頭部透視和表情；正式輸出需 1× owner 審查。

**Expression 語意另存**：`neutral`／`focused`／`effort`／`impact_focus`／`recover_neutral`，不是 PixelLab v3 payload 合法欄位。眉眼嘴僅在必要時由局部 pixel art／Aseprite 或 PixelLab masked inpaint 修，不能在現有 64px 臉畫十種過量微表情。小臉最重要是眼神＋頭部姿勢，分清頭部物理動作和臉像素變化。

**R27 dryrun 已實做**：`ta_r27_head_motion_dryrun.py` 經過 18-joint／SHA／F00／未改非頭部 joints 的防呆負測，並用真正 R26 receipt 驗證四幀 face labels 原本 frozen、提出新偏移而沒有改任何輸入。結果在 `R27_R26_PRIVATE_RECEIPT_HEAD_BASELINE_AUDIT.json`；只能公布**摘要**，不公開 PRIVATE 原始 18-joint keypoints。零 PixelLab POST、零新圖、零成本、零 Godot run。

## 正式下一工序（依使用者 ART Gate）

先讓使用者檢視並確認現有 R26 五姿勢及持劍圖；下次先修 F03/F07/F09 姿勢缺陷時**把 HeadPose 1px 隨動**納入下一輪計畫，避免原角色繼續頭不動。人工滿意後考慮有限的表情修正；每輪都產出 true PNG 1×、4×、Head crop、GIF、來源報告、成本、Handoff。美術還沒過關之前不發付費 12 幀，也不拿工程 PASS 當藝術合格。
