#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EnemyActionDistribution_FinalAuthority v1.1
# 【用途】保留的 Runtime 元件「EnemyActionDistribution」。
# 【主要機制】主要定義／擴充 Game_Enemy、FS_ENEMY_ACTION_DIST、FS；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Enemy、FS_ENEMY_ACTION_DIST、FS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ENEMY_ID_MIN、ENEMY_ID_MAX、PARTY_ATTACK_RATE、PARTY_ATTACK_RATE_DEFAULT、OUTNUMBERED_BONUS_PER_ENEMY、OUTNUMBERED_BONUS_MAX、AFTER_DAMAGE_SKILL_BONUS、RATE_MIN。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Enemy Action Distribution。
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
# 【Phase 23】本頁確認為 Game_Enemy#make_action 的最終專案 wrapper；Pokemon Enemy 600～745 的「改普通攻擊」抽選已改走 FS_AI_RANDOM。
#==============================================================================
#==============================================================================
# ■ FS_EnemyActionDistribution_v1_1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【目的】
# Enemy 600～745 的 Pokémon 行動表目前幾乎只有 Skill。
# 本補丁依我方存活人數、敵我數量與 Break Threshold，
# 在原 AI 完成選招後，以一定機率改成普通攻擊。
#
# 原本的技能條件、評價、狀態技、治療技與隨機性全部保留。
# 菁英、Boss、核心、召喚成長源、Robot 與人類敵人完全不受影響。
#
# 【必要位置】
# 放在所有 Enemy AI／make_action 補丁之下，
# FS_ElementRate_FinalGuard_v1_1 之上：
#
#   其他 Enemy AI
#   FS_EnemyActionDistribution_v1_0
#   FS_ElementRate_FinalGuard_v1_1
#   Main
#
# 【預設普通攻擊率】
# 我方存活 1 人：70%
# 我方存活 2 人：55%
# 我方存活 3 人：45%
# 我方存活 4 人以上：35%
#
# 當敵方存活數多於我方時，每多一隻再增加 5%，最多增加 15%。
# 若上一個行動是正傷害技能，下次普通攻擊率再增加 20%。
#
# Break Threshold 修正：
#   1～3：+10%
#   4～5：+5%
#   6～7：不變
#   8～9：-5%
#   10以上：-10%
#
# 【Enemy Note，可放在 08 Enemies 或 90 UserExtensions】
#   <enemy_attack_rate:60>       固定普通攻擊率
#   <enemy_attack_rate_add:10>   在自動計算後加減
#   <enemy_action_dist_off>      不套用本系統
#
# 【短測試】
# 戰鬥事件腳本：
#   FS.ad
#
# 顯示：
# [Enemy ID, 名稱, 我方存活數, 敵方存活數, 普攻率, 上次是否傷害技能]
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Enemy Action Distribution"] = "1.1"

