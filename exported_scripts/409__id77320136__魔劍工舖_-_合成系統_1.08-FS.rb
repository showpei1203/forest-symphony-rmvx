#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：魔劍工舖 - 合成系統 1.08-FS
# 【用途】保留的 Runtime 元件「魔劍工舖 - 合成系統 1.08-FS」。
# 【主要機制】主要定義／擴充 Game_Party、WSword_Synthesize、WSword_SynthesizeONOFF、WSword_SynthesizeState；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Party、WSword_Synthesize、WSword_SynthesizeONOFF、WSword_SynthesizeState、Sword_Synthesize、Sword
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Audio/SE/#{se.name}、Audio/SE/#{Sword4_SE}。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
module Sword

#=======================================

#★ 魔劍工舖 - 合成系統 1.08-FS

# http://blog.yam.com/a870053jjkj/

#=======================================

  Sword4_Message, Sword4_Help, Sword4_Synthesize = [], [], [[], [], []]

#=======================================

=begin

● 設置方法

呼叫方法(全部)：$scene = Sword_Synthesize.new

呼叫方法(物品)：$scene = Sword_Synthesize.new(0)

呼叫方法(武器)：$scene = Sword_Synthesize.new(1)

呼叫方法(防具)：$scene = Sword_Synthesize.new(2)

習得公開：$game_party.sword_synthesize[種類][編號] = true

習得隱藏：$game_party.sword_synthesize[種類][編號] = false

遺忘合成：$game_party.sword_synthesize[種類][編號] = nil

全部公開：$game_party.sword_synthesize(true)

全部隱藏：$game_party.sword_synthesize(false)

全部遺忘：$game_party.sword_synthesize(nil)

機率加乘變量：$game_party.synthesize_multiply[種類][編號]

=end

#=======================================

#● 使用者自定設置

Sword4_Width = 180 # 設定合成選項的寬度，相對的合成內容寬度也會更動

Sword4_NoCommand = '？？？？？' # 習得卻未合成過的選項文字，''表示道具名稱

Sword4_Whether = '是否要消耗材料並合成道具？' # 合成提示文字，''為不提示

Sword4_Wait1 = 30 # 設定合成中的等待時間，每40約為1秒

Sword4_Wait2 = 30 # 設定成功或完成的訊息等待時間，每40約為1秒

Sword4_Roll = 3 # 設定材料5個以上時，滾動效果的速度

Sword4_Probability1 = 1 # 設定增加成功率的合成結果，0為失敗；1為成功；2是都可

Sword4_Probability2 = 1 # 設定每合成增加成功機率的數值，因Sword4_Probability1而定

Sword4_SE = 49 # 開始合成時演奏SE檔名或動畫編號，''或0為不演奏

Sword4_Picture = 115 # 當習得未合成時的圖示，XP用字串、VX用數值

Sword4_Menu = 0 # 關閉合成返回設定，0為地圖；1以上選單，並指著指定的選項

#--------------------------------------------------------------

#○ 合成提示窗口設定

# Sword4_Message[不必更改] = [紅, 綠, 藍, '文字內容']

Sword4_Message[0] = [255, 255, 255, '開始合成中...'] # 正在合成中

Sword4_Message[1] = [255, 0, 0, '合成失敗']# 合成失敗

Sword4_Message[2] = [255, 255, 0, '合成成功']# 合成成功

Sword4_Message[3] = [255, 0, 0, '材料不足'] # 材料不足

#--------------------------------------------------------------

#○ 說明窗口顯示設定

# Sword4_Help[不必更改] = ['文字內容', 靠邊位置]

# 靠邊位置：0為靠左邊顯示、1為中央顯示、2為靠右邊顯示

Sword4_Help[0] = ['合成系統', 1] # 顯示所有物品、武器、防具時

Sword4_Help[1] = ['物品合成', 0] # 只顯示物品時

Sword4_Help[2] = ['武器合成', 0] # 只顯示武器時

Sword4_Help[3] = ['\IC[3504]祭壇', 0] # 只顯示防具時

#--------------------------------------------------------------

#○ 合成資料表

# Sword4_Synthesize[合成種類][合成編號] = [{物品}, {武器}, {防具}, 成功率, 金錢]

# 合成種類：0為物品、1為武器、2為防具

# 物品、武器、防具：「編號=>數量」，每個相同種類材料必須用小逗號分開

Sword4_Synthesize[0][2] = [{52=>1, 1=>5,2=>5,3=>5,4=>5,5=>5}, {}, {}, 100]

Sword4_Synthesize[0][6] = [{4=>5, 5=>2}, {}, {}, 80]

Sword4_Synthesize[0][1] = [{1=>10}, {}, {}, 100]

Sword4_Synthesize[1][4] = [{}, {1=>3}, {}, 70]

Sword4_Synthesize[1][8] = [{}, {5=>2, 6=>8}, {4=>1}, 70]

Sword4_Synthesize[2][102] = [{153=>1}, {}, {101=>1}, 100]#變異絨毛

