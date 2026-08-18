# -*- coding: utf-8 -*-
#===============================================================================
# ■ Albert_RMVX_REFERENCE_Full_Skill_Design_v1_1_Antagonist_TC
#-------------------------------------------------------------------------------
#  Forest Symphony 森之交響曲
#  我方六主角＋30召喚物＋敵方共用技能庫完整設計藍圖
#-------------------------------------------------------------------------------
# 【用途】
#  純註釋文件，可以直接放進 RPG Maker VX 腳本庫。
#  目的是統一：
#    ・技能 BaseDamage / ATK-F / SPI-F / MP / HIT / Variance
#    ・學習等級 / JP 花費
#    ・技能等級成長
#    ・State / Stack / Break / ATB / OD / Summon Chain
#    ・召喚物 AI 與 Robot Protocol
#    ・敵方小怪 / 菁英 / Boss 共用技能庫
#
# 【基準】
#  依據 All_Scripts_Export(7).txt 的 Main 以上有效腳本與目前傷害公式：
#
#  Damage =
#    (BaseDamage + Power)
#    × 120 / (120 + EffectiveDefense)
#
#  Power =
#    (ATK × atk_f + SPI × spi_f) / 100
#
#  暴擊 1.7 倍，多屬性倍率相乘。
#
# 【重要】
#  本文件使用的 State ID 是「建議標準」，請與狀態設計文件一起使用。
#  既有保留：
#    31毒 / 32濕潤 / 33麻痺 / 34灼燒 / 35寄生
#    37腐蝕 / 38遲緩 / 40共鳴標記 / 41魔力層
#    50破勢 / 51崩防 / 52Mana Shield
#===============================================================================

