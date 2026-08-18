#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：SkillCost_LegacyBase｜Holy87 Parser / UI / Battle Timing Bridge
# 【來源】Holy87 `Costo abilità` v1.2；原文義大利文。此頁是目前 FS Skill Cost 鏈的 Legacy Base，不是最終 Authority。
# 【用途】保留 Holy87 技能消耗的 Notetag／RPG::Skill legacy accessor／技能視窗顯示，以及「戰鬥支付時序 Bridge」。Phase 24 起不再擁有最終成本計算、可用判定或選單支付規則。
# 【Notetag】`<costo hp: x>` / `<costo hp: x%>`；`<costo mp: x>` / `%`；`<costo oro: x>` / `%`；`<costo var: x>` / `%`；`<usa oggetto: x>`；`<costo angry: x>`；`<costo state: x>`。Notetag 名稱是 Runtime API，不翻譯。
# 【Variable】`Skill_Costs::Variabile = 281`，顯示符號「氣」；Angry 顯示符號「怒」。半消耗設定 Dimezza_C_HP/G/V=true，A/S=false。
# 【顏色】ColoreHP=11、MP=5、Gold=6、Variable=2、Angry=1、State=1；Spazio=12。
# 【Load Order／最重要】Phase 24 起 `Skill Cost Fix` 已退休；最終規則由 `FS_SkillCost_Authority v2.0.0` 負責。本頁必須留在 H87 SkillDelay 等舊系統之前，以保留 parser/UI 與既有戰鬥支付時序 Bridge；Bridge 會在 Runtime 晚綁定呼叫最終 Authority 的支付政策。
# 【Phase 24】已移除本頁重複的 `calc_*`／`skill_can_use?`／選單支付實作；只留下資料格式、UI 與 battle timing bridge。未來若要連 Bridge 都移除，必須先證明 CharacterMechanic／SummonChain／MechanicExpansion 等外層對支付時點沒有依賴。
# 【素材】無固定 Graphics/Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
$imported = {} if $imported == nil
$imported["CostoHoly"] = true
#===============================================================================
# 以下為實際 Runtime 程式；成本 Notetag 與設定請見頁首繁中完整說明。
#===============================================================================
module Skill_Costs
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
  Variabile = 281
  Simbolo_Variabile = "氣"
  Simbolo_Angry = "怒"
 
  Dimezza_C_HP = true
  Dimezza_C_G = true
  Dimezza_C_V = true
# 消耗減半是否影響怒氣？
  Dimezza_C_A = false
# 消耗減半是否影響狀態需求？
  Dimezza_C_S = false 

  ColoreHP  = 11
  ColoreMP  = 5#11是綠色
  ColoreG   = 6
  ColoreV   = 2
  ColoreA   = 1
  ColoreS   = 1
 
# 兩種消耗顯示中間的間隔
  Spazio = 12
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
 
  CostoHP  = /<(?:COSTO HP|costo hp):[ ]*(\d+)>/i
  CostoMP  = /<(?:COSTO MP|costo mp):[ ]*(\d+)>/i
  CostoG   = /<(?:COSTO ORO|costo oro):[ ]*(\d+)>/i
  CostoV   = /<(?:COSTO VAR|costo var):[ ]*(\d+)>/i
  CostoI   = /<(?:USA OGGETTO|usa oggetto):[ ]*(\d+)>/i
  CostoA   = /<(?:COSTO ANGRY|costo angry):[ ]*(\d+)>/i
  CostoS   = /<(?:COSTO STATE|costo state):[ ]*(\d+)>/i
 
  CostoHP_Per = /<(?:COSTO HP|costo hp):[ ]*(\d+)([%％])>/i
  CostoMP_Per = /<(?:COSTO MP|costo mp):[ ]*(\d+)([%％])>/i
  CostoG_Per  = /<(?:COSTO ORO|costo oro):[ ]*(\d+)([%％])>/i
  CostoV_Per  = /<(?:COSTO VAR|costo var):[ ]*(\d+)([%％])>/i
 
  def self.var_act
	return $game_variables[Variabile]
  end
 
end # 詳見頁首繁中說明
 
#===============================================================================
#===============================================================================
 
