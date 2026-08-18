#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：好玩寶箱系統
# 【用途】保留的 Runtime 元件「好玩寶箱系統」。
# 【主要機制】主要定義／擴充 Scene_Coffre、Scene_Coffre_bis、Window_Detection、Perso_Detection；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_Coffre、Scene_Coffre_bis、Window_Detection、Perso_Detection、Window_Info、Window_Action、Window_Cl
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DETECTION、ID_SORT_DE_VISION、ID_PASSE、SPECIALISTE、VOLEUR、USAGE_UNIQUE、ETAT_POISON、ANIM_POISON。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
=begin
 
                                          Script de coffre amélioré
 
Auteur : ASHKA
                                          
######################     Instruction     #################################                                      
 
要放置在“後備箱”通風口中的腳本插入列表 :
 
$vision = true/false 
( 確定這個箱子是否可以被視覺法術“讀取” )
 
$verrou = true/false 
( 確定這個保險箱是否上鎖 )
 
$level = x 
( x 介於 1 和 5 之間 - 確定儀表滾動的速度 )
 
$resistance = x 
( x 介於 0 和 100 之間 - 確定保險箱對強行通過的抵抗力 -
越高，強行破壞內容的風險越大
後備箱高 )
 
$sequence = [x,y]
x 正確幾次可開
y 可失敗幾次


以下陷阱之一（由您選擇） :
$piege = ["aucun"]              - 沒有陷阱
$piege = ["poison"]        - 有毒氣體
$piege = ["metal"]              - 金屬刀片
$piege = ["magic_drain"]  - PM吸收
$piege = ["explosif"]    - 爆炸（拿走物品後）
$piege = ["monstre", x]   - 戰鬥（x為要戰鬥的怪物群的ID）
 
以下插入用於定義保險箱中包含的對象：
（我的建議：對上述信息使用不同的插入。
還有一個專門為下面的一個）
 
$tresor = [x, [$data_items[y], quantité, probabilité], 
          [$data_weapons[y], quantité, probabilité], 
          [$data_armors[y], quantité, probabilité]]
 
x 是玩家可以為這個箱子接收的最大物品數量。
其餘的是方括號中的三個信息塊。
每個塊將代表一個可能的對象。
您可以（為了提高可讀性）返回到逗號後的行
分隔每個塊。對象限制是插入行的限制
腳本（但這已經是很多對象了！！）
每個塊的信息是：
1）類型：物品/武器/盔甲
y 是物品/武器/盔甲ID
2）數量（從1到99）
3）獲得對象的概率（百分比）
 
最後一個插入是調用腳本的那個:
 
$scene = Scene_Coffre.new
 
在此之後，通風口應該有一些通風控制
1）“等待5幀”
2) 此腳本插入的條件 = $ game_temp.open == true
（腳本條件 = 條件的第 4 頁）
這個條件決定了保險箱是否打開，所以下面是經典的：
3）本地開關A激活
4) 帶有“行李箱打開”精靈且沒有關閉行李箱控件的第二頁。
N'oubliez pas les différents réglages ci-dessous !!
N'oubliez pas les différents réglages ci-dessous !!
N'oubliez pas les différents réglages ci-dessous !! Et
 
                                                 Bonne utilisation !!
 
=end
########################          Reglages                ################################
module ASHKA
# 如果您允許檢測，則為 true，否則為 false  
  DETECTION = true
# 用於“看到”陷阱的技能 ID（使用動畫和消耗 mp）
  ID_SORT_DE_VISION = 103
# 用於解鎖寶箱的物品 ID
  ID_PASSE = 1
# 如果只有某些英雄可以解鎖箱子，則為 true，如果所有英雄都可以，則為 false
  SPECIALISTE = false 
# 可以解鎖寶箱的英雄ID（僅當SPECIALIST為true時）
  VOLEUR = [5, 8]
# 如果通行證是一次性使用（使用後丟失），則為真，否則為假
  USAGE_UNIQUE = true