Sword4_Synthesize[2][103] = [{155=>1}, {}, {101=>1,102=>2},  90]#巨大絨毛

Sword4_Synthesize[2][106] = [{156=>1}, {}, {105=>1}, 100]#毒蟲

Sword4_Synthesize[2][107] = [{153=>1}, {}, {105=>3},  90]#大力蟲

Sword4_Synthesize[2][108] = [{153=>1}, {}, {101=>1,105=>1},  90]#巨型刺蝟

Sword4_Synthesize[2][109] = [{156=>2}, {}, {108=>1,106=>1},  90]#魔刺蝟

Sword4_Synthesize[2][110] = [{111=>1,155=>3}, {}, {103=>3,107=>3,109=>1},  80]#厚毛牛

Sword4_Synthesize[2][115] = [{112=>1,153=>3}, {}, {111=>2,112=>2,113=>2,114=>2,117=>2},  80]#巨食人花

Sword4_Synthesize[2][120] = [{153=>1}, {}, {119=>1},  100]#憤怒史萊姆

Sword4_Synthesize[2][121] = [{157=>1}, {}, {119=>1},  100]#變異史萊姆

Sword4_Synthesize[2][122] = [{154=>2}, {}, {119=>4,120=>2,121=>2},   80]#史萊姆頭目

Sword4_Synthesize[2][123] = [{113=>1,153=>2}, {}, {120=>4,122=>2},   60]#史萊姆酋長

Sword4_Synthesize[2][129] = [{156=>1}, {}, {126=>2,127=>2,128=>2},   80]#牧菇者

Sword4_Synthesize[2][130] = [{113=>1}, {}, {126=>2,127=>2,128=>2,129=>1},   60]#生態圈

Sword4_Synthesize[2][132] = [{154=>1}, {}, {131=>6},  100]#巨蠍









#=======================================

  #--------------------------------------------------------------------------
  # ● FS擴充：取得配方金錢代價（舊四欄配方自動視為0G）
  #--------------------------------------------------------------------------
  def self.sword4_gold_cost(recipe)
    return 0 if recipe == nil || recipe[4] == nil
    return [recipe[4].to_i, 0].max
  end

  $Sword ? $Sword[4] = true : $Sword = {4=>true} # 腳本使用標誌

  ($Sword_VX = false ; RPG::Weather rescue $Sword_VX = true) if $Sword_VX == nil

end

#=======================================

#■ 處理同伴的類別

class Game_Party

  include Sword

  attr_writer    :sword_synthesize # 合成狀態數據

  attr_accessor :synthesize_multiply # 機率加乘數值

  #-------------------------------------------------------------

  #● 初始化物件

  alias sword4_initialize initialize

  def initialize

    sword4_initialize

    @sword_synthesize = [Array.new($data_items.size + 1){nil}, 

    Array.new($data_weapons.size + 1){nil}, Array.new($data_armors.size + 1){nil}]

    @synthesize_multiply = [Array.new($data_items.size + 1){0}, 

    Array.new($data_weapons.size + 1){0}, Array.new($data_armors.size + 1){0}]

  end

  #-------------------------------------------------------------

  #● 讀取與全部修改的方法

  def sword_synthesize(number = 0)

    return @sword_synthesize if number == 0 # 傳回值

    (0..2).each{|i| (1...Sword4_Synthesize[i].size).each{|ii|

    next unless Sword4_Synthesize[i][ii] ; @sword_synthesize[i][ii] = number}}

  end

end

#=======================================

#■ 合成系統窗口

