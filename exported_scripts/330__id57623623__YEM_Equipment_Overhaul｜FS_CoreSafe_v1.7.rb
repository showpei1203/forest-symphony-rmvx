#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：YEM Equipment Overhaul｜FS CoreSafe v1.7
# 原作：Yanfly Engine Zealous - Equipment Overhaul，最後更新 2010-08-23
#
# 【用途】
# 重做 RPG Maker VX 裝備系統：修正裝備能力值運算順序、提供擴充裝備欄、裝備條件、
# 自動狀態、裝備 Trait、適性（Aptitude）、新的 Equipment Scene 與最佳化流程。
# Forest Symphony 的 SummonEquip、EquipmentCombo、EquipHelpScroll、Safety Patch 等
# 多個系統直接依賴本頁 API，因此它是正式底層，不可任意搬動或刪除。
#
# 【載入順序／相容】
# 1. 必須位於 ▼ Materials 下、Main 上；Forest Symphony 的裝備擴充與 Patch 在後方。
# 2. 會讀取 $imported：EquipmentOverhaul、DEX Stat、RES Stat、BattleEngineMelody、
#    IconModuleLibrary、AggroAI 等；順序錯誤可能改變 available stat／UI／method alias。
# 3. Notetag、Symbol、Script Call 方法名稱是 Runtime API，不翻譯、不改名。
#
# 【第一區：Basic Settings】
# COMMANDS：裝備 Scene 顯示哪些命令，現有 Symbol 包含：
#   :manual   手動裝備
#   :optimize 自動最佳化
#   :aptitude 適性選單（目前程式中可能被註解停用）
# VOCAB：裝備 Scene 的文字，例如 twohand、unequip、amount 等。
# STAT_VOCAB：HIT／EVA／CRI／ODDS 等額外能力顯示名稱。
# SHOWN_STATS：裝備 Scene 比較欄顯示哪些能力以及順序。
# UNEQUIP_ICON：卸下裝備使用的 Icon ID。
# 字體大小／Window Layout 等其餘常數依本頁 Section I 調整。
#
# 【第二區：Equip Settings】
# TYPE_LIST／Equip Type 設定用來突破 VX 原生只有 4 種 Armor Slot 的限制。
# Armor 可利用 <equip type: phrase> 指定自訂欄位；Actor 的 equip_type Array 決定
# 實際擁有哪些欄位。Weapon 為獨立欄位，腳本會特別保護其相容性。
#
# 【第三區：Base Stat Settings】
# 裝備的固定值與百分比會依腳本定義的運算順序計算。百分比先算，再加固定值，
# 因此可避免多個裝備 Patch 各自加減後造成不可預測結果。
# 裝備最佳化會忽略百分比 Tag 的評估，這是原系統既定行為。
#
# 【第四區：Aptitude】
# Aptitude 讓 Class 對不同裝備能力獲得不同倍率，例如戰士可以較不擅長 SPI，
# 法師則取得較高 SPI。Item 也可透過 Notetag 永久／暫時調整適性（依原 API）。
#
# stat 可用 MaxHP、MaxMP、ATK、DEF、SPI、RES、DEX、AGI。
#
# 【Weapon／Armor 共用 Notetag】
# 固定能力：
# 百分比能力：
# stat 可用 MaxHP、MaxMP、ATK、DEF、SPI、AGI、HIT、EVA、CRI、ODDS。
# 百分比先於固定值計算，可突破資料庫 Editor 的 500 數值限制。
#
#   <trait: super guard>       防禦減傷由 1/2 強化為 1/4
#   <trait: pharmacology>      使用物品效果加倍
#   <trait: fast attack>       普攻取得先手修正
#   <trait: dual attack>       普攻兩次
#   <trait: prevent critical>  防止被爆擊
#   <trait: half mp cost>      MP 消耗減半
#   <trait: double exp gain>   EXP 加倍
#   <trait: auto hp recover>   每回合／步行自動恢復 HP
# 另有本版本擴充的 anti hp/mp regen/degen 等 Trait，識別字依程式 REGEXP 為準。
#
# 自動狀態：
# 裝備期間自動擁有指定 State，卸裝後移除。
#
# 能力需求：
#   <require above: stat x>   stat >= x 才能裝
#   <require under: stat x>   stat <= x 才能裝
# stat 可用 Level、MaxHP、MaxMP、ATK、DEF、SPI、RES、DEX、AGI、HIT、EVA、CRI、ODDS。
#
# 開關需求：
# 指定 Switch 必須 ON，否則裝備呈灰色不可選。
#
# 變數需求：
# Variable x 必須高於／低於門檻 y。
# 本版本也含 Weapon Level／Mastery 類需求 REGEXP，改動前先查實際資料庫 Note。
#
# 【Weapon 專用 Notetag】
# 自訂雙手武器顯示文字；phrase 大小寫視原程式處理規則。
#
# 【Armor 專用 Notetag】
# 指定自訂裝備欄名稱，用來擴充 VX 原生 Armor Slot。
#
# 【主要 Script Call】
# 將 Armor 裝到指定擴充欄：
#   item = $data_armors[item_id]
#   $game_actors[x].change_equip(slot_id, item)
#
# 鎖定／解除指定裝備欄：
#   $game_actors[x].lock_equip(slot_id)
#   $game_actors[x].unlock_equip(slot_id)
# 這不會突破 Actor 本身「固定裝備」Trait；固定裝備仍有優先權。
#
# 整批替換 Actor 的 Armor Type：
#   array = [:other, :other, :other]
#   $game_actors[x].equip_type = array
# 無法再裝備的物品會卸下並退回 Inventory；Weapon 不包含在此 Array。
#
# 動態增加欄位：
#   $game_actors[x].add_equip_type(type)
# 動態刪除最後一個欄位：
#   $game_actors[x].delete_last_equip_type
# 刪除欄位時該欄裝備會卸下；Weapon 欄不會被刪除。
#
# 【Test/Battle Test 快捷鍵】
# 裝備 Scene 測試模式：F5 可強制裝上原本不可裝備的物品；F7／F8 調整數量。
# Aptitude 畫面：F5 可強制使用已消耗的適性物品；F6 重設適性；F7／F8 調整數量。
# 只在 $TEST／$BTEST 使用，正式遊戲不應依賴這些鍵。
#
# 【能力比較與取得】
# YEM::EQUIP::COMP_PARAM_PROC 定義「舊裝 vs 新裝」能力差。
# YEM::EQUIP::GET_PARAM_PROC 定義 UI 取得各能力的方法。
# 若新增自訂能力，必須同步檢查 SHOWN_STATS、STAT_VOCAB、Proc 與 FS 後續 UI Patch。
#
# 【相關素材】
# Forest Symphony 現行版本會由此裝備 UI／後續 Patch 直接或間接使用：
# Graphics/System/MenuBack_equip、MenuBack_mask，以及 le.png 等素材。
# 素材是否可刪必須反查 SummonEquip／EquipHelpScroll／Menu Patch，不可只看本頁字串。
#
# 【歷史更新】
# 2010-05-24：轉為 Yanfly Engine Melody。
# 2010-06-03：效率更新。
# 2010-06-24：修正卸裝問題。
# 2010-08-16：修正卸下 MaxHP／MaxMP 裝備問題。
# 2010-08-23：修正 Optimization 問題。
# 2026-08-15：FS CoreSafe v1.2，補回 KGC PassiveSkill 的 CRITICAL_BONUS 最終 CRI +4 語意；
#             Phase42F 實機證明 page330 的最終 cri Authority 漏接此 effect。
# 2026-08-15：FS CoreSafe v1.3，修正 extra-slot discard_equip 的最終 Passive refresh 時序。
#             Phase43A 實機 trace 證明 KGC restore_passive_rev 在 @extra_armor_id 清除前執行，
#             造成 Direct provider 已不可見但 Passive cache 仍殘留；本版只在「確實移除 extra slot」後
#             補一次既有 EquipmentSkill Passive Authority refresh，不改一般 change_equip / setup / level_up。
# 2026-08-15：FS CoreSafe v1.4，將 extra-slot discard_equip 的 final refresh 收斂為
#             Teaching → Passive → EquipmentCombo 三段式 Authority convergence。Phase43C 實機證明
#             extra slot 清除後 Teaching raw/marker 與 Combo-owned State 都會殘留；因此僅在
#             removed_extra=true 時依既有正式 Authority 方法補齊最終同步，不改一般 change_equip / setup / level_up。
# 2026-08-15：FS CoreSafe v1.5，將 discard_equip 的 final Authority convergence 擴展至 VX 原生
#             armor1..armor4。Phase43F 實機證明一般防具欄雖會在 KGC Passive refresh 前先移除裝備，
#             但 Teaching raw/marker 未同步，會讓 Passive 仍依 stale raw skill 保留，Combo-owned State 也不會清除。
#             本版只在 discard_equip 確實移除「一般欄或 extra-slot Armor」後統一執行
#             Teaching → Passive → Combo 一次 final convergence；extra-slot 不重複刷新。
# 2026-08-15：FS CoreSafe v1.6，將相同 final Authority convergence 擴展至 Weapon discard。
#             Phase44A RPG Maker VX 實機 trace 證明 Weapon 已由 VX base discard 真正移除後，
#             Direct <equipskill> 因動態讀取 equips 會自然消失，但 Teaching raw/marker、Passive cache
#             與 EquipmentCombo-owned State 因 v1.5 的 Armor-only return 而殘留。
#             本版只在 discard_equip 確實移除主武器或雙持第二武器時，同樣執行一次
#             Teaching → Passive → Combo final convergence；Armor 與 extra-slot 既有路徑不變。
# 2026-08-16：FS CoreSafe v1.7，Phase44K 將 discard final convergence 的 Teaching 段改走
#             deferred Teaching helper。Teaching 內 Passive learn/forget mutation 不再 transitive rebuild；
#             後續既有 Passive → Combo final Authority 順序不變，因此每次成功 discard 精確只 rebuild Passive 一次。
#
# 【維護規則】
# 1. Notetag、Symbol、REGEXP 字串與 Script Call 不翻譯。
# 2. 改 TYPE_LIST／equip_type 前，必須一起測 Save Compatibility、召喚裝備頁與 Combo。
# 3. 原作者／版本／網址保留；下方英文長篇說明已整理成此中文手冊。
# 4. Phase 30 起，equip_type／欄位增刪／purge_unequippable／equip_legal_slot
#    的 FS 安全修正已直接回寫本 Core；後方 SafetyPatch 不再重複覆寫這六個方法。
#==============================================================================
#===============================================================================
# Yanfly Engine Zealous - Equipment Overhaul
# 最後更新：2010-08-23｜原作者：Yanfly
# 原英文 Instructions／Notetag／Script Call 說明已整理至本頁開頭繁中完整手冊。
# 原 API、Notetag、REGEXP 識別字與 Runtime 程式碼維持原樣。
#===============================================================================

$imported = {} if $imported == nil
$imported["EquipmentOverhaul"] = true
$imported["FS YEM Equipment CoreSafe"] = 1.6

