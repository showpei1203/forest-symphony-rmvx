#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Skill Activation Header
# 【用途】Skill Activation 系統的說明／索引頁，介紹技能啟動流程與相關 Config／Property／Core 腳本的分工。
# 【主要機制】屬說明文件；真正 Runtime 由後續 Skill Activation Config、Make skill action、Activation Property Config、Core 與 Add-on 共同構成。
# 【主要影響】以本頁實際定義／重開啟的 RGSS2 類別與模組為準
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
================================================================================
Skill Activation for Tankentai
By: CrimsonSeas
v1.3
===============================================================================
Hello everyone, this is my first script to be posted at a worldwide forum that is
inspired by Final Fantasy X. This script enable your character to have a skill 
that must be activated before it is performed. If you succeed, the power for that
skill would be increased. If you fail, the skill would still perform at normal 
power. It's good to use in conjunction with KGC Overdrive, since this is originally
used for overdrives. But it can also be used for normal skills.

This is originally made for my project, but I think it wouldn't hurt to share
this too.

You can choose between 3 types of activation:
+Timing Press (Tidus style).
  Press button at the right moment to activate the skill.
+Sequence (Auron style).
  Input sequence of keys to activate skill. Note that the input is based on
  keyboard so if it says "X" then press key X etc
+Mash button (I don't know where did I came with this idea, I guess because it's
 easy to make).
  Press button repeteadly to reach the hit area. If you press too much you might
  pass the hit area, and you press too little the pointer might go backwards.
  
  I'm still unable to make a good Mash activation type for Mash with varying hit
  number effect, I suppose the current Mash is not suitable for this. Just wish
  there'll be v1.4 which includes this.

Remember this is only for Tankentai SBS, it won't work with another CBS or default
battle system


And (another) important note, I am not a skilled scripter. Therefore, my scripts
are liable to be bugged. Although I have tested it and it workedfine for me, it
might not work well for you. If it doesnt' work well, then there are 2
possibilities:
-This script still has bugs
-You are using a script that is not compatible with this one
-You have done something wrong

If you encounter bugs/errors, please check whether there are some compatibility
issue. For ease of tracking, I will list some of my script comaptibilties.
================================================================================
Compatibility:
================================================================================
Rewrite:
-Game Battler
 +make_obj_damage_value
-Scene_Battle
 +playing_action
-Sprite_Battler
 +action

Alias:
-RPG::Skill
 +base_action
 +extension
================================================================================
Update Log
v1.3
+Bugfixes again
+Make a skill that enables you to have a variable hit number or a skill that will
 be canceled due to failure activation.

v1.2
+Lots of bugfixes
+More customize options

v1.1
+Added 2 new activation modes
+Some bugfixes
+Added type logo that tells you what type of activation you're using
+Separated the main core and the configuration part,so if I have new updates
 you can just update thee core part.
================================================================================
=end 

