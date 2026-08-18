#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：魔劍工舖 - 書籍閱讀 1.04
# 【用途】保留的 Runtime 元件「魔劍工舖 - 書籍閱讀 1.04」。
# 【主要機制】主要定義／擴充 Game_Party、WSword_Library、WSword_LibraryPagination、Sword_Library；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Party、WSword_Library、WSword_LibraryPagination、Sword_Library、Sword
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
#★ 魔劍工舖 - 書籍閱讀 1.04
# http://blog.yam.com/a870053jjkj/
#=======================================
  ON, OFF, Sword16_Library = true, false, []
=begin
========================================
● 所需腳本
控制碼轉換：http://blog.yam.com/a870053jjkj/article/28082241（非必要）
========================================
● 控制碼（支援「控制碼轉換」中的控制碼）
 \C[顏色代碼] ： 同事件 [顯示文章] 的「\C」控制碼相同，變更設定好的顏色
 \C[紅,綠,藍] ： 自訂3原色，依照3原色來設置選項內容
 \IC[圖片檔案名稱] ： 顯示Icons資料夾中指定的圖片，VX為System資料夾
 \V[變數編號] ： 顯示指定編號的編號
 \N[角色編號] ： 顯示指定編號的角色名稱
 \B ： 文字加粗，在使用一次會恢復原狀
========================================
● 設置方法
呼叫書庫畫面：$scene = Sword_Library.new
開通書本全頁：$game_party.librarys(書本編號, true)
開通書本單頁：$game_party.librarys(書本編號, 頁數)
關閉書本全頁：$game_party.librarys(書本編號, false)
關閉書本單頁：$game_party.librarys(書本編號, -頁數)
開通關閉互換：$game_party.librarys(書本編號, nil)
========================================
=end
#=======================================
#● 使用者自定設置
Sword16_Width = 160 # 設定左邊選項窗口的寬度，相對的右邊內容窗口也會受影響
Sword16_Help = ['', 1] # 上方幫助窗口的 ['內容', 位置]，位置：0左；1中；2右
Sword16_Order = OFF # 書本的排列是否要照著自定設置的順序排列
Sword16_SE = ['Book', 100, 60] # 設定翻頁時的 ['SE檔案名稱', 音量, 節拍]
Sword16_Arrowhead = ['←', '→'] # 設定箭頭圖片檔案名稱，如沒該檔案就顯示該內容
Sword16_Pagination = 2 # 顯示目前頁數，0為不顯示；1為顯示；2為顯示(含一頁)
Sword16_SignX = 5 # 設定換頁符號的X座標離距離窗口邊緣多遠
Sword16_SignY = 358 # 設定換頁符號的出現的Y座標位置(以書本內容窗口為原點)
#--------------------------------------------------------------
Sword16_Library[1] = ['換頁範例']
Sword16_Library[1][1] = '★設置開始★
歡迎使用\v[2]書庫功能。
（上下鍵可切換書本）
\c[6]按鍵盤方向鍵→可以切換到下一頁
' # ☆設置結束☆
  
Sword16_Library[1][2] = '★設置開始★
目前你正在觀看第二頁的內容
\c[4]按鍵盤方向鍵←可以切換到上一頁
\c[6]按鍵盤方向鍵→可以切換到下一頁
' # ☆設置結束☆
 
Sword16_Library[1][3] = '★設置開始★
目前你正在觀看第三頁的內容
\c[4]按鍵盤方向鍵←可以切換到上一頁
' # ☆設置結束☆
#--------------------------------------------------------------
Sword16_Library[2] = ['\c[10]戰鬥說明書']
Sword16_Library[2][1] = '★設置開始★

      \IC[BT04]







本書將說明如何戰鬥，希望對您有幫助。
（接續下頁）
' # ☆設置結束☆
 
Sword16_Library[2][2] = '★設置開始★



             \IC[BT02]            \IC[BT01]


戰鬥開始時，會看到敵我雙方各有一個行動條。
行動條會隨時間漸漸集滿，集滿時人物即可行動。
（接續下頁）
' # ☆設置結束☆以上是全頁範圍

Sword16_Library[2][3] = '★設置開始★



          \IC[BT01]            \IC[BT03]


行動條集滿後，人物會往前踏一步，
並有浮標指示該人物目前可以行動。
（接續下頁）
' # ☆設置結束☆

Sword16_Library[2][4] = '★設置開始★


                         \IC[BT05]


                         
