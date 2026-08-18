#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ウィンドウクラス
# 【用途】保留的 Runtime 元件「ウィンドウクラス」。
# 【主要機制】主要定義／擴充 Window_BsCmd、Window_BsSysCmd、Window_BsModCmd、Sprite_BsTAG；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_BsCmd、Window_BsSysCmd、Window_BsModCmd、Sprite_BsTAG、Window_BsCtg、Window_BsList、Window_BsSList
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：C_W、OFFSET、M_ITEM、M_PARTY、M_ACTOR、PATTERN、TEXT_H、ES_W。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconset。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ VX-RGSS2-17 鍛冶屋 [ウィンドウクラス]             by Claimh
#==============================================================================

#==============================================================================
# ■ Window_BsCmd
#==============================================================================
class Window_BsCmd < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, WLH + 32, 544-160, WLH + 32)
  end
  def enable
    self.active = self.visible = true
  end
  def disable
    self.active = self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    x = 4 + index * self.width / @column_max
    self.contents.draw_text(x, 0, 300, WLH, @commands[index])
  end
end


#==============================================================================
# ■ Window_BsSysCmd
#==============================================================================
class Window_BsSysCmd < Window_BsCmd
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    @commands = Blacksmith.sys_cmd
    @item_max = @column_max = @commands.size
    refresh
    self.index = 0
  end
  def fix?
    return (Blacksmith::SYS_CMD.size == 1)
  end
  def exit?
    return (Blacksmith::SYS_CMD[@index] == 2)
  end
  def sys
    return Blacksmith::SYS_CMD[@index]
  end
end



#==============================================================================
# ■ Window_BsModCmd
#==============================================================================
class Window_BsModCmd < Window_BsCmd
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(sys=0)
    super()
    self.sys = sys
  end
  def sys=(s)
    @commands = Blacksmith.mod_cmd(s)
    @item_max = @column_max = @commands.size
    refresh
    self.index = 0
  end
  def fix?
    return (Blacksmith::MOD_CMD.size == 1)
  end
  def exit?
    return (Blacksmith::MOD_CMD[@index] == 2)
  end
  def mod
    return Blacksmith::MOD_CMD[@index]
  end
end

#==============================================================================
# ■ Sprite_BsTAG
#==============================================================================
class Sprite_BsTAG < Sprite
  W = 100
  H = 14
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, z, tag)
    super(Viewport.new(x, y, W, H))
    self.viewport.z = z
    self.bitmap = Bitmap.new(W, H)
    self.bitmap.font.size = 12
    self.bitmap.font.color = Color.new(192, 224, 255, 255)
    refresh(tag)
  end
  def refresh(tag)
    self.bitmap.clear
    self.bitmap.draw_text(0, 0, W, H, tag)
  end
end

#==============================================================================
# ■ Window_BsCtg
#==============================================================================
class Window_BsCtg < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, WLH + 32, 544-160, WLH + 32)
    self.z = 200
    self.visible = false
    @type = 0
    @index = 0
    @index_s = [0, 0]
    @fix = false
  end
  def fix?
    return @fix
  end
  #--------------------------------------------------------------------------
  # ● 変更
  #--------------------------------------------------------------------------
  def change(t)
    @index_s[@type] = Blacksmith::S_INDEX ? @index : 0
    @type = t
    ct = t == 0 ? Blacksmith::W_CT : Blacksmith::A_CT
    @commands = []
    for i in 0...ct.size
      @commands[i] = ct[i][0]
    end
    @item_max = @column_max = @commands.size
    refresh
    @index = @index_s[t]
    self.cursor_rect.set(@index * self.contents.width / @column_max, 0, WLH+4, WLH)
    @fix = (@type == 0 ? Blacksmith::W_CT.size : Blacksmith::A_CT.size) == 1
    self.visible = !@fix
    self.contents_opacity = 255 # VXバグ対策
  end
  def shift_l
    draw_item(@index, false, true)
    @index = (@index - 1 + @item_max) % @item_max
    draw_item(@index, true, true)
    self.cursor_rect.set(@index * self.contents.width / @column_max, 0, WLH+4, WLH)
  end
  def shift_r
    draw_item(@index, false, true)
    @index = (@index + 1) % @item_max
    draw_item(@index, true, true)
    self.cursor_rect.set(@index * self.contents.width / @column_max, 0, WLH+4, WLH)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, i == @index)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index, enable, clear=false)
    x = 2 + index * self.contents.width / @column_max
    if clear
      rect = Rect.new(x, 2, 24, WLH)
      self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    end
    draw_icon(@commands[index], x, 0, enable)
  end
end

