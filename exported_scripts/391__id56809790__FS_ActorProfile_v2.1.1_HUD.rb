#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ActorProfile v2.1.1 HUD
# 【用途】Forest Symphony 的 Actor 固定資料 Authority。RPG Maker VX 的 RPG::Actor／RPG::Class 沒有可供此架構使用的 Note，因此主角／召喚物身分、類型、Role、Target Group、Robot Protocol、Mana Engine、Clone 穩定度等固定資料集中於 ALBERT_ACTOR_PROFILE::ACTORS。
# 【資料分工】Actor 固定資料→ACTORS；Skill 固定資料→Skill Note；裝備臨時修正→Weapon／Armor Note；State 臨時修正→State Note。
# 【主要設定】MAIN_ACTOR_MAX_ID、AUTO_ARMOR_MAPPING_SUMMON、FALLBACK_ID_ABOVE_MAIN_IS_SUMMON、ACTORS、DEFAULT_CLONE_STABILITY_MAX、DEFAULT_CLONE_ACTION_COST、RESET_CLONE_STABILITY_ON_BATTLE_START、BLOCK_SKILL_WHEN_STABILITY_NOT_ENOUGH、CLONE_INSTABILITY_STATE_ID、DEFAULT_MANA_ENGINE_TARGET。
# 【公開查詢範例】ALBERT_ACTOR_PROFILE.profile(22)、summon?(22)、main_actor?(1)、summon_type(22)、roles(22)、groups(22)、tag_text(2)。Game_Actor 亦提供 albert_summon?／albert_pokemon?／albert_robot?／albert_clone?／albert_summon_type。
# 【Clone API】actor.clone_stability、clone_stability_max、albert_recover_clone_stability(20)；技能可用性、成功支付、傷害加成與不穩定 State 由本頁自動整合。
# 【Robot／Mana Engine】ACTORS 可定義 robot_protocol 與 mana_engine；裝備／State 可用既有 Notetag 暫時覆蓋，例如 <robot_protocol_skill:630>、<robot_protocol_interval:2>、<robot_protocol_if_state 31:631>、<mana_engine_target:lowest_mp>、<mana_engine_target:actor 2>、<mana_engine_mp:25>、<mana_engine_state 41:1>、<mana_engine_od_actor 2:100>。
# 【Target Group】ACTORS 的 group／role 會提供給 ALBERT_TARGET_GROUP；例如 main、summon、pokemon、robot、clone、actor 1、actors 1,3,5、all_actor、self_group 等既有 Target Group 語意。
# 【BattleStateHUD】Phase 13 起本頁只提供 AlbertBattleStateHUD.clone_stability_rows；extra_info_rows 已由 FS_BattleStateHUD_Authority 單一持有。穩定度改變時透過 albert_bshud_touch! 通知 HUD。
# 【載入順序／為何 Phase 17 不再去 alias】本頁仍包裝 skill_can_use?、skill_effect、make_obj_damage_value、Scene_Battle#start、execute_action_skill、albert_cc_execute_summon_followup、albert_mx_robot_protocol_target。這些方法後方還有 FieldWeather、StateEffects、SoulMark、SummonChain、MarkedCommand、PokemonFollowupIdentity 等正式外層，或依賴 MechanicExpansion 先定義基礎方法；因此目前屬 staged contract，不可為了頁面整齊直接回併／前移。
# 【相關素材】未發現固定 Graphics／Audio 檔名；主要依賴資料庫 Actor／Skill／State／Equipment 與其他 FS Runtime。
# 【來源】Forest Symphony 專用 RGSS2 Runtime；v2.1.1 為 HUD 修正版，保留集中 Actor Profile、Mana Engine、Clone Stability 全功能。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#==============================================================================


#------------------------------------------------------------------------------

#  Forest Symphony / RPG Maker VX / RGSS2 / Ruby 1.8 相容

#  【v2.1.1 HUD 修正版】保留 v2.1 全功能，修正 Clone 穩定度與 Actor Note 的 HUD 整合

#==============================================================================

#
#  【v2.1.1 修正內容】
#
#  1. BattleStateHUD 的實際模組名稱為 AlbertBattleStateHUD。
#     舊版誤寫為 AlbertBattleStateHUD 的舊全大寫底線形式，導致整合區塊不執行。
#
#  2. 修正 Actor 的 battler_note 來源：
#     HUD 現在可讀取 ALBERT_ACTOR_PROFILE 集中設定中的 Actor tags。
#
#  3. 修正 Clone 穩定度 Detail 顯示：
#     選取 Clone 時會追加「穩定度　目前值/最大值」。
#
#  4. 穩定度支付、恢復與重設時，仍會呼叫 albert_bshud_touch!，
#     讓 Detail 視窗立即更新，不必等候備援輪詢。
#
#  【安裝】
#  全文取代原本的 ActorProfile 腳本頁。
#  必須放在 BattleStateHUD_Core_v2_0 之下，並保留原本所在位置。
#
#==============================================================================

#

#  【0. 這支腳本解決什麼問題】

#------------------------------------------------------------------------------

#  RPG Maker VX 的 RPG::Actor 與 RPG::Class 沒有 Note 欄位。

#  因此以下寫法在 VX 中不能作為 Actor / Class 本體資料來源：

#



#      <summon_type:robot>          # 想像中的 Actor Note

#      <summon_role:mana_engine>    # 想像中的 Actor Note

#

#  本腳本把所有「Actor 本體固定資料」集中到：

#


#

#  並統一提供給：

#

#    1. 主角 / 召喚物身分

#    2. Pokémon / Robot / Clone 類型



#    5. Actor 專屬機制 Tag，取代 Actor Note



#    8. Clone 穩定度

#    9. BattleStateHUD Clone 穩定度顯示

#   10. SummonChain3 / 召喚追擊中的 Clone 穩定度成本

#

#  核心原則：

#

#    Actor 本體固定資料  →  ALBERT_ACTOR_PROFILE::ACTORS

#    Skill 固定資料      →  Skill Note

#    裝備臨時修正        →  Weapon / Armor Note

#    State 臨時修正      →  State Note

#

#  不要再把 Actor / Class 當成有 Note。它們沒有。真的沒有。

#

#==============================================================================

#  【1. 放置位置與相依腳本】

#------------------------------------------------------------------------------

#  請放在以下相關腳本之下、Main 之上：

#







#      SummonChain3（若有）

#

#  最簡單做法：

#

#      所有 Albert 自製戰鬥補丁

#      ↓


#      ↓


#

#  若已安裝：

#


#

#  請移除舊版，只保留本 v2.0。

#

#==============================================================================

#  【2. 最重要的入口：ACTORS 集中設定表】

#------------------------------------------------------------------------------

#  所有 Actor 本體資料都寫在：

#

#      module ALBERT_ACTOR_PROFILE

#        ACTORS = {

#          ActorID => { 設定內容 }

#        }

#      end

#

#  完整可用欄位：

#


#      是否為召喚物。

#


#      召喚物種類。

#


#      召喚物 Role，可同時有多個。

#


#      TargetGroup 可使用的群組名稱。

#


#      Actor 專屬機制 Tag。

#      這就是「Actor Note」的正式替代品。

#





#    }

#      Robot 基礎協議。

#



#    }

#      mana_engine 的預設目標規則。

#


#      Clone 最大穩定度。

#


#      Clone 技能未寫個別 cost 時的預設成本。

#

#==============================================================================

#  【3. ACTORS 基礎範例】

#------------------------------------------------------------------------------

#  ● 主要角色

#

#    1 => {





#    }

#

#------------------------------------------------------------------------------


#

#    20 => {






#    }

#

#  這個 Actor 會自動符合：

#






#

#------------------------------------------------------------------------------


#

#    21 => {






#    }

#

#------------------------------------------------------------------------------


#

#    22 => {








#    }

#

#==============================================================================

#  【4. 召喚物 Type 的所有用法】

#------------------------------------------------------------------------------

#  集中設定表：

#




#

#  可供其他腳本 / 事件使用：

#








#

#  albert_unit_type_symbol 可能回傳：

#







#

#  集中模組直接查詢：

#

#      ALBERT_ACTOR_PROFILE.summon?(22)

#      ALBERT_ACTOR_PROFILE.main_actor?(1)

#      ALBERT_ACTOR_PROFILE.summon_type(22)

#

#==============================================================================

#  【5. summon_role 的所有用法】

#------------------------------------------------------------------------------

#  Actor 本體固定 Role：

#


#

#  多 Role：

#


#

#  建議 Role 範例：

#




















#

#  查詢：

#


#      actor.albert_mx_summon_role?("mana_engine")

#

#  注意：

#  Actor 本體 Role 來自 ACTORS。

#  但 Weapon / Armor / State Note 仍可臨時追加 Role：

#

#      <summon_role:mana_engine>

#

#  因此角色可以因裝備或 State 暫時取得額外 Role。

#

#  Role 合併規則：

#

#      ACTORS 固定 Role

#      + 裝備 Note Role


#

#  不重複加入相同 Role。

#

#==============================================================================

#  【6. Group / TargetGroup 的所有用法】

