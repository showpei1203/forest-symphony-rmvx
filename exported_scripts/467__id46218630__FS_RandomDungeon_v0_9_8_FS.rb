#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_RandomDungeon_v0_9_8_FS
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_RandomDungeon_v0_9_8_FS」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RNG、BSPBox、Room、Generator、Renderer、Game_Temp、Game_System
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：GENERATOR_SCHEMA、TILE_SIZE、PASS_BLOCK、PASS_OPEN、PASS_WATER、CELL_VOID、CELL_FLOOR、CELL_WALL。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 10 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_RandomDungeon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】FS_RANDOM_DUNGEON.enter(:field_cave_01)
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
# -*- coding: utf-8 -*-
#==============================================================================
# ■ FS_RandomDungeon_v0_9_8_FS
#------------------------------------------------------------------------------
#  Forest Symphony 專用隨機迷宮核心（RPG Maker VX / RGSS2）
#  地圖拓撲參考：tomoaky（ひきも記）RGSS2_ランダムマップ生成。
#  本版為 Forest Symphony 相容重製，不是原腳本逐行複製。
#------------------------------------------------------------------------------
# 【定位】
#  本腳本不是直接移植「ひきも記／ランダムマップ生成」。
#  僅參考房間、通路與事件配置概念，並依 Forest Symphony 重製：
#    1. 不依賴 VX Tilemap。
#    2. 以 Bitmap 生成 Ground / Water / Bridge / Upper 圖層。
#    3. 第 2 層 Tile ID 專供 ParaPassa 通行編碼。
#    4. 只保存 Seed 與邏輯布局，不把大型 Bitmap 寫進存檔。
#    5. 保留 Scene_Map / Spriteset_Map，不另建 Dungeon Scene。
#
# 【v0.9.8-FS 核心與端點補完】
#    ・Phase49E1：修正 count_as_exit=false 的離場 suppression 未在單次
#      perform_transfer 後消耗，導致下一次普通外部轉場錯誤跳過 :on_exit。
#    ・地圖邏輯、樓層、事件池、重置、HUD、迷你地圖等沿用 v0.9.1-FS。
#    ・廢止 v0.9.2～v0.9.6 的方向猜測、肩部補格與多圈牆體遮罩。
#    ・改採「魔王狩獵／ひきも記式」高度拓撲：開放區、北側牆面、
#      完整 A4 牆頂、南側牆面，再追加一列可自訂深色外壁。
#    ・A1 水域與 A4 牆頂／牆面皆按 VX 原生 autotile 四分片規則繪製。
#    ・中央地板、南側深色外壁、橋與裝飾仍由 32×32 decor atlas 提供。
#    ・本版從穩定的 v0.9.1-FS 重新分支，不繼承錯誤牆體補丁。
#
#    ・新增探索進度與重生規則，重置時機與重置內容分離設定。
#    ・支援 manual / on_exit / on_clear / daily / new_seed_each_entry。
#    ・可分別控制布局、寶箱、敵人、菁英、恢復點、魂刻與 Boss。
#    ・魂刻與 Boss 可設為永久一次，跨布局重建仍保留完成狀態。
#    ・新增通關標記、軟重置、每日重置及離開迷宮排程。
#    ・新增 Forest Symphony 樓層名稱、危險度與 Message Queue 提示。
#    ・新增環境詞綴框架，可影響生成參數並提供戰鬥腳本查詢值。
#    ・新增 Boss 房安全區、生成驗證與自動重試。
#    ・新增房間／事件／通行度 Debug 視覺圖層。
#    ・新增「迷宮 → 特定房間 → 下一座迷宮」安全轉場指令。
#    ・新增常駐進度 HUD：樓層、總樓層、詞綴、危險度可自訂格式。
#    ・HUD 啟用時預設抑制樓層 Message Queue，避免左上角重疊。
#    ・新增按樓層保存的探索進度、迷你地圖與大型地圖。
#    ・新增可選擇的實際地圖戰爭迷霧。
#    ・迷你地圖支援入口、出口、寶箱、菁英、恢復、魂刻與 Boss 標記。
#    ・新增 F7 迷你地圖切換、F6 大型地圖切換與探索重置規則。
#    ・修正 <FS_RD_ENEMY> 未列入迷你地圖標記。
#    ・新增地圖隨機遇敵的樓層隊伍名稱標籤。
#    ・支援 <floor1>、<floor:1>、<floors:1,3>、<floors:2-4>。
#    ・修正 RGSS2 不支援 Fixnum#even? 導致最終層報錯。
#    ・Map ID 改變時自動淘汰舊布局與事件生成狀態。
#    ・保留 v0.8.0 事件池、重生規則、多樓層與水域功能。
#
# 【安裝位置】
#  放在所有地圖顯示、Overlay、Multiple Fog、ParaPassa 腳本之下，
#  Main 之上。請完整取代舊版，不要同時保留兩個版本。
#
# 【素材位置】
#  Graphics/Parallaxes/FS_Dungeon/TileA1.png
#  Graphics/Parallaxes/FS_Dungeon/TileA4.png
#  Graphics/Parallaxes/FS_Dungeon/FS_RD_VXForest_Decor_v1.png
#
#  TileA1／TileA4 維持 RPG Maker VX 內建格式。
#  Decor 圖集為 256 x 256、8 欄，每格 32 x 32；其中：
#    第 1 列前 3 格：中央地板候選。
#    第 8 列前 4 格：南側深色外壁 left/middle/right/single。
#
# 【模板地圖事件】
#    <FS_RD_START>     第 1 層入口，也可在事件頁設定離開迷宮
#    <FS_RD_UP>        第 2 層起的上樓梯，事件腳本：previous_floor
#    <FS_RD_DOWN>      非最終層的下樓梯，事件腳本：next_floor
#    <FS_RD_EXIT>      <FS_RD_DOWN> 的舊版相容別名
#    <FS_RD_BOSS>      只在最終層顯示，放在最深處
#    <FS_RD_ENEMY>     每層隨機敵人
#    <FS_RD_TREASURE>  每層隨機寶箱
#    <FS_RD_ELITE>     每層隨機菁英
#    <FS_RD_HEAL>      每層隨機恢復點
#    <FS_RD_SOUL>      每層魂刻／稀有事件
#
# 【事件池附加標籤】
#    <FS_RD_WEIGHT:50>  抽取權重，預設 100
#    <FS_RD_MAX:2>      同來源每層最多生成 2 個
#    <FS_RD_UNIQUE>     同來源每層最多生成 1 個
#    <FS_RD_NO_REPEAT>  與 UNIQUE 相同
#    <FS_RD_FIXED>     保持原座標，並保留／連接該位置地形
#    <FS_RD_CONTROL>   保持原座標，不修改地形
#    <FS_RD_SHARED>    該事件 Self Switch 不分樓層
#
#  樓層限制可附加在事件名稱：
#    <FS_RD_FIXED><FS_RD_FLOOR:2>
#    <FS_RD_ENEMY><FS_RD_FLOORS:1,3>
#    <FS_RD_CONTROL><FS_RD_FLOORS:2-4>
#
# 【進入迷宮】
#  舊流程仍可使用：
#    FS_RANDOM_DUNGEON.prepare(:field_cave_01)
#    下一個事件指令再「場所移動」到模板地圖。
#
#  也可直接使用：
#    FS_RANDOM_DUNGEON.enter(:field_cave_01)
#
#  強制重建整座迷宮：
#    FS_RANDOM_DUNGEON.enter(:field_cave_01, true)
#
#  固定測試 Seed：
#    FS_RANDOM_DUNGEON.enter(:field_cave_01, true, 123456)
#
# 【樓層事件腳本】
#    FS_RANDOM_DUNGEON.next_floor
#    FS_RANDOM_DUNGEON.previous_floor
#
# 【探索進度與重生】
#    :reset_mode => :manual
#    :reset_mode => :on_exit
#    :reset_mode => :on_clear
#    :reset_mode => :daily
#    :reset_mode => :new_seed_each_entry
#
#    軟重置（依 reset_rules）：
#      FS_RANDOM_DUNGEON.refresh(:field_cave_01)
#
#    標記通關：
#      FS_RANDOM_DUNGEON.mark_cleared
#
#    查詢：
#      FS_RANDOM_DUNGEON.cleared?
#      FS_RANDOM_DUNGEON.reset_status
#      FS_RANDOM_DUNGEON.progress_summary
#
#    完整清空（包含永久一次旗標）：
#      FS_RANDOM_DUNGEON.reset(:field_cave_01)
#
# 【事件完成 Self Switch】
#    預設使用 Self Switch A 作為完成判定。
#    可在事件名稱加入 <FS_RD_COMPLETE:B> 改用 B。
#
# 【其他】
#    FS_RANDOM_DUNGEON.current_floor
#    FS_RANDOM_DUNGEON.floor_count
#    FS_RANDOM_DUNGEON.final_floor?
#
# 【測試建議】
#  v0.8.5-FS 先使用測試存檔，確認樓層切換、讀檔與 Self Switch 分層。
#  樓梯看似只是兩格圖，實際上負責把整個狀態管理拖進地下室。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_RandomDungeon"] = "0.9.8-FS"

