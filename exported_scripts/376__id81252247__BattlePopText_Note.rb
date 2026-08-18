#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：BattlePopText_Note
# 【用途】戰鬥系統元件「BattlePopText_Note」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Scene_Battle、ALBERT_BATTLE_POP_TEXT
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ENABLE_ATTACK_POPUP、ENABLE_SKILL_POPUP、ENABLE_FOLLOWUP_POPUP、FALLBACK_TO_OLD_COMMON_EVENTS、OLD_ATTACK_COMMON_EVENT_ID、OLD_SKILL_COMMON_EVENT_ID、DISABLE_OLD_SBS_POP_KEYS、POP_TEXT_REGEX。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertBattlePopTextNote。
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
# ■ Albert_RMVX_BattlePopText_Note_v1_0.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8 相容
# 武器／技能 Note 戰鬥短句 + 喬伊召喚追擊提示
#------------------------------------------------------------------------------
# 【用途】
# 將目前專案中的「pop text」與「pop text_skill」功能改為 Note 驅動：
#
#   1. 普通攻擊前，可從裝備武器的 Note 讀取短句。
#   2. 使用技能前，可從技能 Note 讀取短句。
#   3. 同一武器／技能可寫多句，實際使用時隨機選一條。
#   4. 沒有 Note 短句時，可選擇自動回退到原本公共事件 21／22，
#      因此可以逐步移植，不必一次刪掉所有舊設定。
#   5. 喬伊成功觸發 Character Mechanic Core 的召喚物追擊時，
#      會在喬伊頭上顯示「追擊！」。
#
# 本腳本沿用目前專案已存在的：
#   ・文字圖片腳本 STRRGSS2 / STR_DumpFont
#   ・Tankentai SBS
#   ・Game_Picture 戰鬥圖片系統
#
# 不需要再為每一招新增公共事件條件分歧。
#==============================================================================
# 【建議放置位置】
#
#   Tankentai SBS / ATB
#   文字圖片腳本
#   其他戰鬥補丁
#   Albert_RMVX_ComboCore_AllInOne_v1_1_OD
#   Albert_RMVX_CharacterMechanicCore_v1_0_TC
#   Albert_RMVX_BattlePopText_Note_v1_0      ← 本腳本
#   全腳本匯出工具
#   Main
#
# 重要：請放在 Character Mechanic Core 下方，才能掛接「召喚物追擊」。
#==============================================================================
# 【一、普通攻擊：武器 Note】
#
# 在武器 Note 寫：
#
#   <pop_text:看招！>
#
# 可以寫多條：
#
#   <pop_text:看招！>
#   <pop_text:接好了！>
#   <pop_text:這一下可不輕。>
#
# 每次普通攻擊時隨機選一條。
# 雙持時會合併兩把武器的全部短句後再隨機抽選。
#
# 同一句重複寫多次，等同提高該句被抽中的權重。
#==============================================================================
# 【二、技能：技能 Note】
#
# 在技能 Note 寫：
#
#   <pop_text:別眨眼。>
#
# 或多條：
#
#   <pop_text:開始吧！>
#   <pop_text:讓我試試這招。>
#   <pop_text:你最好站穩。>
#
# 每次使用技能時隨機選一條。
#==============================================================================
# 【三、沒有 Note 時是否沿用舊公共事件】
#
# FALLBACK_TO_OLD_COMMON_EVENTS = true
#
# true：
#   ・普攻無 Note → 執行原公共事件 21
#   ・技能無 Note → 執行原公共事件 22
#
# false：
#   沒有 Note 就完全不顯示短句。
#
# 建議初期保持 true，等舊台詞全部移到 Note 後再考慮改成 false。
#==============================================================================
# 【四、原本 SBS 動作序列中的 pop text / pop text_skill】
#
# 本腳本預設會把原本的：
#
#   "pop text"
#   "pop text_skill"
#
# 改成空操作，避免「自動顯示一次 + SBS 序列又顯示一次」造成重複。
#
# 因為本腳本直接掛在：
#   Scene_Battle#execute_action_attack
#   Scene_Battle#execute_action_skill
#
# 所以即使某招的 SBS 動作序列裡沒有 pop text_skill，
# 只要技能 Note 有 <pop_text:...>，仍然會自動顯示。
#==============================================================================
# 【五、喬伊召喚物追擊】
#
# 若已使用 Albert_RMVX_CharacterMechanicCore，且追擊成功成立：
#
#   喬伊頭上顯示：追擊！
#
# 可在設定區修改 FOLLOWUP_TEXT。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertBattlePopTextNote"] = true

