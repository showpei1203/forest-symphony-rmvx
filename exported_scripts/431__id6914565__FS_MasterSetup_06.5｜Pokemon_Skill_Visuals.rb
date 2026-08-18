#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 06.5 Pokemon Skill Visuals v1.0
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 06.5 Pokemon Skill Visuals v1.0」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、POKEMON_SKILL_VISUALS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MANAGED_RANGES、MELEE_SKILL_IDS、ICON_ELEMENT_OVERRIDES、FALLBACK_ICON_BY_ELEMENT_ID。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILL VISUALS
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
# ■ FS_MasterSetup 06.5 Pokemon Skill Visuals v1.0
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
#
# 放置位置：
#   FS_MasterSetup 06 Skills Pokemon B
#   本腳本
#   FS_MasterSetup 07 States
#   ...
#   FS_MasterSetup 18 Apply
#
# 功能：
#   1. 僅管理寶可夢型 Boss 技能 400～458，以及一般寶可夢技能 600～771。
#   2. 不處理六名主要角色、敵對人類、機器人、複製物技能。
#   3. 技能 Icon 自動使用技能 element_set 的第一個寶可夢屬性 Icon。
#   4. 無 element_set、但原作招式具有一般屬性的技能，僅補一般屬性 Icon，
#      不改動 element_set，避免影響傷害與屬性相剋。
#   5. 需要貼近目標施放的技能使用 <action:NORMAL_ATTACK>。
#   6. 原地施放、投射、光束、音波、場地、全體與輔助技能使用
#      <action:SKILL_USE>。
#
# 注意：
#   - 雙屬性技能只能顯示一個資料庫技能 Icon，因此取 element_set 第一項。
#   - ACTION_OVERRIDES 會在 FS_MasterSetup 18 Apply 時寫入技能 Note。
#==============================================================================

module FS_MASTER_SETUP
  module POKEMON_SKILL_VISUALS
    VERSION = "1.0"

    # 寶可夢型 Boss 與一般寶可夢技能範圍。
    MANAGED_RANGES = [400..458, 600..771]

    #--------------------------------------------------------------------------
    # ● 需要接近目標的技能
    #--------------------------------------------------------------------------
    # 判定原則：使用身體、爪、牙、翼、尾、拳、踢、衝撞等直接接觸目標。
    # 投射型物理招式（落石、骨頭回力鏢、毒針等）仍屬原地施放。
    # 全體技能即使是物理攻擊，也維持原地施放，避免只衝向單一目標。
    #--------------------------------------------------------------------------
    MELEE_SKILL_IDS = [
      # 寶可夢型 Boss
      405, # 暴君咬碎
      407, # 彗星重擊
      411, # 逆鱗終擊
      456, # 畫龍點睛

      # 一般寶可夢 A
      607, # 抓
      610, # 劈開
      613, # 翅膀攻擊
      614, # 龍爪
      616, # 撞擊
      619, # 咬住
      624, # 連斬
      627, # 超級角擊
      631, # 劇毒牙
      633, # 吸血
      634, # 啄
      636, # 燕返
      639, # 電光一閃
      640, # 咬碎
      641, # 憤怒門牙
      642, # 捨身衝撞
      643, # 啄鑽
      652, # 骨棒
      654, # 劈瓦
      656, # 挖洞
      662, # 火焰輪
      667, # 泰山壓頂
      672, # 攀瀑
      674, # 空手劈

      # 一般寶可夢 B
      677, # 十字劈
      678, # 大鬧一番
      679, # 神速
      688, # 爆裂拳
      695, # 踩踏
      698, # 金屬爪
      702, # 舌舔
      706, # 頭錘
      728, # 暗影拳
      730, # 鋼翼
      732, # 鐵尾
      740, # 拍擊
      749, # 猛推
      750, # 拍落
      755, # 彗星拳
      767  # 雙針
    ]

    # 原資料未設定 element_set，但招式本身屬一般系。
    # 只用於 Icon，不改寫技能屬性。
    ICON_ELEMENT_OVERRIDES = {
      626 => 4, # 揮指
      659 => 4, # 祈願
      684 => 4, # 自我再生
      710 => 4  # 生蛋
    }

    # 當正式屬性 Icon 常數尚未載入時使用的保險對照。
    FALLBACK_ICON_BY_ELEMENT_ID = {
      4  => 3988, # 一般
      5  => 3989, # 格鬥
      6  => 3990, # 飛行
      7  => 3991, # 毒
      8  => 3992, # 地面
      9  => 3993, # 岩石
      10 => 4004, # 蟲
      11 => 4005, # 幽靈
      12 => 4006, # 鋼
      13 => 4007, # 火
      14 => 4008, # 水
      15 => 4009, # 草
      16 => 4020, # 電
      17 => 4021, # 超能力
      18 => 4022, # 冰
      19 => 4023, # 龍
      20 => 4024, # 惡
      21 => 4025  # 妖精
    }

    def self.managed_skill_id?(skill_id)
      for range in MANAGED_RANGES
        return true if range.include?(skill_id)
      end
      return false
    end

    def self.primary_element_id(skill_id, data)
      override = ICON_ELEMENT_OVERRIDES[skill_id]
      return override if override != nil

      elements = data[:element_set]
      return nil unless elements.is_a?(Array)
      return nil if elements.empty?
      return elements[0].to_i
    end

    def self.icon_id_for_element(element_id)
      return 0 if element_id == nil || element_id <= 0

      if defined?(POKEMON_ELEMENT_CHART) &&
         POKEMON_ELEMENT_CHART.const_defined?(:ELEMENT_IDS) &&
         defined?(Window_Base) &&
         Window_Base.const_defined?(:ELEMENT_ICON_TABLE)
        symbol = POKEMON_ELEMENT_CHART::ELEMENT_IDS[element_id]
        if symbol != nil
          icon_id = Window_Base::ELEMENT_ICON_TABLE[symbol]
          return icon_id.to_i if icon_id != nil && icon_id.to_i > 0
        end
      end

      icon_id = FALLBACK_ICON_BY_ELEMENT_ID[element_id]
      return icon_id == nil ? 0 : icon_id.to_i
    end

    def self.action_for(skill_id)
      return "NORMAL_ATTACK" if MELEE_SKILL_IDS.include?(skill_id)
      return "SKILL_USE"
    end

    def self.apply!
      return false unless defined?(FS_MASTER_SETUP::SKILLS)
      return false unless FS_MASTER_SETUP::SKILLS.const_defined?(:DATA)
      return false unless FS_MASTER_SETUP::SKILLS.const_defined?(:ACTION_OVERRIDES)

      data_table = FS_MASTER_SETUP::SKILLS::DATA
      action_table = FS_MASTER_SETUP::SKILLS::ACTION_OVERRIDES

      data_table.keys.each do |skill_id|
        next unless managed_skill_id?(skill_id)

        data = data_table[skill_id]
        next unless data.is_a?(Hash)

        element_id = primary_element_id(skill_id, data)
        icon_id = icon_id_for_element(element_id)
        data[:icon_index] = icon_id if icon_id > 0

        action_table[skill_id] = action_for(skill_id)
      end

      return true
    end
  end
end

FS_MASTER_SETUP::POKEMON_SKILL_VISUALS.apply!
