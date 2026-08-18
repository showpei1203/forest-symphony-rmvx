#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YERD_TargetEffects
# 【用途】Yanfly 目標效果／選取底層，擴充技能目標規則與戰鬥選取流程。
# 【主要機制】目前位於 Targeting 長鏈的前段，後面還有 DynamicThreat、Provoke、TargetGroup、Exact Target、MarkedCommand 與 TargetUI；不可單獨搬動。
# 【主要影響】Game_BattleAction、RPG::BaseItem、RPG::UsableItem、YE、REGEXP、SKILL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：EVERYBODY、PHOENIX、TARGETALLFOE、TARGETRANDOMFOE、RANDOMFOE、MULTI_FOE、ALLBUTUSER、TARGETALLALLY。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：CustomTargetSelect。
# 【呼叫方式／範例】技能 Note：<everybody>、<randomfoe 3>、<multifoe 5>、<allbutuser>；進階自訂目標使用 <pick custom x> 並編輯 def pickcustom 對應 ID。
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
#===============================================================================
#
# Yanfly Engine－自訂目標選取（Custom Target Select）
# 最後更新：2009.04.18
# 難度：一般／進階（Lunatic）
#
# 【功能說明】
# 本腳本首先修正「隨機敵人」目標選取可能抽到已死亡敵人的問題，避免隨機多段攻擊
# 因抽到無效目標而浪費攻擊次數。除此之外，可在技能 Note 中加入標籤，擴充多段、
# 多個隨機敵人、隨機我方、敵我雙方等目標規則。進階模式還能透過 <pick custom x>
# 自訂目標條件，例如只攻擊 HP 高於特定比例的目標。物品同樣會受到本腳本影響。
#
# 【更新紀錄】
# 2009.04.18：改善 REGEXP 快取。
# 2009.04.12：改善 Note 標籤。
# 2009.03.29：建立腳本。
#
# 【一般模式：技能 Note】一次只會啟用一種，優先順序由上而下。
#   <everybody>          ：所有存活敵人＋所有存活我方。
#   <phoenix>            ：所有存活敵人＋所有死亡我方。
#   <targetallfoe>       ：先指定一名敵人，再攻擊其餘所有敵人。
#   <targetrandomfoe x>  ：先指定一名敵人，再選 x 個隨機敵人。
#   <randomfoe x>        ：隨機選 x 名敵人。
#   <multifoe x>         ：指定一名敵人，對其命中 x 次。
#   <allbutuser>         ：所有我方，但排除使用者本人。
#   <targetallally>      ：先指定一名我方，再包含其餘所有我方。
#   <targetrandomally x> ：先指定一名我方，再選 x 個隨機我方。
#   <randomally x>       ：隨機選 x 名我方。
#
# 【進階模式】
# 使用 <pick custom x> 指定自訂目標規則 ID，並在下方 def pickcustom 中編輯對應 when x。
#
# 【相容性】
# 覆寫 Game_BattleAction#make_obj_targets，以及 RPG::UsableItem 多個目標判定方法。
# 與 KGC_TargetExtension 不相容。
# 原作者：Yanfly。原腳本名稱、日期與識別字保留供授權／歷史追溯。
#
#===============================================================================

