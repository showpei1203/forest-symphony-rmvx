#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Activation Property Config
# 【用途】保留的 Runtime 元件「Activation Property Config」。
# 【主要機制】主要定義／擴充 Skill、RPG；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Skill、RPG
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】CrimsonSeas。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
#Config skills activation property v1.2
#   Script by CrimsonSeas
#===============================================================================
#Now that you have some custom skills already, you should configure your skills'
#activation property.

module RPG
  class Skill
#-------------------------------------------------------------------------------
#Set specific time length for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
    def activation_time
      case @id
      when 251
        return 120
      end
      return CRMSN::TIME
    end
#-------------------------------------------------------------------------------
#Set specific power up limit for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
    def max_power_up
      case @id
      when 251
        return 100
      end
      return CRMSN::MAX_POWER_UP
    end
    
    def min_power_up
      case @id
      when 251
        return 50
      end
      return CRMSN::MIN_POWER_UP
    end
#-------------------------------------------------------------------------------
#Set specific activation type for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
    
    def activation_type
      case @id
      when 249, 252
        return "SEQUENCE"
      when 248
        return "MASH"
      end
      return CRMSN::DEFAULT_TYPE
    end

    
#-------------------------------------------------------------------------------
#Set specific hit range for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
    def hit_range
      case @id
      when 251
        return 32
      end
      return CRMSN::HIT_RANGE
    end
    
#-------------------------------------------------------------------------------
#Set specific sequence for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
#You can enter more than one sequence in an array. When sequence is called, one
#sequence will be picked randomly.        
    def sequence
      case @id
      when 249
        temp = [["UP", "DOWN", "LEFT", "RIGHT", "X", "Z"],
                ["Z","X","LEFT","RIGHT", "Q", "W"]]
      end
      return temp if temp != nil   
      return CRMSN::DEFAULT_SEQUENCE
    end
    
#-------------------------------------------------------------------------------
#Set specific effect for certain skills.
#Default is the one set at config.
#-------------------------------------------------------------------------------
    def activation_effect
      case @id
      when 252
        return "ADDNUM" #Skill have varying hit number based on activation
      when 254
        return "CONTINUE" #Skill will continue upon successful activation
      end
      return CRMSN::DEFAULT_EFFECT
    end    

#--------------------------------------------------------------------------------
#Set ID which the skill will link to.
#-------------------------------------------------------------------------------
#This is very important for the ADDNUM and CONTINUE effects. Note that when you
#already specify an ID to be linked here, you won't need to add the Linking
#Anime Hash (the one like this: "LINK_SKILL_91"     => ["der", 100,  true,   91])
#because this will automatically link you to the specified skill ID.
#But this works 100%, so if you want skill to be linked not 100% of the time, you
#still have to use the Linking Anime Hash.

    def link_to
      case @id
      when 252
        return 253
      when 254
        return 255
      #
     # when 255
     #   return 255#要去設定成功跟失敗
      end
      return nil
    end
  
#===============================================================================
#END CONFIGURATION!! DON'T TOUCH ANYTHING BEYOND THIS POINT!!
#===============================================================================
  end
end 
