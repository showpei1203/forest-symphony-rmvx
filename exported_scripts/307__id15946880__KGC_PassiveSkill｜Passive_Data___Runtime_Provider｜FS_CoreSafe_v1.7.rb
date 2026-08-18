#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_PassiveSkill｜Passive Data / Runtime Provider
# 【來源】KGC PassiveSkill（2008-09-13，英文翻譯 Mr. Anonymous）＋星潟「KGC_PassiveSkill 擴張／等級依存被動技能 Ver1.00」。Phase 8 依原順序收斂為單一 Authority。
# 【用途】把已學會 Skill 轉成 Actor 的被動能力來源，可修改能力值、攻擊元素／State、State 抗性、自動 State、Fast/Dual Attack、Critical、半 MP、雙倍 EXP 等；擴張段另外讓被動效果依使用者等級動態計算。
# 【基本 Notetag】Skill Note 使用 <PASSIVE_SKILL> ... </PASSIVE_SKILL>。區塊內每行一個設定，例如 MAXHP +20%、MAXMP -20%、ATK +5、SPI -5、ATTACK_ELEMENT 8,9、PLUS_STATE 8、INVALID_STATE 6。
# 【能力 Key】PARAMS：MAXHP／MAXMP／ATK／DEF／SPI／AGI／HIT／EVA／CRI／LCK(odds)，可使用固定加減值或百分比；ARRAYS：ATTACK_ELEMENT、PLUS_STATE、INVALID_STATE、AUTO_STATE。
# 【特殊效果】TWO_SWORDS_STYLE、AUTO_BATTLE、SUPER_GUARD、PHARMACOLOGY、FAST_ATTACK、DUAL_ATTACK、CRITICAL_BONUS、PREVENT_CRITICAL、HALF_MP_COST、DOUBLE_EXP_GAIN；WHOLE_ATTACK／IGNORE_EVA 需 KGC_ReproduceFunctions；n TIMES_ATTACK／multi_attack_count 依賴 KGC_AddEquipmentOptions。
# 【完整範例】<PASSIVE_SKILL> 區塊可依序寫 MAXHP +20%、MAXMP -20%、ATTACK_ELEMENT 8,9、PLUS_STATE 8；每項請分行。解析器會把所有已生效 Passive Skill 合併後重建 passive_params／passive_arrays／passive_effects。
# 【等級依存擴張】Skill Note：<レベル依存:a,b,c,d>。a=能力編號（0 MaxHP、1 MaxMP、2 ATK、3 DEF、4 SPI、5 AGI、6 HIT、7 EVA、8 CRI）；b=先對 Level 做 0加／1減／2乘／3除；c=與 Level 計算的數字；d=再將結果以 0加／1減／2乘／3除套到能力。四值缺一即無效。
# 【等級依存範例】<レベル依存:0,0,10,3>：以 Level+10 作為最大 HP 除數；<レベル依存:3,3,6,0>：將 Level÷6 加到 DEF。若第一段計算結果為 0，擴張腳本會跳過後續能力運算以避免乘／除 0 異常。
# 【依賴／Authority】本頁必須在 KGC_AddEquipmentOptions／ReproduceFunctions／EquipExtension 等被動來源之後，且後方 FS ActorEnemyGrowth、Equipment Overhaul、Mechanic／State 系統仍直接讀 passive_params／passive_params_rate。Phase 18 稽核確認它不是可安全搬動／去 alias 的孤立頁。
# 【Save 相容】會重建／恢復 Passive cache；改 Note 解析或資料結構後必須實測舊存檔載入、學會／忘記技能、換裝與戰鬥能力值。
# 【相關素材】無固定 Graphics／Audio；依賴 Skill／Actor／State／Equipment 資料庫 Note。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. Phase 29 唯一 Runtime 改動：退休早於 YEM extra-slot 更新的 change_equip 被動刷新 wrapper；最終刷新改由 FS_EquipmentSkill_Authority v2.1 統一執行。
# 5. Phase44D 已封版：退休 discard_equip 內的 legacy early Passive refresh。KGC wrapper 保留為相容邊界，但只轉呼叫底層 discard；最終 Teaching → Passive → Combo convergence 由後方 YEM Equipment Overhaul｜FS CoreSafe v1.6 在實際移除完成後統一持有。
# 6. Phase44F 候選：退休 KGC setup wrapper 在 inner setup 完成後的 legacy final Passive rebuild。reset_passive_rev 與 alias boundary 保留；後方 FS_EquipmentSkill_Authority v2.1 setup 仍統一執行 Teaching → Passive final refresh，RuntimeSupport 後續 learn_skill 仍依既有 KGC wrapper 即時刷新。
# 7. Phase44H 候選：KGC learn_skill 只在 raw learned ownership 真正由未學→已學時重建 Passive。已學技能的重複 learn_skill 仍完整轉呼叫原 RGSS2 learn_skill，但不再對零 mutation 做 restore_passive_rev；forget_skill 本階段不修改。
# 8. Phase44I 候選：KGC learn_skill 在 ownership 真正改變後，僅當新學技能本身為 Passive Skill 時重建 Passive cache。restore_passive_rev 正式實作只會納入 skill.passive == true 的技能，因此新學非 Passive Skill 不再重掃整份 skills；Passive Skill 新學仍即時 rebuild，forget_skill 本階段仍不修改。
# 9. Phase44J 已封版：KGC forget_skill 僅在 raw learned ownership 真正由已學→未學，且被忘技能本身為 Passive Skill 時重建 Passive cache。未學技能的 no-op forget 與真正忘掉非 Passive Skill 都不再重掃 self.skills；alias boundary 保留，方法對外仍固定回 nil。
# 10. Phase44K 已封版：Equipment Teaching 的 final convergence 路徑會在 Teaching 後立即執行一次正式 Passive refresh；因此 Teaching 內 transitive learn_skill／forget_skill 若碰到 Passive mutation，不再重複 rebuild。只在 @albert_equipment_teaching_passive_deferred 為 true 的短暫 transaction 內抑制；一般／獨立 learn_skill、forget_skill 語意完全不變。
# 11. Phase44M1 候選：Phase44M 實機證明 non-Passive Skill 也可攜帶 <レベル依存:a,b,c,d>，而 ALVD cache 會掃描全部 skills，不要求 skill.passive。raw skill ownership 真正改變時，若該 Skill 帶 ALVD tag，僅將 @alvd_flag=false 延遲失效；不觸發 Passive rebuild。下一次能力值 query 才由原 ALVD#alvd_make 正式重建，維持 Phase44I/J 的 non-Passive Passive-refresh retirement。
#==============================================================================
#==============================================================================
# KGC PassiveSkill Base→ALVD 擴張；原 alias 次序不變。
# Original load order: 314:KGC_PassiveSkill -> 315:KGC_PassiveSkill拡張
#==============================================================================
# PHASE8 原始頁：314｜KGC_PassiveSkill
#==============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/   ◆ http://f44.aaa.livedoor.jp/~ytomy/                                    ◆
#_/   ◆ http://mraprojects.wordpress.com                                      ◆
#_/-----------------------------------------------------------------------------
#_/=============================================================================
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
#_/  
#_/
#_/ 
#_/  
#_/============================================================================= 
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_