$imported = {} if $imported == nil
$imported["CustomTargetSelect"] = true
class Game_BattleAction
  
  #-----------------------------------------------------------------------------
  # 只有使用 <pick custom x> 時才需要修改本區；一般模式可保持原樣。
  #-----------------------------------------------------------------------------
  def pickcustom(obj, pickcustom)
    selected = []
    case pickcustom
    #---------------------------------------------------------------------------
    # //////////////////////////////////////////////////////////////////////////
    # 從這裡開始編輯自己的自訂目標規則。
    #---------------------------------------------------------------------------
    when 1 # Hits the target 10 times.
      for i in 0...10
        selected.push(opponents_unit.smooth_target(@target_index))
      end
      
    when 2 # Selects only targets with HP above 40
      for member in opponents_unit.existing_members
        selected.push(member) if member.hp > 40
      end
      
    when 3
      for member in friends_unit.existing_members
        selected.push(member) if member.id >2
      end
    when 4 #全體攻擊我方用(排除友好怪)
      for member in opponents_unit.existing_members
        selected.push(member) if !member.albert_summon?####
      end
      #selected.push(opponents_unit.existing_members)
      #selected.delete(member) if member.agi = 11
    when 5 #全體選我方用(加入友好怪)
      for member in opponents_unit.existing_members
        selected.push(member) if member.albert_summon?####
      end 
      for member in friends_unit.existing_members
        #selected.push(member) if member.gold == 9
        selected.push(member)
      end
    when 6#全體敵人用(加入友好怪)
      #temp = [6,12]
      for member in friends_unit.existing_members
        #selected.push(member) if member.gold == 9
        selected.push(member) if member.albert_summon?
      end
      for member in opponents_unit.existing_members
        selected.push(member)
      end
      
    when 10#全體治癒敵人用(排除友好怪)
      #temp = [6,12]
      for member in friends_unit.existing_members
        #selected.push(member) if member.gold == 9
        selected.push(member) if !member.albert_summon?
      end
      
    when 9 #全體攻擊我方用(排除友好怪+特定狀態ex:流血)
      for member in opponents_unit.existing_members
        #selected.push(member) if member.state?(3)
        selected.delete(member) if member.albert_summon?
        #selected.push(member) if member.eva != 6####
      end
    when 8
      for member in opponents_unit.existing_members
        selected.push(member) if member.albert_summon?
      end
     #單體攻擊可以打到召喚物,用if
       #$game_variables[200] = 0
       ######################################################################
    when 7#單體攻擊+友好怪
         if $game_switches[50] == false#無開場招喚物
           selected.push(opponents_unit.smooth_target(@target_index))
         end
         if $game_switches[50] == true#有開場招喚物
          $game_variables[200] = rand(2)+1
          if $game_variables[200] == 1
            for member in friends_unit.dead_members
              selected.push(opponents_unit.smooth_target(@target_index)) if member.albert_summon?
            end
            for member in friends_unit.existing_members
             selected.push(member) if member.albert_summon?#member.eva == 6
            end
           else
            selected.push(opponents_unit.smooth_target(@target_index))
           end
          end
       #####################################################################         
    when 11#不可使用
      index = @target_index
      # ★ 誤選択防止１・エラー回避
      unless index < opponents_unit.members.size
        index = opponents_unit.members.size - 1
      end
      target_hp = opponents_unit.members[index].hp
      # ★ 誤選択防止２・自分またはＨＰ０の相手を攻撃しない
      while index == battler.index or target_hp == 0
        # ターゲットを再定義
        index = rand(opponents_unit.members.size)
        # 再定義されたターゲットのＨＰを求める
        target_hp = opponents_unit.members[index].hp
      end
      selected.push(opponents_unit.smooth_target(index))
      ######################################################################
    when 12#範圍試做
      selected.push(opponents_unit.smooth_target(@target_index))
      
    #####################################################################         
    when 13#單體攻擊跳過召喚物(無效)
      index = @target_index
      # ★ 誤選択防止１・エラー回避
      unless index < opponents_unit.members.size
        index = opponents_unit.members.size - 1
      end
      target_eva = opponents_unit.members[index].eva
      # ★ 誤選択防止２・自分またはＨＰ０の相手を攻撃しない
      while index == battler.index or target_eva == 6
        # ターゲットを再定義
        index = rand(opponents_unit.members.size)
        # 再定義されたターゲットのＨＰを求める
        target_eva = opponents_unit.members[index].eva
      end
      selected.push(opponents_unit.smooth_target(index))
      ######################################################################
    when 14 # Hits the target 10 times.
      for i in 0...5
        selected.push(opponents_unit.random_target)
      end
      
      when 15 #選寶可夢
      for member in friends_unit.existing_members
        selected.push(member) if member.id == 7 or member.id > 7####
      end
      
      when 16  # 我方過濾用(選寶可夢)
        #valid_members = friends_unit.members.select { |member| member.id < 7 }
        #valid_members_count = valid_members.size
        #selected.push(friends_unit.smooth_target(@target_index + valid_members_count))
        #target_index = $game_temp.target_index
        #selected.push(friends_unit.smooth_target(target_index))
        for member in friends_unit.existing_members
         selected.push(member) if member.id == $game_temp.target_index
        end
      
      when 17  # 我方過濾用(選隊友)
        #valid_members = friends_unit.existing_members.select { |member| member.id >= 7 }
        #valid_members_count = valid_members.size
        selected.push(friends_unit.smooth_target(@target_index))
        
    selected = opponents_unit.existing_members if selected.empty?
    
    
    
    #---------------------------------------------------------------------------
    # 後方為共用核心處理，除非理解整條 Targeting 鏈，否則不要修改。
    # //////////////////////////////////////////////////////////////////////////
    #---------------------------------------------------------------------------
    end
    return selected
    #$game_variables[210]=Array.new(8,0)
    #$game_variables[210]=selected
  end
  
