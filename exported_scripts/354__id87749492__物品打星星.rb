#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：物品打星星
# 【用途】物品／商店元件「物品打星星」。
# 【主要機制】處理物品資料、交易、製作、庫存或 UI；事件入口與資料庫設定需要一起確認。
# 【主要影響】BaseItem、Window_Base、Scene_Title、Window_ItemList、H87_ItemClass、RPG
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：H87_ItemClass、ItemOverhaul。
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
# ** Classi Oggetto
# di Holy87
# v1.0
# -----------------------------------------------------------------------------
# Descrizione:
# 這個腳本允許你在技能圖標上顯示星星，
# 表明其價值的物品、武器或盔甲。
# -----------------------------------------------------------------------------
# Uso:
# ● 在 Materials 下安裝腳本，在 Main 之前和在腳本下
# YEM ItemOverhaul，如果有的話。
# ● 導入星形圖標圖形，將它們放入您的圖標集中，
# 然後在該部分設置每個級別的圖標ID
#  配置
# ● 在註釋標籤中插入行 <classe: x>，其中 x 是值
# 武器，如果你想手動設置物品的值。
#==============================================================================
$imported = {} if $imported == nil
$imported["H87_ItemClass"] = true
module H87_ItemClass
#==============================================================================
# ** Configurazione
# Configura lo script in pochi semplici passi!
#==============================================================================
  #Imposta la propria icona per ogni livello dell'oggetto. Non è obbligatorio
  #usarne 5, puoi mettere quanti livelli vuoi.
  Icone = {
#Liv  Icona
  1 => 2512,
  2 => 2513,
  3 => 2514,
  4 => 2515,
  5 => 2516
  }
  
  # * Assegnazione automatica delle classi
  # Lo script assegna automaticamente il valore di un oggetto a seconda delle
  # sue proprietà. Ti sembra che lo script sia troppo generoso/tirchio per i
  # tuoi gusti? Modifica le proporzioni di stelle da dare a seconda della
  # tipologia! Imposta 0 se non vuoi che venga calcolato automaticamente il
  # valore per quella categoria.設0不顯示
  
  # Proporzioni Poteri
  Prop_Skill = 0
  # Proporzioni Oggetti
  Prop_Item  = 100
  # Proporzioni Armi
  Prop_Weap  = 100
  # Proporzioni Armature
  Prop_Armr  = 100
  
  
  #============================================================================
  # ** FINE CONFIGURAZIONE **
  # Modificare da questo punto in poi è rischioso. Fallo solo se sai ciò che fai!
  #============================================================================
  
  
  
  # Testo per le tag
  Classe = /<(?:CLASSE|classe):[ ]*(\d+)>/i
  
end

