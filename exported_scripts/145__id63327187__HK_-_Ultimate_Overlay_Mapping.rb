#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：HK - Ultimate Overlay Mapping
# 【用途】地圖／事件元件「HK - Ultimate Overlay Mapping」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Spriteset_Map、Scene_Map、Overlay_Map、HK_UOM、Cache
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Hanzo Kimura。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
#              U L T I M A T E    O V E R L A Y    M A P P I N G
#                           Script By: Hanzo Kimura
#                            Date Created: 08/11/10
#==============================================================================
module HK_UOM
  
#=================================== SET UP ===================================#
# SCREEN SETUP
  Width   = 544           # The Size of Resolution (Screen's Width)  544/640
  Height  = 416           # The Size of Resolution (Screen's Height) 416/480
# SWITCHES
  LightSwitch = 201         #Switch to Activate Light Overlays
  ShadowSwitch = 202        #Switch to Activate Shadow Overlays
  ParSwitch = 203          #Switch to Activate Parallax Overlays
  GroundSwitch = 204        #Switch to Activate Ground Overlays
  ShadowSwitch2 = 205        #Switch to Activate Shadow Overlays
# FILENAMES
  LightMap = "Light"      #The name of the file for Light Overlays
  ShadowMap = "Shadow"    #The name of the file for Shadow Overlays
  ParMap = "Par"          #The name of the file for Parallax Overlays
  GroundMap = "Ground"    #The name of the file for Ground Overlays
  ShadowMap2 = "Shadow"    #The name of the file for Shadow Overlays

#================================ END OF SET UP ===============================#
end


# OVERLAY SCRIPT STARTS HERE #
module Cache
  def self.overlay(filename)
    load_bitmap("Overlays/", filename)
  end
end
class Spriteset_Map
  include HK_UOM
  alias hk_uom_initialize initialize
  def initialize
    @GroundON = FileTest.exist?("Overlays/" + "ground" + $game_map.map_id.to_s + ".png")
    hk_uom_initialize
    update
  end
  alias hk_uom_create_parallax create_parallax
  def create_parallax
    if @GroundON
      @ground = Sprite.new(@viewport1)
      @ground.z = 1
      @ground.bitmap = Cache.overlay("ground" + $game_map.map_id.to_s)
      @ground.opacity = 145
      @ground.blend_type = 2
      @ground.visible = $game_switches[GroundSwitch]
    end
    hk_uom_create_parallax
  end
  alias hk_uom_dispose_parallax dispose_parallax
  def dispose_parallax
    if @ground != nil
     @ground.dispose
   end
    hk_uom_dispose_parallax
 end
   alias hk_uom_update_parallax update_parallax
   def update_parallax
    if @ground != nil
        @ground.visible = $game_switches[GroundSwitch]
    end
    if @ground != nil
        @ground.tone = $game_map.screen.tone
        @viewport1.ox = $game_map.screen.shake  #update shake screen
        @viewport1.color = $game_map.screen.flash_color #update flash screen
        if @ground.ox != -$game_map.display_x / 256 or @ground.oy != -$game_map.display_y / 256 or @ground.ox == 0 or @ground.oy == 0
          @ground.ox = $game_map.display_x / 8
          @ground.oy = $game_map.display_y / 8
        end
      end
    hk_uom_update_parallax
    end
end
#==============================================================================
# Scene Map
#==============================================================================
class Scene_Map < Scene_Base
  alias hk_uom_start start
  def start
    hk_uom_start
    $OverlayMap = Overlay_Map.new
  end
  def terminate
    super
    if $scene.is_a?(Scene_Battle)
      @spriteset.dispose_characters
    end
    snapshot_for_background
    @spriteset.dispose
    @message_window.dispose
    $OverlayMap.dispose
    if $scene.is_a?(Scene_Battle)
      perform_battle_transition
    end
  end
  def update
    super
    $game_map.interpreter.update
    $game_map.update
    $game_player.update
    $game_system.update
    @spriteset.update
    @message_window.update
    $OverlayMap.update
    unless $game_message.visible
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
  end
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    @spriteset.dispose
    $game_player.perform_transfer
    $game_map.autoplay
    $game_map.update
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new
    $OverlayMap.dispose
    $OverlayMap = Overlay_Map.new
    fadein(30) if fade
    Input.update
  end
