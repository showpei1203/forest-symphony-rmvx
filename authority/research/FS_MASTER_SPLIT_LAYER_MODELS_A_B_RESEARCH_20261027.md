# FS Layer Decomposition Research — A/B 模型研究補充｜2026-10-27

## 重大新工具 Qwen-Image-Layered
- https://github.com/QwenLM/Qwen-Image-Layered
- 2025-12 發布，CVPR 2026，Apache-2.0。官方功能就是單張圖→可變數量的RGBA圖層（含遮擋內容生成）。
- 注意：文字 prompt 描述整張畫面，不保證可指定每張圖層恰好等於 Ground、PAR、Light、Shadow。
- 正式示例採CUDA/BF16，原版權重非常大；本機 RX6700XT 12GB 本輪未運行此模型，不能把 Qwen-Image 2.1 的普通 GGUF 當成 Qwen-Image-Layered 量化版。
- 潛在風險：生成式模型可能修改原像素、模糊像素風、地面殘留陰影與物件範圍，最終仍要透過原像素 lock + SAM2 mask + source/semantic QA 重組。
- 若使用線上 Hugging Face demo，請先用不含私有授權資產的合成樣本測試，未經授權不把 FS 私有原圖上傳第三方。

## 其他模型
- SAM3.1 (Meta) 官方 2026-03-27 更新，支援文字/範例檢索分割多物件，官方 CUDA 條件，本輪不取代本機 SAM2.1 CPU；
  https://github.com/facebookresearch/sam3
- LaMa 對大面積遮擋補圖較傳統 CV 更有研究價值，但在像素風圖不一定清晰，需實際對照； https://github.com/advimman/lama
- PatchMatch 允許範例紋理修復，可能保留部分地面顆粒，但也可能形成重複拼貼； https://github.com/vacancy/PyPatchMatch
- PixelART 2026-09 預印本強調更低記憶體/延遲的圖層分解；這輪只確認論文資訊，尚未確認可用模型權重/官方推論程式，勿宣稱可以直接安裝。
  https://arxiv.org/abs/2609.22789

## 計畫 A/B（同一張正式來源，同幾何）
- A: SAM2.1 精確遮罩 + 原像素完整保留 + LaMa/PatchMatch補繪。
- B: Qwen-Image-Layered 指出語義與遮擋下背景候選；SAM2再鎖定原生物件像素，禁止直接用生成式重新繪製過的屋體/PAR覆蓋原圖。
- C: 現有 OpenCV Telea 為失敗基線，Ground 內部梯度比外部 0.0948，嚴重模糊。
- 對比 指標：獨立人工標註Mask IoU、Ground唯一地表所有權、母圖0差異/可見區零變更、可見接縫1x/2x、地面紋理連續度、人眼盲評、角色遮擋/通行原生VX。
- Qwen官方 demo 非私有圖環境可先以自製公開測試圖跑，不得誤用產權未確認素材。

## 研究結論
SAM2 可以 3.4 秒CPU抽出3個初候選與0像素差可逆重組，但補地面是本輪 art 主瓶頸。預計同時保留「原像素幾何鎖」與「生成式語義分層」的優點，避免只相信任何一個模型自我驗收。未跑Qwen/LaMa/PatchMatch，不宣稱其效果已經優於現況。