module RPG
  class BaseItem #Superclasse di tutti gli oggetti
    attr_accessor :classe_oggetto #Nuovo attributo
    
  #--------------------------------------------------------------------------
  # * Restituisce il livello dell'oggetto
  #--------------------------------------------------------------------------
    def classe_oggetto
      return @classe_oggetto
    end
    
  #--------------------------------------------------------------------------
  # * Inizializza il livello della classe dell'oggetto
  #--------------------------------------------------------------------------
    def carica_cache_personale_class
      return if @cache_caricata2
      @cache_caricata2 = true
      @classe_oggetto = 0
      case self
      when RPG::Skill
        calcola_valore_skill if H87_ItemClass::Prop_Skill > 0
      when RPG::Item
        calcola_valore_item if H87_ItemClass::Prop_Item > 0
      when RPG::Weapon
        calcola_valore_weapon if H87_ItemClass::Prop_Weap > 0
      when RPG::Armor
        calcola_valore_armor if H87_ItemClass::Prop_Armr > 0
      end
      self.note.split(/[\r\n]+/).each { |riga|
      case riga
      when H87_ItemClass::Classe
        @classe_oggetto = $1.to_i
      end
      }
    end
    
  #--------------------------------------------------------------------------
  # * Calcola il valore dei poteri
  #--------------------------------------------------------------------------
    def calcola_valore_skill
      if self.base_damage < 0 #Se è una magia di cura
        valore = (self.base_damage-100).to_f / -55.0
      else
        valore = (self.base_damage-50).to_f / 10.0
        valore = 1 if valore < 1
      end
      valore += (self.atk_f.to_f+self.spi_f.to_f)/3.1 if self.base_damage != 0
      #moltiplicatori bonus
      valore *= 2.3 if self.absorb_damage
      valore *= 1.5 if self.ignore_defense and self.base_damage > 0
      valore *= 1.9 if self.damage_to_mp
      valore += self.plus_state_set.size.to_f*4.0
      valore += 20.0 if plus_state_set.include?($data_states[1])
      valore += self.minus_state_set.size.to_f*2.0
      valore *= self.hit.to_f/100.0
      valore *= 0.9 if self.physical_attack
      case self.scope
      when 2,8,10 #Totale
        valore *= 1.5
      when 3      #Nemico singolo continuo
        valore *= 2.0
      when 4      #Nemico a caso
        valore *= 0.8
      when 5      #Due nemici a caso
        valore *= 1.5
      when 6      #Tre nemici a caso
        valore *= 2.2
      end
      valore = 100.0 if valore > 100
      valore = valore*H87_ItemClass::Icone.size
      valore = valore.to_f/100.0
      valore *= H87_ItemClass::Prop_Skill / 100.0
      @classe_oggetto = valore.to_i
    end
    
  #--------------------------------------------------------------------------
  # * Calcola il valore degli oggetti
  #--------------------------------------------------------------------------
    def calcola_valore_item
      valore = self.base_damage.to_f
      self.base_damage < 0 ? valore /= -60.0 : valore /= 17.0
      valore += (self.atk_f.to_f+self.spi_f.to_f)/3.1 if self.base_damage != 0
      valore *= 2.3 if self.absorb_damage
      valore *= 1.5 if self.ignore_defense and self.base_damage > 0
      valore *= 1.9 if self.damage_to_mp
      valore += self.plus_state_set.size.to_f*4.0
      valore += 20.0 if plus_state_set.include?($data_states[1])
      valore += self.minus_state_set.size.to_f*1.5
      if parameter_type != 0
        case parameter_type
        when 1 #Aumento HP
          valore += parameter_points.to_f*0.4
        when 2 #Aumento MP
          valore += parameter_points.to_f*2.0
        when 3..6 #Tutti gli altri
          valore += parameter_points.to_f*6.7
        end
      end
      valore += hp_recovery.to_f*0.02
      valore += mp_recovery.to_f*0.05
      valore += hp_recovery_rate.to_f * 0.6
      valore += mp_recovery_rate.to_f * 0.6
      case self.scope
      when 2,8,10
        valore *= 1.5
      when 3
        valore *= 1.5
      when 4
        valore *= 0.8
      when 5
        valore *= 1.25
      when 6
        valore *= 2.5
      end
      valore = 100.0 if valore > 100
      valore = valore*H87_ItemClass::Icone.size
      valore = valore.to_f/100.0
      valore *= H87_ItemClass::Prop_Item / 100.0
      @classe_oggetto = valore.to_i
    end
    
  #--------------------------------------------------------------------------
  # * Calcola il valore delle armi
  #--------------------------------------------------------------------------
    def calcola_valore_weapon
      valore = 7.0
      valore += self.atk.to_f*1.4
      valore += self.def.to_f*1.2
      valore += self.spi.to_f*1.5
      valore += self.agi.to_f*1.2
      valore += self.state_set.size.to_f*15.0 # Bonus per ogni status
      valore += (self.element_set.size-1).to_f*5.0 if element_set.size != 0
      valore *= self.hit.to_f/100.0 #Mira
      # Bonus dell'arma
      valore *= 0.7 if self.two_handed # Valore minore del 30% se a due mani
      valore *= 1.3 if self.fast_attack
      valore *= 1.4 if self.critical_bonus
      valore *= 2.0 if self.dual_attack
      valore = 100.0 if valore > 100
      valore = valore*H87_ItemClass::Icone.size
      valore = valore.to_f/100.0
      valore *= H87_ItemClass::Prop_Weap / 100.0
      @classe_oggetto = valore.to_i
    end
    
  #--------------------------------------------------------------------------
  # * Calcola il valore delle armature
  #--------------------------------------------------------------------------
    def calcola_valore_armor
      valore = 1.0
      case self.kind
      when 0 #valore per scudo
        valore += self.atk.to_f*1.3
        valore += self.def.to_f*4.0
        valore += self.spi.to_f*1.3
        valore += self.agi.to_f*1.3
      when 1 #se è un elmo
        valore += self.atk.to_f*1.3
        valore += self.def.to_f*3.8
        valore += self.spi.to_f*1.3
        valore += self.agi.to_f*1.3
      when 2 #se è un'armatura
        valore += self.atk.to_f*1.3
        valore += self.def.to_f*3.0
        valore += self.spi.to_f*1.3
        valore += self.agi.to_f*1.3
      when 3 #se è un accessorio
        valore += self.atk.to_f*2.0
        valore += self.def.to_f*2.0
        valore += self.spi.to_f*2.0
        valore += self.agi.to_f*2.0
      end
      valore += self.state_set.size.to_f*5.0
      valore += self.element_set.size.to_f*5.0
      valore += self.eva.to_f*3.0
      valore += 80.0 if self.auto_hp_recover
      valore += 80.0 if self.half_mp_cost
      valore += 50 if self.prevent_critical
      valore += 80.0 if self.double_exp_gain
      valore = 100.0 if valore > 100
      valore = valore*H87_ItemClass::Icone.size
      valore = valore.to_f/100.0
      valore *= H87_ItemClass::Prop_Armr / 100.0
      @classe_oggetto = valore.to_i
    end
  end
