# A55｜Failure Log｜2026-11-17

## FL-A55-001｜參考骨架畫出被遮蔽部位
- 外部參考：使用者 2026-11-17 提供 NW 骷髏兵 F5／F6 範例，舊 guide 把本應被盾牌遮住的拳頭仍畫出來。
- A55 修復：每幀 manifest 的 \`fully_occluded\` 部位都要出現在 \`guide_must_exclude\`；除幾何可見性外，guide 自身也有零像素 Gate。
- 實測：合成負例 F5／F6 會被 \`guide_draws_occluded_hand\` 與 \`visible_hand_outside_occluder\` 擋下，正例 PASS。
- 注意：測試用的是合成 64×64 帶遮擋案例，不是修改或重新生成 A53 PixelLab Actor01。

## FL-A55-002｜僅隱藏 Weapon 不代表可清除 Body 內的錯誤手
- A53 Body 是完整 PixelLab 生成的單層圖片。單純 \`WeaponSprite.visible=false\` 不能刪除已被生成在 Body 內、卻露出盾牌外的手。
- A55 修復：前置像素 QA 必須確認 final_hand 在盾牌遮擋外為 0，Body 另維持原始來源；runtime 使用分離的 weapon_tip layer 渲染可見片段。
- **仍未解決**：正式 FS 某個盾牌角色實體的逐幀部位 segmentation、像素級遮擋與美術通過；不可把合成例子當作完成量產。

## FL-A55-003｜4/4 圖像不等於 8 方向量產
- 使用者參考只含一個 NW 方向的 F5／F6，不適用所有角度/所有人物。
- A55 產線要求每一個 action、view、frame 明確聲明遮擋者與可見性，缺值直接 fail closed。

## FL-A55-004｜CI 隱藏 QA 產物的 artifact 預設濾除
- 初版 workflow 把合成預覽放 \`.a55-qa/\`、\`.a55-qa-result.json\`；GitHub upload-artifact v4 預設不包含隱藏檔。
- 已更正為 \`a55-qa-output/\` 與 \`a55-qa-result.json\`，再觸發 CI。
- 不得宣稱未出現在 Actions artifact 清單的預覽圖已交付。需實際確認 artifact 列表與檔案可用。

## FL-A55-005｜Godot headless audio 初始化噪音
- 原生 OpenGL synthetic GPU 測試在 Ubuntu Mesa/llvmpipe 正常 PASS，日志中 ALSA 初始化出現 \`ERR_CANT_OPEN\`，但不是畫面/動畫邏輯失敗。
- Workflow 增加 \`--audio-driver Dummy\` 將音訊環境與 GPU 證據隔離，需下一次成功 CI 核對。

## FL-A55-006｜不要混淆 GPU 環境
- A55 native GPU 使用 GitHub runner 的 Mesa llvmpipe（OpenGL Compatibility），不是使用者 RX 6700 XT 的 Windows 實機，也不是 A53 clean 專案的全套 native test。
- A53 clean 95s timeout（A54 延續議題）尚未被 A55 synthetic QA 證明已修復。
- A55 尚未運行正式 FS ATB／技能／敵方受傷／取消攻擊流程；正式 ART 仍 HOLD。

## 防再發策略
- 保持負例會 FAIL、正例會 PASS 的測試作為 CI 常駐。
- 獨立影像部件遮擋、Godot runtime layering、實際 Godot GPU 和最終人眼 1× 四個 Gate。
- 不再採用「提示詞寫得很明確」作為遮擋過關證明。
- 保留原 A51/R4/A52/A53 私有源圖和 SHA，所有公開 GH 僅存公開安全的測試程式及合成圖。
