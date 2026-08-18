#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_AddEquipmentOptions
# 【來源】KGC Equipment Effects / KGC_AddEquipmentOptions，2008-04-01，英文翻譯 Mr. Anonymous。
# 【用途】透過 Weapon／Armor Note 為裝備增加 VX 原生沒有的效果：多段普通攻擊、HP/MP 自動回復、MP Convert/Absorb、元素抗性／弱點／半減／無效／吸收、State 抗性，以及 Critical／Half MP／EXP／Fast／Dual Attack 等。
# 【預設值】DEFAULT_RECOVER_HP_RATE=5%、DEFAULT_RECOVER_MP_RATE=5%、DEFAULT_CONVERT_MP_RATE=1%、DEFAULT_ABSORB_MP_RATE=5%。Notetag 未明寫百分比時使用這些值。
# 【BaseItem Notetag】<n TIMES_ATTACK>／<n multiatk>；<auto HP recover n%>；<auto MP recover n%>；<MP convert n%>；<MP absorb n%>；<element resist ElementID:Rate%>；<element weakness ids>；<element half ids>；<element null ids>；<element absorb ids>；<state resist StateID:Rate%>。
# 【Weapon Notetag】<prevent critical>、<half MP cost>、<double exp>。
# 【Armor Notetag】<fast attack>、<dual attack>、<critical bonus>、<attack element ids>、<plus state ids>。原文件部分效果旁註「沒用」反映舊專案實測狀態；目前是否生效要以 FS 後續 Authority 與實機驗證為準，不應只依原手冊判斷。
# 【主要 Runtime】重開 RPG::BaseItem/Weapon/Armor 的 cache；Game_Battler 的 make_attack_damage_value／make_obj_damage_value、MP conversion/absorb；Game_BattleAction#make_attack_targets；Game_Actor 的 element_rate、state_probability、element_set、plus_state_set、cri 與多個 trait；Scene_Battle#display_hp_damage。
# 【依賴／為何不能回併】KGC_PassiveSkill 直接讀本頁 AddEquipmentOptions；後方 FS Element、State、EquipmentCombo、MechanicExpansion、BattleFormula 等又繼續包 element_rate／state_probability／make_obj_damage_value。Phase 18 稽核確認這是一條正式 staged chain，不能為了頁數漂亮搬動。
# 【設定方式】所有效果都寫在 Database Note；Notetag 字串是 Runtime API，不可翻譯。若新增新的 regexp tag，需同步檢查 PassiveSkill 與 Equipment Overhaul 是否會取用相同能力。
# 【相關素材】無固定 Graphics／Audio；資料來源為 Weapon／Armor Note 與戰鬥 Runtime。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/-----------------------------------------------------------------------------
#_/=============================================================================
#_/=============================================================================
#_/
#_/  
#_/
#_/  
#_/  <auto MP recover Rate %>沒用
#_/  
#_/  <MP absorb Rate %>沒用
#_/
#_/  <MP convert Rate %>沒用
#_/
#_/  
#_/  
#_/  
#_/  
#_/  
#_/  
#_/
#_/  
#_/  
#_/
#_/  
#_/  <fast attack>沒用
#_/  
#_/  <dual attack>沒用
#_/
#_/  
#_/  
#_/=============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_

#==============================================================================#
#==============================================================================#

module KGC
 module AddEquipmentOptions
  DEFAULT_RECOVER_HP_RATE = 5
  DEFAULT_RECOVER_MP_RATE = 5

  DEFAULT_CONVERT_MP_RATE = 1
  DEFAULT_ABSORB_MP_RATE  = 5
 end
end

## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

$imported = {} if $imported == nil
$imported["AddEquipmentOptions"] = true

