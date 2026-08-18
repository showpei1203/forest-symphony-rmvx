#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：BattleScape｜Base + Variable + Troop Authority
# 【用途】戰鬥系統元件「BattleScape｜Base + Variable + Troop Authority」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Game_Map、Spriteset_Battle、ModernAlgebra
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAP_BATTLE_SCAPES、AREA_BATTLE_SCAPES、BATTLE_SCAPES_VARIABLE、VARIABLE_BATTLE_SCAPES、TROOP_BATTLE_SCAPES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意。
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
#==============================================================================
#==============================================================================
# PHASE 8 AUTHORITY: BattleScape｜Base + Variable + Troop Authority
# 戰鬥背景 Base→Variable→Troop 三層，同一 Game_Map#battle_scapes alias chain。
# Original load order: 266:戰鬥背景 -> 267:Variable Battle Scapes -> 268:Troop Battle Scapes
#==============================================================================
# PHASE8 ORIGINAL PAGE: 266 | 戰鬥背景
#==============================================================================
#==============================================================================
#    华丽战斗背景
#    原作BY: modern algbera
#    提供BY:企鹅达达
#    翻译BY:仲秋启明
#==============================================================================
#==============================================================================
# ● 设定
#==============================================================================
module ModernAlgebra
#==============================================================================
# ● 设定
#  map_id => [scape_1_id, scape_2_id, ..., scape_n_id]
#   when scape_id
#     parallax_name = ""
#     z = 0  决定显示位置
#     scroll_x = 0
#     scroll_y = 0
#     zoom_x = 100
#     zoom_y = 100
#     opacity = 255
#     blend_type = 0
#     color = [r, g, b, a] #(default: [0, 0, 0, 0])
#     tone = [r, g, b]     #(default: [0, 0, 0])
#==============================================================================
  MAP_BATTLE_SCAPES = {
    1 => [1,3],
    2 => [1],
    6 => [1],
    12 => [14,3],#坎普
    14 => [1],
    23 => [1],
    33 => [15,3],
    38 => [15,3],
    39 => [15,3]
  }
  MAP_BATTLE_SCAPES.default = [1,3]
  AREA_BATTLE_SCAPES = {
    1 => [1],
    2 => [1]
  }
  AREA_BATTLE_SCAPES.default = []
  BattleScape = Struct.new (:parallax_name, :z, :scroll_x, :scroll_y, 
                :zoom_x, :zoom_y, :blend_type, :color, :tone, :opacity)
                
  def self.battle_scape (scape_id)
    @battle_scapes = [] if @battle_scapes.nil?
    return @battle_scapes[scape_id] if @battle_scapes[scape_id] != nil
    parallax_name, blend_type, color, tone = "", 0, [0, 0, 0, 0], [0, 0, 0]
    z, scroll_x, scroll_y, zoom_x, zoom_y, opacity = 0, 0, 0, 100, 100, 255
    case scape_id
    when 1
      parallax_name = "new_back00"
      z = 51
    when 2
      parallax_name = "temp1"
      z = 52
    when 3
      parallax_name = "ffog"
      z = 49
      scroll_x = 13
      scroll_y = 0
      blend_type = 1
      opacity = 250
    when 4
      parallax_name = "Bridge"
      z = 50
      zoom_x = 85
      zoom_y = 130
    when 5
      parallax_name = "BlueSky"
      scroll_x = 2
    when 6#透明
      parallax_name = "new_back00"
      z = 60
    when 14
      parallax_name = "new_back01"
      z = 51
    when 15
      parallax_name = "new_back02"
      z = 51
    when 16
      parallax_name = "back02"
      z = 50
    when 31
      parallax_name = "back08"
      z = 50
    end
    
    @battle_scapes[scape_id] = BattleScape.new (parallax_name, z, scroll_x, 
      scroll_y, (zoom_x / 100.0), (zoom_y / 100.0), blend_type, color, tone, opacity)
    return @battle_scapes[scape_id]
  end
  
  def self.map_battle_scapes (map_id)
    scapes = []
    MAP_BATTLE_SCAPES[map_id].each { |scape_id| scapes.push (self.battle_scape (scape_id)) }
    return scapes
  end
  
  def self.area_battle_scapes (area_id)
    scapes = []
    AREA_BATTLE_SCAPES[area_id].each { |scape_id| scapes.push (self.battle_scape (scape_id)) }
    return scapes
  end
