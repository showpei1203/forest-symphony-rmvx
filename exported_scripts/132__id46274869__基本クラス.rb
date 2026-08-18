#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：基本クラス
# 【用途】保留的 Runtime 元件「基本クラス」。
# 【主要機制】主要定義／擴充 Condition、CommonData、CommonWeapon、CommonArmor；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Condition、CommonData、CommonWeapon、CommonArmor、CreateList、StrengthenList、Blacksmith
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DBG、C_W、ITM_MAX、M_S_C、M_S_S、M_N_P、M_N_I、M_N_N。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
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
# ■ VX-RGSS2-17 鍛冶屋 [基本クラス]             by Claimh
#==============================================================================

#==============================================================================
# ■ 基本クラス
#==============================================================================
module Blacksmith
  DBG = false#true  # 全て表示
  C_W=0;C_A=1;S_W=2;S_A=3
  T = ["鍛造", "強化", "離開"]
  ITM_MAX = 99

  # メッセージタイプ
  module MesCmd
    M_S_C = 0 # 生成成功
    M_S_S = 1 # 強化成功
    M_N_P = 10  # お金足りない
    M_N_I = 11  # アイテム足りない
    M_N_N = 12  # アイテムいっぱい
    M_E_N = 20  # 装備できない
    M_E_D = 21  # 装備外した
    M_E_C = 22  # 装備変更した
    M_O_I = 30  # 所持品に入れた
  end
  #--------------------------------------------------------------------------
  # ● コマンド
  #--------------------------------------------------------------------------
  def self.sys_cmd
    cmd = []
    for d in SYS_CMD
      cmd.push(T[d])
    end
    return cmd
  end
  def self.mod_cmd(s)
    text = ["#{$data_system.terms.weapon}#{T[s]}", "防具#{T[s]}", "離開"]
    cmd = []
    for d in MOD_CMD
      cmd.push(text[d])
    end
    return cmd
  end
  #--------------------------------------------------------------------------
  # ● 設定情報参照
  #--------------------------------------------------------------------------
  def self.data(t)
    case t
    when C_W; return C_WEAPON
    when C_A; return C_ARMOR
    when S_W; return S_WEAPON
    when S_A; return S_ARMOR
    end
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ設定情報参照
  #--------------------------------------------------------------------------
  def self.ctg(t)
    case t
    when C_W,S_W; return W_CT
    when C_A,S_A; return A_CT
    end
  end
  #--------------------------------------------------------------------------
  # ● データソート
  #--------------------------------------------------------------------------
  def self.sort(list, t)
    return [] if list.nil?
    return list unless SORT
    case t      # 攻撃力・防御力でソートする
    when C_W, S_W;  list.sort! {|a,b| b.obj.atk - a.obj.atk }
    when C_A, S_A;  list.sort! {|a,b| b.obj.def - a.obj.def }
    end
    return list
  end
  #--------------------------------------------------------------------------
  # ● データPush
  #--------------------------------------------------------------------------
  def self.push(list, d, t, c)
    return list.push(d) if c == CT_ALL
    case t
    when C_W, S_W
      list.push(d) if d.obj.element_set.include?(c)
    when C_A, S_A
      if USE_A_SYS
        list.push(d) if d.obj.kind == c
      elsif d.obj.element_set.include?(c)
        list.push(d)
      end
    end
    return list
  end


# 条件クラス
class Condition
  attr_reader :id     # 条件ID
  attr_reader :num    # 条件値
  attr_reader :enable
  def initialize(prm)
    if prm.empty?
      @id = 0
      @num = 0
      @enable = true
    else
      @id   = prm[0]
      @num  = prm[1]
    end
  end
  def update_status
    return enable?
  end
  def enable?
    return (@enable = true) if @id == 0 or @num == 0
    return (@enable = (pt_num >= @num))
  end
  def lose
    return if @id == 0 or @num == 0
    $game_party.lose_item(obj, @num) if obj.consumable  # 消耗
  end
  def obj
    return $data_items[@id]
  end
  def pt_num
    return $game_party.item_number(obj)
  end
end

