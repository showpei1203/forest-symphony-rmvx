#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Dynamic Sound Emitting Areas/Events (VX) v2.0
# 【來源】modern algebra（rmrk.net），2008-08-09。
# 【用途】讓「事件」或「VX Area」成為 BGM/BGS/SE/ME 聲源；音量依玩家與聲源距離動態衰減，製造聲音從某處傳出的效果。
# 【事件用法】把設定寫在事件頁開頭的註解中：\SNDEMIT[stat = value]。大小寫不敏感，可寫多行。範例：\sndemit[se_name = 'Chicken']、\sndemit[se_max_volume = 80]、\sndemit[se_frames = 440]、\sndemit[se_frame_variance = 60]。此例會在預設半徑 10 格內播放 Chicken，最大音量 80，每約 380~500 frame 重播。
# 【可設定欄位】bgm_name/pitch/radius/max_volume；bgs_name/pitch/radius/max_volume；se_name/pitch/radius/max_volume/frames/frame_variance；me_name/pitch/radius/max_volume/frames/frame_variance。pitch 建議 50~150；radius 為格數；max_volume 為最大音量。
# 【Area 設定】RPG::Area#setup_sound_emissions 內 case @id 可直接寫 Area ID，例如 when 1 後設定 s.bgs_name='River'、s.bgs_radius=15、s.bgs_max_volume=110。未設定的 Area 仍建立空 Sound_Emission。
# 【更新方式】Game_Event 只讀事件頁最前方連續的 Comment（108/408）；Game_Map 會更新 Areas；RPG::Sound_Emission#volume 依距離計算音量，SE/ME 另外依 frame 計時器重播。
# 【載入順序】會 alias Game_Event#setup/update 與 Game_Map#setup/update；若後續地圖音效插件完整覆寫同方法，需維持目前已驗證順序。
# 【相關素材】本頁沒有固定 Audio 檔名；BGM/BGS/SE/ME 名稱由事件註解或 Area 設定提供。刪音效素材前應反查事件與 Area 設定，不可只掃腳本固定字串。
# 【注意】此系統會直接操作 RPG::BGM/BGS/SE/ME 播放與停止；同一地圖同時存在多個 BGM/BGS 聲源時，應實機確認互相覆蓋／停止行為。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#  Version 2.0
#  Author: modern algebra (rmrk.net)
#  Date: August 9, 2008
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Description:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Instructions:
#
#
#      \SNDEMIT[stat = value]
#
#
#
#    EXAMPLE:
#
#      \sndemit[se_name = 'Chicken']
#      \SndEmit[se_max_volume = 80]
#      \sNdeMit[se_frames = 440]
#      \SNDEMIT[se_frame_variance = 60]
#
#==============================================================================

#==============================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#==============================================================================

class RPG::Area
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :sound_emission
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_sound_emissions
    s = @sound_emission = RPG::Sound_Emission.new
    case @id
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    
    #
    #
    #  EXAMPLE:
    #
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    when 1 # 詳見頁首繁中維護說明
    when 4 # 詳見頁首繁中維護說明
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #////////////////////////////////////////////////////////////////////////
    end
    @sound_emission.rect = self.rect
    @sound_emission.initialize_frame_counts
  end
end

#==============================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#==============================================================================

