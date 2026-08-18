#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：播放连续图片
# 【用途】保留的 Runtime 元件「播放连续图片」。
# 【主要機制】主要定義／擴充 Game_Interpreter；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter
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
#==============================================================================
# ■ 播放连续图片
#  作者：影月千秋
#  版本：V 1.0
#  适用：VX
#------------------------------------------------------------------------------
# ● 简介
#  可以按顺序播放一连串图片 形成动画效果
#  XP版作者：天地有正气
#  详见发布帖：[url]http://rpg.blue/thread-351129-1-1.html[/url]
#==============================================================================
# ● 使用方法
#   将此脚本插入到其他脚本以下，Main以上
#   在Graphics下新建文件夹，名为MoviePics
#   假设你需要一个动画 名为"ani" 那么在MoviePics下再新建一个文件夹 名为ani
#    把图片碎片保存在Graphics/MoviePics/ani下
#    将图片碎片命名，形如【"(1).png"，"(2).png"，……】不需要加上"ani"
#   事件脚本调用：
#    picmovie(文件夹名, 横坐标, 纵坐标, 图片张数, 每张图片停留的帧数, 显示端口)
#   每张图片停留的帧数可以省略 默认为一帧  显示端口也可以省略
#   在这个例子中 也就是：
#    picmovie("ani", 100, 150, 20, 3)
#   代表总共有20张图片 显示在(100,150)这个地方 图片在ani文件夹内 每张停留3帧
#   也可以使用
#    picmovie2(文件夹名, 事件ID, 图片张数, 每张图片停留的帧数, 显示端口)
#   将在指定ID的事件上播放动画 事件ID为0 则为当前事件 为-1 则为玩家
#   注意这个是picmovie2 而不是picmovie
#==============================================================================
# ● 更新
#   V 1.0 2014.02.16 VX新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】
#   本脚本XP版来自【天地有正气】
#   使用、修改和转载请保留此信息
#==============================================================================
 
#==============================================================================
# ■ Cache
#==============================================================================
class << Cache
  def moviepics(folder, seq)
    load_bitmap("Graphics/MoviePics/#{folder}/", "#{seq}")
  end
end
#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  def picmovie(folder, x, y, fcount, wcount = 1, viewport = nil)
    sp = Sprite.new(viewport)
    sp.x, sp.y = x, y
    seq = 1
    until seq >= fcount
      sp.bitmap.dispose if sp.bitmap
      sp.bitmap = Cache.moviepics(folder, seq)
      wcount.times{Graphics.update}
      seq += 1
    end
  rescue
    p "错误信息：#{$!}\n播放到第#{seq}张,在动画#{folder}" if $TEST || $BTEST
  ensure
    sp.dispose rescue nil
  end
  def picmovie2(folder, cid, fcount, wcount = 1, viewport = nil)
    sp = Sprite.new(viewport)
    seq = 1
    sp.bitmap = Cache.moviepics(folder, seq)
    sp.ox, sp.oy = sp.bitmap.width / 2, sp.bitmap.height / 2
    sp.x, sp.y = get_character(cid).screen_x, get_character(cid).screen_y
    until seq >= fcount
      sp.bitmap.dispose if sp.bitmap
      sp.bitmap = Cache.moviepics(folder, seq)
      wcount.times{Graphics.update}
      seq += 1
    end
  rescue
    p "错误信息：#{$!}\n播放到第#{seq}张,在动画#{folder}" if $TEST || $BTEST
  ensure
    sp.dispose rescue nil
  end
end