module ALBERT_BATTLE_POP_TEXT
  VERSION = "1.0"

  #--------------------------------------------------------------------------
  # ● 功能開關
  #--------------------------------------------------------------------------
  ENABLE_ATTACK_POPUP = true
  ENABLE_SKILL_POPUP  = true
  ENABLE_FOLLOWUP_POPUP = true

  # 沒有 Note 短句時，是否回退到舊公共事件 21 / 22。
  FALLBACK_TO_OLD_COMMON_EVENTS = false
  OLD_ATTACK_COMMON_EVENT_ID = 21
  OLD_SKILL_COMMON_EVENT_ID  = 22

  # 是否把原本 SBS 的 pop text / pop text_skill 改成空操作。
  # 建議保持 true，避免重複顯示。
  DISABLE_OLD_SBS_POP_KEYS = true

  #--------------------------------------------------------------------------
  # ● Note Tag
  #--------------------------------------------------------------------------
  # 支援：<pop_text:文字內容>
  POP_TEXT_REGEX = /<pop_text\s*:\s*([^>\r\n]+)\s*>/i

  #--------------------------------------------------------------------------
  # ● 文字圖片外觀
  #   依目前公共事件設定：p = 2、s = 16。
  #--------------------------------------------------------------------------
  FONT_PATTERN = 2
  FONT_SIZE = 16

  #--------------------------------------------------------------------------
  # ● 漂浮動畫
  #   目前公共事件是 60 幀內向上漂移並淡出。
  #--------------------------------------------------------------------------
  FLOAT_DURATION = 80
  FLOAT_DISTANCE_Y = 2

  #--------------------------------------------------------------------------
  # ● 顯示位置
  #   使用 Tankentai 當前戰鬥座標，再套用以下偏移。
  #   目前舊公共事件大致相當於 X - 32、Y - 32。
  #--------------------------------------------------------------------------
  OFFSET_X = -16#-32
  OFFSET_Y = -32

  #--------------------------------------------------------------------------
  # ● 圖片 ID
  #   主角 1～6 預設使用 11～16，避免和原本公共事件的圖片 1 衝突。
  #--------------------------------------------------------------------------
  ACTOR_PICTURE_ID_BASE = 10
  FALLBACK_PICTURE_ID = 20

  #--------------------------------------------------------------------------
  # ● 喬伊追擊提示
  #--------------------------------------------------------------------------
  FOLLOWUP_TEXT = "追擊！"
  JOEY_ACTOR_ID = 1

  #--------------------------------------------------------------------------
  # ● 安全取得 Note
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil
    return ""
  end

  #--------------------------------------------------------------------------
  # ● 從 Note 取得全部 pop_text
  #--------------------------------------------------------------------------
  def self.texts_from(obj)
    result = []
    text = note(obj)
    text.scan(POP_TEXT_REGEX) do |data|
      line = data[0].to_s
      line = line.strip
      result.push(line) unless line.empty?
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 普攻短句來源：所有已裝備武器
  #--------------------------------------------------------------------------
  def self.attack_texts(battler)
    result = []
    return result if battler == nil
    return result unless battler.actor?
    return result unless battler.respond_to?(:weapons)
    for weapon in battler.weapons.compact
      result.concat(texts_from(weapon))
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 技能短句來源：技能 Note
  #--------------------------------------------------------------------------
  def self.skill_texts(skill)
    return texts_from(skill)
  end

  #--------------------------------------------------------------------------
  # ● 隨機取一句
  #--------------------------------------------------------------------------
  def self.random_text(texts)
    return nil if texts == nil || texts.empty?
    return texts[rand(texts.size)]
  end

  #--------------------------------------------------------------------------
  # ● 取得 Tankentai 當前戰鬥位置
  #--------------------------------------------------------------------------
  def self.battler_position(battler)
    return [0, 0] if battler == nil
    x = 0
    y = 0
    if battler.respond_to?(:position_x)
      x = battler.position_x.to_i
    elsif battler.respond_to?(:screen_x)
      x = battler.screen_x.to_i
    end
    if battler.respond_to?(:position_y)
      y = battler.position_y.to_i
    elsif battler.respond_to?(:screen_y)
      y = battler.screen_y.to_i
    end
    return [x, y]
  end

  #--------------------------------------------------------------------------
  # ● 為不同主角分配圖片 ID
  #--------------------------------------------------------------------------
  def self.picture_id_for(battler)
    if battler != nil && battler.actor? && battler.respond_to?(:id)
      actor_id = battler.id.to_i
      if actor_id >= 1 && actor_id <= 6
        return ACTOR_PICTURE_ID_BASE + actor_id
      end
    end
    return FALLBACK_PICTURE_ID
  end

  #--------------------------------------------------------------------------
  # ● 直接建立與目前 text_picture 相同格式的文字圖片資料
  #--------------------------------------------------------------------------
  def self.make_text_picture_data(text)
    return nil unless defined?(STRRGSS2)
    return nil unless defined?(STR_DumpFont)
    return nil unless defined?(STRRGSS2::STR27_FLIST)
    strfp = STRRGSS2::STR27_FLIST[FONT_PATTERN]
    return nil if strfp == nil

    font = Font.new(strfp[0], FONT_SIZE)
    font.bold = strfp[1]
    font.italic = strfp[2]
    font.shadow = strfp[3]
    font.color = strfp[5]

    return [text.to_s, STR_DumpFont.new(font, strfp[4], strfp[6])]
  end

  #--------------------------------------------------------------------------
  # ● 在角色頭上顯示短句
  #--------------------------------------------------------------------------
  def self.show(battler, text)
    return false if battler == nil
    return false if text == nil || text.to_s.empty?
    return false if $game_troop == nil
    return false unless $game_troop.respond_to?(:screen)

    data = make_text_picture_data(text)
    return false if data == nil

    pos = battler_position(battler)
    x = pos[0] + OFFSET_X
    y = pos[1] + OFFSET_Y
    picture_id = picture_id_for(battler)
    pictures = $game_troop.screen.pictures
    return false if pictures == nil
    picture = pictures[picture_id]
    return false if picture == nil

    # 與目前公共事件一致：左上原點、100% 縮放、255 不透明度。
    picture.show(data, 0, x, y, 100, 100, 255, 0)
    # 向上漂移並淡出。
    picture.move(0, x, y - FLOAT_DISTANCE_Y,
                 100, 100, 0, 0, FLOAT_DURATION)
    return true
  end

  #--------------------------------------------------------------------------
  # ● 沒有 Note 時，沿用原公共事件 21
  #--------------------------------------------------------------------------
  def self.run_old_attack_popup(battler)
    return false unless FALLBACK_TO_OLD_COMMON_EVENTS
    return false unless defined?(Game_Interpreter_Self)
    return false if battler == nil

    if battler.respond_to?(:base_position_x)
      $game_variables[201] = battler.base_position_x
    elsif battler.respond_to?(:position_x)
      $game_variables[201] = battler.position_x
    end
    if battler.respond_to?(:base_position_y)
      $game_variables[202] = battler.base_position_y
    elsif battler.respond_to?(:position_y)
      $game_variables[202] = battler.position_y
    end
    Game_Interpreter_Self.new(OLD_ATTACK_COMMON_EVENT_ID)
    return true
  end

  #--------------------------------------------------------------------------
  # ● 沒有 Note 時，沿用原公共事件 22
  #--------------------------------------------------------------------------
  def self.run_old_skill_popup(battler, skill)
    return false unless FALLBACK_TO_OLD_COMMON_EVENTS
    return false unless defined?(Game_Interpreter_Self)
    return false if battler == nil || skill == nil

    $game_variables[203] = skill.id
    if battler.respond_to?(:position_x)
      $game_variables[201] = battler.position_x
    end
    if battler.respond_to?(:position_y)
      $game_variables[202] = battler.position_y
    end
    Game_Interpreter_Self.new(OLD_SKILL_COMMON_EVENT_ID)
    return true
  end

  #--------------------------------------------------------------------------
  # ● 普攻前處理
  #--------------------------------------------------------------------------
  def self.show_attack_popup(battler)
    return false unless ENABLE_ATTACK_POPUP
    texts = attack_texts(battler)
    line = random_text(texts)
    return show(battler, line) if line != nil
    return run_old_attack_popup(battler)
  end

  #--------------------------------------------------------------------------
  # ● 技能前處理
  #--------------------------------------------------------------------------
  def self.show_skill_popup(battler, skill)
    return false unless ENABLE_SKILL_POPUP
    texts = skill_texts(skill)
    line = random_text(texts)
    return show(battler, line) if line != nil
    return run_old_skill_popup(battler, skill)
  end