#------------------------------------------------------------------------------

#  Actor 的群組寫在：

#


#

#  系統還會自動補入：

#

#      主角       → "main"

#      召喚物     → "summon"




#

#  因此即使 groups 沒手動寫 pokemon，只要 type 是 :pokemon，

#  ALBERT_ACTOR_PROFILE.groups(actor_id) 仍會包含 "pokemon"。

#

#  Skill Note 可繼續使用 TargetGroup_System 原本語法，例如：

#

#      <target_group: main>

#      <target_group: summon>

#      <target_group: pokemon>

#      <target_group: robot>

#      <target_group: clone>

#      <target_group: forest_beast>

#      <target_group: actor 1>

#      <target_group: actors 1,3,5>

#      <target_group: all_actor>

#      <target_group: self_group>

#

#  自訂群組範例：

#

#    20 => {






#    }

#


#

#      <target_group: forest_beast>

#

#  就只會選取屬於 forest_beast 群組的 Actor。

#

#  查詢：

#

#      ALBERT_ACTOR_PROFILE.groups(20)

#

#==============================================================================

#  【7. :tags，Actor Note 的正式替代品】

#------------------------------------------------------------------------------

#  任何原本想放在 Actor Note、而且現有機制使用 source_text 讀取的 Tag，

#  改放在：

#




#      ]

#

#  例：米亞 Actor 2

#

#    2 => {







#      ]

#    }

#

#  例：艾薇 Actor 5

#

#    5 => {







#      ]

#    }

#

#  :tags 會被目前補丁整合進：

#




#

#  注意：

#  :tags 不是讓所有世界上的 Note 腳本自動支援 Actor 設定。

#  只有透過上述整合入口或相容方法讀取的系統才會看到這些文字。

#

#  查詢原始文字：

#

#      ALBERT_ACTOR_PROFILE.tag_text(2)

#

#==============================================================================

#  【8. Robot Protocol：集中設定表完整用法】

#------------------------------------------------------------------------------

#  Robot Actor 範例：

#

#    21 => {










#          [31, 621],

#          [32, 622]

#        ]

#      }

#    }

#

#  意義：

#


#        預設協議技能 Skill 620。

#


#        每第 3 次行動進入 Protocol。

#        若 <= 0，會自動修正為 1。

#


#        若符合原 Robot Protocol 的 State 條件判斷，

#        State 31 對應 Skill 621，State 32 對應 Skill 622。

#

#  沒有 default skill，但只有條件技能也可以：

#





#      }

#

#  若 skill <= 0 且 if_state 為空，視為沒有 Protocol。

#

#------------------------------------------------------------------------------

#  ● 裝備 / State Note 臨時覆蓋 Robot Protocol

#

#  Weapon / Armor / State Note 可用：

#

#      <robot_protocol_skill:630>

#      <robot_protocol_interval:2>

#      <robot_protocol_if_state 31:631>

#

#  覆蓋規則：

#

#      ACTORS 的 :skill       → 可被裝備 / State Note 取代

#      ACTORS 的 :interval    → 可被裝備 / State Note 取代

#      ACTORS 的 :if_state    → 裝備 / State Note 會追加，不會刪除原條件

#

#  也就是：本體定義基礎協議，裝備 / State 可以臨時改造協議。

#

#==============================================================================

#  【9. mana_engine：Actor 設定】

#------------------------------------------------------------------------------

#  最典型 Robot mana_engine：

#

#    21 => {










#      },



#      }

#    }

#

#  可用 target：

#


#        選目前 MP 比例最低的可用隊員。

#        比較公式是 mp / maxmp，不是單純比較目前 MP 數字。

#


#        固定 Actor 2。

#

#      2

#        固定 Actor ID 2。

#

#  全域預設：

#

#      DEFAULT_MANA_ENGINE_TARGET = :lowest_mp

#

#  若 Actor 沒寫 :mana_engine 或沒寫 :target，就使用全域預設。

#

#==============================================================================

#  【10. mana_engine：Skill Note 目標語法】

#------------------------------------------------------------------------------

#  Skill Note 可以覆蓋 Actor 的 mana_engine 預設目標。

#

#      <mana_engine_target:lowest_mp>

#

#      <mana_engine_target:mia>

#

#      <mana_engine_target:actor 2>

#

#      <mana_engine_target_actor:2>

#

#  優先順序：

#

#      Skill Note 指定目標

#      ↓


#      ↓


#

#  注意：

#  固定 Actor 目標必須：

#

#      1. Actor 存在

#      2. Actor 在目前 $game_party.members 中

#      3. Actor.exist? 為 true

#

#  若找不到指定目標，會回到原 Robot Protocol 目標邏輯。

#

#==============================================================================

#  【11. mana_engine：Skill Note 效果語法，完整清單】

#------------------------------------------------------------------------------

#  以下 Tag 都放在 Skill Note。

#

#  ● 目標回復最大 MP 百分比

#

#      <mana_engine_mp:25>

#

#  目標回復 maxmp 的 25%。

#

#------------------------------------------------------------------------------

#  ● 目標回復固定 MP

#

#      <mana_engine_mp_flat:20>

#

#  目標回復 20 MP。

#

#------------------------------------------------------------------------------

#  ● 目標增加指定 State / 層數

#

#      <mana_engine_state 41:1>

#

#  目標增加 State 41 一層。

#

#      <mana_engine_state 41:3>

#

#  先 add_state(41)，若有 increase_stack 方法，再追加剩餘 2 層。

#  若沒有疊層系統，至少仍會正常附加 State。

#

#------------------------------------------------------------------------------

#  ● 指定 Actor 增加 State / 層數

#

#      <mana_engine_state_actor 2:41:1>

#

#  Actor 2 增加 State 41 一層。

#  Actor 必須存在於目前隊伍且可存在。

#

#------------------------------------------------------------------------------

#  ● 指定 Actor 增加 OD

#

#      <mana_engine_od_actor 2:100>

#

#  Actor 2 增加 100 OD。

#  需要 ALBERT_CHARACTER_CORE.gain_od 存在。

#  若未安裝對應 CharacterMechanicCore，這個 Tag 不會產生 OD 效果。

#

#------------------------------------------------------------------------------

#  ● 多效果可同時使用

#

#      <mana_engine_target:mia>

#      <mana_engine_mp:15>

#      <mana_engine_state_actor 2:41:1>

#      <mana_engine_od_actor 2:50>

#

#  同一技能可同時：

#

#      1. 指向米亞

#      2. 回復米亞最大 MP 15%

#      3. 增加 State 41 一層

#      4. 增加 50 OD

#

#  各效果會累加處理。

#

#==============================================================================

#  【12. mana_engine 完整範例】

#------------------------------------------------------------------------------


#

#    21 => {










#      },


#    }

#


#

#      <mana_engine_mp:25>

#

#  結果：

#  每第 3 次 Robot Protocol 行動，優先選 MP 比例最低隊員，

#  並回復該目標最大 MP 25%。

#

#------------------------------------------------------------------------------

#  米亞專用循環機：

#


#

#      <mana_engine_target:mia>

#      <mana_engine_mp:20>

#      <mana_engine_state_actor 2:41:1>

#

#  結果：

#  固定優先支援 Actor 2 米亞，回 MP 並給魔力層。

#

#==============================================================================

#  【13. Clone 穩定度：全域設定】

#------------------------------------------------------------------------------

#  可調整常數：

#

#      DEFAULT_CLONE_STABILITY_MAX = 100

#        Clone 未單獨設定時的最大穩定度。

#

#      DEFAULT_CLONE_ACTION_COST = 0

#        Clone 未設定 :clone_action_cost 且技能沒有個別 cost 時的成本。

#

#      RESET_CLONE_STABILITY_ON_BATTLE_START = true

#        true：戰鬥開始時，隊伍中的 Clone 回滿穩定度。

#

#      BLOCK_SKILL_WHEN_STABILITY_NOT_ENOUGH = true

#        true：穩定度不足時，除非技能允許透支，否則 skill_can_use? = false。

#

#      CLONE_INSTABILITY_STATE_ID = 91

#        Clone 不穩定 State ID。

#

#      ADD_INSTABILITY_STATE_WHEN_EMPTY = true

#        true：穩定度歸零時自動附加不穩定 State。

#

#      INSTABILITY_CLEAR_AT = 20

#        穩定度恢復到此數值以上，才自動解除不穩定 State。

#

#==============================================================================

#  【14. Clone 穩定度：Actor 設定】

#------------------------------------------------------------------------------


#

#    22 => {








#    }

#

#  意義：

#

#      最大穩定度 100。

#      沒有個別 <clone_stability_cost:x> 的技能，預設花費 10。

#

#  若技能有個別 cost，技能值優先：

#

#      <clone_stability_cost:25>

#

#  會使用 25，而不是 Actor 預設 10。

#

#==============================================================================

#  【15. Clone 技能 Note：完整清單】

#------------------------------------------------------------------------------

#  ● 個別穩定度成本

#

#      <clone_stability_cost:25>

#

#  使用技能時消耗 25 穩定度。

#

#------------------------------------------------------------------------------

