#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：戰鬥HUD-0226｜Window_BattleStatus Skin Core
# 【用途】目前正式戰鬥底層 Window_BattleStatus Skin／HP/MP/OD 數字顯示核心。它不是 Phase 13 的 FS_BattleStateHUD_Authority：前者負責隊伍底部 Status Skin，後者是額外狀態詳細 HUD／Target Info；兩套 UI 同時存在。
# 【主要責任】重開 Window_BattleStatus，建立每位 Actor 的 Skin、HP/MP Gauge、滾動數字、OD 數字、額外角色區塊與 HUD_<角色名> 圖；另外提供 Sprite_strNumber／Sprite_strNumbers 與 Bitmap#draw_text_f。
# 【固定素材】Graphics/System/Btskin_main、Btskin_hp、Btskin_mp、Btskin_n00、Btskin_n01、Btskin_state、Iconset，以及 Graphics/System/HUD_<actor.name>。若角色改名而沒有同名 HUD 圖，需實機確認 Cache.system 載入。
# 【位置設定】BTSKIN_B_XY 為整體背景偏移；BTSKIN_00XY~06XY 分別控制 Skin／HP／MP／數字／State；BTSKIN_EXTRA_XY、EXTRA_OFFSET、STATE_OFFSET 控制 actor.id>=7 的額外角色區。
# 【速度／位數】BTSKIN_01GS/02GS 為 HP/MP Gauge 追隨速度；04SS/25SS/05SS 為 HP/OD/MP 滾動數字速度；04NS/25NS/05NS 為最大位數。
# 【額外角色】actor.id<7 使用一般底部位置；actor.id>=7 走額外區塊。create_extra_background 使用 Bitmap#fill_rounded_rect，因此直接依賴前方 Bitmap Addons Authority。EXTRA_STATUS_ALPHA 與 STATE_ZOOM 控制額外區透明度／狀態圖示縮放。
# 【依賴鏈】前方 SBS/ATB 已建立 Window_BattleStatus；本頁在其後覆寫 UI 實作。下一頁 STR11+og_KGC Overdrive（269）會直接使用 BTSKIN_* 常數／狀態陣列追加 OD Gauge，因此 268→269 的相對順序不能調換。後方 FS BattleStateHUD/TargetUI 是額外 Overlay，不是本頁可替代品。
# 【呼叫方式】Scene_Battle／ATB 自動建立 Window_BattleStatus；沒有事件 Script Call。調外觀優先改 BTSKIN_* 常數與素材，除非已完整追過 update_hp/update_mp/sprite array index，否則不要隨意改索引。
# 【清理警告】本頁大量 s[index] 具有固定語意，269 及其他戰鬥 UI 直接依賴；看似未使用的 Index 或註解區不能只憑肉眼刪除。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#==============================================================================
class Window_BattleStatus < Window_Selectable
  
  # Skin 檔名
  BTSKIN_00 = "Btskin_main"   # 主 HUD Skin
  BTSKIN_01 = "Btskin_hp"     # HP Gauge
  BTSKIN_02 = "Btskin_mp"     # MP Gauge
  BTSKIN_04 = "Btskin_n00"    # HP 數字
  BTSKIN_25 = "Btskin_n01"    # OD 數字
  BTSKIN_05 = "Btskin_n00"    # MP 數字
  BTSKIN_03 = "Btskin_state"  # 狀態
  
  # Skin 座標 [x, y]
  BTSKIN_B_XY = [-179, -17]         # 背景偏移
  BTSKIN_00XY = [-28, 17] # 詳見頁首繁中維護說明
  BTSKIN_01XY = [15, 20]            # HP Gauge（FS 調整）
  BTSKIN_02XY = [15, 33]            # MP Gauge（FS 調整）
  BTSKIN_04XY = [29, 16]            # HP 數字（FS 調整）
  BTSKIN_25XY = [37, 43]            # OD 數字（FS 調整）
  BTSKIN_05XY = [33, 30]            # MP 數字（FS 調整）
  BTSKIN_03XY = [29, 26]            # 狀態
  BTSKIN_06XY = [71, -11]           # 狀態 Icon 偏移
  
  BTSKIN_01GS = 1             # HP Gauge 追隨速度
  BTSKIN_02GS = 1             # MP Gauge 追隨速度
  BTSKIN_04SS = 3             # HP 滾動數字速度
  BTSKIN_25SS = 3             # OD 滾動數字速度
  BTSKIN_05SS = 2             # MP 滾動數字速度
  BTSKIN_04NS = 4             # HP 最大位數
  BTSKIN_25NS = 4             # OD 最大位數
  BTSKIN_05NS = 4             # MP 最大位數
  BTSKIN_06WH = [22,24]       # [State Width, Height]
  BTSKIN_06SC = 3             # 狀態 Icon 捲動速度
  
  # 額外角色（actor.id >= 7）
  BTSKIN_EXTRA_XY = [480, -5]
  EXTRA_OFFSET = [0, 50]      # 額外角色 X/Y 間距
  STATE_OFFSET = [150, 62]
  # 狀態縮放比例
  STATE_ZOOM = 1.0 # 可自行設定額外角色的狀態圖示縮小比例
  # 新增變數：額外角色狀態區塊最終透明度 (可調整)
  EXTRA_STATUS_ALPHA = 200
  # 新增：額外角色Status背景（全域，只建立一次）
  # 將根據額外角色數量調整高度：基本高度30，每增加一個額外角色增加20。
  def create_extra_background
    extra_actors = $game_party.members.select { |actor| actor.id >= 7 }
    return if extra_actors.empty?
    # 取得所有額外角色在狀態區的 y 值（依據 set_xy）
    ys = []
    extra_actors.each_with_index do |actor, i|
      # 從 set_xy 中取得對應的 y 值
      idx = $game_party.members.index(actor)
      ys.push(@y[idx])
    end
    base_y = ys.min
    height = 50 + (extra_actors.size - 1) * 50
    width = 120   # 可根據需求調整
    @extra_background = Sprite.new(@viewport)
    @extra_background.bitmap = Bitmap.new(width, height)
    rect = Rect.new (0, 0, width, height)
    @extra_background.bitmap.fill_rounded_rect (rect, Color.new (65, 117, 120, 150))
    @extra_background.x = @x[$game_party.members.index(extra_actors.first)]
    @extra_background.y = base_y + 13
    @extra_background.z = 50  # 低於名字與狀態圖示
  end
  #---------------------------------------------------------------------------
  # 設定每位角色狀態 HUD 座標
  #---------------------------------------------------------------------------
  def set_xy
    @x = []
    @y = []
    extra_count = 0
    for i in 0...$game_party.members.size
      actor = $game_party.members[i]
      if actor.id < 7
        x = (i * 139) + 40
        y = 3 + 342
        @x[i] = x + 176
        @y[i] = y + 26
      else
        @x[i] = BTSKIN_EXTRA_XY[0] + extra_count * EXTRA_OFFSET[0]
        @y[i] = BTSKIN_EXTRA_XY[1] + extra_count * EXTRA_OFFSET[1]
        extra_count += 1
      end
    end
  end
  
  @@f = false
  alias initialize_str33 initialize
  def initialize(f = false)
    initialize_str33
    unless @@f
      @f = @@f = true
    else
      @f = false
    end
    set_xy
    create_extra_background  # 建立額外角色的背景
    @s_sprite = []
    @s_party = []
    @s_lv = []
    @opacity = 255
    self.contents.dispose
    self.create_contents
    self.back_opacity = 0
    self.opacity = 0
    @viewport = Viewport.new(2, 0, 640, 416)
    @hpgw = Cache.system(BTSKIN_01).width
    @mpgw = Cache.system(BTSKIN_02).width
    @viewport.z = self.z - 1
    @state_opacity = []
    @item_max = $game_party.members.size
    return unless @f
    for i in 0...@item_max
      draw_item(i)
    end
    update
  end
  
  # 當窗口關閉時，立即隱藏額外角色的 HP/MP 條
  def close
    super
    @s_sprite.each do |sprites|
      if sprites && sprites[20]
        sprites[20].opcaty = 0
        sprites[20].visible = false
      end
    end
    @extra_background.visible = false if @extra_background
  end
  
  def refresh
    # :-)
  end
  
  #---------------------------------------------------------------------------
  # 繪製角色狀態 Icon（含額外角色縮放）
  #---------------------------------------------------------------------------
  def draw_actor_state(actor)
    icon = Cache.system("Iconset")
    w = actor.states.size * 24
    w = 24 if w < 1
    bitmap = Bitmap.new(w, BTSKIN_06WH[1])
    count = 0
    zoom = (actor.id >= 7) ? STATE_ZOOM : 1.0
    
    for state in actor.states
      icon_index = state.icon_index
      x = 24 * count * zoom
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      bitmap.blt(x, 0, icon, rect, 255)
      bitmap.stretch_blt(Rect.new(x, 0, 24 * zoom, 24 * zoom), icon, rect)
      duration = actor.state_turns[state.id]
      bitmap.font.size = (14 * zoom).to_i
      
      if state.auto_release_prob > 0 and duration >= 0
        bitmap.draw_text(x-3, 6, (24 * zoom).to_i, WLH, duration, 2)
      end
      count += 1
    end
    return bitmap
  end
  
  #--------------------------------------------------------------------------
  # 繪製狀態剩餘回合（若適用）
  #--------------------------------------------------------------------------
  def draw_state_turns(x, y, state, actor)
    zoom = (actor.id >= 7) ? STATE_ZOOM : 1.0
    w = actor.states.size * 24 * zoom
    w = 24 * zoom if w < 1
    bitmap = Bitmap.new(w, BTSKIN_06WH[1])
    count = 0
    return unless YEM::UPGRADE::DRAW_STATE_TURNS
    return if state == nil
    return unless actor.state_turns.include?(state.id)
    dy = y - (YEM::UPGRADE::STATE_TURN_F_SIZE - 10)
    duration = actor.state_turns[state.id]
    for state in actor.states
      x = 24 * count * zoom
      if state.auto_release_prob > 0 and duration >= 0
        self.contents.font.color = text_color(state.turn_colour)
        self.contents.font.size = YEM::UPGRADE::STATE_TURN_F_SIZE
        self.contents.font.bold = YEM::UPGRADE::STATE_TURN_BOLD
        self.contents.draw_text(x, 10, 24* zoom, WLH* zoom, duration, 2)
      end
      count += 1
    end
    return bitmap
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def name_bitmap(actor)
    bitmap = Bitmap.new(100, 24)
    bitmap.font.size = 16
    bitmap.font.bold = true
    bitmap.draw_text_f(0, 0, 100, 24, actor.name)
    return bitmap
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def state_size(actor)
    return actor.states.size
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @f
    actor = $game_party.members[index]
    extra_actor = (actor.id >= 7)
    @s_sprite[index] = []
    s = @s_sprite[index]
    
    if extra_actor
      zoom = STATE_ZOOM
      s[15] = Sprite.new(@viewport)
      s[15].bitmap = name_bitmap(actor)
      s[15].x = @x[index] + 3
      s[15].y = @y[index] + 15
      s[15].z = 255
      
      # HP Gauge (使用 BTSKIN_01)
      s[1] = Sprite.new(@viewport)
      s[1].bitmap = Cache.system(BTSKIN_01)
      s[1].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_01XY[0]
      s[1].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_01XY[1]
      s[1].z = 4
      w = s[1].bitmap.width; h = s[1].bitmap.height / 2
      s[1].src_rect.set(0, 0, w, h)
      s[2] = Sprite.new(@viewport)
      s[2].bitmap = Cache.system(BTSKIN_01)
      s[2].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_01XY[0]
      s[2].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_01XY[1]
      s[2].z = 3
      s[2].src_rect.set(0, h, w, h)
      s[1].x += 165
      s[1].y += 35
      s[2].x += 165
      s[2].y += 35
      s[1].zoom_x = 0.5
      s[1].zoom_y = 0.5
      s[2].zoom_x = 0.5
      s[2].zoom_y = 0.5

      s[11] = 96
      
      # HP 數字 (s[6])

      s[13] = actor.hp

      
      # MP Gauge (使用 BTSKIN_02)
      s[3] = Sprite.new(@viewport)
      s[3].bitmap = Cache.system(BTSKIN_02)
      s[3].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_02XY[0]
      s[3].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_02XY[1]
      s[3].z = 4
      w = s[3].bitmap.width; h = s[3].bitmap.height / 2
      s[3].src_rect.set(0, 0, w, h)
      s[4] = Sprite.new(@viewport)
      s[4].bitmap = Cache.system(BTSKIN_02)
      s[4].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_02XY[0]
      s[4].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_02XY[1]
      s[4].z = 3
      s[4].src_rect.set(0, h, w, h)
      s[3].x += 165
      s[3].y += 33
      s[4].x += 165
      s[4].y += 33
      s[3].zoom_x = 0.5
      s[3].zoom_y = 0.5
      s[4].zoom_x = 0.5
      s[4].zoom_y = 0.5
      s[12] = 56
      
      # MP 數字 (s[7])

      s[14] = actor.mp

      
      # 狀態圖示 (viewport與plane)
      #s[5].z = 100
      #s[8].z = 99
      
      s[11] = ((@hpgw * actor.hp.to_f / actor.maxhp) + 1).to_i
      if actor.maxmp != 0
        s[12] = ((@mpgw * actor.mp.to_f / actor.maxmp) + 1).to_i
      else
        s[12] = 0
      end
      
      # 額外角色不建立 HUD (s[16])
    else
      # 一般角色：完整狀態（不含名稱）
      s[0] = Sprite.new(@viewport)
      s[0].bitmap = Cache.system(BTSKIN_00)
      s[0].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_00XY[0]
      s[0].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_00XY[1]
      s[0].z = 0
      
      s[1] = Sprite.new(@viewport)
      s[1].bitmap = Cache.system(BTSKIN_01)
      s[1].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_01XY[0]
      s[1].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_01XY[1]
      s[1].z = 4
      w = s[1].bitmap.width
      h = s[1].bitmap.height / 2
      s[1].src_rect.set(0, 0, w, h)
      
      s[2] = Sprite.new(@viewport)
      s[2].bitmap = Cache.system(BTSKIN_01)
      s[2].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_01XY[0]
      s[2].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_01XY[1]
      s[2].z = 3
      s[2].src_rect.set(0, h, w, h)
      s[11] = 96
      
      s[6] = Sprite_strNumbers.new(@viewport, BTSKIN_04, BTSKIN_04NS)
      s[6].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_04XY[0]
      s[6].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_04XY[1]
      s[6].z = 5
      s[13] = actor.hp
      s[6].update(s[13])
      
      s[25] = Sprite_strNumbers.new(@viewport, BTSKIN_25, BTSKIN_25NS)
      s[25].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_25XY[0]
      s[25].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_25XY[1]
      s[25].z = 5
      s[26] = actor.overdrive
      s[25].update(s[26])
      
      s[3] = Sprite.new(@viewport)
      s[3].bitmap = Cache.system(BTSKIN_02)
      s[3].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_02XY[0]
      s[3].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_02XY[1]
      s[3].z = 4
      w = s[3].bitmap.width
      h = s[3].bitmap.height / 2
      s[3].src_rect.set(0, 0, w, h)
      
      s[4] = Sprite.new(@viewport)
      s[4].bitmap = Cache.system(BTSKIN_02)
      s[4].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_02XY[0]
      s[4].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_02XY[1]
      s[4].z = 3
      s[4].src_rect.set(0, h, w, h)
      s[12] = 56
      
      s[7] = Sprite_strNumbers.new(@viewport, BTSKIN_05, BTSKIN_05NS)
      s[7].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_05XY[0]
      s[7].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_05XY[1]
      s[7].z = 5
      s[14] = actor.mp
      s[7].update(s[14])
      
      #s[5].z = 100
      
      #s[8].z = 99
      
      
      s[11] = ((@hpgw * actor.hp.to_f / actor.maxhp) + 1).to_i
      if actor.maxmp != 0
        s[12] = ((@mpgw * actor.mp.to_f / actor.maxmp) + 1).to_i
      else
        s[12] = 0
      end
      
      s[16] = Sprite.new(@viewport)
      s[16].bitmap = Cache.system("HUD_" + actor.name)
      s[16].x = @x[index] + 12 - 219
      s[16].y = @y[index] - 4 + 224 - 342
      s[16].z = 0
    end
    @s_lv[index] = actor.level
    @s_party[index] = [actor.name, actor.hp, actor.maxhp, actor.mp, actor.maxmp, actor.states]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose       
    super
    @extra_background.bitmap.dispose rescue nil
    @extra_background.dispose rescue nil

    return unless @f
    for i in 0...@s_sprite.size
      for l in [0,1,2,3,4,15,16,20]
        next unless @s_sprite[i][l]
        @s_sprite[i][l].bitmap.dispose rescue nil
        @s_sprite[i][l].dispose rescue nil
      end
      for l in [6,7,25]
        next unless @s_sprite[i][l]
        @s_sprite[i][l].dispose rescue nil
      end
    end
    @@f = false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    return unless @f
    # 若窗口完全關閉，立即隱藏額外角色的HP/MP條
    if self.openness == 0
      @s_sprite.each { |sprites| sprites[20].visible = false if sprites && sprites[20] }
    end
    for i in 0...@s_sprite.size
      s = @s_sprite[i]
      a = $game_party.members[i]
      m = @s_party[i]
      @state_opacity[i] = 0 if @state_opacity[i].nil?
      @state_opacity[i] += 8
      
      if a.id >= 7
        # 額外角色：使用與一般角色相同的更新方式 (不更新 main 與 HUD)
        update_hp(s, a, m)
        update_mp(s, a, m)
        if a.name != m[0]
          s[15].bitmap.dispose
          s[15].bitmap = name_bitmap(a)
          m[0] = a.name
        end
      else
        if @opacity < 272
          @opacity += 8
          for l in [0, 1, 2, 3, 4]
            s[l].opacity = @opacity if s[l]
          end
          s[16].opacity = @opacity if s[16]
          for l in [6, 7]
            s[l].o = @opacity if s[l]
          end
        end
      end
      
      if a.id >= 7
        if @opacity < 272
          @opacity += 8
          for l in [0, 1, 2, 3, 4]
            s[l].opacity = @opacity if s[l]
          end
          s[16].opacity = @opacity if s[16]
          for l in [6, 7]
            s[l].o = @opacity if s[l]
          end
        end
        #狀態圖示滾動
        #  s[9].ox += 1 
        #  s[9].ox = 0
      else
        update_hp(s, a, m)
        update_mp(s, a, m)
        #正常角色循環icon
        #  s[9].ox += 1 
        
        #  s[9].ox = 0
      end
    end
  end
  