# ===============================================================================
# 第一部　先統一技能等級成長規格
# ===============================================================================
#
# 目前 YEZ Skill Levels 的危險點：
#
#   DEFAULT_DMG_BONUS = 100
#
# 也就是沒有額外 Note 時，技能每升 1 級預設 +100% 傷害。
# 對本專案而言太誇張。
#
# 所以所有可升級技能，建議明確指定：
#
# 【Profile A｜標準核心技能】
#   <max level 4>
#   <level dmg all:+12%>
#   <level 1 jp cost:600>
#   <level 2 jp cost:1600>
#   <level 3 jp cost:3600>
#   <level 4 jp cost:7500>
#
# 成長：
#   Lv0 100%
#   Lv1 112%
#   Lv2 124%
#   Lv3 136%
#   Lv4 148%
#
# 【Profile B｜重擊 / 高成本技能】
#   <max level 4>
#   <level dmg all:+15%>
#   <level 1 jp cost:900>
#   <level 2 jp cost:2400>
#   <level 3 jp cost:5200>
#   <level 4 jp cost:10500>
#
# 成長：
#   100 / 115 / 130 / 145 / 160%
#
# 【Profile C｜治療技能】
#   <max level 4>
#   <level dmg all:+10%>
#   <level 1 jp cost:600>
#   <level 2 jp cost:1800>
#   <level 3 jp cost:4000>
#   <level 4 jp cost:8500>
#
# 【Profile D｜終極技能】
#   <max level 2>
#   <level dmg all:+12%>
#   <level 1 jp cost:5000>
#   <level 2 jp cost:12000>
#
# 【Profile U｜純功能技能】
#   <cannot level>
#
# 理由：
#   狀態擴散、轉換、Cover、AI指令這類功能，不應因技能等級突然把規則翻倍。
#
# 【若遊戲最終仍封頂 Lv60】
# 把本文學習等級乘以約 0.65：
#   Lv82 → 約 Lv53
#   Lv65 → 約 Lv42
#   Lv48 → 約 Lv31
# 不用重新發明整套技能樹。
#
#
# ===============================================================================
# 總體技能數值原則
# ===============================================================================
#
# 【一般單體核心技】
# BaseDamage 100～280
# atk_f / spi_f 120～220
# MP 4～18
#
# 【重擊】
# BaseDamage 300～550
# 係數 200～320
# MP 18～40
# 需要條件、冷卻或資源。
#
# 【終極技能】
# BaseDamage 650～1000
# 係數 280～450
# MP 50～80
# 必須有：
#   ・高成本
#   ・長冷卻
#   ・OD
#   ・State條件
#   ・Break窗口
# 至少其中一項，最好兩項。
#
# 【治療】
# 一般單補：
#   BaseDamage -150～-260
#   SPI-F 160～220
#
# 高階單補：
#   -300～-500
#   SPI-F 220～320
#
# 全體治療：
#   效率應比單補低約 20～35%。
#
# 【狀態技能】
# 不應只靠資料庫成功率。
# 有條件時用：
#   <state_chance ...>
#   <state_chance_vs_state ...>
#   <state_chance_if_od ...>
#
# 【技能學習 JP】
# Starter：0
# 前期：400～800
# 中期：1500～2800
# 中後期：5000
# 後期：9000
# 終極：16000
#
# 六名主角使用 JP。
# Pokémon / Robot / Clone 不使用 JP：
#   Pokémon：等級 / 進化學習
#   Robot：Protocol / 模組解鎖
#   Clone：劇情 / 穩定度 / 模板解鎖
# ===============================================================================
# 第二部　六名主角技能配置
# ===============================================================================
#
# 【J01｜森芽斬】
# 定位：前期單體輸出／共鳴起手
# 學習：Lv1 / JP 0
# 範圍：敵單體
# 資料庫數值：BaseDamage 120 / ATK-F 150 / SPI-F 0 / MP 4 / HIT 95 / Variance 15
# 狀態 / 疊層：40 共鳴標記，基礎成功率 45%
# 交互：標記後，喬伊與召喚追擊技能可增傷。
# 技能等級：Profile A
# Note：
#   <state_chance 40:15>
#   <max level 4>
#   <level dmg all:+12%>
#   <level 1 jp cost:600>
#   <level 2 jp cost:1600>
#   <level 3 jp cost:3600>
#   <level 4 jp cost:7500>
#
# 【J02｜共鳴標記】
# 定位：建立召喚鏈條件
# 學習：Lv8 / JP 400
# 範圍：敵單體
# 資料庫數值：BaseDamage 40 / ATK-F 60 / SPI-F 60 / MP 6 / HIT 100 / Variance 0
# 狀態 / 疊層：40 共鳴標記，目標已存在時刷新
# 交互：後續技能對 State 40 增傷；召喚物可藉 role 接棒。
# 技能等級：Profile U
# Note：
#   <state_chance 40:40>
#   <cannot level>
#
# 【J03｜藤脈牽引】
# 定位：控制／ATB前置
# 學習：Lv16 / JP 800
# 範圍：敵單體
# 資料庫數值：BaseDamage 160 / ATK-F 60 / SPI-F 130 / MP 10 / HIT 95 / Variance 10
# 狀態 / 疊層：38 遲緩，45%基礎
# 交互：對共鳴標記目標傷害 +30%，ATB -12%。
# 技能等級：Profile A
# Note：
#   <bonus_vs_state 40:30>
#   <atb_shift:-12>
#   <state_chance 38:20>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【J04｜鳴刻指令】
# 定位：單段召喚追擊
# 學習：Lv25 / JP 1500
# 範圍：依追擊技能
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 14 / HIT 100 / Variance 0
# 狀態 / 疊層：不直接造成傷害
# 交互：從場上符合 role 的召喚物自動挑選追擊者。
# 技能等級：Profile U
# 補充：正式製作時，依此技能版本替換 role 與 Skill ID。
# Note：
#   <summon_followup_role poison_starter:241:500:100>
#   <cannot level>
#
# 【J05｜龍森交錯】
# 定位：混合屬性核心輸出
# 學習：Lv35 / JP 2800
# 範圍：敵單體
# 資料庫數值：BaseDamage 320 / ATK-F 120 / SPI-F 120 / MP 18 / HIT 95 / Variance 15
# 狀態 / 疊層：可搭配 40 共鳴標記
# 交互：對共鳴標記 +45%；多屬性會乘算，請避免同時給兩個 200% 弱點。
# 技能等級：Profile B
# Note：
#   <bonus_vs_state 40:45>
#   <crit_rate:5>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【J06｜共鳴轉奏】
# 定位：依召喚類型自動追擊
# 學習：Lv48 / JP 5000
# 範圍：敵單體
# 資料庫數值：BaseDamage 180 / ATK-F 90 / SPI-F 90 / MP 22 / HIT 100 / Variance 10
# 狀態 / 疊層：40 共鳴標記
# 交互：起手後自動找 Pokémon 類召喚物追擊。
# 技能等級：Profile B
# Note：
#   <summon_followup_type pokemon:241:650:150>
#   <bonus_vs_state 40:30>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【J07｜三聲連鎖】
# 定位：中後期完整三段鏈
# 學習：Lv65 / JP 9000
# 範圍：依各追擊技能
# 資料庫數值：BaseDamage 220 / ATK-F 100 / SPI-F 100 / MP 30 / HIT 100 / Variance 10
# 狀態 / 疊層：可要求目標有 40 或其他 Combo State
# 交互：第一棒 Pokémon → 第二棒 Robot → 第三棒 Clone。
# 技能等級：Profile D
# Note：
#   <summon_chain_type 1:pokemon:241:700:0>
#   <summon_chain_type 2:robot:250:700:100>
#   <summon_chain_type 3:clone:260:900:300>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【J08｜森之交響】
# 定位：終極共鳴爆發
# 學習：Lv82 / JP 16000
# 範圍：敵全體／召喚鏈
# 資料庫數值：BaseDamage 820 / ATK-F 180 / SPI-F 180 / MP 60 / HIT 100 / Variance 10
# 狀態 / 疊層：建議對 40 共鳴標記目標有額外效果
# 交互：本體爆發後依隊伍 role 發動三段終奏。
# 技能等級：Profile D
# Note：
#   <bonus_vs_state 40:60>
#   <summon_chain_role 1:starter:241:900:0>
#   <summon_chain_role 2:engine:250:900:150>
#   <summon_chain_role 3:finisher:260:1000:350>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【JP1｜共鳴感知】
# 定位：被動：召喚物行動額外提供OD
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：強化喬伊核心循環。
# 技能等級：被動，不升級
# Note：
#   <PASSIVE_SKILL>
#   SPI +5%
#   AGI +5%
#   </PASSIVE_SKILL>
#   <hide>
#
# 【JP2｜和聲領袖】
# 定位：被動：高OD時提高自身傷害
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：不直接改召喚物，只提高喬伊在共鳴高潮時的輸出。
# 技能等級：被動，不升級
# Note：
#   <PASSIVE_SKILL>
#   MAXMP +10%
#   </PASSIVE_SKILL>
#   <hide>
#
# 【I01｜盾撞】
# 定位：基礎坦克輸出／小控制
# 學習：Lv1 / JP 0
# 範圍：敵單體
# 資料庫數值：BaseDamage 150 / ATK-F 150 / SPI-F 0 / MP 4 / HIT 95 / Variance 15
# 狀態 / 疊層：49 暈眩 20%
# 交互：低傷害但能製造救場空間。
# 技能等級：Profile A
# Note：
#   <state_chance 49:10>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【I02｜庇護架勢】
# 定位：開啟 Cover
# 學習：Lv8 / JP 400
# 範圍：自身
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 8 / HIT 100 / Variance 0
# 狀態 / 疊層：施加 84 庇護架勢
# 交互：State 84 本身用 <COVER 2 100>。
# 技能等級：Profile U
# Note：
#   <cannot level>
#
# 【I03｜怒擊】
# 定位：依OD提高傷害
# 學習：Lv16 / JP 800
# 範圍：敵單體
# 資料庫數值：BaseDamage 220 / ATK-F 180 / SPI-F 0 / MP 8 / HIT 95 / Variance 15
# 狀態 / 疊層：無
# 交互：怒氣越高越痛，但保留OD也代表更硬。
# 技能等級：Profile A
# Note：
#   <bonus_per_od_percent:0.35>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【I04｜鋼壁】
# 定位：高OD防守姿態
# 學習：Lv25 / JP 1500
# 範圍：自身
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 14 / HIT 100 / Variance 0
# 狀態 / 疊層：施加 55 防禦提升
# 交互：建議搭配裝備/State上的 reduce_damage_if_od。
# 技能等級：Profile U
# Note：
#   <cannot level>
#
# 【I05｜痛苦熔爐】
# 定位：提高蓄痛效率
# 學習：Lv35 / JP 2800
# 範圍：自身
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 18 / HIT 100 / Variance 0
# 狀態 / 疊層：施加 85 痛苦熔爐
# 交互：State 85 寫 <store_cover_damage:150> 與上限。
# 技能等級：Profile U
# Note：
#   <cannot level>
#
# 【I06｜復仇重擊】
# 定位：Cover蓄痛轉傷害
# 學習：Lv48 / JP 5000
# 範圍：敵單體
# 資料庫數值：BaseDamage 260 / ATK-F 200 / SPI-F 0 / MP 18 / HIT 100 / Variance 10
# 狀態 / 疊層：不額外上狀態
# 交互：追加目前蓄痛 50%，成功後清空。
# 技能等級：Profile B
# Note：
#   <revenge_from_cover:50>
#   <consume_stored_cover>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【I07｜城牆反擊】
# 定位：高OD重擊＋不清空全部蓄痛
# 學習：Lv65 / JP 9000
# 範圍：敵單體
# 資料庫數值：BaseDamage 520 / ATK-F 240 / SPI-F 0 / MP 28 / HIT 95 / Variance 15
# 狀態 / 疊層：無
# 交互：高OD增傷，保留蓄痛給真正終結技。
# 技能等級：Profile B
# Note：
#   <bonus_if_od 70:45>
#   <bonus_per_od_100:5>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【I08｜怒海歸還】
# 定位：終極復仇爆發
# 學習：Lv82 / JP 16000
# 範圍：敵全體
# 資料庫數值：BaseDamage 760 / ATK-F 260 / SPI-F 0 / MP 55 / HIT 100 / Variance 10
# 狀態 / 疊層：可配合 59 防禦下降
# 交互：消耗全部蓄痛，避免無上限儲值。
# 技能等級：Profile D
# Note：
#   <revenge_from_cover:80>
#   <consume_stored_cover>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【IP1｜怒意不熄】
# 定位：被動：高OD減傷
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：高怒氣維持防守價值。
# 技能等級：被動
# Note：
#   <reduce_damage_if_od 50:12>
#   <reduce_damage_per_od_percent:0.08>
#   <hide>
#
# 【IP2｜替身承擔】
# 定位：被動：提高蓄痛容量
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：適合復仇Build。
# 技能等級：被動
# Note：
#   <cover_store_cap_percent:400>
#   <hide>
#
# 【A01｜電刃突刺】
# 定位：基礎輸出／小幅ATB削減
# 學習：Lv1 / JP 0
# 範圍：敵單體
# 資料庫數值：BaseDamage 140 / ATK-F 150 / SPI-F 0 / MP 5 / HIT 97 / Variance 10
# 狀態 / 疊層：無
# 交互：ATB -8%。
# 技能等級：Profile A
# Note：
#   <atb_shift:-8>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【A02｜截流】
# 定位：核心ATB控制
# 學習：Lv8 / JP 400
# 範圍：敵單體
# 資料庫數值：BaseDamage 180 / ATK-F 160 / SPI-F 0 / MP 8 / HIT 97 / Variance 10
# 狀態 / 疊層：無
# 交互：目標ATB≥60%時，削減額外+35%。
# 技能等級：Profile A
# Note：
#   <atb_shift:-16>
#   <atb_bonus_if_target_atb_above 60:35>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【A03｜雷鎖】
# 定位：濕潤Combo
# 學習：Lv16 / JP 800
# 範圍：敵單體
# 資料庫數值：BaseDamage 210 / ATK-F 80 / SPI-F 120 / MP 12 / HIT 95 / Variance 10
# 狀態 / 疊層：33 麻痺 35%
# 交互：目標有 32 濕潤時，ATB削減+60%，麻痺成功率提高。
# 技能等級：Profile A
# Note：
#   <atb_shift:-14>
#   <atb_bonus_vs_state 32:60>
#   <state_chance_vs_state 33,32:30>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【A04｜超載迴路】
# 定位：自我強化
# 學習：Lv25 / JP 1500
# 範圍：自身
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 15 / HIT 100 / Variance 0
# 狀態 / 疊層：42 超載
# 交互：42 可提高ATB削減或AGI，但應有持續時間。
# 技能等級：Profile U
# Note：
#   <cannot level>
#
# 【A05｜時間斷層】
# 定位：成功打斷獎勵OD
# 學習：Lv35 / JP 2800
# 範圍：敵單體
# 資料庫數值：BaseDamage 300 / ATK-F 180 / SPI-F 80 / MP 20 / HIT 97 / Variance 10
# 狀態 / 疊層：無
# 交互：敵ATB≥80%，打到門檻以下視為成功打斷，+100 OD。
# 技能等級：Profile B
# Note：
#   <atb_shift:-24>
#   <atb_bonus_if_target_atb_above 80:50>
#   <atb_interrupt_threshold:80>
#   <atb_interrupt_od:100>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【A06｜鏈式放電】
# 定位：群體濕潤利用
# 學習：Lv48 / JP 5000
# 範圍：敵全體
# 資料庫數值：BaseDamage 260 / ATK-F 60 / SPI-F 180 / MP 28 / HIT 95 / Variance 15
# 狀態 / 疊層：33 麻痺 20%
# 交互：對32濕潤目標傷害+35%，ATB額外削減。
# 技能等級：Profile B
# Note：
#   <bonus_vs_state 32:35>
#   <atb_shift:-10>
#   <atb_bonus_vs_state 32:40>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【A07｜零時封鎖】
# 定位：Boss大招打斷
# 學習：Lv65 / JP 9000
# 範圍：敵單體
# 資料庫數值：BaseDamage 520 / ATK-F 220 / SPI-F 100 / MP 38 / HIT 100 / Variance 5
# 狀態 / 疊層：無
# 交互：敵ATB≥90%時最有價值；高冷卻。
# 技能等級：Profile D
# Note：
#   <atb_shift:-35>
#   <atb_bonus_if_target_atb_above 90:80>
#   <atb_interrupt_threshold:90>
#   <atb_interrupt_od:180>
#   <ricarica turni:3>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【A08｜終端超頻】
# 定位：終極時間壓制
# 學習：Lv82 / JP 16000
# 範圍：敵全體
# 資料庫數值：BaseDamage 760 / ATK-F 180 / SPI-F 220 / MP 60 / HIT 100 / Variance 10
# 狀態 / 疊層：33 麻痺 25%
# 交互：對高ATB目標額外增傷，並削減全體ATB。
# 技能等級：Profile D
# Note：
#   <atb_shift:-22>
#   <bonus_if_target_atb_above 70:40>
#   <atb_bonus_if_target_atb_above 70:50>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【AP1｜靜電回收】
# 定位：被動：ATB削減換更多OD
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：以 cc_od_atb_per_10 強化資源回收。
# 技能等級：被動
# Note：
#   <cc_od_atb_per_10:50>
#   <hide>
#
# 【AP2｜超頻神經】
# 定位：被動：AGI提高
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：讓艾卓更容易搶在敵人行動前截擊。
# 技能等級：被動
# Note：
#   <PASSIVE_SKILL>
#   AGI +12%
#   </PASSIVE_SKILL>
#   <hide>
#
# 【V01｜毒針】
# 定位：基礎疊毒
# 學習：Lv1 / JP 0
# 範圍：敵單體
# 資料庫數值：BaseDamage 90 / ATK-F 0 / SPI-F 140 / MP 5 / HIT 100 / Variance 5
# 狀態 / 疊層：31 中毒，70%基礎
# 交互：維娜成功新增/增加疊層可得OD。
# 技能等級：Profile A
# Note：
#   <state_chance 31:20>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【V02｜毒素培養】
# 定位：快速疊層
# 學習：Lv8 / JP 400
# 範圍：敵單體
# 資料庫數值：BaseDamage 50 / ATK-F 0 / SPI-F 100 / MP 8 / HIT 100 / Variance 0
# 狀態 / 疊層：31 中毒
# 交互：毒未滿5層時優先使用。
# 技能等級：Profile U
# Note：
#   <state_chance 31:35>
#   <cannot level>
#
# 【V03｜毒霧擴散】
# 定位：把成熟毒擴給其他敵人
# 學習：Lv16 / JP 800
# 範圍：敵單體→其他敵人
# 資料庫數值：BaseDamage 80 / ATK-F 0 / SPI-F 100 / MP 12 / HIT 100 / Variance 0
# 狀態 / 疊層：擴散31
# 交互：主目標毒層高時價值最大。
# 技能等級：Profile U
# Note：
#   <spread_state 31:2:60>
#   <cannot level>
#
# 【V04｜寄生漂移】
# 定位：死亡/換目標續航
# 學習：Lv25 / JP 1500
# 範圍：敵單體
# 資料庫數值：BaseDamage 120 / ATK-F 0 / SPI-F 140 / MP 14 / HIT 100 / Variance 5
# 狀態 / 疊層：35 寄生或31漂移
# 交互：把成熟狀態移到新目標，避免多敵戰重新起手。
# 技能等級：Profile A
# Note：
#   <drift_state 31:1>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【V05｜腐蝕煉成】
# 定位：狀態轉換
# 學習：Lv35 / JP 2800
# 範圍：敵單體
# 資料庫數值：BaseDamage 160 / ATK-F 0 / SPI-F 160 / MP 18 / HIT 100 / Variance 5
# 狀態 / 疊層：31 → 37 腐蝕
# 交互：腐蝕偏向破防與隊伍增傷。
# 技能等級：Profile U
# Note：
#   <convert_state 31:37>
#   <cannot level>
#
# 【V06｜百病相生】
# 定位：依目標狀態數增傷
# 學習：Lv48 / JP 5000
# 範圍：敵單體
# 資料庫數值：BaseDamage 280 / ATK-F 0 / SPI-F 220 / MP 22 / HIT 100 / Variance 10
# 狀態 / 疊層：無
# 交互：每個可見狀態+12%，3種以上再+35%。
# 技能等級：Profile B
# Note：
#   <bonus_per_target_state:12>
#   <bonus_if_state_count 3:35>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【V07｜毒爆處刑】
# 定位：核心引爆
# 學習：Lv65 / JP 9000
# 範圍：敵單體
# 資料庫數值：BaseDamage 220 / ATK-F 0 / SPI-F 180 / MP 32 / HIT 100 / Variance 5
# 狀態 / 疊層：消耗31中毒
# 交互：每層SPI倍率+最大HP比例，Boss有上限。
# 技能等級：Profile B
# Note：
#   <detonate_state_spi 31:90>
#   <detonate_state_percent 31:0.8>
#   <detonate_cap:6000>
#   <consume_state 31>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【V08｜萬毒花園】
# 定位：終極群體狀態引擎
# 學習：Lv82 / JP 16000
# 範圍：敵全體
# 資料庫數值：BaseDamage 520 / ATK-F 0 / SPI-F 280 / MP 60 / HIT 100 / Variance 5
# 狀態 / 疊層：31中毒＋37腐蝕
# 交互：全體建立條件，再讓後續角色收割。
# 技能等級：Profile D
# Note：
#   <state_chance 31:30>
#   <state_chance 37:20>
#   <bonus_per_target_state:8>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【VP1｜毒理學】
# 定位：被動：狀態成功率提高
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：用裝備/被動提高SPI與狀態成功率。
# 技能等級：被動
# Note：
#   <PASSIVE_SKILL>
#   SPI +10%
#   </PASSIVE_SKILL>
#   <hide>
#
# 【VP2｜病灶連鎖】
# 定位：被動：狀態疊層給更多OD
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：維娜核心資源加速。
# 技能等級：被動
# Note：
#   <cc_od_state_stack:85>
#   <hide>
#
# 【T01｜震拳】
# 定位：基礎Break
# 學習：Lv1 / JP 0
# 範圍：敵單體
# 資料庫數值：BaseDamage 150 / ATK-F 170 / SPI-F 0 / MP 4 / HIT 95 / Variance 10
# 狀態 / 疊層：50破勢 +1
# 交互：泰勒最基礎的Break入口。
# 技能等級：Profile A
# Note：
#   <break_power:1>
#   <break_state:50>
#   <broken_state:51>
#   <break_threshold:5>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【T02｜破甲連擊】
# 定位：高Break Power
# 學習：Lv8 / JP 400
# 範圍：敵單體
# 資料庫數值：BaseDamage 200 / ATK-F 190 / SPI-F 0 / MP 8 / HIT 95 / Variance 15
# 狀態 / 疊層：50破勢 +2
# 交互：對菁英/Boss更快累積。
# 技能等級：Profile A
# Note：
#   <break_power:2>
#   <break_state:50>
#   <broken_state:51>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【T03｜乘隙追打】
# 定位：利用破勢進度
# 學習：Lv16 / JP 800
# 範圍：敵單體
# 資料庫數值：BaseDamage 240 / ATK-F 210 / SPI-F 0 / MP 10 / HIT 95 / Variance 10
# 狀態 / 疊層：目標有50時增傷
# 交互：Break未完成也有價值。
# 技能等級：Profile A
# Note：
#   <bonus_vs_state 50:35>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【T04｜破陣震波】
# 定位：群體Break
# 學習：Lv25 / JP 1500
# 範圍：敵全體
# 資料庫數值：BaseDamage 180 / ATK-F 140 / SPI-F 0 / MP 16 / HIT 95 / Variance 15
# 狀態 / 疊層：每目標50破勢 +1
# 交互：對多敵戰建立Break壓力。
# 技能等級：Profile A
# Note：
#   <break_power:1>
#   <break_state:50>
#   <broken_state:51>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【T05｜破勢超載】
# 定位：高OD加速Break
# 學習：Lv35 / JP 2800
# 範圍：敵單體
# 資料庫數值：BaseDamage 320 / ATK-F 220 / SPI-F 0 / MP 18 / HIT 95 / Variance 10
# 狀態 / 疊層：50破勢
# 交互：OD≥50 +1 Break，OD≥80再+1。
# 技能等級：Profile B
# Note：
#   <break_power:2>
#   <break_bonus_if_od 50:1>
#   <break_bonus_if_od 80:1>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【T06｜崩防追獵】
# 定位：Broken窗口輸出
# 學習：Lv48 / JP 5000
# 範圍：敵單體
# 資料庫數值：BaseDamage 420 / ATK-F 260 / SPI-F 0 / MP 24 / HIT 100 / Variance 10
# 狀態 / 疊層：51崩防
# 交互：對Broken +80%，不消耗，適合讓全隊繼續利用窗口。
# 技能等級：Profile B
# Note：
#   <bonus_vs_state 51:80>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【T07｜斷城終結】
# 定位：消耗Broken終結技
# 學習：Lv65 / JP 9000
# 範圍：敵單體
# 資料庫數值：BaseDamage 720 / ATK-F 320 / SPI-F 0 / MP 36 / HIT 100 / Variance 5
# 狀態 / 疊層：消耗51崩防
# 交互：爆發高，但犧牲全隊剩餘窗口。
# 技能等級：Profile D
# Note：
#   <bonus_vs_state 51:130>
#   <consume_broken>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【T08｜地裂終章】
# 定位：終極群體破防
# 學習：Lv82 / JP 16000
# 範圍：敵全體
# 資料庫數值：BaseDamage 680 / ATK-F 280 / SPI-F 0 / MP 60 / HIT 100 / Variance 10
# 狀態 / 疊層：50破勢 +2
# 交互：建立全場Break壓力；不應直接免費崩防所有Boss。
# 技能等級：Profile D
# Note：
#   <break_power:2>
#   <break_bonus_if_od 80:1>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【TP1｜鬥志打磨】
# 定位：被動：Break點給更多OD
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：加速泰勒循環。
# 技能等級：被動
# Note：
#   <cc_od_break_point:65>
#   <hide>
#
# 【TP2｜破城者】
# 定位：被動：穿透
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：讓泰勒更像拆防專家。
# 技能等級：被動
# Note：
#   <pen_rate:12>
#   <hide>
#
# 【M01｜治療之觸】
# 定位：基礎單補
# 學習：Lv1 / JP 0
# 範圍：我方單體
# 資料庫數值：BaseDamage -180 / ATK-F 0 / SPI-F 180 / MP 6 / HIT 100 / Variance 5
# 狀態 / 疊層：無
# 交互：有效治療與溢療都能給米亞OD。
# 技能等級：Profile C
# Note：
#   <heal_bonus:10>
#   <max level 4>
#   <level dmg all:+10%>
#
# 【M02｜溢光】
# 定位：治療轉魔力層
# 學習：Lv8 / JP 400
# 範圍：我方單體
# 資料庫數值：BaseDamage -220 / ATK-F 0 / SPI-F 190 / MP 10 / HIT 100 / Variance 5
# 狀態 / 疊層：溢療轉41魔力層
# 交互：建立『治療→蓄魔』循環。
# 技能等級：Profile C
# Note：
#   <overheal_to_state 41:200>
#   <max level 4>
#   <level dmg all:+10%>
#
# 【M03｜魔力護幕】
# 定位：溢療轉Mana Shield
# 學習：Lv16 / JP 800
# 範圍：我方單體
# 資料庫數值：BaseDamage -240 / ATK-F 0 / SPI-F 210 / MP 14 / HIT 100 / Variance 5
# 狀態 / 疊層：52 Mana Shield
# 交互：溢療50%轉盾。
# 技能等級：Profile C
# Note：
#   <overheal_to_shield 52:50>
#   <max level 4>
#   <level dmg all:+10%>
#
# 【M04｜群體禱歌】
# 定位：全體治療
# 學習：Lv25 / JP 1500
# 範圍：我方全體
# 資料庫數值：BaseDamage -180 / ATK-F 0 / SPI-F 160 / MP 24 / HIT 100 / Variance 5
# 狀態 / 疊層：無
# 交互：全隊恢復，效率低於單補。
# 技能等級：Profile C
# Note：
#   <heal_bonus:5>
#   <max level 4>
#   <level dmg all:+10%>
#
# 【M05｜魔力彈】
# 定位：魔力層越高越痛
# 學習：Lv35 / JP 2800
# 範圍：敵單體
# 資料庫數值：BaseDamage 180 / ATK-F 0 / SPI-F 190 / MP 12 / HIT 100 / Variance 10
# 狀態 / 疊層：使用者41魔力層
# 交互：每層 +15%。
# 技能等級：Profile A
# Note：
#   <bonus_per_user_state_stack 41:15>
#   <max level 4>
#   <level dmg all:+12%>
#
# 【M06｜星輝爆發】
# 定位：消耗自身魔力層
# 學習：Lv48 / JP 5000
# 範圍：敵單體
# 資料庫數值：BaseDamage 420 / ATK-F 0 / SPI-F 260 / MP 22 / HIT 100 / Variance 10
# 狀態 / 疊層：消耗使用者41三層
# 交互：魔力層越高越痛，成功後消耗3層。
# 技能等級：Profile B
# Note：
#   <bonus_per_user_state_stack 41:20>
#   <consume_user_state 41:3>
#   <max level 4>
#   <level dmg all:+15%>
#
# 【M07｜生命回響】
# 定位：復活／救場
# 學習：Lv65 / JP 9000
# 範圍：我方死亡單體
# 資料庫數值：BaseDamage -320 / ATK-F 0 / SPI-F 220 / MP 36 / HIT 100 / Variance 0
# 狀態 / 疊層：復活後可搭配64 Regen
# 交互：純功能不升級，避免復活技能因等級爆量。
# 技能等級：Profile U
# Note：
#   <phoenix>
#   <cannot level>
#
# 【M08｜大地頌歌】
# 定位：終極全體治療＋盾
# 學習：Lv82 / JP 16000
# 範圍：我方全體
# 資料庫數值：BaseDamage -520 / ATK-F 0 / SPI-F 300 / MP 60 / HIT 100 / Variance 0
# 狀態 / 疊層：52 Mana Shield
# 交互：大量溢療轉盾與魔力。
# 技能等級：Profile D
# Note：
#   <overheal_to_shield 52:60>
#   <overheal_to_state 41:250>
#   <max level 2>
#   <level dmg all:+12%>
#
# 【MP1｜溢光回路】
# 定位：被動：溢療換更多OD
# 學習：Lv10 / JP 900
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：加速米亞資源循環。
# 技能等級：被動
# Note：
#   <cc_od_overheal_percent:5>
#   <hide>
#
# 【MP2｜大地祝福】
# 定位：被動：SPI與MP
# 學習：Lv40 / JP 4500
# 範圍：被動
# 資料庫數值：BaseDamage 0 / ATK-F 0 / SPI-F 0 / MP 0 / HIT 100 / Variance 0
# 交互：提高治療、魔法與資源上限。
# 技能等級：被動
# Note：
#   <PASSIVE_SKILL>
#   MAXMP +15%
#   SPI +10%
#   </PASSIVE_SKILL>
#   <hide>
# ===============================================================================
# 第三部　Pokémon 類召喚物技能配置
# ===============================================================================
#
# 共通 Actor Note：
#   <summon_type:pokemon>
#   <summon_role:對應角色>
#
# 【P01｜毒芽獸｜Role poison_starter】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:poison_starter>
#   技能1：毒牙
#     Base 90 / ATK-F 140 / SPI-F 0 / MP 4
#     Note：
#       <state_chance 31:25>
#       <ai_prefer_stack_below 31:5>
#   技能2：毒雲
#     Base 40 / ATK-F 0 / SPI-F 130 / MP 8
#     Note：
#       <state_chance 31:35>
#       <ai_prefer_stack_below 31:5>
#
# 【P02｜潮芽獸｜Role wet_starter】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:wet_starter>
#   技能1：水彈
#     Base 110 / ATK-F 0 / SPI-F 150 / MP 5
#     Note：
#       <state_chance 32:35>
#   技能2：潮濕吐息
#     Base 60 / ATK-F 0 / SPI-F 120 / MP 8
#     Note：
#       <ai_bonus_vs_state 33:40>
#
# 【P03｜雷枝獸｜Role paralysis_engine】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:paralysis_engine>
#   技能1：電擊
#     Base 120 / ATK-F 80 / SPI-F 100 / MP 6
#     Note：
#       <ai_require_state:32>
#       <state_chance_vs_state 33,32:35>
#   技能2：靜電跳躍
#     Base 150 / ATK-F 100 / SPI-F 100 / MP 10
#     Note：
#       <bonus_vs_state 32:30>
#       <atb_shift:-8>
#
# 【P04｜火尾獸｜Role burn_starter】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:burn_starter>
#   技能1：火花
#     Base 120 / ATK-F 120 / SPI-F 80 / MP 5
#     Note：
#       <state_chance 34:25>
#   技能2：灼熱撕咬
#     Base 180 / ATK-F 170 / SPI-F 0 / MP 10
#     Note：
#       <bonus_vs_state 34:25>
#
# 【P05｜藤寄獸｜Role parasite_starter】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:parasite_starter>
#   技能1：寄生種子
#     Base 40 / ATK-F 0 / SPI-F 100 / MP 8
#     Note：
#       <state_chance 35:40>
#   技能2：吸生藤
#     Base 120 / ATK-F 60 / SPI-F 140 / MP 10
#     Note：
#       <bonus_vs_state 35:30>
#
# 【P06｜腐蝕獸｜Role corrosion_engine】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:corrosion_engine>
#   技能1：酸液
#     Base 100 / ATK-F 0 / SPI-F 150 / MP 6
#     Note：
#       <state_chance 37:30>
#   技能2：腐蝕催化
#     Base 150 / ATK-F 0 / SPI-F 180 / MP 12
#     Note：
#       <ai_require_state:31>
#       <bonus_vs_state 31:35>
#
# 【P07｜霧足獸｜Role slow_controller】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:slow_controller>
#   技能1：遲霧
#     Base 60 / ATK-F 0 / SPI-F 130 / MP 7
#     Note：
#       <state_chance 38:35>
#   技能2：時間咬擊
#     Base 150 / ATK-F 150 / SPI-F 0 / MP 10
#     Note：
#       <atb_bonus_vs_state 38:40>
#       <atb_shift:-10>
#
# 【P08｜角碎獸｜Role breaker】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:breaker>
#   技能1：角撞
#     Base 150 / ATK-F 170 / SPI-F 0 / MP 5
#     Note：
#       <break_power:1>
#   技能2：重角衝
#     Base 240 / ATK-F 220 / SPI-F 0 / MP 12
#     Note：
#       <break_power:2>
#       <ricarica turni:2>
#
# 【P09｜殼守獸｜Role protector】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:protector>
#   技能1：守殼
#     Base 0 / ATK-F 0 / SPI-F 0 / MP 4
#     Note：
#       <AI評価:60>
#   技能2：反震
#     Base 120 / ATK-F 120 / SPI-F 0 / MP 8
#     Note：
#       <bonus_if_user_state 55:30>
#
# 【P10｜露靈獸｜Role healer】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:healer>
#   技能1：生命露
#     Base -150 / ATK-F 0 / SPI-F 160 / MP 8
#     Note：
#       <AI評価:80>
#   技能2：淨露
#     Base -90 / ATK-F 0 / SPI-F 120 / MP 10
#     Note：
#       <AI評価:70>
#
# 【P11｜風脈獸｜Role resonance_fast】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:resonance_fast>
#   技能1：疾風爪
#     Base 110 / ATK-F 140 / SPI-F 0 / MP 3
#     Note：
#       <crit_rate:5>
#   技能2：風躍
#     Base 150 / ATK-F 150 / SPI-F 0 / MP 6
#     Note：
#       <AI評価:20>
#
# 【P12｜獵影獸｜Role crit_hunter】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:crit_hunter>
#   技能1：獵影
#     Base 170 / ATK-F 180 / SPI-F 0 / MP 8
#     Note：
#       <crit_rate:15>
#   技能2：處決牙
#     Base 240 / ATK-F 220 / SPI-F 0 / MP 14
#     Note：
#       <bonus_if_target_atb_above 80:25>
#
# 【P13｜疫羽獸｜Role state_spreader】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:state_spreader>
#   技能1：疫羽
#     Base 80 / ATK-F 0 / SPI-F 130 / MP 8
#     Note：
#       <spread_state 31:2:50>
#   技能2：病羽雨
#     Base 120 / ATK-F 0 / SPI-F 150 / MP 14
#     Note：
#       <bonus_per_target_state:8>
#
# 【P14｜遷毒獸｜Role drift_engine】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:drift_engine>
#   技能1：毒遷
#     Base 60 / ATK-F 0 / SPI-F 120 / MP 8
#     Note：
#       <drift_state 31:1>
#   技能2：殘毒追獵
#     Base 150 / ATK-F 150 / SPI-F 0 / MP 10
#     Note：
#       <bonus_vs_state 31:30>
#
# 【P15｜噬終獸｜Role finisher】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:finisher>
#   技能1：追命
#     Base 220 / ATK-F 220 / SPI-F 0 / MP 12
#     Note：
#       <bonus_if_state_count 3:45>
#   技能2：獵殺
#     Base 320 / ATK-F 260 / SPI-F 0 / MP 18
#     Note：
#       <AI評価:35>
#
# 【P16｜磁食獸｜Role anti_robot】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:anti_robot>
#   技能1：磁噬
#     Base 180 / ATK-F 180 / SPI-F 0 / MP 10
#     Note：
#       <bonus_vs_type robot:60>
#   技能2：過載咬擊
#     Base 220 / ATK-F 200 / SPI-F 0 / MP 14
#     Note：
#       <atb_shift:-12>
#
# 【P17｜巨根獸｜Role anti_boss】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:anti_boss>
#   技能1：沉根擊
#     Base 220 / ATK-F 190 / SPI-F 0 / MP 10
#     Note：
#       <pen_rate:10>
#   技能2：壓脈
#     Base 280 / ATK-F 220 / SPI-F 0 / MP 18
#     Note：
#       <break_power:1>
#       <bonus_vs_state 51:30>
#
# 【P18｜岩甲獸｜Role tank_provoke】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:tank_provoke>
#   技能1：挑釁咆哮
#     Base 0 / ATK-F 0 / SPI-F 0 / MP 8
#     Note：
#       <AI評価:80>
#   技能2：岩甲撞
#     Base 160 / ATK-F 150 / SPI-F 0 / MP 8
#     Note：
#       <state_chance 49:10>
#
# 【P19｜星孢獸｜Role magic_artillery】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:magic_artillery>
#   技能1：孢光彈
#     Base 180 / ATK-F 0 / SPI-F 220 / MP 10
#     Note：
#       <crit_rate:5>
#   技能2：星孢爆
#     Base 320 / ATK-F 0 / SPI-F 280 / MP 20
#     Note：
#       <ricarica turni:2>
#
# 【P20｜古森龍獸｜Role legendary_hybrid】
# Actor Note：
#   <summon_type:pokemon>
#   <summon_role:legendary_hybrid>
#   技能1：古森吐息
#     Base 340 / ATK-F 140 / SPI-F 220 / MP 18
#     Note：
#       <bonus_per_target_state:10>
#   技能2：龍脈終響
#     Base 520 / ATK-F 180 / SPI-F 260 / MP 32
#     Note：
#       <ricarica turni:3>
#       <AI評価:50>
#
# ===============================================================================
# 第四部　Robot 類召喚物技能配置
# ===============================================================================
#
# 【R01｜壁壘機｜Role protector】
# Actor Note：
#   <summon_type:robot>
#   <summon_role:protector>
# 協議：每3次行動展開護盾
#   技能1：防衛協議
#     Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#     Note：
#       <robot_protocol_skill:241>
#       <robot_protocol_interval:3>
#   技能2：備用脈衝
#     Base 90 / ATK-F 100 / SPI-F 0 / MP 0
#     Note：
#       （無）
#
# 【R02｜雷序機｜Role atb_controller】
# Actor Note：
#   <summon_type:robot>
#   <summon_role:atb_controller>
# 協議：濕潤時優先雷擊
#   技能1：截流協議
#     Base 180 / ATK-F 80 / SPI-F 160 / MP 0
#     Note：
#       <robot_protocol_skill:242>
#       <robot_protocol_interval:3>
#       <robot_protocol_if_state 32:242>
#       <atb_shift:-18>
#   技能2：備用電弧
#     Base 120 / ATK-F 60 / SPI-F 120 / MP 0
#     Note：
#       <atb_shift:-6>
#
# 【R03｜腐蝕機｜Role corrosion_engine】
# Actor Note：
#   <summon_type:robot>
#   <summon_role:corrosion_engine>
# 協議：中毒時施加腐蝕
#   技能1：催化協議
#     Base 160 / ATK-F 0 / SPI-F 180 / MP 0
#     Note：
#       <robot_protocol_skill:243>
#       <robot_protocol_interval:3>
#       <robot_protocol_if_state 31:243>
#       <state_chance 37:40>
#   技能2：酸霧
#     Base 100 / ATK-F 0 / SPI-F 140 / MP 0
#     Note：
#       <state_chance 37:20>
#
# 【R04｜破城機｜Role breaker】
# Actor Note：
#   <summon_type:robot>
#   <summon_role:breaker>
# 協議：固定週期施加Break
#   技能1：破城協議
#     Base 240 / ATK-F 230 / SPI-F 0 / MP 0
#     Note：
#       <robot_protocol_skill:244>
#       <robot_protocol_interval:4>
#       <break_power:2>
#   技能2：衝錘
#     Base 150 / ATK-F 180 / SPI-F 0 / MP 0
#     Note：
#       <break_power:1>
#
# 【R05｜淨化機｜Role healer】
# Actor Note：
#   <summon_type:robot>
#   <summon_role:healer>
# 協議：定期淨化／支援
#   技能1：淨化協議
#     Base -120 / ATK-F 0 / SPI-F 150 / MP 0
#     Note：
#       <robot_protocol_skill:245>
#       <robot_protocol_interval:3>
#   技能2：修復光
#     Base -80 / ATK-F 0 / SPI-F 110 / MP 0
#     Note：
#       （無）
#
# ===============================================================================
# 第五部　Clone 類召喚物技能配置
# ===============================================================================
#
# Clone 建議使用 MP 當「穩定度」。技能越精準，消耗越高。
#
# 【C01｜狙擊複製體｜Role finisher】
# Actor Note：
#   <summon_type:clone>
#   <summon_role:finisher>
#   技能1：精準射擊
#     Base 220 / ATK-F 240 / SPI-F 0 / 穩定度消耗 12
#     Note：
#       <crit_rate:15>
#   技能2：崩防狙殺
#     Base 420 / ATK-F 300 / SPI-F 0 / 穩定度消耗 26
#     Note：
#       <bonus_vs_state 51:100>
#   技能3：處刑
#     Base 520 / ATK-F 320 / SPI-F 0 / 穩定度消耗 36
#     Note：
#       <bonus_if_state_count 3:60>
#
# 【C02｜醫療複製體｜Role healer】
# Actor Note：
#   <summon_type:clone>
#   <summon_role:healer>
#   技能1：戰場治療
#     Base -180 / ATK-F 0 / SPI-F 180 / 穩定度消耗 14
#     Note：
#       （無）
#   技能2：緊急復甦
#     Base -260 / ATK-F 0 / SPI-F 220 / 穩定度消耗 30
#     Note：
#       <phoenix>
#   技能3：穩定護幕
#     Base -120 / ATK-F 0 / SPI-F 160 / 穩定度消耗 24
#     Note：
#       <overheal_to_shield 52:40>
#
# 【C03｜破陣複製體｜Role breaker】
# Actor Note：
#   <summon_type:clone>
#   <summon_role:breaker>
#   技能1：精準破甲
#     Base 200 / ATK-F 220 / SPI-F 0 / 穩定度消耗 14
#     Note：
#       <break_power:2>
#   技能2：破勢終端
#     Base 360 / ATK-F 280 / SPI-F 0 / 穩定度消耗 28
#     Note：
#       <bonus_vs_state 50:50>
#   技能3：崩防終結
#     Base 620 / ATK-F 340 / SPI-F 0 / 穩定度消耗 42
#     Note：
#       <bonus_vs_state 51:100>
#       <consume_broken>
#
# 【C04｜控制複製體｜Role controller】
# Actor Note：
#   <summon_type:clone>
#   <summon_role:controller>
#   技能1：緩速彈
#     Base 100 / ATK-F 100 / SPI-F 100 / 穩定度消耗 12
#     Note：
#       <state_chance 38:30>
#       <atb_shift:-8>
#   技能2：打斷射線
#     Base 260 / ATK-F 160 / SPI-F 160 / 穩定度消耗 26
#     Note：
#       <atb_interrupt_threshold:80>
#       <atb_shift:-22>
#   技能3：封鎖網
#     Base 180 / ATK-F 120 / SPI-F 180 / 穩定度消耗 34
#     Note：
#       <state_chance 45:25>
#
# 【C05｜毒爆複製體｜Role detonator】
# Actor Note：
#   <summon_type:clone>
#   <summon_role:detonator>
#   技能1：定點注毒
#     Base 80 / ATK-F 0 / SPI-F 160 / 穩定度消耗 10
#     Note：
#       <state_chance 31:35>
#   技能2：毒層校準
#     Base 120 / ATK-F 0 / SPI-F 180 / 穩定度消耗 18
#     Note：
#       <ai_prefer_stack_below 31:5>
#   技能3：毒爆狙擊
#     Base 300 / ATK-F 0 / SPI-F 260 / 穩定度消耗 34
#     Note：
#       <detonate_state_spi 31:80>
#       <consume_state 31>
# ===============================================================================
# 第六部　敵方共用技能庫
# ===============================================================================
#
# 普通怪不需要每隻都有 8 招。建議 2～4 招，靠編成互補。
#
# 【普通小怪】
# E-C01｜撕咬
#   定位：普通單體物理
#   Base 100 / ATK-F 150 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-C02｜毒牙
#   定位：疊毒
#   Base 80 / ATK-F 140 / SPI-F 0 / MP 0
#   Note：
#     <state_chance 31:20>
# E-C03｜泥水噴濺
#   定位：濕潤起手
#   Base 90 / ATK-F 0 / SPI-F 140 / MP 0
#   Note：
#     <state_chance 32:30>
# E-C04｜電弧
#   定位：濕潤→麻痺
#   Base 110 / ATK-F 60 / SPI-F 120 / MP 0
#   Note：
#     <state_chance_vs_state 33,32:25>
# E-C05｜火花
#   定位：灼燒
#   Base 110 / ATK-F 80 / SPI-F 100 / MP 0
#   Note：
#     <state_chance 34:20>
# E-C06｜遲緩唾液
#   定位：ATB控制
#   Base 70 / ATK-F 0 / SPI-F 120 / MP 0
#   Note：
#     <state_chance 38:25>
#     <atb_shift:-8>
# E-C07｜護殼
#   定位：防禦提升
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-C08｜鼓舞
#   定位：攻擊提升
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-C09｜小治療
#   定位：自我/友軍恢復
#   Base -120 / ATK-F 0 / SPI-F 140 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-C10｜腐蝕液
#   定位：降低防守
#   Base 100 / ATK-F 0 / SPI-F 150 / MP 0
#   Note：
#     <state_chance 37:25>
# E-C11｜標記獵物
#   定位：建立集火條件
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-C12｜召喚援軍
#   定位：呼叫同伴
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
#
# 【菁英怪】
# E-E01｜獵殺標記
#   定位：標記後高傷
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-E02｜重擊處刑
#   定位：條件爆發
#   Base 360 / ATK-F 260 / SPI-F 0 / MP 0
#   Note：
#     <bonus_if_state_count 2:40>
# E-E03｜毒爆
#   定位：消耗中毒
#   Base 220 / ATK-F 0 / SPI-F 220 / MP 0
#   Note：
#     <detonate_state_spi 31:70>
#     <consume_state 31>
# E-E04｜破陣槌
#   定位：Break
#   Base 260 / ATK-F 250 / SPI-F 0 / MP 0
#   Note：
#     <break_power:2>
# E-E05｜ATB截擊
#   定位：打斷玩家
#   Base 240 / ATK-F 180 / SPI-F 100 / MP 0
#   Note：
#     <atb_shift:-18>
# E-E06｜群體遲緩
#   定位：控制全體
#   Base 140 / ATK-F 0 / SPI-F 180 / MP 0
#   Note：
#     <state_chance 38:20>
# E-E07｜精英護盾
#   定位：Mana Shield
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-E08｜淨化
#   定位：解除負面
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-E09｜憤怒增幅
#   定位：低HP進入強化
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-E10｜召喚獵人
#   定位：對召喚物增傷
#   Base 280 / ATK-F 220 / SPI-F 0 / MP 0
#   Note：
#     <bonus_vs_type pokemon:50>
# E-E11｜破綻反擊
#   定位：對Broken隊員增傷
#   Base 320 / ATK-F 240 / SPI-F 0 / MP 0
#   Note：
#     <bonus_vs_state 51:60>
# E-E12｜群體壓迫
#   定位：全體中傷
#   Base 220 / ATK-F 180 / SPI-F 120 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
#
# 【Boss】
# E-B01｜蓄力預告
#   定位：Tell：施加75蓄力預告
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B02｜天崩重擊
#   定位：Payoff：重型單體
#   Base 800 / ATK-F 360 / SPI-F 0 / MP 0
#   Note：
#     <pen_rate:20>
# E-B03｜全域震波
#   定位：群體壓力
#   Base 620 / ATK-F 240 / SPI-F 160 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B04｜狀態洗牌
#   定位：擴散/轉換玩家狀態
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B05｜抗性進化
#   定位：Phase State
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B06｜時間吞噬
#   定位：ATB反制
#   Base 420 / ATK-F 220 / SPI-F 180 / MP 0
#   Note：
#     <atb_shift:-25>
# E-B07｜召喚物獵殺
#   定位：召喚物特攻
#   Base 520 / ATK-F 280 / SPI-F 0 / MP 0
#   Note：
#     <bonus_vs_type pokemon:80>
# E-B08｜壁壘再生
#   定位：Break回復／護盾
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B09｜破勢反噬
#   定位：對高Break隊伍施壓
#   Base 480 / ATK-F 300 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B10｜毒素清除
#   定位：移除成熟毒層
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B11｜多重行動協議
#   定位：第二行動
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B12｜狂暴
#   定位：76狂暴
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B13｜階段轉換
#   定位：切換Phase
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# E-B14｜終局壓力
#   定位：低HP強化全體技
#   Base 980 / ATK-F 320 / SPI-F 220 / MP 0
#   Note：
#     <pen_rate:15>
# E-B15｜死亡倒數
#   定位：81 Doom
#   Base 0 / ATK-F 0 / SPI-F 0 / MP 0
#   Note：
#     （依資料庫狀態/事件設定）
# ===============================================================================
# ===============================================================================
# 第六-A部　AntagonistMechanicCore 反派專用技能庫
# ===============================================================================
#
# 本節新增：
#   ・觀律者 莉瑟・奧爾登
#   ・鎮律者 葛蘭・沃德
#   ・改譜師 諾維亞・賽恩
#   ・賽勒斯・赫恩
#
# 注意：
#   以下 A-Sxx 是設計代碼，不是資料庫 Skill ID。
#
# ===============================================================================
# 【觀律者 莉瑟・奧爾登】
# ===============================================================================
#
# 【A-L01｜觀測脈衝】
#
# 定位：
#   普通節奏技。
#
# 範圍：
#   敵單體。
#
# 建議數值：
#   BaseDamage 180
#   ATK-F 0
#   SPI-F 180
#   HIT 100
#   Variance 8
#
# Note：
#   （無必要額外Note）
#
# 用途：
#   讓莉瑟不必每回合都靠特殊機制，
#   留出觀律累積時間。
#
# -------------------------------------------------------------------------------
#
# 【A-L02｜偏差校準】
#
# 定位：
#   對觀律目標增傷。
#
# 範圍：
#   敵單體。
#
# 建議數值：
#   BaseDamage 280
#   SPI-F 220
#   MP 18
#
# Note：
#   <bonus_vs_state 120:50>
#
# 設計：
#   State120只要存在就增傷。
#   高疊層再由更高階技能處理。
#
# -------------------------------------------------------------------------------
#
# 【A-L03｜觀律處刑】
#
# 定位：
#   引爆120疊層。
#
# 建議數值：
#   BaseDamage 240
#   SPI-F 260
#   MP 30
#
# Note：
#   <detonate_state_spi 120:70>
#   <detonate_cap:5000>
#   <consume_state 120>
#
# 平衡：
#   不要一開始就用。
#   AI應只在120達3～5層時提高Rating。
#
# -------------------------------------------------------------------------------
#
# 【A-L04｜視界封閉】
#
# 定位：
#   群體壓力。
#
# 範圍：
#   我方全體。
#
# 建議數值：
#   BaseDamage 260
#   SPI-F 180
#   MP 28
#
# 功能：
#   清場／防止玩家完全交給召喚物拖時間。
#
# ===============================================================================
# 【鎮律者 葛蘭・沃德】
# ===============================================================================
#
# 【A-G01｜雙弦鎖定】
#
# 定位：
#   建立雙弦。
#
# 範圍：
#   我方2名或全體命中取前2名。
#
# 建議數值：
#   BaseDamage 80
#   ATK-F 80
#   SPI-F 80
#
# Note：
#   <double_thread:121,40>
#   <double_thread_animation:45>
#
# 不加：
#   <double_thread_lethal>
#
# 用途：
#   建立第一層壓力。
#
# -------------------------------------------------------------------------------
#
# 【A-G02｜鎮律重壓】
#
# 定位：
#   對雙弦對象施壓。
#
# 建議數值：
#   BaseDamage 380
#   ATK-F 260
#   SPI-F 0
#   MP 22
#
# Note：
#   <bonus_vs_state 121:35>
#
# 用途：
#   讓玩家必須處理121。
#
# -------------------------------------------------------------------------------
#
# 【A-G03｜靜止令】
#
# 定位：
#   ATB控制。
#
# 建議數值：
#   BaseDamage 220
#   ATK-F 180
#   MP 24
#
# Note：
#   <atb_shift:-18>
#
# 對Boss本身：
#   建議啟用ATB動態抗性，
#   但此技能是敵人打玩家，不受Boss抗性影響。
#
# -------------------------------------------------------------------------------
#
# 【A-G04｜斷弦處決】
#
# 定位：
#   高階致死雙弦。
#
# 建議數值：
#   BaseDamage 620
#   ATK-F 320
#   MP 45
#
# Note：
#   <double_thread:121,55>
#   <double_thread_animation:45>
#   <double_thread_lethal>
#
# 前提：
#   必須有明確Tell。
#   不可常態亂放。
#
# ===============================================================================
# 【改譜師 諾維亞・賽恩】
# ===============================================================================
#
# 【A-N01｜人格改譜】
#
# 定位：
#   六主角差異化Debuff。
#
# 範圍：
#   我方單體或全體。
#
# 建議數值：
#   BaseDamage 120
#   SPI-F 120
#   MP 18
#
# Note：
#   <rewrite_actor 1:130>
#   <rewrite_actor 2:131>
#   <rewrite_actor 3:132>
#   <rewrite_actor 4:133>
#   <rewrite_actor 5:134>
#   <rewrite_actor 6:135>
#   <rewrite_default_state:139>
#
# 用途：
#   同一招對不同主角產生不同結果。
#
# -------------------------------------------------------------------------------
#
# 【A-N02｜譜面覆寫】
#
# 定位：
#   對已有改譜State者增傷。
#
# 建議數值：
#   BaseDamage 300
#   SPI-F 240
#   MP 24
#
# Note：
#   可依資料庫設多版本：
#
#   喬伊版：
#     <bonus_vs_state 130:50>
#
#   米亞版：
#     <bonus_vs_state 131:50>
#
# 或做群體技，
# 不必六種都硬塞同一技能。
#
# -------------------------------------------------------------------------------
#
# 【A-N03｜空白化】
#
# 定位：
#   清除玩家已有Buff後再施加139。
#
# 目前腳本沒有一個 Antagonist Note 自動做「清Buff」。
# 因此建議：
#   使用既有State解除／技能設定，
#   再配：
#
#   <rewrite_default_state:139>
#
# 不要在資料庫Note寫一個不存在的功能，
# 然後期待程式被你的決心感動。
#
# ===============================================================================
# 【賽勒斯・赫恩】
# ===============================================================================
#
# 【A-C01｜全知儀啟動】
#
# 定位：
#   Phase 1 開場。
#
# 效果：
#   對自身加入 State150。
#
# Enemy Note：
#   <observe_repeat_state:120>
#   <observe_same_skill:1>
#   <observe_same_element:1>
#   <observe_stack_both>
#   <observe_if_state:150>
#   <observe_main_actors_only>
#
# 建議：
#   用戰鬥事件或技能 State Plus 控制150。
#
# -------------------------------------------------------------------------------
#
# 【A-C02｜偏差清算】
#
# 定位：
#   觀律高層爆發。
#
# 建議數值：
#   BaseDamage 360
#   SPI-F 260
#
# Note：
#   <bonus_vs_state 120:60>
#
# 高階版：
#   <detonate_state_spi 120:80>
#   <consume_state 120>
#
# -------------------------------------------------------------------------------
#
# 【A-C03｜大諧律啟動】
#
# 定位：
#   Phase 2 開場。
#
# 效果：
#   自身加入 State151。
#
# Enemy Note：
#   <law_cycle_states:140,141,142,143>
#   <law_cycle_actions:2>
#   <law_cycle_if_state:151>
#
# -------------------------------------------------------------------------------
#
# 【A-C04｜第一律・觀測】
#
# 條件：
#   Boss有State140。
#
# AI：
#   觀律類技能 Rating提高。
#
# 推薦技能：
#   A-C02 偏差清算。
#
# -------------------------------------------------------------------------------
#
# 【A-C05｜第二律・鎮壓】
#
# 條件：
#   Boss有State141。
#
# 推薦：
#   雙弦
#   ATB削減
#   召喚物獵殺
#
# Note範例：
#   <double_thread:121,40>
#
# -------------------------------------------------------------------------------
#
# 【A-C06｜第三律・改譜】
#
# 條件：
#   Boss有State142。
#
# 推薦：
#   人格改譜。
#
# Note：
#   <rewrite_actor 1:130>
#   ...
#   <rewrite_default_state:139>
#
# -------------------------------------------------------------------------------
#
# 【A-C07｜第四律・歸一】
#
# 條件：
#   Boss有State143。
#
# 定位：
#   AOE高壓。
#
# 建議數值：
#   BaseDamage 620
#   ATK-F 160
#   SPI-F 280
#   MP 45
#
# 可搭配：
#   <bonus_if_state_count 2:30>
#
# 但不要同時：
#   雙弦 lethal
#   全體9999
#   解除所有Buff
#   禁止治療
#   外加 ATB歸零。
#
# Boss可以很強，
# 不必像喝醉的系統管理員一樣把每個權限都打開。
#
# -------------------------------------------------------------------------------
#
# 【A-C08｜失奏】
#
# 定位：
#   Phase 3切換。
#
# 效果：
#   自身加入 State152。
#   移除 State151。
#   清除140～143。
#
# 設計：
#   失去完美循環，
#   改為較高攻擊頻率與直接傷害。
#
# -------------------------------------------------------------------------------
#
# 【A-C09｜失奏裂響】
#
# 定位：
#   Phase3核心單體技。
#
# 建議數值：
#   BaseDamage 760
#   ATK-F 280
#   SPI-F 220
#   MP 50
#
# Note：
#   <pen_rate:15>
#
# 不要依賴140～143。
#
# -------------------------------------------------------------------------------
#
# 【A-C10｜最後的諧律】
#
# 定位：
#   終局大招。
#
# 建議數值：
#   BaseDamage 980
#   ATK-F 240
#   SPI-F 320
#   MP 70
#
# 條件：
#   低HP／Phase3。
#
# 設計：
#   強，但應有Tell。
#
# ===============================================================================
# 【反派技能與六主角Build的關係】
# ===============================================================================
#
# 觀律：
#   反制重複技能與單屬性循環。
#
# 雙弦：
#   提高米亞Mana Shield與單體治療價值。
#   使艾薇Cover出現高風險高報酬。
#
# 改譜：
#   迫使召喚物補位與解除State。
#
# 大諧律：
#   迫使玩家依當前法則改變節奏。
#
# 所以往後敵方技能設計不能只分類：
#
#   物理
#   魔法
#   補血
#   Debuff
#
# 還要分類：
#
#   習慣反制
#   身份反制
#   HP關係反制
#   節奏反制
#
# ===============================================================================

