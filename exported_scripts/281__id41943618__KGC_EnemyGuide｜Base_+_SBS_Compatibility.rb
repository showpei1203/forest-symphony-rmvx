#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_EnemyGuide｜Base + SBS Compatibility
# 【用途】KGC 敵人圖鑑／Enemy Guide，記錄遭遇、擊敗、掉落、可偷取物、弱點／抗性、EXP 等資料；本頁已含 SBS 相容層。
# 【來源】KGC_EnemyGuide；KGC Site: http://f44.aaa.livedoor.jp/~ytomy/；英譯 Mr. Anonymous，Translator Blog: http://mraprojects.wordpress.com。
# 【載入順序】原譯文件要求位於 KGC_ExtraDropItem 上方、KGC_CustomMenuCommand 下方；FS 目前位置已驗證，不要自行搬動。
# 【敵人描述 Notetag】Enemy Note 可使用：
#   <enemy_info>
#   說明文字
#   </enemy_info>
#   亦支援 <GUIDE_DESCRIPTION> ... </GUIDE_DESCRIPTION>。
# 【事件 Script Call】
#   call_enemy_guide                         # 開啟敵人圖鑑
#   get_enemy_guide_completion(variable_id) # 將完成度寫入變數
#   complete_enemy_guide                    # 將全部敵人標記為已擊敗
#   reset_enemy_guide                       # 重設整本圖鑑
#   set_enemy_encountered(enemy_id, flag=true)
#   set_monster_defeated(enemy_id, flag=true)／相容入口 set_enemy_defeated
#   set_enemy_item_dropped(enemy_id, item_index, flag=true)
#   set_enemy_object_stolen(enemy_id, object_index, flag=true)
# 【範例】set_enemy_encountered(1)；set_enemy_encountered(1,false)；set_enemy_item_dropped(1,0)；set_enemy_object_stolen(1,0)。
# 【參數定義】enemy_id=資料庫 Enemy ID；flag=true/false；item_index/object_index 皆從 0 起算；variable_id=接收資料的遊戲變數 ID。
# 【主要設定】
#   USE_BACKGROUND_IMAGE：是否使用 Graphics/System 自訂背景；BACKGROUND_FILENAME：背景檔名，目前 Monstre。
#   INFO_INTERVAL：左上遭遇／擊敗／完成度資訊輪替間隔（frame）。
#   SHOW_SERIAL_NUMBER / SERIAL_NUM_FORMAT：是否在名稱前顯示 Enemy ID 與格式；SERIAL_NUM_FOLLOW：依序號排序。
#   UNKNOWN_ENEMY_NAME：未遭遇名稱遮罩字元；UNENCOUNTERED_DATA：未知資料顯示文字。
#   PARAMETER_NAME：擊殺數、弱點、抗性、EXP、掉落、核心／偷取等欄位名稱。
#   UNDEFEATED_PARAMETER：未擊敗參數遮罩；UNDROPPED_ITEM_NAME：未取得物品名稱遮罩。
#   ELEMENT_RANGE / ELEMENT_ICON：圖鑑要顯示的屬性 ID 與對應 Icon。
#   HIDDEN_ENEMIES：永不列入圖鑑的 Enemy；ENEMY_ORDER：自訂顯示順序；ORIGINAL_DEFEAT：初始擊敗狀態相關設定。
#   USE_MENU_ENEMY_GUIDE_COMMAND / VOCAB_MENU_ENEMY_GUIDE：主選單入口與文字。
# 【FS 整合】FS_Scene_EnemyBook 會使用 enemy_guide_description；因此 KGC_EnemyGuide 仍屬正式依賴，不可因另有 EnemyBook 就移除。
# 【相關素材】USE_BACKGROUND_IMAGE=true 時讀取 Graphics/System/BACKGROUND_FILENAME；其他 Icon 來自 Iconset。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
module KGC
  module EnemyGuide
  USE_BACKGROUND_IMAGE = false
  BACKGROUND_FILENAME  = "Monstre"
  INFO_INTERVAL = 90

  SHOW_SERIAL_NUMBER = true
  SERIAL_NUM_FOLLOW  = true
  SERIAL_NUM_FORMAT  = "%03d: "
  UNKNOWN_ENEMY_NAME = "?"
  UNENCOUNTERED_DATA = "- 未知 -"
  PARAMETER_NAME = {
    :defeat_count   => "擊殺數",
    :weak_element   => "弱點屬性",
    :resist_element => "優勢屬性",
    :weak_state     => "弱點狀態",
    :resist_state   => "優勢狀態",
    :exp            => "經驗",
    :treasure       => "掉落物",
    :drop_prob      => "掉落機率",
    :steal_obj      => "核心",
    :steal_prob     => "核心獲取機率",
  
  }  # ← 不可刪除！
  UNDEFEATED_PARAMETER = "???"
  UNDROPPED_ITEM_NAME  = "?"

  ELEMENT_RANGE = [4..10,15,16]
ELEMENT_ICON = [nil,                       # ID:0 はダミー
      1,   1,   1, 483, 482, 484, 480, 481,  # ID: 1 ～  8
    485, 486,   1,   1,   1,   1, 487, 488,  # ID: 9 ～ 16
     ]  # ← これは消さないこと！
  HIDDEN_ENEMIES = [2]

  ENEMY_ORDER = [1..27]

  ORIGINAL_DEFEAT = true

  USE_MENU_ENEMY_GUIDE_COMMAND = true
  VOCAB_MENU_ENEMY_GUIDE       = "遭遇怪物"
  end
end

#=============================================================================#
#=============================================================================#

#=================================================#
#=================================================#

$imported = {} if $imported == nil
$imported["EnemyGuide"] = true

#=================================================#

