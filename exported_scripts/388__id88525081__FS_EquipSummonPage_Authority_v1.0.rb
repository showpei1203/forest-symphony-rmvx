#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipSummonPage_Authority v1.0
# 【用途】Forest Symphony 正式 Authority「FS_EquipSummonPage_Authority v1.0」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Window_EquipStat、ALBERT_YEM_SUMMON_PAGE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SUMMON_TEXTS、DEFAULT_TEXT_X、DEFAULT_TEXT_Y、TEXT_WIDTH、TEXT_LINE_HEIGHT、TEXT_SIZE、TEXT_POSITIONS、DEFAULT_CHAR_X。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE7 ORIGINAL PAGE: 410 | Equip_SummonPage_Extension
#==============================================================================
#==============================================================================
# ■ Albert_YEM_Equip_SummonPage_Extension_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 功能：
#
# 1. 修正 YEM Equipment Overhaul 召喚物頁面仍讀取舊存檔 Actor 資料的問題。
#
# 2. 每次顯示召喚物頁面時：
#      - 同步目前資料庫中的 Actor 身分資料
#      - 保留等級、EXP、技能、JP、技能等級、裝備等養成資料
#
# 3. 每個召喚 Actor 可以設定自己的專屬文字。
#
# 4. 專屬文字可直接寫字串，也可以指定技能 ID，自動顯示技能名稱。
#
# 5. 每個召喚 Actor 可以個別調整行走圖 X / Y 座標。
#
#------------------------------------------------------------------------------
# 安裝位置：
#
#   YEM Equipment Overhaul
#   Albert YEM Equipment Overhaul Safety Patch
#   Albert_SummonTemporaryBattle_DatabaseSync
#   本補丁
#   Main
#
#==============================================================================


module ALBERT_YEM_SUMMON_PAGE

  #==========================================================================
  # ● 召喚物專屬文字
  #--------------------------------------------------------------------------
  #
  # 格式：
  #
  #   Actor ID => [
  #     "任意文字",
  #     [:skill, 技能ID],
  #     [:skill, 技能ID, "前綴文字"],
  #   ]
  #
  # 範例：
  #
  #   7 => [
  #     "特性：猛火",
  #     [:skill, 31],
  #     [:skill, 32, "招式："]
  #   ]
  #
  # 假設技能 31 名稱是「火花」，會顯示：
  #
  #   特性：猛火
  #   火花
  #   招式：火花
  #
  #==========================================================================

  SUMMON_TEXTS = {

    # Actor 7
    7 => [
      "招式：火花",
    ],

    # Actor 8
    8 => [
      "招式：水槍",
    ],

    # Actor 9
    9 => [
      "招式：藤鞭",
    ],

  }


  #==========================================================================
  # ● 專屬文字預設位置
  #--------------------------------------------------------------------------
  #
  # X 越大 → 越往右
  # Y 越大 → 越往下
  #
  #==========================================================================

  DEFAULT_TEXT_X = 0
  DEFAULT_TEXT_Y = 180

  TEXT_WIDTH       = 190
  TEXT_LINE_HEIGHT = 20
  TEXT_SIZE        = 16


  #==========================================================================
  # ● 每個 Actor 個別的文字位置
  #--------------------------------------------------------------------------
  #
  # Actor ID => [X, Y]
  #
  # 沒有設定的 Actor 使用 DEFAULT_TEXT_X / DEFAULT_TEXT_Y。
  #
  #==========================================================================

  TEXT_POSITIONS = {

    # 7 => [0, 180],
    # 8 => [0, 180],
    # 9 => [0, 180],

  }


  #==========================================================================
  # ● 行走圖預設位置
  #--------------------------------------------------------------------------
  #
  # 你目前 Safety Patch 原本使用：
  #
  #   X = 180
  #   Y = 100
  #
  #==========================================================================

  DEFAULT_CHAR_X = 150
  DEFAULT_CHAR_Y = 80


  #==========================================================================
  # ● 每個 Actor 個別的行走圖位置
  #--------------------------------------------------------------------------
  #
  # Actor ID => [X, Y]
  #
  # 範例：
  #
  #   7 => [175, 105]
  #
  # 代表 Actor 7：
  #   向左移動 5 px
  #   向下移動 5 px
  #
  #==========================================================================

  CHAR_POSITIONS = {

    # 7 => [175, 105],
    # 8 => [180, 100],
    # 9 => [185, 95],

  }