#  ● 允許透支

#

#      <clone_stability_allow_overdraw>

#

#  穩定度不足仍可使用。

#  若實際成本高於目前穩定度，會視為 overdraw，穩定度降至 0，

#  並增加 1 層 Clone 不穩定 State。

#

#  例：目前 20，成本 60：

#

#      20 → 0

#      +1 層 State 91

#

#------------------------------------------------------------------------------

#  ● 成功才支付穩定度

#

#      <clone_stability_pay_on_success>

#

#  預設：技能開始執行時就支付。

#  加上此 Tag 後：至少有一次技能效果被判定成功，才支付成本。

#

#  目前成功旗標判定基礎：

#

#      非 missed

#      非 evaded

#      非 skipped

#

#  mana_engine 有實際效果改變時，也會視為成功。

#

#------------------------------------------------------------------------------

#  ● 成功時退還穩定度

#

#      <clone_stability_refund:10>

#

#  只有技能成功時退還 10。

#

#  例：

#



#      成功後淨成本 = 20

#

#------------------------------------------------------------------------------

#  ● 無論成功與否都回復穩定度

#

#      <clone_stability_recover:20>

#

#  技能行動結束後回復 20。

#  目前實作不要求成功。

#

#------------------------------------------------------------------------------

#  ● 高穩定度條件增傷

#

#      <bonus_if_clone_stability_above 50:30>

#

#  目前穩定度 >= 50 時，正傷害 +30%。

#

#------------------------------------------------------------------------------

#  ● 每點穩定度增傷

#

#      <bonus_per_clone_stability:0.2>

#

#  每 1 點目前穩定度，正傷害 +0.2%。

#

#  100 穩定度 = +20%

#   50 穩定度 = +10%

#

#------------------------------------------------------------------------------

#  ● 不穩定狀態增傷

#

#      <bonus_if_clone_unstable:50>

#

#  使用者有 CLONE_INSTABILITY_STATE_ID 指定 State 時，正傷害 +50%。

#

#  三種 Clone 傷害 Bonus 會相加後一次乘算。

#

#  例：

#

#      高穩定度條件 +30%

#      每點穩定度共 +20%

#      合計 +50%

#

#      最終正傷害 × 1.50

#

#  只修正正的 HP / MP Damage。

#  不會放大治療或負傷害值。

#

#==============================================================================

#  【16. Clone 技能完整範例】

#------------------------------------------------------------------------------

#  ● 普通精準技

#

#      <clone_stability_cost:20>

#      <bonus_if_clone_stability_above 50:20>

#

#------------------------------------------------------------------------------

#  ● 成功才扣費

#

#      <clone_stability_cost:30>

#      <clone_stability_pay_on_success>

#

#------------------------------------------------------------------------------

#  ● 成功後部分退費

#

#      <clone_stability_cost:30>

#      <clone_stability_refund:10>

#

#------------------------------------------------------------------------------

#  ● 自我校準技能

#

#      <clone_stability_recover:25>

#

#------------------------------------------------------------------------------

#  ● 高風險透支爆發

#

#      <clone_stability_cost:60>

#      <clone_stability_allow_overdraw>

#      <bonus_if_clone_unstable:50>

#

#------------------------------------------------------------------------------

#  ● 高穩定精準處刑

#

#      <clone_stability_cost:35>

#      <bonus_if_clone_stability_above 70:30>

#      <bonus_per_clone_stability:0.15>

#

#==============================================================================

#  【17. Clone 不穩定 State 91 建議】

#------------------------------------------------------------------------------

#  State 91 建議設定，例如：

#

#      <max stack 3>

#      <atk -5%>

#      <spi -5%>

#      <agi -5%>

#      <hud_priority:230>

#      <hud_detail>

#      <hud_detail_text:Clone穩定度不足，每層降低ATK/SPI/AGI 5%>

#

#  注意：

#  上述 State Note 是否全部有效，取決於你現有的 State / Stack / HUD 腳本。

#  本腳本本身負責的是：

#

#      1. 何時附加 State 91

#      2. 何時增加堆疊

#      3. 何時自動解除 State 91

#

#==============================================================================

#  【18. Clone 穩定度的實際行為】

#------------------------------------------------------------------------------

#  戰鬥開始：

#

#      RESET_CLONE_STABILITY_ON_BATTLE_START = true

#      → 目前隊伍中的 Clone 穩定度回滿。

#

#  使用技能：

#

#      先讀 Skill Note <clone_stability_cost:x>

#      沒有 → 讀 Actor :clone_action_cost

#      還沒有 → DEFAULT_CLONE_ACTION_COST

#

#  穩定度不足：

#

#      BLOCK_SKILL_WHEN_STABILITY_NOT_ENOUGH = true

#      且沒有 <clone_stability_allow_overdraw>

#      → 技能不可使用。

#

#  允許透支：

#

#      穩定度不足仍可用

#      → 穩定度降為 0

#      → 增加不穩定 State。

#

#  自動解除不穩定：

#

#      穩定度 >= INSTABILITY_CLEAR_AT

#      → 自動移除 State 91。

#

#==============================================================================

#  【19. Clone 穩定度與 SummonChain3 / 召喚追擊】

#------------------------------------------------------------------------------

#  CharacterMechanicCore / SummonChain3 的追擊不一定走一般

#  execute_action_skill，因此本腳本另外補強：

#


#

#  若該方法存在，Clone 作為召喚追擊者時也會：

#

#      1. 檢查穩定度是否足夠

#      2. 支付 <clone_stability_cost:x>

#      3. 支援 pay_on_success

#      4. 支援 refund

#      5. 支援 recover

#

#  也就是 Clone 不會因為是喬伊的第二 / 第三段追擊就免費使用技能。

#

#  若原系統沒有 albert_cc_execute_summon_followup，本補丁不會硬建立它。

#

#==============================================================================

#  【20. Clone 穩定度與 BattleStateHUD】

#------------------------------------------------------------------------------

#  若 AlbertBattleStateHUD 已存在，本腳本會在 extra_info_rows 追加：

#

#      穩定度 | 75/100

#

#  開關：

#

#      SHOW_CLONE_STABILITY_INFO = true

#

#  穩定度改變時，若 battler 支援 albert_bshud_touch!，會通知 HUD 更新。

#

#==============================================================================

#  【21. 事件腳本 / 其他腳本可直接使用的 API】

#------------------------------------------------------------------------------

#  ● 查 Actor Profile

#

#      ALBERT_ACTOR_PROFILE.profile(22)

#

#------------------------------------------------------------------------------

#  ● 判斷召喚物

#

#      ALBERT_ACTOR_PROFILE.summon?(22)

#      $game_actors[22].albert_summon?

#

#------------------------------------------------------------------------------

#  ● 判斷主要角色

#

#      ALBERT_ACTOR_PROFILE.main_actor?(1)

#      $game_actors[1].albert_main_actor?

#

#------------------------------------------------------------------------------

#  ● 取得召喚 Type

#

#      ALBERT_ACTOR_PROFILE.summon_type(22)

#      $game_actors[22].albert_summon_type

#

#------------------------------------------------------------------------------

#  ● 取得 Role

#

#      ALBERT_ACTOR_PROFILE.roles(22)

#      $game_actors[22].albert_mx_summon_roles

#      $game_actors[22].albert_mx_summon_role?("finisher")

#

#------------------------------------------------------------------------------

#  ● 取得 Groups

#

#      ALBERT_ACTOR_PROFILE.groups(22)

#

#------------------------------------------------------------------------------

#  ● 取得 Actor 專屬 Tag 文字

#

#      ALBERT_ACTOR_PROFILE.tag_text(2)

#

#------------------------------------------------------------------------------

#  ● 取得 Clone 穩定度

#

#      $game_actors[22].clone_stability

#      $game_actors[22].clone_stability_max

#

#------------------------------------------------------------------------------

#  ● 直接回復 Clone 穩定度

#

#      $game_actors[22].albert_recover_clone_stability(20)

#

#------------------------------------------------------------------------------

#  ● 直接重置 Clone 穩定度

#

#      $game_actors[22].albert_reset_clone_stability

#

#------------------------------------------------------------------------------

#  ● 直接設定 Clone 穩定度

#

#      $game_actors[22].albert_clone_stability = 50

#

#  會自動限制在 0～最大值之間，並更新不穩定 State / HUD。

#

#==============================================================================

#  【22. ArmorMapping 與未列入 ACTORS 的 Actor】

#------------------------------------------------------------------------------

#  常數：

#

#      AUTO_ARMOR_MAPPING_SUMMON = true

#

#  若 ArmorMapping.mapping 中出現某 Actor ID，該 Actor 可自動被視為召喚物。

#  但 type / roles / groups 仍建議明確寫入 ACTORS。

#

#  常數：

#

#      FALLBACK_ID_ABOVE_MAIN_IS_SUMMON = false

#


#      沒列入 ACTORS、也不在 ArmorMapping 的 Actor，不會只因 ID > 6

#      就自動成為召喚物。

#


#      ID > MAIN_ACTOR_MAX_ID 的 Actor 自動視為召喚物。

#

