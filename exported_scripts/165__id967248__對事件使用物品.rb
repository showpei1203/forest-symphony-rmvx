#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：對事件使用物品
# 【用途】地圖／事件元件「對事件使用物品」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Battler、Game_Party、Game_Event、Game_Player、Game_Interpreter、Window_Message、Scene_Item
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LAST_USE_ITEM。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 10 個 alias／方法包裝，載入順序具有語意。
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
#
#　■イベント起動条件アイテム＆スキル　□Ver5.00　□製作者：月紳士
#  
#　・RPGツクールVX用 RGSS2スクリプト
#
#    ●…書き換えメソッド(競合注意)　◎…メソッドのエイリアス　○…新規メソッド
#
#  ※二次配布禁止！配布元には利用規約があります。必ずそちらを見てください。
#------------------------------------------------------------------------------
# 更新履歴（過去の履歴はマニュアルに記載）
#   Ver5.00  スクリプト内部処理の簡略化。
#            ※ 過去の 起動条件アイテム<…> という
#               Ver1.00～Ver2.00のコマンド表記を廃止。
#　　　　　　月紳士の「アクターアイテムシステム」スクリプトとの併用に対応。
#------------------------------------------------------------------------------
=begin

　起動させたいイベントページの一行目に注釈で以下のように記入してください。

　　起動条件<item-id:25>

　起動条件の後の<>内は、起動させたいアイテム、スキルの指定の仕方で
　記述が変わります。以下が記述例です。

　　起動条件<skill-id:15>　　　　　　　　　　　　　　　　　　：スキルの場合
　　起動条件<item-id:25/item-id:26/skill-id:15>　　　　　　　：連記可能
　　起動条件<items>　　　　　　　　　　　　　　　　　　　　　：すべてのアイテム
　　起動条件<skills>　　　　　　　　　　　　　　　　　 　　　：すべてのスキル
　　起動条件<all>　　　　　　　　　　　　　　　　　　　：アイテム・スキルすべて

　アイテム・スキルに「タイプ」をあらかじめ設定して、
　そのタイプを元にイベントを起動することも可能です。

　　起動条件<type:カギ>

　詳しい設定の仕方はマニュアルを参照してください。

=end 
#==============================================================================

#==============================================================================
# □ イベント起動条件アイテム＆スキル・モジュール（カスタマイズ項目）
#==============================================================================

module Event_Trigger_Object

  LAST_USE_ITEM = 1     # LAST_USE_ITEM の右側の番号の変数に、
                        # 起動に使われたアイテムのID番号を出力します。
                        # スキルの場合は、+1000 の値を出力します。
                        # (スキルIDが15なら1015を出力)                        
                        # イベント起動するアイテム・スキルが複数ある際、
                        # この変数を参照することで
                        # アイテム毎、スキル毎にイベント内で条件分岐できます。

end
                      
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　バトラーを扱うクラスです。このクラスは Game_Actor クラスと Game_Enemy クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ◎ スキルの使用可能判定
  #     skill : スキル
  #--------------------------------------------------------------------------
  alias tig_eto_skill_can_use? skill_can_use?
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    return false if calc_mp_cost(skill) > mp
    unless $game_temp.in_battle
      id = 1000 + skill.id
      if $game_player.check_event_trigger_object(id, true)
        return true
      end
      if skill.scope == 0
        return skill.common_event_id > 0
      end
    end
    return tig_eto_skill_can_use?(skill)
  end
end
  
#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。ゴールドやアイテムなどの情報が含まれます。このク
# ラスのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :use_skill                     # 使用したスキルのＩＤ
  attr_accessor :skill_user                    # スキルを使用したアクターのＩＤ
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tig_eto_initialize initialize
  def initialize
    tig_eto_initialize
    @use_skill_id = nil
    @skill_user_id = nil
  end
  #--------------------------------------------------------------------------
  # ◎ アイテムの使用可能判定
  #     item : アイテム
  #--------------------------------------------------------------------------
  alias tig_eto_item_can_use? item_can_use?
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    unless $game_temp.in_battle
      if $game_player.check_event_trigger_object(item.id, true)
        return true
      end
      if item.scope == 0
        return item.common_event_id > 0
      end
    end
    return tig_eto_item_can_use?(item)
  end
end

