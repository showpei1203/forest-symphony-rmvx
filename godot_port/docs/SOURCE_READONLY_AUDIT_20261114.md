# Forest Symphony → Godot P1 | 原始來源唯讀稽核 (2026-11-14)

**狀態：SOURCE READ PASS / GAMEPLAY NOT RUN / PHASE1 NOT SEALED**。本報告來自已連線 Windows 原始工程的唯讀讀取，**沒有**複製、移動、刪除或覆寫使用者原始檔案，也沒有在使用者 PC 產生新檔案。所有 SHA-256 為資料來源見證，非 Godot 轉換後檔案的雜湊。

## 原始權威
- 檔案所在位置（只讀）：`E:\遊戲專案開發\三大項目現行專案\FS project`
- 戰鬥 RGSS2 腳本匯出：505 分頁、10,927,067 bytes
- `Data/Scripts.rvdata`：2,457,490 bytes
- 地圖檔 `Map001..Map051.rvdata`：共 51 個
- 菜單素材 `Graphics/Menu` 41 件；`Graphics/System` 142 件；`Graphics/Windows` 21 件。

## Ruby Marshal 4.8 真實資料解碼：PASS
腳本 `godot_port/tools/rvdata_to_json.py` 經由 Python 3.11 在來源 PC 記憶體內唯讀執行，逐一完整解析所有 11 個檔案，包括原始 RPG 物件結構、Ruby 符號參照、陣列/Hash、二進位 `RPG::Table` 等。**這只代表解碼成功，不等於已完成 Godot 轉移或與實機戰鬥數值相符。**

| Data | 原檔大小 (bytes) | 含 nil 筆數 | 非 nil 筆數 | 首筆 Ruby 類型 |
|---|---:|---:|---:|---|
| Actors | 396,310 | 301 | 300 | RPG::Actor |
| Classes | 142,702 | 301 | 300 | RPG::Class |
| Skills | 117,644 | 801 | 800 | RPG::Skill |
| Items | 104,656 | 851 | 850 | RPG::Item |
| Weapons | 30,849 | 351 | 350 | RPG::Weapon |
| Armors | 72,536 | 801 | 800 | RPG::Armor |
| Enemies | 515,202 | 801 | 800 | RPG::Enemy |
| States | 21,830 | 156 | 155 | RPG::State |
| Troops | 13,133 | 61 | 60 | RPG::Troop |
| System | 22,298 | 1 | 1 | RPG::System |
| Animations | 292,322 | 301 | 300 | RPG::Animation |

## 實際欄位與尺寸，修復首版錯誤
- **FS 角色參數位於 RPG::Actor.parameters**，為 `RPG::Table` 的 `xsize=6, ysize=100`，線性陣列偏移 `level * 6 + stat_index`；`stat_index=[maxhp,maxmp,atk,def,spi,agi]`。RPG::Class 並沒有此參數表。已修改 `FSDatabase.gd`。
- `System.party_members=[1,2,5]`。角色 ID1 喬伊、ID2 米亞、ID3 艾卓、ID4 維娜、ID5 艾薇、ID6 泰勒。
- RPG Actor 的 character_name 分別為 `$actor01`、`$Actor5`、`$actor03`、`$Verna`、`$Actor6`、`$Actor40`（來源大小寫須保留）。
- **角色圖格子不能一律固定 32×32**：例如 `Graphics/Characters/$001.png` 為 96×128（3×4 格，每格 32px）；`$001_1.png`、`$001_2.png`、`$001_3.png` 都是 90×120（3×4 格，每格 30px）。這是通用檔案觀察，**還不是 6 位主角的實際動作檔對照**。Godot adapter 改為依來源每張圖片長寬計算切格，不做拉伸。
- `Graphics/System/iconset.png` 為 **384×15,096**，不等同乾淨 Tankentai 測試版的 384×768；不可共用對方的 Atlas 上限。
- `Graphics/System/Btskin_main.png` 為 135×40；`Graphics/Menu/Menu01.png` 為 50×20。
- `Troops.rvdata` 第 1 隊的 member 指到 enemy 609，**不能偷懶直接選 Enemies[1] 當第 1 隊**。
- `FSBattle.gd` 裝備重算的首版雙重加總問題已修正。仍未核對最終 Ruby 別名鏈與效果規則。

## SHA256 原始檔見證
| 檔案（相對於 FS project） | SHA256 |
|---|---|
| All_Scripts_Export.txt | `9CBC7A9B4F3595706F3BD9987C8353951B73B14BFAFCE0C574D5C21E438F0F24` |
| Data/Actors.rvdata | `DFBAC672C9E2A6D893A58C7513C8FBBE9087426F7ED53C3E26AAEA1774D9EB59` |
| Data/Classes.rvdata | `D88D3D267E3C23F93F8E9968AC43172D3B608537F64FDAE4A759F68BFB153C0E` |
| Data/Skills.rvdata | `679A9BA8C88A9BC901BCB98D1818FABE006CBBBC7C658E67A9CE53E3F57F436C` |
| Data/Items.rvdata | `9B72B0D38407A0B31F7639CAE39D936004920629F9DEE86F635AFB0608966B93` |
| Data/Weapons.rvdata | `E81246D798493ABB97B46AE06DEA77EB68EAA9E0335EC754C8F2778E50C68AD2` |
| Data/Armors.rvdata | `8C296E608F1176E706E600DF185FA668622F6124B69205169F82FF25B807CB2A` |
| Data/Enemies.rvdata | `F11FA05CED0EF7724166457216BA68986B58F4808D5736003EBBA8F4421EC625` |
| Data/States.rvdata | `55EB136CFB616313D804CDBD0A221DE46121ACDCDA098EF11E24C554D6FB00DC` |
| Data/Troops.rvdata | `07423A3E24E30B473E4C46B332E469B03D52CC46E843EB1750C9884A981754A3` |
| Data/System.rvdata | `76CF4FD3EDDBFA6009682E46EEA736E6A180182D4B99A0CEC27F6A24D5FE6C82` |
| Data/Animations.rvdata | `781A1A2C04EEA8A0809CADE7FDFAFDF3561D310D8058A2807199B7597116AD4D` |
| Data/Scripts.rvdata | `D398178135C5B41622B0E6DA763D58AF1FBF770C9D24A360A23508800015809A` |
| Graphics/Menu/Menu01.png | `D7190866F8A0652F4A7665EA91BEE314062731B952398F2CCE9C7530A4ECFC8C` |
| Graphics/System/iconset.png | `8273BC643025F92496A7471CF080CD6A87D0A762FC04731C7F016E00F0C0BB2C` |
| Graphics/System/Btskin_main.png | `87671D016B03069558601D1E4D0351EAD9762671CB964FBC33A6055AB15348F6` |
| Graphics/Characters/$001.png | `ACC1CC63F3BA424C6D9F6E5FF0359093F2DC123B0FA5FBBE8AE4F67EE7891829` |
| Graphics/Characters/$001_1.png | `02DA558BB5538CD4E05C78923C6BDC33E084F783323CFD6CC1DF91E905584248` |

## 未通過的工程 Gate
- 將 JSON 與實際圖片/音訊整理至私人 Drive：NOT DONE（唯讀轉換，**不准**在 PC 暫存輸出；不准丟公用 repo）。
- 505 段後載入 override 的最終傷害/成本/狀態/AI/ATB/OD/Cover 與召喚規則：NOT DONE。
- Godot native compile、視覺 MENU/BATTLE 對照、整套流程截圖 QA：NOT RUN。
- Phase1 Seal：NO。現有 Godot 程式仍屬遷移原型骨架，不是完整戰鬥移植。