#==============================================================================
#==============================================================================
module KGC
  module_function
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mask_string(str, mask)
    text = mask
    if mask.scan(/./).size == 1
      text = mask * str.scan(/./).size
    end
    return text
  end
end

#==============================================================================
#==============================================================================
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

module KGC::EnemyGuide
  module Regexp
    module Enemy
      BEGIN_GUIDE_DESCRIPTION = /<(?:GUIDE_DESCRIPTION|enemy_info)>/i
      END_GUIDE_DESCRIPTION = /<\/(?:GUIDE_DESCRIPTION|enemy_info)>/i
    end
  end

  module_function
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def convert_integer_array(array)
    result = []
    array.each { |i|
      case i
      when Range
        result |= i.to_a
      when Integer
        result |= [i]
      end
    }
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enemy_show?(enemy_id)
    return false if HIDDEN_ENEMY_LIST.include?(enemy_id)
    if ENEMY_ORDER_ID != nil
      return false unless ENEMY_ORDER_ID.include?(enemy_id)
    end

    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  HIDDEN_ENEMY_LIST = convert_integer_array(HIDDEN_ENEMIES)
  ENEMY_ORDER_ID = (ENEMY_ORDER == nil ? nil :
    convert_integer_array(ENEMY_ORDER))
  CHECK_ELEMENT_LIST = convert_integer_array(ELEMENT_RANGE)
end

#=================================================#

#==============================================================================
#==============================================================================

module KGC
  module Commands
    module_function
    #--------------------------------------------------------------------------
    # ○ 遭遇状態取得
    #     enemy_id : 敵 ID
    #--------------------------------------------------------------------------
    def enemy_encountered?(enemy_id)
      return $game_system.enemy_encountered[enemy_id]
    end
    #--------------------------------------------------------------------------
    # ○ 撃破状態取得
    #     enemy_id : 敵 ID
    #--------------------------------------------------------------------------
    def enemy_defeated?(enemy_id)
      return $game_system.enemy_defeated[enemy_id]
    end
    #--------------------------------------------------------------------------
    # ○ アイテムドロップ状態取得
    #     enemy_id   : 敵 ID
    #     item_index : ドロップアイテム番号
    #--------------------------------------------------------------------------
    def enemy_item_dropped?(enemy_id, item_index)
      if $game_system.enemy_item_dropped[enemy_id] == nil
        return false
      end
      result = $game_system.enemy_item_dropped[enemy_id] & (1 << item_index)
      return (result != 0)
    end
    #--------------------------------------------------------------------------
    # ○ 盗み成功済み状態取得
    #     enemy_id  : 敵 ID
    #     obj_index : オブジェクト番号
    #--------------------------------------------------------------------------
    def enemy_object_stolen?(enemy_id, obj_index)
      if $game_system.enemy_object_stolen[enemy_id] == nil
        return false
      end
      result = $game_system.enemy_object_stolen[enemy_id] & (1 << obj_index)
      return (result != 0)
    end
    #--------------------------------------------------------------------------
    # ○ 遭遇状態設定
    #     enemy_id : 敵 ID
    #     enabled  : true..遭遇済み  false..未遭遇
    #--------------------------------------------------------------------------
    def set_enemy_encountered(enemy_id, enabled = true)
      $game_system.enemy_encountered[enemy_id] = enabled
    end
    #--------------------------------------------------------------------------
    # ○ 撃破状態設定
    #     enemy_id : 敵 ID
    #     enabled  : true..撃破済み  false..未撃破
    #--------------------------------------------------------------------------
    def set_enemy_defeated(enemy_id, enabled = true)
      $game_system.enemy_defeated[enemy_id] = enabled
    end
    #--------------------------------------------------------------------------
    # ○ アイテムドロップ状態設定
    #     enemy_id   : 敵 ID
    #     item_index : ドロップアイテム番号
    #     enabled    : true..ドロップ済み  false..未ドロップ
    #--------------------------------------------------------------------------
    def set_enemy_item_dropped(enemy_id, item_index, enabled = true)
      if $game_system.enemy_item_dropped[enemy_id] == nil
        $game_system.enemy_item_dropped[enemy_id] = 0
      end
      if enabled
        $game_system.enemy_item_dropped[enemy_id] |= (1 << item_index)
      else
        $game_system.enemy_item_dropped[enemy_id] &= ~(1 << item_index)
      end
    end
    #--------------------------------------------------------------------------
    # ○ 盗み成功状態設定
    #     enemy_id  : 敵 ID
    #     obj_index : オブジェクト番号
    #     enabled   : true..成功済み  false..未成功
    #--------------------------------------------------------------------------
    def set_enemy_object_stolen(enemy_id, obj_index, enabled = true)
      if $game_system.enemy_object_stolen[enemy_id] == nil
        $game_system.enemy_object_stolen[enemy_id] = 0
      end
      if enabled
        $game_system.enemy_object_stolen[enemy_id] |= (1 << obj_index)
      else
        $game_system.enemy_object_stolen[enemy_id] &= ~(1 << obj_index)
      end
    end
    #--------------------------------------------------------------------------
    # ○ 図鑑リセット
    #--------------------------------------------------------------------------
    def reset_enemy_guide
      $game_system.enemy_encountered = []
      $game_system.enemy_defeated = []
      $game_system.enemy_item_dropped = []
      $game_system.enemy_object_stolen = []
    end
    #--------------------------------------------------------------------------
    # ○ 図鑑完成
    #--------------------------------------------------------------------------
    def complete_enemy_guide
      (1...$data_enemies.size).each { |i|
        set_enemy_encountered(i)
        set_enemy_defeated(i)

        enemy = $data_enemies[i]

        items = [enemy.drop_item1, enemy.drop_item2]
        if $imported["ExtraDropItem"]
          items += enemy.extra_drop_items
        end
        items.each_index { |j| set_enemy_item_dropped(i, j) }

        if $imported["Steal"]
          objs = enemy.steal_objects
          objs.each_index { |j| set_enemy_object_stolen(i, j) }
        end
      }
    end
    #--------------------------------------------------------------------------
    # ○ 図鑑に含めるか
    #     enemy_id : 敵 ID
    #--------------------------------------------------------------------------
    def enemy_guide_include?(enemy_id)
      return false unless KGC::EnemyGuide.enemy_show?(enemy_id)
      enemy = $data_enemies[enemy_id]
      return (enemy != nil && enemy.name != "")
    end
    #--------------------------------------------------------------------------
    # ○ 存在する敵の種類数取得
    #     variable_id : 取得した値を代入する変数の ID
    #--------------------------------------------------------------------------
    def get_all_enemies_number(variable_id = 0)
      n = 0
      (1...$data_enemies.size).each { |i|
        n += 1 if enemy_guide_include?(i)
      }
      $game_variables[variable_id] = n if variable_id > 0
      return n
    end
    #--------------------------------------------------------------------------
    # ○ 遭遇した敵の種類数取得
    #     variable_id : 取得した値を代入する変数の ID
    #--------------------------------------------------------------------------
    def get_encountered_enemies_number(variable_id = 0)
      n = 0
      (1...$data_enemies.size).each { |i|
        if enemy_guide_include?(i) && $game_system.enemy_encountered[i]
          n += 1
        end
      }
      $game_variables[variable_id] = n if variable_id > 0
      return n
    end
    #--------------------------------------------------------------------------
    # ○ 撃破した敵の種類数取得
    #     variable_id : 取得した値を代入する変数の ID
    #--------------------------------------------------------------------------
    def get_defeated_enemies_number(variable_id = 0)
      n = 0
      (1...$data_enemies.size).each { |i|
        if enemy_guide_include?(i) && $game_system.enemy_encountered[i] &&
            $game_system.enemy_defeated[i]
          n += 1
        end
      }
      $game_variables[variable_id] = n if variable_id > 0
      return n
    end
    #--------------------------------------------------------------------------
    # ○ モンスター図鑑完成度の取得
    #     variable_id : 取得した値を代入する変数の ID
    #--------------------------------------------------------------------------
    def get_enemy_guide_completion(variable_id = 0)
      num = get_all_enemies_number
      value = (num > 0 ? (get_defeated_enemies_number * 100 / num) : 0)
      $game_variables[variable_id] = value if variable_id > 0
      return value
    end
    #--------------------------------------------------------------------------
    # ○ モンスター図鑑呼び出し
    #--------------------------------------------------------------------------
    def call_enemy_guide
      return if $game_temp.in_battle
      $game_temp.next_scene = :enemy_guide
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