# 個別データクラス
class CommonData
  attr_writer :visible
  attr_reader :price
  attr_reader :cond
  attr_reader :status
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(b_id, a_id, data)
    @b_id = b_id
    @a_id = a_id
    @price = data[0]
    @cond = []
    for i in 0...data[1].size
      @cond[i] = Condition.new(data[1][i])
    end
    @visible = data[2].nil? ? false : data[2]
    @status = 0xFF
  end
  def id
    return @a_id
  end
  def size
    return @cond.size
  end
  #--------------------------------------------------------------------------
  # ● 表示状態
  #--------------------------------------------------------------------------
  def visible
    return (@visible or DBG)
  end
  #--------------------------------------------------------------------------
  # ● ステータス更新
  #--------------------------------------------------------------------------
  ST_P = 0b001
  ST_C = 0b010
  ST_N = 0b100
  def update_status
    @status = 0
    @status |= ST_P unless price?
    @status |= ST_C unless cond_enable?
    @status |= ST_N unless num?
    return visible # @statusではなくvisibleを返す
  end
  def enable?
    return (@status == 0)
  end
  def message
    return MesCmd::M_N_P if (@status & ST_P) == ST_P
    return MesCmd::M_N_I if (@status & ST_C) == ST_C
    return MesCmd::M_N_N
  end
  #--------------------------------------------------------------------------
  # ● 鍛冶可否判定
  #--------------------------------------------------------------------------
  def cond_enable?
    return true if @cond.empty?
    for cnd in @cond
      return false unless cnd.update_status
    end
    return true
  end
  def price?
    return (@price <= $game_party.gold)
  end
  def num?(n=1)
    return ((self.num + n) <= ITM_MAX)
  end
  #--------------------------------------------------------------------------
  # ● 鍛冶実行
  #--------------------------------------------------------------------------
  def execute(change=false, actor=nil)
    $game_party.lose_gold(@price)
    for cnd in @cond
      cnd.lose
    end
    gain
    equip(actor) if change
    lose if @b_id != 0
  end
  #--------------------------------------------------------------------------
  # ● 装備可能メンバー
  #--------------------------------------------------------------------------
  def equippable_members
    list = []
    for actor in $game_party.members
      list.push(actor.index) if actor.equippable?(obj)
    end
    return list
  end
end

# 武器・防具クラス
class CommonWeapon < CommonData
  def obj
    return $data_weapons[@a_id]
  end
  def num
    return $game_party.item_number(obj)
  end
  def gain
    $game_party.gain_item(obj, 1)
  end
  def equip(actor)
    actor.change_equip(0, obj)
  end
  def lose
    $game_party.lose_item($data_weapons[@b_id], 1)
  end
end
class CommonArmor < CommonData
  def obj
    return $data_armors[@a_id]
  end
  def num
    return $game_party.item_number(obj)
  end
  def gain
    $game_party.gain_item(obj, 1)
  end
  def equip(actor)
    actor.change_equip(obj.kind+1, obj)
  end
  def lose
    $game_party.lose_item($data_armors[@b_id], 1)
  end
end


# リストクラス
class CreateList
  attr_reader :equip_actors
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(type, b_id=0)
    @type = type
    @b_id = b_id
    reset_all
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def reset_all
    @list = {}
    @equip_actors = []
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def reset(id)
    case @type
    when C_W; @list[id] = CommonWeapon.new(0, id, C_WEAPON[id])
    when C_A; @list[id] = CommonArmor.new(0, id, C_ARMOR[id])
    when S_W; @list[id] = CommonWeapon.new(@b_id, id, S_WEAPON[@b_id][id])
    when S_A; @list[id] = CommonArmor.new(@b_id, id, S_ARMOR[@b_id][id])
    end
    return @list[id]
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト参照
  #--------------------------------------------------------------------------
  def [](id)
    return (@list[id].nil? ? reset(id) : @list[id])
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ別リスト生成(生成用)
  #--------------------------------------------------------------------------
  def make_list
    mlist = []
    ids = ::Blacksmith.data(@type).keys.sort
    ct = ::Blacksmith.ctg(@type)
    for id in ids
      d = self.[](id)
      next unless d.update_status # リスト作るときにステータス更新
      for i in 0...ct.size
        mlist[i] = [] if mlist[i].nil?
        mlist[i] = ::Blacksmith.push(mlist[i], d, @type, ct[i][1])
      end
    end
    for i in 0...ct.size
      mlist[i] = ::Blacksmith.sort(mlist[i], @type)
    end
    return mlist
  end
  #--------------------------------------------------------------------------
  # ● 強化用メソッド
  #--------------------------------------------------------------------------
  def obj
    case @type
    when S_W; return $data_weapons[@b_id]
    when S_A; return $data_armors[@b_id]
    end
  end
  def enable?
    return true
  end
  def num
    return $game_party.item_number(obj)
  end
  #--------------------------------------------------------------------------
  # ● アイテム所持判定（装備品含む）
  #--------------------------------------------------------------------------
  def has_item?
    flag = (self.num > 0)
    @equip_actors = []
    for actor in $game_party.members
      @equip_actors.push(actor.index) if equip_item?(actor)
    end
    return (flag or (@equip_actors.size > 0))
  end
  #--------------------------------------------------------------------------
  # ● アイテム装備判定
  #--------------------------------------------------------------------------
  def equip_item?(actor)
    case @type
    when S_W; return true if actor.weapon_id == @b_id
    when S_A
      case $data_armors[@b_id].kind
      when 0; return true if actor.armor1_id == @b_id
      when 1; return true if actor.armor2_id == @b_id
      when 2; return true if actor.armor3_id == @b_id
      when 3; return true if actor.armor4_id == @b_id
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● リスト生成(強化用)  ※カテゴリ不要
  #--------------------------------------------------------------------------
  def make_slist
    slist = []
    ids = ::Blacksmith.data(@type)[@b_id].keys.sort
    for id in ids
      d = self.[](id)
      next unless d.update_status # リスト作るときにステータス更新
      slist.push(d)
    end
    return ::Blacksmith.sort(slist, @type)
  end
