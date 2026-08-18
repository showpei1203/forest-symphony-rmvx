#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_SkillInfo2
# 【用途】UI／選單元件「Window_SkillInfo2」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_SkillInfo2
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SCOPE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ■ Window_SkillInfo2
#==============================================================================
class Window_SkillInfo2 < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y=WLH*5+64, h=416-(WLH*5+64))
    super(277, y, 264, h)
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  SCOPE = ["なし", "敵単体", "敵全体", "敵単体", 
           "敵単体", "敵二体", "敵三体", "味方単体",
           "味方全体", "味方単体", "味方全体", "使用者"]
  def refresh(skill=nil)
    self.contents.clear
    return if skill.nil?
    ####################
    c_width = contents.text_size(skill.name).width
    dx = (self.width-32)/2 - c_width/2
    self.contents.draw_text(dx, 0, c_width, WLH, skill.name)
    draw_icon(skill.icon_index, dx-24, 0)
    self.contents.font.size = YEZ::JOB::REQUIRE_SIZE
    self.contents.draw_text(0, WLH * 1, self.width-32, WLH, "明細", 1)
    ####################
    self.contents.font.color = system_color
    self.contents.draw_text(0+24, WLH*2, 100, WLH, "属性類別")
    draw_icon(3489,0,WLH*2)
    self.contents.draw_text(0+24, WLH*3, 100, WLH, "効果範囲")
    draw_icon(3504,0,WLH*3)
    self.contents.draw_text(0+24, WLH*4, 100, WLH, "附加")
    draw_icon(516,0,WLH*4)
    self.contents.draw_text(0+24, WLH*5, 100, WLH, "解除")
    draw_icon(517,0,WLH*5)
    #plus_state_set
    #self.contents.draw_text(0, WLH*2, 100, WLH, "命中率")
    #self.contents.draw_text(0, WLH*3, 100, WLH, "属性") if SkillEx::USE_ELE
    self.contents.font.color = normal_color
    if skill.base_damage > 0
      txt = skill.physical_attack ? "物理攻撃" : "攻撃魔法"
    elsif skill.base_damage < 0
      txt = skill.physical_attack ? "回復スキル" : "回復魔法"
    else # とりあえず…
      txt = skill.physical_attack ? "特殊スキル" : "補助魔法"
    end
    self.contents.draw_text(100+48, WLH*2, 160, WLH, txt)
    if dai_surr_skill_note_include(skill.note) != false
      self.contents.draw_text(100+48, WLH*3, 200, WLH, "顯示範囲")
    else  
       if dai_surr_skill_note_include2(skill.note) != false 
         self.contents.draw_text(100+48, WLH*3, 200, WLH, "召喚物")
       else
         self.contents.draw_text(100+48, WLH*3, 200, WLH, SCOPE[skill.scope])
       end
    end
    #self.contents.draw_text(100, WLH*2, 60, WLH, skill.hit.to_s+" ％", 2)
    if SkillEx::USE_ELE
      i = 0
      for element_id in skill.element_set
        next unless SkillEx::ELEMENTS.include?(element_id)
        self.contents.font.color = system_color
        #self.contents.draw_text(0, WLH*2, 100, WLH, "属性")
        self.contents.font.color = normal_color
        #draw_element_icon(element_id, 100+i*24, WLH*2)
        draw_element_icon(element_id, 175+24+i*24, WLH*2)
        i += 1
      end
    end
    
    if skill.plus_state_set != nil#minus_state_set
      i = 0
      for state_id in skill.plus_state_set
      state = $data_states[state_id]
      next if state == nil
      next if state.icon_index == 0
      draw_icon(state.icon_index, 100+48+i*24, WLH*4)
      self.contents.font.color = system_color      
      self.contents.font.color = normal_color
      i += 1
      end
    end
    
    if skill.minus_state_set != nil#minus_state_set
      i = 0
      for state_id in skill.minus_state_set
      state = $data_states[state_id]
      next if state == nil
      next if state.icon_index == 0
      draw_icon(state.icon_index, 100+48+i*24, WLH*5)
      self.contents.font.color = system_color
      self.contents.font.color = normal_color
      i += 1
      end
    end
    self.contents.font.size = Font.default_size
  end
  #--------------------------------------------------------------------------
  # ● 属性アイコンの描画
  #--------------------------------------------------------------------------
  def draw_element_icon(element_id, x, y, enabled = true)
    draw_icon(SkillEx::E_ICON[element_id], x, y, enabled)
  end
  
  ######################  
  def dai_surr_skill_note_include(note)
    return false
  end
#####################
######################  
  def dai_surr_skill_note_include2(note)
    note.each_line{|line|
      if line.include?("召喚物")

        return true
      end
    }
    return false
  end
#####################
#####################
#--------------------------------------------------------------------------
  # draw_level
  #--------------------------------------------------------------------------
  def draw_level(dy)
    self.contents.font.color = normal_color
    hash = YEZ::JOB::LEVEL_DATA
    level1 = @actor.skill_level(@skill)
    if level1 == @skill.max_level and @mode
      text = YEZ::JOB::LEVEL_VOCAB[:max_level]
      self.contents.draw_text(0, dy, self.width-32, WLH, text, 1)
      return (dy + WLH)
    end
    level2 = @mode ? level1 + 1 : level1 - 1
    if level2 < 0
      text = YEZ::JOB::LEVEL_VOCAB[:level_0]
    else
      level1 = hash[level1][1]
      level2 = hash[level2][1]
      text = sprintf(YEZ::JOB::LEVEL_VOCAB[:level_to], level1, level2)
    end
    self.contents.draw_text(0, dy, self.width-32, WLH, text, 1)
    return (dy + WLH)
  end
#####################
end