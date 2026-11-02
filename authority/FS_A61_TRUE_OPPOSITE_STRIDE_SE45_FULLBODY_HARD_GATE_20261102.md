# FS A61 | 修正左右腳前後深度的45度全身跑步實測 (2026-11-02)

## 已確認錯誤的根因
A57來源動作的PixelLab 18點自動估計是估算結果，不是人工校正的動作權威。原始估算F1/F2未建立相反腳領先，A60也延續此錯。A60 48px腳踝座標：
- F1角色LEFT LEG Y35.8；RIGHT LEG Y40.7，右腳領先。
- F2角色LEFT LEG Y37.7；RIGHT LEG Y40.7，右腳仍領先。
把上半身像素差異當成完整跑步成功是錯的，A60正式改判左右步態語意FAIL。

## A61實際修正
保留A60角色F0 48×48來源外觀；重新指定三幀整套18關節：頭、肩、肘、腕、髖、膝、靴。角色自身左腳對應此45度東南畫面的右側，不可把螢幕左當角色左。
- F0 左腳減右腳的畫面Y差 -0.94px
- F1 左腳領先 +5.66px
- F2 右腳領先 -6.34px
- 角色左步右臂前擺；角色右步左臂前擺。髖膝腳對應連結，頭肩軀幹節奏連動。
- 先在生成前通過強制骨架門檻；一次送出PixelLab /animate-with-skeleton-v3 三幀，生成真實48x48 PNG 以及144x48 Spritesheet。
- 真實PixelLab背景工作ID及扣點鎖保存在A61_ONE_PAID_SUBMISSION_LOCK.json，初始1669.1，完成1667.1，使用2.0額度。
- 真實結果A61 F1畫面右腳前伸，F2畫面左腳前伸，修正了A60同一側領先的問題。
- 全部三幀無四周裁切。F0-F1可見差異：頭264像素，肩臂277，腰胸196，腿124。差異表示動態，不等於自然。
- 仍未通過正式美術驗收：新步幅比原版大，膝與腳踝自然度、原版45度方向及比例須由使用者看GIF判斷。

## 永久Fail-closed門檻
FS_SE45_RUN_HARD_GATE_BEFORE_PIXELLAB.py 在付費生成前嚴格檢查角色自身左右腳身分，左腳是否維持畫面右側，F1/F2足部前後深度差是否正負反轉至少2.5px，同側膝靴是否連貫，右臂/左臂是否反向擺動，頭肩髖是否確實動，是否可能裁切。任一不符就不得花PixelLab額度。
已回歸：A57原自動骨架 FAIL、A60舊骨架 FAIL、A61修正骨架 PASS。

## 肉眼驗收用檔
- A61_TRUE_OPPOSITE_STRIDE_8X.gif 新版完整循環F0-F1-F0-F2
- A61_A60_VS_A61_ANIMATED_SIDE_BY_SIDE.gif 左右並排同步A60和A61
- A61_ORIGINAL_A60_A61_12FRAME_QA.png 原版、舊版、新版每格對照
- A61_PREPAY_TRUE_OPPOSITE_STRIDE_18JOINTS.png 正確腳踝身分骨架
- A61_PREPAID_OPPOSITE_STRIDE_SPEC.json 三幀完整18關節來源
- A61_PREPAID_REGRESSION_GATES.json 防止再犯
- A61_PROVIDER_RAW_F0/F1/F2.png 真實模型圖，未作手工動畫修改
- 全部程式、QA、版本Handoff和SHA256。

## 接續策略
保留F1/F2前後深度差符號相反，若人眼覺得跨步過大，再改為±3至4px，適度減少膝、手臂和頭的動作幅度。禁止再次退回雙幀同一腳領先。仍只用GIF驗收，暫停VX實機。
結論：A61 prepaid semantic Gate PASS，模型格式 PASS，左右腳視覺改善，正式美術審核 PENDING。