#=================================================#
#=================================================#

$imported = {} if $imported == nil
$imported["PassiveSkill"] = true

#=================================================#

#==============================================================================
#==============================================================================
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

module KGC
module PassiveSkill
  
  # The (obvious) setup is OriginalString|PersonalAbbreviation
  
  PARAMS = {
    :maxhp => "MAXHP|maximum_hp",
    :maxmp => "MAXMP|maximum_mp",
    :atk   => "ATK|attack",         # Attack
    :def   => "DEF|defense",        # Defense
    :spi   => "SPI|spirit",
    :agi   => "AGI|agility",        # Agility
    :hit   => "HIT|hit_ratio",
    :eva   => "EVA|evasion",
    :cri   => "CRI|critial",
    :odds  => "LCK|luck",           # Luck (See below)
  }

  ARRAYS = {
    :attack_element => "ATTACK_ELEMENT|attack_element",
    :plus_state     => "PLUS_STATE|plus_state",
    :invalid_state  => "INVALID_STATE|invalid_state",
    :auto_state     => "AUTO_STATE|auto_state",
  }

  EFFECTS = {
    :two_swords_style => "TWO_SWORDS_STYLE|two_swords_style",
    :auto_battle      => "AUTO_BATTLE|auto_battle",
    :super_guard      => "SUPER_GUARD|super_guard",
    :pharmacology     => "PHARMACOLOGY|pharmacology",
    :fast_attack      => "FAST_ATTACK|fast_attack",
    :dual_attack      => "DUAL_ATTACK|dual_attack",
    :critical_bonus   => "CRITICAL_BONUS|critical_bonus",
    :prevent_critical => "PREVENT_CRITICAL|prevent_critical",
    :half_mp_cost     => "HALF_MP_COST|half_mp_cost",
    :double_exp_gain  => "DOUBLE_EXP_GAIN|double_exp_gain",
    :whole_attack     => "WHOLE_ATTACK|target_all",
    :ignore_eva       => "IGNORE_EVA|ignore_evasion",
    :multi_attack_count => '(\d+)\s*(?:TIMES_ATTACK|multi_attack_count)',
  }