end


#==============================================================================
# ■ Window_EquipStat
#==============================================================================

class Window_EquipStat < Window_Base

  #--------------------------------------------------------------------------
  # ● 同步召喚 Actor 的目前資料庫身分
  #--------------------------------------------------------------------------
  #
  # 優先使用 SummonTemporaryBattle 的共用同步方法。
  #
  # 如果該方法不存在，則使用本補丁自己的安全同步。
  #
  # 不執行 setup。
  # 不執行 recover_all。
  #
  #--------------------------------------------------------------------------

  def albert_sync_equip_summon_actor(actor_id)

    return nil if actor_id == nil
    return nil if actor_id <= 0
    return nil if $data_actors[actor_id] == nil


    #----------------------------------------------------------------------
    # 優先使用戰鬥召喚系統已有的共用同步方法
    #----------------------------------------------------------------------

    if defined?(AlbertSummonTemporaryBattle) &&
       AlbertSummonTemporaryBattle.respond_to?(:sync_actor_database_data)

      AlbertSummonTemporaryBattle.sync_actor_database_data(actor_id)

      return $game_actors[actor_id]
    end


    #----------------------------------------------------------------------
    # 備用安全同步
    #----------------------------------------------------------------------

    actor = $game_actors[actor_id]
    data  = $data_actors[actor_id]

    return nil if actor == nil
    return nil if data == nil


    # Actor ID
    actor.instance_variable_set(
      :@actor_id,
      actor_id
    )


    # 名稱
    actor.instance_variable_set(
      :@name,
      data.name
    )


    # 行走圖
    actor.instance_variable_set(
      :@character_name,
      data.character_name
    )

    actor.instance_variable_set(
      :@character_index,
      data.character_index
    )


    # 臉圖
    actor.instance_variable_set(
      :@face_name,
      data.face_name
    )

    actor.instance_variable_set(
      :@face_index,
      data.face_index
    )


    # 職業
    actor.instance_variable_set(
      :@class_id,
      data.class_id
    )


    return actor
  end


  #--------------------------------------------------------------------------
  # ● 取得召喚物專屬文字
  #--------------------------------------------------------------------------

  def albert_summon_custom_lines(actor_id)

    lines = ALBERT_YEM_SUMMON_PAGE::SUMMON_TEXTS[actor_id]

    return [] if lines == nil

    return lines if lines.is_a?(Array)

    return [lines]
  end


  #--------------------------------------------------------------------------
  # ● 將設定內容轉換為真正顯示文字
  #--------------------------------------------------------------------------
  #
  # 支援：
  #
  #   "火花"
  #
  #   [:skill, 31]
  #
  #   [:skill, 31, "招式："]
  #
  #--------------------------------------------------------------------------

  def albert_summon_custom_text(entry)

    if entry.is_a?(Array) && entry[0] == :skill

      skill_id = entry[1].to_i
      skill = $data_skills[skill_id]

      return "" if skill == nil

      prefix = entry[2] == nil ? "" : entry[2].to_s

      return prefix + skill.name.to_s
    end

    return entry.to_s
  end


  #--------------------------------------------------------------------------
  # ● 繪製召喚物專屬文字
  #--------------------------------------------------------------------------

  def albert_draw_summon_custom_text(actor_id)

    lines = albert_summon_custom_lines(actor_id)

    return if lines.empty?


    # 個別位置
    position =
      ALBERT_YEM_SUMMON_PAGE::TEXT_POSITIONS[actor_id]

    if position == nil

      x = ALBERT_YEM_SUMMON_PAGE::DEFAULT_TEXT_X
      y = ALBERT_YEM_SUMMON_PAGE::DEFAULT_TEXT_Y

    else

      x = position[0]
      y = position[1]

    end


    width =
      ALBERT_YEM_SUMMON_PAGE::TEXT_WIDTH

    line_height =
      ALBERT_YEM_SUMMON_PAGE::TEXT_LINE_HEIGHT


    old_size = contents.font.size

    contents.font.size =
      ALBERT_YEM_SUMMON_PAGE::TEXT_SIZE

    contents.font.color = normal_color


    draw_index = 0

    lines.each do |entry|

      text = albert_summon_custom_text(entry)

      next if text == nil
      next if text.empty?


      contents.draw_text(
        x,
        y + draw_index * line_height,
        width,
        line_height,
        text,
        0
      )

      draw_index += 1
    end


    contents.font.size = old_size
    contents.font.color = normal_color
  end


  #--------------------------------------------------------------------------
  # ● 取得召喚物行走圖位置
  #--------------------------------------------------------------------------

  def albert_summon_character_position(actor_id)

    position =
      ALBERT_YEM_SUMMON_PAGE::CHAR_POSITIONS[actor_id]

    if position != nil

      return position
    end

    return [
      ALBERT_YEM_SUMMON_PAGE::DEFAULT_CHAR_X,
      ALBERT_YEM_SUMMON_PAGE::DEFAULT_CHAR_Y
    ]
  end


  #--------------------------------------------------------------------------
  # ● 重新定義召喚物詳細頁
  #--------------------------------------------------------------------------
  #
  # 重點：
  #
  #   1. 先取得 ArmorMapping 對應 Actor ID。
  #   2. 同步目前資料庫 Actor 身分。
  #   3. 不 setup。
  #   4. 不 recover_all。
  #   5. 保留真正的養成進度。
  #   6. 加入專屬文字。
  #   7. 支援個別行走圖位置。
  #
  #--------------------------------------------------------------------------

  def draw_summon_stats

    return if @equip == nil
    return unless defined?(ArmorMapping)
    return unless ArmorMapping.respond_to?(:mapping)


    actor_id = ArmorMapping.mapping[@equip.id]

    return if actor_id == nil


    #----------------------------------------------------------------------
    # 修正舊存檔 Actor 身分
    #----------------------------------------------------------------------

    @summon =
      albert_sync_equip_summon_actor(actor_id)

    return if @summon == nil


    @summon_mode = true


    #======================================================================
    # 名稱
    #======================================================================

    contents.font.color = text_color(1)

    contents.draw_text(
      0,
      0,
      90,
      50,
      @summon.name.to_s,
      0
    )


    #======================================================================
    # 等級
    #======================================================================

    contents.font.color = normal_color

    contents.draw_text(
      0,
      20,
      50,
      50,
      "Lv",
      0
    )

    contents.draw_text(
      30,
      20,
      50,
      50,
      @summon.level.to_s,
      0
    )


    #======================================================================
    # HP / MP
    #======================================================================

    draw_actor_hp(
      @summon,
      0,
      50,
      80
    )

    draw_actor_mp_gauge(
      @summon,
      0,
      70,
      80
    )

    contents.draw_text(
      30,
      60,
      50,
      50,
      @summon.maxmp.to_s,
      2
    )


    #======================================================================
    # 能力名稱
    #======================================================================

    contents.font.color = text_color(1)

    contents.draw_text(
      0, 90, 50, 50,
      "攻擊", 0
    )

    contents.draw_text(
      0, 110, 50, 50,
      "防禦", 0
    )

    contents.draw_text(
      0, 130, 50, 50,
      "精神", 0
    )

    contents.draw_text(
      0, 150, 50, 50,
      "敏捷", 0
    )


    #======================================================================
    # 能力數值
    #======================================================================

    contents.font.color = normal_color

    contents.draw_text(
      60, 90, 50, 50,
      @summon.atk.to_s, 0
    )

    contents.draw_text(
      60, 110, 50, 50,
      @summon.def.to_s, 0
    )

    contents.draw_text(
      60, 130, 50, 50,
      @summon.spi.to_s, 0
    )

    contents.draw_text(
      60, 150, 50, 50,
      @summon.agi.to_s, 0
    )


    #======================================================================
    # 臉圖
    #======================================================================

    draw_actor_face(
      @summon,
      100,
      10
    )


    #======================================================================
    # 行走圖
    #======================================================================

    char_position =
      albert_summon_character_position(actor_id)

    char_x = char_position[0]
    char_y = char_position[1]


    if respond_to?(:albert_draw_summon_character)

      albert_draw_summon_character(
        @summon,
        char_x,
        char_y
      )

    else

      draw_actor_graphic(
        @summon,
        char_x,
        char_y
      )

    end


    #======================================================================
    # 專屬文字
    #======================================================================

    albert_draw_summon_custom_text(actor_id)


    contents.font.color = normal_color
  end

