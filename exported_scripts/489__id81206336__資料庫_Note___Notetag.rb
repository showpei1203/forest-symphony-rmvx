# -*- coding: utf-8 -*-
#===============================================================================
# ■ Albert_RMVX_REFERENCE_All_NoteTags_v1_1_Antagonist_TC
#-------------------------------------------------------------------------------
#  Forest Symphony 森之交響曲
#  目前 Main 以上有效腳本之「資料庫 Note / Notetag」長篇索引
#-------------------------------------------------------------------------------
# 【用途】
#  把這一頁直接放進 RPG Maker VX 腳本庫，純註釋，不執行任何功能。
#  重新規劃技能、物品、武器、防具、Actor、Enemy、State 時可直接搜尋。
#
# 【範圍】
#  依據 All_Scripts_Export(7).txt，僅整理 Main 以上有效腳本。
#  Main 以下腳本依專案規則視為無效，不納入正式功能索引。
#
# 【閱讀方式】
#  第一部：本專案最重要、最常用的核心 Note，逐項解釋。
#  第二部：依原腳本頁分組的完整 Literal Tag 索引，避免漏掉舊素材腳本。
#
# 【重要提醒】
#  某些舊腳本會同時接受全形括號、日本語標籤、英文同義字或多種格式。
#  下方「完整索引」保留腳本中實際出現的 Literal Tag；最終採用前仍應依
#  對應腳本的註解確認語意。人類給同一功能取三種名字已經夠麻煩，舊 RGSS
#  腳本作者又非常熱衷讓它們同時存在。
#===============================================================================

