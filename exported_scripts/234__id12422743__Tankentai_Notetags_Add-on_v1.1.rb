#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Tankentai Notetags Add-on v1.1
# 【來源】Mr. Bubble，v1.1，2010-06-29；Special Thanks: Mithran、Yanfly。
# 【用途】把 Tankentai SBS／ATB 大量原本需硬寫在腳本設定的 Action／Enemy／State 行為改成資料庫 Notetag。必須放在 Sideview 與 ATB 基礎腳本之後。
# 【共同規則】`key` 是 SBS Action Sequence Key，大小寫敏感且不可加引號；不存在的 Key 會造成錯誤。`filename` 多數來自 Graphics/Characters。
# 【Skill/Item/Weapon】`<action: key>` 指定 Action Sequence，例如 `<action: NORMAL_ATTACK>`；`<flygraphic: filename>` 指定飛行圖，`<flygraphic: icon>` 使用技能／物品 Icon；Weapon 可 `<graphic: big_sword>` 改武器圖。
# 【Extensions】Skill/Item 用 `<extensions> ... </extensions>` 或 `<ext> ... </ext>`；常用值：`perfect hit`、`ignore reflect`、`hide help window`、`target all`、`random target`、`no flash`。每個 extension 一行。
# 【State】`<slip: hp,15,10%>` 每回合固定+比例傷害；負值代表回復。`<action: WAIT-SLEEP>` 改待機動作。State extensions 支援 autolife/rebirth、magic/physical reflect/null、absorb cost、zero turn lift、enemy off、no pop、action off 等。
# 【Enemy Action】`<unarmed:key>`、`<standby:key>`、`<pinch:key>`、`<guard:key>`、`<hurt:key>`、`<evade:key>`、`<escape:key>`、`<start:key>`、`<interrupt:key>`、`<dead:key>`。
# 【Enemy Graphic/Position】`<shadow: filename>`／`<shadow: off>`、`<move shadow:x,y>`、`<weapon:id>`、`<position:x,y>`、`<collapse:type>`、`<multiact:times,chance%,speed reduction%>`、`<animate>`/`<-animate>`、`<mirror>`/`<-mirror>`。
# 【ATB】`<charge action:key>`、`<recharge:value%>`、`<atb base:value%>`、Weapon 的 `<charge bonus:value%>`、State 的 `<atb damage:value%>`／negative atb、Enemy 的 `<atb gauge>` 開關。這些會直接影響 ATB Runtime，不能把百分號／正負號隨意改掉。
# 【素材】`flygraphic`、weapon graphic、Enemy shadow 等多數讀 Graphics/Characters；實際檔名來自 Notetag，沒有固定清單。
# 【維護】本頁約有大量 Note parser 與 class reopen；新增 Notetag 優先擴充既有 parser，不要再建立另一套相同名稱 Regex。完整原外語手冊已翻成以上繁中索引，所有精確 Notetag 仍以程式 Regex 為最終準則。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#   v1.1 (June 29, 2010)
#------------------------------------------------------------------------------
# By Mr. Bubble
#==============================================================================
# 
#==============================================================================



#=============================================================================
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#=============================================================================