module FS_RandomDungeon
  VERSION = "0.9.8-FS"
  GENERATOR_SCHEMA = 13
  TILE_SIZE = 32

  #--------------------------------------------------------------------------
  # Forest Symphony / ParaPassa 第 2 層碰撞代碼
  #--------------------------------------------------------------------------
  PASS_BLOCK = 768
  PASS_OPEN  = 769
  PASS_WATER = 784

  #--------------------------------------------------------------------------
  # 邏輯格代碼（使用整數，減少存檔體積）
  #--------------------------------------------------------------------------
  CELL_VOID     = 0
  CELL_FLOOR    = 1
  CELL_WALL     = 2
  CELL_ENTRANCE = 3
  CELL_EXIT     = 4
  CELL_WATER    = 5
  CELL_BRIDGE_H = 6
  CELL_BRIDGE_V = 7

  WALKABLE_CELLS = [CELL_FLOOR, CELL_ENTRANCE, CELL_EXIT,
                    CELL_BRIDGE_H, CELL_BRIDGE_V]

  #--------------------------------------------------------------------------
  # Forest Symphony 環境詞綴
  #
  # :values 是提供其他腳本查詢的通用資料，不會擅自改寫戰鬥公式。
  # 查詢：
  #   FS_RANDOM_DUNGEON.affix?(:humid)
  #   FS_RANDOM_DUNGEON.affix_value(:water_damage_rate, 100)
  #
  # :generation 可在生成樓層時調整：
  #   :water_pool_count_bonus
  #   :event_count_bonus
  #   :skin / :water_shape / :water_irregularity 等既有生成設定
  #
  # :switches_on / :variables / :common_event_id 皆為選用。
  # ID 為 0 或空陣列時不做任何事情。
  #--------------------------------------------------------------------------
  ENVIRONMENT_AFFIXES = {
    :humid => {
      :name    => "潮濕岩層",
      :message => "水氣濃厚，水域更容易生成。",
      :values  => {
        :water_damage_rate => 110
      },
      :generation => {
        :water_pool_count_bonus => 1
      },
      :switches_on => [],
      :variables   => {}
    },

    :root_active => {
      :name    => "根域活化",
      :message => "根脈活動旺盛，草系生態反應更加明顯。",
      :values  => {
        :grass_regen_rate => 3
      },
      :generation => {
        :skin => :hikimoki_moss
      },
      :switches_on => [],
      :variables   => {}
    },

    :magnetic => {
      :name    => "磁場異常",
      :message => "機械與電氣反應受到磁場干擾。",
      :values  => {
        :robot_interval_delta => -1
      },
      :generation => {},
      :switches_on => [],
      :variables   => {}
    },

    :poison_mist => {
      :name    => "毒霧瀰漫",
      :message => "空氣中殘留毒性粒子。",
      :values  => {
        :poison_floor_damage_rate => 2
      },
      :generation => {},
      :switches_on => [],
      :variables   => {}
    },

    :soul_rich => {
      :name    => "魂響旺盛",
      :message => "魂響聚集，稀有魂刻事件更容易出現。",
      :values  => {
        :soul_event_rate => 150
      },
      :generation => {
        :event_count_bonus => {
          :soul => 1
        }
      },
      :switches_on => [],
      :variables   => {}
    }
  }

  #--------------------------------------------------------------------------
  # 迷宮設定
  # 先用一張測試模板地圖。map_id 請改成你的實際空白地圖 ID。
  #--------------------------------------------------------------------------
  DUNGEONS = {
    :field_cave_01 => {
      :map_id            => 48,
      :skin                => :hikimoki_cave,
      :floor_count         => 3,
      :width               => 40,
      :height              => 30,
      :room_count          => 8,
      :room_min_w          => 5,
      :room_max_w          => 10,
      :room_min_h          => 4,
      :room_max_h          => 8,
      :corridor_width      => 2,
      :event_margin        => 3,
      :fixed_anchor_size   => 1,
      :use_template_size   => true,
      :water_pool_count    => 2,
      :water_shape         => :organic, # :rectangle / :ellipse / :organic / :river
      :water_irregularity  => 42,       # 只影響 :organic
      :water_bridge        => true,
      :water_anim_speed    => 18,
      :resume_position     => true,
      :visual_bottom_margin => 1,

      # 房間用途系統
      :room_types_enabled  => true,
      :room_type_weights   => {
        :battle => 65,
        :empty  => 35
      },
      :room_type_limits    => {
        :treasure => 2,
        :elite    => 1,
        :heal     => 1,
        :soul     => 1
      },
      :room_event_margin   => 1,

      # 事件生成池與數量控制
      # :template = 依該類模板事件數量生成，維持舊版行為。
      # 整數      = 固定數量。
      # [min,max] = 每次生成整座迷宮時依 Seed 決定數量。
      :event_generation_enabled => true,
      :event_counts => {
        :battle   => :template,
        :treasure => :template,
        :elite    => :template,
        :heal     => :template,
        :soul     => :template
      },
      :event_counts_by_floor => {
        # 1 => { :battle => 4, :treasure => 2, :elite => 0,
        #        :heal => 1, :soul => 1 },
        # 2 => { :battle => [4, 6], :treasure => 2, :elite => 1,
        #        :heal => 1, :soul => 1 }
      },
      :event_pools => {
        # 可省略，省略時自動使用模板地圖上相同標籤的事件。
        # :battle => [
        #   [12, 100, 3], # [模板 Event ID, 權重, 每層上限]
        #   [13,  40, 1]
        # ]
      },
      :pool_allow_repeat   => true,
      :max_generated_events => 40,

      # 探索進度與重生規則
      # 模式只決定「何時啟動重置週期」，rules 決定「重置什麼」。
      :reset_mode => :manual, # :manual / :on_exit / :on_clear / :daily / :new_seed_each_entry
      :reset_rules => {
        :rebuild_layout          => false,
        :new_seed_on_rebuild     => true,
        :reset_treasure          => false,
        :respawn_battle          => true,
        :respawn_elite           => false,
        :reset_heal              => true,
        :reset_soul              => false,
        :reset_boss              => false,
        :preserve_floor_progress => true,
        :reroll_event_pool       => false,
        :reset_exploration       => false
      },
      :soul_once => true,
      :boss_once => true,
      :once_scope => {
        :soul => :event, # :dungeon / :floor / :source / :event
        :boss => :floor
      },
      :completion_self_switch => {
        :battle   => "A",
        :treasure => "A",
        :elite    => "A",
        :heal     => "A",
        :soul     => "A",
        :boss     => "A"
      },
      :auto_clear_on_boss => true,

      #==============================================================
      # Forest Symphony 專屬整合
      #==============================================================

      # 樓層提示。使用目前專案的 Message Queue：
      #   $game_map.queue.push("文字")
      :dungeon_display_name => "原野小洞穴",
      :floor_display_names => {
        1 => "潮濕外緣",
        2 => "苔蘚深層",
        3 => "魂響核心"
      },
      :danger_by_floor => {
        1 => 1,
        2 => 2,
        3 => 3
      },
      :floor_notice_mode => :first_visit, # :always / :first_visit / :never
      :show_affix_notice => false,

      # HUD 開啟時，預設不再播放樓層 Queue，避免兩者疊在左上角。
      # 若要同時顯示，改為 true，並建議把 HUD 移到右上或下方。
      :show_floor_notice_with_hud => false,

      # 常駐迷宮進度 HUD
      # 可用標記：
      # %dungeon% / %floor% / %total% / %progress%
      # %floor_name% / %affixes% / %danger%
      :progress_hud_enabled         => true,
      :progress_hud_anchor          => :top_left, # :top_left / :top_right / :bottom_left / :bottom_right
      :progress_hud_offset_x        => 8,
      :progress_hud_offset_y        => 8,
      :progress_hud_width           => 310,
      :progress_hud_height          => 58,
      :progress_hud_opacity         => 170,
      :progress_hud_font_size       => 18,
      :progress_hud_title_format    => "%dungeon%｜%progress%",
      :progress_hud_progress_format => "%floor%/%total%",
      :progress_hud_affix_format    => "環境：%affixes%",
      :progress_hud_empty_affix     => "無特殊環境",
      :progress_hud_show_danger     => true,

      #==============================================================
      # v0.9.0 探索地圖、迷你地圖與戰爭迷霧
      #==============================================================

      # 迷你地圖
      :minimap_enabled               => true,
      :minimap_default_visible       => true,
      :minimap_anchor                => :top_right,
      :minimap_offset_x              => 8,
      :minimap_offset_y              => 8,
      :minimap_width                 => 178,
      :minimap_height                => 138,
      :minimap_opacity               => 185,
      :minimap_padding               => 7,
      :minimap_toggle_key            => :F7,

      # 大型地圖
      :fullmap_toggle_key             => :F6,
      :fullmap_width                  => 470,
      :fullmap_height                 => 350,
      :fullmap_opacity                => 225,

      # 探索揭露
      :exploration_reveal_radius      => 2,
      :exploration_reveal_room        => true,
      :exploration_room_border        => 1,

      # 標記
      :minimap_show_player            => true,
      :minimap_show_entrance          => true,
      :minimap_show_exit              => true,
      :minimap_exit_requires_explored => true,
      :minimap_marker_requires_explored => true,
      :minimap_hide_completed_events  => true,
      :minimap_show_events            => [
        :battle, :treasure, :elite, :heal, :soul, :boss
      ],

      # 實際畫面戰爭迷霧。
      # 預設關閉，只在迷你地圖隱藏未探索區。
      :fog_of_war_enabled             => false,
      :fog_of_war_opacity             => 255,
      :fog_of_war_z                   => 999,

      #==============================================================
      # 地圖隨機遇敵的樓層篩選
      #==============================================================
      # Map 48 的敵人隊伍清單與平均遇敵步數會正常使用。
      # 敵人隊伍名稱範例：
      #   <floor1>妙蛙種子*3
      #   <floor:2>綠毛蟲*3
      #   <floors:1,3>拉達
      #   <floors:2-4>菁英隊伍
      :floor_encounter_filter_enabled  => true,
      :untagged_encounters_all_floors  => true,

      # 固定詞綴優先；沒有設定的樓層才會由 affix_pool 抽取。
      :floor_affixes => {
        1 => [:humid],
        2 => [:root_active],
        3 => [:soul_rich]
      },
      :affix_pool => [
        [:humid,      35],
        [:root_active,25],
        [:magnetic,   15],
        [:poison_mist,10],
        [:soul_rich,  15]
      ],
      :affixes_per_floor => 1,

      # Boss 房安全鎖
      :boss_safety_enabled       => true,
      :boss_safe_width           => 7,
      :boss_safe_height          => 7,
      :boss_remove_water         => true,
      :boss_event_exclusion      => 3,

      # 生成失敗自動重試
      :max_generate_attempts     => 12,
      :min_generated_rooms       => 2,
      :raise_on_generate_failure => false,

      # Debug 視覺模式，正式版建議 false。
      :debug_visual_enabled      => false,
      :debug_toggle_key          => :F8,
      :debug_show_collision      => false,

      # 範例：三層分別展示三種水岸風格。
      # 正式使用時可依迷宮需求自由修改。
      :floor_overrides => {
        2 => {
          :skin               => :hikimoki_moss,
          :water_shape        => :organic,
          :water_irregularity => 55
        },
        3 => {
          :skin               => :hikimoki_river,
          :water_shape        => :river,
          :water_pool_count   => 1
        }
      }
    }
  }

  #--------------------------------------------------------------------------
  # 圖集設定（8 欄，每格 32 x 32）
  # 座標格式：[欄, 列]
  #--------------------------------------------------------------------------
  V5_TILE_MAP = {
        :void             => [0, 0],
        :floor            => [1, 0],
        :floor_alt_1      => [2, 0],
        :floor_alt_2      => [3, 0],
        :wall_n           => [4, 0],
        :wall_s           => [5, 0],
        :wall_w           => [6, 0],
        :wall_e           => [7, 0],
        :corner_nw        => [0, 1],
        :corner_ne        => [1, 1],
        :corner_sw        => [2, 1],
        :corner_se        => [3, 1],
        :upper_wall       => [4, 1],
        :entrance         => [5, 1],
        :exit             => [6, 1],
        :water            => [7, 1],
        :bridge_h         => [0, 2],
        :bridge_v         => [1, 2],
        :deco_crack       => [2, 2],
        :deco_pebbles     => [3, 2],
        :deco_moss        => [4, 2],
        :deco_crystal     => [5, 2],
        :marker_enemy     => [6, 2],
        :marker_treasure  => [7, 2],
        :water_frame_0    => [0, 3],
        :water_frame_1    => [1, 3],
        :water_frame_2    => [2, 3],
        :stair_up         => [3, 3],
        :stair_down       => [4, 3],
        :boss_seal        => [5, 3],
        :shore_n          => [0, 4],
        :shore_s          => [1, 4],
        :shore_w          => [2, 4],
        :shore_e          => [3, 4],
        :shore_nw         => [4, 4],
        :shore_ne         => [5, 4],
        :shore_sw         => [6, 4],
        :shore_se         => [7, 4],
        :shore_inner_nw   => [0, 5],
        :shore_inner_ne   => [1, 5],
        :shore_inner_sw   => [2, 5],
        :shore_inner_se   => [3, 5],
        :shore_pebbles    => [4, 5],
        :shore_moss       => [5, 5],
        :shore_crystal    => [6, 5],
        :shore_reeds      => [7, 5],
        :bridge_h_left    => [0, 6],
        :bridge_h_right   => [1, 6],
        :bridge_v_top     => [2, 6],
        :bridge_v_bottom  => [3, 6],
        :room_battle      => [4, 6],
        :room_treasure    => [5, 6],
        :room_elite       => [6, 6],
        :room_heal        => [7, 6]
      }

  SKINS = {
    :cave_rock => {
      :atlas => "FS_Dungeon/FS_RD_CaveRock_v6",
      :cols  => 8,
      :tiles => V5_TILE_MAP,
      :water_frames => [:water_frame_0, :water_frame_1, :water_frame_2],
      :shore_decor => {
        :shore_pebbles => 24,
        :shore_moss    => 8,
        :shore_crystal => 3,
        :shore_reeds   => 0
      }
    },
    :moss_cave => {
      :atlas => "FS_Dungeon/FS_RD_MossCave_v6",
      :cols  => 8,
      :tiles => V5_TILE_MAP,
      :water_frames => [:water_frame_0, :water_frame_1, :water_frame_2],
      :shore_decor => {
        :shore_pebbles => 10,
        :shore_moss    => 32,
        :shore_crystal => 3,
        :shore_reeds   => 5
      }
    },
    :underground_river => {
      :atlas => "FS_Dungeon/FS_RD_UndergroundRiver_v6",
      :cols  => 8,
      :tiles => V5_TILE_MAP,
      :water_frames => [:water_frame_0, :water_frame_1, :water_frame_2],
      :shore_decor => {
        :shore_pebbles => 22,
        :shore_moss    => 12,
        :shore_crystal => 1,
        :shore_reeds   => 12
      }
    }
  }

  #==========================================================================
  # ■ v0.9.8 魔王狩獵／ひきも記式高度拓撲 Skin
  #--------------------------------------------------------------------------
  # 牆體不再從每一格「猜方向」。Renderer 先建立完整高度拓撲：
  #   北側：黑色 → A4 牆頂 → A4 牆面 → 地板
  #   左右：黑色 → A4 牆頂 → 地板
  #   南側：地板 → A4 牆頂 → A4 牆面 → 深色外壁 → 黑色
  #--------------------------------------------------------------------------
  HIKIMOKI_COMMON = {
    :renderer              => :hikimoki_height,
    :cols                  => 8,
    :tiles                 => V5_TILE_MAP,
    :vx_tilesheets         => {
      :a1 => "FS_Dungeon/TileA1",
      :a4 => "FS_Dungeon/TileA4"
    },
    :floor_atlas           => {
      :tiles   => [:floor, :floor_alt_1, :floor_alt_2],
      :weights => [75, 16, 9]
    },
    :outer_bottom_atlas    => {
      :left   => [0, 7],
      :middle => [1, 7],
      :right  => [2, 7],
      :single => [3, 7]
    },
    :void_color            => [0, 0, 0, 255],
    :use_floor_decor       => true
  }

  def self.hikimoki_skin(extra)
    result = {}
    HIKIMOKI_COMMON.each { |key, value| result[key] = value }
    extra.each { |key, value| result[key] = value }
    return result
  end

  SKINS[:hikimoki_cave] = hikimoki_skin({
    :decor_atlas => "FS_Dungeon/FS_RD_VXForest_Decor_v1",
    :wall_top_autotile => {
      :sheet => :a4, :block => [6, 0], :section => :ceiling,
      :mode => :floor
    },
    :wall_face_autotile => {
      :sheet => :a4, :block => [6, 0], :section => :wall,
      :mode => :wall
    },
    :water_autotile => {
      :sheet => :a1,
      :origins => [[0, 0], [64, 0], [128, 0]],
      :mode => :floor
    }
  })

  SKINS[:hikimoki_moss] = hikimoki_skin({
    :decor_atlas => "FS_Dungeon/FS_RD_VXMoss_Decor_v1",
    :floor_atlas => {
      :tiles => [:floor, :floor_alt_1, :floor_alt_2],
      :weights => [68, 22, 10]
    },
    :wall_top_autotile => {
      :sheet => :a4, :block => [1, 0], :section => :ceiling,
      :mode => :floor
    },
    :wall_face_autotile => {
      :sheet => :a4, :block => [1, 0], :section => :wall,
      :mode => :wall
    },
    :water_autotile => {
      :sheet => :a1,
      :origins => [[256, 0], [320, 0], [384, 0]],
      :mode => :floor
    }
  })

  SKINS[:hikimoki_river] = hikimoki_skin({
    :decor_atlas => "FS_Dungeon/FS_RD_VXRiver_Decor_v1",
    :floor_atlas => {
      :tiles => [:floor, :floor_alt_1, :floor_alt_2],
      :weights => [72, 18, 10]
    },
    :wall_top_autotile => {
      :sheet => :a4, :block => [4, 2], :section => :ceiling,
      :mode => :floor
    },
    :wall_face_autotile => {
      :sheet => :a4, :block => [4, 2], :section => :wall,
      :mode => :wall
    },
    :water_autotile => {
      :sheet => :a1,
      :origins => [[0, 192], [64, 192], [128, 192]],
      :mode => :floor
    }
  })

  # 舊 Skin 名稱直接轉向新 Renderer，避免自訂設定因名稱沒改而失去牆體。
  SKINS[:cave_rock] = SKINS[:hikimoki_cave]
  SKINS[:moss_cave] = SKINS[:hikimoki_moss]
  SKINS[:underground_river] = SKINS[:hikimoki_river]
  SKINS[:cave_01] = SKINS[:hikimoki_cave]

  #==========================================================================
  # ■ RNG
  #--------------------------------------------------------------------------
  # Ruby 1.8 沒有可攜式 Random 物件，因此使用獨立 LCG。
  # 不呼叫 Kernel.srand，避免改變專案其他亂數行為。
  #==========================================================================
  class RNG
    def initialize(seed)
      @state = seed.to_i & 0x7fffffff
      @state = 1 if @state == 0
    end

    def rand(max = nil)
      @state = (1103515245 * @state + 12345) & 0x7fffffff
      if max == nil
        return @state.to_f / 2147483648.0
      end
      return 0 if max.to_i <= 0
      return @state % max.to_i
    end

    def range(min, max)
      min = min.to_i
      max = max.to_i
      return min if max <= min
      return min + rand(max - min + 1)
    end
  end

  #==========================================================================
  # ■ BSPBox / Room
  #==========================================================================
  class BSPBox
    attr_accessor :x, :y, :w, :h
    def initialize(x, y, w, h)
      @x, @y, @w, @h = x, y, w, h
    end

    def area
      @w * @h
    end
  end

  class Room < BSPBox
    def center_x
      @x + @w / 2
    end

    def center_y
      @y + @h / 2
    end
  end

  #==========================================================================
  # ■ Generator
  #==========================================================================
  class Generator
    attr_reader :layout, :rooms, :entrance, :exit_pos,
                :room_types, :room_depths, :room_links

    def initialize(config, seed)
      @config = config
      @seed = seed.to_i
      @rng = RNG.new(@seed)
      @width = [config[:width].to_i, 17].max
      @height = [config[:height].to_i, 15].max
      @layout = Array.new(@width * @height, CELL_VOID)
      @rooms = []
      @room_links = {}
      @room_types = {}
      @room_depths = {}
      @fixed_anchors = config[:fixed_anchors] || {}
      @fixed_event_positions = {}
      @entrance = [1, 1]
      @exit_pos = [@width - 2, @height - 2]
    end

    def generate
      rects = split_areas
      create_rooms(rects)
      connect_rooms
      connect_fixed_anchors
      create_water_pools
      surround_with_walls
      choose_entrance_and_exit
      protect_boss_room
      surround_with_walls
      classify_rooms
      return {
        :width      => @width,
        :height     => @height,
        :layout     => @layout,
        :rooms                 => @rooms.collect { |r| [r.x, r.y, r.w, r.h] },
        :room_types            => room_type_array,
        :room_depths           => room_depth_array,
        :room_links            => normalized_room_links,
        :entrance              => @entrance,
        :exit                  => @exit_pos,
        :fixed_event_positions => @fixed_event_positions
      }
    end

    def index(x, y)
      x + y * @width
    end

    def inside?(x, y)
      x >= 0 && y >= 0 && x < @width && y < @height
    end

    def cell(x, y)
      return CELL_VOID unless inside?(x, y)
      @layout[index(x, y)]
    end

    def set_cell(x, y, value)
      return unless inside?(x, y)
      @layout[index(x, y)] = value
    end

    def split_areas
      target = [@config[:room_count].to_i, 2].max
      # v0.9.7：預留南側牆頂、牆面與深色外壁所需空間。
      # 房間本身仍使用原座標系，不增加地圖尺寸。
      bottom_margin = @config[:visual_bottom_margin].to_i
      bottom_margin = 1 if bottom_margin <= 0
      usable_h = @height - 2 - bottom_margin
      usable_h = @height - 2 if usable_h < 8
      rects = [BSPBox.new(1, 1, @width - 2, usable_h)]
      attempts = 0
      while rects.size < target && attempts < target * 20
        attempts += 1
        rects.sort! { |a, b| b.area <=> a.area }
        source = nil
        rects.each do |r|
          if splittable?(r)
            source = r
            break
          end
        end
        break if source == nil
        pair = split_rect(source)
        if pair == nil
          next
        end
        rects.delete(source)
        rects.push(pair[0])
        rects.push(pair[1])
      end
      return rects
    end

    def splittable?(rect)
      min_w = @config[:room_min_w].to_i + 4
      min_h = @config[:room_min_h].to_i + 4
      return true if rect.w >= min_w * 2
      return true if rect.h >= min_h * 2
      return false
    end

    def split_rect(rect)
      min_w = @config[:room_min_w].to_i + 4
      min_h = @config[:room_min_h].to_i + 4
      can_v = rect.w >= min_w * 2
      can_h = rect.h >= min_h * 2
      return nil unless can_v || can_h

      vertical = false
      if can_v && can_h
        if rect.w > rect.h * 1.25
          vertical = true
        elsif rect.h > rect.w * 1.25
          vertical = false
        else
          vertical = (@rng.rand(2) == 0)
        end
      else
        vertical = can_v
      end

      if vertical
        cut_min = min_w
        cut_max = rect.w - min_w
        return nil if cut_max < cut_min
        cut = @rng.range(cut_min, cut_max)
        return [BSPBox.new(rect.x, rect.y, cut, rect.h),
                BSPBox.new(rect.x + cut, rect.y, rect.w - cut, rect.h)]
      else
        cut_min = min_h
        cut_max = rect.h - min_h
        return nil if cut_max < cut_min
        cut = @rng.range(cut_min, cut_max)
        return [BSPBox.new(rect.x, rect.y, rect.w, cut),
                BSPBox.new(rect.x, rect.y + cut, rect.w, rect.h - cut)]
      end
    end

    def create_rooms(rects)
      min_w = [@config[:room_min_w].to_i, 3].max
      max_w = [@config[:room_max_w].to_i, min_w].max
      min_h = [@config[:room_min_h].to_i, 3].max
      max_h = [@config[:room_max_h].to_i, min_h].max

      rects.each do |rect|
        room_max_w = [max_w, rect.w - 2].min
        room_max_h = [max_h, rect.h - 2].min
        room_min_w = [min_w, room_max_w].min
        room_min_h = [min_h, room_max_h].min
        next if room_max_w < 3 || room_max_h < 3

        rw = @rng.range(room_min_w, room_max_w)
        rh = @rng.range(room_min_h, room_max_h)
        rx_min = rect.x + 1
        ry_min = rect.y + 1
        rx_max = rect.x + rect.w - rw - 1
        ry_max = rect.y + rect.h - rh - 1
        rx = @rng.range(rx_min, [rx_max, rx_min].max)
        ry = @rng.range(ry_min, [ry_max, ry_min].max)
        room = Room.new(rx, ry, rw, rh)
        @rooms.push(room)
        @room_links[@rooms.size - 1] ||= []
        carve_room(room)
      end

      if @rooms.size < 2
        fallback_rooms
      end
    end

    def fallback_rooms
      @rooms.clear
      rw = [@width / 3, 5].max
      rh = [@height / 3, 4].max
      r1 = Room.new(2, 2, rw, rh)
      r2 = Room.new(@width - rw - 2, @height - rh - 3, rw, rh)
      @rooms.push(r1)
      @rooms.push(r2)
      @room_links = { 0 => [], 1 => [] }
      carve_room(r1)
      carve_room(r2)
    end

    def carve_room(room)
      for y in room.y...(room.y + room.h)
        for x in room.x...(room.x + room.w)
          set_cell(x, y, CELL_FLOOR)
        end
      end
    end

    def connect_rooms
      connected = [@rooms[0]]
      remaining = @rooms[1, @rooms.size - 1] || []
      while remaining.size > 0
        best_a = nil
        best_b = nil
        best_distance = 999999
        connected.each do |a|
          remaining.each do |b|
            d = (a.center_x - b.center_x).abs + (a.center_y - b.center_y).abs
            if d < best_distance
              best_distance = d
              best_a = a
              best_b = b
            end
          end
        end
        carve_corridor(best_a.center_x, best_a.center_y,
                       best_b.center_x, best_b.center_y)
        link_rooms(@rooms.index(best_a), @rooms.index(best_b))
        connected.push(best_b)
        remaining.delete(best_b)
      end
    end

    def link_rooms(a, b)
      return if a == nil || b == nil || a == b
      @room_links[a] ||= []
      @room_links[b] ||= []
      @room_links[a].push(b) unless @room_links[a].include?(b)
      @room_links[b].push(a) unless @room_links[b].include?(a)
    end

    def normalized_room_links
      result = {}
      for i in 0...@rooms.size
        result[i] = (@room_links[i] || []).sort
      end
      return result
    end

    def room_index_for_position(pos)
      return nil if pos == nil
      x = pos[0].to_i
      y = pos[1].to_i
      @rooms.each_with_index do |room, index_id|
        if x >= room.x && x < room.x + room.w &&
           y >= room.y && y < room.y + room.h
          return index_id
        end
      end

      best = nil
      best_distance = 999999
      @rooms.each_with_index do |room, index_id|
        distance = (room.center_x - x).abs + (room.center_y - y).abs
        if distance < best_distance
          best = index_id
          best_distance = distance
        end
      end
      return best
    end

    def room_graph_distances(start_id)
      distance = {}
      return distance if start_id == nil
      queue = [start_id]
      distance[start_id] = 0
      head = 0
      while head < queue.size
        current = queue[head]
        head += 1
        (@room_links[current] || []).each do |next_id|
          next if distance.has_key?(next_id)
          distance[next_id] = distance[current] + 1
          queue.push(next_id)
        end
      end
      return distance
    end

    def classify_rooms
      return if @rooms.empty?
      for i in 0...@rooms.size
        @room_links[i] ||= []
      end

      entrance_id = room_index_for_position(@entrance)
      exit_id = room_index_for_position(@exit_pos)
      distances = room_graph_distances(entrance_id)
      max_distance = 1
      distances.each_value { |value| max_distance = value if value > max_distance }

      for i in 0...@rooms.size
        value = distances[i] || 0
        @room_depths[i] = value.to_f / max_distance.to_f
      end

      @room_types[entrance_id] = :entrance if entrance_id != nil
      if exit_id != nil
        final_floor = @config[:floor].to_i >= @config[:floor_count].to_i
        @room_types[exit_id] = final_floor ? :boss : :stairs
      end

      available = []
      for i in 0...@rooms.size
        next if i == entrance_id || i == exit_id
        available.push(i)
      end

      unless @config[:room_types_enabled] == false
        counts = @config[:room_event_counts] || {}
        limits = @config[:room_type_limits] || {}
        [:treasure, :elite, :heal, :soul].each do |type|
          requested = counts[type].to_i
          next if requested <= 0
          limit = limits[type] == nil ? requested : limits[type].to_i
          limit = 0 if limit < 0
          target = [requested, limit, available.size].min
          target.times do
            room_id = best_room_for_type(type, available)
            break if room_id == nil
            @room_types[room_id] = type
            available.delete(room_id)
          end
        end

        # 有敵人事件時至少保留一個戰鬥房。
        if counts[:battle].to_i > 0 && available.size > 0
          room_id = best_room_for_type(:battle, available)
          if room_id != nil
            @room_types[room_id] = :battle
            available.delete(room_id)
          end
        end
      end

      available.each do |room_id|
        @room_types[room_id] = weighted_basic_room_type
      end
    end

    def best_room_for_type(type, candidates)
      best = nil
      best_score = -999999
      candidates.each do |room_id|
        depth = (@room_depths[room_id] || 0.0) * 100.0
        degree = (@room_links[room_id] || []).size
        dead_end_bonus = degree <= 1 ? 45 : 0
        noise = @rng.rand(21)
        score = noise

        case type
        when :treasure
          score += depth * 1.15 + dead_end_bonus
        when :elite
          score += depth * 1.40
          score -= 80 if depth < 35
        when :heal
          score += 100 - ((depth - 62).abs * 1.5)
          score -= 35 if degree <= 1
        when :soul
          score += depth * 1.35 + dead_end_bonus * 1.2
        when :battle
          score += depth * 0.55
        end

        if score > best_score
          best = room_id
          best_score = score
        end
      end
      return best
    end

    def weighted_basic_room_type
      weights = @config[:room_type_weights] || {}
      battle = weights[:battle].to_i
      empty = weights[:empty].to_i
      battle = 65 if battle <= 0 && empty <= 0
      empty = 35 if battle <= 0 && empty <= 0
      total = battle + empty
      return :empty if total <= 0
      value = @rng.rand(total)
      return value < battle ? :battle : :empty
    end

    def room_type_array
      result = []
      for i in 0...@rooms.size
        result.push(@room_types[i] || :empty)
      end
      return result
    end

    def room_depth_array
      result = []
      for i in 0...@rooms.size
        result.push(@room_depths[i] || 0.0)
      end
      return result
    end

    def carve_corridor(x1, y1, x2, y2)
      width = [[@config[:corridor_width].to_i, 1].max, 3].min
      if @rng.rand(2) == 0
        carve_h_line(x1, x2, y1, width)
        carve_v_line(y1, y2, x2, width)
      else
        carve_v_line(y1, y2, x1, width)
        carve_h_line(x1, x2, y2, width)
      end
    end

    def carve_h_line(x1, x2, y, width)
      min_x = [x1, x2].min
      max_x = [x1, x2].max
      offset = -(width / 2)
      for x in min_x..max_x
        for i in 0...width
          set_cell(x, y + offset + i, CELL_FLOOR)
        end
      end
    end

    def carve_v_line(y1, y2, x, width)
      min_y = [y1, y2].min
      max_y = [y1, y2].max
      offset = -(width / 2)
      for y in min_y..max_y
        for i in 0...width
          set_cell(x + offset + i, y, CELL_FLOOR)
        end
      end
    end

    #----------------------------------------------------------------------
    # 固定事件錨點
    # <FS_RD_FIXED> 不只固定事件座標，也保留該位置的地板並接回主迷宮。
    # 若事件放在最外圈，會向內修正一格，避免事件位於地圖界外。
    #----------------------------------------------------------------------
    def connect_fixed_anchors
      return if @fixed_anchors == nil || @fixed_anchors.empty?
      ids = @fixed_anchors.keys.sort
      ids.each do |event_id|
        original = @fixed_anchors[event_id]
        next if original == nil
        x = [[original[0].to_i, 1].max, @width - 2].min
        y = [[original[1].to_i, 1].max, @height - 2].min
        carve_fixed_anchor(x, y)

        nearest = nearest_room_to(x, y)
        if nearest != nil
          carve_corridor(x, y, nearest.center_x, nearest.center_y)
        end
        @fixed_event_positions[event_id] = [x, y]
      end
    end

    def carve_fixed_anchor(cx, cy)
      radius = @config[:fixed_anchor_size].to_i
      radius = 0 if radius < 0
      radius = 2 if radius > 2
      for y in (cy - radius)..(cy + radius)
        for x in (cx - radius)..(cx + radius)
          next if x <= 0 || y <= 0
          next if x >= @width - 1 || y >= @height - 1
          set_cell(x, y, CELL_FLOOR)
        end
      end
    end

    def nearest_room_to(x, y)
      best = nil
      best_distance = 999999
      @rooms.each do |room|
        distance = (room.center_x - x).abs + (room.center_y - y).abs
        if distance < best_distance
          best = room
          best_distance = distance
        end
      end
      return best
    end

    #----------------------------------------------------------------------
    # 水域生成
    # 支援 :ellipse / :organic / :river。
    # 生成後只保留最大的連通水域，避免零碎孤立水格。
    #----------------------------------------------------------------------
    def create_water_pools
      count = @config[:water_pool_count].to_i
      return if count <= 0
      candidates = @rooms.select { |room| room.w >= 6 && room.h >= 6 }
      return if candidates.empty?

      used = {}
      made = 0
      attempts = 0
      max_attempts = [candidates.size * 6, 12].max
      while made < count && attempts < max_attempts
        attempts += 1
        room = candidates[@rng.rand(candidates.size)]
        next if used[room.object_id]
        used[room.object_id] = true
        next if room_contains_fixed_anchor?(room)
        made += 1 if carve_water_pool(room)
      end
    end

    def room_contains_fixed_anchor?(room)
      @fixed_event_positions.each_value do |pos|
        return true if pos[0] >= room.x && pos[0] < room.x + room.w &&
                       pos[1] >= room.y && pos[1] < room.y + room.h
      end
      return false
    end

    def carve_water_pool(room)
      left   = room.x + 1
      right  = room.x + room.w - 2
      top    = room.y + 1
      bottom = room.y + room.h - 2
      return false if right - left < 2 || bottom - top < 2

      shape = @config[:water_shape] || :organic
      mask = {}
      axis = nil

      case shape
      when :rectangle
        mask = build_rectangle_water_mask(left, right, top, bottom)
      when :ellipse
        mask = build_ellipse_water_mask(left, right, top, bottom)
      when :river
        mask, axis = build_river_water_mask(left, right, top, bottom)
      else
        mask = build_organic_water_mask(left, right, top, bottom)
      end

      mask = largest_water_component(mask)
      return false if mask.size < 6

      mask.each_key do |key|
        x = key % @width
        y = key / @width
        set_cell(x, y, CELL_WATER)
      end

      if @config[:water_bridge] != false
        place_water_bridge(mask, room, axis)
      end
      return true
    end

    def build_rectangle_water_mask(left, right, top, bottom)
      mask = {}
      for y in top..bottom
        for x in left..right
          mask[index(x, y)] = true
        end
      end
      return mask
    end

    def build_ellipse_water_mask(left, right, top, bottom)
      mask = {}
      cx = (left + right) / 2.0
      cy = (top + bottom) / 2.0
      rx = [(right - left + 1) / 2.0, 1.0].max
      ry = [(bottom - top + 1) / 2.0, 1.0].max
      for y in top..bottom
        for x in left..right
          dx = (x - cx) / rx
          dy = (y - cy) / ry
          mask[index(x, y)] = true if dx * dx + dy * dy <= 0.92
        end
      end
      return mask
    end

    def build_organic_water_mask(left, right, top, bottom)
      mask = {}
      cx = (left + right) / 2.0
      cy = (top + bottom) / 2.0
      rx = [(right - left + 1) / 2.0, 1.0].max
      ry = [(bottom - top + 1) / 2.0, 1.0].max
      irregularity = @config[:water_irregularity].to_i
      irregularity = 0 if irregularity < 0
      irregularity = 80 if irregularity > 80

      for y in top..bottom
        for x in left..right
          dx = (x - cx) / rx
          dy = (y - cy) / ry
          distance = dx * dx + dy * dy
          noise = coordinate_noise(x, y, 911)
          threshold = 0.78 + ((noise - 50) * irregularity / 5000.0)
          mask[index(x, y)] = true if distance <= threshold
        end
      end

      # 兩次鄰居平滑，將鋸齒變成較自然的洞穴水岸。
      2.times do
        next_mask = {}
        for y in top..bottom
          for x in left..right
            neighbors = water_mask_neighbor_count(mask, x, y)
            key = index(x, y)
            if mask[key]
              next_mask[key] = true if neighbors >= 3
            else
              next_mask[key] = true if neighbors >= 5
            end
          end
        end
        mask = next_mask
      end

      # 中央必定保留，避免平滑後整池消失。
      mask[index(cx.to_i, cy.to_i)] = true
      return mask
    end

    def build_river_water_mask(left, right, top, bottom)
      mask = {}
      horizontal = (right - left) >= (bottom - top)
      horizontal = @rng.rand(2) == 0 if (right - left - (bottom - top)).abs <= 2

      if horizontal
        center = (top + bottom) / 2
        radius = [(bottom - top + 1) / 4, 1].max
        for x in left..right
          if x > left && x < right && @rng.rand(100) < 38
            center += @rng.rand(3) - 1
          end
          center = top + radius if center < top + radius
          center = bottom - radius if center > bottom - radius
          for y in (center - radius)..(center + radius)
            next if y < top || y > bottom
            mask[index(x, y)] = true
          end
          if @rng.rand(100) < 24
            extra_y = center + (@rng.rand(2) == 0 ? -radius - 1 : radius + 1)
            mask[index(x, extra_y)] = true if extra_y >= top && extra_y <= bottom
          end
        end
        return [mask, :horizontal]
      else
        center = (left + right) / 2
        radius = [(right - left + 1) / 4, 1].max
        for y in top..bottom
          if y > top && y < bottom && @rng.rand(100) < 38
            center += @rng.rand(3) - 1
          end
          center = left + radius if center < left + radius
          center = right - radius if center > right - radius
          for x in (center - radius)..(center + radius)
            next if x < left || x > right
            mask[index(x, y)] = true
          end
          if @rng.rand(100) < 24
            extra_x = center + (@rng.rand(2) == 0 ? -radius - 1 : radius + 1)
            mask[index(extra_x, y)] = true if extra_x >= left && extra_x <= right
          end
        end
        return [mask, :vertical]
      end
    end

    def coordinate_noise(x, y, salt = 0)
      value = (x * 73856093) ^ (y * 19349663) ^ (@seed * 83492791) ^ salt
      return (value & 0x7fffffff) % 100
    end

    def water_mask_neighbor_count(mask, x, y)
      count = 0
      for dy in -1..1
        for dx in -1..1
          next if dx == 0 && dy == 0
          count += 1 if mask[index(x + dx, y + dy)]
        end
      end
      return count
    end

    def largest_water_component(mask)
      visited = {}
      largest = {}
      mask.each_key do |start_key|
        next if visited[start_key]
        component = {}
        queue = [start_key]
        visited[start_key] = true
        until queue.empty?
          key = queue.shift
          component[key] = true
          x = key % @width
          y = key / @width
          [[1,0],[-1,0],[0,1],[0,-1]].each do |dir|
            nkey = index(x + dir[0], y + dir[1])
            next unless mask[nkey]
            next if visited[nkey]
            visited[nkey] = true
            queue.push(nkey)
          end
        end
        largest = component if component.size > largest.size
      end
      return largest
    end

    def place_water_bridge(mask, room, axis_hint = nil)
      if axis_hint == :horizontal
        place_vertical_bridge(mask, room)
      elsif axis_hint == :vertical
        place_horizontal_bridge(mask, room)
      elsif room.w >= room.h
        place_vertical_bridge(mask, room)
      else
        place_horizontal_bridge(mask, room)
      end
    end

    def place_vertical_bridge(mask, room)
      center_x = room.center_x
      best_x = nil
      best_count = 0
      for x in (center_x - 2)..(center_x + 2)
        next if x <= room.x || x >= room.x + room.w - 1
        ys = []
        mask.each_key do |key|
          ys.push(key / @width) if key % @width == x
        end
        if ys.size > best_count
          best_count = ys.size
          best_x = x
        end
      end
      return if best_x == nil || best_count < 2
      ys = []
      mask.each_key { |key| ys.push(key / @width) if key % @width == best_x }
      for y in ys.min..ys.max
        set_cell(best_x, y, CELL_BRIDGE_V)
      end
    end

    def place_horizontal_bridge(mask, room)
      center_y = room.center_y
      best_y = nil
      best_count = 0
      for y in (center_y - 2)..(center_y + 2)
        next if y <= room.y || y >= room.y + room.h - 1
        xs = []
        mask.each_key do |key|
          xs.push(key % @width) if key / @width == y
        end
        if xs.size > best_count
          best_count = xs.size
          best_y = y
        end
      end
      return if best_y == nil || best_count < 2
      xs = []
      mask.each_key { |key| xs.push(key % @width) if key / @width == best_y }
      for x in xs.min..xs.max
        set_cell(x, best_y, CELL_BRIDGE_H)
      end
    end

    def surround_with_walls
      new_layout = @layout.clone
      for y in 0...@height
        for x in 0...@width
          next unless cell(x, y) == CELL_VOID
          if neighbor_walkable?(x, y)
            new_layout[index(x, y)] = CELL_WALL
          end
        end
      end
      @layout = new_layout
    end

    def neighbor_walkable?(x, y)
      for dy in -1..1
        for dx in -1..1
          next if dx == 0 && dy == 0
          return true if walkable_cell?(cell(x + dx, y + dy))
        end
      end
      return false
    end

    def walkable_cell?(value)
      WALKABLE_CELLS.include?(value)
    end

    def choose_entrance_and_exit
      start = [@rooms[0].center_x, @rooms[0].center_y]
      forbidden = {}
      @fixed_event_positions.each_value { |pos| forbidden[index(pos[0], pos[1])] = true }
      first = bfs_farthest(start[0], start[1], forbidden)
      second = bfs_farthest(first[0], first[1], forbidden)
      @entrance = [first[0], first[1]]
      @exit_pos = [second[0], second[1]]
      set_cell(@entrance[0], @entrance[1], CELL_ENTRANCE)
      set_cell(@exit_pos[0], @exit_pos[1], CELL_EXIT)
    end

    #----------------------------------------------------------------------
    # Boss 房安全鎖
    # 最終層將出口周圍整理成固定大小的安全區，移除水與橋，
    # 確保 Boss、劇情、戰後出口不會擠在牆角。
    #----------------------------------------------------------------------
    def protect_boss_room
      return if @config[:boss_safety_enabled] == false
      return unless @config[:floor].to_i >= @config[:floor_count].to_i
      return if @exit_pos == nil

      safe_w = @config[:boss_safe_width].to_i
      safe_h = @config[:boss_safe_height].to_i
      safe_w = 7 if safe_w < 3
      safe_h = 7 if safe_h < 3
      safe_w += 1 if safe_w % 2 == 0
      safe_h += 1 if safe_h % 2 == 0

      cx = @exit_pos[0].to_i
      cy = @exit_pos[1].to_i
      half_w = safe_w / 2
      half_h = safe_h / 2
      x1 = [cx - half_w, 1].max
      y1 = [cy - half_h, 1].max
      x2 = [cx + half_w, @width - 2].min
      y2 = [cy + half_h, @height - 2].min

      for y in y1..y2
        for x in x1..x2
          value = cell(x, y)
          if @config[:boss_remove_water] != false ||
             value != CELL_WATER
            set_cell(x, y, CELL_FLOOR)
          end
        end
      end
      set_cell(cx, cy, CELL_EXIT)
    end

    def bfs_farthest(sx, sy, forbidden = nil)
      forbidden = {} if forbidden == nil
      queue = [[sx, sy]]
      head = 0
      distance = {}
      distance[index(sx, sy)] = 0
      farthest = [sx, sy, -1]
      dirs = [[0, -1], [1, 0], [0, 1], [-1, 0]]
      while head < queue.size
        pos = queue[head]
        head += 1
        x = pos[0]
        y = pos[1]
        d = distance[index(x, y)]
        key_here = index(x, y)
        if !forbidden[key_here] && d > farthest[2]
          farthest = [x, y, d]
        end
        dirs.each do |dir|
          nx = x + dir[0]
          ny = y + dir[1]
          next unless inside?(nx, ny)
          next unless walkable_cell?(cell(nx, ny))
          key = index(nx, ny)
          next if distance.has_key?(key)
          distance[key] = d + 1
          queue.push([nx, ny])
        end
      end
      return [sx, sy, 0] if farthest[2] < 0
      return farthest
    end
  end

  #==========================================================================
  # ■ Renderer v0.9.8
  #--------------------------------------------------------------------------
  # 從穩定版 v0.9.1-FS 重建，沿用 v0.9.7 高度拓撲。
  #
  # v0.9.8 只修正一個可由使用者修改圖精確驗證的缺口：
  # 每一段水平 south face 的左右端，各向外補一格牆面；
  # 深色外壁再依補完後的 south face 往下生成。
  #
  # 這不是重新發明牆體規則，只是補齊 VX 牆面水平段的端點。
  #==========================================================================
  class Renderer
    QUARTER_SIZE = 16

    def initialize(state)
      @state = state
      @width = state[:width]
      @height = state[:height]
      @layout = state[:layout]
      @skin = SKINS[state[:skin]] || SKINS[:hikimoki_cave]
      @tile_size = TILE_SIZE
      @atlas = load_decor_atlas
      @vx_sheets = {}
      @autotile_cache = {}
      @open_mask = nil
      @wall_top_mask = nil
      @north_face_mask = nil
      @south_face_mask = nil
      @outer_bottom_mask = nil
    end

    def build
      pixel_w = @width * @tile_size
      pixel_h = @height * @tile_size
      ground = Bitmap.new(pixel_w, pixel_h)
      upper  = Bitmap.new(pixel_w, pixel_h)
      bridge = Bitmap.new(pixel_w, pixel_h)
      color = @skin[:void_color] || [0, 0, 0, 255]
      ground.fill_rect(0, 0, pixel_w, pixel_h,
                       Color.new(color[0], color[1], color[2], color[3]))

      water_frames = []
      count = water_frame_count
      count = 1 if count <= 0
      count.times { water_frames.push(Bitmap.new(pixel_w, pixel_h)) }

      prepare_height_topology
      begin
        for y in 0...@height
          for x in 0...@width
            draw_cell(ground, upper, bridge, water_frames, x, y)
          end
        end
      ensure
        dispose_autotile_cache
      end
      return [ground, upper, bridge, water_frames]
    end

    def index(x, y)
      return x + y * @width
    end

    def inside?(x, y)
      return x >= 0 && y >= 0 && x < @width && y < @height
    end

    def cell(x, y)
      return CELL_VOID unless inside?(x, y)
      return @layout[index(x, y)]
    end

    def floor_like?(x, y)
      value = cell(x, y)
      return value == CELL_FLOOR ||
             value == CELL_ENTRANCE ||
             value == CELL_EXIT
    end

    def water_like?(x, y)
      value = cell(x, y)
      return value == CELL_WATER ||
             value == CELL_BRIDGE_H ||
             value == CELL_BRIDGE_V
    end

    def open_like?(x, y)
      return floor_like?(x, y) || water_like?(x, y)
    end

    #------------------------------------------------------------------------
    # 高度拓撲
    #
    # open                    = 地板／水／橋
    # north face              = open 正北一格
    # solid                   = open + north face
    # wall top                = solid 的完整八方向外框
    # south face              = 南側 wall top 再往南一格
    # dark outer              = south face 再往南一格
    #
    # 這個模型自然處理房間、通道、轉角與接合，不修改任何地板格。
    #------------------------------------------------------------------------
    def prepare_height_topology
      return if @open_mask != nil
      size = @width * @height
      @open_mask = Array.new(size, false)
      for y in 0...@height
        for x in 0...@width
          @open_mask[index(x, y)] = true if open_like?(x, y)
        end
      end

      north = mask_difference(mask_shift(@open_mask, 0, -1), @open_mask)
      solid = mask_union(@open_mask, north)
      roof = mask_difference(mask_dilate_8(solid), solid)

      # 南側牆頂只取 open 的正南邊界；它同時也是 roof 的一部分。
      south_roof = mask_difference(mask_shift(@open_mask, 0, 1),
                                   @open_mask, north)
      roof = mask_union(roof, south_roof)

      south_face = mask_difference(mask_shift(south_roof, 0, 1),
                                   @open_mask, north, roof)

      # v0.9.8：
      # v0.9.7 的 south face 只涵蓋正下方格，水平牆段的左右端會
      # 各漏掉一格。使用者修正 Seed 123456 預覽後，24 個差異格
      # 全部可由「12 個水平端點牆面＋其下方 12 個外壁」解釋。
      south_face = mask_extend_horizontal_ends(
        south_face, @open_mask, north, roof
      )

      outer = mask_difference(mask_shift(south_face, 0, 1),
                              @open_mask, north, roof, south_face)

      @north_face_mask = north
      @wall_top_mask = roof
      @south_face_mask = south_face
      @outer_bottom_mask = outer
    end

    def mask_shift(mask, dx, dy)
      result = Array.new(@width * @height, false)
      for y in 0...@height
        for x in 0...@width
          next unless mask[index(x, y)]
          nx = x + dx
          ny = y + dy
          next unless inside?(nx, ny)
          result[index(nx, ny)] = true
        end
      end
      return result
    end

    def mask_dilate_8(mask)
      result = mask.clone
      for y in 0...@height
        for x in 0...@width
          next unless mask[index(x, y)]
          for dy in -1..1
            for dx in -1..1
              nx = x + dx
              ny = y + dy
              next unless inside?(nx, ny)
              result[index(nx, ny)] = true
            end
          end
        end
      end
      return result
    end

    #------------------------------------------------------------------------
    # 水平連續段端點補格
    #
    # 只處理 source mask 的每一段水平 run：
    #   [start ... finish]
    #
    # 若 start-1／finish+1 沒有被 open、north face、wall top 等
    # blocked mask 佔用，就補進 result。
    #
    # Ruby 1.8 相容：不使用 each_slice、Enumerator 或新版語法。
    #------------------------------------------------------------------------
    def mask_extend_horizontal_ends(source, *blocked_masks)
      result = source.clone
      for y in 0...@height
        x = 0
        while x < @width
          unless source[index(x, y)]
            x += 1
            next
          end

          start_x = x
          x += 1
          while x < @width && source[index(x, y)]
            x += 1
          end
          finish_x = x - 1

          [start_x - 1, finish_x + 1].each do |target_x|
            next unless inside?(target_x, y)
            target_index = index(target_x, y)
            next if source[target_index]

            blocked = false
            blocked_masks.each do |mask|
              next if mask == nil
              if mask[target_index]
                blocked = true
                break
              end
            end
            result[target_index] = true unless blocked
          end
        end
      end
      return result
    end

    def mask_union(*masks)
      result = Array.new(@width * @height, false)
      masks.each do |mask|
        next if mask == nil
        for i in 0...result.size
          result[i] = true if mask[i]
        end
      end
      return result
    end

    def mask_difference(source, *masks)
      result = source.clone
      masks.each do |mask|
        next if mask == nil
        for i in 0...result.size
          result[i] = false if mask[i]
        end
      end
      return result
    end

    def mask_cell?(mask, x, y)
      return false unless inside?(x, y)
      return mask[index(x, y)] == true
    end

    def draw_cell(ground, upper, bridge, water_frames, x, y)
      value = cell(x, y)
      px = x * @tile_size
      py = y * @tile_size

      # 真正的地板／水域永遠優先，牆體不再覆蓋合法通道。
      case value
      when CELL_FLOOR
        draw_floor(ground, x, y, px, py)
        return
      when CELL_ENTRANCE
        draw_floor(ground, x, y, px, py)
        key = @state[:floor].to_i <= 1 ? :entrance : :stair_up
        key = :entrance if atlas_tile_position(key) == nil
        blit_atlas_tile(ground, key, px, py)
        return
      when CELL_EXIT
        draw_floor(ground, x, y, px, py)
        if @state[:floor].to_i >= @state[:floor_count].to_i
          key = :boss_seal
          key = :exit if atlas_tile_position(key) == nil
        else
          key = :stair_down
          key = :exit if atlas_tile_position(key) == nil
        end
        blit_atlas_tile(ground, key, px, py)
        return
      when CELL_WATER
        draw_water(water_frames, x, y, px, py)
        return
      when CELL_BRIDGE_H
        draw_water(water_frames, x, y, px, py)
        blit_atlas_tile(bridge, bridge_h_key(x, y), px, py)
        return
      when CELL_BRIDGE_V
        draw_water(water_frames, x, y, px, py)
        blit_atlas_tile(bridge, bridge_v_key(x, y), px, py)
        return
      end

      if mask_cell?(@wall_top_mask, x, y)
        draw_autotile(ground, @skin[:wall_top_autotile],
                      x, y, px, py, :wall_top, 0)
      elsif mask_cell?(@north_face_mask, x, y)
        draw_autotile(ground, @skin[:wall_face_autotile],
                      x, y, px, py, :north_face, 0)
      elsif mask_cell?(@south_face_mask, x, y)
        draw_autotile(ground, @skin[:wall_face_autotile],
                      x, y, px, py, :south_face, 0)
      elsif mask_cell?(@outer_bottom_mask, x, y)
        draw_outer_bottom(ground, x, y, px, py)
      end
    end

    def draw_floor(bitmap, x, y, px, py)
      spec = @skin[:floor_atlas] || {}
      tile = choose_atlas_tile(spec, x, y, 19349663)
      tile = :floor if tile == nil
      blit_atlas_tile(bitmap, tile, px, py)
      draw_floor_deco(bitmap, x, y, px, py) if @skin[:use_floor_decor] != false
    end

    def choose_atlas_tile(spec, x, y, salt)
      tiles = spec[:tiles] || []
      return spec[:tile] if tiles.empty?
      weights = spec[:weights] || []
      total = 0
      tiles.each_with_index do |tile, i|
        weight = weights[i]
        weight = 1 if weight == nil
        weight = [weight.to_i, 0].max
        total += weight
      end
      return tiles[0] if total <= 0
      value = ((x.to_i * 73856093) ^
               (y.to_i * 19349663) ^
               (@state[:seed].to_i * salt.to_i)) & 0x7fffffff
      value %= total
      cursor = 0
      tiles.each_with_index do |tile, i|
        weight = weights[i]
        weight = 1 if weight == nil
        weight = [weight.to_i, 0].max
        cursor += weight
        return tile if value < cursor
      end
      return tiles[0]
    end

    def draw_floor_deco(bitmap, x, y, px, py)
      n = ((x * 83492791) ^ (y * 2971215073) ^
           (@state[:seed].to_i * 31)) & 0x7fffffff
      value = n % 100
      if value < 3
        blit_atlas_tile(bitmap, :deco_crack, px, py)
      elsif value < 6
        blit_atlas_tile(bitmap, :deco_pebbles, px, py)
      elsif value < 8
        blit_atlas_tile(bitmap, :deco_moss, px, py)
      elsif value == 99
        blit_atlas_tile(bitmap, :deco_crystal, px, py)
      end
    end

    def water_frame_count
      spec = @skin[:water_autotile] || {}
      origins = spec[:origins] || []
      return origins.size unless origins.empty?
      return 1
    end

    def draw_water(bitmaps, x, y, px, py)
      spec = @skin[:water_autotile]
      bitmaps.each_with_index do |bitmap, frame_index|
        draw_autotile(bitmap, spec, x, y, px, py, :water, frame_index)
      end
    end

    def bridge_h_key(x, y)
      left  = cell(x - 1, y) == CELL_BRIDGE_H
      right = cell(x + 1, y) == CELL_BRIDGE_H
      return :bridge_h_left if !left && atlas_tile_position(:bridge_h_left) != nil
      return :bridge_h_right if !right && atlas_tile_position(:bridge_h_right) != nil
      return :bridge_h
    end

    def bridge_v_key(x, y)
      top    = cell(x, y - 1) == CELL_BRIDGE_V
      bottom = cell(x, y + 1) == CELL_BRIDGE_V
      return :bridge_v_top if !top && atlas_tile_position(:bridge_v_top) != nil
      return :bridge_v_bottom if !bottom && atlas_tile_position(:bridge_v_bottom) != nil
      return :bridge_v
    end

    def draw_outer_bottom(bitmap, x, y, px, py)
      spec = @skin[:outer_bottom_atlas] || {}
      left = mask_cell?(@outer_bottom_mask, x - 1, y)
      right = mask_cell?(@outer_bottom_mask, x + 1, y)
      if !left && !right
        tile = spec[:single] || spec[:middle]
      elsif !left
        tile = spec[:left] || spec[:middle]
      elsif !right
        tile = spec[:right] || spec[:middle]
      else
        tile = spec[:middle]
      end
      blit_atlas_tile(bitmap, tile, px, py)
    end

    #------------------------------------------------------------------------
    # VX 原生 autotile 四分片
    #------------------------------------------------------------------------
    def draw_autotile(dest, spec, x, y, px, py, kind, frame_index)
      tile = autotile_bitmap(spec, x, y, kind, frame_index)
      return if tile == nil
      dest.blt(px, py, tile, ::Rect.new(0, 0, 32, 32))
    end

    def autotile_bitmap(spec, x, y, kind, frame_index)
      return nil if spec == nil
      sheet_key = spec[:sheet]
      sheet = load_vx_sheet(sheet_key)
      return nil if sheet == nil
      origin = spec_origin(spec, frame_index)
      return nil if origin == nil
      mode = spec[:mode] || :floor
      parts = mode == :wall ? wall_quarters(x, y, kind) :
                              floor_quarters(x, y, kind)
      key = [sheet_key, origin[0], origin[1], mode, parts]
      cached = @autotile_cache[key]
      return cached if cached != nil && !cached.disposed?
      bitmap = Bitmap.new(32, 32)
      destinations = [[0, 0], [16, 0], [0, 16], [16, 16]]
      parts.each_with_index do |part, i|
        sx = origin[0].to_i + part[0].to_i * QUARTER_SIZE
        sy = origin[1].to_i + part[1].to_i * QUARTER_SIZE
        bitmap.blt(destinations[i][0], destinations[i][1], sheet,
                   ::Rect.new(sx, sy, QUARTER_SIZE, QUARTER_SIZE))
      end
      @autotile_cache[key] = bitmap
      return bitmap
    end

    def floor_quarters(x, y, kind)
      n  = same_kind?(x, y - 1, kind)
      e  = same_kind?(x + 1, y, kind)
      s  = same_kind?(x, y + 1, kind)
      w  = same_kind?(x - 1, y, kind)
      nw = same_kind?(x - 1, y - 1, kind)
      ne = same_kind?(x + 1, y - 1, kind)
      se = same_kind?(x + 1, y + 1, kind)
      sw = same_kind?(x - 1, y + 1, kind)

      tl = if n && w then (nw ? [2,4] : [2,0])
           elsif n then [0,4]
           elsif w then [2,2]
           else [0,2] end
      tr = if n && e then (ne ? [1,4] : [3,0])
           elsif n then [3,4]
           elsif e then [1,2]
           else [3,2] end
      bl = if s && w then (sw ? [2,3] : [2,1])
           elsif s then [0,3]
           elsif w then [2,5]
           else [0,5] end
      br = if s && e then (se ? [1,3] : [3,1])
           elsif s then [3,3]
           elsif e then [1,5]
           else [3,5] end
      return [tl, tr, bl, br]
    end

    def wall_quarters(x, y, kind)
      n = same_kind?(x, y - 1, kind)
      e = same_kind?(x + 1, y, kind)
      s = same_kind?(x, y + 1, kind)
      w = same_kind?(x - 1, y, kind)

      tl = if n && w then [2,2]
           elsif n then [0,2]
           elsif w then [2,0]
           else [0,0] end
      tr = if n && e then [1,2]
           elsif n then [3,2]
           elsif e then [1,0]
           else [3,0] end
      bl = if s && w then [2,1]
           elsif s then [0,1]
           elsif w then [2,3]
           else [0,3] end
      br = if s && e then [1,1]
           elsif s then [3,1]
           elsif e then [1,3]
           else [3,3] end
      return [tl, tr, bl, br]
    end

    def same_kind?(x, y, kind)
      case kind
      when :water
        return water_like?(x, y)
      when :wall_top
        return mask_cell?(@wall_top_mask, x, y)
      when :north_face
        return mask_cell?(@north_face_mask, x, y)
      when :south_face
        return mask_cell?(@south_face_mask, x, y)
      end
      return false
    end

    def spec_origin(spec, frame_index)
      origins = spec[:origins]
      return origins[frame_index] || origins[0] if origins != nil && !origins.empty?
      return spec[:origin] if spec[:origin] != nil
      block = spec[:block] || [0, 0]
      bx = block[0].to_i
      by = block[1].to_i
      if spec[:sheet] == :a4
        y = by * 160
        y += 96 if spec[:section] == :wall
        return [bx * 64, y]
      end
      return [bx * 64, by * 96]
    end

    def load_vx_sheet(key)
      cached = @vx_sheets[key]
      return cached if cached != nil && !cached.disposed?
      filename = (@skin[:vx_tilesheets] || {})[key]
      return nil if filename == nil
      begin
        bitmap = Cache.parallax(filename)
      rescue Exception
        p "[FS_RandomDungeon] VX tilesheet missing: " + filename.to_s
        bitmap = Bitmap.new(512, 480)
        bitmap.fill_rect(0, 0, bitmap.width, bitmap.height,
                         Color.new(220, 0, 220, 255))
      end
      @vx_sheets[key] = bitmap
      return bitmap
    end

    def dispose_autotile_cache
      @autotile_cache.each_value do |bitmap|
        bitmap.dispose if bitmap != nil && !bitmap.disposed?
      end
      @autotile_cache.clear
    end

    def atlas_tile_position(tile)
      return [tile[0].to_i, tile[1].to_i] if tile.is_a?(Array)
      return (@skin[:tiles] || {})[tile]
    end

    def blit_atlas_tile(dest, tile, px, py)
      return if @atlas == nil || tile == nil
      pos = atlas_tile_position(tile)
      return if pos == nil
      dest.blt(px, py, @atlas,
               ::Rect.new(pos[0] * @tile_size, pos[1] * @tile_size,
                          @tile_size, @tile_size))
    end

    def load_decor_atlas
      filename = @skin[:decor_atlas] || @skin[:atlas]
      begin
        return Cache.parallax(filename)
      rescue Exception
        p "[FS_RandomDungeon] Decor atlas missing: " + filename.to_s
        bitmap = Bitmap.new(256, 256)
        bitmap.fill_rect(0, 0, 256, 256, Color.new(30, 30, 30, 255))
        return bitmap
      end
    end
  end

  #==========================================================================
  # ■ Runtime Bitmap Cache
  #  Bitmap 不進存檔，只依 state 重建。
  #==========================================================================
  module Runtime
    @cache = {}

    def self.key(state)
      return [
        state[:key],
        state[:generation_id],
        state[:floor],
        state[:seed],
        state[:skin],
        VERSION
      ]
    end

    #----------------------------------------------------------------------
    # Bitmap 或 Bitmap 陣列是否已失效
    # 水面動畫使用多幀陣列，因此不能直接對 Array 呼叫 disposed?。
    #----------------------------------------------------------------------
    def self.bitmap_group_invalid?(value)
      return true if value == nil
      if value.is_a?(Array)
        return true if value.empty?
        value.each do |child|
          return true if bitmap_group_invalid?(child)
        end
        return false
      end
      return true unless value.respond_to?(:disposed?)
      return value.disposed?
    end

    #----------------------------------------------------------------------
    # 安全釋放 Bitmap 或巢狀 Bitmap 陣列
    #----------------------------------------------------------------------
    def self.dispose_bitmap_group(value)
      return if value == nil
      if value.is_a?(Array)
        value.each { |child| dispose_bitmap_group(child) }
        return
      end
      return unless value.respond_to?(:disposed?)
      value.dispose unless value.disposed?
    end

    def self.bitmaps(state)
      cache_key = key(state)
      data = @cache[cache_key]
      invalid = bitmap_group_invalid?(data)
      if invalid
        # 若殘留半套失效資料，先安全清除再重建。
        dispose_bitmap_group(data)
        renderer = Renderer.new(state)
        data = renderer.build
        @cache[cache_key] = data
      end
      return data
    end

    def self.clear
      @cache.each_value do |data|
        dispose_bitmap_group(data)
      end
      @cache.clear
    end

    def self.clear_key(state)
      return if state == nil
      cache_key = key(state)
      data = @cache.delete(cache_key)
      dispose_bitmap_group(data)
    end

    def self.clear_run(run)
      return if run == nil
      floors = run[:floors]
      if floors != nil
        floors.each_value { |state| clear_key(state) }
      elsif run[:layout] != nil
        clear_key(run)
      end
    end
  end

  #==========================================================================
  # ■ Module API / 多樓層狀態管理
  #==========================================================================
  def self.config(key)
    value = DUNGEONS[key]
    raise "Unknown dungeon key: #{key}" if value == nil
    return value
  end

  def self.make_seed
    base = Graphics.frame_count.to_i
    base ^= Time.now.to_i
    base ^= rand(0x7fffffff)
    return base & 0x7fffffff
  end

  def self.floor_seed(base_seed, floor)
    floor = floor.to_i
    return base_seed.to_i & 0x7fffffff if floor <= 1
    mixed = (base_seed.to_i ^ (floor * 73244475) ^ (floor * floor * 19349663))
    mixed &= 0x7fffffff
    rng = RNG.new(mixed)
    return rng.rand(0x7fffffff)
  end

  def self.floor_count_for(cfg)
    value = cfg[:floor_count].to_i
    value = 1 if value < 1
    value = 99 if value > 99
    return value
  end

  def self.floor_config(cfg, floor)
    runtime = cfg.dup
    overrides = cfg[:floor_overrides]
    if overrides != nil
      extra = overrides[floor.to_i]
      runtime.merge!(extra) if extra != nil
    end
    runtime[:floor] = floor.to_i
    return runtime
  end

  RESET_RULE_DEFAULTS = {
    :rebuild_layout          => false,
    :new_seed_on_rebuild     => true,
    :reset_treasure          => false,
    :respawn_battle          => true,
    :respawn_elite           => false,
    :reset_heal              => true,
    :reset_soul              => false,
    :reset_boss              => false,
    :preserve_floor_progress => true,
    :reroll_event_pool       => false,
    :reset_exploration       => false
  }

  def self.current_day_key
    begin
      return Time.now.strftime("%Y-%m-%d")
    rescue Exception
      return (Time.now.to_i / 86400).to_i
    end
  end

  def self.reset_rules_for(cfg)
    result = RESET_RULE_DEFAULTS.dup
    extra = cfg[:reset_rules]
    result.merge!(extra) if extra != nil
    return result
  end

  def self.reset_mode_for(cfg)
    mode = cfg[:reset_mode]
    return :manual if mode == nil
    return mode
  end

  def self.generated_descriptor(state, event_id)
    return nil if state == nil
    events = state[:generated_events] || []
    events.each do |entry|
      return entry if entry[:event_id].to_i == event_id.to_i
    end
    return nil
  end

  def self.once_scope_for(cfg, type)
    scopes = cfg[:once_scope]
    return :event if scopes == nil
    value = scopes[type]
    return value == nil ? :event : value
  end

  def self.persistent_event_key(run, state, event_id, type)
    cfg = config(run[:key])
    scope = once_scope_for(cfg, type)
    descriptor = generated_descriptor(state, event_id)
    source_id = descriptor == nil ? event_id.to_i :
                descriptor[:source_id].to_i
    occurrence = descriptor == nil ? 1 :
                 descriptor[:occurrence].to_i
    occurrence = 1 if occurrence <= 0
    case scope
    when :dungeon
      return [type]
    when :floor
      return [type, state[:floor].to_i]
    when :source
      return [type, source_id]
    else
      return [type, state[:floor].to_i, source_id, occurrence]
    end
  end

  def self.persistent_once_enabled?(cfg, type)
    return cfg[:soul_once] != false if type == :soul
    return cfg[:boss_once] != false if type == :boss
    return false
  end

  def self.persistent_event_completed?(run, state, event_id, name = nil)
    return false if run == nil || state == nil
    type = event_progress_type_name(name)
    return false unless persistent_once_enabled?(config(run[:key]), type)
    flags = run[:persistent_flags] || {}
    key = persistent_event_key(run, state, event_id, type)
    return flags[key] == true
  end

  def self.clear_persistent_type(run, type)
    return if run == nil
    run[:persistent_flags] ||= {}
    run[:persistent_flags].delete_if do |key, value|
      key.is_a?(Array) && key[0] == type
    end
  end

  def self.record_event_completion(event_id, letter)
    return false unless active?
    run = current_run
    state = current_state
    return false if run == nil || state == nil
    event = $game_map.events[event_id.to_i]
    return false if event == nil
    rpg_event = nil
    rpg_event = event.event if event.respond_to?(:event)
    if rpg_event == nil
      map_data = $game_map.instance_variable_get(:@map) rescue nil
      rpg_event = map_data.events[event_id.to_i] if map_data != nil
    end
    return false if rpg_event == nil
    name = rpg_event.name.to_s
    type = event_progress_type_name(name)
    return false if type == nil
    cfg = config(run[:key])
    needed = completion_switch_for(cfg, name, type)
    return false unless letter.to_s.upcase == needed

    state[:completed_events] ||= {}
    state[:completed_events][event_id.to_i] = type

    if persistent_once_enabled?(cfg, type)
      run[:persistent_flags] ||= {}
      key = persistent_event_key(run, state, event_id, type)
      run[:persistent_flags][key] = true
    end

    if type == :boss && cfg[:auto_clear_on_boss] != false
      mark_cleared
    end
    return true
  end

  def self.mark_cleared
    run = current_run
    return false if run == nil
    unless run[:cleared]
      run[:clear_count] = run[:clear_count].to_i + 1
      run[:cleared_at] = Time.now.to_i
    end
    run[:cleared] = true
    cfg = config(run[:key])
    if reset_mode_for(cfg) == :on_clear
      run[:pending_reset_reason] = :clear
    end
    return true
  end

  def self.cleared?(key = nil)
    run = key == nil ? current_run : normalize_run_state(key)
    return false if run == nil
    return run[:cleared] == true
  end

  def self.clear_count(key = nil)
    run = key == nil ? current_run : normalize_run_state(key)
    return 0 if run == nil
    return run[:clear_count].to_i
  end

  def self.queue_exit_reset
    run = current_run
    return false if run == nil
    cfg = config(run[:key])
    if reset_mode_for(cfg) == :on_exit &&
       run[:pending_reset_reason] == nil
      run[:pending_reset_reason] = :exit
    end
    run[:last_exit_at] = Time.now.to_i
    return true
  end

  def self.auto_reset_reason(key, run, external_entry)
    return nil if run == nil
    cfg = config(key)
    pending = run[:pending_reset_reason]
    return pending if pending != nil

    mode = reset_mode_for(cfg)
    if mode == :daily
      return :daily if run[:last_reset_day].to_s != current_day_key.to_s
    elsif mode == :new_seed_each_entry
      return :entry if external_entry && run[:entry_count].to_i > 0
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # 樓層標籤判斷
  # 支援：
  #   <FS_RD_FLOOR:2>
  #   <FS_RD_FLOORS:1,3>
  #   <FS_RD_FLOORS:2-4>
  #--------------------------------------------------------------------------
  def self.event_enabled_on_floor_name?(name, floor)
    text = name.to_s
    floor = floor.to_i
    if text =~ /<FS_RD_FLOOR\s*:\s*(\d+)\s*>/i
      return floor == $1.to_i
    end
    if text =~ /<FS_RD_FLOORS\s*:\s*([^>]+)>/i
      spec = $1.to_s
      allowed = false
      spec.split(",").each do |part|
        token = part.to_s.strip
        if token =~ /\A(\d+)\s*-\s*(\d+)\z/
          a = $1.to_i
          b = $2.to_i
          a, b = b, a if a > b
          allowed = true if floor >= a && floor <= b
        elsif token =~ /\A\d+\z/
          allowed = true if floor == token.to_i
        end
      end
      return allowed
    end
    return true
  end

  def self.event_room_type_name(name)
    text = name.to_s.upcase
    return :elite    if text.include?("<FS_RD_ELITE>")
    return :treasure if text.include?("<FS_RD_TREASURE>")
    return :heal     if text.include?("<FS_RD_HEAL>")
    return :soul     if text.include?("<FS_RD_SOUL>")
    return :battle   if text.include?("<FS_RD_ENEMY>")
    return nil
  end

  EVENT_POOL_TYPES = [:battle, :treasure, :elite, :heal, :soul]
  PROGRESS_TYPES = [:battle, :treasure, :elite, :heal, :soul, :boss]

  def self.event_progress_type_name(name)
    text = name.to_s.upcase
    return :boss if text.include?("<FS_RD_BOSS>") ||
                    text.include?("<FS_RD_FINAL>")
    return event_room_type_name(text)
  end

  def self.completion_switch_for(cfg, name, type)
    text = name.to_s
    if text =~ /<FS_RD_COMPLETE\s*:\s*([A-D])\s*>/i
      return $1.to_s.upcase
    end
    value = cfg[:completion_self_switch]
    if value.is_a?(Hash)
      result = value[type]
      return result.to_s.upcase unless result == nil
    elsif value != nil
      return value.to_s.upcase
    end
    return "A"
  end

  def self.generated_event_name?(name)
    return name.to_s.upcase.include?("<FS_RD_GENERATED>")
  end

  def self.event_type_tag(type)
    return "<FS_RD_ENEMY>"    if type == :battle
    return "<FS_RD_TREASURE>" if type == :treasure
    return "<FS_RD_ELITE>"    if type == :elite
    return "<FS_RD_HEAL>"     if type == :heal
    return "<FS_RD_SOUL>"     if type == :soul
    return ""
  end

  def self.event_pool_weight(name)
    text = name.to_s
    if text =~ /<FS_RD_WEIGHT\s*:\s*(\d+)\s*>/i
      value = $1.to_i
      return value <= 0 ? 1 : value
    end
    return 100
  end

  def self.event_pool_max(name)
    text = name.to_s
    return 1 if text =~ /<FS_RD_(UNIQUE|NO_REPEAT)>/i
    if text =~ /<FS_RD_MAX\s*:\s*(\d+)\s*>/i
      value = $1.to_i
      return value < 0 ? 0 : value
    end
    return nil
  end

  def self.count_spec_for_floor(cfg, floor, type)
    spec = nil
    base = cfg[:event_counts]
    spec = base[type] if base != nil
    by_floor = cfg[:event_counts_by_floor]
    if by_floor != nil
      row = by_floor[floor.to_i]
      spec = row[type] if row != nil && row.has_key?(type)
    end
    return spec
  end

  def self.resolve_count_spec(spec, template_count, rng)
    return template_count.to_i if spec == nil || spec == :template
    if spec.is_a?(Array)
      min = spec[0].to_i
      max = spec[1].to_i
      min, max = max, min if min > max
      min = 0 if min < 0
      max = 0 if max < 0
      return min if max <= min
      return rng.range(min, max)
    end
    if spec.is_a?(Range)
      min = spec.first.to_i
      max = spec.last.to_i
      max -= 1 if spec.exclude_end?
      min, max = max, min if min > max
      min = 0 if min < 0
      max = 0 if max < 0
      return min if max <= min
      return rng.range(min, max)
    end
    value = spec.to_i
    return value < 0 ? 0 : value
  end

  def self.resolve_event_counts(cfg, floor, source_counts, seed)
    result = {}
    rng = RNG.new(seed.to_i ^ 0x45D9F3B)
    EVENT_POOL_TYPES.each do |type|
      spec = count_spec_for_floor(cfg, floor, type)
      result[type] = resolve_count_spec(spec, source_counts[type].to_i, rng)
    end
    max_total = cfg[:max_generated_events].to_i
    if max_total > 0
      remaining = max_total
      EVENT_POOL_TYPES.each do |type|
        value = [result[type].to_i, remaining].min
        value = 0 if value < 0
        result[type] = value
        remaining -= value
        remaining = 0 if remaining < 0
      end
    end
    return result
  end

  def self.explicit_pool_entries(cfg, type)
    pools = cfg[:event_pools]
    return nil if pools == nil
    entries = pools[type]
    return nil if entries == nil || entries.empty?
    result = []
    entries.each do |entry|
      if entry.is_a?(Array)
        result.push({
          :source_id => entry[0].to_i,
          :weight    => entry[1] == nil ? 100 : entry[1].to_i,
          :max       => entry[2] == nil ? nil : entry[2].to_i
        })
      else
        result.push({ :source_id => entry.to_i, :weight => 100, :max => nil })
      end
    end
    return result
  end

  def self.pool_entries_for_type(cfg, map, floor, type)
    result = []
    explicit = explicit_pool_entries(cfg, type)
    if explicit != nil
      explicit.each do |entry|
        event = map.events[entry[:source_id]]
        next if event == nil
        next unless event_enabled_on_floor_name?(event.name.to_s, floor)
        weight = entry[:weight].to_i
        weight = 1 if weight <= 0
        max = entry[:max]
        max = event_pool_max(event.name) if max == nil
        result.push({
          :source_id => event.id,
          :weight    => weight,
          :max       => max
        })
      end
      return result
    end

    map.events.each do |event_id, event|
      next if event == nil
      name = event.name.to_s
      next if generated_event_name?(name)
      next unless event_room_type_name(name) == type
      next unless event_enabled_on_floor_name?(name, floor)
      result.push({
        :source_id => event_id,
        :weight    => event_pool_weight(name),
        :max       => event_pool_max(name)
      })
    end
    return result
  end

  def self.weighted_pool_entry(entries, rng)
    total = 0
    entries.each { |entry| total += [entry[:weight].to_i, 1].max }
    return nil if total <= 0
    value = rng.rand(total)
    entries.each do |entry|
      value -= [entry[:weight].to_i, 1].max
      return entry if value < 0
    end
    return entries[-1]
  end

  def self.generated_event_plan(cfg, state, map)
    return [] if cfg[:event_generation_enabled] == false
    counts = state[:event_counts_resolved] || {}
    rng = RNG.new(state[:seed].to_i ^ 0x6C8E9CF5)
    max_id = 0
    map.events.each_key { |event_id| max_id = event_id if event_id.to_i > max_id }
    next_id = max_id + 1
    plan = []
    global_limit = cfg[:max_generated_events].to_i
    global_limit = 999999 if global_limit <= 0

    EVENT_POOL_TYPES.each do |type|
      requested = counts[type].to_i
      next if requested <= 0
      entries = pool_entries_for_type(cfg, map, state[:floor], type)
      next if entries.empty?
      used_counts = {}
      occurrence_counts = {}
      requested.times do
        break if plan.size >= global_limit
        available = []
        entries.each do |entry|
          cap = entry[:max]
          cap = 1 if cfg[:pool_allow_repeat] == false
          current = used_counts[entry[:source_id]].to_i
          next if cap != nil && current >= cap.to_i
          available.push(entry)
        end
        break if available.empty?
        picked = weighted_pool_entry(available, rng)
        break if picked == nil
        used_counts[picked[:source_id]] =
          used_counts[picked[:source_id]].to_i + 1
        occurrence_counts[picked[:source_id]] =
          occurrence_counts[picked[:source_id]].to_i + 1
        plan.push({
          :event_id   => next_id,
          :source_id  => picked[:source_id],
          :type       => type,
          :occurrence => occurrence_counts[picked[:source_id]]
        })
        next_id += 1
      end
    end
    return plan
  end

  def self.generated_clone_name(source_name, type)
    text = source_name.to_s.dup
    text.gsub!(/<FS_RD_WEIGHT\s*:\s*\d+\s*>/i, "")
    text.gsub!(/<FS_RD_MAX\s*:\s*\d+\s*>/i, "")
    text.gsub!(/<FS_RD_(UNIQUE|NO_REPEAT)>/i, "")
    unless event_room_type_name(text) == type
      text += event_type_tag(type)
    end
    text += "<FS_RD_GENERATED>"
    return text
  end

  #--------------------------------------------------------------------------
  # 讀取模板地圖
  #--------------------------------------------------------------------------
  def self.load_template_map(cfg)
    begin
      filename = sprintf("Data/Map%03d.rvdata", cfg[:map_id].to_i)
      return load_data(filename)
    rescue Exception => e
      p "[FS_RandomDungeon] Cannot load template map: " + e.message.to_s
      return nil
    end
  end

  #--------------------------------------------------------------------------
  # Forest Symphony 環境詞綴
  #--------------------------------------------------------------------------
  def self.affix_definition(key)
    return ENVIRONMENT_AFFIXES[key]
  end

  def self.weighted_affix_pick(pool, rng, used)
    available = []
    pool.each do |entry|
      key = entry.is_a?(Array) ? entry[0] : entry
      weight = entry.is_a?(Array) ? entry[1].to_i : 100
      next if key == nil || used.include?(key)
      next if ENVIRONMENT_AFFIXES[key] == nil
      weight = 1 if weight <= 0
      available.push([key, weight])
    end
    return nil if available.empty?
    total = 0
    available.each { |entry| total += entry[1] }
    value = rng.rand(total)
    available.each do |entry|
      value -= entry[1]
      return entry[0] if value < 0
    end
    return available[-1][0]
  end

  def self.resolve_floor_affixes(cfg, floor, seed)
    fixed = cfg[:floor_affixes]
    if fixed != nil && fixed[floor.to_i] != nil
      value = fixed[floor.to_i]
      value = [value] unless value.is_a?(Array)
      return value.select { |key| ENVIRONMENT_AFFIXES[key] != nil }
    end

    count = cfg[:affixes_per_floor].to_i
    return [] if count <= 0
    pool = cfg[:affix_pool] || []
    return [] if pool.empty?
    rng = RNG.new(seed.to_i ^ 0x5F3759DF)
    result = []
    count.times do
      key = weighted_affix_pick(pool, rng, result)
      break if key == nil
      result.push(key)
    end
    return result
  end

  def self.apply_affix_generation!(runtime, affixes)
    event_bonus = {}
    affixes.each do |key|
      definition = ENVIRONMENT_AFFIXES[key]
      next if definition == nil
      generation = definition[:generation] || {}
      generation.each do |option, value|
        case option
        when :water_pool_count_bonus
          runtime[:water_pool_count] =
            runtime[:water_pool_count].to_i + value.to_i
        when :event_count_bonus
          value.each do |type, bonus|
            event_bonus[type] = event_bonus[type].to_i + bonus.to_i
          end
        else
          runtime[option] = value
        end
      end
    end
    runtime[:affix_event_count_bonus] = event_bonus
  end

  def self.current_affixes
    state = current_state
    return [] if state == nil
    return state[:environment_affixes] || []
  end

  def self.affix?(key)
    return current_affixes.include?(key)
  end

  def self.affix_value(name, default_value = nil)
    current_affixes.each do |key|
      definition = ENVIRONMENT_AFFIXES[key]
      next if definition == nil
      values = definition[:values] || {}
      return values[name] if values.has_key?(name)
    end
    return default_value
  end

  def self.environment_summary
    return current_affixes.collect do |key|
      definition = ENVIRONMENT_AFFIXES[key]
      definition == nil ? key.to_s : definition[:name].to_s
    end
  end

  def self.runtime_config(cfg, floor, seed = nil)
    runtime = floor_config(cfg, floor)
    seed = (floor.to_i * 104729 + 17) if seed == nil
    affixes = resolve_floor_affixes(runtime, floor, seed)
    runtime[:resolved_affixes] = affixes
    apply_affix_generation!(runtime, affixes)
    map = load_template_map(cfg)
    anchors = {}
    source_counts = {
      :battle => 0, :treasure => 0, :elite => 0, :heal => 0, :soul => 0
    }
    runtime[:floor_count] = floor_count_for(cfg)
    if map != nil
      if cfg[:use_template_size] != false
        runtime[:width] = map.width
        runtime[:height] = map.height
      end
      if map.events != nil
        map.events.each do |event_id, event|
          next if event == nil
          name = event.name.to_s
          next unless event_enabled_on_floor_name?(name, floor)
          if name.include?("<FS_RD_FIXED>")
            anchors[event_id] = [event.x, event.y]
          end
        end
        EVENT_POOL_TYPES.each do |type|
          source_counts[type] =
            pool_entries_for_type(runtime, map, floor, type).size
        end
      end
    end
    runtime[:fixed_anchors] = anchors
    if runtime[:event_generation_enabled] == false
      resolved_counts = source_counts.dup
    else
      resolved_counts = resolve_event_counts(runtime, floor, source_counts, seed)
    end
    bonus = runtime[:affix_event_count_bonus] || {}
    bonus.each do |type, value|
      resolved_counts[type] = [resolved_counts[type].to_i + value.to_i, 0].max
    end
    runtime[:event_source_counts] = source_counts
    runtime[:event_counts_resolved] = resolved_counts
    runtime[:room_event_counts] = resolved_counts
    return runtime
  end

  #--------------------------------------------------------------------------
  # v0.2.x 舊狀態自動包成單層資料，再依設定延伸成多樓層。
  #--------------------------------------------------------------------------
  def self.normalize_run_state(key, raw = nil)
    raw = $game_system.fs_rd_states[key] if raw == nil
    return nil if raw == nil
    cfg = config(key)

    if raw[:floors] == nil
      floor_state = raw
      floor_state[:key] = key
      floor_state[:floor] = 1
      floor_state[:floor_count] = floor_count_for(cfg)
      floor_state[:event_positions] ||= {}
      floor_state[:fixed_event_positions] ||= {}
      floor_state[:last_player_pos] ||= nil
      floor_state[:visited] = true if floor_state[:visited] == nil
      run = {
        :key           => key,
        :generation_id => floor_state[:generation_id].to_i <= 0 ? 1 : floor_state[:generation_id].to_i,
        :base_seed     => floor_state[:seed].to_i,
        :map_id        => cfg[:map_id],
        :skin          => cfg[:skin],
        :floor_count   => floor_count_for(cfg),
        :current_floor      => 1,
        :floors             => { 1 => floor_state },
        :persistent_flags   => {},
        :pending_reset_reason => nil,
        :last_reset_day     => current_day_key,
        :entry_count        => 0,
        :clear_count        => 0,
        :cleared            => false,
        :created_at         => floor_state[:created_at] || Time.now.to_i
      }
      $game_system.fs_rd_states[key] = run
      raw = run
    end

    raw[:key] = key
    raw[:map_id] = cfg[:map_id]
    raw[:skin] = cfg[:skin]
    raw[:floor_count] = floor_count_for(cfg)
    raw[:current_floor] = raw[:current_floor].to_i
    raw[:current_floor] = 1 if raw[:current_floor] < 1
    raw[:current_floor] = raw[:floor_count] if raw[:current_floor] > raw[:floor_count]
    raw[:generation_id] = 1 if raw[:generation_id].to_i <= 0
    raw[:base_seed] = make_seed if raw[:base_seed].to_i == 0
    raw[:floors] ||= {}
    raw[:persistent_flags] ||= {}
    raw[:pending_reset_reason] = nil unless raw.has_key?(:pending_reset_reason)
    raw[:last_reset_day] ||= current_day_key
    raw[:entry_count] = raw[:entry_count].to_i
    raw[:clear_count] = raw[:clear_count].to_i
    raw[:cleared] = false if raw[:cleared] == nil

    raw[:floors].each do |floor, state|
      next if state == nil
      number = floor.to_i
      state[:key] = key
      state[:floor] = number
      state[:floor_count] = raw[:floor_count]
      state[:generation_id] = raw[:generation_id]
      state[:event_positions] ||= {}
      state[:event_room_ids] ||= {}
      state[:event_counts_resolved] ||= {}
      state[:completed_events] ||= {}
      state[:generated_events] = nil if state[:schema_version].to_i < GENERATOR_SCHEMA
      state[:room_types] ||= []
      state[:room_depths] ||= []
      state[:room_links] ||= {}
      state[:environment_affixes] ||= []
      state[:explored_cells] ||= {}
      state[:exploration_version] = state[:exploration_version].to_i
      state[:generation_attempt] ||= 1
      state[:generation_warnings] ||= []
      state[:fixed_event_positions] ||= {}
      state[:visited] = false if state[:visited] == nil
      state[:schema_version] ||= 0
    end
    return raw
  end

  def self.state_matches_template?(run, cfg)
    return true if run == nil
    run = normalize_run_state(run[:key] || cfg[:key], run)
    run[:floors].each_value do |state|
      next if state == nil
      return false if state[:schema_version].to_i != GENERATOR_SCHEMA
      return false if state[:map_id].to_i != cfg[:map_id].to_i
    end
    return true if cfg[:use_template_size] == false
    map = load_template_map(cfg)
    return true if map == nil
    run[:floors].each_value do |state|
      next if state == nil
      return false if state[:width].to_i != map.width.to_i
      return false if state[:height].to_i != map.height.to_i
    end
    return true
  end

  #--------------------------------------------------------------------------
  # 生成驗證與自動重試
  #--------------------------------------------------------------------------
  def self.validation_reachable_cells(data)
    width = data[:width].to_i
    height = data[:height].to_i
    layout = data[:layout]
    start = data[:entrance]
    return {} if start == nil || layout == nil
    result = {}
    queue = [start]
    result[start[0].to_i + start[1].to_i * width] = true
    head = 0
    while head < queue.size
      pos = queue[head]
      head += 1
      x = pos[0].to_i
      y = pos[1].to_i
      [[1,0],[-1,0],[0,1],[0,-1]].each do |dir|
        nx = x + dir[0]
        ny = y + dir[1]
        next if nx < 0 || ny < 0 || nx >= width || ny >= height
        index_id = nx + ny * width
        next if result[index_id]
        next unless walkable_cell?(layout[index_id])
        result[index_id] = true
        queue.push([nx, ny])
      end
    end
    return result
  end

  def self.generation_validation_errors(data, cfg)
    errors = []
    return [:no_data] if data == nil
    rooms = data[:rooms] || []
    minimum = cfg[:min_generated_rooms].to_i
    minimum = 2 if minimum < 2
    errors.push(:too_few_rooms) if rooms.size < minimum

    width = data[:width].to_i
    layout = data[:layout] || []
    entrance = data[:entrance]
    exit_pos = data[:exit]
    if entrance == nil || exit_pos == nil
      errors.push(:missing_entrance_or_exit)
      return errors
    end
    errors.push(:same_entrance_and_exit) if entrance == exit_pos

    reachable = validation_reachable_cells(data)
    exit_index = exit_pos[0].to_i + exit_pos[1].to_i * width
    errors.push(:exit_unreachable) unless reachable[exit_index]

    (data[:fixed_event_positions] || {}).each_value do |pos|
      next if pos == nil
      index_id = pos[0].to_i + pos[1].to_i * width
      errors.push(:fixed_anchor_unreachable) unless reachable[index_id]
    end

    final_floor = cfg[:floor].to_i >= cfg[:floor_count].to_i
    if final_floor && cfg[:boss_safety_enabled] != false
      clear_w = cfg[:boss_safe_width].to_i
      clear_h = cfg[:boss_safe_height].to_i
      clear_w = 7 if clear_w < 3
      clear_h = 7 if clear_h < 3
      half_w = clear_w / 2
      half_h = clear_h / 2
      boss_ok = true
      for y in (exit_pos[1] - half_h)..(exit_pos[1] + half_h)
        for x in (exit_pos[0] - half_w)..(exit_pos[0] + half_w)
          next if x < 1 || y < 1 ||
                  x >= data[:width].to_i - 1 ||
                  y >= data[:height].to_i - 1
          value = layout[x + y * width]
          unless walkable_cell?(value)
            boss_ok = false
            break
          end
        end
        break unless boss_ok
      end
      errors.push(:boss_area_not_clear) unless boss_ok
    end
    return errors.uniq
  end

  def self.retry_seed(base_seed, attempt)
    return base_seed.to_i if attempt.to_i <= 0
    value = base_seed.to_i ^
            ((attempt.to_i + 1) * 1103515245) ^
            (attempt.to_i * 12345)
    value &= 0x7fffffff
    value = 1 if value == 0
    return value
  end

  def self.build_floor_state(run, floor)
    cfg = config(run[:key])
    base_seed = floor_seed(run[:base_seed], floor)
    max_attempts = cfg[:max_generate_attempts].to_i
    max_attempts = 12 if max_attempts <= 0

    data = nil
    runtime_cfg = nil
    actual_seed = base_seed
    errors = []
    used_attempt = 0

    for attempt in 0...max_attempts
      actual_seed = retry_seed(base_seed, attempt)
      runtime_cfg = runtime_config(cfg, floor, actual_seed)
      generator = Generator.new(runtime_cfg, actual_seed)
      data = generator.generate
      errors = generation_validation_errors(data, runtime_cfg)
      used_attempt = attempt + 1
      break if errors.empty?
    end

    if !errors.empty? && cfg[:raise_on_generate_failure]
      raise("FS Random Dungeon generation failed: " + errors.inspect)
    end

    return {
      :key                   => run[:key],
      :generation_id         => run[:generation_id],
      :floor                 => floor,
      :floor_count           => run[:floor_count],
      :seed                  => actual_seed,
      :base_floor_seed       => base_seed,
      :generation_attempt    => used_attempt,
      :generation_warnings   => errors,
      :environment_affixes   => runtime_cfg[:resolved_affixes] || [],
      :explored_cells        => {},
      :exploration_version   => 0,
      :skin                  => runtime_cfg[:skin],
      :schema_version        => GENERATOR_SCHEMA,
      :map_id                => cfg[:map_id],
      :width                 => data[:width],
      :height                => data[:height],
      :layout                => data[:layout],
      :rooms                 => data[:rooms],
      :room_types            => data[:room_types] || [],
      :room_depths           => data[:room_depths] || [],
      :room_links            => data[:room_links] || {},
      :entrance              => data[:entrance],
      :exit                  => data[:exit],
      :event_positions       => {},
      :event_room_ids        => {},
      :event_counts_resolved => runtime_cfg[:event_counts_resolved] || {},
      :generated_events      => nil,
      :completed_events      => {},
      :fixed_event_positions => data[:fixed_event_positions] || {},
      :last_player_pos       => nil,
      :visited               => false,
      :created_at            => Time.now.to_i
    }
  end

  def self.ensure_floor_state(run, floor)
    floor = floor.to_i
    floor = 1 if floor < 1
    floor = run[:floor_count] if floor > run[:floor_count]
    state = run[:floors][floor]
    if state == nil
      state = build_floor_state(run, floor)
      run[:floors][floor] = state
    end
    return state
  end

  def self.generate_run(key, forced_seed = nil, carry = nil)
    cfg = config(key)
    old = normalize_run_state(key)
    carry ||= {}
    generation_id = old == nil ? 1 : old[:generation_id].to_i + 1
    base_seed = forced_seed == nil ? make_seed : forced_seed.to_i
    base_seed &= 0x7fffffff
    base_seed = 1 if base_seed == 0
    current_floor = carry[:current_floor].to_i
    current_floor = 1 if current_floor < 1
    current_floor = floor_count_for(cfg) if current_floor > floor_count_for(cfg)
    persistent_flags = carry[:persistent_flags]
    persistent_flags = old[:persistent_flags] if persistent_flags == nil && old != nil
    persistent_flags ||= {}
    run = {
      :key                  => key,
      :generation_id        => generation_id,
      :base_seed            => base_seed,
      :map_id               => cfg[:map_id],
      :skin                 => cfg[:skin],
      :floor_count          => floor_count_for(cfg),
      :current_floor        => current_floor,
      :floors               => {},
      :persistent_flags     => persistent_flags,
      :pending_reset_reason => nil,
      :last_reset_day       => current_day_key,
      :entry_count          => carry[:entry_count].to_i,
      :clear_count          => carry[:clear_count].to_i,
      :cleared              => false,
      :created_at           => Time.now.to_i
    }
    $game_system.fs_rd_states[key] = run
    ensure_floor_state(run, current_floor)
    return run
  end

  def self.reset_categories_for(rules)
    result = []
    result.push(:treasure) if rules[:reset_treasure]
    result.push(:battle)   if rules[:respawn_battle]
    result.push(:elite)    if rules[:respawn_elite]
    result.push(:heal)     if rules[:reset_heal]
    result.push(:soul)     if rules[:reset_soul]
    result.push(:boss)     if rules[:reset_boss]
    return result
  end

  def self.event_ids_by_floor_and_type(run, categories)
    result = {}
    return result if run == nil
    cfg = config(run[:key])
    map = load_template_map(cfg)
    run[:floors].each do |floor, state|
      next if state == nil
      row = {}
      categories.each { |type| row[type] = [] }

      (state[:generated_events] || []).each do |entry|
        type = entry[:type]
        if row[type] != nil
          row[type].push(entry[:event_id].to_i)
        end
      end

      if map != nil && map.events != nil
        map.events.each do |event_id, event|
          next if event == nil
          next unless event_enabled_on_floor_name?(event.name.to_s, floor)
          type = event_progress_type_name(event.name.to_s)
          next if row[type] == nil
          if cfg[:event_generation_enabled] == false || type == :boss
            row[type].push(event_id.to_i)
          end
        end
      end
      row.each_value { |ids| ids.uniq! }
      result[floor.to_i] = row
    end
    return result
  end

  def self.clear_category_progress(run, categories)
    return if run == nil || categories.empty?
    ids = event_ids_by_floor_and_type(run, categories)
    if $game_self_switches != nil &&
       $game_self_switches.respond_to?(:fs_rd_clear_event_groups)
      $game_self_switches.fs_rd_clear_event_groups(
        run[:key], run[:generation_id], ids
      )
    end

    run[:floors].each do |floor, state|
      next if state == nil
      row = ids[floor.to_i] || {}
      target = []
      row.each_value { |values| target.concat(values) }
      state[:completed_events] ||= {}
      state[:completed_events].delete_if do |event_id, type|
        target.include?(event_id.to_i)
      end
    end
  end

  def self.reroll_generated_event_pools(run)
    return if run == nil
    cfg = config(run[:key])
    map = load_template_map(cfg)
    max_id = 0
    if map != nil && map.events != nil
      map.events.each_key do |event_id|
        max_id = event_id.to_i if event_id.to_i > max_id
      end
    end
    run[:floors].each_value do |state|
      next if state == nil
      state[:generated_events] = nil
      state[:event_positions] ||= {}
      state[:event_room_ids] ||= {}
      state[:completed_events] ||= {}
      state[:event_positions].delete_if { |event_id, pos| event_id.to_i > max_id }
      state[:event_room_ids].delete_if { |event_id, room| event_id.to_i > max_id }
      state[:completed_events].delete_if { |event_id, type| event_id.to_i > max_id }
    end
  end

  def self.apply_reset_cycle(key, reason = :manual, forced_seed = nil)
    run = normalize_run_state(key)
    return nil if run == nil
    cfg = config(key)
    rules = reset_rules_for(cfg)
    rebuild = rules[:rebuild_layout] == true
    rebuild = true if reason == :entry

    if rules[:reset_soul]
      clear_persistent_type(run, :soul)
    end
    if rules[:reset_boss]
      clear_persistent_type(run, :boss)
    end

    if rebuild
      carry = {
        :persistent_flags => run[:persistent_flags] || {},
        :current_floor => rules[:preserve_floor_progress] == false ?
                          1 : run[:current_floor].to_i,
        :entry_count => run[:entry_count].to_i,
        :clear_count => run[:clear_count].to_i
      }
      old_seed = run[:base_seed].to_i
      Runtime.clear_run(run)
      if $game_self_switches != nil &&
         $game_self_switches.respond_to?(:fs_rd_clear_dungeon)
        $game_self_switches.fs_rd_clear_dungeon(key)
      end
      seed = forced_seed
      if seed == nil
        if reason == :entry
          seed = make_seed
        else
          seed = rules[:new_seed_on_rebuild] == false ? old_seed : make_seed
        end
      end
      run = generate_run(key, seed, carry)
    else
      categories = reset_categories_for(rules)
      clear_category_progress(run, categories)
      reroll_generated_event_pools(run) if rules[:reroll_event_pool]
      if rules[:reset_exploration]
        run[:floors].each_value do |state|
          next if state == nil
          state[:explored_cells] = {}
          state[:exploration_version] =
            state[:exploration_version].to_i + 1
        end
      end
      unless rules[:preserve_floor_progress]
        run[:current_floor] = 1
        run[:floors].each_value do |state|
          next if state == nil
          state[:last_player_pos] = nil
          state[:visited] = false
        end
      end
    end

    run[:cleared] = false
    run[:pending_reset_reason] = nil
    run[:last_reset_day] = current_day_key
    run[:last_reset_reason] = reason
    run[:last_reset_at] = Time.now.to_i
    run[:reset_count] = run[:reset_count].to_i + 1
    return run
  end

  # 手動套用 reset_rules；不同於 reset，這不會無條件清空全部進度。
  def self.refresh(key, forced_seed = nil)
    run = normalize_run_state(key)
    return nil if run == nil
    if active? && current_run != nil && current_run[:key] == key
      run[:pending_reset_reason] = :manual
      run[:pending_forced_seed] = forced_seed
      return run
    end
    return apply_reset_cycle(key, :manual, forced_seed)
  end

  #--------------------------------------------------------------------------
  # 進入前準備。
  # floor 省略時回到 run[:current_floor]。
  #--------------------------------------------------------------------------
  def self.prepare(key, regenerate = false, forced_seed = nil, floor = nil)
    cfg = config(key)
    run = normalize_run_state(key)
    external_entry = true
    if active?
      current = current_run
      external_entry = false if current != nil && current[:key] == key
    end

    regenerate = true if run != nil && !state_matches_template?(run, cfg)

    if !regenerate && run != nil
      reason = auto_reset_reason(key, run, external_entry)
      if reason != nil
        pending_seed = run[:pending_forced_seed]
        run[:pending_forced_seed] = nil
        run = apply_reset_cycle(key, reason, pending_seed)
      end
    end

    if regenerate || run == nil
      Runtime.clear_run(run) if run != nil
      if $game_self_switches != nil &&
         $game_self_switches.respond_to?(:fs_rd_clear_dungeon)
        $game_self_switches.fs_rd_clear_dungeon(key)
      end
      carry = nil
      if run != nil
        carry = {
          :persistent_flags => run[:persistent_flags] || {},
          :current_floor => 1,
          :entry_count => run[:entry_count].to_i,
          :clear_count => run[:clear_count].to_i
        }
      end
      run = generate_run(key, forced_seed, carry)
    end

    if external_entry
      run[:entry_count] = run[:entry_count].to_i + 1
      run[:last_entry_at] = Time.now.to_i
    end

    target_floor = floor == nil ? run[:current_floor].to_i : floor.to_i
    target_floor = 1 if target_floor < 1
    target_floor = run[:floor_count] if target_floor > run[:floor_count]
    state = ensure_floor_state(run, target_floor)
    run[:current_floor] = target_floor

    cfg = config(key)
    mode = :entrance
    if cfg[:resume_position] != false &&
       state[:visited] &&
       valid_position?(state, state[:last_player_pos])
      mode = :resume
    end

    $game_temp.fs_rd_pending_key = key
    $game_temp.fs_rd_pending_floor = target_floor
    $game_temp.fs_rd_place_mode = mode
    $game_temp.fs_rd_place_player = true
    $game_temp.fs_rd_force_setup = false
    return state
  end

  # prepare + 場所移動的簡化版。
  def self.enter(key, regenerate = false, forced_seed = nil, floor = nil)
    state = prepare(key, regenerate, forced_seed, floor)
    cfg = config(key)
    if $game_map != nil && $game_map.map_id.to_i == cfg[:map_id].to_i
      $game_temp.fs_rd_force_setup = true
    end
    $game_player.reserve_transfer(cfg[:map_id].to_i, 0, 0, 2)
    return state
  end

  def self.request_floor_transfer(run, target_floor, place_mode)
    state = ensure_floor_state(run, target_floor)
    save_current_player_position
    run[:current_floor] = target_floor
    $game_temp.fs_rd_pending_key = run[:key]
    $game_temp.fs_rd_pending_floor = target_floor
    $game_temp.fs_rd_place_mode = place_mode
    $game_temp.fs_rd_place_player = true
    $game_temp.fs_rd_force_setup = true
    $game_player.reserve_transfer(run[:map_id].to_i, 0, 0, 2)
    return state
  end

  def self.next_floor
    run = current_run
    return false if run == nil
    floor = current_floor
    return false if floor >= run[:floor_count].to_i
    request_floor_transfer(run, floor + 1, :entrance)
    return true
  end

  def self.previous_floor
    run = current_run
    return false if run == nil
    floor = current_floor
    return false if floor <= 1
    request_floor_transfer(run, floor - 1, :exit)
    return true
  end

  def self.go_to_floor(floor, place_mode = :entrance)
    run = current_run
    return false if run == nil
    target = floor.to_i
    return false if target < 1 || target > run[:floor_count].to_i
    request_floor_transfer(run, target, place_mode)
    return true
  end

  #--------------------------------------------------------------------------
  # 迷宮 → 特定房間 → 下一座迷宮
  #
  # count_as_exit = false 時，不啟動目前迷宮的 :on_exit 重置。
  #--------------------------------------------------------------------------
  def self.leave_to_map(map_id, x, y, direction = 2, count_as_exit = true)
    return false if $game_player == nil
    if $game_temp != nil
      $game_temp.fs_rd_suppress_exit_reset = !count_as_exit
    end
    $game_player.reserve_transfer(
      map_id.to_i, x.to_i, y.to_i, direction.to_i
    )
    return true
  end

  def self.reset(key)
    run = normalize_run_state(key)
    Runtime.clear_run(run) if run != nil
    $game_system.fs_rd_states.delete(key)
    if $game_self_switches != nil &&
       $game_self_switches.respond_to?(:fs_rd_clear_dungeon)
      $game_self_switches.fs_rd_clear_dungeon(key)
    end
    if $game_temp.fs_rd_pending_key == key
      $game_temp.fs_rd_pending_key = nil
      $game_temp.fs_rd_pending_floor = nil
      $game_temp.fs_rd_place_mode = nil
      $game_temp.fs_rd_place_player = false
      $game_temp.fs_rd_force_setup = false
      $game_temp.fs_rd_suppress_exit_reset = false
      $game_temp.fs_rd_minimap_visible = nil
      $game_temp.fs_rd_fullmap_visible = false
    end
  end

  def self.active?
    return false if $game_map == nil
    return $game_map.fs_rd_active?
  end

  def self.current_run
    return nil unless active?
    return $game_map.fs_rd_run
  end

  def self.current_state
    return nil unless active?
    return $game_map.fs_rd_state
  end

  def self.current_floor
    run = current_run
    return 0 if run == nil
    return run[:current_floor].to_i
  end

  def self.floor_count
    run = current_run
    return 0 if run == nil
    return run[:floor_count].to_i
  end

  def self.generated_event_count(type = nil)
    state = current_state
    return 0 if state == nil
    events = state[:generated_events] || []
    return events.size if type == nil
    count = 0
    events.each { |entry| count += 1 if entry[:type] == type }
    return count
  end

  def self.generated_event_summary
    result = {}
    EVENT_POOL_TYPES.each do |type|
      result[type] = generated_event_count(type)
    end
    return result
  end

  def self.reset_status(key = nil)
    run = key == nil ? current_run : normalize_run_state(key)
    return nil if run == nil
    cfg = config(run[:key])
    return {
      :mode                 => reset_mode_for(cfg),
      :pending_reason       => run[:pending_reset_reason],
      :last_reset_reason    => run[:last_reset_reason],
      :last_reset_day       => run[:last_reset_day],
      :reset_count          => run[:reset_count].to_i,
      :entry_count          => run[:entry_count].to_i,
      :clear_count          => run[:clear_count].to_i,
      :cleared              => run[:cleared] == true,
      :current_floor        => run[:current_floor].to_i,
      :persistent_flag_count=> (run[:persistent_flags] || {}).size
    }
  end

  def self.progress_summary(key = nil)
    run = key == nil ? current_run : normalize_run_state(key)
    return nil if run == nil
    floors = {}
    run[:floors].each do |floor, state|
      next if state == nil
      counts = {}
      PROGRESS_TYPES.each { |type| counts[type] = 0 }
      (state[:completed_events] || {}).each_value do |type|
        counts[type] = counts[type].to_i + 1 if counts.has_key?(type)
      end
      floors[floor.to_i] = counts
    end
    return {
      :floors           => floors,
      :persistent_flags => (run[:persistent_flags] || {}).dup,
      :cleared          => run[:cleared] == true,
      :clear_count      => run[:clear_count].to_i
    }
  end

  def self.current_room_type
    return nil if $game_map == nil || !$game_map.fs_rd_active?
    state = $game_map.fs_rd_state
    return nil if state == nil || $game_player == nil
    room_id = nil
    rooms = state[:rooms] || []
    rooms.each_with_index do |room, index_id|
      next if room == nil
      if $game_player.x >= room[0].to_i &&
         $game_player.x < room[0].to_i + room[2].to_i &&
         $game_player.y >= room[1].to_i &&
         $game_player.y < room[1].to_i + room[3].to_i
        room_id = index_id
        break
      end
    end
    return nil if room_id == nil
    return (state[:room_types] || [])[room_id]
  end

  def self.final_floor?
    return false unless active?
    return current_floor >= floor_count
  end

  #--------------------------------------------------------------------------
  # v0.9.0 探索進度
  #--------------------------------------------------------------------------
  def self.exploration_store(state = nil)
    state ||= current_state
    return {} if state == nil
    state[:explored_cells] ||= {}
    state[:exploration_version] = state[:exploration_version].to_i
    return state[:explored_cells]
  end

  def self.exploration_index(state, x, y)
    return x.to_i + y.to_i * state[:width].to_i
  end

  def self.explored?(x, y, state = nil)
    state ||= current_state
    return false if state == nil
    return false if x.to_i < 0 || y.to_i < 0
    return false if x.to_i >= state[:width].to_i
    return false if y.to_i >= state[:height].to_i
    return exploration_store(state)[exploration_index(state, x, y)] == true
  end

  def self.reveal_cell(state, x, y)
    return false if state == nil
    x = x.to_i
    y = y.to_i
    return false if x < 0 || y < 0
    return false if x >= state[:width].to_i
    return false if y >= state[:height].to_i
    index_id = exploration_index(state, x, y)
    store = exploration_store(state)
    return false if store[index_id]
    store[index_id] = true
    return true
  end

  def self.room_id_at_state(state, x, y)
    return nil if state == nil
    rooms = state[:rooms] || []
    rooms.each_with_index do |room, room_id|
      next if room == nil
      if x.to_i >= room[0].to_i &&
         x.to_i < room[0].to_i + room[2].to_i &&
         y.to_i >= room[1].to_i &&
         y.to_i < room[1].to_i + room[3].to_i
        return room_id
      end
    end
    return nil
  end

  def self.reveal_position(x = nil, y = nil)
    state = current_state
    return false if state == nil || $game_player == nil
    x = $game_player.x if x == nil
    y = $game_player.y if y == nil
    cfg = config(state[:key])
    changed = false

    radius = cfg[:exploration_reveal_radius].to_i
    radius = 0 if radius < 0
    for dy in -radius..radius
      for dx in -radius..radius
        next if dx * dx + dy * dy > radius * radius + 1
        changed = true if reveal_cell(state, x + dx, y + dy)
      end
    end

    if cfg[:exploration_reveal_room] != false
      room_id = room_id_at_state(state, x, y)
      room = room_id == nil ? nil : (state[:rooms] || [])[room_id]
      if room != nil
        border = cfg[:exploration_room_border].to_i
        border = 0 if border < 0
        x1 = room[0].to_i - border
        y1 = room[1].to_i - border
        x2 = room[0].to_i + room[2].to_i - 1 + border
        y2 = room[1].to_i + room[3].to_i - 1 + border
        for ry in y1..y2
          for rx in x1..x2
            changed = true if reveal_cell(state, rx, ry)
          end
        end
      end
    end

    if changed
      state[:exploration_version] =
        state[:exploration_version].to_i + 1
    end
    return changed
  end

  def self.reveal_all
    state = current_state
    return false if state == nil
    changed = false
    for y in 0...state[:height].to_i
      for x in 0...state[:width].to_i
        changed = true if reveal_cell(state, x, y)
      end
    end
    if changed
      state[:exploration_version] =
        state[:exploration_version].to_i + 1
    end
    return changed
  end

  def self.clear_exploration
    state = current_state
    return false if state == nil
    state[:explored_cells] = {}
    state[:exploration_version] =
      state[:exploration_version].to_i + 1
    reveal_position
    return true
  end

  def self.explored_percent
    state = current_state
    return 0 if state == nil
    layout = state[:layout] || []
    total = 0
    found = 0
    layout.each_with_index do |value, index_id|
      next unless walkable_cell?(value)
      total += 1
      found += 1 if exploration_store(state)[index_id]
    end
    return 0 if total <= 0
    return ((found * 100.0) / total).to_i
  end

  #--------------------------------------------------------------------------
  # 迷你地圖顯示狀態
  #--------------------------------------------------------------------------
  def self.initialize_map_visibility
    return if $game_temp == nil || current_state == nil
    cfg = config(current_state[:key])
    if $game_temp.fs_rd_minimap_visible == nil
      $game_temp.fs_rd_minimap_visible =
        cfg[:minimap_default_visible] != false
    end
    $game_temp.fs_rd_fullmap_visible = false if
      $game_temp.fs_rd_fullmap_visible == nil
  end

  def self.minimap_visible?
    return false unless active?
    state = current_state
    return false if state == nil
    cfg = config(state[:key])
    return false if cfg[:minimap_enabled] == false
    initialize_map_visibility
    return false if $game_temp.fs_rd_fullmap_visible
    return $game_temp.fs_rd_minimap_visible == true
  end

  def self.fullmap_visible?
    return false unless active?
    state = current_state
    return false if state == nil
    cfg = config(state[:key])
    return false if cfg[:minimap_enabled] == false
    initialize_map_visibility
    return $game_temp.fs_rd_fullmap_visible == true
  end

  def self.minimap_on
    return false unless active?
    initialize_map_visibility
    $game_temp.fs_rd_minimap_visible = true
    return true
  end

  def self.minimap_off
    return false unless active?
    initialize_map_visibility
    $game_temp.fs_rd_minimap_visible = false
    return true
  end

  def self.minimap_toggle
    return false unless active?
    initialize_map_visibility
    $game_temp.fs_rd_minimap_visible =
      !$game_temp.fs_rd_minimap_visible
    return $game_temp.fs_rd_minimap_visible
  end

  def self.fullmap_toggle
    return false unless active?
    initialize_map_visibility
    $game_temp.fs_rd_fullmap_visible =
      !$game_temp.fs_rd_fullmap_visible
    return $game_temp.fs_rd_fullmap_visible
  end

  def self.input_key_triggered?(key_name)
    return false if key_name == nil
    begin
      key_code = Input.const_get(key_name.to_s)
      return Input.trigger?(key_code)
    rescue Exception
      return false
    end
  end

  def self.minimap_toggle_key_triggered?
    return false unless active?
    cfg = config(current_state[:key])
    return input_key_triggered?(cfg[:minimap_toggle_key])
  end

  def self.fullmap_toggle_key_triggered?
    return false unless active?
    cfg = config(current_state[:key])
    return input_key_triggered?(cfg[:fullmap_toggle_key])
  end

  #--------------------------------------------------------------------------
  # 迷你地圖資料與繪製
  #--------------------------------------------------------------------------
  def self.minimap_color_for(value)
    case value
    when CELL_FLOOR
      return Color.new(150, 158, 142, 255)
    when CELL_WALL
      return Color.new(68, 70, 76, 255)
    when CELL_ENTRANCE
      return Color.new(70, 220, 115, 255)
    when CELL_EXIT
      return Color.new(235, 80, 90, 255)
    when CELL_WATER
      return Color.new(45, 115, 160, 255)
    when CELL_BRIDGE_H, CELL_BRIDGE_V
      return Color.new(184, 127, 67, 255)
    else
      return Color.new(38, 39, 45, 255)
    end
  end

  def self.minimap_marker_color(type)
    case type
    when :battle
      return Color.new(232, 92, 67, 255)
    when :treasure
      return Color.new(255, 201, 62, 255)
    when :elite
      return Color.new(188, 86, 235, 255)
    when :heal
      return Color.new(75, 235, 160, 255)
    when :soul
      return Color.new(62, 174, 255, 255)
    when :boss
      return Color.new(255, 68, 80, 255)
    else
      return Color.new(235, 235, 235, 255)
    end
  end

  def self.minimap_geometry(state, width, height, padding, header_height = 0)
    map_w = [state[:width].to_i, 1].max
    map_h = [state[:height].to_i, 1].max
    available_w = width - padding * 2
    available_h = height - padding * 2 - header_height
    available_w = 1 if available_w < 1
    available_h = 1 if available_h < 1
    scale_x = available_w.to_f / map_w.to_f
    scale_y = available_h.to_f / map_h.to_f
    scale = [scale_x, scale_y].min
    cell = scale.floor
    cell = 1 if cell < 1
    draw_w = map_w * cell
    draw_h = map_h * cell
    origin_x = (width - draw_w) / 2
    origin_y = header_height + (height - header_height - draw_h) / 2
    return [cell, origin_x, origin_y]
  end

  def self.minimap_event_entries(state)
    result = []
    cfg = config(state[:key])
    shown = cfg[:minimap_show_events] || []
    shown = [shown] unless shown.is_a?(Array)

    if cfg[:event_generation_enabled] != false
      (state[:generated_events] || []).each do |descriptor|
        type = descriptor[:type]
        next unless shown.include?(type)
        event_id = descriptor[:event_id].to_i
        pos = (state[:event_positions] || {})[event_id]
        next if pos == nil
        result.push([event_id, type, pos])
      end
    else
      map = load_template_map(cfg)
      if map != nil && map.events != nil
        map.events.each do |event_id, event|
          next if event == nil
          type = event_progress_type_name(event.name.to_s)
          next unless shown.include?(type)
          pos = (state[:event_positions] || {})[event_id.to_i]
          next if pos == nil
          result.push([event_id.to_i, type, pos])
        end
      end
    end

    if shown.include?(:boss) && state[:floor].to_i >= state[:floor_count].to_i
      completed = false
      (state[:completed_events] || {}).each_value do |type|
        completed = true if type == :boss
      end
      result.push([-1, :boss, state[:exit]]) unless completed
    end
    return result
  end

  def self.draw_minimap_marker(bitmap, x, y, size, color)
    marker = [size, 3].max
    half = marker / 2
    bitmap.fill_rect(x - half, y - half, marker, marker, Color.new(0,0,0,220))
    inner = [marker - 2, 1].max
    bitmap.fill_rect(x - half + 1, y - half + 1, inner, inner, color)
  end

  def self.create_minimap_bitmap(full_map = false)
    state = current_state
    return nil if state == nil
    cfg = config(state[:key])

    if full_map
      width = cfg[:fullmap_width].to_i
      height = cfg[:fullmap_height].to_i
      opacity = cfg[:fullmap_opacity].to_i
      width = 470 if width <= 0
      height = 350 if height <= 0
      padding = 14
      header_height = 34
    else
      width = cfg[:minimap_width].to_i
      height = cfg[:minimap_height].to_i
      opacity = cfg[:minimap_opacity].to_i
      padding = cfg[:minimap_padding].to_i
      width = 178 if width <= 0
      height = 138 if height <= 0
      padding = 7 if padding < 0
      header_height = 0
    end

    opacity = 0 if opacity < 0
    opacity = 255 if opacity > 255
    bitmap = Bitmap.new(width, height)
    bitmap.fill_rect(0, 0, width, height, Color.new(0, 0, 0, opacity))
    border = Color.new(230, 230, 230, [opacity / 2, 60].max)
    bitmap.fill_rect(0, 0, width, 1, border)
    bitmap.fill_rect(0, height - 1, width, 1, border)
    bitmap.fill_rect(0, 0, 1, height, border)
    bitmap.fill_rect(width - 1, 0, 1, height, border)

    if full_map
      bitmap.font.size = 18
      bitmap.font.bold = true
      cfg_name = cfg[:dungeon_display_name].to_s
      cfg_name = state[:key].to_s if cfg_name.empty?
      title = cfg_name + "｜" + state[:floor].to_i.to_s +
              "/" + state[:floor_count].to_i.to_s +
              "｜探索 " + explored_percent.to_i.to_s + "%"
      bitmap.draw_text(12, 3, width - 24, 28, title, 0)
    end

    geometry = minimap_geometry(
      state, width, height, padding, header_height
    )
    cell = geometry[0]
    origin_x = geometry[1]
    origin_y = geometry[2]
    layout = state[:layout] || []
    store = exploration_store(state)

    for y in 0...state[:height].to_i
      for x in 0...state[:width].to_i
        index_id = exploration_index(state, x, y)
        next unless store[index_id]
        value = layout[index_id]
        bitmap.fill_rect(
          origin_x + x * cell,
          origin_y + y * cell,
          cell, cell,
          minimap_color_for(value)
        )
      end
    end

    # 入口
    if cfg[:minimap_show_entrance] != false && state[:entrance] != nil
      pos = state[:entrance]
      if explored?(pos[0], pos[1], state)
        draw_minimap_marker(
          bitmap,
          origin_x + pos[0].to_i * cell + cell / 2,
          origin_y + pos[1].to_i * cell + cell / 2,
          [cell + 2, 5].max,
          Color.new(70, 255, 120, 255)
        )
      end
    end

    # 出口
    if cfg[:minimap_show_exit] != false && state[:exit] != nil
      pos = state[:exit]
      allowed = cfg[:minimap_exit_requires_explored] == false ||
                explored?(pos[0], pos[1], state)
      if allowed
        draw_minimap_marker(
          bitmap,
          origin_x + pos[0].to_i * cell + cell / 2,
          origin_y + pos[1].to_i * cell + cell / 2,
          [cell + 2, 5].max,
          Color.new(255, 88, 96, 255)
        )
      end
    end

    # 事件
    minimap_event_entries(state).each do |entry|
      event_id = entry[0]
      type = entry[1]
      pos = entry[2]
      next if pos == nil
      if cfg[:minimap_marker_requires_explored] != false
        next unless explored?(pos[0], pos[1], state)
      end
      if cfg[:minimap_hide_completed_events] != false && event_id >= 0
        next if (state[:completed_events] || {})[event_id] != nil
      end
      draw_minimap_marker(
        bitmap,
        origin_x + pos[0].to_i * cell + cell / 2,
        origin_y + pos[1].to_i * cell + cell / 2,
        [cell + 1, 4].max,
        minimap_marker_color(type)
      )
    end

    # 玩家
    if cfg[:minimap_show_player] != false && $game_player != nil
      draw_minimap_marker(
        bitmap,
        origin_x + $game_player.x.to_i * cell + cell / 2,
        origin_y + $game_player.y.to_i * cell + cell / 2,
        [cell + 3, 6].max,
        Color.new(255, 255, 255, 255)
      )
    end
    return bitmap
  end

  def self.minimap_position(cfg, width, height)
    offset_x = cfg[:minimap_offset_x].to_i
    offset_y = cfg[:minimap_offset_y].to_i
    anchor = cfg[:minimap_anchor] || :top_right
    case anchor
    when :top_left
      return [offset_x, offset_y]
    when :bottom_left
      return [offset_x, Graphics.height - height - offset_y]
    when :bottom_right
      return [
        Graphics.width - width - offset_x,
        Graphics.height - height - offset_y
      ]
    else
      return [
        Graphics.width - width - offset_x,
        offset_y
      ]
    end
  end

  def self.minimap_signature(full_map = false)
    state = current_state
    return "inactive" if state == nil
    cfg = config(state[:key])
    return [
      full_map,
      state[:key],
      state[:floor],
      state[:exploration_version],
      $game_player == nil ? 0 : $game_player.x,
      $game_player == nil ? 0 : $game_player.y,
      state[:completed_events],
      minimap_visible?,
      fullmap_visible?,
      cfg[:minimap_anchor],
      cfg[:minimap_width],
      cfg[:minimap_height],
      cfg[:fullmap_width],
      cfg[:fullmap_height],
      cfg[:minimap_show_events],
      cfg[:minimap_hide_completed_events]
    ].inspect
  end

  #--------------------------------------------------------------------------
  # 實際畫面戰爭迷霧
  #--------------------------------------------------------------------------
  def self.fog_of_war_enabled?
    return false unless active?
    state = current_state
    return false if state == nil
    return config(state[:key])[:fog_of_war_enabled] == true
  end

  def self.create_fog_of_war_bitmap
    state = current_state
    return nil if state == nil
    cfg = config(state[:key])
    opacity = cfg[:fog_of_war_opacity].to_i
    opacity = 0 if opacity < 0
    opacity = 255 if opacity > 255
    bitmap = Bitmap.new(
      state[:width].to_i * TILE_SIZE,
      state[:height].to_i * TILE_SIZE
    )
    store = exploration_store(state)
    for y in 0...state[:height].to_i
      for x in 0...state[:width].to_i
        index_id = exploration_index(state, x, y)
        next if store[index_id]
        bitmap.fill_rect(
          x * TILE_SIZE, y * TILE_SIZE,
          TILE_SIZE, TILE_SIZE,
          Color.new(0, 0, 0, opacity)
        )
      end
    end
    return bitmap
  end

  def self.fog_signature
    state = current_state
    return "inactive" if state == nil
    cfg = config(state[:key])
    return [
      state[:key],
      state[:floor],
      state[:exploration_version],
      cfg[:fog_of_war_enabled],
      cfg[:fog_of_war_opacity],
      cfg[:fog_of_war_z]
    ].inspect
  end

  #--------------------------------------------------------------------------
  # Forest Symphony 樓層提示與環境效果
  #--------------------------------------------------------------------------
  def self.floor_display_name(cfg, state)
    floor_names = cfg[:floor_display_names] || {}
    local_name = floor_names[state[:floor].to_i]
    dungeon_name = cfg[:dungeon_display_name].to_s
    dungeon_name = state[:key].to_s if dungeon_name.empty?
    base = dungeon_name + "・第 " + state[:floor].to_i.to_s + " 層"
    return local_name == nil || local_name.to_s.empty? ?
           base : base + "｜" + local_name.to_s
  end

  def self.floor_danger_text(cfg, state)
    table = cfg[:danger_by_floor] || {}
    level = table[state[:floor].to_i].to_i
    return nil if level <= 0
    level = 5 if level > 5
    return "危險度：" + ("★" * level) + ("☆" * (5 - level))
  end

  def self.queue_message(text)
    return false if text == nil || text.to_s.empty?
    if $game_map != nil && $game_map.respond_to?(:queue)
      queue = $game_map.queue
      if queue != nil && queue.respond_to?(:push)
        queue.push(text.to_s)
        return true
      end
    end
    return false
  end

  def self.deactivate_environment(run = nil)
    return if run == nil
    switches = run[:active_affix_switches] || []
    if $game_switches != nil
      switches.each do |switch_id|
        next if switch_id.to_i <= 0
        $game_switches[switch_id.to_i] = false
      end
    end
    run[:active_affix_switches] = []
  end

  def self.apply_environment_runtime(run, state)
    return if run == nil || state == nil
    deactivate_environment(run)
    active_switches = []
    (state[:environment_affixes] || []).each do |key|
      definition = ENVIRONMENT_AFFIXES[key]
      next if definition == nil

      if $game_switches != nil
        (definition[:switches_on] || []).each do |switch_id|
          next if switch_id.to_i <= 0
          $game_switches[switch_id.to_i] = true
          active_switches.push(switch_id.to_i)
        end
      end

      if $game_variables != nil
        (definition[:variables] || {}).each do |variable_id, value|
          next if variable_id.to_i <= 0
          $game_variables[variable_id.to_i] = value
        end
      end

      common_event_id = definition[:common_event_id].to_i
      if common_event_id > 0 && $game_temp != nil &&
         $game_temp.respond_to?(:common_event_id=)
        $game_temp.common_event_id = common_event_id
      end
    end
    run[:active_affix_switches] = active_switches.uniq
  end

  def self.show_floor_notice(run, state, first_visit)
    return if run == nil || state == nil
    cfg = config(run[:key])

    # 常駐 HUD 已包含樓層與環境資訊時，預設不再播放 Queue。
    # 避免 Forest Symphony 的 Message Queue 與 HUD 共用左上角。
    if cfg[:progress_hud_enabled] != false &&
       cfg[:show_floor_notice_with_hud] != true
      return
    end

    mode = cfg[:floor_notice_mode] || :first_visit
    return if mode == :never
    return if mode == :first_visit && !first_visit

    main = floor_display_name(cfg, state)
    danger = floor_danger_text(cfg, state)
    main += "｜" + danger if danger != nil
    queue_message(main)

    if cfg[:show_affix_notice] != false
      names = []
      (state[:environment_affixes] || []).each do |key|
        definition = ENVIRONMENT_AFFIXES[key]
        names.push(definition[:name].to_s) if definition != nil
      end
      queue_message("環境：" + names.join("／")) unless names.empty?
    end
  end

  def self.on_floor_enter(run, state, first_visit)
    apply_environment_runtime(run, state)
    initialize_map_visibility
    show_floor_notice(run, state, first_visit)
  end

  #--------------------------------------------------------------------------
  # 常駐迷宮進度 HUD
  #--------------------------------------------------------------------------
  def self.progress_hud_enabled?
    return false unless active?
    run = current_run
    return false if run == nil
    cfg = config(run[:key])
    return cfg[:progress_hud_enabled] != false
  end

  def self.progress_hud_replace(template, cfg, state)
    text = template.to_s
    progress_format =
      cfg[:progress_hud_progress_format] || "%floor%/%total%"
    progress = progress_format.to_s
    progress = progress.gsub("%floor%", state[:floor].to_i.to_s)
    progress = progress.gsub("%total%", state[:floor_count].to_i.to_s)

    dungeon_name = cfg[:dungeon_display_name].to_s
    dungeon_name = state[:key].to_s if dungeon_name.empty?

    floor_names = cfg[:floor_display_names] || {}
    floor_name = floor_names[state[:floor].to_i].to_s

    affix_names = []
    (state[:environment_affixes] || []).each do |key|
      definition = ENVIRONMENT_AFFIXES[key]
      affix_names.push(definition[:name].to_s) if definition != nil
    end
    if affix_names.empty?
      affixes = cfg[:progress_hud_empty_affix].to_s
    else
      affixes = affix_names.join("／")
    end

    danger = floor_danger_text(cfg, state).to_s
    danger = "" unless cfg[:progress_hud_show_danger] != false

    replacements = {
      "%dungeon%"    => dungeon_name,
      "%floor%"      => state[:floor].to_i.to_s,
      "%total%"      => state[:floor_count].to_i.to_s,
      "%progress%"   => progress,
      "%floor_name%" => floor_name,
      "%affixes%"    => affixes,
      "%danger%"     => danger,
      "%explored%"   => explored_percent.to_i.to_s + "%"
    }
    replacements.each do |token, value|
      text = text.gsub(token, value.to_s)
    end
    text = text.gsub("｜｜", "｜")
    text = text.sub(/\A｜/, "")
    text = text.sub(/｜\z/, "")
    return text
  end

  def self.progress_hud_lines
    state = current_state
    return [] if state == nil
    cfg = config(state[:key])
    title_format =
      cfg[:progress_hud_title_format] || "%dungeon%｜%progress%"
    affix_format =
      cfg[:progress_hud_affix_format] || "環境：%affixes%"
    lines = []
    title = progress_hud_replace(title_format, cfg, state)
    affix = progress_hud_replace(affix_format, cfg, state)
    lines.push(title) unless title.empty?
    lines.push(affix) unless affix.empty?
    return lines
  end

  def self.progress_hud_signature
    state = current_state
    return "inactive" if state == nil
    cfg = config(state[:key])
    return [
      state[:key],
      state[:floor],
      state[:floor_count],
      state[:environment_affixes],
      cfg[:progress_hud_enabled],
      cfg[:show_floor_notice_with_hud],
      cfg[:progress_hud_anchor],
      cfg[:progress_hud_offset_x],
      cfg[:progress_hud_offset_y],
      cfg[:progress_hud_width],
      cfg[:progress_hud_height],
      cfg[:progress_hud_title_format],
      cfg[:progress_hud_progress_format],
      cfg[:progress_hud_affix_format],
      cfg[:progress_hud_show_danger],
      state[:exploration_version]
    ].inspect
  end

  def self.progress_hud_position(cfg, width, height)
    offset_x = cfg[:progress_hud_offset_x].to_i
    offset_y = cfg[:progress_hud_offset_y].to_i
    anchor = cfg[:progress_hud_anchor] || :top_left
    case anchor
    when :top_right
      return [Graphics.width - width - offset_x, offset_y]
    when :bottom_left
      return [offset_x, Graphics.height - height - offset_y]
    when :bottom_right
      return [
        Graphics.width - width - offset_x,
        Graphics.height - height - offset_y
      ]
    else
      return [offset_x, offset_y]
    end
  end

  def self.create_progress_hud_bitmap
    state = current_state
    return nil if state == nil
    cfg = config(state[:key])
    width = cfg[:progress_hud_width].to_i
    height = cfg[:progress_hud_height].to_i
    width = 310 if width <= 0
    height = 58 if height <= 0
    opacity = cfg[:progress_hud_opacity].to_i
    opacity = 0 if opacity < 0
    opacity = 255 if opacity > 255

    bitmap = Bitmap.new(width, height)
    bitmap.fill_rect(
      0, 0, width, height,
      Color.new(0, 0, 0, opacity)
    )
    border = Color.new(255, 255, 255, [opacity / 2, 40].max)
    bitmap.fill_rect(0, 0, width, 1, border)
    bitmap.fill_rect(0, height - 1, width, 1, border)
    bitmap.fill_rect(0, 0, 1, height, border)
    bitmap.fill_rect(width - 1, 0, 1, height, border)

    bitmap.font.size = cfg[:progress_hud_font_size].to_i
    bitmap.font.size = 18 if bitmap.font.size <= 0
    bitmap.font.bold = true

    lines = progress_hud_lines
    line_height = height / [lines.size, 1].max
    lines.each_with_index do |line, index_id|
      bitmap.draw_text(
        10, index_id * line_height,
        width - 20, line_height,
        line.to_s, 0
      )
    end
    return bitmap
  end

  def self.save_current_player_position
    return unless active?
    state = current_state
    return if state == nil || $game_player == nil
    pos = [$game_player.x, $game_player.y]
    state[:last_player_pos] = pos if valid_position?(state, pos)
  end

  def self.valid_position?(state, pos)
    return false if state == nil || pos == nil
    x = pos[0].to_i
    y = pos[1].to_i
    width = state[:width].to_i
    height = state[:height].to_i
    return false if x < 0 || y < 0 || x >= width || y >= height
    value = state[:layout][x + y * width]
    return walkable_cell?(value)
  end

  def self.walkable_cell?(value)
    WALKABLE_CELLS.include?(value)
  end

