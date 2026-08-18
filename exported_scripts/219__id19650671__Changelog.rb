#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Changelog
# 【用途】Tankentai SBS 3.4 / ATB 1.2 的版本變更紀錄，整理新版相較舊版的新增、修正、移除功能與被調整的方法。
# 【主要機制】這是參考文件而非 Runtime；包含 Action Key 改名、Target Cursor、動畫、飛行圖、Enemy Gauge、ATB charge、Union Skill、Two Sword Style 與已移除擴充等歷史資訊。
# 【主要影響】Spriteset_Battle、Game_Battler、Window_Base、Scene_Battle、Game_BattleAction、Scene_Menu
# 【設定／可調參數】若本頁有 Configuration／Settings／設定區，請優先只改該區；核心方法除非已確認依賴鏈，否則不建議直接改寫。
# 【依賴／載入順序】本頁保持目前已驗證的 Script Editor 相對順序；若要搬動，先反查 class reopen／alias 與事件呼叫。
# 【呼叫方式】一般由引擎／既有 Scene、Window、Game_* 流程自動執行；若下方原文件另有 Script Call／Notetag，請沿用原格式。
# 【範例】此腳本若沒有對外 Script Call，通常由 RGSS2、事件流程或其他腳本自動呼叫；請勿為了「有範例」而硬造不存在的 API。
# 【英文說明中文化】本頁原英文說明已在此維護區以繁體中文整理其用途、核心機制、設定、依賴與使用方式；下方英文原文保留作為作者原始資料與授權／細節查核依據。
# 【來源／授權】請保留下方原作者署名／授權資訊；本中文說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本中文區必須放在腳本開頭；新增功能時同步更新用途、設定、依賴與範例。
# 2. 原作者署名、授權與原始英文文件保留在下方，不因中文化而移除。
# 3. 若本頁屬 alias／Compatibility／Authority chain，修改前先查 LoadOrder Guide。
#==============================================================================
=begin

  SBS3.4abc, ATB1.2abc Changelog
  ++Overall++
  
  The original SBS Configurations script has been split into 2 
  parts to better differentiate the importance and usage of each section. 
  They have the same contents from the original, otherwise, except for 
  a few adjustments to some default sequences.
  
  More comments have been added.
  
  Anime keys and action sequence keys have had their names changed to 
  be more self-explanatory and hopefully easier to understand. The use of 
  old key names is still available through another script.
  
  $imported variables have been added.
  
  ++Sideview++
  
  [Updates]
  You can now adjust the position of the targeting cursor in General Settings.
  
  You can now use a Battle Animation key to *only* cause damage and 
  not produce any animation no matter what animation the skill, weapon,
  or item has in the database.
  
  You can now use a Battle Animation key to *only* play the animation 
  associated with the object used (skill, item, weapon).
  
  You will get a specific error message if you try to use an action
  sequence key that does not exist.
  
  Items can now have flying graphics.
  
  Battlers can now have their own individual death action 
  sequence assigned to them.
  
  Enemy Gauge Add-on has been incorporated into the Sideview script.
  
  Enemy Gauge and States display options have been added into General Settings.
  
  Maximum pop damage digits have increased to 6 by default.
  
  Battler Movement anime keys can now target the "head" or "feet" of the
  selected target.
  
  Contents of an aliased method from the ATB has been moved to the Sideview.

  [Bugfixes]
  
  Enemy Transform event command has been fixed to properly 
  update enemy sprites.
  
  Large battlers graphics will no longer make enemy battlers shift 
  high above their intended position.
    
  Flying graphics will now properly mirror when used by enemies.
  
  Flying graphics will now properly mirror themselves in surprise
  encounters.
  
  Non-animated enemies can now use flying graphics.
  
  Screen animations will no longer play an animation for each
  target and will instead play one animation.
  
  [Removed]
  The TWO_SWORDS_STYLE option in General Settings has been removed.

  The BATTLEFLOOR_GRAPHIC option in General Settings has been removed.
  You can still get rid of the battlefloor graphic by setting the opacity 
  to 0.
  
  The following Skill Extensions have been removed entirely:
  CONSUMEHP, %COSTMAX, %COSTNOW, %DAMAGEMAX/, %DAMAGENOW/,
  COSTPOWER, NOHALFMPCOST, HPNOWPOWER, MPNOWPOWER, NONE
    
  Why were these extensions removed?
  1) No one used them.
  2) There are other scripts that can do their functions better.
  3) Removing them clears up some methods from being overwritten.

  The following State Extensions have been removed:
  HIDEICON, SLIPDAMAGE
  
  Why were these extensions removed?
  1) If you want to hide an icon, you can simply not use one in the first place.
  2) Removing HIDEICON clears up a method from being overwritten.
  3) Rather than assigning the SLIPDAMAGE extension to a state in the script,
     you can now simply checkmark the "Slip Damage" option of the state
     in the database. The script will then use whatever slip damage values 
     that are assigned to the state.

  [Methods]
  class Spriteset_Battle#create_battlefloor -no longer redefined -now aliased
  class Game_Battler#skill_can_use?(skill) -no longer redefined
  class Game_Battler#calc_mp_cost(skill) -no longer redefined
  class Window_Base#draw_actor_state -no longer redefined
  class Game_Battler#make_obj_damage_value -no longer aliased
  class Game_Battler#make_attack_damage_value -no longer aliased
  class Scene_Battle#execute_action_skill -no longer uses consum_skill_cost(skill)
    
  ++ATB++
  
  [Updates]
  AlphaWhelp's State charge bonus script has been incorporated into
  the ATB script.
  
  Updated the comments for charge bonus values. Positive charge bonus
  values INCREASE charge times while negative charge bonus values
  DECREASE charge times. Also, charge bonus effects are added directly
  to the charge time. For example, if a skill has a
  charge time of 0% and a total charge bonus value of 15%, then the 
  skill will have a charge time of 15% and will not be instant cast
  anymore.
  
  [Bugfixes]
  Participating actors of a union skill will now have their 
  MP skill costs consumed after use.
  
  Actors using Two Sword Style will now gain proper charge bonus values
  from armor.

  [Removed]
  The menu command for the ATB Options scene no longer overwrites 
  Scene_Menu methods to add a new command. You can instead use 
  your preferred Scene_Menu script to add a command. You can still access 
  the ATB Options menu using $scene = Scene_ATB.new in an event script call.

  [Methods]
  class Game_BattleAction#valid? -no longer redefined
  class Scene_Battle#start_main -no longer is given a new argument
  class Scene_Menu#create_command_window -no longer redefined
  class Scene_Menu#update_command_selection -no longer redefined
  class Scene_File#return_scene -no longer redefined
  class Scene_End#return_scene -no longer redefined

=end