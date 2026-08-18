#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：H87 Skill Delay v1.1
# 【來源】Holy87，2013-02-03 v1.1（原文件義大利文）。
# 【用途】替 Skill 加「冷卻／充能」：可依使用者行動回合、戰鬥場次或地圖步數恢復。冷卻期間 skill_can_use? 回傳 false，Skill Window 會用格／Bar 顯示剩餘量。
# 【Notetag】<ricarica turni: x>：使用後等待 x 個該角色行動回合；<ricarica battaglie: x>：等待 x 場戰鬥；<ricarica passi: x>：走 x 步。三種同時存在時解析順序會讓後者覆蓋前者，正式資料建議每個 Skill 只寫一種。
# 【ATB 注意】在 ATB 下「回合」不是全場 round，而是該角色每次完成行動後 scale_turn，所以角色行動越快，turn cooldown 下降越快。
# 【設定】ColorTurn/ColorBack、ColorBatt/ColorBac2、ColorStep/ColorBac3 控制 Gauge 色號；Lgzz 控制高度；RICARICA=true 代表戰鬥結束時把 turn cooldown 全清；RICOVERO=true 代表 recover_all 時全部充滿；MAP_VIS=true 代表選單也顯示 turn cooldown。
# 【Popup】若 $imported['H87_Popup'] 且 UsePopup=true，step cooldown 歸零時顯示 Popup；PopupColor=[0,100,150,20]、SE='Skill'、TXT='%s di %s pronto!'。TXT 是實際遊戲文字，若要中文化需另做文案調整，不在文件翻譯中偷改 Runtime。
# 【資料載入】Scene_Title#load_database/load_bt_database 後會呼叫 carica_skills3 建立 Skill cache。Game_Battler 保存 turn_skills/battle_skills/step_skills；Game_Party#increase_steps 處理步數冷卻。
# 【戰鬥鉤子】Scene_Battle#turn_end、execute_action_skill、execute_action、process_victory、start/terminate 會更新 cooldown；Window_Skill／Window_Skill2 顯示剩餘量；Scene_Skill 在非目標 Skill 使用後也會加入 cooldown。
# 【載入順序】原作者要求放 Materials、Main 前，若有 Alternative Skill Cost 則放其下；目前 FS 還有 Tankentai/ATB/SkillCost 修正，因此維持現有位置，不應為了把技能系統集中而任意搬動。
# 【相關素材】Audio/SE/Skill（僅 Popup 充能完成時）；Gauge 以視窗內容繪製，無固定圖檔。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
$imported = {} if $imported == nil
$imported["H87_SkillDelay"] = true
#===============================================================================
#===============================================================================
#===============================================================================
=begin
<ricarica turni: x>技能需要等待 X 個回合 才能再次使用
<ricarica battaglie: x>技能在 X 場戰鬥後 重新可用
<ricarica passi: x>技能在 玩家移動 X 步後 重新可用
=end
#===============================================================================
#===============================================================================
#===============================================================================

module H87_Delay
#===============================================================================
#===============================================================================
  ColorTurn = 3
  ColorBack = 7
  ColorBatt = 10
  ColorBac2 = 7
  ColorStep = 17
  ColorBac3 = 7
  
  Lgzz = 1
  
  RICARICA = true
  
  RICOVERO = true
  
  MAP_VIS = true
  
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
  UsePopup = true
  
               #R  G    B    S
  PopupColor = [0, 100, 150, 20]
  SE = "Skill"
  TXT = "%s di %s pronto!"
  
#===============================================================================
# 以下為核心實作；除非已確認依賴鏈，請勿任意修改。
#===============================================================================