class RPG::Skill
  attr_accessor :costohp
  attr_accessor :costog
  attr_accessor :costov
  attr_accessor :costohp_per
  attr_accessor :costomp_per
  attr_accessor :costog_per
  attr_accessor :costov_per
  attr_accessor :costoi
  attr_accessor :costoangry
  attr_accessor :costostate
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def carica_cache_personale
	return if @cache_caricata
	@cache_caricata = true
	@costohp = 0
	@costog = 0
	@costov = 0
	@costohp_per = 0
	@costomp_per = 0
	@costog_per = 0
	@costov_per = 0
	@costoi = 0
  @costoangry = 0
  @costostate = 0
	self.note.split(/[\r\n]+/).each { |riga|
	  case riga
	  #---
	  when Skill_Costs::CostoHP
		@costohp = $1.to_i
	  when Skill_Costs::CostoMP
		@mp_cost = $1.to_i
	  when Skill_Costs::CostoG
		@costog = $1.to_i
	  when Skill_Costs::CostoV
		@costov = $1.to_i
	  when Skill_Costs::CostoHP_Per
		@costohp_per = $1.to_i
	  when Skill_Costs::CostoMP_Per
		@costomp_per = $1.to_i
	  when Skill_Costs::CostoG_Per
		@costog_per = $1.to_i
	  when Skill_Costs::CostoV_Per
		@costov_per = $1.to_i
	  when Skill_Costs::CostoI
		@costoi = $1.to_i
    when Skill_Costs::CostoA
		@costoangry = $1.to_i
    when Skill_Costs::CostoS
		@costostate = $1.to_i
	  end
	}
  end
 
  def costohp;return @costohp;end
  def costog;return @costog;end
  def costov;return @costov;end
  def costoi;return @costoi;end
  def costohp_per;return @costohp_per;end
  def costomp_per;return @costomp_per;end
  def costog_per;return @costog_per;end
  def costov_per;return @costov_per;end
  def costoangry;return @costoangry;end
  def costostate;return @costostate;end
 
 
end # 詳見頁首繁中說明
 
#===============================================================================
#===============================================================================
class Scene_Title < Scene_Base
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias carica_db load_bt_database unless $@
  def load_bt_database
	carica_db
	carica_skills
  end
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  alias carica_db_2 load_database unless $@
  def load_database
	carica_db_2
	carica_skills
  end
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def carica_skills
	for skill in $data_skills
	  next if skill == nil
	  skill.carica_cache_personale
	end
  end
 
end # 詳見頁首繁中說明
 
#===============================================================================
#===============================================================================
#==============================================================================
# ■ Phase 24：成本計算／可用判定已移交 FS_SkillCost_Authority v2.0.0
#------------------------------------------------------------------------------
# 本頁不再定義 calc_mp_cost / calc_hp_cost / calc_gold_cost / calc_var_cost /
# calc_angry_cost / calc_state_cost / calc_item_cost / skill_can_use?。
# Window_Skill 在實際開啟時會呼叫後方 Authority 的最終方法。
#==============================================================================