end

#==============================================================================
# PHASE7 ORIGINAL PAGE: 411 | Equip_SummonPage_SkillElementIcon
#==============================================================================
#==============================================================================
# ■ Albert_YEM_Equip_SummonPage_SkillElementIcon_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 功能：
#
#   讓召喚物頁面的：
#
#     [:skill, 技能ID]
#
#   自動在技能名稱前顯示該技能所屬的屬性 Icon。
#
#
# 範例：
#
#   7 => [
#     [:skill, 31],
#     [:skill, 32, "追擊："],
#   ]
#
#
# 顯示方式：
#
#   [火Icon] 火花
#   [格鬥Icon] 追擊：音速拳
#
#
# 若技能：
#
#   - 沒有屬性
#   - 屬性 ID 沒有對應的寶可夢屬性
#   - 找不到 Icon
#
# 則不顯示 Icon。
#
#
# 若技能具有複數有效屬性：
#
#   [火Icon][飛行Icon] 技能名稱
#
#
# 安裝位置：
#
#   Albert_YEM_Equip_SummonPage_Extension
#   本補丁
#   Main
#
#==============================================================================


module ALBERT_YEM_SUMMON_PAGE

  #--------------------------------------------------------------------------
  # ● Icon 與文字之間的距離
  #--------------------------------------------------------------------------

  SKILL_ELEMENT_ICON_TEXT_GAP = 4


  #--------------------------------------------------------------------------
  # ● 多個 Icon 之間的距離
  #--------------------------------------------------------------------------
  #
  # VX Icon 本身為 24 x 24。
  #
  # 設為 24：
  #   Icon 緊密排列。
  #
  # 設為 26：
  #   Icon 中間留 2 px。
  #
  #--------------------------------------------------------------------------

  SKILL_ELEMENT_ICON_STEP = 24

