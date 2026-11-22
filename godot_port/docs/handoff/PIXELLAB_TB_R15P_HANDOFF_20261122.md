# Forest Symphony｜T-B R15P｜2026-11-22｜熔岩蛙來源精確復活修正版

## 為何需要 R15P
實際檢查 R15 比較圖發現熔岩蛙 AI Revive 動作中段出現不屬於角色的火焰，以及高低角度、姿態扭曲。即使 10F 及 Godot QA 全過，仍是 **不合格美術，ART HOLD**。正式放行絕不以 alpha／帧数／唯一 SHA 檢查偷渡。

## 真正施工與方法
- 不再為相同問題無限重生。使用每一階**已存在且源 SHA 鎖定的 KO 8F**，逐張倒序編排成從倒地起身，再接上原有 **Idle 第 0、1、2 幀**，各輸出 **11 張真正原始 PNG 來源像素影格**。在不同 sprite cell 尺寸時僅將小圖擺在大尺寸透明畫布中心；不改動狼、蛙、蝠既存身份。
- 嚴格核對 R15 KO 原圖最後一幀 = 新 Revive 首幀，同階 Idle F0 = 復活第九幀。未新增任何怪物部位或獨立魔法火球。將原 R15 AI 生成復活完整保留在原始封包與新 manifest 的 `r15_text_v3_revive_art_hold`，從不破壞原先素材。
- **本次 R15P 新 PixelLab jobs = 0；新 PixelLab generations = 0**。這是來源原圖影格重新計時，不冒稱為新的供應商 AI 動畫。三階 Frog 各 11F 取代原 R15 10F，總影格由 802 → **805**。
- 真實官版 Windows Godot 4.7.2 editor 匯入 exit0，原生展示測試：
`FS_TB_R15P_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=805 frog_source_retime=3`。
- **仍是美術候選，OWNER_ART_REVIEW_PENDING**，尤其新 Wolf KO 仍 **ART HOLD 未倒地**。技術合格不得宣告藝術合格。

## Google Drive 私人正式成果（已 API readback）
- [R15P 最新來源精確修正版全包 ZIP](https://drive.google.com/file/d/1Hr-nshnDqyAXnlEMP3g-VyiD_nPnAsdo/view)，**9,643,175 bytes**、**373 檔**、CRC PASS、SHA256 `a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7`。Google Drive API 實證同私人原資料夾、shared=false、user:owner only。
- [R15 火焰錯誤 vs R15P 三階正版來源修正圖](https://drive.google.com/file/d/1CXr-7U2Blxc83-aIinJI2ZYo_S-a1da_/view)
- 真正來源逐幀 GIF：[初階](https://drive.google.com/file/d/1i5537mb2LI5Bdlp23Q1f4eNLy49N6WrT/view)、[中階](https://drive.google.com/file/d/1XMN7zFKbPhBuFS56V9_-VUPFlXN2rMI8/view)、[高階](https://drive.google.com/file/d/1wOQJvFMkmzpQzLEqh58oz57szaRz16G_/view)。
- [來源與 QA JSON](https://drive.google.com/file/d/1Bhc9NPW6P7LUG6Xgjvg70yV57InD8faK/view) | [原生 Godot QA Log](https://drive.google.com/file/d/1PzQtk4f6hv-OO4cGJ8lCNQsVIN7O5TYK/view) | [正式 Manifest](https://drive.google.com/file/d/1P9MkqTtDSotcvUGZ3EleeJwQsUpM9S0b/view)。
- 冷凍封存 R15 真實完整原始 ZIP SHA256 `5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c`，R14 原始 ZIP 亦不變。

## 下階段完整施工
1. 重新生成真正有倒地趴下/側躺末幀的霜晶狼三階 KO，先檢查身體、視角、晶角與四足不能脫落，再重做受影響的 KO↔Revive 對位。限制迭代與留 Failure Log。
2. 完成 Wolf 三階剩下 8 種動作各階共 24 張新 Sprite Sheets；延用 Stage1/2/3 現有來源與 PixelLab 真動畫管線，不牽扯戰鬥系統與 T-A/T-C。
3. 原生 Godot 4.7.2 動態 Gallery QA、私人 Drive CRC/SHA/Owner 和 Handoff。勿以碰巧成功執行的技術檢查代替美術審核。
