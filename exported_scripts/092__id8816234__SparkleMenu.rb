#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SparkleMenu
# 【用途】UI／選單元件「SparkleMenu」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】GB_SelectSparkle、Window_Selectable2、GameBaker
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
#==========================================================================
# ** Sparkling Selectable
#==========================================================================
# Version Q [VX]
# January 26th, 2008
#==========================================================================

module GameBaker
  SelectSparkle = 'gamebaker_sparkle'
  SelectSparkleChance = Hash.new(25)
  SelectSparkleFade = Hash.new(2)
  SelectSparkleOutOfBounds = false
  SelectSparkleRandom = false
end

# GameBaker::SelectSparkleChance['Scene_Battle'] = nil

# This script was for a commercial game. We're releasing it because we're
# nice, but please pretend it doesn't exist instead if you're one of those
# morons who spam me saying they pirated VX & think I'm scum for working on 
# a commercial game because "all rm games are supposed to be free". ty

# Non-commercial use only!

#==========================================================================
#
# Credit:  rmvx.gameclover.com
#
# It's the resource dump site we'll eventually be posting a lot of our work
# for commercial games on as resources the public can use :)
#
#==========================================================================

# Need help with this script?
# Yeah, us too, we forgot where we put the instructions
# Check back wherever you found it later :D

class GB_SelectSparkle < Sprite
  attr_accessor :dying, :fade
  
  def initialize
    super
    self.bitmap = Cache.system(GameBaker::SelectSparkle)
    self.opacity = rand(15)
    if GameBaker::SelectSparkleRandom
      self.tone = Tone.new(rand(255),rand(255),rand(255),141+rand(115))
    end
    self.src_rect.set(0, 0, 7, 7)
  end
     
  def update
    if @dying
      self.opacity -= @fade + rand(11)
      return
    end
    self.opacity += @fade + rand(6)
    if self.opacity >= 230
      @dying = true
      self.src_rect.set(42, 0, 7, 7)
    elsif self.opacity >= 200
      self.src_rect.set(35, 0, 7, 7)
    elsif self.opacity >= 170
      self.src_rect.set(28, 0, 7, 7)
    elsif self.opacity >= 140
      self.src_rect.set(21, 0, 7, 7)
    elsif self.opacity >= 100
      self.src_rect.set(14, 0, 7, 7)
    elsif self.opacity >= 60
      self.src_rect.set(7, 0, 7, 7)
    end
  end
end

class Window_Selectable2 < Window_Base 
  alias_method :gamebaker_sparkselect_init, :initialize
  def initialize(*args)
    gamebaker_sparkselect_init(*args)
    @gb_selectsparkles = []
    #return if self.cursor_rect.empty
    if GameBaker::SelectSparkleChance[$scene.class.to_s] == nil
      @gb_selectsparklesoff = true
      return
    end
    @gb_selectsparklefade = GameBaker::SelectSparkleFade[$scene.class.to_s]
    if GameBaker::SelectSparkleFade.has_key?(self.class.to_s)
      @gb_selectsparklefade = GameBaker::SelectSparkleFade[self.class.to_s]
    end
    @gb_selectsparklechance = GameBaker::SelectSparkleChance[$scene.class.to_s]
    # credit : rmvx.gameclover.com
    if GameBaker::SelectSparkleChance.has_key?(self.class.to_s)
      @gb_selectsparklechance = GameBaker::SelectSparkleChance[self.class.to_s]
    end
  end
    
  if !method_defined?('gamebaker_sparkselect_active')
    alias_method :gamebaker_sparkselect_active, :active=
    alias_method :gamebaker_sparkselect_dispose, :dispose
  end

  def active=(num)
    gamebaker_sparkselect_active(num)
    return if num != false
    @gb_selectsparkles.each { |i| i.dispose if !i.disposed? }
    @gb_selectsparkles = []
  end
  
  def dispose
    gamebaker_sparkselect_dispose
    @gb_selectsparkles.each { |i| i.dispose if !i.disposed? }
    @gb_selectsparkles = []
  end
  
  alias_method :gamebaker_sparkselect_update, :update
  def update
    if !self.active or @gb_selectsparklesoff
      gamebaker_sparkselect_update
    else
      @gb_selectsparklelastindex = @index
      gamebaker_sparkselect_update
      if @gb_selectsparklelastindex != @index
        @gb_selectsparkles.each { |i| i.dying = true }
      end
      for i in 0...@gb_selectsparkles.size
        @gb_selectsparkles[i].update
        if @gb_selectsparkles[i].opacity <= 0
          @gb_selectsparkles[i].dispose
          @gb_selectsparkles[i] = nil
        end
      end
      @gb_selectsparkles = @gb_selectsparkles.compact
      if rand(@gb_selectsparklechance) == 0
        gb = GB_SelectSparkle.new
        gb.fade = @gb_selectsparklefade
        gbx = rand(self.cursor_rect.width)
        gby = rand(self.cursor_rect.height)
        gb.viewport = self.viewport
        if GameBaker::SelectSparkleOutOfBounds
          if rand(2) == 0
            gbx -= 7; gby -= 7
          end
        else
          gbx -= 7 if gbx >= self.cursor_rect.width - 7
          gby -= 7 if gby >= self.cursor_rect.height - 7
        end
        gb.x = self.x + 16 + self.cursor_rect.x + gbx
        gb.y = self.y + 16 + self.cursor_rect.y + gby
        gb.z = self.z + 100
        @gb_selectsparkles += [gb]
      end
    end
  end
end

#==========================================================================
