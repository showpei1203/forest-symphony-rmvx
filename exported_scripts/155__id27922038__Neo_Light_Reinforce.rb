#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Neo Light Reinforce
# 【用途】地圖／事件元件「Neo Light Reinforce」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Event
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
# * [RMVX] Neo Light Reinforce
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
# 1) Place this script after "Khas Script Core" and after "Neo Light Effects"
#
# * PORTUGUES
# 1) Este script tem que ser colocado depois do "Khas Script Core" e depois
# do Neo Light Effects 1.3
#
#-------------------------------------------------------------------------------
# How to use | Como usar
#-------------------------------------------------------------------------------
# * ENGLISH
# Put the "Follow Player" comment on an event with a light effect.
#
# * PORTUGUES
# Coloque o comentario "Follow Player" (sem aspas) em algum evento com efeito
# de luz que você queira que siga o jogador. Assim a imagem irá girar 
# automaticamente na direção do player, podendo assim criar chars com 
# lanternas!
#
#-------------------------------------------------------------------------------

if $enabled_core.nil?
  p "The script 'Neo Light Effects' requires Khas Script Core 1.0 or better"
  p "Please install Khas Script Core 1.0 or better"
  exit
elsif $enabled_core < 1
  p "The script 'Neo Light Effects' requires Khas Script Core 1.0 or better"
  p "Please install Khas Script Core 1.0"
  exit
else
  Core.register("Neo Light Reinforce",1.0)
end

class Game_Event < Game_Character
  alias nlr_initialize initialize
  alias nlr_update_light update_light
  def initialize(map_id, event)
    nlr_initialize(map_id, event)
    @follow_light = false
    for key in 0...@list.size
      next unless @list[key].code == 108
      next if @follow_light
      @follow_light = (@list[key].parameters == ["Follow Player"])
    end
  end
  def update_light
    @follow_light ? update_lr : nlr_update_light
  end
  def update_lr
    @nl_sprite.visible = !$game_switches[Neo_Light_Switch]
    @nl_sprite.x = self.screen_x
    @nl_sprite.y = self.screen_y - 16
    @nl_sprite.opacity = Effects[@nl_effect].opacity + rand(Effects[@nl_effect].opacity_oscillation)
    @nl_sprite.angle = 57.3 * Math.atan2(self.screen_x-$game_player.screen_x,self.screen_y-$game_player.screen_y)
    @nl_sprite.bitmap.hue_change(Effects[@nl_effect].hue_oscillation) unless !Effects[@nl_effect].hue_oscillation
  end
end