end
FS_RANDOM_DUNGEON = FS_RandomDungeon unless defined?(FS_RANDOM_DUNGEON)

#==============================================================================
# ■ Forest Symphony Debug 視覺層
#==============================================================================
module FS_RandomDungeon
  ROOM_DEBUG_COLORS = {
    :entrance => Color.new(70, 190, 110, 80),
    :stairs   => Color.new(80, 150, 230, 80),
    :boss     => Color.new(220, 70, 90, 90),
    :battle   => Color.new(210, 90, 75, 70),
    :treasure => Color.new(225, 180, 65, 75),
    :elite    => Color.new(160, 80, 210, 75),
    :heal     => Color.new(70, 200, 150, 75),
    :soul     => Color.new(70, 150, 235, 75),
    :empty    => Color.new(180, 180, 180, 35)
  }

  def self.debug_visual?
    return false if $game_temp == nil
    return $game_temp.fs_rd_debug_visual == true
  end

  def self.debug_on
    return false unless active?
    $game_temp.fs_rd_debug_visual = true
    return true
  end

  def self.debug_off
    return false if $game_temp == nil
    $game_temp.fs_rd_debug_visual = false
    return true
  end

  def self.debug_toggle
    return debug_visual? ? debug_off : debug_on
  end

  def self.debug_key_triggered?
    return false unless active?
    cfg = config(current_run[:key])
    key_name = cfg[:debug_toggle_key]
    return false if key_name == nil
    begin
      key_code = Input.const_get(key_name.to_s)
      return Input.trigger?(key_code)
    rescue Exception
      return false
    end
  end

  def self.debug_room_color(type)
    return ROOM_DEBUG_COLORS[type] || Color.new(255, 255, 255, 35)
  end

  def self.create_debug_bitmap(state)
    width = state[:width].to_i
    height = state[:height].to_i
    bitmap = Bitmap.new(width * TILE_SIZE, height * TILE_SIZE)
    bitmap.font.size = 15
    bitmap.font.bold = true

    cfg = config(state[:key])
    if cfg[:debug_show_collision]
      for y in 0...height
        for x in 0...width
          value = state[:layout][x + y * width]
          color = case value
          when CELL_WATER
            Color.new(30, 120, 220, 70)
          when CELL_WALL, CELL_VOID
            Color.new(220, 50, 50, 45)
          else
            Color.new(50, 220, 100, 22)
          end
          bitmap.fill_rect(x * TILE_SIZE, y * TILE_SIZE,
                           TILE_SIZE, TILE_SIZE, color)
        end
      end
    end

    rooms = state[:rooms] || []
    types = state[:room_types] || []
    rooms.each_with_index do |room, room_id|
      next if room == nil
      x = room[0].to_i * TILE_SIZE
      y = room[1].to_i * TILE_SIZE
      w = room[2].to_i * TILE_SIZE
      h = room[3].to_i * TILE_SIZE
      type = types[room_id] || :empty
      bitmap.fill_rect(x, y, w, h, debug_room_color(type))
      border = Color.new(255, 255, 255, 150)
      bitmap.fill_rect(x, y, w, 2, border)
      bitmap.fill_rect(x, y + h - 2, w, 2, border)
      bitmap.fill_rect(x, y, 2, h, border)
      bitmap.fill_rect(x + w - 2, y, 2, h, border)
      bitmap.draw_text(x + 3, y + 2, w - 6, 20,
                       room_id.to_s + ":" + type.to_s, 0)
    end

    entrance = state[:entrance]
    exit_pos = state[:exit]
    if entrance != nil
      bitmap.fill_rect(entrance[0] * TILE_SIZE,
                       entrance[1] * TILE_SIZE,
                       TILE_SIZE, TILE_SIZE,
                       Color.new(0, 255, 80, 180))
    end
    if exit_pos != nil
      bitmap.fill_rect(exit_pos[0] * TILE_SIZE,
                       exit_pos[1] * TILE_SIZE,
                       TILE_SIZE, TILE_SIZE,
                       Color.new(255, 70, 70, 180))
    end

    (state[:event_positions] || {}).each do |event_id, pos|
      next if pos == nil
      x = pos[0].to_i * TILE_SIZE
      y = pos[1].to_i * TILE_SIZE
      bitmap.fill_rect(x + 7, y + 7, 18, 18,
                       Color.new(255, 220, 30, 190))
      bitmap.draw_text(x, y + 5, TILE_SIZE, 20,
                       event_id.to_i.to_s, 1)
    end
    return bitmap
  end
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :fs_rd_pending_key
  attr_accessor :fs_rd_pending_floor
  attr_accessor :fs_rd_place_mode
  attr_accessor :fs_rd_place_player
  attr_accessor :fs_rd_force_setup
  attr_accessor :fs_rd_suppress_exit_reset
  attr_accessor :fs_rd_debug_visual
  attr_accessor :fs_rd_minimap_visible
  attr_accessor :fs_rd_fullmap_visible

  unless method_defined?(:fs_rd_initialize_v098fs)
    alias fs_rd_initialize_v098fs initialize
  end
  def initialize
    fs_rd_initialize_v098fs
    @fs_rd_pending_key = nil
    @fs_rd_pending_floor = nil
    @fs_rd_place_mode = nil
    @fs_rd_place_player = false
    @fs_rd_force_setup = false
    @fs_rd_suppress_exit_reset = false
    @fs_rd_debug_visual = false
    @fs_rd_minimap_visible = nil
    @fs_rd_fullmap_visible = false
  end
