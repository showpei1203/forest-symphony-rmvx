#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_偷竊｜Base + Tankentai Compatibility Bundle
# 【來源】KGC Steal（2008-09-13，Mr. Anonymous 翻譯，Touchfuzzy／RFTD 擴充）＋ Moonlight 的 Tankentai SBS 3.4 相容補丁；Phase 6 依原相鄰順序合併成單頁 Bundle。
# 【定位】這是「Steal Base + SBS Compatibility」，不是 Forest Symphony 最終汲取 Authority。後方依序還有 FS_DynamicCaptureRate、FS_SoulRepeatRecipe、FS_SkillCost_AllFix、FS_StealResult_Authority 等正式層。
# 【Skill Notetag】在要作為偷竊／汲取技能的 Skill Note 寫 <steal>。
# 【Enemy Notetag】<steal X:ID Probability%>；X=I 道具、W 武器、A 防具、G 金錢。例：<steal W:2 50%>、<steal G:100 50%>。Probability 若帶 % 使用百分比；原系統也支援分母式資料。
# 【裝備加成】Weapon/Armor Note：<steal_prob_plus +15%> 或負值；Game_Actor#steal_prob_plus 會加總所有裝備。FS DynamicCaptureRate 的魂刻公式也沿用同一裝備加成。
# 【設定】AGILITY_BASED_STEAL=false：目前不用敏捷比例修正；USING_SIDEVIEW=true：使用 Tankentai Steal_Window 顯示結果。VOCAB_STEAL_* 是實際遊戲文字，若要中文文案調整應另做 UI 文案版。
# 【Base Runtime】RPG::Skill#steal?、RPG::Enemy#steal_objects、Game_Battler#make_obj_steal_result、Game_Enemy 的可偷物件 clone、Scene_Battle 的 Steal routing 與結果顯示。
# 【Tankentai 相容段】頁尾補丁重寫 execute_action_steal／display_steal_effects，讓 steal skill 使用 SBS Action Sequence。其後 FS_StealResult_Authority 再補「0 傷害也要真正跑 steal 判定、同一 action 只抽一次、SE」等規則。
# 【FS 正式鏈】本 Bundle → FS_DynamicCaptureRate v1.4（重寫 make_obj_steal_result，魂刻使用動態率）→ FS_SoulRepeatRecipe v1.1.2（display_steal_item 經濟／首次與重複汲取）→ FS_SkillCost_AllFix → FS_StealResult_Authority v1.0（最終 Tankentai 判定包裝與 SE）。因此不能把 280 與 416 直接合併或互換位置。
# 【EnemyGuide】若 $imported['EnemyGuide'] 存在，成功偷竊會登記圖鑑 stole flag。EnemyGuide 本身又讀 enemy.steal_objects，因此 KGC Steal 必須先建立資料 API。
# 【相關素材】無固定 Graphics；USING_SIDEVIEW=true 時使用 Steal_Window。成功／失敗 SE 由後方 FS_StealResult_Authority 設定，不由本頁固定。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
# PHASE6 ORIGINAL PAGE: 285 | KGC_偷竊
#==============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/   ◆                    Translation by Mr. Anonymous                       ◆
#_/   ◆ KGC Site:                                                             ◆
#_/   ◆ http://f44.aaa.livedoor.jp/~ytomy/                                    ◆
#_/   ◆ Translator's Blog:                                                    ◆
#_/   ◆ http://mraprojects.wordpress.com                                      ◆
#_/----------------------------------------------------------------------------
#_/============================================================================
#_/
#_/
#_/
#_/
#_/ 
#_/  
#_/
#_/============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================#
#==============================================================================#

module KGC
 module Steal
  VOCAB_STEAL_NO_ITEM = "%s 沒有可汲取的！"
  VOCAB_STEAL_FAILURE = "汲取失敗了 !"
  VOCAB_STEAL_ITEM    = "成功汲取了 %s !"
  VOCAB_STEAL_GOLD    = "%s a 獲得 %s%s s!"
  
  #  Cagi = 使用汲取技能者的 AGI
  #  Eagi = 敵人的 AGI
  AGILITY_BASED_STEAL = false
  
  USING_SIDEVIEW = true
 end
end

#=============================================================================#
#=============================================================================#

#=================================================#
#=================================================#

$imported = {} if $imported == nil
$imported["Steal"] = true

#=================================================#

#==============================================================================
#==============================================================================
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

module KGC::Steal
  module Regexp
    module BaseItem
      STEAL_PROB_PLUS = /<(?:STEAL_PROB|steal_prob_plus)\s*([\+\-]\d+)[%％]?>/i
    end

    module Skill
      STEAL = /<(?:STEAL|steal)>/i
    end

    module Enemy
      STEAL_OBJECT = /<(?:STEAL|steal)\s*([IWAG]):(\d+)\s+(\d+)([%％])?>/i
    end
  end