class WSword_Synthesize < Window_Base

  include Sword

  attr_accessor :max_oy  # 目前位圖Y座標

  #-------------------------------------------------------------

  #● 初始化物件

  def initialize

    @xpvx = $Sword_VX ? [Graphics.width, Graphics.height, WLH + 32] : [640, 480, 64] 

    super(Sword4_Width, @xpvx[2], @xpvx[0] - Sword4_Width, @xpvx[1] - @xpvx[2])

    self.contents = Bitmap.new(1, 1) ; refresh

  end

  #-------------------------------------------------------------

  #● 更新內容(成品資料)

  def refresh(itema = nil)

    self.contents.clear ; return unless itema # 清除窗口內容

    case itema[0] # 道具種類分歧

    when 0 ; item = $data_items[itema[1]] # 物品

      # [HP恢復量, SP(MP)恢復量, X, X, HP恢復率, SP(MP)恢復率, X]

      words = $Sword_VX ? [$data_system.terms.hp + '恢復量', 

      $data_system.terms.mp + '恢復量', '', '', $data_system.terms.hp + '恢復率', 

      $data_system.terms.mp + '恢復率', ''] : [$data_system.words.hp + '恢復量', 

      $data_system.words.sp + '恢復量', '', '', $data_system.words.hp + '恢復率', 

      $data_system.words.sp + '恢復率', '']

      if $game_party.sword_synthesize[0][itema[1]] # 公開顯示的情況

        amounts = $Sword_VX ? [item.hp_recovery.to_s, item.mp_recovery.to_s, '', '', 

        item.hp_recovery_rate.to_s, item.mp_recovery_rate.to_s, ''] : [item.recover_hp.to_s, 

        item.recover_sp.to_s, '', '', item.recover_hp_rate.to_s, item.recover_sp_rate.to_s, '']

        if item.parameter_type > 0 # 有設定增加能力值的場合

          words[3] = ($Sword_VX ? [$data_system.terms.hp, $data_system.terms.mp, 

          $data_system.terms.atk, $data_system.terms.def, $data_system.terms.spi, 

          $data_system.terms.agi] : [$data_system.words.hp, $data_system.words.sp, 

          $data_system.words.str, $data_system.words.dex, $data_system.words.agi, 

          $data_system.words.int])[item.parameter_type - 1] + '上限'

          amounts[3] = item.parameter_points.to_s

        end

      else ; amounts = ['??', '??', '', '', '??', '??', ''] # 未公開的場合

      end

      number = $Sword_VX ? $game_party.item_number(item) : 

      $game_party.item_number(item.id) # 持有數量

    when 1 ; item = $data_weapons[itema[1]] # 武器

      # [攻擊, 物防(防禦), 魔防(X), 力量(命中), 靈巧(精神), 速度(敏捷), 魔力(X)]

      words = $Sword_VX ? [$data_system.terms.atk, $data_system.terms.def, '', '命中率', 

      $data_system.terms.spi, $data_system.terms.agi, ''] : [$data_system.words.atk, 

      $data_system.words.pdef, $data_system.words.mdef, $data_system.words.str, 

      $data_system.words.dex, $data_system.words.agi, $data_system.words.int]

      if $game_party.sword_synthesize[1][itema[1]] # 公開顯示的情況

        amounts = $Sword_VX ? [item.atk.to_s, item.def.to_s, '', item.hit.to_s + '%', item.spi.to_s, 

        item.agi.to_s, ''] : [item.atk.to_s, item.pdef.to_s, item.mdef.to_s, item.str_plus.to_s, 

        item.dex_plus.to_s, item.agi_plus.to_s, item.int_plus.to_s]

      else ; amounts = ['??'] * 7 # 未公開的場合

      end

      number = $Sword_VX ? $game_party.item_number(item) : 

      $game_party.weapon_number(item.id) # 持有數量

    when 2 ; item = $data_armors[itema[1]] # 防具

   #    [物防(攻擊), 魔防(防禦), 迴避(X), 力量(迴避), 靈巧(精神), 速度(敏捷), 魔力(X)]

      words = $Sword_VX ? [$data_system.terms.atk, $data_system.terms.def, '', '回避率',

      $data_system.terms.spi, $data_system.terms.agi, ''] : [$data_system.words.pdef,

      $data_system.words.mdef, '回避', $data_system.words.str, $data_system.words.dex, 

      $data_system.words.agi, $data_system.words.int]

      if $game_party.sword_synthesize[2][itema[1]] # 公開顯示的情況

        amounts = $Sword_VX ? [item.atk.to_s, item.def.to_s, '', item.eva.to_s + '%', 

        item.spi.to_s, item.agi.to_s, ''] : [item.pdef.to_s, item.mdef.to_s, item.eva.to_s, 

        item.str_plus.to_s, item.dex_plus.to_s, item.agi_plus.to_s, item.int_plus.to_s]

      else ; amounts = ['??'] * 7 # 未公開的場合

      end

      number = $Sword_VX ? $game_party.item_number(item) : 

      $game_party.armor_number(item.id) # 持有數量

    end

    by, y, x, self.oy = 8, 32, Font.default_size * 5, 0 # 位圖行, 描繪Y, 描繪X, 起始位置

    by += self.contents.text_size($game_party.sword_synthesize[itema[0]][itema[1]] ? 

    item.description : '？？？？？？？？？？？？').width / (self.width - 32) # 說明換行

    (0..2).each{|i| by += Sword4_Synthesize[itema[0]][itema[1]][i].size} rescue

