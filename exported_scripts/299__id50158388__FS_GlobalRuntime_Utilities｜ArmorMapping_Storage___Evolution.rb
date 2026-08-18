#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_GlobalRuntime_Utilities｜ArmorMapping Storage / Evolution
# 【用途】保留的 Runtime 元件「全局工具」。
# 【主要機制】ArmorMapping 僅提供持久化 Storage/API；正式核心 Mapping 資料由後方 FS_DatabaseSupport_Authority 注入。另保留 ArmorManager、EvolutionTable、ElementalSettings。
# 【主要影響】ArmorMapping、ArmorManager、EvolutionTable、ElementalSettings
# 【設定／可調參數】ArmorMapping 本頁不再保存 101/103/105 或 Compact ID 預設資料；Mapping Authority 請改 FS_DatabaseSupport_Authority。Evolution／ElementalSettings 仍依本頁既有表維護。
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
# 全局工具 2: ArmorManager - 管理待命角色的暫存與還原
# 全局工具 1: ArmorMapping - 管理防具與角色的對應關係
# 全局工具 3: EvolutionTable - 管理進化
# Phase 29：本頁只擁有 Storage/API，不保存任何正式 Mapping Data。
class Game_System
  attr_accessor :armor_mapping
end

module ArmorMapping
  def self.mapping
    return {} if $game_system == nil
    $game_system.armor_mapping ||= {}
  end

  def self.set_mapping(new_mapping)
    $game_system.armor_mapping = new_mapping
  end

  def self.add_mapping(armor_id, actor_id)
    mapping[armor_id] = actor_id
  end

  def self.remove_mapping(armor_id)
    mapping.delete(armor_id)
  end

  def self.[](armor_id)
    mapping[armor_id]
  end

  def self.update_mapping(old_actor_id, new_actor_id)
    mapping.each do |armor_id, actor_id|
      if actor_id == old_actor_id
        mapping[armor_id] = new_actor_id
        $game_message.add("防具進化成功！#{old_actor_id} 變為 #{new_actor_id}！")
      end
    end
  end
end



# 全局工具 2: ArmorManager - 管理待命角色的暫存與還原
module ArmorManager
  @temp_actor_ids = []

  # 儲存目前待命成員的 ID 並從隊伍中移除
  def self.store_members
    @temp_actor_ids = $game_party.stand_by_members.map { |actor| actor.id }
    @temp_actor_ids.each { |id| $game_party.remove_actor(id) }
  end

  # 還原之前儲存的成員
  def self.restore_members
    @temp_actor_ids.each { |id| $game_party.add_actor(id) }
    @temp_actor_ids = []  # 還原後清空暫存陣列
  end

  # 可供其他腳本讀取暫存的角色 ID 陣列
  def self.temp_actor_ids
    @temp_actor_ids
  end
end


module EvolutionTable
  DATA = {
    11 => { :level => 16, :next_id => 12 },  # 進化妙蛙草
    12 => { :level => 32, :next_id => 13 }, # 進化妙蛙花
    14 => { :level => 18, :next_id => 15 },  # 進化火恐龍
    15 => { :level => 36, :next_id => 16 }, # 進化噴火龍
    17 => { :level => 18, :next_id => 18 },  # 進化卡咪龜
    18 => { :level => 36, :next_id => 19 }, # 進化水箭龜
    20 => { :level => 7, :next_id => 21 }, # 進化鐵甲蛹
    21 => { :level => 10, :next_id => 22 }, # 進化巴大蝴
    23 => { :level => 7, :next_id => 24 }, # 進化鐵殼蛹
    24 => { :level => 10, :next_id => 25 }, # 進化大針鋒
    26 => { :level => 18, :next_id => 27 }, # 進化比比鳥
    27 => { :level => 36, :next_id => 28 }, # 進化大比鳥
    29 => { :level => 20, :next_id => 30 }, # 進化拉達
    31 => { :level => 20, :next_id => 32 }, # 進化大嘴雀
    33 => { :level => 22, :next_id => 34 }, # 進化阿柏怪
    35 => { :level => 12, :next_id => 36 }, # 進化皮卡丘
    36 => { :level => 30, :next_id => 37 }, # 進化雷丘
    38 => { :level => 22, :next_id => 39 }, # 進化穿山王
    40 => { :level => 30, :next_id => 41 }, # 進化六尾
    42 => { :level => 12, :next_id => 43 }, # 進化胖丁
    43 => { :level => 30, :next_id => 44 }, # 進化胖可丁
    45 => { :level => 22, :next_id => 46 }, # 進化大嘴蝠
    46 => { :level => 38, :next_id => 47 }, # 進化叉字蝠
  }

  def self.evolve?(actor_id, level)
    return nil unless DATA[actor_id]  # 如果角色沒有對應進化條件，返回 nil
    return DATA[actor_id][:next_id] if level >= DATA[actor_id][:level]
    return nil
  end