# 與“毒藥”陷阱相關聯的狀態 ID
  ETAT_POISON = 2
# 與“毒藥”陷阱相關的動畫 ID
  ANIM_POISON = 83
# 與“爆炸”陷阱相關的動畫 ID
  ANIM_EXPLOSIF = 84
# 由“爆炸”陷阱造成的傷害（移除 X% 的最大生命值）
  DEGAT_EXPLOSIF = 25 # 隊伍將損失最大HP的25%
# 確定“爆炸”陷阱是否可以殺死英雄
  MORT_EXPLOSIF = false # 如果是假的，至少保留 1 HP
# 與“金屬”陷阱關聯的動畫 ID
  ANIM_METAL = 85
# 由“金屬”陷阱造成的傷害（移除 X% 的最大生命值）
  DEGAT_METAL = 10 #隊伍會損失最大HP的10%
# 確定“金屬”陷阱是否可以殺死英雄
  MORT_METAL = false # 如果是假的，至少保留 1 HP
# 與“magic_drain”陷阱關聯的動畫 ID
  ANIM_MAGIC = 86
# 由“magic_drain”系統造成的傷害（移除 X% 的最大 MP）
  DEGAT_MAGIC = 15 # 團隊將失去最大 MP 的 15%
end
################################################################################
class Scene_Coffre
 
  def main
        
        @spriteset = Spriteset_Map.new
        $fiche_vision = false
        
        @help_window = Window_Help.new
        @help_window.opacity = 255
        @phase1 = Window_Detection.new
        @phase1.index = 0
        @phase1.visible = false
        @phase1.active = false
        @phase1.help_window = @help_window
        @phase1_bis = Perso_Detection.new
        @phase1_bis.index = 0
        @phase1_bis.visible = false
        @phase1_bis.active = false
        @phase1_bis.help_window = @help_window
        
        
        Graphics.transition
        loop do
          Graphics.update
          Input.update
          update
          if $scene != self
                break
          end
        end
        Graphics.freeze
 
        @spriteset.dispose
        @help_window.dispose
        @phase1.dispose
        @phase1_bis.dispose
 
  end # def main
 
  def update
        @spriteset.update
        @help_window.update
        #@help_window.opacity = 255
        @phase1.update
        @phase1_bis.update
        
        if @phase1.active
          update_phase1
          return
        end
        
        if @phase1_bis.active
          update_phase1_bis
          return
        end
 
        
        if ASHKA::DETECTION == true
          if $vision == true
                @magos = []
                for actor in $game_party.members
                  unless actor.dead?
                        if actor.skills.include?($data_skills[ASHKA::ID_SORT_DE_VISION])
                          if actor.mp >= $data_skills[ASHKA::ID_SORT_DE_VISION].mp_cost
                                @magos.push(actor)
                          end
                        end
                  end
                end
                if @magos[0] != nil
                  @phase1.visible = true
                  @phase1.active = true
                else
                  $scene = Scene_Coffre_bis.new
                end
          else
                $scene = Scene_Coffre_bis.new
          end
        else
          $scene = Scene_Coffre_bis.new
        end
 
  end # def update
  
  def update_phase1
        if Input.trigger?(Input::C)
          Sound.play_decision
          case @phase1.index
          when 0 
                @phase1_bis.visible = true
                @phase1_bis.active = true
                @phase1.visible = false
                @phase1.active = false
          when 1
                $scene = Scene_Coffre_bis.new
          end
        end
  end # def update_phase1
  
  def update_phase1_bis
        @help_window.set_text("誰將施展咒語 ? ( 消耗 : " + $data_skills[ASHKA::ID_SORT_DE_VISION].mp_cost.to_s + " " + Vocab::mp.to_s + " )", 1)
        if Input.trigger?(Input::C)
          Sound.play_decision
          $scene = Scene_Map.new
          $game_player.animation_id = $data_skills[ASHKA::ID_SORT_DE_VISION].animation_id
          actor = @phase1_bis.actor
          actor.mp -= $data_skills[ASHKA::ID_SORT_DE_VISION].mp_cost
          $fiche_vision = true
          $scene = Scene_Coffre_bis.new
        end
  end # def update_phase1_bis
  
