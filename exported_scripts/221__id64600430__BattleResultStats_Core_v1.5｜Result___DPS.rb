#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：BattleResultStats_Core v1.5｜Result / DPS
# 【來源】日文 `リザルトウィンドウ v1.5` 基底，Forest Symphony 已加入 DPS 顯示與多套相容。原稿作者資訊未在本頁明示，故不推測。
# 【用途】接管戰後 Result 流程：EXP／Gold／Drop／Level Up／Learned Skill／KGC AP、LargeParty 待機成員，以及 Forest Symphony 的 DPS 統計與占比顯示。
# 【關鍵依賴】本頁直接讀 `actor.dps`，因此前方 `♦DPS計算` 必須存在；後方 `解決 KGC 與 DPS 統計的順序衝突` 仍修正 execute_damage alias chain，不能把 DPS 頁當成純顯示腳本刪掉。
# 【Result 設定】SKIP_PM=true、SKIP_KEY=Input::C、SKIP_COUNT=1、WAIT_TIME=100；WINDOW_WIDTH=304；VIEW_ACTOR=0；VIEW_STAND_BY_MEMBERS=false。
# 【音效】EXP=Decision1(60)、LevelUp=Decision1(80)、Item=Chime2、Skill Master=Up；各自可用 EXP_SOUND/LVUP_SOUND/ITEM_SOUND/SKILL_MASTER_SOUND 關閉。
# 【Bonus】TURN_BONUS=false、TURN_BONUS_LIMIT=2；NO_DAMAGE_BONUS=true；EXP_BONUS_RATE=120、GOLD_BONUS_RATE=120。兩條件同時成立時會各自疊加相對於 100 的增量。
# 【LargeParty/AP】若 KGC LargeParty 存在，可用 STAND_BY_GAIN_AP / STAND_BY_AP_RATE 控制待機成員 AP；待機 EXP 依 KGC::LargeParty::STAND_BY_EXP_RATE。
# 【責任邊界】它會 alias Game_Troop#exp_total/#gold_total 與 Scene_Battle#battle_end/#turn_end，因此 FriendlyMonsters 等較前層獎勵會先算，再由 Result Bonus 套倍率。
# 【素材】Audio/SE Decision1、Chime2、Up。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#==============================================================================
# 
#
#
#
#==============================================================================

module BBL
#==============================================================================
#==============================================================================

  SKIP_PM = true
  SKIP_KEY = Input::C
  SKIP_COUNT = 1
  WAIT_TIME = 100
  
  #---------------------------------------------------------------------------
  #     WINDOW_WIDTH = 272
  #     WINDOW_ACTOR_X = 0
  #     WINDOW_ACTOR_LEVEL = 48
  #     WINDOW_EXP_GAUGE_X = 112
  #     WINDOW_EXP_X = 112
  #---------------------------------------------------------------------------
  WINDOW_WIDTH = 304
  WINDOW_ACTOR_X = 8
  WINDOW_ACTOR_LEVEL = 64
  WINDOW_EXP_GAUGE_X = 136
  WINDOW_EXP_X = 136
  ACTOR_HEIGHT = 40
  
  EXP_COLOR1 = Color.new(105, 255, 132)
  EXP_COLOR2 = Color.new(20,  180,  45)
  
  LVUP_COLOR = Color.new(255, 220, 0)
  
  VIEW_ACTOR = 0
  
  VIEW_EXP = "Exp"
  
  VIEW_GOLD = "金幣"
  
  VIEW_ITEM = "道具"
  
  VIEW_SKILL = "習得技能"
  
  EXP_SOUND = true

  LVUP_SOUND = true

  ITEM_SOUND = true
  
  EXP_SOUND_FILE = RPG::SE.new("Decision1", 60, 100)
  
  EXP_SOUND_COUNT = 3
  
  LVUP_SOUND_FILE = RPG::SE.new("Decision1", 80, 100)
  
  ITEM_SOUND_FILE = RPG::SE.new("Chime2", 80, 100)
  
  VIEW_SKILL_MASTER = "MASTER SKILL"
  STAND_BY_GAIN_AP = false
  STAND_BY_AP_RATE = 500
  SKILL_MASTER_SOUND = true
  SKILL_MASTER_SOUND_FILE = RPG::SE.new("Up", 80, 100)

  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  SKILL_ACTOR_HEIGHT = 24
  SKILL_ACTOR_WIDTH = 40
  SKILL_ACTOR_X = 20
  SKILL_ACTOR_Y = 32
  CLEAR_ACTOR_Y = 10
  
  VIEW_STAND_BY_MEMBERS = false
  
#==============================================================================
#    
#
#
#==============================================================================
  
  TURN_BONUS = false
  TURN_BONUS_LIMIT = 2
  TURN_BONUS_WORD = "額外獎勵"
  TURN_BONUS_COLOR = Color.new(255, 255, 150)
  
  NO_DAMAGE_BONUS = true
  NO_DAMAGE_WORD = "戰鬥統計"
  NO_DAMAGE_COLOR = Color.new(255, 255, 150)
  
  EXP_BONUS_RATE = 120
  GOLD_BONUS_RATE = 120

#==============================================================================
#==============================================================================
end

#==============================================================================
#==============================================================================
$imported = {} if $imported == nil


#==============================================================================
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :level_up_flug # 詳見頁首繁中說明
  attr_accessor :new_skills # 詳見頁首繁中說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_BBL initialize
  def initialize(actor_id)
    initialize_BBL(actor_id)
    @new_skills = []
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def next_rest_exp
    return @exp_list[@level+1] > 0 ? (@exp_list[@level+1] - @exp) : 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def next_max_exp
    return @exp_list[@level+1] - @exp_list[@level]
  end