end

ELEMENT_ID_MAP = {
  :normal    => 4,
  :fighting  => 5,
  :flying    => 6,
  :poison    => 7,
  :ground    => 8,
  :rock      => 9,
  :bug       => 10,
  :ghost     => 11,
  :steel     => 12,
  :fire      => 13,
  :water     => 14,
  :grass     => 15,
  :electric  => 16,
  :psychic   => 17,
  :ice       => 18,
  :dragon    => 19,
  :dark      => 20,
  :fairy     => 21
}


# 📌 模組：設定角色與敵人的屬性對應表
module ElementalSettings
  # 角色職業屬性表（根據 Class ID 設定）
  CLASS_ELEMENT_TABLE = {
    1 => [:normal, nil],  
    2 => [:normal, nil],
    3 => [:normal, nil],
    4 => [:normal, nil],
    5 => [:normal, nil],
    6 => [:normal, nil],
    7 => [:normal, nil],
    8 => [:normal, nil],
    9 => [:normal, nil],  
    10 => [:grass, nil],       
    11 => [:grass, :poison], # 妙蛙種子
    12 => [:grass, :poison], # 妙蛙草
    13 => [:grass, :poison], # 妙蛙花
    14 => [:fire, nil], # 小火龍
    15 => [:fire, nil], # 火恐龍
    16 => [:fire, :dragon], # 噴火龍
    17 => [:water, nil], # 傑尼龜
    18 => [:water, nil], # 卡咪龜
    19 => [:water, :steel], # 水箭龜
    20 => [:bug, nil], # 綠毛蟲
    21 => [:bug, nil], # 鐵甲蛹
    22 => [:bug, :flying], # 巴大蝶
    23 => [:bug, :poison], # 獨角蟲
    24 => [:bug, :poison], # 鐵殼蛹
    25 => [:bug, :poison], # 大針鋒
    26 => [:normal, :flying], # 波波
    27 => [:normal, :flying], # 比比鳥
    28 => [:normal, :flying], # 大比鳥
    29 => [:normal, nil], # 小拉達
    30 => [:normal, nil], # 拉達
    31 => [:normal, :flying], # 列雀
    32 => [:normal, :flying], # 大嘴雀
    33 => [:poison, nil], # 阿柏蛇
    34 => [:poison, nil], # 阿柏怪
    35 => [:electric, nil], # 皮丘
    36 => [:electric, nil], # 皮卡丘
    37 => [:electric, nil], # 雷丘
    38 => [:ground, nil], # 穿山鼠
    39 => [:ground, nil], # 穿山王
    40 => [:fire, nil], # 六尾
    41 => [:fire, nil], # 九尾
    42 => [:normal, :fairy], # 寶寶丁
    43 => [:normal, :fairy], # 胖丁
    44 => [:normal, :fairy], # 胖可丁
    45 => [:flying, :poison], # 超音蝠
    46 => [:flying, :poison], # 大嘴蝠
    47 => [:flying, :poison], # 叉字蝠
  }

  # 敵人屬性表（根據 Enemy ID 設定）
  ENEMY_ELEMENT_TABLE = {
    1 => [:grass, :poison], # 妙蛙種子
    2 => [:grass, :poison], # 妙蛙草
    3 => [:grass, :poison], # 妙蛙花
    4 => [:fire, nil], # 小火龍
    5 => [:fire, nil], # 火恐龍
    6 => [:fire, :dragon], # 噴火龍
    7 => [:water, nil], # 傑尼龜
    8 => [:water, nil], # 卡咪龜
    9 => [:water, :steel], # 水箭龜
    10 => [:bug, nil], # 綠毛蟲
    11 => [:bug, nil], # 鐵甲蛹
    12 => [:bug, :flying], # 巴大蝶
    13 => [:bug, :poison], # 獨角蟲
    14 => [:bug, :poison], # 鐵殼蛹
    15 => [:bug, :poison], # 大針鋒
    16 => [:normal, :flying], # 波波
    17 => [:normal, :flying], # 比比鳥
    18 => [:normal, :flying], # 大比鳥
    19 => [:normal, nil], # 小拉達
    20 => [:normal, nil], # 拉達
    21 => [:normal, :flying], # 列雀
    22 => [:normal, :flying], # 大嘴雀
  }
end