end # scene_coffre
################################################################################
class Scene_Coffre_bis
 
  def main
        
        @spriteset = Spriteset_Map.new
        $game_temp.ouvert = false
        
        $jauge = 0
        @tresor = []
        @quantité = []
        @press = false
        @type = "haut"
        @coord_x = 0
        @coord_y = 0
        $deverrouillage = false
        $desactivation = false
        @help_window = Window_Help.new
        @help_window.opacity = 255
        @info = Window_Info.new
        @action = Window_Action.new
        @action.help_window = @help_window
        @action.visible = true
        @action.active = true
        @action.index = 0
        @clé = Window_Clé.new(0, 0, 0)
        @clé.visible = false
        @perso_clé = Perso_Clé.new
        @perso_clé.visible = false
        @perso_clé.active = false
        @fiche_tresor = Window_Tresor.new(@tresor, @quantité)
        @fiche_tresor.visible = false
        @desactive = Window_Desactive.new(@press, @type, @coord_x, @coord_y)
        @desactive.visible = false
        
        
        Graphics.transition
        loop do
          Graphics.update
          Input.update
          update
          if $scene != self
                break
          end
        end
        Graphics.freeze
 
        @spriteset.dispose
        @help_window.dispose
        @info.dispose
        @action.dispose
        @clé.dispose
        @perso_clé.dispose
        @fiche_tresor.dispose
        @desactive.dispose
        
  end # def main
 
  def update
        @spriteset.update
        @help_window.update
        @info.update
        @action.update
        @clé.update
        @perso_clé.update
        @fiche_tresor.update
        @desactive.update
        
        if @perso_clé.active
          update_perso_clé
          return
        end
        
        if @clé.visible
          update_clé
          return
        end
        
        if @fiche_tresor.visible
          update_tresor
          return
        end
        
        if @desactive.visible
          update_desactive
          return
        end
        
        if Input.trigger?(Input::C)
          case @action.index
          when 0
                if $verrou == true
                  if rand(101) < $resistance
                        Sound.play_decision
                        @help_window.opacity = 0
                        @fiche_tresor.dispose
                        @fiche_tresor = Window_Tresor.new(@tresor, @quantité)
                        @fiche_tresor.visible = true
                        @action.active = false
                        @action.visible = false
                        @info.visible = false
                        return
                  end
                end
                for item in 1...$tresor.size
                  if rand(101) < $tresor[item][2].to_i
                        unless @tresor.size == $tresor[0]
                          @tresor.push($tresor[item][0])
                          @quantité.push($tresor[item][1])
                          $game_party.gain_item($tresor[item][0], $tresor[item][1])
                        end
                  end
                end
                Sound.play_decision
                @help_window.opacity = 0
                @fiche_tresor.dispose
                @fiche_tresor = Window_Tresor.new(@tresor, @quantité)
                @fiche_tresor.visible = true
                @action.active = false
                @action.visible = false
                @info.visible = false
                return
          when 1
                if $deverrouillage == true
                  Sound.play_buzzer
                elsif ASHKA::SPECIALISTE
                        groupe = []
                        test = false
                        for actor in $game_party.members
                          groupe.push(actor.id)
                        end
                        for x in groupe
                          if ASHKA::VOLEUR.include?(x)
                                test = true
                          end
                        end
                  if test and $game_party.has_item?($data_items[ASHKA::ID_PASSE])
                        Sound.play_decision
                        @perso_clé.visible = true
                        @perso_clé.active = true
                        @perso_clé.index = 0
                        @action.visible = false
                        @action.active = false
                        @action.index = -1
                 else
                        Sound.play_buzzer
                 end
           elsif $game_party.has_item?($data_items[ASHKA::ID_PASSE])
                 Sound.play_decision
                  @perso_clé.visible = true
                  @perso_clé.active = true
                  @perso_clé.index = 0
                  @action.visible = false
                  @action.active = false
                  @action.index = -1
                else
                  Sound.play_buzzer
                end
          when 2
                if $desactivation == true
                  Sound.play_buzzer
                else
                  Sound.play_decision
                  @time = rand(60) + 20
                  @press = true
                  @type = "haut"
                  @coord_x = 150
                  @coord_y = 150
                  @essai = 0
                  @succes = 0
                  @desactive.dispose
                  @desactive = Window_Desactive.new(@press, @type, @coord_x, @coord_y)
                  @desactive.visible = true
                  @action.visible = false
                  @action.active = false
                  @action.index = -1
                end
          when 3
                $scene = Scene_Map.new
          end
        end
  end # def update
  
  def update_perso_clé
        @help_window.set_text("誰來強行開鎖 ?", 1)
        if Input.trigger?(Input::C)
          Sound.play_decision
          @actor = @perso_clé.actor
          @clé.dispose
          @essai = 0
          @reussite = []
          $jauge = 0
          @un = rand(50) + 24
          @deux = rand(50) + @un + 24
          @trois = rand(55) + @deux + 24
          @clé = Window_Clé.new(@un, @deux, @trois)
          @clé.visible = true
          @perso_clé.visible = false
          @perso_clé.active = false
          @perso_clé.index = -1
        end
  end # def update_perso_clé
  
  
  def update_clé
        @help_window.set_text('適時按下“箭頭” !!', 1)
        resultat = 2
        case $level
        when 1
          resultat += 0.2
        when 2
          resultat += 0.4
        when 3
          resultat += 0.6
        when 4
          resultat += 0.8
        when 5
          resultat += 1
        end
        if @actor.agi.between?(0, 50)
          resultat -= 0.2
        elsif @actor.agi.between?(51, 150)
          resultat -= 0.4
        elsif @actor.agi.between?(151, 250)
          resultat -= 0.6
        elsif @actor.agi.between?(251, 350)
          resultat -= 0.8
        elsif @actor.agi.between?(351, 450)
          resultat -= 1
        elsif @actor.agi.between?(451, 550)
          resultat -= 1.2
        elsif @actor.agi.between?(551, 650)
          resultat -= 1.4
        elsif @actor.agi.between?(651, 750)
          resultat -= 1.6
        elsif @actor.agi.between?(751, 850)
          resultat -= 1.8
        elsif @actor.agi.between?(851, 999)
          resultat -= 2
        end
        if resultat < 1
          resultat = 1
        end
        if resultat > 3
          resultat = 3
        end
        $jauge += resultat
        if $jauge > 250
          $jauge = 0
        end
        @clé.refresh
        if Input.trigger?(Input::C)
          @essai += 1
          if $jauge.between?(@un + 10, @un + 20)
                Sound.play_decision
                @reussite.push("un")
          elsif $jauge.between?(@deux + 10, @deux + 20)
                Sound.play_decision
                @reussite.push("deux")
          elsif $jauge.between?(@trois + 10, @trois + 20)
                Sound.play_decision
                @reussite.push("trois")
          else
                Sound.play_buzzer
          end
        end
        if @essai == 3
          if @reussite[0] == "un" and @reussite[1] == "deux" and @reussite[2] == "trois"
                $verrou = false
                @info.refresh
                $deverrouillage = true
          end
          if ASHKA::USAGE_UNIQUE == true
                $game_party.lose_item($data_items[ASHKA::ID_PASSE], 1)
          end
          @action.visible = true
          @action.active = true
          @action.index = 1
          @clé.visible = false
        end
  end # def update_clé
  
  def update_tresor
        if Input.trigger?(Input::C)
          $game_temp.ouvert = true
          if $piege[0] == "magic_drain"
                $scene = Scene_Map.new
                $game_player.animation_id = ASHKA::ANIM_MAGIC
                for actor in $game_party.members
                  actor.mp -= ASHKA::DEGAT_MAGIC * actor.maxmp / 100
                end
          elsif $piege[0] == "poison"
                $scene = Scene_Map.new
                $game_player.animation_id = ASHKA::ANIM_POISON
                for actor in $game_party.members
                  actor.add_state(ASHKA::ETAT_POISON)
                end
          elsif $piege[0] == "monstre"
                $scene = Scene_Map.new
                $game_troop.setup($piege[1])
                $game_troop.preemptive = true
                $game_temp.battle_proc = nil
                $game_temp.next_scene = "battle"
          elsif $piege[0] == "metal"
                $scene = Scene_Map.new
                $game_player.animation_id = ASHKA::ANIM_METAL
                for actor in $game_party.members
                  actor.hp -= ASHKA::DEGAT_METAL * actor.maxhp / 100
                  if ASHKA::MORT_METAL == false and actor.hp <= 0
                        actor.hp = 1
                  end
                end
                mort = 0
                for actor in $game_party.members
                  if actor.dead?
                        mort += 1
                  end
                end
                if mort == $game_party.members.size
                  $scene = Scene_Gameover.new
                end
          elsif $piege[0] == "explosif"
                $scene = Scene_Map.new
                $game_player.animation_id = ASHKA::ANIM_EXPLOSIF
                for actor in $game_party.members
                  actor.hp -= ASHKA::DEGAT_EXPLOSIF * actor.maxhp / 100
                  if ASHKA::MORT_EXPLOSIF == false and actor.hp <= 0
                        actor.hp = 1
                  end
                end
                mort = 0
                for actor in $game_party.members
                  if actor.dead?
                        mort += 1
                  end
                end
                if mort == $game_party.members.size
                  $scene = Scene_Gameover.new
                end
          elsif $piege[0] == "aucun"
                $scene = Scene_Map.new
          end
        end
  end # def update_tresor
  
  def update_desactive
        @help_window.set_text("按下屏幕上出現的按鍵 !!", 1)
        @press = true
        @time -= 1
        if @time < 0
          @time = 0
        end
        if @time == 0
          catg = rand(4)
          if catg == 0
                @type = "bas"
          elsif catg == 1
                @type = "gauche"
          elsif catg == 2
                @type = "haut"
          elsif catg == 3
                @type = "droite"
          end
          @coord_x = rand(480)
          @coord_y = rand(180)
          @time = rand(60) + 30
        end