end

#=================================================

#==============================================================================
#==============================================================================

module Vocab
  StealItem    = KGC::Steal::VOCAB_STEAL_ITEM
  StealGold    = KGC::Steal::VOCAB_STEAL_GOLD
  StealNoItem  = KGC::Steal::VOCAB_STEAL_NO_ITEM
  StealFailure = KGC::Steal::VOCAB_STEAL_FAILURE
end

#=================================================

#==============================================================================
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 「盗む」のキャッシュ生成
  #--------------------------------------------------------------------------
  def create_steal_cache
    @__steal_prob_plus = 0

    self.note.each_line { |line|
      case line
      when KGC::Steal::Regexp::BaseItem::STEAL_PROB_PLUS
        # 盗み成功率補正
        @__steal_prob_plus += $1.to_i
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 盗み成功率補正
  #--------------------------------------------------------------------------
  def steal_prob_plus
    create_steal_cache if @__steal_prob_plus == nil
    return @__steal_prob_plus
  end
end

#=================================================

#==============================================================================
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ○ 「盗む」のキャッシュ生成
  #--------------------------------------------------------------------------
  def create_steal_cache
    super
    @__steal = false

    self.note.each_line { |line|
      case line
      when KGC::Steal::Regexp::Skill::STEAL
        # 盗む
        @__steal = true
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 盗む
  #--------------------------------------------------------------------------
  def steal?
    create_steal_cache if @__steal == nil
    return @__steal
  end
end

#=================================================

#==============================================================================
#==============================================================================

class RPG::Enemy
  #--------------------------------------------------------------------------
  # ○ 「盗む」のキャッシュ生成
  #--------------------------------------------------------------------------
  def create_steal_cache
    @__steal_objects = []

    self.note.each_line { |line|
      case line
      when KGC::Steal::Regexp::Enemy::STEAL_OBJECT
        # 盗めるオブジェクト
        obj = RPG::Enemy::StealObject.new
        case $1.upcase
        when "I"  # アイテム
          obj.kind = 1
          obj.item_id = $2.to_i
        when "W"  # 武器
          obj.kind = 2
          obj.weapon_id = $2.to_i
        when "A"  # 防具
          obj.kind = 3
          obj.armor_id = $2.to_i
        when "G"  # 金
          obj.kind = 4
          obj.gold = $2.to_i
        else
          next
        end
        # 成功率
        if $4 != nil
          obj.success_prob = $3.to_i
        else
          obj.denominator = $3.to_i
        end
        @__steal_objects << obj
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 盗めるオブジェクト
  #--------------------------------------------------------------------------
  def steal_objects
    create_steal_cache if @__steal_objects == nil
    return @__steal_objects
  end
end

#=================================================

#==============================================================================
#==============================================================================

class RPG::Enemy::StealObject < RPG::Enemy::DropItem
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  KIND_ITEM   = 1
  KIND_WEAPON = 2
  KIND_ARMOR  = 3
  KIND_GOLD   = 4
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :gold                     # 金
  attr_accessor :success_prob             # 成功率
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    @gold = 0
    @success_prob = 0
  end
  #--------------------------------------------------------------------------
  # ○ 同値判定
  #--------------------------------------------------------------------------
  def equal?(obj)
    return false unless obj.is_a?(RPG::Enemy::StealObject)
    return false if self.gold != obj.gold
    return false if self.success_prob != obj.success_prob

    return true
  end
  #--------------------------------------------------------------------------
  # ○ 等値演算子
  #--------------------------------------------------------------------------
  def ==(obj)
    return self.equal?(obj)
  end
end

#=================================================

#==============================================================================
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :steal_objects            # 盗めるオブジェクト
  attr_accessor :stolen_object            # 前回盗まれたオブジェクト
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_Battler_KGC_Steal initialize
  def initialize
    initialize_Battler_KGC_Steal

    @steal_objects = []
    @stolen_object = nil
  end
  #--------------------------------------------------------------------------
  # ○ 盗み成功率補正値
  #--------------------------------------------------------------------------
  def steal_prob_plus
    return 0
  end
  #--------------------------------------------------------------------------
  # ● スキルの効果適用
  #     user  : スキルの使用者
  #     skill : スキル
  #--------------------------------------------------------------------------
  alias skill_effect_KGC_Steal skill_effect
  def skill_effect(user, skill)
    skill_effect_KGC_Steal(user, skill)

    make_obj_steal_result(user, skill)
  end
  #--------------------------------------------------------------------------
  # ○ スキルまたはアイテムによる盗み効果
  #     user : スキルまたはアイテムの使用者
  #     obj  : スキルまたはアイテム
  #    結果は @stolen_object に代入する。
  #--------------------------------------------------------------------------
  def make_obj_steal_result(user, obj)
    return unless obj.steal?                  # 盗み効果なし
    return if @skipped || @missed || @evaded  # 効果なし

    # 何も持っていない
    if self.steal_objects.compact.empty?
      @stolen_object = :no_item
      return
    end

    @stolen_object = nil
    stolen_index = -1
    self.steal_objects.each_with_index { |sobj, i|
      next if sobj == nil
      if KGC::Steal::AGILITY_BASED_STEAL
        sobj.success_prob = sobj.success_prob * user.agi / self.agi
      end
      # 盗み成功判定
      if sobj.success_prob > 0
        # 確率指定
        next if sobj.success_prob + user.steal_prob_plus < rand(100)
      else
        # 分母指定
        if rand(sobj.denominator) != 0
          next if user.steal_prob_plus < rand(100)
        end
      end
      # 盗み成功
      @stolen_object = sobj
      stolen_index = i
      if $imported["EnemyGuide"]
        # 図鑑用の盗み成功フラグをオン
        self_id = (self.actor? ? self.id : self.enemy_id)
        KGC::Commands.set_enemy_object_stolen(self_id, stolen_index)
      end
      break
    }
    if stolen_index != -1
      @steal_objects[stolen_index] = nil
    end
  end
end

#=================================================

#==============================================================================
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 盗み成功率補正値
  #--------------------------------------------------------------------------
  def steal_prob_plus
    n = 0
    equips.compact.each { |item| n += item.steal_prob_plus }
    return n
  end
end

#=================================================

#==============================================================================
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     index    : 敵グループ内インデックス
  #     enemy_id : 敵キャラ ID
  #--------------------------------------------------------------------------
  alias initialize_Enemy_KGC_Steal initialize
  def initialize(index, enemy_id)
    initialize_Enemy_KGC_Steal(index, enemy_id)

    @steal_objects = enemy.steal_objects.clone
  end
end

#=================================================

#==============================================================================
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : スキル
  #--------------------------------------------------------------------------
  alias execute_action_skill_KGC_Steal execute_action_skill
  def execute_action_skill
    skill = @active_battler.action.skill
    if skill.steal?
      execute_action_steal
      @status_window.refresh
    else
      execute_action_skill_KGC_Steal
    end
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘行動の実行 : 盗む
  #--------------------------------------------------------------------------
  def execute_action_steal
    skill = @active_battler.action.skill
    text = @active_battler.name + skill.message1
    @message_window.add_instant_text(text)
    unless skill.message2.empty?
      wait(10)
      @message_window.add_instant_text(skill.message2)
    end
    targets = @active_battler.action.make_targets
    display_animation(targets, skill.animation_id)
    @active_battler.mp -= @active_battler.calc_mp_cost(skill)
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      target.skill_effect(@active_battler, skill)
      display_steal_effects(target, skill)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 盗んだ結果の表示
  #     target : 対象者
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_effects(target, obj = nil)
    unless target.skipped
      line_number = @message_window.line_number
      wait(5)
      if target.hp_damage != 0 || target.mp_damage != 0
        display_critical(target, obj)
        display_damage(target, obj)
      end
      display_stole_object(target, obj)
      display_state_changes(target, obj)
      if line_number == @message_window.line_number
        display_failure(target, obj) unless target.states_active?
      end
      if line_number != @message_window.line_number
        wait(30)
      end
      @message_window.back_to(line_number)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 盗んだオブジェクトの表示
  #     target : 対象者
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_stole_object(target, obj = nil)
    if target.missed || target.evaded
      display_steal_failure(target, obj)
      return
    end

    case target.stolen_object
    when nil       # 盗み失敗
      display_steal_failure(target, obj)
    when :no_item  # 何も持っていない
      display_steal_no_item(target, obj)
    else
      if target.stolen_object.kind == RPG::Enemy::StealObject::KIND_GOLD
        # お金
        display_steal_gold(target, obj)
      else
        # アイテム or 武器 or 防具
        display_steal_item(target, obj)
      end
      target.stolen_object = nil
    end
  end
  #--------------------------------------------------------------------------
  # ○ 盗み失敗の表示
  #     target : 対象者 (アクター)
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_failure(target, obj)
    if KGC::Steal::USING_SIDEVIEW
      result_data = sprintf(Vocab::StealFailure)
      @steal_window = Steal_Window.new(result_data)
      @steal_window.visible = true
      wait (160)
      @steal_window.dispose
    else
      @message_window.add_instant_text(Vocab::StealFailure)
      wait(30)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 何も持っていない場合の表示
  #     target : 対象者 (アクター)
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_no_item(target, obj)
    if KGC::Steal::USING_SIDEVIEW
      result_data = sprintf(Vocab::StealNoItem, target.name)
      @steal_window = Steal_Window.new(result_data)
      @steal_window.visible = true
      wait (160)
      @steal_window.dispose
    else
      text = sprintf(Vocab::StealNoItem, target.name)
      @message_window.add_instant_text(text)
      wait(30)
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムを盗んだ場合の表示
  #     target : 対象者 (アクター)
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_item(target, obj)
    # 盗んだアイテムを取得
    sobj = target.stolen_object
    case sobj.kind
    when RPG::Enemy::StealObject::KIND_ITEM
      item = $data_items[sobj.item_id]
    when RPG::Enemy::StealObject::KIND_WEAPON
      item = $data_weapons[sobj.weapon_id]
    when RPG::Enemy::StealObject::KIND_ARMOR
      item = $data_armors[sobj.armor_id]
    else
      return
    end
    $game_party.gain_item(item, 1)

    if KGC::Steal::USING_SIDEVIEW
      #result_data = sprintf(Vocab::StealItem, target.name, item.name)
      result_data = sprintf(Vocab::StealItem, item.name)
      @steal_window = Steal_Window.new(result_data)
      @steal_window.visible = true
      wait (160)
      @steal_window.dispose
    else
      #text = sprintf(Vocab::StealItem, target.name, item.name)
      text = sprintf(Vocab::StealItem, item.name)
      @message_window.add_instant_text(text)
      wait(30)
    end
  end
  #--------------------------------------------------------------------------
  # ○ お金を盗んだ場合の表示
  #     target : 対象者 (アクター)
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_gold(target, obj)
    gold = target.stolen_object.gold
    $game_party.gain_gold(gold)

    if KGC::Steal::USING_SIDEVIEW
      result_data = sprintf(Vocab::StealGold, target.name, gold, Vocab.gold)
      @steal_window = Steal_Window.new(result_data)
      @steal_window.visible = true
      wait (160)
      @steal_window.dispose
    else
      text = sprintf(Vocab::StealGold, target.name, gold, Vocab.gold)
      @message_window.add_instant_text(text)
      wait(30)
    end
  end
end

#=================================================

if KGC::Steal::USING_SIDEVIEW
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
# RPG Tankentai SBS 專用方法
#--------------------------------------------------------------------------
class Steal_Window < Window_Base
  def initialize(result_data)
    super(15, 0, 516, 60)
    self.z = 10001
    self.opacity = 0
    contents.font.color = normal_color
    contents.draw_text(0, 0, contents.width, WLH, result_data,1)
  end
end
end # 詳見頁首繁中維護說明

#==============================================================================
# PHASE6 ORIGINAL PAGE: 286 | KGC偷竊_Patch 
#==============================================================================
begin
#==============================================================================
# By Moonlight
#==============================================================================
#==============================================================================
# 安裝位置：Main 之前、KGC_Steal 與 Tankentai SBS 之後。
# 覆寫：execute_action_steal、display_steal_effects
#==============================================================================

$imported = {} if $imported == nil

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

if $imported["Steal"]
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ 戦闘行動の実行 : 盗む
  #--------------------------------------------------------------------------
  def execute_action_steal
    skill = @active_battler.action.skill
    if skill.plus_state_set.include?(1)
      for member in $game_party.members + $game_troop.members
        next if member.immortal
        next if member.dead?
        member.dying = true
      end
    else
      immortaling 
    end
    return unless @active_battler.skill_can_use?(skill)
    targets = @active_battler.action.make_targets
    target_decision(skill)
    @spriteset.set_action(@active_battler.actor?, @active_battler.index, skill.base_action)
    pop_help(skill)
    playing_action
    @active_battler.mp -= @active_battler.calc_mp_cost(skill) # 
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      display_steal_effects(target, skill)
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 盗んだ結果の表示
  #    target : 対象者
  #    obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  def display_steal_effects(target, obj = nil)
    unless target.skipped
      line_number = @message_window.line_number
      wait(5)
      @help_window.visible = false if @help_window != nil
      display_stole_object(target, obj)
      display_state_changes(target, obj)
      if line_number == @message_window.line_number
        display_failure(target, obj) unless target.states_active?
      end
      if line_number != @message_window.line_number
        wait(5)
      end
      @message_window.back_to(line_number)
    end
  end
end
end
end
