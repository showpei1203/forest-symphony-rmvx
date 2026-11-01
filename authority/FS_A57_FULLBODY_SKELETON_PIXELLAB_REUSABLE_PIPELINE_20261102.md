# FS A57 全身骨架 × PixelLab 批次生成規格（2026-11-02）

## 結論
不要再用「角色圖片 + run」一句話讓模型猜動作。正式流程是：
**目標角色參考圖 + FS 原版對應動作三張圖 + 全身18關節三幀數據 + 統一角色外觀Prompt + 該動作Prompt**。
每種動作分別生成3張圖，按指定順序組GIF供肉眼驗收；換角色可以重用原版動作骨架。

## 來源與實作成果
- 原版來源：Forest Symphony $actor01_1、_2、_3、_4，96×128，三欄四列，每格32×32。
- 15種非空動作×3張=45張來源姿勢PNG。第11種 Nothing 不生成。
- **實際使用 PixelLab /estimate-skeleton 共45次**，每張圖估算18個關節，計45組/810個關節點。原版每一幀和骨架都已保存，15份逐格放大疊圖可直接比對。
- 估計骨架消耗約4.5生成額度單位（開始1679.6，結束1675.1），未生成新動作。這45組來源骨架以後可重複使用，不必每個新角色重估原版。
- 16份完整英文 Prompt、16份精簡版（最長1781字元）、15份三姿勢骨架JSON、18關節＋5個衍生參考節點、離線套用腳本及批次準備腳本。
- 已通過離線自我套用測試，產生A08三幀骨架，不需再次消耗生成額度。

## 真正可送PixelLab的18個關節
NOSE、LEFT EYE、RIGHT EYE、LEFT EAR、RIGHT EAR、NECK、
LEFT SHOULDER、RIGHT SHOULDER、LEFT ELBOW、RIGHT ELBOW、LEFT ARM、RIGHT ARM、
LEFT HIP、RIGHT HIP、LEFT KNEE、RIGHT KNEE、LEFT LEG、RIGHT LEG。

涵蓋頭臉朝向、肩線、手臂擺動、骨盆重心、膝腳深度，**不准再鎖死整個上半身**。官方命名中的 ARM 為手/腕末端錨點，LEG 為腳/腳踝末端錨點。胸腔與脊椎主要由NECK、左右SHOULDER和左右HIP形成連桿；另外附帶HEAD_CENTER、CHEST_CENTER、SPINE_CENTER、PELVIS_CENTER、HAIR_ANCHOR五個**公式推算的虛擬點**。它們是內部動作描述，不是PixelLab API支援的另外五個骨架點。衣襬、披風、頭髮須靠prompt、原始圖對照及局部inpainting處理。

## 16動作表
|編號|動作|原版來源|儲存幀的原圖順序|GIF實際播放|類型|
|---|---|---|---|---|---|
|01|Walking Down|_4 row0|col1,col0,col2|0→1→0→2|LOOP|
|02|Walking Left|_4 row1|col1,col0,col2|0→1→0→2|LOOP|
|03|Walking Right|_4 row2|col1,col0,col2|0→1→0→2|LOOP|
|04|Walking Up|_4 row3|col1,col0,col2|0→1→0→2|LOOP|
|05|Waiting|_1 row0|col0,col1,col2|0→1→2→1|LOOP|
|06|Damage|_1 row1|col0,col1,col2|0→1→2、最後停頓|ONCE|
|07|Critical Damaged|_1 row2|col0,col1,col2|0→1→2→1|LOOP|
|08|Moving to Close Attack|_1 row3|**col1,col0,col2**|**0→1→0→2**|LOOP|
|09|Victory Pose|_2 row0|col0,col1,col2|0→1→2、最後停頓|ONCE|
|10|Dodging|_2 row1|col0,col1,col2|0→1→2、最後停頓|ONCE|
|11|Nothing|空白|none|none|EMPTY|
|12|Death|_2 row3|三幀可見姿勢相同|屍體持續靜止|HOLD|
|13|Front Jump / Close Attack|_3 row0|col0,col1,col2|0→1→2、最後停頓|ONCE|
|14|Ranged Attack I|_3 row1|col0,col1,col2|0→1→2、最後停頓|ONCE|
|15|Close / Ranged Attack|_3 row2|col0,col1,col2|0→1→2、最後停頓|ONCE|
|16|Magi Skill Use|_3 row3|col0,col1,col2|0→1→2→1|LOOP|

完整每一動作的頭、臉、頸、肩、胸、臂、髖、膝、腳、衣物的姿態說明，見 FS_16_ACTION_FULLBODY_PLAYBOOK.md 及每一個PIXELLAB提示詞檔。