##
        if Input.trigger?(Input::DOWN) and @type == "bas"
          Sound.play_decision
          @essai += 1
          @succes += 1
        elsif Input.trigger?(Input::DOWN) and @type != "bas"
          Sound.play_buzzer
          @essai += 1
        end
##
        if Input.trigger?(Input::LEFT) and @type == "gauche"
          Sound.play_decision
          @essai += 1
          @succes += 1
        elsif Input.trigger?(Input::LEFT) and @type != "gauche"
          Sound.play_buzzer
          @essai += 1
        end
##
        if Input.trigger?(Input::UP) and @type == "haut"
          Sound.play_decision
          @essai += 1
          @succes += 1
        elsif Input.trigger?(Input::UP) and @type != "haut"
          Sound.play_buzzer
          @essai += 1
        end
##
        if Input.trigger?(Input::RIGHT) and @type == "droite"
          Sound.play_decision
          @essai += 1
          @succes += 1
        elsif Input.trigger?(Input::RIGHT) and @type != "droite"
          Sound.play_buzzer
          @essai += 1
        end
##
        @desactive.dispose
        @desactive = Window_Desactive.new(@press, @type, @coord_x, @coord_y)
        @desactive.visible = true
        if @succes == $sequence[0].to_i
          $piege[0] = "aucun"
          $desactivation = true
          @action.visible = true
          @action.active = true
          @action.index = 2
          @desactive.visible = false
          @info.refresh
        end
        if @essai == $sequence[1].to_i
          @action.visible = true
          @action.active = true
          @action.index = 2
          @desactive.visible = false
        end
  end # def update_desactive
  