#--------------------------------------------------------------------------  
#--------------------------------------------------------------------------  
def update_hp(s, a, m)
  # 先更新 gauge 資料，對所有角色都進行
  if a.hp != m[1]
    s[11] = ((@hpgw * a.hp.to_f / a.maxhp) + 1).to_i
    m[1] = a.hp
  end

  # 僅對一般角色（a.id < 7）更新數字顯示
  if a.id < 7 && a.hp != s[13]
    c = 0
    c = 1 if a.hp < a.maxhp / 4
    c = 2 if a.hp == 0
    if s[13] > a.hp
      s[13] -= BTSKIN_04SS
      s[13] = a.hp if s[13] < a.hp
    else
      s[13] += BTSKIN_04SS
      s[13] = a.hp if s[13] > a.hp
    end
    s[6].update(s[13], c)
  end

  # 針對一般角色更新 Overdrive 數字
  if a.id < 7
    if a.overdrive != s[26]
      c = 0; c = 1 if a.overdrive > (1000 / 4); c = 2 if a.overdrive >= 1000
      if s[26] > a.overdrive
        s[26] -= BTSKIN_25SS
        s[26] = a.overdrive if s[26] < a.overdrive
      else
        s[26] += BTSKIN_25SS
        s[26] = a.overdrive if s[26] > a.overdrive
      end
      s[25].update(s[26], c) if s[25]
    end
  end

  # 更新 HP gauge 寬度（所有角色）
  sr = s[1].src_rect
  if sr.width != s[11]
    sp = BTSKIN_01GS
    sr.width = (s[11] + (s[1].bitmap.width * (sp - 1))) / sp
    sr.width = 2 if sr.width <= 1 and a.hp > 0
  end
  sr = s[2].src_rect
  sp = 2
  if sr.width != s[1].src_rect.width and (Graphics.frame_count % sp) == 0
    if sr.width < s[1].src_rect.width
      sr.width += 1
    else
      sr.width -= 1
    end
  end
  sr.width = 2 if sr.width <= 1 and a.hp > 0