raise("合成資料不存在，Sword4_Synthesize[#{itema[0]}][#{itema[1]}]未設置") # Error

    by += 1 if Sword.sword4_gold_cost(Sword4_Synthesize[itema[0]][itema[1]]) > 0

    by -= 1 if $Sword_VX or itema[0] == 0

    self.contents = Bitmap.new(self.width - 32, by * 32) # 重新產生位圖

    @max_oy = [by * 32 - (@xpvx[1] - @xpvx[2]) + 32, 0].max # 滾動限制

    self.contents.font.color = normal_color # 數值和內容

    if $game_party.sword_synthesize[itema[0]][itema[1]] # 公開顯示的情況

      $Sword_VX ? draw_icon(item.icon_index, 0, 0, true) : # 圖標

      contents.blt(0, 0, RPG::Cache.icon(item.icon_name), Rect.new(0 , 0, 24, 24))

      contents.draw_text(28, 0, 640, 32, item.name) # 名稱

      contents.draw_text(0, 0, self.width - 40, 32, number.to_s, 2) # 持有數

      xx = 0

      item.description.scan(/./).each{|c| cx = self.contents.text_size(c).width

      (xx = 0 ; y += 32) if xx + cx > self.width - 32

      contents.draw_text(xx, y, cx, 32, c) ; xx += cx}  # 說明

    else # 隱藏顯示的場合

      $Sword_VX ? draw_icon(Sword4_Picture, 0, 0, true) : # 圖標

      contents.blt(0, 0, RPG::Cache.icon(Sword4_Picture), Rect.new(0 , 0, 24, 24))

      contents.draw_text(28, 0, 640, 32, Sword4_NoCommand.empty? ? 

      item.name : Sword4_NoCommand) # 名稱

      contents.draw_text(0, 0, self.width - 40, 32, '??', 2) # 持有數

      contents.draw_text(0, 32, 640, 32, '？？？？？？？？？？？？') # 說明

    end

    probability = [[Sword4_Synthesize[itema[0]][itema[1]][3] + 

    $game_party.synthesize_multiply[itema[0]][itema[1]], 100].min, 0].max.to_s + '%'

    contents.draw_text(x, y + 32, 640, 32, probability) # 成功率
    gold_cost = Sword.sword4_gold_cost(Sword4_Synthesize[itema[0]][itema[1]])
    if gold_cost > 0
      self.contents.font.color = $game_party.gold >= gold_cost ? normal_color : Color.new(255, 64, 0)
      contents.draw_text(x, y + 64, 640, 32, gold_cost.to_s + Vocab.gold)
      self.contents.font.color = normal_color
    end

    #contents.draw_text(x, y + 64, 640, 32, amounts[0])

    #contents.draw_text(x, y + 96, 640, 32, amounts[1])

    #contents.draw_text(x, y + 128, 640, 32, amounts[2])

    #contents.draw_text(self.width / 2 + x, y + 32, 640, 32, amounts[3])

    #contents.draw_text(self.width / 2 + x, y + 64, 640, 32, amounts[4])

    #contents.draw_text(self.width / 2 + x, y + 96, 640, 32, amounts[5])

    #contents.draw_text(self.width / 2 + x, y + 128, 640, 32, amounts[6])

    sequence, yy = [Sword4_Synthesize[itema[0]][itema[1]][0].keys.sort, 

    Sword4_Synthesize[itema[0]][itema[1]][1].keys.sort, 

    Sword4_Synthesize[itema[0]][itema[1]][2].keys.sort], 8 + y / 32

    yyy = 7 ; (yy -= 1 ; yyy = 6) if $Sword_VX or itema[0] == 0###yyy = 7

    (0...sequence.size).each{|i| sequence[i].each{|ii| 

    stuff(i, ii, itema[1], yy-4, itema[0]) ; yy += 1}}####改YY

    self.contents.font.color = system_color # 用語

    contents.draw_text(0, 0, self.width - 64, 32, '持有數：', 2)

    contents.draw_text(0, y + 32, 640, 32, '成功率')
    contents.draw_text(0, y + 64, 640, 32, '製作費') if gold_cost > 0

    #contents.draw_text(0, y + 64, 640, 32, words[0])

    #contents.draw_text(0, y + 96, 640, 32, words[1])

    #contents.draw_text(0, y + 128, 640, 32, words[2])

    #contents.draw_text(self.width / 2, y + 32, 640, 32, words[3])

    #contents.draw_text(self.width / 2, y + 64, 640, 32, words[4])

    #contents.draw_text(self.width / 2, y + 96, 640, 32, words[5])

    #contents.draw_text(self.width / 2, y + 128, 640, 32, words[6])

    #contents.draw_text(0, (yyy + y / 32) * 32, 640, 32, '所需道具')

    #contents.draw_text(0, (yyy + y / 32) * 32, self.width - 138, 32, '持有數', 2)

    #contents.draw_text(0, (yyy + y / 32) * 32, self.width - 42, 32, '所需數', 2)

    (0..7).each do |i| # 產生「：」

      next if i == 3 or i == 7 if $Sword_VX

      next if [3, (item.parameter_type > 0 and $game_party.sword_synthesize[0][itema[1]]) ? 

      nil : 4, 7].include?(i) if itema[0] == 0 # 物品的場合，忽略不必描繪的部份

      if i > 3 ; i -= 4

     #   contents.draw_text(self.width / 2 + Font.default_size * 4, 32 * i + 32 + y, 640, 32, '：')

     # else ; contents.draw_text(Font.default_size * 4, 32 * i + 32 + y, 640, 32, '：')

      end

    end

  end

  #-------------------------------------------------------------

  #● 所需材料的內容

  def stuff(kind, i, item, y, kind2)

    # 所需數

    Sword4_Synthesize[kind2][item][kind][i] > 9 ? 

    a = 64 : a = 69

    #######

    self.contents.draw_text(0, y * 32, @xpvx[0] - Sword4_Width - a, 32, 

    Sword4_Synthesize[kind2][item][kind][i].to_s, 2)

    # 圖示與持有數

    case kind

    when 0 # 物品(材料)

      if $Sword_VX

        draw_icon($data_items[i].icon_index, 0, y * 32, true)

        items = $game_party.item_number($data_items[i])

      else

        self.contents.blt(0, y * 32, RPG::Cache.icon(

        $data_items[i].icon_name), Rect.new(0 , 0, 24, 24))

        items = $game_party.item_number(i)

      end

      items >= Sword4_Synthesize[kind2][item][0][i] ?

      color = normal_color : color = Color.new(255, 64, 0)

      self.contents.draw_text(28, y * 32, 640, 32, $data_items[i].name)

      # 持有數

      self.contents.font.color = color

      items > 9 ? a = 160 : a = 165

      self.contents.draw_text(0, y * 32, 

      @xpvx[0] - Sword4_Width - a, 32, items.to_s, 2)

      self.contents.font.color = normal_color

    when 1 # 武器(材料)

      if $Sword_VX

        weapon = $game_party.item_number($data_weapons[i])

        draw_icon($data_weapons[i].icon_index, 0, y * 32, true)

      else

        weapon = $game_party.weapon_number(i)

        self.contents.blt(0, y * 32, RPG::Cache.icon(

        $data_weapons[i].icon_name), Rect.new(0 , 0, 24, 24))

      end

      weapon >= Sword4_Synthesize[kind2][item][1][i] ?

      color = normal_color : color = Color.new(255, 64, 0)

      self.contents.draw_text(28, y * 32, 640, 32, $data_weapons[i].name)

      # 持有數

      self.contents.font.color = color

      weapon > 9 ? a = 160 : a = 165

      self.contents.draw_text(0, y * 32, 

      @xpvx[0] - Sword4_Width - a, 32, weapon.to_s, 2)

      self.contents.font.color = normal_color

    when 2 # 防具(材料)

      if $Sword_VX

        draw_icon($data_armors[i].icon_index, 0, y * 32, true)

        armors = $game_party.item_number($data_armors[i])

      else

        self.contents.blt(0, y * 32, RPG::Cache.icon(

        $data_armors[i].icon_name), Rect.new(0 , 0, 24, 24))

        armors = $game_party.armor_number(i)

      end

      armors >= Sword4_Synthesize[kind2][item][2][i] ?

      color = normal_color : color = Color.new(255, 64, 0)

      self.contents.draw_text(28, y * 32, 640, 32, $data_armors[i].name)

      # 持有數

      self.contents.font.color = color

      armors > 9 ? a = 160 : a = 165

      self.contents.draw_text(0, y * 32, 

      @xpvx[0] - Sword4_Width - a, 32, armors.to_s, 2)

      self.contents.font.color = normal_color

    end

  end

