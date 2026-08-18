#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MonsterCollapse_Tankentai34d_Compat v2.1
# 【用途】Forest Symphony 相容／修正頁「FS_MonsterCollapse_Tankentai34d_Compat v2.1」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Game_Enemy、Sprite_Battler、FS_MC_T34D_COMPAT
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MIN_TYPE、MAX_TYPE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Monster Collapse Tankentai34d Compat；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_MonsterCollapse_Tankentai34d_Compat v2.1
#------------------------------------------------------------------------------
#  適用版本：
#    Tankentai Sideview 3.4d
#    Minto's Monster Collapse VX 1.2
#
#  用途：
#    1. 整合 Tankentai 與 Minto 的敵人死亡流程。
#    2. 防止同一敵人的死亡動畫、崩解效果、掉落統計、JP、擊殺計數等
#       因 perform_collapse 被重複呼叫而執行兩次。
#    3. COLLAPSE_ANIM 先完整播放，再開始崩解效果。
#    4. 一般／Minto 崩解音效只播放一次。
#    5. 保留 Tankentai 1～3 與 Minto 4～18 的整合編號。
#    6. 敵人復活後，可於下一次死亡重新播放死亡效果。
#
#  安裝位置：
#    1. 保留 Tankentai Sideview 3.4d。
#    2. 保留 Minto's Monster Collapse VX 1.2。
#    3. 停用或刪除舊的：
#       Monster Collapse + Tankentai SBS Compatibility Patch 1.0
#    4. 將本腳本放在「所有會修改 Game_Enemy#perform_collapse 的腳本」下方，
#       建議直接放在 Main 上方。
#
#  為什麼必須放得比較下面：
#    你的專案另有圖鑑、JP、擊殺計數、Linked Death 等腳本 alias
#    perform_collapse。只有本腳本位於它們下方，才能從最外層阻止同一死亡
#    被重複結算。人類把十套外掛串成一條鏈後，總得有人站在門口點名。
#
#==============================================================================
#  敵人 Note 寫法
#------------------------------------------------------------------------------
#  【Tankentai 類型】
#    <COLLAPSE: 1>
#    <COLLAPSE: 2>
#    <COLLAPSE: 3>
#
#  【整合類型】
#    \COLLAPSE_TYPE[n]
#
#      0  = 預設淡出
#      1  = 屍體保留在畫面上（Tankentai）
#      2  = 一般淡出（Tankentai）
#      3  = Boss 崩解（Tankentai）
#      4  = 縮小
#      5  = 水平膨脹
#      6  = 垂直膨脹
#      7  = 收縮上升
#      8  = 旋轉
#      9  = 搖晃下沉
#      10 = 垂直切割、上下分離
#      11 = 水平切割、左右分離
#      12 = 垂直切割、左右分離
#      13 = 水平切割、上下分離
#      14 = 波浪
#      15 = 模糊
#      16 = 快速旋轉並縮小
#      17 = 橡皮擦
#      18 = 像素消除
#
#  【死亡前動畫】
#    \COLLAPSE_ANIM[動畫ID]
#
#  【隨機 Minto 效果】
#    \COLLAPSE_TYPE_RANDOM
#    隨機範圍為預設淡出，以及 4～18 的 Minto 效果。
#
#  【顏色與混合模式】
#    \COLLAPSE_COLOR[#RRGGBBAA]
#    \COLLAPSE_BLEND[n]
#
#  注意：
#    同時寫 <COLLAPSE: n> 與 \COLLAPSE_TYPE[n] 時，後者優先。
#------------------------------------------------------------------------------
#  v2.1 修正：
#    修正 RGSS2 Rect 物件使用「!= nil」比較時，可能發生
#    TypeError: can't convert NilClass into Rect。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Monster Collapse Tankentai34d Compat"] = "2.1"

