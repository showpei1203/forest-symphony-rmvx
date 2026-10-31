# FS A12｜動畫製作知識與可驗證的像素動作規範（2026-10-31）

**主線仍是：AI 獨立 Master → 角色／怪物自然新動作 → ASF Sprite Sheets → Godot/VX → FS 人眼正式驗收。**
本輪研究與相容性驗證，不宣稱新動畫已達美術標準，不動 K4/N5/R17/Tankentai/LPC/PMD 封版。

## 針對 A11 的真正問題

A10 的全身網格變形可以輸出合法影格，卻無法表達真正的揮劍；A11 T1 雖新增手臂與獨立劍，但手部握持僵硬，腰間原劍仍可見。T2 分離頭角會出現浮離像素，改回完整身體衝撞後，四足缺乏接地步態。
因此先學「動作語法 + 遮擋部件構造 + 像素 QA」，不是再反覆調整原本的整體旋轉參數。

## 已檢索的學習資源與分類

| Resource | Source | Learned action | Scope / caution |
|---|---|---|---|
| Walt Disney Animation official principles | https://www.disneyanimation.com/process/animation/ | timing, anticipation, follow-through, staging, weight | 本質是美術設計與人眼審查；不可由像素數自動給 PASS |
| PixelOver bones & hidden-area backfill | https://docs.pixelover.io/tutorials/bones_animation/ | 拆層、補背景、Joint / Z-order / bone animation、輸出 sprite | **商業軟體非開源**，免費 Demo 可操作但不可輸出；正式版約 US$19.99 |
| Pixelorama (open-source) | https://pixelorama.org/introduction/ | onion skin、時間軸、編輯幀和人工修整 | 使用前要回歸先前六幀 Shader Effects 造成崩潰的已知失敗案例 |
| AI Sprite Animation (MIT) | https://github.com/JatCool/AI-Sprite-Animation | per-pixel part membership, overlapping limbs, source palette, majority-vote 4x compositor, foot grounding, stable pivot, pose constraints, palette and silhouette QA | 現行 Unity 6000.6 側視人形為主；本機 Unity editor 為 6000.0/2022，尚未作完整 Unity 操作 |
| Rigby2D open-source public beta | https://github.com/jaisurya-dev-art/rigby2d | 2D bones + IK + layered PSD + animation graph and MCP + Godot runtime | 功能與工作流待獨立試作；Demo 人物/美術不允許納入商業遊戲 |
| Pixel art school lessons | https://pixelart.school/learn | walk cycle, anticipation, smearing, easing | 教材可用，不能直接複製未授權的範例素材 |
| Cathy Feraday Miller quadrupeds | https://www.gamedeveloper.com/art/animating-four-legged-beasts | stance/contact/flight, paw order, weight shift | T2 專門先做好四腳接觸圖 |
| Free four-beat footfall lesson | https://playermotion.games/lessons/ztgc-09-creature-animation/01-study-four-legged-locomotion | 4-beat walk footfall chart | 參考原理而非盲套四足物種 |
| Aseprite export docs | https://www.aseprite.org/docs/sprite-sheet/ | frame tags & export, alpha and exact grid | ASF 已實測，屬後段格式，不是自然動作的來源 |
| Godot native Animation | https://docs.godotengine.org/zh-tw/4.x/tutorials/2d/2d_sprite_animation.html | AnimatedSprite2D/AnimationPlayer，1× 播放 | 引擎像素還原0誤差≠動作美術達標 |

## 真正要吸收的 8 項規則

1. **Key pose first**: 先設四個語意狀態（預備、主動作、接觸/力量最大、收勢），不要先從每格移動幾像素開始。
2. **Part maps required**: T1 分出遠手臂／身體／近手臂上臂前臂／手掌／武器；T2 分出遠前後腳、軀幹、近前後腳、頭／樹角。單圖遮擋區需補繪。
3. **Weapon child of hand**: 先算肩→肘→腕 IK，再鎖武器握柄在手掌；刀刃弧線由手部動作決定，而非劍獨立繞身體中心旋轉。
4. **Scabbard state**: 拔刀前佩劍／拔刀後手持：兩者不可同時顯示為兩把獨立劍；持劍時腰間只留空鞘。
5. **Grounding**: 走路的支撐腳與地面不滑動，奔跑與跳躍才有明確離地幀；角色通用 root/pivot 固定。
6. **Quadruped contact chart**: 四隻腳有相位順序、身體壓低與推地再離地；苔角獸的角和臉需維持形狀與連通。
7. **Pixel pipeline**: 透明二值Alpha、nearest/原palette、4× 合成後 majority vote 降採樣、避免抗鋸齒產生新色；浮離像素和重疊破洞列為嚴格FAIL。
8. **Separate gates**: 技術Gate以哈希/對位/來源/引擎確認；G7藝術 Gate 必須在1×及3×實際連播檢視，不得以RGBA差異大當成自然動作。

