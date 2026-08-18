#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：標題Final-0714
# 【用途】保留的 Rafidelis Title X 2.0 標題畫面歷史／參考腳本。
# 【主要機制】目前位於 Main 與全腳本導出工具之後；因前一頁 exporter 會 exit，所以正常 Runtime 不會載入此頁。依使用者要求保留，若未來要重新啟用必須先重新設計載入位置。
# 【主要影響】Sprite_Particle、Sprite_Particle1、Scene_Title、Reffect1、Rafidelis、Title_X、Cache
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：COMMAND_PIC_NAMES、CURSOR_PIC_NAME、MOVE_TITLE_PIC、TITLE_PIC_HORIZONTAL_MOVIMENT_SPEED、TITLE_PIC_VERTICAL_MOVIMENT_SPEED、NAME_GAME_PIC、NAME_GAME_PIC_POSY、TITLE_FOG_NAME。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；目前在 exporter 後方，正常 Runtime 不會載入；若要重新啟用不能只搬頁面，需重新檢查 Scene_Title Authority。
# 【呼叫方式／範例】目前是保留參考頁，正常 Runtime 不呼叫；不要用「直接 new Scene_Title」方式繞過現行標題 Authority。
# 【相關素材】本頁直接引用：lightball。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================#
#              [RGSS2] Rafidelis Title X - 2009 New Version                    #
#------------------------------------------------------------------------------#
# $RafiScripts.by = Rafidelis(Rafis)                                           #
# $RafiScripts.version = 2.0                                                   #
# $RafiScripts.release_date = 30/11/08  (d/m/y)                                #
# $RafiScripts.update_date = 13/08/09  (d/m/y)                                 #
# $RafiScripts.email = Rafa_Fidelis@hotmail.com or Rafa_Fidelis@yahoo.com.br   #
# $RafiScripts.website = www.ReinoRPG.com  or www.ReinoRPG.com/forum           #
#==============================================================================#
# [** $RafiScripts.versions **]  // Versões do Script/Script Versions          #
#------------------------------------------------------------------------------#
# 30/11/09 - Lançada Versão 1.0  - Mais de 1600 Downloads                      #
# 13/07/09 - Lançada Versão 2.0  - Reescrito para ser mai
#==============================================================================#
# [** $RafiScripts.desc **]  // Sobre o Script / About Script                  #
#------------------------------------------------------------------------------#
# Este script personaliza o Titulo,com varios efeitos.                         #
#==============================================================================#
# [** $RafiScripts.instr ] // Instruções / Instructions:                       #
#------------------------------------------------------------------------------#
# 1° Colar este script acima do Main,logo em seguida editar as Constantes no   #
# modulo Rafidelis::Title_X.                                                   #
# 2° Criar a Pasta 'Title' dentro da Pasta 'Graphics' onde deverão ser         #
# inseridos os Graficos do Titulo.                                             #
#==============================================================================#
# [** $RafiScripts.conf_start ] \\ Inicio das Configurações                    #
#------------------------------------------------------------------------------#

