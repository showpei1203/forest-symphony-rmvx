#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：萤火虫模拟
# 【用途】保留的 Runtime 元件「萤火虫模拟」。
# 【主要機制】主要定義／擴充 Game_Firefly、Sprite_Firefly、Scene_Base、FSL；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Firefly、Sprite_Firefly、Scene_Base、FSL、Fireflies_Simulation
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：CYC。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：firefly_head。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
# ■ 萤火虫模拟
#    Fireflies_Simulation
#-------------------------------------------------------------------------------
# 地图上开启萤火虫的方法: 执行事件脚本 $scene.fireflies(数量)
# 关闭的方法是: $scene.fireflies(0)
#
# 其它scene类的开启同样执行该scene对象的 fireflies(数量)
#-------------------------------------------------------------------------------
#    更新作者： 沉影不器
#    许可协议： FSL
#    项目版本： 1.02.0827
#    引用网址： http://bbs.66rpg.com/thread-111137-1-2.html
#-------------------------------------------------------------------------------
#    - *1.02.0827 *  By 沉影不器
#      * 使用FSL协议
#
#    - *1.01.0108 *  By 沉影不器
#      * 允许使用地图模式(否则为屏幕模式),即萤火虫相对整个地图坐标活动
#      * 允许自定义萤火虫的初始化区域
#      * 增加闪烁参数
#
#    - *1.00.1128 *  By 沉影不器
#      * 初版
#===============================================================================
$fscript = {} if $fscript == nil
$fscript["Fireflies_Simulation"] = "1.02.0827"

#-------------------------------------------------------------------------------
# ▼ 通用配置模块
#-------------------------------------------------------------------------------
module FSL
  module Fireflies_Simulation
    PicName      = "firefly"        # 图片名
    Opacity      = 255              # 不透明度
    Speed        = 1                # 移动速度
    CYC          = 20              # 群体分散度
    Disperse     = 1                # 个体分散度
    BlendType    = 1                # 合成方式(0:正常 1:加法 2:减法)
    LeaderEnable = true             # 允许头领带队
    MapMode      = true             # 开启地图模式(地图当坐标,否则屏幕当坐标)
    Sparkle      = 80               # 闪烁值(0-100; 0:关闭闪烁)
    IniRect      = [544,200]               # 初始化萤火虫的区域[x,y,width,height]
                                    #   * 两个元素表示用坐标点做区域
                                    #   * 放空默认使用屏幕或全地图做区域
                                    #     该参数受MapMode影响
  end
end

