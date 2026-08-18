#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：H87-EnemyKilledCounter｜Runtime
# 【用途】保留的 Runtime 元件「H87-EnemyKilledCounter｜Runtime」。
# 【主要機制】主要定義／擴充 RPG::Enemy、Scene_Title、Game_Enemy、H87_EKC；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::Enemy、Scene_Title、Game_Enemy、H87_EKC
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意；登記 $imported：H87_EKC。
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
$imported = {} if $imported == nil
$imported["H87_EKC"] = true
#===============================================================================
# ** INCREMENTA VARIABILE CON UCCISIONE DEL NEMICO **
# Versione: 1.0 (15/04/2013)
# Difficoltà utente: ★
#===============================================================================
# DESCRIZIONE:
# Mettiamo che vuoi fare una quest come "Uccidi 10 Slime!" Come si fa a tenere
# il conto degli Slime uccisi? Con questo script, che li memorizza in una
# variabile!
#===============================================================================
# UTILIZZO:
# Installare lo script sotto Materials e prima del Main.
# Inserire, nel riquadro delle note del nemico, la seguente etichetta:
# <kill var: x>, dove x è la variabile (ID) che verrà incrementata quando quel
# mostro verrà ucciso. Semplice!
#===============================================================================
# COMPATIBILITA':
# Compatibile con quasi tutti gli script.
#===============================================================================


#===============================================================================
# Attenzione: Non modificare ciò che c'è oltre, a meno che tu non sappia ciò che
# fai!
#===============================================================================
module H87_EKC
  KillVariable = /<(?:KILL VAR|kill var):[ ]*(\d+)>/i
end

#===============================================================================
# ** Data Nemico
#===============================================================================
class RPG::Enemy
  attr_reader :killvariable
  
  #-----------------------------------------------------------------------------
  # *Carica le info sulla variabile
  #-----------------------------------------------------------------------------
  def carica_cache_personale_ekc
    return if @cache_caricata_ekc
    @cache_caricata_ekc = true
    @killvariable = 0
    self.note.split(/[\r\n]+/).each { |riga|
      case riga
      #---
      when H87_EKC::KillVariable
        @killvariable = $1.to_i
      end
    }
  end
end

#===============================================================================
# ** Scene_Title
#===============================================================================
class Scene_Title < Scene_Base
  
  #-----------------------------------------------------------------------------
  # *Alias metodo load_bt_database
  #-----------------------------------------------------------------------------
  alias carica_db_ekc load_bt_database unless $@
  def load_bt_database
    carica_db_ekc
    carica_enemy_ekc
  end
  
  #-----------------------------------------------------------------------------
  # *Alias metodo load_database
  #-----------------------------------------------------------------------------
  alias carica_db_ekc load_database unless $@
  def load_database
    carica_db_ekc
    carica_enemy_ekc
  end
  
  #-----------------------------------------------------------------------------
  # Inizializza nel caricamento
  #-----------------------------------------------------------------------------
  def carica_enemy_ekc
    for enemy in $data_enemies
      next if enemy == nil
      enemy.carica_cache_personale_ekc
    end
  end
  
end # scene_title

#===============================================================================
# ** Game_Enemy
#===============================================================================
class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # *inizializzazione
  #-----------------------------------------------------------------------------
  alias h87_ekc_initialize initialize unless $@
  def initialize(index, enemy_id)
    h87_ekc_initialize(index, enemy_id)
    @killed_variable = enemy.killvariable
  end
  
  #-----------------------------------------------------------------------------
  # *alias metodo di collasso (morte)
  #-----------------------------------------------------------------------------
  alias h87_ekc_collapse perform_collapse unless $@
  def perform_collapse
    increment_killed_var if $game_temp.in_battle and dead?
    h87_ekc_collapse
    end
  
  #-----------------------------------------------------------------------------
  # *incremento variabile se permesso
  #-----------------------------------------------------------------------------
  def increment_killed_var
    $game_variables[@killed_variable] += 1 if @killed_variable != 0
  end
end #game_enemy