#==============================================================================#
#                         [** Module Rafidelis ]                               #
#[**Modulo necessario para rodar os Scripts criados por Rafidelis(RafiScripts)]#
#==============================================================================#
class Sprite_Particle < Sprite
    DS = [544, 416]
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Cache.parallax("lightball")
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
    self.blend_type = 1
    setup(rand(556...800))
       @sp = [0, 0]     # 初期座標
    @ma = [0.0, 0.0] # 移動角度(ラジアン)
    @rd = 0.0        # 初期座標からの半径
      @rd = rand(40).next.to_f
      @moveSpeed = rand(100).next * 0.01 + 1.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = 1
  end
  def setStartPosition(typeX, typeY)
    case typeX
    when 0 # ランダム
      @sp[0] = rand(DS[0] + 100) - 50
    when 1 # 画面外(左)
      @sp[0] = -30
    when 2 # 中央
      @sp[0] = DS[0] / 2
    when 3 # 画面外(右)
      @sp[0] = DS[0] + 30
    end
    case typeY
    when 0 # ランダム
      @sp[1] = rand(DS[1] + 50) - 25
    when 1 # 画面外(上)
      @sp[1] = -30
    when 2 # 中央
      @sp[1] = DS[1] / 2
    when 3 # 画面外(下)
      @sp[1] = DS[1] + 30
    end
    self.x = @sp[0]
    self.y = @sp[1]
  end
  def setMoveAngle(ax, ay = ax)
    @ma[0] = Math.cos(ax * 0.01)
    @ma[1] = Math.sin(ay * 0.01)
  end
  def getX
    @sp[0] + @rd * @ma[0]
  end
  def getY
    @sp[1] + @rd * @ma[1]
  end
  def getZoom
    (@rd * @ma[1] / DS[0] / 1.5 + 0.8) * (self.opacity / 255.0)
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  def setup(y = rand(416...486))
    self.x = rand(20...540)
    self.y = y
    n = rand(1...30)
    self.zoom_x = self.zoom_y = (n + 31) / 100.0
    self.opacity = n * 2 + 90
    @y = self.y << 10
    @vy = n * 14 + 256
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
     @nextAngle += [@moveSpeed, 2].min
      @nextAngle = 0.0 if @nextAngle >= 360
      setMoveAngle(@nextAngle * 1.74533)
      self.ox = getX-3
      @y -= @vy
      #@y += (@floteY -= @moveSpeed).round
      self.zoom_x = self.zoom_y = getZoom+0.3
      #self.opacity += 2
       self.opacity -= 1 if self.y < 100
    self.y = @y >> 10
    setup if self.y < 0
  end
end
module Reffect1
  DS = [594, 468]
  @@span = false
  def initialize(viewport1)
    @sp = [0, 0]     # 初期座標
    @ma = [0.0, 0.0] # 移動角度(ラジアン)
    @rd = 0.0        # 初期座標からの半径
    super(viewport1)
    self.blend_type = 1
    self.opacity=250
    @@span ^= true
  end
  def setGraphic(filename)
    self.bitmap = Cache.system(filename)
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
  def setStartPosition(typeX, typeY)
    case typeX
    when 0 # ランダム
      @sp[0] = rand(DS[0] + 100) - 50
    when 1 # 画面外(左)
      @sp[0] = -30
    when 2 # 中央
      @sp[0] = DS[0] / 2
    when 3 # 画面外(右)
      @sp[0] = DS[0] + 30
    end
    case typeY
    when 0 # ランダム
      @sp[1] = rand(DS[1] + 50) - 25
    when 1 # 画面外(上)
      @sp[1] = -30
    when 2 # 中央
      @sp[1] = DS[1] / 2
    when 3 # 画面外(下)
      @sp[1] = DS[1] + 30
    end
    self.x = @sp[0]
    self.y = @sp[1]
  end
  def setMoveAngle(ax, ay = ax)
    @ma[0] = Math.cos(ax * 0.01)
    @ma[1] = Math.sin(ay * 0.01)
  end
  def getX
    @sp[0] + @rd * @ma[0]
  end
  def getY
    @sp[1] + @rd * @ma[1]
  end
  def getZoom
    (@rd * @ma[1] / DS[0] / 1.5 + 0.5) * (self.opacity / 255.0)
  end
end
class Sprite_Particle1 < Sprite
  include Reffect1
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport1 = nil)
    super(viewport1)
     @rd = rand(120).next.to_f
      @moveSpeed = 3.5 - @rd / 60.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = 1
      setStartPosition(2, 3)
      setGraphic("lightball")
      @floteY = self.y.to_f
    end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  def setup
    @sp = [0, 0]     # 初期座標
    @ma = [0.0, 0.0] # 移動角度(ラジアン)
    @rd = 0.0        # 初期座標からの半径
    
      @moveSpeed = 0
      @nextAngle = 0
      @collapseSpeed = 0
      @floteY = 0
    self.x = 0
    self.y = 0
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
      if self.y <= -self.oy || self.opacity.zero?
      setup
      #dispose
      #$game_temp.r_effect_sprites.delete(self)
    else
      @nextAngle += [@moveSpeed, 1].min
      @nextAngle = 0.0 if @nextAngle >= 360
      setMoveAngle(@nextAngle * 1.74533)
      self.x = getX
      self.y = (@floteY -= @moveSpeed).round
      self.zoom_x = self.zoom_y = getZoom
      self.opacity -= @collapseSpeed-1
      end
  end
end