此時，畫面右下角會出現戰鬥轉盤。
選項分別為：攻擊、技能、防禦、物品、逃跑。
玩家必須根據戰鬥的狀況下達不同的指令。
（接續下頁）
' # ☆設置結束☆

Sword16_Library[2][5] = '★設置開始★
                         \IC[BT06]


                         
                         
                         
畫面下方會出現玩家的狀態。
HP：歸零時則該角色死亡
MP：使用技能皆會消耗MP。
怒氣：累積足夠的怒氣值將能釋放憤怒技能。
（接續下頁）
' # ☆設置結束☆

Sword16_Library[2][6] = '★設置開始★

      \IC[BT04]







以上為本書內容，希望對您會有幫助。
' # ☆設置結束☆


#--------------------------------------------------------------
Sword16_Library[10] = ['淨土的傳說']
Sword16_Library[10][1] = '★設置開始★

   \IC[PAINT1]


   

傳說裡，這世界原本是一片混沌，
我們所景仰的主神利用龐大的能量逆轉了它，
在上古時期創造了第一個擁有秩序的層界。
這就是第一個階段，
被命名為「混沌」的初始紀元。
' # ☆設置結束☆

Sword16_Library[10][2] = '★設置開始★

   \IC[PAINT2]



   
之後，主神加入了使世界賴以運轉的元素，
時間、日月、金木水火土等五行運轉，
但主神也在這段過程中耗盡了神力。
自此，淨土的雛形已成，開始了各自的成長。
' # ☆設置結束☆

Sword16_Library[10][3] = '★設置開始★

   \IC[PAINT2]



   
日月與五行在創世的過程中成為了七位神，
彼此維持著平衡狀態，支撐著淨土茁壯，
就這樣經過了三個紀元。
' # ☆設置結束☆

Sword16_Library[10][4] = '★設置開始★

   \IC[PAINT3]



   
終於，生命的始祖出現在淨土上。
在第四個紀元時，
傳說中的生命體「精靈」也出現了。
' # ☆設置結束☆

Sword16_Library[10][5] = '★設置開始★

   \IC[PAINT3]



精靈，多麼不可思議的種族。
同時擁有強大法力與高度智慧，
兼具了創造力與群居的協調性。

他們似乎能感受到七神的存在，
因此有人說他們就是主神的孩子。
' # ☆設置結束☆

Sword16_Library[10][6] = '★設置開始★

   \IC[PAINT3]



為了精靈該不該存在，七神有過一番爭執。
據說，由於日神與月神的堅持，
所以他們被允許生存至今。
在那之後，
精靈們便遵循著規則律法「自然」而行動，
取得了七神的認可。
' # ☆設置結束☆

Sword16_Library[10][7] = '★設置開始★

   \IC[PAINT4]



   
而現在，淨土正邁入第五個紀元。
改變自然、四處開墾，世界因人類改變。

淨土的未來漸漸變得無法預知了……
（全書完）
' # ☆設置結束☆

#--------------------------------------------------------------
Sword16_Library[12] = ['通知信']
Sword16_Library[12][1] = '★設置開始★

此致   魯卡村長

阿爾泰斯特領主有言：
領主千金「艾薇」小姐，近日將前往貴村。
還請  撥冗接待。

萬分感謝
阿爾泰斯特 行文

後註：不須為小姐的安全擔心，有人看著即可。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[13] = ['村長日誌殘頁']
Sword16_Library[13][1] = '★設置開始★

拓荒隊來到此地，大大促進了魯卡村的經濟。
尤其是木材的需求大增，而這是可以理解的。
因為幾乎所有的建設都會需要用到木材...

同樣的木材，在魯卡村和拓荒營地售價不同，
只要夠勤勞，這絕對是一個賺錢的方法。
只要人力充足，錢不是問題。

但話說回來，可惜魯卡村沒有礦產，
否則...

' # ☆設置結束☆
#--------------------------------------------------------------


#--------------------------------------------------------------
Sword16_Library[14] = ['尚諾的筆記']
Sword16_Library[14][1] = '★設置開始★

艾卓隊長說，戰鬥，並不只在於攻擊。
防禦也是同等的重要。

良好的防禦，可以減少傷害、回復HP，
更重要的是可以等待更好的進攻時機。

艾卓隊長有一項另兄弟們望塵莫及的技能，
當他進入某個狀態時，居然能抵擋所有物理攻擊。

弟兄們稱這時候的他為：格擋大師。