class RPG::Sound_Emission
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :rect
  attr_accessor :bgs_name
  attr_accessor :bgs_pitch
  attr_accessor :bgs_radius
  attr_accessor :bgs_max_volume
  attr_accessor :bgm_name
  attr_accessor :bgm_pitch
  attr_accessor :bgm_radius
  attr_accessor :bgm_max_volume
  attr_accessor :se_name
  attr_accessor :se_pitch
  attr_accessor :se_radius
  attr_accessor :se_max_volume
  attr_accessor :se_frames
  attr_accessor :se_frame_variance
  attr_accessor :me_name
  attr_accessor :me_pitch
  attr_accessor :me_radius
  attr_accessor :me_max_volume
  attr_accessor :me_frames
  attr_accessor :me_frame_variance
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize
    @rect = Rect.new (0, 0, 0, 0)
    @bgs_name, @bgs_pitch, @bgs_radius, @bgs_max_volume, @bgm_name, @bgm_pitch, 
      @bgm_radius, @bgm_max_volume, @se_name, @se_pitch, @se_radius, 
      @se_max_volume, @me_name, @me_pitch, @me_radius, @me_max_volume, 
      @se_frames, @se_frame_variance, @me_frames, @me_frame_variance = '', 100, 
      10, 100, '', 100, 10, 100, '', 100, 10, 100 , '', 100, 10, 100, 20, 0, 20, 0
    initialize_frame_counts
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize_frame_counts
    @se_frame_count = @se_frames + rand (2*@se_frame_variance).floor - @se_frame_variance
    @me_frame_count = @me_frames + rand (2*@me_frame_variance).floor - @me_frame_variance
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    @stopped = false
    bgm.play if @bgm_name != '' 
    bgs.play if @bgs_name != ''
    update_se if @se_name != ''
    update_me if @me_name != ''
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def stop
    return if @stopped
    RPG::BGM.stop if @bgm_name != ''
    RPG::BGS.stop if @bgs_name != ''
    @stopped = true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def bgm
    @bgm = RPG::BGM.new (@bgm_name, 0, @bgm_pitch) if @bgm == nil
    @bgm.volume = volume (@bgm_radius, @bgm_max_volume)
    return @bgm
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def bgs
    @bgs = RPG::BGS.new (@bgs_name, 0, @bgs_pitch) if @bgs == nil
    @bgs.volume = volume (@bgs_radius, @bgs_max_volume)
    return @bgs
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * SE
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def se
    @se = RPG::SE.new (@se_name, 0, @se_pitch) if @se == nil
    @se.volume = volume (@se_radius, @se_max_volume)
    return @se
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_se
    if @se_frame_count == 0
      se.play
      @se_frame_count = @se_frames + rand (2*@se_frame_variance).floor - @se_frame_variance 
    else
      @se_frame_count -= 1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * ME
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def me
    @me = RPG::ME.new (@me_name, 0, @me_pitch) if @me == nil
    @me.volume = volume (@me_radius, @me_max_volume)
    return @me
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_me
    if @me_frame_count == 0
      me.play
      @me_frame_count = @me_frames + rand (2*@me_frame_variance).floor - @me_frame_variance
    else
      @me_frame_count -= 1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def volume (radius, max_volume)
    x, y = $game_player.x, $game_player.y
    xd, yd = x - @rect.x, y - @rect.y
    xd > 0 ? xd = x.between? (@rect.x, @rect.x + @rect.width) ? 0 : xd - @rect.width : xd *= -1
    yd > 0 ? yd = y.between? (@rect.y, @rect.y + @rect.height) ? 0 :yd - @rect.height : yd *= -1
    total_distance = Math.sqrt(xd*xd + yd*yd).ceil.to_i
    percent = (total_distance.to_f / radius.to_f)*100 
    percent = (100 - [percent, 100].min).to_f / 100.0
    return (percent*max_volume.to_f).to_i
  end
end

#==============================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#==============================================================================

class Game_Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #    page : the new page
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_sound_emit_obj_stp_event_pg_85nd setup
  def setup (new_page)
    ma_sound_emit_obj_stp_event_pg_85nd (new_page)
    @sound_emission.stop unless @sound_emission.nil?
    unless @page == nil
      s = @sound_emission = RPG::Sound_Emission.new
      @sound_emission.rect = Rect.new (@x, @y, 1, 1)
      comments = []
      @page.list.each { |i| i.code == 108 || i.code == 408 ? comments.push (i) : break }
      comments.each { |i|
        text = i.parameters[0].dup
        while text.sub! (/\\SNDEMIT\[(.+)\]/i) { '' } != nil
          eval ("@sound_emission." + $1.to_s)
        end
      }
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modalg_snd_emssn_script_upd_evnt_4n2 update
  def update
    modalg_snd_emssn_script_upd_evnt_4n2
    return if @sound_emission.nil?
    @sound_emission.rect.x, @sound_emission.rect.y = @x, @y
    @sound_emission.update
  end
end

#==============================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #    map_id : the ID of the map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modalg_dynamic_snd_emit_stup_rn4 setup
  def setup(map_id)
    @areas.each { |area| area.sound_emission.stop } unless @areas.nil?
    modalg_dynamic_snd_emit_stup_rn4 (map_id)
    @areas = []
    $data_areas.values.each { |area| @areas.push (area) if map_id == area.map_id }
    @areas.each { |i| i.setup_sound_emissions if i.sound_emission == nil }
    @advanced_areas = false
    begin
      $data_areas[1].active?
      @advanced_areas = true
    rescue 
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modalg_dyn_sound_emitting_objects_upd_4h3 update
  def update
    modalg_dyn_sound_emitting_objects_upd_4h3
    @areas.each { |area| 
      @advanced_areas && !area.active? ? area.sound_emission.stop : area.sound_emission.update
      }
  end
end