module YEM
  module EQUIP
    
    #===========================================================================
    # 第一區：基本設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    COMMANDS =[
      :manual,  # 手動裝備武器與防具。
      :optimize,  # 自動最佳化裝備。
      #:aptitude,    # 進入適性調整選單。
    ]  # 此行不可移除。
    
    VOCAB ={
      :manual   => "",
      :optimize => "",
      :aptitude => "Aptitude",
      :mastery  => "Weaponry",
      :twohand  => "雙手武器",
      :arrow    => "»",
      :noequip  => "<尚未裝備>",
      :unequip  => "卸下裝備",
      :amount   => ":%2d",
      :apt_rate => "%s Rate",
    }  # 此行不可移除。
    
    STAT_VOCAB ={
      :hit  => "命中",  # 影響命中率的能力。
      :eva  => "閃躲",  # 影響閃避率的能力。
      :cri  => "爆擊",  # 影響爆擊率的能力。
      :odds => "",  # 影響仇恨／被鎖定率的能力。
    }  # 此行不可移除。
    
    #   :hp, :mp, :atk, :def, :spi, :res, :dex, :agi, :hit, :eva, :cri, :odds
    SHOWN_STATS = [:maxhp, :maxmp, :atk, :def, :spi, :agi, :hit, :eva, :cri]
    
    UNEQUIP_ICON = 517
    
    CATEGORY_FONT_SIZE = 20
    
    STAT_FONT_SIZE = 20
    
    #===========================================================================
    # 第二區：裝備欄位設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    TYPE_LIST =[
      :shield,
      :helmet,
      :armour,
      :cloak,
      :other1,
      :other2,
      :name,
     # :other,    # 第 3 個飾品／其他防具欄。
    ]
    
    TYPE_RULES ={
    # 類型     => [     顯示名, Kind, 可空欄?, 自動最佳化],
      :weapon  => [ "武器",  nil,  false,     true],
      :shield  => [ "盾牌",    0,   true,     true],
      :helmet  => [ "頭部",    1,   true,     true],
      :armour  => [ "身體",    2,   true,     true],
      :cloak   => [ "足部",    3,   true,     true],
      :other1  => [ "飾品",    4,   true,     true],
      :name    => [ "特殊",    5,   true,     true],
      :other2  => [ "飾品",    6,   true,     true],
    }  # 此行不可移除。
    
    OPTIMIZE_SETTINGS ={
      :unlisted => [:def, :agi, :maxhp, :spi, :maxmp, :res, :atk],
      :weapon   => [:atk, :spi, :maxmp, :agi, :maxhp, :def, :res],
    }  # 此行不可移除。
    
    #===========================================================================
    # 第三區：基礎能力設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    BASE_STAT ={
      :maxhp => "actor.parameters[0, @level]",
      :maxmp => "actor.parameters[1, @level]",
      :atk   => "actor.parameters[2, @level]",
      :def   => "actor.parameters[3, @level]",
      :spi   => "actor.parameters[4, @level]",
      :agi   => "actor.parameters[5, @level]",
      :hit   => "95",
      :eva   => "5",
      :cri   => "4 + ((actor.critical_bonus) ? 4 : 0)",
      :odds  => "4 - self.class.position",
    }  # 此行不可移除。
    
    #===========================================================================
    # 第四區：適性設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    USE_APTITUDE_SYSTEM = false
    
    APTITUDE ={
    # ClassID => [MaxHP, MaxMP,   ATK,   DEF,   SPI,   RES,   DEX,   AGI]  # 各能力適性百分比
            0 => [  100,   100,   100,   100,   100,   100,   100,   100],
    }  # 此行不可移除。
    
    MINIMUM_APTITUDE = 10
    MAXIMUM_APTITUDE = 255
    
    SHOW_APT_BOOSTS = true
    
  end
end

#===============================================================================
#===============================================================================

module YEM
  module REGEXP
    module BASEITEM
      
      STAT_SET = /<(.*):[ ]*([\+\-]\d+)>/i
      STAT_PER = /<(.*):[ ]*([\+\-]\d+)([%％])>/i
      TRAITS   = /<(?:TRAITS|trait):[ ](.*)>/i
      REQ_SWITCH = /<(?:REQUIRE SWITCH||require switches):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      REQ_STRING = /<(?:REQUIRE|req)[ ](.*):[ ](\d+)[ ](.*)[ ](\d+)>/i
      REQUIRE    = /<(?:REQUIRE|req)[ ](.*):[ ](.*)[ ](\d+)>/i
      AUTOSTATES = /<(?:AUTO_STATE|auto state|auto states):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      APT_GROWTH = /<(.*)[ ](?:APTITUDE|apt):[ ]([\+\-]\d+)([%％])>/i
      
      TWO_HAND = /<(?:2_HAND_TEXT|2 hand text):[ ](.*)>/i
      EQUIP_TYPE = /<(?:EQUIP_TYPE|equip type):[ ](.*)>/i
      
    end
    module STATE
      
      EQUIP_CANCEL = /<(?:EQUIP_CANCEL|equip cancel):[ ](.*)>/i
      
    end
  end
  module EQUIP
    
    # 比較能力值處理
    COMP_PARAM_PROC = {
      :maxhp => Proc.new { |a, b| b.maxhp - a.maxhp },
      :maxmp => Proc.new { |a, b| b.maxmp - a.maxmp },
      :atk => Proc.new { |a, b| b.atk - a.atk },
      :def => Proc.new { |a, b| b.def - a.def },
      :spi => Proc.new { |a, b| b.spi - a.spi },
      :res => Proc.new { |a, b| b.res - a.res },
      :dex => Proc.new { |a, b| b.dex - a.dex },
      :agi => Proc.new { |a, b| b.agi - a.agi }, }
    # 取得能力值處理
    GET_PARAM_PROC = {
      :maxhp => Proc.new { |n| n.maxhp },
      :maxmp => Proc.new { |n| n.maxmp },
      :atk => Proc.new { |n| n.atk },
      :def => Proc.new { |n| n.def },
      :spi => Proc.new { |n| n.spi },
      :res => Proc.new { |n| n.res },
      :dex => Proc.new { |n| n.dex },
      :agi => Proc.new { |n| n.agi }, }
    
  end
end

#===============================================================================
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :maxhp
  attr_accessor :maxmp
  attr_accessor :atk
  attr_accessor :def
  attr_accessor :spi
  attr_accessor :agi
  attr_accessor :hit
  attr_accessor :eva
  attr_accessor :cri
  attr_accessor :odds
  attr_accessor :stat_per
  attr_accessor :traits
  attr_accessor :autostates
  attr_accessor :apt_growth
  attr_accessor :requirements
  attr_accessor :required_switches
  attr_accessor :req_variables_above
  attr_accessor :req_variables_under
  attr_accessor :req_weaponlvl_above
  attr_accessor :req_weaponlvl_under
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yem_cache_baseitem_eo
    return if @cached_baseitem_eo; @cached_baseitem_eo = true
    @maxhp = 0; @maxmp = 0; @cri = 0; @odds = 0
    @hit = 0 if @hit == nil; @eva = 0 if @eva == nil
    @stat_per ={ :hp => 0, :mp => 0, :atk => 0, :def => 0, :spi => 0,
      :agi => 0, :hit => 0, :eva => 0, :cri => 0, :odds => 0}
    @autostates = []; @apt_growth = {}; @traits = []
    @requirements = {}; @required_switches = []
    @req_variables_above = {}; @req_variables_under = {}
    @req_weaponlvl_above = {}; @req_weaponlvl_under = {}
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEM::REGEXP::BASEITEM::TRAITS
        case $1.upcase
        when "SUPER GUARD", "SUPER_GUARD", "SUPERGUARD"
          @traits.push(:super_guard)
        when "PHARMACOLOGY", "PHARMA", "ITEM BOOST", "ITEM_BOOST"
          @traits.push(:pharmacology)
        when "FAST ATTACK", "FAST_ATTACK", "FASTATTACK"
          @traits.push(:fast_attack)
        when "DUAL ATTACK", "DUALATTACK", "DUAL_ATTACK"
          @traits.push(:dual_attack)
        when "PREVENT_CRITICAL", "PREVENT CRITICAL", "PREVENT CRI"
          @traits.push(:prevent_critical)
        when "HALF MP COST", "HALF_MP_COST", "HALF MP", "HALF_MP", "HALFMP"
          @traits.push(:half_mp_cost)
        when "DOUBLE EXP GAIN", "DOUBLE_EXP_GAIN", "DOUBLE EXP", "DOUBLE_EXP"
          @traits.push(:double_exp_gain)
        when "AUTO_HP_RECOVER", "AUTO HP RECOVER", "AUTO HP", "AUTO_HP"
          @traits.push(:auto_hp_recover)
        when "ANTI HP REGEN", "ANTI_HP_REGEN"
          @traits.push(:anti_hp_regen)
        when "ANTI HP DEGEN", "ANTI_HP_DEGEN"
          @traits.push(:anti_hp_degen)
        when "ANTI MP REGEN", "ANTI_MP_REGEN"
          @traits.push(:anti_mp_regen)
        when "ANTI MP DEGEN", "ANTI_MP_DEGEN"
          @traits.push(:anti_mp_degen)
        else; next
        end
      #---
      when YEM::REGEXP::BASEITEM::APT_GROWTH
        case $1.upcase
        when "HP","MAXHP"; @apt_growth[:hp] = $2.to_i
        when "MP","MAXMP"; @apt_growth[:mp] = $2.to_i
        when "ATK"; @apt_growth[:atk] = $2.to_i
        when "DEF"; @apt_growth[:def] = $2.to_i
        when "SPI"; @apt_growth[:spi] = $2.to_i
        when "RES"; @apt_growth[:res] = $2.to_i
        when "DEX"; @apt_growth[:dex] = $2.to_i
        when "AGI"; @apt_growth[:agi] = $2.to_i
        end
      #---
      when YEM::REGEXP::BASEITEM::AUTOSTATES
        $1.scan(/\d+/).each { |num| 
        @autostates.push(num.to_i) if num.to_i > 0 }
      #---
      when YEM::REGEXP::BASEITEM::REQ_SWITCH
        $1.scan(/\d+/).each { |num| 
        @required_switches.push(num.to_i) if num.to_i > 0 }
        @requirements["SWITCH"] = true
      #---
      when YEM::REGEXP::BASEITEM::REQ_STRING
        case $1.upcase
        when "VARIABLE", "VAR"
          text = "VARIABLE"
          case $3.upcase
          when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
            text += " ABOVE"
            @req_variables_above[$2.to_i] = $4.to_i
          when "UNDER", "BELOW", "AT MOST", "LESS THAN"
            text += " UNDER"
            @req_variables_under[$2.to_i] = $4.to_i
          else; next
          end
        when "WEAPON LEVEL", "MASTERY", "WEAPON LVL", "WLVL"
          text = "WEAPON LEVEL"
          case $3.upcase
          when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
            text += " ABOVE"
            @req_weaponlvl_above[$2.to_i] = $4.to_i
          when "UNDER", "BELOW", "AT MOST", "LESS THAN"
            text += " UNDER"
            @req_weaponlvl_under[$2.to_i] = $4.to_i
          else; next
          end
        else; next
        end
        @requirements[text] = true
      #---
      when YEM::REGEXP::BASEITEM::REQUIRE
        case $2.upcase
        when "ABOVE", "AT LEAST" "OVER", "GREATER THAN"
          text = "ABOVE"
        when "UNDER", "BELOW", "AT MOST", "LESS THAN"
          text = "UNDER"
        else; next
        end
        text += " "
        case $1.upcase
        when "LEVEL", "LV", "LVL"
          text += "LEVEL"
        when "HP", "MAXHP"
          text += "MAXHP"
        when "MP", "MAXMP", "SP", "MAXSP"
          text += "MAXMP"
        when "INT", "MAG"
          text += "INT"
        when "AGG", "AGGRO"
          text += "ODDS"
        when "ATK", "DEF", "SPI", "INT", "RES", "DEX", "AGI"
          next if $1.upcase == "DEX" and !$imported["DEX Stat"]
          next if $1.upcase == "RES" and !$imported["RES Stat"]
          text += $1.upcase
        when "HIT", "EVA", "CRI", "ODDS"
          text += $1.upcase
        else; next
        end
        @requirements[text] = $3.to_i
      #---
      when YEM::REGEXP::BASEITEM::STAT_SET
        case $1.upcase
        when "HP","MAXHP"; @maxhp = $2.to_i
        when "MP","MAXMP"; @maxmp = $2.to_i
        when "ATK"; @atk = $2.to_i
        when "DEF"; @def = $2.to_i
        when "SPI"; @spi = $2.to_i
        when "AGI"; @agi = $2.to_i
        when "HIT"; @hit = $2.to_i
        when "EVA"; @eva = $2.to_i
        when "CRI"; @cri = $2.to_i
        when "ODDS"; @odds = $2.to_i
        end
      #---
      when YEM::REGEXP::BASEITEM::STAT_PER
        case $1.upcase
        when "HP","MAXHP"; @stat_per[:hp] = $2.to_i
        when "MP","MAXMP"; @stat_per[:mp] = $2.to_i
        when "ATK"; @stat_per[:atk] = $2.to_i
        when "DEF"; @stat_per[:def] = $2.to_i
        when "SPI"; @stat_per[:spi] = $2.to_i
        when "AGI"; @stat_per[:agi] = $2.to_i
        when "HIT"; @stat_per[:hit] = $2.to_i
        when "EVA"; @stat_per[:eva] = $2.to_i
        when "CRI"; @stat_per[:cri] = $2.to_i
        when "ODDS"; @stat_per[:odds] = $2.to_i
        end
      #---
      end
    }
    @requirements["NONE"] = 0 if @requirements == {}
  end
  
  #--------------------------------------------------------------------------
  # 防崩潰相容方法
  #--------------------------------------------------------------------------
  unless $imported["DEX Stat"]; def dex; return 0; end; end
  unless $imported["RES Stat"]; def res; return 0; end; end
  
