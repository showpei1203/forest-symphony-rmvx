# FS A35 正式施工規格｜45度Dodging關鍵影格補幀與Loop語意檢驗
日期：2026-11-01。承接A31（原始Walk節奏已過關）→A33（Dodging F0 90度FAIL）→A34（真實$actor01_1 45°戰鬥視角修正）。

## 目標
A34直接使用原版battle view的F0/F2、三幀中間F1的倒立閃避姿勢雖然鏡頭改善，卻存在F0→F1→F2時序跳躍，不能宣告動作自然PASS。
A35針對這個階段獨立驗證PixelLab真實/interpolation-v2能否補出1～多張中間過渡，而不造成角色變形、90度臉回歸、頭身比變大、武器殘留、漂浮/斷肢。先做F0→F1一段；驗收候選後再決定F1→F2，不亂做16動作。
## 權威來源
F0: A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png。是真實$actor01_1.png戰鬥角度輸入PixelLab transfer-outfit生成的原生40px無武器白髮青綠盔甲。
F1: A34/B2_DODGE_NATIVE_VIEW_POSES/A34_B2_REAL_PROVIDER_01.png。先自使用者16動作參考Dodging行真正影格F1，清除44px跨列孤立雜訊後PixelLab真實生成的深翻滾姿勢，非人工畫圖。
F2: 等於F0完全相同原始檔，保證站姿、朝向、服裝、武器錨點一致。
## 技術路徑
1. 僅source PNG輸入官方/interpolation-v2 start_image/end_image和action文字說明（描述最大500字），不可換一般影像生圖或自行推測補幀。
2. 每次付費Job前鎖SUBMISSION_LOCK、記來源SHA與餘額，失敗禁止對不確定Job重送；HTTP 422的輸入校驗拒絕另存失敗而不假裝成功。
3. 取得真實Provider所有影格、逐張保存RAW_FRAME；不得直接覆蓋原有FPS、FS素材、腳本。
4. 每幀驗收：F0方向是否依原版45度、F1下蹲/翻滾關節與頭、胸、骨盆、腳的連續性、身體完整性、40×40畫布裁切，原版1:1 Q比例與無武器的SBS前提。對比A34僅3幀的原始版本。
5. 動作屬一次性Dodging，只有內部幀連貫，不需循環至第一幀；死亡及勝利則各自有Hold規則，Walking才需要循環。
6. 若插值新幀角色面向漂移、突然變大、衣服損毀、出現武器或只有交替無關畫面，即藝術FAIL，不能用0像素接點或Provider成功掩飾。
7. 全套SBS紙娃娃武器動畫、遊戲引擎仍未實際通過，不可宣稱正式戰鬥整合。
## Gate
A provenance 原始檔SHA+正式Job ID+扣額；B 幀數/透明/正確bbox；C 每格45度角/沒有90度側臉；D 身體四肢連續；E無武器、紙娃娃分離；F真正播放速度和自然感；G 使用者美術/實機過關後才可封版。
## 預設封存狀態
A34原始所有素材不動；A35所有輸出另置於E:\GameAssetToolLab_20261023\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101。每次輸出先完成本機真圖/JSON、測試時狀態明確，再同步Drive/GitHub與私人ZIP。
