#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_SkillInfo戰鬥用
# 【用途】戰鬥系統元件「Window_SkillInfo戰鬥用」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Window_SkillInfo
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
# ■ Window_SkillInfo
#==============================================================================
class Window_SkillInfo < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y=WLH*5+64, h=416-(WLH*5+64))
    super(0, y, 544, h)
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  SCOPE = ["なし", "敵単体", "敵全体", "敵単体", 
           "敵単体", "敵二体", "敵三体", "味単体",
           "味全体", "味単体", "味全体", "使用者"]
  def refresh(skill=nil)
    self.contents.clear
    return if skill.nil?
=begin
    rect = Rect.new (0, 0, 144,WLH*5)
    rect2 = Rect.new (2, 2, 144-4,WLH*5-4)
    #self.contents.fill_rounded_rect(rect, Color.new(0, 0, 0, 128))
    self.contents.fill_rounded_rect(rect, Color.new(65, 117, 120))#(0, 0, 0, 128))
    self.contents.fill_rounded_rect (rect2, Color.new (0, 0, 0, 138))
    #self.contents.fill_rect(0, 0, 144, WLH*5, Color.new(0, 0, 0, 128))
    self.contents.font.size = YEZ::JOB::REQUIRE_SIZE
    self.contents.font.color = normal_color
    draw_icon(skill.icon_index, 30, WLH*0)
    #self.contents.draw_text(2,2,50,50,@target_members[@index].name) if @target_members
    self.contents.draw_text(60, WLH*0, 100, WLH, skill.name)
    #self.contents.draw_text(60, WLH*0, 100, WLH, battler.name)
    self.contents.font.color = system_color
    self.contents.draw_text(6, WLH*1, 100, WLH, "属性類別")
    self.contents.draw_text(6, WLH*2, 100, WLH, "効果範囲")
    self.contents.draw_text(6, WLH*3, 100, WLH, "附加")
    self.contents.draw_text(6, WLH*4, 100, WLH, "解除")
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
    self.contents.draw_text(66, WLH*1, 160, WLH, txt)
    if dai_surr_skill_note_include(skill.note) != false
      self.contents.draw_text(66, WLH*2, 200, WLH, "指定")
    else  
       if dai_surr_skill_note_include2(skill.note) != false 
         self.contents.draw_text(66, WLH*2, 200, WLH, "召喚物")
       else
         self.contents.draw_text(66, WLH*2, 200, WLH, SCOPE[skill.scope])
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
        draw_element_icon(element_id, 66+51+i*24, WLH*1)
        i += 1
      end
    end
    
    if skill.plus_state_set != nil#minus_state_set
      i = 0
      for state_id in skill.plus_state_set
      state = $data_states[state_id]
      next if state == nil
      next if state.icon_index == 0
      draw_icon(state.icon_index, 66+i*24, WLH*3)
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
      draw_icon(state.icon_index, 66+i*24, WLH*4)
      self.contents.font.color = system_color
      self.contents.font.color = normal_color
      i += 1
      end
    end
=end
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
end