module Vocab
  # モンスター図鑑
  def self.enemy_guide
    return KGC::EnemyGuide::VOCAB_MENU_ENEMY_GUIDE
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class RPG::Enemy
  #--------------------------------------------------------------------------
  # ○ モンスター図鑑のキャッシュ生成
  #--------------------------------------------------------------------------
  def create_enemy_guide_cache
    @__enemy_guide_description = ""

    description_flag = false
    self.note.each_line { |line|
      case line
      when KGC::EnemyGuide::Regexp::Enemy::BEGIN_GUIDE_DESCRIPTION
        # 説明文開始
        description_flag = true
      when KGC::EnemyGuide::Regexp::Enemy::END_GUIDE_DESCRIPTION
        # 説明文終了
        description_flag = false
      else
        if description_flag
          @__enemy_guide_description += line
        end
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 図鑑説明文
  #--------------------------------------------------------------------------
  def enemy_guide_description
    create_enemy_guide_cache if @__enemy_guide_description == nil
    return @__enemy_guide_description
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_writer   :enemy_encountered        # 遭遇済みフラグ
  attr_writer   :enemy_defeated           # 撃破済みフラグ
  attr_writer   :enemy_item_dropped       # アイテムドロップ済みフラグ
  attr_writer   :enemy_object_stolen      # 盗み成功済みフラグ
  #--------------------------------------------------------------------------
  # ○ 遭遇済みフラグ取得
  #--------------------------------------------------------------------------
  def enemy_encountered
    @enemy_encountered = [] if @enemy_encountered == nil
    return @enemy_encountered
  end
  #--------------------------------------------------------------------------
  # ○ 撃破済みフラグ取得
  #--------------------------------------------------------------------------
  def enemy_defeated
    @enemy_defeated = [] if @enemy_defeated == nil
    return @enemy_defeated
  end
  #--------------------------------------------------------------------------
  # ○ アイテムドロップ済みフラグ取得
  #--------------------------------------------------------------------------
  def enemy_item_dropped
    @enemy_item_dropped = [] if @enemy_item_dropped == nil
    return @enemy_item_dropped
  end
  #--------------------------------------------------------------------------
  # ○ 盗み成功済みフラグ取得
  #--------------------------------------------------------------------------
  def enemy_object_stolen
    @enemy_object_stolen = [] if @enemy_object_stolen == nil
    return @enemy_object_stolen
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     index    : 敵グループ内インデックス
  #     enemy_id : 敵キャラ ID
  #--------------------------------------------------------------------------
  alias initialize_KGC_EnemyGuide initialize
  def initialize(index, enemy_id)
    initialize_KGC_EnemyGuide(index, enemy_id)

    @original_ids = []  # 変身前の ID
    # 遭遇済みフラグをオン
    KGC::Commands.set_enemy_encountered(enemy_id) unless hidden
  end
  #--------------------------------------------------------------------------
  # ● コラプスの実行
  #--------------------------------------------------------------------------
  alias perform_collapse_KGC_EnemyGuide perform_collapse
  def perform_collapse
    last_collapsed = @collapse

    perform_collapse_KGC_EnemyGuide

    if !last_collapsed && @collapse
      # 撃破済みフラグをオン
      KGC::Commands.set_enemy_defeated(enemy_id)
      # 変身前の敵も撃破済みにする
      if KGC::EnemyGuide::ORIGINAL_DEFEAT
        @original_ids.compact.each { |i|
          KGC::Commands.set_enemy_defeated(i)
        }
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 変身
  #     enemy_id : 変身先の敵キャラ ID
  #--------------------------------------------------------------------------
  alias transform_KGC_EnemyGuide transform
  def transform(enemy_id)
    # 変身前のIDを保存
    @original_ids << @enemy_id

    transform_KGC_EnemyGuide(enemy_id)

    # 変身後の敵も遭遇済みにする
    KGC::Commands.set_enemy_encountered(enemy_id)
  end
  #--------------------------------------------------------------------------
  # ● 隠れ状態設定
  #--------------------------------------------------------------------------
  alias hidden_equal_KGC_EnemyGuide hidden= unless $@
  def hidden=(value)
    hidden_equal_KGC_EnemyGuide(value)
    # 出現した場合は遭遇済みフラグをオン
    KGC::Commands.set_enemy_encountered(enemy_id) unless value
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの配列作成
  #--------------------------------------------------------------------------
  def make_drop_items
    drop_items = []
    dead_members.each { |enemy|
      [enemy.drop_item1, enemy.drop_item2].each_with_index { |di, i|
        next if di.kind == 0
        next if rand(di.denominator) != 0
        if di.kind == 1
          drop_items.push($data_items[di.item_id])
        elsif di.kind == 2
          drop_items.push($data_weapons[di.weapon_id])
        elsif di.kind == 3
          drop_items.push($data_armors[di.armor_id])
        end
        # ドロップ済みフラグをセット
        KGC::Commands.set_enemy_item_dropped(enemy.enemy.id, i)
      }
    }
    return drop_items
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Window_Command < Window_Selectable
  unless method_defined?(:add_command)
  #--------------------------------------------------------------------------
  # ○ コマンドを追加
  #    追加した位置を返す
  #--------------------------------------------------------------------------
  def add_command(command)
    @commands << command
    @item_max = @commands.size
    item_index = @item_max - 1
    refresh_command
    draw_item(item_index)
    return item_index
  end
  #--------------------------------------------------------------------------
  # ○ コマンドをリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_command
    buf = self.contents.clone
    self.height = [self.height, row_max * WLH + 32].max
    create_contents
    self.contents.blt(0, 0, buf, buf.rect)
    buf.dispose
  end
  #--------------------------------------------------------------------------
  # ○ コマンドを挿入
  #--------------------------------------------------------------------------
  def insert_command(index, command)
    @commands.insert(index, command)
    @item_max = @commands.size
    refresh_command
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ コマンドを削除
  #--------------------------------------------------------------------------
  def remove_command(command)
    @commands.delete(command)
    @item_max = @commands.size
    refresh
  end
  end
end

#=================================================#

#==============================================================================
#------------------------------------------------------------------------------
#   モンスター図鑑画面で、完成度を表示するウィンドウです。
#==============================================================================

class Window_EnemyGuideTop < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 240, WLH * 4 + 32)
    self.height = WLH + 32
    @duration = 0
    @interval = KGC::EnemyGuide::INFO_INTERVAL
    refresh

    if KGC::EnemyGuide::USE_BACKGROUND_IMAGE
      self.opacity = 0
    end
    if self.windowskin != nil
      bitmap = Bitmap.new(windowskin.width, windowskin.height)
      bitmap.blt(0, 0, windowskin, windowskin.rect)
      bitmap.clear_rect(80, 16, 32, 32)
      self.windowskin = bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● 破棄
  #--------------------------------------------------------------------------
  def dispose
    self.windowskin.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    total = KGC::Commands.get_all_enemies_number
    encountered = KGC::Commands.get_encountered_enemies_number
    defeated = KGC::Commands.get_defeated_enemies_number

    text = sprintf("遭遇數: %3d/%3d ",encountered, total)
    self.contents.draw_text(0,       0, width - 32, WLH, text, 1)
    self.contents.draw_text(0, WLH * 3, width - 32, WLH, text, 1)
    text = sprintf("擊殺數: %3d/%3d", defeated, total)
    self.contents.draw_text(0, WLH, width - 32, WLH, text, 1)
    text = sprintf("完成度: %3d%%", defeated * 100 / total)
    self.contents.draw_text(0, WLH * 2, width - 32, WLH, text, 1)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    @duration += 1
    case @duration
    when @interval...(@interval + WLH)
      self.oy += 1
    when (@interval + WLH)
      @duration = 0
      if self.oy >= WLH * 3
        self.oy = 0
      end
    end
  end
