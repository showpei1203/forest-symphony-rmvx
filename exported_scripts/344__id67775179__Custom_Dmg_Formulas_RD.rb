#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Custom Dmg Formulas RD
# 【用途】Yanfly Engine RD 自訂傷害公式底層，提供普通攻擊、技能、暴擊、防禦、Slip Damage 與 Notetag／Lunatic Formula 擴充。
# 【版本】Last Date Updated: 2009.06.10；Level: Easy / Normal / Hard / Lunatic。
# 【FS Authority 注意】此頁不是最終傷害 Authority；後方仍有 FS_BattleFormula、BattleBalance、角色機制、State／Element Guard 等包裝。不要因看到 make_obj_damage_value 就直接搬到鏈尾。
# 【Easy Mode／主要常數】
#   NATK：ATK_X/AGI_X/SPI_X/DEF_X 為普通攻擊乘數；MIN_DMG 最低普通攻擊傷害；VARYDMG 普攻隨機變動。
#   CRIT：CRIT_MOD / CRIT_DIV 決定暴擊傷害倍率；CRIT_NORMAL / CRIT_SKILL 控制普攻／技能是否允許暴擊。
#   SKILL：ATK_F/DEF_F/SPI_F/AGI_F 為施術者能力乘數；ATK_D/DEF_D/SPI_D/AGI_D 為防守方對各能力來源的減算乘數。
#   OTHER：PHARMACIST 道具效果倍率；GUARD_NORMAL/GUARD_SUPER 防禦減傷；SLIP_MAXHP_X/SLIP_FIELDMG Slip Damage 設定。
#   <atk_f x> / <spi_f x>：覆蓋技能 Attack F / Spirit F；可突破資料庫 200 上限。
#   <def_f x> / <agi_f x>：加入 DEF / AGI 乘數；100=100%、200=200%。
#   <hp_hi x> / <hp_lo x> / <mp_hi x> / <mp_lo x>：依施術者目前 HP/MP 高低修正傷害。
#   <mul level> / <div level> / <add level> / <sub level>：以使用者等級乘／除／加／減；Enemy 使用時忽略等級項。
#   <mulvar x> / <divvar x> / <addvar x> / <subvar x>：以遊戲變數 x 對 variance 前傷害做乘／除／加／減。
#   <critical x>：指定技能暴擊機率並覆蓋 Battler 預設暴擊能力；<no crit>：禁止該技能暴擊。
# 【Lunatic Mode】Skill Note 使用 <custom x> 指定下方自訂公式 ID；公式最後必須把結果寫回 damage。
# 【Lunatic 可用值】user/self 分別代表施術者／目標；可讀 hp/maxhp/mp/maxmp/atk/def/spi/agi/hit/eva；obj 可讀 base_damage/atk_f/spi_f/variance。Actor 等級可用 user.level/self.level，但 Enemy 沒有 Actor level，原文件要求自行做類型判斷。
# 【運算】遵守 Ruby 一般優先序：次方、乘除、加減；可用 Math.exp、Math.sqrt、rand、floor、ceil、%、括號。
# 【共用 Hook】common_damage_apply 為最後共通傷害修正；common_critical 為共通暴擊判定；critical_damage 為暴擊傷害修正入口。FS 後續腳本可能再次包裝，修改前先查 Method Chain。
# 【相容性】原文件 Works With: Custom Element Affinity；並覆寫／定義 Game_Battler 的攻擊、技能傷害、HP recovery、Guard、Slip Damage 等流程。
# 【範例】Skill Note：<atk_f 250>、<mulvar 10>、<critical 25>、<custom 3>。
# 【來源】Yanfly Engine RD；完整原始更新紀錄與英文手冊保存於 Phase 16 Archive。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["CustomDmgFormulaRD"] = true