#  目前建議保持 false，避免未來新增普通 Actor 時被誤認。

#

#==============================================================================

#  【23. 目前預設 Actor 7～18 的注意事項】

#------------------------------------------------------------------------------

#  本腳本預設保留原 TargetGroup 歷史設定：

#




#

#  Actor 10～18 目前只標記：

#


#

#  但沒有自動猜測 type。

#

#  因此正式使用前，請把 10～18 各自補成真正資料，例如：

#

#    10 => {






#    }

#

#==============================================================================

#  【24. 完整範例：四種 Actor】

#------------------------------------------------------------------------------

#  ACTORS = {

#

#    # 米亞

#    2 => {







#      ]

#    },

#

#    # 毒 Pokémon

#    20 => {






#    },

#

#    # MP 循環 Robot

#    21 => {










#      },



#      }

#    },

#

#    # 終結 Clone

#    22 => {








#    }

#  }

#

#==============================================================================

#  【25. 完整範例：mana_engine Robot + Skill】

#------------------------------------------------------------------------------


#

#    21 => {










#      },


#    }

#


#

#      <mana_engine_mp:25>

#

#  結果：

#      Robot 的 Protocol 技能 620 會優先選 MP 比例最低隊員，

#      回復該目標最大 MP 25%。

#

#==============================================================================

#  【26. 完整範例：米亞專用 mana_engine】

#------------------------------------------------------------------------------


#

#      <mana_engine_target:mia>

#      <mana_engine_mp:15>

#      <mana_engine_state_actor 2:41:1>

#      <mana_engine_od_actor 2:50>

#

#  結果：

#      優先指定 Actor 2 米亞，並同時處理 MP、魔力層、OD。

#

#==============================================================================

#  【27. 完整範例：Clone 精準終結技】

#------------------------------------------------------------------------------


#

#    22 => {








#    }

#


#

#      <clone_stability_cost:35>

#      <bonus_if_clone_stability_above 70:30>

#      <bonus_per_clone_stability:0.15>

#

#  若目前穩定度 100：

#

#      高穩定條件 +30%

#      每點穩定度 +15%

#      總 Bonus +45%

#

#==============================================================================

#  【28. 完整範例：Clone 失控爆發技】

#------------------------------------------------------------------------------


#

#      <clone_stability_cost:60>

#      <clone_stability_allow_overdraw>

#      <bonus_if_clone_unstable:50>

#

#  若目前只有 20 穩定度：

#

#      仍可使用

#      → 穩定度降到 0

#      → 增加 State 91

#

#  注意：bonus_if_clone_unstable 的傷害判定發生在傷害計算時。

#  若技能是在支付穩定度前就先完成傷害計算，該次攻擊是否吃到

#  「剛剛才新增的不穩定」Bonus，取決於原戰鬥流程順序。

#  不要把這個 Tag 當成保證「本次透支必定立刻 +50%」的承諾。

#

#==============================================================================

#  【29. 使用限制與重要注意事項】

#------------------------------------------------------------------------------

#  1. RPG::Actor / RPG::Class 沒有 Note。

#     Actor 本體設定一律用 ACTORS。

#

#  2. Skill / Weapon / Armor / State 仍可使用各自真正存在的 Note。

#

#  3. :tags 只會被本腳本明確整合的 source_text / HUD 等系統看見，

#     不代表所有第三方腳本自動支援。

#

#  4. Robot Protocol 只有在原本 albert_mx_robot_protocol_target 等方法存在時，

#     才會接管目標選擇。

#

#  5. mana_engine 的 OD 效果需要 ALBERT_CHARACTER_CORE.gain_od。

#

#  6. mana_engine_state 多層效果若要真正堆疊，需要 battler 有 increase_stack。

#

#  7. Clone State 91 必須在資料庫存在，否則不穩定 State 不會附加。

#

#  8. Clone HUD 顯示需要 AlbertBattleStateHUD。

#

#  9. Clone SummonChain 成本補強需要原本存在：

#


#

# 10. Clone 的技能個別 cost 只從 Skill Note 讀取。

#     Actor 預設 cost 則從 ACTORS :clone_action_cost 讀取。

#

# 11. mana_engine 的效果 Tag 只從 Skill Note 讀取。

#

# 12. mana_engine 固定 Actor 目標必須在目前隊伍中且 actor.exist?。

#

# 13. ACTORS 中 type 未設定的召喚物只會被認為是 :summon，

#     不會自動變成 Pokémon / Robot / Clone。

#

# 14. 裝備 / State 可追加 summon_role，Robot Protocol 的 skill / interval

#     可覆蓋本體設定，if_state 則追加。

#

#==============================================================================

#  【30. 建議測試清單】

#------------------------------------------------------------------------------

#  ● Actor 身分

#      □ 主要角色 albert_main_actor? 正確

#      □ 召喚物 albert_summon? 正確

#      □ Pokémon / Robot / Clone type 正確

#


#      □ TargetGroup 可正確選 main / summon / pokemon / robot / clone

#      □ 自訂 groups 可正確選取

#      □ 裝備 / State 可追加 summon_role

#


#      □ interval 正確

#      □ default skill 正確

#      □ if_state 條件技正確

#      □ 裝備 / State 覆蓋 skill / interval 正確

#


#      □ lowest_mp 比較 MP 比例，不是目前 MP 數字

#      □ :mia 正確找 Actor 2

#      □ actor N 正確找指定 Actor

#      □ MP 百分比回復正確

#      □ 固定 MP 回復正確

#      □ State / Stack 正確

#      □ 指定 Actor State 正確

#      □ 指定 Actor OD 正確

#

#  ● Clone 穩定度

#      □ 戰鬥開始重置正確

#      □ Skill cost 正確

#      □ Actor default cost 正確

#      □ 不足時技能禁止正確

#      □ allow_overdraw 正確

#      □ State 91 正確增加

#      □ CLEAR_AT 達標後正確解除

#      □ pay_on_success 正確

#      □ refund 正確

#      □ recover 正確

#      □ 三種傷害 Bonus 正確

#      □ HUD 正確更新

#      □ SummonChain / 召喚追擊不會免費繞過成本

#

#==============================================================================

#  【31. Note Tag 快速總表】

#------------------------------------------------------------------------------


#

#      <summon_role:role_name>

#      <robot_protocol_skill:620>

#      <robot_protocol_interval:3>

#      <robot_protocol_if_state 31:621>

#

#  ● Skill Note：mana_engine 目標

#

#      <mana_engine_target:lowest_mp>

#      <mana_engine_target:mia>

#      <mana_engine_target:actor 2>

#      <mana_engine_target_actor:2>

#

#  ● Skill Note：mana_engine 效果

#

#      <mana_engine_mp:25>

#      <mana_engine_mp_flat:20>

#      <mana_engine_state 41:1>

#      <mana_engine_state_actor 2:41:1>

#      <mana_engine_od_actor 2:100>

#

#  ● Skill Note：Clone 穩定度

#

#      <clone_stability_cost:25>

#      <clone_stability_allow_overdraw>

#      <clone_stability_pay_on_success>

#      <clone_stability_refund:10>

#      <clone_stability_recover:20>

#      <bonus_if_clone_stability_above 50:30>

#      <bonus_per_clone_stability:0.2>

#      <bonus_if_clone_unstable:50>

#

#==============================================================================

#  【32. 最後提醒】

#------------------------------------------------------------------------------

#  角色本體資料只維護一份：ALBERT_ACTOR_PROFILE::ACTORS。

#

#  不要再另外建立：

#      Pokémon Actor ID 表

#      Robot Actor ID 表

#      Clone Actor ID 表

#      TargetGroup Actor 表

#      SummonChain Actor 表

#

#  只要相關腳本都走本補丁提供的統一 API，同一個 Actor 的身分就只會有

#  一個答案。這能避免「在 A 腳本是 Robot，在 B 腳本突然變 Pokémon」的

#  經典資料分裂事故。人類組織已經夠常發生這種事，召喚物就先免了。

#==============================================================================



$imported = {} if $imported == nil

$imported["Albert_ActorProfile_ManaEngine_CloneStability"] = true



#==============================================================================


#------------------------------------------------------------------------------

#  Actor 本體資料唯一來源。

#  以後不要再寫「Actor Note」。要新增 Actor 本體設定，就改這裡。

#==============================================================================

