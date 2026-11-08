# A14｜Actor01 F0 → 姿勢條件化生成輸入包｜真實執行與失敗驗收
日期：2026-11-08。**RESULT: INPUT CONTRACT PASS; NEW ANIMATION ART FAIL/NOT_CREATED; NATIVE NOT_RUN。**

## 依據與方法決策
依 FS 唯一現行 [ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) 的 S-A「高品質單張 F0 → 動作」。A13 證明自行對原圖腿部貼色塊雖能左右腳交替，無法保留足部、關節、披風完整風格，ART FAIL，已明確停止 V4/V5 程式拼貼；本次不重演。

PixelLab 官方：其 v2 API 的 `animate-with-skeleton-v3` 是以**一張來源人物圖＋每一幀骨架重繪 3–15 幀**，不同於既有 `animate-with-text-v3`（4–16 偶數張）或舊 `animate-with-skeleton` 三幀模式。來源：
- https://api.pixellab.ai/v2/docs
- https://www.pixellab.ai/docs/tools/animate-with-skeleton
- https://www.pixellab.ai/pixellab-api

官方舊介面常用 16／32／64／128／256 方形畫布，而 FS A62 F0 是 **48×48**；本輪採「無損 padded 64×64、中央偏移 (8,8)、生成後檢查並 crop 回 48×48」作**待實際供應商測試的轉換假設**。不能把「PixelLab 可以接受 64px」直接解讀成「本角色裁回 48px 必成功」。

## A14 真正已完成可用的控制輸入
- 原版核准白髮 Actor01 F0 48×48 RGBA，SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，F0 位元絕不修改。
- A13 內核對過的先前 A62 Run 144×48 三姿勢參考，第一格與 F0 逐像素相同。
- RUN：三個不同 18-joint 人體骨架姿勢，中立接觸、左腳前、右腳前，透明 PNG、F0 半透明比對、192×64 contact 和 64px 正規化座標。預期 FS 播放 `0,1,0,2`。
- WAITING：三個不同細微呼吸姿勢，與 F0 構圖一致，不採整列平移。三組骨架透明 PNG、F0 比對與正規化座標。預期播放 `0,1,2,1`。
- 公開 Python `a14_f0_pose_provider_gate.py`：F0 SHA、防誤身分、48→64 無損置中、座標正規化、生成 PNG 檢查、原版 F0 保留、3 幀不可重複、Alpha 錯誤拒絕。相對應 `test_a14_f0_pose_provider_gate.py` 六項負向／正向合成測試。
- 私人 ZIP 附完整可重建腳本 `build_a14.py`、`validate_and_export.py`、四項實料本地單元測試、A14 同角色控制姿勢 JSON、所有輸入 PNG、HA256 Manifest 與 Handoff。
- 私有封包名稱 `FS_A14_POSE_CONDITIONED_PIXEL_LAB_READY_INPUTS_20261108.zip`，**47,164 bytes、26 檔、CRC PASS、SHA256 `20f37ba85922d7c679a318d8fc210c67a46bd7a3ebfd552d077ea7d98990d8b0`**。已寫入 owner-only 限制的 Drive，size/readback 權限 owner-only。公開 GitHub 不張貼私人 ZIP 下載 id 或原圖。
- 私人真實驗證 `python -m unittest -v test_a14` ：4/4 PASS，包括 A62 原三影格能正常格式匯出，錯誤資訊圖/重複幀都能拒絕，中央 48px 回裁與 F0 逐像素相同。

## 重要反例：三次生圖全部 FAIL
實際對內建 ImageGen 發出的三次生成結果，都變成無關的彩色「A14 生產流程資訊圖」，人物甚至被錯誤替換成棕髮精靈少女，既不是使用者認可的白髮 Actor01、也不是透明三張 48×48 動作幀。
**三次全部 REJECTED_WRONG_IDENTITY_AND_WRONG_OUTPUT_MEDIUM**。從未將宣傳圖裁成 Sprite，也沒有寫入 FS 角色圖集。這不是 PixelLab 骨架 v3 的品質測試，更不可以歸咎 PixelLab；它只反映本次 ImageGen 無法可靠接受這組角色動畫任務。

## 工程 Gate 狀態
| Gate | 結果 |
|---|---|
| 原版 F0 SHA／64px padding 回裁 | PASS |
| 兩種動作各三組 18-joint 姿勢 | STATIC_INPUT_PASS（需 PixelLab 實際 schema/姿勢校準） |
| 生成器是否輸出白髮 Actor01 真正影格 | **FAIL：目前沒有新可用幀** |
| 自然跑步／Waiting／披風連貫性 | NOT_TESTED_WITH_VALID_OUTPUT |
| PixelLab API 呼叫、費用 | 0／未連線 |
| FS SBS 48x48／真正 Game.exe | NOT_RUN |
| 使用者美術、Formal Seal | NO |

## 下一個實際生產動作（非無限寫文件）
1. 在具 PixelLab 授權與核准扣額上限的工作環境，先使用 **64px padded approved F0**。若 v3 raw Skeleton schema 接受 18-joint 座標，校準第一幀與白髮原圖，再只生成 RUN 一次 3 幀。不得從用戶私人背景猜 API token，亦不得繞過額度授權。
2. 取回真正新三幀 PNG，執行私有 `validate_and_export.py`：格式/身份/Alpha/骨架與原生裁切；藝術 1x 接受後才試 WAITING 和第二位角色。
3. 不再生成海報、不再新造別的棕髮 elf 來說「保真通過」；沒有合格新影格之前，量產仍 HOLD。