end

#==============================================================================
# ■ 停用舊 SBS pop text Key，避免重複顯示
#==============================================================================
if ALBERT_BATTLE_POP_TEXT::DISABLE_OLD_SBS_POP_KEYS && defined?(N01::ANIME)
  N01::ANIME["pop text"] = ["script", ""]
  N01::ANIME["pop text_skill"] = ["script", ""]
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 普攻前：讀取武器 Note 並顯示隨機短句
  #--------------------------------------------------------------------------
  if method_defined?(:execute_action_attack) &&
     !method_defined?(:albert_pop_note_old_execute_action_attack)
    alias albert_pop_note_old_execute_action_attack execute_action_attack
    def execute_action_attack(*args)
      battler = @active_battler
      ALBERT_BATTLE_POP_TEXT.show_attack_popup(battler)
      albert_pop_note_old_execute_action_attack(*args)
    end
  end

  #--------------------------------------------------------------------------
  # ● 技能前：讀取技能 Note 並顯示隨機短句
  #--------------------------------------------------------------------------
  if method_defined?(:execute_action_skill) &&
     !method_defined?(:albert_pop_note_old_execute_action_skill)
    alias albert_pop_note_old_execute_action_skill execute_action_skill
    def execute_action_skill(*args)
      battler = @active_battler
      skill = nil
      if battler != nil && battler.respond_to?(:action) && battler.action != nil
        skill = battler.action.skill
      end
      ALBERT_BATTLE_POP_TEXT.show_skill_popup(battler, skill) if skill != nil
      albert_pop_note_old_execute_action_skill(*args)
    end
  end

  #--------------------------------------------------------------------------
  # ● 喬伊召喚物追擊前顯示「追擊！」
  #
  # Character Mechanic Core 的追擊不走一般 execute_action_skill，
  # 而是直接插入 Tankentai SBS playing_action，因此需要在追擊專用方法掛接。
  #--------------------------------------------------------------------------
  if ALBERT_BATTLE_POP_TEXT::ENABLE_FOLLOWUP_POPUP &&
     method_defined?(:albert_cc_execute_summon_followup) &&
     !method_defined?(:albert_pop_note_old_execute_summon_followup)
    alias albert_pop_note_old_execute_summon_followup albert_cc_execute_summon_followup
    def albert_cc_execute_summon_followup(summon, follow_skill, targets)
      valid = summon != nil && follow_skill != nil && targets != nil && !targets.empty?
      valid = false unless respond_to?(:playing_action)
      valid = false if @spriteset == nil

      if valid
        joey = nil
        if defined?(ALBERT_CHARACTER_CORE)
          joey = ALBERT_CHARACTER_CORE.actor_by_id(ALBERT_BATTLE_POP_TEXT::JOEY_ACTOR_ID)
        elsif $game_actors != nil
          joey = $game_actors[ALBERT_BATTLE_POP_TEXT::JOEY_ACTOR_ID]
        end
        if joey != nil && joey.exist?
          ALBERT_BATTLE_POP_TEXT.show(joey, ALBERT_BATTLE_POP_TEXT::FOLLOWUP_TEXT)
        end
      end

      return albert_pop_note_old_execute_summon_followup(summon, follow_skill, targets)
    end
  end
end