end

#######################################
class Game_Map
  def battle_scapes
    $data_areas.values.each { |area|
      if $game_player.in_area? (area) && !ModernAlgebra.area_battle_scapes (area.id).empty?
        return ModernAlgebra.area_battle_scapes (area.id) 
      end
    }
    return ModernAlgebra.map_battle_scapes (@map_id)
  end
end

######################################
class Spriteset_Battle
  alias modernalgbr_terraintypes_crtbttlebck_63b5 create_battleback
  def create_battleback (*args)
    
    if $BTEST 
      modernalgbr_terraintypes_crtbttlebck_63b5 (*args)
      #plane = Plane.new (@viewport1)
      #plane.z = 40
      #plane.bitmap = Cache.parallax ("back08")
      return
    end
    @battle_scapes = $game_map.battle_scapes
    @battle_planes = []
    @battle_planes_xy = []
    @battle_scapes.each { |battle_scape|
      plane = Plane.new (@viewport1)
      plane.z = battle_scape.z
      #plane.bitmap = $game_temp.background_bitmap
      plane.bitmap = Cache.parallax (battle_scape.parallax_name)
      #########
      plane.zoom_x, plane.zoom_y = battle_scape.zoom_x, battle_scape.zoom_y
      plane.blend_type = battle_scape.blend_type
      plane.color = Color.new (*battle_scape.color)
      plane.tone = Tone.new (*battle_scape.tone)
      plane.opacity = battle_scape.opacity
      @battle_planes.push (plane)
      @battle_planes_xy.push ([0,0])
    }  
    
    if @battle_planes.empty?
      modernalgbr_terraintypes_crtbttlebck_63b5 (*args)
    else
      Graphics.frame_reset
    end
  end
  
  
  alias modrnalgbra_terratas_dspsebkbmp_74bt dispose_battleback_bitmap
  def dispose_battleback_bitmap (*args)
    modrnalgbra_terratas_dspsebkbmp_74bt (*args) unless @battleback_sprite.nil?
#    plane.bitmap.dispose if $BTEST###
    if $BTEST###
    @battleback_sprite.dispose### 
    else###
    @battle_planes.each { |plane| plane.bitmap.dispose unless plane.bitmap.disposed? }
    end###
  end
  
  
  alias modrenalbr_dspsbb_terrintypes_09b6 dispose_battleback
  def dispose_battleback (*args)
    modrenalbr_dspsbb_terrintypes_09b6 (*args) unless @battleback_sprite.nil?
    if $BTEST###
    @battleback_sprite.dispose### 
    else###
    @battle_planes.each { |plane| plane.dispose }
    end###
  end
  
  
  alias modalg_bbckupd_trrantypes_52n5 update_battleback
  def update_battleback (*args)
    if @battleback_sprite.nil?
      @battle_planes.each_index { |i|
        x_y = @battle_planes_xy[i]
        plane = @battle_planes[i]
        scape = @battle_scapes[i]
        x_y[0] += (scape.scroll_x * 2)
        x_y[1] += (scape.scroll_y * 2)
        plane.ox, plane.oy = (x_y[0] / 16), (x_y[1] / 16)
      }
    else
      modalg_bbckupd_trrantypes_52n5 (*args)
    end
  end
end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 267 | Variable Battle Scapes
#==============================================================================
#==============================================================================
#    Variable Battle Scapes
#      [Addon for Battle Scapes 1.0, by modern algebra]
#    Version: 1.0
#    Author: modern algebra
#    Date: May 16, 2010
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    This is an addon for Battle Scapes 1.0, that allows you to set battle
#   scape by variable, rather than just Area or Map ID. It will take priority
#   over those, so if the variable is set to anything greater than 0, it will
#   be the battle scape
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    Place this script below Battle Scapes in the Script Editor, but still
#   above Main. To set it up, see the EDITABLE REGION at line 27
#==============================================================================

#==============================================================================
# ** Game Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constant - BS_TROOP_SCAPES
#    aliased method - battle_scapes
#==============================================================================

