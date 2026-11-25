# Forest Symphony｜T-C D23｜FS_04_MAZE 整張新非地表美術 RGB plate→真透明備援＋實際 Godot 4.7.2 1× 渲染｜2026-11-26

**最高狀態：**以使用者 ART-FIRST 指令生成了**新的獨立非地表來源**，保留 D17 Ground、不覆蓋 D22。D23-C 新全圖 `1280×928` CompletePAR 冷重建完全一致，真的以官方 Godot 4.7.2 和私人 PNG Native 1× 渲染 **TECH PASS**；**原始模型沒有輸出真 Alpha**，是 checkerboard RGB，需受控去底，正式 HUMAN ART **HOLD 0/12**。沒有碰撞／ACTOR01／Runtime 工作。

## D23 真實來源與隔離驗證

- 鎖定 Ground (D17 不變) SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，`1280×928 RGB`。
- 原生成全非地表物件圖 `1474×1067 RGB` SHA `cf13df206f06847f7b95815b25b571b16b01fa21ecdbb93794f85e3a13eb6301`，帶模型繪出的**棋盤格底色，不是真 RGBA**。作為純物件（無 Ground）的 RGB plate 才允許 `neutral-white/gray key`；從背景圖逆向摘取物件完全禁止。去底 RGBA 來源 SHA `627aaeb545123b56d256c11b2395516dfccedacb6c761604c48b4f95fb02e988`，來源仍不改。
- 使用十個 8-connected 主物件來源全體的 Bounding Box 以 1x 原始像素排至同一個 `1280×928 RGBA` PAR（沒有個別圖章縮放、polygon 裁斷或角色擋不擋的篩選）。A 重疊 **3489**、B **5305**、C **259** 前景物件像素；採 **C**（外緣5px高透明度貼邊 0），不代表物件和 Ground 腳點完美。
- 新 D23-C PAR SHA `6d53adde4ed2bac8f5a5a030006f1e0d40098306d61c8b907042b76ca42296e7`，true alpha0 **710596**。真 D17 Ground+ D23-C 靜態合成 SHA `d58afa632e6b66d684043eaca2cfe61224e7dc3a933dd98c9270c8e08f87c0d4`。
- 冷新目錄重新由 source RGB+locked Ground 產出 RGBA source/PAR/composite；三份 SHA 逐一一致。
- 官方 Godot 4.7.2.stable.official.ed1daf0bf、引擎 binary SHA `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e`，Xvfb/Mesa OpenGL3；**真正**私人 D17 Ground+D23 PAR 各自 SHA 驗證，兩張 Sprite2D 相同 (0,0) NEAREST 原生 `1280×928` PNG SHA `9ca2316fb9ab4b266335d6d3ac736b0bc6363941f77fb3e096687d0209663cc3`。與 Pillow static RGB 每像素完全一致（diff 0），不是借用 synthetic CI 或舊 D22 引擎截圖。
- 正式美術 A/B：D22 Native vs D23-C Native 整張比較後，**D23 橋梁雖較短、物件更完整，但主工坊過大、角色可用路網及橋落腳仍未美術封版**。D22 原圖與正式 ART 0/12 保持不變。

## 私人 Drive WRITE→READBACK

