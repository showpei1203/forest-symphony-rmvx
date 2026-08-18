#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_CharacterBook_v2_1
# 【用途】保留的 Runtime 元件「Scene_CharacterBook_v2_1」。
# 【主要機制】主要定義／擴充 Game_Party、Sprite_CharacterBookActor、Window_FSCharacterList、Window_FSCharacterInfo；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Party、Sprite_CharacterBookActor、Window_FSCharacterList、Window_FSCharacterInfo、Scene_CharacterBook、FS_CHARACTER_BOOK_V21
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ACTOR_IDS、DATA、PASSIVE_FLAVOR。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
#==============================================================================
# ■ FS_Scene_CharacterBook_v2_1
# 完整替換舊 CharacterBook。544x416，行走圖獨立 Sprite 動畫，不靠整窗 refresh。
# 操作：上下選角色；左右換資訊頁；B 返回。未習得技能以灰色顯示。
# 安裝：舊 CharacterBook 之下，YEM/召喚同步補丁之下，Main 之上。
#==============================================================================
module FS_CHARACTER_BOOK_V21
  ACTOR_IDS = (1..16).to_a + (100..245).to_a
  DATA = {
    1=>{:element=>"草／龍",:role=>"召喚連結／共鳴指揮",:build=>"共鳴追擊／魂刻專技",:ratings=>"HPA MPB ATKB DEFB SPIB AGIB SUPS",:skills=>(100..109).to_a},
    2=>{:element=>"妖精／飛行",:role=>"治療／魔力層／溢療轉換",:build=>"溢療護盾／魔力爆發",:ratings=>"HPB MPS ATKE DEFB SPIS AGIC SUPS",:skills=>(110..119).to_a},
    3=>{:element=>"鋼／電",:role=>"ATB打斷／高速物魔混合",:build=>"時間監獄／雷雨鎖鏈",:ratings=>"HPB MPB ATKA DEFC SPIB AGIS SUPA",:skills=>(120..129).to_a},
    4=>{:element=>"水／超能",:role=>"異常施加／擴散／引爆",:build=>"腐敗森林／毒爆處刑",:ratings=>"HPB MPA ATKE DEFC SPIS AGIA SUPS",:skills=>(130..139).to_a},
    5=>{:element=>"毒／草",:role=>"護衛坦克／怒氣／蓄痛復仇",:build=>"怒海堡壘／復仇熔爐",:ratings=>"HPS MPC ATKA DEFS SPID AGID SUPA",:skills=>(140..149).to_a},
    6=>{:element=>"火／格鬥",:role=>"Break／崩防／重擊",:build=>"崩防獵殺／混成爆發",:ratings=>"HPA MPC ATKS DEFB SPID AGIA SUPB",:skills=>(150..159).to_a},
    100=>{:element=>"草／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD MPC ATKD DEFD SPIC AGID SUPA",:skills=>[600, 601]},
    101=>{:element=>"草／毒",:role=>"poison_starter／parasite_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPB MPB ATKC DEFC SPIB AGIC SUPA",:skills=>[600, 601, 602]},
    102=>{:element=>"草／毒",:role=>"poison_starter／parasite_starter／state_spreader",:build=>"B03 腐敗森林／B04 毒爆處刑／B11 狀態工廠",:ratings=>"HPA MPS ATKB DEFB SPIS AGIB SUPB",:skills=>[600, 601, 602, 606]},
    103=>{:element=>"火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPE MPC ATKD DEFD SPIC AGIC SUPD",:skills=>[607, 608]},
    104=>{:element=>"火",:role=>"burn_finisher／resonance_fast",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC MPB ATKC DEFC SPIB AGIB SUPD",:skills=>[607, 608, 612]},
    105=>{:element=>"火／飛行",:role=>"burn_finisher／resonance_fast",:build=>"B08 復仇熔爐／B09 共鳴風暴",:ratings=>"HPA MPS ATKB DEFB SPIA AGIS SUPE",:skills=>[607, 608, 612, 613]},
    106=>{:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPC MPD ATKC DEFC SPID AGID SUPC",:skills=>[617, 653]},
    107=>{:element=>"水／地面",:role=>"wet_starter／breaker",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB MPC ATKB DEFB SPIC AGIC SUPA",:skills=>[617, 653, 618]},
    108=>{:element=>"水／地面",:role=>"wet_starter／breaker／tank",:build=>"狀態工廠",:ratings=>"HPS MPA ATKS DEFA SPIA AGIC SUPS",:skills=>[617, 653, 618, 748]},
    109=>{:element=>"蟲",:role=>"sleep_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPD MPE ATKE DEFD SPIE AGID SUPB",:skills=>[768]},
    110=>{:element=>"蟲",:role=>"sleep_controller／state_spreader",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPC MPE ATKE DEFC SPIE AGIE SUPA",:skills=>[768, 769]},
    111=>{:element=>"蟲／飛行",:role=>"sleep_controller／state_spreader",:build=>"混成標準隊",:ratings=>"HPB MPA ATKD DEFC SPIA AGIB SUPA",:skills=>[768, 769, 670, 604]},
    112=>{:element=>"蟲／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD MPE ATKE DEFE SPIE AGIC SUPC",:skills=>[770]},
    113=>{:element=>"蟲／毒",:role=>"poison_starter／crit_hunter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD MPE ATKE DEFC SPIE AGID SUPA",:skills=>[770, 769]},
    114=>{:element=>"蟲／毒",:role=>"poison_starter／crit_hunter",:build=>"共鳴風暴",:ratings=>"HPB MPC ATKA DEFD SPIC AGIB SUPA",:skills=>[770, 769, 767, 676]},
    115=>{:element=>"一般／飛行",:role=>"resonance_fast",:build=>"B07 怒海堡壘／B09 共鳴風暴",:ratings=>"HPD MPE ATKD DEFD SPIE AGIC SUPE",:skills=>[725, 639]},
    116=>{:element=>"一般／飛行",:role=>"resonance_fast／protector",:build=>"B07 怒海堡壘／B09 共鳴風暴",:ratings=>"HPB MPD ATKC DEFC SPID AGIB SUPD",:skills=>[725, 639, 613]},
    117=>{:element=>"一般／飛行",:role=>"resonance_fast／protector",:build=>"混成標準隊",:ratings=>"HPA MPB ATKB DEFB SPIB AGIS SUPB",:skills=>[725, 639, 613, 637]},
    118=>{:element=>"一般",:role=>"crit_hunter",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPE MPE ATKD DEFD SPIE AGIB SUPE",:skills=>[639, 619]},
    119=>{:element=>"一般",:role=>"crit_hunter／low_hp_finisher",:build=>"混成標準隊",:ratings=>"HPC MPC ATKB DEFC SPIC AGIA SUPE",:skills=>[639, 619, 641, 642]},
    120=>{:element=>"一般／飛行",:role=>"crit_hunter",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD MPE ATKC DEFE SPIE AGIB SUPE",:skills=>[634, 639]},
    121=>{:element=>"一般／飛行",:role=>"crit_hunter／fast_breaker",:build=>"B05 崩山／B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB MPC ATKA DEFC SPIC AGIS SUPD",:skills=>[634, 639, 636, 643]},
    122=>{:element=>"毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPE MPD ATKC DEFD SPID AGIC SUPC",:skills=>[644, 619]},
    123=>{:element=>"毒",:role=>"poison_starter／corrosion_engine",:build=>"狀態工廠",:ratings=>"HPB MPB ATKA DEFC SPIB AGIB SUPA",:skills=>[644, 619, 646]},
    124=>{:element=>"電",:role=>"paralysis_engine",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE MPD ATKD DEFD SPID AGIA SUPD",:skills=>[697, 639]},
    125=>{:element=>"電",:role=>"paralysis_engine／atb_controller",:build=>"狀態工廠",:ratings=>"HPB MPA ATKA DEFC SPIA AGIS SUPA",:skills=>[697, 639, 649, 651]},
    126=>{:element=>"地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC MPE ATKB DEFA SPIE AGID SUPD",:skills=>[607, 656]},
    127=>{:element=>"地面",:role=>"breaker／ground_finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPA MPD ATKA DEFS SPID AGIC SUPD",:skills=>[607, 656, 610]},
    128=>{:element=>"火",:role=>"burn_starter",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPE MPC ATKD DEFD SPIC AGIC SUPC",:skills=>[608, 639]},
    129=>{:element=>"火",:role=>"burn_starter／fragile_engine",:build=>"混成標準隊",:ratings=>"HPB MPA ATKB DEFB SPIA AGIS SUPA",:skills=>[608, 639, 663, 615]},
    130=>{:element=>"一般／妖精",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPS MPE ATKD DEFE SPIE AGIE SUPB",:skills=>[740, 666]},
    131=>{:element=>"一般／妖精",:role=>"healer／sleep_controller",:build=>"混成標準隊",:ratings=>"HPS MPB ATKC DEFD SPIB AGID SUPA",:skills=>[740, 666, 659, 667]},
    132=>{:element=>"毒／飛行",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPD MPE ATKD DEFD SPIE AGIC SUPC",:skills=>[633, 690]},
    133=>{:element=>"毒／飛行",:role=>"resonance_fast／poison_spreader",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPA MPB ATKB DEFB SPIB AGIA SUPA",:skills=>[633, 690, 613]},
    134=>{:element=>"毒／飛行",:role=>"resonance_fast／poison_spreader",:build=>"腐敗森林",:ratings=>"HPA MPB ATKA DEFB SPIB AGIS SUPA",:skills=>[633, 690, 613, 631]},
    135=>{:element=>"草／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD MPB ATKD DEFC SPIB AGIE SUPA",:skills=>[741, 601]},
    136=>{:element=>"草／毒",:role=>"poison_starter／sleep_controller",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPB MPB ATKC DEFB SPIB AGID SUPA",:skills=>[741, 601, 604]},
    137=>{:element=>"草／毒",:role=>"poison_starter／sleep_controller",:build=>"狀態工廠",:ratings=>"HPA MPS ATKB DEFA SPIS AGIC SUPA",:skills=>[741, 601, 604, 605]},
    138=>{:element=>"蟲／草",:role=>"parasite_starter",:build=>"B03 腐敗森林／B07 怒海堡壘",:ratings=>"HPE MPD ATKC DEFC SPID AGIE SUPA",:skills=>[633, 602]},
    139=>{:element=>"蟲／草",:role=>"parasite_starter／root_controller",:build=>"B03 腐敗森林／B07 怒海堡壘",:ratings=>"HPB MPB ATKA DEFB SPIB AGIE SUPA",:skills=>[633, 602, 669]},
    140=>{:element=>"蟲／毒",:role=>"state_spreader",:build=>"B03 腐敗森林／B11 狀態工廠",:ratings=>"HPB MPD ATKD DEFC SPID AGID SUPB",:skills=>[670, 601]},
    141=>{:element=>"蟲／毒",:role=>"state_spreader／sleep_controller",:build=>"時間監獄",:ratings=>"HPB MPA ATKC DEFC SPIA AGIA SUPA",:skills=>[670, 601, 604]},
    142=>{:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPC MPC ATKD DEFD SPIC AGIC SUPC",:skills=>[617, 670]},
    143=>{:element=>"水",:role=>"wet_starter／atb_controller",:build=>"狀態工廠",:ratings=>"HPA MPA ATKB DEFB SPIA AGIA SUPA",:skills=>[617, 670, 671, 621]},
    144=>{:element=>"格鬥",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD MPE ATKB DEFD SPID AGIB SUPB",:skills=>[674, 676]},
    145=>{:element=>"格鬥",:role=>"breaker／rage_dps",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPB MPC ATKA DEFC SPIC AGIA SUPB",:skills=>[674, 676, 677]},
    146=>{:element=>"火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC MPC ATKC DEFD SPIC AGIC SUPD",:skills=>[619, 608]},
    147=>{:element=>"火",:role=>"burn_finisher／protector",:build=>"怒海堡壘",:ratings=>"HPA MPA ATKS DEFB SPIA AGIA SUPC",:skills=>[619, 608, 662, 679]},
    148=>{:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD MPD ATKD DEFD SPID AGIA SUPA",:skills=>[620, 680]},
    149=>{:element=>"水",:role=>"wet_starter／breaker",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB MPD ATKC DEFC SPID AGIA SUPA",:skills=>[620, 680, 673]},
    150=>{:element=>"水／格鬥",:role=>"wet_starter／breaker",:build=>"狀態工廠",:ratings=>"HPA MPB ATKA DEFA SPIB AGIB SUPA",:skills=>[620, 680, 673, 654]},
    151=>{:element=>"超能力",:role=>"atb_controller",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE MPA ATKE DEFE SPIB AGIA SUPB",:skills=>[670, 705]},
    152=>{:element=>"超能力",:role=>"atb_controller／state_dps",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPD MPS ATKE DEFE SPIA AGIS SUPB",:skills=>[670, 705, 685]},
    153=>{:element=>"超能力",:role=>"atb_controller／state_dps",:build=>"狀態工廠",:ratings=>"HPC MPS ATKD DEFD SPIS AGIS SUPB",:skills=>[670, 705, 685, 686]},
    154=>{:element=>"格鬥",:role=>"heavy_breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB MPE ATKB DEFC SPIE AGID SUPB",:skills=>[674, 687]},
    155=>{:element=>"格鬥",:role=>"heavy_breaker／finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPA MPC ATKA DEFB SPIC AGID SUPB",:skills=>[674, 687, 677]},
    156=>{:element=>"格鬥",:role=>"heavy_breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPA MPB ATKS DEFB SPIB AGIC SUPB",:skills=>[674, 687, 677, 688]},
    157=>{:element=>"水／毒",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD MPB ATKD DEFD SPIB AGIB SUPC",:skills=>[617, 644]},
    158=>{:element=>"水／毒",:role=>"wet_starter／poison_starter",:build=>"狀態工廠",:ratings=>"HPA MPA ATKC DEFC SPIS AGIS SUPA",:skills=>[617, 644, 690, 645]},
    159=>{:element=>"岩石／地面",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPD MPE ATKB DEFA SPIE AGIE SUPD",:skills=>[691, 693]},
    160=>{:element=>"岩石／地面",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC MPD ATKA DEFS SPID AGID SUPA",:skills=>[691, 693, 618]},
    161=>{:element=>"岩石／地面",:role=>"tank／breaker",:build=>"崩山",:ratings=>"HPA MPC ATKS DEFS SPIC AGID SUPA",:skills=>[691, 693, 618, 655]},
    162=>{:element=>"火",:role=>"burn_starter",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPC MPC ATKB DEFC SPIC AGIA SUPC",:skills=>[608, 695]},
    163=>{:element=>"火",:role=>"burn_starter／resonance_fast",:build=>"混成標準隊",:ratings=>"HPB MPB ATKA DEFB SPIB AGIS SUPC",:skills=>[608, 695, 662, 615]},
    164=>{:element=>"電／鋼",:role=>"paralysis_engine",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPE MPB ATKE DEFB SPIB AGID SUPB",:skills=>[697, 764]},
    165=>{:element=>"電／鋼",:role=>"paralysis_engine／atb_controller",:build=>"B01 雷雨鎖鏈／B02 時間監獄",:ratings=>"HPC MPS ATKC DEFA SPIA AGIB SUPA",:skills=>[697, 764, 649]},
    166=>{:element=>"電／鋼",:role=>"atb_controller／protector",:build=>"B01 雷雨鎖鏈／B02 時間監獄／B11 狀態工廠",:ratings=>"HPB MPS ATKC DEFS SPIS AGIC SUPC",:skills=>[697, 764, 649, 651]},
    167=>{:element=>"一般／飛行",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPE MPE ATKB DEFD SPIE AGIB SUPE",:skills=>[634, 639]},
    168=>{:element=>"一般／飛行",:role=>"resonance_fast／crit_hunter",:build=>"破防追擊",:ratings=>"HPB MPC ATKS DEFB SPIC AGIS SUPE",:skills=>[634, 639, 661]},
    169=>{:element=>"毒",:role=>"corrosion_engine",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPA MPD ATKB DEFC SPID AGIE SUPC",:skills=>[658, 700]},
    170=>{:element=>"毒",:role=>"corrosion_engine／poison_tank",:build=>"怒海堡壘",:ratings=>"HPS MPB ATKA DEFB SPIA AGIC SUPA",:skills=>[658, 700, 632, 645]},
    171=>{:element=>"幽靈／毒",:role=>"state_controller",:build=>"B02 時間監獄／B04 毒爆處刑",:ratings=>"HPE MPB ATKE DEFE SPIB AGIB SUPB",:skills=>[702, 665]},
    172=>{:element=>"幽靈／毒",:role=>"state_controller／state_hunter",:build=>"B02 時間監獄／B04 毒爆處刑",:ratings=>"HPD MPA ATKD DEFD SPIA AGIA SUPB",:skills=>[702, 665, 680]},
    173=>{:element=>"幽靈／毒",:role=>"state_controller／state_hunter",:build=>"狀態工廠",:ratings=>"HPB MPS ATKC DEFC SPIS AGIS SUPB",:skills=>[702, 665, 680, 701]},
    174=>{:element=>"超能力",:role=>"sleep_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPB MPC ATKD DEFD SPIC AGID SUPB",:skills=>[670, 680, 671]},
    175=>{:element=>"超能力",:role=>"sleep_controller／atb_controller",:build=>"雷雨鎖鏈",:ratings=>"HPA MPA ATKC DEFB SPIA AGIC SUPB",:skills=>[670, 680, 671, 686]},
    176=>{:element=>"電",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPD MPC ATKE DEFC SPIC AGIS SUPC",:skills=>[697, 704]},
    177=>{:element=>"電",:role=>"resonance_fast／atb_controller",:build=>"雷雨鎖鏈",:ratings=>"HPB MPB ATKD DEFB SPIB AGIS SUPB",:skills=>[697, 704, 649, 731]},
    178=>{:element=>"地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC MPD ATKD DEFA SPID AGID SUPD",:skills=>[652, 706, 707]},
    179=>{:element=>"地面",:role=>"breaker／low_hp_finisher",:build=>"B05 崩山／B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB MPC ATKB DEFS SPIC AGID SUPD",:skills=>[652, 706, 707, 655]},
    180=>{:element=>"岩石／水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPE MPB ATKD DEFA SPIB AGID SUPC",:skills=>[617, 691]},
    181=>{:element=>"岩石／水",:role=>"wet_starter／tank",:build=>"狀態工廠",:ratings=>"HPB MPA ATKC DEFS SPIA AGIC SUPB",:skills=>[617, 691, 715, 623]},
    182=>{:element=>"岩石／水",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPE MPD ATKB DEFA SPID AGIC SUPD",:skills=>[607, 617]},
    183=>{:element=>"岩石／水",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPB MPC ATKS DEFA SPIB AGIB SUPD",:skills=>[607, 617, 610, 709]},
    184=>{:element=>"超能力",:role=>"legendary_finisher／atb_controller",:build=>"混成標準隊",:ratings=>"HPS MPS ATKS DEFA SPIS AGIS SUPA",:skills=>[670, 684, 685, 682]},
    185=>{:element=>"超能力",:role=>"adaptive_allrounder／state_support",:build=>"混成標準隊",:ratings=>"HPS MPS ATKA DEFA SPIS AGIS SUPB",:skills=>[740, 686, 720]},
    186=>{:element=>"一般",:role=>"resonance_fast",:build=>"B09 共鳴風暴／B12 混成標準隊",:ratings=>"HPE MPE ATKD DEFE SPID AGIE SUPE",:skills=>[616, 639]},
    187=>{:element=>"一般",:role=>"resonance_fast／support",:build=>"魔力永動",:ratings=>"HPA MPD ATKB DEFC SPID AGIA SUPB",:skills=>[616, 639, 722, 724]},
    188=>{:element=>"蟲／毒",:role=>"poison_starter",:build=>"B03 腐敗森林／B04 毒爆處刑",:ratings=>"HPD MPD ATKC DEFD SPID AGIE SUPA",:skills=>[770, 768]},
    189=>{:element=>"蟲／毒",:role=>"poison_starter／root_controller",:build=>"狀態工廠",:ratings=>"HPB MPC ATKA DEFB SPIC AGID SUPA",:skills=>[770, 768, 726, 628]},
    190=>{:element=>"妖精",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE MPD ATKE DEFC SPID AGIE SUPB",:skills=>[660]},
    191=>{:element=>"妖精／飛行",:role=>"healer／shield_support",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPC MPA ATKD DEFA SPIA AGID SUPS",:skills=>[660, 659]},
    192=>{:element=>"妖精／飛行",:role=>"healer／state_controller",:build=>"B10 魔力永動／B12 混成標準隊",:ratings=>"HPA MPS ATKD DEFA SPIS AGIB SUPB",:skills=>[660, 659, 765]},
    193=>{:element=>"幽靈",:role=>"state_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPB MPA ATKC DEFC SPIA AGIA SUPB",:skills=>[702, 665, 683]},
    194=>{:element=>"幽靈",:role=>"state_controller／fragile_engine",:build=>"毒爆處刑",:ratings=>"HPB MPS ATKC DEFC SPIS AGIS SUPB",:skills=>[702, 665, 683, 701]},
    195=>{:element=>"一般",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPS MPE ATKE DEFE SPID AGIE SUPB",:skills=>[740, 660, 705]},
    196=>{:element=>"一般",:role=>"healer／mana_support",:build=>"混成標準隊",:ratings=>"HPS MPA ATKE DEFE SPIS AGIC SUPA",:skills=>[740, 660, 705, 710]},
    197=>{:element=>"電",:role=>"paralysis_engine／resonance_fast",:build=>"狀態工廠",:ratings=>"HPA MPS ATKB DEFB SPIS AGIS SUPB",:skills=>[697, 649, 685, 650]},
    198=>{:element=>"火",:role=>"burn_finisher／breaker",:build=>"B08 復仇熔爐／B11 狀態工廠／B05 崩山",:ratings=>"HPS MPA ATKS DEFA SPIA AGIS SUPA",:skills=>[608, 736, 695, 615]},
    199=>{:element=>"水",:role=>"wet_starter／state_controller",:build=>"B01 雷雨鎖鏈／B11 狀態工廠",:ratings=>"HPS MPS ATKB DEFS SPIS AGIA SUPC",:skills=>[752, 681, 685, 623]},
    200=>{:element=>"岩石／地面",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC MPD ATKC DEFC SPID AGID SUPD",:skills=>[619, 691]},
    201=>{:element=>"岩石／地面",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB MPC ATKB DEFB SPIB AGIC SUPA",:skills=>[619, 691, 657]},
    202=>{:element=>"岩石／惡",:role=>"tank／breaker／finisher",:build=>"崩山",:ratings=>"HPS MPA ATKS DEFS SPIA AGIC SUPA",:skills=>[619, 691, 657, 640]},
    203=>{:element=>"水／草",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPD MPD ATKE DEFE SPID AGIE SUPC",:skills=>[617, 741]},
    204=>{:element=>"水／草",:role=>"wet_starter／healer",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPB MPC ATKD DEFC SPIC AGIC SUPA",:skills=>[617, 741, 673]},
    205=>{:element=>"水／草",:role=>"wet_starter／healer／mana_support",:build=>"狀態工廠",:ratings=>"HPA MPA ATKC DEFB SPIA AGIB SUPS",:skills=>[617, 741, 673, 605]},
    206=>{:element=>"水／飛行",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B07 怒海堡壘",:ratings=>"HPD MPD ATKE DEFE SPID AGIA SUPA",:skills=>[617, 725, 690]},
    207=>{:element=>"水／飛行",:role=>"wet_starter／protector",:build=>"混成標準隊",:ratings=>"HPB MPA ATKD DEFA SPIA AGIC SUPA",:skills=>[617, 725, 690, 765]},
    208=>{:element=>"格鬥",:role=>"heavy_breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB MPE ATKC DEFE SPIE AGIE SUPB",:skills=>[749, 687, 750]},
    209=>{:element=>"格鬥",:role=>"heavy_breaker／tank",:build=>"B05 崩山／B06 破防追擊／B08 復仇熔爐",:ratings=>"HPS MPD ATKS DEFC SPID AGIC SUPA",:skills=>[749, 687, 750, 688]},
    210=>{:element=>"鋼／妖精",:role=>"fragile_engine／protector／finisher",:build=>"怒海堡壘",:ratings=>"HPC MPC ATKB DEFA SPIC AGIC SUPB",:skills=>[619, 751, 640, 732]},
    211=>{:element=>"鋼／岩石",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC MPD ATKC DEFA SPID AGIE SUPD",:skills=>[616, 698]},
    212=>{:element=>"鋼／岩石",:role=>"tank／breaker",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB MPD ATKA DEFS SPID AGID SUPA",:skills=>[616, 698, 751]},
    213=>{:element=>"鋼／岩石",:role=>"tank／breaker／protector",:build=>"崩山",:ratings=>"HPB MPC ATKS DEFS SPIC AGIC SUPA",:skills=>[616, 698, 751, 709]},
    214=>{:element=>"水／惡",:role=>"wet_finisher",:build=>"B01 雷雨鎖鏈／B09 共鳴風暴",:ratings=>"HPD MPD ATKA DEFE SPID AGIC SUPB",:skills=>[619, 611, 640]},
    215=>{:element=>"水／惡",:role=>"wet_finisher／crit_hunter",:build=>"破防追擊",:ratings=>"HPB MPB ATKS DEFD SPIB AGIA SUPB",:skills=>[619, 611, 640, 672]},
    216=>{:element=>"水",:role=>"healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE MPE ATKE DEFE SPIE AGIB SUPB",:skills=>[771, 616, 752]},
    217=>{:element=>"水",:role=>"healer／shield_support／wet_starter",:build=>"混成標準隊",:ratings=>"HPS MPS ATKC DEFB SPIS AGIB SUPS",:skills=>[771, 616, 752, 684]},
    218=>{:element=>"幽靈",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPE MPC ATKD DEFA SPIC AGIE SUPB",:skills=>[702, 663]},
    219=>{:element=>"幽靈",:role=>"tank／state_controller",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPD MPA ATKC DEFS SPIA AGIE SUPA",:skills=>[702, 663, 728]},
    220=>{:element=>"幽靈",:role=>"tank／state_controller",:build=>"時間監獄",:ratings=>"HPD MPA ATKA DEFS SPIS AGID SUPA",:skills=>[702, 663, 728, 701]},
    221=>{:element=>"惡",:role=>"crit_hunter／finisher",:build=>"共鳴風暴",:ratings=>"HPB MPB ATKS DEFC SPIB AGIB SUPC",:skills=>[639, 753, 610, 640]},
    222=>{:element=>"龍",:role=>"finisher",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPD MPE ATKB DEFC SPIE AGIC SUPE",:skills=>[619, 706]},
    223=>{:element=>"龍",:role=>"finisher／resonance_fast",:build=>"B06 破防追擊／B09 共鳴風暴",:ratings=>"HPB MPC ATKA DEFA SPIC AGIC SUPE",:skills=>[619, 706, 718]},
    224=>{:element=>"龍／飛行",:role=>"finisher／resonance_fast",:build=>"混成標準隊",:ratings=>"HPS MPA ATKS DEFB SPIA AGIS SUPE",:skills=>[619, 706, 718, 614]},
    225=>{:element=>"鋼／超能力",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPD MPD ATKD DEFB SPID AGIE SUPD",:skills=>[616, 698]},
    226=>{:element=>"鋼／超能力",:role=>"breaker／atb_controller",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB MPC ATKB DEFA SPIB AGIC SUPC",:skills=>[616, 698, 686]},
    227=>{:element=>"鋼／超能力",:role=>"breaker／atb_controller／tank",:build=>"B05 崩山／B06 破防追擊／B01 雷雨鎖鏈",:ratings=>"HPA MPA ATKS DEFS SPIA AGIB SUPB",:skills=>[616, 698, 686, 755]},
    228=>{:element=>"冰",:role=>"freeze_controller",:build=>"B02 時間監獄／B11 狀態工廠",:ratings=>"HPC MPD ATKD DEFC SPID AGIC SUPB",:skills=>[735, 681, 665]},
    229=>{:element=>"冰／幽靈",:role=>"freeze_controller／resonance_fast",:build=>"共鳴風暴",:ratings=>"HPB MPB ATKB DEFB SPIB AGIS SUPB",:skills=>[735, 681, 665, 622]},
    230=>{:element=>"水",:role=>"wet_starter",:build=>"B01 雷雨鎖鏈／B10 魔力永動",:ratings=>"HPE MPE ATKE DEFC SPIE AGIB SUPA",:skills=>[771, 616]},
    231=>{:element=>"水／飛行",:role=>"wet_starter／rage_dps／breaker",:build=>"狀態工廠",:ratings=>"HPS MPB ATKS DEFB SPIB AGIB SUPA",:skills=>[771, 616, 619, 672]},
    232=>{:element=>"水／電",:role=>"wet_paralysis",:build=>"B01 雷雨鎖鏈／B11 狀態工廠",:ratings=>"HPA MPC ATKE DEFD SPIC AGIC SUPA",:skills=>[617, 697, 649]},
    233=>{:element=>"水／電",:role=>"wet_paralysis／mana_support",:build=>"魔力永動",:ratings=>"HPS MPB ATKD DEFC SPIB AGIC SUPA",:skills=>[617, 697, 649, 621]},
    234=>{:element=>"蟲",:role=>"tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPC MPE ATKC DEFA SPIE AGIE SUPB",:skills=>[616, 618, 729]},
    235=>{:element=>"蟲／鋼",:role=>"tank／state_spreader／protector",:build=>"腐敗森林",:ratings=>"HPA MPC ATKA DEFS SPIC AGID SUPA",:skills=>[616, 618, 729, 731]},
    236=>{:element=>"龍／地面",:role=>"breaker",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPC MPD ATKC DEFD SPID AGID SUPD",:skills=>[616, 653]},
    237=>{:element=>"龍／地面",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊",:ratings=>"HPB MPD ATKA DEFC SPID AGIB SUPD",:skills=>[616, 653, 718]},
    238=>{:element=>"龍／地面",:role=>"breaker／finisher／resonance_fast",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPS MPB ATKS DEFA SPIA AGIS SUPD",:skills=>[616, 653, 718, 655]},
    239=>{:element=>"蟲／格鬥",:role=>"breaker／finisher",:build=>"B05 崩山／B06 破防追擊／B04 毒爆處刑",:ratings=>"HPA MPC ATKS DEFB SPIB AGIA SUPB",:skills=>[624, 654, 687, 627]},
    240=>{:element=>"惡／火",:role=>"burn_finisher",:build=>"B08 復仇熔爐／B11 狀態工廠",:ratings=>"HPD MPB ATKC DEFE SPIC AGIC SUPB",:skills=>[608, 619, 663]},
    241=>{:element=>"惡／火",:role=>"burn_finisher／state_dps",:build=>"時間監獄",:ratings=>"HPA MPA ATKA DEFC SPIA AGIA SUPB",:skills=>[608, 619, 663, 612]},
    242=>{:element=>"鋼／飛行",:role=>"protector／tank",:build=>"B07 怒海堡壘／B12 混成標準隊",:ratings=>"HPB MPD ATKB DEFS SPIC AGIB SUPA",:skills=>[634, 730, 729, 751]},
    243=>{:element=>"超能力／妖精",:role=>"mana_support",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE MPD ATKE DEFE SPID AGID SUPB",:skills=>[670, 685]},
    244=>{:element=>"超能力／妖精",:role=>"mana_support／healer",:build=>"B07 怒海堡壘／B10 魔力永動",:ratings=>"HPE MPC ATKE DEFD SPIC AGIC SUPA",:skills=>[670, 685, 659]},
    245=>{:element=>"超能力／妖精",:role=>"healer／state_controller",:build=>"B10 魔力永動／B11 狀態工廠",:ratings=>"HPB MPS ATKC DEFC SPIS AGIB SUPA",:skills=>[670, 685, 659, 686]},
    7=>{:element=>"鋼／電",:role=>"atb_disruptor",:build=>"時間監獄／雷雨鎖鏈",:ratings=>"依目前能力",:skills=>[160, 161, 162, 163, 164]},
    8=>{:element=>"毒／草",:role=>"emergency_guard",:build=>"怒海堡壘／復仇熔爐",:ratings=>"依目前能力",:skills=>[165, 166, 167, 168, 169]},
    9=>{:element=>"妖精／飛行",:role=>"healer",:build=>"溢療護盾／魔力爆發",:ratings=>"依目前能力",:skills=>[170, 171, 172, 173, 174]},
    10=>{:element=>"水／超能",:role=>"state_starter",:build=>"腐敗森林／狀態工廠",:ratings=>"依目前能力",:skills=>[175, 176, 177, 178, 179]},
    11=>{:element=>"火／格鬥",:role=>"armor_breaker",:build=>"崩防獵殺／混成隊",:ratings=>"依目前能力",:skills=>[180, 181, 182, 183, 184]},
    12=>{:element=>"鋼",:role=>"protector",:build=>"固定 A-A-S",:ratings=>"依目前能力",:skills=>[185]},
    13=>{:element=>"電",:role=>"atb_controller",:build=>"固定 A-S",:ratings=>"依目前能力",:skills=>[186]},
    14=>{:element=>"毒",:role=>"corrosion_engine",:build=>"固定 A-A-S",:ratings=>"依目前能力",:skills=>[187]},
    15=>{:element=>"鋼",:role=>"breaker",:build=>"固定 A-A-A-S",:ratings=>"依目前能力",:skills=>[188]},
    16=>{:element=>"妖精",:role=>"healer／mana_engine",:build=>"固定 A-A-S",:ratings=>"依目前能力",:skills=>[189]},
  }
  PASSIVE_FLAVOR = {
    102=>"共鳴不是命令，是彼此聽見。",106=>"領袖不是最大聲，而是讓每一聲都進得來。",
    112=>"多出來的光也能成為下一次希望。",116=>"大地不催促，它只是一直托著你。",
    122=>"能量不該浪費，尤其是敵人的節奏。",126=>"速度是提前完成思考。",
    132=>"毒性不是邪惡，只是劑量不誠實。",136=>"一個病灶只是案例，一串病灶才是系統。",
    142=>"我還站著，就不算輸。",146=>"替別人受傷不是美德，是我做的選擇。",
    152=>"拳頭也要磨，否則只是噪音。",156=>"牆存在的意義，就是被拆掉。"
  }
  def self.discovered?(actor_id)
    return true if actor_id>=1 && actor_id<=6
    return $game_switches[actor_id+1000]
  end
  def self.sync_actor(actor_id)
    if defined?(AlbertSummonTemporaryBattle) && AlbertSummonTemporaryBattle.respond_to?(:sync_actor_database_data)
      AlbertSummonTemporaryBattle.sync_actor_database_data(actor_id)
    end
    $game_actors[actor_id]
  end
  def self.data(actor)
    d=DATA[actor.id] || {}
    d
  end
  def self.skill_ids(actor)
    d=data(actor)
    return d[:skills] if d[:skills] && !d[:skills].empty?
    ids=[]
    if actor.class && actor.class.respond_to?(:learnings)
      actor.class.learnings.each {|l| ids << l.skill_id}
    end
    ids.uniq.sort
  end
  def self.skill_detail(skill)
    return "" if skill==nil
    n=skill.note.to_s
    parts=[]
    parts << "ATB#{n[/<atb_shift:\s*(-?\d+)>/i,1]}%" if n =~ /<atb_shift:/i
    parts << "Break+#{n[/<break_power:\s*(\d+)>/i,1]}" if n =~ /<break_power:/i
    parts << "對State#{$1}+#{$2}%" if n =~ /<bonus_vs_state\s+(\d+):(\d+)>/i
    parts << "狀態#{$1} #{$2}%" if n =~ /<state_chance\s+(\d+):(\d+)>/i
    parts << "擴散State#{$1}" if n =~ /<spread_state\s+(\d+):/i
    parts << "消耗State#{$1}" if n =~ /<consume_state\s+(\d+)>/i
    parts << "召喚共鳴" if n =~ /<summon_(?:lv|atk|def|spi|agi)_power:/i
    parts.empty? ? skill.description.to_s : parts.join("／")
  end
end
class Game_Party < Game_Unit
  unless method_defined?(:fs_cb_v21_add_actor)
    alias fs_cb_v21_add_actor add_actor
    def add_actor(actor_id)
      fs_cb_v21_add_actor(actor_id)
      $game_switches[actor_id+1000]=true
    end
  end
end
class Sprite_CharacterBookActor < Sprite
  def initialize(viewport=nil)
    super(viewport); @actor=nil; @count=0; @pattern=1
  end
  def actor=(actor)
    return if @actor==actor
    @actor=actor; @count=0; @pattern=1; refresh_bitmap
  end
  def refresh_bitmap
    # Cache.character 回傳共用快取，不可 dispose，否則其他視窗也會一起失憶。
    self.bitmap=nil
    return if @actor==nil || @actor.character_name.to_s==""
    src=Cache.character(@actor.character_name)
    self.bitmap=src
    @single=@actor.character_name[0,1]=="$"
    @cw=src.width/(@single ? 3 : 12)
    @ch=src.height/(@single ? 4 : 8)
    update_rect
  end
  def update_rect
    return if self.bitmap==nil
    idx=@actor.character_index.to_i
    bx=@single ? 0 : (idx%4)*3
    by=@single ? 0 : (idx/4)*4
    self.src_rect.set((bx+@pattern)*@cw,(by+0)*@ch,@cw,@ch)
    self.ox=@cw/2; self.oy=@ch
  end
  def update
    super; return if @actor==nil
    @count+=1
    if @count>=14
      @count=0; @pattern=(@pattern==0 ? 1 : @pattern==1 ? 2 : 0); update_rect
    end
  end
end
class Window_FSCharacterList < Window_Selectable
  attr_reader :data
  def initialize
    super(0,0,180,416); @data=[]
    FS_CHARACTER_BOOK_V21::ACTOR_IDS.each do |id|
      next if $data_actors[id]==nil
      @data << id
    end
    @item_max=@data.size; self.index=0; refresh
  end
  def refresh
    self.contents.dispose if self.contents && !self.contents.disposed?
    self.contents=Bitmap.new(width-32,[height-32,@item_max*WLH].max)
    @data.each_with_index do |id,i|
      name=FS_CHARACTER_BOOK_V21.discovered?(id) ? $data_actors[id].name : "????"
      self.contents.font.color=FS_CHARACTER_BOOK_V21.discovered?(id) ? normal_color : disabled_color
      self.contents.draw_text(item_rect(i),name)
    end
  end
  def actor_id; @data[self.index] end
end
class Window_FSCharacterInfo < Window_Base
  attr_reader :page
  def initialize
    super(180,0,364,416); @actor=nil; @page=0
  end
  def actor=(actor); @actor=actor; @page=0; refresh end
  def next_page; @page=(@page+1)%4; refresh end
  def prev_page; @page=(@page+3)%4; refresh end
  def refresh
    contents.clear; return if @actor==nil
    d=FS_CHARACTER_BOOK_V21.data(@actor)
    contents.font.size=20; contents.font.color=text_color(1)
    contents.draw_text(0,0,contents.width,WLH,@actor.name)
    contents.font.size=16; contents.font.color=normal_color
    contents.draw_text(0,24,contents.width,WLH,"Lv#{@actor.level}  #{d[:element] || '未設定'}")
    contents.draw_text(0,48,contents.width,WLH,"Page #{@page+1}/4",2)
    case @page
    when 0; draw_overview(d)
    when 1; draw_skills(0,5)
    when 2; draw_skills(5,10)
    when 3; draw_build(d)
    end
  end
  def draw_overview(d)
    y=82
    [["HP",@actor.maxhp],["MP",@actor.maxmp],["ATK",@actor.atk],["DEF",@actor.def],["SPI",@actor.spi],["AGI",@actor.agi]].each_with_index do |pair,i|
      x=(i%2)*150; yy=y+(i/2)*24
      contents.draw_text(x,yy,70,WLH,pair[0]); contents.draw_text(x+55,yy,70,WLH,pair[1].to_s,2)
    end
    contents.draw_text(0,164,contents.width,WLH,"定位：#{d[:role] || '依角色設定'}")
    contents.draw_text(0,188,contents.width,WLH,"評價：#{d[:ratings] || '依目前能力'}")
  end
  def draw_skills(from,to)
    ids=FS_CHARACTER_BOOK_V21.skill_ids(@actor)[from...to] || []
    y=82
    ids.each do |sid|
      sk=$data_skills[sid]; next if sk==nil
      learned=!@actor.respond_to?(:skill_learn?) || @actor.skill_learn?(sk)
      contents.font.color=learned ? normal_color : disabled_color
      contents.draw_text(0,y,contents.width,WLH,"#{sid} #{sk.name}")
      contents.font.size=14
      detail=FS_CHARACTER_BOOK_V21.skill_detail(sk)
      contents.draw_text(12,y+20,contents.width-12,WLH,detail)
      contents.font.size=16; y+=52
    end
  end
  def draw_build(d)
    contents.font.color=normal_color
    y=82
    contents.draw_text(0,y,contents.width,WLH,"推薦 Build：#{d[:build] || '依裝備與隊伍調整'}")
    y+=32
    role=(d[:role] || '').to_s
    combo = if role =~ /poison|state|毒|腐蝕/i
      "維娜疊毒／腐蝕 → 百病相生或毒爆"
    elsif role =~ /atb|paralysis|wet|時間/i
      "濕潤 → 艾卓削 ATB／麻痺 → 追擊"
    elsif role =~ /break|breaker|破防/i
      "累積破勢 → 崩防窗口 → 全隊爆發"
    elsif role =~ /heal|protector|tank|guard/i
      "護盾／治療／Cover → 保護爆發角色"
    else
      "共鳴標記 → 魂刻技能 → 三段追擊"
    end
    contents.draw_text(0,y,contents.width,WLH,"Combo：#{combo}")
    y+=40
    FS_CHARACTER_BOOK_V21.skill_ids(@actor).each do |sid|
      flavor=FS_CHARACTER_BOOK_V21::PASSIVE_FLAVOR[sid]
      next if flavor==nil
      contents.font.color=text_color(3)
      contents.draw_text(0,y,contents.width,WLH,flavor)
      y+=24
    end
  end
end
class Scene_CharacterBook < Scene_Base
  def start
    super
    @list=Window_FSCharacterList.new
    @info=Window_FSCharacterInfo.new
    @sprite=Sprite_CharacterBookActor.new
    @sprite.x=492; @sprite.y=150; @sprite.z=300
    refresh_actor
  end
  def terminate
    super
    @list.dispose; @info.dispose
    @sprite.dispose
  end
  def update
    super; @list.update; @sprite.update
    if @last_index!=@list.index
      refresh_actor
    end
    if Input.trigger?(Input::RIGHT); Sound.play_cursor; @info.next_page
    elsif Input.trigger?(Input::LEFT); Sound.play_cursor; @info.prev_page
    elsif Input.trigger?(Input::B); Sound.play_cancel; $scene=Scene_Map.new
    end
  end
  def refresh_actor
    @last_index=@list.index
    id=@list.actor_id
    if FS_CHARACTER_BOOK_V21.discovered?(id)
      actor=FS_CHARACTER_BOOK_V21.sync_actor(id)
      @info.actor=actor; @sprite.actor=actor
    else
      @info.actor=nil; @sprite.actor=nil
    end
  end
end
#==============================================================================
# ■ END
#==============================================================================
