#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：螢幕上繪製狀態
# 【用途】介面腳本「螢幕上繪製狀態」，負責選單／視窗／HUD／狀態顯示的一部分。
# 【主要機制】主要透過 Window_*、Scene_* 或 Sprite 類別擴充既有 UI；若有後載入 FS Patch，最終外觀以後載入 Authority 為準。
# 【主要影響】Sprite_Battler
# 【設定／可調參數】若本頁有 Configuration／Settings／設定區，請優先只改該區；核心方法除非已確認依賴鏈，否則不建議直接改寫。
# 【依賴／載入順序】本頁含 3 個 alias／方法包裝，代表載入順序具有語意。
# 【呼叫方式】一般由引擎／既有 Scene、Window、Game_* 流程自動執行；若下方原文件另有 Script Call／Notetag，請沿用原格式。
# 【範例】此腳本若沒有對外 Script Call，通常由 RGSS2、事件流程或其他腳本自動呼叫；請勿為了「有範例」而硬造不存在的 API。
# 【英文說明中文化】本頁原英文說明已在此維護區以繁體中文整理其用途、核心機制、設定、依賴與使用方式；下方英文原文保留作為作者原始資料與授權／細節查核依據。
# 【來源／授權】請保留下方原作者署名／授權資訊；本中文說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本中文區必須放在腳本開頭；新增功能時同步更新用途、設定、依賴與範例。
# 2. 原作者署名、授權與原始英文文件保留在下方，不因中文化而移除。
# 3. 若本頁屬 alias／Compatibility／Authority chain，修改前先查 LoadOrder Guide。
#==============================================================================
=begin
class Sprite_Battler < Sprite_Base
  
  alias initialize_old initialize
  def initialize(viewport, battler = nil)
    initialize_old(viewport, battler)
    if @battler.is_a?(Game_Enemy)
      create_states
    end
  end
  #--------------------------------------------------------------------------
  # ● 创建状态精灵 draw_stun_indicator(x, y, actor)
  #--------------------------------------------------------------------------
  def create_states
    # 创建精灵
    @spstates = Sprite.new
    @spstates.bitmap = Bitmap.new(100, 124)
    @spstates.visible = true#@battler_visible
    @spstates.z = 0
    bitmap = Bitmap.new("Graphics/Battlers/" + @battler.battler_name)
    @spstates.x = @battler.screen_x - 30# - bitmap.width# + GCCH::BEGIN_X + 20
    @spstates.y = @battler.screen_y - (bitmap.height/2) + 5# + bitmap.height/4# - @base_height# + GCCH::BEGIN_Y - 20
    #@spstates.y = @battler.screen_y - (bitmap.height/2) - 25
    @spstates.zoom_x = 0.7
    @spstates.zoom_y = 0.7
    @spstates.opacity = 150
    @spstates.bitmap.fill_rect(10, 10, 100, 25, Color.new(0, 0, 0,128))#原始
    ###

    ###
    @save=@battler.states
    @spstates.bitmap.font.size=GCCH::F_SIZE
    @spstates.bitmap.font.color=GCCH::F_COLOR
    # 绘制
    refresh_states
  end
  #--------------------------------------------------------------------------
  # ● 绘制精灵
  #--------------------------------------------------------------------------
  def refresh_states
    @spstates.bitmap.clear
    for i in 0..GCCH::MAX_SHOW-1
      if @battler.states[i]!=nil
        x=i*28#i*25
        #y = i*25
        ###
        #rect2 = Rect.new (x, 1, 24, 24)
        #@spstates.bitmap.fill_rounded_rect(rect2, Color.new(0, 0, 0, 128))
        ###
        icon_index=@battler.states[i].icon_index
        bitmap = Cache.system("Iconset")
        rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        @spstates.bitmap.blt(x,0,bitmap,rect)
        #@spstates.bitmap.blt(0,y,bitmap,rect)

        if GCCH::TURN_SHOW
          turn=@battler.state_turns[@battler.states[i].id]
          if turn==0
            @spstates.bitmap.draw_text(x,10,25,15,"即消",2)
          else
             @spstates.bitmap.draw_text(x,10,25,15,turn,2)
          end
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 销毁
  #--------------------------------------------------------------------------
  def dispose_states
    @spstates.dispose if @spstates != nil  #@spstates.dispose #return 0
  end
  
  #--------------------------------------------------------------------------
  # ● 追加刷新
  #--------------------------------------------------------------------------
  alias old_update update
  def update
    old_update
    refresh_states if @battler.is_a?(Game_Enemy)
  end
  #--------------------------------------------------------------------------
  # ● 追加销毁
  alias old_dispose dispose
  def dispose
    old_dispose
    dispose_states
    #↓添加更多的内容
    
  end
end
=end