end

#===============================================================================
#===============================================================================

class RPG::Weapon < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :two_hand_text
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yem_cache_weapon_eo
    return if @cached_weapon_eo; @cached_weapon_eo = true
    @two_hand_text = YEM::EQUIP::VOCAB[:twohand]
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::BASEITEM::TWO_HAND
        @two_hand_text = $1.to_s
      end
    }
  end
  
end

#===============================================================================
#===============================================================================

class RPG::Armor < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :kind
  attr_accessor :equip_type
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yem_cache_armour_eo
    @equip_type = @kind
    for key in YEM::EQUIP::TYPE_RULES
      next if key[1][1] != @kind
      @equip_type = key[1][0].upcase
    end
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::BASEITEM::EQUIP_TYPE
        for key in YEM::EQUIP::TYPE_RULES
          next if key[1][0].upcase != $1.upcase
          @kind = key[1][1]; break
          @equip_type = $1.upcase
        end
      end
    }
  end
  
end
  
#===============================================================================
#===============================================================================

class RPG::State
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yem_cache_state_eo
    @equip_cancel = []
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::STATE::EQUIP_CANCEL
        text = $1.to_s
        @equip_cancel.push(text.upcase)
      end
    }
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_cancel
    yem_cache_state_eo if @equip_cancel == nil
    return @equip_cancel
  end
  
end

#===============================================================================
#===============================================================================

module Vocab
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.hit; return YEM::EQUIP::STAT_VOCAB[:hit]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.eva; return YEM::EQUIP::STAT_VOCAB[:eva]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.cri; return YEM::EQUIP::STAT_VOCAB[:cri]; end
    
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.odds; return YEM::EQUIP::STAT_VOCAB[:odds]; end
  
end

#===============================================================================
# module Icon
#===============================================================================
if !$imported["BattleEngineMelody"] and !$imported["IconModuleLibrary"]
module Icon
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.stat(actor, item); return 0; end
  
end
end

#===============================================================================
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias load_bt_database_eo load_bt_database unless $@
  def load_bt_database
    load_bt_database_eo
    load_eo_cache
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias load_database_eo load_database unless $@
  def load_database
    load_database_eo
    load_eo_cache
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def load_eo_cache
    groups = [$data_items, $data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj == nil
        obj.yem_cache_baseitem_eo if obj.is_a?(RPG::BaseItem)
        obj.yem_cache_weapon_eo if obj.is_a?(RPG::Weapon)
        obj.yem_cache_armour_eo if obj.is_a?(RPG::Armor)
      end
    end
  end
  
end

#===============================================================================
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :equip_last
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def aptitude_items
    return @aptitude_items if @aptitude_items != nil
    @aptitude_items = []
    for item in $data_items
      next if item == nil
      next if item.apt_growth == {}
      @aptitude_items.push(item)
    end
    return @aptitude_items
  end
  
end
  
#===============================================================================
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias states_eo states unless $@
  def states
    list = states_eo
    list += equip_autostates if actor?
    list.uniq.sort! { |state_a,state_b|
      if state_a.priority != state_b.priority
        state_b.priority <=> state_a.priority
      else
        state_a.id <=> state_b.id
      end }
    return list.uniq
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias item_test_eo item_test unless $@
  def item_test(user, item)
    return true if item.apt_growth != {}
    return item_test_eo(user, item)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias item_growth_effect_eo item_growth_effect unless $@
  def item_growth_effect(user, item)
    if item.apt_growth != {} and actor?
      create_aptitude_bonus
      for key in item.apt_growth
        type = key[0]; value = key[1]
        case type
        when :hp, :mp, :atk, :def, :spi, :res, :dex, :agi
          @bonus_apt[type] += value
        else; next
        end
      end
      purge_unequippable
    end
    item_growth_effect_eo(user, item)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  unless
  def traits
    return @cache_traits if @cache_traits != nil
    @cache_traits = []
    if actor?
      for equip in equips.compact; @cache_traits |= equip.traits; end
    end
    return @cache_traits
  end
  end
  
end

#===============================================================================
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias setup_eo setup unless $@
  def setup(actor_id)
    setup_eo(actor_id)
    @extra_armor_id = []
    @locked_equips = []
    @equip_type = nil
    @bonus_apt = nil
    create_aptitude_bonus
    purge_unequippable
  end

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------

  def base_maxhp
  # 使用 @actor_id 來獲取角色 ID
  actor_id = @actor_id
  level = @level#@level # 角色等級

  # 從數據庫獲取角色的種族值 (基礎值)
  base_value = $data_actors[actor_id].parameters[0, 1]
  iv = 31 # 固定個體值

  # VX 版寶可夢 HP 成長公式
  n = ((2 * base_value + iv) * level / 100.0) + level + 10


  # 考慮裝備影響
  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:hp], :hp)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.maxhp, :hp)
  end

  # 被動技能影響
  n += base_maxhp_KGC_PassiveSkill + passive_params[:maxhp]
  n = n * passive_params_rate[:maxhp] / 100


  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def base_maxmp
  actor_id = @actor_id
  level = @level
  base_value = $data_actors[actor_id].parameters[1, 1]
  iv = 31

  n = ((2 * base_value + iv) * level / 100.0) + level + 10

  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:mp], :mp)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.maxmp, :mp)
  end

  n += base_maxmp_KGC_PassiveSkill + passive_params[:maxmp]
  n = n * passive_params_rate[:maxmp] / 100

  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def base_atk
  actor_id = @actor_id
  level = @level
  base_value = $data_actors[actor_id].parameters[2, 1]
  iv = 31

  n = ((2 * base_value + iv) * level / 100.0) + level + 5

  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:atk], :atk)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.atk, :atk)
  end

  n += base_atk_KGC_PassiveSkill + passive_params[:atk]
  n = n * passive_params_rate[:atk] / 100

  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def base_def
  actor_id = @actor_id
  level = @level
  base_value = $data_actors[actor_id].parameters[3, 1]
  iv = 31

  n = ((2 * base_value + iv) * level / 100.0) + level + 5

  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:def], :def)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.def, :def)
  end

  n += base_def_KGC_PassiveSkill + passive_params[:def]
  n = n * passive_params_rate[:def] / 100

  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def base_spi
  actor_id = @actor_id
  level = @level
  base_value = $data_actors[actor_id].parameters[4, 1]
  iv = 31

  n = ((2 * base_value + iv) * level / 100.0) + level + 5

  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:spi], :spi)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.spi, :spi)
  end

  n += base_spi_KGC_PassiveSkill + passive_params[:spi]
  n = n * passive_params_rate[:spi] / 100

  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def base_agi
  actor_id = @actor_id
  level = @level
  base_value = $data_actors[actor_id].parameters[5, 1]
  iv = 31

  n = ((2 * base_value + iv) * level / 100.0) + level + 5

  percent = 100
  for item in equips.compact
    percent += aptitude(item.stat_per[:agi], :agi)
  end
  n *= percent / 100.0
  for item in equips.compact
    n += aptitude(item.agi, :agi)
  end

  n += base_agi_KGC_PassiveSkill + passive_params[:agi]
  n = n * passive_params_rate[:agi] / 100

  return Integer(n)