end

#=======================================

#■ 是否合成提示窗口

class WSword_SynthesizeONOFF < Window_Base

  include Sword # 連接自定設置

  attr_accessor  :index # 游標位置

  #-------------------------------------------------------------

  #● 初始化物件

  def initialize

    @xpvx = $Sword_VX ? [Graphics.width, Graphics.height] : [640, 480]

    contents = Bitmap.new(@xpvx[0], 32)

    @width = contents.text_size(Sword4_Whether).width

    @width = 32 if @width  == 0

    super((@xpvx[0] - @width) / 2 - 32, (@xpvx[1] - (Font.default_size + 10)*4)/2, 

    @width + 32, (Font.default_size + 10) * 4)

    self.contents = Bitmap.new(width - 32, height - 32)

    self.z, @index = 400, 1

    refresh

  end

  #-------------------------------------------------------------

  #● 更新內容

  def refresh

    self.contents.draw_text(0, 0, 640, 32, Sword4_Whether)

    self.contents.draw_text(0, 32, @width, 32, '是', 1)

    self.contents.draw_text(0, 64, @width, 32, '否', 1)

    self.cursor_rect.set(@width / 2 - (Font.default_size * 5 / 2), 

    @index * 32 + 32, Font.default_size * 5, 32)

  end

  #-------------------------------------------------------------

  #● 更新游標

  def update_cursor_rect

    $Sword_VX ? Sound.play_cursor : $game_system.se_play($data_system.cursor_se)

    @index == 0 ? @index = 1 : @index = 0

    self.cursor_rect.set(@width / 2 - (Font.default_size * 5 / 2), 

    @index * 32 + 32, Font.default_size * 5, 32)

  end

end

#=======================================

#■ 合成狀況窗口

