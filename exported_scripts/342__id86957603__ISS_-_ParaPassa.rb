#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ISS - ParaPassa v0.9
# 【來源】IceDragon，ID PR01，建立／修改日 2011-06-15。
# 【用途】改寫 VX 地圖通行判定，利用 E 層指定 Tile ID 768～799 表示額外方向通行規則，並同步改寫 Game_Map、Game_Character、Game_Player、Spriteset_Map／Scene 流程。
# 【核心設定】ISS::ParaPassa::USE_TILEMAP=false。這不是一般事件 Script Call 系統，而是地圖通行 Runtime；修改前必須用實際地圖測試角色移動、事件 Touch、船／水域與 Map Loop。
# 【Ground Tile 768～783】768不可通行、769全通、770僅上、771僅右、772僅下、773僅左、774垂直、775水平、776上+右、777右+下、778下+左、779左+上、780左+上+右（不可下）、781上+右+下（不可左）、782右+下+左（不可上）、783下+左+上（不可右）。
# 【Water Tile 784～799】規則與 768～783 完全對應但偏移 +16；784不可通行、785全通……799為下+左+上。passable? 在 flag==0x01 時會先阻止 784 以上 Water Tile，因此水域行為還受呼叫 flag 影響。
# 【測試工具】Playtest 且 $TEST 時按 F5，會 print 玩家座標的 map.data[x,y,2] Tile ID，方便確認目前 B～E 層實際 ID。原作者也明示此版本仍有一些已知瑕疵，因此不要只靠靜態推理修改。
# 【載入順序】本頁直接 overwrite Game_Map#passable? 與多個 Game_Character move_*，屬高風險地圖核心。不能與另一套通行系統隨意交換順序；若未來退休必須掃描地圖是否使用 768～799 專用 Tile 佈局。
# 【相關素材】不直接引用 Graphics／Audio 檔名；依賴地圖 Tile ID 與 Map Data，本身的「素材」是地圖通行配置而非獨立圖片檔。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#==============================================================================#
#==============================================================================# 
# ** Date Created  : 06/15/2011
# ** Date Modified : 06/15/2011
# ** Created By    : IceDragon
# ** ID            : PR01
# ** Version       : 0.9
#==============================================================================# 
# ============================================================================ #
# ============================================================================ #
$imported = {} if $imported == nil
$imported["ISS-ParaPassa"] = true
#==============================================================================#
#==============================================================================#
module ISS
  module ParaPassa
    USE_TILEMAP = false
  end  
end

#==============================================================================#
#==============================================================================#
class ISS::ParaPassa::Parallax_Passages
  
  def passable?( xo, yo, xt, yt, tile_id, flag=0x01 )
    return false if flag == 0x01 && tile_id >= 784
    case tile_id
#==============================================================================#    
#==============================================================================#    
    when 768
      return false
    when 769
      return true
    when 770
      return true if yo > yt
    when 771
      return true if xo < xt
    when 772
      return true if yo < yt
    when 773
      return true if xo > xt
    when 774
      return false if xo != xt
      return true
    when 775
      return false if yo != yt
      return true
    when 776
      return false if yo < yt
      return false if xo > xt
      return true
    when 777
      return false if xo > xt
      return false if yo > yt
      return true
    when 778
      return false if yo > yt
      return false if xo < xt
      return true
    when 779
      return false if xo < xt
      return false if yo < yt
      return true
    when 780
      return false if yo < yt
      return true
    when 781
      return false if xo > xt
      return true
    when 782
      return false if yo > yt # // No Up
      return true
    when 783
      return false if xo < xt
      return true
#==============================================================================#      
#==============================================================================#    
    when 784
      return false
    when 785
      return true
    when 786
      return true if yo > yt
    when 787
      return true if xo < xt
    when 788
      return true if yo < yt
    when 789
      return true if xo > xt
    when 790
      return false if xo != xt
      return true
    when 791
      return false if yo != yt
      return true
    when 792
      return false if yo < yt
      return false if xo > xt
      return true
    when 793
      return false if xo > xt
      return false if yo > yt
      return true
    when 794
      return false if yo > yt
      return false if xo < xt
      return true
    when 795
      return false if xo < xt
      return false if yo < yt
      return true
    when 796
      return false if yo < yt
      return true
    when 797
      return false if xo > xt
      return true
    when 798
      return false if yo > yt # // No Up
      return true
    when 799
      return false if xo < xt
      return true  