end # def scene_coffre_bis
################################################################################
class Window_Detection < Window_Selectable
 
  def initialize
        super(116, 158, 312, 100)
        @item_max = 2
        @column_max = 2
        @index = -1
        refresh
  end
 
  def refresh
        self.contents.clear
        self.contents.draw_text(0, 0, 280, 32, "要使用透視法術嗎 ?", 1)
        @data = ["是", "否"]
        for i in 0..@data.size
          self.contents.draw_text(i * 140, 30, 140, 32, @data[i].to_s, 1)
        end
  end
  
  def update_cursor
        if @index < 0                              
          self.cursor_rect.empty                
        else                                                    
          row = @index / @column_max    
          if row < top_row                        
                self.top_row = row               
          end
          if row > bottom_row    
                self.bottom_row = row   
          end
          rect = Rect.new(0, 0, 0, 0)
          rect.width = 140
          rect.height = WLH
          rect.x = @index * 140
          rect.y = 35
          self.cursor_rect = rect          
        end
  end
  
  def update_help
        text = ""
        case @index
        when 0, 1
          text = "可以嘗試解除陷阱，取得寶物！"
        end
        @help_window.set_text(text, 1)
  end
 
end # class Window_Detection
################################################################################
class Perso_Detection < Window_Selectable
 
  def initialize
        super(111, 132, 322, 152)
        @column_max = 1
        @index = 0
        refresh
  end
 
  def refresh
        @data = []
        for actor in $game_party.members
          unless actor.dead?
                if actor.skills.include?($data_skills[ASHKA::ID_SORT_DE_VISION])
                  if actor.mp >= $data_skills[ASHKA::ID_SORT_DE_VISION].mp_cost
                        @data.push(actor.id)
                  end
                end
          end
        end
        @item_max = @data.size
        create_contents
        for i in 0...@item_max
          draw_actor(i)
        end
  end
 
  def actor
        return $game_actors[@data[index]]
  end
  
  def draw_actor(index)
        actor = $game_actors[@data[index]]
        self.contents.draw_text(0, index * 30, 300, 32, actor.name + " - " + Vocab::mp.to_s + " : " + actor.mp.to_s + " | " + Vocab::spi.to_s + " : " + actor.spi.to_s, 1)
  end
  
  def update_cursor
        if @index < 0                              
          self.cursor_rect.empty                
        else                                                    
          row = @index / @column_max    
          if row < top_row                        
                self.top_row = row               
          end
          if row > bottom_row    
                self.bottom_row = row   
          end
          rect = Rect.new(0, 0, 0, 0)
          rect.width = 300
          rect.height = WLH
          rect.x = -5
          rect.y = @index * 30 + 5
          self.cursor_rect = rect          
        end
  end
  