#==============================================================================
# 萤火虫效果
#------------------------------------------------------------------------------
#==============================================================================
# □ Game_Firefly
#==============================================================================
class Game_Firefly
  include FSL::Fireflies_Simulation
  #--------------------------------------------------------------------------
  # ○ 实例变量
  #--------------------------------------------------------------------------
  attr_reader   :id                  # ID
  attr_reader   :x                   # X 坐标
  attr_reader   :y                   # Y 坐标
  attr_reader   :z                   # Z 坐标
  attr_reader   :angle               # 角度 (0~360) ### 图像旋转预留
  attr_reader   :blend_type          # 合成方式 
  attr_reader   :pic_name  
  attr_reader   :opacity
  attr_accessor :leader_id           # 头领id
  #--------------------------------------------------------------------------
  # ○ 初始化对象
  #--------------------------------------------------------------------------
  def initialize(id)
    @id = id
    @w,@h = set_rect
    @x,@y = rand_pos
    @angle = rand(360)
    @z = 199
    @angle = 0
    @opacity = Opacity
    @leader_id = 0
    @pic_name = PicName
    @blend_type = BlendType
    ## 百分比*10
    @speed = Speed/100.0
    ## 是否头领
    @leader = @id == @leader_id
    ## 群体分散计数器
    @move_count = 0
  end
  #--------------------------------------------------------------------------
  # ○ 是否地图模式?
  #--------------------------------------------------------------------------
  def map_type?
    return (MapMode and $scene.is_a? Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ○ 活动范围
  #--------------------------------------------------------------------------
  def set_rect
    if map_type?
      return $game_map.width*256,$game_map.height*256
    else
      return Graphics.width,Graphics.height
    end
  end
  #--------------------------------------------------------------------------
  # ○ 打散
  #--------------------------------------------------------------------------
  def rand_pos
    case IniRect.size
    when 1
      return rand(IniRect[0]),rand(IniRect[0])
    when 2
      return rand(IniRect[0]),rand(IniRect[1])
    when 3
      return [IniRect[0]+rand(IniRect[2]),IniRect[1]+rand(IniRect[2])]
    when 4
      return [IniRect[0]+rand(IniRect[2]),IniRect[1]+rand(IniRect[3])]
    else
      return rand(@w),rand(@h)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 自主移动
  #--------------------------------------------------------------------------
  def self_move
    ## 方向转换角度范围(-15..15)
    @angle += (-1)**(rand(2)+1) * rand(15)
    ## 角度转弧度
    rad = (@angle * Math::PI) / 180
    speed = (100.0-rand(Disperse)) * @speed
    dx = Math.cos(rad) * speed
    dy = Math.sin(rad) * speed
    @x += dx
    @y += dy
    ## 转向
    turn_around(dx, dy)
  end
  #--------------------------------------------------------------------------
  # ○ 跟随移动 
  #--------------------------------------------------------------------------
  def follow_move
    ## 超出距离时自主移动
    if distance > 150**2
      self_move
      return
    end
    ## 群体分散
    if @move_count < 0
      @move_count = CYC
      rx = leader.x - @x
      ry = leader.y - @y
      @angle = Math.atan2(ry,rx)*180 / Math::PI
      ## 打散
      @angle += rand(60) * ((-1)**(rand(2)+1))
    else
      @move_count -= rand(Disperse)
      ## 方向转换角度范围(-30..30)
      @angle += rand(15) * ((-1)**(rand(2)+1))
    end
    ###@angle = rad*180 / Math::PI
    ## 角度转弧度
    rad = (@angle * Math::PI) / 180
    speed = (rand(Disperse)+100.0) * @speed
    dx = Math.cos(rad) * speed
    dy = Math.sin(rad) * speed
    @x += dx
    @y += dy
  end
  #--------------------------------------------------------------------------
  # ○ 活动类型
  #--------------------------------------------------------------------------
  def update_active_type
    return if Sparkle.zero?
    @opacity = Opacity - Opacity * rand(Sparkle) / 100.0
  end
  #--------------------------------------------------------------------------
  # ○ 转向
  #--------------------------------------------------------------------------
  def turn_around(dx, dy)
    if @x <= 0 && dx < 0 or @x >= @w && dx > 0
      @angle = Math.atan2(dy,-dx)*180 / Math::PI
      @x -= dx
      ## 角度转弧度
      rad = (@angle * Math::PI) / 180
      speed = (rand(Disperse)+100.0) * @speed
      new_dx = Math.cos(rad) * speed
      new_dy = Math.sin(rad) * speed
      @x += new_dx
      @y += new_dy
    elsif @y <= 0 && dy < 0 or @y >= @h && dy > 0
      @angle = Math.atan2(-dy,dx)*180 / Math::PI
      @y -= dy
      ## 角度转弧度
      rad = (@angle * Math::PI) / 180
      speed = (rand(Disperse)+100.0) * @speed
      new_dx = Math.cos(rad) * speed
      new_dy = Math.sin(rad) * speed
      @x += new_dx
      @y += new_dy
    end
  end
  #--------------------------------------------------------------------------
  # ○ 距离判断 (返回值: 与头领的距离**2)
  #--------------------------------------------------------------------------
  def distance
    if map_type?
      result = (screen_x-leader.screen_x)**2 + (screen_y-leader.screen_y)**2
    else
      result = (@x-leader.x)**2 + (@y-leader.y)**2
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ○ 跟随对象
  #--------------------------------------------------------------------------
  def leader
    return $game_fireflies[0]
  end
  #--------------------------------------------------------------------------
  # ○ 是否跟随对象(头领)?
  #--------------------------------------------------------------------------
  def leader?
    return @leader
  end
  #--------------------------------------------------------------------------
  # ○ 判断坐标一致
  #     x : X 坐标
  #     y : Y 坐标
  #--------------------------------------------------------------------------
  def pos?(x, y)
    return (@x == x and @y == y)
  end
  #--------------------------------------------------------------------------
  # ○ 刷新
  #--------------------------------------------------------------------------
  def update
    if !LeaderEnable or !leader?
      follow_move
    else
      self_move
    end
    ## 处理活动类型
    update_active_type
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    return ($game_map.adjust_x(@x) + 8007) / 8 - 1000 + 16
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return ($game_map.adjust_y(@y) + 8007) / 8 - 1000 + 32
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    if @priority_type == 2
      return 200
    elsif @priority_type == 0
      return 60
    elsif @tile_id > 0
      pass = $game_map.passages[@tile_id]
      if pass & 0x10 == 0x10    # [☆]
        return 160
      else
        return 40
      end
    else
      return 100
    end
  end
end

#==============================================================================
# □ Sprite_Firefly
#==============================================================================
class Sprite_Firefly < Sprite_Base
  #--------------------------------------------------------------------------
  # ○ 初始化对象
  #     firefly   : 萤火虫数据实例
  #     viewport  : 视区
  #--------------------------------------------------------------------------
  def initialize(firefly, viewport = nil)
    super(viewport)
    @firefly = firefly
    self.bitmap = Cache.system(@firefly.pic_name)
    ###self.bitmap = Cache.system('firefly_head') if @firefly.leader?
    self.ox = self.width/2
    self.oy = self.height/2
    self.z = @firefly.z
    update
  end
  #--------------------------------------------------------------------------
  # ○ 释放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ○ 更新
  #--------------------------------------------------------------------------
  def update
    super
    @firefly.update
    if @firefly.map_type? 
      self.x = @firefly.screen_x
      self.y = @firefly.screen_y
    else
      self.x = @firefly.x
      self.y = @firefly.y
    end
    self.opacity = @firefly.opacity
    self.blend_type = @firefly.blend_type
  end
end

#==============================================================================
# ■ Scene_Base
#==============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # ○ 生成萤火虫
  #     num  :数量
  #--------------------------------------------------------------------------
  def fireflies(num)
    # 小等于零时释放
    dispose_firefly if num <= 0
    # 生成实例
    $game_fireflies = []
    for i in 0...num
      $game_fireflies << Game_Firefly.new(i)
    end
    # 生成sprite
    @firefly_sprites = []
    for i in $game_fireflies
      @firefly_sprites << Sprite_Firefly.new(i)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 刷新萤火虫
  #--------------------------------------------------------------------------
  def update_firefly
    return if @firefly_sprites == nil
    for sprite in @firefly_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # ○ 释放萤火虫
  #--------------------------------------------------------------------------
  def dispose_firefly
    return if @firefly_sprites == nil
    for sprite in @firefly_sprites
      sprite.dispose
    end
    @firefly_sprites = []
  end
  #--------------------------------------------------------------------------
  # ◎ 更新画面
  #--------------------------------------------------------------------------
  def update
    update_firefly
  end
  #--------------------------------------------------------------------------
  # ◎ 结束处理
  #--------------------------------------------------------------------------
  def terminate
    dispose_firefly
  end
end