module Rafidelis
#==============================================================================#
# Rafidelis.add_script - Name : Name of Script - Version : Version of Script   #
#------------------------------------------------------------------------------#
  def self.add_script(name,version)
    $RafiScripts = [] if $RafiScripts.nil?
    $RafiScripts.push("Name : #{name} - Version: #{version}")
  end
#==============================================================================#
# Rafidelis.script_exist? - Name : Name of Script - Version : Version of Script#
#------------------------------------------------------------------------------#
  def self.script_exist?(name,version)
    $RafiScripts = [] if $RafiScripts.nil?
    return $RafiScripts.include?("Name : #{name} - Version: #{version}")
  end
#==============================================================================#
# Rafidelis.scripts - Return all script create by Rafidelis(RafiScripts)       #
#------------------------------------------------------------------------------#
  def self.scripts
    print $RafiScripts
  end
#==============================================================================#
# Rafidelis.create_txt - Create a .txt with all Rafidelis(RafiScripts) scripts #
#------------------------------------------------------------------------------#
  def self.create_txt(folder="")
    file = File.open("RafideliScripts.txt","wb")
    for i in 0...$RafiScripts.size
      file.write("#{$RafiScripts[i]}\r\n")
    end
  end
#==============================================================================#
# Rafidelis::Title_X - Modulo de Opções do Titulo                              #
#------------------------------------------------------------------------------#
  module Title_X
    # Adicionando o Script ao Sistema.Não Modifique.
    Rafidelis.add_script("Rafidelis Title X","2.0")
    # Script Adicionado
  #==============================================================================|
  # Abaixo o nome das Imagens que irão servir como "New Game" "Continue" e "Exit"|
  #=-----------------------------------------------------------------------------|
    COMMAND_PIC_NAMES = 
    ["NewGame",                      # Nome da Imagem usada como a opção novojogo
    "Continue",                      # Nome da Imagem usada como a opção continuar
    "ExitGame"]                      # Nome da Imagem usada como a opção Sair
    CURSOR_PIC_NAME = "op_selected"  # Nome da imagem usada como Cursor
    MOVE_TITLE_PIC = false           # true = mover false = não mover
    TITLE_PIC_HORIZONTAL_MOVIMENT_SPEED = 2   # Velocidade do movimento horizontal da img do titulo
    TITLE_PIC_VERTICAL_MOVIMENT_SPEED = 0     #  Velocidade do movimento vertical da img do titulo
  #==============================================================================|
  # Nome da Imagem com o nome do jogo,caso não queira usar deixe o nome em ""    |
  #------------------------------------------------------------------------------|
    NAME_GAME_PIC = "game_name" 
    NAME_GAME_PIC_POSY = 20      # Pos Y da imagem
  #=====================================|
  # Configurações :: Fog                |
  #-------------------------------------|
    TITLE_FOG_NAME = "fog"   # Nome da Fog usada no Title [ Deve estar na Pasta Picture]
    TITLE_FOG_BLEND_TYPE = 2 # Tipo do Blend da Fog do Title (0: normal, 1: adição, 2: subtração).
    TITLE_FOG_OPACITY = 25   # Opacidade Final da Fog ( 0 ~~ 255)
    FOG_HORIZONTAL_MOVIMENT_SPEED = 0     # velocidade do Movimento Horizontal da fog
    FOG_VERTICAL_MOVIMENT_SPEED = -1       # Velocidade do Movimento Vertical da Fog
  #=================================================|
  # Configurações :: Imagem de Luz :: Lights        |
  #-------------------------------------------------|
    LIGHT_PIC_NAME = "lights"                  #Nome da imagem de luz
    TITLE_LIGHT_PIC_BLEND_TYPE = 1             # """"""""""""""""""""""""""" no title
    LIGHT_PIC_OPACITY = 0                    # Opacidade final da imagem de luz
    LIGHT_PIC_HORIZONTAL_MOVIMENT_VELOCITY = 1 # Velocidade do Movimento Horizontal da Luz
    LIGHT_PIC_VERTICAL_MOVIMENT_VELOCITY = 1   # Velocidade do Movimento vertical da Luz
    LIGHT_PIC_TITLE_ZOOM_X = 1.5               # Zoom x da img de luz no Title
    LIGHT_PIC_TITLE_ZOOM_Y = 1.5               # Zoom y da img de luz no Title
    
    #NEW FOG
    TITLE_FOG2_NAME = "fog2"   # Nome da Fog usada no Title [ Deve estar na Pasta Picture]
    TITLE_FOG2_BLEND_TYPE = 0#0 # Tipo do Blend da Fog do Title (0: normal, 1: adição, 2: subtração).
    TITLE_FOG2_OPACITY = 115#75   # Opacidade Final da Fog ( 0 ~~ 255)
    FOG2_HORIZONTAL_MOVIMENT_SPEED = -2#-2     # velocidade do Movimento Horizontal da fog
    FOG2_VERTICAL_MOVIMENT_SPEED = 0       # Velocidade do Mo
    
    TITLE_FOG3_NAME = "fog3"   # Nome da Fog usada no Title [ Deve estar na Pasta Picture]
    TITLE_FOG3_BLEND_TYPE = 2 # Tipo do Blend da Fog do Title (0: normal, 1: adição, 2: subtração).
    TITLE_FOG3_OPACITY = 65#125   # Opacidade Final da Fog ( 0 ~~ 255)
    FOG3_HORIZONTAL_MOVIMENT_SPEED = 2     # velocidade do Movimento Horizontal da fog
    FOG3_VERTICAL_MOVIMENT_SPEED = 0       # Velocidade do Mo
    
    COMMAND_PLUS_Y = 30
    FADE_PER_FRAME = 20 #Cho Command hien thoi
    FADE_PER_FRAME2 = 20#20 #Cho Command se~ hien ra
    MOVE_LEFT_RIGHT = 1 #So' pixel moi~ lan left/right move
    MOVE_PER_FRAME = 5 #MOVE_LEFT_RIGHT per MOVE_PER_FRAME
    MOVE_UP_DOWN = 1
    MAX_MOVE_COMMAND = 2
    MAX_MOVE = 5
  end
