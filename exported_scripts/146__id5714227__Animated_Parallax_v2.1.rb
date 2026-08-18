#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Animated Parallax v2.1
# 【來源】modern algebra（rmrk.net），v2.1，2011-09-09。
# 【用途】讓地圖遠景使用 `_1、_2、_3...` 連號圖片輪播，並能為每張地圖設定切換速度；支援 png/jpg/bmp。
# 【素材命名】例如 `BlueSky_1.png、BlueSky_2.png、BlueSky_3.png` 放在 Graphics/Parallaxes；地圖資料庫的 Parallax 必須指定第一張（如 BlueSky_1），腳本會往後搜尋連號檔。若從 `_2` 開始，前面的 `_1` 不會參與。
# 【速度設定】`MAAP_PARALLAX_ANIMATION_FRAMES = { map_id => frames }`。frames 可為單一 Integer，或陣列指定每一幀停留時間。例如 `10=>40` 每 40 frame 換圖；`8=>[20,5,15]` 依序停 20/5/15 frame。未列出的地圖使用 Hash default，目前為 30。
# 【預載】MAAP_PRELOAD_PARALLAXES=true 會進地圖時一次 Cache 所有幀，降低第一次換圖卡頓但增加初始讀取／記憶體；大型遠景多時需實機衡量。
# 【API】由 Game_Map#setup_parallax_frames 自動掃描；一般事件不需要 Script Call。支援副檔名由 MAAP_SUPPORTED_EXTENSIONS 控制。
# 【相關素材】Graphics/Parallaxes/<base>_1..N；沒有固定檔名。退休前必須反查地圖 Parallax 設定，不能只搜尋 Script Call。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#    Version 2.1
#    Author: modern algebra (rmrk.net)
#    Date: September 9, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#
#==============================================================================

$imported = {} unless $imported
$imported["MAAnimatedParallax"] = true
$imported["MAAnimatedParallax2.1"] = true

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_Map
  MAAP_PARALLAX_ANIMATION_FRAMES = { # 詳見頁首繁中說明
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #
  #      map_id => frames,
  # either (a) an integer for how many frames you want to show each panel 
  #
  #    EXAMPLES:
  #      1 => 35，Map 1 每 35 frame 切換一次遠景幀。
  #      2 => 40，Map 2 每 40 frame 切換一次遠景幀。
  #      8 => [20, 5, 15]，Map 8 依序以 20／5／15 frame 顯示各幀。
  #
    10 => 40, 
    8 => 20, 
  } # 詳見頁首繁中說明
  MAAP_PARALLAX_ANIMATION_FRAMES.default = 30
  MAAP_PRELOAD_PARALLAXES = true
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #///////////////////////////////////////////////////////////////////////////
  MAAP_SUPPORTED_EXTENSIONS = ["png", "jpg", "bmp"]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_ap_stuppara_5tc1 setup_parallax
  def setup_parallax (*args, &block)
    ma_ap_stuppara_5tc1 (*args, &block) # 執行原方法
    setup_parallax_frames
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mlg_ap_updparal_4fg2 update_parallax
  def update_parallax (*args, &block)
    mlg_ap_updparal_4fg2 (*args, &block) # 執行原方法
    if @maap_parallax_frames && @maap_parallax_frames.size > 1
      @maap_parallax_frame_timer += 1
      if @maap_parallax_frame_timer % @maap_parallax_frame_limit == 0
        @maap_parallax_index = (@maap_parallax_index + 1) % @maap_parallax_frames.size
        @parallax_name = @maap_parallax_frames[@maap_parallax_index]
        if MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].is_a? (Array) && MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].size > @maap_parallax_index
          @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id][@maap_parallax_index]
        end
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_parallax_frames
    last_map_bmps = @maap_parallax_frames.nil? ? [] : @maap_parallax_frames
    @maap_parallax_index = 0
    @maap_parallax_frames = [@parallax_name]
    @maap_parallax_frame_timer = 0
    if MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].is_a? (Array) && MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].size > 0
      @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id][0]
    else
      @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id]
    end
    if @parallax_name[/_(\d+)$/] != nil
      frame_id = $1.to_i + 1
      base_name = @parallax_name.sub (/_\d+$/) { "" }
      while maap_check_extensions ("Graphics/Parallaxes/#{base_name}_#{frame_id}")
        @maap_parallax_frames.push ("#{base_name}_#{frame_id}")
        frame_id += 1
      end
    end
    (last_map_bmps - @maap_parallax_frames).each { |bmp| (Cache.parallax (bmp)).dispose }
    if MAAP_PRELOAD_PARALLAXES
      (@maap_parallax_frames - last_map_bmps).each { |bmp| Cache.parallax (bmp) }
      Graphics.frame_reset
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maap_check_extensions (filepath)
    MAAP_SUPPORTED_EXTENSIONS.each { |ext| 
      return true if FileTest.exist? ("#{filepath}.#{ext}") }
    return false
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Spriteset_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_animparlx_upd_4rg1 update_parallax
  def update_parallax (*args, &block)
    @parallax.bitmap = nil if @parallax_name != $game_map.parallax_name  
    malg_animparlx_upd_4rg1 (*args, &block) # 執行原方法
  end
end