module ALBERT_ACTOR_PROFILE



  VERSION = "2.0"



  #--------------------------------------------------------------------------

  # ● 基本規則

  #--------------------------------------------------------------------------

  MAIN_ACTOR_MAX_ID = 6



  # true：ArmorMapping.mapping 中出現的 Actor，自動視為召喚物。

  # 類型 / role 仍建議明確寫進 ACTORS。

  AUTO_ARMOR_MAPPING_SUMMON = true



  # 沒列入 ACTORS、也不在 ArmorMapping 時，是否仍把 ID > 6 當召喚物。

  # 建議 false，避免未來普通 Actor 被誤判成召喚物。

  FALLBACK_ID_ABOVE_MAIN_IS_SUMMON = false



  #--------------------------------------------------------------------------

  # ● Actor 集中設定表

  #

  #  可用欄位：

  #





  #




  #    ]

  #





  #    }

  #



  #      # 也可用 :mia 或 Actor ID 整數，例如 2

  #    }

  #



  #

  #  注意：目前依 TargetGroup 舊預設，先保留：




  #

  #  若你實際 Actor ID 不同，只改這張表即可。

  #--------------------------------------------------------------------------

  ACTORS = {

    #--------------------------------------------------------------------------

    # 六名主要角色

    #--------------------------------------------------------------------------

    1 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },

    2 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },

    3 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },

    4 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },

    5 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },

    6 => {

      :summon => false,

      :groups => ["main"],

      :roles  => [],

      :tags   => []

    },



    #--------------------------------------------------------------------------

    # 目前既有召喚物範圍

    # 先保留原 TargetGroup 的 7 / 8 / 9 類型預設。

    # 10～18 先只認定為召喚物，等你正式決定類型 / role 再補。

    #--------------------------------------------------------------------------

    7 => {

      :summon => true,

      :type   => :pokemon,

      :groups => ["summon", "pokemon"],

      :roles  => [],

      :tags   => []

    },

    8 => {

      :summon => true,

      :type   => :robot,

      :groups => ["summon", "robot"],

      :roles  => [],

      :tags   => []

      # 例：正式作為 mana_engine 時改成：






      # },


    },

    9 => {

      :summon => true,

      :type   => :clone,

      :groups => ["summon", "clone"],

      :roles  => [],

      :tags   => [],

      :clone_stability_max => 100,

      :clone_action_cost   => 0

    },

    10 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    11 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    12 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    13 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    14 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    15 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    16 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    17 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] },

    18 => { :summon => true, :groups => ["summon"], :roles => [], :tags => [] }

  }



  #--------------------------------------------------------------------------

  # ● Clone 穩定度共通設定

  #--------------------------------------------------------------------------

  DEFAULT_CLONE_STABILITY_MAX = 100

  DEFAULT_CLONE_ACTION_COST   = 0



  RESET_CLONE_STABILITY_ON_BATTLE_START = true

  BLOCK_SKILL_WHEN_STABILITY_NOT_ENOUGH = true



  # State 91：Clone 不穩定

  CLONE_INSTABILITY_STATE_ID = 91

  ADD_INSTABILITY_STATE_WHEN_EMPTY = true



  # 穩定度回復到此值以上，才自動解除 State 91。

  # 0 = 只要回復到 1 以上就解除。

  INSTABILITY_CLEAR_AT = 20



  #--------------------------------------------------------------------------

  # ● Mana Engine 共通設定

  #--------------------------------------------------------------------------

  DEFAULT_MANA_ENGINE_TARGET = :lowest_mp



  #--------------------------------------------------------------------------

  # ● 基本資料讀取

  #--------------------------------------------------------------------------

  def self.profile(actor_id)

    actor_id = actor_id.to_i

    data = ACTORS[actor_id]

    return data if data != nil

    return {}

  end



  def self.actor_id_of(actor_or_id)

    return 0 if actor_or_id == nil

    return actor_or_id.to_i if actor_or_id.is_a?(Integer)

    if actor_or_id.respond_to?(:actor?) && actor_or_id.actor?

      return actor_or_id.id.to_i if actor_or_id.respond_to?(:id)

    end

    return 0

  end



  def self.armor_mapping_summon?(actor_id)

    return false unless AUTO_ARMOR_MAPPING_SUMMON

    return false unless defined?(ArmorMapping)

    return false unless ArmorMapping.respond_to?(:mapping)

    begin

      for value in ArmorMapping.mapping.values

        return true if value.to_i == actor_id.to_i

      end

    rescue

      return false

    end

    return false

  end



  def self.summon?(actor_id)

    actor_id = actor_id.to_i

    data = profile(actor_id)

    if data.has_key?(:summon)

      return data[:summon] ? true : false

    end

    return true if armor_mapping_summon?(actor_id)

    return true if FALLBACK_ID_ABOVE_MAIN_IS_SUMMON && actor_id > MAIN_ACTOR_MAX_ID

    return false

  end



  def self.main_actor?(actor_id)

    actor_id = actor_id.to_i

    return false if actor_id <= 0

    return false if summon?(actor_id)

    return actor_id <= MAIN_ACTOR_MAX_ID

  end



  def self.summon_type(actor_id)

    data = profile(actor_id)

    value = data[:type]

    return nil if value == nil

    return value.to_s.downcase.to_sym

  end



  def self.roles(actor_id)

    data = profile(actor_id)

    result = []

    raw = data[:roles]

    raw = [] if raw == nil

    for role in raw

      name = role.to_s.downcase

      result.push(name) unless result.include?(name)

    end

    return result

  end



  def self.groups(actor_id)

    actor_id = actor_id.to_i

    data = profile(actor_id)

    result = []



    raw = data[:groups]

    raw = [] if raw == nil

    for group in raw

      name = group.to_s.downcase

      result.push(name) unless result.include?(name)

    end



    if main_actor?(actor_id)

      result.push("main") unless result.include?("main")

    end



    if summon?(actor_id)

      result.push("summon") unless result.include?("summon")

    end



    type = summon_type(actor_id)

    if type != nil

      name = type.to_s.downcase

      result.push(name) unless result.include?(name)

    end



    return result

  end



  #--------------------------------------------------------------------------

  # ● Actor 專屬機制 Tag

  #

  #  這是「Actor Note」的正式替代品。

  #  現有 CharacterMechanicCore / MechanicExpansion 仍用原本 regex 解析，

  #  但文字來源改為這張集中設定表，不再碰 RPG::Actor.note。

  #--------------------------------------------------------------------------

  def self.tag_text(actor_id)

    data = profile(actor_id)

    tags = data[:tags]

    tags = [] if tags == nil

    text = ""

    for tag in tags

      next if tag == nil

      text += tag.to_s

      text += "\n"

    end

    return text

  end



  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def self.robot_protocol(actor_id)

    data = profile(actor_id)

    raw = data[:robot_protocol]

    return nil if raw == nil



    skill = raw[:skill].to_i

    interval = raw[:interval].to_i

    interval = 1 if interval <= 0



    conditionals = []

    list = raw[:if_state]

    list = [] if list == nil

    for pair in list

      next if pair == nil || pair.size < 2

      conditionals.push([pair[0].to_i, pair[1].to_i])

    end



    return nil if skill <= 0 && conditionals.empty?

    return [skill, interval, conditionals]

  end



  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def self.mana_engine_data(actor_id)

    data = profile(actor_id)

    raw = data[:mana_engine]

    return {} if raw == nil

    return raw

  end



  def self.mana_engine_target(actor_id)

    data = mana_engine_data(actor_id)

    value = data[:target]

    return DEFAULT_MANA_ENGINE_TARGET if value == nil

    return value

  end



  #--------------------------------------------------------------------------

  # ● Clone 穩定度

  #--------------------------------------------------------------------------

  def self.clone_stability_max(actor_id)

    data = profile(actor_id)

    value = data[:clone_stability_max]

    value = DEFAULT_CLONE_STABILITY_MAX if value == nil

    value = value.to_i

    return [value, 1].max

  end



  def self.clone_action_cost(actor_id)

    data = profile(actor_id)

    value = data[:clone_action_cost]

    value = DEFAULT_CLONE_ACTION_COST if value == nil

    value = value.to_i

    return [value, 0].max

  end

end



#==============================================================================

# ■ Game_Battler：統一 Actor 身分 / 類型 / Role

#==============================================================================

class Game_Battler



  def albert_summon?

    return false unless actor?

    return ALBERT_ACTOR_PROFILE.summon?(self.id)

  end



  def albert_main_actor?

    return false unless actor?

    return ALBERT_ACTOR_PROFILE.main_actor?(self.id)

  end



  def albert_pokemon?

    return false unless actor?

    return ALBERT_ACTOR_PROFILE.summon_type(self.id) == :pokemon

  end



  def albert_robot?

    return false unless actor?

    return ALBERT_ACTOR_PROFILE.summon_type(self.id) == :robot

  end



  def albert_clone?

    return false unless actor?

    return ALBERT_ACTOR_PROFILE.summon_type(self.id) == :clone

  end



  def albert_summon_type

    return nil unless actor?

    type = ALBERT_ACTOR_PROFILE.summon_type(self.id)

    return type if type != nil

    return :summon if albert_summon?

    return nil

  end



  def albert_unit_type_symbol

    return :pokemon if albert_pokemon?

    return :robot if albert_robot?

    return :clone if albert_clone?

    return :summon if albert_summon?

    return :main_actor if actor?

    return :enemy

  end



  def albert_mx_summon_roles

    result = []

    return result unless actor?



    # 1. Actor 本體 role：集中設定表

    for role in ALBERT_ACTOR_PROFILE.roles(self.id)

      result.push(role) unless result.include?(role)

    end



    # 2. 裝備 / State Note 仍允許暫時追加 role

    text = ""

    if respond_to?(:equips)

      for equip in equips.compact

        if defined?(ALBERT_MECHANIC_EXPANSION) &&

           ALBERT_MECHANIC_EXPANSION.respond_to?(:note)

          text += ALBERT_MECHANIC_EXPANSION.note(equip)

        elsif equip.respond_to?(:note) && equip.note != nil

          text += equip.note.to_s

        end

      end

    end



    for state in states.compact

      if defined?(ALBERT_MECHANIC_EXPANSION) &&

         ALBERT_MECHANIC_EXPANSION.respond_to?(:note)

        text += ALBERT_MECHANIC_EXPANSION.note(state)

      elsif state.respond_to?(:note) && state.note != nil

        text += state.note.to_s

      end

    end



    text.scan(/<summon_role\s*:\s*([a-z0-9_]+)\s*>/i) do |data|

      role = data[0].to_s.downcase

      result.push(role) unless result.include?(role)

    end



    return result

  end



  def albert_mx_summon_role?(role_name)

    return albert_mx_summon_roles.include?(role_name.to_s.downcase)

  end

