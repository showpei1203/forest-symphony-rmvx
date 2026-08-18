#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SummonUI_Authority v2.8
# 【用途】Forest Symphony 正式 Authority「FS_SummonUI_Authority v2.8」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Window_Base、Window_EquipStat、Scene_Equip、FS_SUMMON_GUIDE_V22、FS_SUMMON_COMPACT_V28
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DATA、PAGE_NAMES、ROLE_LABELS、VISUAL_RAISE、SKILL_X_OFFSET、SKILL_FONT_SIZE、SKILL_LINE_HEIGHT、ELEMENT_NAME_TO_SYMBOL。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# PHASE6 ORIGINAL PAGE: 425 | SummonUI_v2_3
#==============================================================================
#==============================================================================
# ■ FS_SummonUI_v2_3 - YEM Equipment 召喚頁分頁版
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 重要：
#   本腳本不是新增另一個 Window。
#   它重畫 YEM Equipment Overhaul 既有的 Window_EquipStat 召喚物頁面。
#
# 修正 v2.3：
#   1. RPG Maker VX 的 Window_Base 沒有 disabled_color。
#   2. 未習得技能改用安全的半透明 normal_color。
#   3. 同時提供全域 disabled_color 相容方法，修正 CharacterBook 同類問題。
#
# 沿用 v2.2：
#   1. 不再從 Y=180 往下硬塞 6～8 行，避免 544x416 畫面裁切。
#   2. 改為三頁：能力／特色／招式。
#   3. Shift(Input::A) 切頁，換裝備時自動回到能力頁。
#   4. 未習得招式灰字，並保留屬性 Icon。
#   5. 能力頁保留原本的姓名、等級、HP/MP、能力、臉圖與動態行走圖。
#
# 安裝位置：
#   YEM Equipment Overhaul
#   Albert_YEM_EquipmentOverhaul_SafetyPatch
#   Albert_YEM_Equip_SummonPage_Extension
#   Equip_SummonPage_SkillElementIcon
#   FS_SummonUI_v2_3              ← 本腳本
#   Main
#
# 請移除／停用 FS_SummonUI_v2_1 與 v2_2，只保留 v2_3。
#==============================================================================
#==============================================================================
# ■ Window_Base：disabled_color 相容
#------------------------------------------------------------------------------
# VX 原生 Window_Base 沒有 disabled_color。部分 Ace／後期腳本習慣直接呼叫，
# 因此在未習得技能、未發現角色等灰字情境會發生 NameError。
#==============================================================================
class Window_Base < Window
  unless method_defined?(:disabled_color)
    def disabled_color
      color = normal_color
      return Color.new(color.red, color.green, color.blue, 128)
    end
  end
end

