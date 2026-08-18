#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：技能使用條件
# 【用途】技能系統元件「技能使用條件」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】Skill_Use_Conditions、Game_Battler、DAI_Skill_Use_Conditions
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
=begin
■スキル使用条件 RGSS2 DAIpage■ v1.2

●機能●
・メモ欄での設定で使用者などの状況により、スキルの使用を制限します。
・使用不可な場合、ウインドウのスキル表示は半透明になります。消す事はできません。

●使用法●
・以下の二つのタグの中に設定します。
<特殊使用条件>
</特殊使用条件>
<特殊使用条件>で設定開始、</特殊使用条件>で必ず閉じて下さい。
タグの外部に設定しても反映されません。
一行に複数の項目（タグを含む）を設定しないで下さい。

●使用法●
・設定できる条件は以下のとおり。

最大HP, n     # 最大HPが n 以上で使用可能
最大MP, n     # 最大MPが n 以上で使用可能
HP, n         # HPが n 以上で使用可能
MP, n         # MPが n 以上で使用可能
HP％以上, n   # HPが n %以上で使用可能
MP％以上, n   # MPが n %以上で使用可能
HP％以下, n   # HPが n %以下で使用可能
MP％以下, n   # MPが n %以下で使用可能
攻撃力, n     # 攻撃力が n 以上で使用可能
守備力, n     # 守備力が n 以上で使用可能
精神力, n     # 精神力が n 以上で使用可能
敏捷性, n     # 敏捷性が n 以上で使用可能
ステート, n   # ステート n になっていれば使用可能
武器, n       # 武器ID n を装備中に使用可能
防具, n       # 防具ID n を装備中に使用可能
属性, n       # 通常攻撃の属性IDが n の時に使用可能
スイッチ, n   # スイッチ番号 n がオンの時に使用可能
狀態開關, n   # 開關false，技能可用，N是開關ID，要在class Game_Battler裡設定
封印狀態, n   # 狀態true，技能不可使用，N是狀態ID

複数の項目を設定した場合、全ての条件を満たさないと使用できません。
ステート,武器,防具は複数設定可能。その場合は行を別けて下さい。

●メモ欄記述例●

# 最大HPが100以上で、ステート9になっている場合にのみ使用可能。
<特殊使用条件>
最大HP,100
ステート,9
</特殊使用条件>
　
●再定義している箇所●
　Game_Battlerをエイリアス

　※同じ箇所を変更するスクリプトと併用した場合は競合する可能性があります。

●更新履歴●
09/03/03：最大MPが0のキャラがいる場合にエラー落ちする不具合を修正。
09/03/03：％指定の条件が正しく機能していない不具合を修正。
09/02/21：公開

=end

#============================================================================
# ■ メモ欄ワード用（変更しない事）
#============================================================================
module DAI_Skill_Use_Conditions
  ST = "<特殊使用条件>"
  ED = "</特殊使用条件>"
  R = ["最大HP",
       "最大MP",
        "HP",
        "MP",
        "HP％以上",
        "MP％以上",
        "HP％以下",
        "MP％以下",
        "攻撃力",
        "守備力",
        "精神力",
        "敏捷性",
        "ステート",
        "武器",
        "防具",
        "属性",
        "スイッチ",
        "狀態開關",
        "封印狀態"
        ]
end
#==============================================================================
# ■ Skill_Use_Conditions
#------------------------------------------------------------------------------
#    スキルの使用条件を判定するクラスです。
#==============================================================================
class Skill_Use_Conditions
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(skill, battler)
    @skill = skill
    @battler = battler
    @result = {"最大HP" => 0,
               "最大MP" => 0,
               "HP" => 0,
               "MP" => 0,
               "HP％以上" => 0,
               "MP％以上" => 0,
               "HP％以下" => 0,
               "MP％以下" => 0,
               "攻撃力" => 0,
               "守備力" => 0,
               "精神力" => 0,
               "敏捷性" => 0,
               "ステート" => [],
               "武器" => [],
               "防具" => [],
               "属性" => [],
               "スイッチ" => 0,
               "狀態開關" => 0,
               "封印狀態" => []
               }
    @battler_st = [@battler.maxhp,
                   @battler.maxmp,
                   @battler.hp,
                   @battler.mp,
                   @battler.hp * 100 / @battler.maxhp * 100 / 100,
                   @battler.mp * 100 / [@battler.maxmp, 1].max * 100 / 100,
                   @battler.hp * 100 / @battler.maxhp * 100 / 100,
                   @battler.mp * 100 / [@battler.maxmp, 1].max * 100 / 100,
                   @battler.atk,
                   @battler.def,
                   @battler.spi,
                   @battler.agi,
                   ]
  end
  #--------------------------------------------------------------------------
  # ● 使用可能条件判定
  #--------------------------------------------------------------------------
  def use?
    note_get
    r = []
    for i in DAI_Skill_Use_Conditions::R
      r.push @result[i]
    end
    # 最大HP～MP％以上まで
    for i in 0..5
      return false if @battler_st[i] < r[i]
    end
    # ％以下
    for i in 6..7
      return false if @battler_st[i] > r[i] && r[i] != 0
    end
    # 攻撃力～敏捷性まで
    for i in 8..11
      return false if @battler_st[i] < r[i]
    end
    # ステート
    for i in r[12]
      return false unless @battler.state?(i)
    end
    # 武器防具
    if @battler.actor?
      for i in r[13]
        return false unless @battler.weapons.include?($data_weapons[i])
      end
      for i in r[14]
        return false unless @battler.armors.include?($data_armors[i])
      end
    end
    # 属性
    for i in r[15]
      return false unless @battler.element_set == i
    end
    # スイッチ
    if r[16] > 0
      return $game_switches[r[16]]
    end
    #狀態開關
    if r[17] > 0
      return false if $game_switches[r[17]]
    end
    #封印狀態
    for i in r[18]
      return false if @battler.state?(i)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● メモ欄判別
  #--------------------------------------------------------------------------
  def note_get
    return unless @skill.is_a?(RPG::Skill)
    @skill.note.each_line{|line|
      @flg = true if line.include?(DAI_Skill_Use_Conditions::ST)
      @flg = false if line.include?(DAI_Skill_Use_Conditions::ED)
      next if line.include?(DAI_Skill_Use_Conditions::ST)
      next if line.include?(DAI_Skill_Use_Conditions::ED)
      if @flg
        a = line.split(/\s*,\s*/)
        if @result.include?(a[0]) 
          if @result[a[0]].is_a?(Array)
            @result[a[0]].push a[1].to_i
          else
            @result[a[0]] = a[1].to_i
          end
        end
      end
    }
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定
  #--------------------------------------------------------------------------
  alias dai_skill_can_use? skill_can_use?
  def skill_can_use?(skill)
    condition = Skill_Use_Conditions.new(skill, self)
    return false unless condition.use?
    return dai_skill_can_use?(skill)
  end
end