end



#==============================================================================

# ■ CharacterMechanicCore：停止讀取 RPG::Actor.note

#==============================================================================

if defined?(ALBERT_CHARACTER_CORE)

  module ALBERT_CHARACTER_CORE

    def self.source_text(user, obj = nil)

      text = ""

      text += note(obj)

      return text if user == nil



      if user.actor?

        # Actor 本體資料只來自集中設定表。

        text += ALBERT_ACTOR_PROFILE.tag_text(user.id)



        if user.respond_to?(:equips)

          for equip in user.equips.compact

            text += note(equip)

          end

        end

      else

        text += note(user.enemy) if user.respond_to?(:enemy)

      end



      for state in user.states.compact

        text += note(state)

      end



      return text

    end

  end

end



#==============================================================================

# ■ MechanicExpansion：停止讀取 RPG::Actor.note

#==============================================================================

if defined?(ALBERT_MECHANIC_EXPANSION)

  module ALBERT_MECHANIC_EXPANSION

    def self.source_text(user, obj = nil)

      if defined?(ALBERT_CHARACTER_CORE) &&

         ALBERT_CHARACTER_CORE.respond_to?(:source_text)

        return ALBERT_CHARACTER_CORE.source_text(user, obj)

      end



      text = note(obj)

      return text if user == nil



      if user.actor?

        text += ALBERT_ACTOR_PROFILE.tag_text(user.id)



        if user.respond_to?(:equips)

          for equip in user.equips.compact

            text += note(equip)

          end

        end

      elsif user.respond_to?(:enemy)

        text += note(user.enemy)

      end



      for state in user.states.compact

        text += note(state)

      end



      return text

    end

  end

end



#==============================================================================

# ■ TargetGroup：Actor Group 全部改讀集中設定表

#==============================================================================

if defined?(ALBERT_TARGET_GROUP)

  module ALBERT_TARGET_GROUP



    def self.actor_note(actor)

      # 舊 API 保留，但不再讀不存在的 RPG::Actor.note。

      return "" if actor == nil

      return "" unless actor.respond_to?(:actor?) && actor.actor?

      return ALBERT_ACTOR_PROFILE.tag_text(actor.id)

    end



    def self.actor_group_names(actor)

      return [] if actor == nil

      return [] unless actor.respond_to?(:actor?) && actor.actor?

      return ALBERT_ACTOR_PROFILE.groups(actor.id)

    end



    def self.member_in_group?(member, group, user = nil)

      return false unless actor_battler?(member)

      group = normalize_group_name(group)

      return false if group == nil || group == ""



      id = actor_id(member)



      case group

      when "main"

        return ALBERT_ACTOR_PROFILE.main_actor?(id)

      when "summon"

        return ALBERT_ACTOR_PROFILE.summon?(id)

      when "all_actor", "all actor", "all"

        return true

      when "self_group", "self group"

        return same_group_as_user?(member, user)

      end



      ids = direct_actor_ids(group)

      return ids.include?(id) if ids != nil



      return actor_group_names(member).include?(group)

    end



    def self.same_group_as_user?(member, user)

      return false unless actor_battler?(member)

      return false unless actor_battler?(user)



      user_groups = actor_group_names(user)

      for group in user_groups

        next if group == "summon" || group == "main"

        return true if member_in_group?(member, group, user)

      end



      if ALBERT_ACTOR_PROFILE.main_actor?(actor_id(user))

        return member_in_group?(member, "main", user)

      end



      if ALBERT_ACTOR_PROFILE.summon?(actor_id(user))

        # 若有明確 type，優先同 type。

        type = ALBERT_ACTOR_PROFILE.summon_type(actor_id(user))

        if type != nil

          return member_in_group?(member, type.to_s, user)

        end

        return member_in_group?(member, "summon", user)

      end



      return false

    end



    def self.group_prefers_summon_side?(group, user = nil)

      group = normalize_group_name(group)

      return false if group == nil



      return true if group == "summon"



      if group == "self_group" || group == "self group"

        return actor_battler?(user) &&

               ALBERT_ACTOR_PROFILE.summon?(actor_id(user))

      end



      ids = direct_actor_ids(group)

      if ids != nil && !ids.empty?

        all_summons = true

        for id in ids

          all_summons = false unless ALBERT_ACTOR_PROFILE.summon?(id)

        end

        return all_summons

      end



      if $game_party != nil

        matched = []

        for member in $game_party.members

          matched.push(member) if member_in_group?(member, group, user)

        end



        unless matched.empty?

          for member in matched

            return false unless ALBERT_ACTOR_PROFILE.summon?(actor_id(member))

          end

          return true

        end

      end



      return false

    end

  end

end



#==============================================================================

# ■ BattleStateHUD：Actor 額外資訊來源改讀集中設定表

#==============================================================================

if defined?(AlbertBattleStateHUD)

  module AlbertBattleStateHUD

    def self.battler_note(battler)

      return "" if battler == nil

      if battler.is_a?(Game_Enemy)

        return note(battler.enemy)

      elsif battler.is_a?(Game_Actor)

        return ALBERT_ACTOR_PROFILE.tag_text(battler.id)

      end

      return ""

    end

  end

end



#==============================================================================

# ■ Robot Protocol：Actor 本體協議改讀集中設定表

#------------------------------------------------------------------------------

#  裝備 / State Note 仍可作臨時覆蓋。

#  集中設定表優先提供 base protocol。

#==============================================================================

