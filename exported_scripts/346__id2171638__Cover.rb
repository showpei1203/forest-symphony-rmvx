#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Cover｜Tankentai SBS Add-on v2.1
# 【來源】Flipsomel / Lusitano Cover v2.1；額外 credit：Kal 的 Skill User ID 取得方式。原作測試環境 SBS 3.4e + ATB 1.2c。
# 【用途】透過 State 讓 Actor 替另一名 Actor 承受攻擊，並播放保護者移位／受傷／回位 SBS Action。原作明示不支援 Monster 作為 Cover Protector。
# 【Notetag】在 State Note：<COVER cover_type cover_param>。State 的 skill_user 會記錄施放者作為 protector，因此必須由技能正常附加該 State。
# 【Cover Type】1=永遠代擋物理；2=依 cover_param% 機率代擋物理；3=目標 HP% 低於 cover_param 時代擋物理；4=永遠代擋物理＋魔法；5=依機率代擋物理＋魔法；6=目標 HP% 低於門檻時代擋物理＋魔法。
# 【範例】<COVER 1 0> 永遠代擋物理；<COVER 2 50> 50% 機率代擋物理；若要「HP 20% 以下代擋物理＋魔法」應使用 Type 6，例如 <COVER 6 20>。原英文手冊最後一例寫 Type 3 卻描述物理＋魔法，與程式定義矛盾，本中文說明以實際 case 邏輯為準並保留原稿於 Archive。
# 【傷害規則】Cover 發生時使用 protector 自身能力重新計算傷害；Item／Healing 不轉給 Protector。protectee 的 State 變化與物理／魔法條件依本頁 can_be_Covered／apply_state_changes 流程處理。
# 【SBS Action】N01::COVERSCRIPT_SEQUENCE 新增 COVER_RESET 與 BE_COVERED；Cover 會把 Protector 暫時移到被保護者位置。原作者警告若 Protector 回合在 Start Pos Return 前開始，可能暫留錯位；可在 SBS COMMAND_INPUT 中補 Start Pos Return，但 FS 若已另有回位 Patch，修改前先實機確認。
# 【重要 State 設定】原作者要求 Cover State 在戰鬥結束時移除，否則 Protector 關聯資料可能殘留造成異常。
# 【依賴／為何不合併】本頁包裝 skill_effect、add_state/remove_state、make_attack_damage_value、make_obj_damage_value 等；後方 Job Skill Level、SummonEquip、EquipmentCombo、StateEffects／Mechanic 等仍繼續包傷害與 can_be_Covered。Phase 18 不做去 alias，維持現行 staged chain。
# 【相關素材】無固定圖片／音效檔名；依賴 Tankentai SBS Action Key、Battler Sprite 與 State Note。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
 
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/-----------------------------------------------------------------------------
#_/
#_/
#_/
#_/
#_/----------------------------------------------------------------------------
#_/                                   
#_/----------------------------------------------------------------------------
#_/
#_/
#_/   
#_/
#_/----------------------------------------------------------------------------
#_/----------------------------------------------------------------------------
#_/-----------------------------------------------------------------------------
#_/
#_/-----------------------------------------------------------------------------
#_/
#_/
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
 
#------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------
module N01
  COVERSCRIPT_SEQUENCE = {
                "COVER_RESET" => ["30","Start Pos Return","FLEE_RESET"],
                "BE_COVERED" => ["EVADE_JUMP","20","Start Pos Return","FLEE_RESET"]
        }               
ACTION.merge!(COVERSCRIPT_SEQUENCE)
end
 
#==============================================================================
#==============================================================================
class RPG::State
  attr_accessor :skill_user
end
 
# 供 Scene_Battle 使用
class Spriteset_Battle
  attr_accessor :actor_sprites
   
  # 回傳 battler 在 actor_sprites 陣列中的位置
  def pos_in_sprite_array(battler_id)
    for i in 0...actor_sprites.size
      if actor_sprites[i].battler.id == battler_id
        return i
      end
    end
      return -1
  end
     
end
# 提供 spriteset 存取
class Scene_Battle < Scene_Base
    attr_accessor :spriteset
  end