module FS_MC_T34D_COMPAT
  VERSION = "2.1"
  MIN_TYPE = 0
  MAX_TYPE = 18

  # 0 是整合表中的「預設淡出」，實際交由 Tankentai 類型 2 執行。
  def self.effective_type(value)
    n = value.to_i
    return 2 if n == 0
    return 2 if n < MIN_TYPE || n > MAX_TYPE
    return n
  end

  def self.valid_type(value)
    n = value.to_i
    return 2 if n < MIN_TYPE || n > MAX_TYPE
    return n
  end

  def self.random_type
    list = [0]
    for i in 4..18
      list.push(i)
    end
    return list[rand(list.size)]
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
#  從最外層鎖住 perform_collapse，使同一條生命只執行一次死亡流程。
#==============================================================================
class Game_Enemy < Game_Battler
  unless method_defined?(:fs_mc34d_v21_perform_collapse)
    alias fs_mc34d_v21_perform_collapse perform_collapse
  end

  def perform_collapse(*args)
    # 非戰鬥中或尚未死亡時，維持原腳本鏈的行為。
    unless $game_temp != nil && $game_temp.in_battle && dead?
      return fs_mc34d_v21_perform_collapse(*args)
    end

    # 同一條生命只准進入一次。可同時阻止動畫、JP、圖鑑、擊殺數重複。
    return if @fs_mc34d_collapse_started
    @fs_mc34d_collapse_started = true

    # 必須先固定類型。隨機效果也只抽一次，不會每幀重新抽籤。
    selected_type = fs_mc34d_resolve_collapse_type

    # 執行目前專案中既有的完整 alias 鏈。
    fs_mc34d_v21_perform_collapse(*args)

    # Minto 1.2 會把 @collapse_type 改回自己的 0～15 編號，
    # 因此在原流程結束後，恢復成整合後的 0～18 編號。
    @collapse_type = selected_type
  end

  # Tankentai 與 Minto 都會讀取此方法。
  def collapse_type
    if @collapse_type == nil
      @collapse_type = fs_mc34d_resolve_collapse_type
    end
    return @collapse_type
  end

  # 決定整合後的崩解類型。
  def fs_mc34d_resolve_collapse_type
    note = enemy.note.to_s
    value = nil

    # Minto 整合標籤優先。
    if note =~ /\\COLLAPSE_TYPE\[(\d+)\]/i
      value = $1.to_i
    # Tankentai Note 標籤其次。
    elsif note =~ /<COLLAPSE[:]?\s*(\d+)\s*>/i
      value = $1.to_i
    # 隨機效果只抽一次並快取於 Game_Enemy。
    elsif note =~ /\\COLLAPSE_TYPE_RANDOM/i
      value = FS_MC_T34D_COMPAT.random_type
    else
      # 讀取 Tankentai 原本的敵人 ID 設定。
      # Notetags for Tankentai Add-on 雖被 Minto 的 attr_reader 蓋掉，
      # 但它留下的 alias 方法仍可取得 SBS Battler Configuration 的設定。
      if respond_to?(:bubs_tsbs_notetags_enemy_collapse_type)
        begin
          value = bubs_tsbs_notetags_enemy_collapse_type
        rescue
          value = nil
        end
      end
      value = 2 if value == nil
    end

    return FS_MC_T34D_COMPAT.valid_type(value)
  end

  # 敵人復活後解除死亡鎖，下一次死亡才能正常播放。
  unless method_defined?(:fs_mc34d_v21_hp_set)
    alias fs_mc34d_v21_hp_set hp=
  end

  def hp=(value)
    fs_mc34d_v21_hp_set(value)
    if self.hp > 0
      @fs_mc34d_collapse_started = false
      @collapse_type = nil
      @collapse = false
      if @force_action == ["N01collapse"]
        @force_action = 0
      end
    end
  end

  # 變身後重新讀取新敵人的崩解設定。
  unless method_defined?(:fs_mc34d_v21_transform)
    alias fs_mc34d_v21_transform transform
  end

  def transform(enemy_id)
    fs_mc34d_v21_transform(enemy_id)
    @collapse_type = nil unless @fs_mc34d_collapse_started
  end
end