#==============================================================================
# ■ Window_BsList
#==============================================================================
class Window_BsList < Window_Selectable
  attr_accessor :pt_window
  attr_accessor :sts_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(sys=0, mod=0, ctg=0)
    super(0, (WLH+32)*2, 544-120, (WLH*7+32))
    self.contents.dispose
    @dmy_win = Window_Base.new(x, y, width, height)
    self.z = 200
    @sprite_p = Sprite_BsTAG.new(self.x+270, self.y+2, self.z+10, "花費")
    @sprite_n = Sprite_BsTAG.new(self.x+360, self.y+2, self.z+10, "持有")
    @data = [nil, nil, nil, nil]
    @tmp_bit = Bitmap.new(1, 1)
    @bitmap = [[],[],[],[]]
    @index_s = [[],[],[],[]]
    @sys = @mod = @ctg = -1
    change_t(sys*2+mod, ctg)
    @pt_window = @sts_window = nil
    disable
  end
  def enable
    @dmy_win.visible = false
    self.active = self.visible = @sprite_p.visible = @sprite_n.visible = true
  end
  def disable
    @dmy_win.visible = true
    self.active = self.visible = @sprite_p.visible = @sprite_n.visible = false
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト開放
  #--------------------------------------------------------------------------
  def dispose
    super
    for t in 0...@bitmap.size
      dispose_bitmap(t)
    end
    @dmy_win.dispose
    @sprite_p.dispose
    @sprite_n.dispose
  end
  def dispose_bitmap(t)
    return if @bitmap[t].nil? or @bitmap[t].empty?
    for b in @bitmap[t]
      unless b.nil?
        b.dispose
        b = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 動作タイプ
  #--------------------------------------------------------------------------
  C_W=0;C_A=1;S_W=2;S_A=3
  def type
    return (@sys*2 + @mod)
  end
  def type=(t)
    @sys = t / 2
    @mod = t % 2
    @sprite_p.refresh(@sys==0 ? "花費" : "裝備")
  end
  def category(t)
    case t
    when Blacksmith::C_W, Blacksmith::S_W;  return Blacksmith::W_CT.size
    when Blacksmith::C_A, Blacksmith::S_A;  return Blacksmith::A_CT.size
    end
    return 0
  end
  def sys_create?
    return (@sys == 0)
  end
  #--------------------------------------------------------------------------
  # ● モード切り替え
  #--------------------------------------------------------------------------
  def change_t(t, c=0)
    if self.type != t
      push_index(self.type, @ctg)
      self.type = t
      @ctg = c
      refresh_data(t) if @data[t].nil?
      self.contents = @bitmap[t][c]
      @item_max = @data[t][c].size
      pop_index(t, c)
    else
      change_c(c)
    end
  end
  def change_c(c)
    if @ctg != c
      push_index(self.type, @ctg)
      t = self.type
      @ctg = c
      self.contents = @bitmap[t][c]
      @item_max = @data[t][c].size
      pop_index(t, c)
    else
      pop_index(self.type, c)
    end
  end
  def pop_index(t, c)
    self.index = (@index_s[t][c] < 0 ? 0 : @index_s[t][c])
  end
  def push_index(t, c)
    return if t < 0 or c < 0
    @index_s[t][c] = Blacksmith::S_INDEX ? @index : 0
  end
  #--------------------------------------------------------------------------
  # ● データ初期化
  #--------------------------------------------------------------------------
  def refresh_data(t)
    case t
    when C_W; @data[t] = $game_system.bs.c_w.make_list
    when C_A; @data[t] = $game_system.bs.c_a.make_list
    when S_W; @data[t] = $game_system.bs.s_w.make_list
    when S_A; @data[t] = $game_system.bs.s_a.make_list
    end
    refresh_t_bitmap(t)
  end
  #--------------------------------------------------------------------------
  # ● ビットマップ初期化
  #--------------------------------------------------------------------------
  def refresh_t_bitmap(t)
    dispose_bitmap(t)
    @bitmap[t] = []
    @index_s[t] = []
    for c in 0...category(t)
      refresh_bitmap(t, c)
    end
  end
  #--------------------------------------------------------------------------
  # ● カテゴリビットマップ初期化
  #--------------------------------------------------------------------------
  def refresh_bitmap(t, c)
    num = @data[t][c].size
    num = num == 0 ? 1 : num
    @bitmap[t][c].dispose unless @bitmap[t][c].nil?
    @bitmap[t][c] = Bitmap.new(self.width - 32, num * WLH)
    @bitmap[t][c].font.color = normal_color
    @index_s[t][c] = -1
    refresh(t, c)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(t, c)
    self.contents = @bitmap[t][c]
    @item_max = @data[t][c].size
    for i in 0...@item_max
      draw_i(t, c, i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 差分リフレッシュ
  #--------------------------------------------------------------------------
  def diff_refresh
    for t in 0...@bitmap.size
      refresh_data(t) unless @data[t].nil?
    end
    t = self.type
    c = @ctg
    self.contents = @bitmap[t][c]
    @item_max = @data[t][c].size
    self.index = @index >= @data[t][c].size ? (@data[t][c].size-1) : @index
  end
  #--------------------------------------------------------------------------
  # ● 項目描画
  #--------------------------------------------------------------------------
  def draw_i(t, c, i)
    itm = data_i(t, c, i)
    op = itm.enable? ? 255 : 128
    self.contents.font.color.alpha = op
    x = 4
    y = i * WLH
    draw_item_name(itm.obj, x, y, itm.enable?)
    if t / 2 == 0 # create
      self.contents.draw_text(x+90, y, 200, WLH, itm.price.to_s, 2)
      self.contents.draw_text(x+180, y, 200, WLH, itm.num.to_s, 2)
    else
      if itm.equip_actors.size > 0
        self.contents.draw_text(x+90, y, 200, WLH, "[E]", 2)
      end
      self.contents.draw_text(x+180, y, 200, WLH, itm.num.to_s, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム取得
  #--------------------------------------------------------------------------
  def item_list
    return @data[self.type][@ctg]
  end
  def data_i(t, c, i)
    return nil if i < 0 or i >= @data[t][c].size
    return @data[t][c][i]
  end
  def data
    return data_i(self.type, @ctg, @index)
  end
  def item_i(t, c, i)
    return nil if i < 0 or i >= @data[t][c].size
    return @data[t][c][i].obj
  end
  def item
    return item_i(self.type, @ctg, @index)
  end
  #--------------------------------------------------------------------------
  # ● 有効Index？
  #--------------------------------------------------------------------------
  def enable_i?(t, c, i)
    d = data_i(t, c, i)
    return (d.nil? ? false : d.enable?)
  end
  def enable?
    return enable_i?(self.type, @ctg, @index)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
    @pt_window.item = @sts_window.item = self.data
  end
end

#==============================================================================
# ■ Window_BsSList
#==============================================================================
class Window_BsSList < Window_Selectable
  attr_accessor :pt_window
  attr_accessor :sts_window
  OFFSET = 16
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @b_win = Window_BsSListBack.new
    super(@b_win.x+OFFSET, @b_win.y + 32, @b_win.width-OFFSET, @b_win.height-32)
    self.z = @b_win.z + 10
    @data = nil
    @pt_window = @sts_window = nil
    self.opacity = 0
    disable
  end
  def dispose
    @b_win.dispose
    super
  end
  def disable
    self.active = self.visible = @b_win.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 起動
  #--------------------------------------------------------------------------
  def startup(data)
    self.active = self.visible = @b_win.visible = true
    if @data != data
      @data = data
      @slist = @data.make_slist
      @item_max = @slist.size
      self.contents.dispose unless self.contents.nil?
      self.contents = Bitmap.new(self.width - 32, (@item_max+1) * WLH)
      self.contents.font.color = normal_color
      refresh
    end
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @b_win.refresh(@data.obj)
    self.contents.clear
    for i in 0...@item_max
      draw_i(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目描画
  #--------------------------------------------------------------------------
  def draw_i(i)
    itm = data_i(i)
    op = enable_i?(i) ? 255 : 128
    self.contents.font.color.alpha = op
    x = 4
    y = i * WLH
    draw_item_name(itm.obj, x, y,  enable_i?(i))
    self.contents.draw_text(x+ 90-OFFSET, y, 200, WLH, itm.price.to_s, 2)
    self.contents.draw_text(x+180-OFFSET, y, 200, WLH, itm.num.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● アイテム取得
  #--------------------------------------------------------------------------
  def data_i(i)
    return nil if i < 0
    return @slist[i]
  end
  def data
    return data_i(@index)
  end
  def item_i(i)
    return nil if i < 0
    return @slist[i].obj
  end
  def item
    return item_i(@index)
  end
  #--------------------------------------------------------------------------
  # ● 有効Index？
  #--------------------------------------------------------------------------
  def enable_i?(i)
    return data_i(i).enable?
  end
  def enable?
    return enable_i?(@index)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
    @pt_window.item = @sts_window.item = self.data
  end
end


#==============================================================================
# ■ Window_BsSListBack
#==============================================================================
class Window_BsSListBack < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, (WLH+32)*2, 544-120, (WLH*7+32))
    self.z = 300
    @sprite_p = Sprite_BsTAG.new(self.x+270, self.y+2, self.z+10, "花費")
    @sprite_n = Sprite_BsTAG.new(self.x+350, self.y+2, self.z+10, "持有")
    self.contents = Bitmap.new(width - 32, 32)
    self.contents.font.color = normal_color
  end
  def dispose
    super
    @sprite_p.dispose
    @sprite_n.dispose
  end
  def visible=(v)
    super(v)
    @sprite_p.visible = @sprite_n.visible = v
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(item)
    self.contents.clear
    self.draw_item_name(item, 4, 0)
  end
end

#==============================================================================
# ■ Window_BsActors
#==============================================================================
class Window_BsActors < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @hh = 0
    super(544-120, (WLH+32)*2, 120, (WLH*7+32))
    @hh = (height - 32) / 4
    @item = 0
    @index = -1
    @enable = []
    @item_max = $game_party.members.size
    create_contents
    self.item = nil
  end
  def enable?
    return false if @index < 0 or @enable[@index].nil?
    return @enable[@index]
  end
  def actor
    return nil if @index < 0
    return $game_party.members[@index]
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の作成
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, [height - 32, row_max * @hh].max)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #     item : 新しいアイテム
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(list=[])
    self.contents.clear
    for i in 0...$game_party.members.size
      actor = $game_party.members[i]
      y = i * @hh
      e = @item.nil? ? false : actor.equippable?(@item.obj)
      e = list.include?(i) if e and !list.empty?
      @enable[i] = e
      draw_actor_graphic(actor, 4+16, y + 36, e ? 255 : 128)
      next if @item.nil? or !e
      case @item.obj
      when RPG::Weapon
        diff = actor.v_equip(0, @item.obj.id, 0) - actor.atk
        draw_item_diff(28, y, diff, e)
      when RPG::Armor
        kind = @item.obj.kind + 1
        diff =  actor.v_equip(kind, @item.obj.id, 1) - actor.def
        draw_item_diff(28, y, diff, e)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● グラフィックの描画
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y, opacity=255)
    return if actor == nil
    bitmap = Cache.character(actor.character_name)
    sign = actor.character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = actor.character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, opacity)
  end
  #--------------------------------------------------------------------------
  # ● 装備差分値の描画
  #--------------------------------------------------------------------------
  def draw_item_diff(x, y, change, able)
    if !able
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = 128
    elsif change > 0
      self.contents.font.color = power_up_color
    elsif change < 0
      self.contents.font.color = power_down_color
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(x, y, self.contents.width-x-4, @hh, sprintf("%+d", change), 2)
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の取得
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / @hh
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の設定
  #     row : 先頭に表示する行
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * @hh
  end
  #--------------------------------------------------------------------------
  # ● 1 ページに表示できる行数の取得
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height - 32) / @hh
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing 
    rect.height = @hh
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * @hh
    return rect
  end
