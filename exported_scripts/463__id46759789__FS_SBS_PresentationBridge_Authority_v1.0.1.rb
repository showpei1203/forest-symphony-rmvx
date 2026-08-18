#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SBS_PresentationBridge_Authority v1.0.1
# 【用途】Forest Symphony 正式 Authority「FS_SBS_PresentationBridge_Authority v1.0.1」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Scene_Battle、Game_Interpreter、FS_MapSBS_Sprite、FS_MapSBS_AnimationAnchor、Scene_Map、Spriteset_Map、FS_SBS_ACTION_BRIDGE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_WAIT_FRAMES、DEBUG_POPUP、ALLOW_DURING_NORMAL_ACTION、OFFSET_X、OFFSET_Y、Z_OFFSET、ANIMATION_OFFSET_X、ANIMATION_OFFSET_Y。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】sbs_action(-1, 1, "VICTORY")；sbs_action(-1, 1, "NORMAL_ATTACK", 0, 0)；sbs_skill_motion(-1, 1, 100, 0, 0)
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
# PHASE7 ORIGINAL PAGE: 489 | FS_SBS_ActionBridge v1.0
#==============================================================================
#==============================================================================
# ■ FS_SBS_ActionBridge v1.0
#------------------------------------------------------------------------------
#  Forest Symphony / RPG Maker VX / RGSS2
#  Tankentai SBS 純演出橋接腳本
#------------------------------------------------------------------------------
#  功能：
#    1. 戰鬥中指定 Actor／我方位置／敵方位置播放任意 SBS Action Key。
#    2. 可借用指定技能的 base_action，但完全不執行技能效果。
#    3. 不扣 MP、不消耗物品、不造成傷害、不附加狀態、不改變 ATB。
#    4. OBJ_ANIM 節點仍可播放目標動畫，但不呼叫 damage_action。
#
#  放置位置：
#    Tankentai SBS、ATB 及所有 SBS 擴充腳本之下，Main 之上。
#
#  --------------------------------------------------------------------------
#  【施術者指定方式 subject_type】
#    -1 : Actor ID
#     0 : 敵方戰鬥位置（0 起算）
#     1 : 我方戰鬥位置（0 起算）
#
#  【目標指定方式 target_type】
#    -1 : Actor ID
#     0 : 敵方戰鬥位置（0 起算）
#     1 : 我方戰鬥位置（0 起算）
#     2 : 自己
#     3 : 全體敵方
#     4 : 全體我方
#     5 : 隨機敵方一體
#     6 : 施術者的全體對手
#     7 : 施術者的全體同伴
#     8 : 施術者的隨機對手一體
#
#  --------------------------------------------------------------------------
#  【事件腳本指令】
#
#  1. 直接播放 SBS Action Key：
#     sbs_action(subject_type, subject_id, action_key,
#                target_type = 2, target_id = 0)
#
#     例：Actor ID 1 對自己播放 "VICTORY"
#     sbs_action(-1, 1, "VICTORY")
#
#     例：Actor ID 1 以敵方第 1 隻為目標播放 "NORMAL_ATTACK"
#     sbs_action(-1, 1, "NORMAL_ATTACK", 0, 0)
#
#  2. 借用技能的 base_action，但不執行技能：
#     sbs_skill_motion(subject_type, subject_id, skill_id,
#                      target_type = 2, target_id = 0)
#
#     例：Actor ID 1 借用技能 100 的 SBS，敵方第 1 隻為目標
#     sbs_skill_motion(-1, 1, 100, 0, 0)
#
#  回傳值：成功 true，失敗 false。
#==============================================================================