end

#==============================================================================
# ■ Random Encounter Floor Filter
#------------------------------------------------------------------------------
#  Map 48 的 encounter_list 保留原生權重與平均步數，只依目前迷宮樓層
#  過濾敵人隊伍 ID。
#==============================================================================
module FS_RandomDungeon
  def self.floor_spec_includes?(spec, floor)
    floor = floor.to_i
    spec.to_s.split(",").each do |part|
      value = part.to_s.strip
      if value =~ /\A(\d+)\s*-\s*(\d+)\z/
        first = $1.to_i
        last = $2.to_i
        first, last = last, first if first > last
        return true if floor >= first && floor <= last
      elsif value =~ /\A(\d+)\z/
        return true if floor == $1.to_i
      end
    end
    return false
  end

  def self.troop_name_floor_rule(name, floor)
    text = name.to_s
    tagged = false
    allowed = false

    text.scan(/<FLOOR\s*:?\s*(\d+)\s*>/i).each do |match|
      tagged = true
      value = match.is_a?(Array) ? match[0] : match
      allowed = true if floor.to_i == value.to_i
    end

    text.scan(/<FLOORS\s*:\s*([^>]+)>/i).each do |match|
      tagged = true
      value = match.is_a?(Array) ? match[0] : match
      allowed = true if floor_spec_includes?(value, floor)
    end

    return [tagged, allowed]
  end

  def self.encounter_troop_allowed?(troop_id, floor, cfg = nil)
    troop_id = troop_id.to_i
    return false if troop_id <= 0
    return false if $data_troops == nil
    troop = $data_troops[troop_id]
    return false if troop == nil

    rule = troop_name_floor_rule(troop.name.to_s, floor)
    tagged = rule[0]
    allowed = rule[1]
    return allowed if tagged

    cfg ||= current_state == nil ? nil : config(current_state[:key])
    return true if cfg == nil
    return cfg[:untagged_encounters_all_floors] != false
  end

  def self.filter_encounter_troop_ids(list, state = nil)
    return [] if list == nil
    result = []
    state ||= current_state
    return list.clone if state == nil
    cfg = config(state[:key])
    return list.clone if cfg[:floor_encounter_filter_enabled] == false

    list.each do |troop_id|
      if encounter_troop_allowed?(troop_id, state[:floor], cfg)
        result.push(troop_id)
      end
    end
    return result
  end

  def self.current_random_encounter_ids
    return [] if $game_map == nil
    return [] unless $game_map.respond_to?(:encounter_list)
    return $game_map.encounter_list.clone
  end

  def self.current_random_encounter_names
    result = []
    current_random_encounter_ids.each do |troop_id|
      troop = $data_troops[troop_id.to_i]
      result.push(troop.name.to_s) if troop != nil
    end
    return result
  end