# 第七部　本設計使用到的 Note Tag，逐個列出
# ===============================================================================
#
# 【傷害與條件】
#
# <bonus_vs_state 31:50>
#   目標有 State 31 時，傷害 +50%。
#
# <bonus_if_user_state 40:30>
#   使用者有指定 State 時增傷。
#
# <bonus_per_target_state:10>
#   目標每個 State 額外增傷。
#
# <bonus_if_state_count 3:50>
#   目標狀態數達門檻增傷。
#
# <bonus_if_od 50:30>
#   OD 達門檻增傷。
#
# <bonus_per_od_percent:0.5>
#   每 1% OD 增傷。
#
# <bonus_per_od_100:10>
#   每 100 OD 增傷。
#
# <bonus_if_target_atb_above 80:30>
#   目標 ATB 高於門檻增傷。
#
# <bonus_per_user_state_stack 41:15>
#   使用者指定 State 每層增傷。
#
# <pen_rate:20>
#   穿透 20%。
#
# <crit_rate:10>
#   額外暴擊率。
#
# 【State 成功率】
#
# <state_chance 31:20>
#   施加 State31 成功率 +20%。
#
# <state_chance_vs_state 33,32:30>
#   若目標已有32，施加33額外 +30%。
#
# <state_chance_if_user_state 31,40:30>
#   使用者有40時，施加31額外 +30%。
#
# <state_chance_if_od 31,50:20>
#   OD達50%時額外 +20%。
#
# <state_chance_per_od_percent 31:0.2>
#   每1% OD額外 +0.2%。
#
# 【State 加工】
#
# <spread_state 31:2>
# <spread_state 31:2:50>
#   擴散指定 State。
#
# <drift_state 31:1>
#   飄移 State。
#
# <convert_state 31:37>
#   轉換 State。
#
# <detonate_state 31:150>
#   固定值疊層爆發。
#
# <detonate_state_spi 31:90>
#   每層按使用者 SPI 計算。
#
# <detonate_state_atk 31:90>
#   每層按使用者 ATK 計算。
#
# <detonate_state_percent 31:0.8>
#   每層按目標最大HP百分比。
#
# <detonate_cap:6000>
#   爆發追加傷害上限。
#
# <consume_state 31>
#   成功後消耗目標 State。
#
# <consume_user_state 41:3>
#   成功後消耗使用者自身 State 三層。
#
# 【ATB】
#
# <atb_shift:-16>
#   削減 16% ATB。
#
# <atb_bonus_vs_state 32:60>
#   目標有指定 State 時，ATB變化幅度增加。
#
# <atb_bonus_if_target_atb_above 80:50>
#   目標ATB高時增加削減。
#
# <atb_interrupt_threshold:80>
#   目標原本ATB≥80%，被打到門檻下視為打斷。
#
# <atb_interrupt_od:100>
#   打斷成功給100 OD。
#
# 【Break】
#
# <break_power:2>
#   增加2點Break。
#
# <break_state:50>
#   指定Break進度 State。
#
# <broken_state:51>
#   指定崩防 State。
#
# <break_threshold:5>
#   技能預設Break門檻。
#
# <break_bonus_if_od 50:1>
#   OD門檻額外Break Power。
#
# <consume_broken>
#   成功後消耗崩防。
#
# 【治療 / 溢療】
#
# <heal_bonus:10>
#   治療量 +10%。
#
# <heal_bonus_if_od 50:20>
#   OD門檻提高治療。
#
# <heal_bonus_per_od_percent:0.2>
#   每1% OD提高治療。
#
# <overheal_to_state 41:200>
#   每200溢療增加41一層。
#
# <overheal_to_shield 52:50>
#   50%溢療轉State52護盾。
#
# <overheal_to_od:50>
#   溢療轉OD。
#
# <overheal_to_mp:30>
#   溢療轉目標MP。
#
# <overheal_to_user_mp:30>
#   溢療轉使用者MP。
#
# 【召喚追擊】
#
# <summon_followup_type pokemon:241:650:150>
#   依召喚類型找追擊者。
#
# <summon_followup_role poison_starter:241:500:100>
#   依角色功能找追擊者。
#
# <summon_chain_type 1:pokemon:241:700:0>
#   三段鏈指定類型。
#
# <summon_chain_role 1:starter:241:900:0>
#   三段鏈指定Role。
#
# 【Ivy 蓄痛】
#
# <revenge_from_cover:50>
#   追加蓄痛50%。
#
# <consume_stored_cover>
#   成功後清空蓄痛。
#
# 【Pokémon AI】
#
# <ai_bonus_vs_state 31:100>
#   目標有31時，AI評價+100。
#
# <ai_require_state:31>
#   沒有31就不考慮此技能。
#
# <ai_prefer_stack_below 31:5>
#   31低於5層時提高優先度。
#
# <AI評価:50>
# <AI_RATING:50>
#   額外AI評分。
#
# <AI除外>
# <AI_EXCLUDE>
#   AI不使用。
#
# 【Robot Protocol】
#
# <robot_protocol_skill:241>
#   預設協議技能。
#
# <robot_protocol_interval:3>
#   每3次行動觸發協議。
#
# <robot_protocol_if_state 31:241>
#   有31時改用指定協議技能。
#
# 【Cooldown】
#
# <ricarica turni:3>
#   戰鬥回合冷卻。
#
# 【技能等級】
#
# <max level 4>
#   最大技能等級。
#
# <cannot level>
#   不可升級。
#
# <level dmg all:+12%>
#   每技能等級 +12%。
#
# <level 1 jp cost:600>
#   指定升級JP。
#
# 【學習 JP】
#
# <jp cost:1500>
#   學習技能需要1500 JP。
#
# <jp level:25>
#   角色至少Lv25。
#
# <jp skill:123>
# <jp skills:123,124>
#   前置技能。
#
# <jp skill 123 at level 3>
#   前置技能需升到3級。
#
# 【技能使用條件】
#
# <特殊使用条件>
# ステート,41
# </特殊使用条件>
#
# 需要指定 State。
#
# 可用條件：
#   最大HP / 最大MP / HP / MP
#   HP％以上 / MP％以上 / HP％以下 / MP％以下
#   攻撃力 / 守備力 / 精神力 / 敏捷性
#   ステート / 武器 / 防具 / 属性 / スイッチ
#   狀態開關 / 封印狀態
#
# ===============================================================================
# 第八部　技能ID規劃建議
# ===============================================================================
#
# 不要直接把本文代碼 J01 / I01 當資料庫 ID。
#
# 建議先依 Protected IDs 文件避開：
#   Skill 83（月紳士追加條件Dummy）
#   既有職業清單與現有正式技能。
#
# 推薦區段：
#   300～339 喬伊
#   340～379 米亞
#   380～419 艾卓
#   420～459 維娜
#   460～499 艾薇
#   500～539 泰勒
#   600～699 Pokémon召喚
#   700～749 Robot
#   750～799 Clone
#   800～899 敵方共用技能
#   900+ Boss專用
#
# 正式採用前仍要搜尋最新腳本與資料庫。
# 「看起來空著」是 RPG Maker 世界裡最不可靠的證詞之一。