end

#==============================================================================
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
#  def process_victory # 再定義
#     $game_system.battle_end_me.play
#      $game_temp.map_bgs.play
    
#    battle_end(0)
    #
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def display_result
    members = $game_party.all_members if $imported["LargeParty"]
    members = $game_party.members unless $imported["LargeParty"]

    

      for actor in members
        actor.level_up_flug = false
      end
    drop_items = $game_troop.make_drop_items
    for item in drop_items
      $game_party.gain_item(item, 1)
    end
    exp = $game_troop.exp_total
    gold = $game_troop.gold_total
    if $imported["EquipLearnSkill"]
      ap = $game_troop.ap_total
    else
      ap = 0
    end
    
    @resultitem_window = Window_ResultItem.new(drop_items) if drop_items != []
    @result_window = Window_Result.new
    members.each do |actor|
    if actor.id >= 7
     @resultexp_window2 = Window_ResultNextExp2.new(exp)
     break  # 找到符合條件的角色後，提前結束迴圈
     end
    end
    
    @resultexp_window = Window_ResultNextExp.new(exp)
    @expview_window = Window_ResultExp.new(exp, gold, ap)
    @result_window.x = 125
    @resultexp_window.x = 125
    @resultexp_window2.x = 335 if @resultexp_window2
    @expview_window.x = 125
    ###
    @result_window.y = 208-50 - ((@result_window.height - @expview_window.height) / 2)
    
    @resultexp_window.y = @result_window.y
    @resultexp_window2.y = -138 if @resultexp_window2
   
    if drop_items != []
      BBL::ITEM_SOUND_FILE.play if BBL::ITEM_SOUND == true
      if @result_window.height + @resultitem_window.height > 416 - @result_window.y
        @result_window.y = 416 - (@result_window.height + @resultitem_window.height)
        @resultexp_window.y = @result_window.y
      end
      if @result_window.y < @expview_window.height
        @result_window.y = @expview_window.height
        @resultexp_window.y = @result_window.y
      end
      @resultitem_window.y = @result_window.y + @result_window.height if @resultitem_window != nil
      if @result_window.height + @resultitem_window.height + @expview_window.height > 416
        @result_window.x = @resultexp_window.x = @expview_window.x = 0
        @result_window.y = 208 - ((@result_window.height - @expview_window.height) / 2)
        @resultexp_window.y = @result_window.y
        @resultitem_window.x = @result_window.width
        @resultitem_window.y = (@result_window.y + @result_window.height) - @resultitem_window.height
        @resultitem_window.width = 544 - @result_window.width
      else
        @resultitem_window.width = @result_window.width
        @resultitem_window.x = @result_window.x
      end
    end
    @expview_window.y = @result_window.y - @expview_window.height
    
    #---------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    if $imported["EquipLearnSkill"]
      @result_skillkgc_window = Window_ResultSkill_KGC.new
      @result_skillkgc_window.visible = false
      skills = []
      members.each { |actor|
      last_full_ap_skills = actor.full_ap_skills
      unless actor.dead?
        member = actor.battle_member? if $imported["LargeParty"]
        member = actor.exist? unless $imported["LargeParty"]
        if member
          actor.gain_ap(ap, false)
        else
          if BBL::STAND_BY_GAIN_AP
            stand_by_ap = ap
            stand_by_ap = ap * (BBL::STAND_BY_AP_RATE / 1000.0)
            actor.gain_ap(stand_by_ap.round, false)
          end
        end
      end
      if actor.full_ap_skills != last_full_ap_skills
        new_full_ap_skills = actor.full_ap_skills - last_full_ap_skills
        unless new_full_ap_skills.empty?
          for i in 0...new_full_ap_skills.size
            skills.push([new_full_ap_skills[i].name, actor.id])
          end
          @result_skillkgc_window.visible = true
          @result_skillkgc_window.refresh(skills)
          @result_skillkgc_window.y = @expview_window.y
          @result_skill_window.y = @result_skillkgc_window.y + @result_skillkgc_window.height
          BBL::SKILL_MASTER_SOUND_FILE.play if BBL::SKILL_MASTER_SOUND
        end
      end
      }
    end
    #---------------------------------------------------------------------------
      
    @count = 0
    @se_count = 0
    skills = []
    loop do
      if BBL::SKIP_PM == true
      @count += BBL::SKIP_COUNT if Input.press?(BBL::SKIP_KEY)
      end
      if BBL::EXP_SOUND == true
        BBL::EXP_SOUND_FILE.play if @se_count == 0 and exp != 0
        @se_count += 1
        @se_count = 0 if @se_count == BBL::EXP_SOUND_COUNT
      end
      @count += 1
      @count = BBL::WAIT_TIME if @count > BBL::WAIT_TIME
      @resultexp_window.update(exp, @count)
      @resultexp_window2.update(exp, @count) if @resultexp_window2
      
      #      skills.push([actor.new_skills[i].name, actor.id])
      
      break if @count == BBL::WAIT_TIME
      update_basic
    end
      @resultexp_window.update(exp, @count) # 補助
      @resultexp_window2.update(exp, @count) if @resultexp_window2 # 補助
    #wait(30) if @result_skill_window.visible
    # EXP獲得
      $game_party.members.each { |actor|
        actor.gain_exp(exp, false) if actor.exist?
      }
    if $imported["LargeParty"]
      exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
      $game_party.stand_by_members.each { |actor|
      actor.gain_exp(exp, false) if actor.exist?
      }
    end
    $game_party.gain_gold(gold)
    loop do
      update_basic
      break if Input.trigger?(Input::C)
    end
    
    
    @result_window.dispose
    
    @expview_window.dispose
    @resultexp_window.dispose
    @resultexp_window2.dispose if @resultexp_window2 != nil
    @resultitem_window.dispose if @resultitem_window != nil
    @result_skillkgc_window.dispose if $imported["EquipLearnSkill"]
  end