end

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  unless method_defined?(:fs_rd_initialize_v098fs)
    alias fs_rd_initialize_v098fs initialize
  end
  def initialize
    fs_rd_initialize_v098fs
    @fs_rd_states = {}
  end

  def fs_rd_states
    @fs_rd_states = {} if @fs_rd_states == nil
    return @fs_rd_states
  end
end

#==============================================================================
# ■ Game_Map
#==============================================================================
class Game_Map
  attr_reader :fs_rd_key
  attr_reader :fs_rd_floor

  unless method_defined?(:fs_rd_setup_v098fs)
    alias fs_rd_setup_v098fs setup
  end
  def setup(map_id)
    @fs_rd_key = nil
    @fs_rd_floor = nil
    fs_rd_setup_v098fs(map_id)

    key = $game_temp == nil ? nil : $game_temp.fs_rd_pending_key
    return if key == nil
    cfg = FS_RandomDungeon::DUNGEONS[key]
    return if cfg == nil || cfg[:map_id].to_i != map_id.to_i

    run = FS_RandomDungeon.normalize_run_state(key)
    return if run == nil
    floor = $game_temp.fs_rd_pending_floor
    floor = run[:current_floor] if floor == nil
    floor = floor.to_i
    floor = 1 if floor < 1
    floor = run[:floor_count] if floor > run[:floor_count]
    state = FS_RandomDungeon.ensure_floor_state(run, floor)
    run[:current_floor] = floor

    fs_rd_apply_state(key, run, state)
    $game_temp.fs_rd_pending_key = nil
    $game_temp.fs_rd_pending_floor = nil
    $game_temp.fs_rd_place_player = true
  end

  def fs_rd_active?
    return false if @fs_rd_key == nil
    return false if $game_system == nil
    return FS_RandomDungeon.normalize_run_state(@fs_rd_key) != nil
  end

  def fs_rd_run
    return nil unless fs_rd_active?
    return FS_RandomDungeon.normalize_run_state(@fs_rd_key)
  end

  def fs_rd_state
    run = fs_rd_run
    return nil if run == nil
    floor = @fs_rd_floor == nil ? run[:current_floor].to_i : @fs_rd_floor.to_i
    return FS_RandomDungeon.ensure_floor_state(run, floor)
  end

  # Map 48 原生遇敵清單先經過其他腳本處理，再由迷宮樓層做最後篩選。
  # 隨機迷宮腳本放在其他地圖／遇敵腳本下方、Main 上方時，
  # 此 alias 會包住它們既有的 encounter_list 結果。
  if method_defined?(:encounter_list)
    unless method_defined?(:fs_rd_encounter_list_v098fs)
      alias fs_rd_encounter_list_v098fs encounter_list
    end

    def encounter_list
      list = fs_rd_encounter_list_v098fs
      return list unless fs_rd_active?
      return FS_RandomDungeon.filter_encounter_troop_ids(
        list, fs_rd_state
      )
    end
  end

  def fs_rd_apply_state(key, run, state)
    first_visit = !state[:visited]
    @fs_rd_key = key
    @fs_rd_floor = state[:floor].to_i
    run[:current_floor] = @fs_rd_floor
    width = state[:width].to_i
    height = state[:height].to_i

    # 只建立碰撞 Table。圖像由專用 Bitmap 圖層處理。
    @map.width = width
    @map.height = height
    @map.data = Table.new(width, height, 3)
    layout = state[:layout]
    for y in 0...height
      for x in 0...width
        value = layout[x + y * width]
        @map.data[x, y, 0] = 0
        @map.data[x, y, 1] = 0
        @map.data[x, y, 2] = fs_rd_passage_code(value)
      end
    end

    fs_rd_place_events(run, state)
    state[:visited] = true
    FS_RandomDungeon.on_floor_enter(run, state, first_visit)
    @need_refresh = true
  end

  def fs_rd_passage_code(value)
    case value
    when FS_RandomDungeon::CELL_FLOOR,
         FS_RandomDungeon::CELL_ENTRANCE,
         FS_RandomDungeon::CELL_EXIT,
         FS_RandomDungeon::CELL_BRIDGE_H,
         FS_RandomDungeon::CELL_BRIDGE_V
      return FS_RandomDungeon::PASS_OPEN
    when FS_RandomDungeon::CELL_WATER
      return FS_RandomDungeon::PASS_WATER
    else
      return FS_RandomDungeon::PASS_BLOCK
    end
  end

  def fs_rd_prepare_generated_events(run, state)
    @fs_rd_pool_source_ids = {}
    @fs_rd_generated_event_ids = {}
    cfg = FS_RandomDungeon.floor_config(
      FS_RandomDungeon::DUNGEONS[state[:key]], state[:floor]
    )
    return if cfg[:event_generation_enabled] == false

    if state[:generated_events] == nil
      state[:generated_events] =
        FS_RandomDungeon.generated_event_plan(cfg, state, @map)
    end

    # 所有池來源都只是模板，不直接出現在迷宮中。
    FS_RandomDungeon::EVENT_POOL_TYPES.each do |type|
      entries = FS_RandomDungeon.pool_entries_for_type(
        cfg, @map, state[:floor], type
      )
      entries.each { |entry| @fs_rd_pool_source_ids[entry[:source_id]] = true }
    end

    state[:generated_events].each do |descriptor|
      source_id = descriptor[:source_id].to_i
      event_id = descriptor[:event_id].to_i
      type = descriptor[:type]
      source = @map.events[source_id]
      next if source == nil

      begin
        clone = Marshal.load(Marshal.dump(source))
      rescue Exception
        clone = source.clone
      end
      if clone.respond_to?(:id=)
        clone.id = event_id
      else
        clone.instance_variable_set(:@id, event_id)
      end
      clone.x = 0 if clone.respond_to?(:x=)
      clone.y = 0 if clone.respond_to?(:y=)
      clone.name = FS_RandomDungeon.generated_clone_name(
        source.name, type
      ) if clone.respond_to?(:name=)

      @map.events[event_id] = clone
      @events[event_id] = Game_Event.new(@map_id, clone)
      @fs_rd_generated_event_ids[event_id] = true
    end
  end

  def fs_rd_pool_source_event?(event_id)
    return false if @fs_rd_pool_source_ids == nil
    return @fs_rd_pool_source_ids[event_id] == true
  end

  #--------------------------------------------------------------------------
  # 各樓層事件配置
  #--------------------------------------------------------------------------
  def fs_rd_place_events(run, state)
    return if @map.events == nil
    fs_rd_prepare_generated_events(run, state)
    floor = state[:floor].to_i
    max_floor = run[:floor_count].to_i
    used = {}
    used[state[:entrance]] = true
    used[state[:exit]] = true
    room_use_counts = {}

    ids = @map.events.keys.sort
    ids.each do |id|
      rpg_event = @map.events[id]
      game_event = @events[id]
      next if rpg_event == nil || game_event == nil
      name = rpg_event.name.to_s

      if fs_rd_pool_source_event?(id)
        fs_rd_hide_event(rpg_event, game_event)
        next
      end

      unless FS_RandomDungeon.event_enabled_on_floor_name?(name, floor)
        fs_rd_hide_event(rpg_event, game_event)
        next
      end

      pos = nil
      enabled = true

      if name.include?("<FS_RD_START>")
        enabled = (floor == 1)
        pos = state[:entrance]
      elsif name.include?("<FS_RD_UP>")
        enabled = (floor > 1)
        pos = state[:entrance]
      elsif name.include?("<FS_RD_DOWN>") || name.include?("<FS_RD_EXIT>")
        enabled = (floor < max_floor)
        pos = state[:exit]
      elsif name.include?("<FS_RD_BOSS>") || name.include?("<FS_RD_FINAL>")
        enabled = (floor == max_floor)
        pos = state[:exit]
      elsif name.include?("<FS_RD_FIXED>")
        fixed = state[:fixed_event_positions] || {}
        pos = fixed[id]
        if pos == nil
          pos = fs_rd_resolve_fixed_position(state, [rpg_event.x, rpg_event.y], used)
          state[:fixed_event_positions] ||= {}
          state[:fixed_event_positions][id] = pos
        end
      elsif name.include?("<FS_RD_CONTROL>")
        pos = [rpg_event.x, rpg_event.y]
      elsif FS_RandomDungeon.event_room_type_name(name) != nil
        desired_type = FS_RandomDungeon.event_room_type_name(name)
        state[:event_positions] ||= {}
        state[:event_room_ids] ||= {}
        pos = state[:event_positions][id]
        room_id = state[:event_room_ids][id]
        if pos == nil
          result = fs_rd_pick_event_position(
            state, used, id, desired_type, room_use_counts
          )
          pos = result[0]
          room_id = result[1]
          state[:event_positions][id] = pos
          state[:event_room_ids][id] = room_id
        end
        if room_id != nil
          room_use_counts[room_id] = room_use_counts[room_id].to_i + 1
        end
      else
        # 未標記事件保持模板座標。
        pos = [rpg_event.x, rpg_event.y]
      end

      if enabled &&
         FS_RandomDungeon.persistent_event_completed?(
           run, state, id, name
         )
        fs_rd_hide_event(rpg_event, game_event)
        next
      end

      unless enabled
        fs_rd_hide_event(rpg_event, game_event)
        next
      end
      next if pos == nil

      rpg_event.x = pos[0]
      rpg_event.y = pos[1]
      game_event.moveto(pos[0], pos[1])
      used[pos] = true
    end
  end

  def fs_rd_hide_event(rpg_event, game_event)
    rpg_event.x = 0
    rpg_event.y = 0
    game_event.moveto(0, 0)
    game_event.erase if game_event.respond_to?(:erase)
  end

  # <FS_RD_SHARED> 的 Self Switch 使用原始 Map ID，不分樓層。
  def fs_rd_shared_event?(event_id)
    return false if @map == nil || @map.events == nil
    event = @map.events[event_id]
    return false if event == nil
    return event.name.to_s.include?("<FS_RD_SHARED>")
  end

  # 固定點若在界外或非通行地形，移到最近合法格。
  def fs_rd_resolve_fixed_position(state, original, used)
    width = state[:width].to_i
    height = state[:height].to_i
    layout = state[:layout]
    ox = [[original[0].to_i, 1].max, width - 2].min
    oy = [[original[1].to_i, 1].max, height - 2].min
    original_pos = [ox, oy]
    value = layout[ox + oy * width]
    if FS_RandomDungeon.walkable_cell?(value) && !used[original_pos]
      return original_pos
    end

    best = nil
    best_distance = 999999
    for y in 1...(height - 1)
      for x in 1...(width - 1)
        value = layout[x + y * width]
        next unless FS_RandomDungeon.walkable_cell?(value)
        pos = [x, y]
        next if used[pos]
        distance = (x - ox).abs + (y - oy).abs
        if distance < best_distance
          best = pos
          best_distance = distance
        end
      end
    end
    return best || state[:entrance]
  end

  def fs_rd_pick_event_position(state, used, event_id, desired_type = nil,
                                room_use_counts = nil)
    room_use_counts ||= {}
    width = state[:width]
    height = state[:height]
    layout = state[:layout]
    cfg = FS_RandomDungeon::DUNGEONS[state[:key]]
    margin = cfg[:event_margin].to_i
    room_margin = cfg[:room_event_margin].to_i
    room_margin = 0 if room_margin < 0
    salt = event_id.to_i * 2654435761
    salt ^= state[:floor].to_i * 97531
    rng = FS_RandomDungeon::RNG.new(state[:seed].to_i ^ salt)

    rooms = state[:rooms] || []
    types = state[:room_types] || []
    matching_rooms = []
    if cfg[:room_types_enabled] != false && desired_type != nil
      types.each_with_index do |type, room_id|
        matching_rooms.push(room_id) if type == desired_type
      end
    end

    # 戰鬥事件若超過戰鬥房容量，可以使用空房。
    if matching_rooms.empty? && desired_type == :battle
      types.each_with_index do |type, room_id|
        matching_rooms.push(room_id) if type == :empty
      end
    end

    # 找不到專屬房時，退回所有非入口／樓梯／Boss 房。
    if matching_rooms.empty?
      types.each_with_index do |type, room_id|
        next if [:entrance, :stairs, :boss].include?(type)
        matching_rooms.push(room_id)
      end
    end

    unless matching_rooms.empty?
      min_use = nil
      matching_rooms.each do |room_id|
        use = room_use_counts[room_id].to_i
        min_use = use if min_use == nil || use < min_use
      end
      least_used = matching_rooms.select {
        |room_id| room_use_counts[room_id].to_i == min_use
      }
      room_id = least_used[rng.rand(least_used.size)]
      room = rooms[room_id]
      if room != nil
        candidates = []
        x1 = room[0].to_i + room_margin
        y1 = room[1].to_i + room_margin
        x2 = room[0].to_i + room[2].to_i - 1 - room_margin
        y2 = room[1].to_i + room[3].to_i - 1 - room_margin
        x1 = room[0].to_i if x1 > x2
        y1 = room[1].to_i if y1 > y2
        x2 = room[0].to_i + room[2].to_i - 1 if x1 > x2
        y2 = room[1].to_i + room[3].to_i - 1 if y1 > y2

        for y in y1..y2
          for x in x1..x2
            next if x <= 0 || y <= 0 || x >= width - 1 || y >= height - 1
            value = layout[x + y * width]
            next unless value == FS_RandomDungeon::CELL_FLOOR
            pos = [x, y]
            next if used[pos]
            next if fs_rd_distance(pos, state[:entrance]) < margin
            exclusion = cfg[:boss_event_exclusion].to_i
            exclusion = 2 if exclusion <= 0
            next if fs_rd_distance(pos, state[:exit]) < exclusion
            candidates.push(pos)
          end
        end
        unless candidates.empty?
          return [candidates[rng.rand(candidates.size)], room_id]
        end
      end
    end

    # 全圖安全備援
    candidates = []
    for y in 1...(height - 1)
      for x in 1...(width - 1)
        value = layout[x + y * width]
        next unless FS_RandomDungeon.walkable_cell?(value)
        pos = [x, y]
        next if used[pos]
        next if fs_rd_distance(pos, state[:entrance]) < margin
        exclusion = cfg[:boss_event_exclusion].to_i
        exclusion = 2 if exclusion <= 0
        next if fs_rd_distance(pos, state[:exit]) < exclusion
        candidates.push(pos)
      end
    end
    fallback = candidates.empty? ? state[:entrance] :
               candidates[rng.rand(candidates.size)]
    return [fallback, nil]
  end

  def fs_rd_room_id_at(state, x, y)
    rooms = state[:rooms] || []
    rooms.each_with_index do |room, room_id|
      next if room == nil
      if x >= room[0].to_i && x < room[0].to_i + room[2].to_i &&
         y >= room[1].to_i && y < room[1].to_i + room[3].to_i
        return room_id
      end
    end
    return nil
  end

  def fs_rd_distance(a, b)
    return (a[0] - b[0]).abs + (a[1] - b[1]).abs
  end