module YE
 
  module BATTLE
   
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
   
    module NATK
      ATK_X = 2
      AGI_X = 0
      SPI_X = 0
      DEF_X = 1
      MIN_DMG = 1
      VARYDMG = 5
    end # module Normal Attacks
   
    module CRIT
      CRIT_MOD = 200
      CRIT_DIV = 100
     
      CRIT_NORMAL = true
      CRIT_SKILL  = true
    end
   
    module SKILL
      ATK_F = 2
      DEF_F = 2
      SPI_F = 2
      AGI_F = 2
      ATK_D = 1
      DEF_D = 1
      SPI_D = 1
      AGI_D = 1
    end # module Skills
   
    module OTHER
      PHARMACIST  = 2
      GUARD_NORMAL = 2
      GUARD_SUPER  = 4
      SLIP_MAXHP_X = 5
      SLIP_FIELDMG = 1
    end # module Other
   
  end # module BATTLE
 
end # module YE

#===============================================================================
#===============================================================================
#
#
# -----------------------------------------------------------------------------
#
#
#  原始設置 damage *= elements_max_rate(obj.element_set) 
#  damage *= elements_max_rate(user.element_set) 攻擊加乘屬性設置
#
#
# -----------------------------------------------------------------------------
# Math.exp(x)：回傳 e 的 x 次方。
# Math.sqrt(x)：回傳平方根。
# rand(x)：回傳 0...x 範圍的隨機數。
#
#
#
#
#
#===============================================================================

class Game_Battler
 
  def run_cdf(user, obj, formula)
    @heal_skill = false
    @ignore_def = false
    @ignore_ele = false
    @ignore_var = false
    @ignore_blk = false
    @critical  = false
    hp_dmg = 0
    mp_dmg = 0
    damage = 0
    
    level = user.level
    power = obj.base_damage > 0 ? obj.base_damage : 50
    attack = obj.atk_f > 0 ? user.atk * obj.atk_f / 100 : user.atk
    spirit = obj.spi_f > 0 ? user.spi * obj.spi_f / 100 : user.spi
    defense = obj.spi_f > 0 ? self.spi : self.def
    random_factor = rand(85..100) / 100.0
    
    case formula
   
    #---------------------------------------------------------------------------
    # //////////////////////////////////////////////////////////////////////////
    #---------------------------------------------------------------------------
   
    when 1
      damage = user.level * user.maxhp
      @ignore_def = true
     
    when 2
      damage = user.level * user.maxmp * user.mp
      @ignore_def = true
     
    when 3
      damage = 0
      @ignore_def = true
   
    when 4 # 可設置根據敵方數值的傷害This is custom damage formula number four.
      damage += user.hp if self.state?(2)
      
    when 5#熊加成
      damage = obj.base_damage
      damage += user.atk * 1.5 * obj.atk_f / 100
      damage -= self.def * 0.5 * obj.atk_f / 100
      
      damage *= elements_max_rate(obj.element_set)    # 屬性調整
      damage /= 100
      damage = apply_variance(damage, obj.variance)   # 分散度
      damage = apply_guard(damage)                    # 防禦調整
      
      damage += $game_variables[105] * 10#親密度
      @weak = true if elements_max_rate(obj.element_set) > 100
      @strong = true if elements_max_rate(obj.element_set) < 100
    #if n > 200
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_s])
    #elsif n > 150
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_a])
    #elsif n > 100
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_b])
    #end
    
    when 6#狼加成
      damage = obj.base_damage * obj.spi_f/100
      damage += $game_variables[105] * 10
      
    when 7 #斧龍捲
      damage = (user.atk*4) - (self.def*2)
      damage += user.hp / 8
      
    when 8 #燃怒劈擊
      damage = obj.base_damage
      damage += user.atk
    
    when 9 # 物理傷害公式（基於攻擊）
      damage = (((((2 * level / 5.0) + 2) * power * (attack.to_f / self.def.to_f)) / 50) + 2)
      damage = 1 if damage < 1
    when 10 # 特殊傷害公式（基於精神力）
      damage = (((((2 * level / 5.0) + 2) * power * (spirit.to_f / ((self.spi.to_f + self.def.to_f) / 2))) / 50) + 2)
      damage = 1 if damage < 1
    when 11 # 混合傷害公式（攻擊與魔攻平均）
      damage = (((((2 * level / 5.0) + 2) * power * ((attack + spirit).to_f / (self.def + self.mdf).to_f)) / 50) + 2)
    
    #---------------------------------------------------------------------------
    # //////////////////////////////////////////////////////////////////////////
    #---------------------------------------------------------------------------
    end
    if @heal_skill == false
      damage = YE::BATTLE::NATK::MIN_DMG if damage < YE::BATTLE::NATK::MIN_DMG
    end
    damage = common_damage_apply(damage)
    unless @ignore_def
      damage -= self.def * YE::BATTLE::SKILL::ATK_D * obj.atk_f / 100
      damage -= self.def * YE::BATTLE::SKILL::DEF_D * obj.def_f / 100
      damage -= self.def * YE::BATTLE::SKILL::SPI_D * obj.spi_f / 100
      damage -= self.def * YE::BATTLE::SKILL::AGI_D * obj.agi_f / 100
    end
    unless @ignore_ele
      if $imported["CustomElementAffinity"]
        damage *= elements_max_rate(obj.element_set, user)
      else
        damage *= elements_max_rate(obj.element_set)
      end
      damage /= 100
    end
    common_critical(user, obj)
    @critical = false if prevent_critical
    @critical = false if obj.no_crit
    if @critical
      damage = critical_damage(damage)
    end
    if @ignore_var == false
      damage = apply_variance(damage, obj.variance)
    end
    if @ignore_blk == false
      damage = apply_guard(damage)
    end
    if obj.damage_to_mp
      @mp_damage = damage
    else
      @hp_damage = damage
    end
    @mp_damage += mp_dmg
    @hp_damage += hp_dmg
  end
 
  #-----------------------------------------------------------------------------
  def common_damage_apply(damage)
    if damage > 0
    else
    end
    return damage
  end
  #-----------------------------------------------------------------------------
 
  #-----------------------------------------------------------------------------
  def common_critical(user, skill = nil)
    if skill == nil
    else
    end
    #---
  end
  #-----------------------------------------------------------------------------
 
  #-----------------------------------------------------------------------------
  def critical_damage(damage)
    damage *= YE::BATTLE::CRIT::CRIT_MOD
    damage /= YE::BATTLE::CRIT::CRIT_DIV
    return damage
  end
  #-----------------------------------------------------------------------------
 
