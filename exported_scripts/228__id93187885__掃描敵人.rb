#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：掃描敵人
# 【用途】保留的 Runtime 元件「掃描敵人」。
# 【主要機制】主要定義／擴充 Game_Actor、Game_Enemy、Window_Help、N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Actor、Game_Enemy、Window_Help、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ID_SCAN、SCAN_NAME、DECAL_NAME、SCAN_GROUPES、NB_ICONES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】wilkyo - Idea of Drakild。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#############################################################################
# Add_on SBS - Scan V2                                                                                                                                        #
# by wilkyo - Idea of Drakild                                                                                                                                #
# Permet d'utiliser la compétence scan, qui une fois utilisée sur un ennemi, permet de voir sa vie #
#                                                                                                                                                                              #
# Utilisation:                                                                                                                                                          #
# - Créez l'état "Scanné" dans la BDD, en cochant la case "Aucune résistance"                                    #
# - Créez la compétence Scan, qui inflige à un ennemi l'état "Scanné" (avec de préférence 100%)  #
# - Réglez vos préférences çi dessous                                                                                                            #
#############################################################################
 
module N01
  # id de l'état "Scanné"
  ID_SCAN = 3500
  # Si vrai, replace le nom de la cible à la place de sa vie
  SCAN_NAME = true
  # Décale vers la droite le nom (pour ceux qui sont pas satisfaits de l'affichage)
  DECAL_NAME = true
  # Si vrai, en scannant 1 ennemi, ça scan tous les ennemis de la même espèce.
  SCAN_GROUPES = true
  # Nombre d'icônes à afficher
  NB_ICONES = 8
end
 
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================
 
class Game_Actor < Game_Battler
 
  def enemy?
    return false
  end
 
  def scanned?
    return true
  end
 
end
 
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================
 
class Game_Enemy < Game_Battler
   
  def enemy?
    return true
  end
 
  #######################################################
  # Renvoie vrai si l'ennemi est sous l'effet du scan                                    #
  #######################################################
  def scanned?
    return states.include?($data_states[N01::ID_SCAN])
  end
 
  #######################################################
  # Scan tous les ennemis du même type qu'un ennemi scanné            #
  #######################################################
  def scan_groupes
    s_s = $data_states[N01::ID_SCAN]
    for i in $game_troop.members
      if i.states.include?(s_s)
        for j in $game_troop.members
          j.add_state(N01::ID_SCAN) if j.enemy_id == i.enemy_id && !j.states.include?(s_s)
        end
      end
    end
  end
 
end
 
#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================
 
class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text_n01add(member)
    self.contents.clear
    return if member == nil || member.dead?
    member.scan_groupes if N01::SCAN_GROUPES&& member.enemy?
    self.contents.font.color = normal_color
#    self.draw_stun_indicator(180, 0, member) if member.actor?###
    if !member.actor? && N01::ENEMY_NON_DISPLAY.include?(member.enemy_id)
      return self.contents.draw_text(4, 0, self.width - 40, WLH, member.name, 1)
    elsif member.actor? && !N01::ACTOR_DISPLAY
      return self.contents.draw_text(4, 0, self.width - 40, WLH, member.name, 1)
    end
    draw_actor_enemy_elements(member, 200, 0)###
    if N01::WORD_STATE_DISPLAY && N01::HP_DISPLAY
        nom = member.name
        lgt = 175#175
      if member.scanned?
        #draw_actor_hp(member, 182, -6, 120)
        #draw_actor_mp(member, 182,  6, 120)
        self.contents.draw_text(0, 0, self.width - 40, WLH, nom, 1)
        
        #self.contents.draw_text(0, 0, lgt, WLH, nom, 2)
      elsif N01::SCAN_NAME
        #(nom += " " while nom.size < 22) if N01::DECAL_NAME
        #lgt = 300
        self.contents.draw_text(4, 0, self.width - 40, WLH, nom, 1)
        #self.draw_stun_indicator(180, 0, member)###
      end
      
      # 🛠 **新增：如果是 Actor，畫出 Actor 狀態**
        
        draw_enemy_state(member, 315, 0)
      
    elsif N01::HP_DISPLAY
      nom = member.name
      lgt = 175
      if member.scanned?
        draw_actor_hp(member, 262, 0, 120)
      elsif N01::SCAN_NAME
        (nom += " " while nom.size < 22) if N01::DECAL_NAME
        lgt = 300
      end
      self.contents.draw_text(4, 0, lgt, WLH, nom, 2)
    end
  end
 
    def draw_enemy_state(enemy, x, y, width = 24*N01::NB_ICONES)
    count = 0
    for state in enemy.states
      next if state.extension.include?("HIDEICON")
      #next if state.id == 6###
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 繪製我方角色狀態圖示
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 24 * N01::NB_ICONES)
    count = 0
    for state in actor.states
      next if state.extension.include?("HIDEICON")
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
 
end