end

#==============================================================================
# ■ Game_SelfSwitches
#------------------------------------------------------------------------------
# 同一模板 Map ID 在不同樓層重用時，原生 Self Switch 會互相污染。
# 本段把鍵擴充為：
# [map_id, event_id, letter, :fs_rd, dungeon_key, generation_id, floor]
#==============================================================================
class Game_SelfSwitches
  unless method_defined?(:fs_rd_get_v098fs)
    alias fs_rd_get_v098fs []
  end
  def [](key)
    return fs_rd_get_v098fs(fs_rd_virtual_key(key))
  end

  unless method_defined?(:fs_rd_set_v098fs)
    alias fs_rd_set_v098fs []=
  end
  def []=(key, value)
    virtual_key = fs_rd_virtual_key(key)
    fs_rd_set_v098fs(virtual_key, value)
    if value && key.is_a?(Array) && key.size >= 3
      FS_RandomDungeon.record_event_completion(key[1], key[2])
    end
  end

  def fs_rd_virtual_key(key)
    return key unless key.is_a?(Array)
    return key if key.size < 3
    return key if $game_map == nil || !$game_map.fs_rd_active?
    return key if key[0].to_i != $game_map.map_id.to_i
    return key if $game_map.fs_rd_shared_event?(key[1].to_i)

    run = $game_map.fs_rd_run
    return key if run == nil
    return [
      key[0], key[1], key[2], :fs_rd,
      run[:key], run[:generation_id], $game_map.fs_rd_floor
    ]
  end

  def fs_rd_clear_dungeon(dungeon_key)
    changed = false
    @data.delete_if do |key, value|
      match = key.is_a?(Array) &&
              key.size >= 7 &&
              key[3] == :fs_rd &&
              key[4] == dungeon_key
      changed = true if match
      match
    end
    return unless changed
    $game_map.need_refresh = true if $game_map != nil
  end

  def fs_rd_clear_event_groups(dungeon_key, generation_id, groups)
    targets = {}
    groups.each do |floor, row|
      list = []
      row.each_value { |ids| list.concat(ids) }
      targets[floor.to_i] = list
    end

    changed = false
    @data.delete_if do |key, value|
      match = false
      if key.is_a?(Array) && key.size >= 7 &&
         key[3] == :fs_rd &&
         key[4] == dungeon_key &&
         key[5].to_i == generation_id.to_i
        ids = targets[key[6].to_i] || []
        match = ids.include?(key[1].to_i)
      end
      changed = true if match
      match
    end
    $game_map.need_refresh = true if changed && $game_map != nil
  end
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 進出迷宮與同 Map ID 樓層切換。
#==============================================================================
class Game_Player
  if method_defined?(:perform_transfer)
    unless method_defined?(:fs_rd_perform_transfer_v098fs)
      alias fs_rd_perform_transfer_v098fs perform_transfer
    end
    def perform_transfer
      was_active = FS_RandomDungeon.active?
      internal_floor_transfer =
        $game_temp.fs_rd_pending_key != nil

      # 離開目前樓層前保存最後合法位置。
      FS_RandomDungeon.save_current_player_position if was_active
      suppress_exit_reset =
        $game_temp != nil && $game_temp.fs_rd_suppress_exit_reset
      if was_active && !internal_floor_transfer && !suppress_exit_reset
        FS_RandomDungeon.queue_exit_reset
      end
      if was_active && !internal_floor_transfer
        FS_RandomDungeon.deactivate_environment(
          FS_RandomDungeon.current_run
        )
        if $game_temp != nil
          $game_temp.fs_rd_minimap_visible = nil
          $game_temp.fs_rd_fullmap_visible = false
        end
      end

      # 同一張模板地圖切換樓層時，原生 perform_transfer 不會再次 setup。
      # 因此在原方法前強制重建 Game_Map；Scene_Map 仍會正常重建 Spriteset。
      if $game_temp.fs_rd_force_setup &&
         $game_temp.fs_rd_pending_key != nil
        cfg = FS_RandomDungeon.config($game_temp.fs_rd_pending_key)
        $game_map.setup(cfg[:map_id].to_i)
      end

      fs_rd_perform_transfer_v098fs

      # count_as_exit=false 只抑制本次離場的 :on_exit 判定。
      # 原生轉場完成後立即消耗，避免殘留到下一次普通 VX 轉場。
      if $game_temp != nil
        $game_temp.fs_rd_suppress_exit_reset = false
      end

      if $game_temp.fs_rd_place_player && $game_map.fs_rd_active?
        state = $game_map.fs_rd_state
        mode = $game_temp.fs_rd_place_mode
        pos = nil
        if mode == :resume &&
           FS_RandomDungeon.valid_position?(state, state[:last_player_pos])
          pos = state[:last_player_pos]
        elsif mode == :exit
          pos = state[:exit]
        else
          pos = state[:entrance]
        end
        moveto(pos[0], pos[1])
        center(pos[0], pos[1])
        state[:last_player_pos] = [pos[0], pos[1]]
      end

      $game_temp.fs_rd_place_player = false
      $game_temp.fs_rd_place_mode = nil
      $game_temp.fs_rd_force_setup = false
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# Ground 位於角色下方；Upper 位於角色上方。
# 不修改 create_tilemap，也不要求 USE_TILEMAP = true。
#==============================================================================
class Spriteset_Map
  unless method_defined?(:fs_rd_initialize_v098fs)
    alias fs_rd_initialize_v098fs initialize
  end
  def initialize
    fs_rd_initialize_v098fs
    fs_rd_create_sprites
    fs_rd_update_sprites
  end

  unless method_defined?(:fs_rd_update_v098fs)
    alias fs_rd_update_v098fs update
  end
  def update
    fs_rd_update_v098fs
    fs_rd_update_sprites
  end

  unless method_defined?(:fs_rd_dispose_v098fs)
    alias fs_rd_dispose_v098fs dispose
  end
  def dispose
    fs_rd_dispose_sprites
    fs_rd_dispose_v098fs
  end

  def fs_rd_create_sprites
    @fs_rd_ground_sprite = nil
    @fs_rd_water_sprite = nil
    @fs_rd_bridge_sprite = nil
    @fs_rd_upper_sprite = nil
    @fs_rd_debug_sprite = nil
    @fs_rd_progress_hud_sprite = nil
    @fs_rd_progress_hud_signature = nil
    @fs_rd_minimap_sprite = nil
    @fs_rd_minimap_signature = nil
    @fs_rd_fullmap_sprite = nil
    @fs_rd_fullmap_signature = nil
    @fs_rd_fog_sprite = nil
    @fs_rd_fog_signature = nil
    @fs_rd_last_explore_x = nil
    @fs_rd_last_explore_y = nil
    @fs_rd_water_frames = nil
    @fs_rd_water_index = 0
    @fs_rd_water_tick = 0
    return unless $game_map.fs_rd_active?
    state = $game_map.fs_rd_state
    bitmaps = FS_RandomDungeon::Runtime.bitmaps(state)

    @fs_rd_ground_sprite = Sprite.new(@viewport1)
    @fs_rd_ground_sprite.bitmap = bitmaps[0]
    @fs_rd_ground_sprite.z = 0

    @fs_rd_water_frames = bitmaps[3]
    @fs_rd_water_sprite = Sprite.new(@viewport1)
    @fs_rd_water_sprite.bitmap = @fs_rd_water_frames[0]
    @fs_rd_water_sprite.z = 1

    @fs_rd_bridge_sprite = Sprite.new(@viewport1)
    @fs_rd_bridge_sprite.bitmap = bitmaps[2]
    @fs_rd_bridge_sprite.z = 2

    @fs_rd_upper_sprite = Sprite.new(@viewport1)
    @fs_rd_upper_sprite.bitmap = bitmaps[1]
    @fs_rd_upper_sprite.z = 220
    FS_RandomDungeon.reveal_position
    fs_rd_refresh_debug_sprite
    fs_rd_refresh_progress_hud
    fs_rd_refresh_minimap
    fs_rd_refresh_fullmap
    fs_rd_refresh_fog_of_war
  end

  def fs_rd_update_sprites
    return if @fs_rd_ground_sprite == nil
    FS_RandomDungeon.debug_toggle if FS_RandomDungeon.debug_key_triggered?
    if FS_RandomDungeon.minimap_toggle_key_triggered?
      FS_RandomDungeon.minimap_toggle
    end
    if FS_RandomDungeon.fullmap_toggle_key_triggered?
      FS_RandomDungeon.fullmap_toggle
    end

    if $game_player != nil &&
       (@fs_rd_last_explore_x != $game_player.x ||
        @fs_rd_last_explore_y != $game_player.y)
      FS_RandomDungeon.reveal_position
      @fs_rd_last_explore_x = $game_player.x
      @fs_rd_last_explore_y = $game_player.y
    end

    fs_rd_refresh_debug_sprite
    fs_rd_refresh_progress_hud
    fs_rd_refresh_minimap
    fs_rd_refresh_fullmap
    fs_rd_refresh_fog_of_war
    ox = $game_map.display_x / 8
    oy = $game_map.display_y / 8
    @fs_rd_ground_sprite.ox = ox
    @fs_rd_ground_sprite.oy = oy
    @fs_rd_water_sprite.ox = ox
    @fs_rd_water_sprite.oy = oy
    @fs_rd_bridge_sprite.ox = ox
    @fs_rd_bridge_sprite.oy = oy
    @fs_rd_upper_sprite.ox = ox
    @fs_rd_upper_sprite.oy = oy
    if @fs_rd_debug_sprite != nil
      @fs_rd_debug_sprite.ox = ox
      @fs_rd_debug_sprite.oy = oy
    end
    if @fs_rd_fog_sprite != nil
      @fs_rd_fog_sprite.ox = ox
      @fs_rd_fog_sprite.oy = oy
    end
    tone = $game_map.screen.tone
    @fs_rd_ground_sprite.tone = tone
    @fs_rd_water_sprite.tone = tone
    @fs_rd_bridge_sprite.tone = tone
    @fs_rd_upper_sprite.tone = tone
    fs_rd_update_water_animation
  end

  def fs_rd_update_water_animation
    return if @fs_rd_water_sprite == nil
    return if @fs_rd_water_frames == nil || @fs_rd_water_frames.empty?
    state = $game_map.fs_rd_state
    cfg = FS_RandomDungeon.config(state[:key])
    speed = cfg[:water_anim_speed].to_i
    speed = 18 if speed <= 0
    @fs_rd_water_tick += 1
    return if @fs_rd_water_tick < speed
    @fs_rd_water_tick = 0
    @fs_rd_water_index = (@fs_rd_water_index + 1) % @fs_rd_water_frames.size
    @fs_rd_water_sprite.bitmap = @fs_rd_water_frames[@fs_rd_water_index]
  end

  def fs_rd_refresh_minimap
    visible = FS_RandomDungeon.minimap_visible?
    signature = FS_RandomDungeon.minimap_signature(false)

    if visible
      if @fs_rd_minimap_sprite == nil ||
         @fs_rd_minimap_signature != signature
        if @fs_rd_minimap_sprite != nil
          if @fs_rd_minimap_sprite.bitmap != nil &&
             !@fs_rd_minimap_sprite.bitmap.disposed?
            @fs_rd_minimap_sprite.bitmap.dispose
          end
          @fs_rd_minimap_sprite.dispose unless
            @fs_rd_minimap_sprite.disposed?
        end
        bitmap = FS_RandomDungeon.create_minimap_bitmap(false)
        if bitmap != nil
          @fs_rd_minimap_sprite = Sprite.new(@viewport2)
          @fs_rd_minimap_sprite.bitmap = bitmap
          cfg = FS_RandomDungeon.config(
            $game_map.fs_rd_state[:key]
          )
          position = FS_RandomDungeon.minimap_position(
            cfg, bitmap.width, bitmap.height
          )
          @fs_rd_minimap_sprite.x = position[0]
          @fs_rd_minimap_sprite.y = position[1]
          @fs_rd_minimap_sprite.z = 185
        end
        @fs_rd_minimap_signature = signature
      end
    elsif @fs_rd_minimap_sprite != nil
      if @fs_rd_minimap_sprite.bitmap != nil &&
         !@fs_rd_minimap_sprite.bitmap.disposed?
        @fs_rd_minimap_sprite.bitmap.dispose
      end
      @fs_rd_minimap_sprite.dispose unless
        @fs_rd_minimap_sprite.disposed?
      @fs_rd_minimap_sprite = nil
      @fs_rd_minimap_signature = nil
    end
  end

  def fs_rd_refresh_fullmap
    visible = FS_RandomDungeon.fullmap_visible?
    signature = FS_RandomDungeon.minimap_signature(true)

    if visible
      if @fs_rd_fullmap_sprite == nil ||
         @fs_rd_fullmap_signature != signature
        if @fs_rd_fullmap_sprite != nil
          if @fs_rd_fullmap_sprite.bitmap != nil &&
             !@fs_rd_fullmap_sprite.bitmap.disposed?
            @fs_rd_fullmap_sprite.bitmap.dispose
          end
          @fs_rd_fullmap_sprite.dispose unless
            @fs_rd_fullmap_sprite.disposed?
        end
        bitmap = FS_RandomDungeon.create_minimap_bitmap(true)
        if bitmap != nil
          @fs_rd_fullmap_sprite = Sprite.new(@viewport2)
          @fs_rd_fullmap_sprite.bitmap = bitmap
          @fs_rd_fullmap_sprite.x =
            (Graphics.width - bitmap.width) / 2
          @fs_rd_fullmap_sprite.y =
            (Graphics.height - bitmap.height) / 2
          @fs_rd_fullmap_sprite.z = 220
        end
        @fs_rd_fullmap_signature = signature
      end
    elsif @fs_rd_fullmap_sprite != nil
      if @fs_rd_fullmap_sprite.bitmap != nil &&
         !@fs_rd_fullmap_sprite.bitmap.disposed?
        @fs_rd_fullmap_sprite.bitmap.dispose
      end
      @fs_rd_fullmap_sprite.dispose unless
        @fs_rd_fullmap_sprite.disposed?
      @fs_rd_fullmap_sprite = nil
      @fs_rd_fullmap_signature = nil
    end
  end

  def fs_rd_refresh_fog_of_war
    visible = FS_RandomDungeon.fog_of_war_enabled?
    signature = FS_RandomDungeon.fog_signature

    if visible
      if @fs_rd_fog_sprite == nil ||
         @fs_rd_fog_signature != signature
        if @fs_rd_fog_sprite != nil
          if @fs_rd_fog_sprite.bitmap != nil &&
             !@fs_rd_fog_sprite.bitmap.disposed?
            @fs_rd_fog_sprite.bitmap.dispose
          end
          @fs_rd_fog_sprite.dispose unless @fs_rd_fog_sprite.disposed?
        end
        bitmap = FS_RandomDungeon.create_fog_of_war_bitmap
        if bitmap != nil
          @fs_rd_fog_sprite = Sprite.new(@viewport1)
          @fs_rd_fog_sprite.bitmap = bitmap
          cfg = FS_RandomDungeon.config(
            $game_map.fs_rd_state[:key]
          )
          @fs_rd_fog_sprite.z = cfg[:fog_of_war_z].to_i
        end
        @fs_rd_fog_signature = signature
      end
    elsif @fs_rd_fog_sprite != nil
      if @fs_rd_fog_sprite.bitmap != nil &&
         !@fs_rd_fog_sprite.bitmap.disposed?
        @fs_rd_fog_sprite.bitmap.dispose
      end
      @fs_rd_fog_sprite.dispose unless @fs_rd_fog_sprite.disposed?
      @fs_rd_fog_sprite = nil
      @fs_rd_fog_signature = nil
    end
  end

  def fs_rd_refresh_progress_hud
    visible = FS_RandomDungeon.progress_hud_enabled?
    signature = FS_RandomDungeon.progress_hud_signature

    if visible
      if @fs_rd_progress_hud_sprite == nil ||
         @fs_rd_progress_hud_signature != signature
        if @fs_rd_progress_hud_sprite != nil
          if @fs_rd_progress_hud_sprite.bitmap != nil &&
             !@fs_rd_progress_hud_sprite.bitmap.disposed?
            @fs_rd_progress_hud_sprite.bitmap.dispose
          end
          @fs_rd_progress_hud_sprite.dispose unless
            @fs_rd_progress_hud_sprite.disposed?
        end

        bitmap = FS_RandomDungeon.create_progress_hud_bitmap
        if bitmap != nil
          @fs_rd_progress_hud_sprite = Sprite.new(@viewport2)
          @fs_rd_progress_hud_sprite.bitmap = bitmap
          state = $game_map.fs_rd_state
          cfg = FS_RandomDungeon.config(state[:key])
          position = FS_RandomDungeon.progress_hud_position(
            cfg, bitmap.width, bitmap.height
          )
          @fs_rd_progress_hud_sprite.x = position[0]
          @fs_rd_progress_hud_sprite.y = position[1]
          @fs_rd_progress_hud_sprite.z = 190
        end
        @fs_rd_progress_hud_signature = signature
      end
    elsif @fs_rd_progress_hud_sprite != nil
      if @fs_rd_progress_hud_sprite.bitmap != nil &&
         !@fs_rd_progress_hud_sprite.bitmap.disposed?
        @fs_rd_progress_hud_sprite.bitmap.dispose
      end
      @fs_rd_progress_hud_sprite.dispose unless
        @fs_rd_progress_hud_sprite.disposed?
      @fs_rd_progress_hud_sprite = nil
      @fs_rd_progress_hud_signature = nil
    end
  end

  def fs_rd_refresh_debug_sprite
    visible = FS_RandomDungeon.debug_visual?
    if visible && @fs_rd_debug_sprite == nil &&
       $game_map.fs_rd_active?
      @fs_rd_debug_sprite = Sprite.new(@viewport1)
      @fs_rd_debug_sprite.bitmap =
        FS_RandomDungeon.create_debug_bitmap($game_map.fs_rd_state)
      @fs_rd_debug_sprite.z = 500
    elsif !visible && @fs_rd_debug_sprite != nil
      if @fs_rd_debug_sprite.bitmap != nil &&
         !@fs_rd_debug_sprite.bitmap.disposed?
        @fs_rd_debug_sprite.bitmap.dispose
      end
      @fs_rd_debug_sprite.dispose unless @fs_rd_debug_sprite.disposed?
      @fs_rd_debug_sprite = nil
    end
  end

  def fs_rd_dispose_sprites
    if @fs_rd_ground_sprite != nil
      @fs_rd_ground_sprite.dispose unless @fs_rd_ground_sprite.disposed?
      @fs_rd_ground_sprite = nil
    end
    if @fs_rd_water_sprite != nil
      @fs_rd_water_sprite.dispose unless @fs_rd_water_sprite.disposed?
      @fs_rd_water_sprite = nil
    end
    if @fs_rd_bridge_sprite != nil
      @fs_rd_bridge_sprite.dispose unless @fs_rd_bridge_sprite.disposed?
      @fs_rd_bridge_sprite = nil
    end
    if @fs_rd_upper_sprite != nil
      @fs_rd_upper_sprite.dispose unless @fs_rd_upper_sprite.disposed?
      @fs_rd_upper_sprite = nil
    end
    if @fs_rd_debug_sprite != nil
      if @fs_rd_debug_sprite.bitmap != nil &&
         !@fs_rd_debug_sprite.bitmap.disposed?
        @fs_rd_debug_sprite.bitmap.dispose
      end
      @fs_rd_debug_sprite.dispose unless @fs_rd_debug_sprite.disposed?
      @fs_rd_debug_sprite = nil
    end
    if @fs_rd_progress_hud_sprite != nil
      if @fs_rd_progress_hud_sprite.bitmap != nil &&
         !@fs_rd_progress_hud_sprite.bitmap.disposed?
        @fs_rd_progress_hud_sprite.bitmap.dispose
      end
      @fs_rd_progress_hud_sprite.dispose unless
        @fs_rd_progress_hud_sprite.disposed?
      @fs_rd_progress_hud_sprite = nil
    end
    if @fs_rd_minimap_sprite != nil
      if @fs_rd_minimap_sprite.bitmap != nil &&
         !@fs_rd_minimap_sprite.bitmap.disposed?
        @fs_rd_minimap_sprite.bitmap.dispose
      end
      @fs_rd_minimap_sprite.dispose unless @fs_rd_minimap_sprite.disposed?
      @fs_rd_minimap_sprite = nil
    end
    if @fs_rd_fullmap_sprite != nil
      if @fs_rd_fullmap_sprite.bitmap != nil &&
         !@fs_rd_fullmap_sprite.bitmap.disposed?
        @fs_rd_fullmap_sprite.bitmap.dispose
      end
      @fs_rd_fullmap_sprite.dispose unless @fs_rd_fullmap_sprite.disposed?
      @fs_rd_fullmap_sprite = nil
    end
    if @fs_rd_fog_sprite != nil
      if @fs_rd_fog_sprite.bitmap != nil &&
         !@fs_rd_fog_sprite.bitmap.disposed?
        @fs_rd_fog_sprite.bitmap.dispose
      end
      @fs_rd_fog_sprite.dispose unless @fs_rd_fog_sprite.disposed?
      @fs_rd_fog_sprite = nil
    end
    @fs_rd_progress_hud_signature = nil
    @fs_rd_minimap_signature = nil
    @fs_rd_fullmap_signature = nil
    @fs_rd_fog_signature = nil
    @fs_rd_water_frames = nil
  end
end

#==============================================================================
# ■ 測試輔助
#==============================================================================
module FS_RandomDungeon
  def self.debug_print_layout(state = nil)
    state = current_state if state == nil
    return if state == nil
    width = state[:width]
    height = state[:height]
    layout = state[:layout]
    chars = {
      CELL_VOID => " ", CELL_FLOOR => ".", CELL_WALL => "#",
      CELL_ENTRANCE => "S", CELL_EXIT => "E", CELL_WATER => "~",
      CELL_BRIDGE_H => "=", CELL_BRIDGE_V => "|"
    }
    for y in 0...height
      line = ""
      for x in 0...width
        line += chars[layout[x + y * width]] || "?"
      end
      p line
    end
  end
end

#==============================================================================
# ■ END OF FILE
#==============================================================================
