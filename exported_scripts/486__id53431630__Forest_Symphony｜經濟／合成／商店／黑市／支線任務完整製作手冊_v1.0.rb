# ==============================================================================
# ■ Forest Symphony：經濟／合成／商店／黑市／支線任務完整製作手冊 v1.0
# ------------------------------------------------------------------------------
# 適用：
#   RPG Maker VX／RGSS2／Ruby 1.8.1
#   FS_EconomyCrafting_Integrated v1.5.7
#
# 文件性質：
#   本頁全部都是註解，不建立類別、不定義常數、不修改遊戲。
#   可直接新增到VX腳本編輯器，建議頁名：
#
#     【說明】FS經濟與Quest20～29完整製作手冊
#
#   放在Main上方即可，位置不影響執行。
#
# 重要區分：
#   1. Quest 20～29的名稱、目標、報酬與服務效果，已由腳本實作。
#   2. 地圖NPC、線索、門、戰鬥、選項與事件頁，目前不在腳本資料內。
#   3. 本手冊的「事件流程」是依現行任務目標設計的正式製作藍圖。
#   4. 不要把藍圖誤認成地圖事件已經自動生成。事件編輯器仍要逐頁製作。
#
# 目前正式腳本版本：
#   FS_EconomyCore v1.1.1
#   FS_EconomyDropSystem v1.1
#   SoulRepeatRecipe v1.1.2-FS
#   FS_SoulMark_Resonance_Expansion v2.1.1
#   Sword_Synthesize v1.08-FS
#   Window_ShopBuy FS v1.3
#   FS_ShopAllPartyDisplay v1.7
#   FS_ShopStatusDetail v1.1
#   Scene_Shop FS v1.4
#   FS_RegionShops_BlackMarket v1.1
#   FS_QuestEconomyBridge v1.3
#   FS_EconomyAudit v1.0
#   FS_EquipmentCombo_OpeningSkillFix v1.1
#   FS_SoulTerminologyNormalization v1.0
#
# ==============================================================================
# ■ 目錄
# ==============================================================================
#
# 第一篇　資料與設計原則
#   01. 正式資料ID
#   02. 章節與服務權限
#   03. Quest 20～29報酬總表
#   04. 事件製作共通原則
#
# 第二篇　Quest Journal核心指令
#   05. 任務顯示與查詢
#   06. 任務目標控制
#   07. 任務完成與發獎
#   08. 通用事件頁模板
#
# 第三篇　FS改版全部公開指令
#   09. 章節與權限
#   10. 任務完成
#   11. 商店與黑市
#   12. 汲取與配方
#   13. 鍛造與調律
#   14. 碎片交換、回收、重構
#   15. 情報與測試報告
#   16. 合成場景
#   17. 回傳值與條件分歧
#
# 第四篇　Quest 20～29逐步事件設置
#   18. Quest 20 空著的第七張椅子
#   19. Quest 21 借來的名字
#   20. Quest 22 第十三根界樁
#   21. Quest 23 夜班不點名
#   22. Quest 24 不會響的鐵砧
#   23. Quest 25 第零協議
#   24. Quest 26 被刪去的歌名
#   25. Quest 27 樹梢之下
#   26. Quest 28 完美證詞
#   27. Quest 29 一段記憶的價錢
#
# 第五篇　服務NPC與測試
#   28. 碎片交換NPC
#   29. 鍛造NPC
#   30. 調律NPC
#   31. 夜班補給NPC
#   32. 情報查詢NPC
#   33. 黑市與記憶重構NPC
#   34. 完整測試順序
#
# ==============================================================================
# ■ 01. 正式資料ID
# ==============================================================================
#
# 【完整魂刻】
#   Armor 600～665
#   第一次成功汲取取得。
#   一般情況只進背包，不自動換裝。
#
# 【鳴刻冠】
#   Armor 220～285
#   與完整魂刻一一對應。
#   ID公式：
#     鳴刻冠ID = 220 + offset
#
# 【殘響】
#   Item 200～265
#   第二次起成功汲取取得。
#   ID公式：
#     殘響ID = 200 + offset
#
# 【碎片】
#   Item 600～665
#   魂刻敵人戰鬥掉落、首次／重複汲取補給。
#   ID公式：
#     碎片ID = 600 + offset
#
# 【完整魂刻ID】
#   Armor ID = 600 + offset
#
# 【其他五人專屬殘響武器】
#   Weapon 266～275
#
#   266、267：米亞
#   268、269：艾卓
#   270、271：維娜
#   272、273：艾薇
#   274、275：泰勒
#
# 【特別殘響】
#   Item 800：米亞
#   Item 801：艾卓
#   Item 802：維娜
#   Item 803：艾薇
#   Item 804：泰勒
#
# 【任務素材】
#   Item 805～814
#   供Weapon 266～275的原始配方使用。
#
# 【舊資料】
#   Weapon 200～265已停用。
#   不應出現在正式配方、任務獎勵或商店。
#
# ==============================================================================
# ■ 02. 章節與服務權限
# ==============================================================================
#
# 【章節建議值】
#   0：魯卡村／序章
#   1：拓荒營地
#   2：哈貝爾矮人村
#   3：精靈村
#   4：主城
#
# 設定：
#   fs_econ_set_chapter(0)
#   fs_econ_set_chapter(1)
#   fs_econ_set_chapter(2)
#   fs_econ_set_chapter(3)
#   fs_econ_set_chapter(4)
#
# 查詢：
#   fs_econ_chapter
#
# 章節變更時：
#   1. 黑市購買紀錄重置。
#   2. 夜班補給可在新章再次領取。
#   3. 設成相同章節值不會重置。
#
# 【服務Key】
#   :luka_return_credit
#     Quest 20，魯卡商店折扣10%。
#
#   :new_name_blessing
#     Quest 21，新譜系第一次汲取碎片+1。
#
#   :migration_route
#     Quest 22，碎片4換1服務。
#
#   :night_supply
#     Quest 23，每章一次夜班碎片補給。
#
#   :habel_forging
#     Quest 24，鍛造服務、哈貝爾商店折扣10%、高階商品。
#
#   :zero_protocol_license
#     Quest 25，鍛造／調律服務費降低10%。
#     注意：目前實作只有費用折扣，沒有機器人指令設定介面。
#
#   :nameless_tuning
#     Quest 26，調律服務。
#
#   :root_exchange
#     Quest 27，碎片回收為製作抵用。
#
#   :anomaly_record_access
#     Quest 28，敵人掉落／汲取／配方情報。
#
#   :black_market_access
#     Quest 29分支1，黑市。
#
#   :memory_reconstruction
#     Quest 29分支2，記憶重構、服務費再降低20%、免費重調律1次。
#
# 手動解鎖：
#   fs_econ_unlock(:服務Key)
#
# 查詢：
#   fs_econ_unlocked?(:服務Key)
#
# 例：
#   fs_econ_unlock(:habel_forging)
#
# 條件分歧：
#   fs_econ_unlocked?(:habel_forging)
#
# ==============================================================================
# ■ 03. Quest 20～29報酬總表
# ==============================================================================
#
# Quest 20「空著的第七張椅子」
#   300G
#   120EXP
#   魯卡商店折扣10%
#
# Quest 21「借來的名字」
#   150G
#   150EXP
#   新譜系第一次汲取額外碎片1枚
#
# Quest 22「第十三根界樁」
#   400G
#   220EXP
#   碎片4比1交換權
#
# Quest 23「夜班不點名」
#   450G
#   250EXP
#   每章一次、共3枚已收錄譜系碎片
#
# Quest 24「不會響的鐵砧」
#   800G
#   450EXP
#   鳴刻冠與專屬武器鍛造
#   哈貝爾商店折扣10%
#   哈貝爾追加高階商品
#
# Quest 25「第零協議」
#   900G
#   500EXP
#   鍛造／調律服務費降低10%
#
# Quest 26「被刪去的歌名」
#   1200G
#   700EXP
#   鳴刻冠與專屬武器調律
#
# Quest 27「樹梢之下」
#   1200G
#   750EXP
#   6枚同譜系碎片回收為1份製作抵用
#   下一次鍛造／調律費用減1000G
#
# Quest 28「完美證詞」
#   1800G
#   1000EXP
#   敵人碎片掉落、重複汲取與鳴刻冠配方情報
#
# Quest 29「一段記憶的價錢」
#   1500EXP
#
#   分支1：
#     黑市名冊
#     解鎖黑市
#     關閉記憶重構
#
#   分支2：
#     記憶灰燼
#     解鎖記憶重構
#     關閉黑市
#     服務費再降低20%
#     免費重調律1次
#
# ==============================================================================
# ■ 04. 事件製作共通原則
# ==============================================================================
#
# 【原則A：Quest Journal是進度權威】
#   不建議每個目標再用一個全域Switch重複記錄。
#   優先使用：
#
#     objective_complete?(任務ID, 目標索引)
#
#   只有跨地圖計數、分支結果、地圖外觀需要長期保存時，才另用Variable／Switch。
#
# 【原則B：一次性地圖物件使用Self Switch】
#   例如：
#     線索
#     繩結
#     燈塔
#     證詞NPC
#     記憶碎片
#     材料節點
#
#   Page 1：可互動，完成後Self Switch A = ON
#   Page 2：條件Self Switch A，顯示已調查／已取得狀態
#
# 【原則C：後續目標逐一顯示】
#   接任務時：
#
#     reveal_quest(20)
#     reveal_objective(20, 0)
#     conceal_objective(20, 1, 2, 3, 4)
#
#   完成目標0時：
#
#     complete_objective(20, 0)
#     reveal_objective(20, 1)
#
#   這樣玩家不會一接任務就看到整份製作流程清單。
#
# 【原則D：最終獎勵只使用fs_econ_complete_quest】
#   Quest 20～29不要再使用：
#
#     give_quest_reward(任務ID)
#     change_reward_status(任務ID, true)
#     事件指令「增減金錢」
#     事件指令「增加EXP」
#
#   原因：
#     fs_econ_complete_quest會自己給金錢、EXP、服務權限，
#     並把任務標為已發獎。
#     再給一次便是雙倍報酬。玩家通常不會抗議，但平衡會。
#
# 【原則E：最後一個目標才發獎】
#   建議：
#
#     complete_objective(20, 4)
#     fs_econ_complete_quest(20)
#
#   不要在任務中途呼叫fs_econ_complete_quest。
#   該指令會把全部目標標成完成。
#
# 【原則F：分支用Variable保存】
#   任務中的敘事選擇，目前多數不改系統報酬。
#   建議分配空白Variable並命名：
#
#     Q20_巡衛裁定
#     Q21_命名選擇
#     Q22_界樁處置
#     Q25_協議處置
#     Q27_守林人去留
#     Q28_真相處置
#     Q29_記憶庫分支
#
#   建議值：
#     0：未選擇
#     1：第一選項
#     2：第二選項
#
#   本手冊不指定Variable ID。
#   必須從專案實際未使用的ID中配置。
#   All_Scripts_Export不包含全部地圖事件，不能憑空保證某個ID完全空白。
#
# ==============================================================================
# ■ 05. Quest Journal：任務顯示與查詢
# ==============================================================================
#
# 顯示任務：
#   reveal_quest(20)
#
# 隱藏任務：
#   conceal_quest(20)
#
# 查詢是否已顯示：
#   quest_revealed?(20)
#
# 開啟任務介面並定位任務：
#   call_quest(20)
#
# 查詢任務是否完成：
#   quest_complete?(20)
#
# 查詢是否已領獎：
#   quest_rewarded?(20)
#
# 查詢是否失敗：
#   quest_failed?(20)
#
# 重設任務日誌：
#   reset_quest(20)
#
# 注意：
#   reset_quest只重設Quest Journal。
#   不會自動移除FS_ECONOMY裡已領取的服務與報酬紀錄。
#   Quest 20～29需要完整重測時，優先使用新遊戲。
#
# ==============================================================================
# ■ 06. Quest Journal：目標控制
# ==============================================================================
#
# 目標索引從0開始。
#
# 顯示目標：
#   reveal_objective(20, 0)
#
# 一次顯示多個：
#   reveal_objective(20, 0, 1, 2)
#
# 隱藏目標：
#   conceal_objective(20, 1, 2, 3, 4)
#
# 完成目標：
#   complete_objective(20, 0)
#
# 取消完成：
#   uncomplete_objective(20, 0)
#
# 標記失敗：
#   fail_objective(20, 0)
#
# 取消失敗：
#   unfail_objective(20, 0)
#
# 查詢是否顯示：
#   objective_revealed?(20, 0)
#
# 查詢是否完成：
#   objective_complete?(20, 0)
#
# 查詢是否失敗：
#   objective_failed?(20, 0)
#
# 條件分歧範例：
#   條件分歧 → 腳本：
#
#     objective_complete?(20, 2)
#
# ==============================================================================
# ■ 07. Quest Journal：任務完成與發獎
# ==============================================================================
#
# Quest 20～28：
#   fs_econ_complete_quest(任務ID)
#
# 例：
#   fs_econ_complete_quest(24)
#
# Quest 29分支1：
#   fs_econ_complete_quest(29, 1)
#
# Quest 29分支2：
#   fs_econ_complete_quest(29, 2)
#
# 查詢Quest 29分支：
#   fs_econ_quest29_branch
#
# 回傳：
#   :success
#   :already
#   :branch_required
#   :invalid
#
# 不應使用：
#   give_quest_reward(20)
#
# 原因：
#   Quest 20～29的rewards欄是畫面文字。
#   真正金錢／EXP／服務由FS_QuestEconomyBridge直接發放。
#
# ==============================================================================
# ■ 08. 通用任務委託人事件模板
# ==============================================================================
#
# 【事件設定】
#   Trigger：Action Button
#   Priority：Same as Characters
#   Page：一頁即可，使用條件分歧管理狀態
#
# 【事件內容】
#
# 條件分歧 → 腳本：
#   quest_rewarded?(QID)
#
#   TRUE：
#     完成後對話
#     例：「事情已經處理完了。」
#
#   FALSE：
#     條件分歧 → 腳本：
#       quest_revealed?(QID)
#
#       FALSE：
#         接任務前對話
#         顯示選項：接受／暫時不接
#
#         接受：
#           reveal_quest(QID)
#           reveal_objective(QID, 0)
#           conceal_objective(QID, 1, 2, ...)
#           接受任務對話
#
#         暫時不接：
#           拒絕對話
#
#       TRUE：
#         條件分歧 → 腳本：
#           objective_complete?(QID, 倒數第二目標)
#
#           TRUE：
#             最終回報對話
#             complete_objective(QID, 最後目標)
#             fs_econ_complete_quest(QID)
#
#           FALSE：
#             進度提醒對話
#
# 【Quest 29】
#   最終回報改為：
#
#     條件分歧：Variable「Q29_記憶庫分支」== 1
#       fs_econ_complete_quest(29, 1)
#     否則
#       fs_econ_complete_quest(29, 2)
#
# ==============================================================================
# ■ 09. FS指令：章節與權限
# ==============================================================================
#
# 設定章節：
#   fs_econ_set_chapter(值)
#
# 查詢章節：
#   fs_econ_chapter
#
# 手動解鎖服務：
#   fs_econ_unlock(:服務Key)
#
# 查詢服務：
#   fs_econ_unlocked?(:服務Key)
#
# 手動解鎖只建議：
#   1. 測試事件
#   2. 劇情補償
#   3. 特殊難度模式
#
# 正式支線完成應使用：
#   fs_econ_complete_quest
#
# ==============================================================================
# ■ 10. FS指令：任務完成
# ==============================================================================
#
# Quest 20～28：
#   fs_econ_complete_quest(20)
#   fs_econ_complete_quest(21)
#   ...
#   fs_econ_complete_quest(28)
#
# Quest 29：
#   fs_econ_complete_quest(29, 1)
#   fs_econ_complete_quest(29, 2)
#
# 該指令會：
#   1. 給金錢
#   2. 給全隊EXP
#   3. 解鎖服務
#   4. 標記報酬已領
#   5. 把任務全部目標標成完成
#   6. Quest 29改寫成實際分支描述
#
# ==============================================================================
# ■ 11. FS指令：商店與黑市
# ==============================================================================
#
# 一般VX商店：
#   使用事件指令「商店處理」。
#
# 區域商店：
#   fs_open_region_shop(:luka)
#   fs_open_region_shop(:camp)
#   fs_open_region_shop(:habel)
#   fs_open_region_shop(:elf)
#   fs_open_region_shop(:city)
#
# 追加商品格式：
#   [種類, ID, 自訂售價]
#
# 種類：
#   0：Item
#   1：Weapon
#   2：Armor
#
# 例：
#   fs_open_region_shop(
#     :luka,
#     [[0, 10, 120], [1, 50, 2500]],
#     false
#   )
#
# 第三參數：
#   false：可買可賣
#   true：只能購買
#
# 黑市：
#   fs_open_black_market
#
# 黑市條件：
#   1. Quest 29分支1完成
#   2. 至少有一條已首次汲取譜系，否則無貨
#
# 黑市商品：
#   已收錄譜系殘響
#   已收錄譜系碎片
#   已加入角色的特別殘響Item 800～804
#
# 庫存：
#   殘響每章1
#   碎片每章5
#   特別殘響每章1
#
# 章節變更時刷新。
#
# ==============================================================================
# ■ 12. FS指令：汲取與配方
# ==============================================================================
#
# 一般首次汲取：
#   不需要事件指令。
#   自動取得：
#     完整魂刻×1
#     碎片×2
#     Quest 21完成後碎片再+1
#     對應鳴刻冠配方
#
# 一般首次汲取不自動換裝。
#
# 序章下一次首次汲取自動裝備：
#   戰鬥前：
#     fs_auto_equip_next_soul
#
# 取消一次性請求：
#   fs_cancel_auto_equip_next_soul
#
# 注意：
#   這是Game_Temp一次性旗標，不寫入存檔。
#   只在序章劇情使用。
#
# 重複汲取：
#   殘響×1
#   碎片：
#     初階／單階：1
#     中階：2
#     最終階：3
#
# 同步配方：
#   fs_econ_sync_recipes
#
# 開啟合成：
#   $scene = Sword_Synthesize.new
#
# 只顯示物品：
#   $scene = Sword_Synthesize.new(0)
#
# 只顯示武器：
#   $scene = Sword_Synthesize.new(1)
#
# 只顯示防具：
#   $scene = Sword_Synthesize.new(2)
#
# 鳴刻冠基礎配方：
#   殘響×2
#   碎片×4
#   100%成功
#
# 製作費：
#   offset 0～19：800G
#   offset 20～34：1800G
#   offset 35～50：3500G
#   offset 51～65：6000G
#
# 專屬武器製作費：
#   偶數Weapon ID：3500G
#   奇數Weapon ID：9000G
#
# ==============================================================================
# ■ 13. FS指令：鍛造與調律
# ==============================================================================
#
# 【鳴刻冠鍛造】
#   fs_econ_forge_headgear(ArmorID)
#
# 例：
#   fs_econ_forge_headgear(220)
#
# 條件：
#   Quest 24完成
#   持有該鳴刻冠
#
# +1：
#   同譜系殘響×2
#   同譜系碎片×6
#   基礎費用2500G
#
# +2：
#   同譜系殘響×3
#   同譜系碎片×10
#   基礎費用6000G
#
# 每件最高+2。
#
# 【專屬武器鍛造】
#   fs_econ_forge_special_weapon(WeaponID)
#
# +1：
#   對應特別殘響×1
#   基礎費用5000G
#
# +2：
#   對應特別殘響×2
#   基礎費用12000G
#
# 【鳴刻冠調律】
#   fs_econ_tune_headgear(ArmorID, :force)
#   fs_econ_tune_headgear(ArmorID, :harmony)
#
# 第一次調律：
#   殘響×2
#   碎片×8
#   基礎費用7000G
#
# 改調律：
#   殘響×3
#   碎片×12
#   基礎費用4500G
#
# 【專屬武器調律】
#   fs_econ_tune_special_weapon(WeaponID, :force)
#   fs_econ_tune_special_weapon(WeaponID, :harmony)
#
# 第一次調律：
#   特別殘響×1
#   基礎費用9000G
#
# 改調律：
#   特別殘響×2
#   基礎費用6000G
#
# 【分支效果】
#   :force
#     強攻調律
#     ATK +3
#     AGI +3
#
#   :harmony
#     共護調律
#     DEF +3
#     SPI +3
#
# 【鍛造數值】
#   每一鍛造等級，對裝備原本不為0的能力再+2。
#   原本為0的能力不會憑空長出數值。
#
# 【折扣順序】
#   Quest 25：
#     費用×90%
#
#   Quest 29分支2：
#     再×80%
#
#   製作抵用：
#     最後再減1000G
#
# ==============================================================================
# ■ 14. FS指令：碎片交換、回收、重構
# ==============================================================================
#
# 【Quest 22：碎片交換】
#   fs_econ_exchange_fragments(
#     來源offset,
#     目標offset,
#     4
#   )
#
# 規則：
#   消耗來源碎片4枚
#   取得目標碎片1枚
#   目標譜系必須已完成首次汲取
#   來源與目標不可相同
#
# 注意：
#   amount小於4時，腳本仍會強制使用4。
#
# 【Quest 27：碎片回收】
#   fs_econ_recycle_fragments(offset, 6)
#
# 規則：
#   消耗同譜系碎片至少6枚
#   取得1份製作抵用
#   下一次鍛造或調律費用減1000G
#
# 注意：
#   amount小於6時，腳本仍會強制使用6。
#
# 【Quest 29分支2：記憶重構】
#   fs_econ_reconstruct_special_core(ActorID)
#
# Actor ID：
#   2：米亞，取得Item 800
#   3：艾卓，取得Item 801
#   4：維娜，取得Item 802
#   5：艾薇，取得Item 803
#   6：泰勒，取得Item 804
#
# 代價：
#   製作抵用×2
#   基礎費用4000G
#   記憶重構路線的20%折扣會套用
#   Quest 25的10%折扣也會套用
#
# ==============================================================================
# ■ 15. FS指令：情報與測試報告
# ==============================================================================
#
# 【敵人經濟情報】
#   fs_econ_enemy_intel(EnemyID)
#
# 需要：
#   Quest 28完成
#
# 顯示：
#   敵人名稱
#   對應碎片
#   固定掉落
#   追加機率與數量
#   重複汲取獎勵
#   對應鳴刻冠
#   製作費
#
# 【查詢敵人掉落陣列】
#   fs_drop_profile(EnemyID)
#
# 回傳：
#   [固定數, 追加機率, 追加數]
#
# 該指令本身不顯示訊息，主要供條件與測試使用。
#
# 【輸出經濟稽核】
#   fs_econ_write_audit
#
# 輸出：
#   FS_Economy_Audit_Report.txt
#
# 【魂刻說明重新統一】
#   fs_soul_terminology_refresh
#
# 【魂刻名稱報告】
#   fs_soul_terminology_report
#
# 輸出：
#   FS_Soul_Terminology_Report.txt
#
# 【商店全隊報告】
#   fs_shop_party_report
#
# 輸出：
#   FS_Shop_Party_Report.txt
#
# 【鳴刻冠開場技能目標報告】
#   fs_opening_target_report
#
# 輸出：
#   FS_OpeningSkill_Target_Report.txt
#
# 【Quest 29分支查詢】
#   fs_econ_quest29_branch
#
# ==============================================================================
# ■ 16. 合成場景與製作服務
# ==============================================================================
#
# 合成場景是正式選單：
#   $scene = Sword_Synthesize.new
#
# 鍛造、調律、碎片交換、碎片回收、敵人情報目前是後端事件指令。
# 目前沒有自動列出66條譜系的通用服務選單。
#
# 正式事件製作有三種方法：
#
# 方法A：固定商品／譜系NPC
#   每個地區只列出4～8個當地譜系。
#   最容易製作，也最適合玩家理解。
#
# 方法B：依目前裝備處理
#   鍛造師直接鍛造喬伊目前裝備的鳴刻冠。
#   調律師直接調律目前裝備。
#
# 方法C：自行製作分頁選單
#   使用多層「顯示選項」，按地區／譜系分類。
#   66條全部列出會很長，但不需要新腳本。
#
# 不要在正式遊戲讓玩家輸入Armor ID或offset。
# 數字輸入只適合開發測試，玩家沒有義務背資料庫。
#
# ==============================================================================
# ■ 17. 回傳值與條件分歧
# ==============================================================================
#
# 多數服務會自動顯示結果文字，並回傳Symbol。
#
# 常見回傳：
#   :success
#     成功
#
#   :locked
#     尚未解鎖
#
#   :invalid
#     ID、offset或分支無效
#
#   :not_owned
#     沒有持有裝備
#
#   :max_level
#     已達鍛造+2
#
#   :material_short
#     材料不足
#
#   :gold_short
#     金錢不足
#
#   :already
#     已領取／已完成
#
#   :empty
#     沒有可用譜系或商品
#
# 條件分歧範例：
#   條件分歧 → 腳本：
#
#     fs_econ_unlocked?(:nameless_tuning)
#
# ==============================================================================
# ■ 18. Quest 20「空著的第七張椅子」
# ==============================================================================
#
# 【正式資料】
#   委託人：拓荒營地紀錄官
#   地點：拓荒營地／南側巡邏路線
#   建議Lv：3
#
# 目標0：找到第七名巡衛的下落
# 目標1：檢查南側巡邏路線
# 目標2：跟隨遺留的繩結
# 目標3：決定如何處理巡衛的失職
# 目標4：回報營地紀錄官
#
# 報酬：
#   魯卡商店折扣10%
#   300G
#   120EXP
#
# 【建議事件】
#   EV_Q20_紀錄官
#   EV_Q20_第七張椅子
#   EV_Q20_巡邏起點
#   EV_Q20_繩結01
#   EV_Q20_繩結02
#   EV_Q20_繩結03
#   EV_Q20_第七巡衛
#
# 【建議Variable】
#   Q20_繩結數
#   Q20_巡衛裁定
#     1：如實回報
#     2：替巡衛隱瞞
#
# 【紀錄官事件】
#   條件：Action Button
#
#   若 quest_rewarded?(20)
#     顯示完成後對話
#
#   否則若 !quest_revealed?(20)
#     顯示委託說明
#     選項：接受／暫不接受
#
#     接受：
#       reveal_quest(20)
#       reveal_objective(20, 0)
#       conceal_objective(20, 1, 2, 3, 4)
#
#   否則若 objective_complete?(20, 3)
#     依Variable「Q20_巡衛裁定」顯示不同回報對話
#     complete_objective(20, 4)
#     fs_econ_complete_quest(20)
#
#   否則
#     顯示目前進度提示
#
# 【第七張椅子／名冊】
#   僅在quest_revealed?(20)且目標0未完成時有效。
#
#   調查後：
#     顯示名冊：
#       第七名巡衛最後前往南側巡邏路線。
#     complete_objective(20, 0)
#     reveal_objective(20, 1)
#     Self Switch A = ON
#
# 【巡邏起點】
#   條件：
#     objective_complete?(20, 0)
#     !objective_complete?(20, 1)
#
#   內容：
#     檢查足跡、折斷標記、拖行痕跡。
#     complete_objective(20, 1)
#     reveal_objective(20, 2)
#     Variable「Q20_繩結數」= 0
#
# 【三個繩結事件】
#   Page 1：
#     若objective_complete?(20, 1)
#       顯示調查文字
#       Variable「Q20_繩結數」 += 1
#       Self Switch A = ON
#
#       若Variable >= 3
#         complete_objective(20, 2)
#         reveal_objective(20, 3)
#
#   Page 2：
#     Self Switch A
#     顯示已調查圖或空事件
#
# 【第七巡衛事件】
#   條件：
#     objective_complete?(20, 2)
#     !objective_complete?(20, 3)
#
#   對話後選項：
#     如實回報
#     隱瞞失職原因
#
#   第一項：
#     Q20_巡衛裁定 = 1
#
#   第二項：
#     Q20_巡衛裁定 = 2
#
#   完成：
#     complete_objective(20, 3)
#     reveal_objective(20, 4)
#
# 【報酬驗證】
#   完成前：
#     開fs_open_region_shop(:luka)
#     記錄價格
#
#   完成後：
#     再開同商店
#     應折扣10%
#
# ==============================================================================
# ■ 19. Quest 21「借來的名字」
# ==============================================================================
#
# 【正式資料】
#   委託人：等待朋友的孩子
#   地點：魯卡村近郊
#   建議Lv：4
#
# 目標0：調查孩子所稱的朋友
# 目標1：找出無名魂刻留下的記憶
# 目標2：決定是否讓孩子替它命名
# 目標3：回到孩子身邊
#
# 報酬：
#   新譜系第一次碎片+1
#   150G
#   150EXP
#
# 【建議事件】
#   EV_Q21_孩子
#   EV_Q21_朋友出現點
#   EV_Q21_記憶碎片01～03
#   EV_Q21_無名魂刻核心
#
# 【建議Variable】
#   Q21_記憶碎片數
#   Q21_命名選擇
#     1：讓孩子命名
#     2：保留無名
#
# 【孩子事件】
#   接受時：
#     reveal_quest(21)
#     reveal_objective(21, 0)
#     conceal_objective(21, 1, 2, 3)
#
#   最終回來時：
#     若objective_complete?(21, 2)
#       依命名選擇顯示不同對話
#       complete_objective(21, 3)
#       fs_econ_complete_quest(21)
#
# 【朋友出現點】
#   可使用：
#     透明事件
#     閃光動畫
#     音效
#     對話位置提示
#
#   調查後：
#     complete_objective(21, 0)
#     reveal_objective(21, 1)
#     Q21_記憶碎片數 = 0
#
# 【三個記憶碎片事件】
#   不需要新增資料庫Item。
#   使用Variable與Self Switch即可。
#
#   每個事件：
#     Variable += 1
#     Self Switch A = ON
#
#   第三個：
#     complete_objective(21, 1)
#     reveal_objective(21, 2)
#
# 【無名魂刻核心】
#   條件：
#     objective_complete?(21, 1)
#
#   選項：
#     讓孩子替它命名
#     保留無名記憶
#
#   記錄Variable。
#   complete_objective(21, 2)
#   reveal_objective(21, 3)
#
# 【報酬驗證】
#   完成Quest 21後，首次汲取一條從未取得的譜系。
#
#   預期：
#     完整魂刻×1
#     碎片×3
#
#   注意：
#     不是所有首次汲取都再加3。
#     原本2枚，Quest 21追加1枚。
#
# ==============================================================================
# ■ 20. Quest 22「第十三根界樁」
# ==============================================================================
#
# 【正式資料】
#   委託人：拓荒隊測量員
#   地點：拓荒營地外圍
#   建議Lv：8
#
# 目標0：尋找失蹤的第十三根界樁
# 目標1：調查遷徙獸群的路線
# 目標2：修復或移動界樁
# 目標3：向拓荒隊回報
#
# 報酬：
#   碎片4比1交換權
#   400G
#   220EXP
#
# 【建議事件】
#   EV_Q22_測量員
#   EV_Q22_界樁殘坑
#   EV_Q22_足跡01～03
#   EV_Q22_倒下的界樁
#   EV_Q22_碎片交換員
#
# 【建議Variable】
#   Q22_足跡數
#   Q22_界樁處置
#     1：修回原位
#     2：移到遷徙路線外
#
# 【測量員】
#   接受：
#     reveal_quest(22)
#     reveal_objective(22, 0)
#     conceal_objective(22, 1, 2, 3)
#
#   回報：
#     若objective_complete?(22, 2)
#       complete_objective(22, 3)
#       fs_econ_complete_quest(22)
#
# 【界樁殘坑】
#   顯示木屑與拖痕。
#   complete_objective(22, 0)
#   reveal_objective(22, 1)
#
# 【足跡事件】
#   每個只增加一次：
#     Q22_足跡數 += 1
#     Self Switch A = ON
#
#   達3：
#     complete_objective(22, 1)
#     reveal_objective(22, 2)
#
# 【倒下界樁】
#   選項：
#     修回原位
#     移到獸群路線之外
#
#   設定Q22_界樁處置。
#   播放移動路線、音效或動畫。
#   complete_objective(22, 2)
#   reveal_objective(22, 3)
#
# 【交換服務】
#   完成後，交換員事件：
#
#     若fs_econ_unlocked?(:migration_route)
#       顯示交換選項
#     否則
#       顯示尚未開放
#
#   範例：
#     草蛙4換火蜥1
#       fs_econ_exchange_fragments(0, 1, 4)
#
#     火蜥4換沼螈1
#       fs_econ_exchange_fragments(1, 2, 4)
#
#   目標譜系必須已首次汲取。
#   正式遊戲建議每區只提供當地常見譜系，不要叫玩家輸入offset。
#
# ==============================================================================
# ■ 21. Quest 23「夜班不點名」
# ==============================================================================
#
# 【正式資料】
#   委託人：拓荒營地值勤官
#   地點：拓荒營地夜間區域
#   建議Lv：10
#
# 目標0：代替夜班人員巡查營地
# 目標1：檢查沒有回應的三處燈塔
# 目標2：找出失蹤人員
# 目標3：將夜班紀錄交回
#
# 報酬：
#   每章一次碎片補給
#   450G
#   250EXP
#
# 【建議事件】
#   EV_Q23_值勤官
#   EV_Q23_夜班簽到板
#   EV_Q23_燈塔01～03
#   EV_Q23_失蹤值勤員
#   EV_Q23_補給箱
#
# 【建議Variable／Switch】
#   Q23_燈塔數
#   SW_Q23_夜巡中
#
# 【值勤官接受】
#   reveal_quest(23)
#   reveal_objective(23, 0)
#   conceal_objective(23, 1, 2, 3)
#
# 【夜班簽到板】
#   玩家選擇「開始巡查」。
#
#   事件工具：
#     畫面色調變暗
#     切換夜間BGM／BGS
#     SW_Q23_夜巡中 = ON
#
#   complete_objective(23, 0)
#   reveal_objective(23, 1)
#   Q23_燈塔數 = 0
#
# 【三座燈塔】
#   Event Page條件：
#     SW_Q23_夜巡中 = ON
#
#   每座：
#     播放檢查動畫
#     Variable += 1
#     Self Switch A = ON
#
#   達3：
#     complete_objective(23, 1)
#     reveal_objective(23, 2)
#
# 【失蹤人員】
#   條件：
#     objective_complete?(23, 1)
#
#   可設計：
#     護送
#     小型戰鬥
#     解毒
#     對話選項
#
#   完成：
#     complete_objective(23, 2)
#     reveal_objective(23, 3)
#
# 【回報】
#   值勤官：
#     complete_objective(23, 3)
#     fs_econ_complete_quest(23)
#     SW_Q23_夜巡中 = OFF
#     恢復畫面色調與BGM
#
# 【夜班補給箱】
#   條件：
#     fs_econ_unlocked?(:night_supply)
#
#   互動：
#     fs_econ_claim_night_supply
#
#   每章一次。
#   會從已首次汲取譜系中隨機給3枚碎片。
#
#   主線章節切換時必須呼叫：
#     fs_econ_set_chapter(章節值)
#
# ==============================================================================
# ■ 22. Quest 24「不會響的鐵砧」
# ==============================================================================
#
# 【正式資料】
#   委託人：哈貝爾工坊主人
#   地點：哈貝爾矮人村
#   建議Lv：17
#
# 目標0：調查不會響的鐵砧
# 目標1：尋找缺失的鍛造材料
# 目標2：修復鐵砧的共鳴結構
# 目標3：回報工坊主人
#
# 報酬：
#   鍛造服務
#   哈貝爾折扣10%
#   800G
#   450EXP
#
# 【建議事件】
#   EV_Q24_工坊主人
#   EV_Q24_沉默鐵砧
#   EV_Q24_材料節點01～03
#   EV_Q24_風箱
#   EV_Q24_冷卻槽
#   EV_Q24_鍛造服務
#
# 【建議Variable】
#   Q24_材料數
#   Q24_修復步驟
#
# 【沉默鐵砧】
#   調查：
#     complete_objective(24, 0)
#     reveal_objective(24, 1)
#     Q24_材料數 = 0
#
# 【材料節點】
#   不必新增Item 900以上的任務物件。
#   使用Variable＋Self Switch。
#
#   每個：
#     Q24_材料數 += 1
#     Self Switch A = ON
#
#   達3：
#     complete_objective(24, 1)
#     reveal_objective(24, 2)
#
# 【共鳴修復】
#   建議做成簡單順序：
#     1. 啟動風箱
#     2. 敲擊鐵砧
#     3. 注入冷卻液
#
#   正確順序：
#     Q24_修復步驟從0→1→2→3
#
#   錯誤順序：
#     播放失敗SE
#     Q24_修復步驟 = 0
#
#   完成：
#     播放鐵砧音效
#     complete_objective(24, 2)
#     reveal_objective(24, 3)
#
# 【回報】
#   complete_objective(24, 3)
#   fs_econ_complete_quest(24)
#
# 【鍛造服務NPC】
#   目前後端需要指定裝備ID。
#   建議處理「目前裝備」而不是叫玩家選ID。
#
#   喬伊目前鳴刻冠範例：
#     actor = $game_actors[1]
#     gear = actor.equips.compact.find { |e|
#       e.is_a?(RPG::Armor) && e.id >= 220 && e.id <= 285
#     }
#     if gear
#       fs_econ_forge_headgear(gear.id)
#     else
#       $game_message.texts.push("喬伊目前沒有裝備鳴刻冠。")
#     end
#
#   專屬武器建議：
#     顯示選項：米亞／艾卓／維娜／艾薇／泰勒
#     依角色取得目前武器，再呼叫：
#       fs_econ_forge_special_weapon(武器ID)
#
# 【商店驗證】
#   完成前後分別：
#     fs_open_region_shop(:habel)
#
#   完成後：
#     價格降低10%
#     追加T3武器與防具
#
# ==============================================================================
# ■ 23. Quest 25「第零協議」
# ==============================================================================
#
# 【正式資料】
#   委託人：哈貝爾舊工坊管理員
#   地點：哈貝爾封存工坊
#   建議Lv：19
#
# 目標0：找出第零協議的來源
# 目標1：進入封存工坊
# 目標2：確認機器人的終止命令
# 目標3：選擇保留或刪除協議
# 目標4：將協議記錄帶回
#
# 報酬：
#   鍛造／調律費用-10%
#   900G
#   500EXP
#
# 【建議事件】
#   EV_Q25_管理員
#   EV_Q25_檔案終端01～03
#   EV_Q25_封存工坊門
#   EV_Q25_零號機器人
#   EV_Q25_協議核心
#
# 【建議Variable】
#   Q25_檔案數
#   Q25_協議處置
#     1：保留
#     2：刪除
#
# 【來源調查】
#   三份舊檔案：
#     每份Variable += 1
#     Self Switch A
#
#   達3：
#     complete_objective(25, 0)
#     reveal_objective(25, 1)
#
# 【封存工坊門】
#   條件：
#     objective_complete?(25, 0)
#
#   開門／傳送後：
#     complete_objective(25, 1)
#     reveal_objective(25, 2)
#
# 【零號機器人】
#   調查終止命令。
#   可安排無傷害SBS演出或戰鬥。
#   complete_objective(25, 2)
#   reveal_objective(25, 3)
#
# 【協議核心】
#   選項：
#     保留第零協議
#     刪除第零協議
#
#   設定Variable。
#   complete_objective(25, 3)
#   reveal_objective(25, 4)
#
# 【回報】
#   complete_objective(25, 4)
#   fs_econ_complete_quest(25)
#
# 【目前實作限制】
#   Quest 25目前只解鎖：
#     鍛造／調律費用-10%
#
#   尚未實作：
#     機器人協議設定介面
#     機器人零件拆解
#     戰鬥AI切換
#
#   Variable「Q25_協議處置」仍可供後續劇情使用，
#   但兩個選項目前不改經濟報酬。
#
# ==============================================================================
# ■ 24. Quest 26「被刪去的歌名」
# ==============================================================================
#
# 【正式資料】
#   委託人：尋找舊曲的吟遊者
#   地點：精靈村
#   建議Lv：26
#
# 目標0：尋找被刪去的歌名
# 目標1：調查殘缺的樂譜
# 目標2：從魂刻記憶中拼回旋律
# 目標3：將歌名交給吟遊者
#
# 報酬：
#   調律服務
#   1200G
#   700EXP
#
# 【建議事件】
#   EV_Q26_吟遊者
#   EV_Q26_禁名記錄
#   EV_Q26_樂譜片段01～03
#   EV_Q26_記憶共鳴點
#   EV_Q26_調律服務
#
# 【建議Variable】
#   Q26_樂譜片段數
#
# 【禁名記錄】
#   調查精靈檔案。
#   complete_objective(26, 0)
#   reveal_objective(26, 1)
#
# 【樂譜片段】
#   每個：
#     Variable += 1
#     Self Switch A
#
#   達3：
#     complete_objective(26, 1)
#     reveal_objective(26, 2)
#
# 【記憶共鳴點】
#   建議先檢查喬伊是否裝備完整魂刻。
#
#   條件分歧 → 腳本：
#     $game_actors[1].equips.compact.any? { |e|
#       e.is_a?(RPG::Armor) && e.id >= 600 && e.id <= 665
#     }
#
#   TRUE：
#     播放記憶演出
#     complete_objective(26, 2)
#     reveal_objective(26, 3)
#
#   FALSE：
#     顯示：
#       「需要讓喬伊裝備一枚完整魂刻。」
#
# 【回報】
#   complete_objective(26, 3)
#   fs_econ_complete_quest(26)
#
# 【調律服務NPC】
#   顯示選項：
#     強攻調律
#     共護調律
#     取消
#
#   喬伊目前鳴刻冠：
#     先找目前Armor 220～285
#     再呼叫：
#       fs_econ_tune_headgear(gear.id, :force)
#       fs_econ_tune_headgear(gear.id, :harmony)
#
#   專屬武器：
#     fs_econ_tune_special_weapon(weapon.id, :force)
#     fs_econ_tune_special_weapon(weapon.id, :harmony)
#
# ==============================================================================
# ■ 25. Quest 27「樹梢之下」
# ==============================================================================
#
# 【正式資料】
#   委託人：精靈村守林者
#   地點：精靈村下層根域
#   建議Lv：29
#
# 目標0：調查樹梢下的異常聲響
# 目標1：找到不願離開的守林人
# 目標2：處理被侵蝕的樹根
# 目標3：決定守林人的去留
#
# 報酬：
#   碎片回收服務
#   1200G
#   750EXP
#
# 【建議事件】
#   EV_Q27_守林者
#   EV_Q27_聲響點01～03
#   EV_Q27_失聯守林人
#   EV_Q27_侵蝕樹根
#   EV_Q27_碎片回收祭壇
#
# 【建議Variable】
#   Q27_聲響數
#   Q27_守林人去留
#     1：勸離
#     2：允許留下
#
# 【聲響點】
#   三處調查：
#     Variable += 1
#     Self Switch A
#
#   達3：
#     complete_objective(27, 0)
#     reveal_objective(27, 1)
#
# 【守林人】
#   找到後：
#     complete_objective(27, 1)
#     reveal_objective(27, 2)
#
# 【侵蝕樹根】
#   可設計：
#     小Boss戰
#     屬性互動
#     淨化事件
#     魂刻技能檢查
#
#   完成：
#     complete_objective(27, 2)
#     reveal_objective(27, 3)
#
# 【去留選擇】
#   選項：
#     勸守林人離開
#     讓守林人留下
#
#   設定Variable。
#   complete_objective(27, 3)
#   fs_econ_complete_quest(27)
#
#   本任務最後一個目標就是選擇，因此可在現場直接完成，
#   不必強迫玩家再跑回村口一次。
#
# 【碎片回收祭壇】
#   固定譜系範例：
#     fs_econ_recycle_fragments(0, 6)
#
#   成功後：
#     得到1份製作抵用
#
#   下一次鍛造／調律成功時：
#     費用減1000G
#     抵用自動消耗
#
#   目前沒有66譜系通用選單。
#   建議按地區列出常見譜系，或做多層選項。
#
# ==============================================================================
# ■ 26. Quest 28「完美證詞」
# ==============================================================================
#
# 【正式資料】
#   委託人：主城調查官
#   地點：主城
#   建議Lv：36
#
# 目標0：收集三份互相矛盾的證詞
# 目標1：檢查全知儀留下的紀錄
# 目標2：找出被修改的部分
# 目標3：確認真正的事件經過
# 目標4：公開或封存真相
#
# 報酬：
#   異常經濟紀錄權限
#   1800G
#   1000EXP
#
# 【建議事件】
#   EV_Q28_調查官
#   EV_Q28_證人A
#   EV_Q28_證人B
#   EV_Q28_證人C
#   EV_Q28_全知儀
#   EV_Q28_修改紀錄
#   EV_Q28_真正現場
#   EV_Q28_情報終端
#
# 【建議Variable】
#   Q28_證詞數
#   Q28_真相處置
#     1：公開
#     2：封存
#
# 【三名證人】
#   每名第一次對話：
#     Q28_證詞數 += 1
#     Self Switch A
#
#   達3：
#     complete_objective(28, 0)
#     reveal_objective(28, 1)
#
# 【全知儀】
#   條件：
#     objective_complete?(28, 0)
#
#   播放紀錄。
#   complete_objective(28, 1)
#   reveal_objective(28, 2)
#
# 【被修改部分】
#   可設計：
#     三段紀錄比對
#     選項找矛盾
#     調查時間戳記
#     物件位置差異
#
#   答對：
#     complete_objective(28, 2)
#     reveal_objective(28, 3)
#
# 【真正現場】
#   可安排：
#     追查NPC
#     潛入
#     戰鬥
#     全知儀還原動畫
#
#   complete_objective(28, 3)
#   reveal_objective(28, 4)
#
# 【公開或封存】
#   設定Q28_真相處置。
#   complete_objective(28, 4)
#   fs_econ_complete_quest(28)
#
#   目前兩個選項報酬相同。
#   Variable可供主城後續對話與結局差異使用。
#
# 【情報終端】
#   完成後：
#     fs_econ_enemy_intel(EnemyID)
#
#   例：
#     fs_econ_enemy_intel(600)
#
#   目前沒有從敵譜游標直接呼叫的整合UI。
#   事件終端可先提供固定敵人清單。
#
# ==============================================================================
# ■ 27. Quest 29「一段記憶的價錢」
# ==============================================================================
#
# 【正式資料】
#   委託人：匿名委託
#   地點：主城地下拍賣會
#   建議Lv：40
#
# 通用目標：
#   0：接觸記憶拍賣會
#   1：找出被販售記憶的來源
#   2：追查買家與仲介
#   3：決定如何處理記憶庫
#   4：離開黑市
#
# 分支1完成後顯示：
#   保留地下拍賣會的黑市名冊
#   帶著黑市名冊離開地下拍賣會
#
# 分支2完成後顯示：
#   焚毀地下拍賣會的記憶庫
#   帶著記憶灰燼離開地下拍賣會
#
# 【建議事件】
#   EV_Q29_匿名聯絡人
#   EV_Q29_拍賣入口
#   EV_Q29_拍賣品01～03
#   EV_Q29_買家
#   EV_Q29_仲介
#   EV_Q29_記憶庫
#   EV_Q29_出口
#   EV_Q29_黑市商人
#   EV_Q29_記憶重構師
#
# 【建議Variable】
#   Q29_拍賣品數
#   Q29_追查數
#   Q29_記憶庫分支
#     1：保留名冊
#     2：焚毀記憶庫
#
# 【匿名聯絡人】
#   接受：
#     reveal_quest(29)
#     reveal_objective(29, 0)
#     conceal_objective(29, 1, 2, 3, 4)
#
# 【拍賣入口】
#   進場後：
#     complete_objective(29, 0)
#     reveal_objective(29, 1)
#
# 【拍賣品】
#   三份被販售記憶：
#     Variable += 1
#     Self Switch A
#
#   達3：
#     complete_objective(29, 1)
#     reveal_objective(29, 2)
#
# 【買家與仲介】
#   分別調查：
#     Q29_追查數 += 1
#
#   達2：
#     complete_objective(29, 2)
#     reveal_objective(29, 3)
#
# 【記憶庫選擇】
#   選項：
#     保留黑市名冊
#     焚毀記憶庫
#
#   第一項：
#     Q29_記憶庫分支 = 1
#
#   第二項：
#     Q29_記憶庫分支 = 2
#     播放火焰／崩解動畫
#
#   完成：
#     complete_objective(29, 3)
#     reveal_objective(29, 4)
#
# 【出口】
#   只有在objective_complete?(29, 3)後發獎。
#
#   若Q29_記憶庫分支 == 1
#     complete_objective(29, 4)
#     fs_econ_complete_quest(29, 1)
#
#   否則若 == 2
#     complete_objective(29, 4)
#     fs_econ_complete_quest(29, 2)
#
#   注意：
#     不要在記憶庫選擇當下就呼叫fs_econ_complete_quest。
#     該指令會把任務直接標成全部完成。
#
# 【分支1後續】
#   黑市NPC：
#     fs_open_black_market
#
#   章節變更：
#     fs_econ_set_chapter(新章節)
#     黑市庫存刷新
#
# 【分支2後續】
#   先透過Quest 27回收碎片取得2份製作抵用。
#   記憶重構：
#
#     fs_econ_reconstruct_special_core(2)
#     fs_econ_reconstruct_special_core(3)
#     fs_econ_reconstruct_special_core(4)
#     fs_econ_reconstruct_special_core(5)
#     fs_econ_reconstruct_special_core(6)
#
#   免費重調律：
#     只在已經有調律分支、再次改調律時生效。
#     金錢變為0，但材料仍會消耗。
#
# 【分支驗證】
#   fs_econ_quest29_branch
#
# ==============================================================================
# ■ 28. 碎片交換NPC完整頁面
# ==============================================================================
#
# 目前後端沒有自動列66條譜系的選單。
#
# 建議按區域製作：
#   魯卡交換員：offset 0～10
#   拓荒交換員：offset 11～25
#   哈貝爾交換員：offset 26～40
#   精靈村交換員：offset 41～55
#   主城交換員：offset 56～65
#
# 事件開頭：
#   條件分歧 → 腳本：
#     fs_econ_unlocked?(:migration_route)
#
# FALSE：
#   顯示「尚未建立遷徙交換路線。」
#
# TRUE：
#   顯示多層選項。
#   每一條交換直接呼叫：
#
#     fs_econ_exchange_fragments(來源, 目標, 4)
#
# 目標譜系未知時，腳本會回傳:invalid。
#
# ==============================================================================
# ■ 29. 鍛造NPC完整頁面
# ==============================================================================
#
# 事件開頭：
#   條件分歧：
#     fs_econ_unlocked?(:habel_forging)
#
# FALSE：
#   顯示尚未解鎖。
#
# TRUE：
#   選項：
#     鍛造喬伊目前鳴刻冠
#     鍛造米亞目前專屬武器
#     鍛造艾卓目前專屬武器
#     鍛造維娜目前專屬武器
#     下一頁
#     取消
#
# 喬伊：
#   取得目前Armor 220～285。
#   呼叫fs_econ_forge_headgear。
#
# 其他角色：
#   取得目前Weapon 266～275。
#   呼叫fs_econ_forge_special_weapon。
#
# 若沒有裝備指定種類：
#   顯示提示，不呼叫服務。
#
# ==============================================================================
# ■ 30. 調律NPC完整頁面
# ==============================================================================
#
# 事件開頭：
#   fs_econ_unlocked?(:nameless_tuning)
#
# 選擇裝備後，再選：
#   強攻調律
#   共護調律
#   取消
#
# 鳴刻冠：
#   fs_econ_tune_headgear(ID, :force)
#   fs_econ_tune_headgear(ID, :harmony)
#
# 專屬武器：
#   fs_econ_tune_special_weapon(ID, :force)
#   fs_econ_tune_special_weapon(ID, :harmony)
#
# 改調律會消耗更多材料。
# Quest 29分支2的免費重調律只免金錢，不免材料。
#
# ==============================================================================
# ■ 31. 夜班補給NPC
# ==============================================================================
#
# 事件：
#   fs_econ_claim_night_supply
#
# 不必自行判斷章節是否領過。
# 腳本會顯示：
#   成功
#   本章已領
#   尚無已收錄譜系
#   尚未解鎖
#
# 主線每次真正進入新章時：
#   fs_econ_set_chapter(章節)
#
# 不要在每次進地圖時反覆設成不同值。
#
# ==============================================================================
# ■ 32. 情報查詢NPC
# ==============================================================================
#
# 事件開頭：
#   fs_econ_unlocked?(:anomaly_record_access)
#
# FALSE：
#   顯示權限不足。
#
# TRUE：
#   顯示敵人分類選項。
#   每個選項呼叫：
#     fs_econ_enemy_intel(EnemyID)
#
# 目前指令需要資料庫Enemy ID。
# 正式介面若要直接接EnemyBook游標，需要另寫整合，不在現行腳本範圍內。
#
# ==============================================================================
# ■ 33. 黑市與記憶重構NPC
# ==============================================================================
#
# 【黑市商人】
#   fs_open_black_market
#
# 腳本會自行判斷：
#   權限
#   是否有已收錄譜系
#   每章剩餘庫存
#
# 【記憶重構師】
#   條件：
#     fs_econ_unlocked?(:memory_reconstruction)
#
# 選項：
#   重構米亞特別殘響
#   重構艾卓特別殘響
#   重構維娜特別殘響
#   重構艾薇特別殘響
#   重構泰勒特別殘響
#
# 指令：
#   fs_econ_reconstruct_special_core(2～6)
#
# ==============================================================================
# ■ 34. 完整測試順序
# ==============================================================================
#
# 【A. 新遊戲】
#   不支援以舊存檔作正式驗證。
#
# 【B. 配方】
#   fs_econ_sync_recipes
#   fs_econ_write_audit
#
# 確認：
#   Weapon 200～265無配方
#   Armor 220～285有配方
#   Weapon 266～275有配方
#
# 【C. Quest Journal】
#   接Quest 20。
#   確認只顯示目標0。
#   每完成一步，下一個目標才出現。
#
# 【D. 報酬】
#   Quest最終事件只呼叫一次fs_econ_complete_quest。
#   確認金錢、EXP、服務各只給一次。
#
# 【E. 任務服務】
#   Q20：魯卡折扣
#   Q21：新譜系首次碎片+1
#   Q22：4換1
#   Q23：每章3碎片
#   Q24：鍛造、哈貝爾折扣與高階商品
#   Q25：服務費-10%
#   Q26：調律
#   Q27：碎片回收與-1000G抵用
#   Q28：敵人情報
#   Q29-1：黑市
#   Q29-2：記憶重構、-20%、免費重調律
#
# 【F. 分支】
#   Quest 29兩分支用兩個新遊戲測試。
#   同一存檔不能同時解鎖黑市與記憶重構。
#
# 【G. 報告】
#   fs_econ_write_audit
#   fs_soul_terminology_report
#   fs_shop_party_report
#   fs_opening_target_report
#
# ==============================================================================
# ■ Appendix A：66條譜系offset對照
# ==============================================================================
#
#   offset 00：草蛙
#     殘響 Item 200
#     碎片 Item 600
#     鳴刻冠 Armor 220
#     完整魂刻 Armor 600
#
#   offset 01：火蜥
#     殘響 Item 201
#     碎片 Item 601
#     鳴刻冠 Armor 221
#     完整魂刻 Armor 601
#
#   offset 02：沼螈
#     殘響 Item 202
#     碎片 Item 602
#     鳴刻冠 Armor 222
#     完整魂刻 Armor 602
#
#   offset 03：幻蝶
#     殘響 Item 203
#     碎片 Item 603
#     鳴刻冠 Armor 223
#     完整魂刻 Armor 603
#
#   offset 04：疾蜂
#     殘響 Item 204
#     碎片 Item 604
#     鳴刻冠 Armor 224
#     完整魂刻 Armor 604
#
#   offset 05：比雕
#     殘響 Item 205
#     碎片 Item 605
#     鳴刻冠 Armor 225
#     完整魂刻 Armor 605
#
#   offset 06：喵齒
#     殘響 Item 206
#     碎片 Item 606
#     鳴刻冠 Armor 226
#     完整魂刻 Armor 606
#
#   offset 07：山雀
#     殘響 Item 207
#     碎片 Item 607
#     鳴刻冠 Armor 227
#     完整魂刻 Armor 607
#
#   offset 08：毒涎
#     殘響 Item 208
#     碎片 Item 608
#     鳴刻冠 Armor 228
#     完整魂刻 Armor 608
#
#   offset 09：伏特
#     殘響 Item 209
#     碎片 Item 609
#     鳴刻冠 Armor 229
#     完整魂刻 Armor 609
#
#   offset 10：岩鼠
#     殘響 Item 210
#     碎片 Item 610
#     鳴刻冠 Armor 230
#     完整魂刻 Armor 610
#
#   offset 11：妖狐
#     殘響 Item 211
#     碎片 Item 611
#     鳴刻冠 Armor 231
#     完整魂刻 Armor 611
#
#   offset 12：粉球
#     殘響 Item 212
#     碎片 Item 612
#     鳴刻冠 Armor 232
#     完整魂刻 Armor 612
#
#   offset 13：音蝠
#     殘響 Item 213
#     碎片 Item 613
#     鳴刻冠 Armor 233
#     完整魂刻 Armor 613
#
#   offset 14：植根
#     殘響 Item 214
#     碎片 Item 614
#     鳴刻冠 Armor 234
#     完整魂刻 Armor 614
#
#   offset 15：蟲草
#     殘響 Item 215
#     碎片 Item 615
#     鳴刻冠 Armor 235
#     完整魂刻 Armor 615
#
#   offset 16：夜蛾
#     殘響 Item 216
#     碎片 Item 616
#     鳴刻冠 Armor 236
#     完整魂刻 Armor 616
#
#   offset 17：水鴨
#     殘響 Item 217
#     碎片 Item 617
#     鳴刻冠 Armor 237
#     完整魂刻 Armor 617
#
#   offset 18：潑猴
#     殘響 Item 218
#     碎片 Item 618
#     鳴刻冠 Armor 238
#     完整魂刻 Armor 618
#
#   offset 19：風炎
#     殘響 Item 219
#     碎片 Item 619
#     鳴刻冠 Armor 239
#     完整魂刻 Armor 619
#
#   offset 20：勇蛙
#     殘響 Item 220
#     碎片 Item 620
#     鳴刻冠 Armor 240
#     完整魂刻 Armor 620
#
#   offset 21：隱士
#     殘響 Item 221
#     碎片 Item 621
#     鳴刻冠 Armor 241
#     完整魂刻 Armor 621
#
#   offset 22：豪俠
#     殘響 Item 222
#     碎片 Item 622
#     鳴刻冠 Armor 242
#     完整魂刻 Armor 622
#
#   offset 23：瑪瑙
#     殘響 Item 223
#     碎片 Item 623
#     鳴刻冠 Armor 243
#     完整魂刻 Armor 623
#
#   offset 24：滾石
#     殘響 Item 224
#     碎片 Item 624
#     鳴刻冠 Armor 244
#     完整魂刻 Armor 624
#
#   offset 25：炎駒
#     殘響 Item 225
#     碎片 Item 625
#     鳴刻冠 Armor 245
#     完整魂刻 Armor 625
#
#   offset 26：磁場
#     殘響 Item 226
#     碎片 Item 626
#     鳴刻冠 Armor 246
#     完整魂刻 Armor 626
#
#   offset 27：疾走
#     殘響 Item 227
#     碎片 Item 627
#     鳴刻冠 Armor 247
#     完整魂刻 Armor 627
#
#   offset 28：汙泥
#     殘響 Item 228
#     碎片 Item 628
#     鳴刻冠 Armor 248
#     完整魂刻 Armor 628
#
#   offset 29：幽魂
#     殘響 Item 229
#     碎片 Item 629
#     鳴刻冠 Armor 249
#     完整魂刻 Armor 629
#
#   offset 30：夜縛
#     殘響 Item 230
#     碎片 Item 630
#     鳴刻冠 Armor 250
#     完整魂刻 Armor 630
#
#   offset 31：雷彈
#     殘響 Item 231
#     碎片 Item 631
#     鳴刻冠 Armor 251
#     完整魂刻 Armor 631
#
#   offset 32：骨獸
#     殘響 Item 232
#     碎片 Item 632
#     鳴刻冠 Armor 252
#     完整魂刻 Armor 632
#
#   offset 33：菊石
#     殘響 Item 233
#     碎片 Item 633
#     鳴刻冠 Armor 253
#     完整魂刻 Armor 633
#
#   offset 34：石盔
#     殘響 Item 234
#     碎片 Item 634
#     鳴刻冠 Armor 254
#     完整魂刻 Armor 634
#
#   offset 35：超夢
#     殘響 Item 235
#     碎片 Item 635
#     鳴刻冠 Armor 255
#     完整魂刻 Armor 635
#
#   offset 36：夢幻
#     殘響 Item 236
#     碎片 Item 636
#     鳴刻冠 Armor 256
#     完整魂刻 Armor 636
#
#   offset 37：尾立
#     殘響 Item 237
#     碎片 Item 637
#     鳴刻冠 Armor 257
#     完整魂刻 Armor 637
#
#   offset 38：蛛網
#     殘響 Item 238
#     碎片 Item 638
#     鳴刻冠 Armor 258
#     完整魂刻 Armor 638
#
#   offset 39：天祐
#     殘響 Item 239
#     碎片 Item 639
#     鳴刻冠 Armor 259
#     完整魂刻 Armor 639
#
#   offset 40：夢噬
#     殘響 Item 240
#     碎片 Item 640
#     鳴刻冠 Armor 260
#     完整魂刻 Armor 640
#
#   offset 41：守護
#     殘響 Item 241
#     碎片 Item 641
#     鳴刻冠 Armor 261
#     完整魂刻 Armor 641
#
#   offset 42：輔雷
#     殘響 Item 242
#     碎片 Item 642
#     鳴刻冠 Armor 262
#     完整魂刻 Armor 642
#
#   offset 43：燃燼
#     殘響 Item 243
#     碎片 Item 643
#     鳴刻冠 Armor 263
#     完整魂刻 Armor 643
#
#   offset 44：水蘊
#     殘響 Item 244
#     碎片 Item 644
#     鳴刻冠 Armor 264
#     完整魂刻 Armor 644
#
#   offset 45：甲獸
#     殘響 Item 245
#     碎片 Item 645
#     鳴刻冠 Armor 265
#     完整魂刻 Armor 645
#
#   offset 46：舞蓮
#     殘響 Item 246
#     碎片 Item 646
#     鳴刻冠 Armor 266
#     完整魂刻 Armor 646
#
#   offset 47：天翁
#     殘響 Item 247
#     碎片 Item 647
#     鳴刻冠 Armor 267
#     完整魂刻 Armor 647
#
#   offset 48：力士
#     殘響 Item 248
#     碎片 Item 648
#     鳴刻冠 Armor 268
#     完整魂刻 Armor 648
#
#   offset 49：鋼顎
#     殘響 Item 249
#     碎片 Item 649
#     鳴刻冠 Armor 269
#     完整魂刻 Armor 649
#
#   offset 50：鐵塔
#     殘響 Item 250
#     碎片 Item 650
#     鳴刻冠 Armor 270
#     完整魂刻 Armor 650
#
#   offset 51：海牙
#     殘響 Item 251
#     碎片 Item 651
#     鳴刻冠 Armor 271
#     完整魂刻 Armor 651
#
#   offset 52：平息
#     殘響 Item 252
#     碎片 Item 652
#     鳴刻冠 Armor 272
#     完整魂刻 Armor 652
#
#   offset 53：夜靈
#     殘響 Item 253
#     碎片 Item 653
#     鳴刻冠 Armor 273
#     完整魂刻 Armor 653
#
#   offset 54：先兆
#     殘響 Item 254
#     碎片 Item 654
#     鳴刻冠 Armor 274
#     完整魂刻 Armor 654
#
#   offset 55：血月
#     殘響 Item 255
#     碎片 Item 655
#     鳴刻冠 Armor 275
#     完整魂刻 Armor 655
#
#   offset 56：智能
#     殘響 Item 256
#     碎片 Item 656
#     鳴刻冠 Armor 276
#     完整魂刻 Armor 656
#
#   offset 57：冰晶
#     殘響 Item 257
#     碎片 Item 657
#     鳴刻冠 Armor 277
#     完整魂刻 Armor 657
#
#   offset 58：狂暴
#     殘響 Item 258
#     碎片 Item 658
#     鳴刻冠 Armor 278
#     完整魂刻 Armor 658
#
#   offset 59：海燈
#     殘響 Item 259
#     碎片 Item 659
#     鳴刻冠 Armor 279
#     完整魂刻 Armor 659
#
#   offset 60：森果
#     殘響 Item 260
#     碎片 Item 660
#     鳴刻冠 Armor 280
#     完整魂刻 Armor 660
#
#   offset 61：陸鯊
#     殘響 Item 261
#     碎片 Item 661
#     鳴刻冠 Armor 281
#     完整魂刻 Armor 661
#
#   offset 62：巨角
#     殘響 Item 262
#     碎片 Item 662
#     鳴刻冠 Armor 282
#     完整魂刻 Armor 662
#
#   offset 63：獄炎
#     殘響 Item 263
#     碎片 Item 663
#     鳴刻冠 Armor 283
#     完整魂刻 Armor 663
#
#   offset 64：鐵堡
#     殘響 Item 264
#     碎片 Item 664
#     鳴刻冠 Armor 284
#     完整魂刻 Armor 664
#
#   offset 65：安定
#     殘響 Item 265
#     碎片 Item 665
#     鳴刻冠 Armor 285
#     完整魂刻 Armor 665
#
#
# ==============================================================================
# ■ Appendix B：不要再使用的舊內容
# ==============================================================================
#
# 不要使用：
#   Weapon 200～265舊魂刻武器
#   FS_EconomyCrafting_Phase1_v0_1
#   FS_SideQuest_Integrated v1.0
#   FS_ResonanceHeadgear_KindRename v1.0
#   更多掉落物
#   Drop Options
#   商店价格调整
#   Item Price Changer
#   FS_ShopStatusContext v1.1
#   舊版FS_ShopStatusDetail v1.0
#   舊版Scene_Shop FS v1.2／v1.3
#   舊版FS_ShopAllPartyDisplay v1.0～v1.6
#
# 現行商店頁：
#   Window_ShopBuy FS v1.3
#   FS_ShopAllPartyDisplay v1.7
#   FS_ShopStatusDetail v1.1
#   Scene_Shop FS v1.4
#   FS_RegionShops_BlackMarket v1.1
#
# ==============================================================================
# ■ 文件結束
# ==============================================================================
