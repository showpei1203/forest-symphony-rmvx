# Forest Symphony T17A — LPC 官方原始圖層與四方向動畫結構稽核（2026-10-24）

狀態：`T17A_LPC_3_ACTION_4D_88FRAMES_PASS`。本輪為 LPC 身體／服裝分層 **Structural Pixel QA**，不是武器/PMD/SBS 或人眼美術 Gate F PASS。Forest Symphony N5 正式 Runtime 仍 paused，505 SEALED scripts unchanged。

## 來源與授權
- 唯一來源：https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles
- 原始下載 `lpc_base_assets.zip`，712,926 bytes，SHA256 `69efec8a26ef20b26cfd7a8de370e87d0e667136eba2d00392dde13d2ac52465`，78 ZIP entries。
- 官方完整 CREDITS.TXT 包含各類素材作者。三組測試 Body / Pants 歸屬 Stephen Challener (Redshrike)。原始包標示 CC BY-SA 3.0 與 GPL 3.0 雙授權；官方 CREDITS 另註 Redshrike 作品有 OGA-BY 3.0 可選。**每張商用素材的授權與作者必須逐項審查，不能將整個 LPC generator 稱為 CC0。**
- Drive 170 項索引涵蓋 Forest Symphony 地圖素材，不把本份新 LPC 官方測試用樣本冒充已核准地圖 Source Kit。GitHub 僅上傳測試腳本/驗證記錄，不上傳原始第三方 PNG/ZIP。

## 測試矩陣

| 來源動作 | 原始身體/褲裝圖 | 64x64 格 | 方向列 | 逐格對全表 RGBA | 1px 移位負測 | 交換 up/down 負測 |
|---|---|---:|---|---|---:|---:|
| Walk | male_walkcycle / male_pants | 9×4=36 | up,left,down,right（LPC 慣例） | exact | 3187 改變 | 2116 改變 |
| Slash | male_slash / male_slash_pants | 6×4=24 | 同上 | exact | 2182 改變 | 1574 改變 |
| Spellcast | male_spellcast / male_spellcast_pants | 7×4=28 | 同上 | exact | 2597 改變 | 1390 改變 |

**88/88 frame crops，3/3 整表比對符合。** 每格 Pants 非透明、有輸出 12 個方向 PNG strip + 3 張 4 向整表。原 body 與 pants 原圖不縮放、無次像素座標誤差，逐幀 AlphaComposite 後重拼之結果與一次整表合成逐像素完全相同。三動作的 1px 偏移與方向 row swap 故意錯誤皆被抓到。

**已記錄的非 FAIL 差異**：Pants 可出現在 body 透明範圍外，Walk/Slash/Spellcast 各 138/111/150 像素；衣服本來可能超出身體 silhouette，需人眼區分設計形狀與錯誤，不能武斷地以 bbox outside body 當失敗。

## 尚未覆蓋
- 真正 **SBS weapon sprite** 疊圖與 attack hit timing 對位。
- LPC 生成器導出的 attribution file / 部件混合授權。
- PMD Pokémon sprite 商用權利，並非 LPC 授權可涵蓋。
- 人眼視覺／Godot 即時光照／VX 角色實機輸出。
- 此份舊 LPC 2012 樣本方向名稱沿用 LPC 工具規格，尚未做每方向視覺人工確認。

## 本地重現與交付
- Windows root：`E:\GameAssetToolLab_20261023\ToolValidation_T17_20261024`
- `RUN_T17A.cmd` 跑 `run_t17a_lpc.py`
- JSON：`T17A_LPC_LAYER_ALIGNMENT.json`，images：`outputs/`，附原始 CREDITS。
- ZIP：`E:\GameAssetToolLab_20261023\deliveries\FS_LPC_NATIVE_4DIR_LAYER_T17A_20261024.zip`，23 entries，772,535 bytes，SHA256 `d48233251c7ee0eaf7da0cb336908c4e358188de168521ac4a44a126e8d503f3`，完整 ZIP 僅遠端電腦已確認，尚未聲稱 Google Drive ZIP 上傳成功。
- GitHub：`tools/fs_oss_toolchain_v3/t17a_lpc_layer_audit/`

Next T17B：對合法來源的分離 **Weapon/Equipment** overlay 做 action×direction×frame 對位，採兩種故意錯位負測；若來源授權缺漏，`BLOCKED_LICENSE`，不能假 PASS。