end

#=================================================#

#==============================================================================
#------------------------------------------------------------------------------
#   モンスター図鑑画面で、モンスター一覧を表示するウィンドウです。
#==============================================================================

class Window_EnemyGuideList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, WLH + 32, 240, Graphics.height - (WLH + 32))
    self.index = 0
    refresh
    if KGC::EnemyGuide::USE_BACKGROUND_IMAGE
      self.opacity = 0
      self.height -= (self.height - 32) % WLH
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択モンスターの取得
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ○ エネミーをリストに含めるか
  #     enemy_id : 敵 ID
  #--------------------------------------------------------------------------
  def include?(enemy_id)
    return KGC::Commands.enemy_guide_include?(enemy_id)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    if KGC::EnemyGuide::ENEMY_ORDER_ID == nil
      # ID順
      enemy_list = 1...$data_enemies.size
    else
      # 指定順
      enemy_list = KGC::EnemyGuide::ENEMY_ORDER_ID
    end
    enemy_list.each { |i|
      @data << $data_enemies[i] if include?(i)
    }
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    enemy = @data[index]
    self.contents.font.color = normal_color
    unless KGC::Commands.enemy_defeated?(enemy.id)
      self.contents.font.color.alpha = 128
    end
    rect = item_rect(index)
    self.contents.clear_rect(rect)

    if KGC::EnemyGuide::SHOW_SERIAL_NUMBER
      s_num = sprintf(KGC::EnemyGuide::SERIAL_NUM_FORMAT,
        KGC::EnemyGuide::SERIAL_NUM_FOLLOW ? (index + 1) : enemy.id)
    end

    text = (KGC::EnemyGuide::SHOW_SERIAL_NUMBER ? s_num : "")
    if KGC::Commands.enemy_encountered?(enemy.id)
      # 遭遇済み
      text += enemy.name
    else
      # 未遭遇
      mask = KGC::EnemyGuide::UNKNOWN_ENEMY_NAME
      if mask.scan(/./).size == 1
        mask = mask * enemy.name.scan(/./).size
      end
      text += mask
    end
    self.contents.draw_text(rect, text)
  end