module FS_ENEMY_ACTION_DIST
  ENEMY_ID_MIN = 600
  ENEMY_ID_MAX = 745

  PARTY_ATTACK_RATE = {
    1 => 70,
    2 => 55,
    3 => 45
  }
  PARTY_ATTACK_RATE_DEFAULT = 35

  OUTNUMBERED_BONUS_PER_ENEMY = 5
  OUTNUMBERED_BONUS_MAX = 15
  AFTER_DAMAGE_SKILL_BONUS = 20

  RATE_MIN = 15
  RATE_MAX = 90

  OFF_TAG = /<enemy_action_dist_off>/i
  RATE_TAG = /<enemy_attack_rate\s*:\s*(-?\d+)>/i
  ADD_TAG = /<enemy_attack_rate_add\s*:\s*([+-]?\d+)>/i
  BREAK_TAG = /<break_threshold\s*:\s*(\d+)>/i

  def self.note(enemy)
    return "" if enemy == nil || enemy.enemy == nil
    return enemy.enemy.note.to_s
  end

  def self.eligible?(enemy)
    return false if enemy == nil
    return false unless enemy.respond_to?(:enemy_id)
    return false if enemy.enemy_id < ENEMY_ID_MIN
    return false if enemy.enemy_id > ENEMY_ID_MAX
    return false if note(enemy) =~ OFF_TAG
    if enemy.respond_to?(:friendly?)
      return false if enemy.friendly?
    end
    return true
  end

  def self.party_alive_count
    return 1 if $game_party == nil
    members = $game_party.existing_members
    return 1 if members == nil || members.empty?
    return members.size
  rescue
    return 1
  end

  def self.enemy_alive_count
    return 1 if $game_troop == nil
    members = $game_troop.existing_members
    return 1 if members == nil || members.empty?
    return members.size
  rescue
    return 1
  end

  def self.base_party_rate(party_count)
    return PARTY_ATTACK_RATE[party_count] if PARTY_ATTACK_RATE.has_key?(party_count)
    return PARTY_ATTACK_RATE_DEFAULT
  end

  def self.break_threshold(enemy)
    text = note(enemy)
    return $1.to_i if text =~ BREAK_TAG
    return 6
  end

  def self.break_adjustment(enemy)
    value = break_threshold(enemy)
    return 10 if value <= 3
    return 5 if value <= 5
    return 0 if value <= 7
    return -5 if value <= 9
    return -10
  end

  def self.note_fixed_rate(enemy)
    text = note(enemy)
    return $1.to_i if text =~ RATE_TAG
    return nil
  end

  def self.note_rate_add(enemy)
    text = note(enemy)
    return $1.to_i if text =~ ADD_TAG
    return 0
  end

  def self.attack_rate(enemy, party_count = nil, enemy_count = nil)
    fixed = note_fixed_rate(enemy)
    unless fixed == nil
      return [[fixed, RATE_MIN].max, RATE_MAX].min
    end

    party_count = party_alive_count if party_count == nil
    enemy_count = enemy_alive_count if enemy_count == nil

    rate = base_party_rate(party_count)
    rate += break_adjustment(enemy)

    extra = enemy_count - party_count
    if extra > 0
      bonus = extra * OUTNUMBERED_BONUS_PER_ENEMY
      bonus = OUTNUMBERED_BONUS_MAX if bonus > OUTNUMBERED_BONUS_MAX
      rate += bonus
    end

    if enemy.instance_variable_get(:@fs_ead_last_damage_skill)
      rate += AFTER_DAMAGE_SKILL_BONUS
    end

    rate += note_rate_add(enemy)
    return [[rate, RATE_MIN].max, RATE_MAX].min
  end

  def self.urgent_friend_skill?(skill)
    return false if skill == nil
    return true if skill.for_dead_friend?
    return true if skill.base_damage.to_i < 0
    if skill.for_friend? && skill.respond_to?(:minus_state_set)
      return true unless skill.minus_state_set.empty?
    end
    return false
  end

  def self.damage_skill?(action)
    return false if action == nil
    return false unless action.kind == 1
    skill = $data_skills[action.skill_id]
    return false if skill == nil
    return skill.base_damage.to_i > 0
  end

  def self.can_replace_with_attack?(enemy)
    return false unless eligible?(enemy)
    return false unless enemy.movable?
    action = enemy.action
    return false if action == nil
    return false unless action.kind == 1

    skill = $data_skills[action.skill_id]
    return false if skill == nil

    # 治療、復活與解狀態保留，避免治癒型敵人失去特色。
    return false if urgent_friend_skill?(skill)
    return true
  end

  def self.set_attack(enemy)
    enemy.action.set_attack
    if enemy.action.respond_to?(:decide_random_target)
      enemy.action.decide_random_target
    else
      enemy.action.target_index = 0
    end
  end

  def self.record_final_action(enemy)
    value = damage_skill?(enemy.action)
    enemy.instance_variable_set(:@fs_ead_last_damage_skill, value)
  end
end

class Game_Enemy < Game_Battler
  unless method_defined?(:fs_ead_original_make_action)
    alias fs_ead_original_make_action make_action
  end

  def make_action
    fs_ead_original_make_action

    if FS_ENEMY_ACTION_DIST.can_replace_with_attack?(self)
      rate = FS_ENEMY_ACTION_DIST.attack_rate(self)
      FS_ENEMY_ACTION_DIST.set_attack(self) if FS_AI_RANDOM.rand(100, :enemy_attack_distribution) < rate
    end

    FS_ENEMY_ACTION_DIST.record_final_action(self)
  end

  def fs_enemy_attack_rate
    return FS_ENEMY_ACTION_DIST.attack_rate(self)
  end
end

module FS
  def self.ad
    return if $game_troop == nil
    party_count = FS_ENEMY_ACTION_DIST.party_alive_count
    enemy_count = FS_ENEMY_ACTION_DIST.enemy_alive_count
    $game_troop.existing_members.each do |enemy|
      next unless FS_ENEMY_ACTION_DIST.eligible?(enemy)
      p [
        enemy.enemy_id,
        enemy.name,
        party_count,
        enemy_count,
        enemy.fs_enemy_attack_rate,
        enemy.instance_variable_get(:@fs_ead_last_damage_skill) == true
      ]
    end
  end
end