end

#===============================================================================
# 後方為核心快取與目標判定；沒有明確需求時不要修改。
#===============================================================================

module YE
  module REGEXP
    module SKILL
      
      # 敵我雙方全體。
      EVERYBODY = /<(?:EVERYBODY|every body)>/i
      PHOENIX = /<(?:PHOENIX|fenix)>/i
      
      # 敵方目標規則。
      TARGETALLFOE = /<(?:TARGETALLFOE|target all foe)>/i
      TARGETRANDOMFOE = /<(?:TARGETRANDOMFOE|target random foe)[ ]*(\d+)>/i
      RANDOMFOE = /<(?:RANDOMFOE|random foe)[ ]*(\d+)>/i
      MULTI_FOE = /<(?:MULTI_FOE|multi foe|multifoe)[ ]*(\d+)>/i
      
      # 我方目標規則。
      ALLBUTUSER = /<(?:ALLBUTUSER|all but user)>/i
      TARGETALLALLY = /<(?:TARGETALLALLY|target all ally)>/i
      TARGETRANDOMALLY = /<(?:TARGETRANDOMALLY|target random ally)[ ]*(\d+)>/i
      RANDOMALLY = /<(?:RANDOMALLY|random ally)[ ]*(\d+)>/i
      MULTI_ALLY = /<(?:MULTI_ALLY|multially|multi ally)[ ]*(\d+)>/i
      
      # 自訂目標規則。
      PICKCUSTOM = /<(?:PICK_CUSTOM|pick custom)[ ]*(\d+)>/i
      
    end
  end
end