class WSword_SynthesizeState < Window_Base

  include Sword # 連接自定設置

  #-------------------------------------------------------------

  #● 初始化物件

  def initialize

    @xpvx = $Sword_VX ? [Graphics.width, Graphics.height] : [640, 480]

    super(0, (@xpvx[1] - Font.default_size + 10) / 2 - 32, 64, Font.default_size + 42)

    self.contents = Bitmap.new(width - 32, height - 32)

    self.z = 410

    refresh

  end

  #-------------------------------------------------------------

  #● 更新內容

  def refresh(help = nil, color = nil)

    return if help == nil

    self.contents.clear

    self.x = (@xpvx[0] - contents.text_size(help).width) / 2 - 32

    self.width = contents.text_size(help).width + 32

    self.contents = Bitmap.new(self.width - 32, self.height - 32)

    self.contents.font.color = color

    self.contents.draw_text(0, 0, self.width, 32, help)

  end

end

#=======================================

#■ 合成系統畫面

class Sword_Synthesize

  include Sword # 連接自定設置

  #-------------------------------------------------------------

  #● 初始化物件

  def initialize(item = nil) ; @item = item ; end

  #-------------------------------------------------------------

  #● 主處理

  def main

    @help_window = Window_Help.new # 產生幫助窗口

    @help_window.opacity=255

    a = @item == nil ? Sword4_Help[0][0] : Sword4_Help[@item + 1][0]

    b = @item == nil ? Sword4_Help[0][1] : Sword4_Help[@item + 1][1]

    @help_window.set_text(a, b)

    @synthesizestate_wsword = WSword_SynthesizeState.new # 產生合成狀態窗口

    @synthesizestate_wsword.visible = false

    command

    @synthesize_wsword = WSword_Synthesize.new # 產生合成內容窗口

    @synthesize_wsword.refresh(@command[1][@command_window.index])

    @synthesizeonoff_wsword = WSword_SynthesizeONOFF.new

    @synthesizeonoff_wsword.active = false

    @synthesizeonoff_wsword.visible = false

    Graphics.transition

    loop{Graphics.update ; Input.update ; update ; break if $scene != self}

    Graphics.freeze

    @help_window.dispose ; @command_window.dispose ; @synthesize_wsword.dispose

    @synthesizeonoff_wsword.dispose ; @synthesizestate_wsword.dispose

  end

  #-------------------------------------------------------------

  #● 更新

  def update

    @command_window.update ; @synthesizeonoff_wsword.update

    if @command_window.active #○ 當選項窗口活動時

      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN) # 更新合成內容

        @synthesize_wsword.refresh(@command[1][@command_window.index])

      elsif Input.press?(Input::LEFT) and @synthesize_wsword.oy > 0 # 向下滾動內容

        return if @command[1].empty?

        @synthesize_wsword.oy -= Sword4_Roll

        @synthesize_wsword.oy = 0 if @synthesize_wsword.oy < 0

      elsif Input.press?(Input::RIGHT) # 向上滾動內容

        return if @command[1].empty?

        if @synthesize_wsword.oy < @synthesize_wsword.max_oy

          @synthesize_wsword.oy += Sword4_Roll

          @synthesize_wsword.oy = @synthesize_wsword.max_oy if 

          @synthesize_wsword.oy > @synthesize_wsword.max_oy

        end

      elsif Input.repeat?(Input::B) # 回到地圖

        $Sword_VX ? Sound.play_cancel : $game_system.se_play($data_system.cancel_se)

        $scene = Sword4_Menu > 0 ? Scene_Menu.new(Sword4_Menu - 1) : Scene_Map.new

      elsif Input.repeat?(Input::C) # 合成物品

        # 無法合成的場合

        if @command[1][@command_window.index] == false or @no

          $Sword_VX ? Sound.play_buzzer : $game_system.se_play($data_system.buzzer_se)

          return

        end

        # 開始合成

        success  = true # 用來記錄是否可合成

        a = @command[1][@command_window.index]

        eval("a = Sword4_Synthesize[#{a[0]}][#{a[1]}]")

        # 判斷是否有足夠的材料

        for i in 0..2

          for ii in a[i]

            if $Sword_VX

              success = $game_party.item_number($data_items[ii[0]]) >= ii[1] if i == 0

              success = $game_party.item_number($data_weapons[ii[0]]) >= ii[1] if i == 1

              success = $game_party.item_number($data_armors[ii[0]]) >= ii[1] if i == 2

            else

              success = $game_party.item_number(ii[0]) >= ii[1] if i == 0

              success = $game_party.weapon_number(ii[0]) >= ii[1] if i == 1

              success = $game_party.armor_number(ii[0]) >= ii[1] if i == 2

            end

            # 當其中1個材料不符合的情況

            unless success

              $Sword_VX ? Sound.play_buzzer : $game_system.se_play($data_system.buzzer_se) 

              unless Sword4_Message[3][3] == '' # 沒設定訊息的情況下

                color = Sword4_Message[3]

                @synthesizestate_wsword.visible = true

                @synthesizestate_wsword.refresh(

                Sword4_Message[3][3], Color.new(color[0], color[1], color[2]))

                for i in 1..Sword4_Wait2

                  @command_window.update

                  @synthesizeonoff_wsword.update

                  Graphics.update

                end

                @synthesizestate_wsword.visible = false

              end

              return

            end

          end

        end

        gold_cost = Sword.sword4_gold_cost(a)
        if $game_party.gold < gold_cost
          $Sword_VX ? Sound.play_buzzer : $game_system.se_play($data_system.buzzer_se)
          color = Sword4_Message[3]
          @synthesizestate_wsword.visible = true
          @synthesizestate_wsword.refresh(
            "金錢不足（需要" + gold_cost.to_s + Vocab.gold + "）",
            Color.new(color[0], color[1], color[2]))
          for i in 1..Sword4_Wait2
            @command_window.update
            @synthesizeonoff_wsword.update
            Graphics.update
          end
          @synthesizestate_wsword.visible = false
          return
        end

        # 開始活動是否合成選項窗口，不需提示就跳過

        @synthesizeonoff_wsword.active = true

        unless Sword4_Whether == ''

          @synthesizeonoff_wsword.update_cursor_rect if @synthesizeonoff_wsword.index == 0

          $Sword_VX ? Sound.play_decision : $game_system.se_play($data_system.decision_se)

          @synthesizeonoff_wsword.visible = true

          @command_window.active = false

        end

        return

      end

    end

    #○ 當是否合成選項窗口活動時

    if @synthesizeonoff_wsword.active

      if Input.repeat?(Input::C) or Sword4_Whether == ''

        @synthesizeonoff_wsword.index = 0 if Sword4_Whether == ''

        if @synthesizeonoff_wsword.index == 0

          # 合成開始，開始消耗材料

          ac = @command[1][@command_window.index] ; a = nil ; multiply = nil

          eval("multiply = $game_party.synthesize_multiply[#{ac[0]}][#{ac[1]}]

          a = Sword4_Synthesize[#{ac[0]}][#{ac[1]}]")

          (0..2).each do |i| a[i].each do |ii|

            if $Sword_VX

              items = $game_party.item_number($data_items[ii[0]])

              weapons = $game_party.item_number($data_weapons[ii[0]])

              armors = $game_party.item_number($data_armors[ii[0]])

              if items >= ii[1] and i == 0 ; $game_party.lose_item($data_items[ii[0]], ii[1])

              elsif weapons >= ii[1] and i == 1 ; $game_party.lose_item($data_weapons[ii[0]], ii[1])

              elsif armors >= ii[1] and i == 2 ; $game_party.lose_item($data_armors[ii[0]], ii[1])

              end

            else

              items = $game_party.item_number(ii[0])

              weapons = $game_party.weapon_number(ii[0])

              armors = $game_party.armor_number(ii[0])

              if items >= ii[1] and i == 0 ; $game_party.lose_item(ii[0], ii[1])

              elsif weapons >= ii[1] and i == 1 ; $game_party.lose_weapon(ii[0], ii[1])

              elsif armors >= ii[1] and i == 2 ; $game_party.lose_armor(ii[0], ii[1])

              end

            end

          end ; end

          gold_cost = Sword.sword4_gold_cost(a)
          $game_party.lose_gold(gold_cost) if gold_cost > 0

          # 結束活動是否合成選項窗口

          @synthesizeonoff_wsword.visible = false

          @synthesizeonoff_wsword.active = false

          @command_window.active = true

          # 顯示合成狀態

          unless Sword4_Message[0][3] == ''

            @synthesizestate_wsword.visible = true

            color = Sword4_Message[0]

            @synthesizestate_wsword.refresh(

            Sword4_Message[0][3], Color.new(color[0], color[1], color[2]))

          end

          # 演奏合成SE

          if Sword4_SE == '' or Sword4_SE == 0 ; 0 # 不演奏SE

          elsif Sword4_SE.is_a?(Integer) # 指定動畫SE

            searr = []

            (0...$data_animations[Sword4_SE].timings.size).each{|i|

            searr.push($data_animations[Sword4_SE].timings[i].frame)}

            (0...$data_animations[Sword4_SE].frame_max).each do |i|

              tim = $Sword_VX ? 3 : 2

              tim.times {@command_window.update ; @synthesizeonoff_wsword.update 

              Graphics.update} # 更新畫面與窗口

              ii = searr.index(i)

              next unless ii

              se = $data_animations[Sword4_SE].timings[ii].se

              next if se.name == ''

              Audio.se_play("Audio/SE/#{se.name}", se.volume, se.pitch)

            end

          elsif Sword4_SE.is_a?(String) ; Audio.se_play("Audio/SE/#{Sword4_SE}") # 指定SE

          end

          (1..Sword4_Wait1).each do |i| # 合成延遲時間

            break if Sword4_SE.is_a?(Integer)

            @command_window.update

            @synthesizeonoff_wsword.update

            Graphics.update

          end

          # 是否合成成功

          @synthesizestate_wsword.visible = false

          if a[3] + multiply > rand(100) # 計算合成機率與合成成功時的場合

            eval("$game_party.synthesize_multiply[#{ac[0]}][#{ac[1]}] += 

            #{Sword4_Probability2}") if [1, 2].include?(Sword4_Probability1)

            unless Sword4_Message[2][3] == ''

              color = Sword4_Message[2]

              @synthesizestate_wsword.visible = true

              @synthesizestate_wsword.refresh(

              Sword4_Message[2][3], Color.new(color[0], color[1], color[2]))

            end

            a = @command[1][@command_window.index]

            # 如果是未合成物品，切換到已合成過

            unless $game_party.sword_synthesize[a[0]][a[1]]

              $game_party.sword_synthesize[a[0]][a[1]] = true

              command(@command_window.index)

            end

            # 獲取合成的物品

            if $Sword_VX

              b = @command[1][@command_window.index][1]

              case @command[1][@command_window.index][0] # 依道具種類決定執行內容

              when 0 ; $game_party.gain_item($data_items[b], 1)

              when 1 ; $game_party.gain_item($data_weapons[b], 1)

              when 2 ; $game_party.gain_item($data_armors[b], 1)

              end

            else

              case @command[1][@command_window.index][0]

              when 0; $game_party.gain_item(@command[1][@command_window.index][1], 1)

              when 1;$game_party.gain_weapon(@command[1][@command_window.index][1],1)

              when 2; $game_party.gain_armor(@command[1][@command_window.index][1],1)

              end

            end

          else # 合成失敗時

            eval("$game_party.synthesize_multiply[#{ac[0]}][#{ac[1]}] += 

            #{Sword4_Probability2}") if [0, 2].include?(Sword4_Probability1)

            unless Sword4_Message[1][3] == ''

              color = Sword4_Message[1]

              @synthesizestate_wsword.visible = true 

              @synthesizestate_wsword.refresh(

              Sword4_Message[1][3], Color.new(color[0], color[1], color[2]))

            end

          end

          @synthesize_wsword.refresh(@command[1][@command_window.index])

          # 合成訊息時間

          for i in 1..Sword4_Wait2

            break if Sword4_Message[0][3] == ''

            break if Sword4_Message[1][3] == ''

            break if Sword4_Message[2][3] == ''

            @command_window.update

            @synthesizeonoff_wsword.update

            Graphics.update

          end

        else # 選擇否的情況

          $Sword_VX ? Sound.play_cancel : $game_system.se_play($data_system.cancel_se)

        end

        # 結束活動是否合成選項窗口

        @synthesizeonoff_wsword.visible = false

        @synthesizeonoff_wsword.active = false

        @command_window.active = true

        @synthesizestate_wsword.visible = false

      elsif Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN) # 更新游標

        @synthesizeonoff_wsword.update_cursor_rect

      end

    end

  end

  #-------------------------------------------------------------

  #● 選項的方法

  def command(index = 0)

    @command_window.dispose if @command_window # 該窗口存在就釋放該窗口

    @command = [[], []] # [[道具名稱數組], [道具類型與編號數組]]

    # 設定選項文字

    for i in 0..2

      next unless @item == i unless @item == nil # 不符合顯示標準移到下次

      for ii in 1...$game_party.sword_synthesize[i].size

        if $game_party.sword_synthesize[i][ii]

          case i # 依照道具種類決定執行內容

          when 0 ; @command[0].push($data_items[ii].name) ; @command[1].push([0, ii])

          when 1 ; @command[0].push($data_weapons[ii].name) ; @command[1].push([1, ii])

          when 2 ; @command[0].push($data_armors[ii].name) ; @command[1].push([2, ii])

          end

        elsif $game_party.sword_synthesize[i][ii] == false

          if Sword4_NoCommand == '' # 未合成過的道具用該道具名稱

            case i # 依照道具種類決定執行內容

            when 0 ; @command[0].push($data_items[ii].name)

            when 1 ; @command[0].push($data_weapons[ii].name)

            when 2 ; @command[0].push($data_armors[ii].name)

            end

          else ; @command[0].push(Sword4_NoCommand) # 直接指定未合過的選項文字

          end

          case i # 依照道具種類決定執行內容

          when 0 ; @command[1].push([0, ii, false])

          when 1 ; @command[1].push([1, ii, false])

          when 2 ; @command[1].push([2, ii, false])

          end

        end

      end

    end

    @no = true if @command[0].empty?

    @command[0] = [' '] if @command[0].empty?

    # 產生選項窗口

    @command_window = Window_Command.new(Sword4_Width, @command[0])

    if $Sword_VX ; @command_window.y = 56 ; @command_window.height = 360

    else ; @command_window.y = 64 ; @command_window.height = 416

    end

    @command_window.index = index

    # 無效的顏色

    (0...@command[1].size).each{|i|

    if $Sword_VX ; @command_window.draw_item(i, false) if @command[1][i][2] == false

    else ; @command_window.disable_item(i) if @command[1][i][2] == false

    end}

  end

end