#==============================================================================
#==============================================================================
class Game_Battler
 
  alias lusitano_cover_old_initialize initialize
  def initialize
    lusitano_cover_old_initialize # 呼叫原 initialize
    @covered = nil
    @protector = 0
    @protector_spr_id = 0
    @cover_type = 0
    @cover_param = 0
    @is_covering = nil
  end
 
 
 alias cover_skill_effect skill_effect
  def skill_effect(user, skill)
    @skill_user = user
    cover_skill_effect(user, skill)
  end
 
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def LUS_COVER_check_for_state_extensions(state_id)
   
   
      return unless @states.include?(state_id)
   
      $data_states[state_id].note.each_line { |line|
          case line
          when /<(?:cover|COVER)\s*(\d+)\s*(\d+)>/i
              @cover_type = $1.to_i
              @cover_param = $2.to_i
              @covered = true
              @protector = $data_states[state_id].skill_user.id
              #$game_actors[@protector].set_covering
              @protector_spr_id = $scene.spriteset.pos_in_sprite_array(@protector)       
              return true
          end
      }
  end
 
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias add_state_lus_cover add_state
  def add_state(state_id)
   
    state = $data_states[state_id]
    state.skill_user = @skill_user
   
    add_state_lus_cover(state_id)
    LUS_COVER_check_for_state_extensions(state_id)
    remove_state_lus_cover(state_id) if @protector == self.id
  end
 
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias remove_state_lus_cover remove_state
  def remove_state(state_id)
   
    if LUS_COVER_check_for_state_extensions(state_id) == true
      @cover_type = 0
      @covered = false
      @protector = nil
      @protector_spr_id = 0
      @cover_param = 0
    end
   
    remove_state_lus_cover(state_id)
  end
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def can_be_Covered
 
    if $game_actors[@protector].dead? && @states.size > 0
      for state in @states
        if LUS_COVER_check_for_state_extensions(state.id) == true
          remove_state(state.id)
        end
      end 
      return false
    end
   
    case @cover_type
      when 1,4
        return true
      when 2,5
        chance = rand(100)
        return false unless chance >= @cover_param
        return true
      when 3,6
        return false unless ((self.hp.to_f / self.maxhp.to_f) * 100) <= @cover_param
        return true
      else
        return false
      end
  end
 
 
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias lus_cover_apply_state_changes apply_state_changes
  def apply_state_changes(obj)
   
    if @covered == true
      return if can_be_Covered 
    end
   
    lus_cover_apply_state_changes(obj)
  end
 
 
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias lusitano_cover_mk_atk_dam make_attack_damage_value
  def make_attack_damage_value(attacker)
   
    lusitano_cover_mk_atk_dam(attacker)
   
    return unless @covered == true 
    return unless can_be_Covered
   
    @hp_damage = 0
     
    $game_actors[@protector].make_attack_damage_value(attacker)
    $game_actors[@protector].execute_damage(attacker)
    #$scene.spriteset.actor_sprites[@protector_spr_id].damage_pop($game_actors[@protector].hp_damage)
    cover_sprite_movement
  end
 
    #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias lusitano_cover_make_obj_damage_value make_obj_damage_value
  def make_obj_damage_value(user, obj)
    lusitano_cover_make_obj_damage_value(user, obj)
   
    return unless @hp_damage > 0 && obj.is_a?(RPG::Skill)       
    return unless obj.physical_attack || @cover_type > 3
    
    # 如果是全體攻擊，則 Cover 效果無效
    return if obj.for_all? 
   
    return unless @covered == true
    return unless can_be_Covered 
   
    @hp_damage = 0
   
    $game_actors[@protector].make_attack_damage_value(user)
    $game_actors[@protector].execute_damage(user)   
    cover_sprite_movement
    $game_actors[@protector].apply_state_changes(obj)
  end 
   
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cover_sprite_movement
    #$scene is Scene_Battle
     
    self_sprite_id = $scene.spriteset.pos_in_sprite_array(self.id)
    action = $game_actors[self.id].be_covered_action
    $scene.spriteset.set_action(true, self_sprite_id, action)
   
    $game_actors[@protector].change_base_position(self.position_x, self.position_y)
    # $game_actors[@protector].position_y = self.position_y
    action = $game_actors[@protector].cover_action
    $scene.spriteset.set_action(true, @protector_spr_id, action)
     
    $scene.spriteset.actor_sprites[@protector_spr_id].damage_pop($game_actors[@protector].hp_damage)
   
   
    # $game_actors[@protector].damage_num($game_actors[@protector].hp_damage)   
  end
 
  def cover_action
    return "COVER_RESET"
  end
 
  def be_covered_action
    return "BE_COVERED"
  end
 
end
 