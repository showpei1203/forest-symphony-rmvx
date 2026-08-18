# Forest Symphony Phase49K4 最終實機 LOG 分析
日期：2026-08-18

## 結論

Phase49K4 最終實機：
`[SUMMARY] suite=CROSS_SUITE result=FAIL pass=1851 fail=3 warn=0`

這 **3 個 FAIL 不代表 3 個 Runtime defect**。
它們全部源自同一個 TEST guard expectation：

`Graphics.frame_count` 被錯誤要求在完整真實 Battle 前後保持 exact equality。

## 實機證據鏈

### PRE_BATTLE
- Nonbattle Core B→I：`231 PASS / 0 FAIL`
- pre-battle semantic guard：PASS
- Battle 開始前累計：`pass=232 fail=0`

### Battle
- SEALED Battle Smoke：`pass_delta=1388 fail_delta=0`
- Battle snapshot restore：PASS
- Battle restore 後累計：`pass=1620 fail=0`

### Guard diagnostic
K4 新增逐欄 diff 後，BATTLE 只出現：

`[PHASE49K_GUARD_DIFF] stage=BATTLE rows=[[:frame, 205, 236]]`

也就是以下 guard 全部沒有差異：
- brightness
- map_id
- player position/direction
- party gold
- fog transition
- normal minimap visible/fullmap
- AI deterministic RNG enabled state
- Combat deterministic RNG enabled state
- scene class
- ring command count
- Game_Temp / RandomDungeon transfer flags

唯一差異：
- `Graphics.frame_count 205 -> 236`

### POST_BATTLE
Battle 後反向 Nonbattle Core I→B：
`231 PASS / 0 FAIL`

完成後 guard diff 仍然只有：

`[PHASE49K_GUARD_DIFF] stage=POST rows=[[:frame, 205, 236]]`

所以 Battle 後的 Scene/UI、Save/Load、Economy、Map/Event、Random Dungeon、Vehicle/Fog 等全部再次通過。

## FAIL 結構
1. Battle guard 因 frame exact equality 為 false。
2. POST guard 因同一 frame exact equality 為 false。
3. Aggregate 被前兩條連帶拖紅。

因此：
- 真正 functional assertions 全綠。
- 沒有 gameplay state leakage 證據。
- 沒有 Save/Load 污染證據。
- 沒有 Map/Event/RandomDungeon 污染證據。
- 沒有 RNG enable-state leakage 證據。
- 沒有 Scene / Ring / Minimap state leakage 證據。

## 正式分類
**TEST-only semantic invariant defect。**

`Graphics.frame_count` 是時間軸，不是必須 restore 的 gameplay state。
真實 Scene_Battle / Scene_Map lifecycle 本來就會讓 frame 前進。
正確 invariant 應是：
- stable gameplay keys：exact equality
- frame：non-decreasing / monotonic (`actual >= expected`)

不可把 frame 直接完全不驗；建議保留 monotonic guard 與 delta log。

## Phase49K5 正確修法
Formal Runtime delta 必須維持 0，只改 page478 TEST。

建議：
1. `p49k_guard_diff` 對 stable keys 保持 exact。
2. `:frame` 不再因正常前進產生 mismatch。
3. 如果 `actual_frame < expected_frame`，才報 `:frame_regressed`。
4. 保留 `[PHASE49K_GUARD_DIFF]` 與 frame delta marker。
5. 不修改 Battle 1388 / PRE 231 / POST 231 的期望。
6. 不新增或刪除 functional assertions，成功總數仍應為：
   `1854 PASS / 0 FAIL / 0 WARN`

## Current hashes
- K4 Scripts.rvdata SHA-256: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`
- K4 Candidate ZIP SHA-256: `d5074808361c73abdae7b9b89c400267e1754efff9559a63713b37f4fcd03ffc`
- Latest K4 LOG SHA-256: `0710d41e69b09b203feee182e8f60df89fc636b6937e70fead80a4d433ced0c2`
- Latest Validation Report SHA-256: `61b85b24bd76026b991538d76b11cae5bf8cf612fe1e376541eeb3d097730495`