end

#===============================================================================
#===============================================================================

module YE
  module REGEXP
    module BASEITEM
      CUSTOMDMF = /<(?:CUSTOM|custom damage)[ ]*(\d+)>/i
      ATK_F_TAG = /<(?:ATK_F|atk f)[ ]*(\d+)>/i
      DEF_F_TAG = /<(?:DEF_F|def f)[ ]*(\d+)>/i
      SPI_F_TAG = /<(?:SPI_F|spi f)[ ]*(\d+)>/i
      AGI_F_TAG = /<(?:AGI_F|agi f)[ ]*(\d+)>/i
      HP_HI_TAG = /<(?:HP_HI|hp hi)[ ]*(\d+)>/i
      HP_LO_TAG = /<(?:HP_LO|hp lo)[ ]*(\d+)>/i
      MP_HI_TAG = /<(?:MP_HI|mp hi)[ ]*(\d+)>/i
      MP_LO_TAG = /<(?:MP_LO|mp lo)[ ]*(\d+)>/i
      MUL_LEVEL = /<(?:MUL_LEVEL|mul level)>/i
      DIV_LEVEL = /<(?:DIV_LEVEL|div level)>/i
      ADD_LEVEL = /<(?:ADD_LEVEL|add level)>/i
      SUB_LEVEL = /<(?:SUB_LEVEL|sub level)>/i
      MUL_VARIABLE = /<(?:MULVAR|mul var)[ ]*(\d+)>/i
      DIV_VARIABLE = /<(?:DIVVAR|div var)[ ]*(\d+)>/i
      ADD_VARIABLE = /<(?:ADDVAR|add var)[ ]*(\d+)>/i
      SUB_VARIABLE = /<(?:SUBVAR|sub var)[ ]*(\d+)>/i
      NO_CRIT  = /<(?:NO_CRIT|no crit)>/i
      CRITICAL = /<(?:CRITICAL|critical hit)[ ]*(\d+)>/i
    end
  end # module REGEXP