end

#==============================================================================
# ■ Window_BsStatus
#==============================================================================
class Window_BsStatus < Window_Base
  M_ITEM  = 0 # アイテムステータス
  M_PARTY = 1 # パーティーステータス
  M_ACTOR = 2 # アクターステータス
  PATTERN = Blacksmith::ST_PTN  # 切り替えの並び順
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(type=0)
    super(0, 416-(WLH*3+32), 544, WLH*3+32)
    @item = nil
    @type = type
    mode_reset(type)
    refresh
  end
  def fix?
    return (PATTERN.size <= 1)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #     item : 新しいアイテム
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● モードチェンジ
  #--------------------------------------------------------------------------
  def change_mode
    if @mode == M_ACTOR
      @actor_idx += 1
      if @actor_idx == $game_party.members.size
        @actor_idx = 0
        next_mode_t
      end
      refresh
    else
      next_mode_t
      refresh
    end
  end
  def mode_reset(type)
    @mode = M_ITEM
    @type = type
    next_mode if @type == 1 and !fix?
    @actor_idx = 0
  end
  def next_mode_t
    next_mode
    next_mode if @type == 1 and @mode == M_ITEM and !fix?
  end
  def next_mode
    @mode = PATTERN[((PATTERN.index(@mode) + 1) % PATTERN.size)]
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @item == nil
    case @mode
    when M_PARTY; refresh_party
    when M_ACTOR; refresh_actor
    when M_ITEM;  refresh_item
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ  : M_PARTY
  #--------------------------------------------------------------------------
  def refresh_party
    item = @item.obj
    # 装備品追加情報
    for i in 0...$game_party.members.size
      # アクターを取得
      actor = $game_party.members[i]
      x = 128*i
      case item
      when RPG::Item
        draw_actor_name(actor, x, 0)
        draw_actor_hp(actor, x, WLH+4)
        draw_actor_mp(actor, x, WLH*2+4)
      when RPG::Weapon, RPG::Armor
        # 装備可能なら通常文字色に、不可能なら無効文字色に設定
        able = actor.equippable?(item)
        self.contents.font.color = normal_color
        self.contents.font.color.alpha = able ? 255 : 128
        # アクターの名前を描画
        self.contents.draw_text(x, 0, 120, WLH, actor.name)
        next unless able
        if @item.obj.is_a?(RPG::Weapon)
          diff = actor.v_equip(0, @item.obj.id, 0) - actor.atk
          draw_item_diff(x, WLH+4, $data_system.terms.atk, diff, able)
          diff = actor.v_equip(0, @item.id, 4) - actor.hit
          draw_item_diff(x, WLH*2+4, "hit", diff, able)
        elsif @item.obj.is_a?(RPG::Armor)
          kind = @item.obj.kind + 1
          diff = actor.v_equip(kind, @item.obj.id, 1) - actor.def
          draw_item_diff(x, WLH+4, $data_system.terms.def, diff, able)
          diff = actor.v_equip(kind, @item.obj.id, 5) - actor.eva
          draw_item_diff(x, WLH*2+4, "blo", diff, able)
        end
      end
    end
  end
  def draw_item_diff(x, y, word, change, able)
    self.contents.font.color = system_color
    self.contents.font.color.alpha = able ? 255 : 128
    self.contents.draw_text(x, y, 112, WLH, word)
    if !able
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = 128
    elsif change > 0
      self.contents.font.color = power_up_color
    elsif change < 0
      self.contents.font.color = power_down_color
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(x+22, y, 82, WLH, sprintf("%+d", change), 2)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ  : M_ACTOR
  #--------------------------------------------------------------------------
  def refresh_actor
    actor = $game_party.members[@actor_idx]
    able = @item.obj.is_a?(RPG::Item) ? true : actor.equippable?(@item.obj)
    type = @item.obj.is_a?(RPG::Item) ? -1 : (@item.obj.is_a?(RPG::Weapon) ? 0 : (@item.obj.kind + 1) )
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = able ? 255 : 128
    self.contents.draw_text(0, 0, 120, WLH, actor.name)
    case @item.obj
    when RPG::Item
      draw_actor_level(actor, 128, 0)
    when RPG::Weapon
      draw_item_name($data_weapons[actor.weapon_id], 128, 0, able ? 255 : 128)
    when RPG::Armor
      case @item.obj.kind
      when 0; item1 = $data_armors[actor.armor1_id]
      when 1; item1 = $data_armors[actor.armor2_id]
      when 2; item1 = $data_armors[actor.armor3_id]
      when 3; item1 = $data_armors[actor.armor4_id]
      end
      draw_item_name(item1, 128, 0, able ? 255 : 128)
    end
    word = [$data_system.terms.atk, "hit",
      $data_system.terms.def, "blo",
      $data_system.terms.spi, $data_system.terms.agi
    ]
    now = [ actor.atk, actor.hit,
      actor.def, actor.eva,
      actor.spi, actor.agi
    ]
    new = able ? [ actor.v_equip(type, @item.obj.id, 0), actor.v_equip(type, @item.obj.id, 4),
      actor.v_equip(type, @item.obj.id, 1), actor.v_equip(type, @item.obj.id, 5),
      actor.v_equip(type, @item.obj.id, 2), actor.v_equip(type, @item.obj.id, 3)
    ] : now
    
    for i in 0...word.size
      draw_item_diff2(170*(i/2), WLH*(1+i%2)+4, word[i], able, now[i], new[i])
    end
  end
  def draw_item_diff2(x, y, word, able, now, new)
    self.contents.font.color = system_color
    self.contents.font.color.alpha = able ? 255 : 128
    self.contents.draw_text(x, y, 112, WLH, word)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = able ? 255 : 128
    self.contents.draw_text(x+12, y, 82, WLH, now.to_s, 2)
    return if !able or now == new

    self.contents.font.color = system_color
    self.contents.font.color.alpha = able ? 255 : 128
    self.contents.draw_text(x+100, y, WLH, WLH, "→")
    if now < new
      self.contents.font.color = power_up_color
    elsif now > new
      self.contents.font.color = power_down_color
    end
    self.contents.draw_text(x+72, y, 82, WLH, new.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ  : M_ITEM
  #--------------------------------------------------------------------------
  def refresh_item
    return if @type == 1
    self.contents.font.color = normal_color
    w = self.contents.width / 2
    for i in 0...@item.size
      x = 4 + (i / 3) % 2 * w
      y = i % 3 * WLH
      op = @item.cond[i].enable ? 255 : 128
      self.contents.font.color.alpha = op
      draw_item_name(@item.cond[i].obj, x, y, @item.cond[i].enable)
      self.contents.draw_text(x+200, y, 96, WLH, "×")
      self.contents.draw_text(x+w-8-96, y, 96, WLH, @item.cond[i].num.to_s, 2)
#      self.contents.draw_text(x+250, y, 96, WLH, "：")
#      self.contents.draw_text(x+w-8-8-96, y, 96, WLH, @item.cond[i].pt_num.to_s, 2)
    end
  end
end

#==============================================================================
# ■ Window_BsItemInfo
#==============================================================================
class Window_BsItemInfo < Window_Base
  #----------------------------------------------------------------------------
  TEXT_H = WLH  # 文字高さ
  ES_W = 4     # 属性・ステート間隔
  
  SCOPE = [ "なし ", "敵単体", "敵全体", "敵単体 連続", "敵単体 ランダム",
            "敵二体 ランダム", "敵三体 ランダム", "味方単体", "味方全体",
            "味方単体 (戦闘不能) ", "味方全体 (戦闘不能)", "使用者" ]
  #OCCASION = ["常時使用可能", "戦闘のみ", "マップ上のみ", "使用不可"]

  # 属性・ステート表示方法(true:アイコン  false:文字)
  USE_ICON = Blacksmith::USE_ICON

  #----------------------------------------------------------------------------
  # 属性・ステート用アイコン(USE_ICON=trueの時のみ)
  ELE_ICON = Blacksmith::ELE_ICON

  # 表示しない属性
  ELE_NOT_SHOW = Blacksmith::ELE_NOT_SHOW
  # 表示しないステート
  STT_NOT_SHOW = Blacksmith::STT_NOT_SHOW
  
  # 表示最大数(属性)
  ELE_MAX = Blacksmith::ELE_MAX
  # 表示最大数(ステート)
  STT_MAX = Blacksmith::STT_MAX

  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(140, WLH + 32, 404, WLH*7+32+WLH+32)
    self.back_opacity = 200
    self.visible = false
    self.z = 700
    @data = nil
  end
  def item=(data)
    return if @data == data
    @data = data
    refresh(data)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #      data : RPG::Item / RPG::Weapon / RPG::Armor / RPG::Skill
  #--------------------------------------------------------------------------
  def refresh(data)
    self.contents.clear
    return if data.nil?
    draw_item_name(data, indent(0), 0)
    #self.contents.draw_text(indent(1), TEXT_H, contents.width-indent(1), TEXT_H, data.description)
    #self.contents.fill_rect(0, TEXT_H*2, contents.width, 2, Color.new(255,255,255,128))
    case data
    when RPG::Item;   draw_item_info(data)
    when RPG::Weapon; draw_weapon_info(data)
    when RPG::Armor;  draw_armor_info(data)
    end
  end
  #--------------------------------------------------------------------------
  # ● Line計算
  #--------------------------------------------------------------------------
  def line(n)
    return TEXT_H * n + 4
  end
  #--------------------------------------------------------------------------
  # ● インデント
  #--------------------------------------------------------------------------
  def indent(n)
    case n
    when 0; return 4
    when 1; return 14
    when 2; return 14+60
    when 3; return 190
    when 4; return 190+60
    when 5; return 150
    when 6; return 90
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● アイコン描画(Graphics/Icons内の画像を表示)
  #--------------------------------------------------------------------------
  def draw_icon2(x, y, icon_index)
    bit = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    yy = (TEXT_H - 24) / 2
    self.contents.blt(x, y+yy, bit, rect)
    return 24 + ES_W
  end
  #--------------------------------------------------------------------------
  # ● 属性描画
  #--------------------------------------------------------------------------
  def draw_elements(elements, x, y)
    cnt = 0
    xx = 0
    for id in elements
      next if ELE_NOT_SHOW.include?(id)
      break if cnt == ELE_MAX
      if USE_ICON
        xx += draw_icon2(x+xx, y, ELE_ICON[id])
      else
        rect = self.contents.text_size($data_system.elements[id])
        break if (x+xx+rect.width) > contents.width
        self.contents.draw_text(x+xx, y, rect.width, TEXT_H, $data_system.elements[id])
        xx += rect.width + ES_W
      end
      cnt += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート描画
  #--------------------------------------------------------------------------
  def draw_states(states, x, y)
    cnt = 0
    xx = 0
    for id in states
      next if STT_NOT_SHOW.include?(id)
      break if cnt == STT_MAX
      xx += draw_icon2(x+xx, y, $data_states[id].icon_index)
      cnt += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● Item情報描画
  #       data : アイテム(RPG::Item)
  #--------------------------------------------------------------------------
  def draw_item_info(data)
    # 消耗品
    if data.consumable
      self.contents.font.color = system_color
      self.contents.draw_text(200, 0, 200, TEXT_H, "【消耗品】")
    end
    l = 1 # 行

    # 範囲と命中率
    if data.scope != 0
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 200, TEXT_H, "範囲")
      self.contents.font.color = normal_color
      self.contents.draw_text(indent(2), line(l), 200, TEXT_H, SCOPE[data.scope])
      l += 1
    end

    # HP/SP増減、パラメータ変化
    hpspparam = false
    sys_l  = l
    hp = "#{$data_system.terms.hp}"
    mp = "#{$data_system.terms.mp}"
    if data.hp_recovery_rate != 0
      hpspparam = true
      pm = data.hp_recovery_rate >= 0 ? "回復" : "ダメージ"
      text = "最大#{hp}の#{data.hp_recovery_rate.abs}％#{pm}"
      self.contents.draw_text(indent(2), line(l), 300, TEXT_H, text)
      l += 1
    end
    if data.hp_recovery != 0
      hpspparam = true
      pm = data.hp_recovery >= 0 ? "回復" : "ダメージ"
      text = "#{hp} #{data.hp_recovery.abs}#{pm}"
      self.contents.draw_text(indent(2), line(l), 300, TEXT_H, text)
      l += 1
    end
    if data.mp_recovery != 0
      hpspparam = true
      pm = data.mp_recovery >= 0 ? "回復" : "ダメージ"
      text = "最大#{mp}の#{data.mp_recovery.abs}％#{pm}"
      self.contents.draw_text(indent(2), line(l), 300, TEXT_H, text)
      l += 1
    end
    if data.mp_recovery != 0
      hpspparam = true
      pm = data.mp_recovery >= 0 ? "回復" : "ダメージ"
      text = "#{mp} #{data.mp_recovery.abs}#{pm}"
      self.contents.draw_text(indent(2), line(l), 300, TEXT_H, text)
      l += 1
    end
    if data.parameter_type != 0 # パラメータ変化効果あり
      hpspparam = true
      param = ["なし", "最大#{hp}", "最大#{mp}", 
               $data_system.terms.atk, $data_system.terms.def,
               $data_system.terms.spi, $data_system.terms.agi][data.parameter_type]
      pm = data.parameter_points >= 0 ? "+" : "-"
      text = "#{param} #{pm}#{data.parameter_points}"
      self.contents.draw_text(indent(2), line(l), 300, TEXT_H, text)
      l += 1
    end
    if hpspparam
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(sys_l), 100, TEXT_H, "効果")
    end

    # 属性
    unless data.element_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 100, TEXT_H, "属性")
      self.contents.font.color = normal_color
      draw_elements(data.element_set, indent(2), line(l))
      l += 1
    end
    # 付与ステート
    unless data.plus_state_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 140, TEXT_H, "付与ステート")
      self.contents.font.color = normal_color
      draw_states(data.plus_state_set, indent(5), line(l))
      l += 1
    end
    # 解除ステート
    unless data.minus_state_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 140, TEXT_H, "解除ステート")
      self.contents.font.color = normal_color
      draw_states(data.minus_state_set, indent(5), line(l))
      l += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● Weapon情報描画
  #       data : 武器(RPG::Weapon)
  #--------------------------------------------------------------------------
  def draw_weapon_info(data)
    self.contents.font.color = system_color
    self.contents.draw_text(200, 0, 200, TEXT_H, "【#{$data_system.terms.weapon}】")
    self.contents.draw_text(indent(1), line(1), 200, TEXT_H, $data_system.terms.atk)
    self.contents.draw_text(indent(3), line(1), 200, TEXT_H, "hit")
    self.contents.draw_text(indent(1), line(2), 200, TEXT_H, $data_system.terms.def)
    self.contents.draw_text(indent(1), line(3), 200, TEXT_H, $data_system.terms.spi)
    self.contents.draw_text(indent(3), line(3), 200, TEXT_H, $data_system.terms.agi)

    self.contents.font.color = normal_color
    self.contents.draw_text(indent(2), line(1), 40, TEXT_H, data.atk.to_s, 2)
    self.contents.draw_text(indent(4), line(1), 40, TEXT_H, data.hit.to_s, 2)
    self.contents.draw_text(indent(2), line(2), 40, TEXT_H, data.def.to_s, 2)
    self.contents.draw_text(indent(2), line(3), 40, TEXT_H, data.spi.to_s, 2)
    self.contents.draw_text(indent(4), line(3), 40, TEXT_H, data.agi.to_s, 2)

    l = 4
    list = []
    list.push("両手持ち") if data.two_handed
    list.push("先制") if data.fast_attack
    list.push("連続攻撃") if data.dual_attack
    list.push("会心の一撃") if data.critical_bonus
    if list.size > 0
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(4), 100, TEXT_H, "特殊効果")
      self.contents.font.color = normal_color
    end
    i = 0
    for item in list
      self.contents.draw_text(90+i*100, line(l), 140, TEXT_H, item)
      l += 1 if i == 1
      i = (i + 1) % 2
    end
    l += 1 if i == 1

    # 属性
    unless data.element_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 100, TEXT_H, "属性")
      self.contents.font.color = normal_color
      draw_elements(data.element_set, indent(2), line(l))
      l += 1
    end
    # 付与ステート
    unless data.state_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 140, TEXT_H, "付与ステート")
      self.contents.font.color = normal_color
      draw_states(data.state_set, indent(5), line(l))
      l += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● Armor情報描画
  #       data : 防具(RPG::Armor)
  #--------------------------------------------------------------------------
  def draw_armor_info(data)
    self.contents.font.color = system_color
    kind = [$data_system.terms.armor1, $data_system.terms.armor2,
            $data_system.terms.armor3, $data_system.terms.armor4][data.kind]
    self.contents.draw_text(200, 0, 200, TEXT_H, "【#{kind}】")
    self.contents.draw_text(indent(1), line(1), 200, TEXT_H, $data_system.terms.atk)
    self.contents.draw_text(indent(1), line(2), 200, TEXT_H, $data_system.terms.def)
    self.contents.draw_text(indent(3), line(2), 200, TEXT_H, "hit")
    self.contents.draw_text(indent(1), line(3), 200, TEXT_H, $data_system.terms.spi)
    self.contents.draw_text(indent(3), line(3), 200, TEXT_H, $data_system.terms.agi)

    self.contents.font.color = normal_color
    self.contents.draw_text(indent(2), line(1), 40, TEXT_H, data.atk.to_s, 2)
    self.contents.draw_text(indent(2), line(2), 40, TEXT_H, data.def.to_s, 2)
    self.contents.draw_text(indent(4), line(2), 40, TEXT_H, data.eva.to_s, 2)
    self.contents.draw_text(indent(2), line(3), 40, TEXT_H, data.spi.to_s, 2)
    self.contents.draw_text(indent(4), line(3), 40, TEXT_H, data.agi.to_s, 2)

    l = 4
    i = 2
    special = false
    if data.prevent_critical
      special = true
      self.contents.draw_text(indent(i)+20, line(l), 100, TEXT_H, "クリティカル防止")
      i = i == 2 ? 4 : 2
      l += 1 if i == 2
    end
    if data.half_mp_cost 
      special = true
      self.contents.draw_text(indent(i)+20, line(l), 100, TEXT_H, "消費MP半減")
      i = i == 2 ? 4 : 2
      l += 1 if i == 2
    end
    if data.double_exp_gain
      special = true
      self.contents.draw_text(indent(i)+20, line(l), 100, TEXT_H, "取得経験値2倍")
      i = i == 2 ? 4 : 2
      l += 1 if i == 2
    end
    if data.auto_hp_recover
      special = true
      self.contents.draw_text(indent(i)+20, line(l), 100, TEXT_H, "HP自動回復")
      i = i == 2 ? 4 : 2
      l += 1 if i == 2
    end
    l += 1 if i == 4
    if special
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(1), 100, TEXT_H, "特殊効果")
    end


    # 属性防御
    unless data.element_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 100, TEXT_H, "属性防御")
      self.contents.font.color = normal_color
      draw_elements(data.element_set, indent(6), line(l))
      l += 1
    end
    # ステート防御
    unless data.state_set.empty?
      self.contents.font.color = system_color
      self.contents.draw_text(indent(1), line(l), 140, TEXT_H, "ステート防御")
      self.contents.font.color = normal_color
      draw_states(data.state_set, indent(5), line(l))
      l += 1
    end
  end
