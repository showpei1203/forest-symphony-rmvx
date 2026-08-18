#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_BattleCount2｜戰鬥統計相關
# 【來源】KGC 原版，Mr. Anonymous Version 2，2008-04-13。
# 【用途】持久記錄戰鬥次數、勝利／逃跑／敗北、各 Enemy 擊破數、全敵擊破總數、各 Actor 死亡次數與全隊死亡總數，供事件、EnemyBook／圖鑑與其他系統查詢。
# 【使用變數】BATTLE_COUNT=26、VICTORY_COUNT=27、ESCAPE_COUNT=28、LOSE_COUNT=29、TOTAL_DEFEAT_COUNT=30、TOTAL_DEAD_COUNT=31。這些是實際遊戲變數 ID，改動前必須反查事件是否直接讀取。
# 【事件 Script Call】reset_battle_count；get_defeat_count(enemy_id, variable_id)；get_dead_count(actor_id, variable_id)。例如 get_defeat_count(5, 40) 會把 Enemy 5 的擊破數寫進 Variable 40 並回傳該值。
# 【其他 API】$game_system.battle_count/victory_count/escape_count/lose_count；defeat_count(enemy_id)；dead_count(actor_id)；total_defeat_count；total_dead_count。KGC::Commands 亦提供對應 getter/setter。
# 【計數時機】Scene_Battle#post_start 每場 +1；battle_end(result) 依 0勝利／1逃跑／2敗北累計，並把 dead_members 加入擊破；execute_action 前後比較 existing_members 以記錄本次行動造成的 Actor 死亡。
# 【現行依賴】KGC_EnemyGuide 會讀 KGC::Commands.get_defeat_count；FS EnemyBook Runtime 亦會讀 $game_system.defeat_count，因此本頁仍是正式資料來源，不能因「只是統計」退休。
# 【Save】@defeat_count／@dead_count 存於 Game_System；讀舊存檔時 getter 會在 nil 時重建。若更換資料結構要測舊存檔。
# 【相關素材】無 Graphics／Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
#_/    ◆                    Original Version by KGC                         ◆
#_/    ◆                  Version 2 by Mr. Anonymous                        ◆
#_/-----------------------------------------------------------------------------
#_/=============================================================================
#_/
#_/
#_/
#_/
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_

#==============================================================================#
#==============================================================================#
module KGC
  module BattleCount
    
    # 下列常數值就是實際保存各統計值的遊戲 Variable ID。
    
    BATTLE_COUNT = 26
    
    VICTORY_COUNT = 27
    
    ESCAPE_COUNT =28
    
    LOSE_COUNT = 29
    
    TOTAL_DEFEAT_COUNT = 30
    
    TOTAL_DEAD_COUNT = 31   
    
  end
end

#------------------------------------------------------------------------------#

$imported = {} if $imported == nil
$imported["BattleCount"] = true

#==============================================================================#
#==============================================================================#

module KGC
 module Commands
  module_function
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def reset_battle_count
    $game_system.reset_battle_count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_battle_count=(count)
    $game_variables[KGC::BattleCount::BATTLE_COUNT] = count 
    return count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_victory_count=(count)
    $game_variables[KGC::BattleCount::VICTORY_COUNT] = count  
    return count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_escape_count=(count)
    $game_variables[KGC::BattleCount::ESCAPE_COUNT] = count 
    return count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_lose_count=(count)
    $game_variables[KGC::BattleCount::LOSE_COUNT] = count 
    return count
  end
  #--------------------------------------------------------------------------
  #     enemy_id    : Enemy ID
  #     variable_id : Variable ID
  #--------------------------------------------------------------------------
  def get_defeat_count(enemy_id, variable_id = 0)
    count = $game_system.defeat_count(enemy_id)
    $game_variables[variable_id] = count if variable_id > 0
    return count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_total_defeat_count=(count)
    $game_variables[KGC::BattleCount::TOTAL_DEFEAT_COUNT] = count 
    return count
  end
  #--------------------------------------------------------------------------
  #     actor_id    : Actor ID
  #     variable_id : Variable ID
  #--------------------------------------------------------------------------
  def get_dead_count(actor_id, variable_id = 0)
    count = $game_system.dead_count(actor_id)
    $game_variables[variable_id] = count if variable_id > 0
    return count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_total_dead_count=(count)
    $game_variables[KGC::BattleCount::TOTAL_DEAD_COUNT] = count 
    return count
  end
 end
end

class Game_Interpreter
  include KGC::Commands
end