end

#=================================================#

#==============================================================================
#------------------------------------------------------------------------------
#   モンスター図鑑画面で、ステータスを表示するウィンドウです。
#==============================================================================

class Window_EnemyGuideStatus < Window_Base
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  PAGES = 3  # ページ数
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :enemy                    # 表示エネミー
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(240, 0, Graphics.width - 240, Graphics.height)
    self.enemy = nil
    self.z = 100
    if KGC::EnemyGuide::USE_BACKGROUND_IMAGE
      self.opacity = 0
    end
    @show_sprite = false
    @enemy_sprite = Sprite.new
    @enemy_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @enemy_sprite.x = 0
    @enemy_sprite.y = 0
    @enemy_sprite.z = self.z + 100
    @enemy_sprite.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 破棄
  #--------------------------------------------------------------------------
  def dispose
    super
    @enemy_sprite.bitmap.dispose
    @enemy_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 表示エネミー設定
  #--------------------------------------------------------------------------
  def enemy=(enemy)
    @enemy = enemy
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 表示情報切り替え
  #     shamt : 移動ページ数
  #--------------------------------------------------------------------------
  def shift_info_type(shamt)
    n = self.ox + (width - 32) * shamt
    self.ox = [[n, 0].max, (width - 32) * (PAGES - 1)].min
  end
  #--------------------------------------------------------------------------
  # ○ スプライト表示切替
  #--------------------------------------------------------------------------
  def switch_sprite
    @show_sprite = !@show_sprite
    @enemy_sprite.visible = @show_sprite
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    original_width = self.width
    self.width = original_width * PAGES - (32 * (PAGES - 1))
    create_contents
    self.width = original_width

    draw_enemy_sprite

    return if enemy == nil

    self.contents.font.color = normal_color
    # 遭遇していない
    unless KGC::Commands.enemy_encountered?(enemy.id)
      self.contents.font.color.alpha = 128
      dy = (height - 32) / 2
      dy -= dy % WLH
      self.contents.draw_text(0, dy, width - 32, WLH,
        KGC::EnemyGuide::UNENCOUNTERED_DATA, 1)
      self.contents.blt(width - 32, 0, self.contents, self.contents.rect)
      return
    end

    draw_status
  end
  #--------------------------------------------------------------------------
  # ○ ステータス描画
  #--------------------------------------------------------------------------
  def draw_status
    dy = draw_basic_info(0, 0)
    dy = draw_parameter2(0, dy)
    dy = draw_element(0, dy, 2)
    dy = draw_state(0, dy, 2)
    
    draw_prize(0, dy)
    
    dx = width - 32
    dy = draw_basic_info(dx, 0)
    max_rows = (self.height - dy - 32) / WLH
    rows = (max_rows + 1) / 2
    dy = draw_drop_item(dx, dy, rows)
    draw_steal_object(dx, dy, max_rows - rows)
    dx = (width - 32) * 2
    dy = draw_basic_info(dx, 0)
    draw_description(dx, dy)
  end
  #--------------------------------------------------------------------------
  # ○ 基本情報画
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_basic_info(dx, dy)
    draw_graphic(dx, dy)
    draw_parameter1(dx + 112, dy)
    return dy + 96
  end
  #--------------------------------------------------------------------------
  # ○ グラフィック描画
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_graphic(dx, dy)
    bitmap = Cache.battler(enemy.battler_name, enemy.battler_hue)
    rect = Rect.new(0, 0, bitmap.width / 3, bitmap.height / 3)
    rect.x = dx + (104 - rect.width) / 2
    rect.y = dy + (96 - rect.height) / 2
    self.contents.stretch_blt(rect, bitmap, bitmap.rect)
  end
  #--------------------------------------------------------------------------
  # ○ エネミースプライト描画
  #--------------------------------------------------------------------------
  def draw_enemy_sprite
    return if @enemy_sprite == nil

    @enemy_sprite.bitmap.fill_rect(@enemy_sprite.bitmap.rect,
      Color.new(0, 0, 0, 160))

    return if enemy == nil || !KGC::Commands.enemy_encountered?(enemy.id)

    bitmap = Cache.battler(enemy.battler_name, enemy.battler_hue)
    dx = (Graphics.width - bitmap.width) / 2
    dy = (Graphics.height - bitmap.height) / 2
    @enemy_sprite.bitmap.blt(dx, dy, bitmap, bitmap.rect)
  end
  #--------------------------------------------------------------------------
  # ○ パラメータ描画 - 1
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_parameter1(dx, dy)
    # 名前, HP, MP
    param = {}
    if KGC::Commands.enemy_defeated?(enemy.id)
      param[:maxhp] = enemy.maxhp
      param[:maxmp] = enemy.maxmp
      if $imported["BattleCount"]
        param[:defeat_count] = KGC::Commands.get_defeat_count(enemy.id)
      end
    else
      param[:maxhp] = param[:maxmp] = KGC::EnemyGuide::UNDEFEATED_PARAMETER
      param[:defeat_count] = 0
    end

    self.contents.font.color = normal_color
    self.contents.draw_text(dx, dy, width - 144, WLH, enemy.name)
    self.contents.font.color = system_color
    self.contents.draw_text(dx, dy + WLH,     80, WLH, Vocab.hp)
    self.contents.draw_text(dx, dy + WLH * 2, 80, WLH, Vocab.mp)
    if $imported["BattleCount"]
      self.contents.draw_text(dx, dy + WLH * 3, 80, WLH,
        KGC::EnemyGuide::PARAMETER_NAME[:defeat_count])
    end
    self.contents.font.color = normal_color
    self.contents.draw_text(dx + 88, dy + WLH,     64, WLH, param[:maxhp], 2)
    self.contents.draw_text(dx + 88, dy + WLH * 2, 64, WLH, param[:maxmp], 2)
    if $imported["BattleCount"]
      self.contents.draw_text(dx + 88, dy + WLH * 3, 64, WLH,
        param[:defeat_count], 2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ パラメータ描画 - 2
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_parameter2(dx, dy)
    param = {}
    if KGC::Commands.enemy_defeated?(enemy.id)
      param[:atk]   = enemy.atk
      param[:def]   = enemy.def
      param[:spi]   = enemy.spi
      param[:agi]   = enemy.agi
    else
      param[:atk] = param[:def] = param[:spi] = param[:agi] =
        KGC::EnemyGuide::UNDEFEATED_PARAMETER
    end

    dw = (width - 32) / 2
    self.contents.font.color = system_color
    self.contents.draw_text(dx,      dy,       80, WLH, Vocab.atk)
    self.contents.draw_text(dx + dw, dy,       80, WLH, Vocab.def)
    self.contents.draw_text(dx,      dy + WLH, 80, WLH, Vocab.spi)
    self.contents.draw_text(dx + dw, dy + WLH, 80, WLH, Vocab.agi)
    dx += 80
    self.contents.font.color = normal_color
    self.contents.draw_text(dx,      dy,       48, WLH, param[:atk], 2)
    self.contents.draw_text(dx + dw, dy,       48, WLH, param[:def], 2)
    self.contents.draw_text(dx     , dy + WLH, 48, WLH, param[:spi], 2)
    self.contents.draw_text(dx + dw, dy + WLH, 48, WLH, param[:agi], 2)
    return dy + WLH * 2
  end
  #--------------------------------------------------------------------------
  # ○ 属性描画
  #     dx, dy : 描画先 X, Y
  #     rows   : 行数
  #--------------------------------------------------------------------------
  def draw_element(dx, dy, rows = 1)
    new_dy = dy + WLH * (rows * 2)
    self.contents.font.color = system_color
    self.contents.draw_text(dx, dy,              80, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:weak_element])
    self.contents.draw_text(dx, dy + WLH * rows, 80, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:resist_element])

    return new_dy unless KGC::Commands.enemy_defeated?(enemy.id)

    cols = (width - 112) / 24
    # 弱点属性
    draw_icon_list(dx + 80, dy, rows, cols,
      KGC::EnemyGuide::CHECK_ELEMENT_LIST,
      Proc.new { |i| enemy.element_ranks[i] < 3 },
      Proc.new { |i| KGC::EnemyGuide::ELEMENT_ICON[i] })
    # 耐性属性
    draw_icon_list(dx + 80, dy + WLH * rows, rows, cols,
      KGC::EnemyGuide::CHECK_ELEMENT_LIST,
      Proc.new { |i| enemy.element_ranks[i] > 3 },
      Proc.new { |i| KGC::EnemyGuide::ELEMENT_ICON[i] })
    return new_dy
  end
  #--------------------------------------------------------------------------
  # ○ アイコンリスト描画
  #     dx, dy     : 描画先 X, Y
  #     rows, cols : アイコン行/列数
  #     item_list  : 描画対象のリスト
  #     cond_proc  : 描画条件 Proc
  #     index_proc : アイコン index 取得用 Proc
  #--------------------------------------------------------------------------
  def draw_icon_list(dx, dy, rows, cols, item_list, cond_proc, index_proc)
    nc = 0  # 現在の列数
    nr = 0  # 現在の行数
    item_list.each { |item|
      next if item == nil
      next unless cond_proc.call(item)
      icon_index = index_proc.call(item)
      next if icon_index == nil || icon_index == 0

      draw_icon(icon_index, dx + nc * 24, dy + nr * 24)
      nc += 1
      if nc == cols
        # 次の行へ
        nc = 0
        nr += 1
        break if nr == rows  # 行制限オーバー
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ ステート描画
  #     dx, dy : 描画先 X, Y
  #     rows   : 行数
  #--------------------------------------------------------------------------
  def draw_state(dx, dy, rows = 1)
    new_dy = dy + WLH * (rows * 2)
    self.contents.font.color = system_color
    self.contents.draw_text(dx, dy,              80, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:weak_state])
    self.contents.draw_text(dx, dy + WLH * rows, 80, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:resist_state])

    return new_dy unless KGC::Commands.enemy_defeated?(enemy.id)

    cols = (width - 112) / 24
    # 弱点ステート
    draw_icon_list(dx + 80, dy, rows, cols,
      $data_states,
      Proc.new { |i| enemy.state_ranks[i.id] < 3 },
      Proc.new { |i| i.icon_index })
    # 無効ステート
    draw_icon_list(dx + 80, dy + WLH * rows, rows, cols,
      $data_states,
      Proc.new { |i| enemy.state_ranks[i.id] == 6 },
      Proc.new { |i| i.icon_index })
    return new_dy
  end
  #--------------------------------------------------------------------------
  # ○ EXP, Gold 描画
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_prize(dx, dy)
    param = {}
    if KGC::Commands.enemy_defeated?(enemy.id)
      param[:exp]  = enemy.exp
      param[:gold] = enemy.gold
      param[:ap]   = enemy.ap if $imported["EquipLearnSkill"]
    else
      param[:exp] = param[:gold] = param[:ap] =
        KGC::EnemyGuide::UNDEFEATED_PARAMETER
    end

    dw = (width - 32) / 2
    self.contents.font.color = system_color
    self.contents.draw_text(dx,      dy, 80, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:exp])
    self.contents.draw_text(dx + dw, dy, 80, WLH, Vocab.gold)
    if $imported["EquipLearnSkill"]
      self.contents.draw_text(dx, dy + WLH, 80, WLH, Vocab.ap)
    end

    dx += 76
    self.contents.font.color = normal_color
    self.contents.draw_text(dx,      dy, 52, WLH, param[:exp], 2)
    self.contents.draw_text(dx + dw, dy, 52, WLH, param[:gold], 2)
    if $imported["EquipLearnSkill"]
      self.contents.draw_text(dx, dy + WLH, 52, WLH, param[:ap], 2)
    end

    return dy + WLH * 2
  end
  #--------------------------------------------------------------------------
  # ○ ドロップアイテム描画
  #     dx, dy : 描画先 X, Y
  #     rows   : 行数
  #--------------------------------------------------------------------------
  def draw_drop_item(dx, dy, rows)
    new_dy = dy + WLH * rows
    dw = (width - 32) / 2
    self.contents.font.color = system_color
    self.contents.draw_text(dx,      dy, 128, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:treasure], 1)
    self.contents.draw_text(dx + dw, dy, 128, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:drop_prob], 2)

    return new_dy unless KGC::Commands.enemy_defeated?(enemy.id)

    # リスト作成
    drop_items = [enemy.drop_item1, enemy.drop_item2]
    if $imported["ExtraDropItem"]
      drop_items += enemy.extra_drop_items
    end
    drop_items.delete_if { |i| i.kind == 0 }
    if drop_items.size >= rows
      drop_items = drop_items[0...(rows - 1)]
    end

    dy += WLH
    drop_items.each_with_index { |item, i|
      # アイテム名描画
      case item.kind
      when 0
        next
      when 1
        drop_item = $data_items[item.item_id]
      when 2
        drop_item = $data_weapons[item.weapon_id]
      when 3
        drop_item = $data_armors[item.armor_id]
      end
      if KGC::Commands.enemy_item_dropped?(enemy.id, i)
        draw_item_name(drop_item, dx, dy)
      else
        draw_masked_item_name(drop_item, dx, dy)
      end
      # ドロップ率描画
      if $imported["ExtraDropItem"] && item.drop_prob > 0
        text = sprintf("%d%%", item.drop_prob)
      else
        text = "1/#{item.denominator}"
      end
      self.contents.draw_text(dx + dw, dy, 128, WLH, text, 2)
      dy += WLH
    }

    return new_dy
  end
  #--------------------------------------------------------------------------
  # ○ アイテム名をマスクして描画
  #     item    : アイテム (スキル、武器、防具でも可)
  #     x       : 描画先 X 座標
  #     y       : 描画先 Y 座標
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_masked_item_name(item, x, y, enabled = true)
    return if item == nil

    draw_icon(item.icon_index, x, y, enabled)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    mask = KGC::EnemyGuide::UNDROPPED_ITEM_NAME
    text = KGC.mask_string(item.name, mask)
    self.contents.draw_text(x + 24, y, 172, WLH, text)
  end
  #--------------------------------------------------------------------------
  # ○ 盗めるオブジェクト描画
  #     dx, dy : 描画先 X, Y
  #     rows   : 行数
  #--------------------------------------------------------------------------
  def draw_steal_object(dx, dy, rows)
    return unless $imported["Steal"]

    new_dy = dy + WLH * rows
    dw = (width - 32) / 2
    self.contents.font.color = system_color
    self.contents.draw_text(dx,      dy, 128, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:steal_obj], 1)
    self.contents.draw_text(dx + dw, dy, 128, WLH,
      KGC::EnemyGuide::PARAMETER_NAME[:steal_prob], 2)

    return new_dy unless KGC::Commands.enemy_defeated?(enemy.id)

    # リスト作成
    steal_objects = enemy.steal_objects.clone
    if steal_objects.size >= rows
      steal_objects = steal_objects[0...(rows - 1)]
    end

    dy += WLH
    steal_objects.each_with_index { |obj, i|
      if obj.kind == 4
        if KGC::Commands.enemy_object_stolen?(enemy.id, i)
          text = sprintf("%d%s", obj.gold, Vocab.gold)
        else
          mask = KGC::EnemyGuide::UNDROPPED_ITEM_NAME
          text = KGC.mask_string("aaa", mask)
        end
        self.contents.draw_text(dx + 24, dy, dw, WLH, text)
      else
        case obj.kind
        when 1
          item = $data_items[obj.item_id]
        when 2
          item = $data_weapons[obj.weapon_id]
        when 3
          item = $data_armors[obj.armor_id]
        end
        if KGC::Commands.enemy_object_stolen?(enemy.id, i)
          draw_item_name(item, dx, dy)
        else
          draw_masked_item_name(item, dx, dy)
        end
      end
      # 成功率描画
      if obj.success_prob > 0
        text = sprintf("%d%%", obj.success_prob)
      else
        text = "1/#{obj.denominator}"
      end
      self.contents.draw_text(dx + dw, dy, 128, WLH, text, 2)
      dy += WLH
    }

    return new_dy
  end
  #--------------------------------------------------------------------------
  # ○ 説明文描画
  #     dx, dy : 描画先 X, Y
  #--------------------------------------------------------------------------
  def draw_description(dx, dy)
    return unless KGC::Commands.enemy_defeated?(enemy.id)

    dx += 4
    enemy.enemy_guide_description.each_line { |line|
      self.contents.draw_text(dx, dy, width - 32, WLH, line.chomp)
      dy += WLH
    }
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 画面切り替えの実行
  #--------------------------------------------------------------------------
  alias update_scene_change_KGC_EnemyGuide update_scene_change
  def update_scene_change
    return if $game_player.moving?    # プレイヤーの移動中？

    if $game_temp.next_scene == :enemy_guide
      call_enemy_guide
      return
    end

    update_scene_change_KGC_EnemyGuide
  end
  #--------------------------------------------------------------------------
  # ○ モンスター図鑑への切り替え
  #--------------------------------------------------------------------------
  def call_enemy_guide
    $game_temp.next_scene = nil
    $scene = Scene_EnemyGuide.new(0, Scene_EnemyGuide::HOST_MAP)
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Scene_Menu < Scene_Base
  if KGC::EnemyGuide::USE_MENU_ENEMY_GUIDE_COMMAND
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias create_command_window_KGC_EnemyGuide create_command_window
  def create_command_window
    create_command_window_KGC_EnemyGuide

    return if $imported["CustomMenuCommand"]

    @__command_enemy_guide_index =
      @command_window.add_command(Vocab.enemy_guide)
    if @command_window.oy > 0
      @command_window.oy -= Window_Base::WLH
    end
    @command_window.index = @menu_index
  end
  end
  #--------------------------------------------------------------------------
  # ● コマンド選択の更新
  #--------------------------------------------------------------------------
  alias update_command_selection_KGC_EnemyGuide update_command_selection
  def update_command_selection
    current_menu_index = @__command_enemy_guide_index
    call_enemy_guide_flag = false

    if Input.trigger?(Input::C)
      case @command_window.index
      when @__command_enemy_guide_index  # モンスター図鑑
        call_enemy_guide_flag = true
      end
    end

    # モンスター図鑑に移行
    if call_enemy_guide_flag
      Sound.play_decision
      $scene = Scene_EnemyGuide.new(@__command_enemy_guide_index,
        Scene_EnemyGuide::HOST_MENU)
      return
    end

    update_command_selection_KGC_EnemyGuide
  end
