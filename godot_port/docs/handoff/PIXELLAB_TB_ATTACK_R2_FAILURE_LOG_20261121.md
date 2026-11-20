# T-B PMD0001 Attack R2｜根因檢討與施工結果
日期：2026-11-21｜分支：`feat/fs-pixellab-tb-monster-20261121`｜Linear：SHO-37
狀態：**ACTIVE / ATTACK ART FAIL**。第一輪三階靜態與歷史 Idle 不退版；攻擊不可升為 ART PASS。

## 1. 失敗根因（實測，不是推測）
上一輪 `build_tb_monster.py` 用 `body_pose()` 將同一整張怪物圖縮放、平移、逐列扭斜，再 `add_lava_bolt()` 加火球。
從已保存的 `PMD0001_STATIC_64.png` 直接重現 8F 攻擊，**F0、F1、F2、F3、F6、F7 六幀像素完全一致**。另 F4、F5 除各 28／29 像素外，仍由整體身形變形解釋。身體沒有真正獨立關節、張嘴或四肢蹬地動作；單靠火球無法成為合格 Attack。
正式分類：`RIGID_BODY_ONLY`, `NO_LIMB_ARTICULATION`, `DISCONNECTED_PROJECTILE`，**阻斷**。放棄以整圖壓縮／晃動調參修復；不是 minor pixel issue。

## 2. 找回真正的動畫權威
私人 Drive 真實來源 ZIP：`P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027.zip`；Drive ID `1QWdMHbu1VTQ85kaOEXSankeSsIY6FvOS`；ZIP SHA256 `74061d61a7fde6650699ee30ad1339ff255924a9cae13c98cb1703478eae260f`。
ZIP 內 `GODOT_0001/rock_0001/Attack-Anim.png`，SHA256 `ff0026be89a68288f5cad35e46c700fcaefe82dfeb24df1f5b7053a10585f070`；704×576、11幀×64px、8方向×72px。
`AnimData.xml` SHA256 `c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162`。11 幀 duration ticks `[4,2,4,2,2,2,2,2,2,2,4]`；Rush=2，Hit=5，Return=7。
實際拆解 row1、row2，各有 11 張不同的影格，64×96 padding 後無裁切，分別輸出 256×288 透明 atlas 與 GIF。這是**原生動作參考**，不是已與高解析概念母圖一致的正式新攻擊。

## 3. 本輪可驗證成果
- [舊8F對原生11F逐幀比較圖](https://drive.google.com/file/d/1axA8UO5tsupoZKK7psZTdhGFTuhQKucp/view)
- [原生row1 GIF](https://drive.google.com/file/d/1yCCtpMF_i9VsKHvWR3cg-LoauMFy6ScL/view) / [原生row2 GIF](https://drive.google.com/file/d/1xHKK3QUhiqPa_d7Y6iBZoNZtCLHJehhr/view)
- [原生row1 11F atlas](https://drive.google.com/file/d/1iqfYazjFQUnLxunWdIkfTjSRr-T_P3fm/view) / [row2 11F atlas](https://drive.google.com/file/d/1SZoBaWhh79V9xOE6iA2FbRFhVE4jU0HP/view)
- [自動重建與來源 SHA Manifest](https://drive.google.com/file/d/1V4VIfvnkwCwfdgJ28isGApRqa2PR_2wv/view)
- [Godot 4.7.2 獨立對照工程 ZIP](https://drive.google.com/file/d/1p2rZLZFVIEpPgYbpogX42YMhjyMD2upf/view)，18 entries, CRC PASS, SHA256 `a0f63b7883acc963d5c9df929f627ff1fa35d07c6290aeaa352bebdeaab03ea6`。SPACE 播放新舊，1/2 選擇方向，R 重置。**Godot native 尚未執行**。
- GitHub 公開程式只有 `godot_port/tools/pixellab_tb/build_attack_reference.py` 及 `godot_port/experiments/pixellab_tb/tb_attack_review.gd/.tscn`、說明文檔，私有 PNG/ZIP 絕不提交。

## 4. Gate / 成本
- 來源、舊版歸因、原生動畫解構、CRC、SHA、幀數與幾何：SCRIPT PASS。
- 先前 Attack ART：**FAIL**；正式新 Attack：**NOT_CREATED**。
- 11F 原生視角 45° 與高解析概念母體一致性：HOLD，**不是正式完成品**。
- Godot 4.7.2 原生展示：NOT_RUN（隔離環境無 Godot 4.7.2 執行檔）；沒有真正的原生截圖。
- PixelLab 本輪付費生成：**0 generations**；無 job ID；不杜撰費用。
- 第二不同物種量產：NOT_RUN。
- 使用者 PC 新成果庫：無；main、T-A、T-C 未修改。

## 5. 下一個完整成果單位
以已核准的 PMD0001 母圖＋真正 11F PMD 原生姿勢為參考，建立 **四組明確姿勢：蹲伏蓄力→後腿發力→張嘴／前肢命中→回復站姿**，關節、嘴巴與特效分層。先試 PixelLab Skeleton v3（需 `estimate-skeleton` 合法關鍵點），骨架若錯換 Text v3／keypose 路線；保留真正 job/成本；原生 Godot 4.7.2 與人工美術 Gate 過後才擴到第二樣本。禁止用整體位移、縮放或火球代替攻擊姿勢。
