#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：♦DPS計算
# 【用途】保留的 Runtime 元件「♦DPS計算」。
# 【主要機制】主要定義／擴充 Game_Battler、Actor、Enemy、Window_DPS；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Battler、Actor、Enemy、Window_DPS、Scene_DPS、Scene_Battle、RPG
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
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
# ■DPS统计系统 by ZYYNOV
#------------------------------------------------------------------------------
# 此系统用于统计战斗时的输出数据，在战斗结束后显示各个队员造成的伤害及占比
# 新的战斗开始时会清空上一局的DPS统计,并重新统计。
#==============================================================================
$DPSswitch = false #控制战后是否显示DPS
                  #手动呼出使用代码$scene = Scene_DPS.new
class Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :dps     ####
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  alias zyynov_initialize initialize
  def initialize
    @dps = 0 ##############
    zyynov_initialize
  end
  #--------------------------------------------------------------------------
  # ● 伤害效果
  #--------------------------------------------------------------------------
  alias zyynov_execute_damage execute_damage
  def execute_damage(user)
    if @hp_damage > 0           # 若伤害为正数
      user.dps += @hp_damage#######
      remove_states_shock       # 攻击移除状态
    end
    zyynov_execute_damage(user)
  end
  ###
end

#==============================================================================
# ■ RPG::Actor除错用
#==============================================================================
#=begin
module RPG
  class Actor
    def initialize
      @damage = 0  ##除错用
    end
    attr_accessor :damage
  end
end
#=end
#==============================================================================
# ■ RPG::Enemy除错用
#==============================================================================
#=begin
module RPG
  class Enemy
    def initialize
      @damage = 0  ##除错用
    end
    attr_accessor :damage
  end
end
#=end

#==============================================================================
# ■ Window_DPS 
#------------------------------------------------------------------------------
# 　DPS显示的窗口。  by ZYYNOV
#==============================================================================
class Window_DPS < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 96, 544, 160)
    @actor = actor
    @adps = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    for i in 0 .. 3###计算队伍角色加起来的总输出，用来计算单个角色的输出占比
      if $game_party.members[i] != nil
      @adps += ($game_party.members[i].dps).to_f
      end
    end
    ###
    #--------------------------------------------------------------------------
    # ● 绘制战斗状态头像
    #     face_name  : 头像文件名
    #     face_index : 头像号码
    #     x     : 描画目标 X 坐标
    #     y     : 描画目标 Y 坐标
    #     size       : 显示大小
    #--------------------------------------------------------------------------
    def draw_status_face(face_name, face_index, x, y, size = 96)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96 + 32, 96, 22)
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
    end
    #--------------------------------------------------------------------------
    # ● 绘制战斗状态头像
    #     actor : 角色
    #     x     : 描画目标 X 坐标
    #     y     : 描画目标 Y 坐标
    #     size  : 绘制大小
    #--------------------------------------------------------------------------
    def draw_statu_face(actor, x, y)
    draw_status_face(actor.face_name, actor.face_index, x, y)
    end
    ###
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(x - 32 , y-96, 96, 24, "名字", 2)
    self.contents.draw_text(x + 96 , y-96, 96, 24, "头像", 2)
    self.contents.draw_text(x + 224 , y-96, 96, 24, "输出", 2)
    self.contents.draw_text(x + 352 , y-96, 96, 24, "占比", 2)
    ###
    self.contents.font.color = normal_color
    if $game_party.members[0] != nil
    draw_statu_face($game_party.members[0], x + 128, y-WLH*3)
    self.contents.draw_text(x + 0, y-WLH*3, 64, 24, $game_party.members[0].name.to_s, 2)
    self.contents.draw_text(x + 224, y-WLH*3, 96, 24, $game_party.members[0].dps.to_s, 2)
    self.contents.draw_text(x + 352, y-WLH*3, 96, 24, (($game_party.members[0].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    else 
    return
    end
    ###
    if $game_party.members[1] != nil
    draw_statu_face($game_party.members[1], x + 128, y-WLH*2)
    self.contents.draw_text(x + 0, y-WLH*2, 64, 24, $game_party.members[1].name.to_s, 2)
    self.contents.draw_text(x + 224, y-WLH*2, 96, 24, $game_party.members[1].dps.to_s, 2)
    self.contents.draw_text(x + 352, y-WLH*2, 96, 24, (($game_party.members[1].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    else 
    return
    end
    ###
    if $game_party.members[2] != nil
    draw_statu_face($game_party.members[2], x + 128, y-WLH)
    self.contents.draw_text(x + 0, y-WLH, 64, 24, $game_party.members[2].name.to_s, 2)
    self.contents.draw_text(x + 224, y-WLH, 96, 24, $game_party.members[2].dps.to_s, 2)
    self.contents.draw_text(x + 352, y-WLH, 96, 24, (($game_party.members[2].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    else 
    return
    end
    ###
    if $game_party.members[3] != nil
    draw_statu_face($game_party.members[3], x + 128, y)
    self.contents.draw_text(x + 0, y, 64, 24, $game_party.members[3].name.to_s, 2)
    self.contents.draw_text(x + 224, y, 96, 24, $game_party.members[3].dps.to_s, 2)
    self.contents.draw_text(x + 352, y, 96, 24, (($game_party.members[3].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    else 
    return
    end
  end
end

#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　处理DPS窗口的类。by ZYYNOV
#==============================================================================

class Scene_DPS < Scene_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_index : 角色位置
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0)
    @actor_index = actor_index
    #self.bitmap = Cache.save ("temp1")###
  end
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @dps_window = Window_DPS.new(@actor)
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @dps_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 回到原画面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    @dps_window.update
    if Input.trigger?(Input::C)
      Sound.play_cancel
      return_scene
    end
    super
  end
end

#==============================================================================
# ■ 战斗结束时显示DPS窗口
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias zyy_nov_start start
  def start
    zyy_nov_start
    for i in 0 .. 2##清空队伍成员的DPS
      if $game_party.members[i] != nil
      $game_party.members[i].dps = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  alias zyynov_terminate terminate
  def terminate
    zyynov_terminate
    if $DPSswitch == true
    $scene = Scene_DPS.new
    end
  end
end