#==============================================================================
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_writer   :defeat_count # 詳見頁首繁中維護說明
  attr_writer   :dead_count # 詳見頁首繁中維護說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_KGC_BattleCount initialize
  def initialize
    initialize_KGC_BattleCount

    reset_battle_count
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def reset_battle_count
    battle_count  = 0
    victory_count = 0
    escape_count  = 0
    lose_count    = 0
    @defeat_count = []
    @dead_count   = []
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def battle_count
    reset_battle_count if $game_variables[KGC::BattleCount::BATTLE_COUNT] == nil
    return $game_variables[KGC::BattleCount::BATTLE_COUNT]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def victory_count
    reset_battle_count if $game_variables[KGC::BattleCount::VICTORY_COUNT] == nil
    return $game_variables[KGC::BattleCount::VICTORY_COUNT]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def escape_count
    reset_battle_count if $game_variables[KGC::BattleCount::ESCAPE_COUNT] == nil
    return $game_variables[KGC::BattleCount::ESCAPE_COUNT]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def lose_count
    reset_battle_count if $game_variables[KGC::BattleCount::LOSE_COUNT] == nil
    return $game_variables[KGC::BattleCount::LOSE_COUNT]
  end
  #--------------------------------------------------------------------------
  #     enemy_id : Enemy ID
  #--------------------------------------------------------------------------
  def defeat_count(enemy_id)
    reset_battle_count if @defeat_count == nil
    @defeat_count[enemy_id] = 0 if @defeat_count[enemy_id] == nil
    return @defeat_count[enemy_id]
  end
  #--------------------------------------------------------------------------
  #     enemy_id : Enemy ID
  #--------------------------------------------------------------------------
  def add_defeat_count(enemy_id)
    reset_battle_count if @defeat_count == nil
    @defeat_count[enemy_id] = 0 if @defeat_count[enemy_id] == nil
    @defeat_count[enemy_id] += 1
    $game_variables[KGC::BattleCount::TOTAL_DEFEAT_COUNT] = @defeat_count[-1]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def total_defeat_count
    n = 0
    for i in 1...$data_enemies.size
      n += defeat_count(i)
    end
    return n
  end
  #--------------------------------------------------------------------------
  #     actor_id : Actor ID
  #--------------------------------------------------------------------------
  def dead_count(actor_id)
    reset_battle_count if @dead_count == nil
    @dead_count[actor_id] = 0 if @dead_count[actor_id] == nil
    return @dead_count[actor_id]
  end
  #--------------------------------------------------------------------------
  #     actor_id : Actor ID
  #--------------------------------------------------------------------------
  def add_dead_count(actor_id)
    reset_battle_count if @dead_count == nil
    @dead_count[actor_id] = 0 if @dead_count[actor_id] == nil
    @dead_count[actor_id] += 1
    $game_variables[KGC::BattleCount::TOTAL_DEAD_COUNT] = @dead_count[-1]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def total_dead_count
    n = 0
    for i in 1...$data_actors.size
      n += dead_count(i)
    end
    return n
  end
end


#==============================================================================
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias post_start_KGC_BattleCount post_start
  def post_start
    $game_variables[KGC::BattleCount::BATTLE_COUNT] += 1
    post_start_KGC_BattleCount
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def battle_count
    return $game_variables[KGC::BattleCount::BATTLE_COUNT]
  end
  #--------------------------------------------------------------------------
  #     result：戰鬥結果（0=勝利、1=逃跑、2=敗北）
  #--------------------------------------------------------------------------
  alias battle_end_KGC_BattleCount battle_end
  def battle_end(result)
      case result
      when 0 # 詳見頁首繁中維護說明
        $game_variables[KGC::BattleCount::VICTORY_COUNT] += 1
      when 1 # 詳見頁首繁中維護說明
        $game_variables[KGC::BattleCount::ESCAPE_COUNT]  += 1
      when 2 # 詳見頁首繁中維護說明
        $game_variables[KGC::BattleCount::LOSE_COUNT]    += 1
      end
      $game_troop.dead_members.each { |enemy|
        $game_system.add_defeat_count(enemy.enemy.id)
      }
    battle_end_KGC_BattleCount(result)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias execute_action_KGC_BattleCount execute_action
  def execute_action
    last_exist_actors = $game_party.existing_members

    execute_action_KGC_BattleCount

    dead_actors = last_exist_actors - $game_party.existing_members
    dead_actors.each { |actor|
      $game_system.add_dead_count(actor.id)
    }
  end
end

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_
# http://f44.aaa.livedoor.jp/~ytomy/tkool/rpgtech/php/tech.php?tool=VX&cat=tech_vx/base_function&tech=battle_count
#_/=============================================================================
#_/  Version2 brought to you by Mr. Anonymous.
# http://mraprojects.wordpress.com
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_