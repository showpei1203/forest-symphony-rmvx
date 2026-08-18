#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Khas Script Core
# 【用途】保留的 Runtime 元件「Khas Script Core」。
# 【主要機制】主要定義／擴充 Neo_Effect、Title_Effect、Core、Cache；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Neo_Effect、Title_Effect、Core、Cache、Bitcore
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
#-------------------------------------------------------------------------------
# * [RMVX] Khas Script Core
#-------------------------------------------------------------------------------
# * By Khas Arcthunder
# * Version: 1.0
# * Released on: 08/06/2010
#
# * Blog: http://arcthunder.com/
# * Forum: http://rgssx.com/
# * Twitter: http://twitter.com/arcthunder
# * Youtube: http://youtube.com/user/darkkhas
#
#-------------------------------------------------------------------------------
# Terms of Use | Termos de Uso
#-------------------------------------------------------------------------------
# * ENGLISH
# Read updated terms of use at http://arcthunder.com/terms
#
# * PORTUGUES
# Leia os termos atualizados em http://arcthunder.com/termos
#
#-------------------------------------------------------------------------------
# Installation | Instalação
#-------------------------------------------------------------------------------
# * ENGLISH
# 1) This script should be placed after "Materials" and before any Khas' Scripts
# 2) Setup this script in Setup Part below.
#
# *PORTUGUES
# 1)Este script tem que ser colocado depois dos "Scripts Adicionais" e antes
# de qualquer script Khas
# 2) Configure o script na parte de configuração
#
#-------------------------------------------------------------------------------
# Setup | Configuração
#-------------------------------------------------------------------------------
module Core
  # Khas scripts language         | Lingua dos scripts Khas
  # 0 - English                   | 0 - Ingles
  # 1 - Portuguese                | 1 - Portugues
  Language = 0 
  
#-------------------------------------------------------------------------------
# End of Setup Part
#-------------------------------------------------------------------------------

  @scripts = {}
  def self.version
    return 1.0
  end
  def self.register(script,version)
    @scripts[script] = version
  end
  def self.enabled?(script,version=1)
    en = @scripts.has_key?(script) ? true : false; return en unless en
    return (en and @scripts[script] >= version)
  end
  def self.load_matrix; $pixel_matrix = {}
    for x in 0..543
      $pixel_matrix[x] = {}
    end
    for x in 0..543
      for y in 0..415
        $pixel_matrix[x][y] = (57.3*Math.atan2(272-x,208-y)).to_i
      end
    end
  end
  def self.require(script,from,version = 1.0)
    unless @scripts.has_key(script)
      if Language == 1
        p "O script #{from} precisa do script #{script}"
        p "Por favor, instale o #{script} #{version}"
      else
        p "The script #{from} requires #{script}"
        p "Please install the #{script} #{version}"
      end
      exit
    else
      unless @scripts[script] >= version
        if Language == 1
          p "#{script} #{version} é antigo"
          p "Por favor, instale o #{script} #{version}"
        else
          p "#{script} #{version} is obsolete"
          p "Please install the #{script} #{version}"
        end
        exit
      end
    end
  end
  def self.enter_fs
    $showm = Win32API.new 'user32', 'keybd_event', %w(l l l l), ' ' 
    $showm.call(18,0,0,0) 
    $showm.call(13,0,0,0) 
    $showm.call(13,0,2,0) 
    $showm.call(18,0,2,0)
  end
end

$enabled_core = Core.version

module Cache
  def self.particle(filename)
    load_bitmap("Graphics/Particles/", filename)
  end
  def self.title(filename)
    load_bitmap("Graphics/Title/", filename)
  end
end

module Bitcore
  @cached_bitmaps = {}
  def self.add(bitmap,key)
    if @cached_bitmaps.has_key?(key)
      p "Bitcore error!"; p "Cached bitmap: #{key}"
    else
      @cached_bitmaps[key] = bitmap
    end
  end
  def self::[](key)
    return @cached_bitmaps[key]
  end
  def self.delete(key)
    unless @cached_bitmaps.has_key?(key)
      p "Bitcore error!"; p "Uncached bitmap: #{key}"
    else
      @cached_bitmaps[key].dispose
      @cached_bitmaps.delete(key)
    end
  end
  def self.reset
    @cached_bitmaps.keys.each { |i| @cached_bitmaps[i].dispose }
    @cached_bitmaps.clear
  end
  def self.cached_bitmaps
    return @cached_bitmaps.keys
  end
  def self.cached_value
    return @cached_bitmaps.size
  end
end

class Neo_Effect
  attr_accessor :picture_name
  attr_accessor :opacity
  attr_accessor :color
  attr_accessor :blend_mode
  attr_accessor :angle
  attr_accessor :opacity_oscillation
  attr_accessor :ax
  attr_accessor :ay
  attr_accessor :hue_oscillation
  def initialize(picture, opacity, color=Tone.new(0,0,0), blend_mode=1,
    ax=0, ay=0, angle=0, op_os=0, hue=0)
    @picture_name = picture
    @opacity = opacity
    @color = color
    @blend_mode = blend_mode
    @angle = angle
    @opacity_oscillation = op_os
    @ax = ax
    @ay = ay
    @hue_oscillation = (hue == 0 ? false : hue)
  end
end

class Title_Effect
  attr_accessor :picture_name
  attr_accessor :opacity
  attr_accessor :position
  attr_accessor :blend_mode
  attr_accessor :angle
  attr_accessor :ax
  attr_accessor :ay
  attr_accessor :z
  def initialize(picture, plane=false, z=1, op=255,
    pos=[0,0,0], blend=1, angle=0, ax=0, ay=0)
    @picture_name = picture
    @opacity = op
    @position = pos
    @blend_mode = blend
    @angle = angle
    @ax = ax
    @ay = ay
    @z = z
    @plane = plane
  end
  def plane?
    return @plane
  end
end