end # class Perso_Detection
################################################################################
class Window_Info < Window_Base
 
  def initialize
        super(0, WLH + 32, 544, 130)
        refresh
  end
 
  def refresh
        self.contents.clear
        bitmap = Cache.system("Iconset")
        if $fiche_vision == true
          if $verrou == true
                alpha = "上鎖的寶箱 : "
                rect = Rect.new(0 * 24, 5 * 24, 24, 24)
          else
                alpha = "估計 : "
                rect = Rect.new(0 * 24, 0 * 24, 24, 24)
          end
          aa = alpha + "可能有 " + $tresor[0].to_s + " 項寶物 !!"
          self.contents.blt(0, 0, bitmap, rect, 255)
          self.contents.draw_text(0, 0, 544, 32, aa, 1)
### fin ligne 1   
          if $piege[0] == "monstre"
                bb = "小心，這個箱子裡藏著怪物 !!"
                rect = Rect.new(0 * 24, 7 * 24, 24, 24)
          elsif $piege[0] == "poison"
                bb = "這個箱子內有毒氣 !!"
                rect = Rect.new(1 * 24, 7 * 24, 24, 24)
          elsif $piege[0] == "metal"
                bb = "這個箱子內有暗箭 !!"
                rect = Rect.new(9 * 24, 1 * 24, 24, 24)
          elsif $piege[0] == "explosif"
                bb = "這個箱子內有爆炸物 !!"
                rect = Rect.new(7 * 24, 8 * 24, 24, 24)
          elsif $piege[0] == "magic_drain"
                bb = "這個箱子內有詛咒 !!"
                rect = Rect.new(8 * 24, 8 * 24, 24, 24)
          elsif $piege[0] == "aucun"
                bb = "這個箱子安全 !!"
                rect = Rect.new(0 * 24, 0 * 24, 24, 24)
          end
          self.contents.blt(0, 30, bitmap, rect, 255)
          self.contents.draw_text(0, 30, 544, 32, bb, 1)