#==============================================================================#      
    end
    return false
  end
        
  def update()
    if Input.trigger?( Input::F5 )
      print $game_map.data[ $game_player.x, $game_player.y, 2 ]
    end if $TEST 
  end
  
end  

#==============================================================================#
#==============================================================================#
class Game_Map
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)
      next if event.tile_id == 0
      next if event.priority_type > 0
      next if event.through
      pass = @passages[event.tile_id]
      next if pass & 0x10 == 0x10
      return true if pass & flag == 0x00
      return false if pass & flag == flag
    end
    tile_id = @map.data[x, y, 2]
    return false unless $game_parapassa.passable?( x, y, x, y, tile_id, flag )
    return true
  end
  
end

#==============================================================================#
#==============================================================================#
class Game_Character
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_down(turn_ok = true)
    xo, yo, xt, yt = @x, @y, @x, @y+1
    if move_passable?( xo, yo, xt, yt )                  # Passable
      turn_down
      @y = $game_map.round_y(@y+1)
      @real_y = (@y-1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y+1)
      @move_failed = true
    end
  end
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_left(turn_ok = true)
    xo, yo, xt, yt = @x, @y, @x-1, @y
    if move_passable?( xo, yo, xt, yt )                  # Passable
      turn_left
      @x = $game_map.round_x(@x-1)
      @real_x = (@x+1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_left if turn_ok
      check_event_trigger_touch(@x-1, @y)
      @move_failed = true
    end
  end
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_right(turn_ok = true)
    xo, yo, xt, yt = @x, @y, @x+1, @y
    if move_passable?( xo, yo, xt, yt )                  # Passable
      turn_right
      @x = $game_map.round_x(@x+1)
      @real_x = (@x-1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_right if turn_ok
      check_event_trigger_touch(@x+1, @y)
      @move_failed = true
    end
  end
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_up(turn_ok = true)
    xo, yo, xt, yt = @x, @y, @x, @y-1
    if move_passable?( xo, yo, xt, yt )                  # Passable
      turn_up
      @y = $game_map.round_y(@y-1)
      @real_y = (@y+1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y-1)
      @move_failed = true
    end
  end

  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)
      unless event.through
        return true if event.priority_type == 1
      end
    end
    if @priority_type == 1
      return true if $game_player.pos_nt?(x, y)
      return true if $game_map.boat.pos_nt?(x, y)
      return true if $game_map.ship.pos_nt?(x, y)
    end
    return false
  end
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_passable?( xo, yo, xt, yt )
    tile_id = $game_map.data[ xo, yo, 2 ] 
    return true if @through || debug_through?
    return false unless passable?( xt, yt )
    return false unless $game_parapassa.passable?( xo, yo, xt, yt, tile_id )
    return true 
  end  
  
end

#==============================================================================#
#==============================================================================#
class Game_Player < Game_Character
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------# 
  def move_passable?( xo, yo, xt, yt )
    tile_id = $game_map.data[ xo, yo, 2 ] 
    case @vehicle_type 
    when 0 ; flag = 0x02
    when 1 ; flag = 0x04
    when 2 ; flag = 0x08
    else   ; flag = 0x01
    end  
    return true if @through || debug_through?
    return false unless passable?( xt, yt )
    return false unless $game_parapassa.passable?( xo, yo, xt, yt, tile_id, flag )
    return true 
  end
  
end

#==============================================================================#
#==============================================================================#
class Spriteset_Map
  
unless ISS::ParaPassa::USE_TILEMAP  
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------#
  def create_tilemap ; end  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------#
  def dispose_tilemap ; end
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------#
  def update_tilemap ; end
    
end
  
end  
  
#==============================================================================#
#==============================================================================#
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------#    
  alias :iss_parapassa_scnt_create_game_objects :create_game_objects unless $@
  def create_game_objects()
    iss_parapassa_scnt_create_game_objects()
    $game_parapassa = ISS::ParaPassa::Parallax_Passages.new()
  end
  
end

#==============================================================================#
#==============================================================================#
class Scene_Map
  
  alias :iss_parapassa_scmp_update :update unless $@
  def update()
    iss_parapassa_scmp_update()
    $game_parapassa.update()
  end
  
end  

#=*==========================================================================*=#
#=*==========================================================================*=#