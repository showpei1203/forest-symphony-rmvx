# Forest Symphony｜ASF × Pixel Snapper｜真實 A57 R2 人物試作結果

日期：2026-11-20
獨立研究分支：`research/fs-asf-pixelsnapper-20261119`
結果：**ASF procedural idle TECH PASS / ART HOLD；Pixel Snapper 1× FS 人物處理 FAIL；Godot native NOT RUN。**

## 實際試作（不是規劃）
- 雲端 GitHub Actions `44585579340` 初次 ASF master 讀出 6.9px 小於最低 8px，拒絕；不算 PASS。
- 修正僅供上游 demo 的 2× 最近鄰預處理後，GitHub Actions `44586087452` 和 `44586957202` 均跑完實際工具。上游範例輸出 ASF 34×57 / 48色，ASF breath 2 frames；Pixel Snapper 對 34×57 再處理成 24×39 / 45色（尺寸不保留）。
- 使用者**私人 Drive 的 A57 R2 身體圖**實際取出：`actor01_a53_body_12frames.png`，256×192 / 12×64×64，35色，SHA256 `af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44`，與原 A57 交接記載完全一致。**Body-only，不生成裝備**。
- 在隔離工作環境執行實際 ASF `pixel_motion.py breath` 於原 64×64 F0，得到 **2×25×37**、620ms/520ms loop；第一幀置回原畫座標 x=20,y=14 時，對來源 64×64 像素差異 **0**。第二幀同座標相對原 F0 有 **327 像素**變化。此為純程式呼吸幀而非 AI image-to-video 動畫，也尚無人工 ART PASS。
- 在相同私人來源的 **12 張 64×64** 動作影格上，實際執行 Sprite Fusion Pixel Snapper Rust CLI v1.0.0，參數 `35 --pixel-size 1`。**12/12** 輸出不同於 64×64，寬 **53–57**，高 **50–52**；各幀輸出尺寸不完全相同，色數 **23–28**。所有輸出本身 alpha 0/255，但 FS Animation Atlas 幀註冊合約 **FAIL**。
- 狀態嚴守：可執行工具 PASS 不等於原生 Godot 或美術 PASS。本輪**沒有**任何 GitHub 主分支改動、沒有把私人 PNG 推上公開 GitHub、沒有寫入使用者 PC。

## 版本及交付
- ASF commit `25203d03900b46b444bdd72a75768c33d1895ad6`
- Snapper commit `02f9315d73d3219274d17767b36d9a231a6b1f4b`
- CI：[run 44586957202](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44586957202)。
- **PRIVATE evidence**：完整 ZIP、原 12 幀／Snapper 12 輸出、ASF 2 幀 animation.json／PNG、真實對照 PNG、Waiting vs ASF GIF、QA JSON／Failure Log／Handoff 已保存於**原 A57 私人 Drive 工作區**，上傳後按尺寸及父資料夾回讀。外部此公共文字不包含付費素材。
- Cloud artifact workflow 保留 30 日；Drive 私有 ZIP 為持久權威。

## 結論（Fail-closed）
1. 不把 Pixel Snapper 放在現有 FS 1× / 64×64 動畫完成品後端；它將已合格尺寸改成不一致的輸出。未來只在上游 AI fake-pixel 大圖上做候選 A/B，且先鎖固定 canvas, palette, anchor。
2. ASF 有固定同源主角的程序式 idle 能力，第一幀零差，是值得保留的技術；但 327px 變化的下一幀應和既有 A57 Waiting 原生 1× 美術比較，現階段 ART HOLD。
3. ASF 真正量產 AI 動畫需 image-to-video 供應路徑、45° 運動、Body-only 且與 FS 外掛武器手部 anchor 整合。本輪 **AI video 未執行**；正式原生 Godot 4.7.2 未跑，不等於新增 16 套動作。下一輪優先對 A57 尚缺的 Damage、Dodging、Victory 真正生成並完整測試，而非反覆優化合格 F0。