end

#--------------------------------------------------------------------------  
#--------------------------------------------------------------------------  
def update_mp(s, a, m)
  # 先更新 gauge 資料，對所有角色都進行
  if a.mp != m[3]
    s[12] = (a.maxmp != 0 ? ((@mpgw * a.mp.to_f / a.maxmp) + 1).to_i : 0)
    m[3] = a.mp
  end

  # 僅對一般角色更新 MP 數字
  if a.id < 7 && a.mp != s[14]
    c = 0; c = 1 if a.mp < a.maxmp / 4
    if s[14] > a.mp
      s[14] -= BTSKIN_05SS
      s[14] = a.mp if s[14] < a.mp
    else
      s[14] += BTSKIN_05SS
      s[14] = a.mp if s[14] > a.mp
    end
    s[7].update(s[14], c)
  end

  # 更新 MP gauge 寬度（所有角色）
  sr = s[3].src_rect
  if sr.width != s[12]
    sp = BTSKIN_02GS
    sr.width = (s[12] + (s[3].bitmap.width * (sp - 1))) / sp
    sr.width = 2 if sr.width <= 1 and a.mp > 0
  end
  sr = s[4].src_rect
  sp = 2
  if sr.width != s[3].src_rect.width and (Graphics.frame_count % sp) == 0
    if sr.width < s[3].src_rect.width
      sr.width += 1
    else
      sr.width -= 1
    end
  end
  sr.width = 2 if sr.width <= 1 and a.mp > 0