end # module YE

#===============================================================================
# RPG::BaseItem
#===============================================================================

class RPG::BaseItem
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yanfly_cache_cdf
    @acdf = 0; @newatk_f = 0; @def_f = 0; @newspi_f = 0; @agi_f = 0
    @hp_hi = 0; @hp_lo = 0; @mp_hi = 0; @mp_lo = 0; @mul_level = false
    @div_level = false; @add_level = false; @sub_level = false
    @mul_var = 0; @div_var = 0; @add_var = 0; @sub_var = 0
    @no_crit = false; @critical_chance = 0
   
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::BASEITEM::CUSTOMDMF
        @acdf = $1.to_i
       
      when YE::REGEXP::BASEITEM::ATK_F_TAG
        @newatk_f = $1.to_i
      when YE::REGEXP::BASEITEM::DEF_F_TAG
        @def_f = $1.to_i
      when YE::REGEXP::BASEITEM::SPI_F_TAG
        @newspi_f = $1.to_i
      when YE::REGEXP::BASEITEM::AGI_F_TAG
        @agi_f = $1.to_i
         
      when YE::REGEXP::BASEITEM::HP_HI_TAG
        @hp_hi = $1.to_i
      when YE::REGEXP::BASEITEM::HP_LO_TAG
        @hp_lo = $1.to_i
      when YE::REGEXP::BASEITEM::MP_HI_TAG
        @mp_hi = $1.to_i
      when YE::REGEXP::BASEITEM::MP_LO_TAG
        @mp_lo = $1.to_i
       
      when YE::REGEXP::BASEITEM::MUL_LEVEL
        @mul_level = true
      when YE::REGEXP::BASEITEM::DIV_LEVEL
        @div_level = true
      when YE::REGEXP::BASEITEM::ADD_LEVEL
        @add_level = true
      when YE::REGEXP::BASEITEM::SUB_LEVEL
        @sub_level = true
       
      when YE::REGEXP::BASEITEM::MUL_VARIABLE
        @mul_var = $1.to_i
      when YE::REGEXP::BASEITEM::DIV_VARIABLE
        @div_var = $1.to_i
      when YE::REGEXP::BASEITEM::ADD_VARIABLE
        @add_var = $1.to_i
      when YE::REGEXP::BASEITEM::SUB_VARIABLE
        @sub_var = $1.to_i
       
      when YE::REGEXP::BASEITEM::NO_CRIT
        @no_crit = true
      when YE::REGEXP::BASEITEM::CRITICAL
        @critical_chance = $1.to_i
     
      end
    }
  end # end yanfly_cache_cdf
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def acdf
    yanfly_cache_cdf if @acdf == nil
    return @acdf
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def newatk_f
    yanfly_cache_cdf if @newatk_f == nil
    return @newatk_f
  end
 
  def def_f
    yanfly_cache_cdf if @def_f == nil
    return @def_f
  end
 
  def newspi_f
    yanfly_cache_cdf if @newspi_f == nil
    return @newspi_f
  end
 
  def agi_f
    yanfly_cache_cdf if @agi_f == nil
    return @agi_f
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def hp_hi
    yanfly_cache_cdf if @hp_hi == nil
    return @hp_hi
  end
 
  def hp_lo
    yanfly_cache_cdf if @hp_lo == nil
    return @hp_lo
  end
 
  def mp_hi
    yanfly_cache_cdf if @mp_hi == nil
    return @mp_hi
  end
 
  def mp_lo
    yanfly_cache_cdf if @mp_lo == nil
    return @mp_lo
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mul_level
    yanfly_cache_cdf if @mul_level == nil
    return @mul_level
  end
 
  def div_level
    yanfly_cache_cdf if @div_level == nil
    return @div_level
  end
 
  def add_level
    yanfly_cache_cdf if @add_level == nil
    return @add_level
  end
 
  def sub_level
    yanfly_cache_cdf if @sub_level == nil
    return @sub_level
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mul_variable
    yanfly_cache_cdf if @mul_var == nil
    return @mul_var
  end
 
  def div_variable
    yanfly_cache_cdf if @div_var == nil
    return @div_var
  end
 
  def add_variable
    yanfly_cache_cdf if @add_var == nil
    return @add_var
  end
 
  def sub_variable
    yanfly_cache_cdf if @sub_var == nil
    return @sub_var
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def no_crit
    yanfly_cache_cdf if @no_crit == nil
    return @no_crit
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def critical_chance
    yanfly_cache_cdf if @critical_chance == nil
    return @critical_chance
  end
 
