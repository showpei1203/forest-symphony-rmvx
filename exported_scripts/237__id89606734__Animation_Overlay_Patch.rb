#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Animation Overlay Patch
# 【用途】Tankentai 動畫疊加修正，處理動畫層級／覆蓋與戰鬥演出的相容問題。
# 【主要機制】屬 SBS Add-on；要維持在相關 SBS Core 之後。
# 【主要影響】Sprite_Battler、Scene_Battle、Game_Battler、Sprite_Base、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ANIMATION_RATE、RATE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：TankentaiAnimPatch、CoreFixesUpgradesMelody。
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
# + Animation Overlay Patch for RPG Tankentai SBS
#------------------------------------------------------------------------------
#  Methods from 'Yanfly Engine Melody - Core Fixes and Upgrades' is used in this
#  script. Original script can be found at http://www.pockethouse.com/
#------------------------------------------------------------------------------
#  Code from Core Fixes and Upgrades by Yanfly
#  Patch set up by Mr. Bubble
#==============================================================================
# ++ How to Install
# * Place below the Sideview scripts
#==============================================================================
# There has been a long-existing issue with Screen animations playing 
# an animation for each target. This causes the undesirable effect of
# Screen animations having an incorrect opacity level and simultaneous
# sound effects (which may possibly cause hurt ear drums!).
#
# Fortunately, Yanfly has created a very thorough patch which fixes
# this issue once and for all -- except with Tankentai.
#
# Since Tankentai uses its own method of displaying animations, some
# of the Tankentai base code had to be tweaked in order for Yanfly's 
# animation fix to apply. Not only does this patch fix Screen animations 
# played with Tankentai, but it also makes the animation rate option
# Yanfly included fully compatible.
#
# Keep in mind that if you have 'Yanfly Engine Melody - Core Fixes 
# and Upgrades' already installed in your script editor, a large portion
# of this script will get disabled and instead use the methods defined
# in 'Core Fixes and Upgrades' (methods in this script are directly
# taken there). If you choose to use Yanfly Engine Melody - Core Fixes 
# and Upgrades in your project, remember that it must be placed above
# the Sideview scripts.
#==============================================================================

module N01
    # This adjusts the animation rate played by battle animations. By default,
    # animations are played at 40fps with a rate of 4. By changing it to 3, the
    # animations will change to 60fps for a smoother effect. Beware of using
    # heavy animations that may cause the player's computer to explode.
    ANIMATION_RATE = 3
    # This value will not be used if Yanfly Engine Melody - Core Fixes and 
    # Upgrades script is installed.
end

$imported = {} if $imported == nil
$imported["TankentaiAnimPatch"] = true

#==============================================================================
# + Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ++ Show Battle Animation [判別, ID, target, mirror, wait, Weapon 2 flag]
  #--------------------------------------------------------------------------
  def battle_anime
    # return if enemy and processing animation for Weapon 2
    return if @active_action[5] && !@battler.actor?
    # return if trying to process Weapon 2 animation with no Weapon 2 equipped.
    return if @active_action[5] && @battler.weapons[1] == nil
    # return if actor has Weapon 2 equipped, but not Weapon 1
    if @battler.actor?
      return if !@active_action[5] && @battler.weapons[0] == nil && @battler.weapons[1] != nil
    end
    anime_id = @active_action[1]
    # 3.4a properly mirror animations if enemy is manually set to be mirroed
    if @battler.is_a?(Game_Enemy)
      mirror = false
      mirror = true if @battler.action_mirror
    end
    # Mirror animation when in back attack
    if $back_attack
      mirror = true if !@active_action[3] # 3.4a
      mirror = false if @active_action[3] || (@battler.is_a?(Game_Enemy) && @battler.action_mirror) # 3.4a
    end
    # 3.4c
    # Damage with no animation
    if anime_id == -3
      # No animation if anime ID is -3
      anime_id = 0
      # ダメージ表示のアニメなら、ダメージ計算を先に済ませるため処理を中断
      damage_action = [anime_id, mirror, true]
      return @battler.play = ["OBJ_ANIM",damage_action] if @battler.active
    end
    # For skill, item, and weapon animations
    if anime_id < 0
      # Branches from here depending on type of action
      if @battler.action.skill? && anime_id != -2
        ### UNOFFICAL CODE v3.3b ###
        anime_id = @battler.action.skill.animation_id unless @battler.action.skill.animation_id == -1
        if @battler.action.skill.animation_id == -1
          anime_id = N01::NO_WEAPON
          if @battler.actor?
            weapon_id = @battler.weapon_id
            anime_id = $data_weapons[weapon_id].animation_id if weapon_id != 0
            anime_id = @battler.atk_animation_id2 if @active_action[5]
          else
            weapon_id = @battler.weapon
            anime_id = $data_weapons[weapon_id].animation_id if weapon_id != 0
          end
        end
      elsif @battler.action.item? && anime_id != -2
        anime_id = 0
        anime_id = @battler.action.item.animation_id unless @battler.action.item.animation_id == -1
        if @battler.action.item.animation_id == -1
          anime_id = N01::NO_WEAPON
          weapon_id = @battler.weapon_id
          anime_id = $data_weapons[weapon_id].animation_id if weapon_id != 0
          anime_id = @battler.atk_animation_id2 if @active_action[5]
        end
        ### UNOFFICIAL CODE v3.3b END ###
        else
        # Unarmed attack animation
        anime_id = N01::NO_WEAPON
        if @battler.actor?
          weapon_id = @battler.weapon_id
          anime_id = $data_weapons[weapon_id].animation_id if weapon_id != 0
          # For Two Swords Style animation
          anime_id = @battler.atk_animation_id2 if @active_action[5]
        else
          weapon_id = @battler.weapon
          anime_id = $data_weapons[weapon_id].animation_id if weapon_id != 0
        end
      end
      # Set wait value, temporarily delays action sequence processing
      @wait = $data_animations[anime_id].frame_max * RATE + 1 if $data_animations[anime_id] != nil && @active_action[4]
      waitflug = true
      # ダメージ表示のアニメなら、ダメージ計算を先に済ませるため処理を中断
      damage_action = [anime_id, mirror, true]
      return @battler.play = ["OBJ_ANIM",damage_action] if @battler.active && @active_action[1] != -4 # 3.4a
    end
    # Process animation
    if @active_action[2] == 0 && $data_animations[anime_id] != nil
      @battler.animation_id = anime_id
      @battler.animation_mirror = mirror
    elsif $data_animations[anime_id] != nil
      # From CoreFixesUpgradesMelody
      animation = $data_animations[anime_id]
      to_screen = (animation.position == 3)
      ani_check = false
      for target in @target_battler
        if ani_check
          target.pseudo_ani_id = anime_id
        else
          target.animation_id = anime_id
          target.animation_id = 153 if target.state?(36)#魔法盾
          target.animation_mirror = mirror
        end
        ani_check = true if to_screen
      end
    end
    # Set Wait
    @wait = $data_animations[anime_id].frame_max * RATE + 1 if $data_animations[anime_id] != nil && @active_action[4] && !waitflug
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ++ Auto Resurrection - Animation
  #--------------------------------------------------------------------------
  def resurrection(target)
    for state in target.states
      for ext in state.extension
        name = ext.split('')
        next unless name[0] == "A"
        wait(50)
        name = name.join
        name.slice!("AUTOLIFE/")
        target.hp = target.maxhp * name.to_i / 100
        target.remove_state(1)
        target.remove_state(state.id)
        target.animation_id = N01::RESURRECTION
        target.animation_mirror = true if $back_attack
        @status_window.refresh
        wait($data_animations[N01::RESURRECTION].frame_max * RATE + 1)
      end  
    end
  end