#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :erased        # 一時消去されたかどうかを外部から読み取れる様に
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #     map_id : マップ ID
  #     event  : イベント (RPG::Event)
  #--------------------------------------------------------------------------
  alias tig_eto_initialize initialize
  def initialize(map_id, event)
    @event_trigger_all_items = false
    @event_trigger_all_skills = false
    @event_trigger_all_weapons = false
    @event_trigger_all_armors = false
    @event_trigger_type = []
    @event_trigger_id = []
    tig_eto_initialize(map_id, event)
  end
  #--------------------------------------------------------------------------
  # ◎ イベントページの条件合致判定
  #--------------------------------------------------------------------------
  alias tig_eto_conditions_met? conditions_met?
  def conditions_met?(page)
    return if @erased
    if set_event_object_trigger(page)
      return false if $game_player.trigger_object_id == nil
      return object_trigger?($game_player.trigger_object_id)
    end
    return tig_eto_conditions_met?(page) 
  end
  #--------------------------------------------------------------------------
  # ○ イベント起動アイテム条件判定
  #--------------------------------------------------------------------------
  def object_trigger?(object_id)
    if object_id < 1000
      return true if @event_trigger_all_items
      object = $data_items[object_id]
    elsif object_id < 2000
      return true if @event_trigger_all_skills
      object = $data_skills[object_id - 1000]
    elsif object_id < 3000
      return true if @event_trigger_all_weapons
      object = $data_weapons[object_id - 2000]
    elsif object_id < 4000
      return true if @event_trigger_all_armors
      object = $data_armors[object_id - 3000]
    end

    return true if @event_trigger_id.include?(object_id)
    if object != nil
      return true if @event_trigger_type.include?(object.event_trigger_type)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○ イベント起動アイテム条件の取得
  #--------------------------------------------------------------------------
  def set_event_object_trigger(page)
    if page.list.size > 0
      command = page.list[0]
      if command.code == 108
        if /^起動条件[<＜]/ =~ command.parameters[0]
          @event_trigger_all_items = /[<＜\s\/／]items[>＞\s\/／]/ =~ command.parameters[0]
          @event_trigger_all_skills = /[<＜\s\/／]skills[>＞\s\/／]/ =~ command.parameters[0]
          @event_trigger_all_weapons = /[<＜\s\/／]weapons[>＞\s\/／]/ =~ command.parameters[0]
          @event_trigger_all_armors = /[<＜\s\/／]armors[>＞\s\/／]/ =~ command.parameters[0]
          if /[<＜\s]all[>＞\s]/ =~ command.parameters[0]
            @event_trigger_all_items = true ; @event_trigger_all_skills = true
            @event_trigger_all_weapons = true ; @event_trigger_all_armors = true
          end
          
          @event_trigger_id = []
          if /[<＜\s\/／]item[-_]id:\d+[>＞\s\/／]/ =~ command.parameters[0]
            item_id = command.parameters[0].scan(/[<＜\s\/／]item[-_]id:(\d+)[>＞\s\/／]/)
            item_id = item_id.flatten
            item_id.size.times {|n|item_id[n] = item_id[n].to_i}
            @event_trigger_id += item_id.compact
          end
          if /[<＜\s\/／]skill[-_]id:\d+[>＞\s\/／]/ =~ command.parameters[0]
            skill_id = command.parameters[0].scan(/[<＜\s\/／]skill[-_]id:(\d+)[>＞\s\/／]/)
            skill_id = skill_id.flatten
            skill_id.size.times { |n|
              skill_id[n] = skill_id[n].to_i
              skill_id[n] += 1000
            }
            @event_trigger_id += skill_id.compact
          end
          if /[<＜\s\/／]weapon[-_]id:\d+[>＞\s\/／]/ =~ command.parameters[0]
            weapon_id = command.parameters[0].scan(/[<＜\s\/／]weapon[-_]id:(\d+)[>＞\s\/／]/)
            weapon_id = weapon_id.flatten
            weapon_id.size.times { |n|
              weapon_id[n] = weapon_id[n].to_i
              weapon_id[n] += 2000
            }
            @event_trigger_id += weapon_id.compact
          end
          if /[<＜\s\/／]armor[-_]id:\d+[>＞\s\/／]/ =~ command.parameters[0]
            armor_id = command.parameters[0].scan(/[<＜\s\/／]armor[-_]id:(\d+)[>＞\s\/／]/)
            armor_id = armor_id.flatten
            armor_id.size.times { |n|
              armor_id[n] = armorl_id[n].to_i
              armor_id[n] += 3000
            }
            @event_trigger_id += armor_id.compact
          end
          
          words = command.parameters[0].scan(/[<＜\s\/／]type:(\S+)[>＞\s\/／]/)
          words = words.flatten
          words = [] if words == nil
          @event_trigger_type = words
          
          return true
        end
      end
    end
    return false
  end
end
  
