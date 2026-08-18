#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：PopUp Generale｜H87 Popup v1.1
# 【來源】Holy87 / H87 Popup v1.1。原始文件為義大利文；Phase 18 將實際維護資訊整理成繁中，原作者／版本資訊仍保留。
# 【用途】在 Scene_Map 顯示可堆疊 Popup，可自動提示取得／失去金錢、取得／失去物品、Level Up／新技能，以及測試模式下的 Switch／Variable 變化；也提供事件自訂 Popup API。
# 【Script Call】Popup.show("訊息")；Popup.show("訊息", icon_id)；Popup.show("訊息", icon_id, [R,G,B,S])。只有目前 $scene 是 Scene_Map 時才顯示。Popup.esegui("SE檔名") 可播放音效。
# 【一般設定】Speed=3（數值越小進場越快）；Time=1 秒後開始淡出；Fade=12 淡出速度；Altezza=355 為初始 Y；Grafica='BarraPopup'；Distanzax=5、Distanzay=3；Switch=2 控制自動 Popup；ShowInTest=false 控制測試模式 Switch/Variable Debug Popup。
# 【物品】SuonoOggetto='Item1'；ItemPreso=[-50,0,70,0] 為 Tone。
# 【金錢】Iconaoro=205；SuonoOro='Shop'；Mostra_OroU／Mostra_OroD 決定取得／失去金錢是否自動顯示；GoldTone 與 GoldPerso 分別控制兩種色調。
# 【Level Up】MostraLevel／MostraPoteri 控制是否以 Popup 顯示升級／新技能；IconaLevel=62；LivSup／NuoveSkill 控制 Tone；SuonoLevel='Up'；Learn='appresa!' 是原 Runtime 顯示字串，若要中文化遊戲文字應另做 UI 文案版本，不與文件翻譯混在一起。
# 【測試提示】Iconaswitch=80、SwitchTone=[0,0,0,255]；Game_Interpreter#command_121／122 會在設定允許時提示 Switch／Variable 變更。
# 【相關素材】Graphics/Pictures/BarraPopup；Audio/SE/Item1、Shop、Up。這些是目前可直接從腳本確認的固定素材，退休本系統時才可列為專用素材候選，仍需反查其他用途。
# 【載入順序】會 alias Scene_Map#start/update/terminate、Game_Party#gain_gold/gain_item，並覆寫／包裝 Game_Actor Level Up 與 Game_Interpreter 事件命令；不可隨意搬到相關 FS Event／UI Patch 後方。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["H87_Popup"] = true
#===============================================================================
# Versione 1.1
#===============================================================================
# Popup.show("messaggio")
# Oppure
# Popup.show("Messaggio",x) dove x sta all'id dell'icona
# Popup.show("Messaggio",x,[R,G,B,S]) dove RGB sono le tonalità, S la saturazione.
#-------------------------------------------------------------------------------
# INSTALLAZIONE
#===============================================================================
module H87_Popup
#-------------------------------------------------------------------------------
# CONFIGURAZIONE GENERALE
#-------------------------------------------------------------------------------
  Speed = 3
  #-----------------------------------------------------------------------------
  Time = 1
  #-----------------------------------------------------------------------------
  Fade = 12
  #-----------------------------------------------------------------------------
  Altezza = 355
  #-----------------------------------------------------------------------------
  Grafica = "BarraPopup"
  #-----------------------------------------------------------------------------
  Distanzax = 5
  Distanzay = 3
  #-----------------------------------------------------------------------------
  Switch = 2
  #-----------------------------------------------------------------------------
  ShowInTest = false
#-------------------------------------------------------------------------------
# CONFIGURAZIONE SPECIFICA
#-------------------------------------------------------------------------------
  SuonoOggetto = "Item1"
  ItemPreso= [-50,0,70,0]
  #-----------------------------------------------------------------------------
  Iconaoro = 205
  SuonoOro = "Shop"
  Mostra_OroU = false
  Mostra_OroD = false
  GoldTone = [-50,70,0,10]
  GoldPerso= [70,0,-50,50]
  #-----------------------------------------------------------------------------
  MostraLevel = false
  MostraPoteri = false
  IconaLevel = 62
  LivSup      = [ 50, 50,100,0]
  NuoveSkill  = [ 50, 50,50,0]
  SuonoLevel = "Up"
  Learn = "appresa!"
  #-----------------------------------------------------------------------------
  Iconaswitch = 80
  SwitchTone = [0,0,0,255]
  #-----------------------------------------------------------------------------