end

end

#==============================================================================
#==============================================================================
class Sprite_strNumber < Sprite
  def initialize(v, gra, n = 0)
    @n = n
    super(v)
    self.bitmap = Cache.system(gra)
    @w = self.bitmap.width / 10
    @h = self.bitmap.height / 3
    self.src_rect = Rect.new(@n * @w, 0, @w, @h)
  end
  def update(n = -1, c = 0)
    @n = n
    self.src_rect.x = @n * @w
    self.src_rect.y = c * @h
  end
end

#==============================================================================
#==============================================================================
class Sprite_strNumbers
  attr_accessor :x, :y, :z, :o 
  def initialize(v, gra, n = 4, s = 0)
    @n = n
    @x = 0
    @y = 0
    @z = 0
    @o = 255
    @sprite = []
    b = Cache.system(gra)
    @s = b.width / 10 - s
    for i in 0...n
      @sprite[i] = Sprite_strNumber.new(v, gra)
    end
    update
  end
  
  def zoom_x
    @sprite.first.zoom_x
  end
  def zoom_x=(val)
    @sprite.each { |sp| sp.zoom_x = val }
  end
  def zoom_y
    @sprite.first.zoom_y
  end
  def zoom_y=(val)
    @sprite.each { |sp| sp.zoom_y = val }
  end
  
  def update(v = 0, c = 0)
    val = []
    for i in 0...@n
      val[i] = v / (10 ** (i)) % 10
    end
    val = val.reverse 
    for i in 0...@n
      if val[i] == 0 and @n != i + 1
        val[i] = -1
      else
        break
      end
    end
    for i in 0...@n
      @sprite[i].update(val[i], c)
      @sprite[i].x = @x + (i * @s)
      @sprite[i].y = @y
      @sprite[i].z = @z
      @sprite[i].opacity = @o
    end
  end
  def o=(val)
    @o = val
    for i in 0...@n
      @sprite[i].opacity = @o
    end
  end
  def dispose
    for i in 0...@sprite.size
      @sprite[i].bitmap.dispose rescue nil
      @sprite[i].dispose rescue nil
    end
  end
end

#==============================================================================
#==============================================================================
class Bitmap
  def draw_text_f(x, y, width, height, str, align = 0, color = Color.new(64,32,128))
    shadow = self.font.shadow
    b_color = self.font.color.dup
    self.font.shadow = true
    self.font.color = color
    draw_text(x + 1, y, width, height, str, align) 
    draw_text(x - 1, y, width, height, str, align) 
    draw_text(x, y + 1, width, height, str, align) 
    draw_text(x, y - 1, width, height, str, align) 
    self.font.color = b_color
    draw_text(x, y, width, height, str, align)
    self.font.shadow = shadow
  end
  def draw_text_f_rect(r, str, align = 0, color = Color.new(64,32,128))
    draw_text_f(r.x, r.y, r.width, r.height, str, align, color)
  end
end
