#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：EnemySummon_Core v1.1｜Enemy-only + SafePosition
# 【來源】modern algebra Enemy Summon Skill v1.0（2010-05-08）＋ Forest Symphony EnemySummon SafePosition 修正。Phase 20 把原本誤放在 TargetingCompatibility 的 SafePosition 責任回寫本 Core。
# 【用途】只允許 Enemy 在戰鬥中用 Skill 動態新增其他 Enemy；這不是玩家召喚物系統，與 `FS_SummonRuntime_Authority`（我方 Actor 召喚）是兩套不同 Runtime。
# 【Skill Notetag】`\SUMMON_ENEMY[enemy_id, x, y, chance]`。x/y 是相對召喚者的像素增量，可省略使用 MAES_DEFAULT_X_PLUS/Y_PLUS；chance 是候選權重，不是獨立百分比。
# 【範例】同一 Skill Note：`\SUMMON_ENEMY[1,35,45,3]` 與 `\SUMMON_ENEMY[2,25,35,1]`，命中成功後會以 3:1 權重抽 Enemy 1/2。
# 【設定】MAES_MAX_TROOP_SIZE=12；MAES_DEFAULT_X_PLUS=35；MAES_DEFAULT_Y_PLUS=25；MAES_VOCAB_SUMMON_FAILURE 為失敗文案；MAES_NOTECODE="\\SUMMON_ENEMY"。
# 【SafePosition】Game_Troop#ma_call_ally 現由本頁直接使用安全位置實作：最多嘗試 48 個候選；x=y=0 時以 32px 格狀偏移搜尋；避免原版未賦值 screen_x/screen_y 與重疊時無限迴圈。歷史常數命名 `ALBERT_ENEMY_SUMMON_SAFE_POSITION` 保留作相容。
# 【最終安全層】後方 `AutoSetup_12｜FS_EnemySummonGuard_FinalAuthority` 仍會重新解析 Notetag、禁止 Actor 誤用、包裝 ma_call_ally 與 execute_action_skill；所以本頁是 Enemy Summon Core，不是整條鏈最後一頁。
# 【其他依賴】AutoSetup_09_BossRuntime 會直接呼叫 ma_call_ally；SummonGuard_DynamicThreat 與 Targeting 只處理新 Enemy 的威脅／選取，不等於我方 Summon。
# 【素材】無固定 Graphics／Audio；召喚 Enemy 圖像由 Database Enemy battler 與現有 Spriteset_Battle 自動取得。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: May 8, 2010
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 說明：
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 使用說明：
#
#
#
#
#      \SUMMON_ENEMY[enemy_id, x, y, chance]
#
#
#
#      \summon_enemy[1, 35, 45, 3]
#      \summon_enemy[2, 25, 35, 1]
#
#==============================================================================
# 設定
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================
MAES_VOCAB_SUMMON_FAILURE = "%s failed to summon ally!"
MAES_MAX_TROOP_SIZE = 12
MAES_DEFAULT_X_PLUS = 35
MAES_DEFAULT_Y_PLUS = 25
MAES_NOTECODE = "\\SUMMON_ENEMY"

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class RPG::Skill
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_call_ally?
    return self.note[/#{MAES_NOTECODE}\[\d+.*?\]/i] != nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_call_ally
    miss = rand (100)
    return nil if self.hit < miss
    possibilities = []
    note = self.note.dup
    note.gsub! (/#{MAES_NOTECODE}\[(\d+)[,;]?\s*(-?\d*)[,;]?\s*(-?\d*)[,;]?\s*(\d*)\]/i) { |match|
      id = $1.to_i
      x = $2.empty? ? MAES_DEFAULT_X_PLUS : $2.to_i
      y = $3.empty? ? MAES_DEFAULT_Y_PLUS : $3.to_i
      percent = $4.empty? ? 1 : $4.to_i
      (percent).times do possibilities.push ([id, x, y]) end
      ""
    }
    return *possibilities[rand(possibilities.size)]
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :ma_summon_count
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias moda_clally_intz_7uj2 initialize
  def initialize (*args)
    @ma_summon_count = 0
    moda_clally_intz_7uj2 (*args) # 執行原方法
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias moral_caly_skllcnuse_6yh1 skill_can_use?
  def skill_can_use? (skill, *args)
    return false if skill.ma_call_ally? && $game_troop.members.size >= MAES_MAX_TROOP_SIZE
    return moral_caly_skllcnuse_6yh1 (skill, *args)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modbr_ess_skcnuse_7uj2 skill_can_use?
  def skill_can_use? (skill, *args)
    return false if skill.ma_call_ally?
    return modbr_ess_skcnuse_7uj2 (skill, *args)
  end
end

#==============================================================================
# ** Enemy Summon Safe Position（FS Phase 20 回寫）
#==============================================================================
module ALBERT_ENEMY_SUMMON_SAFE_POSITION
  # 最多嘗試多少個位置，避免任何情況下卡死。
  MAX_POSITION_ATTEMPTS = 48

  # 當 x、y 都是 0 時，用這組偏移搜尋周邊位置。
  GRID_STEP = 32
  BASE_OFFSETS = [
    [ 0,  0],
    [ 1,  0], [-1,  0], [ 0,  1], [ 0, -1],
    [ 1,  1], [-1,  1], [ 1, -1], [-1, -1],
    [ 2,  0], [-2,  0], [ 0,  2], [ 0, -2]
  ]

  def self.zero_step_offset(attempt)
    size = BASE_OFFSETS.size
    base = BASE_OFFSETS[attempt % size]
    ring = attempt / size + 1
    return [base[0] * GRID_STEP * ring,
            base[1] * GRID_STEP * ring]
  end
end

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # 安全判斷座標是否已被敵人佔用
  #--------------------------------------------------------------------------
  def albert_enemy_summon_position_occupied?(screen_x, screen_y)
    for battler in @enemies
      next if battler == nil
      return true if battler.screen_x == screen_x &&
                     battler.screen_y == screen_y
    end
    return false
  end

  #--------------------------------------------------------------------------
  # user     : 使用召喚技能的敵人
  # enemy_id : 被召喚敵人的 Enemy ID
  # x, y     : 每次召喚相對於 user 的座標增量
  #--------------------------------------------------------------------------
  def ma_call_ally(user, enemy_id, x, y)
    user.ma_summon_count += 1
    enemy = Game_Enemy.new(@enemies.size, enemy_id)

    step_x = x.to_i
    step_y = y.to_i
    start_count = user.ma_summon_count
    found = false
    attempt = 0
    last_x = user.screen_x
    last_y = user.screen_y

    while attempt < ALBERT_ENEMY_SUMMON_SAFE_POSITION::MAX_POSITION_ATTEMPTS
      count = start_count + attempt
      candidate_x = user.screen_x + step_x * count
      candidate_y = user.screen_y + step_y * count

      # 若 x、y 都是 0，原公式永遠會得到相同位置。
      # 改用安全的周邊格狀搜尋。
      if step_x == 0 && step_y == 0
        offset = ALBERT_ENEMY_SUMMON_SAFE_POSITION.zero_step_offset(attempt)
        candidate_x += offset[0]
        candidate_y += offset[1]
      end

      last_x = candidate_x
      last_y = candidate_y

      unless albert_enemy_summon_position_occupied?(candidate_x, candidate_y)
        enemy.screen_x = candidate_x
        enemy.screen_y = candidate_y
        user.ma_summon_count = count
        found = true
        break
      end

      attempt += 1
    end

    # 極端情況：48 個候選位置都被佔用。
    # 不再無限迴圈，直接使用最後候選位置完成召喚。
    unless found
      enemy.screen_x = last_x
      enemy.screen_y = last_y
      user.ma_summon_count = start_count + attempt
    end

    @enemies.push(enemy)
    make_unique_names
    return enemy
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Spriteset_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_call_enemy (battler)
    @enemy_sprites.push(Sprite_Battler.new(@viewport1, battler))
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Scene_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malb_callally_exactsk_5hy1 execute_action_skill
  def execute_action_skill (*args)
    skill = @active_battler.action.skill
    if skill.ma_call_ally?
      enemy_id, x, y = skill.ma_call_ally
      if enemy_id.nil?
        text = sprintf (MAES_VOCAB_SUMMON_FAILURE, @active_battler.name)
        @message_window.add_instant_text(text)
        wait (30)
        return
      else
        target = $game_troop.ma_call_ally (@active_battler, enemy_id, x, y)
        @spriteset.ma_call_enemy (target)
        display_animation([target], skill.animation_id)
      end
    end
    malb_callally_exactsk_5hy1 (*args) # 執行原方法
  end
end