end
#==============================================================================
#==============================================================================
class Window_ResultExp < Window_Base
  WIDTH = BBL::WINDOW_WIDTH # 詳見頁首繁中說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(exp, gold, ap)
    i = 2
    if BBL::NO_DAMAGE_BONUS
      i += 1 unless $game_temp.damage_flug
    end
    if BBL::TURN_BONUS
      i += 1 if $game_temp.turn_bonus
    end
    if $imported["EquipLearnSkill"]
      i += 1 if ap > 0
    end
    super(0, 0, WIDTH, WLH * i + 32)
    self.contents = Bitmap.new(width - 32, height - 32)
    @adps = 1
    refresh(exp, gold, ap)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(exp, gold, ap)
    self.contents.clear
    $game_party.members.each do |actor|
     next if actor.nil? || actor.id >= 7
     @adps += actor.dps.to_f
    end
    #for i in 0 .. 2###计算队伍角色加起来的总输出，用来计算单个角色的输出占比
    
    def draw_status_face(face_name, face_index, x, y, size = 96)
     bitmap = Cache.face(face_name)
     rect = Rect.new(face_index % 4 * 96 + 15, face_index / 4 * 96 + 31, 96-19, 52)
     # 創建 `RoundRectRegion` 來定義圓角矩形裁剪區域
  region = RoundRectRegion.new(0, 0, rect.width, rect.height, 16, 16) # 圓角大小 16px

  # 創建一個臨時 `Bitmap`
  temp_bitmap = Bitmap.new(rect.width, rect.height)

  # **使用 `clip_blt`** 來裁剪繪製區域，使得 `blt` 只在圓角矩形內生效
  temp_bitmap.clip_blt(0, 0, bitmap, rect, region)

  # 將處理後的臉圖繪製到視窗
  self.contents.blt(x, y, temp_bitmap, Rect.new(0, 0, rect.width, rect.height))

  # 釋放 Bitmap，防止記憶體洩漏
  temp_bitmap.dispose
     bitmap.dispose
    end
    
    def draw_statu_face(actor, x, y)
     draw_status_face(actor.face_name, actor.face_index, x, y)
    end
   
   def draw_character_sprite(actor, x, y)
    return if actor.nil?
    character_bitmap = Cache.character(actor.character_name)
    cw = character_bitmap.width / 3
    ch = character_bitmap.height / 4
    src_rect = Rect.new(32, 0, cw, ch)
    self.contents.blt(x, y, character_bitmap, src_rect)
  end

  ###
  ###
    
 # 取得符合條件的角色 (id < 7)
valid_members = []
summon_members = [] # 儲存 `id >= 7` 的角色

$game_party.members.each do |actor|
  next if actor.nil?
  if actor.id < 7
    valid_members.push(actor)
  else
    summon_members.push(actor)
  end
end

# 計算所有符合條件角色的 DPS 占比
dps_values = []
total_dps_percentage = 0

valid_members.each do |actor|
  dps_percentage = (actor.dps.to_f / @adps * 100).to_i
  dps_values.push([actor, dps_percentage])
  total_dps_percentage += dps_percentage
end

# 檢查是否 DPS 占比總和低於 50%
if total_dps_percentage < 50
  remaining_dps = 100 - total_dps_percentage
  self.contents.font.color = BBL::TURN_BONUS_COLOR
  self.contents.font.size = 18
  self.contents.draw_text(115, -6, 96, 24, "寶可夢!", 2)
  self.contents.font.color = normal_color
  self.contents.font.size = 14
  self.contents.draw_text(148, 56, 96, 24, "占比: #{remaining_dps}%", 2)

  # 在 `draw_statu_face` 位置顯示 `id >= 7` 的角色行走圖
  x_offset = 168
  summon_members.each do |actor|
    draw_character_sprite(actor, x_offset, 20)
    x_offset += 32  # 依次排列角色
  end

  self.contents.font.size = 19
else
  # 計算 MVP
  if valid_members.size == 1
    # 單人隊伍
    dps_percentage = dps_values[0][1]

    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.font.size = 18
    self.contents.draw_text(115, -6, 96, 24, "單打獨鬥!", 2)
    self.contents.font.color = normal_color
    self.contents.font.size = 14
    self.contents.draw_text(148, 56, 96, 24, "占比: #{dps_percentage}%", 2)
    draw_statu_face(valid_members[0], 172, 12)
    self.contents.font.size = 19

  elsif valid_members.size == 2
    # 兩人隊伍
    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.font.size = 18
    self.contents.draw_text(115, -6, 96, 24, "MVP !", 2)

    if dps_values[0][1] >= dps_values[1][1]
      self.contents.font.color = normal_color
      self.contents.font.size = 14
      self.contents.draw_text(148, 56, 96, 24, "占比: #{dps_values[0][1]}%", 2)
      draw_statu_face(dps_values[0][0], 168, 12)
    else
      self.contents.font.color = normal_color
      self.contents.font.size = 14
      self.contents.draw_text(148, 56, 96, 24, "占比: #{dps_values[1][1]}%", 2)
      draw_statu_face(dps_values[1][0], 168, 12)
    end
    self.contents.font.size = 19

  elsif valid_members.size >= 3
    # 三人以上隊伍
    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.font.size = 18
    self.contents.draw_text(115, -6, 96, 24, "MVP !", 2)

    # 找出 DPS 最高的角色
    mvp_actor = nil
    max_dps = 0
    dps_values.each do |actor, dps|
      if dps > max_dps
        max_dps = dps
        mvp_actor = actor
      end
    end

    # 顯示 MVP 角色的占比
    if mvp_actor
      self.contents.font.color = normal_color
      self.contents.font.size = 14
      self.contents.draw_text(148, 56, 96, 24, "占比: #{max_dps}%", 2)
      draw_statu_face(mvp_actor, 168, 12)
      self.contents.font.size = 19
    end
  end