module FS_SBS_ACTION_BRIDGE
  VERSION = "1.0"

  # 壞掉的 SBS 序列若永遠不送出 End，最多等待幀數。
  MAX_WAIT_FRAMES = 3600

  # true：參數錯誤時以訊息框提示；正式發佈可改 false。
  DEBUG_POPUP = true

  # 正常戰鬥行動執行中，是否允許再插入純演出。
  # 建議維持 false，避免同一 Sprite_Battler 同時執行兩套序列。
  ALLOW_DURING_NORMAL_ACTION = false

  #--------------------------------------------------------------------------
  # ● 錯誤提示
  #--------------------------------------------------------------------------
  def self.error(message)
    p("FS_SBS_ActionBridge", message) if DEBUG_POPUP
    return false
  end

  #--------------------------------------------------------------------------
  # ● 我方戰鬥成員
  #--------------------------------------------------------------------------
  def self.party_members
    if $game_party.respond_to?(:battle_members)
      return $game_party.battle_members
    end
    return $game_party.members
  end

  #--------------------------------------------------------------------------
  # ● 依指定方式取得 Battler
  #--------------------------------------------------------------------------
  def self.resolve_battler(type, id)
    case type
    when -1
      return $game_actors[id]
    when 0
      return $game_troop.members[id]
    when 1
      return party_members[id]
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # ● 判斷 Battler 是否有對應戰鬥 Sprite
  #--------------------------------------------------------------------------
  def self.battle_sprite_available?(battler)
    return false if battler == nil
    return false unless battler.respond_to?(:index)
    return false if battler.index == nil
    if battler.actor?
      return party_members[battler.index] == battler
    else
      return $game_troop.members[battler.index] == battler
    end
  end

  #--------------------------------------------------------------------------
  # ● 取得存在中的成員
  #--------------------------------------------------------------------------
  def self.existing_members(unit)
    return [] if unit == nil
    if unit.respond_to?(:existing_members)
      return unit.existing_members.compact
    end
    result = []
    for member in unit.members
      next if member == nil
      next if member.respond_to?(:exist?) && !member.exist?
      result.push(member)
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 解析目標
  #--------------------------------------------------------------------------
  def self.resolve_targets(subject, type, id)
    case type
    when -1
      target = $game_actors[id]
      return target == nil ? [] : [target]
    when 0
      target = $game_troop.members[id]
      return target == nil ? [] : [target]
    when 1
      target = party_members[id]
      return target == nil ? [] : [target]
    when 2, nil
      return [subject]
    when 3
      return existing_members($game_troop)
    when 4
      return existing_members($game_party)
    when 5
      list = existing_members($game_troop)
      return list.empty? ? [] : [list[rand(list.size)]]
    when 6
      unit = subject.actor? ? $game_troop : $game_party
      return existing_members(unit)
    when 7
      unit = subject.actor? ? $game_party : $game_troop
      return existing_members(unit)
    when 8
      unit = subject.actor? ? $game_troop : $game_party
      list = existing_members(unit)
      return list.empty? ? [] : [list[rand(list.size)]]
    end
    return []
  end

  #--------------------------------------------------------------------------
  # ● Action Key 是否存在
  #--------------------------------------------------------------------------
  def self.valid_action_key?(key)
    return false unless defined?(N01::ACTION)
    return N01::ACTION.include?(key.to_s)
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 執行純 SBS 演出
  #     skill_id = 0：直接 Action Key
  #     skill_id > 0：讓 SBS 可讀取該技能的動畫／extension 等資料
  #--------------------------------------------------------------------------
  def fs_sbs_visual_action(subject, action_key, targets, skill_id = 0)
    return FS_SBS_ACTION_BRIDGE.error("目前已有純 SBS 演出正在執行。") if @fs_sbs_visual_running

    if !FS_SBS_ACTION_BRIDGE::ALLOW_DURING_NORMAL_ACTION
      if defined?($in_action) && $in_action
        return FS_SBS_ACTION_BRIDGE.error(
          "一般戰鬥行動執行中，為避免 Sprite 序列互相覆蓋，本次純演出已取消。"
        )
      end
    end

    return FS_SBS_ACTION_BRIDGE.error("找不到施術者。") if subject == nil
    return FS_SBS_ACTION_BRIDGE.error("施術者目前沒有戰鬥 Sprite。") unless FS_SBS_ACTION_BRIDGE.battle_sprite_available?(subject)
    return FS_SBS_ACTION_BRIDGE.error("施術者已離場或不存在。") if subject.respond_to?(:exist?) && !subject.exist?
    return FS_SBS_ACTION_BRIDGE.error("找不到 SBS Action Key：#{action_key}") unless FS_SBS_ACTION_BRIDGE.valid_action_key?(action_key)
    return FS_SBS_ACTION_BRIDGE.error("目標不存在。") if targets == nil || targets.empty?
    return FS_SBS_ACTION_BRIDGE.error("Spriteset_Battle 尚未建立。") if @spriteset == nil

    if skill_id.to_i > 0 && $data_skills[skill_id.to_i] == nil
      return FS_SBS_ACTION_BRIDGE.error("找不到技能 ID #{skill_id}。")
    end

    old_scene_active       = @active_battler
    old_scene_targets      = @targets
    old_individual_target  = @individual_target
    old_stand_by_target    = @stand_by_target
    old_action             = subject.action
    old_active_flag        = subject.active
    old_play               = subject.play
    old_individual         = subject.individual
    old_force_target       = subject.force_target if subject.respond_to?(:force_target)

    temp_action = Game_BattleAction.new(subject)
    temp_action.clear if temp_action.respond_to?(:clear)
    temp_action.set_skill(skill_id.to_i) if skill_id.to_i > 0
    temp_action.target_index = targets[0].index if targets[0] != nil && targets[0].respond_to?(:index)
    temp_action.forcing = true

    success = false
    begin
      @fs_sbs_visual_running = true
      @active_battler = subject
      @targets = targets.compact.clone
      @individual_target = nil
      @stand_by_target = nil

      subject.instance_variable_set(:@action, temp_action)
      subject.active = true
      subject.play = 0
      subject.individual = false

      @spriteset.set_target(subject.actor?, subject.index, @targets)
      @spriteset.set_action(subject.actor?, subject.index, action_key.to_s)
      success = fs_sbs_visual_loop(subject, @targets)
    ensure
      begin
        @spriteset.set_stand_by_action(subject.actor?, subject.index) if @spriteset != nil
      rescue
      end

      subject.instance_variable_set(:@action, old_action)
      subject.active = old_active_flag
      subject.play = old_play
      subject.individual = old_individual
      subject.force_target = old_force_target if subject.respond_to?(:force_target=)

      @active_battler = old_scene_active
      @targets = old_scene_targets
      @individual_target = old_individual_target
      @stand_by_target = old_stand_by_target
      @fs_sbs_visual_running = false
    end
    return success
  end

  #--------------------------------------------------------------------------
  # ● 純演出專用播放迴圈
  #     不呼叫原 playing_action，避免 damage_action / action_end / ATB 處理。
  #--------------------------------------------------------------------------
  def fs_sbs_visual_loop(subject, targets)
    frame_count = 0
    loop do
      break if frame_count >= FS_SBS_ACTION_BRIDGE::MAX_WAIT_FRAMES

      if defined?($cmd_disabled) && defined?($atb_disabled) &&
         ($cmd_disabled || $atb_disabled) && respond_to?(:update_patched)
        update_patched
      else
        update_basic
      end
      frame_count += 1

      signal = subject.play
      next if signal == nil || signal == 0
      subject.play = 0

      if signal.is_a?(Array) && signal[0] == "OBJ_ANIM"
        fs_sbs_visual_animation(targets, signal[1])
      elsif signal.is_a?(Array) && signal[0] == "Individual"
        # 純演出不逐一套用效果；保留流程但不建立 damage_action。
        next
      elsif signal == "Activation"
        # QTE／Activation 屬技能效果流程，純演出模式直接略過。
        next
      elsif signal == "Can Collapse"
        # 純演出不修改不死／倒地狀態。
        next
      elsif signal == "Cancel Action" || signal == "End" || signal == "終了"
        return true
      end
    end

    return FS_SBS_ACTION_BRIDGE.error(
      "SBS Action 超過 #{FS_SBS_ACTION_BRIDGE::MAX_WAIT_FRAMES} 幀仍未結束：可能缺少 End 或序列卡死。"
    )
  end

  #--------------------------------------------------------------------------
  # ● 只播放 OBJ_ANIM 的動畫，不計算任何效果
  #--------------------------------------------------------------------------
  def fs_sbs_visual_animation(targets, data)
    return if data == nil
    animation_id = data[0].to_i
    mirror = data[1] ? true : false
    return if animation_id <= 0
    return if $data_animations[animation_id] == nil

    animation = $data_animations[animation_id]
    list = targets.compact
    return if list.empty?

    # 全畫面動畫只讓第一個目標正式播放，其他目標使用 pseudo_ani_id（若有）。
    if animation.position == 3
      first = list[0]
      first.animation_id = animation_id
      first.animation_mirror = mirror
      for i in 1...list.size
        target = list[i]
        if target.respond_to?(:pseudo_ani_id=)
          target.pseudo_ani_id = animation_id
        end
      end
    else
      for target in list
        target.animation_id = animation_id
        target.animation_mirror = mirror
      end
    end
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 指定 Action Key，純播放 SBS
  #--------------------------------------------------------------------------
  def sbs_action(subject_type, subject_id, action_key, target_type = 2, target_id = 0)
    return FS_SBS_ACTION_BRIDGE.error("sbs_action 只能在戰鬥中使用。") unless $game_temp.in_battle
    return FS_SBS_ACTION_BRIDGE.error("目前場景不是 Scene_Battle。") unless $scene.is_a?(Scene_Battle)

    subject = FS_SBS_ACTION_BRIDGE.resolve_battler(subject_type, subject_id)
    return FS_SBS_ACTION_BRIDGE.error("找不到施術者。") if subject == nil
    targets = FS_SBS_ACTION_BRIDGE.resolve_targets(subject, target_type, target_id)
    return $scene.fs_sbs_visual_action(subject, action_key.to_s, targets, 0)
  end

  #--------------------------------------------------------------------------
  # ● 借用技能 base_action，純播放 SBS
  #--------------------------------------------------------------------------
  def sbs_skill_motion(subject_type, subject_id, skill_id, target_type = 2, target_id = 0)
    return FS_SBS_ACTION_BRIDGE.error("sbs_skill_motion 只能在戰鬥中使用。") unless $game_temp.in_battle
    return FS_SBS_ACTION_BRIDGE.error("目前場景不是 Scene_Battle。") unless $scene.is_a?(Scene_Battle)

    skill = $data_skills[skill_id]
    return FS_SBS_ACTION_BRIDGE.error("找不到技能 ID #{skill_id}。") if skill == nil

    subject = FS_SBS_ACTION_BRIDGE.resolve_battler(subject_type, subject_id)
    return FS_SBS_ACTION_BRIDGE.error("找不到施術者。") if subject == nil
    targets = FS_SBS_ACTION_BRIDGE.resolve_targets(subject, target_type, target_id)
    return $scene.fs_sbs_visual_action(subject, skill.base_action, targets, skill_id)
  end