end

  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def hit
    n = eval(YEM::EQUIP::BASE_STAT[:hit])
    #  n1 = weapons[0] == nil ? n : weapons[0].hit
    #  n2 = weapons[1] == nil ? n : weapons[1].hit
    #  n = [n1, n2].min
    #  n = weapons[0] == nil ? n : weapons[0].hit
    #end
    #############
    percent = 100
    for item in armors.compact
      percent += item.stat_per[:hit]
    end
    n *= percent / 100.0#
    for item in equips.compact
      n += item.hit
    end
    n = hit_KGC_PassiveSkill + passive_params[:hit]
    n = n * passive_params_rate[:hit] / 100
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def eva
    n = eval(YEM::EQUIP::BASE_STAT[:eva])
    for item in equips.compact
      n += item.eva
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:eva]
    end
    n *= percent / 100.0
    n = eva_KGC_PassiveSkill + passive_params[:eva]
    n = n * passive_params_rate[:eva] / 100
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cri
    n = eval(YEM::EQUIP::BASE_STAT[:cri])
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:cri]
    end
    n *= percent / 100.0
    for item in equips.compact
      n += item.cri
    end
    # FS CoreSafe v1.2：page330 是最終 CRI Authority。
    # KGC PassiveSkill 的 cri 實作除了 passive_params[:cri] 外，CRITICAL_BONUS
    # 還有固定 +4；本頁過去重寫 cri 時只接回 passive_params，造成 effect flag
    # 雖然正確啟用，最終 cri 卻沒有 +4。Phase42F 實機已證實此 load-order 缺口。
    n = cri_KGC_PassiveSkill + passive_params[:cri]
    n = n * passive_params_rate[:cri] / 100
    n += 4 if passive_effects[:critical_bonus]
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def odds
    n = $imported["AggroAI"] ? base_aggro : eval(YEM::EQUIP::BASE_STAT[:odds])
    for item in equips.compact
      n += item.odds
    end
    percent = 100
    for item in equips.compact
      percent += item.stat_per[:odds]
    end
    n *= percent / 100.0
    n = odds_KGC_PassiveSkill + passive_params[:odds]
    n = n * passive_params_rate[:odds] / 100
    return [Integer(n), 1].max
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def aptitude(n, type)
    return n unless YEM::EQUIP::USE_APTITUDE_SYSTEM
    multiplier = aptitude_rate(type)
    n = n * multiplier / 100
    return n
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def aptitude_rate(type)
    if YEM::EQUIP::APTITUDE.include?(@class_id)
      array = YEM::EQUIP::APTITUDE[@class_id]
    else
      array = YEM::EQUIP::APTITUDE[0]
    end
    type = :hp if type == :maxhp
    type = :mp if type == :maxmp
    create_aptitude_bonus
    multiplier = 0
    case type
    when :hp;  multiplier = array[0]
    when :mp;  multiplier = array[1]
    when :atk; multiplier = array[2]
    when :def; multiplier = array[3]
    when :spi; multiplier = array[4]
    when :res; multiplier = array[5]
    when :dex; multiplier = array[6]
    when :agi; multiplier = array[7]
    end
    multiplier += @bonus_apt[type]
    multiplier = [multiplier, YEM::EQUIP::MINIMUM_APTITUDE].max
    multiplier = [multiplier, YEM::EQUIP::MAXIMUM_APTITUDE].min
    return multiplier
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def reset_aptitudes
    @bonus_apt = nil
    create_aptitude_bonus
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_aptitude_bonus
    @bonus_apt = {} if @bonus_apt == nil
    @bonus_apt[:hp]  = 0 if @bonus_apt[:hp] == nil
    @bonus_apt[:mp]  = 0 if @bonus_apt[:mp] == nil
    @bonus_apt[:atk] = 0 if @bonus_apt[:atk] == nil
    @bonus_apt[:def] = 0 if @bonus_apt[:def] == nil
    @bonus_apt[:spi] = 0 if @bonus_apt[:spi] == nil
    @bonus_apt[:res] = 0 if @bonus_apt[:res] == nil
    @bonus_apt[:dex] = 0 if @bonus_apt[:dex] == nil
    @bonus_apt[:agi] = 0 if @bonus_apt[:agi] == nil
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_type
    unless @equip_type.is_a?(Array)
      @equip_type = YEM::EQUIP::TYPE_LIST.clone
    end

    # 舊存檔若曾直接指向全域 TYPE_LIST，必須切開共用參照。
    if @equip_type.equal?(YEM::EQUIP::TYPE_LIST)
      @equip_type = @equip_type.clone
    end

    return @equip_type
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_type=(array)
    if array == nil
      @equip_type = YEM::EQUIP::TYPE_LIST.clone
      purge_unequippable
      return
    end

    return unless array.is_a?(Array)

    new_types = array.clone
    new_types.delete(:weapon)
    new_types.delete_if { |type| !YEM::EQUIP::TYPE_RULES.has_key?(type) }

    old_types = equip_type.clone

    # 裝備欄 index 0 是武器；若 armor type 數量縮小，
    # 只卸下真正被移除的 armor slot，避免原版 off-by-one。
    if old_types.size > new_types.size
      first_removed_slot = new_types.size + 1
      for slot in first_removed_slot..old_types.size
        change_equip(slot, nil)
      end
    end

    @equip_type = new_types
    purge_unequippable
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def add_equip_type(type)
    return unless YEM::EQUIP::TYPE_RULES.has_key?(type)
    return if type == :weapon

    current = equip_type
    current.push(type)
    purge_unequippable
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def delete_last_equip_type
    current = equip_type
    return if current.size <= 0

    last_slot = current.size
    change_equip(last_slot, nil)
    current.pop
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def armor_number
    return equip_type.size
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def extra_armor_number
    return [armor_number - 4, 0].max
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def extra_armor_id
    @extra_armor_id = [] if @extra_armor_id == nil
    return @extra_armor_id
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias armors_eo armors unless $@
  def armors
    result = armors_eo
    extra_armor_number.times { |i|
      armor_id = extra_armor_id[i]
      result.push(armor_id == nil ? nil : $data_armors[armor_id]) }
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias change_equip_eo change_equip unless $@
  def change_equip(equip_type, item, test = false)
    change_equip_eo(equip_type, item, test)
    if extra_armor_number > 0
      item_id = item == nil ? 0 : item.id
      case equip_type
      when 5..armor_number
        @extra_armor_id = [] if @extra_armor_id == nil
        @extra_armor_id[equip_type - 5] = item_id
      end
    end
    purge_unequippable(test) unless @purge_on
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias equippable_eo equippable? unless $@
  def equippable?(item)
    return false unless equippable_eo(item)
    for key in item.requirements
      requirement = key[0]; value = key[1]
      case requirement
      when "NONE"; break
      #---
      when "ABOVE LEVEL"; return false unless self.level >= value
      when "ABOVE MAXHP"; return false unless self.maxhp >= value
      when "ABOVE MAXMP"; return false unless self.maxmp >= value
      when "ABOVE ATK";   return false unless self.atk >= value
      when "ABOVE DEF";   return false unless self.def >= value
      when "ABOVE SPI";   return false unless self.spi >= value
      when "ABOVE RES";   return false unless self.res >= value
      when "ABOVE DEX";   return false unless self.dex >= value
      when "ABOVE AGI";   return false unless self.agi >= value
      when "ABOVE HIT";   return false unless self.hit >= value
      when "ABOVE EVA";   return false unless self.eva >= value
      when "ABOVE DUR";   return false unless self.max_dur >= value
      when "ABOVE LUK";   return false unless self.luk >= value
      when "ABOVE CRI";   return false unless self.cri >= value
      when "ABOVE ODDS";  return false unless self.odds >= value
      #---
      when "UNDER LEVEL"; return false unless self.level <= value
      when "UNDER MAXHP"; return false unless self.maxhp <= value
      when "UNDER MAXMP"; return false unless self.maxmp <= value
      when "UNDER ATK";   return false unless self.atk <= value
      when "UNDER DEF";   return false unless self.def <= value
      when "UNDER SPI";   return false unless self.spi <= value
      when "UNDER RES";   return false unless self.res <= value
      when "UNDER DEX";   return false unless self.dex <= value
      when "UNDER AGI";   return false unless self.agi <= value
      when "UNDER HIT";   return false unless self.hit <= value
      when "UNDER EVA";   return false unless self.eva <= value
      when "UNDER DUR";   return false unless self.max_dur <= value
      when "UNDER LUK";   return false unless self.luk <= value
      when "UNDER CRI";   return false unless self.cri <= value
      when "UNDER ODDS";  return false unless self.odds <= value
      #---
      when "SWITCH"
        for switch_id in item.required_switches
          return false unless $game_switches[switch_id]
        end
      #---
      when "VARIABLE ABOVE"
        for key in item.req_variables_above
          variable = key[0]; variable_value = key[1]
          return false unless $game_variables[variable] >= variable_value
        end
      when "VARIABLE UNDER"
        for key in item.req_variables_under
          variable = key[0]; variable_value = key[1]
          return false unless $game_variables[variable] <= variable_value
        end
      #---
      end
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def purge_unequippable(test = false)
    return if $game_temp.in_battle

    @purge_on = true
    begin
      max_slot = armor_number

      for slot in 0..max_slot
        item = equips[slot]
        next if item == nil

        unless equippable?(item)
          change_equip(slot, nil, test)
          next
        end

        next unless item.is_a?(RPG::Armor)

        type = equip_type[slot - 1]
        rule = YEM::EQUIP::TYPE_RULES[type]

        if rule == nil || item.kind != rule[1]
          change_equip(slot, nil, test)
        end
      end
    ensure
      @purge_on = false
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias discard_equip_eo discard_equip unless $@
  def discard_equip(item)
    last_weapon = @weapon_id
    last_armours = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    discard_equip_eo(item)
    current_weapon = @weapon_id
    current_armours = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]

    # FS CoreSafe v1.7：沿用 Phase44A Weapon/Armor final convergence，並由 Phase44K
    # 將 Teaching 段改為 deferred transaction；VX base discard 對主武器
    # 會改 @weapon_id；Two Swords Style 的第二武器則可能存於 @armor1_id，因此
    # Weapon 判定必須同時觀察 weapon 與 armor1..armor4 的前後狀態。
    #
    # Armor 規則沿用 v1.5：一般欄已被底層移除時不再掃 extra slot；只有一般欄
    # 無變化時才嘗試移除 YEM extra Armor。Weapon 永遠不掃 extra Armor。
    # 所有成功路徑最後都只執行一次 Teaching → Passive → Combo。
    removed_standard = false
    if item.is_a?(RPG::Weapon)
      removed_standard = (last_weapon != current_weapon || last_armours != current_armours)
    elsif item.is_a?(RPG::Armor)
      removed_standard = (last_armours != current_armours)
    else
      return nil
    end

    removed_extra = false
    result = nil
    if item.is_a?(RPG::Armor) && !removed_standard
      result = extra_armor_number.times { |i|
        if extra_armor_id[i] == item.id
          @extra_armor_id[i] = 0
          removed_extra = true
          break
        end }
    end

    if removed_standard || removed_extra
      if respond_to?(:albert_refresh_equipment_teaching_skills_deferred)
        albert_refresh_equipment_teaching_skills_deferred
      elsif respond_to?(:albert_refresh_equipment_teaching_skills)
        albert_refresh_equipment_teaching_skills
      end
      if respond_to?(:albert_refresh_equipment_passive_skills)
        albert_refresh_equipment_passive_skills
      elsif respond_to?(:restore_passive_rev)
        restore_passive_rev
      end
      if respond_to?(:albert_refresh_combo_actor_states)
        albert_refresh_combo_actor_states
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias class_id_eo class_id= unless $@
  def class_id=(class_id)
    class_id_eo(class_id)
    return if extra_armor_number == 0
    for i in 5..armor_number
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def restore_equip
    return if @last_equip_type == equip_type
    last_equips = equips
    last_hp = self.hp
    last_mp = self.mp
    last_equips.each_index { |i| change_equip(i, nil) }
    last_equips.compact.each { |item| equip_legal_slot(item) }
    self.hp = last_hp
    self.mp = last_mp
    @last_equip_type = equip_type.clone
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_legal_slot(item)
    return if item == nil

    if item.is_a?(RPG::Weapon)
      if @weapon_id == 0
        change_equip(0, item)
      elsif two_swords_style && @armor1_id == 0
        change_equip(1, item)
      end
      return
    end

    return unless item.is_a?(RPG::Armor)

    # 先處理原生第一防具欄（非二刀流）。
    first_type = equip_type[0]
    first_rule = YEM::EQUIP::TYPE_RULES[first_type]

    if !two_swords_style &&
       first_rule != nil &&
       item.kind == first_rule[1] &&
       @armor1_id == 0
      change_equip(1, item)
      return
    end

    # slot 1 在二刀流時保留給副武器，因此用 -1 阻止防具塞入。
    slot_ids = [-1, @armor2_id, @armor3_id, @armor4_id]
    slot_ids += extra_armor_id

    equip_type.each_with_index do |slot_type, index|
      rule = YEM::EQUIP::TYPE_RULES[slot_type]
      next if rule == nil
      next unless rule[1] == item.kind

      current_id = slot_ids[index]
      next unless current_id == nil || current_id == 0

      change_equip(index + 1, item)
      break
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias super_guard_eo super_guard unless $@
  def super_guard
    return true if traits.include?(:super_guard)
    return super_guard_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias pharmacology_eo pharmacology unless $@
  def pharmacology
    return true if traits.include?(:pharmacology)
    return pharmacology_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias fast_attack_eo fast_attack unless $@
  def fast_attack
    return true if traits.include?(:fast_attack)
    return fast_attack_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias dual_attack_eo dual_attack unless $@
  def dual_attack
    return true if traits.include?(:dual_attack)
    return dual_attack_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias prevent_critical_eo prevent_critical unless $@
  def prevent_critical
    return true if traits.include?(:prevent_critical)
    return prevent_critical_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias half_mp_cost_eo half_mp_cost unless $@
  def half_mp_cost
    return true if traits.include?(:half_mp_cost)
    return half_mp_cost_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias double_exp_gain_eo double_exp_gain unless $@
  def double_exp_gain
    return true if traits.include?(:double_exp_gain)
    return double_exp_gain_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias auto_hp_recover_eo auto_hp_recover unless $@
  def auto_hp_recover
    return true if traits.include?(:auto_hp_recover)
    return auto_hp_recover_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_autostates
    result = []
    for equip in equips.compact
      for state_id in equip.autostates
        state = $data_states[state_id]
        next if state == nil
        result.push(state)
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def locked_equips
    @locked_equips = [] if @locked_equips == nil
    return @locked_equips
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def lock_equip(slot)
    @locked_equips = [] if @locked_equips == nil
    @locked_equips += [slot]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def unlock_equip(slot)
    @locked_equips = [] if @locked_equips == nil
    @locked_equips -= [slot]
  end
  
end

#===============================================================================
#===============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def items_only
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_weapons
    result = []
    for i in @weapons.keys.sort
      result.push($data_weapons[i]) if @weapons[i] > 0
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_armours(type = nil)
    result = []
    for i in @armors.keys.sort
      armour = $data_armors[i]
      result.push(armour) if @armors[i] > 0
    end
    return result
  end
  
end

#===============================================================================
#===============================================================================

class Window_Command_Centered < Window_Command
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
end