希望有朝一日我也能到達這個境界。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[15] = ['伍德的字條(1)']#喬伊家
Sword16_Library[15][1] = '★設置開始★

喬伊，爸爸要出發了。

記得我一直告訴你的，我們是偉大的德魯伊一族。
雖然現在人們漸漸遺忘了德魯伊，
但是我們絕不能忘記自己的使命。

你是個有德魯伊天份的孩子，我們一定會再相見的。

願熊吼能為你帶來勇氣。
願狼嘯能為你指引道路。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[16] = ['伍德的字條(2)']#村長家
Sword16_Library[16][1] = '★設置開始★

村長，感謝您多年前接納了我和喬伊。

喬伊這孩子也順利長大了，
相信不久後他就可以自立，甚至能幫上村子不少事。

和您提到的計畫，時機已經成熟。
您一直提到開發魯卡村周邊的事，我會放在心上。

近日就會出發。
再次，謝謝您。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[17] = ['伍德的字條(3)']
Sword16_Library[17][1] = '★設置開始★

看來我和喬伊並不是唯一倖存的德魯伊...
必須去那個組織一趟。

目前知道的訊息，還無法證實她也是德魯伊。
但我思索再三，實在無法理解...
怎麼會忽略她的存在？

偉大的督伊德啊，我祈求您的庇佑，
請庇佑德魯伊一族能永續留存在史冊中。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[18] = ['伍德的字條(4)']
Sword16_Library[18][1] = '★設置開始★

...我實在太弱小了。
這樣一來，什麼事情都辦不到...

難道，德魯伊一族的血脈在我身上如此淡薄嗎？
不僅召喚不出強大的魔物，甚至...
一定要找到方法變強大。

或許，可以借助精靈魔法的力量...？
另外，據說大陸各地有能量源的存在...

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[19] = ['伍德的字條(5)']
Sword16_Library[19][1] = '★設置開始★

根據調查報告，哈貝爾的能量源確實很強大，
非常接近我的理想

但是，實際到這邊，才發現，
這個能量源根本無法被利用。

除非...
除非做好滅村的準備...

' # ☆設置結束☆
#--------------------------------------------------------------


#--------------------------------------------------------------
Sword16_Library[40] = ['哈貝爾調查紀錄']
Sword16_Library[40][1] = '★設置開始★

-金曜日-
第一組斥候出發，預計當日晚上回報。
後記：
當日未回，已回報隊長。

' # ☆設置結束☆
Sword16_Library[40][2] = '★設置開始★

-木曜日-
第二組斥候出發，縮小探索範圍。
後記：
第一、二組共6人未回，已回報隊長。


' # ☆設置結束☆

Sword16_Library[40][3] = '★設置開始★

-水曜日-
隊長下令：禁止一般衛兵進行搜索
隊長前往探索，當日晚間回營。
後記：
第一、二組共6人依然未回。
隊長指示：
往後探索，解毒劑等物品務須充足。


' # ☆設置結束☆
#--------------------------------------------------------------


#--------------------------------------------------------------
Sword16_Library[41] = ['給艾卓的手信']
Sword16_Library[41][1] = '★設置開始★

小卓卓：
聽說那個組織也派人過去囉！
雖然你武技一流，但對方很擅長魔法...

沒我在，千萬不能大意哦！

小娜娜


' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[42] = ['物資損毀報告']
Sword16_Library[42][1] = '★設置開始★

肇因：艾薇小姐

損毀物資：

桌子X2
椅子X5
藥水瓶X18
...諸多不及備載。


' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[43] = ['人員傷病紀錄']
Sword16_Library[43][1] = '★設置開始★

肇因：艾薇小姐

人員名單：

骨折：2員
重大創傷：3員
心理治療：8員

艾卓隊長指示不必追究。


' # ☆設置結束☆
#--------------------------------------------------------------
#--------------------------------------------------------------
Sword16_Library[44] = ['酒吧告示']
Sword16_Library[44][1] = '★設置開始★

1.請勿因未中獎而搖晃、毆打遊戲機台

2.請勿親自爬上擂台參加格鬥賽

3.請勿私自鑄造遊戲代幣

違反者會實施酒吧禁令


' # ☆設置結束☆
#--------------------------------------------------------------
#=======================================
#--------------------------------------------------------------
Sword16_Library[45] = ['拉吉爾備忘錄']
Sword16_Library[45][1] = '★設置開始★