module KGC::AddEquipmentOptions
  module Regexp
    module BaseItem
      MULTI_ATTACK = /<(\d+)\s*(?:TIMES_ATTACK|multiatk)>/i
      AUTO_HP_RECOVER = /<(?:AUTO_HP_RECOVER|auto HP recover)(\s*(\d+)([%％])?)?>/i
      AUTO_MP_RECOVER = /<(?:AUTO_MP_RECOVER|auto MP recover)(\s*(\d+)([%％])?)?>/i
      CONVERT_MP = /<(?:CONVERT_MP|MP convert)\s*(\d+)?[%％]?>/i
      ABSORB_MP = /<(?:ABSORB_MP|MP absorb)\s*(\d+)?[%％]?>/i

      ELEMENT_RESISTANCE =
        /<(?:ELEMENT_RESISTANCE|element resist)\s*(\d+):(\-?\d+)[%％]?>/i
      WEAK_ELEMENT =
        /<(?:WEAK_ELEMENT|element weakness)\s*(\d+(?:\s*,\s*\d+)*)>/i
      GUARD_ELEMENT =
        /<(?:GUARD_ELEMENT|element half)\s*(\d+(?:\s*,\s*\d+)*)>/i
      INVALID_ELEMENT =
        /<(?:INVALID_ELEMENT|element null)\s*(\d+(?:\s*,\s*\d+)*)>/i
      ABSORB_ELEMENT =
        /<(?:ABSORB_ELEMENT|element absorb)\s*(\d+(?:\s*,\s*\d+)*)>/i
      STATE_RESISTANCE =
        /<(?:STATE_RESISTANCE|state resist)\s*(\d+):(\d+)[%％]?>/i
    end

    module Weapon
      PREVENT_CRITICAL = /<(?:PREVENT_CRITICAL|prevent critical)>/i
      HALF_MP_COST = /<(?:HALF_MP_COST|half MP cost)>/i
      DOUBLE_EXP_GAIN = /<(?:DOUBLE_EXP_GAIN|double exp)>/i
    end

    module Armor
      FAST_ATTACK = /<(?:FAST_ATTACK|fast attack)>/i
      DUAL_ATTACK = /<(?:DUAL_ATTACK|dual attack)>/i
      CRITICAL_BONUS = /<(?:CRITICAL_BONUS|critical bonus)>/i
      ATTACK_ELEMENT =
        /<(?:ATTACK_ELEMENT|attack element)\s*(\d+(?:\s*,\s*\d+)*)>/i
      PLUS_STATE = /<(?:PLUS_STATE|plus state)\s*(\d+(?:\s*,\s*\d+)*)>/i
    end
  end
end

