#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_12｜FS_EnemySummonGuard_FinalAuthority v1.3.6
# 【用途】Enemy Summon 最終 Guard；限制 Enemy Summon 標籤、召喚條件與安全行為。
# 【前置】EnemySummon_Core v1.1 已包含 SafePosition；本頁必須在所有可能重定義 skill_can_use?／execute_action_skill 的後載入補丁之後，才能維持「Actor 不得使用 Enemy Summon」的最終性。
# 【主要 API】FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?、without_enemy_summon_tag；RPG::Skill#ma_call_ally? / ma_call_ally 會以嚴格 Regex 重定義。
# 【Final Guard】Game_Actor#skill_can_use? 最終拒絕召喚標籤；Game_Troop#ma_call_ally 拒絕 Actor／缺少 ma_summon_count 的 user；Scene_Battle 即使被強制行動繞過，也會暫時移除錯誤標籤後執行技能其他效果。
# 【載入順序】保留 AutoSetup_12 的後段位置；不要搬到 EnemySummon_Core 緊鄰下方，否則後載入的舊 skill_can_use? 補丁可能再次繞過它。
# 【素材】無固定 Graphics／Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#------------------------------------------------------------------------------
#
# 【修正問題】
# 1. 舊 Skill ID 被重新利用時，資料庫 Note 可能殘留：
#      \SUMMON_ENEMY[enemy_id, x, y, chance]
#    AutoSetup 舊版為了保留 SBS Note，會把這種未知舊標籤留下。
#
# 2. Modern Algebra Enemy Summon Skill 原本只替 Game_Enemy 建立
#    ma_summon_count；若角色技能被誤判為召喚技能，便會把 Game_Actor
#    傳入 Game_Troop#ma_call_ally，造成 NoMethodError。
#
# 3. 專案中有數個後載入腳本直接重定義 Game_Actor#skill_can_use? 為
#    return super(skill)，會繞過 Enemy Summon Skill 原本的角色禁用判斷。
#
# 【安裝位置】
# 放在以下腳本全部之下、Main 之上：
# - EnemySummon_Core v1.1（已內建 SafePosition）
# - 所有 skill_can_use? 補丁
#
# 建議順序：
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Enemy Summon Guard"] = "1.3.4"

module FS_ENEMY_SUMMON_GUARD
  TAG = /\\SUMMON_ENEMY\[\s*(\d+)\s*(?:[,;]\s*(-?\d*))?\s*(?:[,;]\s*(-?\d*))?\s*(?:[,;]\s*(\d*))?\s*\]/i
  ANY_TAG = /\\SUMMON_ENEMY\[[^\]]*\]/i

  def self.enemy_summon_skill?(skill)
    return false if skill == nil || !skill.respond_to?(:note)
    return skill.note.to_s =~ ANY_TAG ? true : false
  end

  def self.without_enemy_summon_tag(skill)
    return yield if skill == nil || !skill.respond_to?(:note=)
    original = skill.note.to_s
    cleaned = original.gsub(ANY_TAG, "")
    return yield if cleaned == original

    skill.note = cleaned
    begin
      return yield
    ensure
      skill.note = original
    end
  end
end

#==============================================================================
#   以嚴格的「反斜線＋完整標籤」解析，避免原常數插入 Regexp 後把 \S
#   解讀成「任一非空白字元」。
#==============================================================================
class RPG::Skill < RPG::UsableItem
  def ma_call_ally?
    return FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(self)
  end

  def ma_call_ally
    miss = rand(100)
    return nil if self.hit < miss

    possibilities = []
    self.note.to_s.scan(FS_ENEMY_SUMMON_GUARD::TAG) do |data|
      id = data[0].to_i
      x = data[1].to_s.empty? ? MAES_DEFAULT_X_PLUS : data[1].to_i
      y = data[2].to_s.empty? ? MAES_DEFAULT_Y_PLUS : data[2].to_i
      weight = data[3].to_s.empty? ? 1 : [data[3].to_i, 1].max
      weight.times { possibilities.push([id, x, y]) }
    end

    return nil if possibilities.empty?
    return *possibilities[rand(possibilities.size)]
  end
end

#==============================================================================
#   最終層再次禁止角色使用「敵人召喚」技能。
#==============================================================================
class Game_Actor < Game_Battler
  unless method_defined?(:fs_enemy_summon_guard_skill_can_use)
    alias fs_enemy_summon_guard_skill_can_use skill_can_use?
  end

  def skill_can_use?(skill)
    return false if FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(skill)
    return fs_enemy_summon_guard_skill_can_use(skill)
  end
end

#==============================================================================
#   ma_call_ally 只接受 Game_Enemy。Boss Runtime 仍可正常使用。
#==============================================================================
class Game_Troop < Game_Unit
  unless method_defined?(:fs_enemy_summon_guard_ma_call_ally)
    alias fs_enemy_summon_guard_ma_call_ally ma_call_ally
  end

  def ma_call_ally(user, enemy_id, x, y)
    return nil if user == nil
    return nil if user.respond_to?(:actor?) && user.actor?
    return nil unless user.respond_to?(:ma_summon_count)
    user.ma_summon_count = 0 if user.ma_summon_count == nil
    return fs_enemy_summon_guard_ma_call_ally(user, enemy_id, x, y)
  end
end

#==============================================================================
#   即使事件強制行動或其他腳本繞過 skill_can_use?，角色也不會進入
#   Enemy Summon Skill 的分支。暫時只移除錯誤標籤，技能其餘效果照常執行。
#==============================================================================
class Scene_Battle < Scene_Base
  unless method_defined?(:fs_enemy_summon_guard_execute_action_skill)
    alias fs_enemy_summon_guard_execute_action_skill execute_action_skill
  end

  def execute_action_skill(*args)
    battler = @active_battler
    skill = nil
    if battler != nil && battler.respond_to?(:action) && battler.action != nil
      skill = battler.action.skill
    end

    if battler != nil && battler.respond_to?(:actor?) && battler.actor? &&
       FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(skill)
      return FS_ENEMY_SUMMON_GUARD.without_enemy_summon_tag(skill) do
        fs_enemy_summon_guard_execute_action_skill(*args)
      end
    end

    return fs_enemy_summon_guard_execute_action_skill(*args)
  end
end