end

#==============================================================================
# PHASE7 ORIGINAL PAGE: 490 | FS_MapSBS_Action v1.0.1
#==============================================================================
#==============================================================================

# ■ FS_MapSBS_Action v1.0.1

#------------------------------------------------------------------------------

#  Forest Symphony / RPG Maker VX / RGSS2

#  地圖用 Tankentai SBS 無傷害演出轉接器

#------------------------------------------------------------------------------

#  功能：

#    1. 在玩家／目前事件／指定事件的位置建立臨時 Sprite_Battler。

#    2. 使用指定 Actor 的戰鬥圖、武器與 Tankentai SBS Action。

#    3. 可指定另一個地圖人物作為移動／攻擊演出的目標座標。

#    4. OBJ_ANIM 只播放 RPG Animation，不造成傷害、不改 HP／MP／狀態。

#    5. 動作結束後刪除臨時 Sprite，恢復原地圖人物顯示。

#

#  放置位置：

#    Tankentai SBS、ATB、FS_SBS_ActionBridge（若有）之下，Main 之上。

#

#  --------------------------------------------------------------------------

#  【地圖人物 character_id】

#    -1 : 玩家

#     0 : 目前正在執行指令的事件

#     1以上 : 指定地圖事件 ID

#

#  --------------------------------------------------------------------------