end




      #######
   

      
=begin    
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
    rect = Rect.new(face_index % 4 * 96 + 15, face_index / 4 * 96 + 40, 96-19, 22)
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
    end
  
    def draw_status_graphic(character_name, character_index, x, y, size = 32)
    bitmap = Cache.character(character_name)
    rect = Rect.new(character_index % 4 * 32 +64, character_index / 4 * 32, 32, 19)
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
    end
    def draw_statu_graphic(actor, x, y)
    draw_status_graphic(actor.character_name, actor.character_index, x, y)
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
    self.contents.font.color = system_color
    self.contents.font.size = 17
    #self.contents.draw_text(4 + 108+3, 0-6, 96, 24, "總輸出", 2)
    self.contents.font.color = normal_color
    self.contents.font.size = 16
    if $game_party.members[0] != nil
    #draw_statu_graphic($game_party.members[0], 4 + 128, 10)
    draw_statu_face($game_party.members[0], 4 + 88, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(4 + 108, 10-10, 96, 24, $game_party.members[0].dps.to_s, 2)
    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.draw_text(4 + 108+36, 10-10, 96, 24, (($game_party.members[0].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    end
    if $game_party.members[1] != nil
    #draw_statu_graphic($game_party.members[1], 4 + 128, 31)
    self.contents.font.color = normal_color
    self.contents.draw_text(4 + 108, 34-10, 96, 24, $game_party.members[1].dps.to_s, 2)
    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.draw_text(4 + 108+36, 34-10, 96, 24, (($game_party.members[1].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    draw_statu_face($game_party.members[1], 4 + 88, 24)
    end
    if $game_party.members[2] != nil
    #draw_statu_graphic($game_party.members[2], 4 + 128, 52)
    self.contents.font.color = normal_color
    self.contents.draw_text(4 + 108, 58-10, 96, 24, $game_party.members[2].dps.to_s, 2)
    self.contents.font.color = BBL::TURN_BONUS_COLOR
    self.contents.draw_text(4 + 108+36, 58-10, 96, 24, (($game_party.members[2].dps.to_i/@adps*100).to_i).to_s + "%", 2)
    draw_statu_face($game_party.members[2], 4 + 88, 48)
    end
    ###
    self.contents.font.size = 19
=end
    i = 0
    if BBL::TURN_BONUS
      if $game_temp.turn_bonus
        self.contents.font.color = BBL::TURN_BONUS_COLOR
        self.contents.draw_text(4, WLH * i, 272, WLH, BBL::TURN_BONUS_WORD)
        i += 1
      end
    end
    if BBL::NO_DAMAGE_BONUS
      unless $game_temp.damage_flug
        self.contents.font.color = BBL::NO_DAMAGE_COLOR
        self.contents.draw_text(4, WLH * i, 272, WLH, BBL::NO_DAMAGE_WORD)
        i += 1
      end
    end
    self.contents.font.color = system_color
    exp_width = contents.text_size(BBL::VIEW_EXP).width
    gold_width = contents.text_size(BBL::VIEW_GOLD).width
    self.contents.draw_text(4, WLH * i, exp_width, WLH, BBL::VIEW_EXP)
    self.contents.draw_text(4, WLH * i + WLH, gold_width, WLH, BBL::VIEW_GOLD)
    self.contents.font.color = normal_color
    x = [exp_width, gold_width].max
    if BBL::TURN_BONUS || BBL::NO_DAMAGE_BONUS
      exp_rate = 100
      gold_rate = 100
      if $game_temp.damage_flug == false && BBL::NO_DAMAGE_BONUS
      exp_rate += BBL::EXP_BONUS_RATE - 100
      gold_rate += BBL::GOLD_BONUS_RATE - 100
      end
      if $game_temp.turn_bonus && BBL::TURN_BONUS
      exp_rate += BBL::EXP_BONUS_RATE - 100
      gold_rate += BBL::GOLD_BONUS_RATE - 100
      end
      if $game_temp.damage_flug == false || $game_temp.turn_bonus
        exp1 = (exp / (exp_rate / 100.0)).round
        exp2 = exp - exp1
        total_exp = exp1, " ＋ ", exp2
        total_exp = exp if exp == 0
        gold1 = (gold / (gold_rate / 100.0)).round
        gold2 = gold - gold1
        total_gold = gold1, " ＋ ", gold2
        total_gold = gold if gold == 0
        self.contents.draw_text(x + 32, WLH * i, 304 - 32, 24, total_exp)
        self.contents.draw_text(x + 32, WLH * i + WLH, 304 - 32, 24, total_gold)
      else
        self.contents.draw_text(x + 32, WLH * i, 304 - 32, 24, exp)
        self.contents.draw_text(x + 32, WLH * i + WLH, 304 - 32, 24, gold)
      end
    else
      self.contents.draw_text(x + 32, WLH * i, 304 - 32, 24, exp)
      self.contents.draw_text(x + 32, WLH * i + WLH, 304 - 32, 24, gold)
    end
    if ap > 0
      i += 1
      self.contents.draw_text(x + 32, WLH * i + WLH, 304 - 32, 24, ap)
      self.contents.font.color = system_color
      self.contents.draw_text(4, WLH * i + WLH, gold_width, WLH, KGC::EquipLearnSkill::VOCAB_AP)
    end
  end
end
#==============================================================================
#==============================================================================
class Window_ResultItem < Window_Base
  WIDTH = 544 - BBL::WINDOW_WIDTH
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(drop_items)
    x = BBL::WINDOW_WIDTH
    #super(x, 0, WIDTH, (drop_items.size * WLH) + WLH  + 32)
    if drop_items.size <= 4
    super(x, 0, WIDTH, (drop_items.size * WLH) + WLH  + 32)
    else
    super(x, 0, WIDTH, (4 * WLH) + WLH  + 32)
    end
    refresh(drop_items)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(drop_items)
    self.contents.clear
    x = 4
    item_width = contents.text_size(BBL::VIEW_ITEM).width
    self.contents.font.color = BBL::NO_DAMAGE_COLOR
    self.contents.draw_text(x, 0, item_width, WLH, BBL::VIEW_ITEM,1)
    y = WLH
    for item in drop_items
      draw_item_name(item, x, y)
      y += WLH
      if y == WLH * 5
        y -= WLH * 4
        x += 120
      end
    end
  end
  #--------------------------------------------------------------------------
  #     x       : 描画先 X 座標
  #     y       : 描画先 Y 座標
  #--------------------------------------------------------------------------
  #    draw_icon(item.icon_index, x+60, y, enabled)
  #    self.contents.draw_text(x + 24, y, WIDTH - 56, WLH, item.name,1)
end

#==============================================================================
#==============================================================================
class Window_Result < Window_Base
  HEIGHT = BBL::ACTOR_HEIGHT # 詳見頁首繁中說明
  WIDTH = BBL::WINDOW_WIDTH # 詳見頁首繁中說明
  ###
  ###
  #--------------------------------------------------------------------------
  # ● 定義jp獲得
  #--------------------------------------------------------------------------
  def draw_jp_earned(actor, dx, dy)
    self.contents.font.color = text_color(0)
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx+84, dy)
    text = sprintf(YEZ::JOB::JP_GAINED, actor.jp_counter)
    self.contents.draw_text(dx, dy, 84, WLH, text, 2)
    #draw_icon(icon, dx+84, dy)
    #self.contents.draw_text(dx, dy, 84, WLH, text, 2)
  end
  ###
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    @members = $game_party.members.select { |actor| actor && actor.id < 7 }
    if $imported["LargeParty"] && BBL::VIEW_STAND_BY_MEMBERS
      @members = $game_party.all_members
    end
    super(0, 0, WIDTH, (@members.size * HEIGHT) + 32)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 208 - (height / 2)
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
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
    rect = Rect.new(face_index % 4 * 96 + 15, face_index / 4 * 96 + 40, 96-19, 22)
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
    def draw_actor_graphicvic(actor, x, y)
    draw_character(actor.character_name+"_2", actor.character_index, x, y)
    end
    ###
    name_width = []
    actor_x = BBL::WINDOW_ACTOR_X
    level_x = BBL::WINDOW_ACTOR_LEVEL
    gauge_x = BBL::WINDOW_EXP_GAUGE_X
    lv_width = contents.text_size(Vocab::level_a).width
    for actor in @members
      x = 4
      y = actor.index * HEIGHT unless $imported["LargeParty"]
      y = actor.party_index * HEIGHT if $imported["LargeParty"]
      sy = (HEIGHT / 2) - 16
      case BBL::VIEW_ACTOR#
      when 0;draw_actor_graphicvic(actor, actor_x + 16, y + HEIGHT - sy - 3)
      when 1;draw_actor_name(actor, actor_x, y + HEIGHT - 20 - sy)
      end
      ###
      self.contents.font.size = 18
      draw_jp_earned(actor, actor_x-15, y) if actor.id < 7###
      ###
      if actor.id < 7
      self.contents.font.size = 20
      self.contents.font.color = system_color
      self.contents.draw_text(level_x, y + HEIGHT - 20 - sy, lv_width, WLH, Vocab::level_a)
      self.contents.draw_text(gauge_x, y + HEIGHT - 28 - sy, 64, WLH, "Next")
      end
    end
  end
end

#==============================================================================
#==============================================================================
HEIGHT = BBL::SKILL_ACTOR_HEIGHT
WIDTH = 544 - BBL::WINDOW_WIDTH
GWIDTH = BBL::SKILL_ACTOR_WIDTH
class Window_ResultSkill < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    x = BBL::WINDOW_WIDTH
    super(x, 0, WIDTH, WLH + 32)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(skills)
    self.contents.clear

  # 取得所有 ID >= 7 的角色 ID，並去重
  actor_ids = skills.map { |s| s[1] }.uniq.select { |id| id >= 7 }

  # 如果沒有符合條件的角色，則不顯示視窗
  return if actor_ids.empty?

  # 設定行距（可調整）
  line_spacing = 8

  # 視窗高度根據符合條件的角色數量調整
  self.height = actor_ids.size * (HEIGHT + line_spacing) + WLH + 32
  self.contents = Bitmap.new(width - 32, height - 32)

  # 設定字型顏色
  self.contents.font.color = system_color

  # 繪製每個角色的「獲得新技能」
  actor_ids.each_with_index do |actor_id, index|
    actor = $data_actors[actor_id]
    
    # 計算 Y 座標
    y_pos = WLH + index * (HEIGHT + line_spacing)
    
    # 繪製角色圖像
    #draw_actor_graphic(actor, 0, y_pos)
    
    # 顯示「獲得新技能」文字（置中對齊）
    text = "New Skill!"
    text_x = 0 # 詳見頁首繁中說明
    self.contents.font.size = 16
    self.contents.font.color = Color.new(200,60,80)
    self.contents.draw_text(text_x, y_pos, width - 32, WLH, text)
  end
=begin
    self.contents.clear
    text_width = contents.text_size(BBL::VIEW_SKILL).width
    self.height = skills.size * HEIGHT + WLH + 32
    self.contents = Bitmap.new(width - 32, height - 32)
    x = 0
    self.contents.font.color = system_color
    self.contents.draw_text(x, 0, text_width, WLH, BBL::VIEW_SKILL)
    last_id = 9999
    text_x = x + GWIDTH
    sy = BBL::SKILL_ACTOR_Y
    sx = BBL::SKILL_ACTOR_X
    for i in 0...skills.size
      actor = $data_actors[skills[i][1]]
      unless last_id == skills[i][1]
      draw_actor_graphic(actor, x + sx, sy + WLH + HEIGHT * i)
      end
      self.contents.font.color = normal_color
      self.contents.draw_text(text_x, WLH + HEIGHT * i, WIDTH - (32 + text_x), WLH, skills[i][0])
      last_id = skills[i][1]
    end
=end
  end
  #--------------------------------------------------------------------------
  #     x               : 描画先 X 座標
  #     y               : 描画先 Y 座標
  #     opacity         : 不透明度
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y, opacity = 255)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, opacity)
    gheight = BBL::CLEAR_ACTOR_Y
    self.contents.clear_rect(x - cw / 2, y - gheight, GWIDTH, gheight)
  end
end
#==============================================================================
#==============================================================================
class Window_ResultNextExp < Window_Base
  HEIGHT = BBL::ACTOR_HEIGHT # 詳見頁首繁中說明
  WIDTH = BBL::WINDOW_WIDTH # 詳見頁首繁中說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(exp)
    @members = $game_party.all_members if $imported["LargeParty"]
    @members = $game_party.members unless $imported["LargeParty"]  
    super(0, 0, WIDTH, (@members.size * HEIGHT) + 32)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 208 - (height / 2)
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● EXP表示更新
  #--------------------------------------------------------------------------
  def update(exp_s, count)
    self.contents.clear
    
    level_x = BBL::WINDOW_ACTOR_LEVEL
    gauge_x = BBL::WINDOW_EXP_GAUGE_X
    exp_x = BBL::WINDOW_EXP_X
    
    
    i = 100
    for actor in @members
      if actor.id >= 7

      else
       exp = exp_s
       exp = exp_s * 2 if actor.double_exp_gain
       exp = exp_s * actor.exp_gain_rate / 100 if $imported["VariableExpGold"]
       x = 56
       y = actor.index * HEIGHT unless $imported["LargeParty"]
       y = actor.party_index * HEIGHT if $imported["LargeParty"]
       sy = (HEIGHT / 2) - 16
       update_actor_level(actor, level_x, y + HEIGHT - 20 - sy) if view_member?(actor)
       update_actor_nextexp(actor, exp_x, y + HEIGHT - 28 - sy, exp, count) 
       update_actor_exp_gauge(actor, gauge_x, y + HEIGHT - 22 - sy, exp, count) if view_member?(actor)
      end
    end
  end
  #--------------------------------------------------------------------------
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def update_actor_level(actor, x, y)
    self.contents.font.color = BBL::LVUP_COLOR if actor.level_up_flug == true
    self.contents.draw_text(x + 32, y, 24, WLH, actor.level)
  end
  #--------------------------------------------------------------------------
  # ○ NEXTEXP表示更新
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def update_actor_nextexp(actor, x, y, exp, count, width = 120)
    if actor.level == 300
      self.contents.draw_text(x, y, width, WLH, "MAX", 2)
      return
    end
    exp = 0 if actor.dead?
    if $imported["LargeParty"]
      unless actor.battle_member?
        exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
      end
    end
    gwc = exp * count / BBL::WAIT_TIME
    self.contents.font.color = normal_color
    if actor.next_rest_exp_s - gwc <= 0
      last_skills = actor.skills
      last_skills = actor.all_skills if $imported["SkillCPSystem"]
      actor.level_up
      actor.level_up_flug = true
      BBL::LVUP_SOUND_FILE.play if BBL::LVUP_SOUND == true
      actor.new_skills = actor.skills - last_skills
      actor.new_skills = actor.all_skills - last_skills if $imported["SkillCPSystem"]
    end
    if actor.next_max_exp > 0
      self.contents.draw_text(x, y, width, WLH, actor.next_rest_exp_s - gwc, 2) if view_member?(actor)
    else
      xr = x + width
    end
  end
  #--------------------------------------------------------------------------
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def update_actor_exp_gauge(actor, x, y, exp, count, width = 120)
    color1 = BBL::EXP_COLOR1
    color2 = BBL::EXP_COLOR2
    if actor.level == 300
      self.contents.gradient_fill_rect(x, y + WLH - 8, width, 6, color1, color2)
      return
    end
    exp = 0 if actor.dead?
    if $imported["LargeParty"]
      unless actor.battle_member?
        exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
      end
    end
    max = actor.next_max_exp
    gw = width * (max - actor.next_rest_exp) / max
    exp = width * exp / max
    gwc = exp * count / BBL::WAIT_TIME + gw
    color1 = BBL::EXP_COLOR1
    color2 = BBL::EXP_COLOR2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gwc, 6, color1, color2)
  end
  #--------------------------------------------------------------------------
  # ☆ 描画判定
  #--------------------------------------------------------------------------
  def view_member?(actor)
    if $imported["LargeParty"]
      unless BBL::VIEW_STAND_BY_MEMBERS
        return false unless actor.battle_member?
      end
    end
    return true
  end
end

#==============================================================================
#==============================================================================
class Window_ResultNextExp2 < Window_Base
  HEIGHT = BBL::ACTOR_HEIGHT # 詳見頁首繁中說明
  WIDTH = BBL::WINDOW_WIDTH # 詳見頁首繁中說明
  HEIGHT2 = BBL::ACTOR_HEIGHT + 15
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(exp)
    @members = $game_party.all_members if $imported["LargeParty"]
    @members = $game_party.members unless $imported["LargeParty"]  
    super(0, 0, WIDTH, (@members.size * HEIGHT) + 128)
    #super(0, 0, WIDTH, (6 * HEIGHT) + 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 208 - (height / 2)
    self.opacity = 0
    #@learned_skills = {} # 用來存放習得的技能
  end
  #--------------------------------------------------------------------------
  # ● EXP表示更新
  #--------------------------------------------------------------------------
  def update(exp_s, count)
    self.contents.clear
    
    level_x = BBL::WINDOW_ACTOR_LEVEL
    gauge_x = BBL::WINDOW_EXP_GAUGE_X
    exp_x = BBL::WINDOW_EXP_X
    i = 0
    for actor in @members
      if actor.id < 7

      else
       exp = exp_s
       exp = exp_s * 2 if actor.double_exp_gain
       exp = exp_s * actor.exp_gain_rate / 100 if $imported["VariableExpGold"]
       x = 56
       y = actor.index * HEIGHT unless $imported["LargeParty"]
       y = 3 * HEIGHT + (i*50) if $imported["LargeParty"]
       
       sy = (HEIGHT / 2) - 16
#       self.contents.draw_text(level_x, y + HEIGHT - 20 - sy, lv_width, WLH, Vocab::level_a)
       update_actor_level(actor, level_x, y + HEIGHT - 20 - sy) if view_member?(actor)
       update_actor_nextexp(actor, exp_x, y + HEIGHT - 28 - sy, exp, count) 
       update_actor_exp_gauge(actor, gauge_x, y + HEIGHT - 22 - sy, exp, count) if view_member?(actor)
       # 顯示習得的新技能
      #draw_learned_skills(actor, level_x, y + HEIGHT - 20 - sy)
       i = i + 1
      end
    end
  end
  #--------------------------------------------------------------------------
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def update_actor_level(actor, x, y)
    self.contents.font.color = BBL::LVUP_COLOR if actor.level_up_flug == true
    self.contents.font.size = 14
    self.contents.draw_text(50+x, y-3, 24, WLH, actor.level)
    self.contents.draw_text(50+x-12, y-3, 24, WLH, "Lv")
  end
  #--------------------------------------------------------------------------#
# ● 更新角色等級顯示，並在下方增加「獲得新技能！」訊息
#--------------------------------------------------------------------------#
def update_actor_level(actor, x, y)
  self.contents.font.color = BBL::LVUP_COLOR if actor.level_up_flug == true
  self.contents.font.size = 14
  self.contents.draw_text(50+x, y-3, 24, WLH, actor.level)
  self.contents.draw_text(50+x-12, y-3, 24, WLH, "Lv")

  # 如果該角色獲得新技能，則在等級下方顯示「獲得新技能！」
  if actor.new_skills && !actor.new_skills.empty?
    self.contents.font.color = Color.new(200, 60, 80) # 金黃色
    self.contents.font.size = 13
    self.contents.draw_text(80+x-12, y + 27, 120, WLH, "New Skill！", 0)
  end

  self.contents.font.size = 20 # 還原字型大小
end
  #--------------------------------------------------------------------------
  # ○ NEXTEXP表示更新
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def update_actor_nextexp(actor, x, y, exp, count, width = 120)
    if actor.level == 300
      self.contents.draw_text(x, y, width, WLH, "MAX", 2)
      return
    end
    exp = 0 if actor.dead?
    if $imported["LargeParty"]
      unless actor.battle_member?
        exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
      end
    end
    gwc = exp * count / BBL::WAIT_TIME
    self.contents.font.color = normal_color
    if actor.next_rest_exp_s - gwc <= 0
      last_skills = actor.skills
      last_skills = actor.all_skills if $imported["SkillCPSystem"]
      actor.level_up
      actor.level_up_flug = true
      BBL::LVUP_SOUND_FILE.play if BBL::LVUP_SOUND == true
      actor.new_skills = actor.skills - last_skills
      actor.new_skills = actor.all_skills - last_skills if $imported["SkillCPSystem"]
    end
    if actor.next_max_exp > 0
      self.contents.draw_text(x, y, width, WLH, actor.next_rest_exp_s - gwc, 2) if view_member?(actor)
    else
      xr = x + width
    end
  end
  #--------------------------------------------------------------------------
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def update_actor_exp_gauge(actor, x, y, exp, count, width = 30)
    color1 = BBL::EXP_COLOR1
    color2 = BBL::EXP_COLOR2
    if actor.level == 300
      self.contents.gradient_fill_rect(x, y + WLH - 8, width, 6, color1, color2)
      return
    end
    exp = 0 if actor.dead?
    if $imported["LargeParty"]
      unless actor.battle_member?
        exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
      end
    end
    max = actor.next_max_exp
    gw = width * (max - actor.next_rest_exp) / max
    exp = width * exp / max
    gwc = exp * count / BBL::WAIT_TIME + gw
    color1 = BBL::EXP_COLOR1
    color2 = BBL::EXP_COLOR2
    self.contents.fill_rect(x, y + WLH - 8, width, 3, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gwc, 3, color1, color2)
  end
  #--------------------------------------------------------------------------#
  # ● 顯示習得的新技能
  #--------------------------------------------------------------------------#
  def draw_learned_skills(actor, x, y)
    return unless @learned_skills[actor] # 沒學新技能就跳過

    self.contents.font.color = Color.new(255, 200, 50)
    self.contents.font.size = 16

    skill_names = @learned_skills[actor].map(&:name).join(", ")
    self.contents.draw_text(x, y, 200, WLH, "習得 #{skill_names}", 0)

    self.contents.font.size = 20
  end
  #--------------------------------------------------------------------------
  # ☆ 描画判定
  #--------------------------------------------------------------------------
  def view_member?(actor)
    if $imported["LargeParty"]
      unless BBL::VIEW_STAND_BY_MEMBERS
        return false unless actor.battle_member?
      end
    end
    return true
  end
end
if $imported["EquipLearnSkill"]
#==============================================================================
#==============================================================================
HEIGHT = BBL::SKILL_ACTOR_HEIGHT
WIDTH = 544 - BBL::WINDOW_WIDTH
GWIDTH = BBL::SKILL_ACTOR_WIDTH
class Window_ResultSkill_KGC < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    x = BBL::WINDOW_WIDTH
    super(x, 0, WIDTH, WLH + 32)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(skills)
    self.contents.clear
    text_width = contents.text_size(BBL::VIEW_SKILL_MASTER).width
    self.height = skills.size * HEIGHT + WLH + +32
    self.contents = Bitmap.new(width - 32, height - 32)
    x = 0
    self.contents.font.color = system_color
    self.contents.draw_text(x, 0, text_width, WLH, BBL::VIEW_SKILL_MASTER)
    last_id = 9999
    text_x = x + GWIDTH
    sy = BBL::SKILL_ACTOR_Y
    sx = BBL::SKILL_ACTOR_X
    for i in 0...skills.size
      actor = $data_actors[skills[i][1]]
      unless last_id == skills[i][1]
      draw_actor_graphic(actor, x + sx, sy + WLH + HEIGHT * i)
      end
      self.contents.font.color = normal_color
      self.contents.draw_text(text_x, WLH + HEIGHT * i, WIDTH - (32 + text_x), WLH, skills[i][0])
      last_id = skills[i][1]
    end
  end
  #--------------------------------------------------------------------------
  #     x               : 描画先 X 座標
  #     y               : 描画先 Y 座標
  #     opacity         : 不透明度
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y, opacity = 255)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, opacity)
    gheight = BBL::CLEAR_ACTOR_Y
    self.contents.clear_rect(x - cw / 2, y - gheight, GWIDTH, gheight)
  end
end
end

if BBL::TURN_BONUS || BBL::NO_DAMAGE_BONUS
#==============================================================================
#==============================================================================
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :damage_flug # 詳見頁首繁中說明
  attr_accessor :turn_bonus # 詳見頁首繁中說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_BBL initialize
  def initialize
    initialize_BBL
    @damage_flug = false
    @turn_bonus = true
  end
end

#==============================================================================
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias make_attack_damage_value_BBL make_attack_damage_value
  def make_attack_damage_value(attacker)
    make_attack_damage_value_BBL(attacker)
    if $game_temp.damage_flug == false
      if @hp_damage > 0
        $game_temp.damage_flug = true unless attacker.actor?
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias make_obj_damage_value_BBL make_obj_damage_value
  def make_obj_damage_value(user, obj) # 追加定義
    make_obj_damage_value_BBL(user, obj)
    if $game_temp.damage_flug == false
      if @hp_damage > 0
        $game_temp.damage_flug = true unless user.actor?
      end
    end
  end
end

#==============================================================================
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias exp_total_BBL exp_total
  def exp_total # 追加定義
    exp = exp_total_BBL
    rate = 100
    if BBL::NO_DAMAGE_BONUS
      if $game_temp.damage_flug == false
      rate += BBL::EXP_BONUS_RATE - 100
      end
    end
    if BBL::TURN_BONUS
      if $game_temp.turn_bonus
      rate += BBL::EXP_BONUS_RATE - 100
      end
    end
    exp = ((exp * rate) / 100).round
    return exp
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias gold_total_BBL gold_total
  def gold_total # 追加定義
    gold = gold_total_BBL
    rate = 100
    if BBL::NO_DAMAGE_BONUS
      if $game_temp.damage_flug == false
      rate += BBL::GOLD_BONUS_RATE - 100
      end
    end
    if BBL::TURN_BONUS
      if $game_temp.turn_bonus
      rate += BBL::GOLD_BONUS_RATE - 100
      end
    end
    gold = ((gold * rate) / 100).round    
    return gold
  end
end

#==============================================================================
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘終了(追加定義)
  #--------------------------------------------------------------------------
  alias battle_end_BBL battle_end
  def battle_end(result) # 追加定義
    $game_temp.damage_flug = false # 詳見頁首繁中說明
    $game_temp.turn_bonus = true # 詳見頁首繁中說明
    battle_end_BBL(result)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias turn_end_BBL turn_end
  def turn_end # 追加定義
    if $game_troop.turn_count == BBL::TURN_BONUS_LIMIT
      $game_temp.turn_bonus = false
    end
    turn_end_BBL
  end
end
end
