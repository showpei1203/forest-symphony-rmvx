#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Monster Collapse VX v1.2
# 【來源】Minto & modern algebra（rmrk.net），v1.2，2010-06-25。
# 【用途】擴充 Enemy 死亡動畫：可播放指定 Database Animation、選擇 0~15 種 Collapse 效果、設定消散顏色與 Blend。後方 FS_MonsterCollapse_Tankentai34d_Compat 必須維持在本頁之後。
# 【Enemy Notetag】`\COLLAPSE_ANIM[n]` 指死亡動畫 ID；`\COLLAPSE_TYPE[n]` 選效果；`\COLLAPSE_TYPE_RANDOM` 每隻實例隨機；`\COLLAPSE_COLOR[#RRGGBBAA]` 設消散色；`\COLLAPSE_BLEND[n]`：0 Normal、1 Add、2 Sub。
# 【Collapse Type】0預設；1縮小；2水平擴張；3垂直擴張；4收縮上升；5旋轉；6搖晃下降；7垂直切割/垂直分離；8水平切割/水平分離；9垂直切割/水平分離；10水平切割/垂直分離；11 Wave；12 Blur；13快速旋轉+縮小；14 Eraser；15 Pixel Eraser。
# 【範例】Enemy Note：`\COLLAPSE_ANIM[51]` + `\COLLAPSE_TYPE[13]` + `\COLLAPSE_BLEND[0]`。若使用 Pixel/Blur 類效果，原作者建議 Blend 0 往往較合適。
# 【素材】無固定圖片；COLLAPSE_ANIM 使用資料庫 Animation。預設 Enemy Collapse SE 仍由 Sound.play_enemy_collapse／後續 Battle System 決定。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#    Version: 1.2
#    Author: Minto & modern algebra (rmrk.net)
#    Date: June 25, 2010
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 說明：
#
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 使用說明：
#  
#
#
#      \COLLAPSE_ANIM[n]
#   
#      \COLLAPSE_TYPE[n]
#
#      \COLLAPSE_TYPE_RANDOM
#
#      \COLLAPSE_COLOR[#hex]
#                  \collapse_colour[#FF808080] # Default
#
#      \COLLAPSE_BLEND[n]
#==============================================================================

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class RPG::Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def collapse_animation
    @collapse_anim = self.note[/\\COLLAPSE_ANIM\[(\d+)\]/i] != nil ? $1.to_i : 0 if @collapse_anim.nil?
    return @collapse_anim
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def collapse_type
    return $1.to_i if self.note[/\\COLLAPSE_TYPE\[(\d+)\]/i] != nil
    array = self.effect_ids
    return array[rand (array.size)] if self.note[/\\COLLAPSE_TYPE_RANDOM/i] != nil
    return 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def collapse_color
    r, g, b, a = 255, 128, 128, 128
    if self.note[/\\COLLAPSE_COLOU?R\[#([\dABCDEF]+)\]/i] != nil
      r = $1[0, 2].to_i (16) if $1.size >= 2
      g = $1[2, 2].to_i (16) if $1.size >= 4
      b = $1[4, 2].to_i (16) if $1.size >= 6
      a = $1[6, 2].to_i (16) if $1.size >= 8
    end
    return r, g, b, a
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def collapse_blend
    return $1.to_i % 3 if self.note[/\\COLLAPSE_BLEND\[(\d+)\]/i] != nil
    return 1
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def effect_ids
    effects = []
    for i in 0...16 do effects.push (i) end
    return effects
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :collapse_type # The collapse type for this enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_mino_prfrmclpse_mons_0ki2 perform_collapse
  def perform_collapse (*args)
    if enemy.collapse_animation > 0 && $game_temp.in_battle && dead?
      @collapse = true
      self.animation_id = enemy.collapse_animation
    else
      # 執行原方法
      malg_mino_prfrmclpse_mons_0ki2 (*args)
    end
    @collapse_type = enemy.collapse_type
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Sprite_Battler
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_mint_moncollapse_upd_0kh2 update_collapse
  def update_collapse (*args)
    if @battler.actor?
      malg_mint_moncollapse_upd_0kh2 (*args) # Run Original Method
      return
    end
    if self.animation?
      @effect_duration += 1
      return
    end
    execute_special_collapse (@battler.collapse_type) 
    malg_mint_moncollapse_upd_0kh2 (*args) # Run Original Method
    self.color.set (*@battler.enemy.collapse_color)
    self.blend_type = @battler.enemy.collapse_blend
    @dup_sprite.opacity = self.opacity if @dup_sprite != nil
    if @effect_duration == 0 
      self.zoom_x = 1
      self.zoom_y = 1
      @dup_sprite = nil
    elsif @effect_duration == 47 && @battler.enemy.collapse_animation > 0
      Sound.play_enemy_collapse 
    end 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mal_minto_setx_collapse_0kh3 x=
  def x= (n, *args)
    return if @effect_type == COLLAPSE && n == @battler.screen_x
    mal_minto_setx_collapse_0kh3 (n, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias algbmod_ntomi_yset_cllpse_9gb2 y=
  def y= (n, *args)
    return if @effect_type == COLLAPSE && n == @battler.screen_y
    algbmod_ntomi_yset_cllpse_9gb2 (n, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_dup_sprite (split_type = 0)
    @dup_sprite = self.class.new (self.viewport, @battler)
    @dup_sprite.x, @dup_sprite.y = self.x, self.y
    @dup_sprite.blend_type = 1
    @dup_sprite.color.set(255, 128, 128, 128)
    @dup_sprite.update
    if split_type == 0 # Vertical Split
      @dup_sprite.src_rect.width = @dup_sprite.ox
      self.src_rect.x = self.ox
      self.x += self.ox
    elsif split_type == 1 # Horizontal Split
      @dup_sprite.src_rect.height = @dup_sprite.oy / 2
      self.src_rect.y = self.oy / 2
      self.y += self.oy / 2
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #    collapse_type (type of collapse)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def execute_special_collapse (collapse_type)
    case collapse_type
    when 1 # Shrink
      self.zoom_x -= 0.02
      self.zoom_y -= 0.02
      self.y -= (0.01*self.height)
    when 2 # Horizontal Expansion
      self.zoom_x += 0.05
    when 3 # Vertical Expansion
      self.zoom_y += 0.05
      self.zoom_x -= 0.02
    when 4 # Spring Ascent
      if @effect_duration >= 24 then
        self.zoom_y = [self.zoom_y - 0.02, 0].max
        self.zoom_x = [self.zoom_x + 0.01, 1.24].min
      else
        self.zoom_x -= 0.115
        self.zoom_y += 0.6
      end
    when 5 # Rotate
      self.zoom_x -= 0.03
      self.zoom_y += 0.05
      self.angle += 7.5
    when 6 # Shake Descent
      if @effect_duration >= 44
        self.ox -= 1
      else
        self.ox += ((@effect_duration / 4) % 2) == 0 ? 2 : -2
      end
      self.src_rect.y -= self.bitmap.rect.height / 48
    when 7 # 垂直切割；垂直分離
      create_dup_sprite (0) if @effect_duration == 47 # Split Vertically
      self.y += [self.oy / 96, 1].max
      @dup_sprite.y -= [@dup_sprite.oy / 96, 1].max
    when 8 # 水平切割；水平分離
      create_dup_sprite (1) if @effect_duration == 47 # Split Horizontally
      self.x += [self.ox / 48, 1].max
      @dup_sprite.x -= [@dup_sprite.ox / 48, 1].max
    when 9 # 垂直切割；水平分離
      create_dup_sprite (0) if @effect_duration == 47 # Split Vertically
      self.x += [self.ox / 48, 1].max
      @dup_sprite.x -= [@dup_sprite.ox / 48, 1].max
    when 10 # 水平切割；垂直分離
      create_dup_sprite (1) if @effect_duration == 47 # Split Horizontally
      self.y += [self.oy / 96, 1].max
      @dup_sprite.y -= [@dup_sprite.oy / 96, 1].max
    when 11 # Wave
      self.wave_amp += 1
    when 12 # Blur
      self.bitmap = self.bitmap.dup if @effect_duration == 47
      self.bitmap.blur if @effect_duration % 4 == 0
    when 13 # Fast Rotate and Shrink
      self.angle += 48 - @effect_duration
      execute_special_collapse (1)
    when 14 # Eraser
      self.bush_opacity = 0
      self.bush_depth += (self.height / 48.0).ceil
    when 15 # Pixel Eraser
      if @effect_duration == 47
        self.bitmap = self.bitmap.dup
        @pixels_to_erase = []
        for i in 0...self.bitmap.width
          for j in 0...self.bitmap.height
            @pixels_to_erase.push ([i, j])
          end
        end
        @pixel_erase_rate = @pixels_to_erase.size / 48
      end
      erase_color = Color.new (255, 255, 255, 0)
      @pixel_erase_rate.times do
        x, y = @pixels_to_erase.delete_at (rand (@pixels_to_erase.size))
        self.bitmap.set_pixel (x, y, erase_color)
      end
    end
  end
end