#  【事件腳本指令】

#

#  1. 直接播放 SBS Action Key：

#     map_sbs_action(actor_id, action_key,

#                    character_id = -1,

#                    target_character_id = nil,

#                    hide_character = true,

#                    mirror = nil)

#

#     例：Actor 1 在玩家位置播放 "VICTORY"

#     map_sbs_action(1, "VICTORY")

#

#     例：Actor 1 在目前事件位置，朝事件 12 播放攻擊動作

#     map_sbs_action(1, "NORMAL_ATTACK", 0, 12)

#

#  2. 借用技能的 base_action，但不執行技能：

#     map_sbs_skill_motion(actor_id, skill_id,

#                          character_id = -1,

#                          target_character_id = nil,

#                          hide_character = true,

#                          mirror = nil)

#

#     例：Actor 1 在玩家位置借用技能 100 的 SBS，目標為事件 12

#     map_sbs_skill_motion(1, 100, -1, 12)

#

#  mirror：

#    nil   = 不強制，依 Tankentai 原設定

#    true  = 水平反轉

#    false = 不反轉

#

#  --------------------------------------------------------------------------

#  【限制】

#    地圖沒有 Scene_Battle、戰鬥 HUD、隊伍目標、damage_action 等環境。

#    本腳本支援姿勢、位移、跳躍、武器、SE、RPG Animation 等純演出。