### fin ligne 2 
        else # if pas info
          self.contents.draw_text(0, 30, 544, 32, "沒有可用信息 !!", 1)
        end
  end
end
################################################################################
class Window_Action < Window_Selectable
 
  def initialize
        super(186, 186, 172, 155)
        @item_max = 4
        @column_max = 1
        @index = -1
        refresh
  end
 
  def refresh
        self.contents.clear
        @data = ["強行打開", "嘗試解鎖", "關閉陷阱", "放棄"]
        for i in 0..@data.size
          self.contents.draw_text(0, i * 30, 140, 32, @data[i].to_s, 1)
        end
  end
  
  def update_cursor
        if @index < 0                              
          self.cursor_rect.empty                
        else                                                    
          row = @index / @column_max    
          if row < top_row                        
                self.top_row = row               
          end
          if row > bottom_row    
                self.bottom_row = row   
          end
          rect = Rect.new(0, 0, 0, 0)
          rect.width = 140
          rect.height = WLH
          rect.x = 0
          rect.y =  @index * 30 + 5
          self.cursor_rect = rect          
        end
  end
  
  def update_help
        text = ""
        case @index
        when 0
          text = "不考慮後果，強行打開寶箱"
        when 1
          text = "你沒有解鎖工具 !!"
          if $game_party.has_item?($data_items[ASHKA::ID_PASSE])
                text = "使用解鎖工具解鎖寶箱"
          end
          if $deverrouillage == true
                text = "寶箱已經解鎖 !!"
          end
        when 2
          text = "在打開寶箱之前，嘗試關閉陷阱"
          if $desactivation == true
                text = "陷阱已停用 !!"
          end
        when 3
          text = "離開寶箱，稍後回來"
        end
        @help_window.set_text(text, 1)
  end
 
end # class Window_Action
################################################################################
class Window_Clé < Window_Base
 
  def initialize(un, deux, trois)
        super(136, 186, 272, 100)
        @un = un
        @deux = deux
        @trois = trois
        refresh
  end
 
  def refresh
        self.contents.clear
        bitmap = Cache.system("Iconset")
        rect = Rect.new(0 * 24, 5 * 24, 24, 24)
        self.contents.blt(@un, 0, bitmap, rect, 255)
        self.contents.blt(@deux, 0, bitmap, rect, 255)
        self.contents.blt(@trois, 0, bitmap, rect, 255)
        self.contents.fill_rect(0, 35, 250, 32, Color.new(20, 20, 20, 255))
        self.contents.fill_rect(@un + 7, 35, 10, 32, Color.new(255, 255, 255, 255))
        self.contents.fill_rect(@deux + 7, 35, 10, 32, Color.new(255, 255, 255, 255))
        self.contents.fill_rect(@trois + 7, 35, 10, 32, Color.new(255, 255, 255, 255))
        self.contents.gradient_fill_rect(0, 36, $jauge, 30, Color.new(255, 0, 0, 255), Color.new(0, 255, 0, 255))
  end
 