end
# リストクラス
class StrengthenList
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(type)
    @type = type
    reset_all
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def reset_all
    @list = {}
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def reset(b_id)
    @list[b_id] = CreateList.new(@type, b_id)
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト参照
  #--------------------------------------------------------------------------
  def [](b_id)
    reset(b_id) if @list[b_id].nil?
    return @list[b_id]
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ別リスト生成
  #--------------------------------------------------------------------------
  def make_list
    mlist = []
    ids = ::Blacksmith.data(@type).keys.sort
    ct = ::Blacksmith.ctg(@type)
    for id in ids
      d = self.[](id)
      next unless d.has_item? # 所持アイテムのみ有効
      for i in 0...ct.size
        mlist[i] = [] if mlist[i].nil?
        num = 0
        a_ids = ::Blacksmith.data(@type)[id].keys
        for a_id in a_ids
          if d[a_id].update_status # リスト作るときにステータス更新
            num = 1;  break
          end
        end
        next if num == 0  # 全て非表示なら除外
        mlist[i] = ::Blacksmith.push(mlist[i], d, @type, ct[i][1])
      end
    end
    for i in 0...ct.size
      mlist[i] = ::Blacksmith.sort(mlist[i], @type)
    end
    return mlist
  end
end


# Blacksmithクラス
class Blacksmith
  attr_reader :c_w
  attr_reader :c_a
  attr_reader :s_w
  attr_reader :s_a
  def initialize
    reset_all
  end
  def reset_all
    @c_w = CreateList.new(C_W)
    @c_a = CreateList.new(C_A)
    @s_w = StrengthenList.new(S_W)
    @s_a = StrengthenList.new(S_A)
  end
end


end ## module Blacksmith


#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  attr_reader :bs
  alias initialize_blacksmith initialize
  def initialize
    initialize_blacksmith
    @bs = Blacksmith::Blacksmith.new
  end
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :call_blacksmith
  alias initialize_blacksmith initialize
  def initialize
    initialize_blacksmith
    @call_blacksmith = false
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  def call_blacksmith
    $game_temp.next_scene = "shop"
    $game_temp.call_blacksmith = true
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  alias call_blacksmith call_shop
  def call_shop
    if $game_temp.call_blacksmith
      $game_temp.next_scene = nil
      $game_temp.call_blacksmith = false
      $scene = Scene_Blacksmith.new
    else
      call_blacksmith
    end
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 仮想装備時の能力値取得
  #--------------------------------------------------------------------------
  def v_equip(type, equip_id, prm)
    tmp2_id = 0
    case type # 仮想装備にする
    when 0; tmp_id = @weapon_id; @weapon_id = equip_id
      unless two_hands_legal?
        tmp2_id = @armor1_id;    @armor1_id = 0
      end
    when 1; tmp_id = @armor1_id; @armor1_id = equip_id
      unless two_hands_legal?
        tmp2_id = @weapon_id;    @weapon_id = 0
      end
    when 2; tmp_id = @armor2_id; @armor2_id = equip_id
    when 3; tmp_id = @armor3_id; @armor3_id = equip_id
    when 4; tmp_id = @armor4_id; @armor4_id = equip_id
    end
    case prm  # 仮想装備時のパラメータ
    when 0; ret_prm = self.atk
    when 1; ret_prm = self.def
    when 2; ret_prm = self.spi
    when 3; ret_prm = self.agi
    when 4; ret_prm = self.hit
    when 5; ret_prm = self.eva
    end
    case type # 仮想装備を戻す
    when 0; @weapon_id = tmp_id
      @armor1_id = tmp2_id  if tmp2_id != 0
    when 1; @armor1_id = tmp_id
      @weapon_id = tmp2_id  if tmp2_id != 0
    when 2; @armor2_id = tmp_id
    when 3; @armor3_id = tmp_id
    when 4; @armor4_id = tmp_id
    end
    return ret_prm
  end
end