#==============================================================================
#==============================================================================
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

  module Regexp
    module Skill
      BEGIN_PASSIVE = /<(?:PASSIVE_SKILL|passive_skill)>/i
      END_PASSIVE = /<\/(?:PASSIVE_SKILL|passive_skill)>/i
      PASSIVE_PARAMS = /^\s*([^:\+\-\d\s]+)\s*([\+\-]\d+)([%％])?/
      PASSIVE_ARRAYS = /^\s*([^:\+\-\d\s]+)\s*(\d+(?:\s*,\s*\d+)*)/
      PASSIVE_EFFECTS = /^\s*([^:\+\-\d\s]+)/
    end
  end
end
end

#=================================================#

#==============================================================================
#==============================================================================

module KGC
  module Commands
    module_function
    #--------------------------------------------------------------------------
    # ○ パッシブスキルの修正値を再設定
    #--------------------------------------------------------------------------
    def restore_passive_rev
      (1...$data_actors.size).each { |i|
        actor = $game_actors[i]
        actor.restore_passive_rev
      }
    end
  end
end

#=================================================#
#=================================================#
#=================================================#

class Game_Interpreter
  include KGC::Commands
end

#=================================================#

#==============================================================================
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ○ パッシブスキルのキャッシュを生成
  #--------------------------------------------------------------------------
  def create_passive_skill_cache
    @__passive = false
    @__passive_params = {}
    @__passive_params_rate = {}
    @__passive_arrays = {}
    @__passive_effects = { :multi_attack_count => 1 }

    passive_flag = false
    self.note.each_line { |line|
      case line
      when KGC::PassiveSkill::Regexp::Skill::BEGIN_PASSIVE
        # パッシブスキル定義開始
        passive_flag = true
        @__passive = true
      when KGC::PassiveSkill::Regexp::Skill::END_PASSIVE
        # パッシブスキル定義終了
        passive_flag = false
      when KGC::PassiveSkill::Regexp::Skill::PASSIVE_PARAMS
        # 能力値修正
        if passive_flag
          apply_passive_params($1, $2.to_i, $3 != nil)
        end
      when KGC::PassiveSkill::Regexp::Skill::PASSIVE_ARRAYS
        # 属性・ステート
        if passive_flag
          apply_passive_arrays($1, $2.scan(/\d+/))
        end
      else
        # 特殊効果
        if passive_flag
          apply_passive_effects(line)
        end
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの能力値修正を適用
  #     param : 対象パラメータ
  #     value : 修正値
  #     rate  : true なら % 指定
  #--------------------------------------------------------------------------
  def apply_passive_params(param, value, rate)
    KGC::PassiveSkill::PARAMS.each { |k, v|
      if param =~ /(?:#{v})/i
        if rate
          @__passive_params_rate[k] = 0 if @__passive_params_rate[k] == nil
          @__passive_params_rate[k] += value
        else
          @__passive_params[k] = 0 if @__passive_params[k] == nil
          @__passive_params[k] += value
        end
        break
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの追加属性・ステートを適用
  #     param : 対象パラメータ
  #     list  : 属性・ステート一覧
  #--------------------------------------------------------------------------
  def apply_passive_arrays(param, list)
    KGC::PassiveSkill::ARRAYS.each { |k, v|
      if param =~ /(?:#{v})/i
        values = []
        list.each { |num| values << num.to_i }
        @__passive_arrays[k] = [] if @__passive_arrays[k] == nil
        @__passive_arrays[k] |= values
        break
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの特殊効果を適用
  #     effect : 対象効果
  #--------------------------------------------------------------------------
  def apply_passive_effects(effect)
    KGC::PassiveSkill::EFFECTS.each { |k, v|
      if effect =~ /^\s*(#{v})/i
        if k == :multi_attack_count
          $1 =~ /#{v}/i
          @__passive_effects[k] = [ $1.to_i, @__passive_effects[k] ].max
        else
          @__passive_effects[k] = true
        end
        break
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルであるか
  #--------------------------------------------------------------------------
  def passive
    create_passive_skill_cache if @__passive == nil
    return @__passive
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの能力値修正 (即値)
  #--------------------------------------------------------------------------
  def passive_params
    create_passive_skill_cache if @__passive_params == nil
    return @__passive_params
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの能力値修正 (割合)
  #--------------------------------------------------------------------------
  def passive_params_rate
    create_passive_skill_cache if @__passive_params_rate == nil
    return @__passive_params_rate
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの属性・ステートリスト
  #--------------------------------------------------------------------------
  def passive_arrays
    create_passive_skill_cache if @__passive_arrays == nil
    return @__passive_arrays
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの特殊効果リスト
  #--------------------------------------------------------------------------
  def passive_effects
    create_passive_skill_cache if @__passive_effects == nil
    return @__passive_effects
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● セットアップ
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  alias setup_KGC_PassiveSkill setup
  def setup(actor_id)
    reset_passive_rev

    setup_KGC_PassiveSkill(actor_id)

    # Phase44F：legacy setup-final Passive refresh retirement candidate。
    # 後方 FS_EquipmentSkill_Authority v2.1 的 setup final convergence 會在
    # Equipment / Teaching 最終 ownership 建立後統一重建 Passive；此處僅保留
    # KGC cache 初始化與原 alias boundary，避免同一 setup lifecycle 提前重建一次。
    return nil
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの修正値を初期化
  #--------------------------------------------------------------------------
  def reset_passive_rev
    @passive_params = {}
    @passive_params_rate = {}
    @passive_arrays = {}
    @passive_effects = {}
    KGC::PassiveSkill::PARAMS.each_key { |k|
      @passive_params[k] = 0
      @passive_params_rate[k] = 100
    }
    KGC::PassiveSkill::ARRAYS.each_key { |k| @passive_arrays[k] = [] }
    KGC::PassiveSkill::EFFECTS.each_key { |k| @passive_effects[k] = false }
    @passive_effects[:multi_attack_count] = 1
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの修正値を再設定
  #--------------------------------------------------------------------------
  def restore_passive_rev
    return if @__passive_rev_restoring

    # 修正前の値を保持
    last_effects = @passive_effects.clone if @passive_effects != nil

    reset_passive_rev

    # ≪スキルCP制≫ の併用を考慮し、戦闘中フラグを一時的にオン
    last_in_battle = $game_temp.in_battle
    $game_temp.in_battle = true
    # 修正値を取得
    self.skills.each { |skill|
      next unless skill.passive

      skill.passive_params.each { |k, v| @passive_params[k] += v }
      skill.passive_params_rate.each { |k, v| @passive_params_rate[k] += v }
      skill.passive_arrays.each { |k, v| @passive_arrays[k] |= v }
      skill.passive_effects.each { |k, v|
        if k == :multi_attack_count
          @passive_effects[k] = [ v, @passive_effects[k] ].max
        else
          @passive_effects[k] |= v
        end
      }
    }
    $game_temp.in_battle = last_in_battle

    @__passive_rev_restoring = true
    # HP/MP を修正
    self.hp = self.hp
    self.mp = self.mp

    # 二刀流違反を修正
    if last_effects[:two_swords_style] != nil &&
        last_effects[:two_swords_style] != two_swords_style
      @__one_time_two_swords_style = last_effects[:two_swords_style]
      change_equip(1, nil)
      @__one_time_two_swords_style = nil
    end
    @__passive_rev_restoring = nil
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルによるパラメータ修正値 (即値)
  #--------------------------------------------------------------------------
  def passive_params
    restore_passive_rev if @passive_params == nil
    return @passive_params
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルによるパラメータ修正値 (割合)
  #--------------------------------------------------------------------------
  def passive_params_rate
    restore_passive_rev if @passive_params_rate == nil
    return @passive_params_rate
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルによる追加属性・ステート
  #--------------------------------------------------------------------------
  def passive_arrays
    restore_passive_rev if @passive_arrays == nil
    return @passive_arrays
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルによる特殊効果
  #--------------------------------------------------------------------------
  def passive_effects
    restore_passive_rev if @passive_effects == nil
    return @passive_effects
  end
  #--------------------------------------------------------------------------
  # ● Phase 29：換裝後被動技能刷新責任
  #--------------------------------------------------------------------------
  # 舊版在此直接 alias change_equip 並 restore_passive_rev。
  # YEM 額外裝備欄位是在這一層返回後才真正更新，因此早期刷新可能看見舊裝備。
  # 現改由後方 FS_EquipmentSkill_Authority 在完整換裝鏈結束後統一刷新。
  #--------------------------------------------------------------------------
  # ● 装備の破棄
  #     item : 破棄する武器 or 防具
  #    武器／防具の増減で「装備品も含める」のとき使用する。
  #--------------------------------------------------------------------------
  # Phase44D：legacy KGC early Passive refresh retirement candidate。
  # 本 wrapper 保留 alias boundary，避免破壞既有 load-order／相容性引用；但不再於
  # YEM / CoreSafe final ownership 尚未完全收斂前重建 Passive。實際成功移除後由
  # page330 CoreSafe v1.6 統一執行 Teaching → Passive → Combo。
  alias discard_equip_KGC_PassiveSkill discard_equip
  def discard_equip(item)
    discard_equip_KGC_PassiveSkill(item)
    return nil
  end
  #--------------------------------------------------------------------------
  # ● ステート無効化判定
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  alias state_resist_KGC_PassiveSkill? state_resist?
  def state_resist?(state_id)
    return true if passive_arrays[:invalid_state].include?(state_id)

    return state_resist_KGC_PassiveSkill?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の属性取得
  #--------------------------------------------------------------------------
  alias element_set_KGC_PassiveSkill element_set
  def element_set
    return (element_set_KGC_PassiveSkill | passive_arrays[:attack_element])
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の追加効果 (ステート変化) 取得
  #--------------------------------------------------------------------------
  alias plus_state_set_KGC_PassiveSkill plus_state_set
  def plus_state_set
    return (plus_state_set_KGC_PassiveSkill | passive_arrays[:plus_state])
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxHP の取得
  #--------------------------------------------------------------------------
  alias base_maxhp_KGC_PassiveSkill base_maxhp
  def base_maxhp
    n = base_maxhp_KGC_PassiveSkill + passive_params[:maxhp]
    n = n * passive_params_rate[:maxhp] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxMP の取得
  #--------------------------------------------------------------------------
  alias base_maxmp_KGC_PassiveSkill base_maxmp
  def base_maxmp
    n = base_maxmp_KGC_PassiveSkill + passive_params[:maxmp]
    n = n * passive_params_rate[:maxmp] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本攻撃力の取得
  #--------------------------------------------------------------------------
  alias base_atk_KGC_PassiveSkill base_atk
  def base_atk
    n = base_atk_KGC_PassiveSkill + passive_params[:atk]
    n = n * passive_params_rate[:atk] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本防御力の取得
  #--------------------------------------------------------------------------
  alias base_def_KGC_PassiveSkill base_def
  def base_def
    n = base_def_KGC_PassiveSkill + passive_params[:def]
    n = n * passive_params_rate[:def] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本精神力の取得
  #--------------------------------------------------------------------------
  alias base_spi_KGC_PassiveSkill base_spi
  def base_spi
    n = base_spi_KGC_PassiveSkill + passive_params[:spi]
    n = n * passive_params_rate[:spi] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 基本敏捷性の取得
  #--------------------------------------------------------------------------
  alias base_agi_KGC_PassiveSkill base_agi
  def base_agi
    n = base_agi_KGC_PassiveSkill + passive_params[:agi]
    n = n * passive_params_rate[:agi] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 命中率の取得
  #--------------------------------------------------------------------------
  alias hit_KGC_PassiveSkill hit
  def hit
    n = hit_KGC_PassiveSkill + passive_params[:hit]
    n = n * passive_params_rate[:hit] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● 回避率の取得
  #--------------------------------------------------------------------------
  alias eva_KGC_PassiveSkill eva
  def eva
    n = eva_KGC_PassiveSkill + passive_params[:eva]
    n = n * passive_params_rate[:eva] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● クリティカル率の取得
  #--------------------------------------------------------------------------
  alias cri_KGC_PassiveSkill cri
  def cri
    n = cri_KGC_PassiveSkill + passive_params[:cri]
    n = n * passive_params_rate[:cri] / 100
    n += 4 if passive_effects[:critical_bonus]
    return n
  end
  #--------------------------------------------------------------------------
  # ● 狙われやすさの取得
  #--------------------------------------------------------------------------
  alias odds_KGC_PassiveSkill odds
  def odds
    n = odds_KGC_PassiveSkill + passive_params[:odds]
    n = n * passive_params_rate[:odds] / 100
    return n
  end
  #--------------------------------------------------------------------------
  # ● オプション [二刀流] の取得
  #--------------------------------------------------------------------------
  alias two_swords_style_KGC_PassiveSkill two_swords_style
  def two_swords_style
    return @__one_time_two_swords_style if @__one_time_two_swords_style != nil

    return (two_swords_style_KGC_PassiveSkill ||
      passive_effects[:two_swords_style])
  end
  #--------------------------------------------------------------------------
  # ● オプション [自動戦闘] の取得
  #--------------------------------------------------------------------------
  alias auto_battle_KGC_PassiveSkill auto_battle
  def auto_battle
    return (auto_battle_KGC_PassiveSkill || passive_effects[:auto_battle])
  end
  #--------------------------------------------------------------------------
  # ● オプション [強力防御] の取得
  #--------------------------------------------------------------------------
  alias super_guard_KGC_PassiveSkill super_guard
  def super_guard
    return (super_guard_KGC_PassiveSkill || passive_effects[:super_guard])
  end
  #--------------------------------------------------------------------------
  # ● オプション [薬の知識] の取得
  #--------------------------------------------------------------------------
  alias pharmacology_KGC_PassiveSkill pharmacology
  def pharmacology
    return (pharmacology_KGC_PassiveSkill || passive_effects[:pharmacology])
  end
  #--------------------------------------------------------------------------
  # ● 武器オプション [ターン内先制] の取得
  #--------------------------------------------------------------------------
  alias fast_attack_KGC_PassiveSkill fast_attack
  def fast_attack
    return (fast_attack_KGC_PassiveSkill || passive_effects[:fast_attack])
  end
  #--------------------------------------------------------------------------
  # ● 武器オプション [連続攻撃] の取得
  #--------------------------------------------------------------------------
  alias dual_attack_KGC_PassiveSkill dual_attack
  def dual_attack
    if $imported["AddEquipmentOptions"]
      # ２回攻撃以上なら無視
      return false if passive_effects[:multi_attack_count] >= 2
    end

    return (dual_attack_KGC_PassiveSkill || passive_effects[:dual_attack])
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [クリティカル防止] の取得
  #--------------------------------------------------------------------------
  alias prevent_critical_KGC_PassiveSkill prevent_critical
  def prevent_critical
    return (prevent_critical_KGC_PassiveSkill ||
      passive_effects[:prevent_critical])
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [消費 MP 半分] の取得
  #--------------------------------------------------------------------------
  alias half_mp_cost_KGC_KGC_PassiveSkill half_mp_cost
  def half_mp_cost
    return (half_mp_cost_KGC_KGC_PassiveSkill ||
      passive_effects[:half_mp_cost])
  end
  #--------------------------------------------------------------------------
  # ● 防具オプション [取得経験値 2 倍] の取得
  #--------------------------------------------------------------------------
  alias double_exp_gain_KGC_PassiveSkill double_exp_gain
  def double_exp_gain
    return (double_exp_gain_KGC_PassiveSkill ||
      passive_effects[:double_exp_gain])
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ○ ALVD 等級依存 Skill 判定
  #--------------------------------------------------------------------------
  def fs_kgc_alvd_skill?(skill)
    return false if skill == nil
    note = skill.note.to_s rescue ""
    return note =~ /<レベル依存[：:][^>]+>/ ? true : false
  rescue
    return false
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  alias learn_skill_KGC_PassiveSkill learn_skill
  def learn_skill(skill_id)
    # Phase44H：RGSS2 base learn_skill 對已學技能本來就是 no-op。
    # Phase44I：Passive cache 只在真正新增 Passive Skill 時 rebuild。
    # Phase44M1：ALVD 會掃描全部 skills；non-Passive ALVD Skill ownership
    # 真正改變時只 invalidate @alvd_flag，不重建 Passive。
    learned_before = (@skills != nil && @skills.include?(skill_id))
    learn_skill_KGC_PassiveSkill(skill_id)
    learned_after = (@skills != nil && @skills.include?(skill_id))
    if learned_before != learned_after
      skill = $data_skills[skill_id] rescue nil
      @alvd_flag = false if respond_to?(:alvd_make) && fs_kgc_alvd_skill?(skill)
      # Phase44K：Equipment Teaching final convergence 已承諾在 Teaching 完成後
      # 立即做一次 Passive Authority refresh；transaction 內避免 transitive rebuild。
      deferred = (@albert_equipment_teaching_passive_deferred == true)
      restore_passive_rev if skill != nil && skill.passive && !deferred
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルを忘れる
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  alias forget_skill_KGC_PassiveSkill forget_skill
  def forget_skill(skill_id)
    # Phase44J：RGSS2 base forget_skill 對未學技能本來就是 no-op。
    # Passive cache 只受 Passive Skill ownership 影響，因此僅在真正
    # 已學→未學且該 Skill 為 Passive 時 rebuild。舊 wrapper 對外回傳 nil。
    # Phase44M1：若被忘 Skill 帶 ALVD tag，真正 ownership 移除時另外只
    # invalidate @alvd_flag；下一次能力值 query 才按原 ALVD Authority 重建。
    learned_before = (@skills != nil && @skills.include?(skill_id))
    skill = $data_skills[skill_id] rescue nil
    forget_skill_KGC_PassiveSkill(skill_id)
    learned_after = (@skills != nil && @skills.include?(skill_id))
    if learned_before && !learned_after
      @alvd_flag = false if respond_to?(:alvd_make) && fs_kgc_alvd_skill?(skill)
      # Phase44K：同 learn_skill，只有 Equipment Teaching deferred transaction
      # 才延後到外層 final Passive Authority；standalone forget 仍即時刷新。
      deferred = (@albert_equipment_teaching_passive_deferred == true)
      restore_passive_rev if skill != nil && skill.passive && !deferred
    end
    return nil
  end

if $imported["ReproduceFunctions"]

  #--------------------------------------------------------------------------
  # ○ オートステートの配列を取得
  #     id_only : ID のみを取得
  #--------------------------------------------------------------------------
  alias auto_states_KGC_PassiveSkill auto_states
  def auto_states(id_only = false)
    result = auto_states_KGC_PassiveSkill(id_only)

    passive_arrays[:auto_state].each { |i|
      result << (id_only ? i : $data_states[i])
    }
    result.uniq!
    return result
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [全体攻撃] の取得
  #--------------------------------------------------------------------------
  alias whole_attack_KGC_PassiveSkill whole_attack
  def whole_attack
    return (whole_attack_KGC_PassiveSkill || passive_effects[:whole_attack])
  end
  #--------------------------------------------------------------------------
  # ○ 装備オプション [回避無視] の取得
  #--------------------------------------------------------------------------
  alias ignore_eva_KGC_PassiveSkill ignore_eva
  def ignore_eva
    return (ignore_eva_KGC_PassiveSkill || passive_effects[:ignore_eva])
  end

end

if $imported["AddEquipmentOptions"]

  #--------------------------------------------------------------------------
  # ○ 攻撃回数の取得
  #--------------------------------------------------------------------------
  alias multi_attack_count_KGC_PassiveSkill multi_attack_count
  def multi_attack_count
    n = multi_attack_count_KGC_PassiveSkill
    return [ n, passive_effects[:multi_attack_count] ].max
  end

end

end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Window_EquipItem < Window_Item
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x          : ウィンドウの X 座標
  #     y          : ウィンドウの Y 座標
  #     width      : ウィンドウの幅
  #     height     : ウィンドウの高さ
  #     actor      : アクター
  #     equip_type : 装備部位 (0～4)
  #--------------------------------------------------------------------------
  alias initialize_KGC_PassiveSkill initialize unless $@
  def initialize(x, y, width, height, actor, equip_type)
    @original_equip_type = equip_type

    initialize_KGC_PassiveSkill(x, y, width, height, actor, equip_type)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias refresh_KGC_PassiveSkill refresh unless $@
  def refresh
    if @original_equip_type == 1
      @equip_type = (@actor.two_swords_style ? 0 : 1)
    end

    refresh_KGC_PassiveSkill
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Scene_File < Scene_Base
  #--------------------------------------------------------------------------
  # ● セーブデータの読み込み
  #     file : 読み込み用ファイルオブジェクト (オープン済み)
  #--------------------------------------------------------------------------
  alias read_save_data_KGC_PassiveSkill read_save_data
  def read_save_data(file)
    read_save_data_KGC_PassiveSkill(file)

    KGC::Commands.restore_passive_rev
    Graphics.frame_reset
  end
end

#==============================================================================
# PHASE8 原始頁：315｜KGC_PassiveSkill 擴張
#==============================================================================
#==============================================================================
# ■ RGSS2 KGC_PassiveSkill拡張 レベル依存パッシブスキル Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 習得者のレベルに依存して能力値が変化する
# パッシブスキルの作成が可能となります。
# 非戦闘時のアイテム使用者はアイテム使用対象となります。
#------------------------------------------------------------------------------
# 使用例
#------------------------------------------------------------------------------
# ★スキルのメモ欄に以下のように記述する。
#
# <レベル依存:a,b,c,d>
# aに能力値番号
#（0:最大HP 1:最大MP 2:攻撃力 3:防御力 4:精神力 5:敏捷性
#  6:命中率 7:回避率 8:クリティカル率）
# bにレベルに対する処理
# (0:加算 1:減算 2:乗算 3:除算)
# cにレベルに対する処理に用いる数字（任意）
# dに能力値に対する処理
# (0:加算 1:減算 2:乗算 3:除算)
# 以上4つの数字を記述。一つでも漏れがある場合無効。
#
# 記入例
#
# <レベル依存:0,0,10,3>
# 使用者のレベル＋10の数値を最大HPに除算する。
# 
# <レベル依存:1,1,5,2>
# 使用者のレベル－5の数値を最大MPに乗算する。將用戶的 5 級數乘以最大 MP
#
# <レベル依存:2,2,7,1>
# 使用者のレベル×7の数値を攻撃力に減算する。攻擊力減去使用者等級x 7的值
#
# <レベル依存:3,3,6,0>
# 使用者のレベル÷6の数値を防御力に加算する。防禦力加上使用者等級÷6
#
#------------------------------------------------------------------------------
# なお、全ての能力値についてcの値とレベルをbの方法で計算した際に
# 結果が0となった場合、能力値へのdの方法による計算と処理は行われません。
# 例 レベルが1の時に<レベル依存:0,1,1,2>
# 個の場合、1-1で0になる為、最大HP×0の処理は行われません。
#==============================================================================
module ALVD
  
  #スキル設定用ワード
  
  WORD = "レベル依存"
  
end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 能力値に加算する値をクリア
  #--------------------------------------------------------------------------
  alias clear_extra_values_alvd clear_extra_values  unless $!
  def clear_extra_values
    clear_extra_values_alvd
    @alvd_flag = false
  end
  def alvd_make
    @alvd_flag = true
    @alvd1 = []
    @alvd2 = []
    @alvd3 = []
    @alvd4 = []
    number = 9
    number.times do
      @alvd1.push(0)
      @alvd2.push(0)
      @alvd3.push(0)
      @alvd4.push(0)
    end
    skill_data2 = nil
    if $imported["SkillCPSystem"]
      skill_data1 = skills
      skill_data2 = battle_skills
      skill_data3 = @battle_skills
    else
      skill_data1 = skills
    end
    for i in skill_data1
      if $imported["SkillCPSystem"]
        if KGC::SkillCPSystem::USABLE_COST_ZERO_SKILL
          if KGC::SkillCPSystem::PASSIVE_NEED_TO_SET
            next if !skill_data2.include?(i) && i.cp_cost > 0
          end
        else
          if KGC::SkillCPSystem::PASSIVE_NEED_TO_SET
            next unless skill_data3.include?(i.id)
          end
        end
      end
      i.note.each_line { |line|
      memo = line.scan(/<#{ALVD::WORD}[：:](\S+),(\S+),(\S+),(\S+)>/)
      memo = memo.flatten
      if memo != nil and not memo.empty?
        data = level
        case memo[1].to_i#レベルに対する処理
        when 0#加算
          data += memo[2].to_i
        when 1#減算
          data -= memo[2].to_i
        when 2#乗算
          data *= memo[2].to_i
        when 3#除算
          data /= memo[2].to_i
        end
        case memo[0].to_i#変化パラメータ
        when 0#HP
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[0] += data
          when 1#減算
            @alvd2[0] += data
          when 2#乗算
            @alvd3[0] += data
          when 3#除算
            @alvd4[0] += data
          end
        when 1#MP
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[1] += data
          when 1#減算
            @alvd2[1] += data
          when 2#乗算
            @alvd3[1] += data
          when 3#除算
            @alvd4[1] += data
          end
        when 2#ATK
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[2] += data
          when 1#減算
            @alvd2[2] += data
          when 2#乗算
            @alvd3[2] += data
          when 3#除算
            @alvd4[2] += data
          end
        when 3#DEF
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[3] += data
          when 1#減算
            @alvd2[3] += data
          when 2#乗算
            @alvd3[3] += data
          when 3#除算
            @alvd4[3] += data
          end
        when 4#SPI
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[4] += data
          when 1#減算
            @alvd2[4] += data
          when 2#乗算
            @alvd3[4] += data
          when 3#除算
            @alvd4[4] += data
          end
        when 5#AGI
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[5] += data
          when 1#減算
            @alvd2[5] += data
          when 2#乗算
            @alvd3[5] += data
          when 3#除算
            @alvd4[5] += data
          end
        when 6#HIT
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[6] += data
          when 1#減算
            @alvd2[6] += data
          when 2#乗算
            @alvd3[6] += data
          when 3#除算
            @alvd4[6] += data
          end
        when 7#EVA
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[7] += data
          when 1#減算
            @alvd2[7] += data
          when 2#乗算
            @alvd3[7] += data
          when 3#除算
            @alvd4[7] += data
          end
        when 8#CRI
          case memo[3].to_i#レベルを処理した数値をパラメータに対しどう処理するか
          when 0#加算
            @alvd1[8] += data
          when 1#減算
            @alvd2[8] += data
          when 2#乗算
            @alvd3[8] += data
          when 3#除算
            @alvd4[8] += data
          end
        end
      end
      }
    end
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxHP の取得
  #--------------------------------------------------------------------------
  alias base_maxhp_alvd base_maxhp
  def base_maxhp
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 0
    data = base_maxhp_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 基本 MaxMP の取得
  #--------------------------------------------------------------------------
  alias base_maxmp_alvd base_maxmp
  def base_maxmp
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 1
    data = base_maxmp_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 基本攻撃力の取得
  #--------------------------------------------------------------------------
  alias base_atk_alvd base_atk
  def base_atk
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 2
    data = base_atk_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 基本防御力の取得
  #--------------------------------------------------------------------------
  alias base_def_alvd base_def
  def base_def
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 3
    data = base_def_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 基本精神力の取得
  #--------------------------------------------------------------------------
  alias base_spi_alvd base_spi
  def base_spi
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 4
    data = base_spi_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 基本敏捷性の取得
  #--------------------------------------------------------------------------
  alias base_agi_alvd base_agi
  def base_agi
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 5
    data = base_agi_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 命中率の取得
  #--------------------------------------------------------------------------
  alias hit_alvd hit
  def hit
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 6
    data = hit_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● 回避率の取得
  #--------------------------------------------------------------------------
  alias eva_alvd eva
  def eva
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 7
    data = eva_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ● クリティカル率の取得
  #--------------------------------------------------------------------------
  alias cri_alvd cri
  def cri
    alvd_make if @alvd_flag == false or @alvd_flag == nil
    i = 8
    data = cri_alvd
    data += @alvd1[i] if @alvd1[i] != 0
    data -= @alvd2[i] if @alvd2[i] != 0
    data *= @alvd3[i] if @alvd3[i] != 0
    data /= @alvd4[i] if @alvd4[i] != 0
    return data
  end
  #--------------------------------------------------------------------------
  # ○ パッシブスキルの修正値を再設定
  #--------------------------------------------------------------------------
  alias restore_passive_rev_alvd restore_passive_rev
  def restore_passive_rev
    @alvd_flag = false
    restore_passive_rev_alvd
  end
end
