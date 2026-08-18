#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_隱藏技能
# 【用途】技能系統元件「KGC_隱藏技能」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】RPG::Skill、Window_Skill、KGC、HiddenSkill、KGC::HiddenSkill、Regexp、Skill
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：HIDE_PASSIVE_SKILL、HIDDEN。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：HiddenSkill、PassiveSkill。
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
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/ ◆ Hidden Skills - KGC_HiddenSkill ◆ VX ◆
#_/ ◇  Last update: 01/18/0209
#_/ ◆ Written by TOMY     
#_/ ◆ Translation by Mr. Anonymous                  
#_/ ◆ KGC Site:                                                   
#_/ ◆  http://ytomy.sakura.ne.jp/                                   
#_/ ◆ Translator's Blog:                                             
#_/ ◆  http://mraprojects.wordpress.com     
#_/-----------------------------------------------------------------------------
#_/  This script allows a designer to assign certain skills as 'hidden'.
#_/  It primarly enhances effects like passive skills. I'm sure there are other
#_/  creative uses. To utilize this effect, add <HIDDEN> or <hide> in the 
#_/  specified skill's "Note" box.
#_/  This script is meant to augment the KCG_PassiveSkill script.
#_/  That script is not required however.
#_/=============================================================================
#_/                      ◆ 2008/03/08 UPDATE [KGC] ◆           
#_/                     Compatablity with KGC_OverDrive
#_/=============================================================================
#_/  Installation Note: Insert above other skill-related scripts.
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_

#==============================================================================#
#                             ★ Customization ★                                #
#==============================================================================#

module KGC
 module HiddenSkill
  # This toggle automatically hides all skills tagged as <passive> when used
  #  in conjunction with KGC_PassiveSkill
  HIDE_PASSIVE_SKILL = false
 end
end

# The Trigger for this effect is <hide> or <HIDDEN>.

#------------------------------------------------------------------------------#

$imported = {} if $imported == nil
$imported["HiddenSkill"] = true

module KGC::HiddenSkill
  # Regular Expression Definition 
  module Regexp
    # Base Skill Module
    module Skill
      # Hidden (skill) String Tag
      HIDDEN = /<(?:hide|HIDDEN)\s*
                (menu|battle|MENU|BATTLE)?>/ix
    end
  end
end

#==============================================================================
# ■ RPG::Skill
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ○ If the skill isn't hidden...
  #--------------------------------------------------------------------------
  def create_hidden_skill_cache
    @__hidden_in_menu   = false
    @__hidden_in_battle = false

    self.note.each_line { |line|
      case line
      when KGC::HiddenSkill::Regexp::Skill::HIDDEN
        case $1
        when /^menu|非戦闘|MENU/i
          @__hidden_in_menu   = true
        when /^battle|BATTLE/i
          @__hidden_in_battle = true
        when nil
          @__hidden_in_menu   = true
          @__hidden_in_battle = true
        end
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ Hidden In Menu
  #--------------------------------------------------------------------------
  def hidden_in_menu?
    create_hidden_skill_cache if @__hidden_in_menu == nil
    return @__hidden_in_menu
  end
  #--------------------------------------------------------------------------
  # ○ Hidden In Battle
  #--------------------------------------------------------------------------
  def hidden_in_battle?
    create_hidden_skill_cache if @__hidden_in_battle == nil
    return @__hidden_in_battle
  end
end

#==============================================================================
# ■ Window_Skill
#------------------------------------------------------------------------------
# Imports settings incase KCG_PassiveSkill is imported.
#==============================================================================

class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ Import Passive Skills
  #     skill : passive
  #--------------------------------------------------------------------------
  unless $@
    alias include_KGC_HiddenSkill? include? if method_defined?(:include?)
  end
  def include?(skill)
    return false if skill == nil

    if defined?(include_KGC_HiddenSkill?)
      return false unless include_KGC_HiddenSkill?(skill)
    end

    if $game_temp.in_battle
      return false if skill.hidden_in_battle?
      #return false if @actor.skill_can_use?(skill) == false###
    else
      return false if skill.hidden_in_menu?
    end

    if $imported["PassiveSkill"] && KGC::HiddenSkill::HIDE_PASSIVE_SKILL
      return false if skill.passive
    end

    return true
  end
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for skill in @actor.skills
      next unless include?(skill)
      @data.push(skill)
      if skill.id == @actor.last_skill_id
        self.index = @data.size - 1
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
end