end

# Code below this point will not be used if Yanfly Engine Melody - Core 
# Fixes and Upgrades script is installed.

unless $imported["CoreFixesUpgradesMelody"]
  
class Game_Battler
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :pseudo_ani_id
  #--------------------------------------------------------------------------
  # alias method: clear_sprite_effects
  #--------------------------------------------------------------------------
  alias clear_sprite_effects_cfu clear_sprite_effects unless $@
  def clear_sprite_effects
    clear_sprite_effects_cfu
    @pseudo_ani_id = 0
  end
end

#==============================================================================
# Sprite_Base
#==============================================================================

class Sprite_Base < Sprite
  
  #--------------------------------------------------------------------------
  # constants
  #--------------------------------------------------------------------------
  RATE = N01::ANIMATION_RATE
  
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    update_animation if @animation != nil
    @@animations.clear
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: start_animation
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    load_animation_bitmap
    @animation_sprites = []
    if @animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(self.viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        @@animations.push(animation) unless @@animations.include?(animation)
      end
    end
    if @animation.position == 3
      if viewport == nil
        @animation_ox = Graphics.width / 2
        @animation_oy = Graphics.height / 2
      else
        @animation_ox = viewport.rect.width / 2
        @animation_oy = viewport.rect.height / 2
      end
    else
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
      if @animation.position == 0
        @animation_oy -= height / 2
      elsif @animation.position == 2
        @animation_oy += height / 2
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: start_pseudo_ani
  #--------------------------------------------------------------------------
  def start_pseudo_ani(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    @animation_sprites = []
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_animation
  #--------------------------------------------------------------------------
  def update_animation
    # from Tankentai
    if @animation.position == 1 # 3.4a
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
    end
    
    @animation_duration -= 1
    return unless @animation_duration % RATE == 0
    if @animation_duration > 0
      frame_index = @animation.frame_max
      frame_index -= (@animation_duration+RATE-1)/RATE
      animation_set_sprites(@animation.frames[frame_index])
      for timing in @animation.timings
        next unless timing.frame == frame_index
        animation_process_timing(timing)
      end
      return
    end
    dispose_animation
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: animation_process_timing
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * RATE)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * RATE)
      end
    when 3
      self.flash(nil, timing.flash_duration * RATE)
    end
  end
    
end # Sprite_Base

#==============================================================================
# Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias setup_new_effect_cfu setup_new_effect unless $@
  def setup_new_effect
    setup_new_effect_cfu
    if @battler.pseudo_ani_id != 0 and @battler.pseudo_ani_id != nil
      animation = $data_animations[@battler.pseudo_ani_id]
      start_pseudo_ani(animation)
      @battler.pseudo_ani_id = 0
    end
  end
  
end # Sprite_Battler

end # $imported["CoreFixesUpgradesMelody"]