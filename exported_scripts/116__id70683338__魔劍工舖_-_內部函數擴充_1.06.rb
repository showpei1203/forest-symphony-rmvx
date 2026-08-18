#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：魔劍工舖 - 內部函數擴充 1.06
# 【用途】保留的 Runtime 元件「魔劍工舖 - 內部函數擴充 1.06」。
# 【主要機制】主要定義／擴充 Array、Numeric、NilClass、String；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Array、Numeric、NilClass、String、Sword、Kernel
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
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
module Sword
#=======================================
#★ 魔劍工舖 - 內部函數擴充 1.06
# http://blog.yam.com/a870053jjkj/
#=======================================
  $Sword ? $Sword[5] = true : $Sword = {5=>true} # 腳本使用標誌
  $Sword_F12_Error = {5=>false} unless $Sword_F12_Error # F12除錯標誌
end
#=======================================
#□ 該模塊中定義了可供所有類使用的方法
module Kernel
  Regexps = %w(^ $ . * + - ? [ ] \w \W \s \S \d \D \b \B \A \Z \z \G ( ) { } , |) # 正則符號表
  #-------------------------------------------------------------
  #● 隨機數
  alias swordSYS_rand rand unless $Sword_F12_Error[5]
  def rand(max = false)
    case max
    when TrueClass, FalseClass ; swordSYS_rand(2) == 0 ? true : false # 真, 偽
    when Range ; rand(max.to_a) # 範圍
    when Array ; max[swordSYS_rand(max.size)] # 數組
    when Hash ; a = max.keys[swordSYS_rand(max.size)] ; [a, max[a]] # 哈希表
    when String ; max.scan(/./)[swordSYS_rand(max.scan(/./).size)] # 字符串
    else ; swordSYS_rand(max) # 其他(數值, 空)
    end
  end
end
#=======================================
#■ 數組類
class Array
  #-------------------------------------------------------------
  #● 單元值範圍轉換
  def range
    a, e = [], -1 # 結果數組, 索引
    self.each do |i|
      e += 1
      if i.is_a?(Range)
        b = i.begin and c = i.end
        i.exclude_end? ? d = 0 : d = 1
        a += Array.new(c - b + d){|f|f + b}
        next
      end
      a += [i]
    end
    a
  end
end
#=======================================
#■ 數字的抽像類
class Numeric
  #-------------------------------------------------------------
  #● 負數
  def minus ; return self if self < 0 ; self - self * 2 ; end
  #-------------------------------------------------------------
  #● 百分比
  def per(per = 100, of = 1) ; self / per.to_f * of ; end
  #-------------------------------------------------------------
  #● 總位數
  def digit(digit = 0)
    digit > 0 ? self.digit_a[-digit] : self.digit_a.size
  end
  #-------------------------------------------------------------
  #● 分解位數數組
  def digit_a ; a = [] ; self.to_s.scan(/\d/).each{|i| a += [i.to_i]} ; a ; end
end
#=======================================
#■ nil 的類
class NilClass
  #-------------------------------------------------------------
  #● 空哈希表
  def to_h ; {} ; end
  #-------------------------------------------------------------
  #● 空正則表達式
  def to_reg ; // ; end
end
#=======================================
#■ 字符串類
class String
  #-------------------------------------------------------------
  #● 轉換為正則表達式
  def to_reg
    text = dup ; Regexps.each {|i| text.gsub!(/#{"\\" + i}/){"\\#{i}"}} ; /#{text}/
  end
end
#=======================================
#□ 處理遊戲手柄和鍵盤輸入信息的模塊
class << Input
  #-------------------------------------------------------------
  #● 更新輸入訊息
  alias sword5_update update unless $Sword_F12_Error[5]
  def update
    (@simv > 0 ? @simv -= 1 : @simulate = nil) if @simv ; sword5_update
  end
  #-------------------------------------------------------------
  #● 按住的場合
  alias sword5_press? press? unless $Sword_F12_Error[5]
  def press?(num) ; return true if @simulate == num ; sword5_press?(num) ; end
  #-------------------------------------------------------------
  #● 按下的場合
  alias sword5_trigger? trigger? unless $Sword_F12_Error[5]
  def trigger?(num) ; return true if @simulate == num ; sword5_trigger?(num) ; end
  #-------------------------------------------------------------
  #● 連續按住的場合
  alias sword5_repeat? repeat? unless $Sword_F12_Error[5]
  def repeat?(num) ; return true if @simulate == num ; sword5_repeat?(num) ; end
  #-------------------------------------------------------------
  #● 模擬按下按鍵
  def simulate(num, v = 0) ; @simulate = num ; @simv = v ; end
end
$Sword_F12_Error[5] = true # 開啟F12除錯標誌