#===============================================================================
  DelayTurn    = /<(?:RICARICA TURNI|ricarica turni):[ ]*(\d+)>/i
  DelayBattle  = /<(?:RICARICA BATTAGLIE|ricarica battaglie):[ ]*(\d+)>/i
  DelayStep    = /<(?:RICARICA PASSI|ricarica passi):[ ]*(\d+)>/i
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.allow_popup?
    return false unless $imported["H87_Popup"]
    return false unless UsePopup
    return true
  end
  
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Game_Battler
  attr_accessor :turn_skills # 詳見頁首繁中維護說明
  attr_accessor :battle_skills # 詳見頁首繁中維護說明
  attr_accessor :step_skills # 詳見頁首繁中維護說明
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias inizializza_turni initialize unless $@
  def initialize
    inizializza_turni
    @turn_skills = {}
    @battle_skills = {}
    @step_skills = {}
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def turn_skills
    @turn_skills = {} if @turn_skills == nil
    return @turn_skills
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def battle_skills
    @battle_skills = {} if @battle_skills == nil
    return @battle_skills
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def step_skills
    @step_skills = {} if @step_skills == nil
    return @step_skills
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_turn_skill(skill)
    @turn_skills[skill.id] = skill.turn_delay
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def flush_turn_skills
    @turn_skills = {} if @turn_skills == nil
    @turn_skills.clear
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_battle_skill(skill)
    @battle_skills[skill.id] = skill.battle_delay
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_step_skill(skill)
    @step_skills[skill.id] = skill.step_delay
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def scale_turn
    return unless $imported["TankentaiATB"]  # 確保 ATB 模式開啟
  @turn_skills.each_key do |skill_id|
    @turn_skills[skill_id] -= 1 if @turn_skills[skill_id] > 0
    @turn_skills.delete(skill_id) if @turn_skills[skill_id] <= 0
  end
    #}
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def scale_battle
    @battle_skills = {} if @battle_skills == nil
    @battle_skills.each_key { |delay|
      @battle_skills[delay] -= 1
      @battle_skills.delete(delay) if @battle_skills[delay] <= 0
    }
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def scale_step
    @step_skills = {} if @step_skills == nil
    @step_skills.each_key do |delay|
      @step_skills[delay] -= 1
      if @step_skills[delay] <= 0
        @step_skills.delete(delay)
        show_popup($data_skills[delay]) if H87_Delay.allow_popup?
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def show_popup(delay)
    RPG::SE.new(H87_Delay::SE).play
    text = sprintf(H87_Delay::TXT,delay.name,name)
    Popup.show(text,delay.icon_index,H87_Delay::PopupColor)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias usabile_da_delay skill_can_use? unless $@
  def skill_can_use?(skill)
    return if skill == nil
    return false if no_charged(skill)
    return usabile_da_delay(skill)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def no_charged(skill)
    return false unless @turn_skills.include?(skill.id)  # 只有在技能使用過後才進入冷卻
  return true if skill.turn_delay > 0 && @turn_skills[skill.id] > 0
  return true if skill.battle_delay > 0 && @battle_skills[skill.id] > 0
  return true if skill.step_delay > 0 && @step_skills[skill.id] > 0
  return false
  end
  
  def recharge_all
    flush_turn_skills
    @battle_skills = {} if @battle_skills == nil
    @battle_skills.clear
    @step_skills = {} if @step_skills == nil
    @step_skills.clear
  end
  
  alias rec_skill_all recover_all unless $@
  def recover_all
    rec_skill_all
    recharge_all if H87_Delay::RICOVERO
  end
  
  
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class RPG::Skill
  attr_accessor :turn_delay # 詳見頁首繁中維護說明
  attr_accessor :battle_delay # 詳見頁首繁中維護說明
  attr_accessor :step_delay # 詳見頁首繁中維護說明
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def carica_cache_personale3
    return if @cache_caricata3
    @cache_caricata3 = true
    @turn_delay = 0
    @battle_delay = 0
    @step_delay = 0
    self.note.split(/[\r\n]+/).each { |riga|
      case riga
      #---
      when H87_Delay::DelayTurn
        @turn_delay = $1.to_i
      when H87_Delay::DelayBattle
        @battle_delay = $1.to_i
        @turn_delay = 0
      when H87_Delay::DelayStep
        @step_delay = $1.to_i
        @battle_delay = 0
        @turn_delay = 0
      end
    }
  end
  
  def turn_delay;   return @turn_delay;   end
  def battle_delay; return @battle_delay; end
  def step_delay;   return @step_delay;   end
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Scene_Title < Scene_Base
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias carica_db3 load_bt_database unless $@
  def load_bt_database
    carica_db3
    carica_skills3
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias carica_db_23 load_database unless $@
  def load_database
    carica_db_23
    carica_skills3
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def carica_skills3
    for skill in $data_skills
      next if skill == nil
      skill.carica_cache_personale3
    end
  end
  
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Scene_Battle < Scene_Base
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87starter start unless $@
  def start
    h87starter
    reset_turni if H87_Delay::RICARICA
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias terminater3 terminate unless $@
  def terminate
    terminater3
    reset_turni if H87_Delay::RICARICA
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def reset_turni
    $game_party.members.each do |member|
      member.flush_turn_skills
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87te turn_end unless $@
  def turn_end(member = nil)
    h87te(member)
    scale_all unless $imported["TankentaiATB"]
  end
  
  def scale_all
    $game_party.members.each {|member|member.scale_turn}
  end
  
    
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87eas execute_action_skill unless $@
  def execute_action_skill
    h87eas
    skill = @active_battler.action.skill
    return if @active_battler == nil
    return if skill == nil
    @active_battler.add_turn_skill(skill) if skill.turn_delay > 0
    @active_battler.add_battle_skill(skill) if skill.battle_delay > 0
    @active_battler.add_step_skill(skill) if skill.step_delay > 0
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87ea execute_action unless$@
  def execute_action
    h87ea
    @active_battler.scale_turn if $imported["TankentaiATB"] and @active_battler != nil
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87pv process_victory unless $@
  def process_victory
    h87pv
    $game_party.members.each {|member|
      member.scale_battle
    }
  end
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Window_Skill < Window_Selectable
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87di draw_item unless $@
  def draw_item(index)
    h87di(index)
    rect = item_rect(index)
    skill = @data[index]
    x = rect.x + 24
    y = rect.y + rect.height - H87_Delay::Lgzz
    lenght = rect.width - 24
    if skill.turn_delay > 0 and ($scene.is_a?(Scene_Battle) or H87_Delay::MAP_VIS)
      lb = lenght/skill.turn_delay - 3
      caricato = 0
      caricato = @actor.turn_skills[skill.id] if @actor.turn_skills.include?(skill.id)
      caricato = skill.turn_delay - caricato
      for i in 0..skill.turn_delay-1
        caricato > i ? colore = text_color(H87_Delay::ColorTurn) : colore = text_color(H87_Delay::ColorBack)
        self.contents.fill_rect(x+((lb+3)*i),y,lb,H87_Delay::Lgzz,colore)
      end
    elsif skill.battle_delay > 0
      lb = lenght/skill.battle_delay - 3
      caricato = 0
      caricato = @actor.battle_skills[skill.id] if @actor.battle_skills.include?(skill.id)
      caricato = skill.battle_delay - caricato
      for i in 0..skill.battle_delay-1
        caricato > i ? colore = text_color(H87_Delay::ColorBatt) : colore = text_color(H87_Delay::ColorBac2)
        self.contents.fill_rect(x+((lb+3)*i),y,lb,H87_Delay::Lgzz,colore)
      end
    elsif skill.step_delay > 0
      lb = lenght - 3
      caricato = 0
      caricato = @actor.step_skills[skill.id] if @actor.step_skills.include?(skill.id)
      caricato = skill.step_delay - caricato
      self.contents.fill_rect(x,y,lb,H87_Delay::Lgzz,text_color(H87_Delay::ColorBac3))
      lung = lb.to_f*(caricato.to_f/skill.step_delay.to_f)
      self.contents.fill_rect(x,y,lung,H87_Delay::Lgzz,text_color(H87_Delay::ColorStep))
    end
  end
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Window_Skill2 < Window_Selectable
  #--------------2---------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87di draw_item unless $@
  def draw_item(index)
    h87di(index)
    rect = item_rect(index)
    skill = @data[index]
    x = rect.x + 24
    y = rect.y + rect.height - H87_Delay::Lgzz
    lenght = rect.width - 24
    if skill.turn_delay > 0 and ($scene.is_a?(Scene_Battle) or H87_Delay::MAP_VIS)
      lb = lenght/skill.turn_delay - 3
      caricato = 0
      caricato = @actor.turn_skills[skill.id] if @actor.turn_skills.include?(skill.id)
      caricato = skill.turn_delay - caricato
      for i in 0..skill.turn_delay-1
        caricato > i ? colore = text_color(H87_Delay::ColorTurn) : colore = text_color(H87_Delay::ColorBack)
        self.contents.fill_rect(x+((lb+3)*i),y,lb,H87_Delay::Lgzz,colore)
      end
    elsif skill.battle_delay > 0
      lb = lenght/skill.battle_delay - 3
      caricato = 0
      caricato = @actor.battle_skills[skill.id] if @actor.battle_skills.include?(skill.id)
      caricato = skill.battle_delay - caricato
      for i in 0..skill.battle_delay-1
        caricato > i ? colore = text_color(H87_Delay::ColorBatt) : colore = text_color(H87_Delay::ColorBac2)
        self.contents.fill_rect(x+((lb+3)*i),y,lb,H87_Delay::Lgzz,colore)
      end
    elsif skill.step_delay > 0
      lb = lenght - 3
      caricato = 0
      caricato = @actor.step_skills[skill.id] if @actor.step_skills.include?(skill.id)
      caricato = skill.step_delay - caricato
      self.contents.fill_rect(x,y,lb,H87_Delay::Lgzz,text_color(H87_Delay::ColorBac3))
      lung = lb.to_f*(caricato.to_f/skill.step_delay.to_f)
      self.contents.fill_rect(x,y,lung,H87_Delay::Lgzz,text_color(H87_Delay::ColorStep))
    end
  end
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Scene_Skill < Scene_Base
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87usn use_skill_nontarget unless $@
  def use_skill_nontarget
    h87usn
    if @skill.battle_delay > 0
      @actor.add_battle_skill(@skill) 
      @skill_window.refresh
    elsif @skill.step_delay > 0
      @actor.add_step_skill(@skill) 
      @skill_window.refresh
    end
  end
end # 詳見頁首繁中維護說明

#===============================================================================
#===============================================================================
class Game_Party < Game_Unit
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias h87is increase_steps unless $@
  def increase_steps
    h87is
    $game_party.members.each {|member|
      member.scale_step
    }
  end
end # 詳見頁首繁中維護說明