#    依賴戰鬥視窗、反射、傷害、倒地判定或特殊戰鬥管理器的序列會略過

#    效果節點，或需另做專用地圖版本。

#==============================================================================



module FS_MAP_SBS_ACTION

  VERSION = "1.0.1"



  MAX_WAIT_FRAMES = 3600

  DEBUG_POPUP = true



  # 臨時 Battler 相對地圖人物的座標修正。

  OFFSET_X = 0

  OFFSET_Y = 0

  Z_OFFSET = 50



  # RPG Animation 顯示位置修正。

  ANIMATION_OFFSET_X = 0

  ANIMATION_OFFSET_Y = -16



  #--------------------------------------------------------------------------

  # ● 錯誤提示

  #--------------------------------------------------------------------------

  def self.error(message)

    p("FS_MapSBS_Action", message) if DEBUG_POPUP

    return false

  end



  #--------------------------------------------------------------------------

  # ● Action Key 是否存在

  #--------------------------------------------------------------------------

  def self.valid_action_key?(key)

    return false unless defined?(N01::ACTION)

    return N01::ACTION.include?(key.to_s)

  end



  #--------------------------------------------------------------------------

  # ● 複製 Actor 作為臨時地圖 Battler

  #--------------------------------------------------------------------------

  def self.make_proxy(actor_id, x, y, z)

    source = $game_actors[actor_id]

    return nil if source == nil



    proxy = source.clone

    proxy.extend(FS_MapSBS_Position)

    proxy.fs_map_sbs_setup(x, y, z)

    return proxy

  end

end



#==============================================================================

# ■ FS_MapSBS_Position

#------------------------------------------------------------------------------

#  以 singleton extension 覆寫複製 Actor 的戰鬥座標，不污染原 Actor。

#==============================================================================