#===============================================================================
# FINE CONFIGURAZIONE
#===============================================================================
end
#===============================================================================
#===============================================================================
module Popup
  def self.show(testo, icona=0, tone=nil)
    $scene.mostra_popup(testo, icona, tone) if $scene.is_a?(Scene_Map)
  end
  
  def self.esegui(suono)
    RPG::SE.new(suono,80,100).play if $scene.is_a?(Scene_Map)
  end
end

#===============================================================================
#===============================================================================
class Scene_Map < Scene_Base
  include H87_Popup
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87_pstart start
  def start
    h87_pstart
    @popups = []
    @oblo = Viewport.new(0,0,Graphics.width,Graphics.height)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87_pupdate update
  def update
    h87_pupdate
    aggiorna_popups
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def mostra_popup(testo, icona=0, tone=nil)
    immagine = Sprite.new(@oblo)
    immagine.bitmap = Cache.picture(Grafica)
    immagine.tone = Tone.new(tone[0],tone[1],tone[2],tone[3]) if tone != nil
    finestra = Window_Map_Popup.new(immagine.width,testo, icona)
    finestra.opacity = 0
    finestra.x = 0-finestra.width
    finestra.y = Altezza
    immagine.x = riposizionax(finestra,immagine)
    immagine.y = riposizionay(finestra,immagine)
    popup = [finestra,immagine,0,0]
    sposta_popup_su
    @popups.push(popup)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def riposizionax(finestra,immagine)
    larg=(finestra.width-immagine.width)/2
    return finestra.x+larg
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def riposizionay(finestra,immagine)
    alt=(finestra.height-immagine.height)/2
    return finestra.y+alt
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def aggiorna_popups
    muovi_popup
    fade_popup
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def muovi_popup
    for i in 0..@popups.size-1
      break if @popups[i] == nil
      barra = @popups[i]
      finestra = barra[0]
      next if finestra.disposed?
      immagine = barra[1]
      tempo    = barra[2]
      prossimay= barra[3]
      x = finestra.x
      y = finestra.y
      metax = Distanzax
      if Altezza > Graphics.height/2
        metay = Altezza - Distanzay - prossimay
      else
        metay = Altezza + Distanzay + prossimay
      end
      finestra.x += (metax-x)/Speed
      finestra.y += (metay-y)/Speed
      tempo += 1
      immagine.x = riposizionax(finestra,immagine)
      immagine.y = riposizionay(finestra,immagine)
      if tempo > Time*Graphics.frame_rate
        finestra.contents_opacity -= Fade
        immagine.opacity -= Fade
      end
      @popups[i] = [finestra,immagine,tempo, prossimay] #riassemblamento
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def sposta_popup_su
    for i in 0..@popups.size-1
      next if @popups[i][1].disposed?
      @popups[i][3]+=@popups[i][1].height+Distanzay
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87_pterminate terminate
  def terminate
    h87_pterminate
    for i in 0..@popups.size-1
      elimina_elemento(i)
    end
    @oblo.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def fade_popup
    for i in 0..@popups.size-1
      next if @popups[i][1].disposed?
      if @popups[i][1].opacity == 0
        elimina_elemento(i)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def elimina_elemento(i)
    @popups[i][0].dispose unless @popups[i][0].disposed?
    @popups[i][1].dispose unless @popups[i][1].disposed?
  end
  
end

#===============================================================================
#===============================================================================
class Window_Map_Popup < Window_Base
  def initialize(larghezza,testo, icona=0)
    super(0,0,larghezza,WLH+32)
    @testo = testo
    @icona = icona
    refresh
  end
  
  def refresh
    self.contents.clear
    unless @icona == 0
      draw_icon(@icona,0,0)
      dist = 24
    else
      dist = 0
    end
    self.contents.draw_text(dist,0,self.width-(32+dist),WLH,@testo)
  end
end #Scene_Map

