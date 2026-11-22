# Forest Symphony｜T-B R15｜2026-11-22｜第三怪物家族與六階復活重製

## 施工範圍
本版僅負責怪物美術。嚴禁回到 Battle/ATB/ACT/EnemyID/UI 整合或動到 main、T-A、T-C。R14 完整 ZIP SHA256 `07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575` 保留不動。

## 真正的新增成果
- 第三個獨立怪物家族 `TB03_GLACIER_JACKAL`：一階 Glacier Jackal Pup，二階 Crystal Wolf Guardian，三階 Ancient Glacier Fenrir。其四足、藍色眼睛、深色口鼻、厚尾及冰晶身份跨三階一致；冰晶結構、體型與輪廓逐階成長，並非單純放大或換色。
- 三張真實 PixelLab 原始身份圖：一階 `create-image-pixen` (1.0 generation)，中高階各由上一階真正圖片 SHA 鎖定 `edit-image` (1.0 generation ×2)。**三張原圖合計 3.0 generations**。
- 第三家族每階真實 PixelLab `animate-with-text-v3` **Idle、Attack、Hurt、KO 四動作、每動作 8 張真實輸出選用圖**。共 **12 動作圖集 ×8 =96 匯出影格**，每筆有 PixelLab 真實 job id、generation id、source SHA、尺寸/alpha/裁切 QA，原始影格保存在私人 ZIP。
- 另葉翼蝠及熔岩蛙的 6 個階段各重製 `Revive`，使用真正同階 KO 最後一幀為第一端，Idle 第一幀為最後一端，原始 KO/Idle 不同尺寸時只在透明畫布置中，不重畫來源像素。每段 10 張輸出影格，累計 60 張。
- `animate-with-text-v3` 某次回傳 n+1（多一張輸入 echo），R15 存 **174 幀真實 PixelLab 回傳影格，選用輸出 156 幀**。第一/末影格為 exact original KO/Idle source anchor 而非 2 張新 AI 生成圖。絕不混淆 provider/raw 與匯出數。
- 18 組本次正式通過的 PixelLab 動畫累計 provider 用量 **68.0 generations**；三階來源圖 **3.0 generations**；另初次熔岩蛙一階 Revive 因 2 張影格碰邊而淘汰 **3.0 generations**，退件 PNG＋報表與原供應商 id 完整存檔。**R15 本輪實際 PixelLab 成本 74.0 provider-reported generations**，美元價格未知，沒有假裝退件免費。
- 新增兩段 Frost 1→2、2→3 各 16F 晶化溶解過場，首尾精確使用兩張原來源 PNG，**屬程序化圖像運算，不是 PixelLab AI 生成 morph**。原有 4 段 Bat/Frog 進化全保留。
- 累計 **三家族／九階形態／84 動作圖集／6 段進化效果＝90 組圖集、802 匯出影格**。第三家族目前 **4／12 個動作／階**，不能宣稱 12 動作齊備。

## 真正引擎測試
官方 Windows Godot **4.7.2.stable.official.ed1daf0bf** 原生 editor headless 匯入 exit 0；獨立藝術展示檢查：
`FS_TB_R15_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=802 third_species_actions=4 revised_revives=6`.
沒有提供非 headless 顯示器實際戰鬥截圖，切勿聲稱玩家角度人工美術已合格。

## Google Drive 私人正式備份
- [R15 完整 354 檔 ZIP](https://drive.google.com/file/d/1svlqtT0M3e88n62FH_qF8afUlIr9qqyK/view)，**9,302,874 bytes**，CRC PASS，SHA256 `5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c`。Google Drive 直接取證 parent 10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3、shared=false、user:owner only。
- [霜晶狼三階×四動作真圖比較](https://drive.google.com/file/d/1hWEjGXs9PrfFhtMwR6gBMUmB3nEXprrZ/view)
- [葉翼蝠 R14/R15 Revive 前後](https://drive.google.com/file/d/1AW2WJJ-Baqc3Tq8qahwXUkyOWyxJov2_/view)
- [熔岩蛙 R14/R15 Revive 前後](https://drive.google.com/file/d/1u6xyvcyXVCUVmQ-udeDSzTR5tJQ8lLTF/view)
- [PixelLab 供應商 Ledger](https://drive.google.com/file/d/1LrbXW55MMRI4Jtev_IBKnJH69PMCCo_C/view) | [真 Godot 原生日誌](https://drive.google.com/file/d/1bn-t3B26SBqedOfUVdZxHOXrbo0xmRA9/view)
- [霜晶狼 1→2 GIF](https://drive.google.com/file/d/1TZiP52JztV6_F3SRFCXdFG_GQNxaWcm2/view) | [2→3 GIF](https://drive.google.com/file/d/1h8q-ucPI1wNzX9dHDEi1nII_b8VmnUFa/view)

## 重要美術 HOLD（R15 本體）
實際開啟真實比較圖後，**Frog 的 PixelLab Revive 中段自創過大的獨立火焰與變形**，明顯不符身份、不能只憑影格／Godot 測試通過就批准；**Glacier Jackal 3 階 KO 動作不足以明顯倒下**，須重做 KO。R15 Frog AI Revive 雖工程 TECH PASS，卻為 **ART HOLD**。已另以 **R15P** 的來源精確影格重排修正，請以 [R15P Handoff](PIXELLAB_TB_R15P_HANDOFF_20261122.md) 的最新候選為準，勿以 R15 代替。

## 下一步
第三家族尚缺每階 Guard、Skill、Locomotion、Stun、Taunt、Charge、Release、Revive，共 **24 新 PixelLab 動畫**，另需真正趴倒的 3 階 KO 訂正；全部維持原圖與東南 3/4 鎖定。美術要先看動態 GIF，不能以原生 QA PASS 代替。
