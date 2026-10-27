# CURRENT_RESEARCH_HANDOFF | FS Master Split | 2026-10-27
- 實機在隔離 Windows E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027。
- SAM2.1 small 544x416 CPU R0: 3 selected objects, 30770 px mask; master recomposition 0 pixel diff; 1px negative -> 1444 diff；非最終美術。
- Raw mask right tree 誤收灌木；guided negative-point refinement 已做三組候選但仍 ART HOLD。
- OpenCV Telea underpaint 嚴重模糊，近邊緣紋理梯度比0.0948 => GROUND ART FAIL。
- 本輪僅私人來源，Par 未完整切出，未導入 VX，正式主線完全未改。
- 下一步：獨立進行 Ground-hole inpaint A/B/C（PatchMatch/LaMa/AI），針對邊界 1x 視覺 QA；建立真正的 Object semantic gate，而非只看模型 confidence／connected components／0diff。
- 禁止將研究候選覆蓋現有正式 FS 素材/圖層、或與另一對話正在施工的 V6 混用。