#===============================================================================
#===============================================================================

class Window_ShopStatus < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, 200, WLH, actor.name)
    draw_actor_graphic(actor, x+50, y+27) if enabled
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
      item = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
      item = nil
    else
      item1 = actor.equips[1 + @item.kind]
      item  = actor.equips[1 + @item.kind]
    end
    if enabled
      if @item.is_a?(RPG::Weapon)
       self.contents.font.color = system_color
       self.contents.draw_text(-93, 30, 200, WLH, "攻擊", 2)
       self.contents.draw_text(-57, 30, 200, WLH, "意志", 2)
       self.contents.draw_text(-21, 30, 200, WLH, "爆擊", 2)
       self.contents.draw_text( 15, 30, 200, WLH, "命中", 2)
       self.contents.draw_text( 51, 30, 200, WLH, "閃躲", 2)
       self.contents.draw_text( 87, 30, 200, WLH, "生命", 2)
       self.contents.draw_text(123, 30, 200, WLH, "魔力", 2)
      else 
       self.contents.font.color = system_color
       self.contents.draw_text(-93, 30, 200, WLH, "防禦", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text(-57, 30, 200, WLH, "敏捷", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text(-21, 30, 200, WLH, "爆擊", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text( 15, 30, 200, WLH, "命中", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text( 51, 30, 200, WLH, "閃躲", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text( 87, 30, 200, WLH, "生命", 2) if @item.is_a?(RPG::Armor)
       self.contents.draw_text(123, 30, 200, WLH, "魔力", 2) if @item.is_a?(RPG::Armor)
      end
      if @item.is_a?(RPG::Weapon)
        hp1 = item1 == nil ? 0 : actor.aptitude(item1.maxhp, :maxhp)
        hp2 = @item == nil ? 0 : actor.aptitude(@item.maxhp, :maxhp)
        hpchange = hp2 - hp1
        mp1 = item1 == nil ? 0 : actor.aptitude(item1.maxmp, :maxmp)
        mp2 = @item == nil ? 0 : actor.aptitude(@item.maxmp, :maxmp)
        mpchange = mp2 - mp1
        atk1 = item1 == nil ? 0 : actor.aptitude(item1.atk, :atk)
        atk2 = @item == nil ? 0 : actor.aptitude(@item.atk, :atk)
        spi1 = item1 == nil ? 0 : actor.aptitude(item1.spi, :spi)
        spi2 = @item == nil ? 0 : actor.aptitude(@item.spi, :spi)
        spichange = spi2 - spi1
        atkchange = atk2 - atk1
        cri1 = item1 == nil ? 0 : actor.aptitude(item1.cri, :cri)
        cri2 = @item == nil ? 0 : actor.aptitude(@item.cri, :cri)
        crichange = cri2 - cri1
        hit1 = item1 == nil ? 0 : actor.aptitude(item1.hit, :hit)
        hit2 = @item == nil ? 0 : actor.aptitude(@item.hit, :hit)
        hitchange = hit2 - hit1
        eva1 = item1 == nil ? 0 : actor.aptitude(item1.eva, :eva)
        eva2 = @item == nil ? 0 : actor.aptitude(@item.eva, :eva)
        evachange = eva2 - eva1

        change = atk2 - atk1
      else
        def1 = item1 == nil ? 0 : actor.aptitude(item1.def, :def)
        def2 = @item == nil ? 0 : actor.aptitude(@item.def, :def)
        agi1 = item1 == nil ? 0 : actor.aptitude(item1.agi, :agi)
        agi2 = @item == nil ? 0 : actor.aptitude(@item.agi, :agi)
        agichange = agi2 - agi1
        defchange = def2 - def1
        cri1 = item1 == nil ? 0 : actor.aptitude(item1.cri, :cri)
        cri2 = @item == nil ? 0 : actor.aptitude(@item.cri, :cri)
        crichange = cri2 - cri1
        hit1 = item1 == nil ? 0 : actor.aptitude(item1.hit, :hit)
        hit2 = @item == nil ? 0 : actor.aptitude(@item.hit, :hit)
        hitchange = hit2 - hit1
        eva1 = item1 == nil ? 0 : actor.aptitude(item1.eva, :eva)
        eva2 = @item == nil ? 0 : actor.aptitude(@item.eva, :eva)
        evachange = eva2 - eva1
        hp1 = item1 == nil ? 0 : actor.aptitude(item1.maxhp, :maxhp)
        hp2 = @item == nil ? 0 : actor.aptitude(@item.maxhp, :maxhp)
        hpchange = hp2 - hp1
        mp1 = item1 == nil ? 0 : actor.aptitude(item1.maxmp, :maxmp)
        mp2 = @item == nil ? 0 : actor.aptitude(@item.maxmp, :maxmp)
        mpchange = mp2 - mp1
        
        change = def2 - def1
      end
      self.contents.font.size = 16
      self.contents.font.color = normal_color
#      self.contents.font.color = text_color(10) if def2 - def1 > 0
#      self.contents.font.color = text_color(10) if hpchange < 0
#      self.contents.font.color = text_color(10) if mpchange < 0
#      self.contents.font.color = text_color(10) if atkchange < 0
#      self.contents.font.color = text_color(10) if defchange < 0
#      self.contents.font.color = text_color(10) if agichange < 0
#      self.contents.font.color = text_color(10) if spichange < 0
#      self.contents.font.color = text_color(10) if crichange < 0
#      self.contents.font.color = text_color(10) if hitchange < 0
#      self.contents.font.color = text_color(10) if evachange < 0
      
      self.contents.draw_text(x-97,  y-35, 200, 100, sprintf("%+d", atkchange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x-61,  y-35, 200, 100, sprintf("%+d", spichange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x-25,  y-35, 200, 100, sprintf("%+d", crichange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x+11,  y-35, 200, 100, sprintf("%+d", hitchange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x+47,  y-35, 200, 100, sprintf("%+d", evachange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x+83,  y-35, 200, 100, sprintf("%+d", hpchange), 2) if @item.is_a?(RPG::Weapon)
      self.contents.draw_text(x+119, y-35, 200, 100, sprintf("%+d", mpchange), 2) if @item.is_a?(RPG::Weapon)

      self.contents.draw_text(x-97,  y-35, 200, 100, sprintf("%+d", defchange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x-61,  y-35, 200, 100, sprintf("%+d", agichange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x-25,  y-35, 200, 100, sprintf("%+d", crichange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x+11,  y-35, 200, 100, sprintf("%+d", hitchange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x+47,  y-35, 200, 100, sprintf("%+d", evachange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x+83,  y-35, 200, 100, sprintf("%+d", hpchange), 2) if @item.is_a?(RPG::Armor)
      self.contents.draw_text(x+119, y-35, 200, 100, sprintf("%+d", mpchange), 2) if @item.is_a?(RPG::Armor)      
      
      #self.contents.font.size = 16
      #self.contents.draw_text(x-25, y, 200, WLH, sprintf("命中率%+d", hit), 2)
    end
    #draw_item_name(item, x, y + WLH, enabled)
  end
  
end

#===============================================================================
#===============================================================================

class Window_Equip_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, Graphics.width - 160, 128)
    @actor = actor
    refresh(0)
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh($scene.equip_window.index)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(type = nil)
    self.contents.clear
    @type = type
    draw_actor_face(@actor, 0, 0, size = 96)
    x = 104
    y = 0
    self.contents.font.color = normal_color
    draw_actor_name(@actor, x, y)
    #draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH)
    draw_actor_autostate(@actor, x + 120, y + WLH)
    return if @type == nil
    self.contents.font.color = system_color
    if @type == 0 and @actor.weapons[0] != nil and @actor.weapons[0].two_handed
      text = @actor.weapons[0].two_hand_text
    elsif @type == 0
      text = YEM::EQUIP::TYPE_RULES[:weapon][0]
    elsif @type == 1 and @actor.two_swords_style
      text = YEM::EQUIP::TYPE_RULES[:weapon][0]
    else
      type = @actor.equip_type[@type-1]
      return if YEM::EQUIP::TYPE_RULES[type] == nil
      text = YEM::EQUIP::TYPE_RULES[type][0]
    end
    self.contents.draw_text(x, y + WLH*2, 76, WLH, text, 0)
    self.contents.draw_text(x, y + WLH*3, 20, WLH, "•", 1)
    self.contents.font.color = normal_color
    item = @actor.equips[@type]
    if item == nil
      text = YEM::EQUIP::VOCAB[:noequip]
      self.contents.font.color.alpha = 128
      self.contents.draw_text(x+20, y + WLH*3, 196, WLH, text)
    else
      category = get_category(item)
      return if category == :none   
      $game_party.nitems[category][item.id] = true
      draw_item_name10(item, x+20, y + WLH*3)
    end
  end
  ##################
  def get_category(item)
    if item.is_a?(RPG::Item)
      return :item
    elsif item.is_a?(RPG::Weapon)
      return :weapon
    elsif item.is_a?(RPG::Armor)
      return :armor
    else
      return :none
    end
  end
  ##################
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_autostate(actor, x, y, width = 96)
    count = 0
    for state in actor.equip_autostates
      next if state.icon_index == 0
      next if $imported["CoreFixesUpgradesMelody"] and state.hide_state
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  
end

#===============================================================================
#===============================================================================

class Window_Equip < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, Graphics.width - 240, Graphics.height - y)
    self.active = false
    self.index = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    @data = @actor.equips.clone
    @item_max = (@actor.equip_type.size+1)
    self.index = [@item_max-1, self.index].min
    create_contents
    self.contents.font.color = system_color
    draw_equipment_category
    draw_equipment_items
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_equipment_category
    self.contents.font.size = YEM::EQUIP::CATEGORY_FONT_SIZE
    dy = 0
    for i in 0..(@actor.equip_type.size)
      self.contents.font.color = system_color
      if i == 0 and @actor.weapons[0] != nil and @actor.weapons[0].two_handed
        text = @actor.weapons[0].two_hand_text
      elsif i == 0
        text = YEM::EQUIP::TYPE_RULES[:weapon][0]
      elsif i == 1 and @actor.two_swords_style
        text = YEM::EQUIP::TYPE_RULES[:weapon][0]
      else
        type = @actor.equip_type[i-1]
        text = YEM::EQUIP::TYPE_RULES[type][0]
      end
      self.contents.draw_text(4, dy, 76, WLH, text, 1)
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_equipment_items
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color; dy = 0; dx = 76
    for i in 0..(@actor.equip_type.size)
      self.contents.font.color = normal_color
      item = @data[i]
      if item == nil
        text = YEM::EQUIP::VOCAB[:noequip]
        self.contents.font.color.alpha = 128
        self.contents.draw_text(dx+30, dy, 196, WLH, text)###
      else
        draw_item_name10(item, dx+30, dy)###
      end
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_changable?(index)
    if index == 0 or (index == 1 and @actor.two_swords_style)
      type = :weapon
    else
      type = @actor.equip_type[index-1]
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def equip_type
    if self.index == 0 or (self.index == 1 and @actor.two_swords_style)
      return :weapon
    else
      return @actor.equip_type[self.index-1]
    end
  end
  
end

#===============================================================================
#===============================================================================

class Window_Equip_Item < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(window, actor)
    super(window.x, window.y, window.width, window.height)
    self.active = false
    self.index = 0
    @actor = actor
    refresh(:weapon)
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(type, debug = false)
    debug = false unless $TEST
    @data = []; @type = type
    if @type == :weapon
      equips = $game_party.equip_weapons
      equips = $data_weapons if debug
    else
      equips = $game_party.equip_armours(@type)
      equips = $data_armors if debug
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2]
    for item in equips
      @data.push(item) if include?(item)
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2] and @data.size > 8
    @item_max = @data.size
    create_contents
    for i in 0..(@item_max-1); draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    case @type
    when :weapon
      return false unless item.is_a?(RPG::Weapon)
    else
      kind = YEM::EQUIP::TYPE_RULES[@type][1]
      return false unless item.kind == kind
    end
    return class_equippable?(item)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def class_equippable?(item)
    if item.is_a?(RPG::Weapon)
      class_set = @actor.class.weapon_set
    else
      class_set = @actor.class.armor_set
    end
    return class_set.include?(item.id)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if item == nil and YEM::EQUIP::TYPE_RULES[@type][2]
    return false if $game_party.item_number(item) <= 0
    @equippables = {} if @equippables == nil
    @equippables[item] = @actor.equippable?(item) if @equippables[item] == nil
    return @equippables[item]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    item = @data[index]
    if item == nil
      draw_icon(YEM::EQUIP::UNEQUIP_ICON, rect.x, rect.y)
      text = YEM::EQUIP::VOCAB[:unequip]
      self.contents.draw_text(rect.x + 24, rect.y, 172, WLH, text)
      return
    end
    number = $game_party.item_number(item)
    enabled = enable?(item)
    rect.width -= 4
    draw_item_name(item, rect.x, rect.y, enabled)
    if $imported["BattleEngineMelody"]
      self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:size]
      colour = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:colour]
      self.contents.font.color = text_color(colour)
      sprint = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:text]
    else
      sprint = YEM::EQUIP::VOCAB[:amount]
    end
    self.contents.draw_text(rect, sprintf(sprint, number),2)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end


#===============================================================================
#===============================================================================

class Window_Equip_Item_mini < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(window, actor)
    super(window.x, window.y, window.width, window.height)
    self.active = false
    self.index = 0
    @actor = actor
    refresh(:weapon)
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(type, debug = false)
    debug = false unless $TEST
    @data = []; @type = type
    if @type == :weapon
      equips = $game_party.equip_weapons
      equips = $data_weapons if debug
    else
      equips = $game_party.equip_armours(@type)
      equips = $data_armors if debug
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2]
    for item in equips
      @data.push(item) if include?(item)
    end
    @data += [nil] if YEM::EQUIP::TYPE_RULES[@type][2] and @data.size > 8
    @item_max = @data.size
    create_contents
    for i in 0..(@item_max-1); draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    case @type
    when :weapon
      return false unless item.is_a?(RPG::Weapon)
    else
      kind = YEM::EQUIP::TYPE_RULES[@type][1]
      return false unless item.kind == kind
    end
    return class_equippable?(item)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def class_equippable?(item)
    if item.is_a?(RPG::Weapon)
      class_set = @actor.class.weapon_set
    else
      class_set = @actor.class.armor_set
    end
    return class_set.include?(item.id)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if item == nil and YEM::EQUIP::TYPE_RULES[@type][2]
    return false if $game_party.item_number(item) <= 0
    @equippables = {} if @equippables == nil
    @equippables[item] = @actor.equippable?(item) if @equippables[item] == nil
    return @equippables[item]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    item = @data[index]
    if item == nil
      draw_icon(YEM::EQUIP::UNEQUIP_ICON, rect.x, rect.y)
      text = "可卸下裝備"
      self.contents.draw_text(rect.x + 24, rect.y, 172, WLH, text)
      return
    end
    number = $game_party.item_number(item)
    enabled = enable?(item)
    rect.width -= 4
    draw_item_name(item, rect.x, rect.y, enabled)
    if $imported["BattleEngineMelody"]
      self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:size]
      colour = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:colour]
      self.contents.font.color = text_color(colour)
      sprint = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:text]
    else
      sprint = YEM::EQUIP::VOCAB[:amount]
    end
    self.contents.draw_text(rect, sprintf(sprint, number),2)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #def update_help
  #  @help_window.set_text(item == nil ? "" : item.description)
  #end
  def update_cursor
    self.cursor_rect.empty
   # if @index < 0               # 無光標
   # elsif @index < @item_max    # 正常狀態
   # end
  end
end
#===============================================================================
#===============================================================================

class Window_EquipStat < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(window, actor)
    dx = window.x + window.width
    dy = window.y
    super(dx, dy, Graphics.width - dx, Graphics.height - dy)
    @actor = actor
    refresh
  end
  
  def summon_mode?
   @summon_mode
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_character_animation(character_name, character_index, x, y, direction = 0)
    return if character_name.nil?
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n % 4 * 3 + @frame) * cw, (n / 4 * 4 + direction) * ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(equip = nil, equip_index = nil)
    #return unless self.visible  # 只有視窗可見時才刷新，避免無意間清空畫面
    self.contents.clear
    @equip = equip; @equip_index = equip_index
    return if @equip_index == nil or (@equip != nil and 
      !@actor.equippable?(@equip))
    @clone = Marshal.load(Marshal.dump(@actor))
    @clone.change_equip(@equip_index, @equip, true)
    if ArmorMapping.mapping.include?(@equip.id)
      draw_summon_stats
    else
      draw_actor_stats
      draw_clone_stats
    end
    
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_summon_stats
    @summon_mode = true
    #actor_id = ArmorMapping::Mapping[@equip.id]
    actor_id = ArmorMapping.mapping[@equip.id]
    @summon = $game_actors[actor_id]
    @summon.setup(actor_id)  # 依據 $data_actors[actor_id] 重新初始化角色
    @summon.change_level(@summon.temp_level, false) if @summon.temp_level
    @summon.gain_exp(100 - @summon.temp_exp, false) if @summon.temp_exp
    @summon.recover_all
    contents.font.color = text_color(1)
    text = @summon.name
    contents.draw_text(0, 0, 50, 50, text, 0)
    contents.font.color = normal_color
    text = @summon.level
    contents.draw_text(30, 20, 50, 50, text, 0)
    text = "Lv"
    contents.draw_text(0, 20, 50, 50, text, 0)
    draw_actor_hp(@summon, 0, 50, 80)
    #draw_actor_mp(@summon, 0, 70, 80)
    draw_actor_mp_gauge(@summon, 0, 70, 80)
    text = @summon.maxmp
    contents.draw_text(30, 60, 50, 50, text, 2)
    contents.font.color = text_color(1)
    text = "攻擊"
    contents.draw_text(0, 90, 50, 50, text, 0)
    text = "防禦"
    contents.draw_text(0, 110, 50, 50, text, 0)
    text = "精神"
    contents.draw_text(0, 130, 50, 50, text, 0)
    text = "敏捷"
    contents.draw_text(0, 150, 50, 50, text, 0)
    contents.font.color = normal_color
    text = @summon.atk
    contents.draw_text(60, 90, 50, 50, text, 0)
    text = @summon.def
    contents.draw_text(60, 110, 50, 50, text, 0)
    text = @summon.spi
    contents.draw_text(60, 130, 50, 50, text, 0)
    text = @summon.agi
    contents.draw_text(60, 150, 50, 50, text, 0)
    draw_actor_face(@summon,100,10)
    draw_actor_graphic(@summon,180,50)
    # 用行走圖動畫方法來顯示召喚角色的圖像
    #draw_character_animation(@summon.character_name + "_1", 0, 150, 65, 0)
    
    
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_stats
    dx = 0; dy = 0
    arrow = YEM::EQUIP::VOCAB[:arrow]
    for stat in YEM::EQUIP::SHOWN_STATS
      icon = Icon.stat(@actor, stat)
      case stat
      when :maxhp
        text = Vocab.hp
        text2 = "生命"
        value = @actor.maxhp
      when :maxmp
          text = 0
          text2 = "魔力"
        case @actor.class_id
        when 1, 3, 8
          text2 = "魔力"
        when 2
          text2 = "魔力"
        when 4, 5, 6, 7
          text2 = "魔力"
        end
        value = @actor.maxmp
      when :atk
        text = Vocab.atk
        text2 = "攻擊"
        value = @actor.atk
      when :def
        text = Vocab.def
        text2 = "防禦"
        value = @actor.def
      when :spi
        text = Vocab.spi
        text2 = "精神"
        value = @actor.spi
      when :agi
        text = Vocab.agi
        text2 = "敏捷"
        value = @actor.agi
      when :dex
        next unless $imported["DEX Stat"]
        text = Vocab.dex
        value = @actor.dex
      when :res
        next unless $imported["RES Stat"]
        text = Vocab.res
        value = @actor.res
      when :hit
        text2 = "命中"
        value = [@actor.hit, 100].min
        value = sprintf("%d%%", value)
      when :eva
        text2 = "閃躲"
        value = [@actor.eva, 100].min
        value = sprintf("%d%%", value)
      when :cri
        text2 = "爆擊"
        value = [@actor.cri, 100].min
        value = sprintf("%d%%", value)
      when :odds
        text = Vocab.odds
        value = @actor.odds
      else; next
      end
      draw_icon(text.to_i, dx, dy)
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 60, WLH, text2, 0); dx += 60
      self.contents.font.color = normal_color
      self.contents.draw_text(dx, dy, 45, WLH, value, 2); dx += 45
      self.contents.font.color = system_color
      self.contents.font.size = Font.default_size
      self.contents.draw_text(dx, dy, 30, WLH, arrow, 1); dx += 30
      if @equip_index == nil or (@equip != nil and !@actor.equippable?(@equip))
        self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
        self.contents.font.color = normal_color
        self.contents.draw_text(dx, dy, 45, WLH, value, 2)
      end
      dx = 0; dy += WLH-4
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_clone_stats
    dx = 0; dy = 0
    last_hp = @actor.hp
    last_mp = @actor.mp
    for stat in YEM::EQUIP::SHOWN_STATS
      case stat
      when :maxhp
        value2 = @actor.maxhp
        value1 = @clone.maxhp
      when :maxmp
        value2 = @actor.maxmp
        value1 = @clone.maxmp
      when :atk
        value2 = @actor.atk
        value1 = @clone.atk
      when :def
        value2 = @actor.def
        value1 = @clone.def
      when :spi
        value2 = @actor.spi
        value1 = @clone.spi
      when :agi
        value2 = @actor.agi
        value1 = @clone.agi
      when :dex
        next unless $imported["DEX Stat"]
        value2 = @actor.dex
        value1 = @clone.dex
      when :res
        next unless $imported["RES Stat"]
        value2 = @actor.res
        value1 = @clone.res
      when :hit
        value2 = [@actor.hit, 100].min
        value1 = @clone.hit
      when :eva
        value2 = [@actor.eva, 100].min
        value1 = @clone.eva        
      when :cri
        value2 = [@actor.cri, 100].min
        value1 = @clone.cri        
      else; next
      end
      if value1 > value2
        self.contents.font.color = power_up_color
      elsif value1 < value2
        self.contents.font.color = power_down_color
      else
        self.contents.font.color = normal_color
      end
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      
      case stat
      when :hit, :eva, :cri
        self.contents.draw_text(dx+159, dy, 45, WLH, value1.to_s + "%", 2)      
      else
        self.contents.draw_text(dx+159, dy, 45, WLH, value1, 2)
      end
      
      dx = 0; dy += WLH-4
    end
    @actor.hp = last_hp
    @actor.mp = last_mp
  end
  
end

#===============================================================================
#===============================================================================

class Window_EquipApt < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(aptitude_window, actor)
    @aptitude_window = aptitude_window
    dx = @aptitude_window.x + @aptitude_window.width
    dy = @aptitude_window.y
    super(dx, dy, Graphics.width - dx, Graphics.height - dy)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item = @aptitude_window.item
    @item = nil if @item != nil and $game_party.item_number(@item) <= 0
    draw_actor_stats
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_stats
    dx = 0; dy = 0
    @actor.create_aptitude_bonus
    arrow = YEM::EQUIP::VOCAB[:arrow]
    for stat in YEM::EQUIP::SHOWN_STATS
      icon = Icon.stat(@actor, stat)
      case stat
      when :maxhp
        text = Vocab.hp
      when :maxmp
        text = Vocab.mp
      when :atk
        text = Vocab.atk
      when :def
        text = Vocab.def
      when :spi
        text = Vocab.spi
      when :agi
        text = Vocab.agi
      when :dex
        next unless $imported["DEX Stat"]
        text = Vocab.dex
      when :res
        next unless $imported["RES Stat"]
        text = Vocab.res
      else; next
      end
      value = @actor.aptitude_rate(stat)
      if @item != nil
        stat = :hp if stat == :maxhp
        stat = :mp if stat == :maxmp
        value += @item.apt_growth[stat] if @item.apt_growth[stat] != nil
        value = [value, YEM::EQUIP::MINIMUM_APTITUDE].max
        value = [value, YEM::EQUIP::MAXIMUM_APTITUDE].min
      end
      draw_icon(icon, dx, dy); dx += 24
      text1 = sprintf(YEM::EQUIP::VOCAB[:apt_rate], text)
      text2 = sprintf("%d%%", value)
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 80, WLH, text1, 0); dx += 60
      self.contents.font.color = normal_color
      actor_stat = sprintf("%d%%", @actor.aptitude_rate(stat))
      self.contents.draw_text(dx, dy, 45, WLH, actor_stat, 2); dx += 45
      self.contents.font.size = Font.default_size
      self.contents.font.color = system_color
      self.contents.draw_text(dx, dy, 30, WLH, arrow, 1); dx += 30
      if value > @actor.aptitude_rate(stat)
        self.contents.font.color = power_up_color
      elsif value < @actor.aptitude_rate(stat)
        self.contents.font.color = power_down_color
      else
        self.contents.font.color = normal_color
      end
      self.contents.font.size = YEM::EQUIP::STAT_FONT_SIZE
      self.contents.draw_text(dx, dy, 45, WLH, text2, 2)
      dy += WLH
      dx = 0
    end
  end
  
end

#===============================================================================
#===============================================================================

class Window_Aptitude < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(help_window, actor)
    @help_window = help_window
    dy = @help_window.y + @help_window.height
    super(0, dy, Graphics.width - 240, Graphics.height - dy)
    self.active = false
    self.index = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(new_actor)
    @actor = new_actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    if YEM::EQUIP::SHOW_APT_BOOSTS
      @data = $game_temp.aptitude_items.clone
    else
      for item in $game_temp.aptitude_items
        next if item == nil
        next unless $game_party.item_number(item) > 0
        @data.push(item)
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0..(@item_max-1); draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item.apt_growth == {}
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if $game_party.item_number(item) <= 0
    changes = false
    max_apt = YEM::EQUIP::MAXIMUM_APTITUDE
    min_apt = YEM::EQUIP::MINIMUM_APTITUDE
    for key in item.apt_growth
      stat = key[0]; value = key[1]
      if value > 0 and @actor.aptitude_rate(stat) != max_apt
        changes = true
        break
      elsif value < 0 and @actor.aptitude_rate(stat) != min_apt
        changes = true
        break
      end
    end
    return changes
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    return if item == nil
    enabled = enable?(item)
    draw_obj_name(item, rect.clone, enabled)
    draw_obj_charges(item, rect.clone, enabled)
    draw_obj_total(item, rect.clone, enabled)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_obj_name(obj, rect, enabled)
    draw_icon(obj.icon_index, rect.x, rect.y, enabled)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    rect.width -= 48
    self.contents.draw_text(rect.x+24, rect.y, rect.width-24, WLH, obj.name)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_obj_charges(obj, rect, enabled)
    return unless $imported["BattleEngineMelody"]
    return unless obj.is_a?(RPG::Item)
    return unless obj.consumable
    return if obj.charges <= 1
    $game_party.item_charges = {} if $game_party.item_charges == nil
    $game_party.item_charges[obj.id] = obj.charges if
      $game_party.item_charges[obj.id] == nil
    charges = $game_party.item_charges[obj.id]
    dx = rect.x; dy = rect.y + WLH/3
    self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:charge]
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, 24, WLH * 2/3, charges, 2)
    self.contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_obj_total(obj, rect, enabled)
    if $imported["BattleEngineMelody"]
      hash = YEM::BATTLE_ENGINE::ITEM_SETTINGS
    else
      hash ={ :text => ":%d", :size => Font.default_size, :colour => 0 }
    end
    number = $game_party.item_number(obj)
    dx = rect.x + rect.width - 36; dy = rect.y; dw = 32
    text = sprintf(hash[:text], number)
    self.contents.font.size = hash[:size]
    self.contents.font.color = text_color(hash[:colour])
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Equip < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :equip_window
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    @actor = $game_party.members[@actor_index]
    $game_party.last_actor_index = @actor_index
    $game_temp.equip_last = 0 if $game_temp.equip_last == nil
    @help_window = Window_Help.new
    @help_window.y = 128
    @windows = []
    create_command_window
    @status_window = Window_Equip_Actor.new(@actor)
    @equip_window = Window_Equip.new(0, 184, @actor)
    @equip_window.help_window = @help_window
    @windows.push(@equip_window)
    @stat_window = Window_EquipStat.new(@equip_window, @actor)
    #@stat_window.visible = false
    @windows.push(@stat_window)
    
    @item_window = Window_Equip_Item.new(@equip_window, @actor)
    @item_window.help_window = @help_window
    @item_window.y = 416*3
    @windows.push(@item_window)
    #################
    @mini_item_window = Window_Equip_Item_mini.new(@equip_window, @actor)
    @mini_item_window.x = 300#300
    @mini_item_window.y = 416*3
    @mini_item_window.opacity = 0
    @windows.push(@mini_item_window)
    ################
    @com_count = 11
    create_menu_background
    update_windows
  end
  
  def create_menu_background
    @menuback_sprite.dispose if @menuback_sprite != nil
    @menuback_sprite2.dispose if @menuback_sprite2 != nil
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("MenuBack_equip")
    @menuback_sprite.z -= 1
    @status_window.opacity = 0
    @help_window.opacity = 0
    @equip_window.opacity = 0
    @command_window.opacity = 0 if @command_window != nil
    @stat_window.opacity = 0 if @stat_window != nil
    @item_window.opacity = 0 if @item_window != nil
    #@stat_window.visible = false
    #####################################################################
    @sprites = []
    images_name =
    ["Equip01","Equip02"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = 28
     @sprites[i].y = (i * 27) + 40
     @sprites[i].opacity = 255
     #@sprites[i].x = (i * -10)+30 if i>=4
     #@sprites[i].x = (i * 10)-20 if i<4
     #@sprites[i].y = (i * @sprites[i].height*0.7 + (Graphics.height - @sprites[i].height)/1.5 )-230
     #@sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
     @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
    end
    ####################################################################
    ####################################################################
    @mask = Sprite.new
    @mask.bitmap = Cache.system("MenuBack_mask")
    @mask.z = 999
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407
    @light.y = -20
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
#    @light2.x = 407#((403*256) - 600 -403)/8 + rand(6) - 3#403
#    @light2.y = -20#((-20*256) -600 +20)/8 +rand(6) - 3#-20
    @light2.x = 10
    @light2.y = 31
    @light2.zoom_x = 150 / 100.0
    @light2.zoom_y = 55 / 100.0
    @light2.opacity = 70
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
		@light2.z = 1000
    
    fireflies(5)
    ####################################################################

    update_menu_background
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose if @command_window != nil
    @status_window.dispose if @status_window != nil
    @help_window.dispose if @help_window != nil
    @equip_window.dispose if @equip_window != nil
    @stat_window.dispose if @stat_window != nil
    @item_window.dispose if @item_window != nil
    @mini_item_window.dispose if @mini_item_window != nil
    @aptitude_window.dispose if @aptitude_window != nil
    @apt_stat.dispose if @apt_stat != nil
    for i in 0..1
      @sprites[i].dispose
    end
    @mask.dispose
    @light.dispose
    @light2.dispose
    fireflies(0)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias return_scene_eo return_scene unless $@
  def return_scene
    return_scene_eo
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    set_new_actor
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    set_new_actor
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_new_actor
    $game_party.last_actor_index = @actor_index
    @actor = $game_party.members[@actor_index]
    @status_window.actor = @actor
    for window in @windows; window.actor = @actor; end
    update_windows
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []; @data = []
    for command in YEM::EQUIP::COMMANDS
      case command
      when :manual, :optimize
      when :aptitude
        next unless YEM::EQUIP::USE_APTITUDE_SYSTEM
        @aptitude_window = Window_Aptitude.new(@help_window, @actor)
        @aptitude_window.help_window = @help_window
        @windows.push(@aptitude_window)
        @apt_stat = Window_EquipApt.new(@aptitude_window, @actor)
        @windows.push(@apt_stat)
      else; next
      end
      @data.push(command)
      commands.push(YEM::EQUIP::VOCAB[command])
    end
    @command_window = Window_Command_Centered.new(160, commands)
    @command_window.windowskin = Cache.windows("windowX") 
    @command_window.height = 128
    @command_window.index = $game_temp.equip_last
    @command_window.active = true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    if @command_window.active
      update_command_selection
      @stat_window.visible = true
      @mini_item_window.y = 416*3
      #@stat_window.visible = false
      #@equip_window.help_window = @help_window
      #@windows.push(@equip_window)
    elsif @equip_window.active
      update_equip_selection
      @stat_window.visible = false
      @mini_item_window.y = @equip_window.y
      #@stat_window.refresh########################
      #@equip_window.help_window = @help_window
      #@windows.push(@equip_window)
    elsif @item_window.active
      update_item_selection
      @stat_window.visible = true
      @mini_item_window.y = 416*3
      #@stat_window.visible = true
    elsif @aptitude_window.active
      update_aptitude_selection
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_windows
    @aptitude_window.y = Graphics.height*8 if @aptitude_window != nil
    @apt_stat.y = Graphics.height*8 if @apt_stat != nil
    @help_window.y = Graphics.height*8
    @equip_window.y = Graphics.height*8
    @stat_window.y = @equip_window.y
    case @data[@command_window.index]
    when :aptitude
      @help_window.y = @status_window.height
      @aptitude_window.y = @help_window.y + @help_window.height
      @apt_stat.y = @aptitude_window.y
      @aptitude_window.update_help
    else
      @help_window.y = @status_window.height
      @equip_window.y = @help_window.y + @help_window.height
      @stat_window.y = @equip_window.y
      @equip_window.update_help if !@command_window.active####
    end
    @help_window.y += 11
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_command_selection
    ################################
     @help_window.set_text("自由更換裝備") if @command_window.index == 0
     @help_window.set_text("自動換裝，請注意不包含身上的裝備") if @command_window.index == 1
    for i in 0..1
      @sprites[i].tone = Tone.new(0,0,0,255)
      #@sprites[i].zoom_x -= 0.05 if @sprites[i].zoom_x > 1.0
      #@sprites[i].zoom_y -= 0.05 if @sprites[i].zoom_y > 1.0
      @sprites[i].y = (i * 27) + 40
      #@sprites[i].y = (i * @sprites[i].height*0.7 + (Graphics.height - @sprites[i].height)/1.5 )-230
    end
    @sprites[@command_window.index].tone = Tone.new(0,0,0)
    #@sprites[@command_window.index].zoom_x += 0.05 if @sprites[@command_window.index].zoom_x < 3#1.8
    #@sprites[@command_window.index].zoom_y += 0.05 if @sprites[@command_window.index].zoom_y < 3#1.8
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
    @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
    @sprites[@command_window.index].y = (@command_window.index * 27) + 40 if Input.trigger?(Input::UP)
    @sprites[@command_window.index].y = (@command_window.index * 27) + 40 if Input.trigger?(Input::DOWN)
    #@sprites[@command_window.index].flash(Color.new(100,255,255),1) if Input.trigger?(Input::UP)
    #@sprites[@command_window.index].flash(Color.new(100,255,255),1) if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @com_count +=1
    end
#################################################
################################
    @mask.visible = true if @command_window.active###
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
    
    @light2.opacity = rand(40) + 70
    @light2.x = 10
    @light2.y = (@command_window.index * 30) + 31
    ################################

    @command_window.update
    if $game_temp.equip_last != @command_window.index
      $game_temp.equip_last = @command_window.index
      update_windows
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
      $game_temp.equip_last = nil
    elsif Input.repeat?(Input::RIGHT)
      return if $game_temp.in_battle
      Sound.play_cursor
      next_actor
      @mini_item_window.refresh(@equip_window.equip_type, false)
      #@stat_window.refresh(@equip_window.item, @equip_window.index)
    elsif Input.repeat?(Input::LEFT)
      return if $game_temp.in_battle
      Sound.play_cursor
      prev_actor
      @mini_item_window.refresh(@equip_window.equip_type, false)
      #@stat_window.refresh(@equip_window.item, @equip_window.index)
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @mask.visible = false
      case @data[@command_window.index]
      when :manual
        @command_window.active = false
        @sprites[@command_window.index].color.set(200, 255, 255, 160)
        @sprites[@command_window.index].y = (@command_window.index * 27) + 40
        @equip_window.active = true
      when :optimize
      ###
     #   @actor.change_equip(i, nil)
     # end
      ###
      perform_optimize
     # Game_Interpreter_Self.new(25)###############套裝
     # @stat_window.refresh########################
#      p "已自動換上裝備"
###################################################################
# 設定訊息
#$game_message.texts.push("       已自動換上裝備")
#$game_message.position = 2
#$game_message.background = 1

# 建立訊息視窗
#message_window = Window_Message.new

# 把視窗加入當前場景
#$scene.instance_variable_set(:@message_window, message_window)

# 等待玩家按下確認鍵
#  break if Input.trigger?(Input::C) # 玩家按下確認鍵
#end

# 清除訊息視窗
###################################################################
      #@help_window.contents.clear
      #@help_window.set_text("已換裝完成") 
      #@help_window.update
      when :aptitude
        @command_window.active = false
        @aptitude_window.active = true
      when :mastery
        $scene = Scene_Mastery.new(@actor_index, @command_window.index)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_equip_selection
    @equip_window.update
    if @last_equip_index != @equip_window.index
      @last_equip_index = @equip_window.index
      @status_window.refresh(@equip_window.index)
      @mini_item_window.refresh(@equip_window.equip_type, false)
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @equip_window.active = false
      @sprites[@command_window.index].color.set(255, 255, 255, 0)
      @sprites[@command_window.index].y = (@command_window.index * 27) + 40
    elsif Input.repeat?(Input::RIGHT)
      #return if $game_temp.in_battle
      #@mini_item_window.refresh(@equip_window.equip_type, false)

    elsif Input.repeat?(Input::LEFT)
      #return if $game_temp.in_battle
      #@mini_item_window.refresh(@equip_window.equip_type, false)

    elsif Input.trigger?(Input::X)
      if !YEM::EQUIP::TYPE_RULES[@equip_window.equip_type][2]
        Sound.play_buzzer
        return
      end
      return if @equip_window.item == nil
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      @actor.change_equip(@equip_window.index, nil)
      @status_window.refresh(@equip_window.index)
      @equip_window.refresh
      @stat_window.refresh
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
    elsif $TEST and Input.trigger?(Input::F5)
      Sound.play_decision
      start_item_selection(true)
    elsif Input.trigger?(Input::C)
      if @actor.locked_equips.include?(@equip_window.index) or
      @actor.fix_equipment
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      start_item_selection
      @stat_window.refresh(@equip_window.item, @equip_window.index)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_item_selection(debug = false)
    @equip_window.active = false
    @item_window.active = true
    #@stat_window.visible = true
    #@mini_item_window.visible = false
    @item_window.refresh(@equip_window.equip_type, debug)
    @item_window_oy = {} if @item_window_oy == nil
    @item_window_oy[@equip_window.equip_type] = 0 if
      @item_window_oy[@equip_window.equip_type] == nil
    @item_window.oy = @item_window_oy[@equip_window.equip_type]
    @item_window_index = {} if @item_window_index == nil
    @item_window_index[@equip_window.equip_type] = 0 if
      @item_window_index[@equip_window.equip_type] == nil
    @item_window.index = [[@item_window_index[@equip_window.equip_type],
      @item_window.item_max - 1].min, 0].max
    @item_window.y = @equip_window.y
    @equip_window.y = 416*3
    @item_window.update_help
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_item_selection
    @item_window.update
    if @last_item_index != @item_window.index
      @last_item_index = @item_window.index
      @stat_window.refresh(@item_window.item, @equip_window.index)
    end
    if Input.trigger?(Input::B) or ($TEST and Input.trigger?(Input::F6))
      Sound.play_cancel
      end_item_selection
    elsif $TEST and Input.repeat?(Input::F8)
      item = @item_window.item
      return if item == nil
      Sound.play_use_item
      $game_party.gain_item(item, 1)
     
      @item_window.draw_item(@item_window.index)
    elsif $TEST and Input.repeat?(Input::F7)
      item = @item_window.item
      return if item == nil
      return if $game_party.item_number(item) <= 0
      Sound.play_use_item
      $game_party.lose_item(item, 1)
      @item_window.draw_item(@item_window.index)
    elsif Input.trigger?(Input::X)
      if !YEM::EQUIP::TYPE_RULES[@equip_window.equip_type][1]
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      @actor.change_equip(@equip_window.index, nil)
      @status_window.refresh(@equip_window.index)
      end_item_selection
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
    elsif $TEST and Input.trigger?(Input::F5)
      Sound.play_equip
      $game_temp.in_battle = true
      @actor.change_equip(@equip_window.index, @item_window.item)
      $game_temp.in_battle = false
      @status_window.refresh(@equip_window.index)
      end_item_selection
    elsif Input.trigger?(Input::C)
      if !@item_window.enable?(@item_window.item)
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
      last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
      ####################
     # cat = get_category(@equip_window.item)
     # return if cat == :none
     # $game_party.nitems[cat][@equip_window.item.id] = true
      ####################
      @actor.change_equip(@equip_window.index, @item_window.item)
       
      @status_window.refresh(@equip_window.index)
      
      end_item_selection
      @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
      @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
      
    end
  end
  def get_category(item)
    if item.is_a?(RPG::Item)
      return :item
    elsif item.is_a?(RPG::Weapon)
      return :weapon
    elsif item.is_a?(RPG::Armor)
      return :armor
    else
      return :none
    end
  end
  ###################
  class Window_Suit < Window_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 544, WLH + 32)
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # * 設置文本
  #  text  : 顯示於視窗中的字串
  #  align : 對齊方式（0為左對齊，1為劇中，二為右對齊）
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, "套裝啟動", 1)      
    end
  end