#===============================================================================
#===============================================================================
class Game_Party < Game_Unit
  alias ottieni_oro gain_gold
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def gain_gold(n)
    if $game_switches[H87_Popup::Switch] == false
      if n> 0 and H87_Popup::Mostra_OroU
        Popup.show("+"+n.to_s+Vocab.gold,H87_Popup::Iconaoro,H87_Popup::GoldTone)
        Popup.esegui(H87_Popup::SuonoOro)
      end
      if n < 0 and H87_Popup::Mostra_OroD
        Popup.show(n.to_s+Vocab.gold,H87_Popup::Iconaoro,H87_Popup::GoldPerso)
        Popup.esegui(H87_Popup::SuonoOro)
      end
    end
    ottieni_oro(n)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias prendi_oggetto gain_item
  def gain_item(item, n, include_equip = false)
    case item
    when RPG::Item
      oggetto = $data_items[item.id]
    when RPG::Armor
      oggetto = $data_armors[item.id]
    when RPG::Weapon
      oggetto = $data_weapons[item.id]
    end
    if n > 0 and $game_switches[H87_Popup::Switch] == false and item != nil
      nome = oggetto.name
      icona = oggetto.icon_index
      testo = sprintf("%s x%d",nome,n)
      Popup.show(testo,icona,H87_Popup::ItemPreso)
      Popup.esegui(H87_Popup::SuonoOggetto)
    end
    prendi_oggetto(item, n, include_equip)
  end
  
end # Game_Party

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def display_level_up(new_skills)
    if $scene.is_a?(Scene_Map) and H87_Popup::MostraLevel
      testo = sprintf("%s %s%d!",@name,Vocab::level,@level)
      Popup.show(testo,H87_Popup::IconaLevel,H87_Popup::LivSup)
      Popup.esegui(H87_Popup::SuonoLevel)
      if H87_Popup::MostraPoteri
        for skill in new_skills
          testo = sprintf("%s %s",skill.name,H87_Popup::Learn)
          Popup.show(testo,skill.icon_index,H87_Popup::NuoveSkill)
        end
      end
    else
      $game_message.new_page
      text = sprintf(Vocab::LevelUp, @name, Vocab::level, @level)
      $game_message.texts.push(text)
      for skill in new_skills
        text = sprintf(Vocab::ObtainSkill, skill.name)
        $game_message.texts.push(text)
      end
    end
  end
end # Game_Actor

#===============================================================================
#===============================================================================
if H87_Popup::ShowInTest and $TEST
class Game_Interpreter
  alias comando121 command_121
  def command_121
    for i in @params[0] .. @params[1] 
      nome = $data_system.switches[i]
      id = i
      stato = @params[2] == 0 ? "ON" : "OFF"
      tone = H87_Popup::SwitchTone
      testo = sprintf("[%d] %s: %s",id,nome,stato)
      Popup.show(testo,H87_Popup::Iconaswitch,tone)
    end
    comando121
  end

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # Operando
    when 0  # Costante
      value = @params[4]
    when 1  # Variabile
      value = $game_variables[@params[4]]
    when 2
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # Oggetto
      value = $game_party.item_number($data_items[@params[4]])
    when 4  # Eroe
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # Livello
          value = actor.level
        when 1  # Esperienza
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4
          value = actor.maxhp
        when 5
          value = actor.maxmp
        when 6  # Attacco
          value = actor.atk
        when 7  # Difesa
          value = actor.def
        when 8  # Spirito
          value = actor.spi
        when 9
          value = actor.agi
        end
      end
    when 5  # Nemico
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2
          value = enemy.maxhp
        when 3
          value = enemy.maxmp
        when 4  # Attacco
          value = enemy.atk
        when 5  # Difesa
          value = enemy.def
        when 6  # Spirito
          value = enemy.spi
        when 7
          value = enemy.agi
        end
      end
    when 6  # Personaggio
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0
          value = character.x
        when 1
          value = character.y
        when 2  # direzione
          value = character.direction
        when 3
          value = character.screen_x
        when 4
          value = character.screen_y
        end
      end
    when 7  # Altro
      case @params[4]
      when 0
        value = $game_map.map_id
      when 1
        value = $game_party.members.size
      when 2  # oro
        value = $game_party.gold
      when 3  # passi
        value = $game_party.steps
      when 4
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        value = $game_system.timer / Graphics.frame_rate
      when 6
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]
      case @params[2]  # Operazione
      when 0  # Setta
        $game_variables[i] = value
      when 1  # Aggiungi
        $game_variables[i] += value
      when 2  # Sottrai
        $game_variables[i] -= value
      when 3  # Moltiplica
        $game_variables[i] *= value
      when 4  # Dividi
        $game_variables[i] /= value if value != 0
      when 5  # Resto
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    valore = $game_variables[i]
    nome = $data_system.variables[i]
    tone = H87_Popup::SwitchTone
    testo = sprintf("[%2d] %s = %d",i,nome,valore)
    Popup.show(testo,H87_Popup::Iconaswitch,tone)
    $game_map.need_refresh = true
    return true
  end
end # Game_Interpreter
end