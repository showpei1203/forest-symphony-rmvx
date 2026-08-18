#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：閃光效果
# 【用途】保留的 Runtime 元件「閃光效果」。
# 【主要機制】主要定義／擴充 Effects、Effect；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Effects、Effect
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：LightingBase、LightingTrace1、LightingTrace2、LightingBoom1、LightingBoom2、LightingEnd。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
class Effects
  def initialize
    @effects = []
  end
  def create(id,x,y)
    @effects.push(Effect.new(id,x,y))
  end
  def update
    for i in 0...@effects.size
      @effects[i].update
      if @effects[i].finished
        @effects[i].dispose
      end
    end
    @effects.compact!
  end
end

class Effect
  attr_reader :finished
  def initialize(type,x,y)
    @type = type
    @finished = false
    @frame = 0
    @spawns_every = 4
    create_sprite(x,y)
    set_movement
  end
  def create_sprite(x,y)
    @sprite = Sprite_Base.new
    case @type
    when 0 # Base
      @sprite.bitmap = Cache.picture('LightingBase')
      @sprite.zoom_x = 0.8
      @sprite.zoom_y = 0.8
    when 1 # Trace
      case rand(2)
      when 0
        @sprite.bitmap = Cache.picture('LightingTrace1')
      when 1
        @sprite.bitmap = Cache.picture('LightingTrace2')
      end
    when 2 # Boom
      case rand(2)
      when 0
        @sprite.bitmap = Cache.picture('LightingBoom1')
      when 1
        @sprite.bitmap = Cache.picture('LightingBoom2')
      end
    when 3 # End
      @sprite.bitmap = Cache.picture('LightingEnd')
      @sprite.zoom_x = 0.5
      @sprite.zoom_y = 0.5
    end
    @sprite.z = 100
    @sprite.x = x
    @sprite.y = y
#~     if @type == 3
#~       @sprite.x = x - (@sprite.width/2)
#~       @sprite.y = y - (@sprite.height/2)
#~     end
    @sprite.ox = @sprite.width/2
    @sprite.oy = @sprite.height/2
  end
  def set_movement
    @movement = []
    case @type
    when 0 # Base
      @movement = [6,0,-30,4]
    when 1 # Trace
      @movement = [0.5,0,0,5]
    when 2 # Boom
      case rand(4)
      when 0 # Up
        @movement = [0,-8,0,10]
      when 1 # Upper-Right
        @movement = [8,-8,0,10]
      when 2 # Right
        @movement = [8,0,0,10]
      when 3 # Lower-Right
        @movement = [8,8,0,10]
      when 4 # Down
        @movement = [0,8,0,10]
      end
    when 3 # End
      @movement = [0,0,0,8]
    end
  end
  def update
    if !@finished
      if @type == 0
        @frame += 1
        if @frame % @spawns_every == 0
          $effects.create(1,@sprite.x,@sprite.y)
        end
      end
      if @type == 3
        @sprite.zoom_x += 0.02
        @sprite.zoom_y += 0.02
      end
      @sprite.x += @movement[0]
      @sprite.y += @movement[1]
      @sprite.angle += @movement[2]
      @sprite.opacity -= @movement[3]
      if @sprite.opacity <= 0
#~         $effects.create(3,@sprite.x,@sprite.y) if @type == 0
        @finished = true
      end
    end
  end
  def dispose
    @sprite.dispose
  end
end