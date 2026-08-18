#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Fridgecrisis's EXP Controller (EXPC) v1.2
# 【用途】改寫 Actor 升級 EXP 表、Enemy EXP 與 Troop 最終 EXP，可使用固定需求、線性成長或複合成長；亦可選擇把戰鬥 EXP 在隊伍成員間分配。
# 【目前設定】SPLIT_EXP=true；EXP_METHOD=1（Set）；SET_NEED=100；SET_LEVEL_TYPE=1（隊伍平均等級）。因此目前核心玩法依賴 Method 1，而後方 FC_PerActor_EXP_Fix_v2_0 會直接讀取 FC::EXPC_CUSTOM::EXP_METHOD 與 SET_LEVEL_TYPE。
# 【Method 1 Set】每級固定需要 SET_NEED EXP。Enemy Note 使用 <exp at level x> 表示資料庫 EXP 是以隊伍代表等級 x 為基準；實際取得量約為 enemy.exp × x / 代表等級。SET_LEVEL_TYPE：1=平均、2=最高、3=最低。
# 【Method 1 範例】SET_NEED=100、SET_LEVEL_TYPE=1，Slime 資料庫 EXP=25 並寫 <exp at level 2>：隊伍平均 Lv1 約得 50 EXP、Lv2 得 25、Lv5 得 10。
# 【Method 2 Steady】STEADY_NEED 為升 Lv2 所需 EXP，之後每級把 STEADY_ADD 加到上一級需求。
# 【Method 3 Compound】COMPOUND_NEED 為升 Lv2 所需；COMPOUND_ADD 為初始追加量；COMPOUND_GROWTH 讓追加量每級繼續成長。例如 10/2/2 會形成 10、12、16、22、30... 的需求序列。
# 【主要覆寫】Game_Actor#make_exp_list、Game_Enemy#exp、Game_Troop#exp_total。後方 FS_PerActor EXP Fix、Boss／Level Runtime 仍會在其上調整，因此本頁不是整個專案最後 EXP Authority。
# 【載入順序】必須先於 FC_PerActor_EXP_Fix_v2_0 與任何讀取 FC::EXPC_CUSTOM 的後續 FS 腳本；不要把它搬到那類修正之後。
# 【相關素材／呼叫】無固定素材，正常由戰鬥與等級系統自動使用；沒有事件 Script Call。Notetag <exp at level x> 是資料庫 API，不可翻譯。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
################################################################################
  #------------------------------------------------------------------------------#
  # Version 1.2
  #
  #
  # Version Details:
  #
  #
  # Overwrites:
  #
  ################################################################################
  #------------------------------------------------------------------------------#
  #
  # SPLIT_EXP = true/false #
  #------------------------#
  #
  # EXP_METHOD = x #
  #----------------#
  #
  # SET_NEED = x       #
  # SET_LEVEL_TYPE = x #
  # <exp at level x>   #
  #--------------------#
  # by LEVEL_TYPE is x. There are three options for LEVEL_TYPE: average, highest, 
  #
  #
  # <exp at level> tag (2), over the party's average level (1). You're basically 
  #
  # STEADY_NEED = x  #
  # STEADY_ADD  = x  #
  #------------------#
  #
  # COMPOUND_NEED   = x #
  # COMPOUND_ADD    = x #
  # COMPOUND_GROWTH = x #
  #---------------------#
  #
  #
  
  module FC
    module EXPC_CUSTOM
  
      SPLIT_EXP         = true # 是否將戰鬥最終 EXP 分配給隊伍成員？
      
      # 選擇 EXP 成長模式
      EXP_METHOD        = 1
    
      SET_NEED          = 100  # 每級需要多少 EXP？
      SET_LEVEL_TYPE    = 1    # 以哪種隊伍代表等級決定 EXP？
                               # 1=平均、2=最高、3=最低。
    
      STEADY_NEED       = 100   # 升到 Lv2 所需 EXP
      STEADY_ADD        = 0   # 每級固定增加多少需求
    
      COMPOUND_NEED     = 10   # 升到 Lv2 所需 EXP
      COMPOUND_ADD      = 0    # 初始追加值
      COMPOUND_GROWTH   = 2    # 每級讓 COMPOUND_ADD 再增加多少
    
    end
  end
  
  ################################################################################
  #------------------------------------------------------------------------------#
  
  $imported = {} if $imported == nil
  $imported["FC_EXPC"] = true
  
  ################################################################################
  #------------------------------------------------------------------------------#
  
  module FC
    module EXPC
    EXP_AT_LEVEL        = /<(?:EXP_AT_LEVEL|exp at level)[ ]*(\d+)>/i
    end
  end
  
  class RPG::Enemy
    def fc_note_interpreter_expc
      
      @exp_at_level=1
      
      self.note.split(/[\r\n]+/).each { |line|
        case line
        when FC::EXPC::EXP_AT_LEVEL
          @exp_at_level = $1.to_f
        end
      }
    end
  
  #----------------#
  #----------------#
    
    def exp_at_level
      fc_note_interpreter_expc if @exp_at_level == nil
      return @exp_at_level
    end
  
  end
  
  ################################################################################
  #------------------------------------------------------------------------------#
  
  class Game_Actor < Game_Battler
    
  #---------------------------#
  #---------------------------#  
    
    def make_exp_list
      @exp_list[1] = @exp_list[100] = 0
      
      exp_method      = FC::EXPC_CUSTOM::EXP_METHOD
      set_need        = FC::EXPC_CUSTOM::SET_NEED
      steady_need     = FC::EXPC_CUSTOM::STEADY_NEED
      steady_add      = FC::EXPC_CUSTOM::STEADY_ADD
      compound_need   = FC::EXPC_CUSTOM::COMPOUND_NEED
      compound_add    = FC::EXPC_CUSTOM::COMPOUND_ADD
      compound_growth = FC::EXPC_CUSTOM::COMPOUND_GROWTH
      
      case exp_method
      when 1 # 詳見頁首繁中維護說明
        for i in 2..99
          @exp_list[i] = @exp_list[i-1] + set_need
        end
        
      when 2 # 詳見頁首繁中維護說明
        @exp_list[2] = steady_need
        for i in 3..99
          steady_need += steady_add
          @exp_list[i] = @exp_list[i-1] + Integer(steady_need)
        end
        
      when 3 # 詳見頁首繁中維護說明
        @exp_list[2] = compound_need
        for i in 3..99
          compound_add += compound_growth
          compound_need += compound_add
          @exp_list[i] = @exp_list[i-1] + Integer(compound_need)
        end
        
      end
    end
  
  end
  
  ################################################################################
  #------------------------------------------------------------------------------#
  
  class Game_Enemy < Game_Battler
  
  #-----------------#
  # EXP (Overwrite) #
  #-----------------#  
    
    def exp
      result = enemy.exp
      if FC::EXPC_CUSTOM::EXP_METHOD == 1
  
        if FC::EXPC_CUSTOM::SET_LEVEL_TYPE == 1 
          level_var = 0
          for actor in $game_party.members do
            level_var += actor.level
          end
          level_var /= $game_party.members.size
          
        elsif FC::EXPC_CUSTOM::SET_LEVEL_TYPE == 2 
          level_var = 0
          for actor in $game_party.members do
            next if actor.level <= level_var
            level_var = actor.level
          end
          
        elsif FC::EXPC_CUSTOM::SET_LEVEL_TYPE == 3 
          level_var = 100
          for actor in $game_party.members do
            next if actor.level >= level_var
            level_var = actor.level
          end
        end
        
        exp_yield = enemy.exp_at_level / level_var
        
        result *= exp_yield
      end
      return result.to_i
    end
  
  end
  
  ################################################################################
  #------------------------------------------------------------------------------#
  
  class Game_Troop < Game_Unit
  
  #-----------------------#
  #-----------------------#  
    
    def exp_total
      exp = 0
      for enemy in dead_members
        exp += enemy.exp unless enemy.hidden
      end
      if FC::EXPC_CUSTOM::SPLIT_EXP
        return exp / $game_party.members.size
      else
        return exp
      end
    end
    
  end
  
  ################################################################################
  ################################################################################