#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================  
  
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :trigger_object_id           # 起動条件アイテムのＩＤ
  attr_reader   :last_trigger_object_id      # 最後に起動条件にしたアイテムのＩＤ
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tig_eto_initialize initialize
  def initialize
    tig_eto_initialize
    @trigger_object_id = nil
    @last_trigger_object_id = nil
  end
  #--------------------------------------------------------------------------
  # ○ オブジェクトの使用によるイベントの起動判定
  #     triggers : トリガーの配列
  #--------------------------------------------------------------------------
  def check_event_trigger_object(object_id, test = false)
    return false if $game_map.interpreter.running?
    result = false
    $game_variables[Event_Trigger_Object::LAST_USE_ITEM] = object_id
    @trigger_object_id = object_id
    @last_trigger_object_id = object_id
    for event in $game_map.events_xy(@x, @y)
      event.refresh
      next if event.erased
      next unless event.object_trigger?(object_id)
      next if event.priority_type == 1
      event.start unless test
      result = true
    end
    if result == false
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      for event in $game_map.events_xy(front_x, front_y)
        event.refresh
        next if event.erased
        next unless event.object_trigger?(object_id)
        next if event.priority_type != 1
        event.start unless test
        result = true
      end
    end
    @trigger_object_id = nil
    
    return result
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ◎ イベントの終了
  #--------------------------------------------------------------------------
  alias tig_eto_command_end command_end
  def command_end
    tig_eto_command_end
    $game_variables[Event_Trigger_Object::LAST_USE_ITEM] = 0 # 初期化
  end
  #--------------------------------------------------------------------------
  # ○ タイプの判別
  #--------------------------------------------------------------------------
  # memo :このメソッドはイベント内の条件分岐に使用できます。
  #--------------------------------------------------------------------------
  def event_trigger_type?(type)
    id = $game_player.last_trigger_object_id
    object = nil
    if id < 1000
      object = $data_items[id]
    elsif id < 2000
      object = $data_skills[id - 1000]
    elsif id < 3000
      object = $data_weapons[id - 2000]
    elsif id < 4000
      object = $data_armors[id - 3000]
    end
    return false if object == nil
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ object.note
      return type == $1
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムタイプの判別
  #--------------------------------------------------------------------------
  # memo :このメソッドはイベント内の条件分岐に使用できます。
  #--------------------------------------------------------------------------
  def event_trigger_item_type?(type)
    object = $data_items[$game_player.last_trigger_object_id]
    return false if object == nil
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ object.note
      return type == $1
    else
      return false
    end  
  end
  #--------------------------------------------------------------------------
  # ○ スキルタイプの判別
  #--------------------------------------------------------------------------
  # memo :このメソッドはイベント内の条件分岐に使用できます。
  #--------------------------------------------------------------------------
  def event_trigger_skill_type?(type)
    object = $data_skills[$game_player.last_trigger_object_id - 1000]
    return false if object == nil
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ object.note
      return type == $1
    else
      return false
    end  
  end
  #--------------------------------------------------------------------------
  # ○ 武器タイプの判別
  #--------------------------------------------------------------------------
  # memo :このメソッドはイベント内の条件分岐に使用できます。
  #--------------------------------------------------------------------------
  def event_trigger_weapon_type?(type)
    object = $data_weapons[$game_player.last_trigger_object_id - 2000]
    return false if object == nil
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ object.note
      return type == $1
    else
      return false
    end  
  end
  #--------------------------------------------------------------------------
  # ○ 防具タイプの判別
  #--------------------------------------------------------------------------
  # memo :このメソッドはイベント内の条件分岐に使用できます。
  #--------------------------------------------------------------------------
  def event_trigger_armor_type?(type)
    object = $data_armors[$game_player.last_trigger_object_id - 3000]
    return false if object == nil
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ object.note
      return type == $1
    else
      return false
    end  
  end
  #--------------------------------------------------------------------------
  # ○ スキルコスト消費
  #--------------------------------------------------------------------------
  # memo :最後にスキルでイベント起動したアクターが、そのコストを消費をします。
  #--------------------------------------------------------------------------
  def consume_skill_cost
    skill = $game_party.use_skill
    user = $game_party.skill_user
    return if $game_party.use_skill == nil
    user.mp -= user.calc_mp_cost(skill)
  end
end

#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　文章表示に使うメッセージウィンドウです。
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ◎ 特殊文字の変換
  #--------------------------------------------------------------------------
  alias tig_eto_convert_special_characters convert_special_characters
  def convert_special_characters
    object_id = $game_player.last_trigger_object_id
    if object_id != nil
      if object_id < 1000
        object = $data_items[object_id]
      elsif object_id < 2000
        object = $data_skills[object_id - 1000]
      elsif object_id < 3000
        object = $data_weapons[object_id - 2000]
      elsif object_id < 4000
        object = $data_armors[object_id - 3000]
      end
      if object != nil
        @text.gsub!(/\\N\[起動条件オブジェクト\]/i) { object.name }
      end
    end
    tig_eto_convert_special_characters
  end
end

#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item < Scene_Base
  #--------------------------------------------------------------------------
  # ◎ アイテムの決定
  #--------------------------------------------------------------------------
  alias tig_eto_determine_item determine_item
  def determine_item
    if $game_player.check_event_trigger_object(@item.id)
      $scene = Scene_Map.new
      return
    end
    tig_eto_determine_item
  end
end

#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　スキル画面の処理を行うクラスです。
#==============================================================================

class Scene_Skill < Scene_Base
  #--------------------------------------------------------------------------
  # ◎ スキルの決定
  #--------------------------------------------------------------------------
  alias tig_eto_determine_skill determine_skill
  def determine_skill
    id = 1000 + @skill.id 
    if $game_player.check_event_trigger_object(id)
      $game_party.use_skill = @skill
      $game_party.skill_user = @actor
      $scene = Scene_Map.new
      return
    end
    tig_eto_determine_skill
  end
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 起動条件アイテムタイプ取得
  #--------------------------------------------------------------------------
  def event_trigger_type
    if /起動条件[<＜]type[:：](\S+)[>＞]/ =~ self.note
      return $1
    else
      return ""
    end
  end
end