end


#==============================================================================
# ■ Window_EquipStat
#==============================================================================

class Window_EquipStat < Window_Base

  #--------------------------------------------------------------------------
  # ● 取得技能所有有效的寶可夢屬性 Icon ID
  #--------------------------------------------------------------------------
  #
  # 流程：
  #
  #   skill.element_set
  #
  #     ↓
  #
  #   Element ID
  #
  #     ↓
  #
  #   POKEMON_ELEMENT_CHART::ELEMENT_IDS
  #
  #     ↓
  #
  #   :fire / :water / :grass ...
  #
  #     ↓
  #
  #   Window_Base::ELEMENT_ICON_TABLE
  #
  #     ↓
  #
  #   Icon ID
  #
  #--------------------------------------------------------------------------

  def albert_summon_skill_element_icon_ids(skill)

    result = []

    return result if skill == nil

    return result unless defined?(POKEMON_ELEMENT_CHART)

    return result unless
      POKEMON_ELEMENT_CHART.const_defined?(:ELEMENT_IDS)

    return result unless
      Window_Base.const_defined?(:ELEMENT_ICON_TABLE)


    skill.element_set.each do |element_id|

      #--------------------------------------------------------------------
      # Element ID → 屬性 Symbol
      #
      # 例如：
      #
      #   13 → :fire
      #   14 → :water
      #
      #--------------------------------------------------------------------

      element_symbol =
        POKEMON_ELEMENT_CHART::ELEMENT_IDS[element_id]

      next if element_symbol == nil


      #--------------------------------------------------------------------
      # 屬性 Symbol → Icon ID
      #
      # 例如：
      #
      #   :fire → 4007
      #   :water → 4008
      #
      #--------------------------------------------------------------------

      icon_id =
        Window_Base::ELEMENT_ICON_TABLE[element_symbol]

      next if icon_id == nil
      next if icon_id <= 0


      #--------------------------------------------------------------------
      # 避免同一 Icon 重複
      #--------------------------------------------------------------------

      unless result.include?(icon_id)

        result.push(icon_id)

      end

    end


    return result
  end


  #--------------------------------------------------------------------------
  # ● 重新定義：繪製召喚物專屬文字
  #--------------------------------------------------------------------------
  #
  # 普通字串：
  #
  #   "定位：高速強攻"
  #
  # 顯示：
  #
  #   定位：高速強攻
  #
  #
  # 技能：
  #
  #   [:skill, 31]
  #
  # 顯示：
  #
  #   [屬性Icon] 技能名稱
  #
  #
  # 技能＋前綴：
  #
  #   [:skill, 31, "招式："]
  #
  # 顯示：
  #
  #   [屬性Icon] 招式：技能名稱
  #
  #--------------------------------------------------------------------------

  def albert_draw_summon_custom_text(actor_id)

    lines = albert_summon_custom_lines(actor_id)

    return if lines.empty?


    #----------------------------------------------------------------------
    # ● 取得文字位置
    #----------------------------------------------------------------------

    position =
      ALBERT_YEM_SUMMON_PAGE::TEXT_POSITIONS[actor_id]


    if position == nil

      x = ALBERT_YEM_SUMMON_PAGE::DEFAULT_TEXT_X

      y = ALBERT_YEM_SUMMON_PAGE::DEFAULT_TEXT_Y

    else

      x = position[0]

      y = position[1]

    end


    width =
      ALBERT_YEM_SUMMON_PAGE::TEXT_WIDTH


    #----------------------------------------------------------------------
    # Icon 為 24 px 高。
    #
    # 即使原設定低於 24，也至少使用 24，
    # 避免上下兩行 Icon 重疊。
    #----------------------------------------------------------------------

    line_height = [
      ALBERT_YEM_SUMMON_PAGE::TEXT_LINE_HEIGHT,
      24
    ].max


    old_size = contents.font.size

    contents.font.size =
      ALBERT_YEM_SUMMON_PAGE::TEXT_SIZE

    contents.font.color = normal_color


    draw_index = 0


    lines.each do |entry|

      line_y =
        y + draw_index * line_height


      #====================================================================
      # ● :skill 類型
      #====================================================================

      if entry.is_a?(Array) &&
         entry[0] == :skill


        skill_id = entry[1].to_i

        skill = $data_skills[skill_id]


        # 找不到技能資料則跳過
        next if skill == nil


        #------------------------------------------------------------------
        # 取得真正顯示文字
        #
        # 仍沿用上一版方法：
        #
        #   [:skill, 31]
        #
        # 或：
        #
        #   [:skill, 31, "招式："]
        #
        #------------------------------------------------------------------

        text =
          albert_summon_custom_text(entry)


        next if text == nil
        next if text.empty?


        #------------------------------------------------------------------
        # 取得屬性 Icon
        #------------------------------------------------------------------

        icon_ids =
          albert_summon_skill_element_icon_ids(skill)


        draw_x = x


        #------------------------------------------------------------------
        # 繪製所有有效屬性 Icon
        #------------------------------------------------------------------

        icon_ids.each do |icon_id|

          draw_icon(
            icon_id,
            draw_x,
            line_y,
            true
          )


          draw_x +=
            ALBERT_YEM_SUMMON_PAGE::
              SKILL_ELEMENT_ICON_STEP

        end


        #------------------------------------------------------------------
        # 有 Icon 才加入 Icon 與文字間距
        #------------------------------------------------------------------

        unless icon_ids.empty?

          draw_x +=
            ALBERT_YEM_SUMMON_PAGE::
              SKILL_ELEMENT_ICON_TEXT_GAP

        end


        #------------------------------------------------------------------
        # 計算剩餘文字寬度
        #------------------------------------------------------------------

        text_width =
          width - (draw_x - x)


        text_width = 0 if text_width < 0


        #------------------------------------------------------------------
        # 繪製技能文字
        #------------------------------------------------------------------

        contents.draw_text(
          draw_x,
          line_y,
          text_width,
          line_height,
          text,
          0
        )


      #====================================================================
      # ● 普通文字
      #====================================================================

      else

        text =
          albert_summon_custom_text(entry)


        next if text == nil
        next if text.empty?


        contents.draw_text(
          x,
          line_y,
          width,
          line_height,
          text,
          0
        )

      end


      draw_index += 1

    end


    #----------------------------------------------------------------------
    # ● 還原字體
    #----------------------------------------------------------------------

    contents.font.size = old_size

    contents.font.color = normal_color

  end

end
