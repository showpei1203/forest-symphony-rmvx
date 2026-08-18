# FS Tree Standard Broadleaf 01 — Asset / Semantic Depth Spec v0.3

- Project: Forest Symphony
- Asset ID: `FS_Tree_Standard_Broadleaf_01`
- Family: `standard_broadleaf`
- Category: `tree`
- Status: `REGENERATION REQUIRED / PIPELINE BENCHMARK`
- Authority date: 2026-08-18
- Related Linear: `SHO-34 | FS Parallax Master Object Benchmark I`

## 1. Purpose

本資產是 Forest Symphony 第一個正式「標準森林闊葉樹」量產原型，同時作為以下流程的基準樣本：

1. Game Asset Forge / PixelLab original Master Object generation
2. Forest Symphony Style DNA visual acceptance
3. Aseprite final cleanup / semantic-mask authoring
4. D1 / D3 / D4 semantic depth planning
5. Python Asset Validator
6. Render Policy
7. FS single-object Compiler Prototype
8. 後續 standard broadleaf variants 的風格與工程基準

本規格遵循 **Master Object First**：完整 Master Object 是唯一美術主體；D1 / D3 / D4 描述物件的世界語意；Ground / Par 則由 Render Policy 派生。

## 2. Current benchmark decision

先前生成的 standard broadleaf 候選樹已由使用者判定 **不通過視覺驗收**。

因此撤回任何 `PROVISIONAL PASS` 解讀。現在必須重新生成新的 Master Object。

失敗的重要教訓：

- 舊 FS 樹圖是用來分析 Forest Symphony 的風格家族與地圖使用方式。
- 不應把單棵舊樹直接當成新樹的形狀答案。
- 若生成 prompt 要求過度貼近 canopy structure / trunk proportion / branch layout，模型會產生近似複製。
- 下一輪生成改採 **Style DNA first / reference images for acceptance** 策略。

## 3. Style Authority

正式 standard broadleaf Style DNA：

`docs/asset_pipeline/FS_STANDARD_BROADLEAF_STYLE_DNA_V1.md`

Game Asset Forge 下一輪正式 Prompt：

`docs/asset_pipeline/GAME_ASSET_FORGE_FS_STANDARD_BROADLEAF_PROMPT_V1.md`

核心生成原則：

> Learn the family DNA. Do not copy the individual.

第一輪 originality benchmark 不應提供單棵 legacy tree sprite 作為主要 image-conditioning reference。

可使用：
- Style DNA 文字
- FS 整體 map screenshot 作低權重世界 / 比例 context
- 從 FS 資產抽出的 palette swatch

Legacy tree sprites 主要用在生成後 acceptance comparison。

## 4. Family Evidence

Family 規則目前根據已上傳並實際檢查的 FS 素材建立，包括：

- `tree variation.png`：standard / production broadleaf 最重要分析來源
- `Trees1.png`：葉叢、樹皮與 legacy broadleaf 語言分析來源
- `Hanzo-VSTrees03.png`：conifer 對照來源，排除其輪廓
- `SCENE21` 與多組 `groundXX / parXX`：實際 map scale、重複配置、Ground/Par 遮擋行為分析

這些來源的任務是幫助建立規則，不是要求生成器重畫其中任一棵樹。

## 5. Master Object Authority

當新的候選通過視覺驗收後，正式美術 Authority 才會成為：

`FS_Tree_Standard_Broadleaf_01_Master.png`

在通過前，任何失敗候選都不得升為 production Master。

D1 / D3 / D4 為工程 semantic masks，不是三份獨立美術資產。

## 6. Semantic Depth Definitions

### D1 — Ground Contact / Placement Semantics

用途：
- 根部 / 接地關係
- anchor
- 未來 collision / passability / placement reasoning

應包含：最低位樹根、接地陰影、貼地草 / 苔蘚 / 低位裝飾。

**D1 不等同 Ground output。**

### D3 — Primary Occluder

用途：定義角色位於樹後方時，主要應顯示於角色前方的實體遮擋區。

應包含：主幹、中下段粗枝、具主要遮擋意義的結構。

### D4 — Canopy / High Foliage

用途：定義高位枝葉與樹冠的遮擋語意。

應包含：大部分樹冠、高位葉叢、外側延伸枝葉。

## 7. Semantic Relationship Rules

1. 禁止以水平高度硬切 D1 / D3 / D4。
2. Depth assignment 以 gameplay / occlusion / placement function 為優先。
3. D3 與 D4 邊界允許不規則輪廓。
4. Semantic masks 不是 Ground / Par 的互斥 destination map。
5. Mask overlap 可存在，Validator 會量測，但 overlap 本身不直接判 FAIL。

## 8. Forest Symphony Render Policy Authority

實際檢查既有 FS `groundXX / parXX` reference 後，確認舊 FS 使用 **Base + Occlusion Overlay** 類型行為。

Profile：

`fs_legacy_parallax_vx`

正式規則：

```text
Ground = full Master Object
Par    = Master Object masked by D3 + D4
```

Ground / Par pixel overlap 是預期結果。

完整定義：

`docs/asset_pipeline/FS_RENDER_POLICY_V0_2.md`

## 9. File Naming

候選通過後使用：

```text
FS_Tree_Standard_Broadleaf_01_Master.png
FS_Tree_Standard_Broadleaf_01_D1.png
FS_Tree_Standard_Broadleaf_01_D3.png
FS_Tree_Standard_Broadleaf_01_D4.png
FS_Tree_Standard_Broadleaf_01.meta.json
```

所有 masks 必須與 Master 完全同尺寸、同 canvas origin。

## 10. Anchor Authority

Anchor：
- X = trunk center
- Y = root bottom contact

Normalized baseline：

```json
{
  "mode": "normalized",
  "x": 0.50,
  "y": 0.95
}
```

## 11. Visual Acceptance Gate — BEFORE mask authoring

新的候選 Master 必須先通過以下視覺檢查，才值得製作 D1 / D3 / D4：

1. 看起來屬於 Forest Symphony 世界。
2. 明確屬於 standard broadleaf，而非 landmark / conifer / fantasy hero tree。
3. 輪廓與任何 legacy source tree 都有實質差異。
4. 樹冠、主幹、枝條、根部不是舊樹的近似重畫。
5. 作為普通森林樹可以重複使用，不會過度搶戲。
6. 能合理衍生至少 2 個不同 sibling variants。
7. 在實際 RMVX map scale 下仍可讀。
8. 結構天然適合後續 D1 / D3 / D4 authoring。

若 Visual Acceptance FAIL：

> 直接重新生成，不進 Mask / Validator / Compiler。

避免對失敗美術投入後段工程成本。

## 12. Engineering Acceptance — AFTER visual pass

視覺通過後才進入：

- D1 / D3 / D4 authoring
- Validator v0.2
- Compiler v0.2
- `fs_legacy_parallax_vx` Ground / Par output
- RMVX runtime visual acceptance

只有全部通過，才可升為正式 production reference。

## 13. Scope Boundary

尚未納入：

- conifer family
- landmark / ancient tree family
- dead tree family
- seasonal variants
- collision authority
- whole-map compiler
- dynamic runtime occlusion

這些功能必須在新的真實 Benchmark 02 通過 visual + runtime acceptance 後再擴張。