end # end RPG::BaseItem

#===============================================================================
# Game_Battler
#===============================================================================

class Game_Battler
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def make_attack_damage_value(attacker)
    
    level = attacker.level
    power = 50 # 預設普通攻擊威力
    attack = attacker.atk
    defense = self.def
    random_factor = rand(85..100) / 100.0
    
    damage = (((((2 * level / 5.0) + 2) * power * (attack.to_f / defense.to_f)) / 50) + 2).to_i
    damage = (damage * random_factor).to_i
=begin
    damage = attacker.atk * YE::BATTLE::NATK::ATK_X
    damage += attacker.spi * YE::BATTLE::NATK::SPI_X
    damage += attacker.agi * YE::BATTLE::NATK::AGI_X
    damage -= self.def * YE::BATTLE::NATK::DEF_X
    damage = YE::BATTLE::NATK::MIN_DMG if damage < YE::BATTLE::NATK::MIN_DMG
=end
    
    if $imported["CustomElementAffinity"]
      damage *= elements_max_rate(attacker.element_set, attacker)
    else
      damage *= elements_max_rate(attacker.element_set)
      @weak = true if elements_max_rate(attacker.element_set) > 100
      @strong = true if elements_max_rate(attacker.element_set) < 100
    end
    
    damage /= 100
    damage = common_damage_apply(damage)
    if (damage > 0) and YE::BATTLE::CRIT::CRIT_NORMAL
      @critical = (rand(100) < attacker.cri)
      common_critical(attacker)
      @critical = false if prevent_critical
      if @critical
        damage = critical_damage(damage)
      end
    end
    
    damage = apply_variance(damage, YE::BATTLE::NATK::VARYDMG)
    damage = apply_guard(damage)
    
    #魔力增幅94
    if attacker.actor?
     if attacker.armors.include?($data_armors[94])
      if attacker.mp >= 5
      attacker.mp -= 5
      damage = ((attacker.spi*2) - self.spi)
      else
      end
     end
    end
   
    #測試91
    if attacker.actor?
     damage += self.atk if attacker.armors.include?($data_armors[91])
    end
    #傷害擴散
    if attacker.actor?
     damage = attacker.atk*2 - self.def if attacker.armors.include?($data_armors[213])
     damage = damage/2 if attacker.armors.include?($data_armors[213])
   end
   
   #######普攻帶屬性###########################################################
   ###帶火屬性
   if attacker.actor?
   if attacker.armors.include?($data_armors[86])
     attacker.animation_id = 179
   end
   end
   ###帶冰屬性
   if attacker.actor?
   if attacker.armors.include?($data_armors[87])
     attacker.animation_id = 180
   end
   end
   ###帶雷屬性
   if attacker.actor?
   if attacker.armors.include?($data_armors[88])
     attacker.animation_id = 181
   end
   end
   ###帶岩屬性
   if attacker.actor?
   if attacker.armors.include?($data_armors[89])
     attacker.animation_id = 182
   end
   end
    
   ###帶風屬性
   if attacker.actor?
   if attacker.armors.include?($data_armors[90])
     attacker.animation_id = 183
   end
   end
   ############################################################################
    ####確認傷害語句
    @hp_damage = damage
    ####
    
    # Armor 212 普攻吸血政策由 Equipment Runtime Authority 管理。
    # 呼叫位置維持原樣，仍由 Tankentai force_damage 延後回復／顯示 Popup。
    if attacker.actor?
    FS_EQUIPMENT_RUNTIME.queue_legacy_attack_drain(attacker, damage)
    end
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def make_obj_damage_value(user, obj)
    if obj.acdf > 0
      run_cdf(user, obj, obj.acdf)
    else
      damage = obj.base_damage
      if damage > 0
        #--------------------------------------------------------------------
       
        if obj.mul_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage *= user.level
        end
        if obj.div_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage /= user.level
        end
       
        if obj.mul_variable > 0
          damage *= $game_variables[obj.mul_variable]
        end
        if obj.div_variable > 0
          damage /= $game_variables[obj.div_variable]
        end
       
        if obj.newatk_f > 0
          damage += user.atk * YE::BATTLE::SKILL::ATK_F * obj.newatk_f / 100
          damage -= self.def * YE::BATTLE::SKILL::ATK_D * obj.newatk_f / 100 unless obj.ignore_defense
        else
          damage += user.atk * YE::BATTLE::SKILL::ATK_F * obj.atk_f / 100
          damage -= self.def * YE::BATTLE::SKILL::ATK_D * obj.atk_f / 100 unless obj.ignore_defense
        end
       
        if obj.def_f > 0
          damage += user.def * YE::BATTLE::SKILL::DEF_F * obj.def_f / 100
          damage -= self.def * YE::BATTLE::SKILL::DEF_D * obj.def_f / 100 unless obj.ignore_defense
        end
       
        if obj.newspi_f > 0
          damage += user.def * YE::BATTLE::SKILL::SPI_F * obj.newspi_f / 100
          damage -= self.def * YE::BATTLE::SKILL::SPI_D * obj.newspi_f / 100 unless obj.ignore_defense
        else
          damage += user.spi * YE::BATTLE::SKILL::SPI_F * obj.spi_f / 100
          damage -= self.spi * YE::BATTLE::SKILL::SPI_D * obj.spi_f / 100 unless obj.ignore_defense
        end
       
        if obj.agi_f > 0
          damage += user.def * YE::BATTLE::SKILL::AGI_F * obj.agi_f / 100
          damage -= self.def * YE::BATTLE::SKILL::AGI_D * obj.agi_f / 100 unless obj.ignore_defense
        end
       
        damage += user.hp * obj.hp_hi / 100 if obj.hp_hi > 0
        damage += (user.maxhp - user.hp) * obj.hp_lo / 100 if obj.hp_lo > 0
       
        damage += user.mp * obj.mp_hi / 100 if obj.mp_hi > 0
        damage += (user.maxmp - user.mp) * obj.mp_lo / 100 if obj.mp_lo > 0
       
        if obj.add_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage += user.level
        end
        if obj.sub_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage -= user.level
        end
       
        if obj.add_variable > 0
          damage += $game_variables[obj.add_variable] * 5###
        end
        if obj.sub_variable > 0
          damage -= $game_variables[obj.sub_variable]
        end
       
        damage = YE::BATTLE::NATK::MIN_DMG if damage < YE::BATTLE::NATK::MIN_DMG
        #--------------------------------------------------------------------
       
      elsif damage < 0
        #--------------------------------------------------------------------
        if obj.mul_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage *= user.level
        end
        if obj.div_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage /= user.level
        end
       
        if obj.mul_variable > 0
          damage *= $game_variables[obj.mul_variable]
        end
        if obj.div_variable > 0
          damage /= $game_variables[obj.div_variable]
        end
       
        if obj.newatk_f > 0
          damage -= user.atk * YE::BATTLE::SKILL::ATK_F * obj.newatk_f / 100
        else
          damage -= user.atk * YE::BATTLE::SKILL::ATK_F * obj.atk_f / 100
        end
       
        if obj.def_f > 0
          damage -= user.def * YE::BATTLE::SKILL::DEF_F * obj.def_f / 100
        end
       
        if obj.newspi_f > 0
          damage -= user.spi * YE::BATTLE::SKILL::SPI_F * obj.newspi_f / 100
        else
          damage -= user.spi * YE::BATTLE::SKILL::SPI_F * obj.spi_f / 100
        end
       
        if obj.agi_f > 0
          damage -= user.def * YE::BATTLE::SKILL::AGI_F * obj.agi_f / 100
        end
       
        damage -= user.hp * obj.hp_hi / 100 if obj.hp_hi > 0
        damage -= (user.maxhp - user.hp) * obj.hp_lo / 100 if obj.hp_lo > 0
       
        damage -= user.mp * obj.mp_hi / 100 if obj.mp_hi > 0
        damage -= (user.maxmp - user.mp) * obj.mp_lo / 100 if obj.mp_lo > 0
       
        if obj.add_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage += user.level
        end
        if obj.sub_level and (user.is_a?(Game_Actor) or $imported["EnemyLevelControl"])
          damage -= user.level
        end
       
        if obj.add_variable > 0
          damage += $game_variables[obj.add_variable]
        end
        if obj.sub_variable > 0
          damage -= $game_variables[obj.sub_variable]
        end
        #--------------------------------------------------------------------
      end
      damage = common_damage_apply(damage)
      if $imported["CustomElementAffinity"]
        damage *= elements_max_rate(obj.element_set, user)
      else
        damage *= elements_max_rate(obj.element_set)
        @weak = true if elements_max_rate(obj.element_set) > 100
        @strong = true if elements_max_rate(obj.element_set) < 100
    #if n > 200
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_s])
    #elsif n > 150
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_a])
    #elsif n > 100
    #  gain_stun(YEZ::STAT::STUN_CALC[:element_b])
    #end
      end
      damage /= 100
      if (damage > 0) and YE::BATTLE::CRIT::CRIT_SKILL
        if obj.critical_chance > 0
          @critical = (rand(100) < obj.critical_chance)
        else
          @critical = (rand(100) < user.cri)
        end
      end
      common_critical(user, obj)
      @critical = false if prevent_critical
      @critical = false if obj.no_crit
      if @critical
        damage *= YE::BATTLE::CRIT::CRIT_MOD
        damage /= YE::BATTLE::CRIT::CRIT_DIV
      end
      damage = apply_variance(damage, obj.variance)
      damage = apply_guard(damage)
      if obj.damage_to_mp 
        @mp_damage = damage
      else
        @hp_damage = damage
      end
    end
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def calc_hp_recovery(user, item)
    result = maxhp * item.hp_recovery_rate / 100 + item.hp_recovery
    result *= YE::BATTLE::OTHER::PHARMACIST if user.pharmacology   
    return result
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    if damage > 0 and guarding?                   
      damage /= super_guard ? YE::BATTLE::OTHER::GUARD_SUPER : YE::BATTLE::OTHER::GUARD_NORMAL
    end
    return damage
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  if $imported["SlipDamageExtension"] == false
    def slip_damage_effect
      if slip_damage? and @hp > 0
        @hp_damage = apply_variance(maxhp / YE::BATTLE::OTHER::SLIP_MAXHP_X, YE::BATTLE::OTHER::SLIP_FIELDMG)
        @hp_damage = @hp - 1 if @hp_damage >= @hp
        self.hp -= @hp_damage
      end
    end
  end
 
end # Game_Battler

#===============================================================================
#
#
#===============================================================================