#===============================================================================
# RPG::BaseItem
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # Yanfly 自訂目標選取快取。
  #--------------------------------------------------------------------------
  def yanfly_cache_cts 
    @everybody = false; @phoenix = false; @targetallfoe = false
    @targetrandomfoe = 0; @randomfoe = 0; @multifoe = 0; @allbutuser = false
    @targetallally = false; @targetrandomally = 0; @randomally = 0
    @multially = 0; @pickcustom = 0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::SKILL::EVERYBODY
        @everybody = true
      when YE::REGEXP::SKILL::PHOENIX
        @phoenix = true
      when YE::REGEXP::SKILL::TARGETALLFOE
        @targetallfoe = true
      when YE::REGEXP::SKILL::TARGETRANDOMFOE
        @targetrandomfoe = $1.to_i
      when YE::REGEXP::SKILL::RANDOMFOE
        @randomfoe = $1.to_i
      when YE::REGEXP::SKILL::MULTI_FOE
        @multifoe = $1.to_i
      when YE::REGEXP::SKILL::ALLBUTUSER
        @allbutuser = true
      when YE::REGEXP::SKILL::TARGETALLALLY
        @targetallally = true
      when YE::REGEXP::SKILL::TARGETRANDOMALLY
        @targetrandomally = $1.to_i
      when YE::REGEXP::SKILL::RANDOMALLY
        @randomally = $1.to_i
      when YE::REGEXP::SKILL::MULTI_ALLY
        @multially = $1.to_i
      when YE::REGEXP::SKILL::PICKCUSTOM
        @pickcustom = $1.to_i
        
      end
    }
  end # end yanfly_cache_cts
  
  #--------------------------------------------------------------------------
  # 是否以敵我全體為目標？
  #--------------------------------------------------------------------------
  def everybody?
    yanfly_cache_cts if @everybody == nil
    return @everybody
  end
  
  #--------------------------------------------------------------------------
  # 是否為「存活敵人＋死亡我方」目標？
  #--------------------------------------------------------------------------
  def phoenix?
    yanfly_cache_cts if @phoenix == nil
    return @phoenix
  end
  
  #--------------------------------------------------------------------------
  # 是否指定一名敵人後包含所有敵人？
  #--------------------------------------------------------------------------
  def targetallfoe?
    yanfly_cache_cts if @targetallfoe == nil
    return @targetallfoe
  end
  
  #--------------------------------------------------------------------------
  # 是否呼叫隨機敵人目標？
  #--------------------------------------------------------------------------
  def targetrandomfoe
    yanfly_cache_cts if @targetrandomfoe == nil
    return @targetrandomfoe
  end
  
  #--------------------------------------------------------------------------
  # 是否為隨機敵人？
  #--------------------------------------------------------------------------
  def randomfoe
    yanfly_cache_cts if @randomfoe == nil
    return @randomfoe
  end
  
  #--------------------------------------------------------------------------
  # 是否對單一敵人多段命中？
  #--------------------------------------------------------------------------
  def multifoe
    yanfly_cache_cts if @rmultifoe == nil
    return @multifoe
  end
  
  #--------------------------------------------------------------------------
  # 是否為所有我方但排除使用者？
  #--------------------------------------------------------------------------
  def allbutuser?
    yanfly_cache_cts if @allbutuser == nil
    return @allbutuser
  end
  
  #--------------------------------------------------------------------------
  # 是否指定一名我方後包含所有我方？
  #--------------------------------------------------------------------------
  def targetallally?
    yanfly_cache_cts if @targetallally == nil
    return @targetallally
  end
  
  #--------------------------------------------------------------------------
  # 是否為隨機我方？
  #--------------------------------------------------------------------------
  def targetrandomally
    yanfly_cache_cts if @targetrandomally == nil
    return @targetrandomally
  end
  
  #--------------------------------------------------------------------------
  # 是否呼叫隨機我方目標？
  #--------------------------------------------------------------------------
  def randomally
    yanfly_cache_cts if @randomally == nil
    return @randomally
  end
  
  #--------------------------------------------------------------------------
  # 是否對單一我方多次套用？
  #--------------------------------------------------------------------------
  def multially
    yanfly_cache_cts if @multially == nil
    return @multially
  end
  
  #--------------------------------------------------------------------------
  # 是否使用自訂 pick custom 規則？
  #--------------------------------------------------------------------------
  def pickcustom
    yanfly_cache_cts if @pickcustom == nil
    return @pickcustom
  end
  
end

#==============================================================================
# RPG::UsableItem
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 此技能／物品是否需要手動選擇？
  #--------------------------------------------------------------------------
  def need_selection?
    return false if everybody?
    return false if phoenix?
    return false if allbutuser?
    return true if targetallfoe?
    return true if targetallally?
    return true if targetrandomfoe > 0
    return false if randomfoe > 0
    return true if multifoe > 0
    return true if targetrandomally > 0
    return false if randomally > 0
    return true if multially > 0
    return [1, 3, 7, 9].include?(@scope)
  end
  
  #--------------------------------------------------------------------------
  # 是否以敵方為目標？
  #--------------------------------------------------------------------------
  def for_opponent?
    return true if targetallfoe?
    return false if targetallally?
    return true if targetrandomfoe > 0
    return true if multifoe > 0
    return false if targetrandomally > 0
    return false if randomally > 0
    return false if multially > 0
    return [1, 2, 3, 4, 5, 6].include?(@scope)
  end
  
  #--------------------------------------------------------------------------
  # 是否以我方為目標？
  #--------------------------------------------------------------------------
  def for_friend?
    return false if targetallfoe?
    return true if targetallally?
    return false if targetrandomfoe > 0
    return false if multifoe > 0
    return true if targetrandomally > 0
    return true if randomally > 0
    return true if multially > 0
    return [7, 8, 9, 10, 11].include?(@scope)
  end
  
  #--------------------------------------------------------------------------
  # 是否只以使用者為目標？
  #--------------------------------------------------------------------------
  def for_user?
    return false if allbutuser?
    return [11].include?(@scope)
  end
  