module FS_MapSBS_Position

  def fs_map_sbs_setup(x, y, z)

    @fs_map_sbs_base_x = x

    @fs_map_sbs_base_y = y

    @fs_map_sbs_base_z = z



    @base_position_x = x

    @base_position_y = y

    @move_x = 0

    @move_y = 0

    @move_z = 0

    @jump = 0

    @active = true

    @play = 0

    @individual = false

    @force_action = nil

    @force_target = nil

    @collapse = false

    @action = Game_BattleAction.new(self)

  end



  def base_position

    @base_position_x = @fs_map_sbs_base_x

    @base_position_y = @fs_map_sbs_base_y

  end



  def index

    return 0

  end



  def position_x

    return @fs_map_sbs_base_x + (@move_x || 0)

  end



  def position_y

    return @fs_map_sbs_base_y + (@move_y || 0) + (@jump || 0)

  end



  def position_z

    return @fs_map_sbs_base_z + (@move_y || 0) + (@move_z || 0) - (@jump || 0)

  end



  def screen_x

    return position_x

  end



  def screen_y

    return position_y

  end



  def screen_z(height = 0)

    return position_z

  end



  # 地圖演出用 proxy 不參與死亡／離場判斷。

  def exist?

    return true

  end



  def dead?

    return false

  end

end



#==============================================================================

# ■ FS_MapSBS_Sprite

#------------------------------------------------------------------------------

#  使用真正 Sprite_Battler，但關閉 ATB Gauge 建立。

#==============================================================================

class FS_MapSBS_Sprite < Sprite_Battler

  # Cache.character 回傳的是共用 Bitmap。臨時 Sprite 銷毀前先解除引用，

  # 避免連地圖上原本的人物圖也一起被 dispose。人類果然連刪一張圖都能牽連九族。

  def dispose

    self.bitmap = nil if self.bitmap != nil

    super

  end



  def make_atb

    # 地圖上不建立 ATB Gauge。

  end



  def make_atb_viewport(new_viewport)

    # 地圖上不使用 ATB 專用 viewport。

  end



  def gauge_update

  end



  def gauge_refresh

  end



  def gauge_on

  end



  def gauge_off

  end

end



#==============================================================================

# ■ FS_MapSBS_AnimationAnchor

#------------------------------------------------------------------------------

#  讓 OBJ_ANIM 可以在地圖人物座標播放 RPG Animation。

#==============================================================================

class FS_MapSBS_AnimationAnchor < Sprite_Base

  def initialize(viewport, character)

    super(viewport)

    @character = character

    self.bitmap = Bitmap.new(1, 1)

    self.ox = 0

    self.oy = 0

    update_position

  end



  def update

    super

    update_position

  end



  def update_position

    return if @character == nil

    self.x = @character.screen_x + FS_MAP_SBS_ACTION::ANIMATION_OFFSET_X

    self.y = @character.screen_y + FS_MAP_SBS_ACTION::ANIMATION_OFFSET_Y

    begin

      self.z = @character.screen_z(200) + FS_MAP_SBS_ACTION::Z_OFFSET

    rescue

      self.z = 300

    end

  end



  def play_animation(animation_id, mirror)

    return if animation_id <= 0

    animation = $data_animations[animation_id]

    return if animation == nil

    start_animation(animation, mirror)

  end



  def dispose

    if self.bitmap != nil && !self.bitmap.disposed?

      self.bitmap.dispose

    end

    super

  end

end



#==============================================================================

# ■ Scene_Map

#==============================================================================

class Scene_Map < Scene_Base

  def fs_map_sbs_play(actor_id, action_key, character_id,

                      target_character_id, current_event_id,

                      hide_character, mirror, skill_id = 0)

    return FS_MAP_SBS_ACTION.error("Spriteset_Map 尚未建立。") if @spriteset == nil

    return @spriteset.fs_map_sbs_play(

      actor_id, action_key, character_id, target_character_id,

      current_event_id, hide_character, mirror, skill_id

    )

  end

end



#==============================================================================

# ■ Spriteset_Map

#==============================================================================

