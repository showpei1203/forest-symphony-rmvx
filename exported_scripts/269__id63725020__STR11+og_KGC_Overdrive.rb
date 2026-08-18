#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：STR11+og_KGC Overdrive
# 【用途】保留的 Runtime 元件「STR11+og_KGC Overdrive」。
# 【主要機制】主要定義／擴充 Window_BattleStatus；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_BattleStatus
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BTSKIN_10、BTSKIN_10XY。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意。
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
# ★RGSS2 
# STR11+og_KGC Overdrive v1.1 08/03/13
# ◇ Requires STR11e_Battle Status
#
# ・若要顯示 KGC_OD，請將此腳本置於 Main 上方，並放在 STR11e_Battle Status 之下
#
# <Material Instructions>
# Skin images 載入自 Graphics\System
#
#  First Row: OD Skin
#  Second Row: Normal Gauge color
#  Third Row: Gauge MAX (flashing) color
#
# Mr. Bubble: 修正與 STR11+atb_Wait Gauge 同時使用時的 stack error
#------------------------------------------------------------------------------
#==============================================================================
# ■ Window_BattleStatus
#==============================================================================
class Window_BattleStatus < Window_Selectable
  # OD Gauge skin
  BTSKIN_10 = "Btskin_odg"   # 檔名
  BTSKIN_10XY = [-14, 42]     # 座標偏移 [x, y]
  
  #--------------------------------------------------------------------------
  # ★ Alias 初始化
  #--------------------------------------------------------------------------
  alias initialize_str11pog_od initialize
  def initialize(f = false)
    @odgw = Cache.system(BTSKIN_10).width
    initialize_str11pog_od(f)
  end
  
  #--------------------------------------------------------------------------
  # ● 建立項目
  #--------------------------------------------------------------------------
  alias draw_item_str11pog draw_item
  def draw_item(index)
    return unless @f
    actor = $game_party.members[index]
    draw_item_str11pog(index)
    extra_actor = (actor.id >= 7)
    s = @s_sprite[index]
    
    # 僅對 id < 7 的角色建立 OD gauge 精靈
    unless extra_actor
      s[21] = Sprite.new(@viewport)
      s[21].bitmap = Cache.system(BTSKIN_10)
      s[21].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_10XY[0]
      s[21].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_10XY[1]
      s[21].z = 4
      w = s[21].bitmap.width
      h = s[21].bitmap.height / 3
      s[21].src_rect.set(0, h, w, h)
      
      s[22] = Sprite.new(@viewport)
      s[22].bitmap = Cache.system(BTSKIN_10)
      s[22].x = @x[index] + BTSKIN_B_XY[0] + BTSKIN_10XY[0]
      s[22].y = @y[index] + BTSKIN_B_XY[1] + BTSKIN_10XY[1]
      s[22].z = 3
      s[22].src_rect.set(0, 0, w, h)
      
      s[23] = ((@odgw * actor.overdrive.to_f / actor.max_overdrive) + 1).to_i
      s[21].src_rect.width = s[23]
      
      for l in [21,22]
        s[l].opacity = 255
      end
      
      @s_party[index].push(actor.overdrive)
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 釋放物件
  #--------------------------------------------------------------------------
  alias dispose_str11pog dispose
  def dispose
    dispose_str11pog
    for i in 0...@s_sprite.size
      for l in [21,22]
        if @s_sprite[i][l]
          @s_sprite[i][l].bitmap.dispose rescue nil
          @s_sprite[i][l].dispose rescue nil
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 每幀更新
  #--------------------------------------------------------------------------
  alias update_str11pog update
  def update
    update_str11pog
    return unless @f
    for i in 0...@s_sprite.size
      s = @s_sprite[i]
      a = $game_party.members[i]
      # 強制對 id < 7 的角色才更新 OD（額外角色則隱藏）
      v = (a.id < 7) && (not KGC::OverDrive::HIDE_GAUGE_ACTOR.include?(a.id))
      for l in [21,22]
        s[l].visible = v if s[l]
      end
      if @opacity < 272
        for l in [21,22]
          s[l].opacity = @opacity if s[l]
        end
      end
      update_od(s, a, @s_party[i]) if a.id < 7
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 每幀更新 (OD)
  #--------------------------------------------------------------------------
  def update_od(s, a, m)
    # 若角色為額外角色，直接跳過
    return if a.id >= 7
    sr = s[21].src_rect
    if @odgw <= sr.width and Graphics.frame_count % 4 < 2
      s[21].src_rect.y = s[21].src_rect.height * 2
    else
      s[21].src_rect.y = s[21].src_rect.height
    end
    if a.overdrive != m[6]
      s[23] = ((@odgw * a.overdrive.to_f / a.max_overdrive) + 1).to_i
      m[6] = a.overdrive
    end
    if sr.width != s[23]
      if sr.width < s[23]
        sr.width += 1
      else
        sr.width -= 1
      end
      sr.width = s[23] if sr.width.abs <= 1
    end
  end
end