礦材斷貨，需再採購

拓展客源

柔伊、泰勒商品採購

人族、半精靈產品質佳


' # ☆設置結束☆
#--------------------------------------------------------------
#=======================================
#--------------------------------------------------------------
#=======================================
#--------------------------------------------------------------
Sword16_Library[46] = ['洛馬爾的手稿']
Sword16_Library[46][1] = '★設置開始★

TX-000 基本型
TX-001 攻擊型
TX-002 防禦型
TX-003 雙爪型
TX-004 液態型
TX-S...

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[47] = ['矮人族的信仰']
Sword16_Library[47][1] = '★設置開始★

傳說中，矮人族是女武神的後裔，
她最著名的特點，
就是只使用自己鍛造的武器。

這個傳統也很好地被矮人保留了下來。
大陸各地的矮人，不論是否與他族交流，
對於自己打造的裝備、武器，
總是抱有特殊的情感，不輕易出售。

' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[48] = ['洛馬爾的報告']
Sword16_Library[48][1] = '★設置開始★

-戰曆331 秋 火曜日 土時-

伊瓦地：

木時，柵欄機關 被破解
水時，巨鎚機關 被破解
木時，齒輪機關 被破解

外來者：人類三名
(白髮男、金髮女、金髮男)


' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[49] = ['納吉司觀察報告']
Sword16_Library[49][1] = '★設置開始★

矮人族：無魔法天賦、體格強健、恢復力佳

精靈族：魔法天賦佳、行動敏捷、預知能力

地精族：各項能力介於矮人與精靈之間

人族：個體差異極大，尚難歸類


' # ☆設置結束☆
#--------------------------------------------------------------

#--------------------------------------------------------------
Sword16_Library[50] = ['柔伊日記殘頁']
Sword16_Library[50][1] = '★設置開始★

泰勒...你究竟在想什麼呢？

我始終無法理解，
在你冷靜的外表下，
為什麼藏有那麼深、那麼強烈的情緒。

他們對你的傷害，讓我撫平，好嗎...

' # ☆設置結束☆
#--------------------------------------------------------------
#=======================================


  $Sword ? $Sword[16] = true : $Sword = {16=>true} # 腳本使用標誌
  ($Sword_VX = false ; RPG::Weather rescue $Sword_VX = true) if $Sword_VX == nil
  Sword16_SE[0] = 'Audio/SE/' + Sword16_SE[0]
end
#=======================================
#■ 處理同伴的類別
class Game_Party
  include Sword # 連接自定設置
  attr_reader    :library_order # 書本排列順序
  attr_reader    :pages # 書本頁數收錄列表
  attr_accessor :library # 書本收錄標誌數組
  #-------------------------------------------------------------
  #● 初始化物件
  alias sword16_initialize initialize
  def initialize
    sword16_initialize
    @library_order, @pages = [], {}
    @library = Array.new(Sword16_Library.size - 1){|i| @pages[i] = [] ; false}
  end
  #-------------------------------------------------------------
  #● 添加與移除書本的(書本編號, 標誌或書籍編號)
  def librarys(id, add)
    (pag = add ; add = true) if add.is_a?(Integer) # 如果指定數值就變換變量
    @library[id] = add == nil ? (not @library[id]) : add # 變更書本獲得狀態
    if @library[id] ; @library_order += [id] unless @library_order.include?(id) # 加入順序
      unless pag ; @pages[id] = Array.new(Sword16_Library[id].size - 1){|i| i + 1} # 全頁
      else ; @pages[id] += [pag] unless @pages[id].include?(pag) if pag > 0 # 添加頁數
        @pages[id] -= [pag.abs] if pag < 0 # 移除頁數
      end
    else ; @library_order -= [id] ; @pages[id] = [] # 移除順序並清除書本的頁數
    end
    @pages[id] = @pages[id].sort # 頁數順序修正
    @library[id] = false if @pages[id].empty? # 書本無任何一頁就移除書本
  end