end

#=================================================#

#==============================================================================
#------------------------------------------------------------------------------
#   モンスター図鑑画面の処理を行うクラスです。
#==============================================================================

class Scene_EnemyGuide < Scene_Base
  HOST_MENU   = 0
  HOST_MAP    = 1
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     menu_index  : コマンドのカーソル初期位置
  #     host_scene  : 呼び出し元 (0..メニュー  1..マップ)
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0, host_scene = HOST_MENU)
    @menu_index = menu_index
    @host_scene = host_scene
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    if KGC::EnemyGuide::USE_BACKGROUND_IMAGE
      @back_sprite = Sprite.new
      begin
        @back_sprite.bitmap = Cache.system(KGC::EnemyGuide::BACKGROUND_FILENAME)
      rescue
        @back_sprite.bitmap = Bitmap.new(32, 32)
      end
    end

    @top_window = Window_EnemyGuideTop.new
    @enemy_window = Window_EnemyGuideList.new
    @status_window = Window_EnemyGuideStatus.new
    @status_window.enemy = @enemy_window.item
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    if @back_sprite != nil
      @back_sprite.bitmap.dispose
      @back_sprite.dispose
    end
    @top_window.dispose
    @enemy_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 元の画面へ戻る
  #--------------------------------------------------------------------------
  def return_scene
    case @host_scene
    when HOST_MENU
      $scene = Scene_Menu.new(@menu_index)
    when HOST_MAP
      $scene = Scene_Map.new
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @top_window.update
    @enemy_window.update
    @status_window.update
    if @enemy_window.active
      update_enemy_selection
    end
  end
  #--------------------------------------------------------------------------
  # ○ エネミー選択の更新
  #--------------------------------------------------------------------------
  def update_enemy_selection
    if @last_index != @enemy_window.index
      @status_window.enemy = @enemy_window.item
      @last_index = @enemy_window.index
    end

    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::A) || Input.trigger?(Input::C)
      # スプライト表示切替
      Sound.play_decision
      @status_window.switch_sprite
    elsif Input.trigger?(Input::LEFT)
      # 左ページ
      Sound.play_cursor
      @status_window.shift_info_type(-1)
    elsif Input.trigger?(Input::RIGHT)
      # 右ページ
      Sound.play_cursor
      @status_window.shift_info_type(1)
    end
  end
end

#==============================================================================
# PHASE6 原始頁: 288 | Patch compatibilité SBS-Bestiaire
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Game_Enemy < Game_Battler
#--------------------------------------------------------------------------
# ● コラプスの実行
#--------------------------------------------------------------------------
  alias moonlight_kgcenemyguide_fix_perform_collapse perform_collapse
  def perform_collapse
    last_collapsed = @force_action == ["N01collapse"] ? true : false

     moonlight_kgcenemyguide_fix_perform_collapse

    if !last_collapsed && @force_action == ["N01collapse"]
      # 撃破済みフラグをオン
      KGC::Commands.set_enemy_defeated(enemy_id)
      # 変身前の敵も撃破済みにする
      if KGC::EnemyGuide::ORIGINAL_DEFEAT
        @original_ids.compact.each { |i|
          KGC::Commands.set_enemy_defeated(i)
        }
      end
    end
  end
end 