# 第一部　目前專案核心 Note Tag 詳解
#===============================================================================
#
# A. ComboCore：傷害、狀態、ATB、OD、Cover、Mana Shield
#-------------------------------------------------------------------------------
# 語法：<bonus_vs_state 31:50>
# 適用：Skill
# 功能：目標有 State 31 時，傷害 +50%。
# 範例：<bonus_vs_state 31:50>
#
# 語法：<bonus_if_user_state 40:30>
# 適用：Skill
# 功能：使用者有 State 40 時，傷害 +30%。
# 範例：<bonus_if_user_state 40:30>
#
# 語法：<bonus_per_target_state:10>
# 適用：Skill
# 功能：目標每多 1 個可見狀態，傷害額外 +10%。
# 範例：<bonus_per_target_state:10>
#
# 語法：<bonus_if_state_count 3:50>
# 適用：Skill
# 功能：目標狀態數達 3 個時，傷害 +50%。
# 範例：<bonus_if_state_count 3:50>
#
# 語法：<bonus_vs_type robot:50>
# 適用：Skill
# 功能：對 Robot 類召喚物增傷 50%。pokemon / clone 同理。
# 範例：<bonus_vs_type robot:50>
#
# 語法：<detonate_state 31:150>
# 適用：Skill
# 功能：依目標 State 31 疊層數，每層追加 150 固定傷害。
# 範例：<detonate_state 31:150>
#
# 語法：<consume_state 31>
# 適用：Skill
# 功能：技能成功後消耗目標 State 31。
# 範例：<consume_state 31>
#
# 語法：<damage_per_stack:150>
# 適用：Skill
# 功能：搭配舊式疊層爆發流程，每層固定傷害 150。
# 範例：<damage_per_stack:150>
#
# 語法：<spread_state 31:2>
# 適用：Skill
# 功能：把 State 31 擴散到最多 2 個其他目標。
# 範例：<spread_state 31:2>
#
# 語法：<spread_state 31:2:50>
# 適用：Skill
# 功能：擴散 State 31 到 2 個目標，並依腳本參數使用 50% 規則。
# 範例：<spread_state 31:2:50>
#
# 語法：<drift_state 31:1>
# 適用：Skill
# 功能：把 State 31 從原目標飄移到 1 個其他目標。
# 範例：<drift_state 31:1>
#
# 語法：<convert_state 31:32>
# 適用：Skill
# 功能：把 State 31 轉換為 State 32。
# 範例：<convert_state 31:32>
#
# 語法：<spread_on_death:2>
# 適用：State
# 功能：持有者死亡時，把此 State 擴散到最多 2 名其他目標。
# 範例：<spread_on_death:2>
#
# 語法：<drift_on_death:1>
# 適用：State
# 功能：持有者死亡時，把此 State 飄移到 1 名其他目標。
# 範例：<drift_on_death:1>
#
# 語法：<state_chance 31:20>
# 適用：Skill
# 功能：施加 State 31 的成功率額外 +20%。
# 範例：<state_chance 31:20>
#
# 語法：<state_chance_vs_state 31,32:25>
# 適用：Skill
# 功能：施加 State 31 時，若目標已有 State 32，再 +25% 成功率。
# 範例：<state_chance_vs_state 31,32:25>
#
# 語法：<state_chance_if_user_state 31,40:30>
# 適用：Skill
# 功能：施加 State 31 時，若使用者有 State 40，再 +30%。
# 範例：<state_chance_if_user_state 31,40:30>
#
# 語法：<state_chance_if_od 31,50:20>
# 適用：Skill
# 功能：使用者 OD 達 50% 時，施加 State 31 成功率 +20%。
# 範例：<state_chance_if_od 31,50:20>
#
# 語法：<state_chance_per_od_percent 31:0.2>
# 適用：Skill
# 功能：每 1% OD，State 31 成功率額外 +0.2%。
# 範例：<state_chance_per_od_percent 31:0.2>
#
# 語法：<atb_shift:-25>
# 適用：Skill
# 功能：直接削減目標 25% ATB。正值則增加。
# 範例：<atb_shift:-25>
#
# 語法：<atb_bonus:50>
# 適用：Skill
# 功能：ATB 變化幅度 +50%。
# 範例：<atb_bonus:50>
#
# 語法：<atb_bonus_vs_state 31:50>
# 適用：Skill
# 功能：目標有 State 31 時，ATB 變化幅度 +50%。
# 範例：<atb_bonus_vs_state 31:50>
#
# 語法：<atb_bonus_if_user_state 40:50>
# 適用：Skill
# 功能：使用者有 State 40 時，ATB 變化幅度 +50%。
# 範例：<atb_bonus_if_user_state 40:50>
#
# 語法：<atb_bonus_per_target_state:10>
# 適用：Skill
# 功能：目標每個 State 讓 ATB 變化幅度 +10%。
# 範例：<atb_bonus_per_target_state:10>
#
# 語法：<bonus_if_od 50:30>
# 適用：Skill
# 功能：使用者 OD 達 50% 時，傷害 +30%。
# 範例：<bonus_if_od 50:30>
#
# 語法：<bonus_per_od_percent:0.5>
# 適用：Skill
# 功能：每 1% OD，傷害 +0.5%。
# 範例：<bonus_per_od_percent:0.5>
#
# 語法：<bonus_per_od_100:10>
# 適用：Skill
# 功能：每 100 OD，傷害 +10%。
# 範例：<bonus_per_od_100:10>
#
# 語法：<reduce_damage_if_od 50:20>
# 適用：Actor/Equipment/State
# 功能：OD 達 50% 時，受到傷害降低 20%。
# 範例：<reduce_damage_if_od 50:20>
#
# 語法：<reduce_damage_per_od_percent:0.2>
# 適用：Actor/Equipment/State
# 功能：每 1% OD，受到傷害降低 0.2%。
# 範例：<reduce_damage_per_od_percent:0.2>
#
# 語法：<atb_bonus_if_od 50:50>
# 適用：Skill
# 功能：OD 達 50% 時，ATB 變化幅度 +50%。
# 範例：<atb_bonus_if_od 50:50>
#
# 語法：<atb_bonus_per_od_percent:0.5>
# 適用：Skill
# 功能：每 1% OD，ATB 變化幅度 +0.5%。
# 範例：<atb_bonus_per_od_percent:0.5>
#
# 語法：<mana_shield 500:50>
# 適用：State
# 功能：建立容量 500 的 Mana Shield，吸收 50% 傷害。
# 範例：<mana_shield 500:50>
#
# 語法：<COVER 2 50>
# 適用：State
# 功能：Cover 規則，type 與 param 依腳本說明設定。
# 範例：<COVER 2 50>
#
#
# B. Character Mechanic Core：六位主角核心
#-------------------------------------------------------------------------------
# 語法：<cc_od_summon_action:80>
# 適用：Actor/Equipment/State/Skill
# 功能：召喚物正常完成一次行動時，喬伊獲得 80 OD。
# 範例：<cc_od_summon_action:80>
#
# 語法：<cc_od_cover:60>
# 適用：Actor/Equipment/State/Skill
# 功能：艾薇成功 Cover 承傷時額外獲得 60 OD。
# 範例：<cc_od_cover:60>
#
# 語法：<cc_od_atb_per_10:40>
# 適用：Actor/Equipment/State/Skill
# 功能：艾卓每實際削減 10% ATB，獲得 40 OD。
# 範例：<cc_od_atb_per_10:40>
#
# 語法：<cc_od_state_stack:70>
# 適用：Actor/Equipment/State/Skill
# 功能：維娜每成功新增 1 層 State，獲得 70 OD。
# 範例：<cc_od_state_stack:70>
#
# 語法：<cc_od_break_point:50>
# 適用：Actor/Equipment/State/Skill
# 功能：泰勒每增加 1 點破勢，獲得 50 OD。
# 範例：<cc_od_break_point:50>
#
# 語法：<cc_od_break:200>
# 適用：Actor/Equipment/State/Skill
# 功能：真正觸發崩防時，泰勒額外獲得 200 OD。
# 範例：<cc_od_break:200>
#
# 語法：<cc_od_heal_percent:5>
# 適用：Actor/Equipment/State/Skill
# 功能：米亞依有效治療量換算 OD。
# 範例：<cc_od_heal_percent:5>
#
# 語法：<cc_od_overheal_percent:3>
# 適用：Actor/Equipment/State/Skill
# 功能：米亞依溢療量換算 OD。
# 範例：<cc_od_overheal_percent:3>
#
# 語法：<heal_bonus:15>
# 適用：Skill
# 功能：治療量 +15%。
# 範例：<heal_bonus:15>
#
# 語法：<heal_bonus_if_od 50:20>
# 適用：Skill
# 功能：OD 達 50% 時，治療量 +20%。
# 範例：<heal_bonus_if_od 50:20>
#
# 語法：<heal_bonus_per_od_percent:0.2>
# 適用：Skill
# 功能：每 1% OD，治療量 +0.2%。
# 範例：<heal_bonus_per_od_percent:0.2>
#
# 語法：<overheal_to_od:50>
# 適用：Skill
# 功能：溢療量的 50% 轉換為 OD。
# 範例：<overheal_to_od:50>
#
# 語法：<overheal_to_mp:30>
# 適用：Skill
# 功能：溢療量的 30% 轉換為目標 MP。
# 範例：<overheal_to_mp:30>
#
# 語法：<overheal_to_user_mp:30>
# 適用：Skill
# 功能：溢療量的 30% 轉換為使用者 MP。
# 範例：<overheal_to_user_mp:30>
#
# 語法：<overheal_to_state 41:10>
# 適用：Skill
# 功能：每累積指定溢療門檻，增加 State 41 疊層。
# 範例：<overheal_to_state 41:10>
#
# 語法：<overheal_to_shield 52:50>
# 適用：Skill
# 功能：把 50% 溢療轉為 State 52 的動態 Mana Shield 容量。
# 範例：<overheal_to_shield 52:50>
#
# 語法：<break_power:1>
# 適用：Skill
# 功能：此技能增加 1 點破勢。
# 範例：<break_power:1>
#
# 語法：<break_state:50>
# 適用：Skill
# 功能：指定破勢進度 State 50。
# 範例：<break_state:50>
#
# 語法：<broken_state:51>
# 適用：Skill
# 功能：達門檻後施加崩防 State 51。
# 範例：<broken_state:51>
#
# 語法：<break_threshold:5>
# 適用：Skill/Enemy
# 功能：技能端為 Break 門檻；Enemy 端可覆蓋個別門檻。
# 範例：<break_threshold:5>
#
# 語法：<break_bonus_if_od 50:1>
# 適用：Skill
# 功能：OD 達 50% 時，額外 +1 Break Power。
# 範例：<break_bonus_if_od 50:1>
#
# 語法：<summon_followup 18:241:700:200>
# 適用：Skill
# 功能：喬伊使用技能後，Actor 18 以 Skill 241 追擊；需求 700 OD，成功消耗 200。
# 範例：<summon_followup 18:241:700:200>
#
#
# C. Mechanic Expansion：六角色第二層與召喚物 AI
#-------------------------------------------------------------------------------
# 語法：<summon_type:pokemon>
# 適用：Actor/Equipment/State
# 功能：把召喚物分類為 Pokémon。robot / clone 同理。
# 範例：<summon_type:pokemon>
#
# 語法：<summon_role:poison_starter>
# 適用：Actor/Equipment/State
# 功能：賦予召喚物功能角色標籤，可供喬伊自動選擇。
# 範例：<summon_role:poison_starter>
#
# 語法：<summon_followup_type pokemon:241:700:200>
# 適用：Skill
# 功能：喬伊從場上 Pokémon 類召喚物中自動挑一隻追擊。
# 範例：<summon_followup_type pokemon:241:700:200>
#
# 語法：<summon_followup_role poison_starter:241:700:200>
# 適用：Skill
# 功能：依 summon_role 自動挑選追擊者。
# 範例：<summon_followup_role poison_starter:241:700:200>
#
# 語法：<summon_chain_type 1:pokemon:241:700:0>
# 適用：Skill
# 功能：三段召喚鏈第 1 棒自動找 Pokémon。
# 範例：<summon_chain_type 1:pokemon:241:700:0>
#
# 語法：<summon_chain_role 2:corrosion_engine:250:700:100>
# 適用：Skill
# 功能：第 2 棒依功能角色自動選擇。
# 範例：<summon_chain_role 2:corrosion_engine:250:700:100>
#
# 語法：<store_cover_damage:150>
# 適用：Actor/Equipment/State
# 功能：艾薇記錄實際 Cover 損血的 150% 為蓄痛。
# 範例：<store_cover_damage:150>
#
# 語法：<cover_store_cap_percent:300>
# 適用：Actor/Equipment/State
# 功能：蓄痛上限為自身最大 HP 的 300%。
# 範例：<cover_store_cap_percent:300>
#
# 語法：<revenge_from_cover:50>
# 適用：Skill
# 功能：追加目前蓄痛值 50% 的固定傷害。
# 範例：<revenge_from_cover:50>
#
# 語法：<consume_stored_cover>
# 適用：Skill
# 功能：技能成功後清空蓄痛。
# 範例：<consume_stored_cover>
#
# 語法：<atb_bonus_if_target_atb_above 80:50>
# 適用：Skill
# 功能：目標 ATB ≥80% 時，ATB 變化幅度 +50%。
# 範例：<atb_bonus_if_target_atb_above 80:50>
#
# 語法：<bonus_if_target_atb_above 80:30>
# 適用：Skill
# 功能：目標 ATB ≥80% 時，傷害 +30%。
# 範例：<bonus_if_target_atb_above 80:30>
#
# 語法：<atb_interrupt_threshold:80>
# 適用：Skill
# 功能：目標原本 ≥80% ATB，技能後掉到門檻下視為成功打斷。
# 範例：<atb_interrupt_threshold:80>
#
# 語法：<atb_interrupt_od:100>
# 適用：Skill
# 功能：成功打斷後，艾卓獲得 100 OD。
# 範例：<atb_interrupt_od:100>
#
# 語法：<interrupt_if_target_atb_above:80>
# 適用：Skill
# 功能：目標 ATB 高於門檻時觸發打斷型判定。
# 範例：<interrupt_if_target_atb_above:80>
#
# 語法：<detonate_state_percent 31:2>
# 適用：Skill
# 功能：State 31 每層按目標最大 HP 2% 追加爆發。
# 範例：<detonate_state_percent 31:2>
#
# 語法：<detonate_state_spi 31:120>
# 適用：Skill
# 功能：State 31 每層按使用者 SPI 120% 追加爆發。
# 範例：<detonate_state_spi 31:120>
#
# 語法：<detonate_state_atk 31:120>
# 適用：Skill
# 功能：State 31 每層按使用者 ATK 120% 追加爆發。
# 範例：<detonate_state_atk 31:120>
#
# 語法：<detonate_cap:5000>
# 適用：Skill
# 功能：限制本次擴充爆發追加傷害上限。
# 範例：<detonate_cap:5000>
#
# 語法：<state_dynamic_resist>
# 適用：Enemy
# 功能：啟用 Boss 動態異常抗性。
# 範例：<state_dynamic_resist>
#
# 語法：<state_dynamic_resist_states:31,32,33>
# 適用：Enemy
# 功能：只讓列出的 State 進入動態抗性。
# 範例：<state_dynamic_resist_states:31,32,33>
#
# 語法：<state_dynamic_resist_all>
# 適用：Enemy
# 功能：所有可用 State 都進入動態抗性。
# 範例：<state_dynamic_resist_all>
#
# 語法：<dynamic_resist>
# 適用：State
# 功能：標記此 State 可被動態異常抗性管理。
# 範例：<dynamic_resist>
#
# 語法：<control_state>
# 適用：State
# 功能：把此 State 視為控制類異常，納入動態抗性。
# 範例：<control_state>
#
# 語法：<state_resist_step:25>
# 適用：Enemy
# 功能：每成功一次，該 State 的成功率降低 25 個百分點。
# 範例：<state_resist_step:25>
#
# 語法：<state_resist_min:10>
# 適用：Enemy
# 功能：動態抗性最低成功率為 10%。
# 範例：<state_resist_min:10>
#
# 語法：<state_resist_recover:1>
# 適用：Enemy
# 功能：Boss 每完成一次有效行動，抗性等級回復 1。
# 範例：<state_resist_recover:1>
#
# 語法：<break_resist:50>
# 適用：Enemy
# 功能：受到的 Break Power 降低 50%。
# 範例：<break_resist:50>
#
# 語法：<break_immune>
# 適用：Enemy
# 功能：完全免疫 Break Power。
# 範例：<break_immune>
#
# 語法：<break_recover:1>
# 適用：Enemy
# 功能：每完成一次有效行動，破勢進度下降 1。
# 範例：<break_recover:1>
#
# 語法：<break_recover_state:50>
# 適用：Enemy
# 功能：指定自然回復的 Break 進度 State。
# 範例：<break_recover_state:50>
#
# 語法：<consume_broken>
# 適用：Skill
# 功能：成功命中後消耗目標的崩防 State。
# 範例：<consume_broken>
#
# 語法：<bonus_per_user_state_stack 41:15>
# 適用：Skill
# 功能：使用者每有 1 層 State 41，傷害 +15%。
# 範例：<bonus_per_user_state_stack 41:15>
#
# 語法：<consume_user_state 41:3>
# 適用：Skill
# 功能：技能成功後消耗使用者 State 41 的 3 層。
# 範例：<consume_user_state 41:3>
#
# 語法：<ai_bonus_vs_state 31:100>
# 適用：Skill
# 功能：有效目標有 State 31 時，AI 評價 +100。
# 範例：<ai_bonus_vs_state 31:100>
#
# 語法：<ai_require_state:31>
# 適用：Skill
# 功能：沒有合法目標擁有 State 31 時，AI 不考慮此技能。
# 範例：<ai_require_state:31>
#
# 語法：<ai_prefer_stack_below 31:5>
# 適用：Skill
# 功能：優先選擇 State 31 疊層低於 5 的目標。
# 範例：<ai_prefer_stack_below 31:5>
#
# 語法：<robot_protocol_skill:241>
# 適用：Actor/Equipment/State
# 功能：Robot 協議預設技能 ID 241。
# 範例：<robot_protocol_skill:241>
#
# 語法：<robot_protocol_interval:3>
# 適用：Actor/Equipment/State
# 功能：每第 3 次 AI 行動進入協議回合。
# 範例：<robot_protocol_interval:3>
#
# 語法：<robot_protocol_if_state 31:241>
# 適用：Actor/Equipment/State
# 功能：協議回合若合法目標有 State 31，優先 Skill 241。
# 範例：<robot_protocol_if_state 31:241>
#
#
# D. SummonChain3：三段召喚追擊
#-------------------------------------------------------------------------------
# 語法：<summon_chain 1:18:241:700:0>
# 適用：Skill
# 功能：第1棒：Actor18 使用 Skill241；需求700 OD；不額外消耗。
# 範例：<summon_chain 1:18:241:700:0>
#
# 語法：<chain_require 2:state:31>
# 適用：Skill
# 功能：第2棒要求目標已有 State 31。
# 範例：<chain_require 2:state:31>
#
# 語法：<chain_require 2:not_state:31>
# 適用：Skill
# 功能：第2棒要求目標沒有 State 31。
# 範例：<chain_require 2:not_state:31>
#
# 語法：<chain_require 3:hp_below:30>
# 適用：Skill
# 功能：第3棒要求目標 HP 低於 30%。
# 範例：<chain_require 3:hp_below:30>
#
# 語法：<chain_require 3:broken>
# 適用：Skill
# 功能：第3棒要求目標處於崩防。
# 範例：<chain_require 3:broken>
#
# 語法：<chain_require 2:damage:500>
# 適用：Skill
# 功能：上一棒至少造成 500 傷害。
# 範例：<chain_require 2:damage:500>
#
# 語法：<chain_require 2:added_state:31>
# 適用：Skill
# 功能：上一棒新增 State 31。
# 範例：<chain_require 2:added_state:31>
#
# 語法：<chain_require 2:stack_up:31>
# 適用：Skill
# 功能：上一棒使 State 31 疊層增加。
# 範例：<chain_require 2:stack_up:31>
#
# 語法：<chain_require 2:weak>
# 適用：Skill
# 功能：上一棒打中弱點。
# 範例：<chain_require 2:weak>
#
# 語法：<chain_require 2:critical>
# 適用：Skill
# 功能：上一棒暴擊。
# 範例：<chain_require 2:critical>
#
# 語法：<chain_require 2:kill>
# 適用：Skill
# 功能：上一棒擊殺目標。
# 範例：<chain_require 2:kill>
#
# 語法：<chain_require 1:type:pokemon>
# 適用：Skill
# 功能：第1棒追擊者必須是 Pokémon 類。
# 範例：<chain_require 1:type:pokemon>
#
#
# E. Battle State HUD
#-------------------------------------------------------------------------------
# 語法：<hud_priority:100>
# 適用：State
# 功能：HUD 顯示優先度。
# 範例：<hud_priority:100>
#
# 語法：<hud_hide>
# 適用：State
# 功能：不顯示在戰鬥 HUD。
# 範例：<hud_hide>
#
# 語法：<hud_show>
# 適用：State
# 功能：強制顯示。
# 範例：<hud_show>
#
# 語法：<hud_icon:123>
# 適用：State
# 功能：戰鬥 HUD 改用 Icon 123。
# 範例：<hud_icon:123>
#
# 語法：<hud_name:劇毒>
# 適用：State
# 功能：詳細視窗顯示名稱改為「劇毒」。
# 範例：<hud_name:劇毒>
#
# 語法：<hud_detail>
# 適用：State
# 功能：強制進入詳細視窗。
# 範例：<hud_detail>
#
# 語法：<hud_detail_text:每層提高毒爆傷害20%>
# 適用：State
# 功能：追加自訂詳細說明。
# 範例：<hud_detail_text:每層提高毒爆傷害20%>
#
# 語法：<hud_show_turns>
# 適用：State
# 功能：即使沒有其他特殊資訊，也因剩餘回合顯示詳細列。
# 範例：<hud_show_turns>
#
#
# F. ATB 動態抗性
#-------------------------------------------------------------------------------
# 語法：<atb_dynamic_resist>
# 適用：Enemy
# 功能：啟用動態 ATB 延遲抗性。
# 範例：<atb_dynamic_resist>
#
# 語法：<atb_resist_start:0>
# 適用：Enemy
# 功能：初始抗性等級。
# 範例：<atb_resist_start:0>
#
# 語法：<atb_resist_max:4>
# 適用：Enemy
# 功能：最大抗性等級。
# 範例：<atb_resist_max:4>
#
# 語法：<atb_resist_floor:10>
# 適用：Enemy
# 功能：ATB 最低保護線 10%。
# 範例：<atb_resist_floor:10>
#
# 語法：<atb_resist_recover:1>
# 適用：Enemy
# 功能：每完成一次有效行動回復 1 級抗性。
# 範例：<atb_resist_recover:1>
#
#
# G. Pokémon / Actor AutoBattleAI
#-------------------------------------------------------------------------------
# 語法：<AI除外>
# 適用：Skill
# 功能：AI 不把此技能列入候補。
# 範例：<AI除外>
#
# 語法：<AI評価:8>
# 適用：Skill
# 功能：調整 AI 評價權重。
# 範例：<AI評価:8>
#
#
# H. Enemy Target / Threat
#-------------------------------------------------------------------------------
# 語法：<summon_guard:2>
# 適用：Skill
# 功能：敵方技能優先鎖定指定召喚物群組。
# 範例：<summon_guard:2>
#
# 語法：<state_focus:31>
# 適用：Skill
# 功能：優先攻擊帶有 State 31 的目標。
# 範例：<state_focus:31>
#
# 語法：<dps_focus:800>
# 適用：Skill
# 功能：若有角色累積 DPS 達門檻，優先追擊高 DPS 目標。
# 範例：<dps_focus:800>
#
# 語法：<threat_target>
# 適用：Skill
# 功能：啟用軟式威脅值加權選擇。
# 範例：<threat_target>
#
# 語法：<state_threat:31,500>
# 適用：Skill
# 功能：目標有 State 31 時威脅值 +500。
# 範例：<state_threat:31,500>
#
# 語法：<dps_threat:100,10>
# 適用：Skill
# 功能：每 100 傷害貢獻 +10 威脅值。
# 範例：<dps_threat:100,10>
#
# 語法：<target priority: 2>
# 適用：Enemy/State
# 功能：玩家手動選敵時，只能選目前最高優先級群組。
# 範例：<target priority: 2>
#
# 語法：<ignore target priority>
# 適用：Skill/Item
# 功能：此技能／物品無視目標優先級限制。
# 範例：<ignore target priority>
#
#===============================================================================
# ===============================================================================
# 【AntagonistMechanicCore_v1_0｜反派共用機制】
# ===============================================================================
#
# 本節是新加入的反派核心 Note。
# 功能分為：
#
#   1. 觀律
#   2. 雙弦
#   3. 改譜
#   4. 大諧律
#
# -------------------------------------------------------------------------------
# 【Enemy Note｜觀律】
# -------------------------------------------------------------------------------
#
# <observe_repeat_state:120>
#
# 重複行為時，
# 對該主要 Actor 增加 State 120。
#
# 範例：
#   <observe_repeat_state:120>
#
# -------------------------------------------------------------------------------
#
# <observe_same_skill:1>
#
# 重複同一 Skill 時，
# 觀律 State 增加 1 層。
#
# 範例：
#   <observe_same_skill:1>
#
# -------------------------------------------------------------------------------
#
# <observe_same_element:1>
#
# 重複同一屬性時，
# 觀律 State 增加 1 層。
#
# 範例：
#   <observe_same_element:1>
#
# -------------------------------------------------------------------------------
#
# <observe_stack_both>
#
# 若同一次行動同時符合：
#   ・同 Skill
#   ・同 Element
#
# 允許兩種觀律疊層同時累積。
#
# -------------------------------------------------------------------------------
#
# <observe_if_state:150>
#
# 只有敵人自己擁有 State 150 時，
# 觀律功能才啟動。
#
# 適合：
#   賽勒斯第一階段「全知儀」。
#
# -------------------------------------------------------------------------------
#
# <observe_main_actors_only>
#
# 只觀察主要 Actor 1～6。
#
# 召喚物 Actor 7+ 不累積觀律，
# 因此可作為換節奏與避免重複模式的戰術緩衝。
#
# -------------------------------------------------------------------------------
# 【Skill Note｜雙弦】
# -------------------------------------------------------------------------------
#
# <double_thread:121,40>
#
# 第一個參數：
#   121 = 雙弦標記 State ID。
#
# 第二個參數：
#   40 = 連帶傷害比例 40%。
#
# 規則：
#   技能命中的前兩名 Actor 被連結。
#
# 其中一人實際失去 HP 時，
# 另一人承受該「實際 HP 損失」的 40%。
#
# 不是原始傷害40%。
#
# 範例：
#   <double_thread:121,40>
#
# -------------------------------------------------------------------------------
#
# <double_thread_animation:45>
#
# 雙弦連帶傷害／連結時使用 Animation 45。
#
# 範例：
#   <double_thread_animation:45>
#
# -------------------------------------------------------------------------------
#
# <double_thread_lethal>
#
# 允許雙弦連帶傷害致死。
#
# 沒有此 Note 時：
#   雙弦連帶傷害預設最多把對象打到 1 HP。
#
# 建議：
#   只給Boss終結技或高階法則。
#
# -------------------------------------------------------------------------------
# 【Skill Note｜改譜】
# -------------------------------------------------------------------------------
#
# <rewrite_actor 1:130>
# <rewrite_actor 2:131>
# <rewrite_actor 3:132>
# <rewrite_actor 4:133>
# <rewrite_actor 5:134>
# <rewrite_actor 6:135>
#
# 依命中 Actor ID，
# 套用不同 State。
#
# 範例：
#   Actor 1 喬伊 → 130
#   Actor 2 米亞 → 131
#   Actor 3 艾卓 → 132
#   Actor 4 維娜 → 133
#   Actor 5 艾薇 → 134
#   Actor 6 泰勒 → 135
#
# -------------------------------------------------------------------------------
#
# <rewrite_default_state:139>
#
# 若命中的 Actor 沒有個別 rewrite_actor 對應，
# 套用 State 139。
#
# 適合召喚物／其他角色。
#
# -------------------------------------------------------------------------------
# 【Enemy Note｜大諧律】
# -------------------------------------------------------------------------------
#
# <law_cycle_states:140,141,142,143>
#
# 指定法則循環 State 清單。
#
# -------------------------------------------------------------------------------
#
# <law_cycle_actions:2>
#
# 每完成 2 次有效行動，
# 切換到下一個法則 State。
#
# 流程：
#   140 → 141 → 142 → 143 → 140
#
# -------------------------------------------------------------------------------
#
# <law_cycle_if_state:151>
#
# 只有敵人擁有 State 151 時，
# 才執行法則循環。
#
# 適合：
#   賽勒斯第二階段「大諧律」。
#
# -------------------------------------------------------------------------------
# 【賽勒斯建議整合】
# -------------------------------------------------------------------------------
#
# 第一階段：
#   State 150
#   啟動觀律。
#
# 第二階段：
#   State 151
#   啟動大諧律。
#
# 第三階段：
#   State 152
#   移除151，
#   清除140～143，
#   停止法則循環。
#
# ===============================================================================

