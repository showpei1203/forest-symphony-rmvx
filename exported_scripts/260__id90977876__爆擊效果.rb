#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：爆擊效果
# 【用途】保留的 Runtime 元件「爆擊效果」。
# 【主要機制】主要定義／擴充 Sprite_Battler、N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_Battler、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：CRIT_SHAKE、CRIT_SHAKE_POWER、CRIT_SHAKE_SPEED、CRIT_SHAKE_TIME、CRIT_FLASH、CRIT_FLASH_COLOR、CRIT_FLASH_TIME、CRIT_SOUND。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Audio/SE/。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Mr. Bubble。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# + Critical Effects Add-on for RPG Tankentai Sideview Battle System
#   v1.1
#------------------------------------------------------------------------------
#  Script by Mr. Bubble
#------------------------------------------------------------------------------
# ++ How to Install
# * Place below the Sideview and ATB scripts (if you are using the ATB.)
#==============================================================================
# Produce screen effects when a battler deals a critical hit.
#
# Using "Crit Effects OFF" in an action sequence will temporarily disable
# all critical effects
#==============================================================================

module N01
 #-------------------------------------------------------------------------- 
 # * Critical Hit Effect Settings
 #-------------------------------------------------------------------------- 
  # true: Allow screen shaking when critical hit is dealt.
  # false: Disable critical screen shake effect.
  # Screen will not shake for critical healing effects.
  CRIT_SHAKE = true
  # Critical screen shake power. (1~10)
  CRIT_SHAKE_POWER = 5
  # Critical screen shake speed. (1~10)
  CRIT_SHAKE_SPEED = 5
  # Critical screen shake total duration in 1/60 sec. increments.
  CRIT_SHAKE_TIME = 20

  # true: Allow screen flash when critical hit is dealt.
  # false: Disable screen flash for critical hits.
  # Screen will not flash for critical healing effects.
  CRIT_FLASH = true
  # Critical screen flash color. 
  # Color.new(red, green, blue, strength)
  # Color values and strength are between 0~255.
  CRIT_FLASH_COLOR = Color.new(255, 0, 0, 64)
  # Critical screen flash total duration in 1/60 sec. increments.
  CRIT_FLASH_TIME = 20
  
  # true: Allow sound effect when critical hit is dealt.
  # false: Disable sound effect for critical hits.
  # Sound effect will not play for critical healing effects.
  CRIT_SOUND = true
  # Critical sound effect file name in Audio/SE folder.
  CRIT_SOUND_FILE = "Damage2"
  # Critical sound effect volume (0~100)
  CRIT_SOUND_VOL = 80
  # Critical sound effect pitch (50~150)
  CRIT_SOUND_PITCH = 100
 #-------------------------------------------------------------------------- 
 # * END OF CUSTOMIZATION
 #--------------------------------------------------------------------------
end
#==========================================================================
#-------------------------------------------------------------------------- 
# Do not edit anything below this line unless you know what you're doing
#--------------------------------------------------------------------------
#==========================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ++ Damage Action
  #--------------------------------------------------------------------------
  alias crit_fx_damage_action damage_action
  def damage_action(action)
    crit_fx_damage_action(action)
    damage = @battler.hp_damage
    if @battler.critical && damage > 0
      if N01::CRIT_SHAKE
        # Critical hit screen shake
        power = N01::CRIT_SHAKE_POWER
        speed = N01::CRIT_SHAKE_SPEED
        duration = N01::CRIT_SHAKE_TIME
        $game_troop.screen.start_shake(power, speed, duration)
      end
      if N01::CRIT_FLASH
        # Critical screen flash
        color = N01::CRIT_FLASH_COLOR
        time = N01::CRIT_FLASH_TIME
        $game_troop.screen.start_flash(color, time)
      end
      if N01::CRIT_SOUND
        # Critical sound effect
        name = N01::CRIT_SOUND_FILE
        vol = N01::CRIT_SOUND_VOL
        pitch = N01::CRIT_SOUND_PITCH
        Audio.se_play("Audio/SE/" + name, vol, pitch)
      end
    end
  end
end