class Game_Actor < Game_Battler



  def albert_actor_profile_note_from_equips_and_states

    text = ""



    if respond_to?(:equips)

      for equip in equips.compact

        if defined?(ALBERT_MECHANIC_EXPANSION) &&

           ALBERT_MECHANIC_EXPANSION.respond_to?(:note)

          text += ALBERT_MECHANIC_EXPANSION.note(equip)

        elsif equip.respond_to?(:note) && equip.note != nil

          text += equip.note.to_s

        end

      end

    end



    for state in states.compact

      if defined?(ALBERT_MECHANIC_EXPANSION) &&

         ALBERT_MECHANIC_EXPANSION.respond_to?(:note)

        text += ALBERT_MECHANIC_EXPANSION.note(state)

      elsif state.respond_to?(:note) && state.note != nil

        text += state.note.to_s

      end

    end



    return text

  end



  def albert_mx_robot_protocol_data

    return nil unless albert_robot?



    base = ALBERT_ACTOR_PROFILE.robot_protocol(self.id)

    default_skill = base == nil ? 0 : base[0].to_i

    interval      = base == nil ? 1 : [base[1].to_i, 1].max

    conditionals  = base == nil ? [] : (base[2] || []).clone



    # 裝備 / State 可暫時覆蓋。

    text = albert_actor_profile_note_from_equips_and_states



    if text =~ /<robot_protocol_skill\s*:\s*(\d+)\s*>/i

      default_skill = $1.to_i

    end



    if text =~ /<robot_protocol_interval\s*:\s*(\d+)\s*>/i

      interval = [$1.to_i, 1].max

    end



    text.scan(/<robot_protocol_if_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|

      conditionals.push([data[0].to_i, data[1].to_i])

    end



    return nil if default_skill <= 0 && conditionals.empty?

    return [default_skill, interval, conditionals]

  end



  #--------------------------------------------------------------------------

  # ● Mana Engine 目標

  #--------------------------------------------------------------------------

  def albert_mana_engine_target_rule(skill = nil)

    text = ""

    if skill != nil && skill.respond_to?(:note) && skill.note != nil

      text = skill.note.to_s

    end



    if text =~ /<mana_engine_target\s*:\s*lowest_mp\s*>/i

      return :lowest_mp

    end

    if text =~ /<mana_engine_target\s*:\s*mia\s*>/i

      return :mia

    end

    if text =~ /<mana_engine_target\s*:\s*actor\s+(\d+)\s*>/i

      return $1.to_i

    end

    if text =~ /<mana_engine_target_actor\s*:\s*(\d+)\s*>/i

      return $1.to_i

    end



    return ALBERT_ACTOR_PROFILE.mana_engine_target(self.id)

  end



  def albert_lowest_mp_party_member

    return nil if $game_party == nil

    targets = []



    for actor in $game_party.existing_members

      next if actor == nil

      next if actor.maxmp <= 0

      next if actor.mp >= actor.maxmp

      targets.push(actor)

    end



    return nil if targets.empty?



    best = targets[0]

    best_rate = best.mp.to_f / [best.maxmp, 1].max.to_f



    for actor in targets

      rate = actor.mp.to_f / [actor.maxmp, 1].max.to_f

      if rate < best_rate

        best = actor

        best_rate = rate

      end

    end



    return best

  end



  def albert_actor_profile_actor_in_party(actor_id)

    return nil if $game_actors == nil || $game_party == nil

    actor = $game_actors[actor_id.to_i]

    return nil if actor == nil

    return nil unless $game_party.members.include?(actor)

    return nil unless actor.exist?

    return actor

  end



  #--------------------------------------------------------------------------

  # ● 覆寫 Robot Protocol 目標

  #--------------------------------------------------------------------------

  if method_defined?(:albert_mx_robot_protocol_target)

    unless method_defined?(:albert_profile_old_robot_protocol_target)

      alias albert_profile_old_robot_protocol_target albert_mx_robot_protocol_target

    end



    def albert_mx_robot_protocol_target(skill, required_state_id = nil)

      if skill != nil && skill.for_friend? && albert_robot?

        mana_role = albert_mx_summon_role?("mana_engine")

        text = skill.respond_to?(:note) && skill.note != nil ? skill.note.to_s : ""

        mana_skill = (text =~ /<mana_engine_/i) ? true : false



        if mana_role || mana_skill

          rule = albert_mana_engine_target_rule(skill)



          if rule.is_a?(Integer)

            target = albert_actor_profile_actor_in_party(rule)

            return target if target != nil

          elsif rule == :mia

            target = albert_actor_profile_actor_in_party(2)

            return target if target != nil

          elsif rule == :lowest_mp

            target = albert_lowest_mp_party_member

            return target if target != nil

          end

        end

      end



      return albert_profile_old_robot_protocol_target(skill, required_state_id)

    end

  end

end



#==============================================================================

# ■ Mana Engine 技能效果

#------------------------------------------------------------------------------


#

#    <mana_engine_mp:25>                 目標回復 max MP 25%

#    <mana_engine_mp_flat:20>            目標回復固定 20 MP

#    <mana_engine_state 41:1>            目標增加 State 41 一層

#    <mana_engine_state_actor 2:41:1>    Actor 2 增加 State 41 一層

#    <mana_engine_od_actor 2:100>         Actor 2 增加 100 OD

#==============================================================================

class Game_Battler



  def albert_profile_actor_in_party(actor_id)

    return nil if $game_actors == nil || $game_party == nil

    actor = $game_actors[actor_id.to_i]

    return nil if actor == nil

    return nil unless $game_party.members.include?(actor)

    return nil unless actor.exist?

    return actor

  end



  def albert_profile_add_state_stack(target, state_id, amount)

    return false if target == nil

    return false if $data_states[state_id] == nil

    amount = amount.to_i

    return false if amount <= 0



    target.add_state(state_id)



    if amount > 1 && target.respond_to?(:increase_stack)

      target.increase_stack(state_id, amount - 1)

    end



    return true

  end



  def albert_apply_mana_engine_effect(user, skill)

    return false if skill == nil

    return false if @missed || @evaded || @skipped

    return false unless skill.respond_to?(:note)

    return false if skill.note == nil



    text = skill.note.to_s

    return false unless text =~ /<mana_engine_/i



    changed = false



    text.scan(/<mana_engine_mp\s*:\s*(\d+)\s*>/i) do |data|

      rate = data[0].to_i

      next if rate <= 0

      value = (maxmp.to_f * rate / 100.0).to_i

      if value > 0

        before = mp

        self.mp += value

        changed = true if mp != before

      end

    end



    text.scan(/<mana_engine_mp_flat\s*:\s*(\d+)\s*>/i) do |data|

      value = data[0].to_i

      if value > 0

        before = mp

        self.mp += value

        changed = true if mp != before

      end

    end



    text.scan(/<mana_engine_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|

      state_id = data[0].to_i

      amount   = data[1].to_i

      changed = true if albert_profile_add_state_stack(self, state_id, amount)

    end



    text.scan(/<mana_engine_state_actor\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*>/i) do |data|

      actor_id = data[0].to_i

      state_id = data[1].to_i

      amount   = data[2].to_i

      actor = albert_profile_actor_in_party(actor_id)

      changed = true if albert_profile_add_state_stack(actor, state_id, amount)

    end



    text.scan(/<mana_engine_od_actor\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|

      actor_id = data[0].to_i

      value    = data[1].to_i

      actor = albert_profile_actor_in_party(actor_id)

      next if actor == nil || value <= 0



      if defined?(ALBERT_CHARACTER_CORE) &&

         ALBERT_CHARACTER_CORE.respond_to?(:gain_od)

        gain = ALBERT_CHARACTER_CORE.gain_od(actor, value)

        changed = true if gain.to_i != 0

      end

    end



    return changed

  end

end



#==============================================================================

# ■ Clone 穩定度

#==============================================================================

class Game_Battler



  def albert_clone_stability_max

    return 0 unless actor? && albert_clone?

    return ALBERT_ACTOR_PROFILE.clone_stability_max(self.id)

  end



  def albert_clone_stability

    return 0 unless actor? && albert_clone?



    if @albert_clone_stability == nil

      @albert_clone_stability = albert_clone_stability_max

    end



    max_value = albert_clone_stability_max

    @albert_clone_stability = [[@albert_clone_stability.to_i, 0].max, max_value].min

    return @albert_clone_stability

  end



  def albert_clone_stability=(value)

    return unless actor? && albert_clone?



    max_value = albert_clone_stability_max

    @albert_clone_stability = [[value.to_i, 0].max, max_value].min

    albert_update_clone_instability_state

    albert_bshud_touch! if respond_to?(:albert_bshud_touch!)

  end



  def albert_reset_clone_stability

    return unless actor? && albert_clone?

    @albert_clone_stability = albert_clone_stability_max

    albert_update_clone_instability_state

    albert_bshud_touch! if respond_to?(:albert_bshud_touch!)

  end



  def albert_clone_stability_cost(skill)

    return 0 unless actor? && albert_clone?

    return 0 if skill == nil



    if skill.respond_to?(:note) && skill.note != nil

      text = skill.note.to_s

      if text =~ /<clone_stability_cost\s*:\s*(\d+)\s*>/i

        return $1.to_i

      end

    end



    return ALBERT_ACTOR_PROFILE.clone_action_cost(self.id)

  end



  def albert_clone_stability_allow_overdraw?(skill)

    return false if skill == nil

    return false unless skill.respond_to?(:note)

    return false if skill.note == nil

    return skill.note.to_s =~ /<clone_stability_allow_overdraw\s*>/i ? true : false

  end



  def albert_clone_stability_pay_on_success?(skill)

    return false if skill == nil

    return false unless skill.respond_to?(:note)

    return false if skill.note == nil

    return skill.note.to_s =~ /<clone_stability_pay_on_success\s*>/i ? true : false

  end



  def albert_clone_stability_enough?(skill)

    cost = albert_clone_stability_cost(skill)

    return true if cost <= 0

    return true if albert_clone_stability >= cost

    return true if albert_clone_stability_allow_overdraw?(skill)

    return false

  end



  def albert_add_clone_instability_stack(amount = 1)

    state_id = ALBERT_ACTOR_PROFILE::CLONE_INSTABILITY_STATE_ID

    return if state_id <= 0

    return if $data_states[state_id] == nil



    amount = [amount.to_i, 1].max



    unless state?(state_id)

      add_state(state_id)

      amount -= 1

    end



    if amount > 0 && respond_to?(:increase_stack)

      increase_stack(state_id, amount)

    end



    albert_bshud_touch! if respond_to?(:albert_bshud_touch!)

  end



  def albert_update_clone_instability_state

    return unless actor? && albert_clone?



    state_id = ALBERT_ACTOR_PROFILE::CLONE_INSTABILITY_STATE_ID

    return if state_id <= 0

    return if $data_states[state_id] == nil



    if albert_clone_stability <= 0 &&

       ALBERT_ACTOR_PROFILE::ADD_INSTABILITY_STATE_WHEN_EMPTY

      add_state(state_id) unless state?(state_id)

    elsif albert_clone_stability >= ALBERT_ACTOR_PROFILE::INSTABILITY_CLEAR_AT

      remove_state(state_id) if state?(state_id)

    end

  end



  def albert_pay_clone_stability(skill)

    return 0 unless actor? && albert_clone?



    cost = albert_clone_stability_cost(skill)

    return 0 if cost <= 0



    before = albert_clone_stability

    remain = before - cost

    overdraw = remain < 0



    @albert_clone_stability = [[remain, 0].max, albert_clone_stability_max].min



    if overdraw && albert_clone_stability_allow_overdraw?(skill)

      albert_add_clone_instability_stack(1)

    end



    albert_update_clone_instability_state

    albert_bshud_touch! if respond_to?(:albert_bshud_touch!)

    return cost

  end



  def albert_recover_clone_stability(value)

    return 0 unless actor? && albert_clone?



    value = value.to_i

    return 0 if value <= 0



    before = albert_clone_stability

    self.albert_clone_stability = before + value

    return albert_clone_stability - before

  end



  #--------------------------------------------------------------------------

  # ● Clone 技能是否可用

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_profile_old_skill_can_use)

    alias albert_profile_old_skill_can_use skill_can_use?

  end



  def skill_can_use?(skill)

    return false unless albert_profile_old_skill_can_use(skill)



    if actor? && albert_clone? &&

       ALBERT_ACTOR_PROFILE::BLOCK_SKILL_WHEN_STABILITY_NOT_ENOUGH

      return false unless albert_clone_stability_enough?(skill)

    end



    return true

  end

end



class Game_Actor < Game_Battler

  def clone_stability

    return albert_clone_stability

  end



  def clone_stability_max

    return albert_clone_stability_max

  end

end



#==============================================================================

# ■ 技能效果後處理


#   - Clone 行動成功旗標

#==============================================================================

class Game_Battler

  unless method_defined?(:albert_profile_old_skill_effect)

    alias albert_profile_old_skill_effect skill_effect

  end



  def skill_effect(user, skill)

    result = albert_profile_old_skill_effect(user, skill)



    success = (!@missed && !@evaded && !@skipped)



    if success && user != nil && user.respond_to?(:albert_clone?) && user.albert_clone?

      user.instance_variable_set(:@albert_profile_clone_action_success, true)

    end



    mana_changed = albert_apply_mana_engine_effect(user, skill)

    if mana_changed && user != nil

      user.instance_variable_set(:@albert_profile_clone_action_success, true) if

        user.respond_to?(:albert_clone?) && user.albert_clone?

    end



    return result

  end

end



#==============================================================================

# ■ Clone 穩定度傷害加成

#------------------------------------------------------------------------------


#

#    <bonus_if_clone_stability_above 50:30>

#    <bonus_per_clone_stability:0.2>

#    <bonus_if_clone_unstable:50>

#==============================================================================

class Game_Battler

  unless method_defined?(:albert_profile_old_make_obj_damage_value)

    alias albert_profile_old_make_obj_damage_value make_obj_damage_value

  end



  def make_obj_damage_value(user, obj)

    result = albert_profile_old_make_obj_damage_value(user, obj)



    return result if user == nil || obj == nil

    return result unless user.respond_to?(:albert_clone?) && user.albert_clone?

    return result unless obj.respond_to?(:note) && obj.note != nil



    text = obj.note.to_s

    bonus = 0.0



    text.scan(/<bonus_if_clone_stability_above\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      threshold = data[0].to_i

      value = data[1].to_i

      bonus += value if user.albert_clone_stability >= threshold

    end



    text.scan(/<bonus_per_clone_stability\s*:\s*(-?\d+(?:\.\d+)?)\s*>/i) do |data|

      rate = data[0].to_f

      bonus += user.albert_clone_stability * rate

    end



    state_id = ALBERT_ACTOR_PROFILE::CLONE_INSTABILITY_STATE_ID

    if state_id > 0 && user.state?(state_id)

      text.scan(/<bonus_if_clone_unstable\s*:\s*(-?\d+)\s*>/i) do |data|

        bonus += data[0].to_i

      end

    end



    return result if bonus == 0.0



    if @hp_damage != nil && @hp_damage > 0

      @hp_damage = (@hp_damage * (100.0 + bonus) / 100.0).to_i

    end



    if @mp_damage != nil && @mp_damage > 0

      @mp_damage = (@mp_damage * (100.0 + bonus) / 100.0).to_i

    end



    return result

  end

end



#==============================================================================

# ■ Scene_Battle：Clone 穩定度每次行動只處理一次

#==============================================================================

class Scene_Battle < Scene_Base

  unless method_defined?(:albert_profile_old_start)

    alias albert_profile_old_start start

  end



  def start

    result = albert_profile_old_start



    if ALBERT_ACTOR_PROFILE::RESET_CLONE_STABILITY_ON_BATTLE_START &&

       $game_party != nil

      for actor in $game_party.members

        next if actor == nil

        if actor.respond_to?(:albert_clone?) && actor.albert_clone?

          actor.albert_reset_clone_stability

        end

      end

    end



    return result

  end



  unless method_defined?(:albert_profile_old_execute_action_skill)

    alias albert_profile_old_execute_action_skill execute_action_skill

  end



  def execute_action_skill(*args)

    battler = @active_battler

    skill = nil



    begin

      skill = battler.action.skill if battler != nil && battler.action != nil

    rescue

      skill = nil

    end



    clone_user = battler != nil && skill != nil &&

                 battler.respond_to?(:albert_clone?) && battler.albert_clone?



    if clone_user

      battler.instance_variable_set(:@albert_profile_clone_action_success, false)



      unless battler.albert_clone_stability_pay_on_success?(skill)

        battler.albert_pay_clone_stability(skill)

      end

    end



    result = nil



    begin

      result = albert_profile_old_execute_action_skill(*args)



      if clone_user

        success = battler.instance_variable_get(:@albert_profile_clone_action_success) ? true : false



        if success && battler.albert_clone_stability_pay_on_success?(skill)

          battler.albert_pay_clone_stability(skill)

        end



        if skill.respond_to?(:note) && skill.note != nil

          text = skill.note.to_s



          if success

            text.scan(/<clone_stability_refund\s*:\s*(\d+)\s*>/i) do |data|

              battler.albert_recover_clone_stability(data[0].to_i)

            end

          end



          text.scan(/<clone_stability_recover\s*:\s*(\d+)\s*>/i) do |data|

            battler.albert_recover_clone_stability(data[0].to_i)

          end

        end

      end



      return result

    ensure

      if clone_user

        battler.instance_variable_set(:@albert_profile_clone_action_success, false)

      end

    end

  end

end



#==============================================================================

# ■ BattleStateHUD：顯示 Clone 穩定度

#==============================================================================

if defined?(AlbertBattleStateHUD)

  module AlbertBattleStateHUD

    SHOW_CLONE_STABILITY_INFO = true unless const_defined?(:SHOW_CLONE_STABILITY_INFO)



    def self.clone_stability_rows(battler)

      rows = []

      return rows unless SHOW_CLONE_STABILITY_INFO

      return rows unless battler.is_a?(Game_Actor)

      return rows unless battler.respond_to?(:albert_clone?) && battler.albert_clone?

      return rows unless battler.respond_to?(:albert_clone_stability)



      current = battler.albert_clone_stability.to_i

      max_value = battler.albert_clone_stability_max.to_i

      rows << ["穩定度", "#{current}/#{max_value}"]

      return rows

    end



    # Phase 13：不再 alias extra_info_rows。
    # clone_stability_rows 由 FS_BattleStateHUD_Authority 在 Runtime 晚綁定收集。

  end

end



#==============================================================================

# ■ Summon Follow-up / SummonChain3：Clone 追擊也必須支付穩定度

#------------------------------------------------------------------------------

#  CharacterMechanicCore 的召喚追擊不走一般 execute_action_skill，

#  而是直接呼叫 albert_cc_execute_summon_followup。

#  若不補這段，Clone 作為第三段追擊時會免費繞過穩定度成本。

#==============================================================================

class Scene_Battle < Scene_Base

  if method_defined?(:albert_cc_execute_summon_followup)

    unless method_defined?(:albert_profile_old_execute_summon_followup)

      alias albert_profile_old_execute_summon_followup albert_cc_execute_summon_followup

    end



    def albert_cc_execute_summon_followup(summon, follow_skill, targets)

      clone_user = summon != nil && follow_skill != nil &&

                   summon.respond_to?(:albert_clone?) && summon.albert_clone?



      if clone_user

        return false unless summon.albert_clone_stability_enough?(follow_skill)

        summon.instance_variable_set(:@albert_profile_clone_action_success, false)



        unless summon.albert_clone_stability_pay_on_success?(follow_skill)

          summon.albert_pay_clone_stability(follow_skill)

        end

      end



      result = nil



      begin

        result = albert_profile_old_execute_summon_followup(summon, follow_skill, targets)



        if clone_user

          effect_success = summon.instance_variable_get(:@albert_profile_clone_action_success) ? true : false



          if effect_success && summon.albert_clone_stability_pay_on_success?(follow_skill)

            summon.albert_pay_clone_stability(follow_skill)

          end



          if follow_skill.respond_to?(:note) && follow_skill.note != nil

            text = follow_skill.note.to_s



            if effect_success

              text.scan(/<clone_stability_refund\s*:\s*(\d+)\s*>/i) do |data|

                summon.albert_recover_clone_stability(data[0].to_i)

              end

            end



            text.scan(/<clone_stability_recover\s*:\s*(\d+)\s*>/i) do |data|

              summon.albert_recover_clone_stability(data[0].to_i)

            end

          end

        end



        return result

      ensure

        if clone_user

          summon.instance_variable_set(:@albert_profile_clone_action_success, false)

        end

      end

    end

  end

end