module FS_SUMMON_GUIDE_V22
  DATA = {
    100=>{:name=>"妙蛙種子",:element=>"草／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD ATKD DEFD SPIC AGID SUPA",:skills=>[600, 601]},
    101=>{:name=>"妙蛙草",:element=>"草／毒",:role=>"poison_starter／parasite_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPB ATKC DEFC SPIB AGIC SUPA",:skills=>[600, 601, 602]},
    102=>{:name=>"妙蛙花",:element=>"草／毒",:role=>"poison_starter／parasite_starter／state_spreader",:build=>"B03 腐敗森林／B04 毒爆處刑／B11 狀態工廠",:ratings=>"HPA ATKB DEFB SPIS AGIB SUPB",:skills=>[600, 601, 602, 606]},
    103=>{:name=>"小火龍",:element=>"火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPE ATKD DEFD SPIC AGIC SUPD",:skills=>[607, 608]},
    104=>{:name=>"火恐龍",:element=>"火",:role=>"burn_finisher／resonance_fast",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC ATKC DEFC SPIB AGIB SUPD",:skills=>[607, 608, 612]},
    105=>{:name=>"噴火龍",:element=>"火／飛行",:role=>"burn_finisher／resonance_fast",:build=>"B08 復仇熔爐／B09 共鳴風暴",:ratings=>"HPA ATKB DEFB SPIA AGIS SUPE",:skills=>[607, 608, 612, 613]},
    106=>{:name=>"水躍魚",:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPC ATKC DEFC SPID AGID SUPC",:skills=>[617, 653]},
    107=>{:name=>"沼躍魚",:element=>"水／地面",:role=>"wet_starter／breaker",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB ATKB DEFB SPIC AGIC SUPA",:skills=>[617, 653, 618]},
    108=>{:name=>"巨沼怪",:element=>"水／地面",:role=>"wet_starter／breaker／tank",:build=>"狀態工廠",:ratings=>"HPS ATKS DEFA SPIA AGIC SUPS",:skills=>[617, 653, 618, 748]},
    109=>{:name=>"綠毛蟲",:element=>"蟲",:role=>"sleep_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPD ATKE DEFD SPIE AGID SUPB",:skills=>[768]},
    110=>{:name=>"鐵甲蛹",:element=>"蟲",:role=>"sleep_controller／state_spreader",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPC ATKE DEFC SPIE AGIE SUPA",:skills=>[768, 769]},
    111=>{:name=>"巴大蝶",:element=>"蟲／飛行",:role=>"sleep_controller／state_spreader",:build=>"混成標準隊",:ratings=>"HPB ATKD DEFC SPIA AGIB SUPA",:skills=>[768, 769, 670, 604]},
    112=>{:name=>"獨角蟲",:element=>"蟲／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD ATKE DEFE SPIE AGIC SUPC",:skills=>[770]},
    113=>{:name=>"鐵殼蛹",:element=>"蟲／毒",:role=>"poison_starter／crit_hunter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD ATKE DEFC SPIE AGID SUPA",:skills=>[770, 769]},
    114=>{:name=>"大針蜂",:element=>"蟲／毒",:role=>"poison_starter／crit_hunter",:build=>"共鳴風暴",:ratings=>"HPB ATKA DEFD SPIC AGIB SUPA",:skills=>[770, 769, 767, 676]},
    115=>{:name=>"波波",:element=>"一般／飛行",:role=>"resonance_fast",:build=>"B07 怒海堡壘／B09 共鳴風暴",:ratings=>"HPD ATKD DEFD SPIE AGIC SUPE",:skills=>[725, 639]},
    116=>{:name=>"比比鳥",:element=>"一般／飛行",:role=>"resonance_fast／protector",:build=>"B07 怒海堡壘／B09 共鳴風暴",:ratings=>"HPB ATKC DEFC SPID AGIB SUPD",:skills=>[725, 639, 613]},
    117=>{:name=>"比雕",:element=>"一般／飛行",:role=>"resonance_fast／protector",:build=>"混成標準隊",:ratings=>"HPA ATKB DEFB SPIB AGIS SUPB",:skills=>[725, 639, 613, 637]},
    118=>{:name=>"小拉達",:element=>"一般",:role=>"crit_hunter",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPE ATKD DEFD SPIE AGIB SUPE",:skills=>[639, 619]},
    119=>{:name=>"拉達",:element=>"一般",:role=>"crit_hunter／low_hp_finisher",:build=>"混成標準隊",:ratings=>"HPC ATKB DEFC SPIC AGIA SUPE",:skills=>[639, 619, 641, 642]},
    120=>{:name=>"烈雀",:element=>"一般／飛行",:role=>"crit_hunter",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD ATKC DEFE SPIE AGIB SUPE",:skills=>[634, 639]},
    121=>{:name=>"大嘴雀",:element=>"一般／飛行",:role=>"crit_hunter／fast_breaker",:build=>"B05 崩山／B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB ATKA DEFC SPIC AGIS SUPD",:skills=>[634, 639, 636, 643]},
    122=>{:name=>"阿柏蛇",:element=>"毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPE ATKC DEFD SPID AGIC SUPC",:skills=>[644, 619]},
    123=>{:name=>"阿柏怪",:element=>"毒",:role=>"poison_starter／corrosion_engine",:build=>"狀態工廠",:ratings=>"HPB ATKA DEFC SPIB AGIB SUPA",:skills=>[644, 619, 646]},
    124=>{:name=>"皮卡丘",:element=>"電",:role=>"paralysis_engine",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE ATKD DEFD SPID AGIA SUPD",:skills=>[697, 639]},
    125=>{:name=>"雷丘",:element=>"電",:role=>"paralysis_engine／atb_controller",:build=>"狀態工廠",:ratings=>"HPB ATKA DEFC SPIA AGIS SUPA",:skills=>[697, 639, 649, 651]},
    126=>{:name=>"穿山鼠",:element=>"地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC ATKB DEFA SPIE AGID SUPD",:skills=>[607, 656]},
    127=>{:name=>"穿山王",:element=>"地面",:role=>"breaker／ground_finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPA ATKA DEFS SPID AGIC SUPD",:skills=>[607, 656, 610]},
    128=>{:name=>"六尾",:element=>"火",:role=>"burn_starter",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPE ATKD DEFD SPIC AGIC SUPC",:skills=>[608, 639]},
    129=>{:name=>"九尾",:element=>"火",:role=>"burn_starter／fragile_engine",:build=>"混成標準隊",:ratings=>"HPB ATKB DEFB SPIA AGIS SUPA",:skills=>[608, 639, 663, 615]},
    130=>{:name=>"胖丁",:element=>"一般／妖精",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPS ATKD DEFE SPIE AGIE SUPB",:skills=>[740, 666]},
    131=>{:name=>"胖可丁",:element=>"一般／妖精",:role=>"healer／sleep_controller",:build=>"混成標準隊",:ratings=>"HPS ATKC DEFD SPIB AGID SUPA",:skills=>[740, 666, 659, 667]},
    132=>{:name=>"超音蝠",:element=>"毒／飛行",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPD ATKD DEFD SPIE AGIC SUPC",:skills=>[633, 690]},
    133=>{:name=>"大嘴蝠",:element=>"毒／飛行",:role=>"resonance_fast／poison_spreader",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPA ATKB DEFB SPIB AGIA SUPA",:skills=>[633, 690, 613]},
    134=>{:name=>"叉字蝠",:element=>"毒／飛行",:role=>"resonance_fast／poison_spreader",:build=>"腐敗森林",:ratings=>"HPA ATKA DEFB SPIB AGIS SUPA",:skills=>[633, 690, 613, 631]},
    135=>{:name=>"走路草",:element=>"草／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD ATKD DEFC SPIB AGIE SUPA",:skills=>[741, 601]},
    136=>{:name=>"走路花",:element=>"草／毒",:role=>"poison_starter／sleep_controller",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPB ATKC DEFB SPIB AGID SUPA",:skills=>[741, 601, 604]},
    137=>{:name=>"霸王花",:element=>"草／毒",:role=>"poison_starter／sleep_controller",:build=>"狀態工廠",:ratings=>"HPA ATKB DEFA SPIS AGIC SUPA",:skills=>[741, 601, 604, 605]},
    138=>{:name=>"派拉斯",:element=>"蟲／草",:role=>"parasite_starter",:build=>"B03 腐敗森林／B07 怒海堡壘",:ratings=>"HPE ATKC DEFC SPID AGIE SUPA",:skills=>[633, 602]},
    139=>{:name=>"派拉斯特",:element=>"蟲／草",:role=>"parasite_starter／root_controller",:build=>"B03 腐敗森林／B07 怒海堡壘",:ratings=>"HPB ATKA DEFB SPIB AGIE SUPA",:skills=>[633, 602, 669]},
    140=>{:name=>"毛球",:element=>"蟲／毒",:role=>"state_spreader",:build=>"B03 腐敗森林／B11 狀態工廠",:ratings=>"HPB ATKD DEFC SPID AGID SUPB",:skills=>[670, 601]},
    141=>{:name=>"摩魯蛾",:element=>"蟲／毒",:role=>"state_spreader／sleep_controller",:build=>"時間監獄",:ratings=>"HPB ATKC DEFC SPIA AGIA SUPA",:skills=>[670, 601, 604]},
    142=>{:name=>"可達鴨",:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPC ATKD DEFD SPIC AGIC SUPC",:skills=>[617, 670]},
    143=>{:name=>"哥達鴨",:element=>"水",:role=>"wet_starter／atb_controller",:build=>"狀態工廠",:ratings=>"HPA ATKB DEFB SPIA AGIA SUPA",:skills=>[617, 670, 671, 621]},
    144=>{:name=>"猴怪",:element=>"格鬥",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD ATKB DEFD SPID AGIB SUPB",:skills=>[674, 676]},
    145=>{:name=>"火爆猴",:element=>"格鬥",:role=>"breaker／rage_dps",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPB ATKA DEFC SPIC AGIA SUPB",:skills=>[674, 676, 677]},
    146=>{:name=>"卡蒂狗",:element=>"火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC ATKC DEFD SPIC AGIC SUPD",:skills=>[619, 608]},
    147=>{:name=>"風速狗",:element=>"火",:role=>"burn_finisher／protector",:build=>"怒海堡壘",:ratings=>"HPA ATKS DEFB SPIA AGIA SUPC",:skills=>[619, 608, 662, 679]},
    148=>{:name=>"蚊香蝌蚪",:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD ATKD DEFD SPID AGIA SUPA",:skills=>[620, 680]},
    149=>{:name=>"蚊香君",:element=>"水",:role=>"wet_starter／breaker",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB ATKC DEFC SPID AGIA SUPA",:skills=>[620, 680, 673]},
    150=>{:name=>"蚊香泳士",:element=>"水／格鬥",:role=>"wet_starter／breaker",:build=>"狀態工廠",:ratings=>"HPA ATKA DEFA SPIB AGIB SUPA",:skills=>[620, 680, 673, 654]},
    151=>{:name=>"凱西",:element=>"超能力",:role=>"atb_controller",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE ATKE DEFE SPIB AGIA SUPB",:skills=>[670, 705]},
    152=>{:name=>"勇基拉",:element=>"超能力",:role=>"atb_controller／state_dps",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPD ATKE DEFE SPIA AGIS SUPB",:skills=>[670, 705, 685]},
    153=>{:name=>"胡地",:element=>"超能力",:role=>"atb_controller／state_dps",:build=>"狀態工廠",:ratings=>"HPC ATKD DEFD SPIS AGIS SUPB",:skills=>[670, 705, 685, 686]},
    154=>{:name=>"腕力",:element=>"格鬥",:role=>"heavy_breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB ATKB DEFC SPIE AGID SUPB",:skills=>[674, 687]},
    155=>{:name=>"豪力",:element=>"格鬥",:role=>"heavy_breaker／finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPA ATKA DEFB SPIC AGID SUPB",:skills=>[674, 687, 677]},
    156=>{:name=>"怪力",:element=>"格鬥",:role=>"heavy_breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPA ATKS DEFB SPIB AGIC SUPB",:skills=>[674, 687, 677, 688]},
    157=>{:name=>"瑪瑙水母",:element=>"水／毒",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD ATKD DEFD SPIB AGIB SUPC",:skills=>[617, 644]},
    158=>{:name=>"毒刺水母",:element=>"水／毒",:role=>"wet_starter／poison_starter",:build=>"狀態工廠",:ratings=>"HPA ATKC DEFC SPIS AGIS SUPA",:skills=>[617, 644, 690, 645]},
    159=>{:name=>"小拳石",:element=>"岩石／地面",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPD ATKB DEFA SPIE AGIE SUPD",:skills=>[691, 693]},
    160=>{:name=>"隆隆石",:element=>"岩石／地面",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC ATKA DEFS SPID AGID SUPA",:skills=>[691, 693, 618]},
    161=>{:name=>"隆隆岩",:element=>"岩石／地面",:role=>"tank／breaker",:build=>"崩山",:ratings=>"HPA ATKS DEFS SPIC AGID SUPA",:skills=>[691, 693, 618, 655]},
    162=>{:name=>"小火馬",:element=>"火",:role=>"burn_starter",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC ATKB DEFC SPIC AGIA SUPC",:skills=>[608, 695]},
    163=>{:name=>"烈焰馬",:element=>"火",:role=>"burn_starter／resonance_fast",:build=>"混成標準隊",:ratings=>"HPB ATKA DEFB SPIB AGIS SUPC",:skills=>[608, 695, 662, 615]},
    164=>{:name=>"小磁怪",:element=>"電／鋼",:role=>"paralysis_engine",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE ATKE DEFB SPIB AGID SUPB",:skills=>[697, 764]},
    165=>{:name=>"三合一磁怪",:element=>"電／鋼",:role=>"paralysis_engine／atb_controller",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPC ATKC DEFA SPIA AGIB SUPA",:skills=>[697, 764, 649]},
    166=>{:name=>"自爆磁怪",:element=>"電／鋼",:role=>"atb_controller／protector",:build=>"B01 雷雨鎖鏈／B02 時間監獄／B11 狀態工廠",:ratings=>"HPB ATKC DEFS SPIS AGIC SUPC",:skills=>[697, 764, 649, 651]},
    167=>{:name=>"嘟嘟",:element=>"一般／飛行",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPE ATKB DEFD SPIE AGIB SUPE",:skills=>[634, 639]},
    168=>{:name=>"嘟嘟利",:element=>"一般／飛行",:role=>"resonance_fast／crit_hunter",:build=>"破防追擊",:ratings=>"HPB ATKS DEFB SPIC AGIS SUPE",:skills=>[634, 639, 661]},
    169=>{:name=>"臭泥",:element=>"毒",:role=>"corrosion_engine",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPA ATKB DEFC SPID AGIE SUPC",:skills=>[658, 700]},
    170=>{:name=>"臭臭泥",:element=>"毒",:role=>"corrosion_engine／poison_tank",:build=>"怒海堡壘",:ratings=>"HPS ATKA DEFB SPIA AGIC SUPA",:skills=>[658, 700, 632, 645]},
    171=>{:name=>"鬼斯",:element=>"幽靈／毒",:role=>"state_controller",:build=>"B02 時間監獄／B04 毒爆處刑",:ratings=>"HPE ATKE DEFE SPIB AGIB SUPB",:skills=>[702, 665]},
    172=>{:name=>"鬼斯通",:element=>"幽靈／毒",:role=>"state_controller／state_hunter",:build=>"B02 時間監獄／B04 毒爆處刑",:ratings=>"HPD ATKD DEFD SPIA AGIA SUPB",:skills=>[702, 665, 680]},
    173=>{:name=>"耿鬼",:element=>"幽靈／毒",:role=>"state_controller／state_hunter",:build=>"狀態工廠",:ratings=>"HPB ATKC DEFC SPIS AGIS SUPB",:skills=>[702, 665, 680, 701]},
    174=>{:name=>"催眠貘",:element=>"超能力",:role=>"sleep_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPB ATKD DEFD SPIC AGID SUPB",:skills=>[670, 680, 671]},
    175=>{:name=>"引夢貘人",:element=>"超能力",:role=>"sleep_controller／atb_controller",:build=>"雷雨鎖鏈",:ratings=>"HPA ATKC DEFB SPIA AGIC SUPB",:skills=>[670, 680, 671, 686]},
    176=>{:name=>"霹靂電球",:element=>"電",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPD ATKE DEFC SPIC AGIS SUPC",:skills=>[697, 704]},
    177=>{:name=>"頑皮雷彈",:element=>"電",:role=>"resonance_fast／atb_controller",:build=>"雷雨鎖鏈",:ratings=>"HPB ATKD DEFB SPIB AGIS SUPB",:skills=>[697, 704, 649, 731]},
    178=>{:name=>"卡拉卡拉",:element=>"地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC ATKD DEFA SPID AGID SUPD",:skills=>[652, 706, 707]},
    179=>{:name=>"嘎啦嘎啦",:element=>"地面",:role=>"breaker／low_hp_finisher",:build=>"B05 崩山／B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB ATKB DEFS SPIC AGID SUPD",:skills=>[652, 706, 707, 655]},
    180=>{:name=>"菊石獸",:element=>"岩石／水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPE ATKD DEFA SPIB AGID SUPC",:skills=>[617, 691]},
    181=>{:name=>"多刺菊石獸",:element=>"岩石／水",:role=>"wet_starter／tank",:build=>"狀態工廠",:ratings=>"HPB ATKC DEFS SPIA AGIC SUPB",:skills=>[617, 691, 715, 623]},
    182=>{:name=>"化石盔",:element=>"岩石／水",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPE ATKB DEFA SPID AGIC SUPD",:skills=>[607, 617]},
    183=>{:name=>"鐮刀盔",:element=>"岩石／水",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPB ATKS DEFA SPIB AGIB SUPD",:skills=>[607, 617, 610, 709]},
    184=>{:name=>"超夢",:element=>"超能力",:role=>"legendary_finisher／atb_controller",:build=>"混成標準隊",:ratings=>"HPS ATKS DEFA SPIS AGIS SUPA",:skills=>[670, 684, 685, 682]},
    185=>{:name=>"夢幻",:element=>"超能力",:role=>"adaptive_allrounder／state_support",:build=>"混成標準隊",:ratings=>"HPS ATKA DEFA SPIS AGIS SUPB",:skills=>[740, 686, 720]},
    186=>{:name=>"尾立",:element=>"一般",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPE ATKD DEFE SPID AGIE SUPE",:skills=>[616, 639]},
    187=>{:name=>"大尾立",:element=>"一般",:role=>"resonance_fast／support",:build=>"魔力永動",:ratings=>"HPA ATKB DEFC SPID AGIA SUPB",:skills=>[616, 639, 722, 724]},
    188=>{:name=>"圓絲蛛",:element=>"蟲／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD ATKC DEFD SPID AGIE SUPA",:skills=>[770, 768]},
    189=>{:name=>"阿利多斯",:element=>"蟲／毒",:role=>"poison_starter／root_controller",:build=>"狀態工廠",:ratings=>"HPB ATKA DEFB SPIC AGID SUPA",:skills=>[770, 768, 726, 628]},
    190=>{:name=>"波克比",:element=>"妖精",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE ATKE DEFC SPID AGIE SUPB",:skills=>[660]},
    191=>{:name=>"波克基古",:element=>"妖精／飛行",:role=>"healer／shield_support",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPC ATKD DEFA SPIA AGID SUPS",:skills=>[660, 659]},
    192=>{:name=>"波克基斯",:element=>"妖精／飛行",:role=>"healer／state_controller",:build=>"B10 魔力永動／B12 混成標準隊",:ratings=>"HPA ATKD DEFA SPIS AGIB SUPB",:skills=>[660, 659, 765]},
    193=>{:name=>"夢妖",:element=>"幽靈",:role=>"state_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPB ATKC DEFC SPIA AGIA SUPB",:skills=>[702, 665, 683]},
    194=>{:name=>"夢妖魔",:element=>"幽靈",:role=>"state_controller／fragile_engine",:build=>"毒爆處刑",:ratings=>"HPB ATKC DEFC SPIS AGIS SUPB",:skills=>[702, 665, 683, 701]},
    195=>{:name=>"小福蛋",:element=>"一般",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPS ATKE DEFE SPID AGIE SUPB",:skills=>[740, 660, 705]},
    196=>{:name=>"幸福蛋",:element=>"一般",:role=>"healer／mana_support",:build=>"混成標準隊",:ratings=>"HPS ATKE DEFE SPIS AGIC SUPA",:skills=>[740, 660, 705, 710]},
    197=>{:name=>"雷公",:element=>"電",:role=>"paralysis_engine／resonance_fast",:build=>"狀態工廠",:ratings=>"HPA ATKB DEFB SPIS AGIS SUPB",:skills=>[697, 649, 685, 650]},
    198=>{:name=>"炎帝",:element=>"火",:role=>"burn_finisher／breaker",:build=>"B08 復仇熔爐／B11 狀態工廠／B05 崩山",:ratings=>"HPS ATKS DEFA SPIA AGIS SUPA",:skills=>[608, 736, 695, 615]},
    199=>{:name=>"水君",:element=>"水",:role=>"wet_starter／state_controller",:build=>"B01 雷雨鎖鏈／B11 狀態工廠",:ratings=>"HPS ATKB DEFS SPIS AGIA SUPC",:skills=>[752, 681, 685, 623]},
    200=>{:name=>"幼基拉斯",:element=>"岩石／地面",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC ATKC DEFC SPID AGID SUPD",:skills=>[619, 691]},
    201=>{:name=>"沙基拉斯",:element=>"岩石／地面",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB ATKB DEFB SPIB AGIC SUPA",:skills=>[619, 691, 657]},
    202=>{:name=>"班基拉斯",:element=>"岩石／惡",:role=>"tank／breaker／finisher",:build=>"崩山",:ratings=>"HPS ATKS DEFS SPIA AGIC SUPA",:skills=>[619, 691, 657, 640]},
    203=>{:name=>"蓮葉童子",:element=>"水／草",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD ATKE DEFE SPID AGIE SUPC",:skills=>[617, 741]},
    204=>{:name=>"蓮帽小童",:element=>"水／草",:role=>"wet_starter／healer",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB ATKD DEFC SPIC AGIC SUPA",:skills=>[617, 741, 673]},
    205=>{:name=>"樂天河童",:element=>"水／草",:role=>"wet_starter／healer／mana_support",:build=>"狀態工廠",:ratings=>"HPA ATKC DEFB SPIA AGIB SUPS",:skills=>[617, 741, 673, 605]},
    206=>{:name=>"長翅鷗",:element=>"水／飛行",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B07 怒海堡壘",:ratings=>"HPD ATKE DEFE SPID AGIA SUPA",:skills=>[617, 725, 690]},
    207=>{:name=>"大嘴鷗",:element=>"水／飛行",:role=>"wet_starter／protector",:build=>"混成標準隊",:ratings=>"HPB ATKD DEFA SPIA AGIC SUPA",:skills=>[617, 725, 690, 765]},
    208=>{:name=>"幕下力士",:element=>"格鬥",:role=>"heavy_breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB ATKC DEFE SPIE AGIE SUPB",:skills=>[749, 687, 750]},
    209=>{:name=>"鐵掌力士",:element=>"格鬥",:role=>"heavy_breaker／tank",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPS ATKS DEFC SPID AGIC SUPA",:skills=>[749, 687, 750, 688]},
    210=>{:name=>"大嘴娃",:element=>"鋼／妖精",:role=>"fragile_engine／protector／finisher",:build=>"怒海堡壘",:ratings=>"HPC ATKB DEFA SPIC AGIC SUPB",:skills=>[619, 751, 640, 732]},
    211=>{:name=>"可可多拉",:element=>"鋼／岩石",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC ATKC DEFA SPID AGIE SUPD",:skills=>[616, 698]},
    212=>{:name=>"可多拉",:element=>"鋼／岩石",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB ATKA DEFS SPID AGID SUPA",:skills=>[616, 698, 751]},
    213=>{:name=>"波士可多拉",:element=>"鋼／岩石",:role=>"tank／breaker／protector",:build=>"崩山",:ratings=>"HPB ATKS DEFS SPIC AGIC SUPA",:skills=>[616, 698, 751, 709]},
    214=>{:name=>"利牙魚",:element=>"水／惡",:role=>"wet_finisher",:build=>"B01 雷雨鎖鏈／B09 共鳴風暴",:ratings=>"HPD ATKA DEFE SPID AGIC SUPB",:skills=>[619, 611, 640]},
    215=>{:name=>"巨牙鯊",:element=>"水／惡",:role=>"wet_finisher／crit_hunter",:build=>"破防追擊",:ratings=>"HPB ATKS DEFD SPIB AGIA SUPB",:skills=>[619, 611, 640, 672]},
    216=>{:name=>"醜醜魚",:element=>"水",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE ATKE DEFE SPIE AGIB SUPB",:skills=>[771, 616, 752]},
    217=>{:name=>"美納斯",:element=>"水",:role=>"healer／shield_support／wet_starter",:build=>"混成標準隊",:ratings=>"HPS ATKC DEFB SPIS AGIB SUPS",:skills=>[771, 616, 752, 684]},
    218=>{:name=>"夜巡靈",:element=>"幽靈",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPE ATKD DEFA SPIC AGIE SUPB",:skills=>[702, 663]},
    219=>{:name=>"彷徨夜靈",:element=>"幽靈",:role=>"tank／state_controller",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPD ATKC DEFS SPIA AGIE SUPA",:skills=>[702, 663, 728]},
    220=>{:name=>"黑夜魔靈",:element=>"幽靈",:role=>"tank／state_controller",:build=>"時間監獄",:ratings=>"HPD ATKA DEFS SPIS AGID SUPA",:skills=>[702, 663, 728, 701]},
    221=>{:name=>"阿勃梭魯",:element=>"惡",:role=>"crit_hunter／finisher",:build=>"共鳴風暴",:ratings=>"HPB ATKS DEFC SPIB AGIB SUPC",:skills=>[639, 753, 610, 640]},
    222=>{:name=>"寶貝龍",:element=>"龍",:role=>"finisher",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPD ATKB DEFC SPIE AGIC SUPE",:skills=>[619, 706]},
    223=>{:name=>"甲殼龍",:element=>"龍",:role=>"finisher／resonance_fast",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB ATKA DEFA SPIC AGIC SUPE",:skills=>[619, 706, 718]},
    224=>{:name=>"暴飛龍",:element=>"龍／飛行",:role=>"finisher／resonance_fast",:build=>"混成標準隊",:ratings=>"HPS ATKS DEFB SPIA AGIS SUPE",:skills=>[619, 706, 718, 614]},
    225=>{:name=>"鐵啞鈴",:element=>"鋼／超能力",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD ATKD DEFB SPID AGIE SUPD",:skills=>[616, 698]},
    226=>{:name=>"金屬怪",:element=>"鋼／超能力",:role=>"breaker／atb_controller",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB ATKB DEFA SPIB AGIC SUPC",:skills=>[616, 698, 686]},
    227=>{:name=>"巨金怪",:element=>"鋼／超能力",:role=>"breaker／atb_controller／tank",:build=>"B05 崩山／B06 破防追擊／B01 雷雨鎖鏈",:ratings=>"HPA ATKS DEFS SPIA AGIB SUPB",:skills=>[616, 698, 686, 755]},
    228=>{:name=>"雪童子",:element=>"冰",:role=>"freeze_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPC ATKD DEFC SPID AGIC SUPB",:skills=>[735, 681, 665]},
    229=>{:name=>"雪妖女",:element=>"冰／幽靈",:role=>"freeze_controller／resonance_fast",:build=>"共鳴風暴",:ratings=>"HPB ATKB DEFB SPIB AGIS SUPB",:skills=>[735, 681, 665, 622]},
    230=>{:name=>"鯉魚王",:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPE ATKE DEFC SPIE AGIB SUPA",:skills=>[771, 616]},
    231=>{:name=>"暴鯉龍",:element=>"水／飛行",:role=>"wet_starter／rage_dps／breaker",:build=>"狀態工廠",:ratings=>"HPS ATKS DEFB SPIB AGIB SUPA",:skills=>[771, 616, 619, 672]},
    232=>{:name=>"燈籠魚",:element=>"水／電",:role=>"wet_paralysis",:build=>"B01 雷雨鎖鏈／B11 狀態工廠",:ratings=>"HPA ATKE DEFD SPIC AGIC SUPA",:skills=>[617, 697, 649]},
    233=>{:name=>"電燈怪",:element=>"水／電",:role=>"wet_paralysis／mana_support",:build=>"魔力永動",:ratings=>"HPS ATKD DEFC SPIB AGIC SUPA",:skills=>[617, 697, 649, 621]},
    234=>{:name=>"榛果球",:element=>"蟲",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC ATKC DEFA SPIE AGIE SUPB",:skills=>[616, 618, 729]},
    235=>{:name=>"佛烈托斯",:element=>"蟲／鋼",:role=>"tank／state_spreader／protector",:build=>"腐敗森林",:ratings=>"HPA ATKA DEFS SPIC AGID SUPA",:skills=>[616, 618, 729, 731]},
    236=>{:name=>"圓陸鯊",:element=>"龍／地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC ATKC DEFD SPID AGID SUPD",:skills=>[616, 653]},
    237=>{:name=>"尖牙陸鯊",:element=>"龍／地面",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB ATKA DEFC SPID AGIB SUPD",:skills=>[616, 653, 718]},
    238=>{:name=>"烈咬陸鯊",:element=>"龍／地面",:role=>"breaker／finisher／resonance_fast",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPS ATKS DEFA SPIA AGIS SUPD",:skills=>[616, 653, 718, 655]},
    239=>{:name=>"赫拉克羅斯",:element=>"蟲／格鬥",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPA ATKS DEFB SPIB AGIA SUPB",:skills=>[624, 654, 687, 627]},
    240=>{:name=>"戴魯比",:element=>"惡／火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPD ATKC DEFE SPIC AGIC SUPB",:skills=>[608, 619, 663]},
    241=>{:name=>"黑魯加",:element=>"惡／火",:role=>"burn_finisher／state_dps",:build=>"時間監獄",:ratings=>"HPA ATKA DEFC SPIA AGIA SUPB",:skills=>[608, 619, 663, 612]},
    242=>{:name=>"盔甲鳥",:element=>"鋼／飛行",:role=>"protector／tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB ATKB DEFS SPIC AGIB SUPA",:skills=>[634, 730, 729, 751]},
    243=>{:name=>"拉魯拉絲",:element=>"超能力／妖精",:role=>"mana_support",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE ATKE DEFE SPID AGID SUPB",:skills=>[670, 685]},
    244=>{:name=>"奇魯莉安",:element=>"超能力／妖精",:role=>"mana_support／healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE ATKE DEFD SPIC AGIC SUPA",:skills=>[670, 685, 659]},
    245=>{:name=>"沙奈朵",:element=>"超能力／妖精",:role=>"healer／state_controller",:build=>"B10 魔力永動／B11 狀態工廠",:ratings=>"HPB ATKC DEFC SPIS AGIB SUPA",:skills=>[670, 685, 659, 686]},
    7=>{:name=>"映體・艾卓",:element=>"鋼／電",:role=>"atb_disruptor",:build=>"時間監獄／雷雨鎖鏈",:ratings=>"依資料庫現值",:skills=>[160, 161, 162, 163, 164]},
    8=>{:name=>"映體・艾薇",:element=>"毒／草",:role=>"emergency_guard",:build=>"怒海堡壘／復仇熔爐",:ratings=>"依資料庫現值",:skills=>[165, 166, 167, 168, 169]},
    9=>{:name=>"映體・米亞",:element=>"妖精／飛行",:role=>"healer",:build=>"溢療護盾／魔力爆發",:ratings=>"依資料庫現值",:skills=>[170, 171, 172, 173, 174]},
    10=>{:name=>"映體・維娜",:element=>"水／超能",:role=>"state_starter",:build=>"腐敗森林／狀態工廠",:ratings=>"依資料庫現值",:skills=>[175, 176, 177, 178, 179]},
    11=>{:name=>"映體・泰勒",:element=>"火／格鬥",:role=>"armor_breaker",:build=>"崩防獵殺／混成隊",:ratings=>"依資料庫現值",:skills=>[180, 181, 182, 183, 184]},
    12=>{:name=>"結界機",:element=>"鋼",:role=>"protector",:build=>"固定 A-A-S",:ratings=>"依資料庫現值",:skills=>[185]},
    13=>{:name=>"雷序機",:element=>"電",:role=>"atb_controller",:build=>"固定 A-S",:ratings=>"依資料庫現值",:skills=>[186]},
    14=>{:name=>"腐蝕機",:element=>"毒",:role=>"corrosion_engine",:build=>"固定 A-A-S",:ratings=>"依資料庫現值",:skills=>[187]},
    15=>{:name=>"破城機",:element=>"鋼",:role=>"breaker",:build=>"固定 A-A-A-S",:ratings=>"依資料庫現值",:skills=>[188]},
    16=>{:name=>"淨化機",:element=>"妖精",:role=>"healer／mana_engine",:build=>"固定 A-A-S",:ratings=>"依資料庫現值",:skills=>[189]},
  }
  def self.texts
    result={}
    DATA.each do |actor_id,d|
      arr=[]
      arr << "屬性：#{d[:element]}｜定位：#{d[:role]}"
      arr << "Build：#{d[:build]}"
      arr << "評價：#{d[:ratings]}"
      d[:skills].each {|sid| arr << [:skill,sid,"招式："]}
      result[actor_id]=arr
    end
    result
  end
end


module FS_SUMMON_GUIDE_V22
  PAGE_NAMES = ["能力", "特色", "招式"]

  ROLE_LABELS = {
    "poison_starter"=>"中毒起手", "parasite_starter"=>"寄生起手",
    "wet_starter"=>"濕潤起手", "burn_starter"=>"灼燒起手",
    "burn_finisher"=>"灼燒終結", "wet_finisher"=>"濕潤終結",
    "resonance_fast"=>"高速共鳴", "breaker"=>"破勢",
    "fast_breaker"=>"高速破勢", "heavy_breaker"=>"重型破勢",
    "protector"=>"保護", "tank"=>"坦傷", "healer"=>"治療",
    "mana_support"=>"魔力支援", "mana_engine"=>"魔力引擎",
    "state_spreader"=>"狀態擴散", "poison_spreader"=>"毒素擴散",
    "state_controller"=>"狀態控制", "sleep_controller"=>"睡眠控制",
    "freeze_controller"=>"冰凍控制", "root_controller"=>"根縛控制",
    "atb_controller"=>"ATB控制", "corrosion_engine"=>"腐蝕引擎",
    "paralysis_engine"=>"麻痺引擎", "fragile_engine"=>"脆弱引擎",
    "crit_hunter"=>"暴擊獵手", "state_hunter"=>"狀態獵手",
    "state_dps"=>"異常輸出", "rage_dps"=>"怒氣輸出",
    "finisher"=>"終結", "low_hp_finisher"=>"殘血終結",
    "ground_finisher"=>"地面終結", "shield_support"=>"護盾支援",
    "wet_paralysis"=>"濕潤麻痺", "adaptive_allrounder"=>"適應型全能",
    "state_support"=>"狀態支援", "atb_disruptor"=>"ATB干擾",
    "emergency_guard"=>"緊急護衛", "state_starter"=>"異常起手",
    "armor_breaker"=>"裂甲", "poison_tank"=>"毒系坦克"
  }

  def self.data(actor_id)
    return DATA[actor_id]
  end

  def self.role_labels(raw)
    result = []
    raw.to_s.split(/／|\//).each do |name|
      key = name.to_s.strip.downcase
      label = ROLE_LABELS[key]
      label = key if label == nil || label == ""
      result << label
    end
    return result
  end

  def self.rating_pairs(raw)
    result = []
    raw.to_s.scan(/(HP|ATK|DEF|SPI|AGI|SUP)([SABCDE])/i) do |data|
      label = data[0].upcase
      label = "輔助" if label == "SUP"
      result << [label, data[1].upcase]
    end
    return result
  end
end

if defined?(ALBERT_YEM_SUMMON_PAGE)
  if ALBERT_YEM_SUMMON_PAGE.const_defined?(:SUMMON_TEXTS)
    ALBERT_YEM_SUMMON_PAGE.send(:remove_const, :SUMMON_TEXTS)
  end
  ALBERT_YEM_SUMMON_PAGE.const_set(:SUMMON_TEXTS, FS_SUMMON_GUIDE_V22.texts)
end

class Window_EquipStat < Window_Base
  unless method_defined?(:fs_v22_summon_ui_old_refresh)
    alias fs_v22_summon_ui_old_refresh refresh
  end

  def refresh(equip = nil, equip_index = nil)
    key = [equip == nil ? nil : equip.class.to_s,
           equip == nil ? 0 : equip.id,
           equip_index]
    if @fs_v22_summon_preview_key != key
      @fs_v22_summon_preview_key = key
      @fs_v22_summon_page = 0
    end
    @fs_v22_summon_page = 0 if @fs_v22_summon_page == nil
    fs_v22_summon_ui_old_refresh(equip, equip_index)
  end

  def fs_v22_summon_page
    @fs_v22_summon_page = 0 if @fs_v22_summon_page == nil
    return @fs_v22_summon_page
  end

  def fs_v22_summon_page_next
    return unless @summon_mode
    @fs_v22_summon_page = (fs_v22_summon_page + 1) % 3
    refresh(@equip, @equip_index)
  end

  def fs_v22_draw_page_header(actor, page)
    old_size = contents.font.size
    old_bold = contents.font.bold
    contents.font.size = 18
    contents.font.bold = true
    contents.font.color = text_color(1)
    contents.draw_text(0, 0, contents.width - 68, 24, actor.name.to_s, 0)
    contents.font.size = 15
    contents.font.bold = false
    contents.font.color = system_color
    title = FS_SUMMON_GUIDE_V22::PAGE_NAMES[page]
    contents.draw_text(contents.width - 68, 0, 68, 24, "#{title} #{page + 1}/3", 2)
    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = normal_color
  end

  def fs_v22_draw_page_footer
    old_size = contents.font.size
    contents.font.size = 15
    contents.font.color = system_color
    y = contents.height - 20
    contents.draw_text(0, y, contents.width, 20, "Shift：切換資訊頁", 2)
    contents.font.size = old_size
    contents.font.color = normal_color
  end

  def fs_v22_draw_stats_page(actor)
    fs_v22_draw_page_header(actor, 0)
    contents.font.size = 16
    contents.font.color = normal_color
    contents.draw_text(0, 24, 72, 22, "Lv #{actor.level}", 0)
    draw_actor_hp(actor, 0, 46, 96)
    draw_actor_mp(actor, 0, 68, 96)
    #draw_actor_mp_gauge(actor, 0, 68, 96)
    contents.draw_text(0, 91, 48, 22, "攻擊", 0)
    contents.draw_text(48, 91, 42, 22, actor.atk.to_s, 2)
    contents.draw_text(0, 113, 48, 22, "防禦", 0)
    contents.draw_text(48, 113, 42, 22, actor.def.to_s, 2)
    contents.draw_text(0, 135, 48, 22, "精神", 0)
    contents.draw_text(48, 135, 42, 22, actor.spi.to_s, 2)
    contents.draw_text(0, 157, 48, 22, "敏捷", 0)
    contents.draw_text(48, 157, 42, 22, actor.agi.to_s, 2)

    face_x = [contents.width - 96, 96].max
    draw_actor_face(actor, face_x, 28)
    char_x = contents.width - 42
    char_y = [contents.height - 22, 178].min
    if respond_to?(:albert_draw_summon_character)
      albert_draw_summon_character(actor, char_x-5, char_y-75)
    else
      draw_actor_graphic(actor, char_x, char_y)
    end
    fs_v22_draw_page_footer
  end

  def fs_v22_draw_wrapped(text, x, y, width, line_height, max_lines)
    raw = text.to_s
    lines = []
    raw.split(/／|\n/).each do |part|
      part = part.to_s.strip
      next if part == ""
      if contents.text_size(part).width <= width
        lines << part
      else
        current = ""
        part.split(//).each do |ch|
          trial = current + ch
          if current != "" && contents.text_size(trial).width > width
            lines << current
            current = ch
          else
            current = trial
          end
        end
        lines << current unless current == ""
      end
    end
    lines = lines[0, max_lines]
    lines.each_with_index do |line, index|
      contents.draw_text(x, y + index * line_height, width, line_height, line, 0)
    end
    return y + lines.size * line_height
  end

  def fs_v22_draw_guide_page(actor, data)
    fs_v22_draw_page_header(actor, 1)
    contents.font.size = 15
    y = 27
    contents.font.color = system_color
    contents.draw_text(0, y, 42, 21, "屬性", 0)
    contents.font.color = normal_color
    contents.draw_text(42, y, contents.width - 42, 21, data[:element].to_s, 0)
    y += 22

    contents.font.color = system_color
    contents.draw_text(0, y, contents.width, 21, "定位", 0)
    y += 20
    contents.font.color = normal_color
    roles = FS_SUMMON_GUIDE_V22.role_labels(data[:role]).join("／")
    y = fs_v22_draw_wrapped(roles, 0, y, contents.width, 20, 2)

    contents.font.color = system_color
    contents.draw_text(0, y, contents.width, 21, "推薦 Build", 0)
    y += 20
    contents.font.color = normal_color
    y = fs_v22_draw_wrapped(data[:build], 0, y, contents.width, 20, 3)

    pairs = FS_SUMMON_GUIDE_V22.rating_pairs(data[:ratings])
    unless pairs.empty?
      contents.font.color = system_color
      contents.draw_text(0, y, contents.width, 20, "能力評價", 0)
      y += 19
      contents.font.color = normal_color
      pairs.each_with_index do |pair, index|
        col = index % 3
        row = index / 3
        w = contents.width / 3
        contents.draw_text(col * w, y + row * 20, w, 20,
                           "#{pair[0]} #{pair[1]}", 0)
      end
    else
      contents.font.color = normal_color
      fs_v22_draw_wrapped(data[:ratings], 0, y, contents.width, 20, 2)
    end
    fs_v22_draw_page_footer
  end

  def fs_v22_skill_icon_ids(skill)
    if respond_to?(:albert_summon_skill_element_icon_ids)
      return albert_summon_skill_element_icon_ids(skill)
    end
    return []
  end

  def fs_v22_draw_skills_page(actor, data)
    fs_v22_draw_page_header(actor, 2)
    old_size = contents.font.size
    contents.font.size = 15
    y = 27
    count = 0
    for skill_id in data[:skills]
      skill = $data_skills[skill_id]
      next if skill == nil
      break if count >= 6
      learned = true
      if actor.respond_to?(:skill_learn?)
        learned = actor.skill_learn?(skill)
      end
      contents.font.color = learned ? normal_color : disabled_color
      draw_x = 0
      for icon_id in fs_v22_skill_icon_ids(skill)
        draw_icon(icon_id, draw_x, y, learned)
        draw_x += 24
        break if draw_x >= 48
      end
      contents.draw_text(draw_x, y, contents.width - draw_x, 24,
                         skill.name.to_s, 0)
      y += 25
      count += 1
    end
    if count == 0
      contents.font.color = disabled_color
      contents.draw_text(0, 54, contents.width, 24, "尚無可顯示招式", 1)
    end
    contents.font.size = 15
    contents.font.color = disabled_color
    contents.draw_text(0, contents.height - 40, contents.width, 20,
                       "灰字＝尚未習得", 0)
    contents.font.size = old_size
    contents.font.color = normal_color
    fs_v22_draw_page_footer
  end

  # 最終覆寫。安裝在既有 Extension / Icon Patch 下方。
  def draw_summon_stats
    return if @equip == nil
    actor_id = nil
    if respond_to?(:albert_summon_actor_id)
      actor_id = albert_summon_actor_id(@equip)
    elsif defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
      actor_id = ArmorMapping.mapping[@equip.id]
    end
    return if actor_id == nil

    if respond_to?(:albert_sync_equip_summon_actor)
      @summon = albert_sync_equip_summon_actor(actor_id)
    else
      @summon = $game_actors[actor_id]
    end
    return if @summon == nil

    old_size = contents.font.size
    old_bold = contents.font.bold
    old_italic = contents.font.italic
    old_color = contents.font.color
    begin
      @summon_mode = true
      data = FS_SUMMON_GUIDE_V22.data(actor_id)
      page = fs_v22_summon_page
      if page == 0 || data == nil
        fs_v22_draw_stats_page(@summon)
      elsif page == 1
        fs_v22_draw_guide_page(@summon, data)
      else
        fs_v22_draw_skills_page(@summon, data)
      end
    ensure
      contents.font.size = old_size
      contents.font.bold = old_bold
      contents.font.italic = old_italic
      contents.font.color = old_color
    end
  end
end

if defined?(Scene_Equip)
  class Scene_Equip < Scene_Base
    unless method_defined?(:fs_v22_summon_ui_old_update)
      alias fs_v22_summon_ui_old_update update
    end

    def update
      fs_v22_summon_ui_old_update
      return if @stat_window == nil || @stat_window.disposed?
      return unless @stat_window.instance_variable_get(:@summon_mode)
      if Input.trigger?(Input::A)
        Sound.play_cursor
        @stat_window.fs_v22_summon_page_next
      end
    end
  end
end

#==============================================================================
# ■ END
#==============================================================================

#==============================================================================
# PHASE6 ORIGINAL PAGE: 426 | SummonUI_v2_8_CompactOverride
#==============================================================================
#==============================================================================
# ■ FS_SummonUI_v2_8_CompactOverride
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 安裝位置：
#   FS_SummonUI_v2_3
#   FS_SummonUI_v2_8_CompactOverride   ← 本腳本
#   Main
#
# 本版功能：
#   1. 固定單頁，取消 Shift 翻頁與翻頁音效。
#   2. 名字右側顯示最多兩個屬性 Icon。
#   3. 等級右側顯示放大的 ROLE_LABELS。
#   4. 屬性 Icon 直接讀 actor.primary_element／secondary_element。
#      不再用中文名稱反查 $data_system.elements，避免火／水被換成錯誤 ID。
#   5. Icon 直接使用 Window_Base::ELEMENT_ICON_TABLE。
#      不修改 YEM::ITEM::ELEMENT_ICONS，也不覆寫全域 Icon.element。
#   6. 能力列改為「評價 → 名稱 → 數值」，並與右側技能逐行對齊。
#   7. 臉圖、動態角色圖與技能同步上移。
#   8. MP 使用 draw_actor_mp，與 HP 一樣顯示目前值／最大值。
#   9. 技能顯示整條 Class learnings，已習得正常色，未習得半透明。
#
# 調整用常數：
#   VISUAL_RAISE     臉圖與角色圖同步上移量
#   SKILL_X_OFFSET   技能相對臉圖左緣的右移量
#   SKILL_FONT_SIZE  技能預設字體大小
#==============================================================================

module FS_SUMMON_COMPACT_V28
  VISUAL_RAISE      = 20
  SKILL_X_OFFSET    = 6
  SKILL_FONT_SIZE   = 16
  SKILL_LINE_HEIGHT = 20

  # FS_SUMMON_GUIDE_V22 的中文字串僅作備援。
  # 正常情況優先使用 actor.primary_element／secondary_element。
  ELEMENT_NAME_TO_SYMBOL = {
    "一般"   => :normal,
    "普通"   => :normal,
    "格鬥"   => :fighting,
    "飛行"   => :flying,
    "毒"     => :poison,
    "地面"   => :ground,
    "岩石"   => :rock,
    "蟲"     => :bug,
    "幽靈"   => :ghost,
    "鋼"     => :steel,
    "火"     => :fire,
    "水"     => :water,
    "草"     => :grass,
    "電"     => :electric,
    "超能力" => :psychic,
    "超能"   => :psychic,
    "冰"     => :ice,
    "龍"     => :dragon,
    "惡"     => :dark,
    "邪惡"   => :dark,
    "妖精"   => :fairy,
  }
end

class Window_EquipStat < Window_Base

  #--------------------------------------------------------------------------
  # ● 固定為單頁
  #--------------------------------------------------------------------------
  def fs_v22_summon_page
    @fs_v22_summon_page = 0
    return 0
  end

  #--------------------------------------------------------------------------
  # ● 取消 Shift 翻頁
  #--------------------------------------------------------------------------
  def fs_v22_summon_page_next
    @fs_v22_summon_page = 0
    return
  end

  #--------------------------------------------------------------------------
  # ● 安全的未習得文字色
  #--------------------------------------------------------------------------
  def fs_v28_disabled_color
    return disabled_color if respond_to?(:disabled_color)
    color = normal_color
    return Color.new(color.red, color.green, color.blue, 128)
  end

  #--------------------------------------------------------------------------
  # ● 取得本角色的 Summon Guide 資料
  #--------------------------------------------------------------------------
  def fs_v28_guide_data(actor)
    return nil unless defined?(FS_SUMMON_GUIDE_V22)
    return nil unless FS_SUMMON_GUIDE_V22.respond_to?(:data)
    return FS_SUMMON_GUIDE_V22.data(actor.id)
  end

  #--------------------------------------------------------------------------
  # ● 取得 ATK／DEF／SPI／AGI 評價
  #--------------------------------------------------------------------------
  def fs_v28_rating_hash(actor)
    result = {}
    data = fs_v28_guide_data(actor)
    return result if data == nil

    raw = data[:ratings].to_s
    raw.scan(/(ATK|DEF|SPI|AGI)([SABCDE])/i) do |pair|
      result[pair[0].upcase] = pair[1].upcase
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 取得 ROLE_LABELS
  #--------------------------------------------------------------------------
  def fs_v28_role_text(actor)
    data = fs_v28_guide_data(actor)
    return "" if data == nil
    return "" if data[:role] == nil

    if defined?(FS_SUMMON_GUIDE_V22) &&
       FS_SUMMON_GUIDE_V22.respond_to?(:role_labels)
      return FS_SUMMON_GUIDE_V22.role_labels(data[:role]).join("／")
    end
    return data[:role].to_s
  end

  #--------------------------------------------------------------------------
  # ● 繪製姓名與右側屬性 Icon
  #    Icon 起點依姓名實際像素寬度調整
  #--------------------------------------------------------------------------
  def fs_v28_draw_name_and_elements(actor)
    old_size = contents.font.size
    old_bold = contents.font.bold
    old_color = contents.font.color

    name = actor.name.to_s

    contents.font.size = 18
    contents.font.bold = true
    contents.font.color = text_color(1)

    name_width = contents.text_size(name).width
    name_draw_width = [name_width + 4, contents.width].min
    contents.draw_text(0, 0, name_draw_width, 24, name, 0)

    icon_x = name_width + 6
    for element_symbol in fs_v28_element_symbols(actor)
      icon_id = fs_v28_element_icon_id(element_symbol)
      next if icon_id <= 0
      break if icon_x + 24 > contents.width
      draw_icon(icon_id, icon_x, 0, true)
      icon_x += 25
    end

    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = old_color
  end

  #--------------------------------------------------------------------------
  # ● 取得角色的屬性 Symbol
  #
  # 優先來源：
  #   actor.primary_element／secondary_element
  #
  # 備援來源：
  #   FS_SUMMON_GUIDE_V22::DATA 的中文字串
  #
  # 不再經過：
  #   中文名稱 → $data_system.elements → Element ID
  #
  # 因此即使資料庫的火／水文字位置與固定 ID 表不同，也不會互換。
  #--------------------------------------------------------------------------
  def fs_v28_element_symbols(actor)
    result = []

    if actor.respond_to?(:primary_element)
      primary = actor.primary_element
      if primary != nil && primary != :normal
        result.push(primary)
      end
    end

    if actor.respond_to?(:secondary_element)
      secondary = actor.secondary_element
      if secondary != nil && secondary != :normal &&
         !result.include?(secondary)
        result.push(secondary)
      end
    end

    # 若角色屬性方法不存在或尚未完成 setup，才使用指南文字備援。
    if result.empty?
      data = fs_v28_guide_data(actor)
      if data != nil && data[:element] != nil
        names = data[:element].to_s.split(/／|\/|、|,|，/)
        for raw_name in names
          name = raw_name.to_s.strip
          symbol =
            FS_SUMMON_COMPACT_V28::ELEMENT_NAME_TO_SYMBOL[name]
          next if symbol == nil
          next if symbol == :normal
          next if result.include?(symbol)

          result.push(symbol)
          break if result.size >= 2
        end
      end
    end

    return result[0, 2]
  end

  #--------------------------------------------------------------------------
  # ● 屬性 Symbol → Icon ID
  #
  # 使用與寶可夢技能屬性 Icon 相同的正式資料來源：
  #   Window_Base::ELEMENT_ICON_TABLE
  #
  # 例如：
  #   :fire  → 4007
  #   :water → 4008
  #--------------------------------------------------------------------------
  def fs_v28_element_icon_id(element_symbol)
    return 0 unless Window_Base.const_defined?(:ELEMENT_ICON_TABLE)

    table = Window_Base.const_get(:ELEMENT_ICON_TABLE)
    icon_id = table[element_symbol]
    return icon_id == nil ? 0 : icon_id.to_i
  end

  #--------------------------------------------------------------------------
  # ● 繪製等級與右側 ROLE_LABELS
  #    ROLE 字體放大，起點依等級實際寬度調整
  #--------------------------------------------------------------------------
  def fs_v28_draw_level_and_role(actor)
    old_size = contents.font.size
    old_bold = contents.font.bold
    old_color = contents.font.color

    contents.font.size = 16
    contents.font.bold = false
    contents.font.color = normal_color

    level_text = "Lv #{actor.level}"
    level_width = contents.text_size(level_text).width
    contents.draw_text(0, 24, level_width + 2, 22, level_text, 0)

    role_text = fs_v28_role_text(actor)
    role_x = level_width + 7
    role_width = contents.width - role_x

    if role_text != "" && role_width > 12
      contents.font.size = 16
      contents.font.bold = true
      contents.font.color = system_color

      # 長定位只在必要時縮字，最低維持 12。
      while contents.font.size > 12 &&
            contents.text_size(role_text).width > role_width
        contents.font.size -= 1
      end

      contents.draw_text(role_x, 24, role_width, 22, role_text, 0)
    end

    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = old_color
  end

  #--------------------------------------------------------------------------
  # ● 繪製單項能力
  #    顯示順序為「D 攻擊 7」，Y 座標與右側技能逐行共用。
  #--------------------------------------------------------------------------
  def fs_v28_draw_stat_row(label, key, value, y, ratings)
    old_size = contents.font.size
    old_bold = contents.font.bold
    old_color = contents.font.color

    contents.font.size = 17
    contents.font.bold = true
    contents.font.color = system_color
    contents.draw_text(0, y, 18, 22, ratings[key].to_s, 0)

    contents.font.size = 16
    contents.font.bold = false
    contents.font.color = normal_color
    contents.draw_text(20, y, 36, 22, label, 0)

    contents.draw_text(62, y, 36, 22, value.to_s, 2)

    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = old_color
  end

  #--------------------------------------------------------------------------
  # ● 取得整條進化線技能
  #    同進化線共用 Class，因此直接讀取 Class learnings。
  #--------------------------------------------------------------------------
  def fs_v28_evolution_learnings(actor)
    result = []
    used = {}

    klass = $data_classes[actor.class_id]
    return result if klass == nil
    return result unless klass.respond_to?(:learnings)

    list = klass.learnings.clone
    list.sort! do |a, b|
      level_result = a.level.to_i <=> b.level.to_i
      if level_result == 0
        a.skill_id.to_i <=> b.skill_id.to_i
      else
        level_result
      end
    end

    for learning in list
      skill_id = learning.skill_id.to_i
      next if skill_id <= 0
      next if used[skill_id]

      skill = $data_skills[skill_id]
      next if skill == nil

      used[skill_id] = true
      result.push([learning.level.to_i, skill])
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 繪製整條進化線技能
  #    位置相對臉圖稍微右移，字體放大。
  #--------------------------------------------------------------------------
  def fs_v28_draw_evolution_skills(actor, face_x, face_y, start_y = nil)
    list = fs_v28_evolution_learnings(actor)
    return if list.empty?

    old_size = contents.font.size
    old_bold = contents.font.bold
    old_color = contents.font.color

    x = face_x + FS_SUMMON_COMPACT_V28::SKILL_X_OFFSET
    y = start_y == nil ? face_y + 99 : start_y
    width = contents.width - x
    available_height = contents.height - y
    count = list.size

    line_height = FS_SUMMON_COMPACT_V28::SKILL_LINE_HEIGHT
    font_size = FS_SUMMON_COMPACT_V28::SKILL_FONT_SIZE

    # 日後若某 Class 塞入過多技能，才自動壓縮，正常四招維持 15 號字。
    if count > 0 && count * line_height > available_height
      line_height = available_height / count
      line_height = 12 if line_height < 12
      font_size = line_height - 3
      font_size = 11 if font_size < 11
    end

    contents.font.size = font_size
    contents.font.bold = false

    for entry in list
      level = entry[0]
      skill = entry[1]

      learned = false
      if actor.respond_to?(:skill_learn?)
        learned = actor.skill_learn?(skill)
      else
        learned = actor.level >= level
      end

      contents.font.color = learned ? normal_color : fs_v28_disabled_color
      text = sprintf("Lv%d %s", level, skill.name.to_s)
      contents.draw_text(x, y, width, line_height, text, 0)
      y += line_height
    end

    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = old_color
  end

  #--------------------------------------------------------------------------
  # ● 單頁召喚物資訊
  #--------------------------------------------------------------------------
  def fs_v28_draw_compact_summon_page(actor)
    old_size = contents.font.size
    old_bold = contents.font.bold
    old_color = contents.font.color

    face_x = [contents.width - 96, 96].max
    face_y = 28 - FS_SUMMON_COMPACT_V28::VISUAL_RAISE

    # 姓名與屬性 Icon
    fs_v28_draw_name_and_elements(actor)

    # 等級與定位
    fs_v28_draw_level_and_role(actor)

    # HP／MP：兩者都顯示目前值與最大值
    draw_actor_hp(actor, 0, 46, 96)
    draw_actor_mp(actor, 0, 68, 96)

    # 左側能力與右側技能共用相同起始 Y／行距
    # 目前 face_y = 8，因此起始 Y 為 107。
    row_start_y = face_y + 99
    row_step = FS_SUMMON_COMPACT_V28::SKILL_LINE_HEIGHT

    ratings = fs_v28_rating_hash(actor)
    fs_v28_draw_stat_row("攻擊", "ATK", actor.atk,
      row_start_y + row_step * 0, ratings)
    fs_v28_draw_stat_row("防禦", "DEF", actor.def,
      row_start_y + row_step * 1, ratings)
    fs_v28_draw_stat_row("精神", "SPI", actor.spi,
      row_start_y + row_step * 2, ratings)
    fs_v28_draw_stat_row("敏捷", "AGI", actor.agi,
      row_start_y + row_step * 3, ratings)

    # 臉圖上移
    draw_actor_face(actor, face_x, face_y)

    # 技能與能力列使用完全相同的起始 Y
    fs_v28_draw_evolution_skills(actor, face_x, face_y, row_start_y)

    # 動態角色圖與臉圖、技能同步再上移
    char_x = contents.width - 42
    char_y = [contents.height - 22, 178].min
    char_draw_y = char_y - 75 - FS_SUMMON_COMPACT_V28::VISUAL_RAISE

    if respond_to?(:albert_draw_summon_character)
      albert_draw_summon_character(actor, char_x - 5, char_draw_y)
    else
      draw_actor_graphic(actor, char_x - 5, char_draw_y)
    end

    contents.font.size = old_size
    contents.font.bold = old_bold
    contents.font.color = old_color
  end

  #--------------------------------------------------------------------------
  # ● 最終覆寫召喚物裝備預覽
  #--------------------------------------------------------------------------
  def draw_summon_stats
    return if @equip == nil

    actor_id = nil
    if respond_to?(:albert_summon_actor_id)
      actor_id = albert_summon_actor_id(@equip)
    elsif defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
      actor_id = ArmorMapping.mapping[@equip.id]
    end
    return if actor_id == nil

    if respond_to?(:albert_sync_equip_summon_actor)
      @summon = albert_sync_equip_summon_actor(actor_id)
    else
      @summon = $game_actors[actor_id]
    end
    return if @summon == nil

    old_size = contents.font.size
    old_bold = contents.font.bold
    old_italic = contents.font.italic
    old_color = contents.font.color

    begin
      @summon_mode = true
      @fs_v22_summon_page = 0
      fs_v28_draw_compact_summon_page(@summon)
    ensure
      contents.font.size = old_size
      contents.font.bold = old_bold
      contents.font.italic = old_italic
      contents.font.color = old_color
    end
  end
end

#==============================================================================
# ■ Scene_Equip：移除 v2.3 的 Shift 監聽與翻頁音效
#==============================================================================
if defined?(Scene_Equip)
  class Scene_Equip < Scene_Base
    if method_defined?(:fs_v22_summon_ui_old_update)
      def update
        fs_v22_summon_ui_old_update
      end
    end
  end
end

#==============================================================================
# ■ END
#==============================================================================
