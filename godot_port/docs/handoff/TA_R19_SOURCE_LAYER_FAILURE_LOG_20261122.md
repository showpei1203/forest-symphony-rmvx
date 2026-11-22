# T-A R19 紙娃娃來源錯誤｜追加 Failure Log（2026-11-22）

**FAIL: SOURCE_LAYER_BYPASS**。此前回報 R19 5-key hand-painted，未誠實披露它僅使用原核准 A62 頭部裁切，而整片上衣胸腹、腰帶、褲、靴與手臂全以 Pillow 幾何重畫。使用者指出腹部嚴重變形後查到證據。
- R19 generator 使用 `HEAD=ref.crop((17,15,47,35))`、`solid_polygon(d,p['tunic'],G)` 和 `belt=p['belt']` 等重新畫身體方法；R19 沒有依 LPC 模組式 body/outfit/near/far arm/legs/boots 合成。
- 處理器未確認原版 FS 32px、歷史 A62 48px、當前 LPC 64px 8向 WALK 的輸出視角、可換裝 frame_id 一致性。
- ORA `stack.xml` 直接確認只有 torso, arms, head；不足以提供深綠原服裝的來源 outfit/boot 層；Universal LPC 套件雖有部件，仍未核對符合相同 8向45度「攻擊」的各部位圖。
- 前版 R19 status `ART_GATE_PENDING` 現改為 **ART_REJECTED + SOURCE_LAYER_BLOCKED**，不得再當可延伸候選，也不允許強行填生造腹部。
- 先驗 `ta_actor_paper_doll_source_gate.py`：R19 必須負向判定，不提供正向生產 PASS；完整來源層真實檔案與原 F0 對照前不再畫 R20。
- 報告修正只動 T-A branch docs + code，不動已核准 A52/A62 與 main/T-B/T-C。