end
#=======================================
#■ 書庫窗口
class WSword_Library < Window_Base
  include Sword # 連接自定設置
  #-------------------------------------------------------------
  #● 初始化物件(書本編號)
  def initialize(library_id)
    @xpvx = $Sword_VX ? [Graphics.width, Graphics.height, 54] : [640, 480, 64]
    @xpvx[2] = 0 if Sword16_Help[0].empty? # 如果沒幫助窗口就不依照幫助窗口高度
    super(Sword16_Width, @xpvx[2], @xpvx[0] - Sword16_Width, @xpvx[1] - @xpvx[2])
    self.contents = Bitmap.new(width - 32, height - 32)
    (1..$game_party.library.size).each do |i| # 顯示第1個要顯示的內容
      (refresh(library_id, $game_party.pages[library_id][0]) ; return) if $game_party.library[i]
    end
  end
  #-------------------------------------------------------------
  #● 更新內容(書本編號, 頁數)
  def refresh(library_id, pagination)
    self.contents.clear ; return if pagination == 0 # 清除，如果無頁數就中斷
    self.contents.font.color = normal_color ; self.contents.font.bold = true
    self.contents.font.size = 17
    ignore_row = true # 忽略第一行的標誌（清除「★設置開始★」）
    text = Sword16_Library[library_id][pagination] ; x = 4 ; y = 0
    text = text.gsub(/\\[Ii][Cc]\[([\w_\-]+)\]/){"\001[#{$1}]"}
    text = text.gsub(/\\[Cc]\[(\d+)[ \,]+(\d+)[ \,]+(\d+)\]/){"\002[#{$1},#{$2},#{$3}]"}
    text = text.gsub(/\\[Cc]\[(\d+)\]/){"\003[#{$1}]"}
    text = text.gsub(/\\[Bb]/){"\004"}
    text = text.gsub(/\\[Vv]\[(\d+)\]/){$game_variables[$1.to_i]}
    text = text.gsub(/\\[Nn]\[(\d+)\]/){$game_actors[$1.to_i].name}
    text = text.code_explain if $Sword[46] # 控制碼轉換
    while ((c = text.slice!(/./m)) != nil)
      case c
      when "\n" ; if ignore_row ; ignore_row = false ; else ; x = 4 ; y += 32 ; next ; end # 換行
      when "\001"
        text.sub!(/\[([\w_\-]+)\]/, '')
        icon = $Sword_VX ? Cache.system($1) : RPG::Cache.icon($1)
        self.contents.blt(x, y, icon, Rect.new(0, 0, 640, 480))
        x += icon.width # 代入圖片寬度
        next
      when "\002" ; text.sub!(/\[(\d+)\,(\d+)\,(\d+)\]/, '')
        self.contents.font.color = Color.new($1.to_i, $2.to_i, $3.to_i) ; next
      when "\003" ; text.sub!(/\[(\d+)\]/, '') ; self.contents.font.color = text_color($1.to_i) ; next
      when "\004" ; self.contents.font.bold = (not self.contents.font.bold) ; next
      end
      next if (ignore_row or c == "\n")
      self.contents.draw_text(x, y, 640 - 36 - Sword16_Width, 32, c)
      x += contents.text_size(c).width # 代入內容寬度
    end
  end