## 角度與角色一致性（絕不可省）
「45°」指角色在地圖水平面**斜朝東南的三分之四戰鬥角度**，不是相機俯視角45°。
對PixelLab使用 direction=south-east、view=low top-down，但實際必須對照FS原生臉頰、鼻、肩與髮型。不能將向右走路的90°正側面直接當SBS戰鬥原圖；也不能變成完全正面。
四方向走路分別south、west、east、north。絕不把SE圖直接當north的背影。
武器、箭、護盾、魔法、粒子不內嵌在人物sprite；FS武器與VFX分層。
三格全都32×32，輸出96×32的單動作列，未來再整合完整96×128的角色圖。不要生成40×40強行放進32×32原生版。

## PixelLab官方專業操作
1. 目標新角色在對應角度提供透明32×32 F0。設成 Set reference，PixelLab估算18關節後人工校正眼睛、左右肩、肘、髖、膝、靴。
2. 把對應 ORIGINAL 三幀參考圖放到Aseprite/PixelLab同一專案中。選三幀並按 Set animation，在 Animation to Animation 中抽取骨架並 Rescale 到新角色，逐格檢查。
3. 或直接使用本包 REUSABLE_ACTION_18JOINT_TEMPLATES 及 PIXELLAB_RETARGET_18JOINTS_OFFLINE.py，輸入新角色參考圖與其18點估算JSON，離線套出三張動作姿勢（還未生成新圖）。
4. 使用 Animate with Skeleton v3，不要只使用text動畫。附加 PIXELLAB_MASTER_CHARACTER_PROMPT 與對應動作提示詞：長版已包含master；API版精簡且同樣包含所有核心條件。
5. 三幀生成前看動作骨架有沒有真正的頭肩、手臂、骨盆、膝與腳連動；若不對先改骨架，不要付費碰運氣。
6. 生成後製作GIF以肉眼檢查，動作不自然則用局部Inpaint與修正骨架；先不要做VX實機。
7. 若以單張新角色圖起步要做全方向，PixelLab可建立8方向圖，但每個方向必須另外檢查並對應目標圖；仍需要逐種動作分別生成，不能一個API請求產出全部15種。

## API構造（供程式，不會自動扣點）
POST /v2/animate-with-skeleton-v3。
first_frame：目標角色該角度的F0圖片base64。
first_frame_keypoints：新角色18個第一幀關節。
keypoints：[F0 18點、F1 18點、F2 18點]。
description：該動作短版英文prompt；action：動作描述。
view：low top-down；direction：依動作 south-east/south/west/east/north。
template_id：mannequin（人形；之前實測支援）。
no_background=true。
每個動作單次申請，回傳job id再查詢；絕不因尚未收到結果而重送。
官方Animate with Skeleton v3支援3～15幀、尺寸至256×256。不能把45組估算骨架的精度當作完全正確；32像素的左右手／腳可能被模型誤認，所有骨架疊圖需先肉眼校正。

## 什麼可以自動化、什麼不行
**可自動化：** 原版三幀解析、45張骨架估算、按16種動作配方重新排序、18點保形套用、批次建立待生成工作、所有生成結果組GIF。
**仍需肉眼QA：** 肢體左右正確、45°角度、人物比例一致、盔甲衣擺、動作讀得懂、整體骨架是否自然，尤其受傷、迴避、死亡、飛躍動作。不能宣稱一張參考圖加一段文字100%出全套合格圖。

## 檔案與權威
ACTION_REFERENCE_32：15×3來源PNG與每一列96×32。
ESTIMATED_SKELETONS_18：45張真正的PixelLab skeleton估算與扣點鎖。
REUSABLE_ACTION_18JOINT_TEMPLATES：每個動作的三幀骨架＋QA警示＋播放順序。
PIXELLAB_PROMPTS_PER_ACTION：16種完整/精簡提示詞。
A57_ESTIMATED_18JOINT_XX.png：15份三姿勢骨架疊圖。
A57_23NODE_ENRICHED_FULLBODY_MOTION_GRAPH.json：18可用點＋5內部輔助點。
PIXELLAB_RETARGET_18JOINTS_OFFLINE.py：新角色骨架轉換，不呼叫付費API。
A57_BATCH_PREPARE_ALL_ACTIONS_OFFLINE.py：自動分配五種朝向，缺素材直接BLOCK，不冒充合格。
A57_ORIGINAL_16_ACTION_VISIBLE_MOTION_METRICS.json：依實際畫面合成後統計，排除透明背景RGB假差異。
A57_FULL_SKELETON_45POSE_QA_SUMMARY.json：逐動作18點變化與人工警示。

## A43~A55失敗規則
A43側面、A44正面、A45逐幀方向漂移、A46整個上半身鎖定、A47過大跨步、A48頭身飄移、A49混搭不對稱、A50-A55局部只有腿移動，全都不可繼續當成正式跑步。A57必須從**原版全身動作**出發，所有新角色先GIF肉眼驗收，不修改封版FS。

官方文件：https://www.pixellab.ai/docs/tools/animate-with-skeleton
API文件：https://api.pixellab.ai/v2/docs