## 具體關鍵姿勢模板（候選，不是已生成完成的 FS 美術）

T1 8-frame quick sword slash:
0 原站姿（劍入鞘）→1 身體後沉蓄勢→2 手握劍拔出（入鞘視覺移除）→3 肩肘腕協調加速、劍尖切線→4 打擊接觸與清楚大輪廓→5 極短 hit-stop→6 殘餘動作（披風延遲）→7 回收／持劍待機。
每格可配置不同 ticks；接觸時拉出清楚的攻擊方向，不能只轉動武器圖層。

T2 8-frame charge:
0 站姿四足着地→1 前身下沉與後腳蓄力→2 後腳推離→3 前腳抬起、頭角前伸→4 衝撞接觸，身體動量最大→5 前腳回地→6 體態回正→7 回起點。需逐格標記至少一隻支撐腳及受力方向。直立「整隻怪獸左右旋轉」不得當作步態 PASS。

## 我們實際做了哪些測試？

- 透過授權 Windows 的隔離資料夾，git clone JatCool AI Sprite Animation，固定 SHA `174fc878a8387de1419a6876af1c7dffe79df366`。只讀取/研究原始碼，不改遊戲封版。
- 官方測試原本的 `UnityEngine.CoreModule` 路徑指向 Unity 6000.6.0f1；本機有 6000.0.41f1。只在 A12 隔離複本的 .csproj 改寫參考後 .NET build 成功（0 錯誤／1 未使用局部函式警告）。**不是正式 Unity 6000.6 相容 PASS**。
- 用 A10 的 T1 Master 64×80 建立自有 .raw；上游附的 `player_front_48.raw` 前8 bytes卻給0×0，不能直接作原始測資。原始 upstream 測試碼也有固定輸出路徑；於隔離clone修正了輸出位置並複製 fixtures 後才跑完整測試。
- 最終本地上游測試共 **159 PASS、14 FAIL、exit code 14**。失敗包括 idle arm/body mapping、idle sway、jump/crouch/sit cut and feet、floating components/temporal seam。它們是原包測試條件在我們非側視 A10 Master上的測試，**不是 FS 動畫 G7 PASS，也不能宣稱上游軟體存在14個通用bug**。
- 自製 `analyze_a10_a11_motion.py` 對 A10、A11原始T1/T2 attack_00..07 做 bbox、Alpha、位移、重複幀、像素變化與裁邊檢查。T1 A10→A11平均相對首格變動1082.75→1561.0；最大alpha中心位移3.271→6.05px；T2同指標1277.875→1547.875，2.601→9.373px。全部0畫布邊界接觸。**變動越大並不等於自然度越高。** 缺手/腳mask不能假裝自動驗證握劍/四腳着地，這幾項維持 HUMAN/PART-LABEL PENDING。

## 建議後續 A13 Gate

1. 先製作一份 T1/T2 人工標註 Joint+PartMap：腕／肘／肩與四足骨點、遠近Z、原身體遮擋補色。另保存這份可重用的 JSON 模板。
2. 從 T1 先做四個有清楚意義的 keyframes：預備、拔劍、擊中、收勢，設合理 timing；如果手腕與刀柄無法鎖定，停止、不再靠轉劍補救。
3. 對 T2 先做四足接地表，生成 contact/pass/off-ground 的可解釋姿勢，不要直接畫8張飄動。
4. 用 ASF --strict + Godot GPU + G7 1×/3×視覺審核；後段VX / Tankentai在美術過關後才接。
5. 如需研究 Unity/ML或Rigby2D，先在隔離環境確認版本、來源、授權和輸出；任何第三方重型模型/驅動變更另立Gate，不逕行安裝。

**CURRENT A12: research/doc + code-level and numeric regression DONE; new G7-approved frames NOT PRODUCED, genuine I2V NOT RUN.**