#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
#  統一處理 Tankentai 與 Minto 的死亡動畫、等待、崩解、SE 與復活還原。
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● Setup New Effect
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_mc34d_v21_setup_new_effect)
    alias fs_mc34d_v21_setup_new_effect setup_new_effect
  end

  def setup_new_effect
    # 若敵人已復活，先解除 Minto 的座標鎖與死亡圖像狀態。
    if @battler != nil && !@battler.actor? && !@battler.dead? &&
       @fs_mc34d_collapsing
      fs_mc34d_restore_after_revive
    end

    starting_enemy_collapse = false
    if @battler != nil && !@battler.actor? && @battler.collapse
      starting_enemy_collapse = true
    end

    fs_mc34d_v21_setup_new_effect

    # COLLAPSE_ANIM 路線由內建 @collapse 啟動，不會經過 collapse_action，
    # 因此在此補上 Tankentai／Minto 的整合類型與正確時長。
    if starting_enemy_collapse
      fs_mc34d_prepare_collapse
      type = FS_MC_T34D_COMPAT.effective_type(@collapse_type)
      if type == 1
        @effect_duration = 1
      elsif type == 3
        @effect_duration = 401
      else
        @effect_duration = 48
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Collapse Action
  #--------------------------------------------------------------------------
  #  直接取代舊相容補丁。敵人沒有 COLLAPSE_ANIM 時，Tankentai 會走此路線。
  #--------------------------------------------------------------------------
  def collapse_action(*args)
    @non_repeat = true
    @effect_type = COLLAPSE

    # Tankentai 正常情況下不會讓敵方以外的 battler 進入 N01collapse。
    return if @battler == nil || @battler.actor?

    fs_mc34d_prepare_collapse
    @battler_visible = false

    type = FS_MC_T34D_COMPAT.effective_type(@collapse_type)
    if type == 1
      # 屍體留在畫面上，不建立倒數效果。
      @effect_duration = 0
    elsif type == 3
      @effect_duration = 401
    else
      # Tankentai 的等待時間結束後，再執行 48 幀崩解。
      @effect_duration = N01::COLLAPSE_WAIT + 48
    end
  end

  #--------------------------------------------------------------------------
  # ● Update Collapse
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_mc34d_v21_update_collapse)
    alias fs_mc34d_v21_update_collapse update_collapse
  end

  def update_collapse(*args)
    # 我方角色維持專案原本的 Sideview 行為。
    if @battler == nil || @battler.actor?
      return fs_mc34d_v21_update_collapse(*args)
    end

    # 死亡動畫尚未結束時，把崩解倒數補回來。
    # 因此順序固定為：COLLAPSE_ANIM → 崩解效果。
    if self.animation?
      @effect_duration += 1
      return
    end

    type = FS_MC_T34D_COMPAT.effective_type(@battler.collapse_type)
    @collapse_type = @battler.collapse_type

    case type
    when 1
      self.opacity = 255
      @effect_duration = 0
    when 2
      # Tankentai 一般淡出。SE 只會在 duration == 47 時播放一次。
      normal_collapse
      fs_mc34d_apply_minto_color
    when 3
      # Boss 崩解保留 Tankentai 原本的多段震動與音效。
      boss_collapse1
    else
      # 整合編號 4～18 對應 Minto 原始編號 1～15。
      fs_mc34d_execute_minto(type - 3)
      normal_collapse
      fs_mc34d_apply_minto_color
    end

    if @dup_sprite != nil
      @dup_sprite.opacity = self.opacity
    end

    fs_mc34d_finish_collapse if @effect_duration == 0
  end

  #--------------------------------------------------------------------------
  # ● Prepare Collapse
  #--------------------------------------------------------------------------
  def fs_mc34d_prepare_collapse
    @collapse_type = @battler.collapse_type
    @fs_mc34d_collapsing = true
    @fs_mc34d_finished = false
    @pixels_to_erase = nil

    # 留存復活時需要還原的圖像與座標資料。
    @fs_mc34d_original_bitmap = self.bitmap
    @fs_mc34d_original_x = self.x
    @fs_mc34d_original_y = self.y
    @fs_mc34d_original_ox = self.ox
    @fs_mc34d_original_oy = self.oy
    # RGSS2 的 Rect#== 無法安全地和 nil 比較。
    # 使用「rect != nil」會嘗試把 nil 轉成 Rect，直接發生 TypeError。
    rect = self.src_rect
    unless rect.nil?
      @fs_mc34d_original_src_rect = Rect.new(rect.x, rect.y,
        rect.width, rect.height)
    end
  end

  #--------------------------------------------------------------------------
  # ● Apply Minto Colour / Blend
  #--------------------------------------------------------------------------
  def fs_mc34d_apply_minto_color
    return if @battler == nil || @battler.actor?
    color = @battler.enemy.collapse_color
    self.color.set(color[0], color[1], color[2], color[3])
    self.blend_type = @battler.enemy.collapse_blend
  end

  #--------------------------------------------------------------------------
  # ● Execute Minto Collapse 1～15
  #--------------------------------------------------------------------------
  #  這裡直接整合 Minto 1.2 的效果，避免再次呼叫舊相容補丁的 alias，
  #  也就不會多執行一次 normal_collapse 或 Sound.play_enemy_collapse。
  #--------------------------------------------------------------------------
  def fs_mc34d_execute_minto(type)
    case type
    when 1 # Shrink
      self.zoom_x -= 0.02
      self.zoom_y -= 0.02
      self.y -= (0.01 * self.height)
    when 2 # Horizontal Expansion
      self.zoom_x += 0.05
    when 3 # Vertical Expansion
      self.zoom_y += 0.05
      self.zoom_x -= 0.02
    when 4 # Contract and Ascend
      if @effect_duration >= 24
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
    when 6 # Shake and Descend
      if @effect_duration >= 44
        self.ox -= 1
      else
        self.ox += ((@effect_duration / 4) % 2) == 0 ? 2 : -2
      end
      self.src_rect.y -= self.bitmap.rect.height / 48
    when 7 # Vertical Division; Vertical Movement
      create_dup_sprite(0) if @effect_duration == 47 && @dup_sprite == nil
      if @dup_sprite != nil
        self.y += [self.oy / 96, 1].max
        @dup_sprite.y -= [@dup_sprite.oy / 96, 1].max
      end
    when 8 # Horizontal Division; Horizontal Movement
      create_dup_sprite(1) if @effect_duration == 47 && @dup_sprite == nil
      if @dup_sprite != nil
        self.x += [self.ox / 48, 1].max
        @dup_sprite.x -= [@dup_sprite.ox / 48, 1].max
      end
    when 9 # Vertical Division; Horizontal Movement
      create_dup_sprite(0) if @effect_duration == 47 && @dup_sprite == nil
      if @dup_sprite != nil
        self.x += [self.ox / 48, 1].max
        @dup_sprite.x -= [@dup_sprite.ox / 48, 1].max
      end
    when 10 # Horizontal Division; Vertical Movement
      create_dup_sprite(1) if @effect_duration == 47 && @dup_sprite == nil
      if @dup_sprite != nil
        self.y += [self.oy / 96, 1].max
        @dup_sprite.y -= [@dup_sprite.oy / 96, 1].max
      end
    when 11 # Wave
      self.wave_amp += 1
    when 12 # Blur
      if @effect_duration == 47
        @fs_mc34d_original_bitmap = self.bitmap
        self.bitmap = self.bitmap.dup
      end
      self.bitmap.blur if @effect_duration % 4 == 0
    when 13 # Rotate Fast & Shrink
      self.angle += 48 - @effect_duration
      fs_mc34d_execute_minto(1)
    when 14 # Eraser
      self.bush_opacity = 0
      self.bush_depth += (self.height / 48.0).ceil
    when 15 # Pixel Eraser
      if @effect_duration == 47
        @fs_mc34d_original_bitmap = self.bitmap
        self.bitmap = self.bitmap.dup
        @pixels_to_erase = []
        for i in 0...self.bitmap.width
          for j in 0...self.bitmap.height
            @pixels_to_erase.push([i, j])
          end
        end
        @pixel_erase_rate = [(@pixels_to_erase.size / 48.0).ceil, 1].max
      end
      if @pixels_to_erase != nil && @pixels_to_erase.size > 0
        erase_color = Color.new(255, 255, 255, 0)
        count = [@pixel_erase_rate, @pixels_to_erase.size].min
        count.times do
          index = rand(@pixels_to_erase.size)
          x, y = @pixels_to_erase.delete_at(index)
          self.bitmap.set_pixel(x, y, erase_color)
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Finish Collapse
  #--------------------------------------------------------------------------
  def fs_mc34d_finish_collapse
    return if @fs_mc34d_finished
    @fs_mc34d_finished = true

    # Minto 的分割副圖不可直接 dispose，否則可能連 Cache 圖像一起釋放。
    if @dup_sprite != nil
      @dup_sprite.visible = false
      @dup_sprite.opacity = 0
      @dup_sprite = nil
    end
    @pixels_to_erase = nil
  end

  #--------------------------------------------------------------------------
  # ● Restore After Revive
  #--------------------------------------------------------------------------
  def fs_mc34d_restore_after_revive
    @effect_type = 0
    @effect_duration = 0
    @collapse_type = nil
    @non_repeat = false
    @fs_mc34d_collapsing = false
    @fs_mc34d_finished = false

    self.bitmap = @fs_mc34d_original_bitmap if @fs_mc34d_original_bitmap != nil
    self.x = @fs_mc34d_original_x if @fs_mc34d_original_x != nil
    self.y = @fs_mc34d_original_y if @fs_mc34d_original_y != nil
    self.ox = @fs_mc34d_original_ox if @fs_mc34d_original_ox != nil
    self.oy = @fs_mc34d_original_oy if @fs_mc34d_original_oy != nil
    unless @fs_mc34d_original_src_rect.nil?
      self.src_rect.set(@fs_mc34d_original_src_rect.x,
        @fs_mc34d_original_src_rect.y,
        @fs_mc34d_original_src_rect.width,
        @fs_mc34d_original_src_rect.height)
    end

    self.zoom_x = 1.0
    self.zoom_y = 1.0
    self.angle = 0
    self.wave_amp = 0
    self.bush_depth = 0
    self.bush_opacity = 128
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
    self.visible = true
    @battler_visible = true

    if @dup_sprite != nil
      @dup_sprite.visible = false
      @dup_sprite.opacity = 0
      @dup_sprite = nil
    end

    @pixels_to_erase = nil
    @fs_mc34d_original_bitmap = nil
    @fs_mc34d_original_src_rect = nil
    @fs_mc34d_original_x = nil
    @fs_mc34d_original_y = nil
    @fs_mc34d_original_ox = nil
    @fs_mc34d_original_oy = nil
  end
end