class Window_Skill < Window_Selectable
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def draw_item(index)
	rect = item_rect(index)
	self.contents.clear_rect(rect)
	skill = @data[index]
	if skill != nil
	  rect.width -= 4
	  enabled = @actor.skill_can_use?(skill) # 詳見頁首繁中說明
	  draw_item_name11(skill, rect.x, rect.y, enabled)
	  posizione = 0
	  gfont = Skill_Costs::Spazio
	  if skill.costoi != 0
		oggetto = $data_items[skill.costoi]
		draw_icon(oggetto.icon_index,rect.x+rect.width-24,rect.y,enabled)
		posizione += 24
    end
    ################顯示狀態ICON
    if skill.costostate != 0
		oggetto1 = $data_states[skill.costostate]
		draw_icon(oggetto1.icon_index,rect.x+rect.width-24,rect.y,enabled)
		posizione += 24
	  end
    ################
    if @actor.calc_angry_cost(skill) > 0
		self.contents.font.color = colore_angry
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_angry_cost(skill)
		costo = costo.to_s+Vocab.angry_skill
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
    ################
	  if @actor.calc_hp_cost(skill) > 0
		self.contents.font.color = colore_hp
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_hp_cost(skill)
		costo = costo.to_s+Vocab.hp_a
		self.contents.draw_text(rect, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_mp_cost(skill) > 0
		self.contents.font.color = colore_mp
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_mp_cost(skill)
		costo = costo.to_s+Vocab.mp_a
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_var_cost(skill) > 0
		self.contents.font.color = colore_var
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_var_cost(skill)
		costo = costo.to_s+Vocab.var_skill
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_gold_cost(skill) > 0
		self.contents.font.color = colore_gold
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_gold_cost(skill)
		costo = costo.to_s+Vocab.gold
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
	  end
	end
  end
else
 
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================
class Window_Skill2 < Window_Selectable
 
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def draw_item(index)
	rect = item_rect(index)
	self.contents.clear_rect(rect)
  self.contents.font.size = 17
	skill = @data[index]
	if skill != nil
	  rect.width -= 4
	  enabled = @actor.skill_can_use?(skill) # 詳見頁首繁中說明
	  draw_item_name11(skill, rect.x, rect.y, enabled)
	  posizione = 0
	  gfont = Skill_Costs::Spazio
	  if skill.costoi != 0
		oggetto = $data_items[skill.costoi]
		draw_icon(oggetto.icon_index,rect.x+rect.width-24,rect.y,enabled)
		posizione += 24
    end
    ################顯示狀態ICON
    if skill.costostate != 0
		oggetto1 = $data_states[skill.costostate]
		draw_icon(oggetto1.icon_index,rect.x+rect.width-24,rect.y,enabled)
		posizione += 24
	  end
    ################
    if @actor.calc_angry_cost(skill) > 0
      self.contents.font.size = 14
		self.contents.font.color = colore_angry
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_angry_cost(skill)
		costo = costo.to_s+Vocab.angry_skill
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
    ################
	  if @actor.calc_hp_cost(skill) > 0
      self.contents.font.size = 14
		self.contents.font.color = colore_hp
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_hp_cost(skill)
		costo = costo.to_s+Vocab.hp_a
		self.contents.draw_text(rect, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_mp_cost(skill) > 0
      self.contents.font.size = 14
		self.contents.font.color = colore_mp
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_mp_cost(skill)
		costo = costo.to_s+Vocab.mp_a
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_var_cost(skill) > 0
      self.contents.font.size = 14
		self.contents.font.color = colore_var
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_var_cost(skill)
		costo = costo.to_s+Vocab.var_skill
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
		posizione += gfont*costo.size
	  end
	  if @actor.calc_gold_cost(skill) > 0
      self.contents.font.size = 14
		self.contents.font.color = colore_gold
		self.contents.font.color.alpha = enabled ? 255 : 128
		costo = @actor.calc_gold_cost(skill)
		costo = costo.to_s+Vocab.gold
		self.contents.draw_text(rect.x,rect.y,rect.width-posizione,rect.height, costo, 2)
	  end
	end
  end
else
 
end # 詳見頁首繁中說明
 
#===============================================================================
#===============================================================================
class Scene_Battle < Scene_Base
  unless method_defined?(:fs_skill_cost_timing_bridge_execute_action_skill)
    alias fs_skill_cost_timing_bridge_execute_action_skill execute_action_skill
  end

  # Phase 24：保留舊支付發生的 alias-chain 位置，但支付政策由最終 Authority 提供。
  def execute_action_skill(*args)
    result = fs_skill_cost_timing_bridge_execute_action_skill(*args)

    battler = @active_battler
    skill = nil
    begin
      skill = battler.action.skill if battler != nil && battler.action != nil
    rescue
      skill = nil
    end
    return result if battler == nil || skill == nil

    if defined?(FS_SKILL_COST_ALLFIX) &&
       FS_SKILL_COST_ALLFIX.respond_to?(:pay_battle_legacy_costs)
      FS_SKILL_COST_ALLFIX.pay_battle_legacy_costs(battler, skill)
    else
      raise "FS_SkillCost_Authority v2.0.0 未載入：無法執行戰鬥技能成本支付。"
    end

    return result
  end
end

#==============================================================================
#===============================================================================

class Window_Base < Window
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def colore_mp;return text_color(Skill_Costs::ColoreMP);end
  def colore_hp;return text_color(Skill_Costs::ColoreHP);end
  def colore_gold;return text_color(Skill_Costs::ColoreG);end
  def colore_var;return text_color(Skill_Costs::ColoreV);end
  def colore_angry;return text_color(Skill_Costs::ColoreA);end
 
end # 詳見頁首繁中說明
 
#===============================================================================
#===============================================================================
#==============================================================================
# ■ Phase 24：選單支付已由 FS_SkillCost_Authority v2.0.0 單一擁有
#==============================================================================

module Vocab
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.var_skill
	return Skill_Costs::Simbolo_Variabile
  end
  def self.angry_skill
	return Skill_Costs::Simbolo_Angry
  end
end # 詳見頁首繁中說明