#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Make skill action
# 【用途】技能系統元件「Make skill action」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【Phase37D】原作 247～255 為 Tankentai Demo 範例 ID；Forest Symphony 已將同區段正式用於 Soul Art。
#         若技能 Note 含 <fs_soul_art:x>，本頁必須讓出 base_action／extension Authority，避免舊 Demo ID 攔截正式魂刻技。
# 【主要影響】Skill、N01、RPG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ACTIVATE_ACTION、ACTIVATE_ANIME。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
#Make Skills & an example
#   Script by CrimsonSeas
#===============================================================================
#You don't have to create your custom skills here. If by any chance you already
#made some custom skills and you're too lazy to paste them here, you can just
#add the keyword "Activation" somewhere in your finished skills.
#it's perfectly fine if this part is empty, I only included this as a template of
#some sort
#==============================================================================
module N01
#Make skill animation set. For best result, use these commands in the beginning
#of the Action Hash:
#   ["START_MAGIC_ANIM", "52", "Activation", ......]
#"Activation" is the most important, it will call the activation window.
#As for value after "START_MAGIC_ANIM", set is to be:
#     START_MAGIC_ANIM's Pass value (default is 52)
#===============================================================================
##This also demonstrates the disabling patch that I made. Since this animation 
#took quite some time to reach activation process, I decided to use the disabling
#patch to disable command input.
  ACTIVATE_ACTION = {
  
  "TEST_MIDDLE"   => ["Cmd_Disable", "START_MAGIC_ANIM", "52",  "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                    "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                    "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16", "Activation",
                    "Cmd_Enable", "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","Can Collapse","COORD_RESET"],
    
  "TEST_ACTIVATION"   => ["START_MAGIC_ANIM", "52", "Activation", "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                          "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                          "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                          "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","Can Collapse","COORD_RESET"],
    
  
  #This is for activation action,this only calls the activation, which then links
  #to another skill. Notice that this has no Linking Anime Hash, but it will still
  #link to a skill specified in the Activation Property Config. This makes the
  #action hash reusable, which saves the time of typing many Activation for each
  #skill. Of course you can have more than one Activation Action.
  
  "ACTIVATION_ACT"   => ["START_MAGIC_ANIM", "52", "Activation"],
   
  #This BLANK is important for the varying hit number and the continue activation,
  #because with this the "BLANK" can be made to any kind of Action hash depending
  #on what you wrote down below. Scroll down to see what I mean.
  "BLANK"             => []
}



  ACTION.merge!(ACTIVATE_ACTION)
#Make anime hashes here
  ACTIVATE_ANIME = {
    
    
    
    }
  ANIME.merge!(ACTIVATE_ANIME)
end

#===============================================================================
#Assigning Skill Action Set to Skill ID
#===============================================================================
module RPG
  class Skill
    attr_accessor :damage_multiplier

    #--------------------------------------------------------------------------
    # ● Phase37D：正式 Soul Art Authority Guard
    #   原作下方 247～255 僅是 Tankentai Demo 範例。Forest Symphony 的正式
    #   SoulMark Runtime 會在技能 Note 寫入 <fs_soul_art:x>；遇到此標記時，
    #   不得套用舊 Demo 的 RANDOMTARGET／TEST_ACTIVATION／BLANK 等設定。
    #   只依正式 Note 判定，不依賴 FS_SOULMARK_RESONANCE 常數載入時機。
    #--------------------------------------------------------------------------
    def crmsn_fs_formal_soul_art?
      begin
        return false unless respond_to?(:note)
        return note.to_s =~ /<fs_soul_art\s*:\s*\d+\s*>/i ? true : false
      rescue
        return false
      end
    end

    alias crmsn_extension extension
    def extension
      return crmsn_extension if crmsn_fs_formal_soul_art?
#-------------------------------------------------------------------------------
#Config Skill Extension
#-------------------------------------------------------------------------------
#Configuring Skill Extension
#This is an example I made using Tankentai+ATB Demo. I made a copy of multi
#attack random (skill ID 89) in skill ID 247. If you want to see this example,
#please use Tankentai+ATB Demo and make a copy of skill ID 89 in skill ID 247.
#-------------------------------------------------------------------------------
#Note that if you decide to create other skill in skill ID 247, you should delete
#or change this example.
      case @id
      when 247, 248, 249, 251, 250, 253, 255
        return ["RANDOMTARGET"]
      end
      crmsn_extension
    end    

    alias crmsn_base_action base_action
    def base_action
      return crmsn_base_action if crmsn_fs_formal_soul_art?
#-------------------------------------------------------------------------------
#Config Skill Action Set
#-------------------------------------------------------------------------------
#Configuring action set of a skill so it can have activation.
#Note that if you decide to create other skill in skill ID 247, you should delete
#or change this example.
      case @id
      when 247, 248, 249, 251
        return "TEST_ACTIVATION"
      when 250
        return "TEST_MIDDLE"
      
      #This calls the activation. After this, the skill will link to the next skill
      #according to what is configured at the Activation Property Config. The next
      #skill's effect depends on how well you do in the activation process.
      when 252, 254
        return "ACTIVATION_ACT"
      
      #This is base_action for the varying hit number skills.
      when 253
        temp = [] #First define a starting action set (It doesn't have to be [],
                  #it can be ["PREV_STEP_ATTACK"] for example.
        for i in 1..hit_number
          #This part defines what action set will be repeated for each hit number
          temp.push ("PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16")
        end
        #This part defines what action set to be played after the repetition is done
        temp.push ("Can Collapse", "COORD_RESET")
        N01::ACTION["BLANK"] = temp
        return "BLANK" #See how the blank is useful?
        
      #This is base_action for the continue skills.
      #I made it slightly different from what was requested, cause I think this
      #is more flexible.
      when 255
        temp = [] #This part is the same as above
        if success
        #This part defines action set to be carried out if successful
          temp.push ("PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16",
                      "PREV_STEP_ATTACK","WPN_SWING_VL","OBJ_ANIM_WEAPON","WAIT(FIXED)","16")
        else
        #This part defines action set to be carried out if failed. With this, you can
        #add a failing action set (Like in FFX Tidus has a different animation when
        #Blitz Ace failed.)
          temp.push ()
        end
        #This part is the same as above.
        temp.push ("Can Collapse", "COORD_RESET")
        N01::ACTION["BLANK"] = temp
        return "BLANK" #It's BLANK time again!!
      end
      crmsn_base_action
    end
  end
end
      
    