module Bubs
#=========================================================================
#=========================================================================
module TankentaiBaseItemTags
  # <action: key>
  # <flygraphic: filename>
  # <graphic: filename>
  # <charge bonus: value>
  # <atb base: value>
  # <recharge: value>
  BASE_ACTION_TAG = /<ACTION[:]?\s*(.+)\s*>/i
  FLYING_GRAPHIC_TAG = /<FLYGRAPHIC[:]?\s*([\w]+)\s*>/i
  WEAPON_GRAPHIC_TAG = /<GRAPHIC[:]?\s*([\w]+)\s*>/i
  
  CHARGE_TAG = /<CHARGE[:]?\s*(\d+)\s*[,]?\s*(\d+)[%]?\s*[,]?\s*(\d+)\s*>/i
  CHARGE_SEQUENCE_TAG = /<CHARGE\s?ACTION[:]?\s*(.+)\s*>/i
  RECHARGE_TAG = /<RECHARGE[:]?\s*([-+]?[\d]+)[%]?\s*>/i
  CHARGE_BONUS_TAG = /<CHARGE\s?BONUS[:]?\s*([-+]?[\d]+)[%]?\s*>/i
  ATB_BASE_TAG = /<ATB\s?BASE[:]?\s*([-+]?[\d]+)[%]?\s*>/i
  
  def base_action_noteread
    @action_key ||= note =~ BASE_ACTION_TAG ? $1 : :nothing
  end
  
  def flying_graphic_noteread
    @flygraphic ||= note =~ FLYING_GRAPHIC_TAG ? $1 : :nothing
  end
  
  def weapon_graphic_noteread
    @weapon_graphic ||= note =~ WEAPON_GRAPHIC_TAG ? $1 : :nothing
  end
  
  def charge_noteread
    @charge_values ||= note =~ CHARGE_TAG ? [$1.to_i, $2.to_i, $3.to_i, charge_sequence_noteread] : :nothing
  end
  
  def charge_sequence_noteread
    note =~ CHARGE_SEQUENCE_TAG ? $1 : ""
  end
  
  def recharge_noteread
    @recharge_value ||= note =~ RECHARGE_TAG ? $1.to_i : :nothing
  end
  
  def charge_bonus_noteread
    @charge_bonus ||= note =~ CHARGE_BONUS_TAG ? $1.to_i : :nothing
  end
  
  def atb_base_noteread
    @atb_base ||= note =~ ATB_BASE_TAG ? $1.to_i : :nothing
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def skill_item_extension_noteread
    return @extensions if @extensions != nil
    @extensions = []
    ext_reading = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:EXTENSION[S]?|ext)>/i
        ext_reading = true
      when /<\/(?:EXTENSION[S]?|ext)>/i
        ext_reading = false
      when /([\w\s]+)/i
        next unless ext_reading
        case $1.upcase
        when "PERFECTHIT", "PERFECT HIT", "NOEVADE", "NO EVADE"
          @extensions.push("PERFECTHIT")
          
        when "IGNOREREFLECT", "IGNORE REFLECT"
          @extensions.push("IGNOREREFLECT")
          
        when "HELPHIDE", "HELP HIDE", "HIDEHELP", "HIDE HELP", "HIDE HELP WINDOW"
          @extensions.push("HELPHIDE")
          
        when "TARGETALL", "TARGET ALL"
          @extensions.push("TARGETALL")
          
        when "RANDOMTARGET", "RANDOM TARGET", "RANDOM"
          @extensions.push("RANDOMTARGET")
          
        when "OTHERS", "REMOVE SELF", "NOT SELF"
          @extensions.push("OTHERS")
          
        when "NOOVERKILL", "NO OVERKILL"
          @extensions.push("NOOVERKILL")
          
        when "NOFLASH", "NO FLASH", "DON'T FLASH"
          @extensions.push("NOFLASH")
          
        when "NONE"
          @extensions.push("NONE")
          
        end # 詳見頁首繁中說明
      end # 詳見頁首繁中說明
    }
    return @extensions
  end # 詳見頁首繁中說明
end # 詳見頁首繁中說明