end
  ###################
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def end_item_selection
    Game_Interpreter_Self.new(25)###############套裝
    @stat_window.refresh########################
    #@stat_window.visible = false
    #@mini_item_window.visible = true
    @mini_item_window.refresh(@equip_window.equip_type, false)
    @item_window_oy[@equip_window.equip_type] = @item_window.oy
    @item_window_index[@equip_window.equip_type] = @last_item_index
    @item_window.active = false
    @equip_window.active = true
    @last_item_index = nil
    @equip_window.refresh
    @equip_window.y = @item_window.y
    @item_window.y = 416*3
    @equip_window.update_help
    @stat_window.refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def perform_optimize
    Sound.play_equip

    last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
    last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
    types = [:weapon] + @actor.equip_type
    slot = -1
    for type in types
      slot += 1
      type = :weapon if slot == 1 and @actor.two_swords_style
      next unless YEM::EQUIP::TYPE_RULES[type][3]
      item = optimal_equip(slot, type)
      next if item == nil
      @actor.change_equip(slot, item)
    end
    @status_window.refresh(@equip_window.index)
    @equip_window.refresh
    @stat_window.refresh
    @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
    @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def optimal_equip(slot, type)
    return nil if slot == 1 and @actor.weapons[0] != nil and 
      @actor.weapons[0].two_handed
    equips = []; valid = []
    if type == :weapon
      for item in $game_party.equip_weapons
        next if item == nil
        next unless @actor.equippable?(item)
        equips.push(item)
        #equips.push(@actor.weapons[0])###也比較身上這件
      end
    else
      for item in $game_party.equip_armours
        next if item == nil
        next unless item.kind == YEM::EQUIP::TYPE_RULES[type][1]
        next unless @actor.equippable?(item)
        equips.push(item)
        #################
        #equips.push(@actor.armors[slot]) if @actor.armors[slot] != nil
        #################
      end
    end
    order_type = YEM::EQUIP::OPTIMIZE_SETTINGS.include?(type) ? type : :unlisted
    order = YEM::EQUIP::OPTIMIZE_SETTINGS[order_type]
    return nil if equips == []
    result = []
    for param in order
      comp_proc = YEM::EQUIP::COMP_PARAM_PROC[param]
      get_proc = YEM::EQUIP::GET_PARAM_PROC[param]
      equips.sort! { |a, b| comp_proc.call(a, b) }
      highest = equips[0]
      result = equips.find_all { |item|
        get_proc.call(highest) == get_proc.call(item)
      }
      break if result.size == 1
      equips = result.clone
    end
    return nil if result == []
    result.sort! { |a, b| b.id - a.id }
    return result[0]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_aptitude_selection
    @aptitude_window.update
    if @last_aptitude != @aptitude_window.index
      @last_aptitude = @aptitude_window.index
      item = @aptitude_window.item
      @apt_stat.refresh
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @aptitude_window.active = false
      @command_window.active = true
      @equip_window.refresh
      @stat_window.refresh
      @apt_stat.refresh
      @last_aptitude = nil
    elsif Input.repeat?(Input::RIGHT)
      return if $game_temp.in_battle
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(Input::LEFT)
      return if $game_temp.in_battle
      Sound.play_cursor
      prev_actor
    elsif $TEST and Input.repeat?(Input::F8)
      Sound.play_equip
      for item in $game_temp.aptitude_items
        next if item == nil
        amount = Input.press?(Input::SHIFT) ? 10 : 1 + rand(3)
        $game_party.gain_item(item, amount)
      end
      @aptitude_window.refresh
    elsif $TEST and Input.repeat?(Input::F7)
      Sound.play_equip
      for item in $game_temp.aptitude_items
        next if item == nil
        amount = Input.press?(Input::SHIFT) ? 10 : 1 + rand(3)
        $game_party.lose_item(item, amount)
      end
      @aptitude_window.refresh
    elsif $TEST and Input.repeat?(Input::F6)
      item = @aptitude_window.item
      return if item == nil
      Sound.play_equip
      amount = Input.press?(Input::SHIFT) ? 10 : 1 + rand(3)
      $game_party.gain_item(item, amount)
      @aptitude_window.draw_item(@aptitude_window.index)
    elsif $TEST and Input.repeat?(Input::F5)
      item = @aptitude_window.item
      return if item == nil
      Sound.play_equip
      amount = Input.press?(Input::SHIFT) ? 10 : 1 + rand(3)
      $game_party.lose_item(item, amount)
      @aptitude_window.draw_item(@aptitude_window.index)
    elsif Input.repeat?(Input::C)
      item = @aptitude_window.item
      if @aptitude_window.enable?(item)
        Sound.play_use_item
        last_hp_per = @actor.hp * 100.0 / [@actor.maxhp, 1].max
        last_mp_per = @actor.mp * 100.0 / [@actor.maxmp, 1].max
        @actor.item_growth_effect(@actor, item)
        @actor.hp = Integer(@actor.maxhp * last_hp_per / 100.0)
        @actor.mp = Integer(@actor.maxmp * last_mp_per / 100.0)
        $game_party.consume_item(item) unless @actor.skipped
        @aptitude_window.draw_item(@aptitude_window.index)
        @apt_stat.refresh
        @status_window.refresh(@equip_window.index)
      elsif Input.trigger?(Input::C)
        Sound.play_buzzer
      end
    end
  end
  
end

#===============================================================================
# 
# 
#===============================================================================