class Spriteset_Map

  #--------------------------------------------------------------------------

  # ● 解析地圖人物

  #--------------------------------------------------------------------------

  def fs_map_sbs_character(character_id, current_event_id)

    case character_id

    when -1

      return $game_player

    when 0

      return $game_map.events[current_event_id]

    else

      return $game_map.events[character_id]

    end

  end



  #--------------------------------------------------------------------------

  # ● 取得人物畫面 Z

  #--------------------------------------------------------------------------

  def fs_map_sbs_character_z(character)

    begin

      return character.screen_z(200) + FS_MAP_SBS_ACTION::Z_OFFSET

    rescue

      return character.screen_y + FS_MAP_SBS_ACTION::Z_OFFSET

    end

  end



  #--------------------------------------------------------------------------

  # ● 主執行程序

  #--------------------------------------------------------------------------

  def fs_map_sbs_play(actor_id, action_key, character_id,

                      target_character_id, current_event_id,

                      hide_character, mirror, skill_id = 0)

    return FS_MAP_SBS_ACTION.error("目前已有地圖 SBS 演出正在執行。") if @fs_map_sbs_running



    actor = $game_actors[actor_id]

    return FS_MAP_SBS_ACTION.error("找不到 Actor ID #{actor_id}。") if actor == nil

    return FS_MAP_SBS_ACTION.error("找不到 SBS Action Key：#{action_key}") unless FS_MAP_SBS_ACTION.valid_action_key?(action_key)



    if skill_id.to_i > 0 && $data_skills[skill_id.to_i] == nil

      return FS_MAP_SBS_ACTION.error("找不到技能 ID #{skill_id}。")

    end



    source_character = fs_map_sbs_character(character_id, current_event_id)

    return FS_MAP_SBS_ACTION.error("找不到來源地圖人物：#{character_id}") if source_character == nil



    if target_character_id == nil

      target_character = source_character

    else

      target_character = fs_map_sbs_character(target_character_id, current_event_id)

      return FS_MAP_SBS_ACTION.error("找不到目標地圖人物：#{target_character_id}") if target_character == nil

    end



    source_x = source_character.screen_x + FS_MAP_SBS_ACTION::OFFSET_X

    source_y = source_character.screen_y + FS_MAP_SBS_ACTION::OFFSET_Y

    source_z = fs_map_sbs_character_z(source_character)



    target_x = target_character.screen_x + FS_MAP_SBS_ACTION::OFFSET_X

    target_y = target_character.screen_y + FS_MAP_SBS_ACTION::OFFSET_Y

    target_z = fs_map_sbs_character_z(target_character)



    battler = FS_MAP_SBS_ACTION.make_proxy(actor_id, source_x, source_y, source_z)

    target_proxy = FS_MAP_SBS_ACTION.make_proxy(actor_id, target_x, target_y, target_z)

    return FS_MAP_SBS_ACTION.error("建立臨時地圖 Battler 失敗。") if battler == nil || target_proxy == nil



    temp_action = Game_BattleAction.new(battler)

    temp_action.clear if temp_action.respond_to?(:clear)

    temp_action.set_skill(skill_id.to_i) if skill_id.to_i > 0

    temp_action.target_index = 0

    temp_action.forcing = true

    battler.instance_variable_set(:@action, temp_action)

    battler.active = true

    battler.play = 0



    old_transparent = nil

    battler_sprite = nil

    animation_anchor = nil

    success = false



    begin

      @fs_map_sbs_running = true



      if hide_character && source_character.respond_to?(:transparent) &&

         source_character.respond_to?(:transparent=)

        old_transparent = source_character.transparent

        source_character.transparent = true

      end



      battler_sprite = FS_MapSBS_Sprite.new(@viewport1, battler)

      battler_sprite.make_battler

      battler_sprite.first_action if battler_sprite.respond_to?(:first_action)

      battler_sprite.get_target([target_proxy])

      battler_sprite.mirror = mirror unless mirror == nil



      animation_anchor = FS_MapSBS_AnimationAnchor.new(@viewport1, target_character)



      battler_sprite.start_action(action_key.to_s)

      success = fs_map_sbs_visual_loop(

        battler, battler_sprite, animation_anchor, target_character

      )

    ensure

      source_character.transparent = old_transparent unless old_transparent == nil



      if battler_sprite != nil && !battler_sprite.disposed?

        battler_sprite.dispose

      end

      if animation_anchor != nil && !animation_anchor.disposed?

        animation_anchor.dispose

      end



      @fs_map_sbs_running = false

    end



    return success

  end



  #--------------------------------------------------------------------------

  # ● 地圖 SBS 播放迴圈

  #     不更新 Game_Map Interpreter，避免事件遞迴執行。

  #     地圖人物暫停，但畫面、天氣、圖片與 SBS Sprite 持續更新。

  #--------------------------------------------------------------------------

  def fs_map_sbs_visual_loop(battler, battler_sprite,

                             animation_anchor, target_character)

    frame_count = 0

    loop do

      break if frame_count >= FS_MAP_SBS_ACTION::MAX_WAIT_FRAMES



      Graphics.update

      Input.update

      $game_system.update

      $game_map.screen.update if $game_map.respond_to?(:screen) && $game_map.screen != nil



      # 更新原地圖畫面，但不重入 $game_map.update／事件 Interpreter。

      update

      battler_sprite.update

      animation_anchor.update

      frame_count += 1



      signal = battler.play

      next if signal == nil || signal == 0

      battler.play = 0



      if signal.is_a?(Array) && signal[0] == "OBJ_ANIM"

        fs_map_sbs_visual_animation(animation_anchor, signal[1])

      elsif signal.is_a?(Array) && signal[0] == "Individual"

        next

      elsif signal == "Activation"

        # 地圖上沒有技能 QTE 視窗，直接略過。

        next

      elsif signal == "Can Collapse"

        # 地圖純演出不處理倒地／死亡。

        next

      elsif signal == "Cancel Action" || signal == "End" || signal == "終了"

        return true

      end

    end



    return FS_MAP_SBS_ACTION.error(

      "地圖 SBS Action 超過 #{FS_MAP_SBS_ACTION::MAX_WAIT_FRAMES} 幀仍未結束：可能缺少 End 或用了戰鬥限定序列。"

    )

  end



  #--------------------------------------------------------------------------

  # ● 只播放 RPG Animation，不執行任何技能效果

  #--------------------------------------------------------------------------

  def fs_map_sbs_visual_animation(animation_anchor, data)

    return if data == nil

    animation_id = data[0].to_i

    mirror = data[1] ? true : false

    return if animation_id <= 0

    animation_anchor.play_animation(animation_id, mirror)

  end