end
#==============================================================================#
# [** $RafiScripts.conf_end ] \\ Fim das Configurações                         #
#------------------------------------------------------------------------------# 
# Verificando se o Script esta incluso no Sistema
if Rafidelis.script_exist?("Rafidelis Title X","2.0")
#==============================================================================
# Cache
#------------------------------------------------------------------------------
# Nesta classe vários gráficos são carregados e guardados como Bitmaps. Para 
# acelerar o processo e preservar a memória, os Bitmaps são guardados em cache
# para uso futuro. 
#==============================================================================
module Cache
  def self.title(filename)
    load_bitmap("Graphics/Title/", filename)
  end
end
#==============================================================================
# Scene_Title
#------------------------------------------------------------------------------
# Classe das operações na tela de título.
#==============================================================================
class Scene_Title < Scene_Base
  include Rafidelis::Title_X
  alias rafidelis_title_x_start start
  alias rafidelis_title_x_terminate terminate
  #--------------------------------------------------------------------------
  # Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    rafidelis_title_x_start
    @command_window.opacity = @command_window.contents_opacity = 0
    @sprite.opacity = 0
    create_images
    @c_flash = 0
    @flashcount = 0
    @com_count = 11
    #start_effect(1)##############################
  end
  #--------------------------------------------------------------------------
  # Criação das Imagens do Titulo
  #--------------------------------------------------------------------------
  def create_images
    @viewport = Viewport.new(-32, -32, 608, 480)
    @viewport.z = 90
    @particles = []
    for i in 0...7
      @particles.push(Sprite_Particle.new(@viewport))
    end
    for i in 0...20
      @particles.push(Sprite_Particle1.new(@viewport))
    end

    @sprites = []  # Imagens do Titulo
    images_name =  # Nome das Imagens
    [COMMAND_PIC_NAMES[0],COMMAND_PIC_NAMES[1],COMMAND_PIC_NAMES[2],
    CURSOR_PIC_NAME,NAME_GAME_PIC,TITLE_FOG_NAME,LIGHT_PIC_NAME,TITLE_FOG2_NAME,TITLE_FOG3_NAME]
    for i in 0...images_name.size
      if i <= 2  # Novo Jogo/Continuar/Sair
        @sprites[i] = Sprite.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].x = (Graphics.width - @sprites[i].width)/2
        @sprites[i].y = i * @sprites[i].height*0.7 + (Graphics.height - @sprites[i].height)/1.5 
        @sprites[i].opacity = 0
        @sprites[i].z = (@sprite.z + 10 * i)+1
        @sprites[i].tone = Tone.new(0,0,0,255)
        @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
      elsif i == 3 # Cursor
        @sprites[i] = Sprite.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].opacity = 0
        @sprites[i].x = (Graphics.width - @sprites[i].width)/2
        @sprites[i].y = @sprites[0].y
        @sprites[i].z = @sprites[0].z-1#20
      elsif i == 4 # Nome do Jogo
        @sprites[i] = Sprite.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].y = NAME_GAME_PIC_POSY 
        @sprites[i].opacity = 0
        #@sprites[i].wave_amp = 4
        @sprites[i].z = @sprite.z + 10 * i
      elsif i == 5 # Fog
        @sprites[i] = Plane.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].opacity = 5
        @sprites[i].blend_type = TITLE_FOG_BLEND_TYPE 
        @sprites[i].z = @sprite.z + 10 * i
      elsif i == 6 # Luz
        @sprites[i] = Plane.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].blend_type = TITLE_LIGHT_PIC_BLEND_TYPE
        @sprites[i].opacity = 0
        @sprites[i].zoom_y = LIGHT_PIC_TITLE_ZOOM_Y
        @sprites[i].zoom_x = LIGHT_PIC_TITLE_ZOOM_X
        @sprites[i].blend_type = TITLE_LIGHT_PIC_BLEND_TYPE
        @sprites[i].z = @sprites[4].z - 10
      elsif i == 7 # Fog
        @sprites[i] = Plane.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].opacity = 10
        @sprites[i].blend_type = TITLE_FOG2_BLEND_TYPE 
        @sprites[i].z = @sprite.z + 10 * i
      elsif i == 8 # Fog
        @sprites[i] = Plane.new
        @sprites[i].bitmap = Cache.title(images_name[i])
        @sprites[i].opacity = 10
        @sprites[i].blend_type = TITLE_FOG3_BLEND_TYPE 
        @sprites[i].z = @sprite.z + 10 * i
      end
    end
  end
  #--------------------------------------------------------------------------
  # Atualização Do Processo
  #--------------------------------------------------------------------------
  def update
    update_images_effects
    for sprite in @particles do sprite.update end
    @viewport.update
    if @sprites[2].opacity >= 150
     if @com_count <= 10
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 6
      @sprites[@command_window.index].y += 3 if @com_count == 3
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @com_count +=1
     end
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
      @command_window.update
      if Input.trigger?(Input::C)
        case @command_window.index
        when 0    # Novo Jogo
          command_new_game
        when 1    # Continuar
          command_continue
        when 2    # Sair
          command_shutdown
        end
      end
    end
      if Input.trigger?(Input::UP)
        case @command_window.index
        when 3    # Novo Jogo
          @command_window.index = 2
        end
      end
    if @command_window.index > 2
      @command_window.index =0
    end
    @sprites[@command_window.index].update
  end
  #--------------------------------------------------------------------------
  # Atualização dos efeitos da imagem de Luz
  #--------------------------------------------------------------------------
  def update_light
    @sprites[6].ox += LIGHT_PIC_HORIZONTAL_MOVIMENT_VELOCITY
    #@sprites[4].wave_amp = 4
    @sprites[6].oy += LIGHT_PIC_VERTICAL_MOVIMENT_VELOCITY
    @sprites[6].opacity += 2 if @sprites[6].opacity < LIGHT_PIC_OPACITY and @sprites[5].opacity >= TITLE_FOG_OPACITY
  end
  #--------------------------------------------------------------------------
  # Atualização dos efeitos da imagem de Fog
  #--------------------------------------------------------------------------
  def update_fog
    @sprites[5].opacity += 1 if @sprites[5].opacity < TITLE_FOG_OPACITY and @sprite.opacity >= 200
    @sprites[5].ox += FOG_HORIZONTAL_MOVIMENT_SPEED
    @sprites[5].oy += FOG_VERTICAL_MOVIMENT_SPEED
  end
  def update_fog2
    @sprites[7].opacity += 1 if @sprites[7].opacity < TITLE_FOG2_OPACITY and @sprite.opacity >= 200
    @sprites[7].ox += FOG2_HORIZONTAL_MOVIMENT_SPEED
    @sprites[7].oy += FOG2_VERTICAL_MOVIMENT_SPEED
  end
  def update_fog3
    @sprites[8].opacity += 1 if @sprites[8].opacity < TITLE_FOG3_OPACITY and @sprite.opacity >= 200
    @sprites[8].ox += FOG3_HORIZONTAL_MOVIMENT_SPEED
    @sprites[8].oy += FOG3_VERTICAL_MOVIMENT_SPEED
  end
  #--------------------------------------------------------------------------
  # Atualização dos efeitos das imagens de comandos
  #--------------------------------------------------------------------------
  def update_commands
    for i in 0..3
      @sprites[i].opacity += 2 if @sprites[i].opacity < 255 and @sprites[4].opacity >= 105
    end
    set_tone(@command_window.index)
  end
  #--------------------------------------------------------------------------
  # Atualização dos efeitos da imagem de Titulo(Fundo)
  #--------------------------------------------------------------------------
  def update_title_sprite
    @sprite.opacity += 2 if @sprite.opacity < 255
    @sprites[4].opacity += 1 if @sprites[4].opacity < 255 and @sprites[6].opacity >= LIGHT_PIC_OPACITY
    if MOVE_TITLE_PIC
      @sprite.ox += TITLE_PIC_HORIZONTAL_MOVIMENT_SPEED
      @sprite.oy += TITLE_PIC_VERTICAL_MOVIMENT_SPEED
    end
  end
  #--------------------------------------------------------------------------
  def update_cursor(index)
    if @c_flash == 0 ; @sprites[3].opacity -= 70 ; end
    if @c_flash == 0 ; @sprites[3].flash(Color.new(100,255,255),60) ; end
      @c_flash += 10
    if @c_flash >= 1220; @c_flash = 0; end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # Atualização dos efeitos das imagens do Titulo
  #--------------------------------------------------------------------------
  def update_images_effects
    update_fog
    update_light
    update_fog2
    update_fog3
    update_commands
    update_title_sprite
    update_cursor(@command_window.index)
  end
  #--------------------------------------------------------------------------
  # Atualizar tom das Imagens do Titulo
  #--------------------------------------------------------------------------
  def set_tone(index)
    for i in 0..2
      #@sprites[i].opacity -= 5 if @sprites[i].opacity > 155 
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].zoom_x -= 0.00 if @sprites[i].zoom_x > 1.0
      @sprites[i].zoom_y -= 0.05 if @sprites[i].zoom_y > 1.0
      #@sprites[i].wave_amp = 2
    end
    #@sprites[index].opacity += 10 if @sprites[index].opacity > 255
    @sprites[index].tone = Tone.new(0,0,0)
    @sprites[index].zoom_x += 0.00 if @sprites[index].zoom_x < 3#1.8
    @sprites[index].zoom_y += 0.05 if @sprites[index].zoom_y < 3#1.8

  #  @sprites[3].wave_amp = 5
    @sprites[3].y = @sprites[index].y
    #if @c_flash == 0; @sprites[@command_window.index].flash(Color.new(100,255,255),10); end
    #@c_flash += 2
    #if @c_flash >= 220; @c_flash = 0; end
  end
  #--------------------------------------
  #--------------------------------------

  #--------------------------------------------------------------------------
  # Finalização do Processo
  #--------------------------------------------------------------------------
  def terminate
    rafidelis_title_x_terminate
    dispose_command_pictures
  end
  #--------------------------------------------------------------------------
  # Finalização das Imagens do Titulo
  #--------------------------------------------------------------------------
  def dispose_command_pictures
    @viewport.dispose
    for i in 0...@sprites.size
      @sprites[i].bitmap.dispose
      @sprites[i].dispose
    end
  end
  #--------------------------------------------------------------------------
  # Criação do gráfico de título
  #--------------------------------------------------------------------------
  def create_title_graphic
    if MOVE_TITLE_PIC
        @sprite = Plane.new
        @sprite.bitmap = Cache.title("Title")
      else
        @sprite = Sprite.new
        @sprite.bitmap = Cache.title("Title")
      end
    end
  end
 # Finalização da Verificação do Script no sistema
end