end
################################################################################
class Perso_Clé < Window_Selectable
 
  def initialize
        super(161, 186, 222, 152)
        @column_max = 1
        @index = 0
        refresh
  end
 
  def refresh
        @data = []
        for actor in $game_party.members
          unless actor.dead?
                if ASHKA::SPECIALISTE  
                  if ASHKA::VOLEUR.include?(actor.id)
                        @data.push(actor.id)
                  end
                else
                        @data.push(actor.id)
                end
          end
        end
        @item_max = @data.size
        create_contents
        for i in 0...@item_max
          draw_actor(i)
        end
  end
 
  def actor
        return $game_actors[@data[index]]
  end
  
  def draw_actor(index)
        actor = $game_actors[@data[index]]
        self.contents.draw_text(0, index * 30, 200, 32, actor.name + " - " + Vocab::agi.to_s + " : " + actor.agi.to_s, 1)
  end
  
  def update_cursor
        if @index < 0                              
          self.cursor_rect.empty                
        else                                                    
          row = @index / @column_max    
          if row < top_row                        
                self.top_row = row               
          end
          if row > bottom_row    
                self.bottom_row = row   
          end
          rect = Rect.new(0, 0, 0, 0)
          rect.width = 200
          rect.height = WLH
          rect.x = -5
          rect.y = @index * 30 + 5
          self.cursor_rect = rect          
        end
  end
  
end # class Perso_Clé
################################################################################
class Window_Tresor < Window_Base
 
  def initialize(tresor, quantité)
        super(0, 0, 544, 416)
        @tresor = tresor
        @quantité = quantité
        refresh
  end
 
  def refresh
        self.contents.clear
        self.contents.draw_text(0, 0, 522, 32, "發現寶物！", 1)
        y = 60
        index = 0
        for item in @tresor
          icon_index = item.icon_index
          bitmap = Cache.system("Iconset")
          rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
          self.contents.blt(90, y, bitmap, rect, 255)
          self.contents.draw_text(100, y, 300, WLH, item.name + " + " + @quantité[index].to_s, 1)
          y += 30
          index += 1
        end
        if @tresor.size == 0
          self.contents.draw_text(0, y + 30, 522, 32, "你的行為破壞了寶箱內的物品!!", 1)
        end
        if $piege[0] == "poison"
          text = "毒氣從寶箱逸出 !!"
        elsif $piege[0] == "monstre"
          text = "躲在寶箱裡的怪物跳了出來 !!"
        elsif $piege[0] == "metal"
          text = "觸發了陷阱 !!"
        elsif $piege[0] == "explosif"
          text = "觸發了陷阱 !!"
        elsif $piege[0] == "aucun"
          text = "沒有觸發任何陷阱 !!"
        end
        self.contents.draw_text(0, y + 60, 522, 32, text, 1)
        if $piege[0] == "magic_drain"
          self.contents.draw_text(0, y + 60 , 522, 32, "詛咒被觸發 !!", 1)
          self.contents.draw_text(0, y + 90, 522, 32, "被吸取了MP !!", 1)
        end
  end
 
end # class Window_Tresor
################################################################################
class Game_Temp
  
  attr_accessor  :ouvert
 
  alias new_initialize initialize
  def initialize
        @ouvert = false
        new_initialize
  end
  
end
################################################################################
class Window_Desactive < Window_Base
 
  def initialize(action, type, coord_x, coord_y)
        super(0, 186, 544, 230)
        @action = action
        @type = type
        @coord_x = coord_x
        @coord_y = coord_y
        refresh
  end
 
  def refresh
        self.contents.clear
        if @action == true
          bitmap = Cache.system("Iconset")
          case @type
          when "bas"#下
                rect = Rect.new(8 * 24, 13 * 24, 24, 24)
          when "gauche"#左
                rect = Rect.new(9 * 24, 13 * 24, 24, 24)
          when "haut"#上
                rect = Rect.new(10 * 24, 13 * 24, 24, 24)
          when "droite"#右
                rect = Rect.new(11 * 24, 13 * 24, 24, 24)
          end  
          self.contents.blt(@coord_x, @coord_y, bitmap, rect, 255)
        end
  end
 
end
################################################################################