# 第二部　Main 以上有效腳本：Literal Note Tag 完整索引
#===============================================================================
#
# 說明：以下只收錄來源腳本中真正出現的 <...> 文字，並排除明顯 regex
#       片段與程式碼誤判。適用欄位為靜態推定，核心腳本請以前半部為準。
#
#===============================================================================
# 來源腳本：交換商店
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<BARTER>
# 範例：<NOBARTER>
#
#===============================================================================
# 來源腳本：物品圖鑑
# 適用推定：Item / Weapon / Armor
#-------------------------------------------------------------------------------
# 範例：<Almanac out>
# 範例：<Almanac com_on>
# 範例：<Almanac com_off>
# 範例：<almanac com_on>
# 範例：<almanac com_off>
# 範例：<Almanac graphic name>
# 範例：<Almanac graphic club>
#
#===============================================================================
# 來源腳本：Hospital Fees
# 適用推定：State
#-------------------------------------------------------------------------------
# 範例：<hospital fee: x>
#
#===============================================================================
# 來源腳本：H87 - Guida遊戲指南
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<icon id>
# 範例：<icon %d>
#
#===============================================================================
# 來源腳本：選擇物品小視窗
# 適用推定：Item / Weapon / Armor / Actor / Class / Skill / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<pick item>
#
#===============================================================================
# 來源腳本：TPet_Item
# 適用推定：Item / Weapon
#-------------------------------------------------------------------------------
# 範例：<3 self.x = @real_x>
#
#===============================================================================
# 來源腳本：TPet_Window
# 適用推定：Item / Weapon
#-------------------------------------------------------------------------------
# 範例：<餌>
#
#===============================================================================
# 來源腳本：對事件使用物品
# 適用推定：Skill / Item / Actor / Class / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<…>
# 範例：<item-id:25>
# 範例：<skill-id:15>
# 範例：<items>
# 範例：<skills>
# 範例：<all>
# 範例：<type:カギ>
#
#===============================================================================
# 來源腳本：----說明
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<…>
# 範例：<item-id:25>
# 範例：<skill-id:15>
# 範例：<item-id:25/skill-id:15>
# 範例：<type:カギ>
# 範例：<type:カギ/type:回復アイテム>
# 範例：<type:カギ/type:回復アイテム/skill-id:15>
# 範例：<items>
# 範例：<skills>
# 範例：<items/skill-id:15>
# 範例：<all>
#
#===============================================================================
# 來源腳本：特殊移動命令
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<sy.abs # Vertical distance is longer sy>
#
#===============================================================================
# 來源腳本：YEM Core Fixes and Upgrades
# 適用推定：State
#-------------------------------------------------------------------------------
# 範例：<hide state>
# 範例：<turn colour: x>
# 範例：<turn colour n>
#
#===============================================================================
# 來源腳本：YEM Item Overhaul
# 適用推定：Skill / Item / Weapon / Armor / Actor / Class / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<key item>
# 範例：<custom data>
# 範例：</custom data>
#
#===============================================================================
# 來源腳本：200x/XP 機能再現 全體攻擊等
# 適用推定：Skill / Item / Enemy / State / Actor / Class / Weapon / Armor
#-------------------------------------------------------------------------------
# 範例：<WHOLE_ATTACK>
# 範例：<AUTO_STATE n>
# 範例：<IGNORE_EVA>
# 範例：<CRITICAL>
# 範例：<SEAL_ATK_F n>
# 範例：<SEAL_SPI_F n>
# 範例：<全体攻撃>
# 範例：<=>
#
#===============================================================================
# 來源腳本：エネミー行動パターン改良
# 適用推定：Enemy / State
#-------------------------------------------------------------------------------
# 範例：<＜]索敵[:：]頻回[>
# 範例：<＜]索敵[:：]極稀[>
# 範例：<頻繁>
# 範例：<極稀>
# 範例：<無鉄砲>
# 範例：<好戦的>
# 範例：<慎重派>
# 範例：<=>
#
#===============================================================================
# 來源腳本：行動パターン改良マニュアル
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<エネミー行動変化：1>
# 範例：<無鉄砲>
# 範例：<好戦的>
# 範例：<慎重派>
# 範例：<索敵:頻回>
# 範例：<索敵:極稀>
# 範例：<索敵：極稀>
#
#===============================================================================
# 來源腳本：機能追加：アクター行動パターン化
# 適用推定：State
#-------------------------------------------------------------------------------
# 範例：<エネミー行動参照：1>
# 範例：<エネミー行動変化：1>
# 範例：<=>
# 範例：<無鉄砲>
# 範例：<好戦的>
# 範例：<慎重派>
#
#===============================================================================
# 來源腳本：SBS General Settings
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<hide states>
# 範例：<hide hp>
# 範例：<filename>
#
#===============================================================================
# 來源腳本：Sideview 2 (3.4d)
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<-200 or self.x>
# 範例：<-200 or self.y>
# 範例：<7 的角色數量 summon_actor_index = 0 # 計算當前角色是第幾個 self.id>
# 範例：<7 的數量，並計算 self.id>
# 範例：<7 normal_actor_count += 1 elsif actor == self # 確保當前角色取得正確的 summon_index break # 當找到自己時，終止計算，確保這是目前第幾個 self.id>
# 範例：<7 的角色使用 N01::ACTOR_POSITION @base_position_x = base[0] @base_position_y = base[1] else # self.id>
#
#===============================================================================
# 來源腳本：ATB Configurations
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<charge action: key>
# 範例：<recharge: value%>
# 範例：<atb damage: value%>
# 範例：<atb minus damage>
# 範例：<-atb minus damage>
# 範例：<charge bonus: value%>
# 範例：<atb base: value%>
# 範例：<atb gauge>
# 範例：<-atb gauge>
#
#===============================================================================
# 來源腳本：Notetags for Tankentai Add-on
# 適用推定：Skill / Item / Weapon / Armor / Enemy / State / Actor / Class
#-------------------------------------------------------------------------------
# 範例：<action: key>
# 範例：<action: NORMAL_ATTACK>
# 範例：<flygraphic: filename>
# 範例：<flygraphic: woodarrow>
# 範例：<flygraphic: icon>
# 範例：<graphic: filename>
# 範例：<graphic: big_sword>
# 範例：<extensions>
# 範例：</extensions>
# 範例：<ext>
# 範例：</ext>
# 範例：<slip: type, value, value%>
# 範例：<slip: hp, 15, 10%>
# 範例：<slip: hp, 0, -5%>
# 範例：<slip: mp, -12, 0>
# 範例：<slip: mp, 5, 0>
# 範例：<slip: hp, -50, 0>
# 範例：<action: WAIT-SLEEP>
# 範例：<unarmed: key>
# 範例：<unarmed: SKILL_USE>
# 範例：<standby: key>
# 範例：<standby: WAIT>
# 範例：<pinch: key>
# 範例：<pinch: WAIT>
# 範例：<guard: key>
# 範例：<guard: WAIT>
# 範例：<hurt: key>
# 範例：<hurt: WAIT>
# 範例：<evade: key>
# 範例：<evade: WAIT>
# 範例：<escape: key>
# 範例：<escape: ENEMY_FLEE>
# 範例：<start: key>
# 範例：<start: WAIT>
# 範例：<interrupt: key>
# 範例：<interrupt: RESET_POSITION>
# 範例：<dead: key>
# 範例：<dead: DEAD>
# 範例：<shadow: filename>
# 範例：<shadow: off>
# 範例：<shadow: shadow01>
# 範例：<move shadow: x, y>
# 範例：<move shadow: 0, -50>
# 範例：<weapon: id>
# 範例：<weapon: 4>
# 範例：<position: x, y>
# 範例：<position: 0, 50>
# 範例：<collapse: type>
# 範例：<collapse: 1>
# 範例：<collapse: 2>
# 範例：<collapse: 3>
# 範例：<multiact: times, chance%, speed reduction%>
# 範例：<multiact: 3, 50%, 70%>
# 範例：<animate>
# 範例：<-animate>
# 範例：<+animate>
# 範例：<mirror>
# 範例：<-mirror>
# 範例：<+mirror>
# 範例：<charge action: key>
# 範例：<charge:>
# 範例：<charge action: CHARGING>
# 範例：<recharge: value%>
# 範例：<recharge: 25%>
# 範例：<atb base: value%>
# 範例：<atb base: 60%>
# 範例：<atb base: -15%>
# 範例：<charge bonus: value%>
# 範例：<charge bonus: 30%>
# 範例：<charge bonus: -10%>
# 範例：<atb damage: value%>
# 範例：<atb damage: -25%>
# 範例：<atb damage: 80%>
# 範例：<atb gauge>
# 範例：<-atb gauge>
# 範例：<+atb gauge>
# 範例：<charge bonus: value>
# 範例：<atb base: value>
# 範例：<recharge: value>
# 範例：<shadow plus: value x, value y>
# 範例：<position plus: value x, value y>
# 範例：<multiact: value>
#
#===============================================================================
# 來源腳本：NightWalker's Sample Skills
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<action: FIRE_ATTACK>
# 範例：<action: FIRE_ASSIST>
# 範例：<action: FROUST>
#
#===============================================================================
# 來源腳本：Bubs' Bow Add-on (K)
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<action: BOW_ATTACK>
#
#===============================================================================
# 來源腳本：Guns Action Sequence (K)
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<action: GUN_ATTACK>
#
#===============================================================================
# 來源腳本：Premade Action Sequences
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<action: SPEAR_ATTACK>
# 範例：<action: THROW_RETURN_ATTACK>
# 範例：<action: THROW_STICKY_ATTACK>
# 範例：<action: THROW_MULTIPLE_ATTACK>
# 範例：<action: TKSLAM>
# 範例：<action: GUN_ATTACK>
# 範例：<action: STATIONARY_ATTACK>
# 範例：<action: STATIONARY_SKILL>
# 範例：<action: HYPERBARRAGE>
# 範例：<action: JUMPATTACK>
# 範例：<action: GIANT_TOSS>
# 範例：<action: OMNISLASH>
# 範例：<action: BACKSTAB>
# 範例：<action: HARP_ATTACK>
# 範例：<action: THROW_ITEM>
# 範例：<action: STRANGE_CUT-IN>
# 範例：<action: EXAMPLE_ANIM_ON_SELF>
# 範例：<action: ANTIPODE>
# 範例：<action: ANTIPODE_ASSIST>
# 範例：<action: SOUTHERN_CROSS>
# 範例：<action: SOUTHERN_CROSS_ASSIST>
#
#===============================================================================
# 來源腳本：STR15_Enemy HP Gauge
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<= 1 and @hp>
#
#===============================================================================
# 來源腳本：KGC_OverDrive
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<overdrive>
# 範例：<OD_gain n%>
# 範例：<OD_gain 200%>
#
#===============================================================================
# 來源腳本：攻擊時OD加值
# 適用推定：Actor / Class / Skill / Item / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<OdBonus +n>
# 範例：<EnemyOdBonus +n>
#
#===============================================================================
# 來源腳本：EXP Controller
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<exp at level x>
# 範例：<exp at level 2>
# 範例：<exp at level>
#
#===============================================================================
# 來源腳本：更多掉落物
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<gold rate x%>
# 範例：<gold rate 75%>
# 範例：<gold range x:y>
# 範例：<gold range 50:150>
# 範例：<lucky rate x%>
# 範例：<more items x:y-z>
# 範例：<more armors x:y-z>
# 範例：<more weapons x:y-z>
# 範例：<more items 1:1-4>
# 範例：<more items 1:4-50>
#
#===============================================================================
# 來源腳本：YERD_EnemyLevelControl
# 適用推定：Enemy / Actor / Class / Skill / Item / Weapon / Armor / State
#-------------------------------------------------------------------------------
# 範例：<match highest level>
# 範例：<match average level>
# 範例：<match lowest level>
# 範例：<level max x>
# 範例：<level min x>
# 範例：<level set x>
# 範例：<level mod +x>
# 範例：<level mod -x>
# 範例：<level mod +5>
# 範例：<growth stat +x>
# 範例：<growth stat +x%>
# 範例：<super guard level x>
# 範例：<fast attack level x>
# 範例：<dual attack level x>
# 範例：<prevent cri level x>
# 範例：<half mp level x>
# 範例：<auto state lv x:y>
# 範例：<auto state lv x:y,y>
# 範例：<change enemy level +x>
# 範例：<level lock>
# 範例：<reset level>
# 範例：<=>
#
#===============================================================================
# 來源腳本：YERD_BestiaryScan
# 適用推定：Enemy / Actor / Class / Skill / Item / Weapon / Armor / State
#-------------------------------------------------------------------------------
# 範例：<hide>
# 範例：<scan whole>
# 範例：<scan hp mp>
# 範例：<scan stats>
# 範例：<scan skills>
# 範例：<scan elements>
# 範例：<scan status effects>
# 範例：<scan states>
# 範例：<scan steal>
# 範例：<scan spoils>
# 範例：<scan drops>
# 範例：<scan description>
# 範例：<boss type x>
# 範例：<boss type x,x>
# 範例：<hide whole>
# 範例：<hide hp_mp>
# 範例：<hide stats>
# 範例：<hide skills>
# 範例：<hide elements>
# 範例：<hide status effects>
# 範例：<hide states>
# 範例：<hide steal>
# 範例：<hide spoils>
# 範例：<hide drops>
# 範例：<@enemy.base_maxhp and @enemy.base_maxhp>
# 範例：<@enemy.base_maxmp and @enemy.base_maxmp>
#
#===============================================================================
# 來源腳本：YERD_TargetEffects
# 適用推定：Actor / Class / Skill / Item / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<everybody>
# 範例：<phoenix>
# 範例：<targetallfoe>
# 範例：<targetrandomfoe x>
# 範例：<randomfoe x>
# 範例：<multifoe x>
# 範例：<allbutuser>
# 範例：<targetallally>
# 範例：<targetrandomally x>
# 範例：<randomally x>
# 範例：<pick custom x>
#
#===============================================================================
# 來源腳本：SummonGuard_DynamicThreat_v2
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<summon_guard:2>
# 範例：<state_focus:31>
# 範例：<dps_focus:800>
# 範例：<threat_target>
# 範例：<state_threat:31,500>
# 範例：<dps_threat:100,10>
# 範例：<dps_focus:1>
#
#===============================================================================
# 來源腳本：Friendly Monsters
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<friendly>
# 範例：<friendly exp: x>
# 範例：<friendly gold: x>
# 範例：<friendly i: x>
# 範例：<friendly w: x>
# 範例：<friendly a: x>
#
#===============================================================================
# 來源腳本：KGC_偷竊
# 適用推定：Skill / Enemy / Actor / Class / Item / Weapon / Armor / State
#-------------------------------------------------------------------------------
# 範例：<steal>
# 範例：<steal X:ID Probability %>
# 範例：<steal W:2 50%>
# 範例：<steal G:100 50%>
# 範例：<steal_prob_plus Modifier Rate %>
# 範例：<steal_prob_plus + 15%>
#
#===============================================================================
# 來源腳本：KGC_EnemyGuide
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<enemy_info>
# 範例：</enemy_info>
# 範例：<GUIDE_DESCRIPTION>
# 範例：</GUIDE_DESCRIPTION>
#
#===============================================================================
# 來源腳本：Field Effect
# 適用推定：Actor / Class / Skill / Item / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<field effect: x>
# 範例：<remove field effect>
#
#===============================================================================
# 來源腳本：KGC_LargeParty
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<=>
# 範例：<@item_max # 通常 super elsif @index>
#
#===============================================================================
# 來源腳本：YEZ Job System: Base
# 適用推定：Enemy / State / Actor / Class / Skill / Item / Weapon / Armor
#-------------------------------------------------------------------------------
# 範例：<jp skill x at level y>
# 範例：<jp growth +n>
# 範例：<jp rate n%>
# 範例：<jp growth -n>
# 範例：<jp cost: n>
# 範例：<jp level: n>
# 範例：<jp skill: n>
# 範例：<jp skills: n,n>
# 範例：<jp passive: x>
# 範例：<jp passives: x,x>
# 範例：<jp switch: n>
# 範例：<jp switches: n,n>
# 範例：<jp gain n>
# 範例：<=>
#
#===============================================================================
# 來源腳本：技能使用條件
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<特殊使用条件>
# 範例：</特殊使用条件>
#
#===============================================================================
# 來源腳本：KGC_隱藏技能
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<HIDDEN>
# 範例：<hide>
# 範例：<passive>
#
#===============================================================================
# 來源腳本：KGC_PassiveSkill
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<PASSIVE_SKILL>
# 範例：</PASSIVE_SKILL>
#
#===============================================================================
# 來源腳本：KGC_PassiveSkill拡張
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<レベル依存:a,b,c,d>
# 範例：<レベル依存:0,0,10,3>
# 範例：<レベル依存:1,1,5,2>
# 範例：<レベル依存:2,2,7,1>
# 範例：<レベル依存:3,3,6,0>
# 範例：<レベル依存:0,1,1,2>
#
#===============================================================================
# 來源腳本：YEZ Custom Status Properties
# 適用推定：Skill / Item / State
#-------------------------------------------------------------------------------
# 範例：<animation n>
# 範例：<max stack n>
# 範例：<stat +n>
# 範例：<stat -n>
# 範例：<stat n%>
# 範例：<hp degen n>
# 範例：<hp degen n%>
# 範例：<mp degen n>
# 範例：<mp degen n%>
# 範例：<hp regen n>
# 範例：<hp regen n%>
# 範例：<mp regen n>
# 範例：<mp regen n%>
# 範例：<trait: phrase>
# 範例：<apply effect: phrase>
# 範例：<erase effect: phrase>
# 範例：<leave effect: phrase>
# 範例：<react effect: phrase>
# 範例：<shock effect: phrase>
# 範例：<begin effect: phrase>
# 範例：<while effect: phrase>
# 範例：<close effect: phrase>
#
#===============================================================================
# 來源腳本：KGC_AddEquipmentOptions
# 適用推定：Item / Weapon / Armor / Actor / Class / Skill / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<Auto HP Recover 10%>
# 範例：<auto MP recover 10%>
# 範例：<auto HP recover Rate %>
# 範例：<auto MP recover Rate %>
# 範例：<MP absorb Rate %>
# 範例：<MP convert Rate %>
# 範例：<element resist ElementID: Modifier Rate %>
# 範例：<element weakness ElementID: Modifier Rate>
# 範例：<element half ElementID>
# 範例：<element null ElementID>
# 範例：<element absorb ElementID: Modifier Rate>
# 範例：<state resist stateID: Modifier Rate %>
# 範例：<prevent critical>
# 範例：<half MP cost>
# 範例：<double exp>
# 範例：<fast attack>
# 範例：<dual attack>
# 範例：<critical bonus>
# 範例：<attack element ElementID>
# 範例：<plus state StateID>
# 範例：<auto HP recover>
# 範例：<auto MP recover>
# 範例：<MP convert>
# 範例：<MP absorb>
#
#===============================================================================
# 來源腳本：技能消耗改變
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<costo hp: x>
# 範例：<costo hp: x%>
# 範例：<costo mp: x>
# 範例：<costo mp: x%>
# 範例：<costo oro: x>
# 範例：<costo oro: x%>
# 範例：<costo angry: x>
# 範例：<costo state: x>
# 範例：<costo var: x>
# 範例：<costo var: x%>
# 範例：<usa oggetto: x>
#
#===============================================================================
# 來源腳本：H87-Skill Delay
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<ricarica turni: x>
# 範例：<ricarica battaglie: x>
# 範例：<ricarica passi: x>
#
#===============================================================================
# 來源腳本：FS_SkillCost_Authority v2.0.0（Phase 24）
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 說明：舊 `Skill Cost Fix` 已退休；以下 Notetag 由 Holy87 Parser 與
#       FS_SkillCost_Authority 統一解析／計算／支付。
# 範例：<costo hp:x>
# 範例：<costo hp:x%>
# 範例：<costo mp:x>
# 範例：<costo mp:x%>
# 範例：<costo oro:x>
# 範例：<costo oro:x%>
# 範例：<costo var:x>
# 範例：<costo var:x%>
# 範例：<usa oggetto:x>
# 範例：<costo angry:x>
# 範例：<costo state:x>
#
#===============================================================================
# 來源腳本：Equipment Skills
# 適用推定：Actor / Class / Skill / Item / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<equipskill: x>
# 範例：<equipskill: x, x, x>
#
#===============================================================================
# 來源腳本：YEM Equipment Overhaul
# 適用推定：Item / Weapon / Armor / State / Actor / Class / Skill / Enemy
#-------------------------------------------------------------------------------
# 範例：<stat aptitude: +x%>
# 範例：<stat aptitude: -x%>
# 範例：<stat: +x>
# 範例：<stat: -x>
# 範例：<stat: +x%>
# 範例：<stat: -x%>
# 範例：<trait: phrase>
# 範例：<auto state: x>
# 範例：<auto states: x,x>
# 範例：<require above: stat x>
# 範例：<require under: stat x>
# 範例：<require switch: x>
# 範例：<require switches: x,x>
# 範例：<require variable x: above y>
# 範例：<require variable x: under y>
# 範例：<2 hand text: phrase>
# 範例：<equip type: phrase>
# 範例：<尚未裝備>
# 範例：<=>
#
#===============================================================================
# 來源腳本：Custom Dmg Formulas RD
# 適用推定：Actor / Class / Skill / Item / Weapon / Armor / Enemy / State
#-------------------------------------------------------------------------------
# 範例：<critical x>
# 範例：<no crit>
# 範例：<atk_f x>
# 範例：<spi_f x>
# 範例：<def_f x>
# 範例：<agi_f x>
# 範例：<hp_hi x>
# 範例：<hp_lo x>
# 範例：<mp_hi x>
# 範例：<mp_lo x>
# 範例：<mul level>
# 範例：<div level>
# 範例：<add level>
# 範例：<sub level>
# 範例：<mulvar x>
# 範例：<divvar x>
# 範例：<addvar x>
# 範例：<subvar x>
# 範例：<custom x>
#
#===============================================================================
# 來源腳本：Cover
# 適用推定：Skill / State
#-------------------------------------------------------------------------------
# 範例：<COVER cover_type cover_param>
# 範例：<COVER 1 0>
# 範例：<COVER 2 50>
# 範例：<COVER 3 20>
#
#===============================================================================
# 來源腳本：Counterattack State v1.3.1 (修正版)
# 適用推定：State
#-------------------------------------------------------------------------------
# 範例：<counterattack>
#
#===============================================================================
# 來源腳本：YEZ Job System: Skill Levels
# 適用推定：Skill / Enemy / Actor / Class / Item / Weapon / Armor / State
#-------------------------------------------------------------------------------
# 範例：<max level x>
# 範例：<cannot level>
# 範例：<max leve 0>
# 範例：<level x jp: y>
# 範例：<level dmg all: +x%>
# 範例：<level dmg all: -x%>
# 範例：<level x dmg: +y%>
# 範例：<level x dmg: -y%>
# 範例：<level hit all: +x%>
# 範例：<level hit all: -x%>
# 範例：<level x hit: +y%>
# 範例：<level x hit: -y%>
# 範例：<level cost all: +x>
# 範例：<level cost all: -x>
# 範例：<level x cost: +y>
# 範例：<level x cost: -y>
# 範例：<level state all: +x>
# 範例：<level state all: -x>
# 範例：<level x state: +y>
# 範例：<level x state: -y>
# 範例：<level chain all: +x>
# 範例：<level chain all: -x>
# 範例：<level x chain: +y>
# 範例：<level x chain: -y>
# 範例：<level speed all: +x>
# 範例：<level speed all: -x>
# 範例：<level x speed: +y>
# 範例：<level x speed: -y>
# 範例：<level cooldown all: +x>
# 範例：<level cooldown all: -x>
# 範例：<level x cooldown: +y>
# 範例：<level x cooldown: -y>
# 範例：<skill x at level y>
# 範例：<all skills level +x>
# 範例：<=>
#
#===============================================================================
# 來源腳本：H87-EnemyKilledCounter影響測試
# 適用推定：Enemy
#-------------------------------------------------------------------------------
# 範例：<kill var: x>
#
#===============================================================================
# 來源腳本：物品打星星
# 適用推定：Skill / Item / Weapon / Armor
#-------------------------------------------------------------------------------
# 範例：<classe: x>
#
#===============================================================================
# 來源腳本：目標過濾-new
# 適用推定：Skill / Weapon
#-------------------------------------------------------------------------------
# 範例：<特殊使用条件>
# 範例：</特殊使用条件>
#
#===============================================================================
# 來源腳本：BattleFormula_TargetFix
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<ele_res 13:25>
# 範例：<ele_res[13]:25>
# 範例：<ele_weak 13:50>
# 範例：<target_weight:50>
# 範例：<no_random_target>
# 範例：<pen_rate:20>
# 範例：<crit_rate:10>
#
#===============================================================================
# 來源腳本：AutoBattleAI_DamageEval_Random
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<AI除外>
# 範例：<AI評価:8>
# 範例：<AI評価:n>
# 範例：<＜]AI除外[>
# 範例：<＜]AI_EXCLUDE[>
#
#===============================================================================
# 來源腳本：SummonEquipSkill_PowerAndDesc
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<equipskill: n>
# 範例：<summon_lv_power: 10>
# 範例：<summon_atk_power: 50>
# 範例：<summon_spi_power: 50>
# 範例：<summon_def_power: 50>
# 範例：<summon_agi_power: 50>
#
#===============================================================================
# 來源腳本：TargetPriority_SelectionFix
# 適用推定：Enemy / State
#-------------------------------------------------------------------------------
# 範例：<target priority: n>
# 範例：<target priority: 1>
# 範例：<target priority: 2>
# 範例：<目標優先: 1>
# 範例：<ignore target priority>
# 範例：<無視目標優先>
# 範例：<target_priority: 2>
# 範例：<target-priority: 2>
# 範例：<目標優先: 2>
# 範例：<target[ _-]*priority>
# 範例：<目標優先>
# 範例：<ignore[ _-]*target[ _-]*priority>
#
#===============================================================================
# 來源腳本：RandomTarget_IntegrationFix
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<no_random_target>
# 範例：<target_weight:n>
#
#===============================================================================
# 來源腳本：RMVX_ComboCore_AllInOne_v1_1_OD
# 適用推定：Item / State
#-------------------------------------------------------------------------------
# 範例：<absorb X Y>
# 範例：<COVER 1 0>
# 範例：<COVER 2 50>
# 範例：<COVER 6 30>
# 範例：<absorb 500 50>
# 範例：<bonus_vs_state 31:50>
# 範例：<bonus_vs_state 32:40>
# 範例：<bonus_vs_state 33:70>
# 範例：<bonus_if_user_state 40:30>
# 範例：<bonus_per_target_state:10>
# 範例：<bonus_if_state_count 3:50>
# 範例：<bonus_vs_type robot:50>
# 範例：<bonus_vs_type pokemon:30>
# 範例：<detonate_state 31:150>
# 範例：<consume_state 31>
# 範例：<damage_per_stack:150>
# 範例：<spread_state 31:2>
# 範例：<spread_state 31:2:50>
# 範例：<drift_state 31:1>
# 範例：<convert_state 31:32>
# 範例：<spread_on_death:2>
# 範例：<drift_on_death:1>
# 範例：<state_chance 31:20>
# 範例：<state_chance_vs_state 31,32:25>
# 範例：<state_chance_if_user_state 31,40:30>
# 範例：<atb_shift:-25>
# 範例：<atb_shift:30>
# 範例：<atb_shift:-20>
# 範例：<atb_bonus_vs_state 31:50>
# 範例：<atb_bonus_if_user_state 40:50>
# 範例：<atb_bonus_per_target_state:10>
# 範例：<bonus_if_od 50:30>
# 範例：<bonus_per_od_percent:0.5>
# 範例：<bonus_if_od 25:10>
# 範例：<bonus_if_od 50:20>
# 範例：<bonus_if_od 75:30>
# 範例：<bonus_per_od_100:10>
# 範例：<reduce_damage_if_od 50:20>
# 範例：<reduce_damage_per_od_percent:0.2>
# 範例：<state_chance_if_od 31,50:20>
# 範例：<state_chance_per_od_percent 31:0.2>
# 範例：<atb_bonus_if_od 50:50>
# 範例：<atb_bonus_per_od_percent:0.5>
# 範例：<mana_shield 500:50>
# 範例：<mana shield 500 50>
# 範例：<COVER type param>
# 範例：<cover_param when 3, 6 hp_rate = self.maxhp>
# 範例：<atb_bonus:50>
#
#===============================================================================
# 來源腳本：CharacterMechanicCore_v1_0_TC
# 適用推定：Skill
#-------------------------------------------------------------------------------
# 範例：<cc_od_summon_action:80>
# 範例：<cc_od_cover:60>
# 範例：<cc_od_atb_per_10:40>
# 範例：<cc_od_state_stack:70>
# 範例：<cc_od_break_point:50>
# 範例：<cc_od_break:200>
# 範例：<cc_od_heal_percent:5>
# 範例：<cc_od_overheal_percent:3>
# 範例：<heal_bonus:15>
# 範例：<heal_bonus_if_od 50:20>
# 範例：<heal_bonus_per_od_percent:0.2>
# 範例：<overheal_to_od:50>
# 範例：<overheal_to_mp:30>
# 範例：<overheal_to_user_mp:30>
# 範例：<overheal_to_state 41:10>
# 範例：<overheal_to_shield 52:50>
# 範例：<max stack 5>
# 範例：<break_power:1>
# 範例：<break_state:50>
# 範例：<broken_state:51>
# 範例：<break_threshold:5>
# 範例：<break_bonus_if_od 50:1>
# 範例：<break_bonus_if_od 80:1>
# 範例：<summon_followup 18:241:700>
# 範例：<summon_followup 召喚物ActorID:追擊技能ID:需求OD>
# 範例：<summon_followup 18:241:700:200>
# 範例：<summon_followup 召喚物ActorID:追擊技能ID:需求OD:觸發後消耗OD>
#
#===============================================================================
# 來源腳本：BattlePopText_Note
# 適用推定：Skill / Weapon
#-------------------------------------------------------------------------------
# 範例：<pop_text:看招！>
# 範例：<pop_text:接好了！>
# 範例：<pop_text:這一下可不輕。>
# 範例：<pop_text:別眨眼。>
# 範例：<pop_text:開始吧！>
# 範例：<pop_text:讓我試試這招。>
# 範例：<pop_text:你最好站穩。>
# 範例：<pop_text:...>
# 範例：<pop_text:文字內容>
#
#===============================================================================
# 來源腳本：BattleStateHUD_Core
# 適用推定：State
#-------------------------------------------------------------------------------
# 範例：<hud_detail>
# 範例：<hud_detail_text:文字>
# 範例：<HUD詳細文字:文字>
# 範例：<hud_priority:100>
# 範例：<hide_battle_hud>
# 範例：<hud_hide>
# 範例：<show_battle_hud>
# 範例：<hud_show>
# 範例：<hud_icon:123>
# 範例：<hud_name:劇毒>
# 範例：<HUD詳細>
# 範例：<hud_detail_text:每層提高毒爆傷害20%>
# 範例：<HUD詳細文字:再1層觸發崩防>
# 範例：<hud_priority:x>
# 範例：<=>
#
#===============================================================================
# 來源腳本：ATB_DynamicResistance
# 適用推定：Enemy / State
#-------------------------------------------------------------------------------
# 範例：<atb_shift:-x>
# 範例：<atb_dynamic_resist>
# 範例：<atb_resist_start:0>
# 範例：<atb_resist_max:4>
# 範例：<atb_resist_floor:10>
# 範例：<atb_resist_recover:1>
# 範例：<atb damage: -x%>
# 範例：<atb_shift>
#
#===============================================================================
# 來源腳本：SummonChain3_v1_0
# 適用推定：依來源腳本判定
#-------------------------------------------------------------------------------
# 範例：<summon_followup>
# 範例：<summon_chain 1:18:241:700:0>
# 範例：<summon_chain 2:30:250:700:100>
# 範例：<summon_chain 3:35:260:900:300>
# 範例：<summon_chain 階段:召喚物ActorID:追擊技能ID:需求OD:成功後消耗OD>
# 範例：<chain_require 階段:條件[:數值]>
# 範例：<chain_require 2:state:31>
# 範例：<chain_require 2:not_state:31>
# 範例：<chain_require 3:hp_below:30>
# 範例：<chain_require 3:hp_above:50>
# 範例：<chain_require 3:broken>
# 範例：<chain_require 1:hit>
# 範例：<chain_require 2:damage:500>
# 範例：<chain_require 2:added_state:31>
# 範例：<chain_require 2:stack_up:31>
# 範例：<chain_require 2:weak>
# 範例：<chain_require 2:critical>
# 範例：<chain_require 2:kill>
# 範例：<chain_require 1:type:pokemon>
# 範例：<chain_require 2:type:robot>
# 範例：<chain_require 3:type:clone>
# 範例：<summon_chain 1:18:241:0:0>
# 範例：<summon_chain 1:19:242:0:0>
# 範例：<summon_chain>
# 範例：<= 0.0 ? 0.0 : target.hp.to_f * 100.0 / maxhp passed = rate>
#
#===============================================================================
# 來源腳本：MechanicExpansion_AllInOne
# 適用推定：State / Skill / Enemy / Actor
#-------------------------------------------------------------------------------
# 範例：<ai_bonus_vs_state 31:100>
# 範例：<ai_require_state:31>
# 範例：<ai_prefer_stack_below 31:5>
# 範例：<robot_protocol_skill:241>
# 範例：<robot_protocol_interval:3>
# 範例：<robot_protocol_if_state 31:241>
# 範例：<summon_type:pokemon>
# 範例：<summon_type:robot>
# 範例：<summon_type:clone>
# 範例：<summon_role:poison_starter>
# 範例：<summon_role:breaker>
# 範例：<summon_role:finisher>
# 範例：<summon_followup_type pokemon:241:700:200>
# 範例：<summon_followup_type 類型:追擊技能ID:需求OD:成功後消耗OD>
# 範例：<summon_followup_role poison_starter:241:700:200>
# 範例：<summon_chain_type 1:pokemon:241:700:0>
# 範例：<summon_chain_type 2:robot:250:700:100>
# 範例：<summon_chain_type 3:clone:260:900:300>
# 範例：<summon_chain_role 1:poison_starter:241:700:0>
# 範例：<summon_chain_role 2:corrosion_engine:250:700:100>
# 範例：<summon_chain_role 3:finisher:260:900:300>
# 範例：<store_cover_damage:150>
# 範例：<cover_store_cap_percent:300>
# 範例：<revenge_from_cover:50>
# 範例：<consume_stored_cover>
# 範例：<atb_bonus_if_target_atb_above 80:50>
# 範例：<bonus_if_target_atb_above 80:30>
# 範例：<atb_interrupt_threshold:80>
# 範例：<atb_interrupt_od:100>
# 範例：<interrupt_if_target_atb_above:80>
# 範例：<detonate_state_percent 31:2>
# 範例：<detonate_state_spi 31:120>
# 範例：<detonate_state_atk 31:120>
# 範例：<detonate_cap:5000>
# 範例：<state_dynamic_resist>
# 範例：<dynamic_resist>
# 範例：<control_state>
# 範例：<state_dynamic_resist_states:31,32,33>
# 範例：<state_dynamic_resist_all>
# 範例：<state_resist_step:25>
# 範例：<state_resist_min:10>
# 範例：<state_resist_recover:1>
# 範例：<break_threshold:8>
# 範例：<break_resist:50>
# 範例：<break_immune>
# 範例：<break_recover:1>
# 範例：<break_recover_state:50>
# 範例：<bonus_vs_state 51:100>
# 範例：<consume_broken>
# 範例：<bonus_per_user_state_stack 41:15>
# 範例：<consume_user_state 41:3>
#