end
#==============================================================================
# Overlay
#==============================================================================
class Overlay_Map
include HK_UOM
  def initialize
    check_file
    display_overlay
  end
  def check_file
    @LightON = FileTest.exist?("Overlays/" + LightMap + $game_map.map_id.to_s + ".jpg")
    @ShadowON = FileTest.exist?("Overlays/" + ShadowMap + $game_map.map_id.to_s + ".jpg")
    @ParON = FileTest.exist?("Overlays/" + ParMap + $game_map.map_id.to_s + ".png")
    @GroundON = FileTest.exist?("Overlays/" + GroundMap + $game_map.map_id.to_s + ".png")
    @ShadowON2 = FileTest.exist?("Overlays/" + ShadowMap2 + $game_map.map_id.to_s + ".jpg")

    end
  
  # Displaying Overlays SET UP #
  def display_overlay
    if @LightON
      @light_viewport = Viewport.new(0, 0, Width, Height)
      @light_viewport.z = 10
      @light = Sprite.new(@light_viewport)
      @light.bitmap = Cache.overlay(LightMap + $game_map.map_id.to_s)
      @light.z = 10
      @light.opacity = 135
      @light.blend_type = 1
      @light.visible = $game_switches[LightSwitch]
    end
    if @ShadowON
      @shadow_viewport = Viewport.new(0, 0, Width, Height)
      @shadow_viewport.z = 9
      @shadow = Sprite.new(@shadow_viewport)
      @shadow.bitmap = Cache.overlay(ShadowMap + $game_map.map_id.to_s)
      @shadow.z = 9
      @shadow.opacity = 145
      @shadow.blend_type = 2
      @shadow.visible = $game_switches[ShadowSwitch]
      end
    if @ParON
      @par_viewport = Viewport.new(0, 0, Width, Height)
      @par_viewport.z = 8
      @par = Sprite.new(@par_viewport)
      @par.z = 8
      @par.bitmap = Cache.overlay(ParMap + $game_map.map_id.to_s)
      #@par_viewport.tone = $game_map.screen.tone
      @par.tone = $game_map.screen.tone
      @par.opacity = 255
      @par.blend_type = 0
      @par.visible = $game_switches[ParSwitch]
    end
    if @ShadowON2
      @shadow2_viewport = Viewport.new(0, 0, Width, Height)
      @shadow2_viewport.z = -1
      @shadow2 = Sprite.new(@shadow_viewport)
      @shadow2.bitmap = Cache.overlay(ShadowMap + $game_map.map_id.to_s)
      @shadow2.z = -1
      @shadow2.opacity = 65
      @shadow2.blend_type = 2
      @shadow2.visible = $game_switches[ShadowSwitch2]
      end
    update
  end
  
  # Update Overlays SET UP #
  def update
      if @light != nil
        @light.visible = $game_switches[LightSwitch]
      end 
      if @shadow != nil
        @shadow.visible = $game_switches[ShadowSwitch]
      end
      if @shadow2 != nil
        @shadow2.visible = $game_switches[ShadowSwitch2]
      end 
      if @par != nil
        @par.visible = $game_switches[ParSwitch]
      end 
      if @light != nil
        @light.tone = $game_map.screen.tone #update screentone
        @light_viewport.ox = $game_map.screen.shake #update shake screen
        @light_viewport.color = $game_map.screen.flash_color #update flash screen
        if @light.x != $game_map.display_x / 256 or @light.y != $game_map.display_y / 256 or @light.x == 0 or @light.y == 0
          @light.ox = $game_map.display_x / 8
          @light.oy = $game_map.display_y / 8
        end #./
      end #./
      if @shadow != nil
        @shadow.tone = $game_map.screen.tone #update screentone
        @shadow_viewport.ox = $game_map.screen.shake #update shake screen
        @shadow_viewport.color = $game_map.screen.flash_color #update flash screen
        if @shadow.x != $game_map.display_x / 256 or @shadow.y != $game_map.display_y / 256 or @shadow.x == 0 or @shadow.y == 0
          @shadow.ox = $game_map.display_x / 8
          @shadow.oy = $game_map.display_y / 8
        end #./
      end #./
      if @shadow2 != nil
        @shadow2.tone = $game_map.screen.tone #update screentone
        @shadow2_viewport.ox = $game_map.screen.shake #update shake screen
        @shadow2_viewport.color = $game_map.screen.flash_color #update flash screen
        if @shadow2.x != $game_map.display_x / 256 or @shadow2.y != $game_map.display_y / 256 or @shadow2.x == 0 or @shadow2.y == 0
          @shadow2.ox = $game_map.display_x / 8
          @shadow2.oy = $game_map.display_y / 8
        end #./
      end #./

      if @par != nil
        @par.tone = $game_map.screen.tone #update screentone
        @par_viewport.tone = $game_map.screen.tone
        @par_viewport.ox = $game_map.screen.shake  #update shake screen
        @par_viewport.color = $game_map.screen.flash_color #update flash screen
        if @par.ox != $game_map.display_x / 256 or @par.oy != $game_map.display_y / 256 or @par.ox == 0 or @par.oy == 0
          @par.ox = $game_map.display_x / 8
          @par.oy = $game_map.display_y / 8
        end #./
      end #./
  end #def end
  def dispose
      if @light != nil
        @light_viewport.dispose
        @light.dispose
      end
      if @shadow != nil
        @shadow_viewport.dispose
        @shadow.dispose
      end
      if @shadow2 != nil
        @shadow2_viewport.dispose
        @shadow2.dispose
      end
      if @par != nil
        @par_viewport.dispose
        @par.dispose
      end
  end
end