#==============================================================================
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_add_equipment_options_cache
    @__multi_attack_count = 1
    @__auto_hp_recover = false
    @__auto_hp_recover_value = 0
    @__auto_hp_recover_rate = 0
    @__auto_mp_recover = false
    @__auto_mp_recover_value = 0
    @__auto_mp_recover_rate = 0
    @__convert_mp_rate = 0
    @__absorb_mp_rate = 0

    @note.split(/[\r\n]+/).each { |line|
      case line
      when KGC::AddEquipmentOptions::Regexp::BaseItem::MULTI_ATTACK
        # n回攻撃
        @__multi_attack_count = [$1.to_i, 1].max
      when KGC::AddEquipmentOptions::Regexp::BaseItem::AUTO_HP_RECOVER
        # HP自動回復
        @__auto_hp_recover = true
        next if $1 == nil
        if $3 != nil
          @__auto_hp_recover_rate += $2.to_i
        else
          @__auto_hp_recover_value += $2.to_i
        end
      when KGC::AddEquipmentOptions::Regexp::BaseItem::AUTO_MP_RECOVER
        # MP自動回復
        @__auto_mp_recover = true
        next if $1 == nil
        if $3 != nil
          @__auto_mp_recover_rate += $2.to_i
        else
          @__auto_mp_recover_value += $2.to_i
        end
      when KGC::AddEquipmentOptions::Regexp::BaseItem::CONVERT_MP
        # MP転換
        @__convert_mp_rate = ($1 != nil ?
          $1.to_i : KGC::AddEquipmentOptions::DEFAULT_CONVERT_MP_RATE)
      when KGC::AddEquipmentOptions::Regexp::BaseItem::ABSORB_MP
        # MP吸収
        @__absorb_mp_rate = ($1 != nil ?
          $1.to_i : KGC::AddEquipmentOptions::DEFAULT_ABSORB_MP_RATE)
      end
    }

    create_resistance_cache
  end
  #--------------------------------------------------------------------------
  # ○ 耐性のキャッシュ生成
  #--------------------------------------------------------------------------
  def create_resistance_cache
    @__element_resistance = []
    @__weak_element_set = []
    @__guard_element_set = []
    @__invalid_element_set = []
    @__absorb_element_set = []

    @__state_resistance = []

    @note.split(/[\r\n]+/).each { |line|
      case line
      when KGC::AddEquipmentOptions::Regexp::BaseItem::ELEMENT_RESISTANCE
        # 属性耐性
        element_id = $1.to_i
        value = $2.to_i
        if @__element_resistance[element_id] == nil
          @__element_resistance[element_id] = 100
        end
        @__element_resistance[element_id] -= (100 - value)
      when KGC::AddEquipmentOptions::Regexp::BaseItem::WEAK_ELEMENT
        # 弱点属性
        $1.scan(/\d+/).each { |num|
          @__weak_element_set << num.to_i
        }
      when KGC::AddEquipmentOptions::Regexp::BaseItem::GUARD_ELEMENT
        # 半減属性
        $1.scan(/\d+/).each { |num|
          @__guard_element_set << num.to_i
        }
      when KGC::AddEquipmentOptions::Regexp::BaseItem::INVALID_ELEMENT
        # 無効属性
        $1.scan(/\d+/).each { |num|
          @__invalid_element_set << num.to_i
        }
      when KGC::AddEquipmentOptions::Regexp::BaseItem::ABSORB_ELEMENT
        # 吸収属性
        $1.scan(/\d+/).each { |num|
          @__absorb_element_set << num.to_i
        }
      when KGC::AddEquipmentOptions::Regexp::BaseItem::STATE_RESISTANCE
        # ステート耐性
        state_id = $1.to_i
        value = $2.to_i
        if @__state_resistance[state_id] == nil
          @__state_resistance[state_id] = 100
        end
        @__state_resistance[state_id] -= (100 - value)
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 攻撃回数
  #--------------------------------------------------------------------------
  def multi_attack_count
    create_add_equipment_options_cache if @__multi_attack_count == nil
    return @__multi_attack_count
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [HP自動回復]
  #--------------------------------------------------------------------------
  def auto_hp_recover
    create_add_equipment_options_cache if @__auto_hp_recover == nil
    return @__auto_hp_recover
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [MP自動回復]
  #--------------------------------------------------------------------------
  def auto_mp_recover
    create_add_equipment_options_cache if @__auto_mp_recover == nil
    return @__auto_mp_recover
  end
  #--------------------------------------------------------------------------
  # ○ HP 自動回復量 (即値)
  #--------------------------------------------------------------------------
  def auto_hp_recover_value
    create_add_equipment_options_cache if @__auto_hp_recover_value == nil
    return @__auto_hp_recover_value
  end
  #--------------------------------------------------------------------------
  # ○ HP 自動回復量 (割合)
  #--------------------------------------------------------------------------
  def auto_hp_recover_rate
    create_add_equipment_options_cache if @__auto_hp_recover_rate == nil
    return @__auto_hp_recover_rate
  end
  #--------------------------------------------------------------------------
  # ○ MP 自動回復量 (即値)
  #--------------------------------------------------------------------------
  def auto_mp_recover_value
    create_add_equipment_options_cache if @__auto_mp_recover_value == nil
    return @__auto_mp_recover_value
  end
  #--------------------------------------------------------------------------
  # ○ MP 自動回復量 (割合)
  #--------------------------------------------------------------------------
  def auto_mp_recover_rate
    create_add_equipment_options_cache if @__auto_mp_recover_rate == nil
    return @__auto_mp_recover_rate
  end
  #--------------------------------------------------------------------------
  # ○ MP 転換率
  #--------------------------------------------------------------------------
  def convert_mp_rate
    create_add_equipment_options_cache if @__convert_mp_rate == nil
    return @__convert_mp_rate
  end
  #--------------------------------------------------------------------------
  # ○ MP 吸収率
  #--------------------------------------------------------------------------
  def absorb_mp_rate
    create_add_equipment_options_cache if @__absorb_mp_rate == nil
    return @__absorb_mp_rate
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性
  #--------------------------------------------------------------------------
  def element_resistance
    create_add_equipment_options_cache if @__element_resistance == nil
    return @__element_resistance
  end
  #--------------------------------------------------------------------------
  # ○ 弱点属性
  #--------------------------------------------------------------------------
  def weak_element_set
    create_add_equipment_options_cache if @__weak_element_set == nil
    return @__weak_element_set
  end
  #--------------------------------------------------------------------------
  # ○ 半減属性
  #--------------------------------------------------------------------------
  def guard_element_set
    create_add_equipment_options_cache if @__guard_element_set == nil
    return @__guard_element_set
  end
  #--------------------------------------------------------------------------
  # ○ 無効属性
  #--------------------------------------------------------------------------
  def invalid_element_set
    create_add_equipment_options_cache if @__invalid_element_set == nil
    return @__invalid_element_set
  end
  #--------------------------------------------------------------------------
  # ○ 吸収属性
  #--------------------------------------------------------------------------
  def absorb_element_set
    create_add_equipment_options_cache if @__absorb_element_set == nil
    return @__absorb_element_set
  end
  #--------------------------------------------------------------------------
  # ○ ステート耐性
  #--------------------------------------------------------------------------
  def state_resistance
    create_add_equipment_options_cache if @__state_resistance == nil
    return @__state_resistance
  end
end


#==============================================================================
#==============================================================================

class RPG::Weapon < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 追加オプションのキャッシュを作成
  #--------------------------------------------------------------------------
  def create_add_equipment_options_cache
    super
    @__prevent_critical = false
    @__half_mp_cost = false
    @__double_exp_gain = false

    @note.split(/[\r\n]+/).each { |line|
      case line
      when KGC::AddEquipmentOptions::Regexp::Weapon::PREVENT_CRITICAL
        # クリティカル防止
        @__prevent_critical = true
      when KGC::AddEquipmentOptions::Regexp::Weapon::HALF_MP_COST
        # 消費MP半分
        @__half_mp_cost = true
      when KGC::AddEquipmentOptions::Regexp::Weapon::DOUBLE_EXP_GAIN
        # 取得経験値2倍
        @__double_exp_gain = true
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [クリティカル防止]
  #--------------------------------------------------------------------------
  def prevent_critical
    create_add_equipment_options_cache if @__prevent_critical == nil
    return @__prevent_critical
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [消費MP半分]
  #--------------------------------------------------------------------------
  def half_mp_cost
    create_add_equipment_options_cache if @__half_mp_cost == nil
    return @__half_mp_cost
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [取得経験値2倍]
  #--------------------------------------------------------------------------
  def double_exp_gain
    create_add_equipment_options_cache if @__double_exp_gain == nil
    return @__double_exp_gain
  end
end


#==============================================================================
#==============================================================================

class RPG::Armor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 追加オプションのキャッシュを作成
  #--------------------------------------------------------------------------
  def create_add_equipment_options_cache
    super
    @__fast_attack = false
    @__dual_attack = false
    @__critical_bonus = false
    @__attack_element_set = []
    @__plus_state_set = []

    @note.split(/[\r\n]+/).each { |line|
      case line
      when KGC::AddEquipmentOptions::Regexp::Armor::FAST_ATTACK
        # ターン内先制
        @__fast_attack = true
      when KGC::AddEquipmentOptions::Regexp::Armor::DUAL_ATTACK
        # 連続攻撃
        @__dual_attack = true
      when KGC::AddEquipmentOptions::Regexp::Armor::CRITICAL_BONUS
        # クリティカル頻発
        @__critical_bonus = true
      when KGC::AddEquipmentOptions::Regexp::Armor::ATTACK_ELEMENT
        # 攻撃属性
        $1.scan(/\d+/).each { |num|
          @__attack_element_set << num.to_i
        }
      when KGC::AddEquipmentOptions::Regexp::Armor::PLUS_STATE
        # 付加ステート
        $1.scan(/\d+/).each { |num|
          @__plus_state_set << num.to_i
        }
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [ターン内先制]
  #--------------------------------------------------------------------------
  def fast_attack
    create_add_equipment_options_cache if @__fast_attack == nil
    return @__fast_attack
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [連続攻撃]
  #--------------------------------------------------------------------------
  def dual_attack
    create_add_equipment_options_cache if @__dual_attack == nil
    return @__dual_attack
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [クリティカル頻発]
  #--------------------------------------------------------------------------
  def critical_bonus
    create_add_equipment_options_cache if @__critical_bonus == nil
    return @__critical_bonus
  end
  #--------------------------------------------------------------------------
  # ● 装備オプション [HP自動回復]
  #--------------------------------------------------------------------------
  def auto_hp_recover
    return (@auto_hp_recover || super)
  end
  #--------------------------------------------------------------------------
  # ○ 攻撃属性
  #--------------------------------------------------------------------------
  def attack_element_set
    create_add_equipment_options_cache if @__attack_element_set == nil
    return @__attack_element_set
  end
  #--------------------------------------------------------------------------
  # ○ 付加ステート
  #--------------------------------------------------------------------------
  def plus_state_set
    create_add_equipment_options_cache if @__plus_state_set == nil
    return @__plus_state_set
  end
end


#==============================================================================
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ○ 攻撃回数の取得
  #--------------------------------------------------------------------------
  def multi_attack_count
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃によるダメージ計算
  #     attacker : 攻撃者
  #    結果は @hp_damage に代入する。
  #--------------------------------------------------------------------------
  alias make_attack_damage_value_KGC_AddEquipmentOptions make_attack_damage_value
  def make_attack_damage_value(attacker)
    make_attack_damage_value_KGC_AddEquipmentOptions(attacker)

    make_convert_mp_value(attacker)
    make_absorb_mp_value(attacker)
  end
  #--------------------------------------------------------------------------
  # ● スキルまたはアイテムによるダメージ計算
  #     user : スキルまたはアイテムの使用者
  #     obj  : スキルまたはアイテム
  #    結果は @hp_damage または @mp_damage に代入する。
  #--------------------------------------------------------------------------
  alias make_obj_damage_value_KGC_AddEquipmentOptions make_obj_damage_value
  def make_obj_damage_value(user, obj)
    make_obj_damage_value_KGC_AddEquipmentOptions(user, obj)

    make_convert_mp_value(user, obj)
    make_absorb_mp_value(user, obj)
  end
  #--------------------------------------------------------------------------
  # ○ MP 転換率の計算
  #--------------------------------------------------------------------------
  def calc_convert_mp_rate
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ MP 吸収率の計算
  #--------------------------------------------------------------------------
  def calc_absorb_mp_rate
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ MP 転換効果の適用
  #     user : 攻撃者
  #     obj  : スキルまたはアイテム (nil なら通常攻撃)
  #    結果は @hp_damage または @mp_damage に代入する。
  #--------------------------------------------------------------------------
  def make_convert_mp_value(user, obj = nil)
    return if @hp_damage <= 0  # 回復する場合は転換しない

    rate = calc_convert_mp_rate
    return if rate == 0        # 転換率が 0 なら転換しない

    @mp_damage -= [@hp_damage * rate / 100, 1].max
  end
  #--------------------------------------------------------------------------
  # ○ MP 吸収効果の適用
  #     user : 攻撃者
  #     obj  : スキルまたはアイテム (nil なら通常攻撃)
  #    結果は @hp_damage または @mp_damage に代入する。
  #--------------------------------------------------------------------------
  def make_absorb_mp_value(user, obj = nil)
    return unless mp_absorb?(user, obj)

    # HP ダメージを MP 回復値に変換
    rate = elements_max_rate( (obj == nil ? user : obj).element_set )
    rate = rate.abs * calc_absorb_mp_rate / 100
    @mp_damage -= [@hp_damage.abs * rate / 100, 1].max
    @hp_damage = 0
  end
  #--------------------------------------------------------------------------
  # ○ MP 吸収判定
  #     user : 攻撃者
  #     obj  : スキルまたはアイテム (nil なら通常攻撃)
  #--------------------------------------------------------------------------
  def mp_absorb?(user, obj = nil)
    if obj.is_a?(RPG::UsableItem)
      return false if obj.base_damage < 0     # 回復なら吸収しない
      if obj.is_a?(RPG::Item)
        # 回復アイテムなら吸収しない
        return false if obj.hp_recovery_rate > 0 || obj.hp_recovery > 0
      end
    end
    return false if calc_absorb_mp_rate == 0  # 吸収率が 0 なら吸収しない
    rate = elements_max_rate( (obj == nil ? user : obj).element_set )
    return false if rate >= 0                 # 有効な属性なら吸収しない

    return true
  end
end


#==============================================================================
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # ● 通常攻撃のターゲット作成
  #--------------------------------------------------------------------------
  alias make_attack_targets_KGC_AddEquipmentOptions make_attack_targets
  def make_attack_targets
    buf = make_attack_targets_KGC_AddEquipmentOptions
    targets = buf.clone

    # n 回攻撃
    (battler.multi_attack_count - 1).times { targets += buf }
    return targets
  end
end


#==============================================================================
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 屬性耐性資料 Provider（Phase 28）
  #--------------------------------------------------------------------------
  # 原本此處會 alias / override Game_Actor#element_rate。
  # Phase 28 起，最終屬性倍率統一由 FS_ElementRate_FinalAuthority v2.0
  # 讀取本頁的 element_resistance / weak / guard / invalid / absorb 資料；
  # 本頁不再接管 element_rate，避免形成已被 FinalAuthority 覆寫的死鏈。
  #--------------------------------------------------------------------------
  # ○ 属性耐性の取得
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_resistance(element_id)
    n = 100
    equips.compact.each { |item|
      if item.element_resistance[element_id] != nil
        n += item.element_resistance[element_id] - 100
      end
    }
    return n
  end
  #--------------------------------------------------------------------------
  # ● ステートの付加成功率の取得
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  alias state_probability_KGC_AddEquipmentOptions state_probability
  def state_probability(state_id)
    result = state_probability_KGC_AddEquipmentOptions(state_id)

    return result * state_resistance(state_id) / 100
  end
  #--------------------------------------------------------------------------
  # ○ ステート耐性の取得
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  def state_resistance(state_id)
    n = 100
    equips.compact.each { |item|
      if item.state_resistance[state_id] != nil
        n += item.state_resistance[state_id] - 100
      end
    }
    return [n, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の属性取得
  #--------------------------------------------------------------------------
  alias element_set_KGC_AddEquipmentOptions element_set
  def element_set
    result = element_set_KGC_AddEquipmentOptions

    armors.compact.each { |armor|
      result |= armor.attack_element_set
    }
    return result
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の追加効果 (ステート変化) 取得
  #--------------------------------------------------------------------------
  alias plus_state_set_KGC_AddEquipmentOptions plus_state_set
  def plus_state_set
    result = plus_state_set_KGC_AddEquipmentOptions

    armors.compact.each { |armor|
      result |= armor.plus_state_set
    }
    return result
  end
  #--------------------------------------------------------------------------
  # ● クリティカル率の取得
  #--------------------------------------------------------------------------
  alias cri_KGC_AddEquipmentOptions cri
  def cri
    n = cri_KGC_AddEquipmentOptions

    armors.compact.each { |armor|
      n += 4 if armor.critical_bonus
    }
    return n
  end
  #--------------------------------------------------------------------------
  # ○ 攻撃回数の取得
  #--------------------------------------------------------------------------
  def multi_attack_count
    result = [1]
    equips.compact.each { |item|
      result << item.multi_attack_count
    }
    return result.max
  end
  #--------------------------------------------------------------------------
  # ● 武器オプション [ターン内先制] の取得
  #--------------------------------------------------------------------------
  alias fast_attack_KGC_AddEquipmentOptions fast_attack
  def fast_attack
    return true if fast_attack_KGC_AddEquipmentOptions

    armors.compact.each { |armor|
      return true if armor.fast_attack
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 武器オプション [連続攻撃] の取得
  #--------------------------------------------------------------------------
  alias dual_attack_KGC_AddEquipmentOptions dual_attack
  def dual_attack
    # ２回攻撃以上なら無視
    return false if multi_attack_count >= 2

    return true if dual_attack_KGC_AddEquipmentOptions

    armors.compact.each { |armor|
      return true if armor.dual_attack
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [クリティカル防止] の取得
  #--------------------------------------------------------------------------
  alias prevent_critical_KGC_AddEquipmentOptions prevent_critical
  def prevent_critical
    return true if prevent_critical_KGC_AddEquipmentOptions

    weapons.compact.each { |weapon|
      return true if weapon.prevent_critical
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [消費 MP 半分] の取得
  #--------------------------------------------------------------------------
  alias half_mp_cost_KGC_AddEquipmentOptions half_mp_cost
  def half_mp_cost
    return true if half_mp_cost_KGC_AddEquipmentOptions

    weapons.compact.each { |weapon|
      return true if weapon.half_mp_cost
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [取得経験値 2 倍] の取得
  #--------------------------------------------------------------------------
  alias double_exp_gain_KGC_AddEquipmentOptions double_exp_gain
  def double_exp_gain
    return true if double_exp_gain_KGC_AddEquipmentOptions

    weapons.compact.each { |weapon|
      return true if weapon.double_exp_gain
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [HP 自動回復] の取得
  #--------------------------------------------------------------------------
  alias auto_hp_recover_KGC_AddEquipmentOptions auto_hp_recover
  def auto_hp_recover
    return true if auto_hp_recover_KGC_AddEquipmentOptions

    weapons.compact.each { |weapon|
      return true if weapon.auto_hp_recover
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ● 装備オプション [MP 自動回復] の取得
  #--------------------------------------------------------------------------
  def auto_mp_recover
    equips.compact.each { |item|
      return true if item.auto_mp_recover
    }
    return false
  end
  #--------------------------------------------------------------------------
  # ○ HP 自動回復量の取得
  #--------------------------------------------------------------------------
  def auto_hp_recover_value
    value = 0
    rate = 0
    equips.compact.each { |item|
      value += item.auto_hp_recover_value
      rate  += item.auto_hp_recover_rate
    }
    # 回復量を算出
    if value == 0 && rate == 0
      n = maxhp * KGC::AddEquipmentOptions::DEFAULT_RECOVER_HP_RATE / 100
    else
      n = value + (maxhp * rate / 100)
    end
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # ○ MP 自動回復量の取得
  #--------------------------------------------------------------------------
  def auto_mp_recover_value
    value = 0
    rate = 0
    equips.compact.each { |item|
      value += item.auto_mp_recover_value
      rate  += item.auto_mp_recover_rate
    }
    # 回復量を算出
    if value == 0 && rate == 0
      n = maxmp * KGC::AddEquipmentOptions::DEFAULT_RECOVER_MP_RATE / 100
    else
      n = value + (maxmp * rate / 100)
    end
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # ● 自動回復の実行 (ターン終了時に呼び出し)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    return if dead?

    self.hp += auto_hp_recover_value if auto_hp_recover
    self.mp += auto_mp_recover_value if auto_mp_recover
  end
  #--------------------------------------------------------------------------
  # ○ MP 転換率の計算
  #--------------------------------------------------------------------------
  def calc_convert_mp_rate
    n = 0
    equips.compact.each { |item| n += item.convert_mp_rate }
    return n
  end
  #--------------------------------------------------------------------------
  # ○ MP 吸収率の計算
  #--------------------------------------------------------------------------
  def calc_absorb_mp_rate
    n = 0
    equips.compact.each { |item| n += item.absorb_mp_rate }
    return n
  end
end


#==============================================================================
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● HP ダメージ表示
  #     target : 対象者
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  alias display_hp_damage_KGC_AddEquipmentOptions display_hp_damage
  def display_hp_damage(target, obj = nil)
    if target.hp_damage == 0 && target.mp_damage < 0
      return if target.mp_absorb?(@active_battler, obj)  # MP 吸収
    end

    display_hp_damage_KGC_AddEquipmentOptions(target, obj)
  end
end


#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
# http://f44.aaa.livedoor.jp/~ytomy/tkool/rpgtech/php/tech.php?tool=VX&cat=tech_vx/equip&tech=add_equipment_options
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_