end

#==============================================================================
# ■ Window_BsYesNo
#==============================================================================
class Window_BsYesNo < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super((544-200)/2, 160, 200, WLH*2+4+32)
    @commands = ["是", "否"]
    @column_max = @item_max = @commands.size
    refresh
    disable
    self.z = 500
  end
  def enable
    self.visible = true
    self.active = true
    self.index = 1
  end
  def disable
    self.visible = false
    self.active = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.draw_text(4, 0, 200, WLH, "要裝備嗎？")
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    x = 4 + index * self.width / @column_max
    self.contents.draw_text(x, WLH+4, 100, WLH, @commands[index])
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH + WLH + 4
    return rect
  end
end

#==============================================================================
# ■ Window_BsCaution
#==============================================================================
class Window_BsCaution < Window_Base
  include Blacksmith::MesCmd

  WAIT_TIME = 40 # 表示ウェイト時間[frame]
  FADE_F = WAIT_TIME / 4
  def xx(w)
    return (544-w)/2
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(xx(240), 160, 240, WLH+32)
    @wait = 0
    @callback = nil
    self.z = 600
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def set_text(type, item=nil)
    return unless Blacksmith::MESSAGE
    case type
    when M_S_C; text = "#{item.name}成功製作"
    when M_S_S; text = "#{item.name}成功強化"
    when M_N_P; text = "金錢不足"
    when M_N_I; text = "材料不足"
    when M_N_N; text = "無法再持有"
    when M_E_N: text = "無法裝備"
    when M_E_D; text = "#{item.name}の装備を外しました"
    when M_E_C; text = "#{item.name}の装備を変更しました"
    when M_O_I; text = "所持品に入れました"
    else;   p "bad arg", type;  return
    end
    w = self.contents.text_size(text).width
    self.width = w + 32
    self.x = xx(self.width)
    self.contents.dispose
    self.contents = Bitmap.new(w, WLH)
    self.contents.draw_text(0, 0, w, WLH, text)
    @wait = WAIT_TIME
    self.visible = true
    self.opacity = self.contents_opacity = 255
    set_callback(nil)
  end
  #--------------------------------------------------------------------------
  # ● Callback登録
  #--------------------------------------------------------------------------
  def set_callback(callback=nil)
    if Blacksmith::MESSAGE
      @callback = callback
    elsif !callback.nil? # メッセージ表示しない場合はその場で実行
      $scene.callback(callback)
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def update
    super
    @wait -= 1
    if @wait < FADE_F
      self.opacity = self.contents_opacity = 255 / FADE_F * @wait
      if @wait == 0
        self.visible = false
        $scene.callback(@callback) unless @callback.nil?
        set_callback(nil)
      end
    end
  end
end