end #Usable

#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  alias disegna_nome_oggetto draw_item_name
  def draw_item_name(item, x, y, enabled = true)
    disegna_nome_oggetto(item, x, y, enabled)
    if item != nil and item.classe_oggetto != 0
      draw_icon(H87_ItemClass::Icone[item.classe_oggetto], x, y, enabled)
    end
  end
end #Window_Base

class Window_Base < Window
  alias disegna_nome_oggetto10 draw_item_name
  def draw_item_name10(item, x, y, enabled = true)
    disegna_nome_oggetto10(item, x, y, enabled)
    if item != nil and item.classe_oggetto != 0
      draw_icon(H87_ItemClass::Icone[item.classe_oggetto], x, y, enabled)
    end
  end
end #Window_Base

#==============================================================================
# ** Scene_Title
#==============================================================================
class Scene_Title < Scene_Base
  
  #-----------------------------------------------------------------------------
  # *Alias metodo load_bt_database
  #-----------------------------------------------------------------------------
  alias carica_db2 load_bt_database unless $@
  def load_bt_database
    carica_db2
    carica_skills_class
    carica_item_class
    carica_armor_class
    carica_weapon_class
  end
  
  #-----------------------------------------------------------------------------
  # *Alias metodo load_database
  #-----------------------------------------------------------------------------
  alias carica_db_22 load_database unless $@
  def load_database
    carica_db_22
    carica_skills_class
    carica_item_class
    carica_armor_class
    carica_weapon_class
  end
  
  #-----------------------------------------------------------------------------
  # Inizializza nel caricamento
  #-----------------------------------------------------------------------------
  def carica_skills_class
    for skill in $data_skills
      next if skill == nil
      skill.carica_cache_personale_class
    end
  end
  
  def carica_item_class
    for item in $data_items
      next if item == nil
      item.carica_cache_personale_class
    end
  end
  
  def carica_armor_class
    for armor in $data_armors
      next if armor == nil
      armor.carica_cache_personale_class
    end
  end
  
  def carica_weapon_class
    for weapon in $data_weapons
      next if weapon == nil
      weapon.carica_cache_personale_class
    end
  end
  
end # scene_title

#==============================================================================
# ** Compatibilità Yanfly
#==============================================================================
if $imported["ItemOverhaul"]
class Window_ItemList < Window_Selectable
  alias nuovo_draw_item draw_obj_name
  def draw_obj_name(obj, rect, enabled)
    nuovo_draw_item(obj, rect, enabled)
    if obj != nil and obj.classe_oggetto != 0
      draw_icon(H87_ItemClass::Icone[obj.classe_oggetto], rect.x, rect.y, enabled)
    end
  end
end
end