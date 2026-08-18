#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：FriendlyMonsters_Core v1.1｜GoldFix Integrated
# 【來源】Shanghai Simple Script - Friendly Monsters，最後更新 2010-06-17。Phase 21 將專案既有 `FS_FriendlyMonsters_GoldFix` 回寫本 Core。
# 【用途】讓標記為 Friendly 的 Enemy 在戰鬥中站到玩家陣營邏輯側，攻擊其他 Enemy；當正常敵人全滅且 Friendly 仍存活時，玩家取得其友軍獎勵。
# 【Enemy Notetag】`<friendly>`；`<friendly exp: x>`；`<friendly gold: x>`；`<friendly i: x>` Item；`<friendly w: x>` Weapon；`<friendly a: x>` Armor。掉落 Notetag 可寫多筆。
# 【預設獎勵】若沒寫 friendly exp/gold，預設各為 Enemy 原 EXP／Gold 的 2 倍；只對戰鬥結束時仍存活的 Friendly 加算。
# 【目標切換】Friendly Enemy 的 friends_unit 改為 Game_Party、opponents_unit 改為 Game_Troop；Game_Troop#members / Game_Party#members 以 `$game_temp.friendly_monster` 暫時切換目標集合。
# 【全滅判定】Game_Troop#all_dead? 會把 Friendly 從需要擊倒的集合扣除，所以只剩存活 Friendly 時戰鬥可以結束。
# 【Phase 21 GoldFix】原第三方 gold_total 誤寫 `friendly_exp`。後方 FS_FriendlyMonsters_GoldFix 曾覆寫成 `friendly_gold`；現在直接回寫本 Core，最終金錢行為與 Phase 20 一致，獨立 Hotfix 退休進 Project History。
# 【Load Order】本頁仍是 Friendly subsystem Core；後方 BattleResultStats 可能再對總 EXP/Gold 套 Bonus。不要把兩者合併。
# 【素材】無固定 Graphics/Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#===============================================================================
# 以下為實際 Runtime 程式；Notetag 與使用方式請見頁首繁中完整說明。
#===============================================================================
 
$imported = {} if $imported == nil
$imported["FriendlyMonsters"] = true
 
#==============================================================================
#==============================================================================
 
class RPG::Enemy
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendly_monster
    return @friendly_monster if @friendly_monster != nil
    @friendly_monster = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:FRIENDLY|friendly monster)>/i
        @friendly_monster = true
      end
    }
    return @friendly_monster
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendly_exp
    return @friendly_exp if @friendly_exp != nil
    @friendly_exp = @exp * 2
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:FRIENDLY_EXP|friendly exp):[ ](\d+)>/i
        @friendly_exp = $1.to_i
      end
    }
    return @friendly_exp
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendly_gold
    return @friendly_gold if @friendly_gold != nil
    @friendly_gold = @gold * 2
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:FRIENDLY_GOLD|friendly gold):[ ](\d+)>/i
        @friendly_gold = $1.to_i
      end
    }
    return @friendly_gold
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendly_drops
    return @friendly_drops if @friendly_drops != nil
    @friendly_drops = []
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:FRIENDLY_ITEM|friendly item|friendly i):[ ]*(\d+)>/i
        @friendly_drops.push($data_items[$1.to_i])
      when /<(?:FRIENDLY_WEP|friendly wep|friendly w):[ ]*(\d+)>/i
        @friendly_drops.push($data_weapons[$1.to_i])
      when /<(?:FRIENDLY_ARM|friendly arm|friendly a):[ ]*(\d+)>/i
        @friendly_drops.push($data_armors[$1.to_i])
      end
    }
    return @friendly_drops.compact
  end
end
 
#==============================================================================
#==============================================================================
 
class Game_Temp
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :friendly_monster
end
 
#==============================================================================
#==============================================================================
 
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendly?
    return enemy.friendly_monster
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias make_action_sss_friendly_monsters make_action unless $@
  def make_action
    $game_temp.friendly_monster = true
    make_action_sss_friendly_monsters
    $game_temp.friendly_monster = false
  end
end
 
#==============================================================================
#==============================================================================
 
class Game_BattleAction
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias friends_unit_sss_friendly_monsters friends_unit unless $@
  def friends_unit
    if !battler.actor? and battler.friendly?
      return $game_party
    else
      return friends_unit_sss_friendly_monsters
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias opponents_unit_sss_friendly_monsters opponents_unit unless $@
  def opponents_unit
    if !battler.actor? and battler.friendly?
      return $game_troop
    else
      return opponents_unit_sss_friendly_monsters
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias make_attack_targets_sss_friendly_monsters make_attack_targets unless $@
  def make_attack_targets
    $game_temp.friendly_monster = true if !battler.actor?
    result = make_attack_targets_sss_friendly_monsters
    $game_temp.friendly_monster = false
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #  $game_temp.friendly_monster = true if !battler.actor?
  #  $game_temp.friendly_monster = false
end
 
#==============================================================================
#==============================================================================
 
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias members_troop_sss_friendly_monsters members unless $@
  def members
    result = members_troop_sss_friendly_monsters
    result -= $game_troop.friendlies if $game_temp.friendly_monster
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendlies
    result = []
    for member in members_troop_sss_friendly_monsters
      result.push(member) if member.friendly?
    end
    return result.compact
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def friendlies_alive?
    for member in friendlies
      return true unless member.dead?
    end
    return false
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def all_dead?
    n = existing_members
    n -= $game_troop.friendlies
    return n.empty?
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias exp_total_sss_friendly_monsters exp_total unless $@
  def exp_total
    n = exp_total_sss_friendly_monsters
    for member in $game_troop.friendlies
      next if member.dead?
      n += member.enemy.friendly_exp
    end
    return n
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias gold_total_sss_friendly_monsters gold_total unless $@
  def gold_total
    n = gold_total_sss_friendly_monsters
    for member in $game_troop.friendlies
      next if member.dead?
      n += member.enemy.friendly_gold
    end
    return n
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias make_drop_items_sss_friendly_monsters make_drop_items unless $@
  def make_drop_items
    n = make_drop_items_sss_friendly_monsters
    for member in $game_troop.friendlies
      next if member.dead?
      n += member.enemy.friendly_drops
    end
    return n
  end
end
 
#==============================================================================
#==============================================================================
 
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias members_party_sss_friendly_monsters members unless $@
  def members
    result = members_party_sss_friendly_monsters
    if $game_temp.friendly_monster and $game_troop.friendlies_alive?
      return $game_troop.friendlies
    end
    return result
  end
end
 
#===============================================================================
# 
# 
#==============================================================================