end
#=======================================
#■ 書庫頁數窗口
class WSword_LibraryPagination < Window_Base
  include Sword # 連接自定設置
  #-------------------------------------------------------------
  #● 初始化物件
  def initialize(library)
    @xpvx = $Sword_VX ? [Graphics.width, Graphics.height, 54] : [640, 480, 64]
    @xpvx[2] = 0 if Sword16_Help[0].empty? # 如果沒幫助窗口就不依照幫助窗口高度
    super(Sword16_Width - 16, @xpvx[2] + Sword16_SignY, 
    @xpvx[0] - Sword16_Width + 32, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0 ; self.z = 5100
    $game_party.pages[library].size == 1 ? refresh(0) : refresh(2) if library
  end
  #-------------------------------------------------------------
  #● 更新內容
  def refresh(dir)
    self.contents.clear
    self.contents.font.color = normal_color ; self.contents.font.bold = true
    a = Sword16_Arrowhead
    cache = [RPG::Cache.icon(a[0])] rescue cache = [] # 偵測左鍵頭圖片
    cache += [RPG::Cache.icon(a[1])] rescue 0 # 偵測右鍵頭圖片
    if dir == 1 or dir == 3 ; if cache[0] # 上一頁符號的處理
      self.contents.blt(0 + Sword16_SignX, 0, cache[0], Rect.new(0, 0, 100, 100))
    else ; self.contents.draw_text(0 + Sword16_SignX, 0, 32, 32, a[0])
    end ; end
    if dir == 2 or dir == 3 ; if cache[1] # 下一頁符號的處理
      self.contents.blt(self.width - cache[1].width - 
      Sword16_SignX - 32, 0, cache[1], Rect.new(0, 0, 100, 100))
    else ; self.contents.draw_text(0, 0, self.width - 32 - Sword16_SignX, 32, a[1], 2)
    end ; end
    self.contents.draw_text(0, 0, self.width - 32, 32, $scene.pagination.to_s, 1) if (
    Sword16_Pagination == 2 or (Sword16_Pagination == 1 and dir > 0)) # 目前頁數
  end
end
#=======================================
#■ 書庫畫面
class Sword_Library
  include Sword # 連接自定設置
  attr_reader    :pagination # 觀看的頁數
  #-------------------------------------------------------------
  #● 主處理
  def main
    # 產生窗口
    @library = [[], []] # 定義選項
    (Sword16_Order ? 1..$game_party.library.size : $game_party.library_order).each do |i|
      (@library[0].push(Sword16_Library[i][0]); @library[1].push(i)) if 
      $game_party.library[i] rescue next
    end
    @library[0] = [''] if @library[0].empty? # 如果沒符合的選項時，就空白
    @command_window = Window_Command.new(Sword16_Width, @library[0])#選項窗口
    @command_window.y = $Sword_VX ? 54 : 64 unless Sword16_Help[0].empty?
    @command_window.height = ($Sword_VX ? 416 : 480) - @command_window.y
    @library_wsword = WSword_Library.new(@library[1][0]) # 產生書庫窗口
    @pagination = $game_party.pages[library_id][0] if $game_party.pages[library_id] # 起始
    @librarypagi_wsword = WSword_LibraryPagination.new(@library[1][0]) # 頁數窗口
    unless Sword16_Help[0].empty? # 有設置窗口內容時
      @help_window = Window_Help.new  # 產生幫助窗口
      @help_window.set_text(Sword16_Help[0], Sword16_Help[1]) # 設置窗口內容
    end
    #○ 主循環
    Graphics.transition
    loop {Graphics.update ; Input.update ; update ; break if $scene != self} # 更新
    Graphics.freeze
    #○ 釋放窗口
    @command_window.dispose
    @library_wsword.dispose
    @librarypagi_wsword.dispose
    @help_window.dispose unless Sword16_Help[0].empty?
  end
  #-------------------------------------------------------------
  #● 更新畫面
  def update
    @command_window.update
    #○ 按鍵判斷
    p $game_party.pages[library_id] if Input.trigger?(Input::A)
    if Input.trigger?(Input::B)
      $Sword_VX ? Sound.play_cancel : $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new # 返回地圖
    elsif Input.repeat?(Input::UP) or Input.trigger?(Input::DOWN)
      return if (not library_id) or @library[0].size <= 1 # 非指定編號或只有一頁就中斷
      @pagination = $game_party.pages[library_id][0] # 變更為一開始的一頁
      @library_wsword.refresh(library_id, @pagination)
      $game_party.pages[library_id].size == 1 ?
      @librarypagi_wsword.refresh(0) : @librarypagi_wsword.refresh(2)
    elsif Input.repeat?(Input::LEFT) # 上一頁
      return unless library_id # 如果非指定編號就中斷
      if $game_party.pages[library_id].index(@pagination) != 0
        @pagination = $game_party.pages[library_id][
        $game_party.pages[library_id].index(@pagination) - 1]
        Audio.se_play(Sword16_SE[0], Sword16_SE[1], Sword16_SE[2]) rescue 0
        @library_wsword.refresh(library_id, @pagination)
        @pagination == $game_party.pages[library_id][0] ? 
        @librarypagi_wsword.refresh(2) : @librarypagi_wsword.refresh(3)
      end
    elsif Input.trigger?(Input::RIGHT) # 下一頁
      return unless library_id # 如果非指定編號就中斷
      if $game_party.pages[library_id].index(@pagination) != 
      $game_party.pages[library_id].size - 1
        @pagination = $game_party.pages[library_id][
        $game_party.pages[library_id].index(@pagination) + 1]
        Audio.se_play(Sword16_SE[0], Sword16_SE[1], Sword16_SE[2]) rescue 0
        @library_wsword.refresh(library_id, @pagination)
        @pagination == $game_party.pages[library_id][-1] ? 
        @librarypagi_wsword.refresh(1) : @librarypagi_wsword.refresh(3)
      end
    end
  end
  #-------------------------------------------------------------
  #● 獲取選項目前指著的書籍編號
  def library_id ; @library[1][@command_window.index] ; end
end