#=========================================================================
#=========================================================================
module TankentaiStateTags
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # <extensions>
  # </extensions>
  def state_extension_noteread
    return @extensions if @extensions != nil
    @extensions = []
    ext_reading = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:extensions|EXTENSION)>/i
        ext_reading = true
      when /<\/(?:extensions|EXTENSION)>/i
        ext_reading = false
      when /([\w\s]+)[:]?\s*([\d]+)/i
        next unless ext_reading
        case $1.upcase
        when "AUTOLIFE", "REBIRTH"
          @extensions.push("AUTOLIFE/" + $2)
          
        when "MAGREFLECT", "MAGIC REFLECT", "REFLECT MAGIC"
          @extensions.push("MAGREFLECT/" + $2)
          
        when "PHYREFLECT", "PHYSICAL REFLECT", "REFLECT PHYSICAL"
          @extensions.push("PHYREFLECT/" + $2)
          
        when "MAGNULL", "MAGIC NULL", "NULL MAGIC"
          @extensions.push("MAGNULL/" + $2)
          
        when "PHYNULL", "PHYSICAL NULL", "NULL PHYSICAL"
          @extensions.push("PHYNULL/" + $2)
          
        end # 詳見頁首繁中說明
        
      when /([\w\s]+)/i
        next unless ext_reading
        case $1.upcase
        when "COSTABSORB", "COST ABSORB", "ABSORB COST"
          @extensions.push("COSTABSORB")
          
        when "ZEROTURNLIFT", "ZERO TURN LIFT", "TURN END LIFT"
          @extensions.push("ZEROTURNLIFT")
          
        when "EXCEPTENEMY", "ENEMY OFF", "ENEMY ACTION OFF"
          @extensions.push("EXCEPTENEMY")
          
        when "NOSTATEANIME", "ACTION OFF", "STATE ACTION OFF"
          @extensions.push("NOSTATEANIME")
          
        when "NOPOP", "NO POP" "HIDE POP", "HIDE POP WINDOW",
          @extensions.push("NOPOP")
          
        when "NONE"
          @extensions.push("NONE")
        end # 詳見頁首繁中說明
      end # 詳見頁首繁中說明
    }
    return @extensions
  end # 詳見頁首繁中說明

  # <slip: HP/MP, value, value(%)>
  SLIP_CANNOT_KILL = /<(?:CANNOT\s?KILL|can't kill)>/i
  SLIP_CANNOT_POP = /<(?:CANNOT\s?POP|can't pop)>/i
  SLIP_DAMAGE_TAG = 
  /<slip[:]?\s*([HM]P)\s*[,]?\s*([-+]?\d+)\s*[,]?\s*([-+]?\d+)[%]?\s*>/i
  
  ATB_DAMAGE_TAG = /<ATB\s?DAMAGE[:]?\s*([-+]?[\d]+)[%]?\s*>/i
  ATB_MINUS_DAMAGE_TAG = /<([-+])?(?:ATB\s?MINUS\s?DAMAGE|negative\s?atb)>/i
  
  def state_base_action_noteread
    @state_action ||= note =~ TankentaiBaseItemTags::BASE_ACTION_TAG ? $1 : :nothing
  end
  
  def slip_can_kill_noteread 
    note =~ SLIP_CANNOT_KILL ? false : true 
  end
  
  def slip_can_pop_noteread
    note =~ SLIP_CANNOT_POP ? false : true
  end
  
  def state_slip_extension_noteread
    @slip_values ||= note =~ SLIP_DAMAGE_TAG ? [$1.downcase, $2.to_i, $3.to_i, slip_can_pop_noteread, slip_can_kill_noteread] : [] 
  end
  
  def atb_damage_noteread
    @atb_damage ||= note =~ ATB_DAMAGE_TAG ? $1.to_i : :nothing
  end
  
  def atb_minus_damage_noteread
    @minus_damage.nil? ? @minus_damage =  (note =~ ATB_MINUS_DAMAGE_TAG ? $1 != '-' : :nothing) : @minus_damage
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def state_slip_extension_all_noteread
    return @slip_extensions if @slip_extensions != nil
    @slip_extensions = []
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when SLIP_DAMAGE_TAG
        #                    ["hp", value, value(%), bool, bool]
        @slip_extensions.push(state_slip_extension_noteread)
      end
    }
    @slip_extensions
  end # 詳見頁首繁中說明
  
end # 詳見頁首繁中說明

#=========================================================================
#=========================================================================
module TankentaiEnemyTags
  # <unarmed: key>
  # <standby: key>
  # <pinch: key>
  # <guard: key>
  # <hurt: key>
  # <evade: key>
  # <escape: key>
  # <start: key>
  # <interrupt: key>
  # <dead: key>
  # <shadow: filename>
  # <shadow plus: value x, value y>
  # <weapon: id>
  # <position plus: value x, value y>
  # <collapse: type>
  # <multiact: value>
  # <animate>
  # <mirror>
  ENEMY_UNARMED_ACTION = /<UNARMED[:]?\s*(.+)\s*>/i
  ENEMY_STANDBY = /<STANDBY[:]?\s*(.+)\s*>/i
  ENEMY_PINCH = /<PINCH[:]?\s*(.+)\s*>/i
  ENEMY_GUARD = /<GUARD[:]?\s*(.+)\s*>/i
  ENEMY_HURT = /<HURT[:]?\s*(.+)\s*>/i
  ENEMY_EVADE = /<EVADE[:]?\s*(.+)\s*>/i
  ENEMY_ESCAPE = /<ESCAPE[:]?\s*(.+)\s*>/i
  ENEMY_START = /<START[:]?\s*(.+)\s*>/i
  ENEMY_INTERRUPT = /<INTERRUPT[:]?\s*(.+)\s*>/i
  ENEMY_INCAPACITATED = /<DEAD[:]?\s*(.+)\s*>/i
  ENEMY_SHADOW = /<SHADOW[:]?\s*(\w+)\s*>/i
  ENEMY_SHADOW_PLUS = /<MOVE\s?SHADOW[:]?\s*([-+]?\d+)\s*[,]?\s*([-+]?\d+)\s*>/i
  ENEMY_WEAPON = /<WEAPON[:]?\s*([-+]?\d+)\s*>/i
  ENEMY_POSITION = /<POSITION[:]?\s*([-+]?\d+)\s*[,]?\s*([-+]?\d+)\s*>/i
  ENEMY_COLLAPSE = /<COLLAPSE[:]?\s*(\d+)\s*>/i
  ENEMY_MULTIACT = /<MULTIACT[:]?\s*(\d+)\s*[,]?\s*(\d+)\s*[,]?\s*([-+]?\d+)\s*>/i
  ENEMY_ANIMATE = /<([-+])?(?:ANIMATE|animated)>/i
  ENEMY_MIRROR = /<([-+])?(?:MIRROR|invert)>/i
  ENEMY_ATB_ON = /<([-+])?(?:ATB\s?GAUGE|atb\s?on)>/i

  def enemy_base_action_noteread
    @action_key ||= note =~ ENEMY_UNARMED_ACTION ? $1 : :nothing
  end

  def enemy_normal_noteread
    @enemy_standby ||= note =~ ENEMY_STANDBY ? $1 : :nothing
  end
  
  def enemy_pinch_noteread
    @enemy_pinch ||= note =~ ENEMY_PINCH ? $1 : :nothing
  end
  
  def enemy_guard_noteread
    @enemy_guard ||= note =~ ENEMY_GUARD ? $1 : :nothing
  end
  
  def enemy_hurt_noteread
    @enemy_hurt ||= note =~ ENEMY_HURT ? $1 : :nothing
  end
  
  def enemy_evade_noteread
    @enemy_evade ||= note =~ ENEMY_EVADE ? $1 : :nothing
  end
  
  def enemy_escape_noteread
    @enemy_escape ||= note =~ ENEMY_ESCAPE ? $1 : :nothing
  end
  
  def enemy_start_noteread
    @enemy_start ||= note =~ ENEMY_START ? $1 : :nothing
  end
  
  def enemy_interrupt_noteread
    @enemy_interrupt ||= note =~ ENEMY_INTERRUPT ? $1 : :nothing
  end
  
  def enemy_incapacitated_noteread
    @enemy_dead ||= note =~ ENEMY_INCAPACITATED ? $1 : :nothing
  end
  
  def enemy_mirror_noteread
    @enemy_mirror.nil? ? @enemy_mirror =  (note =~ ENEMY_MIRROR ? $1 != '-' : :nothing) : @enemy_mirror
  end
  
  def enemy_animate_noteread
    @enemy_animate.nil? ? @enemy_animate =  (note =~ ENEMY_ANIMATE ? $1 != '-' : :nothing) : @enemy_animate
  end
  
  def enemy_shadow_noteread
    @shadow_name ||= note =~ ENEMY_SHADOW ? $1 : :nothing
  end
  
  def enemy_shadow_plus_noteread
    @shadow_plus ||= note =~ ENEMY_SHADOW_PLUS ? [$1.to_i, $2.to_i] : :nothing
  end
  
  def enemy_position_plus_noteread
    @position_plus ||= note =~ ENEMY_POSITION ? [$1.to_i, $2.to_i] : :nothing
  end
  
  def enemy_weapon_noteread
    @enemy_weapon ||= note =~ ENEMY_WEAPON ? $1.to_i : :nothing
  end
  
  def enemy_collapse_noteread
    @enemy_collapse ||= note =~ ENEMY_COLLAPSE ? $1.to_i : :nothing
  end
  
  def enemy_action_time_noteread
    @multiact ||= note =~ ENEMY_MULTIACT ? [$1.to_i, $2.to_i, $3.to_i] : :nothing
  end
  
  def enemy_charge_noteread
    @charge_values ||= note =~ TankentaiBaseItemTags::CHARGE_TAG ? [$1.to_i, $2.to_i, $3.to_i, enemy_charge_sequence_noteread] : :nothing
  end
  
  def enemy_charge_sequence_noteread
    note =~ TankentaiBaseItemTags::CHARGE_SEQUENCE_TAG ? $1 : ""
  end
  
  def enemy_recharge_noteread
    @recharge_value ||= note =~ TankentaiBaseItemTags::RECHARGE_TAG ? $1.to_i : :nothing
  end

  def enemy_atb_base_noteread
    @atb_base ||= note =~ TankentaiBaseItemTags::ATB_BASE_TAG ? $1.to_i : :nothing
  end
  
  def enemy_atb_on_noteread
    @atb_on.nil? ? @atb_on = (note =~ ENEMY_ATB_ON ? $1 != '-' : :nothing) : @atb_on
  end

end # 詳見頁首繁中說明

end # 詳見頁首繁中說明

#==========================================================================
#==========================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_base_action base_action unless $@
  def base_action
    return @action_key if @action_key != nil 
    action = enemy.enemy_base_action_noteread
    if action != :nothing
       @action_key = action
    else
      @action_key = bubs_tsbs_notetags_enemy_base_action # 詳見頁首繁中說明
    end
    @action_key 
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_normal normal unless $@
  def normal
    return @enemy_standby if @enemy_standby != nil 
    action = enemy.enemy_normal_noteread
    if action != :nothing
       @enemy_standby = action
    else
      @enemy_standby = bubs_tsbs_notetags_enemy_normal # 詳見頁首繁中說明
    end
    @enemy_standby
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_pinch pinch unless $@
  def pinch
    return @enemy_pinch if @enemy_pinch != nil 
    action = enemy.enemy_pinch_noteread
    if action != :nothing
       @enemy_pinch = action
    else
      @enemy_pinch = bubs_tsbs_notetags_enemy_pinch # 詳見頁首繁中說明
    end
    @enemy_pinch
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_defence defence unless $@
  def defence
    return @enemy_guard if @enemy_guard != nil 
    action = enemy.enemy_guard_noteread
    if action != :nothing
       @enemy_guard = action
    else
      @enemy_guard = bubs_tsbs_notetags_enemy_defence # 詳見頁首繁中說明
    end
    @enemy_guard
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_damage_hit damage_hit unless $@
  def damage_hit
    return @enemy_hurt if @enemy_hurt != nil 
    action = enemy.enemy_hurt_noteread
    if action != :nothing
       @enemy_hurt = action
    else
      @enemy_hurt = bubs_tsbs_notetags_enemy_damage_hit # 詳見頁首繁中說明
    end
    @enemy_hurt
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_evasion evasion unless $@
  def evasion
    return @enemy_evade if @enemy_evade != nil 
    action = enemy.enemy_evade_noteread
    if action != :nothing
       @enemy_evade = action
    else
      @enemy_evade = bubs_tsbs_notetags_enemy_evasion # 詳見頁首繁中說明
    end
    @enemy_evade
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_run_success run_success unless $@
  def run_success
    return @enemy_escape if @enemy_escape != nil 
    action = enemy.enemy_escape_noteread
    if action != :nothing
       @enemy_escape = action
    else
      @enemy_escape = bubs_tsbs_notetags_enemy_run_success # 詳見頁首繁中說明
    end
    @enemy_escape
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_first_action first_action unless $@
  def first_action
    return @enemy_start if @enemy_start != nil 
    action = enemy.enemy_start_noteread
    if action != :nothing
       @enemy_start = action
    else
      @enemy_start = bubs_tsbs_notetags_enemy_first_action # 詳見頁首繁中說明
    end
    @enemy_start
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_recover_action recover_action unless $@
  def recover_action
    return @enemy_interrupt if @enemy_interrupt != nil 
    action = enemy.enemy_interrupt_noteread
    if action != :nothing
       @enemy_interrupt = action
    else
      @enemy_interrupt = bubs_tsbs_notetags_enemy_recover_action # 詳見頁首繁中說明
    end
    @enemy_interrupt
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_incapacitated incapacitated unless $@
  def incapacitated
    return @enemy_dead if @enemy_dead != nil 
    action = enemy.enemy_incapacitated_noteread
    if action != :nothing
       @enemy_dead = action
    else
      @enemy_dead = bubs_tsbs_notetags_enemy_incapacitated # 詳見頁首繁中說明
    end
    @enemy_dead
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_action_mirror action_mirror unless $@
  def action_mirror
    return @enemy_mirror if @enemy_mirror != nil # 詳見頁首繁中說明
    value = enemy.enemy_mirror_noteread # 詳見頁首繁中說明
    if value != :nothing # 詳見頁首繁中說明
      @enemy_mirror = value # 詳見頁首繁中說明
    else
      @enemy_mirror = bubs_tsbs_notetags_action_mirror # 詳見頁首繁中說明
    end
    @enemy_mirror # 詳見頁首繁中說明
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_anime_on anime_on unless $@
  def anime_on
    return @enemy_animate if @enemy_animate != nil
    value = enemy.enemy_animate_noteread
    if value != :nothing
      @enemy_animate = value 
    else
      @enemy_animate = bubs_tsbs_notetags_anime_on # 詳見頁首繁中說明
    end
    @enemy_animate
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_shadow shadow unless $@
  def shadow
    return @shadow_name if @shadow_name != nil
    file = enemy.enemy_shadow_noteread
    if file != :nothing
      @shadow_name = file
      @shadow_name = "" if file.upcase == "OFF"
    else
      @shadow_name = bubs_tsbs_notetags_shadow # 詳見頁首繁中說明
    end
    @shadow_name
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_shadow_plus shadow_plus unless $@
  def shadow_plus
    return @shadow_plus if @shadow_plus != nil
    coordinate = enemy.enemy_shadow_plus_noteread
    if coordinate != :nothing
      @shadow_plus = coordinate
    else
      @shadow_plus = bubs_tsbs_notetags_shadow_plus # 詳見頁首繁中說明
    end
    @shadow_plus
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_position_plus position_plus unless $@
  def position_plus 
    return @position_plus if @position_plus != nil
    coordinate = enemy.enemy_position_plus_noteread
    if coordinate != :nothing
      @position_plus = coordinate
    else
      @position_plus = bubs_tsbs_notetags_position_plus # 詳見頁首繁中說明
    end
    @position_plus
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_weapon weapon unless $@
  def weapon
    return @enemy_weapon if @enemy_weapon != nil
    id = enemy.enemy_weapon_noteread
    if id != :nothing
      @enemy_weapon = id
    else
      @enemy_weapon = bubs_tsbs_notetags_enemy_weapon # 詳見頁首繁中說明
    end
    @enemy_weapon
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_collapse_type collapse_type unless $@
  def collapse_type
    return @enemy_collapse if @enemy_collapse != nil
    num = enemy.enemy_collapse_noteread
    if num != :nothing
      @enemy_collapse = num
    else
      @enemy_collapse = bubs_tsbs_notetags_enemy_collapse_type # 詳見頁首繁中說明
    end
    @enemy_collapse
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_action_time action_time unless $@
  def action_time
    return @multiact if @multiact != nil
    array = enemy.enemy_action_time_noteread
    if array != :nothing
      @multiact = array
    else
      @multiact = bubs_tsbs_notetags_action_time # 詳見頁首繁中說明
    end
    @multiact
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
  alias bubs_tsbs_notetags_enemy_charge charge unless $@
  def charge
    return @charge_values if @charge_values != nil 
    action = enemy.enemy_charge_noteread
    if action != :nothing
       @charge_values = action
    else
      @charge_values = bubs_tsbs_notetags_enemy_charge # 詳見頁首繁中說明
    end
    @charge_values
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_recharge recharge unless $@
  def recharge
    return @recharge_value if @recharge_value != nil 
    value = enemy.enemy_recharge_noteread
    if value != :nothing
       @recharge_value = value
    else
      @recharge_value = bubs_tsbs_notetags_enemy_recharge # 詳見頁首繁中說明
    end
    @recharge_value
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_atb_base atb_base unless $@
  def atb_base
    return @atb_base if @atb_base != nil 
    value = enemy.enemy_atb_base_noteread
    if value != :nothing
       @atb_base = value
    else
      @atb_base = bubs_tsbs_notetags_enemy_atb_base # 詳見頁首繁中說明
    end
    @atb_base
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_enemy_atb_on atb_on unless $@
  def atb_on
    return @atb_on if @atb_on != nil 
    value = enemy.enemy_atb_on_noteread
    if value != :nothing
       @atb_on = value
    else
      @atb_on = bubs_tsbs_notetags_enemy_atb_on # 詳見頁首繁中說明
    end
    @atb_on
  end
  
  end # 詳見頁首繁中說明
end # 詳見頁首繁中說明

#==========================================================================
#==========================================================================
class RPG::Skill
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_skill_base_action base_action unless $@
  def base_action
    return @action_key if @action_key != nil 
    action = base_action_noteread
    if action != :nothing
       @action_key = action
    else
      @action_key = bubs_tsbs_notetags_skill_base_action # 詳見頁首繁中說明
    end
    @action_key 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_skill_extension extension unless $@
  def extension
    return @extensions if @extensions != nil
    ext = skill_item_extension_noteread
    if !ext.empty?
      @extensions = ext
    else
      @extensions = bubs_tsbs_notetags_skill_extension # 詳見頁首繁中說明
    end
    @extensions
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_skill_flying_graphic flying_graphic unless $@
  def flying_graphic
    file = flying_graphic_noteread
    if file != :nothing
      @flygraphic = file
    else
      @flygraphic = bubs_tsbs_notetags_skill_flying_graphic # 詳見頁首繁中說明
    end
    @flygraphic
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
    
  alias bubs_tsbs_notetags_skill_charge charge unless $@
  def charge
    return @charge_values if @charge_values != nil 
    value = charge_noteread
    if value != :nothing
       @charge_values = value
    else
      @charge_values = bubs_tsbs_notetags_skill_charge # 詳見頁首繁中說明
    end
    @charge_values
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_skill_recharge recharge unless $@
  def recharge
    return @recharge_value if @recharge_value != nil 
    value = recharge_noteread
    if value != :nothing
       @recharge_value = value
    else
      @recharge_value = bubs_tsbs_notetags_skill_recharge # 詳見頁首繁中說明
    end
    @recharge_value
  end

  end # 詳見頁首繁中說明
end

#===========================================================================
#===========================================================================
class RPG::Item
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_item_base_action base_action unless $@
  def base_action
    return @action_key if @action_key != nil 
    action = base_action_noteread 
    if action != :nothing
      @action_key = action
    else
      @action_key = bubs_tsbs_notetags_item_base_action # 詳見頁首繁中說明
    end
    @action_key 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_item_flying_graphic flying_graphic unless $@
  def flying_graphic
    return @flygraphic if @flygraphic != nil
    file = flying_graphic_noteread
    if file != :nothing
      @flygraphic = file
    else
      @flygraphic = bubs_tsbs_notetags_item_flying_graphic # 詳見頁首繁中說明
    end
    @flygraphic
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
    
  alias bubs_tsbs_notetags_item_charge charge unless $@
  def charge
    return @charge_values if @charge_values != nil 
    array = charge_noteread
    if array != :nothing
       @charge_values = array
    else
      @charge_values = bubs_tsbs_notetags_item_charge # 詳見頁首繁中說明
    end
    @charge_values
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_item_recharge recharge unless $@
  def recharge
    return @recharge_value if @recharge_value != nil 
    value = recharge_noteread
    if value != :nothing
       @recharge_value = value
    else
      @recharge_value = bubs_tsbs_notetags_item_recharge # 詳見頁首繁中說明
    end
    @recharge_value
  end

  end # 詳見頁首繁中說明

end # 詳見頁首繁中說明
#==========================================================================
#==========================================================================
class RPG::Weapon
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_base_action base_action unless $@
  def base_action
    return @action_key if @action_key != nil 
    action = base_action_noteread
    if action != :nothing
      @action_key = action
    else
      @action_key = bubs_tsbs_notetags_weapon_base_action # 詳見頁首繁中說明
    end
    @action_key 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_graphic graphic unless $@
  def graphic
    return @weapon_graphic if @weapon_graphic != nil 
    file = weapon_graphic_noteread
    if file != :nothing
      @weapon_graphic = file
    else
      @weapon_graphic = bubs_tsbs_notetags_weapon_graphic # 詳見頁首繁中說明
    end
    @weapon_graphic 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_flying_graphic flying_graphic unless $@
  def flying_graphic
    return @flygraphic if @flygraphic != nil 
    flying = flying_graphic_noteread
    if flying != :nothing
      @flygraphic = flying
    else
      @flygraphic = bubs_tsbs_notetags_weapon_flying_graphic # 詳見頁首繁中說明
    end
    @flygraphic 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
    
  alias bubs_tsbs_notetags_weapon_charge charge unless $@
  def charge
    return @charge_values if @charge_values != nil 
    value = charge_noteread
    if value != :nothing
       @charge_values = value
    else
      @charge_values = bubs_tsbs_notetags_weapon_charge # 詳見頁首繁中說明
    end
    @charge_values
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_recharge recharge unless $@
  def recharge
    return @recharge_value if @recharge_value != nil 
    value = recharge_noteread
    if value != :nothing
       @recharge_value = value
    else
      @recharge_value = bubs_tsbs_notetags_weapon_recharge # 詳見頁首繁中說明
    end
    @recharge_value
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_charge_bonus charge_bonus unless $@
  def charge_bonus
    return @charge_bonus if @charge_bonus != nil 
    value = charge_bonus_noteread
    if value != :nothing
       @charge_bonus = value
    else
      @charge_bonus = bubs_tsbs_notetags_weapon_charge_bonus # 詳見頁首繁中說明
    end
    @charge_bonus
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_weapon_atb_base atb_base unless $@
  def atb_base
    return @atb_base if @atb_base != nil 
    value = atb_base_noteread
    if value != :nothing
       @atb_base = value
    else
      @atb_base = bubs_tsbs_notetags_weapon_atb_base # 詳見頁首繁中說明
    end
    @atb_base
  end

  end # 詳見頁首繁中說明

end

class RPG::Armor
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
    
  alias bubs_tsbs_notetags_armor_charge_bonus charge_bonus unless $@
  def charge_bonus
    return @charge_bonus if @charge_bonus != nil 
    value = charge_bonus_noteread
    if value != :nothing
       @charge_bonus = value
    else
      @charge_bonus = bubs_tsbs_notetags_armor_charge_bonus # 詳見頁首繁中說明
    end
    @charge_bonus
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_armor_atb_base atb_base unless $@
  def atb_base
    return @atb_base if @atb_base != nil 
    value = atb_base_noteread
    if value != :nothing
       @atb_base = value
    else
      @atb_base = bubs_tsbs_notetags_armor_atb_base # 詳見頁首繁中說明
    end
    @atb_base
  end
  
  end # 詳見頁首繁中說明
end

#==========================================================================
#==========================================================================
class RPG::State
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_state_base_action base_action unless $@
  def base_action
    return @state_action if @state_action != nil 
    action = state_base_action_noteread
    if action != :nothing
      @state_action = action
    else
      @state_action = bubs_tsbs_notetags_state_base_action # 詳見頁首繁中說明
    end
    @state_action 
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_state_extension extension unless $@
  def extension
    return @extensions if @extensions != nil
    ext = state_extension_noteread
    if !ext.empty?
      @extensions = ext
    else
      @extensions = bubs_tsbs_notetags_state_extension # 詳見頁首繁中說明
    end
    @extensions
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_state_slip_extension slip_extension unless $@
  def slip_extension
    return @slip_values if @slip_values != nil
    array = state_slip_extension_all_noteread
    if !array.empty?
      @slip_values = array
    else
      @slip_values = bubs_tsbs_notetags_state_slip_extension # 詳見頁首繁中說明
    end
    @slip_values
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  if $imported["TankentaiATB"]
    
  alias bubs_tsbs_notetags_atb_damage atb_damage unless $@
  def atb_damage
    return @atb_damage if @atb_damage != nil 
    value = atb_damage_noteread
    if value != :nothing
       @atb_damage = value
    else
      @atb_damage = bubs_tsbs_notetags_atb_damage # 詳見頁首繁中說明
    end
    @atb_damage
  end
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  alias bubs_tsbs_notetags_atb_minus_damage atb_minus_damage unless $@
  def atb_minus_damage
    return @atb_minus_damage if @atb_minus_damage != nil 
    value = atb_minus_damage_noteread
    if value != :nothing
       @atb_minus_damage = value
    else
      @atb_minus_damage = bubs_tsbs_notetags_atb_minus_damage # 詳見頁首繁中說明
    end
    @atb_minus_damage
  end

  end # 詳見頁首繁中說明
end

#==========================================================================
#==========================================================================
module RPG
  class BaseItem; include Bubs::TankentaiBaseItemTags; end
  class Enemy; include Bubs::TankentaiEnemyTags; end
  class State; include Bubs::TankentaiStateTags; end
end