class Game_Map
  # The ID of the variable you want to use to control which battle scape is 
  #  shown. When the value of the variable corresponds to one of the scapes in
  #  VARIABLE_BATTLE_SCAPES, it will take priority and be shown.
  BATTLE_SCAPES_VARIABLE = 1000
  VARIABLE_BATTLE_SCAPES = {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #  EDITABLE REGION
    #````````````````````````````````````````````````````````````````````````
    #  Set up what scapes you want for the troops as follows:
    # 
    #    variable_value => [scape_1_id, scape_2_id, ..., scape_n_id]
    #      troop_id   : ID of the troop you want scapes to be battleback for
    #      scape_n_id : the ID of each scape you want to use, as set up in the
    #                  original script
    #
    #  You only need to set up the ones that you want to get to be variable.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    1 => [1],
    2 => [],
    3 => []
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #  END EDITABLE REGION
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  VARIABLE_BATTLE_SCAPES.default = [1]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Battle Scapes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modal_varadon_bscp_8ik2 battle_scapes
  def battle_scapes (*args)
    scapes = []
    VARIABLE_BATTLE_SCAPES[$game_variables[BATTLE_SCAPES_VARIABLE]].each { |scape_id| scapes.push (ModernAlgebra.battle_scape (scape_id)) }
    return scapes unless scapes.empty? 
    # If no special BG for that variable value set, default to showing by area or map
    return modal_varadon_bscp_8ik2 (*args)
  end
end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 268 | Troop Battle Scapes
#==============================================================================
#==============================================================================
#    Troop Battle Scapes
#      [Addon for Battle Scapes 1.0, by modern algebra]
#    Version: 1.1
#    Author: modern algebra
#    Date: January 7, 2010
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    This is an addon for Battle Scapes 1.0, that allows you to set battle
#   scape by troop ID, rather than just Area or Map ID. It will take priority
#   over those, so if a troop battle scape exists, that is what will be used.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    Place this script below Battle Scapes in the Script Editor, but still
#   above Main. To set it up, see the EDITABLE REGION at line 27
#==============================================================================

#==============================================================================
# ** Game Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constant - BS_TROOP_SCAPES
#    aliased method - battle_scapes
#==============================================================================

class Game_Map
  TROOP_BATTLE_SCAPES = {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #  EDITABLE REGION
    #````````````````````````````````````````````````````````````````````````
    #  Set up what scapes you want for the troops as follows:
    # 
    #    troop_id => [scape_1_id, scape_2_id, ..., scape_n_id]
    #      troop_id   : ID of the troop you want scapes to be battleback for
    #      scape_n_id : the ID of each scape you want to use, as set up in the
    #                  original script
    #
    #  You only need to set up the ones for which you want the troop ID to take
    # precedence over area or map ID. You can exclude any troops for which you
    # want to default to the regular method. Note that troop ID will take 
    # priority over area or map ID, so if you set it here, that troop will 
    # always have this battle scape, unless there is another addon or patch
    # placed below this script in the script order
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    36 => [1],#里歐
    3 => [1],#樹寶
    11 => [14,3],#營地士兵
    12 => [14,3],#艾卓
    29 => [15,3],
    30 => [15,3],
    31 => [15,3],
    32 => [15,3],
    33 => [15,3],
    34 => [15,3],
    36 => [15,3],
    40 => [15,3],
    41 => [15,3],
    42 => [15,3],
    43 => [15,3],
    44 => [15,3],
    45 => [15,3],
    46 => [15,3],
    48 => [15,3],
    49 => [15,3],
    50 => [15,3],
    51 => [15,3],
    52 => [15,3],
    53 => [15,3],
    54 => [15,3],
    56 => [15,3],
    

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #  END EDITABLE REGION
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  TROOP_BATTLE_SCAPES.default = [1]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Battle Scapes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_zro28_btlscp_troopscape_4we1 battle_scapes
  def battle_scapes (*args)
    if $game_troop.troop.id > 0 && !TROOP_BATTLE_SCAPES[$game_troop.troop.id].empty?
      scapes = []
      TROOP_BATTLE_SCAPES[$game_troop.troop.id].each { |scape_id| scapes.push (ModernAlgebra.battle_scape (scape_id)) }
      return scapes unless scapes.empty? 
    end
    # If no special BG for troop set, default to showing by area or map
    return ma_zro28_btlscp_troopscape_4we1 (*args)
  end
end