end

#===============================================================================
# Game_BattleAction
#===============================================================================

class Game_BattleAction

  #--------------------------------------------------------------------------
  # 建立技能／物品實際目標陣列。
  #--------------------------------------------------------------------------
  def make_obj_targets(obj)
    targets = []
    
    #------------------------------------------------
    
    if obj.everybody?
      targets += opponents_unit.existing_members
      targets += friends_unit.existing_members
    
    elsif obj.phoenix?
      targets += opponents_unit.existing_members
      targets += friends_unit.dead_members
      
    #------------------------------------------------
      
    elsif obj.targetallfoe?
      targets.push(opponents_unit.smooth_target(@target_index))
      targetted = opponents_unit.smooth_target(@target_index)
      othertargets = opponents_unit.existing_members
      othertargets.delete(targetted)
      targets += othertargets
        
    elsif obj.targetrandomfoe > 0
      number_of_targets = obj.targetrandomfoe
      targets.push(opponents_unit.smooth_target(@target_index))
      number_of_targets.times do
        targets.push(opponents_unit.random_target)
      end
        
    elsif obj.randomfoe > 0
      number_of_targets = obj.randomfoe
      number_of_targets.times do
        targets.push(opponents_unit.random_target)
      end
      
    elsif obj.multifoe > 0
      number_of_targets = obj.multifoe
      hits = obj.multifoe
      for i in 0...hits
        targets.push(opponents_unit.smooth_target(@target_index))
      end
      
    #------------------------------------------------
      
    elsif obj.allbutuser?
      targets += friends_unit.existing_members
      targets.delete(battler)
      
    elsif obj.targetallally?
      targets.push(friends_unit.smooth_target(@target_index))
      targetted = friends_unit.smooth_target(@target_index)
      othertargets = friends_unit.existing_members
      othertargets.delete(targetted)
      targets += othertargets
      
    elsif obj.targetrandomally > 0
      number_of_targets = obj.targetrandomally
      targets.push(friends_unit.smooth_target(@target_index))
      number_of_targets.times do
        targets.push(friends_unit.random_target)
      end
      
    elsif obj.randomally > 0 
      number_of_targets = obj.randomally
      number_of_targets.times do
        targets.push(friends_unit.random_target)
      end
      
    elsif obj.multially > 0
      number_of_targets = obj.multially
      hits = obj.multially
      for i in 0...hits
        targets.push(friends_unit.smooth_target(@target_index))
      end
      
    #------------------------------------------------
      
    elsif obj.pickcustom > 0
      targets = pickcustom(obj, obj.pickcustom)
      
    #------------------------------------------------
    
    elsif obj.for_opponent?
      
      if obj.for_random?
        
        if obj.for_one?         # One random enemy
          number_of_targets = 1
        elsif obj.for_two?      # Two random enemies
          number_of_targets = 2
        else                    # Three random enemies
          number_of_targets = 3
        end
        number_of_targets.times do
          targets.push(opponents_unit.random_target)
        end
        
      elsif obj.dual?           # One enemy, dual
        targets.push(opponents_unit.smooth_target(@target_index))
        targets += targets
      elsif obj.for_one?        # One enemy
        targets.push(opponents_unit.smooth_target(@target_index))
      else                      # All enemies
        targets += opponents_unit.existing_members
      end
      
    elsif obj.for_user?         # User
      targets.push(battler)
      
    elsif obj.for_dead_friend?
      if obj.for_one?           # One ally (incapacitated)
        targets.push(friends_unit.smooth_dead_target(@target_index))
      else                      # All allies (incapacitated)
        targets += friends_unit.dead_members
      end
      
    elsif obj.for_friend?
      if obj.for_one?           # One ally
        targets.push(friends_unit.smooth_target(@target_index))
      else                      # All allies
        targets += friends_unit.existing_members
      end
    end
    
    return targets.compact
    
  end
  
end

#===============================================================================
#
# 檔案結束
#
#===============================================================================