end



#==============================================================================

# ■ Game_Interpreter

#==============================================================================

class Game_Interpreter

  #--------------------------------------------------------------------------

  # ● 指定 Action Key，在地圖播放 SBS

  #--------------------------------------------------------------------------

  def map_sbs_action(actor_id, action_key, character_id = -1,

                     target_character_id = nil, hide_character = true,

                     mirror = nil)

    return FS_MAP_SBS_ACTION.error("map_sbs_action 只能在地圖上使用。") unless $scene.is_a?(Scene_Map)



    return $scene.fs_map_sbs_play(

      actor_id, action_key.to_s, character_id, target_character_id,

      @event_id, hide_character, mirror, 0

    )

  end



  #--------------------------------------------------------------------------

  # ● 借用技能 base_action，在地圖播放 SBS

  #--------------------------------------------------------------------------

  def map_sbs_skill_motion(actor_id, skill_id, character_id = -1,

                           target_character_id = nil, hide_character = true,

                           mirror = nil)

    return FS_MAP_SBS_ACTION.error("map_sbs_skill_motion 只能在地圖上使用。") unless $scene.is_a?(Scene_Map)



    skill = $data_skills[skill_id]

    return FS_MAP_SBS_ACTION.error("找不到技能 ID #{skill_id}。") if skill == nil



    return $scene.fs_map_sbs_play(

      actor_id, skill.base_action, character_id, target_character_id,

      @event_id, hide_character, mirror, skill_id

    )

  end

end