- [**D23 20 檔完整 source／不同候選／原生 screenshot／SHA／測試腳本／拒收 Master／Failure Log ZIP**](https://drive.google.com/file/d/1k5q1KZsgOGmfwHGVOU7bBTdUNsy6g_Qx/view)，**30,087,017 bytes，ZIP CRC PASS，SHA `164572bccc775c2c0a01800dc6b13e32e064c75ce091ccf86e603e5ef93faee8`**。
- [D23 全新真正獨立**RGB 棋盤格**來源](https://drive.google.com/file/d/1i1BrkWAe3OK-U5do4BVKtsj2s1P-lI07/view)、[白/灰去底候選 RGBA source](https://drive.google.com/file/d/1VZOwRgG3fMgNcX9mRIpjqzcA1aGoriSd/view)、[D23-C 完整 PAR](https://drive.google.com/file/d/13jWqEULGNEaoUM-XHZf4ZVhne1vCCN3C/view)、[真 PIL 靜態合成](https://drive.google.com/file/d/1CILCmPIAmmc4-NdQ6K8MCpZ5AsLy3zOJ/view)。
- [**D23-C 真的 Godot 4.7.2 native 截圖**](https://drive.google.com/file/d/1puTw6b_oTCApmAh_hSbJPPOnl5noaAu-/view)、[D22 vs D23 原生 1× 整張 AB](https://drive.google.com/file/d/14tZB-xXEMhg7jn5eTimrp3wyxeCgD4n0/view)、[完整數據 JSON](https://drive.google.com/file/d/10VqzdSwbE9GLR4T1CI7slE_Ldv-UuOoC/view)、[可再執行腳本原始檔](https://drive.google.com/file/d/1SP_ZlWgfeKRgjQ0e6FnL8vMK3hhP4whU/view)。
- 以上最重要私人檔案 metadata **已讀回 `shared=false`、`permissions owner`**；公開 GitHub 只放文字程式、來源 SHA、Handoff、進度記錄，沒有私有 PNG。

## 門檻

| Gate | 正式結果 |
|---|---|
| 真獨立物件來源（不含 Ground） | SOURCE PASS（RGB 棋盤格 plate，而非原生 RGBA） |
| 模型原生 Alpha 輸出 | **FAIL**，去底是下游備援 |
| 原作者在正式 1280×928 原生直接輸出 | **FAIL**，來源 1474×1067，10組 1x relayout |
| 可重建 PAR 與 Ground 同原點/尺寸 | PASS |
| 真的 Godot 4.7.2 私人 PNG 1x native | PASS |
| 整張美術／橋頭語意／風格與 A35 比較 | **HOLD** |
| 正式十二圖 ART PASS | **0/12** |
| 角色碰撞／事件／戰鬥／存讀 | **NOT RUN / outside T-C** |

下一完整施工單位仍是以 **D22 vs D23 原生 A/B** 和正式 1× 風格 DNA 做**整張**美術 ART Gate，若大工坊、橋頭仍不自然，就需真正重做匹配既有 Ground 的新 CompletePAR 作者圖，而不是重返 D21 碰撞、逐 pixel 修邊或假稱量產已成功。保留 D17 Ground/D22 PAR/D23 原作者 plate，不合併 Draft PR #17，不改 Windows E:。

---

# Forest Symphony | T-C D23 ART-FIRST | FS_04_MAZE independent RGB plate to complete PAR
Date: 2026-11-26. T-C isolated experimental branch. User directive: produce art; no Godot gameplay, collision or occlusion construction.

## What was actually created
1. D17 original continuous RGB Ground remains SHA-locked unchanged.
2. A newly generated independent collection of all-non-ground volcanic workshop/bridge/crane/lamps/rocks/banners, original 1474x1067 **RGB WITH VISIBLE CHECKERBOARD**. Source has NO alpha channel. It is NOT a directly generated RGBA plate.
3. Controlled explicit white/grey key only because source was genuinely *non-ground-only*; retains original RGB unmodified. Pixel key: (minimum RGB>178) and (maximum-minus-minimum<15) become transparent; other source pixels remain opaque. This is a deterministic FALLBACK, not original native alpha; expect some harsh alias fringes.
4. Identify ten main 8-neighbor components from keyed 1x source; place complete rectangular alpha bounding islands in native 1280x928 one PAR without shrinking, polygons, or cutting whole houses. Source high-frequency pixel art does not prove stylistic compatibility.
5. Whole-scene layout A: 3489 overlap source pixels; B: 5305; C: 259, 0 high-opacity border pixels. Freeze best candidate C. No changes to old D22 or other project files.
6. Cold rebuilt entire keyed source/PAR/Composite with new isolated output and all SHA hashes matched exactly.
7. Official Godot 4.7.2 stable official Linux binary SHA256 8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e, private true D17 Ground and D23 PAR, separate nearest Sprite2D same (0,0) origin, native 1280x928 framebuffer, both SHA locks PASS. Pure renderer test only. No user gameplay or human ART acceptance.

## Failures and gates, ART HOLD
- New image generation attempt returned a full Ground+objects scene; it was rejected as MIXED MASTER, cannot use reverse extraction for PAR.
- Independent plate returned RGB checkerboard rather than genuine RGBA; white/grey-key is a practical but lossy matte fallback. Alpha now binary, minor edge artifacts on bright smoke/stone likely. Original source is preserved.
- Despite a shorter bridge than D22 and fewer mutually overlapping object pixels, its 1x bridge span is still much wider than the lava channel; artist must check supports, footprint and true walkable route. Large forge can overpower the maze composition.
- Technical source/structure/native PASS; human source styling, full-map composition and ART **HOLD**, 0/12 formally approved; ACTOR01, collision, gameplay etc NOT_RUN and out of T-C authoring scope.
- A/B/C are independent whole-scene layout studies; no proof model generated native 1280x928, only 1x full component relay-out from 1474x1067 source.

## Next ART work unit
Use the D22/D23 native 1x comparison for holistic visual review; unless the owner approves, do NOT replace D22. If neither matches art target, author a new *native-safe continuous complete PAR* for the unchanged D17 Ground (or redesign the scene Ground with clear blueprint if necessary). Do not add AI tools or restart bridge physics.
