#==============================================================================
# Forest Symphony AutoRegression
# Phase47B1 Boss Matrix II / Boss511 TEST Idempotence Correction
# TEST-only v1.0b
# 基底：Phase47B 實機 1361 PASS / 2 FAIL / 0 WARN；Formal Runtime 零修改。
# Phase47B1：只修正 Boss511 idempotence 的 TEST 觀察面，允許新召 Elite 在下一 update 啟動自身正式 Runtime。
# Formal Runtime：零修改。Ruby 1.8 / RGSS2 單執行緒相容。
# Phase46E：Mia targeting/support tail、Vina detonate/dynamic state resistance、Tyler break resist/lock tail。
# 【Phase47B】Phase47A1 已由使用者實機 1311 PASS / 0 FAIL / 0 WARN SEALED；本版只追加剩餘 23 名 Boss 的 Matrix II TEST evidence。
# 【Phase47A1】依 2026-08-17 實機 1302 PASS / 9 FAIL：3 個 defined? readiness 為 TEST Boolean bug；
#   Phase46E gate 的全域 fail_delta 會被交錯 Boss background 污染，改回只看本批 job 結果。
#   Formal 修正只限 Cyrus：law_cycle_interval parser + State151→第一律 convergence。
#==============================================================================
# encoding: utf-8
#==============================================================================
# 【Phase46B】Main Character Regression Track II — Native Popup Rollback / Joey Follow-up / Ivy Lifecycle
# 【Phase46B1a】TEST fixture semantics fix：實機已於 1158/0/0 封版 Phase46B；Formal Runtime 不變。
# 【Phase46B2】Ivy Lifecycle III：consume success gate / Active Cover OD / serial dedupe / Fatal Cover compatibility。
# 【Phase46B2a】TEST context/determinism fix：Joey follow-up 鎖定 Combat RNG；Ivy Active/Fatal Cover 補齊實戰 active_battler 與 Skill146 synthetic prerequisite。
# 【Phase46B2b】TEST determinism/session-semantics fix：Skill147 關閉 critical；Active Cover 計入 KGC defender OD，並以 active Cover Motion session 驗證同 session 不重複扣 charge／+6% OD。
# 【Phase46C1】TEST fixture semantics fix：修正艾卓正式技能名稱、Ruby =~ literal Boolean、Game_Enemy(index, enemy_id) 建構參數，以及 live fixture 過度 whole-ivar equality；Formal Runtime 零變更。
# 【Phase46C2】TEST determinism fix：Phase46C1 實機證明艾卓六子區塊全 PASS；修正 Ivy Skill147 fixture 錯把 physical_attack=false 當成 no-crit。Custom Damage Authority 實際以 obj.no_crit 阻止技能暴擊；Formal Runtime 零變更。
# Phase46A2 實機 1141 PASS / 0 FAIL / 0 WARN，但使用者 Visual Acceptance 拒絕 recolor；
# Formal page376 已 byte-exact 回復 Phase45K1 原生 BattlePopText_Note，不再程式染色。
# 本版 TEST-only 延伸 Joey Skill104/107 follow-up 與 Ivy Skill141/144/147/148 gameplay lifecycle。
# Formal Runtime delta=0（相對 Phase45K1）；相對 A2 只有 page376 rollback + TEST page480。
#==============================================================================
#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 【Phase45K1】依 Phase45K 實機 1106 PASS / 5 FAIL / 0 WARN 診斷：
#         IvyClone FAIL 為 Formal page394 真缺陷，致死 Cover Runtime 參照 namespaced constants，
#         但 v1.6.1 兩常數誤落在 module 外；Formal page394 v1.6.2 補回 module namespace。
#         CustomStatusProperties FAIL 為 TEST synthetic State clone cache 初始化不足；
#         page480 現以 YEZ 正式 yez_cache_state_csp parser 明確重建 synthetic cache。
#         其餘 Phase45K conditional owners 不變，預期 1112 PASS / 0 FAIL / 0 WARN。
# 腳本：FS_BattleRegression_ExecuteDamageSemanticOwnershipI v1.0ap
# 【Phase45J】Phase45I 實機 1045 PASS / 0 FAIL / 0 WARN SEALED 後，TEST-only 進入 execute_damage Semantic Ownership I。
#         本批先鎖定通用／底層可隔離語意：真實 Skill100 的 VX Base HP application、DPS 統計、DynamicThreat 傷害累積、
#         KGC OverDrive gain，以及 dedicated RecoveryBlock、Counterattack、Sideview absorb display、IntegerFix、KGC↔DPS order-fix。
#         Combo／Character／MechanicExpansion／Antagonist／IvyClone／MarkedCommand／CustomStatusProperties 的條件式角色／複合語意
#         留給下一批專門 fixture，不因 Skill100 selected-case pass-through 就宣稱無作用。Formal Runtime 0 修改。
# 【Phase45I】Phase45H 實機 1036 PASS / 0 FAIL / 0 WARN SEALED 後，TEST-only 追蹤 Game_Battler#execute_damage。
#         以既有 Skill100 真實 Battle Fixture 鎖定 runtime outer→base / return reverse / exactly-once，並將
#         page478 AutoRegression Harness 明確標為 TEST-only projection；Formal projection 逐層驗證 MarkedCommand、
#         IvyClone、Antagonist、MechanicExpansion、Character、Combo、KGC↔DPS order-fix、IntegerFix、Counter、
#         RecoveryBlock、YEZ Custom Status Properties、DynamicThreat、OverDrive、Sideview、DPS、VX Base。
#         本階段只做 provenance，不提前宣稱 semantic ownership，也不刪除任何 Formal wrapper。
# 【後續 Mechanic Coverage 硬性要求】六名主要角色與所有 Boss 的專屬機制、phase transition、AI、特殊規則、
#         互動與 cleanup 必須建立 deterministic AutoRegression fixture；Boss 名單與機制以正式 Enemy/Troop/腳本盤點為準，
#         不用人工記憶補齊。此矩陣獨立於 Authority provenance 主線，最終必須納入 integrated soak。
# 【Phase45H】Phase45G1 實機 1027 PASS / 0 FAIL / 0 WARN SEALED 後，正式轉入 Damage Authority。
#         本版 TEST-only 在既有 Skill100 真實 Battle Fixture 透明追蹤 Game_Battler#make_obj_damage_value。
#         目的不是先相信舊文件，而是實機證明 active runtime outer→base / return reverse order / exactly-once。
#         特別把 page344 Custom Dmg Formulas RD 的直接 redefine 視為結構分界：它可能 shadow 早期
#         BattleResultStats / SkillActivation / KGC AddEquipmentOptions / VX Base 歷史段；Phase45H 會同時記錄
#         active chain 與 pre-Custom shadow alias 是否真的被呼叫，不據靜態頁碼擅自簡化 Formal Runtime。
#         所有 Formal Damage pages 0 修改；Skill100 damage102、Phase45E/G、8 Core Fixture、Residual/Drain、
#         Summon、AI、Snapshot 全部保留回歸。
# 【Phase45G1】依 Phase45G 實機 1007 PASS / 5 FAIL / 0 WARN 修正兩個 TEST-only fixture 缺陷；Formal Runtime 0 修改。
#         1. PokemonFollowup fixture 舊常數 Actor7 已被正式 Profile Authority 定義為 Clone，改採目前正式 Pokémon Actor100。
#         2. detached skill_effect 在 Scene_Battle 內直接執行時缺少正式 action 原本存在的 active_battler context；
#            1 點傷害因此進 Counterattack create_counterattack 後讀到 nil.active_battler。TEST wrapper 現在只在呼叫期間
#            暫時設定 $scene.active_battler=user，並於 ensure exact restore；不修改 Counter／ActorProfile／PFI Formal Runtime。
# 【Phase45G】Phase45F1 實機 975 PASS / 0 FAIL / 0 WARN 後，TEST-only 進入 Skill Effect Semantic Ownership II。
#         保留既有 8 Core Battle Fixture 數量不變；在 Battle sandbox 內追加獨立 semantic fixtures：
#         SupportState 純狀態／零傷害 physical gate、PokemonFollowup context trigger／temporary identity／target dedupe、
#         AutoSetup late-bound <fs_user_add_state> outer ownership、ActorProfile Clone success marker，並借用 Phase45D 真實 Steal
#         action 鎖定 StealResult processed/checked ownership。MechanicExpansion action-success marker亦在 SupportState fixture 觀察；
#         Antagonist／IvyClone 等對本批 fixture 無新增 mutation 的層只標 selected-case pass-through，不虛構 ownership。
#         所有 detached battler、temporary context、Skill slot 1 與 deterministic RNG 都 immediate/exact restore；Formal Runtime 0 修改。
# 【Phase45F1】依 Phase45F 實機 968 PASS / 7 FAIL / 0 WARN 修正 TEST-only RGSS2 / Ruby 1.8 相容性。
#         唯一根因為 Skill101 semantic probe 新碼誤用 Object#instance_variable_defined?；VX Ruby 不提供此 API，
#         造成 prepare capture 例外及 6 個連帶 semantic FAIL。改回本 Harness 既有
#         p42l_instance_variable_defined_compat?，並以 send(:remove_instance_variable, ...) 清除 TEST 暫存 ivar。
#         SoulMark / Field ownership 已於 Phase45F 實機獨立 PASS；Formal Runtime 0 修改。
# 【Phase45F】Phase45E 實機 947 PASS / 0 FAIL / 0 WARN 後，TEST-only 進入 Skill Effect Semantic Ownership I。
#         以 Skill101 鎖定 StateEffects→VX Base→CharacterMechanic 的狀態／Joey OD+ATB 語意，
#         以 Skill253 鎖定 SoulMark 50% drain post-heal，並用 synthetic Field153 鎖定 legacy FieldEffect 與
#         FieldWeather source Authority 的責任邊界。沿用 Phase45E probes，不新增第二套 skill_effect wrapper。
# 【Phase45E】Phase45D 實機 939 PASS / 0 FAIL / 0 WARN 後，Skill Cost 主線收斂，正式切入 Skill Effect staged-chain provenance。
#         本版 TEST-only 不新增 synthetic Skill，直接在既有 Skill100 真實 Battle Fixture 上透明包住每個已命名 alias layer；
#         將 AutoSetup late-bound runtime patch 與 page479 Combat RNG TEST layer分開標記，並驗證 Formal projection 的 outer→base / base→outer
#         順序、return reverse order 與每層 exactly-once。所有 Formal Skill Effect pages 保持 byte-exact。
# 【Phase45D】Phase45C 實機 913 PASS / 0 FAIL / 0 WARN 後，補齊 Skill Cost 最後一條高風險特殊支付路徑：
#         KGC Steal 的 execute_action_steal 會自行扣除 calc_mp_cost，page411 Final Authority 必須辨識 steal skill
#         並跳過第二次 MP payment。本版 TEST-only 建立真實 <steal> multi-cost Battle Fixture，trace inner Steal MP、
#         legacy HP/Gold/Var/Item、final Angry 與外層總差額；battle-local target steal reward source 暫時隔離並 exact restore。
#         Formal page280 / page302 / page411 全部保持 byte-exact。
# 【Phase45C】Phase45B2 實機 897 PASS / 0 FAIL / 0 WARN 後，TEST-only 封裝 fixed+percentage 成本、真正 resource
#         threshold、Half Cost 選擇性減半、hard clamp，以及真正 Scene_Skill#use_skill_nontarget 六資源 exact-once。
#         實機結果 913 PASS / 0 FAIL / 0 WARN，SKILL_COST_PHASE45C_GATE ready=true。Formal Runtime 0 修改。
# 【Phase45B2】依 Phase45B1 實機 893 PASS / 3 FAIL / 0 WARN，確認 Angry 100→0 並非
#         KGC consume_od_gauge 或 FS_SkillCost_Authority 重複扣款，而是 Phase45B synthetic Skill
#         深拷貝 Skill100 時連同 <joey_resonance_pull ...> 角色機制 Notetag 一併繼承；命中共鳴標記
#         後，FS_CharacterMechanicCore 依法先支付 conditional OD，造成 Skill Cost Angry 測試被污染。
#         本版 TEST-only：仍以 Skill100 保留完整 runtime shape，但 synthetic Note 改成純成本 fixture；
#         並要求 provenance 不再出現 positive→0 OD write、Angry 100→89、KGC OD cost 仍為 0。
# 【用途】Phase 37 戰鬥回歸測試第二批 Fixture。建立在 Phase 36 已實機 PASS 的
#         Core Battle Fixtures 之後，專門驗證 Residual／Regen／Leech Seed／Drain。
# 【目前案例】Ctrl+F9 的 Core Battle Plan 全部完成後、正式離開戰鬥前，自動追加：
#   1. State 31「中毒」：MaxHP=1000、1 stack，驗證 HP Slip 實際扣血。
#   2. State 34「灼燒」：正式疊至 1→2→3 層，驗證每層 1% MaxHP DOT、最大層數 3 與超額附加不溢位。
#   3. State 64「再生」：MaxHP=1000，驗證 HP Regen 實際回血。
#   4. MP Regen：從正式 State Note 動態尋找負值 <slip: mp>，MaxMP=1000 驗證精確回復與上限 clamp。
#   5. MP Degen：從正式 State Note 動態尋找正值 <slip: mp>，MaxMP=1000 驗證精確流失與 0 下限 clamp。
#   6. State 35「寄生」：MaxHP=800，驗證每次 1/8=100 傷害與來源者實際回血。
#   7. VX 一般 Drain：自動選現有 absorb_damage 技能，驗證傷害與 100% 吸血。
#   8. SoulMark Drain：自動找第一個 effects[:drain] 魂刻技，驗證 post-effect 百分比吸血。
# 【測試方式】全部在已建立的 Battle Sandbox 內執行。Poison／Regen／Leech 直接呼叫正式
#         Scene_Battle#hp_slip_damage；General Drain／SoulMark Drain 則加入 Phase36 Action
#         Plan，完整走 ForceAction → Scene_Battle#execute_action_skill → skill_effect → execute_damage。
# 【Combat RNG】中毒／再生的 Tankentai slip variance，以及兩種 Drain 的 Hit/Eva/
#         Damage Variance 都使用 FS_COMBAT_RANDOM seed=149；正常遊戲不受影響。
# 【依賴／載入順序】必須位於 FS_BattleRegression_CoreFixtures 之後、Main 之前。
# 【LOG】沿用 FS_AutoRegression_LATEST.log，新增 [PREBATTLE] [EQUIP] [REFRESH] [WAIT]
#         [RESIDUAL] [BURN] [MP_RESIDUAL] [LEECH] [DRAIN]。
# 【Phase44C】新增 Lifecycle Invocation-count Convergence Audit。只做 TEST-only trace，不修改 Formal Runtime。
#         以 detached Actor 分別隔離 setup / change_equip / level_up / discard_equip / skills / skill_can_use?，
#         記錄現存 alias layer、Authority refresh、purge、NEW suppression 與查詢鏈的實際進入順序／次數。
#         本階段只建立 wrapper retirement 的實機證據，不刪除任何 legacy wrapper；所有 probe 結束後
#         必須 exact restore Game_Party / $game_actors / database slot / inventory tombstone / detached Actor。
# 【Phase44C1】依 Phase44C 實機 FAIL 修正 TEST instrumentation，Formal Runtime 0 修改：
#         1. RGSS2 / Ruby 1.8 不支援 Object#instance_variable_defined?，Phase44C helper 全改用既有
#            p42l_instance_variable_defined_compat?，避免 skill_can_use probe 與 Actor baseline 例外。
#         2. discard trace 原誤指不存在的 fs_p44a_weapon_discard_base，改掛實際 Phase44A alias
#            fs_p44a_weapon_discard_final_base，補回 CoreSafe final boundary 記錄。
#         3. 保留 Phase44C 所有 invocation-count expectation，不修改 Formal page330 v1.6。
# 【Phase44C2】依 Phase44C1 實機唯一 substantive FAIL 修正 TEST cleanup，Formal Runtime 0 修改：
#         Combo refresh 會合法初始化 @albert_combo_owned_state_ids=[]；若 detached Actor baseline 原本沒有該 ivar，
#         TEST cleanup 必須用 send(:remove_instance_variable, ...) 還原「ivar 不存在」的 exact state。
#         不修改任何 invocation trace、Authority expectation 或 Formal page330 v1.6。
# 【Phase45A1】依 Phase45A 實機 618 PASS / 3 FAIL / 0 WARN 修正 TEST fixture，Formal Runtime 0 修改：
#         Phase45A 的 local RPG::Skill.new 未經完整資料庫載入／舊插件 parser 初始化，完整 skill_can_use? 鏈進入
#         FS_BattleUtility_RuntimeBridge#no_charged 時 skill.turn_delay / battle_delay / step_delay 至少一項為 nil，
#         造成 nil > 0 NoMethodError。改以已知可用、且 detached Actor 原生持有的正式 Skill100 深拷貝作為
#         local synthetic base，只追加 Phase45 成本 Notetag 並強制 FS_SKILL_COST_ALLFIX 重新解析；不改正式資料庫物件。
# 【Phase45A】Phase44M1 實機 859 PASS / 0 FAIL / 0 WARN 後，正式切入 Skill Cost / Skill Effect / Damage Authority 驗證。
#         本階段 TEST-only、Formal Runtime 0 修改；以 detached Actor + local RPG::Skill 驗證 FS_SkillCost_Authority
#         的 fixed cost calculators、完整 skill_can_use resource gates、Battle legacy HP/Gold/Var/Item payment policy，
#         以及 final MP/Angry 計算政策。Party mutation 必須 exact restore gold / variable / inventory Hash slot / NEW flag。
# 【Phase44M1】依 Phase44M 實機 611 PASS / 2 FAIL / 0 WARN，確認兩個 substantive ALVD cache invalidation defects：
#         changed non-Passive ALVD learn_skill 與 forget_skill 都會保留 @alvd_flag=true，下一次能力值 query 因而讀到 stale cache；
#         TEST-only manual invalidate 後 reference 值正確，證明 parser / tag /公式本身正常。正式資料庫目前 ALVD_USAGE count=0，屬 latent compatibility defect。
#         Formal page307 v1.7 候選只在 raw ownership 真正改變且 Skill 帶 <レベル依存:...> 時設 @alvd_flag=false；
#         不新增 Passive rebuild，不回退 Phase44I/J non-Passive refresh retirement。TEST 要求 learn/forget flag_before_query=false、
#         immediate ATK 正確、restore_passive=0，並維持所有 Phase44K/L gates。
# 【Phase44M】依 Phase44L 實機 847 PASS / 0 FAIL / 0 WARN，進入 TEST-only ALVD Cache Invalidation Diagnostic：
#         Phase44L 已證明 lifecycle 的第二次 skills traversal 不是 EquipmentSkill／Combo 重複查詢，而是 page307
#         內建 ALVD（<レベル依存:a,b,c,d>）cache rebuild；restore_passive_rev_alvd 會先令 @alvd_flag=false，
#         隨後 HP/MP clamp 觸發 base_maxhp → alvd_make，再掃一次完整 skills。這次掃描具有獨立功能，不能直接退休。
#         本階段先掃描正式 $data_skills 中實際 ALVD tag 使用量，再用 TEST-only synthetic non-Passive ALVD Skill
#         驗證 standalone learn_skill / forget_skill 是否會立即使 ALVD cache 失效。Phase44I/J 只依 skill.passive 決定
#         KGC Passive rebuild；若 ALVD tag 不要求 skill.passive，則 changed non-Passive ALVD ownership 可能留下 stale cache。
#         Formal page307 v1.6 / page330 v1.7 / page363 v2.2 完全不改；若實機 FAIL 才進 Phase44M1 Formal candidate。
# 【Phase44L】依 Phase44K 實機 844 PASS / 0 FAIL / 0 WARN，進入 TEST-only Skills Query Provenance Diagnostic：
#         Phase44K 已證明 standalone Teaching 仍即時 rebuild=1；deferred Teaching inner rebuild=0、final=1，
#         standard / Weapon Teaching discard 也都精確只剩 1 次 final Passive rebuild。Formal Authority 已收斂。
#         但 Invocation Audit 的 setup / change_equip / level_up / discard_equip 仍分別看到 skills chain 3 / 2 / 2 / 2 次。
#         本階段不假設第二次 skills query 是冗餘 Formal；只在既有 Phase44C trace window 內記錄每次 skills 的 caller provenance，
#         輸出 [SKILLS_PROVENANCE] / [SKILLS_PROVENANCE_SUMMARY]，確認來源後下一階段才決定是否能安全退休。
#         Formal page307 v1.6 / page330 v1.7 / page363 v2.2 whole-entry 不變。
# 【Phase44K】依 Phase44J 實機 832 PASS / 0 FAIL / 0 WARN，收斂 Equipment Teaching 內層 Passive rebuild：
#         standard / Weapon Teaching discard 實機 trace 均證明 Passive Skill 被 Teaching forget 時會先由 KGC
#         forget_skill rebuild 一次，Teaching 返回後 final EquipmentSkill Passive Authority 又 rebuild 一次。
#         Formal page363 v2.2 新增 deferred Teaching helper；只有已知緊接 final Passive refresh 的
#         change_equip / setup / level_up / discard convergence 使用，standalone Teaching 仍維持即時 rebuild。
#         TEST 會要求 standard / Weapon Teaching discard 各只剩 1 次 restore_passive，且新增 standalone vs
#         deferred Teaching synthetic Passive probe，驗證 deferred 內 0 rebuild、final 精確 1 rebuild、flag exact cleanup。
# 【Phase44J】依 Phase44I 實機 818 PASS / 0 FAIL / 0 WARN，進入 forget_skill Formal candidate：
#         page307 KGC forget_skill 只在 raw ownership 真正由已學→未學，且被忘 Skill 本身為 Passive 時
#         restore_passive_rev。RGSS2 base forget_skill 對不存在的 ownership 只是 delete no-op；正式 Passive
#         rebuild 也只讀 skill.passive，因此 no-op forget 與 changed/non-passive forget 都屬冗餘 rebuild。
#         TEST-only standalone gate 分四路：no-op non-passive、changed non-passive、changed Passive、
#         no-op Passive；要求 rebuild 次數依序 0/0/1/0，並驗證 Passive ATK/DEF/CRITICAL_BONUS
#         在真正 forget Passive 後回到 baseline。既有 Equipment Teaching/Discard/Purge final convergence 全保留。
# 【Phase44I】依 Phase44H 實機 812 PASS / 0 FAIL / 0 WARN，進入下一個 Formal candidate：
#         page307 KGC learn_skill 在 raw ownership 真正改變後，只有新學 Skill 本身為 Passive 時才
#         restore_passive_rev。正式 restore_passive_rev 只會納入 self.skills 中 skill.passive == true 的技能；
#         Phase44H 實機 setup 剩餘兩次 changed learn 分別為 Skill82 / Skill100，兩者 passive=false，故兩次
#         rebuild 都是完整重掃後零 Passive mutation。Phase44I 預期 setup restore 3→1、skills traversal 每層
#         7→3、audit events 43→25；EquipmentSkill final Passive convergence 保留。
#         另加入 TEST-only synthetic Passive learn probe，確認真正新學 Passive Skill 仍精確 rebuild 一次並
#         實際套用 ATK/DEF/CRITICAL_BONUS；新學非 Passive Skill 則 ownership 改變但 Passive rebuild=0。
# 【Phase44H】依 Phase44G2 實機 805 PASS / 0 FAIL / 0 WARN，進入 Formal candidate：
#         page307 KGC learn_skill 僅在 raw learned ownership 真正改變時 restore_passive_rev。Phase44G/G2 已實機證明
#         setup 共有 3 次 learn_skill，其中前兩次 changed=true、第三次 RuntimeSupport skill82 為 before=true /
#         after=true / changed=false，卻仍造成一次完整 Passive rebuild。H 保留底層 learn_skill 呼叫與所有 changed
#         learn refresh，只退休 no-op refresh。預期 setup restore 4→3、skills traversal 每層 9→7、audit events 52→43。
#         另加入 TEST-only standalone learn probe：重複學習既有 Skill 不得刷新；真正學會新 Skill 必須仍刷新一次。
# 【Phase44G2】依 Phase44G1 實機 800 PASS / 1 FAIL / 0 WARN 修正 TEST-only Leech isolation ASSERT 語意：
#         G1 已成功清除 prior HP-slip，但錯把 State35「寄生」當成一般 <slip: hp> State，要求
#         p41e_active_hp_slip_states == [35]；正式 State35 實際為 <close effect: 寄生種子>，slip_damage=false，
#         所以該 helper 正確結果本來就是 []。G2 先明確移除舊 State35、清除其他 HP-slip，再 add State35；
#         分開 ASSERT state?(35)==true 與 active HP-slip == []，最後仍走正式 Scene_Battle#hp_slip_damage。
#         Formal Runtime 0 修改；Phase44G setup mutation evidence與所有 Authority expectation 保留。
# 【Phase44G1】依 Phase44G 實機 801 PASS / 1 FAIL / 0 WARN 修正 TEST-only Leech Fixture 隔離：
#         Phase44G 診斷本體已完整 PASS，唯一 FAIL 為 Combo 開場鬼火剛好命中後續 Leech 目標，
#         使 Scene_Battle#hp_slip_damage 同 tick 結算 State35 的 100 傷害與殘留 HP-slip 8 傷害。
#         Leech Fixture 現與 Poison / Burn / Regen 一致，先以 p41e_clear_hp_slip_states 清除其他
#         active HP-slip State，再加入 State35 並 ASSERT isolated=[35]。Formal Runtime 0 修改。
# 【Phase44G】Setup LearnSkill Mutation Diagnostic。Phase44F 實機 800 PASS / 0 FAIL / 0 WARN 已封版，
#         setup restore_passive_rev 已由 5→4→3、skills traversal 每層 11→9→7。Phase44I candidate 目標為 1 / 3。
#         本階段只把剩餘三個 learn_skill scope 拆成「skill_id／名稱／before raw ownership／after raw ownership／
#         是否真的改變／Passive flag／所在 setup scope」，逐次輸出 [SETUP_LEARN_MUTATION]。
#         不先假設三次都是必要 mutation，也不修改 KGC learn_skill/forget_skill 或 EquipmentSkill Authority。
# 【Phase44F】KGC Setup Final Passive Refresh Retirement Candidate。Phase44E 實機 800 PASS / 0 FAIL / 0 WARN
#         已確認 setup 的 5 次 restore_passive_rev 來源：3 次 learn_skill、1 次 KGC setup wrapper 自身 final rebuild、
#         1 次 EquipmentSkill final Passive refresh；StateLearn / purge 均為 0。Formal 只修改 page307：保留
#         reset_passive_rev 與 setup_KGC_PassiveSkill alias boundary，退休 inner setup 返回後那次 legacy rebuild。
#         TEST 要求 restores 由 5 精確降為 4，learn_skill 仍為 3、EquipmentSkill final 仍為 1，且不得再出現
#         scopes=[:setup_total, :equipment_skill_setup] 的孤立 setup-final restore。其餘 Authority / Battle suite 全部照舊。
# 【Phase44E】Setup Passive Rebuild Source Diagnostic。Phase44D1 實機 795 PASS / 0 FAIL / 0 WARN 已封版
#         discard_equip legacy KGC early refresh retirement；本階段 Formal Runtime 0 修改，只追查 setup 仍存在的
#         restore_passive_rev=5 / skills traversal 每層=11 的來源。TEST-only scope stack 會標記 setup、
#         EquipmentSkill setup boundary、KGC PassiveSkill setup、learn_skill、StateLearnSkill cache、
#         YEM purge 與 EquipmentSkill final Passive refresh，逐次輸出 [SETUP_PASSIVE_SOURCE]。
#         probe 使用 detached Actor 並在結束後 exact restore；只建立下一個 wrapper retirement 的實機證據。
# 【Phase44D1】依 Phase44D 實機 390 PASS / 4 FAIL / 0 WARN 修正 TEST-only instrumentation：
#         page480 原以 Ruby 1.9+ Array#index { block } 尋找 KGC/EO boundary，RGSS2 Ruby 1.8 會拋 ArgumentError。
#         改用本頁既有 Ruby 1.8-safe p43g_event_index_after(events, tag, start_index)。
#         Formal page307 v1.1 retirement candidate 與 page330 v1.6 完全不變；所有 Phase44D Authority expectation 保留。
# 【Phase44D】Discard Passive Refresh Retirement Candidate。依 Phase44C2 實機 794 PASS / 0 FAIL / 0 WARN
#         的 invocation evidence，正常 discard_equip 同一次 lifecycle 仍執行 restore_passive_rev 兩次，
#         其中第一個來自 KGC_PassiveSkill legacy discard wrapper，第二個才是 CoreSafe v1.6 的 final Authority convergence。
#         本候選只退休 page307 legacy early refresh，保留 wrapper alias boundary；page330 v1.6 不變。
#         TEST expectation 改為 discard 全路徑只允許一次 final Passive refresh，且 skills traversal 由每層 4 次降為 2 次；
#         Teaching / Passive / Combo final convergence、Weapon / standard Armor / extra Armor、inventory / NEW / detached cleanup 全部仍須 PASS。
# 【素材】只使用目前資料庫既有 State／Skill／Actor／Enemy，不新增任何素材。
# 【安全規則】只在 $TEST=true 生效；SoulMark Fixture 禁止 learn_skill 偷塞魂刻技。
# 【Phase37D】新增 Soul Art Action Sequence Authority ASSERT，防止舊 CrimsonSeas Demo ID 247～255 攔截正式 Soul Art。
#         完整魂刻／碎片均在 Scene_Map Snapshot 後透過正式裝備／Party API 配置，
#         等待數個 Map frames 後才進戰鬥；Snapshot restore 後再 ASSERT 裝備與物品回復。
# 【Phase38A】新增 State34「灼燒」疊層 Residual Fixture。正式資料由 State Note 動態取得
#         max stack 與每層 HP slip 百分比；測試各層真實 DOT、ATK 逐層下降，並確認超額 add_state 不超過上限。
# 【Phase38B】新增 MP Regen / MP Degen Fixture。直接掃描正式 State Note 的 <slip: mp, flat, percent%>，
#         依符號動態分類回復／流失 State；走正式 Scene_Battle#mp_slip_damage，驗證精確 tick 與 MP 上下限 clamp。
# 【Phase38C】修正 MP Fixture 隔離：RGSS2 Game_Battler 並無 clear_states，因此舊 prepare helper 的
#         respond_to?(:clear_states) 在實機為 no-op。每個 MP case 改為逐一 remove_state 所有 active <slip: mp>
#         State，ASSERT cleanup 完成後才加入本 case State，避免 Regen / Degen 同時存在互相抵銷。
# 【Phase39A】新增 EquipmentCombo Opening / Summon State Ownership Fixture。沿用 SoulMark 動態配對，
#         在 Scene_Map 正式裝備 matching resonance headgear；Battle Start 由 ArmorMapping 動態取得 summon。
#         TEST-only wrapper 只在正式 Combo prepare 前預置其中一個 summon state，用來驗證 FinalAuthority
#         只 ownership 本場新加入的 state；同時等待 opening forced skill 真正 execute_action_skill 後才放行 Core Fixtures。
#         另修正 Core Fixture：技能已由 equipskill 等正式 provider 提供時不得再次 learn_skill。
# 【Phase40A】新增我方 Summon Runtime lifecycle Fixture。沿用 Phase39A 動態解析的 SoulMark→ArmorMapping summon，
#         Snapshot 後先確保 summon 不在 Party，再觀察 AlbertSummonTemporaryBattle.prepare / cleanup 正式 Authority：
#         驗證 summon entry、added ownership、SUMMON_BATTLE_SWITCH、Party/Battle Members、progress identity、
#         standby 暫移與 battle member count restore；terminate 後確認只移除本場新增 summon，runtime registry 全清空。
#         本階段只觀察正式 Runtime，不修改 FS_SummonRuntime_Authority。
# 【Phase40B】新增 EnemySummon lifecycle Fixture。與我方 Summon Runtime 分離驗證：
#         動態使用當前 Troop 的合法 Enemy 作 source / summon data，走正式 Game_Troop#ma_call_ally、
#         SafePosition、make_unique_names、Spriteset_Battle#ma_call_enemy，再讓新 Enemy 透過 FS_ForceAction_Bridge
#         真正進 Scene_Battle#execute_action_attack。另以暫時 Note probe 驗證 Final Guard 的嚴格 parser、
#         Game_Actor#skill_can_use? 禁用、Game_Troop Actor user guard 與 without_enemy_summon_tag；Note 立即還原。
#         battle_end / terminate 分段驗證：正式 battle_end 先清空 Game_Troop，Scene_Battle#terminate 再 dispose Sprite；
#         Battle Snapshot restore 最後確認 summoned instance、暫時 Note 與 forced queue 都不殘留。
# 【Phase40C】修正 Phase40B TEST-only Ruby 1.8 相容性：RPG Maker VX / RGSS2 執行環境不支援
#         Array#count { block }。EnemySummon duplicate-count 改用 Ruby 1.8 安全的 select { ... }.size；
#         不修改 EnemySummon Core / Final Guard / ForceAction 正式 Runtime。
# 【Phase40D】修正 EnemySummon lifecycle Fixture 的 ownership 時點 expectation。正式 Scene_Battle#battle_end
#         會在 Scene_Battle#terminate 之前先 $game_troop.clear，因此 Enemy instance 的 Battle-local ownership
#         邊界是 battle_end，不是 terminate。新增 battle_end 前後 ASSERT：進入前 summoned Enemy 必須仍在 Troop、
#         返回後 Troop 必須已清空；terminate 只驗 Sprite disposal 與 battle_end boundary 已觀察完成。
#         本階段只修 TEST-only Fixture，不修改 Scene_Battle / EnemySummon 正式 Runtime。
# 【Phase41B】修正 AI Authority deterministic expectation：依正式 RNG trace 的實際呼叫序列重播 preview，不再假設 distribution 是 reset 後第一個 RNG。
# 【Phase41C】新增 Equipment provider / equip-refresh Regression。Scene_Map prebattle 完成 SoulMark + matching headgear 後，
#         以正式 Game_Actor#change_equip 對 Armor653 做「卸下 → 再裝回」cycle；TEST-only trace 觀察
#         SetupBridge NEW suppression、EquipmentSkill teaching refresh、KGC Passive refresh、EquipmentCombo refresh。
#         卸下時 <equipskill> provider 必須從 Actor.skills 消失、raw learned 不得污染、matching headgear Combo 必須失效；
#         再裝回後 provider / Combo / inventory / NEW flag / skill list 必須完整恢復。Cooldown 仍依既有 prebattle 規格
#         在 final state 明確呼叫 recharge_all，不把 cooldown ownership 假裝成 change_equip 自動責任。
# 【Phase41A】新增 AI Authority Selection Regression。正式 Runtime 不執行額外戰鬥行動，只在 Combo Opening
#         完成後、EnemySummon Fixture 開始前，直接呼叫正式 Game_Actor#make_action / Game_Enemy#make_action：
#         Actor 端驗證 AI State 優先序、support package、合法技能／目標與零 progression 污染；Enemy 端驗證
#         FS_EnemyActionDistribution_FinalAuthority 的 eligibility、動態 attack rate、FS_AI_RANDOM 抽選與普通攻擊 override。
#         Fixture 完成後清除兩邊 Action 並重設 AI deterministic seed，不污染後續 EnemySummon / Core Fixtures。
# 【Phase41D】新增 Actor Setup chain regression。TEST-only 以 detached Game_Actor.new(1) 驗證正式 setup alias chain，
#         不替換 $game_actors[1]、不加入 Party。Trace 鎖定 RuntimeSupport → EquipmentSkill → SkillLevels →
#         EquipmentOverhaul → PassiveSkill → JobBase → OverDrive → RX/Base，並確認 setup 後 teaching/passive refresh。
#         第一輪建立正式 baseline；第二輪先污染 detached actor 的 level/EXP/raw skill/OD/JP/skill-level/equip runtime cache，
#         再對同一 object 呼叫 setup(1)，驗證 class/level/EXP/skills/equips/passive/runtime caches 完整回復。
#         同時 ASSERT detached setup 不改動 $game_party 與正式 $game_actors[1]。Combo refresh 不屬 setup ownership，
#         因此本 Fixture 不強迫 setup 自動觸發 EquipmentCombo。
# 【Phase41E】修正 HP Residual Fixture 隔離。Combo Opening Skill663「鬼火」可能合法把 State34 灼燒
#         附加到後續 Poison／Burn／Regen Fixture 使用的 Enemy；RGSS2 Game_Battler 沒有 clear_states，
#         舊 p37_prepare_enemy 因此不會清掉這些既存 HP-slip State。新增 TEST-only 動態隔離 helper：
#         透過正式 ALBERT_STATE_EFFECTS_V2.state_slip_value(..., "hp", ...) 找出目前會實際參與
#         Scene_Battle#hp_slip_damage 的 State，逐一走正式 remove_state alias chain 清除，再 ASSERT 空集合。
#         Poison／Burn／Regen 各 case 在加入本身 State 前都先完成隔離；不修改 StateEffects 正式 Runtime。
# 【Phase42A】新增 Equipment Slot Topology Regression。Phase41C 已封版正常 change_equip；本階段專測
#         YEM Equipment Overhaul#equip_type= 這條「結構性卸裝」側門。TEST-only detached Actor1 先以 test=true
#         將 SoulMark Armor653 放入目前正式最後一個合法額外防具欄，再把 equip_type 正式縮短一欄。
#         Setter 必須只透過正式 change_equip 移除被刪除欄位：193/194/253 equipskill provider 立即消失、
#         raw learned / unnatural marker 不受污染、原武器與前置欄位保留、NEW suppression 與
#         teaching → passive → combo refresh chain 正常。結構性卸裝暫時把 Armor653 歸還 Party 後，
#         Fixture 以正式 Party API 並在 NEW suppression 內補回原 inventory；再恢復 equip_type、重新 test-equip
#         驗證 provider 可復原，最後卸掉 detached provider。正式 $game_actors[1]、$game_party、
#         YEM::EQUIP::TYPE_LIST 必須與 Fixture 前完全一致；不修改 Equipment Runtime。
# 【Phase43B】依 Phase43A 實機 trace 修正並驗證 extra-slot discard_equip 最終 Passive refresh。
#         Formal page330 CoreSafe v1.3 只在真正清除 @extra_armor_id 後補 final Passive refresh；
#         Phase44D 後 TEST-only Fixture 改為只允許 post-removal final refresh（target equipped=false）；
#         legacy KGC early refresh 已退休，最後 Passive 仍必須回 baseline。
#         Phase43A 的 Armor101 byte-exact FAIL 另分類為 TEST-only lazy-cache cleanup：本版改用
#         database-slot Armor clone 注入 <equipskill>，正式 Armor object 從頭到尾不改 Note/cache，測後
#         將 $data_armors[id] 指回原 object 並驗證 object_id / Marshal bytes / Array identity 全部精確回復。
# 【Phase43D】discard_equip extra-slot Teaching / Combo Authority Diagnostic。Phase43B 已封閉 Passive stale；
#         本階段 Formal Runtime 0 修改，只沿同一 side-door 繼續診斷兩種 ownership：
#         A. synthetic extra-slot Armor 以 \ls[target, pre_level] 建立 temporary raw skill + @unnatural_skills marker；
#            discard 後正確行為應立即忘記 temporary skill 並清 marker。
#         B. synthetic extra-slot Armor 以 <combo_actor:1> + <combo_actor_state:state_id> 建立 Combo-owned State；
#            discard 後正確行為應立即移除本 Combo 自己持有的 State / ownership marker。
#         兩個 probe 都用 database-slot Armor clone；若 Formal discard 未刷新對應 Authority，ASSERT 會真實 FAIL，
#         但 TEST-only 會在返回前手動 refresh cleanup，確保 detached Actor / database / Party / $game_actors 精確還原。
# 【Phase43E】Phase43D 實機已證明 CoreSafe v1.4 的 extra-slot final convergence 正確執行
#         Teaching → Passive → Combo，Teaching raw/marker 與 Combo-owned State 都可在 discard 後清乾淨。
#         Phase43D 唯一 substantive FAIL 是 Phase43B 遺留的 TEST-only trace expectation 還只接受
#         Passive-only final refresh。本版只更新該 expected tag sequence，納入 teaching_refresh / combo_refresh；
#         Formal Runtime 0 修改，CoreSafe v1.4 保持 byte-exact。所有既有 ownership / cleanup ASSERT 保留。
# 【Phase43F】一般裝備欄（slot1..4）discard_equip Authority Diagnostic。Phase43E 已封版 extra-slot
#         Teaching → Passive → Combo final convergence；本階段 Formal Runtime 0 修改，改測同一 discard_equip
#         對 VX 原生四個防具欄的 ownership 邊界。Teaching probe 對 synthetic Skill 同時加入 Passive
#         ATK+37 / DEF+13 / CRITICAL_BONUS，藉此區分「裝備已先移除」與「Teaching raw skill 尚未清除」：
#         若舊 KGC Passive refresh 在 Teaching cleanup 前執行，raw/marker 與 Passive 會一起 stale。Combo probe
#         則驗證一般欄 Armor 被 discard 後 Combo-owned State 是否同步解除。兩 probe 均使用 database-slot
#         Armor/Skill clone，失敗後以既有正式 Authority TEST-only cleanup，再要求 Party / $game_actors / DB 精確還原。
# 【Phase44A1】依 Phase44A 實機 LOG 修正一個 TEST-only precondition expectation：Weapon 本身的 ATK
#         會進入 Actor.base_atk，因此不能沿用 Armor fixture 的「base_atk 只增加 Passive +37」判定。
#         改以 passive_params[:atk]/[:def]、critical_bonus 與 CRI 精確驗證 Passive Authority；
#         Formal defect 的 Teaching／Passive／Combo post-discard ASSERT 保留不放寬，用來驗收 CoreSafe v1.6。
# 【Phase44A】Weapon discard_equip Authority Diagnostic。Phase43G 已封版所有 Armor slot 的
#         Teaching → Passive → Combo final convergence；本階段 Formal Runtime 0 修改，只測 Weapon。
#         Provider probe 使用 database-slot Weapon clone，同時加入獨立 Direct <equipskill> 與
#         Teaching \ls[target, pre_level]；Teaching target 暫時切到 synthetic Passive Skill clone，
#         因此可分辨「Direct visibility 自動消失」與「temporary raw/marker、Passive cache 是否 stale」。
#         Combo probe 另保留 synthetic Armor trigger，以 <combo_require_weapon:weapon_id> +
#         <combo_actor_state:state_id> 建立 ownership，只 discard Weapon，確認 required-weapon 條件失效後
#         Combo-owned State / marker 是否立即清除。兩 probe 均 trace discard_equip final / YEM / KGC /
#         Teaching / Passive / Combo exact invocation order/count；ASSERT 失敗後只由 TEST 手動 convergence cleanup。
#         Weapon/Armor/Skill database slot、Class learning、inventory Hash tombstone、NEW flag、detached Actor、
#         Game_Party / $game_actors 必須在 Scene_Map 階段 byte/state exact restore。
# 【Phase44B】Legality / purge_unequippable Automatic Removal Authority Diagnostic。Phase44A1 已實機封版
#         Weapon + Armor discard_equip final convergence；本階段 Formal Runtime 0 修改。TEST-only 以 database-slot
#         clone 在「已正式裝備後」注入 impossible ABOVE LEVEL requirement，使 equippable? 轉為 false，再直接呼叫
#         YEM purge_unequippable。Weapon probe 同時覆蓋 Direct <equipskill>、Teaching \ls、synthetic Passive、
#         required-Weapon Combo-owned State；extra-slot Armor probe 覆蓋 Direct / Teaching / Passive / self Combo State。
#         兩案都 trace purge_enter -> change_equip -> purge_exit、@purge_on recursion guard、NEW suppression 與
#         Teaching -> Passive -> Combo exact-once convergence；inventory Hash tombstone、NEW flag、database slots、
#         detached Actor、Game_Party / $game_actors 必須在 Scene_Map 階段 exact restore。禁止 Class Change。
# 【來源／授權】Forest Symphony 專案自製自動回歸測試腳本。
#==============================================================================

# 【Phase42C】修正 Phase42B Fixture 選材假設：Actor1/Class1 在目前資料庫 Lv5 後沒有 future class learning，
#         因此前版在真正測試 \ls ownership 前即 TEST-only prerequisite FAIL。新版先掃描 $data_actors / $data_classes
#         找到具有 future learning 的 actor/class/skill，再建立 detached Actor 做正式 eligibility probe；候選搜尋不得透過
#         $game_actors[id] 建立 formal instance，並以 Marshal.dump($game_actors) 前後 byte-exact 驗證零全域污染。
#         Armor 候選也排除所有目前已實例化 Actor 正在穿的 Armor。Formal Runtime 仍維持 0 修改。
# 【Phase42D】修正 Phase42C 測試素材不存在問題：目前正式 $data_actors / $data_classes 掃描後沒有任何可供 Fixture 使用的
#         future Class learning 樣本，因此動態 selector 仍無法真正進入 Equipment Teaching ownership Runtime。
#         新版改為 TEST-only Synthetic Class Learning：只在 Fixture 執行期間，對一個 detached Actor 的正式 Class
#         learnings Array 尾端暫時加入一筆 RPG::Class::Learning，natural_level 固定為該 Actor initial_level + 1；
#         target skill 動態挑選為目前未學、未由既有裝備提供、且該 Class 沒有既有 learning 的有效 Skill。
#         注入前記錄 Class learnings Array object_id + Marshal.dump；測完只刪除同一 synthetic object，要求
#         Array identity 不變且 Marshal bytes 完全回復，並在進戰鬥前完成還原。Formal Runtime / 正式資料庫內容 0 永久修改。
# 【Phase42E】修正 Phase42D TEST-only Party byte-exact cleanup。RGSS2 原生 Game_Party#gain_item 在數量歸零時
#         會保留 @items/@weapons/@armors Hash 的 zero-count key；Phase42D 使用原本未存在的 Armor1 做 detached
#         Fixture，因此正式 grant/equip/unequip/compensate 後 item_number 已回 0，但 @armors[1]=0 tombstone 仍存在，
#         造成 Marshal.dump($game_party) 由 10748 增至 10752。新版在 Fixture 前記錄 inventory container
#         object_id、key 是否存在與 raw value；仍先用正式 Party API 恢復數量，再僅對 Fixture 自己新增的 zero-count
#         tombstone 做 TEST-only 精確刪除。最後 ASSERT container identity / key-presence / raw value / Party Marshal 全部回復。
#         這是測試清理，不修改 RGSS2 / Game_Party 正式 Runtime，也不把 zero-key 行為分類為遊戲 bug。
# 【Phase42F】新增 Equipment PassiveSkill Refresh / Ownership Regression。FS 正式無轉職系統，因此取消原規劃的
#         Class Change / Equipment Legality 測試；改驗證實際會使用的固定職業升級＋裝備教學＋KGC PassiveSkill 鏈。
#         TEST-only 對 synthetic teaching skill 暫時加入 PassiveSkill Note，驗證：L-1 裝備教學時被動立即生效；
#         自然等級前卸裝會忘記臨時技能且被動完整回復；重裝後再次生效；升級成自然學會後 marker 解除；
#         最後卸裝不得移除自然技能，被動也必須持續有效。
# 【Phase42H】修正 Phase42G 最後一個 TEST-only 還原假陽性：不再原地修改正式 $data_skills[target] 的
#         Note/cache，也不再嘗試猜測並還原所有可能由其他腳本建立的 Skill ivar。新版先 Marshal clone 原 Skill，
#         synthetic Passive 只寫 clone，再暫時把同一 $data_skills Array slot 指向 clone；Fixture 結束前恢復
#         原本完全未被修改的 Skill object，要求 $data_skills Array identity、原 Skill object_id、Marshal bytes 全部一致。
#         Phase42G page330 CRITICAL_BONUS Formal fix 保持 byte-exact，不再修改正式 Runtime。
# 【Phase42J】修正 Multi-Provider Fixture：Passive ownership 比較改以 Passive Authority cache 為準，不把第二件裝備自身 ATK/DEF 等固有能力誤判為同一 Passive 重複疊加。FS 固定職業架構下，實際仍可能有兩件裝備
#         同時以 \ls 提供同一技能。新版以 TEST-only detached Actor + synthetic Passive Skill clone，動態找兩件不同合法欄位、
#         無既有 \ls/equipskill/Combo/SoulMark 的 Armor，暫時都追加同一 \ls[target, pre_level]。驗證 A→B 同時裝備時
#         raw learned / @unnatural_skills 只維持單一 ownership、Passive 不得重複疊加；先卸 A 時只要 B 還在，技能與 Passive
#         必須保留，最後卸 B 才解除。接著反向重跑並先卸 B，確認 provider removal order 不影響 ownership。
#         兩件 Armor Note、Party inventory/tombstone、NEW flag、synthetic Skill database slot、Class learning、detached Actor、
#         $game_party / $game_actors 均在進戰鬥前精確還原。Formal Runtime 不修改。
# 【Phase42L】修正 Phase42K TEST-only Ruby 1.8 cache existence probe。RGSS2 執行環境中
#         `instance_variable_defined?` 不可作為可靠的 Fixture 相容性判定；舊 helper rescue 後把既存
#         `@equipment_skills=[]` 誤判成「原本沒有 cache」，因此追加 `<equipskill: 2>` 後未將舊空 cache
#         設回 nil，正式 RPG::BaseItem#skills 直接回傳 stale []，造成 Direct provider 整串假失敗，cleanup
#         也誤 remove 原本存在的 cache slot。新版改用 Ruby 1.8 安全的 `instance_variables.collect { |v| v.to_s }`
#         判斷 ivar 是否存在；原本有 slot 時只 set nil 觸發正式 parser 重算，測後恢復原 raw value 與 ivar order；
#         原本沒有 slot 才允許移除 Fixture 新增的 cache。Formal EquipmentSkill / PassiveSkill Runtime 0 修改。
# 【Phase43A】Equipment / Setup Authority Convergence Audit。Phase42L 已封版 mixed Teaching × Direct provider ownership；
#         本階段不刪除任何 Formal wrapper，只新增 TEST-only 診斷。第一個高風險邊界鎖定 Game_Actor#discard_equip：
#         KGC PassiveSkill 仍在 discard_equip wrapper 內呼叫 restore_passive_rev，而 YEM Equipment Overhaul
#         對 extra armor slot 的實際 @extra_armor_id 清除發生在該 KGC wrapper 返回之後。Fixture 以 detached Actor、
#         synthetic Passive Skill clone 與乾淨 extra-slot Armor 暫時建立 <equipskill> provider，完整 trace
#         discard_equip final → YEM alias → KGC alias → base discard → restore_passive_rev 的時序，並驗證
#         discard 後 extra slot、Skill visibility 與 Passive cache 是否一致清除。若實機只剩 Passive stale，
#         才分類為 Formal refresh-order defect；本 Phase 本身 Formal Runtime 0 修改。
# 【Phase42C】Equipment Teaching / Level-Up Ownership Regression 本體沿用 Phase42B 設計：TEST-only detached Actor 動態選擇
#         下一個尚未自然學會的 Class learning，並挑選一件正式可裝、未被正式 Actor 使用、無 Combo／equipskill／既有 \ls 的 Armor。
#         Fixture 暫時在該 Armor Note 追加 \ls[target_skill, current_level]，透過正式 Party API 提供裝備並走
#         change_equip：技能必須進 raw learned 並由 @unnatural_skills 標記為裝備臨時 ownership。接著只呼叫一次
#         正式 level_up 跨入 Class learning 等級；EquipmentSkill Authority 的 level_up refresh 必須將 marker 除籍但保留
#         learned skill。最後再正式卸裝，技能仍必須存在，證明 ownership 已從 equipment-temporary 轉為 natural。
#         暫時 Note、Party inventory、NEW flag、正式 $game_actors 與 detached Actor baseline 全部精確還原；不修改正式 Runtime。

$imported = {} if $imported == nil
$imported["FS BattleRegression ResidualDrainFixtures"] = "1.0a"

module FS_TEST_HARNESS
  RESIDUAL_FIXTURE_VERSION = "0.8b"
  RESIDUAL_POISON_STATE_ID = 31
  RESIDUAL_BURN_STATE_ID   = 34
  RESIDUAL_REGEN_STATE_ID  = 64
  RESIDUAL_LEECH_STATE_ID  = 35

  @p37_residual_suite_done = false
  @p37_soul_prebattle = nil

  class << self
    #--------------------------------------------------------------------------
    # ● Phase 37 至少需要一名 Enemy；Phase36 原條件維持即可
    #--------------------------------------------------------------------------
    def p37_alive_enemy(preferred = 0)
      list = $game_troop.members.select { |e| e != nil }
      return nil if list.empty?
      target = list[preferred.to_i % list.size]
      return target
    end

    def p37_subject
      return core_current_subject if respond_to?(:core_current_subject)
      begin
        return $game_actors[1]
      rescue
        return nil
      end
    end

    #--------------------------------------------------------------------------
    # ● Phase37C：SoulMark 正式前置資料動態推導
    #--------------------------------------------------------------------------
    def p37_raw_skill_learned?(actor, skill_id)
      return false if actor == nil
      raw = actor.instance_variable_get(:@skills) rescue nil
      return false unless raw.is_a?(Array)
      return raw.include?(skill_id.to_i)
    end

    def p37_equipped_item?(actor, item)
      return false if actor == nil || item == nil || !actor.respond_to?(:equips)
      actor.equips.compact.any? do |current|
        current.class == item.class && current.id.to_i == item.id.to_i
      end
    end

    def p37_find_armor_slot(actor, armor)
      return nil if actor == nil || armor == nil
      return nil unless armor.is_a?(RPG::Armor)
      return nil unless actor.respond_to?(:equip_type)
      return nil unless defined?(YEM::EQUIP::TYPE_RULES)
      actor.equip_type.each_with_index do |slot_type, index|
        rule = YEM::EQUIP::TYPE_RULES[slot_type]
        next if rule == nil
        return index + 1 if rule[1].to_i == armor.kind.to_i
      end
      return nil
    end

    def p37_equip_signature(actor)
      return [] if actor == nil || !actor.respond_to?(:equips)
      actor.equips.collect do |item|
        item == nil ? nil : [item.class.to_s, item.id.to_i]
      end
    end

    def p37_probe_battle_skill_can_use(actor, skill)
      return false if actor == nil || skill == nil || $game_temp == nil
      old = $game_temp.in_battle
      begin
        # Scene 仍是 Scene_Map；只把正式 skill_can_use? 以 battle occasion 做純查詢。
        # 不建立 Action、不支付成本、不切 Scene，也不改變任何正式資料。
        $game_temp.in_battle = true
        return actor.skill_can_use?(skill) == true
      ensure
        $game_temp.in_battle = old
      end
    rescue
      return false
    end

    def p37_soul_prebattle_data(actor, skill, percent)
      return nil unless defined?(FS_SOULMARK_RESONANCE)
      return nil if actor == nil || skill == nil
      mod = FS_SOULMARK_RESONANCE
      required = ["SOUL_SKILL_START", "SOUL_ARMOR_START", "FRAGMENT_ITEM_START",
                  "RESONANCE_HEADGEAR_START"]
      required.each { |name| return nil unless mod.const_defined?(name) }
      index = skill.id.to_i - mod::SOUL_SKILL_START.to_i
      return nil if index < 0
      armor_id = mod::SOUL_ARMOR_START.to_i + index
      fragment_id = mod::FRAGMENT_ITEM_START.to_i + index
      headgear_id = mod::RESONANCE_HEADGEAR_START.to_i + index
      armor = $data_armors[armor_id] rescue nil
      item = $data_items[fragment_id] rescue nil
      headgear = $data_armors[headgear_id] rescue nil
      return {
        :actor_id=>actor.id.to_i, :skill_id=>skill.id.to_i, :index=>index,
        :drain_percent=>percent.to_i, :armor_id=>armor_id, :fragment_id=>fragment_id,
        :headgear_id=>headgear_id, :armor=>armor, :item=>item, :headgear=>headgear
      }
    end

    #--------------------------------------------------------------------------
    # ● Scene_Map：Snapshot 後正式配置 SoulMark / Item prerequisite
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37c_prepare_battle_fixture_on_map_base)
      alias fs_phase37c_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase37c_prepare_battle_fixture_on_map_base
      actor = p37_subject
      soul_data = p37_find_soul_drain
      skill = soul_data[0]
      percent = soul_data[1].to_i
      data = p37_soul_prebattle_data(actor, skill, percent)

      assert("SoulMark prebattle runs on Scene_Map", $scene.is_a?(Scene_Map), $scene.class)
      assert("SoulMark prebattle subject exists", actor != nil,
             actor == nil ? "nil" : object_label(actor))
      assert("SoulMark prebattle drain art exists", skill != nil && percent > 0,
             skill == nil ? "nil" : "skill=#{skill.id}:#{skill.name} drain=#{percent}%")
      assert("SoulMark prerequisite constants resolved", data != nil,
             data == nil ? "nil" : "index=#{data[:index]}")
      return false if actor == nil || skill == nil || data == nil

      armor = data[:armor]
      item = data[:item]
      headgear = data[:headgear]
      assert("SoulMark provider armor exists", armor != nil,
             "armor_id=#{data[:armor_id]}")
      assert("SoulMark cost item exists", item != nil,
             "item_id=#{data[:fragment_id]}")
      assert("SoulMark matching resonance headgear exists", headgear != nil,
             "headgear_id=#{data[:headgear_id]}")
      return false if armor == nil || item == nil

      armor_skill_ids = []
      begin
        armor_skill_ids = armor.skills.compact.collect { |entry| entry.id.to_i }
      rescue
        armor_skill_ids = []
      end
      assert("SoulMark armor formally grants drain art via equipskill",
             armor_skill_ids.include?(skill.id.to_i),
             "armor=#{armor.id}:#{armor.name} skills=#{armor_skill_ids.inspect}")

      combo_pair = false
      combo_grants_art = false
      if headgear != nil && headgear.respond_to?(:albert_combo_required_armors)
        combo_pair = headgear.albert_combo_required_armors.include?(armor.id.to_i)
        if headgear.respond_to?(:albert_combo_skill_ids)
          combo_grants_art = headgear.albert_combo_skill_ids.include?(skill.id.to_i)
        end
      end
      assert("Matching resonance headgear points to SoulMark armor", combo_pair == true,
             "headgear=#{data[:headgear_id]} armor=#{data[:armor_id]}")
      assert("SoulMark art is not gated by EquipmentCombo headgear", combo_grants_art == false,
             "headgear=#{data[:headgear_id]} combo_skill253=#{combo_grants_art}")
      log("[PREBATTLE] soul_index=#{data[:index]} skill=#{skill.id}:#{skill.name} " +
          "armor=#{armor.id}:#{armor.name} headgear=#{data[:headgear_id]} role=optional_summon_combo")

      # 保存 Snapshot 前的玩家狀態期望值，供 Snapshot restore 後逐項 ASSERT。
      data[:original_equips] = p37_equip_signature(actor)
      data[:original_item_count] = $game_party.item_number(item)
      data[:original_armor_count] = $game_party.item_number(armor)
      data[:original_raw_skill] = p37_raw_skill_learned?(actor, skill.id)

      # 禁止 manual learn：若玩家原狀態剛好殘留 Skill253，測試暫時移除它；
      # Snapshot 會還原。之後 actor.skills 必須只能由裝備完整魂刻取得。
      actor.forget_skill(skill.id) if actor.respond_to?(:forget_skill) &&
                                      p37_raw_skill_learned?(actor, skill.id)
      assert("SoulMark manual learned copy absent before equip",
             p37_raw_skill_learned?(actor, skill.id) == false,
             "skill=#{skill.id}")

      slot = p37_find_armor_slot(actor, armor)
      data[:slot] = slot
      assert("SoulMark legal equipment slot resolved", slot != nil,
             "armor_kind=#{armor.kind} actor_types=#{actor.equip_type.inspect}")
      return false if slot == nil

      already = p37_equipped_item?(actor, armor)
      unless already
        $game_party.gain_item(armor, 1) if $game_party.item_number(armor) <= 0
        assert("SoulMark armor available in party before equip",
               $game_party.item_number(armor) > 0,
               "armor=#{armor.id} count=#{$game_party.item_number(armor)}")
        actor.change_equip(slot, armor, false)
      end
      equipped = p37_equipped_item?(actor, armor)
      current = actor.equips[slot] rescue nil
      log("[EQUIP] actor=#{actor.id}:#{actor.name} slot=#{slot} armor=#{armor.id}:#{armor.name} " +
          "already=#{already.inspect} current=#{current == nil ? 'nil' : current.id}")
      assert("SoulMark armor equipped through formal change_equip", equipped == true,
             "slot=#{slot} armor=#{armor.id}")

      # 正式 Refresh 鏈。<equipskill> 本身是 actor.skills 動態讀取，但仍把
      # teaching/passive/combo 都刷新，確保 Fixture 與正常換裝完成後狀態一致。
      actor.albert_refresh_equipment_teaching_skills if actor.respond_to?(:albert_refresh_equipment_teaching_skills)
      actor.albert_refresh_equipment_passive_skills if actor.respond_to?(:albert_refresh_equipment_passive_skills)
      actor.albert_refresh_combo_actor_states if actor.respond_to?(:albert_refresh_combo_actor_states)
      actor.recharge_all if actor.respond_to?(:recharge_all)
      log("[REFRESH] actor=#{actor.id} equipskill=true passive=true combo=true cooldown=true")

      skill_in_list = actor.skills.any? { |entry| entry != nil && entry.id.to_i == skill.id.to_i }
      assert("SoulMark drain art obtained from equipped armor", skill_in_list == true,
             "skill=#{skill.id} armor=#{armor.id}")
      assert("SoulMark drain art still absent from raw learned list",
             p37_raw_skill_learned?(actor, skill.id) == false,
             "skill=#{skill.id}")

      calc_item = actor.respond_to?(:calc_item_cost) ? actor.calc_item_cost(skill).to_i : 0
      assert_equal("SoulMark dynamic item cost matches Soul Art index", data[:fragment_id], calc_item)
      item_before = $game_party.item_number(item)
      $game_party.gain_item(item, 1)
      item_after = $game_party.item_number(item)
      data[:fixture_item_before] = item_after
      assert_equal("SoulMark prebattle cost item granted once", item_before + 1, item_after)
      log("[PREBATTLE] [COST] item=#{item.id}:#{item.name} before=#{item_before} prepared=#{item_after}")

      usable = p37_probe_battle_skill_can_use(actor, skill)
      log("[PREBATTLE] skill_can_use_battle_probe=#{usable.inspect} scene=#{$scene.class} in_battle=#{$game_temp.in_battle.inspect}")
      assert("SoulMark battle prerequisites usable before transition", usable == true,
             "skill=#{skill.id} equipped=#{equipped} item=#{item_after}")

      data[:ready] = equipped && skill_in_list && !p37_raw_skill_learned?(actor, skill.id) && usable
      @p37_soul_prebattle = data
      return data[:ready] == true
    rescue Exception => e
      exception(e, "p37_prepare_soulmark_prebattle")
      assert("SoulMark prebattle fixture prepared", false, e.message)
      return false
    end

    # Phase37C 規格：配置完成後至少等 6 個真正的 Map frame。
    unless method_defined?(:fs_phase37c_prebattle_wait_frames_base)
      alias fs_phase37c_prebattle_wait_frames_base prebattle_wait_frames
    end
    def prebattle_wait_frames
      base = fs_phase37c_prebattle_wait_frames_base.to_i
      return [base, 6].max
    end

    # Scene_Battle 真正開始後，再確認同一套正式 skill_can_use? 仍成立。
    unless method_defined?(:fs_phase37c_on_battle_scene_start_base)
      alias fs_phase37c_on_battle_scene_start_base on_battle_scene_start
    end
    def on_battle_scene_start(scene)
      result = fs_phase37c_on_battle_scene_start_base(scene)
      data = @p37_soul_prebattle
      if data != nil && data[:ready]
        actor = $game_actors[data[:actor_id]] rescue nil
        skill = $data_skills[data[:skill_id]] rescue nil
        armor = $data_armors[data[:armor_id]] rescue nil
        equipped = p37_equipped_item?(actor, armor)
        listed = actor != nil && skill != nil && actor.skills.any? { |entry| entry != nil && entry.id.to_i == skill.id.to_i }
        usable = actor != nil && skill != nil ? actor.skill_can_use?(skill) : false
        log("[REFRESH] battle-entry actor=#{data[:actor_id]} armor=#{data[:armor_id]} equipped=#{equipped.inspect} " +
            "skill=#{data[:skill_id]} listed=#{listed.inspect} skill_can_use=#{usable.inspect}")
        assert("SoulMark armor remains equipped at battle entry", equipped == true)
        assert("SoulMark skill remains equipment-provided at battle entry", listed == true && !p37_raw_skill_learned?(actor, data[:skill_id]))
        assert("SoulMark skill formally usable at battle entry", usable == true,
               "skill=#{data[:skill_id]}")
      end
      return result
    end

    # Snapshot restore 後，Summary 前逐項證明裝備與物品已回原狀。
    unless method_defined?(:fs_phase37c_after_snapshot_restore_base)
      alias fs_phase37c_after_snapshot_restore_base after_battle_snapshot_restore
    end
    def after_battle_snapshot_restore
      base = fs_phase37c_after_snapshot_restore_base
      data = @p37_soul_prebattle
      return base if data == nil
      actor = $game_actors[data[:actor_id]] rescue nil
      item = $data_items[data[:fragment_id]] rescue nil
      armor = $data_armors[data[:armor_id]] rescue nil
      equips_now = p37_equip_signature(actor)
      item_now = item == nil ? nil : $game_party.item_number(item)
      armor_now = armor == nil ? nil : $game_party.item_number(armor)
      raw_now = p37_raw_skill_learned?(actor, data[:skill_id])
      log("[SNAPSHOT] SOULMARK restore equips=#{equips_now.inspect} item=#{data[:fragment_id]}:#{item_now} armor=#{data[:armor_id]}:#{armor_now}")
      assert_equal("SoulMark snapshot restores original equips", data[:original_equips], equips_now)
      assert_equal("SoulMark snapshot restores original cost item", data[:original_item_count], item_now)
      assert_equal("SoulMark snapshot restores original armor inventory", data[:original_armor_count], armor_now)
      assert_equal("SoulMark snapshot restores original raw skill", data[:original_raw_skill], raw_now)
      return base
    end

    def p37_prepare_enemy(target, maxhp, hp)
      return false if target == nil
      begin
        target.clear_states if target.respond_to?(:clear_states)
        target.clear_action_results if target.respond_to?(:clear_action_results)
        target.maxhp = maxhp.to_i if target.respond_to?(:maxhp=)
        target.hp = hp.to_i if target.respond_to?(:hp=)
        target.mp = target.maxmp if target.respond_to?(:mp=)
        return true
      rescue Exception => e
        exception(e, "p37_prepare_enemy")
        return false
      end
    end

    def p37_prepare_subject(subject)
      return false if subject == nil
      begin
        subject.clear_states if subject.respond_to?(:clear_states)
        subject.clear_action_results if subject.respond_to?(:clear_action_results)
        subject.hp = 1 if subject.respond_to?(:hp=)
        subject.mp = subject.maxmp if subject.respond_to?(:mp=)
        return true
      rescue Exception => e
        exception(e, "p37_prepare_subject")
        return false
      end
    end

    #--------------------------------------------------------------------------
    # ● Fixture 專用 Combat RNG scope（不覆寫 Core Fixture 計數器）
    #--------------------------------------------------------------------------
    def p37_with_combat_rng(label)
      unless defined?(FS_COMBAT_RANDOM)
        assert("Residual Combat RNG provider exists", false, label)
        return yield
      end
      FS_COMBAT_RANDOM.enable(COMBAT_SEED)
      log("[RESIDUAL_RNG] ENABLE seed=#{COMBAT_SEED} scope=#{label}")
      result = yield
      lines = FS_COMBAT_RANDOM.trace_lines
      for line in lines
        log("[RESIDUAL_RNG] #{line}")
      end
      log("[RESIDUAL_RNG] DISABLE scope=#{label} count=#{FS_COMBAT_RANDOM.count}")
      return result
    ensure
      begin
        FS_COMBAT_RANDOM.disable if defined?(FS_COMBAT_RANDOM) && FS_COMBAT_RANDOM.enabled?
      rescue
      end
    end

    #--------------------------------------------------------------------------
    # ● Phase41E：HP Slip Fixture 隔離
    #    - RGSS2 Game_Battler 沒有 clear_states；只清除「目前真的會參與 hp_slip_damage」
    #      的 active State，並走正式 remove_state alias chain。
    #    - 使用正式 ALBERT_STATE_EFFECTS_V2.state_slip_value 判定，不硬編碼 State34。
    #--------------------------------------------------------------------------
    def p41e_active_hp_slip_states(target)
      return [] if target == nil || !target.respond_to?(:states)
      return [] unless defined?(ALBERT_STATE_EFFECTS_V2)
      maxhp = target.respond_to?(:maxhp) ? target.maxhp.to_i : 1
      maxhp = 1 if maxhp < 1
      return target.states.compact.select do |state|
        begin
          data = ALBERT_STATE_EFFECTS_V2.state_slip_value(target, state, "hp", maxhp)
          data != nil && data[0].to_f != 0.0
        rescue
          false
        end
      end
    rescue
      return []
    end

    def p41e_clear_hp_slip_states(target, label)
      return false if target == nil
      before = p41e_active_hp_slip_states(target).collect { |state| state.id.to_i }
      before.each do |state_id|
        target.remove_state(state_id) if target.respond_to?(:remove_state)
      end
      after = p41e_active_hp_slip_states(target).collect { |state| state.id.to_i }
      log("[HP_RESIDUAL] isolate case=#{label} before=#{before.inspect} after=#{after.inspect}")
      assert("HP residual prior slip states cleared for #{label}", after.empty?,
             "before=#{before.inspect} after=#{after.inspect}")
      return after.empty?
    rescue Exception => e
      exception(e, "p41e_clear_hp_slip_states_#{label}")
      assert("HP residual prior slip states cleared for #{label}", false, e.message)
      return false
    end

    def p41e_assert_hp_slip_isolated(target, expected_ids, label)
      active = p41e_active_hp_slip_states(target).collect { |state| state.id.to_i }.sort
      expected = expected_ids.collect { |id| id.to_i }.sort
      assert_equal("HP residual fixture isolated for #{label}", expected, active)
      log("[HP_RESIDUAL] isolate case=#{label} active=#{active.inspect}")
      return active == expected
    end

    #--------------------------------------------------------------------------
    # ● Poison：State31 1 stack / 1% MaxHP + Tankentai variance
    #    現行 baseline：MaxHP=1000、seed149 的 rand(5)=2,0 → 10.2 round=10
    #--------------------------------------------------------------------------
    def p37_fixture_poison(scene)
      target = p37_alive_enemy(0)
      assert("Residual poison target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if target == nil
      return false unless p37_prepare_enemy(target, 1000, 1000)
      return false unless p41e_clear_hp_slip_states(target, "poison")
      state = $data_states[RESIDUAL_POISON_STATE_ID] rescue nil
      assert("Poison State31 exists", state != nil,
             "state=#{RESIDUAL_POISON_STATE_ID}")
      return false if state == nil
      target.add_state(RESIDUAL_POISON_STATE_ID)
      return false unless p41e_assert_hp_slip_isolated(target, [RESIDUAL_POISON_STATE_ID], "poison")
      stack = 1
      begin
        stack = target.stack(state).to_i if target.respond_to?(:stack)
      rescue
        stack = 1
      end
      stack = 1 if stack < 1
      assert_equal("Poison fixture stack", 1, stack)
      before = target.hp
      p37_with_combat_rng("poison_state31") do
        scene.send(:hp_slip_damage, target)
      end
      actual = before - target.hp
      expected = 10
      log("[RESIDUAL] POISON state=31 maxhp=1000 stack=#{stack} hp=#{before}->#{target.hp} damage=#{actual}")
      assert_equal("Poison residual damage exact", expected, actual)
      assert("Poison state remains active", target.state?(RESIDUAL_POISON_STATE_ID) == true)
      return true
    rescue Exception => e
      exception(e, "p37_fixture_poison")
      assert("Poison residual fixture completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● Phase38A：Burn Stack（State34）
    #    - 正式資料：<max stack 3>、<slip: hp, 0, 1%>
    #    - MaxHP=1000 時，1/2/3 stack 應分別造成 10/20/30 傷害。
    #    - 第 4 次 add_state 後仍必須維持 max stack，不得溢位。
    #    - expected 由正式 State Note / max_stack 動態推導，不把 1% 或 3 層寫死成結果。
    #--------------------------------------------------------------------------
    def p38_burn_slip_percent(state)
      return nil if state == nil || !state.respond_to?(:note)
      text = state.note.to_s
      if text =~ /<\s*slip\s*:\s*hp\s*,\s*([-+]?\d+(?:\.\d+)?)\s*,\s*([-+]?\d+(?:\.\d+)?)\s*[%％]?\s*>/i
        return $2.to_f
      end
      if text =~ /<\s*hp\s+degen\s+([-+]?\d+(?:\.\d+)?)\s*[%％]\s*>/i
        return $1.to_f
      end
      return nil
    end

    def p38_state_stack(target, state)
      return 0 if target == nil || state == nil
      begin
        return target.stack(state).to_i if target.respond_to?(:stack)
      rescue
      end
      return target.state?(state.id) ? 1 : 0
    end

    def p38_fixture_burn_stack(scene)
      target = p37_alive_enemy(3)
      assert("Burn stack target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if target == nil
      return false unless p37_prepare_enemy(target, 1000, 1000)
      return false unless p41e_clear_hp_slip_states(target, "burn")

      state = $data_states[RESIDUAL_BURN_STATE_ID] rescue nil
      assert("Burn State34 exists", state != nil,
             "state=#{RESIDUAL_BURN_STATE_ID}")
      return false if state == nil

      max_stack = state.respond_to?(:max_stack) ? state.max_stack.to_i : 1
      max_stack = 1 if max_stack < 1
      per_stack_percent = p38_burn_slip_percent(state)
      assert("Burn formal max stack supports stacking", max_stack > 1,
             "state=#{state.id}:#{state.name} max_stack=#{max_stack}")
      assert("Burn formal HP slip percent resolved", per_stack_percent != nil && per_stack_percent > 0,
             "state=#{state.id}:#{state.name} percent=#{per_stack_percent.inspect}")
      return false if per_stack_percent == nil || per_stack_percent <= 0

      begin
        target.atk = 500 if target.respond_to?(:atk=)
      rescue
      end
      baseline_atk = target.respond_to?(:atk) ? target.atk.to_i : nil
      previous_atk = baseline_atk
      log("[BURN] stat_probe state=#{state.id} atk_rate=#{state.atk_rate} baseline_atk=#{baseline_atk.inspect}")

      tested_max = max_stack
      for desired_stack in 1..tested_max
        target.add_state(state.id)
        p41e_assert_hp_slip_isolated(target, [state.id], "burn") if desired_stack == 1
        actual_stack = p38_state_stack(target, state)
        assert_equal("Burn stack increments formally to #{desired_stack}", desired_stack, actual_stack)

        current_atk = target.respond_to?(:atk) ? target.atk.to_i : nil
        if previous_atk != nil && current_atk != nil && state.atk_rate.to_i < 100
          assert("Burn stack lowers ATK at layer #{desired_stack}", current_atk < previous_atk,
                 "before=#{previous_atk} after=#{current_atk} atk_rate=#{state.atk_rate}")
        end
        log("[BURN] stat stack=#{actual_stack} atk=#{current_atk.inspect} previous=#{previous_atk.inspect}")
        previous_atk = current_atk

        target.hp = target.maxhp if target.respond_to?(:hp=)
        before = target.hp.to_i
        p37_with_combat_rng("burn_state#{state.id}_stack#{desired_stack}") do
          scene.send(:hp_slip_damage, target)
        end
        actual_damage = before - target.hp.to_i
        per_stack_damage = (target.maxhp.to_f * per_stack_percent / 100.0).round
        per_stack_damage = 1 if per_stack_damage < 1 && per_stack_percent > 0
        expected_damage = per_stack_damage * desired_stack
        log("[BURN] state=#{state.id}:#{state.name} maxhp=#{target.maxhp} stack=#{actual_stack}/#{max_stack} " +
            "per_stack=#{per_stack_percent}% hp=#{before}->#{target.hp} damage=#{actual_damage} expected=#{expected_damage}")
        assert_equal("Burn residual damage exact at stack #{desired_stack}", expected_damage, actual_damage)
        assert("Burn state remains active at stack #{desired_stack}", target.state?(state.id) == true)
      end

      before_overflow = p38_state_stack(target, state)
      atk_before_overflow = target.respond_to?(:atk) ? target.atk.to_i : nil
      target.add_state(state.id)
      after_overflow = p38_state_stack(target, state)
      atk_after_overflow = target.respond_to?(:atk) ? target.atk.to_i : nil
      log("[BURN] overflow_guard state=#{state.id} before=#{before_overflow} after=#{after_overflow} max=#{max_stack} " +
          "atk=#{atk_before_overflow.inspect}->#{atk_after_overflow.inspect}")
      assert_equal("Burn stack capped at formal max", [before_overflow, max_stack].min, after_overflow)
      assert("Burn stack never exceeds formal max", after_overflow <= max_stack,
             "actual=#{after_overflow} max=#{max_stack}")
      if atk_before_overflow != nil && atk_after_overflow != nil
        assert_equal("Burn ATK penalty capped with max stack", atk_before_overflow, atk_after_overflow)
      end
      return true
    rescue Exception => e
      exception(e, "p38_fixture_burn_stack")
      assert("Burn stack residual fixture completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● Regen：State64 / -5% MaxHP；現行 Authority 不使用 slip variance = 50 heal
    #--------------------------------------------------------------------------
    def p37_fixture_regen(scene)
      target = p37_alive_enemy(1)
      assert("Residual regen target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if target == nil
      return false unless p37_prepare_enemy(target, 1000, 500)
      return false unless p41e_clear_hp_slip_states(target, "regen")
      state = $data_states[RESIDUAL_REGEN_STATE_ID] rescue nil
      assert("Regen State64 exists", state != nil,
             "state=#{RESIDUAL_REGEN_STATE_ID}")
      return false if state == nil
      target.add_state(RESIDUAL_REGEN_STATE_ID)
      return false unless p41e_assert_hp_slip_isolated(target, [RESIDUAL_REGEN_STATE_ID], "regen")
      before = target.hp
      p37_with_combat_rng("regen_state64") do
        scene.send(:hp_slip_damage, target)
      end
      actual = target.hp - before
      expected = 50
      log("[RESIDUAL] REGEN state=64 maxhp=1000 hp=#{before}->#{target.hp} heal=#{actual}")
      assert_equal("Regen residual heal exact", expected, actual)
      assert("Regen state remains active", target.state?(RESIDUAL_REGEN_STATE_ID) == true)
      return true
    rescue Exception => e
      exception(e, "p37_fixture_regen")
      assert("Regen residual fixture completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● Phase38B：MP Regen / MP Degen
    #    - 不硬編碼 State ID；掃描正式 State Note 的 <slip: mp, flat, percent%>。
    #    - Tankentai/Residual Authority 的符號規則：正值 = MP 損失，負值 = MP 回復。
    #    - MaxMP=1000、MP=500 做 nominal tick；再驗證 Regen 不超過 MaxMP、
    #      Degen 不低於 0。正式 KEEP_TANKENTAI_VARIANCE=false，因此結果應精確。
    #--------------------------------------------------------------------------
    def p38_mp_slip_signature(state)
      return nil if state == nil || !state.respond_to?(:note)
      text = state.note.to_s
      if text =~ /<\s*slip\s*:\s*mp\s*,\s*([-+]?\d+(?:\.\d+)?)\s*,\s*([-+]?\d+(?:\.\d+)?)\s*[%％]\s*>/i
        return {:flat=>$1.to_f, :percent=>$2.to_f}
      end
      return nil
    end

    def p38_find_mp_slip_state(mode)
      return nil if $data_states == nil
      for state in $data_states.compact
        sig = p38_mp_slip_signature(state)
        next if sig == nil
        probe = sig[:flat].to_f + 1000.0 * sig[:percent].to_f / 100.0
        return [state, sig] if mode == :regen && probe < 0.0
        return [state, sig] if mode == :degen && probe > 0.0
      end
      return nil
    end

    def p38_round_nonzero_local(value)
      n = value.round
      if n == 0 && value != 0.0
        n = value > 0 ? 1 : -1
      end
      return n
    end

    def p38_expected_mp_after(before_mp, maxmp, sig)
      damage = sig[:flat].to_f + maxmp.to_f * sig[:percent].to_f / 100.0
      damage = p38_round_nonzero_local(damage)
      after = before_mp.to_i - damage.to_i
      after = 0 if after < 0
      after = maxmp.to_i if after > maxmp.to_i
      return [after, damage]
    end

    # Phase38C：VX/RGSS2 的 Game_Battler 沒有 clear_states。
    # 只清除本 Fixture 關心的 MP slip State，並走正式 remove_state alias chain，
    # 讓 CSP stack / state origin / HUD touch 等清理仍照 Runtime 規則執行。
    def p38_active_mp_slip_states(target)
      return [] if target == nil || !target.respond_to?(:states)
      return target.states.compact.select { |state| p38_mp_slip_signature(state) != nil }
    rescue
      return []
    end

    def p38_clear_mp_slip_states(target)
      return false if target == nil
      before = p38_active_mp_slip_states(target).collect { |state| state.id.to_i }
      before.each do |state_id|
        target.remove_state(state_id) if target.respond_to?(:remove_state)
      end
      after = p38_active_mp_slip_states(target).collect { |state| state.id.to_i }
      log("[MP_RESIDUAL] isolate cleanup before=#{before.inspect} after=#{after.inspect}")
      assert("MP residual prior MP slip states cleared", after.empty?,
             "before=#{before.inspect} after=#{after.inspect}")
      return after.empty?
    rescue Exception => e
      exception(e, "p38_clear_mp_slip_states")
      assert("MP residual prior MP slip states cleared", false, e.message)
      return false
    end

    def p38_prepare_mp_target(target, maxmp, mp)
      return false if target == nil
      return false unless p38_clear_mp_slip_states(target)
      target.clear_action_results if target.respond_to?(:clear_action_results)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = target.maxhp if target.respond_to?(:hp=)
      target.maxmp = maxmp.to_i if target.respond_to?(:maxmp=)
      target.mp = mp.to_i if target.respond_to?(:mp=)
      return true
    rescue Exception => e
      exception(e, "p38_prepare_mp_target")
      return false
    end

    def p38_run_mp_case(scene, target, mode, entry)
      state = entry == nil ? nil : entry[0]
      sig = entry == nil ? nil : entry[1]
      label = mode == :regen ? "Regen" : "Degen"
      assert("MP #{label} formal State resolved", state != nil && sig != nil,
             entry == nil ? "nil" : "state=#{state.id}:#{state.name}")
      return false if state == nil || sig == nil

      assert("MP #{label} formal slip sign matches mode",
             mode == :regen ? sig[:percent].to_f < 0.0 : sig[:percent].to_f > 0.0,
             "state=#{state.id}:#{state.name} flat=#{sig[:flat]} percent=#{sig[:percent]}")

      return false unless p38_prepare_mp_target(target, 1000, 500)
      target.add_state(state.id)
      assert("MP #{label} state applied", target.state?(state.id) == true,
             "state=#{state.id}:#{state.name}")
      active_mp_states = p38_active_mp_slip_states(target).collect { |entry_state| entry_state.id.to_i }
      assert("MP #{label} fixture has isolated MP residual state",
             active_mp_states == [state.id.to_i],
             "expected=[#{state.id}] actual=#{active_mp_states.inspect}")
      log("[MP_RESIDUAL] isolate mode=#{mode} active_mp_states=#{active_mp_states.inspect}")

      before = target.mp.to_i
      expected_after, formal_damage = p38_expected_mp_after(before, target.maxmp, sig)
      p37_with_combat_rng("mp_#{mode}_state#{state.id}") do
        scene.send(:mp_slip_damage, target)
      end
      after = target.mp.to_i
      delta = after - before
      expected_delta = expected_after - before
      log("[MP_RESIDUAL] mode=#{mode} state=#{state.id}:#{state.name} maxmp=#{target.maxmp} " +
          "flat=#{sig[:flat]} percent=#{sig[:percent]} damage_sign=#{formal_damage} " +
          "mp=#{before}->#{after} delta=#{delta} expected_delta=#{expected_delta}")
      assert_equal("MP #{label} residual exact", expected_delta, delta)
      assert("MP #{label} state remains active", target.state?(state.id) == true)

      # Boundary clamp：回復不得超過 MaxMP；流失不得低於 0。
      boundary_before = mode == :regen ? target.maxmp.to_i - 10 : 10
      boundary_before = 0 if boundary_before < 0
      target.mp = boundary_before
      expected_boundary_after, boundary_damage = p38_expected_mp_after(boundary_before, target.maxmp, sig)
      p37_with_combat_rng("mp_#{mode}_clamp_state#{state.id}") do
        scene.send(:mp_slip_damage, target)
      end
      boundary_after = target.mp.to_i
      log("[MP_RESIDUAL] clamp mode=#{mode} state=#{state.id}:#{state.name} " +
          "damage_sign=#{boundary_damage} mp=#{boundary_before}->#{boundary_after} expected=#{expected_boundary_after}")
      assert_equal("MP #{label} boundary clamp exact", expected_boundary_after, boundary_after)
      return true
    rescue Exception => e
      exception(e, "p38_run_mp_case_#{mode}")
      assert("MP #{label} residual fixture completed", false, e.message)
      return false
    end

    def p38_fixture_mp_regen_degen(scene)
      target = p37_alive_enemy(1)
      assert("MP residual target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if target == nil

      regen = p38_find_mp_slip_state(:regen)
      degen = p38_find_mp_slip_state(:degen)
      assert("MP Regen/Degen formal states are distinct",
             regen != nil && degen != nil && regen[0].id.to_i != degen[0].id.to_i,
             "regen=#{regen == nil ? 'nil' : regen[0].id} degen=#{degen == nil ? 'nil' : degen[0].id}")
      if defined?(ALBERT_STATE_EFFECTS_V2)
        assert("MP residual Tankentai variance disabled",
               ALBERT_STATE_EFFECTS_V2::KEEP_TANKENTAI_VARIANCE == false,
               "KEEP_TANKENTAI_VARIANCE=#{ALBERT_STATE_EFFECTS_V2::KEEP_TANKENTAI_VARIANCE.inspect}")
      end

      ok_regen = p38_run_mp_case(scene, target, :regen, regen)
      ok_degen = p38_run_mp_case(scene, target, :degen, degen)
      return ok_regen && ok_degen
    rescue Exception => e
      exception(e, "p38_fixture_mp_regen_degen")
      assert("MP Regen/Degen residual fixture completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● Leech Seed：State35 MaxHP/8；來源者回復實際吸取量
    #--------------------------------------------------------------------------
    def p37_fixture_leech(scene)
      target = p37_alive_enemy(2)
      subject = p37_subject
      assert("Leech target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      assert("Leech origin exists", subject != nil,
             subject == nil ? "nil" : object_label(subject))
      return false if target == nil || subject == nil
      return false unless p37_prepare_enemy(target, 800, 800)
      return false unless p37_prepare_subject(subject)
      # State35 是 CLOSE-effect 寄生，不是一般 <slip: hp> State。
      # 先清掉舊寄生 ownership，再清除其他 HP-slip，避免 Burn/Poison 同 tick 污染。
      if target.respond_to?(:state?) && target.state?(RESIDUAL_LEECH_STATE_ID)
        target.remove_state(RESIDUAL_LEECH_STATE_ID) if target.respond_to?(:remove_state)
      end
      return false unless p41e_clear_hp_slip_states(target, "leech")
      state = $data_states[RESIDUAL_LEECH_STATE_ID] rescue nil
      assert("Leech State35 exists", state != nil,
             "state=#{RESIDUAL_LEECH_STATE_ID}")
      return false if state == nil
      target.add_state(RESIDUAL_LEECH_STATE_ID)
      leech_applied = target.respond_to?(:state?) && target.state?(RESIDUAL_LEECH_STATE_ID)
      assert("Leech close-effect State35 applied", leech_applied,
             "state=#{RESIDUAL_LEECH_STATE_ID} states=#{target.states.collect { |s| s.id }.inspect}")
      return false unless leech_applied
      # State35 自身不應出現在 numeric HP-slip helper；此處只要求沒有其他 HP-slip 殘留。
      return false unless p41e_assert_hp_slip_isolated(target, [], "leech")
      if target.respond_to?(:albert_sev28_record_state_origin)
        target.albert_sev28_record_state_origin(RESIDUAL_LEECH_STATE_ID, subject)
      end
      assert("Leech origin recorder exists",
             target.respond_to?(:albert_sev28_record_state_origin))
      target_before = target.hp
      subject_before = subject.hp
      scene.send(:hp_slip_damage, target)
      target_loss = target_before - target.hp
      subject_gain = subject.hp - subject_before
      expected_loss = 100
      missing = subject.maxhp.to_i - subject_before.to_i
      expected_gain = [expected_loss, missing].min
      log("[LEECH] state=35 target=#{object_label(target)} hp=#{target_before}->#{target.hp} loss=#{target_loss} " +
          "origin=#{object_label(subject)} hp=#{subject_before}->#{subject.hp} gain=#{subject_gain}")
      assert_equal("Leech Seed target loss exact", expected_loss, target_loss)
      assert_equal("Leech Seed origin heal exact", expected_gain, subject_gain)
      return true
    rescue Exception => e
      exception(e, "p37_fixture_leech")
      assert("Leech residual fixture completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● 一般 VX absorb_damage Drain：自動找現成技能
    #--------------------------------------------------------------------------
    def p37_find_general_drain_skill
      ids = [605, 633, 741, 313]
      for id in ids
        begin
          skill = $data_skills[id]
          return skill if skill != nil && skill.respond_to?(:absorb_damage) && skill.absorb_damage
        rescue
        end
      end
      return nil
    end

    #--------------------------------------------------------------------------
    # ● SoulMark Drain：依 SOUL_ARTS 找第一個 effects[:drain]
    #--------------------------------------------------------------------------
    def p37_find_soul_drain
      return [nil, nil] unless defined?(FS_SOULMARK_RESONANCE)
      return [nil, nil] unless FS_SOULMARK_RESONANCE.const_defined?("SOUL_ARTS")
      arts = FS_SOULMARK_RESONANCE::SOUL_ARTS
      for i in 0...arts.size
        art = arts[i]
        next if art == nil || !art.is_a?(Hash)
        effects = art[:effects]
        next unless effects.is_a?(Hash)
        percent = effects[:drain].to_i
        next if percent <= 0
        id = FS_SOULMARK_RESONANCE::SOUL_SKILL_START + i
        skill = $data_skills[id] rescue nil
        return [skill, percent] if skill != nil
      end
      return [nil, nil]
    end

    #--------------------------------------------------------------------------
    # ● Phase37A：Drain 不再直接呼叫 Game_Battler#skill_effect。
    #    追加到 Phase36 真實 Action Plan，確保 Scene_Battle 的 @active_battler、
    #    Counterattack、Skill Cost、SBS/ATB 等正式 context 全部存在。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37_core_build_fixture_plan_base)
      alias fs_phase37_core_build_fixture_plan_base core_build_fixture_plan
    end
    def core_build_fixture_plan
      plan = fs_phase37_core_build_fixture_plan_base
      return plan if plan == nil
      return plan if plan.any? { |f| f.is_a?(Hash) && f[:p37_drain_mode] }

      enemies = $game_troop.members.select { |e| e != nil && e.exist? }
      general = p37_find_general_drain_skill
      soul_data = p37_find_soul_drain
      soul_skill = soul_data[0]
      soul_percent = soul_data[1].to_i

      assert("General Drain skill exists", general != nil,
             general == nil ? "nil" : "#{general.id}:#{general.name}")
      assert("SoulMark Drain art exists", soul_skill != nil && soul_percent > 0,
             soul_skill == nil ? "nil" : "skill=#{soul_skill.id}:#{soul_skill.name} drain=#{soul_percent}%")

      if general != nil && !enemies.empty?
        t = enemies[3 % enemies.size]
        plan << {
          :name=>"GENERAL_DRAIN_SKILL#{general.id}", :kind=>:skill,
          :skill_id=>general.id, :boost_hp=>true,
          :p37_drain_mode=>:general,
          :target_index=>t.index, :target_oid=>t.object_id
        }
      end
      if soul_skill != nil && soul_percent > 0 && !enemies.empty?
        t = enemies[4 % enemies.size]
        plan << {
          :name=>"SOULMARK_DRAIN_SKILL#{soul_skill.id}", :kind=>:skill,
          :skill_id=>soul_skill.id, :boost_hp=>true,
          :p37_drain_mode=>:soulmark, :p37_drain_percent=>soul_percent,
          :target_index=>t.index, :target_oid=>t.object_id
        }
      end
      @core_fixture_plan = plan
      log("[FIXTURE] PHASE42C action-plan=#{plan.collect { |f| f[:name] }.inspect}")
      return plan
    end

    #--------------------------------------------------------------------------
    # ● Drain Action 前置：讓使用者缺血、目標保持高 HP，並記錄回血基準。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37_core_prepare_action_state_base)
      alias fs_phase37_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase37_core_prepare_action_state_base(fixture, subject, target)
      @p37_drain_user_hp_before = nil
      @p37_drain_user_maxhp = nil
      @p37_drain_percent = nil
      @p37_drain_item_id = nil
      @p37_drain_item_before = nil
      if fixture != nil && fixture[:p37_drain_mode]
        begin
          target.clear_states if target.respond_to?(:clear_states)
          target.maxhp = 9999 if target.respond_to?(:maxhp=)
          target.hp = target.maxhp if target.respond_to?(:hp=)
        rescue
        end
        begin
          subject.hp = 1 if subject.respond_to?(:hp=)
          @p37_drain_user_hp_before = subject.hp.to_i
          @p37_drain_user_maxhp = subject.maxhp.to_i
          @p37_drain_percent = fixture[:p37_drain_percent].to_i
        rescue
        end

        # Phase37C：SoulMark prerequisite 已在 Scene_Map Snapshot 後完成。
        # Battle 內只驗證，絕不 learn_skill、絕不補 Item、絕不換裝。
        if fixture[:p37_drain_mode] == :soulmark
          skill = $data_skills[fixture[:skill_id].to_i] rescue nil
          data = @p37_soul_prebattle
          assert("SoulMark prebattle fixture metadata exists", data != nil && data[:ready] == true,
                 data == nil ? "nil" : data.inspect)
          if skill != nil && data != nil
            @p37_drain_item_id = data[:fragment_id].to_i
            item = $data_items[@p37_drain_item_id] rescue nil
            armor = $data_armors[data[:armor_id]] rescue nil
            equipped = p37_equipped_item?(subject, armor)
            listed = subject.skills.any? { |entry| entry != nil && entry.id.to_i == skill.id.to_i }
            usable = subject.skill_can_use?(skill)
            @p37_drain_item_before = item == nil ? nil : $game_party.item_number(item)
            log("[PREBATTLE] VERIFY battle_action skill=#{skill.id}:#{skill.name} armor=#{data[:armor_id]} " +
                "equipped=#{equipped.inspect} listed=#{listed.inspect} raw_learned=#{p37_raw_skill_learned?(subject, skill.id).inspect}")

            # Phase37D：實機證據已證明 prerequisite 全部成立後，Skill253 仍未進
            # skill_effect。根因追到 CrimsonSeas Demo page 對 247～255 的舊 ID
            # base_action／extension 攔截。這裡直接驗證正式 Soul Art 已奪回 Authority。
            action_key = nil
            extensions = []
            begin
              action_key = skill.base_action
            rescue
              action_key = nil
            end
            begin
              extensions = skill.extension
              extensions = [] if extensions == nil
            rescue
              extensions = []
            end
            legacy_action_keys = ["TEST_ACTIVATION", "TEST_MIDDLE", "ACTIVATION_ACT", "BLANK"]
            legacy_action = legacy_action_keys.include?(action_key.to_s)
            legacy_random = (skill.scope.to_i == 1 && extensions.include?("RANDOMTARGET"))
            log("[ACTION_SEQ] SOULMARK skill=#{skill.id}:#{skill.name} base_action=#{action_key.inspect} " +
                "extension=#{extensions.inspect} legacy_action=#{legacy_action.inspect} legacy_random=#{legacy_random.inspect}")
            assert("SoulMark action sequence bypasses legacy Skill Activation demo mapping", legacy_action == false,
                   "skill=#{skill.id} base_action=#{action_key.inspect}")
            assert("SoulMark single-target extension bypasses legacy RANDOMTARGET demo mapping", legacy_random == false,
                   "skill=#{skill.id} extension=#{extensions.inspect}")

            log("[COST] SOULMARK skill=#{skill.id}:#{skill.name} item=#{@p37_drain_item_id}:#{item == nil ? 'nil' : item.name} " +
                "before=#{@p37_drain_item_before} skill_can_use=#{usable.inspect}")
            assert("SoulMark armor prerequisite remains equipped", equipped == true)
            assert("SoulMark skill remains formally equipment-provided",
                   listed == true && !p37_raw_skill_learned?(subject, skill.id))
            assert("SoulMark Drain skill usable at action time", usable == true,
                   "skill=#{skill.id} item=#{@p37_drain_item_id} count=#{@p37_drain_item_before}")
          end
        end

        log("[DRAIN] PREP mode=#{fixture[:p37_drain_mode]} user_hp=#{@p37_drain_user_hp_before}/#{@p37_drain_user_maxhp} target_hp=#{target.hp}/#{target.maxhp}")
      end
      return result
    end

    #--------------------------------------------------------------------------
    # ● Drain Action 後置 ASSERT：使用 Phase36 已累積的真實 @core_action_damage。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37_core_finalize_fixture_base)
      alias fs_phase37_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase37_core_finalize_fixture_base
      if fixture != nil && fixture[:p37_drain_mode]
        subject = core_current_subject
        before_hp = @p37_drain_user_hp_before.to_i
        maxhp = @p37_drain_user_maxhp.to_i
        gain = subject == nil ? 0 : subject.hp.to_i - before_hp
        damage = @core_action_damage.to_i
        missing = maxhp - before_hp
        missing = 0 if missing < 0
        expected = 0
        if fixture[:p37_drain_mode] == :general
          expected = [damage, missing].min
          log("[DRAIN] GENERAL action=#{fixture[:name]} target_damage=#{damage} user_hp=#{before_hp}->#{subject == nil ? 'nil' : subject.hp} gain=#{gain}")
          assert_equal("General Drain heals actual damage", expected, gain)
        else
          percent = @p37_drain_percent.to_i
          expected = [damage * percent / 100, missing].min
          log("[DRAIN] SOUL action=#{fixture[:name]} drain=#{percent}% target_damage=#{damage} user_hp=#{before_hp}->#{subject == nil ? 'nil' : subject.hp} gain=#{gain}")
          assert_equal("SoulMark Drain percentage heal", expected, gain)

          # 同時驗證正式 <usa oggetto:x> 成本只支付一次。
          item_id = @p37_drain_item_id.to_i
          if item_id > 0 && $data_items != nil && $game_party != nil
            item = $data_items[item_id] rescue nil
            if item != nil && @p37_drain_item_before != nil
              after_count = $game_party.item_number(item)
              expected_count = @p37_drain_item_before.to_i - 1
              expected_count = 0 if expected_count < 0
              log("[COST] SOULMARK item=#{item_id}:#{item.name} before=#{@p37_drain_item_before} after=#{after_count}")
              assert_equal("SoulMark Drain item cost paid exactly once", expected_count, after_count)
            end
          end
        end
      end
      return result
    end

    #--------------------------------------------------------------------------
    # ● Residual / Drain Suite
    #--------------------------------------------------------------------------
    def p37_run_residual_drain_suite(scene)
      return true if @p37_residual_suite_done
      @p37_residual_suite_done = true
      log("[FIXTURE] RESIDUAL-DRAIN suite start version=#{RESIDUAL_FIXTURE_VERSION}")
      p37_fixture_poison(scene)
      p38_fixture_burn_stack(scene)
      p37_fixture_regen(scene)
      p38_fixture_mp_regen_degen(scene)
      p37_fixture_leech(scene)
      assert("Residual Fixture suite completed", true, "count=6")
      log("[FIXTURE] RESIDUAL-DRAIN suite end")
      return true
    rescue Exception => e
      exception(e, "p37_run_residual_drain_suite")
      assert("Residual Fixture suite completed", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # ● Phase36 Core plan 完成時，先跑 Residual/Drain，再正式退出
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37_request_exit_base)
      alias fs_phase37_request_exit_base request_battle_smoke_exit
    end
    def request_battle_smoke_exit(scene, reason)
      if battle_active? && reason.to_s == "core_fixture_plan_complete" && !@p37_residual_suite_done
        p37_run_residual_drain_suite(scene)
      end
      fs_phase37_request_exit_base(scene, reason)
    end

    #--------------------------------------------------------------------------
    # ● 下一次 Ctrl+F9 / Snapshot restore 後重置 Suite 狀態
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase37_restore_pending_base)
      alias fs_phase37_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase37_restore_pending_base
      if result
        @p37_residual_suite_done = false
        @p37_soul_prebattle = nil
      end
      return result
    end
  end
end

#==============================================================================
# ■ Phase39A｜EquipmentCombo Opening / Summon State Ownership Fixture
#------------------------------------------------------------------------------
# TEST-only：不改正式 EquipmentCombo Runtime。Prerequisite 仍在 Scene_Map 透過
# change_equip 建立；「預先存在一個 summon state」只在正式 Battle Start 的 Combo
# prepare 前一瞬間注入，專門驗證 ownership 不會把既有 State 認成自己新增。
#==============================================================================
module FS_TEST_HARNESS
  @p39_combo_fixture = nil
  @p39_combo_gate_active = false
  @p39_combo_gate_updates = 0
  @p39_combo_opening_started = false
  @p39_combo_opening_completed = false
  @p39_combo_post_wait = 0

  class << self
    def p39_state_ids(actor)
      return [] if actor == nil || !actor.respond_to?(:states)
      return actor.states.compact.collect { |state| state.id.to_i }.uniq.sort
    rescue
      return []
    end

    def p39_owned_summon_state_ids(actor)
      return [] if actor == nil
      ids = actor.instance_variable_get(:@albert_combo_owned_summon_state_ids) rescue nil
      return [] unless ids.is_a?(Array)
      return ids.compact.collect { |id| id.to_i }.uniq.sort
    end

    # Scene_Map：SoulMark prerequisite 完成後，再正式裝備 matching resonance headgear。
    unless method_defined?(:fs_phase39a_prepare_battle_fixture_on_map_base)
      alias fs_phase39a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase39a_prepare_battle_fixture_on_map_base
      data = @p37_soul_prebattle
      assert("Combo prebattle metadata exists", data != nil && data[:ready] == true)
      return false if data == nil || data[:ready] != true

      owner = $game_actors[data[:actor_id]] rescue nil
      headgear = data[:headgear]
      armor = data[:armor]
      assert("Combo owner exists", owner != nil,
             owner == nil ? "nil" : object_label(owner))
      assert("Combo matching headgear exists", headgear != nil,
             "headgear_id=#{data[:headgear_id]}")
      return false if owner == nil || headgear == nil || armor == nil

      required = headgear.respond_to?(:albert_combo_required_armors) ?
                 headgear.albert_combo_required_armors : []
      states = headgear.respond_to?(:albert_combo_summon_state_ids) ?
               headgear.albert_combo_summon_state_ids.compact.collect { |id| id.to_i } : []
      opening_skill_id = headgear.respond_to?(:albert_combo_summon_opening_skill_id) ?
                         headgear.albert_combo_summon_opening_skill_id.to_i : 0
      opening_skill = $data_skills[opening_skill_id] rescue nil
      summon_actor_id = owner.respond_to?(:albert_combo_summon_actor_id_for) ?
                        owner.albert_combo_summon_actor_id_for(headgear).to_i : 0
      summon = $game_actors[summon_actor_id] rescue nil
      mapping_id = nil
      begin
        mapping_id = ArmorMapping.mapping[armor.id] if defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
      rescue
        mapping_id = nil
      end

      assert("Combo headgear formally requires equipped SoulMark armor",
             required.include?(armor.id.to_i),
             "headgear=#{headgear.id} required=#{required.inspect} armor=#{armor.id}")
      assert("Combo summon states resolved", states.size >= 2,
             "states=#{states.inspect}")
      assert("Combo opening skill resolved", opening_skill != nil,
             "skill_id=#{opening_skill_id}")
      assert("Combo summon actor resolved through formal mapping",
             summon_actor_id > 0 && summon != nil,
             "armor=#{armor.id} mapping=#{mapping_id.inspect} summon=#{summon_actor_id}")
      assert_equal("Combo summon actor matches ArmorMapping", mapping_id.to_i, summon_actor_id)
      return false if states.size < 2 || opening_skill == nil || summon == nil

      data[:original_headgear_count] = $game_party.item_number(headgear)
      data[:original_summon_states] = p39_state_ids(summon)
      slot = p37_find_armor_slot(owner, headgear)
      assert("Combo headgear legal equipment slot resolved", slot != nil,
             "kind=#{headgear.kind} actor_types=#{owner.equip_type.inspect}")
      return false if slot == nil

      already = p37_equipped_item?(owner, headgear)
      unless already
        $game_party.gain_item(headgear, 1) if $game_party.item_number(headgear) <= 0
        assert("Combo headgear available before equip",
               $game_party.item_number(headgear) > 0,
               "headgear=#{headgear.id} count=#{$game_party.item_number(headgear)}")
        owner.change_equip(slot, headgear, false)
      end
      equipped = p37_equipped_item?(owner, headgear)
      owner.albert_refresh_equipment_teaching_skills if owner.respond_to?(:albert_refresh_equipment_teaching_skills)
      owner.albert_refresh_equipment_passive_skills if owner.respond_to?(:albert_refresh_equipment_passive_skills)
      owner.albert_refresh_combo_actor_states if owner.respond_to?(:albert_refresh_combo_actor_states)
      active = owner.respond_to?(:albert_combo_effect_active?) ?
               owner.albert_combo_effect_active?(headgear) : false
      log("[COMBO_PREBATTLE] owner=#{owner.id}:#{owner.name} headgear=#{headgear.id}:#{headgear.name} " +
          "slot=#{slot} armor=#{armor.id}:#{armor.name} summon=#{summon_actor_id}:#{summon.name} " +
          "states=#{states.inspect} opening=#{opening_skill_id}:#{opening_skill.name}")
      assert("Combo headgear equipped through formal change_equip", equipped == true,
             "slot=#{slot} headgear=#{headgear.id}")
      assert("Combo effect active before battle transition", active == true,
             "headgear=#{headgear.id} armor=#{armor.id}")

      @p39_combo_fixture = {
        :owner_id=>owner.id.to_i, :headgear_id=>headgear.id.to_i,
        :armor_id=>armor.id.to_i, :summon_actor_id=>summon_actor_id,
        :summon_state_ids=>states.uniq.sort, :opening_skill_id=>opening_skill_id,
        :preexisting_state_id=>states[0].to_i,
        :expected_owned_state_ids=>states[1..-1].compact.collect { |id| id.to_i }.uniq.sort,
        :original_headgear_count=>data[:original_headgear_count],
        :original_summon_states=>data[:original_summon_states],
        :ready=>equipped && active
      }
      return @p39_combo_fixture[:ready] == true
    rescue Exception => e
      exception(e, "p39_prepare_combo_prebattle")
      assert("Combo prebattle fixture prepared", false, e.message)
      return false
    end

    # 正式 Combo FinalAuthority 前：建立 ownership 鑑別用「既有 State」。
    def p39_before_combo_prepare(scene)
      data = @p39_combo_fixture
      return true unless battle_active? && data != nil && data[:ready]
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      assert("Combo summon present before formal prepare",
             summon != nil && $game_party.members.include?(summon),
             summon == nil ? "nil" : object_label(summon))
      return false if summon == nil

      summon.albert_combo_clear_owned_summon_states if summon.respond_to?(:albert_combo_clear_owned_summon_states)
      data[:summon_state_ids].each do |state_id|
        summon.remove_state(state_id) if summon.state?(state_id)
      end
      pre_id = data[:preexisting_state_id].to_i
      summon.add_state(pre_id)
      data[:states_before_combo] = p39_state_ids(summon)
      data[:owned_before_combo] = p39_owned_summon_state_ids(summon)
      log("[COMBO_STATE] before_prepare summon=#{data[:summon_actor_id]} preexisting=#{pre_id} " +
          "active=#{data[:states_before_combo].inspect} owned=#{data[:owned_before_combo].inspect}")
      assert("Combo ownership seed state formally active before prepare",
             summon.state?(pre_id) == true,
             "state=#{pre_id}")
      assert("Combo ownership registry empty before formal prepare",
             data[:owned_before_combo].empty?,
             data[:owned_before_combo].inspect)
      return true
    rescue Exception => e
      exception(e, "p39_before_combo_prepare")
      return false
    end

    # 正式 Combo FinalAuthority 後：驗證 desired State 與 ownership 差集、Opening queue。
    def p39_after_combo_prepare(scene)
      data = @p39_combo_fixture
      return true unless battle_active? && data != nil && data[:ready]
      owner = $game_actors[data[:owner_id]] rescue nil
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      headgear = $data_armors[data[:headgear_id]] rescue nil
      opening = $data_skills[data[:opening_skill_id]] rescue nil
      return false if owner == nil || summon == nil || headgear == nil || opening == nil

      active_states = p39_state_ids(summon)
      owned = p39_owned_summon_state_ids(summon)
      expected_states = data[:summon_state_ids]
      expected_owned = data[:expected_owned_state_ids]
      action = summon.action
      queued = action != nil && action.skill? &&
               action.skill_id.to_i == data[:opening_skill_id].to_i && action.forcing == true
      forcing = scene.instance_variable_get(:@forcing_battlers) rescue []
      forcing = [] if forcing == nil
      locked = action.respond_to?(:fs_combo_opening_target) ? action.fs_combo_opening_target : nil
      locked_valid = false
      begin
        locked_valid = FS_COMBO_OPENING_TARGET.target_valid?(locked, summon, opening) if defined?(FS_COMBO_OPENING_TARGET)
      rescue
        locked_valid = false
      end
      opponent_side = locked != nil && !locked.actor?

      log("[COMBO_STATE] after_prepare summon=#{summon.id}:#{summon.name} desired=#{expected_states.inspect} " +
          "active=#{active_states.inspect} owned=#{owned.inspect} expected_owned=#{expected_owned.inspect}")
      log("[COMBO_OPENING] queued summon=#{summon.id}:#{summon.name} skill=#{opening.id}:#{opening.name} " +
          "forcing=#{queued.inspect} queue_include=#{forcing.include?(summon).inspect} " +
          "target=#{locked == nil ? 'nil' : object_label(locked)}")
      expected_states.each do |state_id|
        assert("Combo summon desired state active after formal prepare",
               summon.state?(state_id) == true,
               "state=#{state_id} summon=#{summon.id}")
      end
      assert_equal("Combo ownership includes only states newly added this battle",
                   expected_owned, owned)
      assert("Combo preexisting state is not claimed by ownership",
             !owned.include?(data[:preexisting_state_id].to_i),
             "preexisting=#{data[:preexisting_state_id]} owned=#{owned.inspect}")
      assert("Combo opening skill queued as forced action", queued == true,
             "skill=#{action == nil ? 'nil' : action.skill_id} forcing=#{action == nil ? 'nil' : action.forcing}")
      assert("Combo opening summon registered in forcing queue",
             forcing.include?(summon),
             "queue_size=#{forcing.size}")
      assert("Combo opening exact target locked and valid", locked_valid == true,
             locked == nil ? "nil" : object_label(locked))
      assert("Combo opponent opening locks opponent battler", opponent_side == true,
             locked == nil ? "nil" : object_label(locked))

      data[:locked_target_object_id] = locked == nil ? nil : locked.object_id
      @p39_combo_gate_active = true
      @p39_combo_gate_updates = 0
      @p39_combo_opening_started = false
      @p39_combo_opening_completed = false
      @p39_combo_post_wait = 0
      return true
    rescue Exception => e
      exception(e, "p39_after_combo_prepare")
      assert("Combo post-prepare verification completed", false, e.message)
      return false
    end

    def p39_combo_opening_match?(battler, skill)
      data = @p39_combo_fixture
      return false unless battle_active? && data != nil && data[:ready]
      return false if battler == nil || skill == nil
      return false unless battler.respond_to?(:actor?) && battler.actor?
      return battler.id.to_i == data[:summon_actor_id].to_i &&
             skill.id.to_i == data[:opening_skill_id].to_i
    rescue
      return false
    end

    def p39_opening_execute_start(scene, battler, skill)
      return unless p39_combo_opening_match?(battler, skill)
      data = @p39_combo_fixture
      action = battler.action
      locked = action.respond_to?(:fs_combo_opening_target) ? action.fs_combo_opening_target : nil
      @p39_combo_opening_started = true
      data[:opening_exec_target_object_id] = locked == nil ? nil : locked.object_id
      log("[COMBO_OPENING] EXECUTE START summon=#{battler.id}:#{battler.name} " +
          "skill=#{skill.id}:#{skill.name} target=#{locked == nil ? 'nil' : object_label(locked)}")
      assert("Combo opening execute uses originally locked battler",
             data[:locked_target_object_id] != nil &&
             data[:locked_target_object_id] == data[:opening_exec_target_object_id],
             "queued=#{data[:locked_target_object_id].inspect} exec=#{data[:opening_exec_target_object_id].inspect}")
    rescue Exception => e
      exception(e, "p39_opening_execute_start")
    end

    def p39_opening_execute_end(scene, battler, skill)
      return unless p39_combo_opening_match?(battler, skill)
      @p39_combo_opening_completed = true
      @p39_combo_post_wait = 2
      log("[COMBO_OPENING] EXECUTE END summon=#{battler.id}:#{battler.name} skill=#{skill.id}:#{skill.name}")
      assert("Combo opening entered Scene_Battle#execute_action_skill", true,
             "skill=#{skill.id}:#{skill.name}")
    rescue Exception => e
      exception(e, "p39_opening_execute_end")
    end

    # Opening 尚未執行完前，不讓 Core Fixture 在 frame2 再塞另一個 forced action。
    unless method_defined?(:fs_phase39a_on_battle_scene_update_base)
      alias fs_phase39a_on_battle_scene_update_base on_battle_scene_update
    end
    def on_battle_scene_update(scene)
      if battle_active? && @p39_combo_gate_active
        @p39_combo_gate_updates += 1
        if @p39_combo_opening_completed
          if @p39_combo_post_wait.to_i > 0
            @p39_combo_post_wait -= 1
            log("[COMBO_WAIT] opening settle remaining=#{@p39_combo_post_wait}")
            return
          end
          data = @p39_combo_fixture
          summon = data == nil ? nil : ($game_actors[data[:summon_actor_id]] rescue nil)
          owned = p39_owned_summon_state_ids(summon)
          active = p39_state_ids(summon)
          log("[COMBO_WAIT] opening complete release_core updates=#{@p39_combo_gate_updates} " +
              "active=#{active.inspect} owned=#{owned.inspect}")
          assert("Combo opening completed before Core Fixtures", @p39_combo_opening_started == true &&
                 @p39_combo_opening_completed == true)
          if data != nil && summon != nil
            assert_equal("Combo summon ownership stable after opening",
                         data[:expected_owned_state_ids], owned)
          end
          @p39_combo_gate_active = false
          return
        end
        if @p39_combo_gate_updates >= 240
          assert("Combo opening forced action timeout", false,
                 "updates=#{@p39_combo_gate_updates}")
          @p39_combo_gate_active = false
        else
          return
        end
      end
      fs_phase39a_on_battle_scene_update_base(scene)
    end

    # Snapshot restore：額外驗證 resonance headgear inventory 與 summon 原始 State。
    unless method_defined?(:fs_phase39a_after_snapshot_restore_base)
      alias fs_phase39a_after_snapshot_restore_base after_battle_snapshot_restore
    end
    def after_battle_snapshot_restore
      base = fs_phase39a_after_snapshot_restore_base
      data = @p39_combo_fixture
      return base if data == nil
      headgear = $data_armors[data[:headgear_id]] rescue nil
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      count = headgear == nil ? nil : $game_party.item_number(headgear)
      states = p39_state_ids(summon)
      log("[SNAPSHOT] COMBO restore headgear=#{data[:headgear_id]}:#{count} " +
          "summon=#{data[:summon_actor_id]} states=#{states.inspect}")
      assert_equal("Combo snapshot restores original headgear inventory",
                   data[:original_headgear_count], count)
      assert_equal("Combo snapshot restores original summon states",
                   data[:original_summon_states], states)
      return base
    end

    unless method_defined?(:fs_phase39a_restore_pending_base)
      alias fs_phase39a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase39a_restore_pending_base
      if result
        @p39_combo_fixture = nil
        @p39_combo_gate_active = false
        @p39_combo_gate_updates = 0
        @p39_combo_opening_started = false
        @p39_combo_opening_completed = false
        @p39_combo_post_wait = 0
      end
      return result
    end
  end
end

#==============================================================================
# ■ Phase39A TEST-only Scene_Battle wrappers
#==============================================================================
if (defined?($TEST) != nil && $TEST == true) && defined?(Scene_Battle)
  class Scene_Battle < Scene_Base
    # FinalAuthority prepare 的前後觀察點。正式 method 本體完全保留。
    if method_defined?(:albert_prepare_equipment_combo_battle_effects) &&
       !method_defined?(:fs_phase39a_combo_prepare_base)
      alias fs_phase39a_combo_prepare_base albert_prepare_equipment_combo_battle_effects
      def albert_prepare_equipment_combo_battle_effects
        FS_TEST_HARNESS.p39_before_combo_prepare(self)
        result = fs_phase39a_combo_prepare_base
        FS_TEST_HARNESS.p39_after_combo_prepare(self)
        return result
      end
    end

    unless method_defined?(:fs_phase39a_execute_action_skill_base)
      alias fs_phase39a_execute_action_skill_base execute_action_skill
    end
    def execute_action_skill(*args)
      battler = @active_battler
      skill = nil
      begin
        skill = battler.action.skill if battler != nil && battler.respond_to?(:action)
      rescue
        skill = nil
      end
      FS_TEST_HARNESS.p39_opening_execute_start(self, battler, skill)
      result = fs_phase39a_execute_action_skill_base(*args)
      FS_TEST_HARNESS.p39_opening_execute_end(self, battler, skill)
      return result
    end

    unless method_defined?(:fs_phase39a_terminate_base)
      alias fs_phase39a_terminate_base terminate
    end
    def terminate
      data = FS_TEST_HARNESS.instance_variable_get(:@p39_combo_fixture) rescue nil
      summon = data == nil ? nil : ($game_actors[data[:summon_actor_id]] rescue nil)
      before_owned = FS_TEST_HARNESS.p39_owned_summon_state_ids(summon)
      FS_TEST_HARNESS.log("[COMBO_STATE] terminate before owned=#{before_owned.inspect}") if data != nil
      result = fs_phase39a_terminate_base
      if data != nil && summon != nil
        after_owned = FS_TEST_HARNESS.p39_owned_summon_state_ids(summon)
        FS_TEST_HARNESS.log("[COMBO_STATE] terminate after owned=#{after_owned.inspect}")
        FS_TEST_HARNESS.assert("Combo owned summon state registry cleared on terminate",
                               after_owned.empty?, after_owned.inspect)
      end
      return result
    end
  end
end



#==============================================================================
# ■ Phase40A｜Friendly Summon Runtime Lifecycle Fixture
#------------------------------------------------------------------------------
# TEST-only：不修改 AlbertSummonTemporaryBattle 正式 Runtime，只在 prepare / terminate
# 前後插入觀察點。Fixture 在 Snapshot 後確保目標 summon 不在 Party，專門驗證
# 「本場新增 -> Battle 中存在 -> terminate 只移除本場新增者 -> runtime registry 清空」。
#==============================================================================
module FS_TEST_HARNESS
  @p40_summon_lifecycle = nil

  class << self
    def p40_party_ids
      list = []
      begin
        list = AlbertSummonTemporaryBattle.all_party_members if defined?(AlbertSummonTemporaryBattle)
      rescue
        list = []
      end
      if list == nil || list.empty?
        begin
          list = $game_party.respond_to?(:all_members) ? $game_party.all_members : $game_party.members
        rescue
          list = []
        end
      end
      return list.compact.collect { |actor| actor.id.to_i }
    rescue
      return []
    end

    def p40_battle_party_ids
      return [] if $game_party == nil
      return $game_party.members.compact.collect { |actor| actor.id.to_i }
    rescue
      return []
    end

    def p40_raw_skill_ids(actor)
      return [] if actor == nil
      value = actor.instance_variable_get(:@skills) rescue nil
      return [] unless value.is_a?(Array)
      return value.compact.collect { |id| id.to_i }.sort
    rescue
      return []
    end

    def p40_runtime_array(name)
      return [] unless defined?(AlbertSummonTemporaryBattle)
      value = AlbertSummonTemporaryBattle.instance_variable_get(name) rescue nil
      return [] unless value.is_a?(Array)
      return value.clone
    rescue
      return []
    end

    def p40_runtime_active?
      return false unless defined?(AlbertSummonTemporaryBattle)
      return AlbertSummonTemporaryBattle.instance_variable_get(:@active) == true
    rescue
      return false
    end

    # Phase39A prerequisite 完成後，建立 Summon lifecycle 的 Map-side baseline。
    unless method_defined?(:fs_phase40a_prepare_battle_fixture_on_map_base)
      alias fs_phase40a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase40a_prepare_battle_fixture_on_map_base
      combo = @p39_combo_fixture
      assert("Summon lifecycle Combo metadata exists", combo != nil && combo[:ready] == true)
      return false if combo == nil || combo[:ready] != true
      summon = $game_actors[combo[:summon_actor_id]] rescue nil
      assert("Summon lifecycle actor exists", summon != nil,
             "actor_id=#{combo[:summon_actor_id]}")
      return false if summon == nil || !defined?(AlbertSummonTemporaryBattle)

      pre_fixture_party = p40_party_ids
      original_switch = nil
      begin
        original_switch = $game_switches[AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH]
      rescue
        original_switch = nil
      end
      original_battle_count = $game_party.respond_to?(:battle_member_count) ? $game_party.battle_member_count : nil
      original_max_count = $game_party.respond_to?(:max_battle_member_count) ? $game_party.max_battle_member_count : nil

      # 測試「本場新增 summon」路徑；若目前存檔碰巧把 summon 留在 Party，Snapshot 會在測試後完整還原。
      if p40_party_ids.include?(summon.id.to_i)
        $game_party.remove_actor(summon.id.to_i)
        log("[SUMMON_LIFECYCLE] fixture_remove_preexisting actor=#{summon.id}:#{summon.name}")
      end
      absent = !p40_party_ids.include?(summon.id.to_i)
      assert("Summon lifecycle fixture starts with summon outside Party", absent,
             "party=#{p40_party_ids.inspect}")

      @p40_summon_lifecycle = {
        :summon_actor_id=>summon.id.to_i,
        :armor_id=>combo[:armor_id].to_i,
        :pre_fixture_party_ids=>pre_fixture_party,
        :fixture_party_ids=>p40_party_ids,
        :original_switch=>original_switch,
        :original_battle_member_count=>original_battle_count,
        :original_max_battle_member_count=>original_max_count,
        :object_id=>summon.object_id,
        :level=>summon.level.to_i,
        :exp=>summon.exp.to_i,
        :class_id=>summon.class_id.to_i,
        :raw_skills=>p40_raw_skill_ids(summon),
        :hp=>summon.hp.to_i,
        :mp=>summon.mp.to_i,
        :states=>p39_state_ids(summon),
        :ready=>absent
      }
      log("[SUMMON_LIFECYCLE] map_ready summon=#{summon.id}:#{summon.name} armor=#{combo[:armor_id]} " +
          "party_before=#{pre_fixture_party.inspect} party_fixture=#{p40_party_ids.inspect} " +
          "level=#{summon.level} exp=#{summon.exp} hp=#{summon.hp}/#{summon.maxhp} mp=#{summon.mp}/#{summon.maxmp}")
      return absent
    rescue Exception => e
      exception(e, "p40_prepare_summon_lifecycle")
      assert("Summon lifecycle prebattle fixture prepared", false, e.message)
      return false
    end

    def p40_before_summon_prepare
      data = @p40_summon_lifecycle
      return true unless battle_active? && data != nil && data[:ready]
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      active = p40_runtime_active?
      added = p40_runtime_array(:@added_summon_ids)
      log("[SUMMON_LIFECYCLE] prepare_before scene=#{$scene.class} active=#{active.inspect} " +
          "party=#{p40_party_ids.inspect} added=#{added.inspect}")
      assert("Summon Runtime prepare begins on Scene_Map", $scene.is_a?(Scene_Map), $scene.class.to_s)
      assert("Summon Runtime clean before prepare", active == false && added.empty?,
             "active=#{active.inspect} added=#{added.inspect}")
      assert("Summon absent immediately before formal prepare",
             summon != nil && !p40_party_ids.include?(summon.id.to_i),
             "party=#{p40_party_ids.inspect}")
      return true
    rescue Exception => e
      exception(e, "p40_before_summon_prepare")
      return false
    end

    def p40_after_summon_prepare
      data = @p40_summon_lifecycle
      return true unless battle_active? && data != nil && data[:ready]
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      entries = p40_runtime_array(:@summon_entries)
      added = p40_runtime_array(:@added_summon_ids).collect { |id| id.to_i }
      standby = p40_runtime_array(:@standby_ids).collect { |id| id.to_i }
      original_party = p40_runtime_array(:@original_party_ids).collect { |id| id.to_i }
      active = p40_runtime_active?
      switch_value = $game_switches[AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH]
      all_ids = p40_party_ids
      battle_ids = p40_battle_party_ids
      entry_match = entries.any? { |entry| entry != nil && entry[0].to_i == data[:armor_id].to_i && entry[1].to_i == data[:summon_actor_id].to_i }
      full_recover = AlbertSummonTemporaryBattle::FULL_RECOVER_ON_BATTLE_START == true

      data[:standby_ids] = standby
      data[:runtime_original_party_ids] = original_party
      data[:runtime_original_battle_member_count] = AlbertSummonTemporaryBattle.instance_variable_get(:@original_battle_member_count) rescue nil
      data[:runtime_original_max_battle_member_count] = AlbertSummonTemporaryBattle.instance_variable_get(:@original_max_battle_member_count) rescue nil

      log("[SUMMON_LIFECYCLE] prepare_after active=#{active.inspect} entries=#{entries.inspect} added=#{added.inspect} " +
          "standby=#{standby.inspect} original_party=#{original_party.inspect} all_party=#{all_ids.inspect} " +
          "battle_party=#{battle_ids.inspect} switch=#{switch_value.inspect}")
      assert("Summon Runtime active after prepare", active == true)
      assert("Summon Runtime collected equipped ArmorMapping entry", entry_match,
             "entries=#{entries.inspect}")
      assert("Summon Runtime owns newly added summon", added.include?(data[:summon_actor_id].to_i),
             "added=#{added.inspect}")
      assert("Summon Runtime original Party excludes fixture summon",
             !original_party.include?(data[:summon_actor_id].to_i),
             "original_party=#{original_party.inspect}")
      assert("Summon actor added to full Party", all_ids.include?(data[:summon_actor_id].to_i),
             "party=#{all_ids.inspect}")
      assert("Summon actor visible in battle members", battle_ids.include?(data[:summon_actor_id].to_i),
             "battle_party=#{battle_ids.inspect}")
      assert("Summon battle switch enabled", switch_value == true,
             "switch=#{AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH} value=#{switch_value.inspect}")
      assert("Summon Runtime preserves actor object identity",
             summon != nil && summon.object_id == data[:object_id],
             "expected=#{data[:object_id]} actual=#{summon == nil ? 'nil' : summon.object_id}")
      if summon != nil
        assert("Summon Runtime preserves progression without setup reset",
               summon.level.to_i == data[:level].to_i && summon.exp.to_i == data[:exp].to_i &&
               summon.class_id.to_i == data[:class_id].to_i && p40_raw_skill_ids(summon) == data[:raw_skills],
               "level=#{data[:level]}->#{summon.level} exp=#{data[:exp]}->#{summon.exp} " +
               "class=#{data[:class_id]}->#{summon.class_id} skills=#{data[:raw_skills].inspect}->#{p40_raw_skill_ids(summon).inspect}")
        if full_recover
          assert("Summon FULL_RECOVER policy applied", summon.hp == summon.maxhp && summon.mp == summon.maxmp,
                 "hp=#{summon.hp}/#{summon.maxhp} mp=#{summon.mp}/#{summon.maxmp}")
        else
          assert("Summon persistent HP/MP policy preserved",
                 summon.hp.to_i == data[:hp].to_i && summon.mp.to_i == data[:mp].to_i,
                 "hp=#{data[:hp]}->#{summon.hp} mp=#{data[:mp]}->#{summon.mp}")
        end
      end
      return true
    rescue Exception => e
      exception(e, "p40_after_summon_prepare")
      assert("Summon Runtime post-prepare verification completed", false, e.message)
      return false
    end

    def p40_before_summon_cleanup
      data = @p40_summon_lifecycle
      return true unless data != nil && data[:ready]
      added = p40_runtime_array(:@added_summon_ids).collect { |id| id.to_i }
      switch_value = $game_switches[AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH] rescue nil
      log("[SUMMON_LIFECYCLE] cleanup_before active=#{p40_runtime_active?.inspect} " +
          "party=#{p40_party_ids.inspect} added=#{added.inspect} switch=#{switch_value.inspect}")
      assert("Summon Runtime still active before terminate cleanup", p40_runtime_active? == true)
      assert("Summon still present before terminate cleanup",
             p40_party_ids.include?(data[:summon_actor_id].to_i), p40_party_ids.inspect)
      assert("Summon ownership still registered before cleanup",
             added.include?(data[:summon_actor_id].to_i), added.inspect)
      return true
    rescue Exception => e
      exception(e, "p40_before_summon_cleanup")
      return false
    end

    def p40_after_summon_cleanup
      data = @p40_summon_lifecycle
      return true unless data != nil && data[:ready]
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      active = p40_runtime_active?
      entries = p40_runtime_array(:@summon_entries)
      added = p40_runtime_array(:@added_summon_ids)
      standby_runtime = p40_runtime_array(:@standby_ids)
      switch_value = $game_switches[AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH] rescue nil
      all_ids = p40_party_ids
      restored_standby = (data[:standby_ids] || []).all? { |id| all_ids.include?(id.to_i) }
      battle_count = $game_party.respond_to?(:battle_member_count) ? $game_party.battle_member_count : nil
      max_count = $game_party.respond_to?(:max_battle_member_count) ? $game_party.max_battle_member_count : nil
      expected_battle_count = data[:runtime_original_battle_member_count]
      expected_max_count = data[:runtime_original_max_battle_member_count]

      log("[SUMMON_LIFECYCLE] cleanup_after active=#{active.inspect} party=#{all_ids.inspect} " +
          "entries=#{entries.inspect} added=#{added.inspect} standby_runtime=#{standby_runtime.inspect} " +
          "switch=#{switch_value.inspect} battle_count=#{battle_count.inspect} max=#{max_count.inspect}")
      assert("Summon Runtime inactive after cleanup", active == false)
      assert("Summon Runtime registries cleared after cleanup",
             entries.empty? && added.empty? && standby_runtime.empty?,
             "entries=#{entries.inspect} added=#{added.inspect} standby=#{standby_runtime.inspect}")
      assert("Temporary summon removed after cleanup",
             !all_ids.include?(data[:summon_actor_id].to_i), all_ids.inspect)
      assert("Summon battle switch disabled after cleanup", switch_value == false,
             "value=#{switch_value.inspect}")
      assert("Standby members restored after Summon cleanup", restored_standby,
             "standby=#{data[:standby_ids].inspect} party=#{all_ids.inspect}")
      if expected_battle_count != nil && battle_count != nil
        assert_equal("Summon cleanup restores battle_member_count", expected_battle_count, battle_count)
      end
      if expected_max_count != nil && max_count != nil
        assert_equal("Summon cleanup restores max_battle_member_count", expected_max_count, max_count)
      end
      if summon != nil
        assert("Summon actor identity/progression survives Party removal",
               summon.object_id == data[:object_id] && summon.level.to_i == data[:level].to_i &&
               summon.exp.to_i == data[:exp].to_i && summon.class_id.to_i == data[:class_id].to_i,
               "object=#{data[:object_id]}->#{summon.object_id} level=#{data[:level]}->#{summon.level} " +
               "exp=#{data[:exp]}->#{summon.exp}")
      end
      return true
    rescue Exception => e
      exception(e, "p40_after_summon_cleanup")
      assert("Summon Runtime cleanup verification completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase40a_after_snapshot_restore_base)
      alias fs_phase40a_after_snapshot_restore_base after_battle_snapshot_restore
    end
    def after_battle_snapshot_restore
      base = fs_phase40a_after_snapshot_restore_base
      data = @p40_summon_lifecycle
      return base if data == nil
      party_ids = p40_party_ids
      switch_value = nil
      begin
        switch_value = $game_switches[AlbertSummonTemporaryBattle::SUMMON_BATTLE_SWITCH]
      rescue
        switch_value = nil
      end
      summon = $game_actors[data[:summon_actor_id]] rescue nil
      log("[SNAPSHOT] SUMMON restore party=#{party_ids.inspect} expected=#{data[:pre_fixture_party_ids].inspect} " +
          "switch=#{switch_value.inspect} runtime_active=#{p40_runtime_active?.inspect}")
      assert_equal("Summon snapshot restores original Party membership",
                   data[:pre_fixture_party_ids], party_ids)
      assert_equal("Summon snapshot restores original battle switch",
                   data[:original_switch], switch_value)
      assert("Summon Runtime remains cleared after Snapshot restore",
             p40_runtime_active? == false && p40_runtime_array(:@summon_entries).empty? &&
             p40_runtime_array(:@added_summon_ids).empty?)
      if summon != nil
        assert("Summon snapshot restores actor progression baseline",
               summon.level.to_i == data[:level].to_i && summon.exp.to_i == data[:exp].to_i &&
               summon.class_id.to_i == data[:class_id].to_i && p40_raw_skill_ids(summon) == data[:raw_skills],
               "level=#{data[:level]}->#{summon.level} exp=#{data[:exp]}->#{summon.exp}")
      end
      return base
    end

    unless method_defined?(:fs_phase40a_restore_pending_base)
      alias fs_phase40a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase40a_restore_pending_base
      @p40_summon_lifecycle = nil if result
      return result
    end
  end
end

#==============================================================================
# ■ Phase40A TEST-only AlbertSummonTemporaryBattle / Scene_Battle wrappers
#==============================================================================
if (defined?($TEST) != nil && $TEST == true) && defined?(AlbertSummonTemporaryBattle)
  module AlbertSummonTemporaryBattle
    class << self
      unless method_defined?(:fs_phase40a_prepare_base)
        alias fs_phase40a_prepare_base prepare
      end
      def prepare
        FS_TEST_HARNESS.p40_before_summon_prepare
        result = fs_phase40a_prepare_base
        FS_TEST_HARNESS.p40_after_summon_prepare
        return result
      end
    end
  end
end

if (defined?($TEST) != nil && $TEST == true) && defined?(Scene_Battle)
  class Scene_Battle < Scene_Base
    unless method_defined?(:fs_phase40a_terminate_base)
      alias fs_phase40a_terminate_base terminate
    end
    def terminate
      FS_TEST_HARNESS.p40_before_summon_cleanup
      result = fs_phase40a_terminate_base
      FS_TEST_HARNESS.p40_after_summon_cleanup
      return result
    end
  end
end


#==============================================================================
# ■ Phase40B｜EnemySummon Runtime Lifecycle Fixture
#------------------------------------------------------------------------------
# TEST-only：不修改 EnemySummon_Core / Final Guard。測試順序刻意放在 Phase39A
# EquipmentCombo opening 完成之後、Phase36 Core Fixtures 開始之前，避免 forced action
# 互撞。正式 EnemySummon 的 Battle-local Enemy member 由 $game_troop 擁有；Sprite 由
# Spriteset_Battle dispose；Battle 後 Harness Snapshot 還原 $game_troop。
#==============================================================================
module FS_TEST_HARNESS
  @p40b_enemy_fixture = nil
  @p40b_enemy_gate_active = false
  @p40b_enemy_gate_updates = 0
  @p40b_enemy_attack_started = false
  @p40b_enemy_attack_completed = false
  @p40b_enemy_post_wait = 0

  class << self
    def p40b_troop_members
      return [] if $game_troop == nil
      list = $game_troop.members rescue []
      return (list || []).compact
    end

    def p40b_enemy_signature(enemy)
      return nil if enemy == nil
      return [enemy.enemy_id.to_i, enemy.index.to_i, enemy.screen_x.to_i,
              enemy.screen_y.to_i, enemy.object_id]
    rescue
      return nil
    end

    def p40b_enemy_sprite_list(scene)
      return [] if scene == nil
      spriteset = scene.instance_variable_get(:@spriteset) rescue nil
      return [] if spriteset == nil
      list = spriteset.instance_variable_get(:@enemy_sprites) rescue nil
      return (list || []).compact
    rescue
      return []
    end

    def p40b_sprite_disposed?(sprite)
      return true if sprite == nil
      return sprite.disposed? if sprite.respond_to?(:disposed?)
      return false
    rescue
      return true
    end

    def p40b_find_probe_skill
      return nil if $data_skills == nil
      $data_skills.compact.each do |skill|
        next if skill == nil || skill.id.to_i <= 0
        next unless skill.respond_to?(:note) && skill.respond_to?(:note=)
        next if defined?(FS_ENEMY_SUMMON_GUARD) &&
                FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(skill)
        # parser probe 需要 hit=100，避免 ma_call_ally 的命中 roll 產生不必要隨機 FAIL。
        next if skill.respond_to?(:hit) && skill.hit.to_i < 100
        return skill
      end
      return nil
    rescue
      return nil
    end

    #--------------------------------------------------------------------------
    # ● Final Guard / Notetag parser：只暫時改 Note，ensure 立即還原
    #--------------------------------------------------------------------------
    def p40b_probe_enemy_summon_guard(enemy_id)
      unless defined?(FS_ENEMY_SUMMON_GUARD)
        assert("EnemySummon Final Guard module exists", false, "FS_ENEMY_SUMMON_GUARD missing")
        return nil
      end
      skill = p40b_find_probe_skill
      actor = p37_subject
      assert("EnemySummon guard probe skill resolved", skill != nil,
             skill == nil ? "nil" : "skill=#{skill.id}:#{skill.name}")
      assert("EnemySummon Actor guard subject exists", actor != nil,
             actor == nil ? "nil" : object_label(actor))
      return nil if skill == nil || actor == nil

      original_note = skill.note.to_s.dup
      tag = "\\SUMMON_ENEMY[#{enemy_id.to_i},0,0,1]"
      begin
        skill.note = original_note + "\n" + tag
        tagged = FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(skill)
        call_flag = skill.ma_call_ally? rescue false
        parsed = skill.ma_call_ally rescue nil
        actor_can_use = actor.skill_can_use?(skill) rescue nil
        direct_actor_call = $game_troop.ma_call_ally(actor, enemy_id.to_i, 0, 0) rescue :exception
        stripped_inside = FS_ENEMY_SUMMON_GUARD.without_enemy_summon_tag(skill) do
          !FS_ENEMY_SUMMON_GUARD.enemy_summon_skill?(skill)
        end

        log("[ENEMY_SUMMON_GUARD] probe skill=#{skill.id}:#{skill.name} tag=#{tag.inspect} " +
            "parser=#{parsed.inspect} actor_can_use=#{actor_can_use.inspect} direct_actor=#{direct_actor_call.inspect}")
        assert("EnemySummon strict parser recognizes temporary formal tag", tagged == true && call_flag == true,
               "tagged=#{tagged.inspect} ma_call_ally?=#{call_flag.inspect}")
        parsed_ok = parsed.is_a?(Array) && parsed[0].to_i == enemy_id.to_i &&
                    parsed[1].to_i == 0 && parsed[2].to_i == 0
        assert("EnemySummon strict parser resolves requested Enemy and offsets", parsed_ok,
               "expected=[#{enemy_id},0,0] actual=#{parsed.inspect}")
        assert("EnemySummon Game_Actor skill_can_use Final Guard blocks tagged skill",
               actor_can_use == false, "actor_can_use=#{actor_can_use.inspect}")
        assert("EnemySummon Game_Troop Final Guard rejects Actor user",
               direct_actor_call == nil, "result=#{direct_actor_call.inspect}")
        assert("EnemySummon forced-action tag stripping helper removes tag inside guard",
               stripped_inside == true)
      ensure
        skill.note = original_note
      end
      restored = (skill.note.to_s == original_note)
      assert("EnemySummon guard probe restores Skill Note byte-for-byte", restored,
             "skill=#{skill.id}")
      return {:skill_id=>skill.id.to_i, :original_note=>original_note}
    rescue Exception => e
      exception(e, "p40b_probe_enemy_summon_guard")
      assert("EnemySummon Final Guard probe completed", false, e.message)
      begin
        skill.note = original_note if skill != nil && original_note != nil
      rescue
      end
      return nil
    end

    #--------------------------------------------------------------------------
    # ● 建立一個正式 EnemySummon，建立 Sprite，並排入一次真正 Enemy 普攻
    #--------------------------------------------------------------------------
    def p40b_begin_enemy_lifecycle(scene)
      return true if @p40b_enemy_fixture != nil && @p40b_enemy_fixture[:started]
      @p40b_enemy_fixture = {:started=>true, :ready=>false, :done=>false}
      members = p40b_troop_members
      source = members.find do |enemy|
        begin
          enemy.is_a?(Game_Enemy) && enemy.exist? && !enemy.dead?
        rescue
          false
        end
      end
      assert("EnemySummon lifecycle source Enemy exists", source != nil,
             "members=#{members.collect { |e| e.enemy_id rescue nil }.inspect}")
      return false if source == nil
      enemy_id = source.enemy_id.to_i
      enemy_data = $data_enemies[enemy_id] rescue nil
      assert("EnemySummon lifecycle target Enemy data exists", enemy_data != nil,
             "enemy_id=#{enemy_id}")
      return false if enemy_data == nil
      assert("EnemySummon lifecycle below formal troop cap",
             members.size < MAES_MAX_TROOP_SIZE,
             "size=#{members.size} max=#{MAES_MAX_TROOP_SIZE}")

      probe = p40b_probe_enemy_summon_guard(enemy_id)
      before_count = members.size
      before_positions = members.collect { |e| [e.screen_x.to_i, e.screen_y.to_i] rescue nil }.compact
      before_same = members.select { |e| (e.enemy_id.to_i rescue -1) == enemy_id }.size
      source_summon_count = source.ma_summon_count.to_i rescue 0
      sprite_before = p40b_enemy_sprite_list(scene).size

      log("[ENEMY_SUMMON] create_before source=#{object_label(source)} enemy_id=#{enemy_id}:#{enemy_data.name} " +
          "troop=#{before_count} same=#{before_same} pos=[#{source.screen_x},#{source.screen_y}] " +
          "summon_count=#{source_summon_count} sprites=#{sprite_before}")
      summoned = $game_troop.ma_call_ally(source, enemy_id, 0, 0)
      after_members = p40b_troop_members
      assert("EnemySummon formal ma_call_ally returns Game_Enemy",
             summoned != nil && summoned.is_a?(Game_Enemy),
             summoned == nil ? "nil" : summoned.class.to_s)
      return false if summoned == nil
      after_same = after_members.select { |e| (e.enemy_id.to_i rescue -1) == enemy_id }.size
      unique_position = !before_positions.include?([summoned.screen_x.to_i, summoned.screen_y.to_i])
      name_unique = (summoned.plural == true && !summoned.letter.to_s.empty?) rescue false
      log("[ENEMY_SUMMON] create_after summon=#{object_label(summoned)} signature=#{p40b_enemy_signature(summoned).inspect} " +
          "troop=#{after_members.size} same=#{after_same} letter=#{summoned.letter.inspect} plural=#{summoned.plural.inspect}")
      assert_equal("EnemySummon troop member count increments exactly once", before_count + 1, after_members.size)
      assert("EnemySummon new instance registered in Game_Troop members",
             after_members.any? { |e| e.object_id == summoned.object_id },
             "oid=#{summoned.object_id}")
      assert_equal("EnemySummon new instance uses requested Enemy ID", enemy_id, summoned.enemy_id.to_i)
      assert_equal("EnemySummon new instance index is appended position", before_count, summoned.index.to_i)
      assert("EnemySummon SafePosition avoids all pre-existing occupied coordinates", unique_position,
             "new=[#{summoned.screen_x},#{summoned.screen_y}] before=#{before_positions.inspect}")
      assert("EnemySummon make_unique_names assigns duplicate identity", name_unique,
             "letter=#{summoned.letter.inspect} plural=#{summoned.plural.inspect} same=#{after_same}")
      assert("EnemySummon source summon counter advances",
             source.ma_summon_count.to_i > source_summon_count,
             "before=#{source_summon_count} after=#{source.ma_summon_count}")

      spriteset = scene.instance_variable_get(:@spriteset) rescue nil
      assert("EnemySummon battle Spriteset exists", spriteset != nil)
      return false if spriteset == nil
      spriteset.ma_call_enemy(summoned)
      sprites = p40b_enemy_sprite_list(scene)
      sprite = sprites.find { |sp| sp.respond_to?(:battler) && sp.battler.equal?(summoned) }
      log("[ENEMY_SUMMON_SPRITE] before=#{sprite_before} after=#{sprites.size} " +
          "sprite=#{sprite == nil ? 'nil' : sprite.object_id} disposed=#{p40b_sprite_disposed?(sprite)}")
      assert_equal("EnemySummon Spriteset adds exactly one Sprite_Battler", sprite_before + 1, sprites.size)
      assert("EnemySummon Sprite_Battler binds summoned Game_Enemy", sprite != nil,
             "summon_oid=#{summoned.object_id}")
      assert("EnemySummon Sprite_Battler alive before terminate", !p40b_sprite_disposed?(sprite),
             "sprite=#{sprite == nil ? 'nil' : sprite.object_id}")

      target = nil
      begin
        target = $game_party.battle_members.find { |a| a != nil && a.id.to_i == 1 }
        target = $game_party.battle_members.first if target == nil
      rescue
        target = nil
      end
      assert("EnemySummon summoned Enemy action target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if target == nil
      target.hp = target.maxhp if target.respond_to?(:hp=)
      action_ok = defined?(FS_FORCE_ACTION_BRIDGE) &&
                  FS_FORCE_ACTION_BRIDGE.setup_action(summoned, 0, 0, target.index.to_i)
      assert("EnemySummon summoned Enemy forced attack action setup", action_ok == true,
             "summon=#{object_label(summoned)} target=#{object_label(target)}")
      return false unless action_ok
      $game_troop.fs_force_action_queue ||= []
      $game_troop.fs_force_action_queue << summoned
      queue_has = $game_troop.fs_force_action_queue.any? { |b| b.object_id == summoned.object_id }
      assert("EnemySummon summoned Enemy registered in force action queue", queue_has,
             "queue=#{($game_troop.fs_force_action_queue || []).size}")

      @p40b_enemy_fixture.merge!({
        :ready=>true,
        :source_oid=>source.object_id,
        :enemy_id=>enemy_id,
        :summoned_oid=>summoned.object_id,
        :summoned_index=>summoned.index.to_i,
        :summoned_signature=>p40b_enemy_signature(summoned),
        :sprite=>sprite,
        :sprite_oid=>(sprite == nil ? nil : sprite.object_id),
        :target_oid=>target.object_id,
        :target_hp_before=>target.hp.to_i,
        :probe_skill_id=>(probe == nil ? nil : probe[:skill_id]),
        :probe_original_note=>(probe == nil ? nil : probe[:original_note]),
        :battle_troop_count_before=>before_count,
        :battle_enemy_ids_before=>members.collect { |e| e.enemy_id.to_i },
        :done=>false
      })
      @p40b_enemy_gate_active = true
      @p40b_enemy_gate_updates = 0
      @p40b_enemy_attack_started = false
      @p40b_enemy_attack_completed = false
      @p40b_enemy_post_wait = 0
      log("[ENEMY_SUMMON_ACTION] queued summon=#{object_label(summoned)} target=#{object_label(target)} " +
          "target_index=#{target.index}")
      return true
    rescue Exception => e
      exception(e, "p40b_begin_enemy_lifecycle")
      assert("EnemySummon lifecycle fixture setup completed", false, e.message)
      @p40b_enemy_fixture[:done] = true if @p40b_enemy_fixture != nil
      @p40b_enemy_gate_active = false
      return false
    end

    def p40b_enemy_attack_match?(battler)
      data = @p40b_enemy_fixture
      return false if data == nil || !data[:ready] || battler == nil
      return battler.object_id == data[:summoned_oid]
    rescue
      return false
    end

    def p40b_enemy_attack_start(scene, battler)
      return unless p40b_enemy_attack_match?(battler)
      @p40b_enemy_attack_started = true
      data = @p40b_enemy_fixture
      target = nil
      begin
        target = $game_party.battle_members.find { |a| a != nil && a.object_id == data[:target_oid] }
      rescue
        target = nil
      end
      data[:target_hp_before_execute] = target.hp.to_i if target != nil
      log("[ENEMY_SUMMON_ACTION] EXECUTE START summon=#{object_label(battler)} " +
          "target=#{target == nil ? 'nil' : object_label(target)}")
    rescue Exception => e
      exception(e, "p40b_enemy_attack_start")
    end

    def p40b_enemy_attack_end(scene, battler)
      return unless p40b_enemy_attack_match?(battler)
      data = @p40b_enemy_fixture
      target = nil
      begin
        target = $game_party.battle_members.find { |a| a != nil && a.object_id == data[:target_oid] }
      rescue
        target = nil
      end
      data[:target_hp_after_execute] = target.hp.to_i if target != nil
      @p40b_enemy_attack_completed = true
      @p40b_enemy_post_wait = 2
      log("[ENEMY_SUMMON_ACTION] EXECUTE END summon=#{object_label(battler)} " +
          "target_hp=#{data[:target_hp_before_execute].inspect}->#{data[:target_hp_after_execute].inspect}")
      assert("EnemySummon summoned Enemy entered Scene_Battle#execute_action_attack", true,
             object_label(battler))
      assert("EnemySummon summoned Enemy remains formal Troop member after action",
             p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] },
             "summoned_oid=#{data[:summoned_oid]}")
    rescue Exception => e
      exception(e, "p40b_enemy_attack_end")
    end

    #--------------------------------------------------------------------------
    # ● Combo opening 完成後先跑 EnemySummon，再放行 Core Fixtures
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase40b_on_battle_scene_update_base)
      alias fs_phase40b_on_battle_scene_update_base on_battle_scene_update
    end
    def on_battle_scene_update(scene)
      if battle_active?
        # Phase39A 的 opening gate 擁有較高優先權；它完成後會 return 一幀。
        if @p39_combo_gate_active
          return fs_phase40b_on_battle_scene_update_base(scene)
        end

        if @p40b_enemy_fixture == nil || !@p40b_enemy_fixture[:started]
          p40b_begin_enemy_lifecycle(scene)
          return if @p40b_enemy_gate_active
        end

        if @p40b_enemy_gate_active
          @p40b_enemy_gate_updates += 1
          if @p40b_enemy_attack_completed
            if @p40b_enemy_post_wait.to_i > 0
              @p40b_enemy_post_wait -= 1
              log("[ENEMY_SUMMON_WAIT] action settle remaining=#{@p40b_enemy_post_wait}")
              return
            end
            data = @p40b_enemy_fixture
            log("[ENEMY_SUMMON_WAIT] lifecycle action complete release_core updates=#{@p40b_enemy_gate_updates} " +
                "troop=#{p40b_troop_members.size} summon_oid=#{data[:summoned_oid]}")
            assert("EnemySummon action completed before Core Fixtures",
                   @p40b_enemy_attack_started == true && @p40b_enemy_attack_completed == true)
            assert("EnemySummon member remains alive in Battle lifecycle before terminate",
                   p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] })
            data[:done] = true
            @p40b_enemy_gate_active = false
            return
          end
          if @p40b_enemy_gate_updates >= 240
            assert("EnemySummon summoned Enemy forced attack timeout", false,
                   "updates=#{@p40b_enemy_gate_updates}")
            @p40b_enemy_gate_active = false
            @p40b_enemy_fixture[:done] = true if @p40b_enemy_fixture != nil
          else
            return
          end
        end
      end
      fs_phase40b_on_battle_scene_update_base(scene)
    end

    #--------------------------------------------------------------------------
    # ● Battle-end ownership boundary：Enemy instance 由 battle_end 清；Sprite 由 terminate dispose
    #--------------------------------------------------------------------------
    def p40d_before_enemy_battle_end(scene, result)
      data = @p40b_enemy_fixture
      return true unless data != nil && data[:ready]
      in_troop = p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] }
      log("[ENEMY_SUMMON_LIFECYCLE] battle_end_before result=#{result} in_troop=#{in_troop} " +
          "troop=#{p40b_troop_members.size}")
      assert("EnemySummon Battle-local member remains in Game_Troop before formal battle_end clear", in_troop,
             "summoned_oid=#{data[:summoned_oid]}")
      data[:battle_end_before_seen] = true
      return true
    rescue Exception => e
      exception(e, "p40d_before_enemy_battle_end")
      return false
    end

    def p40d_after_enemy_battle_end(scene, result)
      data = @p40b_enemy_fixture
      return true unless data != nil && data[:ready]
      in_troop = p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] }
      log("[ENEMY_SUMMON_LIFECYCLE] battle_end_after result=#{result} in_troop=#{in_troop} " +
          "troop=#{p40b_troop_members.size}")
      assert("EnemySummon Game_Troop cleared by formal Scene_Battle#battle_end",
             !in_troop && p40b_troop_members.empty?,
             "in_troop=#{in_troop} troop=#{p40b_troop_members.size}")
      data[:battle_end_after_seen] = true
      return true
    rescue Exception => e
      exception(e, "p40d_after_enemy_battle_end")
      return false
    end

    def p40b_before_enemy_terminate(scene)
      data = @p40b_enemy_fixture
      return true unless data != nil && data[:ready]
      sprite = data[:sprite]
      in_troop = p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] }
      log("[ENEMY_SUMMON_LIFECYCLE] terminate_before in_troop=#{in_troop} " +
          "sprite_disposed=#{p40b_sprite_disposed?(sprite)} troop=#{p40b_troop_members.size} " +
          "battle_end_seen=#{[data[:battle_end_before_seen], data[:battle_end_after_seen]].inspect}")
      assert("EnemySummon Game_Troop already cleared before Scene_Battle terminate",
             !in_troop && p40b_troop_members.empty?,
             "in_troop=#{in_troop} troop=#{p40b_troop_members.size}")
      assert("EnemySummon formal battle_end ownership boundary observed before terminate",
             data[:battle_end_before_seen] == true && data[:battle_end_after_seen] == true,
             "before=#{data[:battle_end_before_seen].inspect} after=#{data[:battle_end_after_seen].inspect}")
      assert("EnemySummon Sprite still alive before Scene_Battle terminate",
             !p40b_sprite_disposed?(sprite), "sprite=#{data[:sprite_oid].inspect}")
      return true
    rescue Exception => e
      exception(e, "p40b_before_enemy_terminate")
      return false
    end

    def p40b_after_enemy_terminate(scene)
      data = @p40b_enemy_fixture
      return true unless data != nil && data[:ready]
      sprite = data[:sprite]
      disposed = p40b_sprite_disposed?(sprite)
      data[:sprite_disposed_after_terminate] = disposed
      data[:troop_contains_after_terminate] = p40b_troop_members.any? { |e| e.object_id == data[:summoned_oid] }
      log("[ENEMY_SUMMON_LIFECYCLE] terminate_after sprite_disposed=#{disposed} " +
          "troop_contains=#{data[:troop_contains_after_terminate]} troop=#{p40b_troop_members.size}")
      assert("EnemySummon Sprite disposed by Scene_Battle/Spriteset terminate", disposed == true,
             "sprite=#{data[:sprite_oid].inspect}")
      # 這裡不要求 $game_troop 刪 member。正式 Battle object 由 Harness Snapshot 在下一步還原。
      assert("EnemySummon fixture action lifecycle completed before terminate", data[:done] == true,
             "started=#{@p40b_enemy_attack_started} completed=#{@p40b_enemy_attack_completed}")
      return true
    rescue Exception => e
      exception(e, "p40b_after_enemy_terminate")
      assert("EnemySummon terminate lifecycle verification completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase40b_after_snapshot_restore_base)
      alias fs_phase40b_after_snapshot_restore_base after_battle_snapshot_restore
    end
    def after_battle_snapshot_restore
      base = fs_phase40b_after_snapshot_restore_base
      data = @p40b_enemy_fixture
      return base if data == nil || !data[:ready]
      current = p40b_troop_members
      oid_present = current.any? { |e| e.object_id == data[:summoned_oid] }
      probe_restored = true
      if data[:probe_skill_id] != nil
        skill = $data_skills[data[:probe_skill_id]] rescue nil
        probe_restored = skill != nil && skill.note.to_s == data[:probe_original_note].to_s
      end
      queue = $game_troop.respond_to?(:fs_force_action_queue) ? ($game_troop.fs_force_action_queue || []) : []
      queued_oid = queue.any? { |b| b != nil && b.object_id == data[:summoned_oid] }
      log("[SNAPSHOT] ENEMY_SUMMON restore summoned_oid=#{data[:summoned_oid]} present=#{oid_present} " +
          "troop=#{current.collect { |e| e.enemy_id rescue nil }.inspect} probe_note_restored=#{probe_restored} " +
          "queue_contains=#{queued_oid}")
      assert("EnemySummon Snapshot removes Battle-local summoned Enemy instance", oid_present == false,
             "summoned_oid=#{data[:summoned_oid]}")
      assert("EnemySummon temporary guard probe Skill Note remains restored", probe_restored == true,
             "skill=#{data[:probe_skill_id].inspect}")
      assert("EnemySummon forced action queue does not retain Battle-local summoned Enemy", queued_oid == false)
      assert("EnemySummon Sprite remained disposed through Snapshot restore",
             data[:sprite_disposed_after_terminate] == true)
      return base
    end

    unless method_defined?(:fs_phase40b_restore_pending_base)
      alias fs_phase40b_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase40b_restore_pending_base
      if result
        @p40b_enemy_fixture = nil
        @p40b_enemy_gate_active = false
        @p40b_enemy_gate_updates = 0
        @p40b_enemy_attack_started = false
        @p40b_enemy_attack_completed = false
        @p40b_enemy_post_wait = 0
      end
      return result
    end
  end
end

#==============================================================================
# ■ Phase40B TEST-only Scene_Battle wrappers
#==============================================================================
if (defined?($TEST) != nil && $TEST == true) && defined?(Scene_Battle)
  class Scene_Battle < Scene_Base
    unless method_defined?(:fs_phase40b_execute_action_attack_base)
      alias fs_phase40b_execute_action_attack_base execute_action_attack
    end
    def execute_action_attack(*args)
      battler = @active_battler
      FS_TEST_HARNESS.p40b_enemy_attack_start(self, battler)
      result = fs_phase40b_execute_action_attack_base(*args)
      FS_TEST_HARNESS.p40b_enemy_attack_end(self, battler)
      return result
    end

    unless method_defined?(:fs_phase40d_battle_end_base)
      alias fs_phase40d_battle_end_base battle_end
    end
    def battle_end(result)
      FS_TEST_HARNESS.p40d_before_enemy_battle_end(self, result)
      value = fs_phase40d_battle_end_base(result)
      FS_TEST_HARNESS.p40d_after_enemy_battle_end(self, result)
      return value
    end

    unless method_defined?(:fs_phase40b_terminate_base)
      alias fs_phase40b_terminate_base terminate
    end
    def terminate
      FS_TEST_HARNESS.p40b_before_enemy_terminate(self)
      result = fs_phase40b_terminate_base
      FS_TEST_HARNESS.p40b_after_enemy_terminate(self)
      return result
    end
  end
end


#==============================================================================
# ■ Phase41B｜AI Authority RNG Trace Expectation Fix
# ■ Phase41A｜AI Authority Selection Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：只驗證「選招」，不執行 AI 產生的 Action。
# Actor 使用 Phase39/40 已正式加入戰場的 summon；Enemy 使用目前 Troop 中第一個
# FS_EnemyActionDistribution eligible Enemy。完成後立即 clear action / restore AI seed。
#==============================================================================
module FS_TEST_HARNESS
  @p41a_ai_fixture_done = false
  @p41a_ai_fixture = nil

  class << self
    def p41a_action_signature(battler)
      return nil if battler == nil || !battler.respond_to?(:action)
      action = battler.action
      return nil if action == nil
      return [action.kind.to_i, action.basic.to_i, action.skill_id.to_i,
              action.item_id.to_i, action.target_index.to_i, action.forcing == true]
    rescue
      return nil
    end

    def p41a_force_queue_size
      return 0 if $game_troop == nil || !$game_troop.respond_to?(:fs_force_action_queue)
      queue = $game_troop.fs_force_action_queue
      return 0 unless queue.is_a?(Array)
      return queue.size
    rescue
      return 0
    end

    def p41a_ai_trace_lines(prefix)
      return unless defined?(FS_AI_RANDOM)
      for line in FS_AI_RANDOM.trace_lines
        log("[#{prefix}] #{line}")
      end
    rescue Exception => e
      exception(e, "p41a_ai_trace_lines")
    end

    def p41a_run_actor_ai_fixture
      combo = @p39_combo_fixture
      summon = combo == nil ? nil : ($game_actors[combo[:summon_actor_id]] rescue nil)
      assert("Actor AI Authority summon exists", summon != nil,
             combo == nil ? "combo=nil" : "actor_id=#{combo[:summon_actor_id]}")
      assert("Actor AI Authority module exists", defined?(AutoBattleAI) != nil)
      assert("Actor AI deterministic provider exists", defined?(FS_AI_RANDOM) != nil)
      return false if summon == nil || !defined?(AutoBattleAI) || !defined?(FS_AI_RANDOM)

      package = AutoBattleAI.get_actor_ai(summon)
      active_ai_states = []
      if defined?(AutoBattleAI::STATE_AI_MAPPING)
        for state_id in AutoBattleAI::STATE_AI_MAPPING.keys
          active_ai_states.push(state_id) if summon.state?(state_id)
        end
      end
      assert_equal("Actor AI State priority resolves support package", :support, package)
      assert("Actor AI control State23 formally active", summon.state?(23),
             "states=#{active_ai_states.inspect}")

      raw_before = p40_raw_skill_ids(summon)
      level_before = summon.level.to_i
      exp_before = summon.exp.to_i
      queue_before = p41a_force_queue_size
      usable = summon.skills.compact.select { |skill| summon.skill_can_use?(skill) }
      assert("Actor AI has at least one formally usable skill", !usable.empty?,
             "skills=#{summon.skills.compact.collect { |s| s.id }.inspect} mp=#{summon.mp}")

      FS_AI_RANDOM.reset(4101)
      summon.make_action
      sig = p41a_action_signature(summon)
      chosen_skill = nil
      chosen_target = nil
      if summon.action.kind.to_i == 1
        chosen_skill = $data_skills[summon.action.skill_id] rescue nil
        chosen_target = $game_troop.members[summon.action.target_index] rescue nil
      elsif summon.action.kind.to_i == 0 && summon.action.basic.to_i == 0
        chosen_target = $game_troop.members[summon.action.target_index] rescue nil
      end
      p41a_ai_trace_lines("AI_ACTOR_RNG")
      log("[AI_ACTOR] actor=#{summon.id}:#{summon.name} package=#{package.inspect} " +
          "states=#{active_ai_states.inspect} usable=#{usable.collect { |s| s.id }.inspect} " +
          "action=#{sig.inspect} skill=#{chosen_skill == nil ? 'nil' : chosen_skill.id.to_s + ':' + chosen_skill.name.to_s} " +
          "target=#{chosen_target == nil ? 'nil' : object_label(chosen_target)}")

      valid_action = false
      if summon.action.kind.to_i == 1
        valid_action = chosen_skill != nil &&
                       usable.any? { |skill| skill.id.to_i == chosen_skill.id.to_i } &&
                       chosen_target != nil && chosen_target.exist?
      elsif summon.action.kind.to_i == 0 && summon.action.basic.to_i == 0
        valid_action = chosen_target != nil && chosen_target.exist?
      end
      assert("Actor AI make_action selects legal executable action", valid_action,
             "action=#{sig.inspect}")
      if usable.size == 1 && usable[0].for_opponent?
        assert_equal("Actor AI single usable offensive skill remains selected",
                     usable[0].id.to_i, summon.action.skill_id.to_i)
      end
      assert_equal("Actor AI selection does not mutate raw learned skills", raw_before, p40_raw_skill_ids(summon))
      assert("Actor AI selection preserves progression", summon.level.to_i == level_before && summon.exp.to_i == exp_before,
             "level=#{level_before}->#{summon.level} exp=#{exp_before}->#{summon.exp}")
      assert_equal("Actor AI selection does not enqueue forced action", queue_before, p41a_force_queue_size)
      summon.action.clear
      return true
    rescue Exception => e
      exception(e, "p41a_run_actor_ai_fixture")
      assert("Actor AI Authority fixture completed", false, e.message)
      begin
        summon.action.clear if summon != nil && summon.respond_to?(:action)
      rescue
      end
      return false
    end

    def p41a_run_enemy_ai_fixture
      assert("Enemy AI Distribution Authority exists", defined?(FS_ENEMY_ACTION_DIST) != nil)
      assert("Enemy AI deterministic provider exists", defined?(FS_AI_RANDOM) != nil)
      return false unless defined?(FS_ENEMY_ACTION_DIST) && defined?(FS_AI_RANDOM)

      enemy = nil
      begin
        enemy = $game_troop.existing_members.find { |e| FS_ENEMY_ACTION_DIST.eligible?(e) }
      rescue
        enemy = nil
      end
      assert("Enemy AI Distribution eligible fixture Enemy exists", enemy != nil,
             "members=#{$game_troop.members.collect { |e| e.enemy_id rescue 0 }.inspect}")
      return false if enemy == nil

      old_last = enemy.instance_variable_get(:@fs_ead_last_damage_skill)
      queue_before = p41a_force_queue_size
      party_count = FS_ENEMY_ACTION_DIST.party_alive_count
      enemy_count = FS_ENEMY_ACTION_DIST.enemy_alive_count
      rate = FS_ENEMY_ACTION_DIST.attack_rate(enemy, party_count, enemy_count)
      assert("Enemy AI attack rate stays within formal clamp",
             rate.to_i >= FS_ENEMY_ACTION_DIST::RATE_MIN && rate.to_i <= FS_ENEMY_ACTION_DIST::RATE_MAX,
             "rate=#{rate}")

      enemy.instance_variable_set(:@fs_ead_last_damage_skill, false)
      ai_seed = 12345
      FS_AI_RANDOM.reset(ai_seed)
      enemy.make_action
      sig = p41a_action_signature(enemy)
      trace = FS_AI_RANDOM.trace
      dist = trace.find { |entry| entry[1] == :enemy_attack_distribution }
      dist_value = dist == nil ? nil : dist[3].to_i
      dist_index = nil
      max_list = []
      expected_sequence = []
      expected_dist = nil
      if dist != nil
        i = 0
        while i < trace.size
          max_list.push(trace[i][2].to_i)
          if trace[i][1] == :enemy_attack_distribution
            dist_index = i
            break
          end
          i += 1
        end
        expected_sequence = FS_AI_RANDOM.preview(ai_seed, max_list)
        expected_dist = expected_sequence[dist_index] if dist_index != nil
      end
      p41a_ai_trace_lines("AI_ENEMY_RNG")
      log("[AI_ENEMY] enemy=#{enemy.enemy_id}:#{enemy.name} party_alive=#{party_count} enemy_alive=#{enemy_count} " +
          "rate=#{rate} dist=#{dist_value.inspect} dist_index=#{dist_index.inspect} max_list=#{max_list.inspect} " +
          "expected_sequence=#{expected_sequence.inspect} expected_dist=#{expected_dist.inspect} action=#{sig.inspect} " +
          "last_damage=#{enemy.instance_variable_get(:@fs_ead_last_damage_skill).inspect}")

      assert("Enemy AI Distribution consumes tagged deterministic roll", dist != nil,
             "trace=#{trace.inspect}")
      if dist != nil
        assert("Enemy AI Distribution deterministic replay sequence resolved",
               dist_index != nil && expected_sequence.size == max_list.size && expected_dist != nil,
               "index=#{dist_index.inspect} max_list=#{max_list.inspect} expected=#{expected_sequence.inspect}")
        assert_equal("Enemy AI Distribution roll matches deterministic trace-order replay", expected_dist.to_i, dist_value.to_i)
        expected_attack = dist_value.to_i < rate.to_i
        if expected_attack
          assert("Enemy AI Distribution overrides replaceable skill with normal attack",
                 enemy.action.kind.to_i == 0 && enemy.action.basic.to_i == 0,
                 "rate=#{rate} roll=#{dist_value} action=#{sig.inspect}")
          assert("Enemy AI final-action recorder sees normal attack as non-damage-skill",
                 enemy.instance_variable_get(:@fs_ead_last_damage_skill) == false)
        else
          assert("Enemy AI Distribution respects non-override roll",
                 !(enemy.action.kind.to_i == 0 && enemy.action.basic.to_i == 0),
                 "rate=#{rate} roll=#{dist_value} action=#{sig.inspect}")
        end
      end
      assert_equal("Enemy AI selection does not enqueue forced action", queue_before, p41a_force_queue_size)
      enemy.action.clear
      enemy.instance_variable_set(:@fs_ead_last_damage_skill, old_last)
      return true
    rescue Exception => e
      exception(e, "p41a_run_enemy_ai_fixture")
      assert("Enemy AI Distribution fixture completed", false, e.message)
      begin
        enemy.action.clear if enemy != nil && enemy.respond_to?(:action)
        enemy.instance_variable_set(:@fs_ead_last_damage_skill, old_last) if enemy != nil
      rescue
      end
      return false
    end

    def p41a_run_ai_authority_fixture(scene)
      return true if @p41a_ai_fixture_done
      @p41a_ai_fixture_done = true
      log("[AI_AUTHORITY] fixture begin scene=#{scene.class}")
      actor_ok = p41a_run_actor_ai_fixture
      enemy_ok = p41a_run_enemy_ai_fixture
      if defined?(FS_AI_RANDOM)
        FS_AI_RANDOM.reset(AI_SEED)
        log("[AI_AUTHORITY] deterministic seed restored=#{AI_SEED}")
      end
      @p41a_ai_fixture = { :actor=>actor_ok, :enemy=>enemy_ok }
      assert("AI Authority selection fixtures completed before EnemySummon",
             actor_ok == true && enemy_ok == true,
             @p41a_ai_fixture.inspect)
      log("[AI_AUTHORITY] fixture end result=#{@p41a_ai_fixture.inspect}")
      return actor_ok == true && enemy_ok == true
    rescue Exception => e
      exception(e, "p41a_run_ai_authority_fixture")
      assert("AI Authority selection fixture completed", false, e.message)
      return false
    end

    # Current wrapper owns EnemySummon. Phase41B AI regression sits outside it:
    # let Combo opening finish first, then consume one frame for pure AI selection,
    # and only on the following frame let Phase40D begin EnemySummon lifecycle.
    unless method_defined?(:fs_phase41a_on_battle_scene_update_base)
      alias fs_phase41a_on_battle_scene_update_base on_battle_scene_update
    end
    def on_battle_scene_update(scene)
      if battle_active? && !@p41a_ai_fixture_done
        if @p39_combo_gate_active
          return fs_phase41a_on_battle_scene_update_base(scene)
        end
        p41a_run_ai_authority_fixture(scene)
        return
      end
      fs_phase41a_on_battle_scene_update_base(scene)
    end

    unless method_defined?(:fs_phase41a_restore_pending_base)
      alias fs_phase41a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase41a_restore_pending_base
      if result
        @p41a_ai_fixture_done = false
        @p41a_ai_fixture = nil
      end
      return result
    end
  end
end


#==============================================================================
# ■ Phase41C｜Equipment Provider / Equip-Refresh Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：只觀察既有 change_equip wrapper chain，不修改正式 Equipment Runtime。
# 正式責任：
#   SetupBridge NewIndicator suppression (outer)
#   -> FS_EquipmentCombo_Base#change_equip
#   -> FS_EquipmentSkill_Authority#change_equip
#   -> YEM Equipment Overhaul / VX base mutation
#   -> teaching refresh -> passive refresh -> combo refresh
# Fixture 完成後把 Armor653 裝回，維持 Phase39+ 後續 Combo/Summon prerequisite。
#==============================================================================
module FS_TEST_HARNESS
  @p41c_equip_refresh = nil
  @p41c_trace_active = false
  @p41c_refresh_events = []

  class << self
    def p41c_skill_ids(actor)
      return [] if actor == nil || !actor.respond_to?(:skills)
      return actor.skills.compact.collect { |skill| skill.id.to_i }.uniq.sort
    rescue
      return []
    end

    def p41c_raw_skill_map(actor, skill_ids)
      result = {}
      skill_ids.each { |id| result[id.to_i] = p37_raw_skill_learned?(actor, id.to_i) }
      return result
    rescue
      return {}
    end

    def p41c_unnatural_skill_ids(actor)
      value = actor == nil ? nil : (actor.instance_variable_get(:@unnatural_skills) rescue nil)
      return [] unless value.is_a?(Array)
      return value.compact.collect { |id| id.to_i }.uniq.sort
    rescue
      return []
    end

    def p41c_new_flag(item)
      return nil if item == nil || !defined?(FS_GALV_NEW_ITEM)
      return nil unless FS_GALV_NEW_ITEM.respond_to?(:new_item?)
      return FS_GALV_NEW_ITEM.new_item?(item)
    rescue
      return nil
    end

    def p41c_trace_begin
      @p41c_refresh_events = []
      @p41c_trace_active = true
    end

    def p41c_trace_end
      @p41c_trace_active = false
      return (@p41c_refresh_events || []).clone
    end

    def p41c_record_refresh(actor, tag)
      return unless @p41c_trace_active == true
      @p41c_refresh_events = [] unless @p41c_refresh_events.is_a?(Array)
      @p41c_refresh_events << [tag, actor == nil ? nil : actor.id.to_i]
    rescue
    end

    def p41c_record_party_refresh(tag, party)
      return unless @p41c_trace_active == true
      @p41c_refresh_events = [] unless @p41c_refresh_events.is_a?(Array)
      depth = party.instance_variable_get(:@fs_nitem_suppress_depth) rescue nil
      @p41c_refresh_events << [tag, depth]
    rescue
    end

    def p41c_event_tags(events)
      return [] unless events.is_a?(Array)
      return events.collect { |entry| entry.is_a?(Array) ? entry[0] : entry }
    rescue
      return []
    end

    def p41c_assert_refresh_trace(label, events)
      tags = p41c_event_tags(events)
      teach_i = tags.index(:teaching)
      passive_i = tags.index(:passive)
      combo_i = tags.index(:combo)
      begin_i = tags.index(:nitem_begin)
      end_i = tags.rindex(:nitem_end)
      chain_ok = teach_i != nil && passive_i != nil && combo_i != nil &&
                 teach_i < passive_i && passive_i < combo_i
      suppress_ok = begin_i != nil && end_i != nil && begin_i < teach_i && combo_i < end_i
      begin_count = tags.select { |tag| tag == :nitem_begin }.size
      end_count = tags.select { |tag| tag == :nitem_end }.size
      assert("Equipment #{label} automatic refresh chain order", chain_ok,
             "events=#{events.inspect}")
      assert("Equipment #{label} NEW suppression wraps refresh chain",
             suppress_ok && begin_count == end_count,
             "begin=#{begin_count} end=#{end_count} events=#{events.inspect}")
      return chain_ok && suppress_ok && begin_count == end_count
    rescue Exception => e
      exception(e, "p41c_assert_refresh_trace_#{label}")
      assert("Equipment #{label} refresh trace completed", false, e.message)
      return false
    end

    # Phase40A map baseline 完成後，正式做 equipment provider cycle，再恢復正式 prerequisite。
    unless method_defined?(:fs_phase41c_prepare_battle_fixture_on_map_base)
      alias fs_phase41c_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase41c_prepare_battle_fixture_on_map_base
      soul = @p37_soul_prebattle
      combo = @p39_combo_fixture
      assert("Equipment refresh SoulMark metadata exists", soul != nil && soul[:ready] == true)
      assert("Equipment refresh Combo metadata exists", combo != nil && combo[:ready] == true)
      return false if soul == nil || combo == nil || !soul[:ready] || !combo[:ready]

      actor = $game_actors[soul[:actor_id]] rescue nil
      armor = $data_armors[soul[:armor_id]] rescue nil
      headgear = $data_armors[combo[:headgear_id]] rescue nil
      skill = $data_skills[soul[:skill_id]] rescue nil
      slot = soul[:slot]
      assert("Equipment refresh runs on Scene_Map", $scene.is_a?(Scene_Map), $scene.class.to_s)
      assert("Equipment refresh actor/provider/headgear resolved",
             actor != nil && armor != nil && headgear != nil && skill != nil && slot != nil,
             "actor=#{actor == nil ? 'nil' : actor.id} armor=#{soul[:armor_id]} headgear=#{combo[:headgear_id]} slot=#{slot.inspect}")
      return false if actor == nil || armor == nil || headgear == nil || skill == nil || slot == nil

      provider_ids = []
      begin
        provider_ids = armor.skills.compact.collect { |entry| entry.id.to_i }.uniq.sort
      rescue
        provider_ids = []
      end
      assert("Equipment refresh provider exposes formal equipskill set",
             !provider_ids.empty? && provider_ids.include?(skill.id.to_i),
             "armor=#{armor.id}:#{armor.name} provider_ids=#{provider_ids.inspect}")
      return false if provider_ids.empty?

      before = {
        :equip_signature=>p37_equip_signature(actor),
        :skill_ids=>p41c_skill_ids(actor),
        :raw_provider=>p41c_raw_skill_map(actor, provider_ids),
        :unnatural=>p41c_unnatural_skill_ids(actor),
        :armor_count=>$game_party.item_number(armor),
        :headgear_count=>$game_party.item_number(headgear),
        :new_flag=>p41c_new_flag(armor),
        :combo_active=>actor.respond_to?(:albert_combo_effect_active?) ? actor.albert_combo_effect_active?(headgear) : false
      }
      assert("Equipment refresh baseline provider skills all visible",
             provider_ids.all? { |id| before[:skill_ids].include?(id) },
             "providers=#{provider_ids.inspect} skills=#{before[:skill_ids].inspect}")
      assert("Equipment refresh baseline Combo active", before[:combo_active] == true,
             "headgear=#{headgear.id} armor=#{armor.id}")

      # --- formal unequip ---
      p41c_trace_begin
      begin
        actor.change_equip(slot, nil, false)
      ensure
        remove_events = p41c_trace_end
      end
      after_remove_skills = p41c_skill_ids(actor)
      after_remove_raw = p41c_raw_skill_map(actor, provider_ids)
      after_remove_combo = actor.respond_to?(:albert_combo_effect_active?) ? actor.albert_combo_effect_active?(headgear) : false
      after_remove_new = p41c_new_flag(armor)
      log("[EQUIP_REFRESH] remove armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{remove_events.inspect} " +
          "skills=#{provider_ids.inspect}->#{provider_ids.select { |id| after_remove_skills.include?(id) }.inspect} " +
          "raw=#{after_remove_raw.inspect} combo=#{after_remove_combo.inspect} inventory=#{$game_party.item_number(armor)} " +
          "new=#{before[:new_flag].inspect}->#{after_remove_new.inspect}")
      p41c_assert_refresh_trace("remove", remove_events)
      assert("Equipment provider armor formally unequipped", !p37_equipped_item?(actor, armor),
             "slot=#{slot}")
      assert("Equipment provider skills disappear when provider removed",
             !provider_ids.any? { |id| after_remove_skills.include?(id) },
             "providers=#{provider_ids.inspect} actor_skills=#{after_remove_skills.inspect}")
      assert("Equipment provider removal does not mutate raw learned skills",
             after_remove_raw == before[:raw_provider],
             "before=#{before[:raw_provider].inspect} after=#{after_remove_raw.inspect}")
      assert("Equipment dependent Combo deactivates when required armor removed",
             after_remove_combo == false,
             "headgear=#{headgear.id} armor=#{armor.id}")
      assert("Equipment headgear remains equipped while dependency is absent",
             p37_equipped_item?(actor, headgear) == true,
             "headgear=#{headgear.id}")
      assert_equal("Equipment unequip returns provider armor to inventory",
                   before[:armor_count].to_i + 1, $game_party.item_number(armor))
      assert("Equipment unequip does not mark returned armor NEW",
             after_remove_new == before[:new_flag],
             "before=#{before[:new_flag].inspect} after=#{after_remove_new.inspect}")
      assert("Equipment teaching marker list unchanged for equipskill provider",
             p41c_unnatural_skill_ids(actor) == before[:unnatural],
             "before=#{before[:unnatural].inspect} after=#{p41c_unnatural_skill_ids(actor).inspect}")

      # --- formal re-equip ---
      p41c_trace_begin
      begin
        actor.change_equip(slot, armor, false)
      ensure
        add_events = p41c_trace_end
      end
      final_skills = p41c_skill_ids(actor)
      final_raw = p41c_raw_skill_map(actor, provider_ids)
      final_combo = actor.respond_to?(:albert_combo_effect_active?) ? actor.albert_combo_effect_active?(headgear) : false
      final_new = p41c_new_flag(armor)
      log("[EQUIP_REFRESH] restore armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{add_events.inspect} " +
          "providers=#{provider_ids.inspect} raw=#{final_raw.inspect} combo=#{final_combo.inspect} " +
          "inventory=#{$game_party.item_number(armor)} new=#{final_new.inspect}")
      p41c_assert_refresh_trace("restore", add_events)
      assert("Equipment provider armor formally re-equipped", p37_equipped_item?(actor, armor) == true,
             "slot=#{slot} armor=#{armor.id}")
      assert("Equipment provider skills restored after re-equip",
             provider_ids.all? { |id| final_skills.include?(id) },
             "providers=#{provider_ids.inspect} actor_skills=#{final_skills.inspect}")
      assert("Equipment provider re-equip does not mutate raw learned skills",
             final_raw == before[:raw_provider],
             "before=#{before[:raw_provider].inspect} after=#{final_raw.inspect}")
      assert("Equipment dependent Combo reactivates after required armor restore",
             final_combo == true,
             "headgear=#{headgear.id} armor=#{armor.id}")
      assert_equal("Equipment re-equip restores provider armor inventory count",
                   before[:armor_count].to_i, $game_party.item_number(armor))
      assert_equal("Equipment cycle preserves headgear inventory count",
                   before[:headgear_count].to_i, $game_party.item_number(headgear))
      assert("Equipment cycle preserves NEW flag", final_new == before[:new_flag],
             "before=#{before[:new_flag].inspect} after=#{final_new.inspect}")
      assert("Equipment cycle restores Actor skill list exactly",
             final_skills == before[:skill_ids],
             "before=#{before[:skill_ids].inspect} after=#{final_skills.inspect}")
      assert("Equipment cycle preserves teaching marker list",
             p41c_unnatural_skill_ids(actor) == before[:unnatural],
             "before=#{before[:unnatural].inspect} after=#{p41c_unnatural_skill_ids(actor).inspect}")

      # Cooldown 不是 change_equip 自動 ownership；維持既有 prebattle fixture 規格明確刷新 final state。
      cooldown_refresh = actor.respond_to?(:recharge_all)
      actor.recharge_all if cooldown_refresh
      assert("Equipment final-state cooldown refresh provider exists", cooldown_refresh,
             "actor=#{actor.id}")
      usable = p37_probe_battle_skill_can_use(actor, skill)
      assert("Equipment cycle leaves SoulMark formally usable before battle", usable == true,
             "skill=#{skill.id} item=#{soul[:fragment_id]}")

      @p41c_equip_refresh = {
        :actor_id=>actor.id.to_i, :armor_id=>armor.id.to_i, :headgear_id=>headgear.id.to_i,
        :provider_skill_ids=>provider_ids, :remove_events=>remove_events, :restore_events=>add_events,
        :ready=>p37_equipped_item?(actor, armor) && final_combo && usable
      }
      log("[EQUIP_REFRESH] cycle complete ready=#{@p41c_equip_refresh[:ready]} provider=#{provider_ids.inspect}")
      assert("Equipment provider / refresh cycle completed", @p41c_equip_refresh[:ready] == true,
             @p41c_equip_refresh.inspect)
      return @p41c_equip_refresh[:ready] == true
    rescue Exception => e
      @p41c_trace_active = false
      exception(e, "p41c_prepare_equipment_refresh_cycle")
      assert("Equipment provider / refresh cycle completed", false, e.message)
      return false
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only trace wrappers：只記錄正式 provider 被 change_equip 呼叫的事實。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:albert_refresh_equipment_teaching_skills) &&
       !method_defined?(:fs_p41c_trace_equipment_teaching_refresh)
      alias fs_p41c_trace_equipment_teaching_refresh albert_refresh_equipment_teaching_skills
      def albert_refresh_equipment_teaching_skills
        FS_TEST_HARNESS.p41c_record_refresh(self, :teaching)
        fs_p41c_trace_equipment_teaching_refresh
      end
    end

    if method_defined?(:albert_refresh_equipment_passive_skills) &&
       !method_defined?(:fs_p41c_trace_equipment_passive_refresh)
      alias fs_p41c_trace_equipment_passive_refresh albert_refresh_equipment_passive_skills
      def albert_refresh_equipment_passive_skills
        FS_TEST_HARNESS.p41c_record_refresh(self, :passive)
        fs_p41c_trace_equipment_passive_refresh
      end
    end

    if method_defined?(:albert_refresh_combo_actor_states) &&
       !method_defined?(:fs_p41c_trace_equipment_combo_refresh)
      alias fs_p41c_trace_equipment_combo_refresh albert_refresh_combo_actor_states
      def albert_refresh_combo_actor_states
        FS_TEST_HARNESS.p41c_record_refresh(self, :combo)
        fs_p41c_trace_equipment_combo_refresh
      end
    end
  end

  class Game_Party < Game_Unit
    if method_defined?(:fs_nitem_suppress_begin) &&
       !method_defined?(:fs_p41c_trace_nitem_suppress_begin)
      alias fs_p41c_trace_nitem_suppress_begin fs_nitem_suppress_begin
      def fs_nitem_suppress_begin
        FS_TEST_HARNESS.p41c_record_party_refresh(:nitem_begin, self)
        fs_p41c_trace_nitem_suppress_begin
      end
    end

    if method_defined?(:fs_nitem_suppress_end) &&
       !method_defined?(:fs_p41c_trace_nitem_suppress_end)
      alias fs_p41c_trace_nitem_suppress_end fs_nitem_suppress_end
      def fs_nitem_suppress_end
        result = fs_p41c_trace_nitem_suppress_end
        FS_TEST_HARNESS.p41c_record_party_refresh(:nitem_end, self)
        return result
      end
    end
  end
end


#==============================================================================
# ■ Phase41D｜Actor Setup Chain Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：用 detached Game_Actor 驗證目前正式 setup alias/load-order chain。
# 不替換 $game_actors、不加入 Party，也不把 Combo refresh 假裝成 setup 自動責任。
#==============================================================================
module FS_TEST_HARNESS
  @p41d_setup_trace_active = false
  @p41d_setup_events = []
  @p41d_setup_fixture = nil

  class << self
    def p41d_record_setup(actor, tag)
      return unless @p41d_setup_trace_active == true
      @p41d_setup_events = [] unless @p41d_setup_events.is_a?(Array)
      actor_id = nil
      begin
        actor_id = actor.id.to_i if actor != nil && actor.respond_to?(:id)
      rescue
        actor_id = nil
      end
      @p41d_setup_events << [tag, actor_id]
    rescue
    end

    def p41d_setup_trace_begin
      @p41d_setup_events = []
      @p41d_setup_trace_active = true
    end

    def p41d_setup_trace_end
      @p41d_setup_trace_active = false
      return (@p41d_setup_events || []).clone
    end

    def p41d_setup_tags(events)
      return [] unless events.is_a?(Array)
      return events.collect { |entry| entry.is_a?(Array) ? entry[0] : entry }
    rescue
      return []
    end

    def p41d_assert_setup_trace(label, events)
      tags = p41d_setup_tags(events)
      core = [:setup_final_begin, :runtime_support, :equipment_skill,
              :skill_levels, :equipment_overhaul, :passive_skill,
              :job_base, :overdrive, :rx_base]
      indices = core.collect { |tag| tags.index(tag) }
      chain_ok = !indices.any? { |value| value == nil }
      if chain_ok
        0.upto(indices.size - 2) do |i|
          chain_ok = false unless indices[i] < indices[i + 1]
        end
      end
      teaching_i = tags.rindex(:teaching_refresh)
      passive_i = tags.rindex(:passive_refresh)
      end_i = tags.rindex(:setup_final_end)
      refresh_ok = teaching_i != nil && passive_i != nil && end_i != nil &&
                   indices[-1] != nil && indices[-1] < teaching_i &&
                   teaching_i < passive_i && passive_i < end_i
      begin_count = tags.select { |tag| tag == :setup_final_begin }.size
      end_count = tags.select { |tag| tag == :setup_final_end }.size
      assert("Actor setup #{label} formal alias chain order", chain_ok,
             "events=#{events.inspect}")
      assert("Actor setup #{label} EquipmentSkill teaching/passive refresh order", refresh_ok,
             "events=#{events.inspect}")
      assert("Actor setup #{label} final wrapper balanced",
             begin_count == 1 && end_count == 1,
             "begin=#{begin_count} end=#{end_count} events=#{events.inspect}")
      return chain_ok && refresh_ok && begin_count == 1 && end_count == 1
    rescue Exception => e
      exception(e, "p41d_assert_setup_trace_#{label}")
      assert("Actor setup #{label} trace completed", false, e.message)
      return false
    end

    def p41d_raw_skill_ids(actor)
      raw = actor == nil ? nil : (actor.instance_variable_get(:@skills) rescue nil)
      return [] unless raw.is_a?(Array)
      return raw.compact.collect { |id| id.to_i }.uniq.sort
    rescue
      return []
    end

    def p41d_equipped_provider_skill_ids(actor)
      return [] if actor == nil || !actor.respond_to?(:equips)
      result = []
      actor.equips.compact.each do |item|
        begin
          next unless item.respond_to?(:skills)
          item.skills.compact.each { |skill| result << skill.id.to_i if skill != nil }
        rescue
        end
      end
      return result.uniq.sort
    rescue
      return []
    end

    def p41d_expected_raw_skills(actor, actor_id)
      data = $data_actors[actor_id] rescue nil
      return [] if data == nil
      klass = $data_classes[data.class_id] rescue nil
      result = []
      if klass != nil && klass.respond_to?(:learnings)
        klass.learnings.each do |learning|
          next if learning == nil
          result << learning.skill_id.to_i if learning.level.to_i <= data.initial_level.to_i
        end
      end
      if defined?(FS_DB_RUNTIME_SUPPORT) &&
         FS_DB_RUNTIME_SUPPORT.const_defined?("JOEY_ACTOR_ID") &&
         FS_DB_RUNTIME_SUPPORT.const_defined?("STEAL_SKILL_ID") &&
         actor_id.to_i == FS_DB_RUNTIME_SUPPORT::JOEY_ACTOR_ID.to_i
        result << FS_DB_RUNTIME_SUPPORT::STEAL_SKILL_ID.to_i
      end
      if actor != nil && actor.respond_to?(:albert_equipment_teaching_entries)
        begin
          actor.albert_equipment_teaching_entries.each do |entry|
            skill_id = entry[0].to_i
            level_min = entry[1].to_i
            result << skill_id if actor.level.to_i >= level_min
          end
        rescue
        end
      end
      return result.uniq.sort
    rescue
      return []
    end

    def p41d_exp(actor)
      return 0 if actor == nil
      return actor.exp.to_i if actor.respond_to?(:exp)
      return (actor.instance_variable_get(:@exp) || 0).to_i
    rescue
      return 0
    end

    def p41d_deep_copy(value)
      return Marshal.load(Marshal.dump(value))
    rescue
      begin
        return value.clone
      rescue
        return value
      end
    end

    def p41d_setup_signature(actor)
      return nil if actor == nil
      passive = {}
      [:passive_params, :passive_params_rate, :passive_arrays, :passive_effects].each do |name|
        value = actor.instance_variable_get("@#{name}") rescue nil
        passive[name] = p41d_deep_copy(value)
      end
      return {
        :object_id=>actor.object_id,
        :actor_id=>(actor.id.to_i rescue 0),
        :class_id=>(actor.class_id.to_i rescue (actor.instance_variable_get(:@class_id).to_i rescue 0)),
        :level=>(actor.level.to_i rescue (actor.instance_variable_get(:@level).to_i rescue 0)),
        :exp=>p41d_exp(actor),
        :hp=>(actor.hp.to_i rescue 0), :mp=>(actor.mp.to_i rescue 0),
        :raw_skills=>p41d_raw_skill_ids(actor),
        :all_skills=>p41c_skill_ids(actor),
        :equips=>p37_equip_signature(actor),
        :unnatural=>p41c_unnatural_skill_ids(actor),
        :overdrive=>(actor.instance_variable_get(:@overdrive) rescue nil),
        :drive_type=>(actor.instance_variable_get(:@drive_type) rescue nil),
        :class_jp=>p41d_deep_copy((actor.instance_variable_get(:@class_jp) rescue nil)),
        :skill_level=>p41d_deep_copy((actor.instance_variable_get(:@skill_level) rescue nil)),
        :extra_armor=>p41d_deep_copy((actor.instance_variable_get(:@extra_armor_id) rescue nil)),
        :locked_equips=>p41d_deep_copy((actor.instance_variable_get(:@locked_equips) rescue nil)),
        :passive=>passive
      }
    rescue Exception => e
      exception(e, "p41d_setup_signature")
      return nil
    end

    def p41d_global_actor_signature(actor)
      return nil if actor == nil
      return [actor.object_id,
              (actor.class_id.to_i rescue 0),
              (actor.level.to_i rescue 0),
              p41d_exp(actor), p41d_raw_skill_ids(actor),
              p37_equip_signature(actor), (actor.hp.to_i rescue 0), (actor.mp.to_i rescue 0)]
    rescue
      return nil
    end

    def p41d_find_mutation_skill(excluded)
      1.upto($data_skills.size - 1) do |id|
        next if $data_skills[id] == nil
        next if excluded.include?(id)
        return id
      end
      return nil
    rescue
      return nil
    end

    def p41d_run_actor_setup_fixture
      actor_id = 1
      data = $data_actors[actor_id] rescue nil
      formal_actor = $game_actors[actor_id] rescue nil
      assert("Actor setup fixture data exists", data != nil, "actor_id=#{actor_id}")
      assert("Actor setup fixture formal actor exists", formal_actor != nil, "actor_id=#{actor_id}")
      return false if data == nil || formal_actor == nil

      party_before = Marshal.dump($game_party) rescue nil
      formal_before = p41d_global_actor_signature(formal_actor)

      detached = nil
      p41d_setup_trace_begin
      begin
        detached = Game_Actor.new(actor_id)
      ensure
        create_events = p41d_setup_trace_end
      end
      assert("Actor setup detached instance created", detached != nil,
             detached == nil ? "nil" : "oid=#{detached.object_id}")
      return false if detached == nil
      assert("Actor setup detached instance does not replace formal $game_actors entry",
             detached.object_id != formal_actor.object_id,
             "detached=#{detached.object_id} formal=#{formal_actor.object_id}")
      assert("Actor setup detached instance is not added to Party",
             !$game_party.members.include?(detached),
             "party=#{$game_party.members.collect { |a| a.id }.inspect}")
      p41d_assert_setup_trace("create", create_events)

      baseline = p41d_setup_signature(detached)
      expected_raw = p41d_expected_raw_skills(detached, actor_id)
      provider_ids = p41d_equipped_provider_skill_ids(detached)
      log("[ACTOR_SETUP] create actor=#{actor_id}:#{data.name} oid=#{detached.object_id} " +
          "class=#{baseline[:class_id]} level=#{baseline[:level]} exp=#{baseline[:exp]} " +
          "raw=#{baseline[:raw_skills].inspect} all=#{baseline[:all_skills].inspect} " +
          "equips=#{baseline[:equips].inspect} providers=#{provider_ids.inspect} events=#{create_events.inspect}")

      assert_equal("Actor setup class matches database", data.class_id.to_i, baseline[:class_id])
      assert_equal("Actor setup level matches database initial level", data.initial_level.to_i, baseline[:level])
      exp_list = detached.instance_variable_get(:@exp_list) rescue nil
      expected_exp = exp_list.is_a?(Array) ? exp_list[baseline[:level].to_i].to_i : baseline[:exp]
      assert_equal("Actor setup EXP matches generated level table", expected_exp, baseline[:exp])
      assert("Actor setup raw learned skills match class/runtime/teaching authorities",
             baseline[:raw_skills] == expected_raw,
             "expected=#{expected_raw.inspect} actual=#{baseline[:raw_skills].inspect}")
      assert("Actor setup equipment-provided skills are visible without requiring raw learning",
             provider_ids.all? { |id| baseline[:all_skills].include?(id) },
             "providers=#{provider_ids.inspect} all=#{baseline[:all_skills].inspect}")
      if defined?(FS_DB_RUNTIME_SUPPORT) &&
         FS_DB_RUNTIME_SUPPORT.const_defined?("STEAL_SKILL_ID")
        steal_id = FS_DB_RUNTIME_SUPPORT::STEAL_SKILL_ID.to_i
        assert("Actor setup RuntimeSupport grants Joey steal skill",
               baseline[:raw_skills].include?(steal_id),
               "steal=#{steal_id} raw=#{baseline[:raw_skills].inspect}")
      end
      assert("Actor setup OverDrive reset applied", baseline[:overdrive].to_i == 0,
             "overdrive=#{baseline[:overdrive].inspect}")
      class_jp = detached.instance_variable_get(:@class_jp) rescue nil
      assert("Actor setup JobBase class JP initialized",
             class_jp.is_a?(Hash) && class_jp[baseline[:class_id]].to_i == 0,
             "class_jp=#{class_jp.inspect}")
      skill_level = detached.instance_variable_get(:@skill_level) rescue nil
      assert("Actor setup SkillLevels cache initialized", skill_level.is_a?(Hash) && skill_level.empty?,
             "skill_level=#{skill_level.inspect}")
      assert("Actor setup EquipmentOverhaul runtime arrays initialized",
             (detached.instance_variable_get(:@extra_armor_id) rescue nil).is_a?(Array) &&
             (detached.instance_variable_get(:@locked_equips) rescue nil).is_a?(Array),
             "extra=#{(detached.instance_variable_get(:@extra_armor_id) rescue nil).inspect} " +
             "locked=#{(detached.instance_variable_get(:@locked_equips) rescue nil).inspect}")
      passive_ok = [:passive_params, :passive_params_rate, :passive_arrays, :passive_effects].all? do |name|
        (detached.instance_variable_get("@#{name}") rescue nil).is_a?(Hash)
      end
      assert("Actor setup PassiveSkill runtime caches initialized", passive_ok,
             "passive_effects=#{(detached.instance_variable_get(:@passive_effects) rescue nil).inspect}")

      fake_skill = p41d_find_mutation_skill((baseline[:raw_skills] + provider_ids).uniq)
      assert("Actor setup reset mutation skill resolved", fake_skill != nil,
             "excluded=#{(baseline[:raw_skills] + provider_ids).uniq.inspect}")
      return false if fake_skill == nil

      # 污染 detached actor，然後用正式 setup 重設同一 object。
      detached.learn_skill(fake_skill) if detached.respond_to?(:learn_skill)
      detached.instance_variable_set(:@level, [baseline[:level].to_i + 7, 99].min)
      detached.instance_variable_set(:@exp, baseline[:exp].to_i + 123456)
      detached.instance_variable_set(:@overdrive, 999)
      cjp = detached.instance_variable_get(:@class_jp) rescue nil
      cjp[baseline[:class_id]] = 777 if cjp.is_a?(Hash)
      slv = detached.instance_variable_get(:@skill_level) rescue nil
      slv[fake_skill] = 5 if slv.is_a?(Hash)
      detached.instance_variable_set(:@extra_armor_id, [999])
      detached.instance_variable_set(:@locked_equips, [999])
      unnatural = detached.instance_variable_get(:@unnatural_skills) rescue nil
      unnatural << fake_skill if unnatural.is_a?(Array) && !unnatural.include?(fake_skill)
      dirty = p41d_setup_signature(detached)
      log("[ACTOR_SETUP] dirty oid=#{detached.object_id} level=#{dirty[:level]} exp=#{dirty[:exp]} " +
          "raw=#{dirty[:raw_skills].inspect} overdrive=#{dirty[:overdrive].inspect}")

      p41d_setup_trace_begin
      begin
        detached.setup(actor_id)
      ensure
        reset_events = p41d_setup_trace_end
      end
      reset = p41d_setup_signature(detached)
      log("[ACTOR_SETUP] reset actor=#{actor_id}:#{data.name} oid=#{detached.object_id} " +
          "class=#{reset[:class_id]} level=#{reset[:level]} exp=#{reset[:exp]} " +
          "raw=#{reset[:raw_skills].inspect} all=#{reset[:all_skills].inspect} " +
          "equips=#{reset[:equips].inspect} events=#{reset_events.inspect}")
      p41d_assert_setup_trace("reset", reset_events)
      assert("Actor setup reset preserves detached object identity",
             reset[:object_id] == baseline[:object_id],
             "before=#{baseline[:object_id]} after=#{reset[:object_id]}")
      comparable_keys = [:actor_id, :class_id, :level, :exp, :hp, :mp, :raw_skills,
                         :all_skills, :equips, :unnatural, :overdrive, :drive_type,
                         :class_jp, :skill_level, :extra_armor, :locked_equips, :passive]
      comparable_keys.each do |key|
        assert("Actor setup reset restores #{key}", reset[key] == baseline[key],
               "before=#{baseline[key].inspect} dirty=#{dirty[key].inspect} after=#{reset[key].inspect}")
      end
      assert("Actor setup reset removes injected raw skill",
             !reset[:raw_skills].include?(fake_skill),
             "fake_skill=#{fake_skill} raw=#{reset[:raw_skills].inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      formal_after = p41d_global_actor_signature(formal_actor)
      assert("Actor setup detached fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Actor setup detached fixture does not mutate formal $game_actors[1]",
             formal_after == formal_before,
             "before=#{formal_before.inspect} after=#{formal_after.inspect}")

      @p41d_setup_fixture = {
        :actor_id=>actor_id, :create_events=>create_events, :reset_events=>reset_events,
        :provider_skill_ids=>provider_ids, :fake_skill=>fake_skill,
        :ready=>reset[:object_id] == baseline[:object_id] && reset[:raw_skills] == baseline[:raw_skills] &&
                formal_after == formal_before && party_before != nil && party_after == party_before
      }
      assert("Actor setup chain regression completed", @p41d_setup_fixture[:ready] == true,
             @p41d_setup_fixture.inspect)
      return @p41d_setup_fixture[:ready] == true
    rescue Exception => e
      @p41d_setup_trace_active = false
      exception(e, "p41d_run_actor_setup_fixture")
      assert("Actor setup chain regression completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase41d_prepare_battle_fixture_on_map_base)
      alias fs_phase41d_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase41d_prepare_battle_fixture_on_map_base
      return p41d_run_actor_setup_fixture
    end

    unless method_defined?(:fs_phase41d_restore_pending_base)
      alias fs_phase41d_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase41d_restore_pending_base
      if result
        @p41d_setup_trace_active = false
        @p41d_setup_events = []
        @p41d_setup_fixture = nil
      end
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only setup-chain wrappers。只在 trace active 時記錄，正常 Test Play 行為不變。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:setup) && !method_defined?(:fs_p41d_trace_setup_final_base)
      alias fs_p41d_trace_setup_final_base setup
      def setup(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :setup_final_begin)
        result = fs_p41d_trace_setup_final_base(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :setup_final_end)
        return result
      end
    end

    if method_defined?(:fs_db_runtime_setup) && !method_defined?(:fs_p41d_trace_runtime_support_base)
      alias fs_p41d_trace_runtime_support_base fs_db_runtime_setup
      def fs_db_runtime_setup(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :runtime_support)
        return fs_p41d_trace_runtime_support_base(actor_id)
      end
    end

    if method_defined?(:albert_eqskill_setup_final) && !method_defined?(:fs_p41d_trace_equipment_skill_base)
      alias fs_p41d_trace_equipment_skill_base albert_eqskill_setup_final
      def albert_eqskill_setup_final(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :equipment_skill)
        return fs_p41d_trace_equipment_skill_base(actor_id)
      end
    end

    if method_defined?(:setup_jpsl) && !method_defined?(:fs_p41d_trace_skill_levels_base)
      alias fs_p41d_trace_skill_levels_base setup_jpsl
      def setup_jpsl(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :skill_levels)
        return fs_p41d_trace_skill_levels_base(actor_id)
      end
    end

    if method_defined?(:setup_eo) && !method_defined?(:fs_p41d_trace_equipment_overhaul_base)
      alias fs_p41d_trace_equipment_overhaul_base setup_eo
      def setup_eo(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :equipment_overhaul)
        return fs_p41d_trace_equipment_overhaul_base(actor_id)
      end
    end

    if method_defined?(:setup_KGC_PassiveSkill) && !method_defined?(:fs_p41d_trace_passive_skill_base)
      alias fs_p41d_trace_passive_skill_base setup_KGC_PassiveSkill
      def setup_KGC_PassiveSkill(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :passive_skill)
        return fs_p41d_trace_passive_skill_base(actor_id)
      end
    end

    if method_defined?(:setup_actor_jpbase) && !method_defined?(:fs_p41d_trace_job_base)
      alias fs_p41d_trace_job_base setup_actor_jpbase
      def setup_actor_jpbase(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :job_base)
        return fs_p41d_trace_job_base(actor_id)
      end
    end

    if method_defined?(:setup_KGC_OverDrive) && !method_defined?(:fs_p41d_trace_overdrive_base)
      alias fs_p41d_trace_overdrive_base setup_KGC_OverDrive
      def setup_KGC_OverDrive(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :overdrive)
        return fs_p41d_trace_overdrive_base(actor_id)
      end
    end

    if method_defined?(:rx_rgss2bs1_setup) && !method_defined?(:fs_p41d_trace_rx_base)
      alias fs_p41d_trace_rx_base rx_rgss2bs1_setup
      def rx_rgss2bs1_setup(actor_id)
        FS_TEST_HARNESS.p41d_record_setup(self, :rx_base)
        return fs_p41d_trace_rx_base(actor_id)
      end
    end

    if method_defined?(:albert_refresh_equipment_teaching_skills) && !method_defined?(:fs_p41d_trace_teaching_refresh_base)
      alias fs_p41d_trace_teaching_refresh_base albert_refresh_equipment_teaching_skills
      def albert_refresh_equipment_teaching_skills
        FS_TEST_HARNESS.p41d_record_setup(self, :teaching_refresh)
        return fs_p41d_trace_teaching_refresh_base
      end
    end

    if method_defined?(:albert_refresh_equipment_passive_skills) && !method_defined?(:fs_p41d_trace_passive_refresh_base)
      alias fs_p41d_trace_passive_refresh_base albert_refresh_equipment_passive_skills
      def albert_refresh_equipment_passive_skills
        FS_TEST_HARNESS.p41d_record_setup(self, :passive_refresh)
        return fs_p41d_trace_passive_refresh_base
      end
    end
  end
end


#==============================================================================
# ■ Phase42A｜Equipment Slot Topology Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：驗證 YEM Equipment Overhaul#equip_type= 的結構性卸裝仍走正式 change_equip
# Authority chain，並且不污染正式 Actor / Party / 全域 TYPE_LIST。
#==============================================================================
module FS_TEST_HARNESS
  @p42a_equipment_topology = nil

  class << self
    def p42a_types(actor)
      value = actor == nil ? nil : (actor.equip_type rescue nil)
      return [] unless value.is_a?(Array)
      return value.clone
    rescue
      return []
    end

    def p42a_rightmost_armor_slot(actor, armor)
      return nil if actor == nil || armor == nil
      return nil unless defined?(YEM) && defined?(YEM::EQUIP) && YEM::EQUIP.const_defined?("TYPE_RULES")
      types = p42a_types(actor)
      index = nil
      types.each_with_index do |type, i|
        rule = YEM::EQUIP::TYPE_RULES[type] rescue nil
        next if rule == nil
        index = i if armor.is_a?(RPG::Armor) && armor.kind.to_i == rule[1].to_i
      end
      return nil if index == nil
      return index + 1
    rescue
      return nil
    end

    def p42a_restore_party_item_count(item, expected)
      return false if item == nil || $game_party == nil
      current = $game_party.item_number(item).to_i
      delta = expected.to_i - current
      return true if delta == 0
      suppressed = false
      begin
        if $game_party.respond_to?(:fs_nitem_suppress_begin)
          $game_party.fs_nitem_suppress_begin
          suppressed = true
        end
        if delta > 0
          $game_party.gain_item(item, delta)
        else
          $game_party.lose_item(item, -delta)
        end
      ensure
        if suppressed && $game_party.respond_to?(:fs_nitem_suppress_end)
          $game_party.fs_nitem_suppress_end
        end
      end
      return $game_party.item_number(item).to_i == expected.to_i
    rescue
      return false
    end

    def p42a_run_equipment_topology_fixture
      soul = @p37_soul_prebattle
      assert("Equipment topology SoulMark metadata exists", soul != nil && soul[:ready] == true)
      return false if soul == nil || !soul[:ready]

      actor_id = soul[:actor_id].to_i
      armor = $data_armors[soul[:armor_id]] rescue nil
      formal_actor = $game_actors[actor_id] rescue nil
      assert("Equipment topology provider/formal actor resolved", armor != nil && formal_actor != nil,
             "actor=#{actor_id} armor=#{soul[:armor_id]}")
      return false if armor == nil || formal_actor == nil

      provider_ids = []
      begin
        provider_ids = armor.skills.compact.collect { |skill| skill.id.to_i }.uniq.sort
      rescue
        provider_ids = []
      end
      assert("Equipment topology provider exposes equipskill set", !provider_ids.empty?,
             "armor=#{armor.id}:#{armor.name} providers=#{provider_ids.inspect}")
      return false if provider_ids.empty?

      party_before = Marshal.dump($game_party) rescue nil
      formal_before = p41d_global_actor_signature(formal_actor)
      global_types_before = (YEM::EQUIP::TYPE_LIST.clone rescue nil)
      armor_count_before = $game_party.item_number(armor).to_i
      new_before = p41c_new_flag(armor)

      detached = Game_Actor.new(actor_id)
      detached_baseline_equips = p37_equip_signature(detached)
      detached_baseline_skills = p41c_skill_ids(detached)
      detached_baseline_raw = p41c_raw_skill_map(detached, provider_ids)
      detached_baseline_unnatural = p41c_unnatural_skill_ids(detached)
      original_types = p42a_types(detached)
      provider_slot = p42a_rightmost_armor_slot(detached, armor)
      assert("Equipment topology detached actor created", detached != nil,
             "actor=#{actor_id}")
      assert("Equipment topology formal type list resolved", !original_types.empty? && provider_slot != nil,
             "types=#{original_types.inspect} provider_slot=#{provider_slot.inspect} armor_kind=#{armor.kind}")
      return false if original_types.empty? || provider_slot == nil
      assert("Equipment topology provider uses final formal armor slot",
             provider_slot.to_i == original_types.size,
             "slot=#{provider_slot} armor_slots=#{original_types.size} types=#{original_types.inspect}")
      return false unless provider_slot.to_i == original_types.size

      # test=true：只在 detached actor 建立 provider baseline，不碰 Party inventory。
      detached.change_equip(provider_slot, armor, true)
      equipped_before_shrink = p37_equipped_item?(detached, armor)
      skills_before_shrink = p41c_skill_ids(detached)
      raw_before_shrink = p41c_raw_skill_map(detached, provider_ids)
      assert("Equipment topology test-equip installs provider in detached final slot", equipped_before_shrink,
             "slot=#{provider_slot} equips=#{p37_equip_signature(detached).inspect}")
      assert("Equipment topology provider skills visible before structural shrink",
             provider_ids.all? { |id| skills_before_shrink.include?(id) },
             "providers=#{provider_ids.inspect} skills=#{skills_before_shrink.inspect}")
      assert("Equipment topology test-equip does not consume Party inventory",
             $game_party.item_number(armor).to_i == armor_count_before,
             "before=#{armor_count_before} after=#{$game_party.item_number(armor)}")

      new_types = original_types[0, original_types.size - 1]
      p41c_trace_begin
      begin
        detached.equip_type = new_types
      ensure
        shrink_events = p41c_trace_end
      end
      after_shrink_skills = p41c_skill_ids(detached)
      after_shrink_raw = p41c_raw_skill_map(detached, provider_ids)
      after_shrink_unnatural = p41c_unnatural_skill_ids(detached)
      log("[EQUIP_TOPOLOGY] shrink actor=#{actor_id} slot=#{provider_slot} " +
          "types=#{original_types.inspect}->#{p42a_types(detached).inspect} events=#{shrink_events.inspect} " +
          "providers=#{provider_ids.inspect}->#{provider_ids.select { |id| after_shrink_skills.include?(id) }.inspect} " +
          "inventory=#{armor_count_before}->#{$game_party.item_number(armor)} new=#{new_before.inspect}->#{p41c_new_flag(armor).inspect}")

      p41c_assert_refresh_trace("topology shrink", shrink_events)
      assert("Equipment topology setter removes exactly the deleted final armor slot",
             p42a_types(detached) == new_types && !p37_equipped_item?(detached, armor),
             "types=#{p42a_types(detached).inspect} equips=#{p37_equip_signature(detached).inspect}")
      assert("Equipment topology structural removal drops provider skills",
             !provider_ids.any? { |id| after_shrink_skills.include?(id) },
             "providers=#{provider_ids.inspect} skills=#{after_shrink_skills.inspect}")
      assert("Equipment topology structural removal preserves raw learned provider state",
             after_shrink_raw == raw_before_shrink,
             "before=#{raw_before_shrink.inspect} after=#{after_shrink_raw.inspect}")
      assert("Equipment topology structural removal preserves teaching ownership markers",
             after_shrink_unnatural == detached_baseline_unnatural,
             "before=#{detached_baseline_unnatural.inspect} after=#{after_shrink_unnatural.inspect}")
      assert("Equipment topology shrink preserves original weapon / earlier slots",
             (p37_equip_signature(detached)[0] rescue nil) == (detached_baseline_equips[0] rescue nil),
             "before=#{detached_baseline_equips.inspect} after=#{p37_equip_signature(detached).inspect}")
      assert_equal("Equipment topology structural unequip returns provider armor to Party",
                   armor_count_before + 1, $game_party.item_number(armor).to_i)
      assert("Equipment topology structural unequip preserves NEW flag",
             p41c_new_flag(armor) == new_before,
             "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")
      assert("Equipment topology global TYPE_LIST remains unchanged during shrink",
             global_types_before != nil && (YEM::EQUIP::TYPE_LIST rescue nil) == global_types_before,
             "before=#{global_types_before.inspect} after=#{(YEM::EQUIP::TYPE_LIST rescue nil).inspect}")

      inventory_restored = p42a_restore_party_item_count(armor, armor_count_before)
      assert("Equipment topology compensates detached structural inventory through formal Party API",
             inventory_restored,
             "expected=#{armor_count_before} actual=#{$game_party.item_number(armor)}")
      assert("Equipment topology compensation preserves NEW flag",
             p41c_new_flag(armor) == new_before,
             "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

      # 恢復欄位拓樸；擴張欄位本身不應憑空重裝 provider。
      detached.equip_type = original_types
      assert("Equipment topology restores original equip_type array",
             p42a_types(detached) == original_types,
             "expected=#{original_types.inspect} actual=#{p42a_types(detached).inspect}")
      assert("Equipment topology expansion does not auto-restore removed provider",
             !p37_equipped_item?(detached, armor) &&
             !provider_ids.any? { |id| p41c_skill_ids(detached).include?(id) },
             "equips=#{p37_equip_signature(detached).inspect} skills=#{p41c_skill_ids(detached).inspect}")

      detached.change_equip(provider_slot, armor, true)
      assert("Equipment topology provider can be reinstalled after topology restore",
             p37_equipped_item?(detached, armor) &&
             provider_ids.all? { |id| p41c_skill_ids(detached).include?(id) },
             "slot=#{provider_slot} skills=#{p41c_skill_ids(detached).inspect}")
      detached.change_equip(provider_slot, nil, true)
      assert("Equipment topology detached actor returns to original equip baseline",
             p37_equip_signature(detached) == detached_baseline_equips &&
             p41c_skill_ids(detached) == detached_baseline_skills &&
             p41c_raw_skill_map(detached, provider_ids) == detached_baseline_raw,
             "equips=#{p37_equip_signature(detached).inspect} skills=#{p41c_skill_ids(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      formal_after = p41d_global_actor_signature(formal_actor)
      assert("Equipment topology detached fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Equipment topology detached fixture does not mutate formal $game_actors actor",
             formal_after == formal_before,
             "before=#{formal_before.inspect} after=#{formal_after.inspect}")
      assert("Equipment topology final global TYPE_LIST remains byte/state identical",
             global_types_before != nil && (YEM::EQUIP::TYPE_LIST rescue nil) == global_types_before,
             "before=#{global_types_before.inspect} after=#{(YEM::EQUIP::TYPE_LIST rescue nil).inspect}")

      @p42a_equipment_topology = {
        :actor_id=>actor_id, :armor_id=>armor.id.to_i, :provider_slot=>provider_slot.to_i,
        :original_types=>original_types, :shrunk_types=>new_types,
        :shrink_events=>shrink_events, :provider_skill_ids=>provider_ids,
        :ready=>party_before != nil && party_after == party_before && formal_after == formal_before &&
                p42a_types(detached) == original_types &&
                (YEM::EQUIP::TYPE_LIST rescue nil) == global_types_before
      }
      assert("Equipment slot topology regression completed", @p42a_equipment_topology[:ready] == true,
             @p42a_equipment_topology.inspect)
      return @p42a_equipment_topology[:ready] == true
    rescue Exception => e
      @p41c_trace_active = false
      begin
        if armor != nil && armor_count_before != nil
          p42a_restore_party_item_count(armor, armor_count_before)
        end
      rescue
      end
      exception(e, "p42a_run_equipment_topology_fixture")
      assert("Equipment slot topology regression completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase42a_prepare_battle_fixture_on_map_base)
      alias fs_phase42a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase42a_prepare_battle_fixture_on_map_base
      return p42a_run_equipment_topology_fixture
    end

    unless method_defined?(:fs_phase42a_restore_pending_base)
      alias fs_phase42a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase42a_restore_pending_base
      @p42a_equipment_topology = nil if result
      return result
    end
  end
end


#==============================================================================
# ■ Phase42D｜Equipment Teaching / Level-Up Ownership Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：驗證 Modern Algebra \ls[skill, level] 暫時教學技能跨入自然學習等級後，
# @unnatural_skills ownership 會正確解除，後續卸裝不得把已自然學會技能忘掉。
#==============================================================================
module FS_TEST_HARNESS
  @p42d_equipment_teaching = nil

  class << self
    def p42c_learning_signature(learning)
      return nil if learning == nil
      return [learning.skill_id.to_i, learning.level.to_i]
    rescue
      return nil
    end

    def p42c_find_future_learning(actor)
      return nil if actor == nil || actor.class == nil
      current = actor.level.to_i
      max_level = 99
      begin
        data_actor = actor.actor
        max_level = data_actor.final_level.to_i if data_actor != nil && data_actor.respond_to?(:final_level)
      rescue
      end
      max_level = 99 if max_level <= 0
      list = actor.class.learnings.select do |learning|
        next false if learning == nil
        sid = learning.skill_id.to_i
        lvl = learning.level.to_i
        sid > 0 && lvl > current && lvl <= max_level && $data_skills[sid] != nil
      end
      list.sort_by { |learning| [learning.level.to_i, learning.skill_id.to_i] }.each do |learning|
        sid = learning.skill_id.to_i
        return learning unless p37_raw_skill_learned?(actor, sid)
      end
      return nil
    rescue
      return nil
    end

    # Phase42D：正式資料庫不存在可用的 future Class learning Fixture 樣本，改以 TEST-only synthetic learning
    # 進入同一個 Formal Runtime。候選掃描不碰 $game_actors，只建立 detached Game_Actor。
    def p42d_synthetic_skill_id(actor, klass)
      return nil if actor == nil || klass == nil || $data_skills == nil
      existing_learning_ids = []
      klass.learnings.each do |learning|
        next if learning == nil
        sid = learning.skill_id.to_i
        existing_learning_ids << sid if sid > 0
      end
      current_skill_ids = p41c_skill_ids(actor)
      $data_skills.compact.each do |skill|
        next if skill == nil || skill.id.to_i <= 0
        sid = skill.id.to_i
        next if existing_learning_ids.include?(sid)
        next if p37_raw_skill_learned?(actor, sid)
        next if current_skill_ids.include?(sid)
        note = skill.note.to_s
        next if note =~ /<(?:PASSIVE_SKILL|passive_skill)>/i
        next if note =~ /<レベル依存:/
        name = skill.name.to_s
        next if name.strip.empty?
        next if name =~ /----/
        visible = name.gsub(/[\s\-_=:]+/, '')
        next if visible.empty?
        return sid
      end
      return nil
    rescue
      return nil
    end

    def p42d_prepare_synthetic_learning_fixture
      return nil if $data_actors == nil || $data_classes == nil || $data_skills == nil
      $data_actors.compact.each do |data_actor|
        next if data_actor == nil || data_actor.id.to_i <= 0
        actor_id = data_actor.id.to_i
        class_id = data_actor.class_id.to_i rescue 0
        klass = (class_id > 0 ? $data_classes[class_id] : nil) rescue nil
        next if klass == nil || !klass.respond_to?(:learnings) || klass.learnings == nil
        initial_level = data_actor.initial_level.to_i rescue 1
        final_level = data_actor.final_level.to_i rescue 99
        initial_level = 1 if initial_level <= 0
        final_level = 99 if final_level <= 0
        next unless initial_level < final_level
        detached = Game_Actor.new(actor_id) rescue nil
        next if detached == nil
        skill_id = p42d_synthetic_skill_id(detached, klass)
        next if skill_id == nil
        natural_level = initial_level + 1
        next if natural_level > final_level
        begin
          before_dump = Marshal.dump(klass.learnings)
          array_oid = klass.learnings.object_id
          synthetic = RPG::Class::Learning.new
          synthetic.level = natural_level
          synthetic.skill_id = skill_id
          klass.learnings << synthetic
        rescue
          next
        end
        return {
          :actor_id=>actor_id, :class_id=>class_id, :skill_id=>skill_id,
          :natural_level=>natural_level, :pre_level=>initial_level, :initial_level=>initial_level,
          :klass=>klass, :synthetic_learning=>synthetic,
          :learnings_before_dump=>before_dump, :learnings_array_oid=>array_oid
        }
      end
      return nil
    rescue
      return nil
    end

    def p42d_restore_synthetic_learning_fixture(fixture)
      return false if fixture == nil
      klass = fixture[:klass]
      synthetic = fixture[:synthetic_learning]
      return false if klass == nil || synthetic == nil || !klass.respond_to?(:learnings)
      list = klass.learnings
      target_oid = synthetic.object_id
      list.delete_if { |learning| learning != nil && learning.object_id == target_oid }
      same_array = list.object_id == fixture[:learnings_array_oid].to_i
      same_dump = false
      begin
        same_dump = Marshal.dump(list) == fixture[:learnings_before_dump]
      rescue
        same_dump = false
      end
      return same_array && same_dump
    rescue
      return false
    end

    def p42c_instantiated_actor_objects
      result = []
      begin
        data = $game_actors.instance_variable_get(:@data)
        if data.is_a?(Array)
          data.each do |actor|
            result << actor if actor.is_a?(Game_Actor)
          end
        elsif data.respond_to?(:each)
          data.each do |key, actor|
            result << actor if actor.is_a?(Game_Actor)
          end
        end
      rescue
      end
      begin
        $game_party.members.each do |actor|
          result << actor if actor.is_a?(Game_Actor)
        end
      rescue
      end
      return result.compact.uniq
    rescue
      return []
    end

    def p42c_formal_equipped_armor_ids
      ids = []
      p42c_instantiated_actor_objects.each do |actor|
        begin
          actor.equips.compact.each do |item|
            ids << item.id.to_i if item.is_a?(RPG::Armor)
          end
        rescue
        end
      end
      return ids.uniq
    rescue
      return []
    end

    def p42c_clean_teaching_armor(actor)
      return [nil, nil] if actor == nil || $data_armors == nil
      formal_ids = p42c_formal_equipped_armor_ids
      $data_armors.compact.each do |armor|
        next if armor == nil || armor.id.to_i <= 0
        next if formal_ids.include?(armor.id.to_i)
        note = armor.note.to_s
        next if note =~ /\\ls\[/i
        next if note =~ /<(?:EQUIPMENTSKILL|equipskill):/i
        next if note =~ /<combo_/i
        next if note =~ /<fs_(?:soulmark|resonance_headgear)/i
        slot = p37_find_armor_slot(actor, armor)
        next if slot == nil
        begin
          next unless actor.equippable?(armor)
        rescue
          next
        end
        begin
          next unless actor.equips[slot] == nil
        rescue
          next
        end
        return [armor, slot]
      end
      return [nil, nil]
    rescue
      return [nil, nil]
    end

    def p42c_set_level_for_fixture(actor, level)
      return false if actor == nil
      target = level.to_i
      return false if target <= 0
      actor.instance_variable_set(:@level, target)
      begin
        exp_list = actor.instance_variable_get(:@exp_list)
        if exp_list.is_a?(Array) && exp_list[target] != nil
          actor.instance_variable_set(:@exp, exp_list[target].to_i)
        end
      rescue
      end
      return actor.level.to_i == target
    rescue
      return false
    end

    def p42c_level_refresh_trace_ok(events)
      tags = p41c_event_tags(events)
      teach_i = tags.index(:teaching)
      passive_i = tags.index(:passive)
      combo_i = tags.index(:combo)
      ok = teach_i != nil && passive_i != nil && teach_i < passive_i && combo_i == nil
      assert("Equipment teaching level_up refresh owns teaching/passive but not Combo", ok,
             "events=#{events.inspect}")
      return ok
    rescue Exception => e
      exception(e, "p42c_level_refresh_trace_ok")
      assert("Equipment teaching level_up refresh trace completed", false, e.message)
      return false
    end

    # Phase42E：記錄／還原 Game_Party 原生 inventory Hash slot。
    # RGSS2 gain_item 在數量歸零時保留 key=>0；detached Fixture 若原先沒有該 key，
    # 正式 API 雖恢復 item_number，Marshal 仍會留下結構差異。
    def p42e_inventory_container_info(item)
      return [nil, nil] if item == nil || $game_party == nil
      ivar = nil
      ivar = :@items if item.is_a?(RPG::Item)
      ivar = :@weapons if item.is_a?(RPG::Weapon)
      ivar = :@armors if item.is_a?(RPG::Armor)
      return [nil, nil] if ivar == nil
      container = $game_party.instance_variable_get(ivar) rescue nil
      return [ivar, container]
    rescue
      return [nil, nil]
    end

    def p42e_inventory_slot_snapshot(item)
      ivar, container = p42e_inventory_container_info(item)
      return nil unless container.is_a?(Hash)
      id = item.id.to_i
      return {
        :ivar=>ivar, :container_oid=>container.object_id, :item_id=>id,
        :had_key=>container.has_key?(id), :raw=>container[id]
      }
    rescue
      return nil
    end

    def p42e_restore_inventory_slot(item, snapshot)
      return false if item == nil || snapshot == nil
      ivar, container = p42e_inventory_container_info(item)
      return false unless ivar == snapshot[:ivar] && container.is_a?(Hash)
      return false unless container.object_id == snapshot[:container_oid].to_i
      id = snapshot[:item_id].to_i
      if snapshot[:had_key]
        container[id] = snapshot[:raw]
      else
        # 只刪除 Fixture 自己造成、且數量已經由正式 API 回到 0 的 tombstone。
        return false if container.has_key?(id) && container[id].to_i != 0
        container.delete(id)
      end
      same_key = container.has_key?(id) == (snapshot[:had_key] ? true : false)
      same_raw = snapshot[:had_key] ? (container[id] == snapshot[:raw]) : !container.has_key?(id)
      return same_key && same_raw
    rescue
      return false
    end

    # Phase42H：PassiveSkill TEST-only synthetic Skill slot。
    # 不再修改正式 $data_skills 中原 Skill object 的 Note/cache。先 Marshal clone 一份測試 Skill，
    # synthetic Passive 只寫 clone，再暫時讓同一個 $data_skills Array slot 指向 clone。
    # Fixture 結束前把 slot 指回原本完全未被修改的 Skill object，因此 object identity / Marshal bytes
    # 天然可精確還原，也避免猜測其他腳本可能建立的額外 cache ivar。
    def p42f_passive_cache_ivars
      return [:@__passive, :@__passive_params, :@__passive_params_rate,
              :@__passive_arrays, :@__passive_effects]
    end

    def p42h_prepare_synthetic_skill_slot(skill_id)
      return nil if $data_skills == nil
      id = skill_id.to_i
      original = $data_skills[id] rescue nil
      return nil if original == nil
      original_dump = Marshal.dump(original) rescue nil
      return nil if original_dump == nil
      synthetic = Marshal.load(original_dump) rescue nil
      return nil if synthetic == nil
      return {
        :skill_id=>id, :data_array_oid=>$data_skills.object_id,
        :original=>original, :original_oid=>original.object_id, :original_dump=>original_dump,
        :synthetic=>synthetic, :synthetic_oid=>synthetic.object_id, :active=>false
      }
    rescue
      return nil
    end

    def p42h_activate_synthetic_skill_slot(slot)
      return false if slot == nil || $data_skills == nil
      return false unless $data_skills.object_id == slot[:data_array_oid].to_i
      id = slot[:skill_id].to_i
      return false unless ($data_skills[id] rescue nil).object_id == slot[:original_oid].to_i
      $data_skills[id] = slot[:synthetic]
      slot[:active] = true
      return ($data_skills[id] rescue nil).object_id == slot[:synthetic_oid].to_i
    rescue
      return false
    end

    def p42h_restore_synthetic_skill_slot(slot)
      return false if slot == nil || $data_skills == nil
      return false unless $data_skills.object_id == slot[:data_array_oid].to_i
      id = slot[:skill_id].to_i
      current = $data_skills[id] rescue nil
      return false if current == nil
      current_oid = current.object_id
      return false unless current_oid == slot[:synthetic_oid].to_i || current_oid == slot[:original_oid].to_i
      $data_skills[id] = slot[:original]
      slot[:active] = false
      restored = $data_skills[id] rescue nil
      return false if restored == nil || restored.object_id != slot[:original_oid].to_i
      dump = Marshal.dump(restored) rescue nil
      return dump != nil && dump == slot[:original_dump]
    rescue
      return false
    end

    def p42f_clear_skill_passive_cache(skill)
      return false if skill == nil
      # synthetic clone 可安全清 cache；正式資料庫 Skill object 從頭到尾不會進入這裡。
      p42f_passive_cache_ivars.each do |ivar|
        begin
          skill.instance_variable_set(ivar, nil)
        rescue
          return false
        end
      end
      return true
    rescue
      return false
    end

    def p42f_apply_synthetic_passive(skill)
      return false if skill == nil
      note = skill.note.to_s
      block = "<PASSIVE_SKILL>\nATK +37\nDEF +13\nCRITICAL_BONUS\n</PASSIVE_SKILL>"
      skill.note = note + (note.empty? ? "" : "\n") + block
      p42f_clear_skill_passive_cache(skill)
      return skill.passive == true && skill.passive_params[:atk].to_i == 37 &&
             skill.passive_params[:def].to_i == 13 &&
             skill.passive_effects[:critical_bonus] == true
    rescue
      return false
    end

    def p42f_passive_signature(actor)
      return nil if actor == nil || !actor.respond_to?(:restore_passive_rev)
      return {
        :atk=>actor.passive_params[:atk].to_i,
        :def=>actor.passive_params[:def].to_i,
        :critical_bonus=>(actor.passive_effects[:critical_bonus] == true),
        :base_atk=>actor.base_atk.to_i,
        :base_def=>actor.base_def.to_i,
        :cri=>actor.cri.to_i
      }
    rescue
      return nil
    end

    def p42f_assert_passive_temp_delta(label, baseline, current, active)
      ok = baseline != nil && current != nil
      if ok && active
        ok &&= current[:atk].to_i == baseline[:atk].to_i + 37
        ok &&= current[:def].to_i == baseline[:def].to_i + 13
        ok &&= current[:critical_bonus] == true
        ok &&= current[:base_atk].to_i == baseline[:base_atk].to_i + 37
        ok &&= current[:base_def].to_i == baseline[:base_def].to_i + 13
        ok &&= current[:cri].to_i == baseline[:cri].to_i + 4
      elsif ok
        ok = current == baseline
      end
      assert("Equipment passive #{label}", ok,
             "baseline=#{baseline.inspect} current=#{current.inspect} active=#{active}")
      return ok
    rescue Exception => e
      exception(e, "p42f_assert_passive_temp_delta")
      assert("Equipment passive #{label}", false, e.message)
      return false
    end

    def p42d_run_equipment_teaching_fixture
      soul = @p37_soul_prebattle
      assert("Equipment teaching SoulMark/prebattle metadata exists", soul != nil && soul[:ready] == true)
      return false if soul == nil || !soul[:ready]

      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fixture = p42d_prepare_synthetic_learning_fixture
      assert("Equipment teaching synthetic Class learning fixture prepared", fixture != nil,
             "data_actors=#{($data_actors == nil ? 0 : $data_actors.compact.size)}")
      return false if fixture == nil

      scan_party_after = Marshal.dump($game_party) rescue nil
      scan_actors_after = Marshal.dump($game_actors) rescue nil
      assert("Equipment teaching synthetic candidate preparation does not mutate Game_Party",
             party_before != nil && scan_party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{scan_party_after == nil ? 'nil' : scan_party_after.size}")
      assert("Equipment teaching synthetic candidate preparation does not instantiate/mutate $game_actors",
             actors_before != nil && scan_actors_after == actors_before,
             "bytes_before=#{actors_before == nil ? 'nil' : actors_before.size} bytes_after=#{scan_actors_after == nil ? 'nil' : scan_actors_after.size}")

      actor_id = fixture[:actor_id].to_i
      detached = Game_Actor.new(actor_id)
      detached_baseline = p41d_global_actor_signature(detached)
      detached_baseline_unnatural = p41c_unnatural_skill_ids(detached)
      skill_id = fixture[:skill_id].to_i
      natural_level = fixture[:natural_level].to_i
      pre_level = fixture[:pre_level].to_i
      learning = detached.class.learnings.select do |entry|
        entry != nil && entry.skill_id.to_i == skill_id && entry.level.to_i == natural_level
      end[0] rescue nil
      assert("Equipment teaching synthetic Class learning resolves on detached Actor", learning != nil &&
             learning.object_id == fixture[:synthetic_learning].object_id,
             "class=#{detached.class_id} initial=#{detached.level} skill=#{skill_id} natural=#{natural_level}")
      return false if learning == nil
      assert("Equipment teaching synthetic Class learning preserves learnings Array identity during fixture",
             detached.class.learnings.object_id == fixture[:learnings_array_oid].to_i,
             "before_oid=#{fixture[:learnings_array_oid]} actual_oid=#{detached.class.learnings.object_id}")
      log("[EQUIP_TEACHING_SELECT] synthetic=true actor=#{actor_id}:#{detached.name} class=#{detached.class_id} " +
          "initial=#{detached.level} skill=#{skill_id} natural=#{natural_level} pre=#{pre_level} " +
          "learning_oid=#{learning.object_id} array_oid=#{detached.class.learnings.object_id}")
      original_skill = $data_skills[skill_id] rescue nil
      assert("Equipment teaching target skill / threshold resolved",
             original_skill != nil && pre_level >= detached.level.to_i,
             "learning=#{p42c_learning_signature(learning).inspect} current=#{detached.level} pre=#{pre_level}")
      return false if original_skill == nil || pre_level < detached.level.to_i

      skill_slot = p42h_prepare_synthetic_skill_slot(skill_id)
      assert("Equipment passive target Skill clone/database-slot baseline captured",
             skill_slot != nil && skill_slot[:original_oid].to_i == original_skill.object_id &&
             skill_slot[:synthetic_oid].to_i != skill_slot[:original_oid].to_i,
             "skill=#{skill_id}:#{original_skill.name}")
      return false if skill_slot == nil
      skill = skill_slot[:synthetic]
      passive_injected = p42f_apply_synthetic_passive(skill)
      assert("Equipment passive synthetic Skill clone parses formal PassiveSkill effects", passive_injected,
             "skill=#{skill_id}:#{skill.name} passive=#{(skill.passive rescue nil).inspect} " +
             "params=#{(skill.passive_params rescue nil).inspect} effects=#{(skill.passive_effects rescue nil).inspect}")
      return false unless passive_injected
      skill_slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Equipment passive synthetic Skill clone owns temporary database slot",
             skill_slot_active && ($data_skills[skill_id] rescue nil).object_id == skill.object_id,
             "original_oid=#{skill_slot[:original_oid]} synthetic_oid=#{skill.object_id} " +
             "array_oid=#{$data_skills == nil ? 'nil' : $data_skills.object_id}")
      return false unless skill_slot_active

      level_prepared = p42c_set_level_for_fixture(detached, pre_level)
      assert("Equipment teaching detached actor prepared exactly one level below natural learning",
             level_prepared && detached.level.to_i == pre_level,
             "target=#{pre_level} actual=#{detached.level}")
      return false unless level_prepared
      assert("Equipment teaching target is not natural before level-up",
             !detached.albert_natural_level_skill?(skill_id),
             "skill=#{skill_id}:#{skill.name} level=#{detached.level} natural=#{natural_level}")
      assert("Equipment teaching target absent from raw learned list before equip",
             !p37_raw_skill_learned?(detached, skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
      passive_baseline = p42f_passive_signature(detached)
      assert("Equipment passive synthetic Skill does not affect Actor before learning",
             passive_baseline != nil && passive_baseline[:atk].to_i == 0 && passive_baseline[:def].to_i == 0 &&
             passive_baseline[:critical_bonus] == false,
             "baseline=#{passive_baseline.inspect}")

      armor, slot = p42c_clean_teaching_armor(detached)
      assert("Equipment teaching clean formal Armor / legal slot resolved", armor != nil && slot != nil,
             "actor=#{actor_id} level=#{detached.level}")
      return false if armor == nil || slot == nil

      note_before = armor.note.to_s.dup
      armor_count_before = $game_party.item_number(armor).to_i
      inventory_slot_before = p42e_inventory_slot_snapshot(armor)
      assert("Equipment teaching Party inventory slot baseline captured", inventory_slot_before != nil,
             "armor=#{armor.id}:#{armor.name}")
      new_before = p41c_new_flag(armor)
      raw_before = p37_raw_skill_learned?(detached, skill_id)
      marker_before = p41c_unnatural_skill_ids(detached)
      formal_equipped_armor_ids = p42c_formal_equipped_armor_ids
      assert("Equipment teaching candidate is not equipped by any instantiated formal Actor",
             !formal_equipped_armor_ids.include?(armor.id.to_i),
             "armor=#{armor.id}:#{armor.name} formal_armor_ids=#{formal_equipped_armor_ids.inspect}")

      tag = "\\ls[#{skill_id}, #{pre_level}]"
      armor.note = note_before + (note_before.empty? ? "" : "\n") + tag
      parsed = armor.skill_ids rescue nil
      assert("Equipment teaching temporary Note parser resolves exact boundary tag",
             parsed != nil && parsed.include?([skill_id, pre_level]),
             "armor=#{armor.id}:#{armor.name} tag=#{tag.inspect} parsed=#{parsed.inspect}")

      # 正式提供一件裝備；suppression 只避免測試準備本身改動 NEW indicator。
      grant_ok = p42a_restore_party_item_count(armor, armor_count_before + 1)
      assert("Equipment teaching prerequisite Armor granted through formal Party API", grant_ok,
             "expected=#{armor_count_before + 1} actual=#{$game_party.item_number(armor)}")
      assert("Equipment teaching prerequisite grant preserves NEW flag",
             p41c_new_flag(armor) == new_before,
             "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

      p41c_trace_begin
      begin
        detached.change_equip(slot, armor)
      ensure
        equip_events = p41c_trace_end
      end
      log("[EQUIP_TEACHING] equip actor=#{actor_id} armor=#{armor.id}:#{armor.name} slot=#{slot} " +
          "skill=#{skill_id}:#{skill.name} level=#{detached.level}/natural#{natural_level} events=#{equip_events.inspect} " +
          "raw=#{p37_raw_skill_learned?(detached, skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      p41c_assert_refresh_trace("teaching equip", equip_events)
      assert("Equipment teaching Armor formally equipped", p37_equipped_item?(detached, armor),
             "equips=#{p37_equip_signature(detached).inspect}")
      assert("Equipment teaching boundary level learns skill into raw list",
             p37_raw_skill_learned?(detached, skill_id),
             "skill=#{skill_id} raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      assert("Equipment teaching temporary ownership marker created before natural level",
             p41c_unnatural_skill_ids(detached).include?(skill_id),
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      assert_equal("Equipment teaching equip consumes exactly prepared Armor", armor_count_before,
                   $game_party.item_number(armor).to_i)
      passive_after_equip = p42f_passive_signature(detached)
      p42f_assert_passive_temp_delta("temporary teaching activates passive effect", passive_baseline, passive_after_equip, true)

      # 自然學會前先正式卸裝一次：teaching 必須先 forget temporary skill，再由 passive refresh 清回 baseline。
      p41c_trace_begin
      begin
        detached.change_equip(slot, nil)
      ensure
        temp_remove_events = p41c_trace_end
      end
      log("[EQUIP_PASSIVE] temp_remove actor=#{actor_id} skill=#{skill_id}:#{skill.name} " +
          "events=#{temp_remove_events.inspect} raw=#{p37_raw_skill_learned?(detached, skill_id)} " +
          "markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{p42f_passive_signature(detached).inspect}")
      p41c_assert_refresh_trace("passive temporary remove", temp_remove_events)
      assert("Equipment passive temporary unequip forgets equipment-owned skill",
             !p37_raw_skill_learned?(detached, skill_id) && !p41c_skill_ids(detached).include?(skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} all=#{p41c_skill_ids(detached).inspect}")
      assert("Equipment passive temporary ownership marker released on unequip",
             !p41c_unnatural_skill_ids(detached).include?(skill_id),
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      passive_after_temp_remove = p42f_passive_signature(detached)
      p42f_assert_passive_temp_delta("temporary unequip restores passive baseline", passive_baseline, passive_after_temp_remove, false)
      assert_equal("Equipment passive temporary unequip returns Armor exactly once", armor_count_before + 1,
                   $game_party.item_number(armor).to_i)

      # 同一件正式重裝，證明 refresh chain 可重建 teaching + passive ownership。
      p41c_trace_begin
      begin
        detached.change_equip(slot, armor)
      ensure
        passive_reequip_events = p41c_trace_end
      end
      log("[EQUIP_PASSIVE] re_equip actor=#{actor_id} skill=#{skill_id}:#{skill.name} " +
          "events=#{passive_reequip_events.inspect} raw=#{p37_raw_skill_learned?(detached, skill_id)} " +
          "markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{p42f_passive_signature(detached).inspect}")
      p41c_assert_refresh_trace("passive re-equip", passive_reequip_events)
      assert("Equipment passive re-equip relearns temporary skill",
             p37_raw_skill_learned?(detached, skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      assert("Equipment passive re-equip restores temporary ownership marker",
             p41c_unnatural_skill_ids(detached).include?(skill_id),
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      passive_after_reequip = p42f_passive_signature(detached)
      p42f_assert_passive_temp_delta("re-equip reactivates passive effect", passive_baseline, passive_after_reequip, true)
      assert_equal("Equipment passive re-equip consumes returned Armor", armor_count_before,
                   $game_party.item_number(armor).to_i)

      p41c_trace_begin
      begin
        detached.level_up
      ensure
        level_events = p41c_trace_end
      end
      log("[EQUIP_TEACHING] level_up actor=#{actor_id} skill=#{skill_id}:#{skill.name} " +
          "level=#{pre_level}->#{detached.level} natural=#{detached.albert_natural_level_skill?(skill_id)} " +
          "raw=#{p37_raw_skill_learned?(detached, skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect} " +
          "events=#{level_events.inspect}")
      p42c_level_refresh_trace_ok(level_events)
      assert_equal("Equipment teaching level_up reaches natural learning threshold", natural_level, detached.level.to_i)
      assert("Equipment teaching skill is formally natural after level_up",
             detached.albert_natural_level_skill?(skill_id),
             "skill=#{skill_id} level=#{detached.level} natural=#{natural_level}")
      assert("Equipment teaching natural transition keeps raw learned skill",
             p37_raw_skill_learned?(detached, skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      assert("Equipment teaching natural transition releases temporary ownership marker",
             !p41c_unnatural_skill_ids(detached).include?(skill_id),
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      passive_after_natural = p42f_passive_signature(detached)
      assert("Equipment passive remains active after temporary ownership becomes natural",
             passive_after_natural != nil &&
             passive_after_natural[:atk].to_i == passive_baseline[:atk].to_i + 37 &&
             passive_after_natural[:def].to_i == passive_baseline[:def].to_i + 13 &&
             passive_after_natural[:critical_bonus] == true,
             "baseline=#{passive_baseline.inspect} natural=#{passive_after_natural.inspect}")

      p41c_trace_begin
      begin
        detached.change_equip(slot, nil)
      ensure
        remove_events = p41c_trace_end
      end
      log("[EQUIP_TEACHING] remove actor=#{actor_id} armor=#{armor.id}:#{armor.name} skill=#{skill_id}:#{skill.name} " +
          "events=#{remove_events.inspect} raw=#{p37_raw_skill_learned?(detached, skill_id)} " +
          "markers=#{p41c_unnatural_skill_ids(detached).inspect} inventory=#{$game_party.item_number(armor)}")
      p41c_assert_refresh_trace("teaching remove after natural", remove_events)
      assert("Equipment teaching Armor formally removed after natural transition",
             !p37_equipped_item?(detached, armor),
             "equips=#{p37_equip_signature(detached).inspect}")
      assert("Equipment teaching natural skill survives later unequip",
             p37_raw_skill_learned?(detached, skill_id) && p41c_skill_ids(detached).include?(skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} all=#{p41c_skill_ids(detached).inspect}")
      assert("Equipment teaching ownership marker stays released after unequip",
             !p41c_unnatural_skill_ids(detached).include?(skill_id),
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")
      passive_after_natural_remove = p42f_passive_signature(detached)
      assert("Equipment passive natural skill effect survives later equipment removal",
             passive_after_natural_remove == passive_after_natural,
             "before=#{passive_after_natural.inspect} after=#{passive_after_natural_remove.inspect}")
      assert_equal("Equipment teaching unequip returns Armor exactly once", armor_count_before + 1,
                   $game_party.item_number(armor).to_i)

      inventory_restored = p42a_restore_party_item_count(armor, armor_count_before)
      assert("Equipment teaching detached inventory side effect compensated through formal Party API",
             inventory_restored,
             "expected=#{armor_count_before} actual=#{$game_party.item_number(armor)}")
      assert("Equipment teaching inventory compensation preserves NEW flag",
             p41c_new_flag(armor) == new_before,
             "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

      ivar_after_api, container_after_api = p42e_inventory_container_info(armor)
      raw_after_api = container_after_api.is_a?(Hash) ? container_after_api[armor.id.to_i] : nil
      key_after_api = container_after_api.is_a?(Hash) ? container_after_api.has_key?(armor.id.to_i) : nil
      log("[EQUIP_TEACHING_PARTY] after_formal_api armor=#{armor.id}:#{armor.name} " +
          "ivar=#{ivar_after_api.inspect} had_key_before=#{inventory_slot_before == nil ? 'nil' : inventory_slot_before[:had_key].inspect} " +
          "raw_before=#{inventory_slot_before == nil ? 'nil' : inventory_slot_before[:raw].inspect} " +
          "key_after=#{key_after_api.inspect} raw_after=#{raw_after_api.inspect}")
      inventory_slot_restored = p42e_restore_inventory_slot(armor, inventory_slot_before)
      assert("Equipment teaching TEST-only inventory tombstone cleanup restores exact Hash slot",
             inventory_slot_restored,
             "before=#{inventory_slot_before.inspect} after_key=#{key_after_api.inspect} after_raw=#{raw_after_api.inspect}")
      ivar_final, container_final = p42e_inventory_container_info(armor)
      log("[EQUIP_TEACHING_PARTY] cleanup armor=#{armor.id}:#{armor.name} ivar=#{ivar_final.inspect} " +
          "container_oid=#{container_final == nil ? 'nil' : container_final.object_id} " +
          "key=#{container_final.is_a?(Hash) ? container_final.has_key?(armor.id.to_i) : 'nil'} " +
          "raw=#{container_final.is_a?(Hash) ? container_final[armor.id.to_i].inspect : 'nil'}")

      skill_slot_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Equipment passive original Skill database slot/object/bytes restored exactly",
             skill_slot_restored,
             "skill=#{skill_id}:#{original_skill.name} original_oid=#{skill_slot[:original_oid]} " +
             "current_oid=#{(($data_skills[skill_id] rescue nil) == nil ? 'nil' : ($data_skills[skill_id] rescue nil).object_id)}")

      armor.note = note_before
      assert("Equipment teaching temporary Armor Note restored byte-for-byte",
             armor.note.to_s == note_before,
             "armor=#{armor.id}:#{armor.name}")

      learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
      assert("Equipment teaching synthetic Class learning restored byte/state exact before battle",
             learning_restored,
             "class=#{fixture[:class_id]} array_oid=#{fixture[:klass].learnings.object_id} expected_oid=#{fixture[:learnings_array_oid]}")

      detached.setup(actor_id)
      assert("Equipment teaching detached actor reset to original setup baseline",
             p41d_global_actor_signature(detached) == detached_baseline &&
             p41c_unnatural_skill_ids(detached) == detached_baseline_unnatural,
             "before=#{detached_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect} " +
             "markers=#{p41c_unnatural_skill_ids(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      assert("Equipment teaching detached fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Equipment teaching detached fixture does not instantiate/mutate $game_actors",
             actors_before != nil && actors_after == actors_before,
             "bytes_before=#{actors_before == nil ? 'nil' : actors_before.size} bytes_after=#{actors_after == nil ? 'nil' : actors_after.size}")
      assert("Equipment teaching final candidate Note remains restored",
             armor.note.to_s == note_before,
             "armor=#{armor.id}:#{armor.name}")
      assert("Equipment teaching final Class learning Array remains restored",
             p42d_restore_synthetic_learning_fixture(fixture),
             "class=#{fixture[:class_id]} array_oid=#{fixture[:klass].learnings.object_id}")

      @p42d_equipment_teaching = {
        :actor_id=>actor_id, :class_id=>fixture[:class_id].to_i, :armor_id=>armor.id.to_i, :slot=>slot.to_i,
        :skill_id=>skill_id, :initial_level=>fixture[:initial_level].to_i,
        :pre_level=>pre_level, :natural_level=>natural_level,
        :equip_events=>equip_events, :level_events=>level_events, :remove_events=>remove_events,
        :synthetic=>true, :inventory_slot_restored=>inventory_slot_restored,
        :skill_slot_restored=>skill_slot_restored,
        :temp_remove_events=>temp_remove_events, :passive_reequip_events=>passive_reequip_events,
        :ready=>inventory_slot_restored == true && skill_slot_restored == true && party_before != nil && party_after == party_before &&
                actors_before != nil && actors_after == actors_before && armor.note.to_s == note_before &&
                p41d_global_actor_signature(detached) == detached_baseline && p42d_restore_synthetic_learning_fixture(fixture)
      }
      assert("Equipment teaching / level-up ownership regression completed",
             @p42d_equipment_teaching[:ready] == true,
             @p42d_equipment_teaching.inspect)
      return @p42d_equipment_teaching[:ready] == true
    rescue Exception => e
      @p41c_trace_active = false
      begin
        p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
      rescue
      end
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      begin
        armor.note = note_before if armor != nil && note_before != nil
      rescue
      end
      begin
        p42a_restore_party_item_count(armor, armor_count_before) if armor != nil && armor_count_before != nil
        p42e_restore_inventory_slot(armor, inventory_slot_before) if armor != nil && inventory_slot_before != nil
      rescue
      end
      exception(e, "p42d_run_equipment_teaching_fixture")
      assert("Equipment teaching / level-up ownership regression completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase42d_prepare_battle_fixture_on_map_base)
      alias fs_phase42d_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase42d_prepare_battle_fixture_on_map_base
      return p42d_run_equipment_teaching_fixture
    end

    unless method_defined?(:fs_phase42d_restore_pending_base)
      alias fs_phase42d_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase42d_restore_pending_base
      @p42d_equipment_teaching = nil if result
      return result
    end
  end
end


#==============================================================================
# ■ Phase42J｜Equipment Teaching Multi-Provider Passive Authority Isolation Regression Fixture
#------------------------------------------------------------------------------
# TEST-only：驗證兩件裝備同時以 \\ls 提供同一技能時，移除其中一個 provider
# 不得誤刪仍由另一個 provider 持有的 temporary skill / Passive；反向卸除亦同。
#==============================================================================
module FS_TEST_HARNESS
  @p42i_multi_provider = nil

  class << self
    def p42i_clean_teaching_armor_pair(actor)
      return [nil, nil, nil, nil] if actor == nil || $data_armors == nil
      formal_ids = p42c_formal_equipped_armor_ids
      candidates = []
      $data_armors.compact.each do |armor|
        next if armor == nil || armor.id.to_i <= 0
        next if formal_ids.include?(armor.id.to_i)
        note = armor.note.to_s
        next if note =~ /\\ls\[/i
        next if note =~ /<(?:EQUIPMENTSKILL|equipskill):/i
        next if note =~ /<combo_/i
        next if note =~ /<fs_(?:soulmark|resonance_headgear)/i
        slot = p37_find_armor_slot(actor, armor)
        next if slot == nil
        begin
          next unless actor.equippable?(armor)
          next unless actor.equips[slot] == nil
        rescue
          next
        end
        candidates << [armor, slot.to_i]
      end
      0.upto(candidates.size - 1) do |i|
        a = candidates[i]
        (i + 1).upto(candidates.size - 1) do |j|
          b = candidates[j]
          next if a[0].id.to_i == b[0].id.to_i
          next if a[1].to_i == b[1].to_i
          return [a[0], a[1], b[0], b[1]]
        end
      end
      return [nil, nil, nil, nil]
    rescue
      return [nil, nil, nil, nil]
    end

    def p42i_marker_count(actor, skill_id)
      list = actor == nil ? nil : (actor.instance_variable_get(:@unnatural_skills) rescue nil)
      return 0 unless list.is_a?(Array)
      sid = skill_id.to_i
      return list.select { |value| value.to_i == sid }.size
    rescue
      return 0
    end

    # Phase42J：多 provider 重複 ownership 的判定必須看 Passive Authority 本身，
    # 不可直接比較 base_atk/base_def/cri 等最終 Actor 能力值，因為第二件裝備
    # 自己可能帶有 DEF/ATK/CRI。這裡只抽取 PassiveSkill refresh 產生的
    # ownership cache，證明同一 Skill 只被計算一次。
    def p42j_passive_authority_signature(signature)
      return nil unless signature.is_a?(Hash)
      return {
        :atk=>signature[:atk].to_i,
        :def=>signature[:def].to_i,
        :critical_bonus=>(signature[:critical_bonus] == true)
      }
    rescue
      return nil
    end

    def p42i_change_equip_with_trace(actor, slot, item, label)
      events = []
      p41c_trace_begin
      begin
        actor.change_equip(slot, item)
      ensure
        events = p41c_trace_end
      end
      p41c_assert_refresh_trace(label, events)
      return events
    rescue Exception => e
      @p41c_trace_active = false
      exception(e, "p42i_change_equip_with_trace_#{label}")
      assert("Equipment #{label} formal change_equip completed", false, e.message)
      return []
    end

    def p42i_run_multi_provider_fixture
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fixture = p42d_prepare_synthetic_learning_fixture
      assert("Equipment multi-provider synthetic learning fixture prepared", fixture != nil)
      return false if fixture == nil

      actor_id = fixture[:actor_id].to_i
      skill_id = fixture[:skill_id].to_i
      pre_level = fixture[:pre_level].to_i
      detached = Game_Actor.new(actor_id)
      detached_baseline = p41d_global_actor_signature(detached)
      detached_unnatural_baseline = p41c_unnatural_skill_ids(detached)

      skill_slot = p42h_prepare_synthetic_skill_slot(skill_id)
      assert("Equipment multi-provider synthetic Skill clone prepared", skill_slot != nil,
             "actor=#{actor_id} skill=#{skill_id}")
      return false if skill_slot == nil
      skill = skill_slot[:synthetic]
      passive_ok = p42f_apply_synthetic_passive(skill)
      assert("Equipment multi-provider synthetic Skill Passive parsed", passive_ok,
             "skill=#{skill_id}:#{skill.name}")
      return false unless passive_ok
      slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Equipment multi-provider synthetic Skill owns temporary database slot", slot_active,
             "skill=#{skill_id} original_oid=#{skill_slot[:original_oid]} synthetic_oid=#{skill_slot[:synthetic_oid]}")
      return false unless slot_active

      level_ok = p42c_set_level_for_fixture(detached, pre_level)
      assert("Equipment multi-provider detached Actor stays below natural threshold",
             level_ok && !detached.albert_natural_level_skill?(skill_id),
             "level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{skill_id}")
      return false unless level_ok && !detached.albert_natural_level_skill?(skill_id)
      detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
      passive_baseline = p42f_passive_signature(detached)
      assert("Equipment multi-provider passive baseline captured", passive_baseline != nil,
             passive_baseline.inspect)

      armor_a, slot_a, armor_b, slot_b = p42i_clean_teaching_armor_pair(detached)
      assert("Equipment multi-provider two clean Armors / distinct legal slots resolved",
             armor_a != nil && armor_b != nil && slot_a != nil && slot_b != nil && slot_a.to_i != slot_b.to_i,
             "actor=#{actor_id} slot_a=#{slot_a.inspect} slot_b=#{slot_b.inspect}")
      return false if armor_a == nil || armor_b == nil || slot_a == nil || slot_b == nil

      note_a = armor_a.note.to_s.dup
      note_b = armor_b.note.to_s.dup
      count_a = $game_party.item_number(armor_a).to_i
      count_b = $game_party.item_number(armor_b).to_i
      inv_a = p42e_inventory_slot_snapshot(armor_a)
      inv_b = p42e_inventory_slot_snapshot(armor_b)
      new_a = p41c_new_flag(armor_a)
      new_b = p41c_new_flag(armor_b)
      assert("Equipment multi-provider inventory baselines captured", inv_a != nil && inv_b != nil,
             "A=#{armor_a.id}:#{armor_a.name} B=#{armor_b.id}:#{armor_b.name}")

      tag = "\\ls[#{skill_id}, #{pre_level}]"
      armor_a.note = note_a + (note_a.empty? ? "" : "\n") + tag
      armor_b.note = note_b + (note_b.empty? ? "" : "\n") + tag
      parsed_a = armor_a.skill_ids rescue nil
      parsed_b = armor_b.skill_ids rescue nil
      assert("Equipment multi-provider both Armor Notes parse same teaching entry",
             parsed_a != nil && parsed_b != nil && parsed_a.include?([skill_id, pre_level]) && parsed_b.include?([skill_id, pre_level]),
             "A=#{parsed_a.inspect} B=#{parsed_b.inspect} tag=#{tag.inspect}")

      grant_a = p42a_restore_party_item_count(armor_a, count_a + 1)
      grant_b = p42a_restore_party_item_count(armor_b, count_b + 1)
      assert("Equipment multi-provider prerequisites granted through formal Party API",
             grant_a && grant_b && $game_party.item_number(armor_a).to_i == count_a + 1 &&
             $game_party.item_number(armor_b).to_i == count_b + 1,
             "A=#{$game_party.item_number(armor_a)} B=#{$game_party.item_number(armor_b)}")
      assert("Equipment multi-provider prerequisite grants preserve NEW flags",
             p41c_new_flag(armor_a) == new_a && p41c_new_flag(armor_b) == new_b,
             "A=#{new_a.inspect}->#{p41c_new_flag(armor_a).inspect} B=#{new_b.inspect}->#{p41c_new_flag(armor_b).inspect}")

      events_a1 = p42i_change_equip_with_trace(detached, slot_a, armor_a, "multi-provider equip A")
      sig_a1 = p42f_passive_signature(detached)
      assert("Equipment multi-provider A alone learns temporary skill once",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect}")
      p42f_assert_passive_temp_delta("multi-provider A alone activates one passive copy", passive_baseline, sig_a1, true)

      events_b1 = p42i_change_equip_with_trace(detached, slot_b, armor_b, "multi-provider equip B")
      sig_ab1 = p42f_passive_signature(detached)
      assert("Equipment multi-provider A+B keep a single temporary ownership marker",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1,
             "markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect}")
      auth_a1 = p42j_passive_authority_signature(sig_a1)
      auth_ab1 = p42j_passive_authority_signature(sig_ab1)
      log("[EQUIP_MULTI_PROVIDER] A->AB passive_authority=#{auth_a1.inspect}->#{auth_ab1.inspect} " +
          "final_base_atk=#{sig_a1[:base_atk]}->#{sig_ab1[:base_atk]} final_base_def=#{sig_a1[:base_def]}->#{sig_ab1[:base_def]}")
      assert("Equipment multi-provider duplicate providers keep exactly one Passive Authority copy",
             auth_ab1 == auth_a1,
             "A_auth=#{auth_a1.inspect} AB_auth=#{auth_ab1.inspect} A_final=#{sig_a1.inspect} AB_final=#{sig_ab1.inspect}")
      assert("Equipment multi-provider both Armors are formally equipped",
             p37_equipped_item?(detached, armor_a) && p37_equipped_item?(detached, armor_b),
             p37_equip_signature(detached).inspect)

      events_remove_a = p42i_change_equip_with_trace(detached, slot_a, nil, "multi-provider remove A first")
      sig_b_only = p42f_passive_signature(detached)
      assert("Equipment multi-provider removing A keeps B equipped",
             !p37_equipped_item?(detached, armor_a) && p37_equipped_item?(detached, armor_b),
             p37_equip_signature(detached).inspect)
      assert("Equipment multi-provider removing A does not forget skill still owned by B",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect}")
      auth_b_only = p42j_passive_authority_signature(sig_b_only)
      assert("Equipment multi-provider removing A preserves one-copy Passive Authority from B",
             auth_b_only == auth_a1,
             "expected_auth=#{auth_a1.inspect} actual_auth=#{auth_b_only.inspect} A_final=#{sig_a1.inspect} B_only_final=#{sig_b_only.inspect}")

      events_remove_b = p42i_change_equip_with_trace(detached, slot_b, nil, "multi-provider remove B last")
      sig_none1 = p42f_passive_signature(detached)
      assert("Equipment multi-provider removing last provider forgets temporary skill",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect}")
      assert("Equipment multi-provider removing last provider restores Passive baseline",
             sig_none1 == passive_baseline,
             "baseline=#{passive_baseline.inspect} actual=#{sig_none1.inspect}")

      # 反向卸除順序：重新裝 A+B，這次先移除 B，確認 provider order 不影響 ownership。
      events_a2 = p42i_change_equip_with_trace(detached, slot_a, armor_a, "multi-provider reverse equip A")
      events_b2 = p42i_change_equip_with_trace(detached, slot_b, armor_b, "multi-provider reverse equip B")
      sig_ab2 = p42f_passive_signature(detached)
      auth_ab2 = p42j_passive_authority_signature(sig_ab2)
      assert("Equipment multi-provider reverse cycle starts with one marker / one Passive Authority copy",
             p42i_marker_count(detached, skill_id) == 1 && auth_ab2 == auth_a1,
             "markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} expected_auth=#{auth_a1.inspect} actual_auth=#{auth_ab2.inspect} final=#{sig_ab2.inspect}")

      events_remove_b2 = p42i_change_equip_with_trace(detached, slot_b, nil, "multi-provider remove B first")
      sig_a_only = p42f_passive_signature(detached)
      assert("Equipment multi-provider removing B first keeps A ownership",
             p37_equipped_item?(detached, armor_a) && !p37_equipped_item?(detached, armor_b) &&
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1 && sig_a_only == sig_a1,
             "equips=#{p37_equip_signature(detached).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} passive=#{sig_a_only.inspect}")

      events_remove_a2 = p42i_change_equip_with_trace(detached, slot_a, nil, "multi-provider remove A last")
      sig_none2 = p42f_passive_signature(detached)
      assert("Equipment multi-provider reverse cycle last removal clears temporary ownership",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0 && sig_none2 == passive_baseline,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} passive=#{sig_none2.inspect}")

      assert_equal("Equipment multi-provider cycles return Armor A exactly once", count_a + 1,
                   $game_party.item_number(armor_a).to_i)
      assert_equal("Equipment multi-provider cycles return Armor B exactly once", count_b + 1,
                   $game_party.item_number(armor_b).to_i)

      restore_count_a = p42a_restore_party_item_count(armor_a, count_a)
      restore_count_b = p42a_restore_party_item_count(armor_b, count_b)
      assert("Equipment multi-provider inventory counts compensated through formal Party API",
             restore_count_a && restore_count_b,
             "A=#{$game_party.item_number(armor_a)} B=#{$game_party.item_number(armor_b)}")
      tomb_a = p42e_restore_inventory_slot(armor_a, inv_a)
      tomb_b = p42e_restore_inventory_slot(armor_b, inv_b)
      assert("Equipment multi-provider inventory Hash slots restored exactly", tomb_a && tomb_b,
             "A=#{inv_a.inspect} B=#{inv_b.inspect}")
      assert("Equipment multi-provider final NEW flags restored",
             p41c_new_flag(armor_a) == new_a && p41c_new_flag(armor_b) == new_b,
             "A=#{new_a.inspect}->#{p41c_new_flag(armor_a).inspect} B=#{new_b.inspect}->#{p41c_new_flag(armor_b).inspect}")

      armor_a.note = note_a
      armor_b.note = note_b
      assert("Equipment multi-provider both Armor Notes restored byte-for-byte",
             armor_a.note.to_s == note_a && armor_b.note.to_s == note_b,
             "A=#{armor_a.id} B=#{armor_b.id}")
      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Equipment multi-provider original Skill database slot/object/bytes restored", skill_restored,
             "skill=#{skill_id} original_oid=#{skill_slot[:original_oid]}")
      learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
      assert("Equipment multi-provider synthetic Class learning restored exactly", learning_restored,
             "class=#{fixture[:class_id]}")

      detached.setup(actor_id)
      actor_restored = p41d_global_actor_signature(detached) == detached_baseline &&
                       p41c_unnatural_skill_ids(detached) == detached_unnatural_baseline
      assert("Equipment multi-provider detached Actor baseline restored", actor_restored,
             "before=#{detached_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      assert("Equipment multi-provider fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Equipment multi-provider fixture does not instantiate/mutate $game_actors",
             actors_before != nil && actors_after == actors_before,
             "bytes_before=#{actors_before == nil ? 'nil' : actors_before.size} bytes_after=#{actors_after == nil ? 'nil' : actors_after.size}")

      @p42i_multi_provider = {
        :actor_id=>actor_id, :skill_id=>skill_id,
        :armor_a=>armor_a.id.to_i, :slot_a=>slot_a.to_i,
        :armor_b=>armor_b.id.to_i, :slot_b=>slot_b.to_i,
        :events=>{
          :equip_a1=>events_a1, :equip_b1=>events_b1,
          :remove_a1=>events_remove_a, :remove_b1=>events_remove_b,
          :equip_a2=>events_a2, :equip_b2=>events_b2,
          :remove_b2=>events_remove_b2, :remove_a2=>events_remove_a2
        },
        :ready=>tomb_a == true && tomb_b == true && skill_restored == true && learning_restored == true &&
                actor_restored == true && party_before != nil && party_after == party_before &&
                actors_before != nil && actors_after == actors_before && armor_a.note.to_s == note_a && armor_b.note.to_s == note_b
      }
      assert("Equipment multi-provider ownership regression completed",
             @p42i_multi_provider[:ready] == true,
             @p42i_multi_provider.inspect)
      return @p42i_multi_provider[:ready] == true
    rescue Exception => e
      @p41c_trace_active = false
      begin
        detached.change_equip(slot_a, nil) if detached != nil && armor_a != nil && p37_equipped_item?(detached, armor_a)
        detached.change_equip(slot_b, nil) if detached != nil && armor_b != nil && p37_equipped_item?(detached, armor_b)
      rescue
      end
      begin
        p42a_restore_party_item_count(armor_a, count_a) if armor_a != nil && count_a != nil
        p42a_restore_party_item_count(armor_b, count_b) if armor_b != nil && count_b != nil
        p42e_restore_inventory_slot(armor_a, inv_a) if armor_a != nil && inv_a != nil
        p42e_restore_inventory_slot(armor_b, inv_b) if armor_b != nil && inv_b != nil
      rescue
      end
      begin
        armor_a.note = note_a if armor_a != nil && note_a != nil
        armor_b.note = note_b if armor_b != nil && note_b != nil
      rescue
      end
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      begin
        p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
      rescue
      end
      exception(e, "p42i_run_multi_provider_fixture")
      assert("Equipment multi-provider ownership regression completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase42i_prepare_battle_fixture_on_map_base)
      alias fs_phase42i_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase42i_prepare_battle_fixture_on_map_base
      return p42i_run_multi_provider_fixture
    end

    unless method_defined?(:fs_phase42i_restore_pending_base)
      alias fs_phase42i_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase42i_restore_pending_base
      @p42i_multi_provider = nil if result
      return result
    end
  end
end


#==============================================================================
# 【Phase42K】Equipment Teaching × Direct EquipSkill Mixed Provider Ownership
#------------------------------------------------------------------------------
# TEST-only：同一技能同時由 Modern Algebra \ls 與 Shanghai <equipskill: ...>
# 兩種不同 ownership 提供時，驗證 raw learned / @unnatural_skills / Actor.skills /
# KGC PassiveSkill 的責任邊界不互相踩掉。正式 Runtime 不在本段修改。
#==============================================================================
module FS_TEST_HARNESS
  @p42k_mixed_provider = nil

  class << self
    def p42k_skill_list_count(actor, skill_id)
      return 0 if actor == nil
      sid = skill_id.to_i
      list = actor.skills rescue []
      return list.select { |skill| skill != nil && skill.id.to_i == sid }.size
    rescue
      return 0
    end

    def p42l_instance_variable_defined_compat?(object, ivar_name)
      return false if object == nil
      target = ivar_name.to_s
      vars = object.instance_variables rescue []
      return vars.collect { |var| var.to_s }.include?(target)
    rescue
      return false
    end

    def p42k_equipskill_cache_snapshot(item)
      return nil if item == nil
      had = p42l_instance_variable_defined_compat?(item, "@equipment_skills")
      value = had ? (item.instance_variable_get(:@equipment_skills) rescue nil) : nil
      return {
        :had=>had,
        :value=>value,
        :note=>item.note.to_s.dup,
        :dump=>(Marshal.dump(item) rescue nil),
        :oid=>item.object_id
      }
    rescue
      return nil
    end

    def p42k_invalidate_equipskill_cache(item, snapshot)
      return false if item == nil || snapshot == nil
      # 既存 slot 只設 nil，不 remove/re-add，保留 ivar order；原本無 slot 則讓正式 parser 自行建立。
      item.instance_variable_set(:@equipment_skills, nil) if snapshot[:had]
      return true
    rescue
      return false
    end

    def p42k_restore_equipskill_cache(item, snapshot)
      return false if item == nil || snapshot == nil
      item.note = snapshot[:note].to_s
      if snapshot[:had]
        item.instance_variable_set(:@equipment_skills, snapshot[:value])
      else
        if p42l_instance_variable_defined_compat?(item, "@equipment_skills")
          item.remove_instance_variable(:@equipment_skills)
        end
      end
      after = Marshal.dump(item) rescue nil
      return item.object_id == snapshot[:oid] && snapshot[:dump] != nil && after == snapshot[:dump]
    rescue
      return false
    end

    def p42k_skill_visible?(actor, skill_id)
      return p42k_skill_list_count(actor, skill_id) == 1
    rescue
      return false
    end

    def p42k_run_mixed_provider_fixture
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fixture = p42d_prepare_synthetic_learning_fixture
      assert("Equipment mixed-provider synthetic learning fixture prepared", fixture != nil)
      return false if fixture == nil

      actor_id = fixture[:actor_id].to_i
      skill_id = fixture[:skill_id].to_i
      pre_level = fixture[:pre_level].to_i
      detached = Game_Actor.new(actor_id)
      detached_baseline = p41d_global_actor_signature(detached)
      detached_unnatural_baseline = p41c_unnatural_skill_ids(detached)

      skill_slot = p42h_prepare_synthetic_skill_slot(skill_id)
      assert("Equipment mixed-provider synthetic Skill clone prepared", skill_slot != nil,
             "actor=#{actor_id} skill=#{skill_id}")
      return false if skill_slot == nil
      skill = skill_slot[:synthetic]
      passive_ok = p42f_apply_synthetic_passive(skill)
      assert("Equipment mixed-provider synthetic Skill Passive parsed", passive_ok,
             "skill=#{skill_id}:#{skill.name}")
      return false unless passive_ok
      slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Equipment mixed-provider synthetic Skill owns temporary database slot", slot_active,
             "skill=#{skill_id} original_oid=#{skill_slot[:original_oid]} synthetic_oid=#{skill_slot[:synthetic_oid]}")
      return false unless slot_active

      level_ok = p42c_set_level_for_fixture(detached, pre_level)
      assert("Equipment mixed-provider detached Actor stays below natural threshold",
             level_ok && !detached.albert_natural_level_skill?(skill_id),
             "level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{skill_id}")
      return false unless level_ok && !detached.albert_natural_level_skill?(skill_id)
      detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
      passive_baseline = p42f_passive_signature(detached)
      assert("Equipment mixed-provider passive baseline captured", passive_baseline != nil,
             passive_baseline.inspect)

      armor_a, slot_a, armor_b, slot_b = p42i_clean_teaching_armor_pair(detached)
      assert("Equipment mixed-provider Teaching/Direct Armors in distinct legal slots resolved",
             armor_a != nil && armor_b != nil && slot_a != nil && slot_b != nil && slot_a.to_i != slot_b.to_i,
             "actor=#{actor_id} slot_a=#{slot_a.inspect} slot_b=#{slot_b.inspect}")
      return false if armor_a == nil || armor_b == nil || slot_a == nil || slot_b == nil

      note_a = armor_a.note.to_s.dup
      note_b = armor_b.note.to_s.dup
      armor_b_cache = p42k_equipskill_cache_snapshot(armor_b)
      count_a = $game_party.item_number(armor_a).to_i
      count_b = $game_party.item_number(armor_b).to_i
      inv_a = p42e_inventory_slot_snapshot(armor_a)
      inv_b = p42e_inventory_slot_snapshot(armor_b)
      new_a = p41c_new_flag(armor_a)
      new_b = p41c_new_flag(armor_b)
      assert("Equipment mixed-provider inventory/cache baselines captured",
             inv_a != nil && inv_b != nil && armor_b_cache != nil,
             "A=#{armor_a.id}:#{armor_a.name} B=#{armor_b.id}:#{armor_b.name}")

      teaching_tag = "\\ls[#{skill_id}, #{pre_level}]"
      direct_tag = "<equipskill: #{skill_id}>"
      armor_a.note = note_a + (note_a.empty? ? "" : "\n") + teaching_tag
      armor_b.note = note_b + (note_b.empty? ? "" : "\n") + direct_tag
      cache_invalidated = p42k_invalidate_equipskill_cache(armor_b, armor_b_cache)
      parsed_a = armor_a.skill_ids rescue nil
      parsed_b = armor_b.skills rescue nil
      parsed_b_ids = parsed_b == nil ? [] : parsed_b.compact.collect { |s| s.id.to_i }
      assert("Equipment mixed-provider Teaching and Direct provider Notes parse exact same Skill",
             cache_invalidated && parsed_a != nil && parsed_a.include?([skill_id, pre_level]) && parsed_b_ids.include?(skill_id),
             "A=#{parsed_a.inspect} B=#{parsed_b_ids.inspect} teaching=#{teaching_tag.inspect} direct=#{direct_tag.inspect}")

      grant_a = p42a_restore_party_item_count(armor_a, count_a + 1)
      grant_b = p42a_restore_party_item_count(armor_b, count_b + 1)
      assert("Equipment mixed-provider prerequisites granted through formal Party API",
             grant_a && grant_b && $game_party.item_number(armor_a).to_i == count_a + 1 &&
             $game_party.item_number(armor_b).to_i == count_b + 1,
             "A=#{$game_party.item_number(armor_a)} B=#{$game_party.item_number(armor_b)}")
      assert("Equipment mixed-provider prerequisite grants preserve NEW flags",
             p41c_new_flag(armor_a) == new_a && p41c_new_flag(armor_b) == new_b,
             "A=#{new_a.inspect}->#{p41c_new_flag(armor_a).inspect} B=#{new_b.inspect}->#{p41c_new_flag(armor_b).inspect}")

      # Cycle 1：Teaching A → Direct B → remove Teaching first → remove Direct last
      events_a1 = p42i_change_equip_with_trace(detached, slot_a, armor_a, "mixed-provider equip Teaching A")
      sig_a = p42f_passive_signature(detached)
      auth_a = p42j_passive_authority_signature(sig_a)
      assert("Equipment mixed-provider Teaching A creates raw temporary ownership",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1 && p42k_skill_visible?(detached, skill_id),
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)}")
      p42f_assert_passive_temp_delta("mixed-provider Teaching A activates Passive", passive_baseline, sig_a, true)

      events_b1 = p42i_change_equip_with_trace(detached, slot_b, armor_b, "mixed-provider equip Direct B")
      sig_ab = p42f_passive_signature(detached)
      auth_ab = p42j_passive_authority_signature(sig_ab)
      assert("Equipment mixed-provider Teaching+Direct keep one visible Skill / one marker",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1 && p42k_skill_list_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)}")
      assert("Equipment mixed-provider Direct provider does not double-stack Passive Authority",
             auth_ab == auth_a,
             "A_auth=#{auth_a.inspect} AB_auth=#{auth_ab.inspect} A_final=#{sig_a.inspect} AB_final=#{sig_ab.inspect}")

      events_remove_a1 = p42i_change_equip_with_trace(detached, slot_a, nil, "mixed-provider remove Teaching A first")
      sig_b_only = p42f_passive_signature(detached)
      auth_b_only = p42j_passive_authority_signature(sig_b_only)
      assert("Equipment mixed-provider removing Teaching clears raw/marker but Direct keeps Skill visible",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0 &&
             p37_equipped_item?(detached, armor_b) && p42k_skill_list_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)}")
      assert("Equipment mixed-provider Direct-only provider preserves one-copy Passive Authority",
             auth_b_only == auth_a,
             "expected=#{auth_a.inspect} actual=#{auth_b_only.inspect} final=#{sig_b_only.inspect}")

      events_remove_b1 = p42i_change_equip_with_trace(detached, slot_b, nil, "mixed-provider remove Direct B last")
      sig_none1 = p42f_passive_signature(detached)
      assert("Equipment mixed-provider removing last Direct provider removes visibility and Passive",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0 &&
             p42k_skill_list_count(detached, skill_id) == 0 && sig_none1 == passive_baseline,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)} passive=#{sig_none1.inspect}")

      # Cycle 2：Direct B → Teaching A → remove Direct first → remove Teaching last
      events_b2 = p42i_change_equip_with_trace(detached, slot_b, armor_b, "mixed-provider reverse equip Direct B")
      sig_b_first = p42f_passive_signature(detached)
      auth_b_first = p42j_passive_authority_signature(sig_b_first)
      assert("Equipment mixed-provider Direct B alone grants visibility without raw/marker",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0 && p42k_skill_list_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)}")
      assert("Equipment mixed-provider Direct B alone activates one-copy Passive Authority",
             auth_b_first == auth_a,
             "expected=#{auth_a.inspect} actual=#{auth_b_first.inspect} final=#{sig_b_first.inspect}")

      events_a2 = p42i_change_equip_with_trace(detached, slot_a, armor_a, "mixed-provider reverse equip Teaching A")
      sig_ba = p42f_passive_signature(detached)
      auth_ba = p42j_passive_authority_signature(sig_ba)
      assert("Equipment mixed-provider adding Teaching to Direct creates exactly one raw marker",
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1 && p42k_skill_list_count(detached, skill_id) == 1,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)}")
      assert("Equipment mixed-provider reverse Teaching+Direct still one Passive Authority copy",
             auth_ba == auth_a,
             "expected=#{auth_a.inspect} actual=#{auth_ba.inspect} final=#{sig_ba.inspect}")

      events_remove_b2 = p42i_change_equip_with_trace(detached, slot_b, nil, "mixed-provider remove Direct B first")
      sig_a_only = p42f_passive_signature(detached)
      auth_a_only = p42j_passive_authority_signature(sig_a_only)
      assert("Equipment mixed-provider removing Direct first preserves Teaching raw/marker ownership",
             p37_equipped_item?(detached, armor_a) && !p37_equipped_item?(detached, armor_b) &&
             p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 1 && p42k_skill_list_count(detached, skill_id) == 1,
             "equips=#{p37_equip_signature(detached).inspect} raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect}")
      assert("Equipment mixed-provider Teaching-only remains one-copy Passive Authority",
             auth_a_only == auth_a,
             "expected=#{auth_a.inspect} actual=#{auth_a_only.inspect} final=#{sig_a_only.inspect}")

      events_remove_a2 = p42i_change_equip_with_trace(detached, slot_a, nil, "mixed-provider remove Teaching A last")
      sig_none2 = p42f_passive_signature(detached)
      assert("Equipment mixed-provider reverse last removal clears all temporary ownership",
             !p37_raw_skill_learned?(detached, skill_id) && p42i_marker_count(detached, skill_id) == 0 &&
             p42k_skill_list_count(detached, skill_id) == 0 && sig_none2 == passive_baseline,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{(detached.instance_variable_get(:@unnatural_skills) rescue []).inspect} visible=#{p42k_skill_list_count(detached, skill_id)} passive=#{sig_none2.inspect}")

      assert_equal("Equipment mixed-provider cycles return Teaching Armor exactly once", count_a + 1,
                   $game_party.item_number(armor_a).to_i)
      assert_equal("Equipment mixed-provider cycles return Direct Armor exactly once", count_b + 1,
                   $game_party.item_number(armor_b).to_i)

      restore_count_a = p42a_restore_party_item_count(armor_a, count_a)
      restore_count_b = p42a_restore_party_item_count(armor_b, count_b)
      assert("Equipment mixed-provider inventory counts compensated through formal Party API",
             restore_count_a && restore_count_b,
             "A=#{$game_party.item_number(armor_a)} B=#{$game_party.item_number(armor_b)}")
      tomb_a = p42e_restore_inventory_slot(armor_a, inv_a)
      tomb_b = p42e_restore_inventory_slot(armor_b, inv_b)
      assert("Equipment mixed-provider inventory Hash slots restored exactly", tomb_a && tomb_b,
             "A=#{inv_a.inspect} B=#{inv_b.inspect}")
      assert("Equipment mixed-provider final NEW flags restored",
             p41c_new_flag(armor_a) == new_a && p41c_new_flag(armor_b) == new_b,
             "A=#{new_a.inspect}->#{p41c_new_flag(armor_a).inspect} B=#{new_b.inspect}->#{p41c_new_flag(armor_b).inspect}")

      armor_a.note = note_a
      armor_a_restored = armor_a.note.to_s == note_a
      armor_b_restored = p42k_restore_equipskill_cache(armor_b, armor_b_cache)
      assert("Equipment mixed-provider Teaching Armor Note and Direct Armor Note/cache restored exactly",
             armor_a_restored && armor_b_restored,
             "A=#{armor_a.id} B=#{armor_b.id} B_cache_had=#{armor_b_cache[:had].inspect}")

      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Equipment mixed-provider original Skill database slot/object/bytes restored", skill_restored,
             "skill=#{skill_id} original_oid=#{skill_slot[:original_oid]}")
      learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
      assert("Equipment mixed-provider synthetic Class learning restored exactly", learning_restored,
             "class=#{fixture[:class_id]}")

      detached.setup(actor_id)
      actor_restored = p41d_global_actor_signature(detached) == detached_baseline &&
                       p41c_unnatural_skill_ids(detached) == detached_unnatural_baseline
      assert("Equipment mixed-provider detached Actor baseline restored", actor_restored,
             "before=#{detached_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      assert("Equipment mixed-provider fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Equipment mixed-provider fixture does not instantiate/mutate $game_actors",
             actors_before != nil && actors_after == actors_before,
             "bytes_before=#{actors_before == nil ? 'nil' : actors_before.size} bytes_after=#{actors_after == nil ? 'nil' : actors_after.size}")

      @p42k_mixed_provider = {
        :actor_id=>actor_id, :skill_id=>skill_id,
        :teaching_armor=>armor_a.id.to_i, :teaching_slot=>slot_a.to_i,
        :direct_armor=>armor_b.id.to_i, :direct_slot=>slot_b.to_i,
        :events=>{
          :teach_a1=>events_a1, :direct_b1=>events_b1,
          :remove_teach1=>events_remove_a1, :remove_direct1=>events_remove_b1,
          :direct_b2=>events_b2, :teach_a2=>events_a2,
          :remove_direct2=>events_remove_b2, :remove_teach2=>events_remove_a2
        },
        :ready=>tomb_a == true && tomb_b == true && armor_a_restored == true && armor_b_restored == true &&
                skill_restored == true && learning_restored == true && actor_restored == true &&
                party_before != nil && party_after == party_before && actors_before != nil && actors_after == actors_before
      }
      assert("Equipment mixed-provider ownership regression completed",
             @p42k_mixed_provider[:ready] == true,
             @p42k_mixed_provider.inspect)
      return @p42k_mixed_provider[:ready] == true
    rescue Exception => e
      @p41c_trace_active = false
      begin
        detached.change_equip(slot_a, nil) if detached != nil && armor_a != nil && p37_equipped_item?(detached, armor_a)
        detached.change_equip(slot_b, nil) if detached != nil && armor_b != nil && p37_equipped_item?(detached, armor_b)
      rescue
      end
      begin
        p42a_restore_party_item_count(armor_a, count_a) if armor_a != nil && count_a != nil
        p42a_restore_party_item_count(armor_b, count_b) if armor_b != nil && count_b != nil
        p42e_restore_inventory_slot(armor_a, inv_a) if armor_a != nil && inv_a != nil
        p42e_restore_inventory_slot(armor_b, inv_b) if armor_b != nil && inv_b != nil
      rescue
      end
      begin
        armor_a.note = note_a if armor_a != nil && note_a != nil
        p42k_restore_equipskill_cache(armor_b, armor_b_cache) if armor_b != nil && armor_b_cache != nil
      rescue
      end
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      begin
        p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
      rescue
      end
      exception(e, "p42k_run_mixed_provider_fixture")
      assert("Equipment mixed-provider ownership regression completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase42k_prepare_battle_fixture_on_map_base)
      alias fs_phase42k_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase42k_prepare_battle_fixture_on_map_base
      return p42k_run_mixed_provider_fixture
    end

    unless method_defined?(:fs_phase42k_restore_pending_base)
      alias fs_phase42k_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase42k_restore_pending_base
      @p42k_mixed_provider = nil if result
      return result
    end
  end
end

#==============================================================================
# ■ Phase43A｜Equipment / Setup Authority Convergence Audit
#------------------------------------------------------------------------------
# TEST-only diagnostic：不退休／不修改任何 Formal wrapper。
# 目前先驗證 discard_equip(extra slot) 的 Passive refresh ownership 時序。
#==============================================================================
module FS_TEST_HARNESS
  @p43a_convergence = nil
  @p43a_discard_trace_active = false
  @p43a_discard_trace_events = []
  @p43a_discard_target_armor_id = 0

  class << self
    def p43a_extra_slot_for_armor(actor, armor)
      return nil if actor == nil || armor == nil
      return nil unless defined?(YEM) && defined?(YEM::EQUIP) && YEM::EQUIP.const_defined?("TYPE_RULES")
      types = actor.equip_type rescue nil
      return nil unless types.is_a?(Array)
      types.each_with_index do |type, index|
        slot = index + 1
        next if slot < 5
        rule = YEM::EQUIP::TYPE_RULES[type] rescue nil
        next if rule == nil
        next unless armor.is_a?(RPG::Armor) && armor.kind.to_i == rule[1].to_i
        current = actor.equips[slot] rescue nil
        next unless current == nil
        return slot
      end
      return nil
    rescue
      return nil
    end

    def p43a_clean_extra_slot_armor(actor)
      return [nil, nil] if actor == nil || $data_armors == nil
      formal_ids = p42c_formal_equipped_armor_ids
      $data_armors.compact.each do |armor|
        next if armor == nil || armor.id.to_i <= 0
        next if formal_ids.include?(armor.id.to_i)
        note = armor.note.to_s
        next if note =~ /\\ls\[/i
        next if note =~ /<(?:EQUIPMENTSKILL|equipskill):/i
        next if note =~ /<combo_/i
        next if note =~ /<fs_(?:soulmark|resonance_headgear)/i
        slot = p43a_extra_slot_for_armor(actor, armor)
        next if slot == nil
        begin
          next unless actor.equippable?(armor)
        rescue
          next
        end
        return [armor, slot]
      end
      return [nil, nil]
    rescue
      return [nil, nil]
    end

    def p43a_discard_trace_begin(armor_id)
      @p43a_discard_trace_active = true
      @p43a_discard_trace_events = []
      @p43a_discard_target_armor_id = armor_id.to_i
    end

    def p43a_discard_trace_end
      result = @p43a_discard_trace_events == nil ? [] : @p43a_discard_trace_events.clone
      @p43a_discard_trace_active = false
      @p43a_discard_trace_events = []
      @p43a_discard_target_armor_id = 0
      return result
    end

    def p43a_record_discard(actor, tag)
      return unless @p43a_discard_trace_active
      return if actor == nil
      target = @p43a_discard_target_armor_id.to_i
      equipped = false
      begin
        equipped = actor.equips.compact.any? do |item|
          item.is_a?(RPG::Armor) && item.id.to_i == target
        end
      rescue
        equipped = false
      end
      @p43a_discard_trace_events << [tag, equipped]
    rescue
    end

    def p43a_event_tags(events)
      return [] unless events.is_a?(Array)
      return events.collect { |entry| entry.is_a?(Array) ? entry[0] : entry }
    rescue
      return []
    end

    def p43b_run_authority_convergence_fixture
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fixture = p42d_prepare_synthetic_learning_fixture
      assert("Authority convergence synthetic learning fixture prepared", fixture != nil)
      return false if fixture == nil

      actor_id = fixture[:actor_id].to_i
      skill_id = fixture[:skill_id].to_i
      pre_level = fixture[:pre_level].to_i
      detached = Game_Actor.new(actor_id)
      detached_baseline = p41d_global_actor_signature(detached)
      detached_unnatural_baseline = p41c_unnatural_skill_ids(detached)

      skill_slot = p42h_prepare_synthetic_skill_slot(skill_id)
      assert("Authority convergence synthetic Passive Skill clone prepared", skill_slot != nil,
             "actor=#{actor_id} skill=#{skill_id}")
      return false if skill_slot == nil
      skill = skill_slot[:synthetic]
      passive_ok = p42f_apply_synthetic_passive(skill)
      assert("Authority convergence synthetic Passive Skill parsed", passive_ok,
             "skill=#{skill_id}:#{skill.name}")
      return false unless passive_ok
      slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Authority convergence synthetic Skill owns temporary database slot", slot_active,
             "skill=#{skill_id}")
      return false unless slot_active

      level_ok = p42c_set_level_for_fixture(detached, pre_level)
      assert("Authority convergence detached Actor below natural threshold",
             level_ok && !detached.albert_natural_level_skill?(skill_id),
             "level=#{detached.level} natural=#{fixture[:natural_level]}")
      return false unless level_ok && !detached.albert_natural_level_skill?(skill_id)
      detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
      passive_baseline = p42f_passive_signature(detached)
      assert("Authority convergence passive baseline captured", passive_baseline != nil,
             passive_baseline.inspect)

      armor, slot = p43a_clean_extra_slot_armor(detached)
      assert("Authority convergence clean extra-slot Armor resolved",
             armor != nil && slot != nil && slot.to_i >= 5,
             "armor=#{armor == nil ? nil : armor.id} slot=#{slot.inspect}")
      return false if armor == nil || slot == nil

      # Phase43B：不再直接修改正式 Armor object。Marshal clone 後暫時接管同一
      # $data_armors slot，讓正式 equips / discard 仍以 ID 解析到 synthetic Armor。
      armor_original = armor
      armor_id = armor_original.id.to_i
      armor_array_oid = $data_armors.object_id
      armor_original_oid = armor_original.object_id
      armor_original_bytes = Marshal.dump(armor_original) rescue nil
      synthetic_armor = armor_original_bytes == nil ? nil : (Marshal.load(armor_original_bytes) rescue nil)
      assert("Authority convergence extra Armor database-slot clone baseline captured",
             synthetic_armor != nil && armor_original_bytes != nil,
             "armor=#{armor_id}:#{armor_original.name}")
      return false if synthetic_armor == nil || armor_original_bytes == nil
      $data_armors[armor_id] = synthetic_armor
      armor = synthetic_armor
      direct_tag = "<equipskill: #{skill_id}>"
      armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") + direct_tag
      clone_cache = p42k_equipskill_cache_snapshot(armor)
      cache_invalidated = clone_cache != nil && p42k_invalidate_equipskill_cache(armor, clone_cache)
      parsed = armor.skills rescue nil
      parsed_ids = parsed == nil ? [] : parsed.compact.collect { |s| s.id.to_i }
      assert("Authority convergence extra Armor Direct provider parses synthetic Skill",
             cache_invalidated && parsed_ids.include?(skill_id),
             "armor=#{armor.id} parsed=#{parsed_ids.inspect} tag=#{direct_tag.inspect}")

      # test=true：只建立 detached Actor 的 extra-slot 狀態，不碰 Party inventory。
      p41c_trace_begin
      begin
        detached.change_equip(slot, armor, true)
      ensure
        test_events = p41c_trace_end
      end
      # test=true 不應觸發 teaching/passive/combo refresh；手動做一次正式被動重算建立 probe baseline。
      detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
      active_sig = p42f_passive_signature(detached)
      active_auth = p42j_passive_authority_signature(active_sig)
      baseline_auth = p42j_passive_authority_signature(passive_baseline)
      assert("Authority convergence extra-slot Direct provider installed for discard probe",
             p37_equipped_item?(detached, armor) && p42k_skill_visible?(detached, skill_id),
             "slot=#{slot} equips=#{p37_equip_signature(detached).inspect} visible=#{p42k_skill_list_count(detached, skill_id)} test_events=#{test_events.inspect}")
      assert("Authority convergence extra-slot Direct provider activates Passive before discard",
             active_auth != baseline_auth && active_auth[:atk].to_i == baseline_auth[:atk].to_i + 37 &&
             active_auth[:def].to_i == baseline_auth[:def].to_i + 13 && active_auth[:critical_bonus] == true,
             "baseline=#{passive_baseline.inspect} active=#{active_sig.inspect}")

      p43a_discard_trace_begin(armor.id)
      begin
        detached.discard_equip(armor)
      ensure
        discard_events = p43a_discard_trace_end
      end
      tags = p43a_event_tags(discard_events)
      log("[AUTH_CONVERGENCE] discard_extra armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{discard_events.inspect} " +
          "equips_after=#{p37_equip_signature(detached).inspect} visible=#{p42k_skill_list_count(detached, skill_id)} " +
          "passive=#{p42f_passive_signature(detached).inspect}")

      expected_tags = [:discard_final_enter, :discard_eo_enter, :discard_kgc_base_enter,
                       :discard_kgc_base_exit, :discard_eo_exit,
                       :teaching_refresh_enter, :teaching_refresh_exit,
                       :restore_passive_enter, :restore_passive_exit,
                       :combo_refresh_enter, :combo_refresh_exit, :discard_final_exit]
      assert("Authority convergence discard_equip wrapper chain includes final Teaching/Passive/Combo convergence",
             tags == expected_tags,
             "expected=#{expected_tags.inspect} actual=#{tags.inspect} events=#{discard_events.inspect}")

      restore_entries = discard_events.select { |entry| entry.is_a?(Array) && entry[0] == :restore_passive_enter }
      final_exit = discard_events.find { |entry| entry.is_a?(Array) && entry[0] == :discard_final_exit }
      assert("Authority convergence discard uses only one final Passive refresh after extra-slot removal",
             restore_entries.size == 1 && restore_entries[0][1] == false &&
             final_exit != nil && final_exit[1] == false,
             "restores=#{restore_entries.inspect} final=#{final_exit.inspect}")

      final_sig = p42f_passive_signature(detached)
      assert("Authority convergence discard removes extra-slot equipment",
             !p37_equipped_item?(detached, armor),
             "equips=#{p37_equip_signature(detached).inspect}")
      assert("Authority convergence discard removes Direct Skill visibility",
             !p42k_skill_visible?(detached, skill_id),
             "visible=#{p42k_skill_list_count(detached, skill_id)} raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      passive_clean = final_sig == passive_baseline
      assert("Authority convergence discard refreshes Passive after final extra-slot state",
             passive_clean,
             "baseline=#{passive_baseline.inspect} final=#{final_sig.inspect} events=#{discard_events.inspect}")

      $data_armors[armor_id] = armor_original
      armor_slot_restored = $data_armors.object_id == armor_array_oid &&
                            $data_armors[armor_id].object_id == armor_original_oid &&
                            (Marshal.dump($data_armors[armor_id]) rescue nil) == armor_original_bytes
      assert("Authority convergence original Armor database slot/object/bytes restored exactly", armor_slot_restored,
             "armor=#{armor_id} original_oid=#{armor_original_oid} current_oid=#{$data_armors[armor_id].object_id}")
      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Authority convergence original Skill database slot restored", skill_restored,
             "skill=#{skill_id}")
      learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
      assert("Authority convergence synthetic Class learning restored", learning_restored,
             "class=#{fixture[:class_id]}")

      detached.setup(actor_id)
      actor_restored = p41d_global_actor_signature(detached) == detached_baseline &&
                       p41c_unnatural_skill_ids(detached) == detached_unnatural_baseline
      assert("Authority convergence detached Actor baseline restored", actor_restored,
             "before=#{detached_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      assert("Authority convergence fixture does not mutate Game_Party",
             party_before != nil && party_after == party_before,
             "bytes_before=#{party_before == nil ? 'nil' : party_before.size} bytes_after=#{party_after == nil ? 'nil' : party_after.size}")
      assert("Authority convergence fixture does not mutate $game_actors",
             actors_before != nil && actors_after == actors_before,
             "bytes_before=#{actors_before == nil ? 'nil' : actors_before.size} bytes_after=#{actors_after == nil ? 'nil' : actors_after.size}")

      @p43a_convergence = {
        :actor_id=>actor_id, :skill_id=>skill_id, :armor_id=>armor.id.to_i, :slot=>slot.to_i,
        :discard_events=>discard_events, :passive_clean=>passive_clean,
        :ready=>armor_slot_restored == true && skill_restored == true && learning_restored == true &&
                actor_restored == true && party_before != nil && party_after == party_before &&
                actors_before != nil && actors_after == actors_before &&
                !p37_equipped_item?(detached, armor) && !p42k_skill_visible?(detached, skill_id) && passive_clean
      }
      assert("Authority convergence discard_equip extra-slot diagnostic completed",
             @p43a_convergence[:ready] == true,
             @p43a_convergence.inspect)
      return @p43a_convergence[:ready] == true
    rescue Exception => e
      @p43a_discard_trace_active = false
      begin
        if armor_id != nil && armor_original != nil && $data_armors != nil
          $data_armors[armor_id] = armor_original
        end
      rescue
      end
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      begin
        p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
      rescue
      end
      exception(e, "p43b_run_authority_convergence_fixture")
      assert("Authority convergence discard_equip extra-slot diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase43b_prepare_battle_fixture_on_map_base)
      alias fs_phase43b_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase43b_prepare_battle_fixture_on_map_base
      return p43b_run_authority_convergence_fixture
    end

    unless method_defined?(:fs_phase43b_restore_pending_base)
      alias fs_phase43b_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase43b_restore_pending_base
      if result
        @p43a_convergence = nil
        @p43a_discard_trace_active = false
        @p43a_discard_trace_events = []
        @p43a_discard_target_armor_id = 0
      end
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only wrappers：Phase43B 延用 p43a_discard_trace_active recorder，記錄 Formal fix 前後兩次 Passive refresh。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:discard_equip) && !method_defined?(:fs_p43a_discard_final_base)
      alias fs_p43a_discard_final_base discard_equip
      def discard_equip(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_final_enter)
        result = fs_p43a_discard_final_base(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_final_exit)
        return result
      end
    end

    if method_defined?(:discard_equip_eo) && !method_defined?(:fs_p43a_discard_eo_base)
      alias fs_p43a_discard_eo_base discard_equip_eo
      def discard_equip_eo(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_eo_enter)
        result = fs_p43a_discard_eo_base(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_eo_exit)
        return result
      end
    end

    if method_defined?(:discard_equip_KGC_PassiveSkill) && !method_defined?(:fs_p43a_discard_kgc_base)
      alias fs_p43a_discard_kgc_base discard_equip_KGC_PassiveSkill
      def discard_equip_KGC_PassiveSkill(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_kgc_base_enter)
        result = fs_p43a_discard_kgc_base(item)
        FS_TEST_HARNESS.p43a_record_discard(self, :discard_kgc_base_exit)
        return result
      end
    end

    if method_defined?(:restore_passive_rev) && !method_defined?(:fs_p43a_restore_passive_base)
      alias fs_p43a_restore_passive_base restore_passive_rev
      def restore_passive_rev
        FS_TEST_HARNESS.p43a_record_discard(self, :restore_passive_enter)
        result = fs_p43a_restore_passive_base
        FS_TEST_HARNESS.p43a_record_discard(self, :restore_passive_exit)
        return result
      end
    end
  end
end

#==============================================================================
# ■ Phase43D｜discard_equip Teaching / Combo Authority Diagnostic
#------------------------------------------------------------------------------
# TEST-only。Phase43B 已修正 extra-slot final Passive refresh；本階段不改 Formal Runtime，
# 只確認同一 side-door 是否也遺漏 Equipment Teaching 與 EquipmentCombo ownership refresh。
#==============================================================================
module FS_TEST_HARNESS
  @p43d_discard_authority = nil

  class << self
    def p43d_clone_armor_slot(armor)
      return nil if armor == nil || $data_armors == nil
      armor_id = armor.id.to_i
      return nil if armor_id <= 0
      bytes = Marshal.dump(armor) rescue nil
      return nil if bytes == nil
      synthetic = Marshal.load(bytes) rescue nil
      return nil if synthetic == nil
      data = {
        :id=>armor_id,
        :array_oid=>$data_armors.object_id,
        :original=>armor,
        :original_oid=>armor.object_id,
        :original_bytes=>bytes,
        :synthetic=>synthetic
      }
      $data_armors[armor_id] = synthetic
      return data
    rescue
      return nil
    end

    def p43d_restore_armor_slot(data)
      return false if data == nil || $data_armors == nil
      armor_id = data[:id].to_i
      original = data[:original]
      return false if armor_id <= 0 || original == nil
      $data_armors[armor_id] = original
      after = Marshal.dump($data_armors[armor_id]) rescue nil
      return $data_armors.object_id == data[:array_oid] &&
             $data_armors[armor_id].object_id == data[:original_oid] &&
             data[:original_bytes] != nil && after == data[:original_bytes]
    rescue
      return false
    end

    def p43d_choose_combo_state(actor)
      return 55 if $data_states != nil && $data_states[55] != nil && !(actor.state?(55) rescue false)
      return 0 if $data_states == nil
      $data_states.compact.each do |state|
        next if state == nil || state.id.to_i <= 1
        next if actor.state?(state.id) rescue true
        return state.id.to_i
      end
      return 0
    rescue
      return 0
    end

    def p43d_run_teaching_discard_probe
      fixture = nil
      armor_slot = nil
      detached = nil
      begin
        fixture = p42d_prepare_synthetic_learning_fixture
        assert("Authority convergence Teaching discard synthetic learning prepared", fixture != nil)
        return false if fixture == nil

        actor_id = fixture[:actor_id].to_i
        skill_id = fixture[:skill_id].to_i
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        unnatural_baseline = p41c_unnatural_skill_ids(detached)
        level_ok = p42c_set_level_for_fixture(detached, fixture[:pre_level].to_i)
        assert("Authority convergence Teaching discard detached Actor below natural threshold",
               level_ok && !detached.albert_natural_level_skill?(skill_id),
               "level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{skill_id}")
        return false unless level_ok && !detached.albert_natural_level_skill?(skill_id)

        armor_original, slot = p43a_clean_extra_slot_armor(detached)
        assert("Authority convergence Teaching discard clean extra-slot Armor resolved",
               armor_original != nil && slot != nil && slot.to_i >= 5,
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil

        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Authority convergence Teaching discard Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        tag = "\\ls[#{skill_id}, #{fixture[:pre_level].to_i}]"
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") + tag
        parsed = armor.skill_ids rescue nil
        assert("Authority convergence Teaching discard synthetic Armor parses teaching entry",
               parsed == [[skill_id, fixture[:pre_level].to_i]],
               "armor=#{armor.id} parsed=#{parsed.inspect} tag=#{tag.inspect}")

        detached.change_equip(slot, armor, true)
        detached.albert_refresh_equipment_teaching_skills if detached.respond_to?(:albert_refresh_equipment_teaching_skills)
        taught_before = p37_raw_skill_learned?(detached, skill_id) &&
                        p41c_unnatural_skill_ids(detached).include?(skill_id)
        assert("Authority convergence Teaching discard precondition owns temporary raw skill / marker",
               taught_before,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect}")

        p43a_discard_trace_begin(armor.id)
        begin
          detached.discard_equip(armor)
        ensure
          events = p43a_discard_trace_end
        end
        raw_after = p37_raw_skill_learned?(detached, skill_id)
        marker_after = p41c_unnatural_skill_ids(detached).include?(skill_id)
        log("[AUTH_CONVERGENCE_TEACHING] discard_extra armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{events.inspect} " +
            "raw_after=#{raw_after} markers=#{p41c_unnatural_skill_ids(detached).inspect} equips=#{p37_equip_signature(detached).inspect}")
        assert("Authority convergence Teaching discard removes extra-slot equipment",
               !p37_equipped_item?(detached, armor),
               "equips=#{p37_equip_signature(detached).inspect}")
        teaching_clean = !raw_after && !marker_after
        assert("Authority convergence discard refreshes Teaching ownership after final extra-slot state",
               teaching_clean,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect} events=#{events.inspect}")

        # Diagnostic FAIL 時仍清掉 detached actor 的 stale temporary ownership，避免污染後續 probe。
        detached.albert_refresh_equipment_teaching_skills if detached.respond_to?(:albert_refresh_equipment_teaching_skills)
        cleanup_ok = !p37_raw_skill_learned?(detached, skill_id) && !p41c_unnatural_skill_ids(detached).include?(skill_id)
        assert("Authority convergence Teaching discard TEST cleanup restores temporary ownership baseline", cleanup_ok,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        assert("Authority convergence Teaching discard original Armor slot/object/bytes restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        armor_slot = nil if armor_restored
        learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
        assert("Authority convergence Teaching discard synthetic Class learning restored", learning_restored,
               "class=#{fixture[:class_id]}")
        fixture = nil if learning_restored

        detached.setup(actor_id)
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         p41c_unnatural_skill_ids(detached) == unnatural_baseline
        assert("Authority convergence Teaching discard detached Actor baseline restored", actor_restored,
               "before=#{actor_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")
        return teaching_clean && cleanup_ok && armor_restored && learning_restored && actor_restored
      rescue Exception => e
        exception(e, "p43d_run_teaching_discard_probe")
        assert("Authority convergence Teaching discard diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
        begin
          p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
        rescue
        end
      end
    end

    def p43d_run_combo_discard_probe
      armor_slot = nil
      begin
        actor_id = 1
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        states_baseline = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        owned_had_baseline = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        owned_baseline = owned_had_baseline ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        owned_baseline = owned_baseline == nil ? nil : owned_baseline.clone
        state_id = p43d_choose_combo_state(detached)
        assert("Authority convergence Combo discard usable actor-state fixture resolved",
               state_id > 0 && $data_states[state_id] != nil,
               "actor=#{actor_id} state=#{state_id}")
        return false if state_id <= 0 || $data_states[state_id] == nil

        armor_original, slot = p43a_clean_extra_slot_armor(detached)
        assert("Authority convergence Combo discard clean extra-slot Armor resolved",
               armor_original != nil && slot != nil && slot.to_i >= 5,
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil

        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Authority convergence Combo discard Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") +
                     "<combo_actor:#{actor_id}>\n<combo_actor_state:#{state_id}>"
        armor.instance_variable_set(:@albert_combo_cache_loaded, false)
        combo_ids = armor.albert_combo_actor_state_ids rescue []
        assert("Authority convergence Combo discard synthetic Armor parses actor-state ownership",
               combo_ids.include?(state_id),
               "armor=#{armor.id} states=#{combo_ids.inspect} target=#{state_id}")

        detached.change_equip(slot, armor, true)
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned = [] if owned == nil
        combo_before = detached.state?(state_id) && owned.include?(state_id)
        assert("Authority convergence Combo discard precondition owns synthetic State",
               combo_before,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned.inspect}")

        p43a_discard_trace_begin(armor.id)
        begin
          detached.discard_equip(armor)
        ensure
          events = p43a_discard_trace_end
        end
        owned_after = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_after = [] if owned_after == nil
        state_after = detached.state?(state_id)
        log("[AUTH_CONVERGENCE_COMBO] discard_extra armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{events.inspect} " +
            "state=#{state_id} active_after=#{state_after} owned_after=#{owned_after.inspect} equips=#{p37_equip_signature(detached).inspect}")
        assert("Authority convergence Combo discard removes extra-slot equipment",
               !p37_equipped_item?(detached, armor),
               "equips=#{p37_equip_signature(detached).inspect}")
        combo_clean = !state_after && !owned_after.include?(state_id)
        assert("Authority convergence discard refreshes Combo-owned State after final extra-slot state",
               combo_clean,
               "state=#{state_id} active=#{state_after} owned=#{owned_after.inspect} events=#{events.inspect}")

        # Diagnostic FAIL 時仍用 Formal Combo refresh 清掉 stale State / ownership。
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned_cleanup = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_cleanup = [] if owned_cleanup == nil
        cleanup_ok = !detached.state?(state_id) && !owned_cleanup.include?(state_id)
        assert("Authority convergence Combo discard TEST cleanup restores owned-State baseline", cleanup_ok,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned_cleanup.inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        assert("Authority convergence Combo discard original Armor slot/object/bytes restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        armor_slot = nil if armor_restored

        # TEST-only 精確恢復 Combo ownership ivar 的「存在性」與原值。
        if owned_had_baseline
          detached.instance_variable_set(:@albert_combo_owned_state_ids, owned_baseline == nil ? nil : owned_baseline.clone)
        else
          if p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
            detached.send(:remove_instance_variable, :@albert_combo_owned_state_ids)
          end
        end
        detached.setup(actor_id)
        current_states = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        current_owned_had = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        current_owned = current_owned_had ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        current_owned = current_owned == nil ? nil : current_owned.clone
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         current_states == states_baseline && current_owned_had == owned_had_baseline &&
                         current_owned == owned_baseline
        assert("Authority convergence Combo discard detached Actor/state baseline restored", actor_restored,
               "states=#{states_baseline.inspect}->#{current_states.inspect} owned=#{owned_baseline.inspect}->#{current_owned.inspect}")
        return combo_clean && cleanup_ok && armor_restored && actor_restored
      rescue Exception => e
        exception(e, "p43d_run_combo_discard_probe")
        assert("Authority convergence Combo discard diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
      end
    end

    def p43d_run_discard_authority_diagnostic
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fail_before = @fail.to_i
      teaching_ok = p43d_run_teaching_discard_probe
      combo_ok = p43d_run_combo_discard_probe
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && party_after == party_before &&
                     actors_before != nil && actors_after == actors_before
      assert("Authority convergence discard Teaching/Combo diagnostic leaves Game_Party / $game_actors exact",
             global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")
      @p43d_discard_authority = {
        :teaching_clean=>teaching_ok,
        :combo_clean=>combo_ok,
        :global_clean=>global_clean,
        :fail_delta=>@fail.to_i - fail_before,
        :ready=>teaching_ok && combo_ok && global_clean
      }
      assert("Authority convergence discard Teaching / Combo diagnostic completed",
             @p43d_discard_authority[:ready] == true,
             @p43d_discard_authority.inspect)
      return @p43d_discard_authority[:ready] == true
    rescue Exception => e
      exception(e, "p43d_run_discard_authority_diagnostic")
      assert("Authority convergence discard Teaching / Combo diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase43c_prepare_battle_fixture_on_map_base)
      alias fs_phase43c_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase43c_prepare_battle_fixture_on_map_base
      return p43d_run_discard_authority_diagnostic
    end

    unless method_defined?(:fs_phase43c_restore_pending_base)
      alias fs_phase43c_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase43c_restore_pending_base
      @p43d_discard_authority = nil if result
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only recorder extension：只在 p43a discard trace 啟用時記錄 Teaching / Combo refresh。
# 若 discard path 完全沒有呼叫它們，trace 中自然不會出現這些 tag。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:albert_refresh_equipment_teaching_skills) && !method_defined?(:fs_p43d_teaching_refresh_base)
      alias fs_p43d_teaching_refresh_base albert_refresh_equipment_teaching_skills
      def albert_refresh_equipment_teaching_skills
        FS_TEST_HARNESS.p43a_record_discard(self, :teaching_refresh_enter)
        result = fs_p43d_teaching_refresh_base
        FS_TEST_HARNESS.p43a_record_discard(self, :teaching_refresh_exit)
        return result
      end
    end

    if method_defined?(:albert_refresh_combo_actor_states) && !method_defined?(:fs_p43d_combo_refresh_base)
      alias fs_p43d_combo_refresh_base albert_refresh_combo_actor_states
      def albert_refresh_combo_actor_states
        FS_TEST_HARNESS.p43a_record_discard(self, :combo_refresh_enter)
        result = fs_p43d_combo_refresh_base
        FS_TEST_HARNESS.p43a_record_discard(self, :combo_refresh_exit)
        return result
      end
    end
  end
end


# 【Phase43G】依 Phase43F 實機 394 PASS / 5 FAIL 證據修正一般防具欄 discard_equip。Formal page330
#         CoreSafe v1.5 在 armor1..armor4 或 extra-slot 任一路徑「確實移除 Armor」後，只執行一次
#         Teaching → Passive → Combo final convergence。TEST 端保留 Phase43F 的 end-state ASSERT，並新增
#         final convergence trace-order ASSERT，要求 Teaching 完成後另有 final Passive，再進 Combo；
#         以免只因 cleanup 最終狀態碰巧正確就誤判封版。
#==============================================================================
# ■ Phase43G｜Standard Armor Slot discard_equip Authority Convergence Fix
#------------------------------------------------------------------------------
# TEST-only：Formal Runtime 修正位於 page330 CoreSafe v1.5。本區驗證 VX 原生 armor1..armor4
# 由 discard_equip 移除後，Teaching / Passive / EquipmentCombo 依最終裝備狀態與正式順序收斂。
#==============================================================================
module FS_TEST_HARNESS
  @p43f_standard_discard_authority = nil

  class << self
    def p43f_clean_standard_slot_armor(actor)
      return [nil, nil] if actor == nil || $data_armors == nil
      formal_ids = p42c_formal_equipped_armor_ids
      $data_armors.compact.each do |armor|
        next if armor == nil || armor.id.to_i <= 0
        next if formal_ids.include?(armor.id.to_i)
        note = armor.note.to_s
        next if note =~ /\\ls\[/i
        next if note =~ /<(?:EQUIPMENTSKILL|equipskill):/i
        next if note =~ /<combo_/i
        next if note =~ /<fs_(?:soulmark|resonance_headgear)/i
        slot = p37_find_armor_slot(actor, armor)
        next if slot == nil || slot.to_i < 1 || slot.to_i > 4
        begin
          next unless actor.equippable?(armor)
          next unless actor.equips[slot] == nil
        rescue
          next
        end
        return [armor, slot.to_i]
      end
      return [nil, nil]
    rescue
      return [nil, nil]
    end

    def p43g_event_index_after(events, tag, start_index)
      i = start_index.to_i
      i = 0 if i < 0
      while i < events.size
        entry = events[i]
        return i if entry.is_a?(Array) && entry[0] == tag
        i += 1
      end
      return nil
    rescue
      return nil
    end

    def p43g_final_convergence_trace?(events)
      return false if events == nil
      eo_exit = p43g_event_index_after(events, :discard_eo_exit, 0)
      return false if eo_exit == nil
      teaching_enter = p43g_event_index_after(events, :teaching_refresh_enter, eo_exit + 1)
      return false if teaching_enter == nil
      teaching_exit = p43g_event_index_after(events, :teaching_refresh_exit, teaching_enter + 1)
      return false if teaching_exit == nil
      passive_enter = p43g_event_index_after(events, :restore_passive_enter, teaching_exit + 1)
      return false if passive_enter == nil
      passive_exit = p43g_event_index_after(events, :restore_passive_exit, passive_enter + 1)
      return false if passive_exit == nil
      combo_enter = p43g_event_index_after(events, :combo_refresh_enter, passive_exit + 1)
      return false if combo_enter == nil
      combo_exit = p43g_event_index_after(events, :combo_refresh_exit, combo_enter + 1)
      return false if combo_exit == nil
      final_exit = p43g_event_index_after(events, :discard_final_exit, combo_exit + 1)
      return false if final_exit == nil
      indices = [teaching_enter, teaching_exit, passive_enter, passive_exit, combo_enter, combo_exit, final_exit]
      indices.each do |index|
        entry = events[index]
        return false unless entry.is_a?(Array) && entry[1] == false
      end
      return true
    rescue
      return false
    end

    def p43f_run_standard_teaching_passive_probe
      fixture = nil
      skill_slot = nil
      armor_slot = nil
      detached = nil
      begin
        fixture = p42d_prepare_synthetic_learning_fixture
        assert("Standard discard Teaching/Passive synthetic learning prepared", fixture != nil)
        return false if fixture == nil
        actor_id = fixture[:actor_id].to_i
        skill_id = fixture[:skill_id].to_i
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        unnatural_baseline = p41c_unnatural_skill_ids(detached)

        skill_slot = p42h_prepare_synthetic_skill_slot(skill_id)
        assert("Standard discard Teaching/Passive synthetic Skill clone prepared", skill_slot != nil,
               "actor=#{actor_id} skill=#{skill_id}")
        return false if skill_slot == nil
        skill = skill_slot[:synthetic]
        passive_ok = p42f_apply_synthetic_passive(skill)
        slot_active = passive_ok && p42h_activate_synthetic_skill_slot(skill_slot)
        assert("Standard discard Teaching/Passive synthetic Skill owns Passive database slot",
               slot_active,
               "skill=#{skill_id}:#{skill.name}")
        return false unless slot_active

        level_ok = p42c_set_level_for_fixture(detached, fixture[:pre_level].to_i)
        assert("Standard discard Teaching/Passive Actor below natural threshold",
               level_ok && !detached.albert_natural_level_skill?(skill_id),
               "level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{skill_id}")
        return false unless level_ok && !detached.albert_natural_level_skill?(skill_id)
        detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
        passive_baseline = p42f_passive_signature(detached)

        armor_original, slot = p43f_clean_standard_slot_armor(detached)
        assert("Standard discard Teaching/Passive clean base Armor slot resolved",
               armor_original != nil && slot != nil && slot.to_i.between?(1, 4),
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil
        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Standard discard Teaching/Passive Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        tag = "\\ls[#{skill_id}, #{fixture[:pre_level].to_i}]"
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") + tag
        parsed = armor.skill_ids rescue nil
        assert("Standard discard Teaching/Passive synthetic Armor parses teaching entry",
               parsed == [[skill_id, fixture[:pre_level].to_i]],
               "armor=#{armor.id} parsed=#{parsed.inspect} tag=#{tag.inspect}")

        detached.change_equip(slot, armor, true)
        detached.albert_refresh_equipment_teaching_skills if detached.respond_to?(:albert_refresh_equipment_teaching_skills)
        detached.albert_refresh_equipment_passive_skills if detached.respond_to?(:albert_refresh_equipment_passive_skills)
        raw_before = p37_raw_skill_learned?(detached, skill_id)
        marker_before = p41c_unnatural_skill_ids(detached).include?(skill_id)
        active_sig = p42f_passive_signature(detached)
        baseline_auth = p42j_passive_authority_signature(passive_baseline)
        active_auth = p42j_passive_authority_signature(active_sig)
        passive_active = active_auth != baseline_auth &&
                         active_auth[:atk].to_i == baseline_auth[:atk].to_i + 37 &&
                         active_auth[:def].to_i == baseline_auth[:def].to_i + 13 &&
                         active_auth[:critical_bonus] == true
        assert("Standard discard Teaching/Passive precondition owns raw marker and Passive",
               raw_before && marker_before && passive_active,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{active_sig.inspect}")

        p43a_discard_trace_begin(armor.id)
        begin
          detached.discard_equip(armor)
        ensure
          events = p43a_discard_trace_end
        end
        raw_after = p37_raw_skill_learned?(detached, skill_id)
        marker_after = p41c_unnatural_skill_ids(detached).include?(skill_id)
        passive_after = p42f_passive_signature(detached)
        log("[AUTH_STANDARD_TEACHING] discard armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{events.inspect} " +
            "raw_after=#{raw_after} markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{passive_after.inspect}")
        assert("Standard discard removes base-slot Teaching Armor",
               !p37_equipped_item?(detached, armor),
               "equips=#{p37_equip_signature(detached).inspect}")

        # Phase44D：一般欄 discard 不再允許 KGC wrapper 在 EO return 前做 early rebuild。
        # Teaching refresh 自己若因 forget_skill 觸發 Passive rebuild，仍屬 final-state convergence
        # 的 transitive side effect，所以此處只禁止 KGC exit → EO exit 之間的 restore。
        restore_enters = events.select { |entry| entry.is_a?(Array) && entry[0] == :restore_passive_enter }
        kgc_exit_index = p43g_event_index_after(events, :discard_kgc_base_exit, 0)
        eo_exit_index = p43g_event_index_after(events, :discard_eo_exit, 0)
        early_restore = false
        if kgc_exit_index != nil && eo_exit_index != nil && kgc_exit_index < eo_exit_index
          ((kgc_exit_index + 1)...eo_exit_index).each do |idx|
            entry = events[idx]
            early_restore = true if entry.is_a?(Array) && entry[0] == :restore_passive_enter
          end
        end
        teaching_enter_index = p43g_event_index_after(events, :teaching_refresh_enter, 0)
        teaching_exit_index = p43g_event_index_after(events, :teaching_refresh_exit, 0)
        nested_teaching_restore = false
        if teaching_enter_index != nil && teaching_exit_index != nil && teaching_enter_index < teaching_exit_index
          ((teaching_enter_index + 1)...teaching_exit_index).each do |idx|
            entry = events[idx]
            nested_teaching_restore = true if entry.is_a?(Array) && entry[0] == :restore_passive_enter
          end
        end
        boundary_ok = kgc_exit_index != nil && eo_exit_index != nil && !early_restore &&
                      !nested_teaching_restore && restore_enters.size == 1 &&
                      restore_enters.all? { |entry| entry[1] == false }
        assert("Standard discard uses exactly one final Passive refresh with no nested Teaching rebuild",
               boundary_ok,
               "restores=#{restore_enters.inspect} events=#{events.inspect}")
        convergence_trace = p43g_final_convergence_trace?(events)
        assert("Standard discard executes final Teaching/Passive/Combo convergence after base-slot removal",
               convergence_trace,
               "events=#{events.inspect}")

        teaching_clean = !raw_after && !marker_after
        assert("Standard discard refreshes Teaching ownership after base-slot removal",
               teaching_clean,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect} events=#{events.inspect}")
        passive_clean = passive_after == passive_baseline
        assert("Standard discard recomputes Passive after Teaching ownership cleanup",
               passive_clean,
               "baseline=#{passive_baseline.inspect} after=#{passive_after.inspect} events=#{events.inspect}")

        # Diagnostic FAIL 時仍用正式 Authority 方法清乾淨 detached actor。
        detached.albert_refresh_equipment_teaching_skills if detached.respond_to?(:albert_refresh_equipment_teaching_skills)
        detached.albert_refresh_equipment_passive_skills if detached.respond_to?(:albert_refresh_equipment_passive_skills)
        cleanup_sig = p42f_passive_signature(detached)
        cleanup_ok = !p37_raw_skill_learned?(detached, skill_id) &&
                     !p41c_unnatural_skill_ids(detached).include?(skill_id) && cleanup_sig == passive_baseline
        assert("Standard discard Teaching/Passive TEST cleanup restores baseline", cleanup_ok,
               "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect} markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{cleanup_sig.inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        assert("Standard discard Teaching/Passive original Armor slot/object/bytes restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        armor_slot = nil if armor_restored
        skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
        assert("Standard discard Teaching/Passive original Skill slot/object/bytes restored", skill_restored,
               "skill=#{skill_id}")
        skill_slot = nil if skill_restored
        learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
        assert("Standard discard Teaching/Passive synthetic Class learning restored", learning_restored,
               "class=#{fixture[:class_id]}")
        fixture = nil if learning_restored

        detached.setup(actor_id)
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         p41c_unnatural_skill_ids(detached) == unnatural_baseline
        assert("Standard discard Teaching/Passive detached Actor baseline restored", actor_restored,
               "before=#{actor_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")
        return teaching_clean && passive_clean && cleanup_ok && armor_restored &&
               skill_restored && learning_restored && actor_restored
      rescue Exception => e
        exception(e, "p43f_run_standard_teaching_passive_probe")
        assert("Standard discard Teaching/Passive diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
        begin
          p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
        rescue
        end
        begin
          p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
        rescue
        end
      end
    end

    def p43f_run_standard_combo_probe
      armor_slot = nil
      detached = nil
      begin
        actor_id = 1
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        states_baseline = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        owned_had_baseline = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        owned_baseline = owned_had_baseline ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        owned_baseline = owned_baseline == nil ? nil : owned_baseline.clone
        state_id = p43d_choose_combo_state(detached)
        assert("Standard discard Combo usable actor-state fixture resolved",
               state_id > 0 && $data_states[state_id] != nil,
               "actor=#{actor_id} state=#{state_id}")
        return false if state_id <= 0 || $data_states[state_id] == nil

        armor_original, slot = p43f_clean_standard_slot_armor(detached)
        assert("Standard discard Combo clean base Armor slot resolved",
               armor_original != nil && slot != nil && slot.to_i.between?(1, 4),
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil
        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Standard discard Combo Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") +
                     "<combo_actor:#{actor_id}>\n<combo_actor_state:#{state_id}>"
        armor.instance_variable_set(:@albert_combo_cache_loaded, false)
        combo_ids = armor.albert_combo_actor_state_ids rescue []
        assert("Standard discard Combo synthetic Armor parses actor-state ownership",
               combo_ids.include?(state_id),
               "armor=#{armor.id} states=#{combo_ids.inspect} target=#{state_id}")

        detached.change_equip(slot, armor, true)
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned = [] if owned == nil
        assert("Standard discard Combo precondition owns synthetic State",
               detached.state?(state_id) && owned.include?(state_id),
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned.inspect}")

        p43a_discard_trace_begin(armor.id)
        begin
          detached.discard_equip(armor)
        ensure
          events = p43a_discard_trace_end
        end
        owned_after = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_after = [] if owned_after == nil
        state_after = detached.state?(state_id)
        log("[AUTH_STANDARD_COMBO] discard armor=#{armor.id}:#{armor.name} slot=#{slot} events=#{events.inspect} " +
            "state=#{state_id} active_after=#{state_after} owned_after=#{owned_after.inspect}")
        assert("Standard discard removes base-slot Combo Armor",
               !p37_equipped_item?(detached, armor),
               "equips=#{p37_equip_signature(detached).inspect}")
        combo_trace = p43g_final_convergence_trace?(events)
        assert("Standard discard Combo path executes final Teaching/Passive/Combo convergence",
               combo_trace,
               "events=#{events.inspect}")
        combo_clean = !state_after && !owned_after.include?(state_id)
        assert("Standard discard refreshes Combo-owned State after base-slot removal",
               combo_clean,
               "state=#{state_id} active=#{state_after} owned=#{owned_after.inspect} events=#{events.inspect}")

        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned_cleanup = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_cleanup = [] if owned_cleanup == nil
        cleanup_ok = !detached.state?(state_id) && !owned_cleanup.include?(state_id)
        assert("Standard discard Combo TEST cleanup restores State baseline", cleanup_ok,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned_cleanup.inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        assert("Standard discard Combo original Armor slot/object/bytes restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        armor_slot = nil if armor_restored

        if owned_had_baseline
          detached.instance_variable_set(:@albert_combo_owned_state_ids, owned_baseline == nil ? nil : owned_baseline.clone)
        else
          if p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
            detached.send(:remove_instance_variable, :@albert_combo_owned_state_ids)
          end
        end
        detached.setup(actor_id)
        current_states = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        current_owned_had = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        current_owned = current_owned_had ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        current_owned = current_owned == nil ? nil : current_owned.clone
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         current_states == states_baseline && current_owned_had == owned_had_baseline &&
                         current_owned == owned_baseline
        assert("Standard discard Combo detached Actor/state baseline restored", actor_restored,
               "states=#{states_baseline.inspect}->#{current_states.inspect} owned=#{owned_baseline.inspect}->#{current_owned.inspect}")
        return combo_clean && cleanup_ok && armor_restored && actor_restored
      rescue Exception => e
        exception(e, "p43f_run_standard_combo_probe")
        assert("Standard discard Combo diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
      end
    end

    def p43f_run_standard_discard_authority_diagnostic
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fail_before = @fail.to_i
      teaching_passive_ok = p43f_run_standard_teaching_passive_probe
      combo_ok = p43f_run_standard_combo_probe
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && party_after == party_before &&
                     actors_before != nil && actors_after == actors_before
      assert("Standard discard diagnostic leaves Game_Party / $game_actors exact",
             global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")
      @p43f_standard_discard_authority = {
        :teaching_passive_clean=>teaching_passive_ok,
        :combo_clean=>combo_ok,
        :global_clean=>global_clean,
        :fail_delta=>@fail.to_i - fail_before,
        :ready=>teaching_passive_ok && combo_ok && global_clean
      }
      assert("Standard discard Teaching / Passive / Combo diagnostic completed",
             @p43f_standard_discard_authority[:ready] == true,
             @p43f_standard_discard_authority.inspect)
      return @p43f_standard_discard_authority[:ready] == true
    rescue Exception => e
      exception(e, "p43f_run_standard_discard_authority_diagnostic")
      assert("Standard discard Teaching / Passive / Combo diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase43f_prepare_battle_fixture_on_map_base)
      alias fs_phase43f_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase43f_prepare_battle_fixture_on_map_base
      return p43f_run_standard_discard_authority_diagnostic
    end

    unless method_defined?(:fs_phase43f_restore_pending_base)
      alias fs_phase43f_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase43f_restore_pending_base
      @p43f_standard_discard_authority = nil if result
      return result
    end
  end
end

#==============================================================================
# ■ Phase44A｜Weapon discard_equip Authority Diagnostic
#------------------------------------------------------------------------------
# TEST-only：不修改 Formal Runtime。Armor side-door 已由 Phase43G 封版，本段只驗證
# Weapon 經既有 discard_equip wrapper chain 移除後，Direct／Teaching／Passive／Combo
# 是否依「最終裝備狀態」收斂，並記錄 exact wrapper invocation order/count。
#==============================================================================
module FS_TEST_HARNESS
  @p44a_weapon_discard_authority = nil
  @p44a_weapon_trace_active = false
  @p44a_weapon_trace_events = []
  @p44a_weapon_trace_target_class = nil
  @p44a_weapon_trace_target_id = 0

  class << self
    def p44a_formal_equipped_weapon_ids
      ids = []
      p42c_instantiated_actor_objects.each do |actor|
        begin
          actor.equips.compact.each do |item|
            ids << item.id.to_i if item.is_a?(RPG::Weapon)
          end
        rescue
        end
      end
      return ids.uniq
    rescue
      return []
    end

    def p44a_clean_weapon(actor)
      return nil if actor == nil || $data_weapons == nil
      formal_ids = p44a_formal_equipped_weapon_ids
      $data_weapons.compact.each do |weapon|
        next if weapon == nil || weapon.id.to_i <= 0
        next if formal_ids.include?(weapon.id.to_i)
        name = weapon.name.to_s
        next if name.strip.empty? || name =~ /----/
        note = weapon.note.to_s
        next if note =~ /\\ls\[/i
        next if note =~ /<(?:EQUIPMENTSKILL|equipskill):/i
        next if note =~ /<combo_/i
        next if note =~ /<fs_(?:soulmark|resonance_headgear)/i
        begin
          next unless actor.equippable?(weapon)
          next if weapon.respond_to?(:two_handed) && weapon.two_handed
        rescue
          next
        end
        return weapon
      end
      return nil
    rescue
      return nil
    end

    def p44a_direct_skill_id(actor, excluded_ids)
      return nil if actor == nil || $data_skills == nil
      excluded = excluded_ids == nil ? [] : excluded_ids.collect { |id| id.to_i }
      current = p41c_skill_ids(actor)
      $data_skills.compact.each do |skill|
        next if skill == nil || skill.id.to_i <= 0
        sid = skill.id.to_i
        next if excluded.include?(sid)
        next if current.include?(sid)
        next if p37_raw_skill_learned?(actor, sid)
        name = skill.name.to_s
        next if name.strip.empty? || name =~ /----/
        note = skill.note.to_s
        next if note =~ /<(?:PASSIVE_SKILL|passive_skill)>/i
        next if note =~ /<レベル依存:/
        return sid
      end
      return nil
    rescue
      return nil
    end

    def p44a_clone_weapon_slot(weapon)
      return nil if weapon == nil || $data_weapons == nil
      weapon_id = weapon.id.to_i
      return nil if weapon_id <= 0
      bytes = Marshal.dump(weapon) rescue nil
      return nil if bytes == nil
      synthetic = Marshal.load(bytes) rescue nil
      return nil if synthetic == nil
      data = {
        :id=>weapon_id,
        :array_oid=>$data_weapons.object_id,
        :original=>weapon,
        :original_oid=>weapon.object_id,
        :original_bytes=>bytes,
        :synthetic=>synthetic
      }
      $data_weapons[weapon_id] = synthetic
      return data
    rescue
      return nil
    end

    def p44a_restore_weapon_slot(data)
      return false if data == nil || $data_weapons == nil
      weapon_id = data[:id].to_i
      original = data[:original]
      return false if weapon_id <= 0 || original == nil
      $data_weapons[weapon_id] = original
      after = Marshal.dump($data_weapons[weapon_id]) rescue nil
      return $data_weapons.object_id == data[:array_oid] &&
             $data_weapons[weapon_id].object_id == data[:original_oid] &&
             data[:original_bytes] != nil && after == data[:original_bytes]
    rescue
      return false
    end

    def p44a_discard_trace_begin(item)
      @p44a_weapon_trace_active = true
      @p44a_weapon_trace_events = []
      @p44a_weapon_trace_target_class = item == nil ? nil : item.class
      @p44a_weapon_trace_target_id = item == nil ? 0 : item.id.to_i
    end

    def p44a_discard_trace_end
      events = @p44a_weapon_trace_events == nil ? [] : @p44a_weapon_trace_events.clone
      @p44a_weapon_trace_active = false
      @p44a_weapon_trace_events = []
      @p44a_weapon_trace_target_class = nil
      @p44a_weapon_trace_target_id = 0
      return events
    end

    def p44a_record_discard(actor, tag)
      return unless @p44a_weapon_trace_active == true
      return if actor == nil
      klass = @p44a_weapon_trace_target_class
      target_id = @p44a_weapon_trace_target_id.to_i
      equipped = false
      begin
        equipped = actor.equips.compact.any? do |item|
          item != nil && item.class == klass && item.id.to_i == target_id
        end
      rescue
        equipped = false
      end
      @p44a_weapon_trace_events << [tag, equipped]
    rescue
    end

    def p44a_event_tags(events)
      return [] unless events.is_a?(Array)
      return events.collect { |entry| entry.is_a?(Array) ? entry[0] : entry }
    rescue
      return []
    end

    def p44a_trace_counts(events)
      result = {}
      p44a_event_tags(events).each do |tag|
        result[tag] = 0 if result[tag] == nil
        result[tag] += 1
      end
      return result
    rescue
      return {}
    end

    def p44a_index_after(events, tag, start_index)
      i = start_index.to_i
      i = 0 if i < 0
      while i < events.size
        entry = events[i]
        return i if entry.is_a?(Array) && entry[0] == tag
        i += 1
      end
      return nil
    rescue
      return nil
    end

    def p44a_base_discard_trace_ok(events)
      return false unless events.is_a?(Array)
      tags = p44a_event_tags(events)
      counts = p44a_trace_counts(events)
      required_once = [:weapon_discard_final_enter, :weapon_discard_eo_enter,
                       :weapon_discard_kgc_base_enter, :weapon_discard_kgc_base_exit,
                       :weapon_discard_eo_exit, :weapon_discard_final_exit]
      required_once.each do |tag|
        return false unless counts[tag].to_i == 1
      end
      i0 = tags.index(:weapon_discard_final_enter)
      i1 = tags.index(:weapon_discard_eo_enter)
      i2 = tags.index(:weapon_discard_kgc_base_enter)
      i3 = tags.index(:weapon_discard_kgc_base_exit)
      i4 = tags.index(:weapon_discard_eo_exit)
      i5 = tags.index(:weapon_discard_final_exit)
      return false if [i0, i1, i2, i3, i4, i5].include?(nil)
      return false unless i0 < i1 && i1 < i2 && i2 < i3 && i3 < i4 && i4 < i5
      return false unless events[i0][1] == true && events[i1][1] == true && events[i2][1] == true
      return false unless events[i3][1] == false && events[i4][1] == false && events[i5][1] == false
      # Phase44D：KGC wrapper 與 YEM EO exit 之間不應再出現 legacy Passive rebuild。
      early_passive = p44a_index_after(events, :weapon_restore_passive_enter, i3 + 1)
      return false if early_passive != nil && early_passive < i4
      return true
    rescue
      return false
    end

    def p44a_final_convergence_trace?(events)
      return false unless events.is_a?(Array)
      eo_exit = p44a_index_after(events, :weapon_discard_eo_exit, 0)
      return false if eo_exit == nil
      teaching_enter = p44a_index_after(events, :weapon_teaching_refresh_enter, eo_exit + 1)
      return false if teaching_enter == nil
      teaching_exit = p44a_index_after(events, :weapon_teaching_refresh_exit, teaching_enter + 1)
      return false if teaching_exit == nil

      passive_enter = p44a_index_after(events, :weapon_equipment_passive_enter, teaching_exit + 1)
      passive_exit = nil
      if passive_enter != nil
        passive_exit = p44a_index_after(events, :weapon_equipment_passive_exit, passive_enter + 1)
      else
        passive_enter = p44a_index_after(events, :weapon_restore_passive_enter, teaching_exit + 1)
        passive_exit = p44a_index_after(events, :weapon_restore_passive_exit, passive_enter == nil ? teaching_exit + 1 : passive_enter + 1)
      end
      return false if passive_enter == nil || passive_exit == nil

      combo_enter = p44a_index_after(events, :weapon_combo_refresh_enter, passive_exit + 1)
      return false if combo_enter == nil
      combo_exit = p44a_index_after(events, :weapon_combo_refresh_exit, combo_enter + 1)
      return false if combo_exit == nil
      final_exit = p44a_index_after(events, :weapon_discard_final_exit, combo_exit + 1)
      return false if final_exit == nil

      [teaching_enter, teaching_exit, passive_enter, passive_exit,
       combo_enter, combo_exit, final_exit].each do |index|
        entry = events[index]
        return false unless entry.is_a?(Array) && entry[1] == false
      end
      return true
    rescue
      return false
    end

    def p44a_run_weapon_provider_probe
      fixture = nil
      skill_slot = nil
      weapon_slot = nil
      weapon = nil
      detached = nil
      inventory_slot = nil
      weapon_count = nil
      begin
        fixture = p42d_prepare_synthetic_learning_fixture
        assert("Weapon discard provider synthetic learning fixture prepared", fixture != nil)
        return false if fixture == nil

        actor_id = fixture[:actor_id].to_i
        teaching_skill_id = fixture[:skill_id].to_i
        pre_level = fixture[:pre_level].to_i
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        unnatural_baseline = p41c_unnatural_skill_ids(detached)
        level_ok = p42c_set_level_for_fixture(detached, pre_level)
        assert("Weapon discard provider detached Actor below natural threshold",
               level_ok && !detached.albert_natural_level_skill?(teaching_skill_id),
               "actor=#{actor_id} level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{teaching_skill_id}")
        return false unless level_ok && !detached.albert_natural_level_skill?(teaching_skill_id)

        skill_slot = p42h_prepare_synthetic_skill_slot(teaching_skill_id)
        assert("Weapon discard provider synthetic Passive Skill clone prepared", skill_slot != nil,
               "skill=#{teaching_skill_id}")
        return false if skill_slot == nil
        skill = skill_slot[:synthetic]
        passive_ok = p42f_apply_synthetic_passive(skill)
        assert("Weapon discard provider synthetic Teaching Skill parses Passive effects", passive_ok,
               "skill=#{teaching_skill_id}:#{skill.name}")
        return false unless passive_ok
        slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
        assert("Weapon discard provider synthetic Skill owns database slot", slot_active,
               "skill=#{teaching_skill_id}")
        return false unless slot_active

        direct_skill_id = p44a_direct_skill_id(detached, [teaching_skill_id])
        assert("Weapon discard provider independent Direct Skill resolved",
               direct_skill_id != nil && direct_skill_id.to_i > 0 && $data_skills[direct_skill_id.to_i] != nil,
               "teaching=#{teaching_skill_id} direct=#{direct_skill_id.inspect}")
        return false if direct_skill_id == nil || direct_skill_id.to_i <= 0

        weapon_original = p44a_clean_weapon(detached)
        assert("Weapon discard provider clean equippable Weapon resolved", weapon_original != nil,
               "actor=#{actor_id} formal_weapons=#{p44a_formal_equipped_weapon_ids.inspect}")
        return false if weapon_original == nil
        weapon_slot = p44a_clone_weapon_slot(weapon_original)
        assert("Weapon discard provider Weapon database-slot clone prepared", weapon_slot != nil,
               "weapon=#{weapon_original.id}:#{weapon_original.name}")
        return false if weapon_slot == nil
        weapon = weapon_slot[:synthetic]

        direct_tag = "<equipskill: #{direct_skill_id}>"
        teaching_tag = "\\ls[#{teaching_skill_id}, #{pre_level}]"
        weapon.note = weapon.note.to_s + (weapon.note.to_s.empty? ? "" : "\n") + direct_tag + "\n" + teaching_tag
        weapon.instance_variable_set(:@equipment_skills, nil)
        direct_ids = (weapon.skills rescue []).compact.collect { |s| s.id.to_i }
        teaching_entries = weapon.skill_ids rescue []
        assert("Weapon discard provider synthetic Weapon parses Direct equipskill",
               direct_ids.include?(direct_skill_id.to_i),
               "weapon=#{weapon.id} direct=#{direct_skill_id} parsed=#{direct_ids.inspect}")
        assert("Weapon discard provider parser supports Teaching \\ls on Weapon/BaseItem",
               teaching_entries != nil && teaching_entries.include?([teaching_skill_id, pre_level]),
               "weapon=#{weapon.id} tag=#{teaching_tag.inspect} parsed=#{teaching_entries.inspect}")

        weapon_count = $game_party.item_number(weapon).to_i
        inventory_slot = p42e_inventory_slot_snapshot(weapon)
        new_before = p41c_new_flag(weapon)
        assert("Weapon discard provider inventory Hash baseline captured", inventory_slot != nil,
               "weapon=#{weapon.id}:#{weapon.name} count=#{weapon_count} new=#{new_before.inspect}")
        return false if inventory_slot == nil

        # Detached Actor 的既有主武器先用 test=true 正式 API 清空；避免 prerequisite grant
        # 牽連原始武器 inventory。真正 synthetic Weapon 的裝備則走 test=false + Party API。
        detached.change_equip(0, nil, true)
        detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
        passive_baseline = p42f_passive_signature(detached)
        assert("Weapon discard provider Passive baseline captured", passive_baseline != nil,
               passive_baseline.inspect)

        grant_ok = p42a_restore_party_item_count(weapon, weapon_count + 1)
        assert("Weapon discard provider prerequisite Weapon granted through formal Party API", grant_ok,
               "expected=#{weapon_count + 1} actual=#{$game_party.item_number(weapon)}")
        assert("Weapon discard provider prerequisite grant preserves NEW flag",
               p41c_new_flag(weapon) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(weapon).inspect}")

        detached.change_equip(0, weapon)
        pre_direct_visible = p42k_skill_visible?(detached, direct_skill_id)
        pre_direct_raw = p37_raw_skill_learned?(detached, direct_skill_id)
        pre_teaching_raw = p37_raw_skill_learned?(detached, teaching_skill_id)
        pre_markers = p41c_unnatural_skill_ids(detached)
        passive_active = p42f_passive_signature(detached)
        log("[AUTH_WEAPON_PROVIDER] pre actor=#{actor_id} weapon=#{weapon.id}:#{weapon.name} " +
            "direct=#{direct_skill_id} visible=#{pre_direct_visible} raw=#{pre_direct_raw} " +
            "teaching=#{teaching_skill_id} raw=#{pre_teaching_raw} markers=#{pre_markers.inspect} " +
            "passive=#{passive_active.inspect} inventory=#{$game_party.item_number(weapon)} new=#{p41c_new_flag(weapon).inspect}")
        assert("Weapon discard provider Weapon formally equipped", p37_equipped_item?(detached, weapon),
               "equips=#{p37_equip_signature(detached).inspect}")
        assert("Weapon discard Direct provider visible without raw learned ownership",
               pre_direct_visible && !pre_direct_raw,
               "direct=#{direct_skill_id} visible=#{pre_direct_visible} raw=#{pre_direct_raw}")
        assert("Weapon discard Teaching provider creates temporary raw/marker ownership",
               pre_teaching_raw && pre_markers.include?(teaching_skill_id),
               "skill=#{teaching_skill_id} raw=#{pre_teaching_raw} markers=#{pre_markers.inspect}")
        weapon_passive_pre_ok = passive_baseline != nil && passive_active != nil &&
                                passive_active[:atk].to_i == passive_baseline[:atk].to_i + 37 &&
                                passive_active[:def].to_i == passive_baseline[:def].to_i + 13 &&
                                passive_active[:critical_bonus] == true &&
                                passive_active[:cri].to_i == passive_baseline[:cri].to_i + 4
        assert("Equipment passive Weapon Teaching provider activates Passive before discard",
               weapon_passive_pre_ok,
               "baseline=#{passive_baseline.inspect} current=#{passive_active.inspect} active=#{weapon_passive_pre_ok}")
        assert_equal("Weapon discard provider equip consumes exactly prepared Weapon", weapon_count,
                     $game_party.item_number(weapon).to_i)

        p44a_discard_trace_begin(weapon)
        begin
          detached.discard_equip(weapon)
        ensure
          events = p44a_discard_trace_end
        end
        trace_counts = p44a_trace_counts(events)
        post_direct_visible = p42k_skill_visible?(detached, direct_skill_id)
        post_direct_raw = p37_raw_skill_learned?(detached, direct_skill_id)
        post_teaching_raw = p37_raw_skill_learned?(detached, teaching_skill_id)
        post_markers = p41c_unnatural_skill_ids(detached)
        passive_after = p42f_passive_signature(detached)
        log("[AUTH_WEAPON_PROVIDER] discard weapon=#{weapon.id}:#{weapon.name} events=#{events.inspect} counts=#{trace_counts.inspect} " +
            "equips_after=#{p37_equip_signature(detached).inspect} direct_visible=#{post_direct_visible} direct_raw=#{post_direct_raw} " +
            "teaching_raw=#{post_teaching_raw} markers=#{post_markers.inspect} passive=#{passive_after.inspect}")

        assert("Weapon discard removes main-slot Weapon through formal discard path",
               !p37_equipped_item?(detached, weapon),
               "equips=#{p37_equip_signature(detached).inspect}")
        assert("Weapon discard exact base wrapper order/count captured",
               p44a_base_discard_trace_ok(events),
               "events=#{events.inspect} counts=#{trace_counts.inspect}")
        final_trace = p44a_final_convergence_trace?(events)
        assert("Weapon discard executes post-removal Teaching/Passive/Combo final convergence",
               final_trace,
               "events=#{events.inspect} counts=#{trace_counts.inspect}")
        weapon_single_passive = trace_counts[:weapon_restore_passive_enter].to_i == 1
        weapon_teach_enter = p44a_index_after(events, :weapon_teaching_refresh_enter, 0)
        weapon_teach_exit = p44a_index_after(events, :weapon_teaching_refresh_exit, weapon_teach_enter == nil ? 0 : weapon_teach_enter + 1)
        weapon_nested_restore = false
        if weapon_teach_enter != nil && weapon_teach_exit != nil && weapon_teach_enter < weapon_teach_exit
          ((weapon_teach_enter + 1)...weapon_teach_exit).each do |idx|
            entry = events[idx]
            weapon_nested_restore = true if entry.is_a?(Array) && entry[0] == :weapon_restore_passive_enter
          end
        end
        assert("Weapon Teaching discard uses exactly one final Passive refresh with no nested rebuild",
               weapon_single_passive && !weapon_nested_restore,
               "events=#{events.inspect} counts=#{trace_counts.inspect}")

        direct_clean = !post_direct_visible && !post_direct_raw
        assert("Weapon discard Direct equipskill visibility disappears immediately",
               direct_clean,
               "skill=#{direct_skill_id} visible=#{post_direct_visible} raw=#{post_direct_raw}")
        teaching_clean = !post_teaching_raw && !post_markers.include?(teaching_skill_id)
        assert("Weapon discard clears temporary Teaching raw skill / marker ownership",
               teaching_clean,
               "skill=#{teaching_skill_id} raw=#{post_teaching_raw} markers=#{post_markers.inspect}")
        passive_clean = passive_after == passive_baseline
        assert("Weapon discard Passive cache rebuilds from final Weapon ownership",
               passive_clean,
               "baseline=#{passive_baseline.inspect} after=#{passive_after.inspect}")

        # FAIL 也必須把 detached probe 清乾淨，Formal defect 不能污染下一個 fixture。
        detached.albert_refresh_equipment_teaching_skills if detached.respond_to?(:albert_refresh_equipment_teaching_skills)
        detached.albert_refresh_equipment_passive_skills if detached.respond_to?(:albert_refresh_equipment_passive_skills)
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        cleanup_ok = !p37_raw_skill_learned?(detached, teaching_skill_id) &&
                     !p41c_unnatural_skill_ids(detached).include?(teaching_skill_id) &&
                     p42f_passive_signature(detached) == passive_baseline
        assert("Weapon discard provider TEST cleanup restores Teaching/Passive baseline", cleanup_ok,
               "raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect} passive=#{p42f_passive_signature(detached).inspect}")

        count_restored = p42a_restore_party_item_count(weapon, weapon_count)
        assert("Weapon discard provider inventory count restored through formal Party API", count_restored,
               "expected=#{weapon_count} actual=#{$game_party.item_number(weapon)}")
        assert("Weapon discard provider final NEW flag restored",
               p41c_new_flag(weapon) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(weapon).inspect}")
        tombstone_restored = p42e_restore_inventory_slot(weapon, inventory_slot)
        assert("Weapon discard provider inventory Hash slot restored exactly", tombstone_restored,
               "snapshot=#{inventory_slot.inspect}")

        weapon_restored = p44a_restore_weapon_slot(weapon_slot)
        assert("Weapon discard provider original Weapon slot/object/bytes restored", weapon_restored,
               "weapon=#{weapon_slot[:id]}")
        weapon_slot = nil if weapon_restored
        skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
        assert("Weapon discard provider original Skill database slot/object/bytes restored", skill_restored,
               "skill=#{teaching_skill_id}")
        skill_slot = nil if skill_restored
        learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
        assert("Weapon discard provider synthetic Class learning restored exactly", learning_restored,
               "class=#{fixture[:class_id]}")
        fixture = nil if learning_restored

        detached.setup(actor_id)
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         p41c_unnatural_skill_ids(detached) == unnatural_baseline
        assert("Weapon discard provider detached Actor setup baseline restored", actor_restored,
               "before=#{actor_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")

        return direct_clean && teaching_clean && passive_clean && final_trace && cleanup_ok &&
               count_restored && tombstone_restored && weapon_restored && skill_restored &&
               learning_restored && actor_restored
      rescue Exception => e
        exception(e, "p44a_run_weapon_provider_probe")
        assert("Weapon discard Direct/Teaching/Passive diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p42a_restore_party_item_count(weapon, weapon_count) if weapon != nil && weapon_count != nil
          p42e_restore_inventory_slot(weapon, inventory_slot) if weapon != nil && inventory_slot != nil
        rescue
        end
        begin
          p44a_restore_weapon_slot(weapon_slot) if weapon_slot != nil
        rescue
        end
        begin
          p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
        rescue
        end
        begin
          p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
        rescue
        end
      end
    end

    def p44a_run_weapon_combo_probe
      weapon_slot = nil
      armor_slot = nil
      detached = nil
      begin
        actor_id = 1
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        states_baseline = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        owned_had_baseline = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        owned_baseline = owned_had_baseline ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        owned_baseline = owned_baseline == nil ? nil : owned_baseline.clone
        state_id = p43d_choose_combo_state(detached)
        assert("Weapon discard Combo usable actor-state fixture resolved",
               state_id > 0 && $data_states[state_id] != nil,
               "actor=#{actor_id} state=#{state_id}")
        return false if state_id <= 0 || $data_states[state_id] == nil

        weapon_original = p44a_clean_weapon(detached)
        assert("Weapon discard Combo clean required Weapon resolved", weapon_original != nil,
               "actor=#{actor_id} formal_weapons=#{p44a_formal_equipped_weapon_ids.inspect}")
        return false if weapon_original == nil
        weapon_slot = p44a_clone_weapon_slot(weapon_original)
        assert("Weapon discard Combo Weapon database-slot clone prepared", weapon_slot != nil,
               "weapon=#{weapon_original.id}:#{weapon_original.name}")
        return false if weapon_slot == nil
        weapon = weapon_slot[:synthetic]

        armor_original, slot = p43f_clean_standard_slot_armor(detached)
        assert("Weapon discard Combo clean trigger Armor/base slot resolved",
               armor_original != nil && slot != nil && slot.to_i >= 1 && slot.to_i <= 4,
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil
        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Weapon discard Combo trigger Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") +
                     "<combo_actor:#{actor_id}>\n<combo_require_weapon:#{weapon.id}>\n<combo_actor_state:#{state_id}>"
        armor.instance_variable_set(:@albert_combo_cache_loaded, false)
        required_weapons = armor.albert_combo_required_weapons rescue []
        actor_states = armor.albert_combo_actor_state_ids rescue []
        assert("Weapon discard Combo trigger parses required Weapon + actor-state ownership",
               required_weapons.include?(weapon.id.to_i) && actor_states.include?(state_id),
               "armor=#{armor.id} required=#{required_weapons.inspect} states=#{actor_states.inspect}")

        detached.change_equip(0, nil, true)
        detached.change_equip(slot, armor, true)
        detached.change_equip(0, weapon, true)
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned = [] if owned == nil
        assert("Weapon discard Combo precondition keeps trigger Armor + required Weapon equipped",
               p37_equipped_item?(detached, armor) && p37_equipped_item?(detached, weapon) &&
               (detached.albert_combo_effect_active?(armor) rescue false),
               "equips=#{p37_equip_signature(detached).inspect}")
        assert("Weapon discard Combo precondition owns synthetic State",
               detached.state?(state_id) && owned.include?(state_id),
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned.inspect}")

        p44a_discard_trace_begin(weapon)
        begin
          detached.discard_equip(weapon)
        ensure
          events = p44a_discard_trace_end
        end
        trace_counts = p44a_trace_counts(events)
        owned_after = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_after = [] if owned_after == nil
        state_after = detached.state?(state_id)
        combo_active_after = detached.albert_combo_effect_active?(armor) rescue false
        log("[AUTH_WEAPON_COMBO] discard weapon=#{weapon.id}:#{weapon.name} trigger_armor=#{armor.id}:#{armor.name} " +
            "events=#{events.inspect} counts=#{trace_counts.inspect} combo_active=#{combo_active_after} " +
            "state=#{state_id} active_after=#{state_after} owned_after=#{owned_after.inspect}")

        assert("Weapon discard Combo removes required Weapon but keeps trigger Armor",
               !p37_equipped_item?(detached, weapon) && p37_equipped_item?(detached, armor),
               "equips=#{p37_equip_signature(detached).inspect}")
        assert("Weapon discard Combo condition becomes false after required Weapon removal",
               combo_active_after == false,
               "armor=#{armor.id} required_weapon=#{weapon.id} active=#{combo_active_after}")
        assert("Weapon discard Combo exact base wrapper order/count captured",
               p44a_base_discard_trace_ok(events),
               "events=#{events.inspect} counts=#{trace_counts.inspect}")
        final_trace = p44a_final_convergence_trace?(events)
        assert("Weapon discard Combo path executes post-removal Teaching/Passive/Combo final convergence",
               final_trace,
               "events=#{events.inspect} counts=#{trace_counts.inspect}")
        combo_clean = !state_after && !owned_after.include?(state_id)
        assert("Weapon discard refreshes Combo-owned State after required Weapon removal",
               combo_clean,
               "state=#{state_id} active=#{state_after} owned=#{owned_after.inspect} events=#{events.inspect}")

        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        owned_cleanup = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_cleanup = [] if owned_cleanup == nil
        cleanup_ok = !detached.state?(state_id) && !owned_cleanup.include?(state_id)
        assert("Weapon discard Combo TEST cleanup restores State ownership baseline", cleanup_ok,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned_cleanup.inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        assert("Weapon discard Combo original trigger Armor slot/object/bytes restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        armor_slot = nil if armor_restored
        weapon_restored = p44a_restore_weapon_slot(weapon_slot)
        assert("Weapon discard Combo original Weapon slot/object/bytes restored", weapon_restored,
               "weapon=#{weapon_slot[:id]}")
        weapon_slot = nil if weapon_restored

        if owned_had_baseline
          detached.instance_variable_set(:@albert_combo_owned_state_ids, owned_baseline == nil ? nil : owned_baseline.clone)
        else
          if p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
            detached.send(:remove_instance_variable, :@albert_combo_owned_state_ids)
          end
        end
        detached.setup(actor_id)
        current_states = (detached.states.compact.collect { |state| state.id.to_i } rescue [])
        current_owned_had = p42l_instance_variable_defined_compat?(detached, "@albert_combo_owned_state_ids")
        current_owned = current_owned_had ? (detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil) : nil
        current_owned = current_owned == nil ? nil : current_owned.clone
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         current_states == states_baseline && current_owned_had == owned_had_baseline &&
                         current_owned == owned_baseline
        assert("Weapon discard Combo detached Actor/state baseline restored", actor_restored,
               "states=#{states_baseline.inspect}->#{current_states.inspect} owned=#{owned_baseline.inspect}->#{current_owned.inspect}")

        return combo_clean && final_trace && cleanup_ok && armor_restored && weapon_restored && actor_restored
      rescue Exception => e
        exception(e, "p44a_run_weapon_combo_probe")
        assert("Weapon discard required-Weapon Combo diagnostic completed", false, e.message)
        return false
      ensure
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
        begin
          p44a_restore_weapon_slot(weapon_slot) if weapon_slot != nil
        rescue
        end
      end
    end

    def p44a_run_weapon_discard_authority_diagnostic
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      fail_before = @fail.to_i
      provider_ok = p44a_run_weapon_provider_probe
      combo_ok = p44a_run_weapon_combo_probe
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && party_after == party_before &&
                     actors_before != nil && actors_after == actors_before
      assert("Weapon discard diagnostic leaves Game_Party / $game_actors exact",
             global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} " +
             "actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")
      @p44a_weapon_discard_authority = {
        :provider_clean=>provider_ok,
        :combo_clean=>combo_ok,
        :global_clean=>global_clean,
        :fail_delta=>@fail.to_i - fail_before,
        :ready=>provider_ok && combo_ok && global_clean
      }
      assert("Weapon discard Direct / Teaching / Passive / Combo diagnostic completed",
             @p44a_weapon_discard_authority[:ready] == true,
             @p44a_weapon_discard_authority.inspect)
      return @p44a_weapon_discard_authority[:ready] == true
    rescue Exception => e
      exception(e, "p44a_run_weapon_discard_authority_diagnostic")
      assert("Weapon discard Direct / Teaching / Passive / Combo diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase44a_prepare_battle_fixture_on_map_base)
      alias fs_phase44a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44a_prepare_battle_fixture_on_map_base
      return p44a_run_weapon_discard_authority_diagnostic
    end

    unless method_defined?(:fs_phase44a_restore_pending_base)
      alias fs_phase44a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44a_restore_pending_base
      if result
        @p44a_weapon_discard_authority = nil
        @p44a_weapon_trace_active = false
        @p44a_weapon_trace_events = []
        @p44a_weapon_trace_target_class = nil
        @p44a_weapon_trace_target_id = 0
      end
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only wrappers：Phase44A 獨立記錄 Weapon discard exact chain。
# 與 Phase43 p43a recorder 並存，但各自只有自己的 active flag 開啟時才記錄。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:discard_equip) && !method_defined?(:fs_p44a_weapon_discard_final_base)
      alias fs_p44a_weapon_discard_final_base discard_equip
      def discard_equip(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_final_enter)
        result = fs_p44a_weapon_discard_final_base(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_final_exit)
        return result
      end
    end

    if method_defined?(:discard_equip_eo) && !method_defined?(:fs_p44a_weapon_discard_eo_base)
      alias fs_p44a_weapon_discard_eo_base discard_equip_eo
      def discard_equip_eo(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_eo_enter)
        result = fs_p44a_weapon_discard_eo_base(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_eo_exit)
        return result
      end
    end

    if method_defined?(:discard_equip_KGC_PassiveSkill) && !method_defined?(:fs_p44a_weapon_discard_kgc_base)
      alias fs_p44a_weapon_discard_kgc_base discard_equip_KGC_PassiveSkill
      def discard_equip_KGC_PassiveSkill(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_kgc_base_enter)
        result = fs_p44a_weapon_discard_kgc_base(item)
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_discard_kgc_base_exit)
        return result
      end
    end

    if method_defined?(:restore_passive_rev) && !method_defined?(:fs_p44a_weapon_restore_passive_base)
      alias fs_p44a_weapon_restore_passive_base restore_passive_rev
      def restore_passive_rev
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_restore_passive_enter)
        result = fs_p44a_weapon_restore_passive_base
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_restore_passive_exit)
        return result
      end
    end

    if method_defined?(:albert_refresh_equipment_teaching_skills) &&
       !method_defined?(:fs_p44a_weapon_teaching_refresh_base)
      alias fs_p44a_weapon_teaching_refresh_base albert_refresh_equipment_teaching_skills
      def albert_refresh_equipment_teaching_skills
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_teaching_refresh_enter)
        result = fs_p44a_weapon_teaching_refresh_base
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_teaching_refresh_exit)
        return result
      end
    end

    if method_defined?(:albert_refresh_equipment_passive_skills) &&
       !method_defined?(:fs_p44a_weapon_equipment_passive_base)
      alias fs_p44a_weapon_equipment_passive_base albert_refresh_equipment_passive_skills
      def albert_refresh_equipment_passive_skills
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_equipment_passive_enter)
        result = fs_p44a_weapon_equipment_passive_base
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_equipment_passive_exit)
        return result
      end
    end

    if method_defined?(:albert_refresh_combo_actor_states) &&
       !method_defined?(:fs_p44a_weapon_combo_refresh_base)
      alias fs_p44a_weapon_combo_refresh_base albert_refresh_combo_actor_states
      def albert_refresh_combo_actor_states
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_combo_refresh_enter)
        result = fs_p44a_weapon_combo_refresh_base
        FS_TEST_HARNESS.p44a_record_discard(self, :weapon_combo_refresh_exit)
        return result
      end
    end
  end
end

#==============================================================================
# ■ Phase44B｜Legality / purge_unequippable Automatic Removal Authority Diagnostic
#------------------------------------------------------------------------------
# TEST-only：Phase44A1 已封版 discard_equip（Weapon + Armor）final convergence。
# 本階段不修改 Formal Runtime，改測 YEM Equipment Overhaul#purge_unequippable：
#   1. 已裝備 Weapon 因 legality 失效被自動卸下時，Direct / Teaching / Passive /
#      required-Weapon Combo ownership 是否透過正式 change_equip 收斂。
#   2. YEM extra-slot Armor 因 legality 失效被自動卸下時，Direct / Teaching /
#      Passive / Combo-owned State 是否同樣收斂。
# Fixture 只對 database-slot clone 的 requirements 注入 TEST-only impossible
# ABOVE LEVEL 條件，不使用 Class Change，不永久改資料庫。
#==============================================================================
module FS_TEST_HARNESS
  @p44b_legality_purge_authority = nil
  @p44b_purge_trace_active = false
  @p44b_purge_trace_events = []
  @p44b_purge_target_class = nil
  @p44b_purge_target_id = 0

  class << self
    def p44b_purge_trace_begin(item)
      @p44b_purge_trace_active = true
      @p44b_purge_trace_events = []
      @p44b_purge_target_class = item == nil ? nil : item.class
      @p44b_purge_target_id = item == nil ? 0 : item.id.to_i
    end

    def p44b_purge_trace_end
      events = @p44b_purge_trace_events == nil ? [] : @p44b_purge_trace_events.clone
      @p44b_purge_trace_active = false
      @p44b_purge_trace_events = []
      @p44b_purge_target_class = nil
      @p44b_purge_target_id = 0
      return events
    end

    def p44b_record_purge(actor, tag)
      return unless @p44b_purge_trace_active == true
      return if actor == nil
      klass = @p44b_purge_target_class
      target_id = @p44b_purge_target_id.to_i
      equipped = false
      begin
        equipped = actor.equips.compact.any? do |item|
          item != nil && item.class == klass && item.id.to_i == target_id
        end
      rescue
        equipped = false
      end
      purge_on = actor.instance_variable_get(:@purge_on) rescue nil
      @p44b_purge_trace_events << [tag, purge_on == true, equipped]
    rescue
    end

    def p44b_event_tags(events)
      return [] unless events.is_a?(Array)
      return events.collect { |entry| entry.is_a?(Array) ? entry[0] : entry }
    rescue
      return []
    end

    def p44b_purge_trace_ok(events)
      return false unless events.is_a?(Array)
      tags = p44b_event_tags(events)
      expected = [:purge_enter, :change_enter, :change_exit, :purge_exit]
      return false unless tags == expected
      return false unless events[0][1] == false && events[0][2] == true
      return false unless events[1][1] == true  && events[1][2] == true
      return false unless events[2][1] == true  && events[2][2] == false
      return false unless events[3][1] == false && events[3][2] == false
      return true
    rescue
      return false
    end

    def p44b_refresh_trace_exact_once?(events)
      tags = p41c_event_tags(events)
      return false unless tags.select { |tag| tag == :nitem_begin }.size == 1
      return false unless tags.select { |tag| tag == :teaching }.size == 1
      return false unless tags.select { |tag| tag == :passive }.size == 1
      return false unless tags.select { |tag| tag == :combo }.size == 1
      return false unless tags.select { |tag| tag == :nitem_end }.size == 1
      begin_i = tags.index(:nitem_begin)
      teach_i = tags.index(:teaching)
      passive_i = tags.index(:passive)
      combo_i = tags.index(:combo)
      end_i = tags.index(:nitem_end)
      return begin_i < teach_i && teach_i < passive_i && passive_i < combo_i && combo_i < end_i
    rescue
      return false
    end

    def p44b_make_illegal_by_level(item, actor)
      return false if item == nil || actor == nil
      value = actor.level.to_i + 999
      item.requirements = {"ABOVE LEVEL"=>value}
      return !(actor.equippable?(item) rescue true)
    rescue
      return false
    end

    def p44b_run_weapon_legality_purge_probe
      fixture = nil
      skill_slot = nil
      weapon_slot = nil
      armor_slot = nil
      weapon = nil
      armor = nil
      detached = nil
      inventory_slot = nil
      weapon_count = nil
      begin
        fixture = p42d_prepare_synthetic_learning_fixture
        assert("Legality purge Weapon synthetic learning fixture prepared", fixture != nil)
        return false if fixture == nil

        actor_id = fixture[:actor_id].to_i
        teaching_skill_id = fixture[:skill_id].to_i
        pre_level = fixture[:pre_level].to_i
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        unnatural_baseline = p41c_unnatural_skill_ids(detached)
        level_ok = p42c_set_level_for_fixture(detached, pre_level)
        assert("Legality purge Weapon detached Actor below natural threshold",
               level_ok && !detached.albert_natural_level_skill?(teaching_skill_id),
               "actor=#{actor_id} level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{teaching_skill_id}")
        return false unless level_ok && !detached.albert_natural_level_skill?(teaching_skill_id)

        skill_slot = p42h_prepare_synthetic_skill_slot(teaching_skill_id)
        assert("Legality purge Weapon synthetic Passive Skill clone prepared", skill_slot != nil,
               "skill=#{teaching_skill_id}")
        return false if skill_slot == nil
        skill = skill_slot[:synthetic]
        passive_ok = p42f_apply_synthetic_passive(skill)
        assert("Legality purge Weapon synthetic Teaching Skill parses Passive effects", passive_ok,
               "skill=#{teaching_skill_id}:#{skill.name}")
        return false unless passive_ok
        slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
        assert("Legality purge Weapon synthetic Skill owns database slot", slot_active,
               "skill=#{teaching_skill_id}")
        return false unless slot_active

        direct_skill_id = p44a_direct_skill_id(detached, [teaching_skill_id])
        assert("Legality purge Weapon independent Direct Skill resolved",
               direct_skill_id != nil && direct_skill_id.to_i > 0,
               "teaching=#{teaching_skill_id} direct=#{direct_skill_id.inspect}")
        return false if direct_skill_id == nil || direct_skill_id.to_i <= 0

        weapon_original = p44a_clean_weapon(detached)
        assert("Legality purge clean equippable Weapon resolved", weapon_original != nil,
               "actor=#{actor_id} formal_weapons=#{p44a_formal_equipped_weapon_ids.inspect}")
        return false if weapon_original == nil
        weapon_slot = p44a_clone_weapon_slot(weapon_original)
        assert("Legality purge Weapon database-slot clone prepared", weapon_slot != nil,
               "weapon=#{weapon_original.id}:#{weapon_original.name}")
        return false if weapon_slot == nil
        weapon = weapon_slot[:synthetic]
        weapon.note = weapon.note.to_s + (weapon.note.to_s.empty? ? "" : "\n") +
                      "<equipskill: #{direct_skill_id}>\n\\ls[#{teaching_skill_id}, #{pre_level}]"
        weapon.instance_variable_set(:@equipment_skills, nil)
        direct_ids = (weapon.skills rescue []).compact.collect { |s| s.id.to_i }
        teaching_entries = weapon.skill_ids rescue []
        assert("Legality purge Weapon parses Direct + Teaching providers",
               direct_ids.include?(direct_skill_id.to_i) &&
               teaching_entries != nil && teaching_entries.include?([teaching_skill_id, pre_level]),
               "direct=#{direct_ids.inspect} teaching=#{teaching_entries.inspect}")

        state_id = p43d_choose_combo_state(detached)
        assert("Legality purge Weapon Combo usable actor-state fixture resolved", state_id.to_i > 0,
               "actor=#{actor_id} state=#{state_id}")
        return false if state_id.to_i <= 0
        armor_original, trigger_slot = p43f_clean_standard_slot_armor(detached)
        assert("Legality purge Weapon Combo clean trigger Armor resolved",
               armor_original != nil && trigger_slot != nil,
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{trigger_slot.inspect}")
        return false if armor_original == nil || trigger_slot == nil
        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Legality purge Weapon Combo trigger Armor clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") +
                     "<combo_actor:#{actor_id}>\n<combo_require_weapon:#{weapon.id}>\n<combo_actor_state:#{state_id}>"
        armor.instance_variable_set(:@albert_combo_cache_loaded, false)
        required_weapons = armor.albert_combo_required_weapons rescue []
        actor_states = armor.albert_combo_actor_state_ids rescue []
        assert("Legality purge Weapon Combo metadata parses required Weapon + State",
               required_weapons.include?(weapon.id.to_i) && actor_states.include?(state_id),
               "required=#{required_weapons.inspect} states=#{actor_states.inspect}")

        weapon_count = $game_party.item_number(weapon).to_i
        inventory_slot = p42e_inventory_slot_snapshot(weapon)
        new_before = p41c_new_flag(weapon)
        assert("Legality purge Weapon inventory Hash baseline captured", inventory_slot != nil,
               "weapon=#{weapon.id}:#{weapon.name} count=#{weapon_count} new=#{new_before.inspect}")
        return false if inventory_slot == nil

        detached.change_equip(0, nil, true)
        detached.change_equip(trigger_slot, armor, true)
        detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
        passive_baseline = p42f_passive_signature(detached)
        assert("Legality purge Weapon Passive baseline captured with trigger Armor retained",
               passive_baseline != nil, passive_baseline.inspect)

        grant_ok = p42a_restore_party_item_count(weapon, weapon_count + 1)
        assert("Legality purge Weapon prerequisite granted through formal Party API", grant_ok,
               "expected=#{weapon_count + 1} actual=#{$game_party.item_number(weapon)}")
        assert("Legality purge Weapon prerequisite grant preserves NEW flag",
               p41c_new_flag(weapon) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(weapon).inspect}")

        detached.change_equip(0, weapon, false)
        owned_before = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_before = [] if owned_before == nil
        passive_active = p42f_passive_signature(detached)
        pre_ok = p37_equipped_item?(detached, weapon) && p37_equipped_item?(detached, armor) &&
                 p42k_skill_visible?(detached, direct_skill_id) &&
                 !p37_raw_skill_learned?(detached, direct_skill_id) &&
                 p37_raw_skill_learned?(detached, teaching_skill_id) &&
                 p41c_unnatural_skill_ids(detached).include?(teaching_skill_id) &&
                 (detached.state?(state_id) rescue false) && owned_before.include?(state_id)
        assert("Legality purge Weapon precondition owns Direct/Teaching/Combo providers", pre_ok,
               "equips=#{p37_equip_signature(detached).inspect} raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} " +
               "markers=#{p41c_unnatural_skill_ids(detached).inspect} state=#{detached.state?(state_id)} owned=#{owned_before.inspect}")
        passive_authority = p42j_passive_authority_signature(passive_active)
        baseline_authority = p42j_passive_authority_signature(passive_baseline)
        passive_pre_ok = passive_authority[:atk].to_i == baseline_authority[:atk].to_i + 37 &&
                         passive_authority[:def].to_i == baseline_authority[:def].to_i + 13 &&
                         passive_authority[:critical_bonus] == true
        assert("Legality purge Weapon Teaching provider activates one Passive Authority copy", passive_pre_ok,
               "baseline=#{baseline_authority.inspect} active=#{passive_authority.inspect}")
        assert_equal("Legality purge Weapon equip consumes exactly prepared Weapon", weapon_count,
                     $game_party.item_number(weapon).to_i)

        illegal = p44b_make_illegal_by_level(weapon, detached)
        assert("Legality purge Weapon synthetic requirement makes equipped Weapon illegal", illegal,
               "requirements=#{weapon.requirements.inspect} level=#{detached.level} equippable=#{detached.equippable?(weapon) rescue nil}")
        return false unless illegal

        p44b_purge_trace_begin(weapon)
        p41c_trace_begin
        begin
          detached.purge_unequippable(false)
        ensure
          refresh_events = p41c_trace_end
          purge_events = p44b_purge_trace_end
        end
        owned_after = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_after = [] if owned_after == nil
        passive_after = p42f_passive_signature(detached)
        log("[AUTH_PURGE_WEAPON] weapon=#{weapon.id}:#{weapon.name} purge=#{purge_events.inspect} refresh=#{refresh_events.inspect} " +
            "equips=#{p37_equip_signature(detached).inspect} direct=#{p42k_skill_visible?(detached, direct_skill_id)} " +
            "teaching_raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect} " +
            "passive=#{passive_after.inspect} state=#{state_id}:#{detached.state?(state_id)} owned=#{owned_after.inspect} " +
            "inventory=#{$game_party.item_number(weapon)} new=#{p41c_new_flag(weapon).inspect}")

        trace_ok = p44b_purge_trace_ok(purge_events)
        assert("Legality purge Weapon uses one non-recursive purge -> formal change_equip removal", trace_ok,
               "events=#{purge_events.inspect}")
        p41c_assert_refresh_trace("legality purge Weapon", refresh_events)
        refresh_once = p44b_refresh_trace_exact_once?(refresh_events)
        assert("Legality purge Weapon Teaching/Passive/Combo convergence occurs exactly once", refresh_once,
               "events=#{refresh_events.inspect}")
        removed = !p37_equipped_item?(detached, weapon) && p37_equipped_item?(detached, armor)
        assert("Legality purge Weapon removes only illegal Weapon and retains trigger Armor", removed,
               "equips=#{p37_equip_signature(detached).inspect}")
        direct_clean = !p42k_skill_visible?(detached, direct_skill_id) &&
                       !p37_raw_skill_learned?(detached, direct_skill_id)
        assert("Legality purge Weapon removes Direct equipskill visibility", direct_clean,
               "skill=#{direct_skill_id} visible=#{p42k_skill_visible?(detached, direct_skill_id)} raw=#{p37_raw_skill_learned?(detached, direct_skill_id)}")
        teaching_clean = !p37_raw_skill_learned?(detached, teaching_skill_id) &&
                         !p41c_unnatural_skill_ids(detached).include?(teaching_skill_id)
        assert("Legality purge Weapon clears temporary Teaching raw/marker ownership", teaching_clean,
               "skill=#{teaching_skill_id} raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect}")
        passive_clean = passive_after == passive_baseline
        assert("Legality purge Weapon rebuilds Passive from final ownership", passive_clean,
               "baseline=#{passive_baseline.inspect} after=#{passive_after.inspect}")
        combo_clean = !(detached.state?(state_id) rescue true) && !owned_after.include?(state_id) &&
                      !(detached.albert_combo_effect_active?(armor) rescue true)
        assert("Legality purge Weapon clears required-Weapon Combo-owned State", combo_clean,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned_after.inspect} combo=#{detached.albert_combo_effect_active?(armor) rescue nil}")
        inventory_ok = $game_party.item_number(weapon).to_i == weapon_count.to_i + 1
        assert("Legality purge Weapon automatic removal returns Weapon exactly once", inventory_ok,
               "expected=#{weapon_count.to_i + 1} actual=#{$game_party.item_number(weapon)}")
        assert("Legality purge Weapon automatic return preserves NEW flag",
               p41c_new_flag(weapon) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(weapon).inspect}")

        detached.change_equip(trigger_slot, nil, true)
        detached.albert_refresh_combo_actor_states if detached.respond_to?(:albert_refresh_combo_actor_states)
        count_restored = p42a_restore_party_item_count(weapon, weapon_count)
        tombstone_restored = p42e_restore_inventory_slot(weapon, inventory_slot)
        assert("Legality purge Weapon inventory count restored through formal Party API", count_restored,
               "expected=#{weapon_count} actual=#{$game_party.item_number(weapon)}")
        assert("Legality purge Weapon inventory Hash slot restored exactly", tombstone_restored,
               "snapshot=#{inventory_slot.inspect}")
        assert("Legality purge Weapon final NEW flag restored", p41c_new_flag(weapon) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(weapon).inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        weapon_restored = p44a_restore_weapon_slot(weapon_slot)
        skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
        learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
        assert("Legality purge Weapon Combo trigger Armor database slot restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        assert("Legality purge Weapon database slot restored", weapon_restored,
               "weapon=#{weapon_slot[:id]}")
        assert("Legality purge Weapon synthetic Skill database slot restored", skill_restored,
               "skill=#{teaching_skill_id}")
        assert("Legality purge Weapon synthetic Class learning restored", learning_restored,
               "class=#{fixture[:class_id]}")
        armor_slot = nil if armor_restored
        weapon_slot = nil if weapon_restored
        skill_slot = nil if skill_restored
        fixture = nil if learning_restored

        detached.setup(actor_id)
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         p41c_unnatural_skill_ids(detached) == unnatural_baseline
        assert("Legality purge Weapon detached Actor setup baseline restored", actor_restored,
               "before=#{actor_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")

        return pre_ok && passive_pre_ok && trace_ok && refresh_once && removed && direct_clean &&
               teaching_clean && passive_clean && combo_clean && inventory_ok && count_restored &&
               tombstone_restored && armor_restored && weapon_restored && skill_restored &&
               learning_restored && actor_restored
      rescue Exception => e
        exception(e, "p44b_run_weapon_legality_purge_probe")
        assert("Legality purge Weapon Authority diagnostic completed", false, e.message)
        return false
      ensure
        @p44b_purge_trace_active = false
        @p41c_trace_active = false
        begin
          p42a_restore_party_item_count(weapon, weapon_count) if weapon != nil && weapon_count != nil
          p42e_restore_inventory_slot(weapon, inventory_slot) if weapon != nil && inventory_slot != nil
        rescue
        end
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
        begin
          p44a_restore_weapon_slot(weapon_slot) if weapon_slot != nil
        rescue
        end
        begin
          p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
        rescue
        end
        begin
          p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
        rescue
        end
      end
    end

    def p44b_run_extra_armor_legality_purge_probe
      fixture = nil
      skill_slot = nil
      armor_slot = nil
      armor = nil
      detached = nil
      inventory_slot = nil
      armor_count = nil
      begin
        fixture = p42d_prepare_synthetic_learning_fixture
        assert("Legality purge extra Armor synthetic learning fixture prepared", fixture != nil)
        return false if fixture == nil

        actor_id = fixture[:actor_id].to_i
        teaching_skill_id = fixture[:skill_id].to_i
        pre_level = fixture[:pre_level].to_i
        detached = Game_Actor.new(actor_id)
        actor_baseline = p41d_global_actor_signature(detached)
        unnatural_baseline = p41c_unnatural_skill_ids(detached)
        level_ok = p42c_set_level_for_fixture(detached, pre_level)
        assert("Legality purge extra Armor detached Actor below natural threshold",
               level_ok && !detached.albert_natural_level_skill?(teaching_skill_id),
               "actor=#{actor_id} level=#{detached.level} natural=#{fixture[:natural_level]} skill=#{teaching_skill_id}")
        return false unless level_ok && !detached.albert_natural_level_skill?(teaching_skill_id)

        skill_slot = p42h_prepare_synthetic_skill_slot(teaching_skill_id)
        assert("Legality purge extra Armor synthetic Passive Skill clone prepared", skill_slot != nil,
               "skill=#{teaching_skill_id}")
        return false if skill_slot == nil
        skill = skill_slot[:synthetic]
        passive_ok = p42f_apply_synthetic_passive(skill)
        assert("Legality purge extra Armor synthetic Teaching Skill parses Passive effects", passive_ok,
               "skill=#{teaching_skill_id}:#{skill.name}")
        return false unless passive_ok
        slot_active = p42h_activate_synthetic_skill_slot(skill_slot)
        assert("Legality purge extra Armor synthetic Skill owns database slot", slot_active,
               "skill=#{teaching_skill_id}")
        return false unless slot_active

        direct_skill_id = p44a_direct_skill_id(detached, [teaching_skill_id])
        assert("Legality purge extra Armor independent Direct Skill resolved",
               direct_skill_id != nil && direct_skill_id.to_i > 0,
               "teaching=#{teaching_skill_id} direct=#{direct_skill_id.inspect}")
        return false if direct_skill_id == nil || direct_skill_id.to_i <= 0

        armor_original, slot = p43a_clean_extra_slot_armor(detached)
        assert("Legality purge clean YEM extra-slot Armor resolved",
               armor_original != nil && slot != nil && slot.to_i >= 5,
               "armor=#{armor_original == nil ? nil : armor_original.id} slot=#{slot.inspect}")
        return false if armor_original == nil || slot == nil
        armor_slot = p43d_clone_armor_slot(armor_original)
        assert("Legality purge extra Armor database-slot clone prepared", armor_slot != nil,
               "armor=#{armor_original.id}:#{armor_original.name}")
        return false if armor_slot == nil
        armor = armor_slot[:synthetic]
        state_id = p43d_choose_combo_state(detached)
        assert("Legality purge extra Armor Combo usable actor-state fixture resolved", state_id.to_i > 0,
               "actor=#{actor_id} state=#{state_id}")
        return false if state_id.to_i <= 0
        armor.note = armor.note.to_s + (armor.note.to_s.empty? ? "" : "\n") +
                     "<equipskill: #{direct_skill_id}>\n\\ls[#{teaching_skill_id}, #{pre_level}]\n" +
                     "<combo_actor:#{actor_id}>\n<combo_actor_state:#{state_id}>"
        armor.instance_variable_set(:@equipment_skills, nil)
        armor.instance_variable_set(:@albert_combo_cache_loaded, false)
        direct_ids = (armor.skills rescue []).compact.collect { |s| s.id.to_i }
        teaching_entries = armor.skill_ids rescue []
        actor_states = armor.albert_combo_actor_state_ids rescue []
        assert("Legality purge extra Armor parses Direct + Teaching + Combo providers",
               direct_ids.include?(direct_skill_id.to_i) &&
               teaching_entries != nil && teaching_entries.include?([teaching_skill_id, pre_level]) &&
               actor_states.include?(state_id),
               "direct=#{direct_ids.inspect} teaching=#{teaching_entries.inspect} states=#{actor_states.inspect}")

        armor_count = $game_party.item_number(armor).to_i
        inventory_slot = p42e_inventory_slot_snapshot(armor)
        new_before = p41c_new_flag(armor)
        assert("Legality purge extra Armor inventory Hash baseline captured", inventory_slot != nil,
               "armor=#{armor.id}:#{armor.name} count=#{armor_count} new=#{new_before.inspect}")
        return false if inventory_slot == nil

        detached.restore_passive_rev if detached.respond_to?(:restore_passive_rev)
        passive_baseline = p42f_passive_signature(detached)
        assert("Legality purge extra Armor Passive baseline captured", passive_baseline != nil,
               passive_baseline.inspect)
        grant_ok = p42a_restore_party_item_count(armor, armor_count + 1)
        assert("Legality purge extra Armor prerequisite granted through formal Party API", grant_ok,
               "expected=#{armor_count + 1} actual=#{$game_party.item_number(armor)}")
        assert("Legality purge extra Armor prerequisite grant preserves NEW flag",
               p41c_new_flag(armor) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

        detached.change_equip(slot, armor, false)
        owned_before = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_before = [] if owned_before == nil
        passive_active = p42f_passive_signature(detached)
        pre_ok = p37_equipped_item?(detached, armor) &&
                 p42k_skill_visible?(detached, direct_skill_id) &&
                 !p37_raw_skill_learned?(detached, direct_skill_id) &&
                 p37_raw_skill_learned?(detached, teaching_skill_id) &&
                 p41c_unnatural_skill_ids(detached).include?(teaching_skill_id) &&
                 (detached.state?(state_id) rescue false) && owned_before.include?(state_id)
        assert("Legality purge extra Armor precondition owns Direct/Teaching/Combo providers", pre_ok,
               "equips=#{p37_equip_signature(detached).inspect} raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} " +
               "markers=#{p41c_unnatural_skill_ids(detached).inspect} state=#{detached.state?(state_id)} owned=#{owned_before.inspect}")
        passive_authority = p42j_passive_authority_signature(passive_active)
        baseline_authority = p42j_passive_authority_signature(passive_baseline)
        passive_pre_ok = passive_authority[:atk].to_i == baseline_authority[:atk].to_i + 37 &&
                         passive_authority[:def].to_i == baseline_authority[:def].to_i + 13 &&
                         passive_authority[:critical_bonus] == true
        assert("Legality purge extra Armor Teaching provider activates one Passive Authority copy", passive_pre_ok,
               "baseline=#{baseline_authority.inspect} active=#{passive_authority.inspect}")
        assert_equal("Legality purge extra Armor equip consumes exactly prepared Armor", armor_count,
                     $game_party.item_number(armor).to_i)

        illegal = p44b_make_illegal_by_level(armor, detached)
        assert("Legality purge extra Armor synthetic requirement makes equipped Armor illegal", illegal,
               "requirements=#{armor.requirements.inspect} level=#{detached.level} equippable=#{detached.equippable?(armor) rescue nil}")
        return false unless illegal

        p44b_purge_trace_begin(armor)
        p41c_trace_begin
        begin
          detached.purge_unequippable(false)
        ensure
          refresh_events = p41c_trace_end
          purge_events = p44b_purge_trace_end
        end
        owned_after = detached.instance_variable_get(:@albert_combo_owned_state_ids) rescue []
        owned_after = [] if owned_after == nil
        passive_after = p42f_passive_signature(detached)
        log("[AUTH_PURGE_EXTRA_ARMOR] armor=#{armor.id}:#{armor.name} slot=#{slot} purge=#{purge_events.inspect} refresh=#{refresh_events.inspect} " +
            "equips=#{p37_equip_signature(detached).inspect} direct=#{p42k_skill_visible?(detached, direct_skill_id)} " +
            "teaching_raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect} " +
            "passive=#{passive_after.inspect} state=#{state_id}:#{detached.state?(state_id)} owned=#{owned_after.inspect} " +
            "inventory=#{$game_party.item_number(armor)} new=#{p41c_new_flag(armor).inspect}")

        trace_ok = p44b_purge_trace_ok(purge_events)
        assert("Legality purge extra Armor uses one non-recursive purge -> formal change_equip removal", trace_ok,
               "events=#{purge_events.inspect}")
        p41c_assert_refresh_trace("legality purge extra Armor", refresh_events)
        refresh_once = p44b_refresh_trace_exact_once?(refresh_events)
        assert("Legality purge extra Armor Teaching/Passive/Combo convergence occurs exactly once", refresh_once,
               "events=#{refresh_events.inspect}")
        removed = !p37_equipped_item?(detached, armor)
        assert("Legality purge extra Armor removes illegal YEM extra-slot Armor", removed,
               "equips=#{p37_equip_signature(detached).inspect}")
        direct_clean = !p42k_skill_visible?(detached, direct_skill_id) &&
                       !p37_raw_skill_learned?(detached, direct_skill_id)
        assert("Legality purge extra Armor removes Direct equipskill visibility", direct_clean,
               "skill=#{direct_skill_id} visible=#{p42k_skill_visible?(detached, direct_skill_id)} raw=#{p37_raw_skill_learned?(detached, direct_skill_id)}")
        teaching_clean = !p37_raw_skill_learned?(detached, teaching_skill_id) &&
                         !p41c_unnatural_skill_ids(detached).include?(teaching_skill_id)
        assert("Legality purge extra Armor clears temporary Teaching raw/marker ownership", teaching_clean,
               "skill=#{teaching_skill_id} raw=#{p37_raw_skill_learned?(detached, teaching_skill_id)} markers=#{p41c_unnatural_skill_ids(detached).inspect}")
        passive_clean = passive_after == passive_baseline
        assert("Legality purge extra Armor rebuilds Passive from final ownership", passive_clean,
               "baseline=#{passive_baseline.inspect} after=#{passive_after.inspect}")
        combo_clean = !(detached.state?(state_id) rescue true) && !owned_after.include?(state_id)
        assert("Legality purge extra Armor clears Combo-owned State", combo_clean,
               "state=#{state_id} active=#{detached.state?(state_id)} owned=#{owned_after.inspect}")
        inventory_ok = $game_party.item_number(armor).to_i == armor_count.to_i + 1
        assert("Legality purge extra Armor automatic removal returns Armor exactly once", inventory_ok,
               "expected=#{armor_count.to_i + 1} actual=#{$game_party.item_number(armor)}")
        assert("Legality purge extra Armor automatic return preserves NEW flag",
               p41c_new_flag(armor) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

        count_restored = p42a_restore_party_item_count(armor, armor_count)
        tombstone_restored = p42e_restore_inventory_slot(armor, inventory_slot)
        assert("Legality purge extra Armor inventory count restored through formal Party API", count_restored,
               "expected=#{armor_count} actual=#{$game_party.item_number(armor)}")
        assert("Legality purge extra Armor inventory Hash slot restored exactly", tombstone_restored,
               "snapshot=#{inventory_slot.inspect}")
        assert("Legality purge extra Armor final NEW flag restored", p41c_new_flag(armor) == new_before,
               "before=#{new_before.inspect} after=#{p41c_new_flag(armor).inspect}")

        armor_restored = p43d_restore_armor_slot(armor_slot)
        skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
        learning_restored = p42d_restore_synthetic_learning_fixture(fixture)
        assert("Legality purge extra Armor database slot restored", armor_restored,
               "armor=#{armor_slot[:id]}")
        assert("Legality purge extra Armor synthetic Skill database slot restored", skill_restored,
               "skill=#{teaching_skill_id}")
        assert("Legality purge extra Armor synthetic Class learning restored", learning_restored,
               "class=#{fixture[:class_id]}")
        armor_slot = nil if armor_restored
        skill_slot = nil if skill_restored
        fixture = nil if learning_restored

        detached.setup(actor_id)
        actor_restored = p41d_global_actor_signature(detached) == actor_baseline &&
                         p41c_unnatural_skill_ids(detached) == unnatural_baseline
        assert("Legality purge extra Armor detached Actor setup baseline restored", actor_restored,
               "before=#{actor_baseline.inspect} after=#{p41d_global_actor_signature(detached).inspect}")

        return pre_ok && passive_pre_ok && trace_ok && refresh_once && removed && direct_clean &&
               teaching_clean && passive_clean && combo_clean && inventory_ok && count_restored &&
               tombstone_restored && armor_restored && skill_restored && learning_restored && actor_restored
      rescue Exception => e
        exception(e, "p44b_run_extra_armor_legality_purge_probe")
        assert("Legality purge extra Armor Authority diagnostic completed", false, e.message)
        return false
      ensure
        @p44b_purge_trace_active = false
        @p41c_trace_active = false
        begin
          p42a_restore_party_item_count(armor, armor_count) if armor != nil && armor_count != nil
          p42e_restore_inventory_slot(armor, inventory_slot) if armor != nil && inventory_slot != nil
        rescue
        end
        begin
          p43d_restore_armor_slot(armor_slot) if armor_slot != nil
        rescue
        end
        begin
          p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
        rescue
        end
        begin
          p42d_restore_synthetic_learning_fixture(fixture) if fixture != nil
        rescue
        end
      end
    end

    def p44b_run_legality_purge_authority_diagnostic
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      weapon_ok = p44b_run_weapon_legality_purge_probe
      extra_ok = p44b_run_extra_armor_legality_purge_probe
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("Legality purge diagnostic leaves Game_Party / $game_actors exact", global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} " +
             "actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")
      fail_delta = @fail.to_i - fail_before
      @p44b_legality_purge_authority = {
        :weapon_clean=>weapon_ok,
        :extra_armor_clean=>extra_ok,
        :global_clean=>global_clean,
        :fail_delta=>fail_delta,
        :ready=>weapon_ok && extra_ok && global_clean && fail_delta == 0
      }
      assert("Legality / purge automatic-removal Authority diagnostic completed",
             @p44b_legality_purge_authority[:ready] == true,
             @p44b_legality_purge_authority.inspect)
      return @p44b_legality_purge_authority[:ready] == true
    rescue Exception => e
      exception(e, "p44b_run_legality_purge_authority_diagnostic")
      assert("Legality / purge automatic-removal Authority diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase44b_prepare_battle_fixture_on_map_base)
      alias fs_phase44b_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44b_prepare_battle_fixture_on_map_base
      return p44b_run_legality_purge_authority_diagnostic
    end

    unless method_defined?(:fs_phase44b_restore_pending_base)
      alias fs_phase44b_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44b_restore_pending_base
      if result
        @p44b_legality_purge_authority = nil
        @p44b_purge_trace_active = false
        @p44b_purge_trace_events = []
        @p44b_purge_target_class = nil
        @p44b_purge_target_id = 0
      end
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only wrappers：記錄 purge_unequippable 是否只透過一次正式 change_equip
# 移除 target，並確認 @purge_on 防止遞迴 purge。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    if method_defined?(:purge_unequippable) && !method_defined?(:fs_p44b_purge_base)
      alias fs_p44b_purge_base purge_unequippable
      def purge_unequippable(test = false)
        FS_TEST_HARNESS.p44b_record_purge(self, :purge_enter)
        result = fs_p44b_purge_base(test)
        FS_TEST_HARNESS.p44b_record_purge(self, :purge_exit)
        return result
      end
    end

    if method_defined?(:change_equip) && !method_defined?(:fs_p44b_change_equip_base)
      alias fs_p44b_change_equip_base change_equip
      def change_equip(equip_type, item, test = false)
        FS_TEST_HARNESS.p44b_record_purge(self, :change_enter)
        result = fs_p44b_change_equip_base(equip_type, item, test)
        FS_TEST_HARNESS.p44b_record_purge(self, :change_exit)
        return result
      end
    end
  end
end

#==============================================================================
# ■ Phase44C｜Lifecycle Invocation-count Convergence Audit
#------------------------------------------------------------------------------
# TEST-only：只量測現有 Runtime 的 wrapper / alias / refresh 真實呼叫次數與順序。
# 不修改 Formal Runtime，不退休 wrapper，不改任何既有 Authority ownership。
#==============================================================================
module FS_TEST_HARNESS
  @p44c_trace_active = false
  @p44c_trace_target_oid = nil
  @p44c_trace_scope = nil
  @p44c_trace_events = []
  @p44c_invocation_audit = nil

  class << self
    def p44c_trace_begin(actor, scope)
      @p44c_trace_active = true
      @p44c_trace_target_oid = actor == nil ? nil : actor.object_id
      @p44c_trace_scope = scope
      @p44c_trace_events = []
    end

    def p44c_record(actor, event)
      return unless @p44c_trace_active
      return if actor == nil || @p44c_trace_target_oid == nil
      return unless actor.object_id == @p44c_trace_target_oid
      @p44c_trace_events << event
    rescue
    end

    def p44c_record_party(event)
      return unless @p44c_trace_active
      @p44c_trace_events << event
    rescue
    end

    def p44c_trace_end
      events = @p44c_trace_events == nil ? [] : @p44c_trace_events.clone
      @p44c_trace_active = false
      @p44c_trace_target_oid = nil
      @p44c_trace_scope = nil
      @p44c_trace_events = []
      return events
    end

    def p44c_counts(events)
      result = {}
      (events || []).each do |event|
        result[event] = result.key?(event) ? result[event].to_i + 1 : 1
      end
      return result
    end

    def p44c_log_trace(label, events)
      log("[INVOCATION_AUDIT] #{label} events=#{events.inspect} counts=#{p44c_counts(events).inspect}")
    end

    def p44c_actor_baseline(actor)
      return nil if actor == nil
      return {
        :signature=>p41d_global_actor_signature(actor),
        :unnatural=>p41c_unnatural_skill_ids(actor),
        :states=>(actor.states rescue []).compact.collect { |state| state.id.to_i },
        :owned_defined=>p42l_instance_variable_defined_compat?(actor, "@albert_combo_owned_state_ids"),
        :owned=>(actor.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil)
      }
    rescue
      return nil
    end

    def p44c_actor_restored?(actor, baseline)
      return false if actor == nil || baseline == nil
      current_owned = actor.instance_variable_get(:@albert_combo_owned_state_ids) rescue nil
      current_owned_defined = p42l_instance_variable_defined_compat?(actor, "@albert_combo_owned_state_ids")
      current_states = (actor.states rescue []).compact.collect { |state| state.id.to_i }
      return p41d_global_actor_signature(actor) == baseline[:signature] &&
             p41c_unnatural_skill_ids(actor) == baseline[:unnatural] &&
             current_states == baseline[:states] && current_owned == baseline[:owned] &&
             current_owned_defined == baseline[:owned_defined]
    rescue
      return false
    end

    def p44c_restore_actor_aux(actor, baseline)
      return if actor == nil || baseline == nil
      begin
        if baseline[:owned_defined]
          value = baseline[:owned]
          value = value.clone if value.is_a?(Array)
          actor.instance_variable_set(:@albert_combo_owned_state_ids, value)
        elsif p42l_instance_variable_defined_compat?(actor, "@albert_combo_owned_state_ids")
          actor.send(:remove_instance_variable, :@albert_combo_owned_state_ids)
        end
      rescue
      end
    end

    def p44c_probe_setup(detached, actor_id)
      p44c_trace_begin(detached, :setup)
      begin
        detached.setup(actor_id)
      ensure
        events = p44c_trace_end
      end
      p44c_log_trace("setup", events)
      assert("Invocation audit setup reaches formal setup chain", events.include?(:setup_formal_final),
             events.inspect)
      assert("Invocation audit setup reaches EquipmentSkill final refresh", 
             events.include?(:teaching_refresh) && events.include?(:equipment_passive_refresh),
             events.inspect)
      return events
    rescue Exception => e
      @p44c_trace_active = false
      exception(e, "p44c_probe_setup")
      assert("Invocation audit setup probe completed", false, e.message)
      return []
    end

    def p44c_probe_skills(detached)
      detached.skills rescue nil
      p44c_trace_begin(detached, :skills)
      begin
        list = detached.skills
      ensure
        events = p44c_trace_end
      end
      ids = (list || []).compact.collect { |skill| skill.id.to_i }
      p44c_log_trace("skills", events)
      log("[INVOCATION_AUDIT] skills_result ids=#{ids.inspect}")
      assert("Invocation audit skills query reaches Combo/Equipment/StateLearn/base layers",
             events.include?(:skills_combo) && events.include?(:skills_equipment) &&
             events.include?(:skills_statelearn) && events.include?(:skills_base),
             events.inspect)
      return events
    rescue Exception => e
      @p44c_trace_active = false
      exception(e, "p44c_probe_skills")
      assert("Invocation audit skills probe completed", false, e.message)
      return []
    end

    def p44c_choose_usable_skill(detached)
      return nil if detached == nil || $game_temp == nil
      old_battle = $game_temp.in_battle
      begin
        $game_temp.in_battle = true
        detached.hp = detached.maxhp if detached.respond_to?(:hp=)
        detached.mp = detached.maxmp if detached.respond_to?(:mp=)
        detached.instance_variable_set(:@turn_skills, {}) if p42l_instance_variable_defined_compat?(detached, "@turn_skills")
        detached.instance_variable_set(:@battle_skills, {}) if p42l_instance_variable_defined_compat?(detached, "@battle_skills")
        candidates = detached.skills
        preferred = $data_skills[100] rescue nil
        if preferred != nil && candidates.any? { |entry| entry != nil && entry.id.to_i == preferred.id.to_i }
          begin
            return preferred if detached.skill_can_use?(preferred) == true
          rescue
          end
        end
        candidates.each do |skill|
          next if skill == nil
          begin
            return skill if detached.skill_can_use?(skill) == true
          rescue
          end
        end
      ensure
        $game_temp.in_battle = old_battle
      end
      return nil
    rescue
      return nil
    end

    def p44c_probe_skill_can_use(detached)
      skill = $data_skills[100] rescue nil
      in_list = false
      begin
        in_list = detached.skills.any? { |entry| entry != nil && skill != nil && entry.id.to_i == skill.id.to_i }
      rescue
        in_list = false
      end
      assert("Invocation audit skill_can_use uses sealed Skill100 provider", skill != nil && in_list,
             skill == nil ? "skill100=nil" : "skill=#{skill.id}:#{skill.name} in_list=#{in_list}")
      return [] if skill == nil || !in_list

      old_battle = $game_temp.in_battle
      old_occasion = skill.instance_variable_get(:@occasion) rescue skill.occasion
      result = false
      restored = false
      begin
        # Scene_Map 純查詢：temporarily Always，避免 Battle target 尚未 setup 導致 TargetGroup 早退。
        $game_temp.in_battle = false
        skill.instance_variable_set(:@occasion, 0)
        detached.hp = detached.maxhp if detached.respond_to?(:hp=)
        detached.mp = detached.maxmp if detached.respond_to?(:mp=)
        detached.instance_variable_set(:@turn_skills, {}) if p42l_instance_variable_defined_compat?(detached, "@turn_skills")
        detached.instance_variable_set(:@battle_skills, {}) if p42l_instance_variable_defined_compat?(detached, "@battle_skills")
        precheck = detached.skill_can_use?(skill) == true
        assert("Invocation audit Skill100 permissive query reaches usable state", precheck,
               "skill=#{skill.id}:#{skill.name} occasion=0")
        p44c_trace_begin(detached, :skill_can_use)
        begin
          result = detached.skill_can_use?(skill) == true
        ensure
          events = p44c_trace_end
        end
      ensure
        begin
          skill.instance_variable_set(:@occasion, old_occasion)
          restored = (skill.instance_variable_get(:@occasion) rescue nil) == old_occasion
        rescue
          restored = false
        end
        $game_temp.in_battle = old_battle
      end
      p44c_log_trace("skill_can_use", events)
      log("[INVOCATION_AUDIT] skill_can_use_result skill=#{skill.id}:#{skill.name} result=#{result}")
      assert("Invocation audit skill_can_use selected Skill remains usable", result == true,
             "skill=#{skill.id}:#{skill.name} events=#{events.inspect}")
      assert("Invocation audit skill_can_use reaches Actor EquipmentSkill and Game_Battler final chain",
             events.include?(:scu_equipment_skill) && events.include?(:scu_marked_command) &&
             events.include?(:scu_base), events.inspect)
      assert("Invocation audit Skill100 temporary occasion restored exactly", restored,
             "before=#{old_occasion.inspect} after=#{(skill.instance_variable_get(:@occasion) rescue nil).inspect}")
      return events
    rescue Exception => e
      @p44c_trace_active = false
      begin
        skill.instance_variable_set(:@occasion, old_occasion) if skill != nil && old_occasion != nil
      rescue
      end
      begin
        $game_temp.in_battle = old_battle if $game_temp != nil && old_battle != nil
      rescue
      end
      exception(e, "p44c_probe_skill_can_use")
      assert("Invocation audit skill_can_use probe completed", false, e.message)
      return []
    end

    def p44c_probe_change_equip(detached)
      armor = nil
      slot = nil
      inventory_snapshot = nil
      count_before = nil
      new_before = nil
      begin
        armor, slot = p42c_clean_teaching_armor(detached)
        assert("Invocation audit change_equip clean legal Armor resolved", armor != nil && slot != nil,
               "armor=#{armor == nil ? nil : armor.id} slot=#{slot.inspect}")
        return [] if armor == nil || slot == nil
        count_before = $game_party.item_number(armor).to_i
        inventory_snapshot = p42e_inventory_slot_snapshot(armor)
        new_before = p41c_new_flag(armor)
        p42a_restore_party_item_count(armor, count_before + 1)
        p44c_trace_begin(detached, :change_equip)
        begin
          detached.change_equip(slot, armor, false)
        ensure
          events = p44c_trace_end
        end
        p44c_log_trace("change_equip", events)
        current = detached.equips[slot] rescue nil
        assert("Invocation audit change_equip performs real formal equipment change",
               current != nil && current.id.to_i == armor.id.to_i,
               "slot=#{slot} current=#{current == nil ? nil : current.id}")
        assert("Invocation audit change_equip reaches NEW/Combo/EquipmentSkill/YEM/base boundaries",
               events.include?(:change_formal_final) && events.include?(:nitem_begin) &&
               events.include?(:change_combo_layer) && events.include?(:change_equipment_skill_layer) &&
               events.include?(:change_yem_layer) && events.include?(:change_base) &&
               events.include?(:teaching_refresh) && events.include?(:equipment_passive_refresh) &&
               events.include?(:combo_refresh) && events.include?(:nitem_end), events.inspect)
        return events
      rescue Exception => e
        @p44c_trace_active = false
        exception(e, "p44c_probe_change_equip")
        assert("Invocation audit change_equip probe completed", false, e.message)
        return []
      ensure
        begin
          detached.setup(detached.id) if detached != nil && detached.respond_to?(:id)
        rescue
        end
        begin
          p42a_restore_party_item_count(armor, count_before) if armor != nil && count_before != nil
          p42e_restore_inventory_slot(armor, inventory_snapshot) if armor != nil && inventory_snapshot != nil
          p41c_set_new_flag(armor, new_before) if armor != nil && new_before != nil && respond_to?(:p41c_set_new_flag)
        rescue
        end
      end
    end

    def p44c_probe_level_up(detached)
      before = detached.level.to_i
      p44c_trace_begin(detached, :level_up)
      begin
        detached.level_up
      ensure
        events = p44c_trace_end
      end
      p44c_log_trace("level_up", events)
      assert("Invocation audit level_up advances detached Actor exactly one level",
             detached.level.to_i == before + 1,
             "before=#{before} after=#{detached.level}")
      assert("Invocation audit level_up reaches DB cap/EquipmentSkill/JobBase/base boundaries",
             events.include?(:level_database_support) && events.include?(:level_equipment_skill) &&
             events.include?(:level_job_base) && events.include?(:level_base) &&
             events.include?(:teaching_refresh) && events.include?(:equipment_passive_refresh),
             events.inspect)
      return events
    rescue Exception => e
      @p44c_trace_active = false
      exception(e, "p44c_probe_level_up")
      assert("Invocation audit level_up probe completed", false, e.message)
      return []
    ensure
      begin
        detached.setup(detached.id) if detached != nil && detached.respond_to?(:id)
      rescue
      end
    end

    def p44c_probe_discard_equip(detached)
      weapon = detached.weapons[0] rescue nil
      assert("Invocation audit discard_equip baseline Weapon resolved", weapon != nil,
             weapon == nil ? "nil" : "weapon=#{weapon.id}:#{weapon.name}")
      return [] if weapon == nil
      p44c_trace_begin(detached, :discard_equip)
      begin
        detached.discard_equip(weapon)
      ensure
        events = p44c_trace_end
      end
      p44c_log_trace("discard_equip", events)
      current = detached.weapons[0] rescue nil
      assert("Invocation audit discard_equip removes detached main Weapon", current == nil,
             "after=#{current == nil ? nil : current.id}")
      assert("Invocation audit discard_equip reaches CoreSafe/KGC/base and final convergence",
             events.include?(:discard_formal_final) && events.include?(:discard_kgc_wrapper) &&
             events.include?(:discard_base) && events.include?(:restore_passive) &&
             events.include?(:teaching_refresh) && events.include?(:equipment_passive_refresh) &&
             events.include?(:combo_refresh), events.inspect)
      counts = p44c_counts(events)
      retire_ok = counts[:discard_formal_final].to_i == 1 && counts[:discard_kgc_wrapper].to_i == 1 &&
                  counts[:discard_base].to_i == 1 && counts[:teaching_refresh].to_i == 1 &&
                  counts[:equipment_passive_refresh].to_i == 1 && counts[:restore_passive].to_i == 1 &&
                  counts[:combo_refresh].to_i == 1 && counts[:skills_combo].to_i == 2 &&
                  counts[:skills_equipment].to_i == 2 && counts[:skills_statelearn].to_i == 2 &&
                  counts[:skills_base].to_i == 2
      assert("Invocation audit discard_equip legacy KGC Passive refresh retired exactly once",
             retire_ok, "counts=#{counts.inspect} events=#{events.inspect}")
      return events
    rescue Exception => e
      @p44c_trace_active = false
      exception(e, "p44c_probe_discard_equip")
      assert("Invocation audit discard_equip probe completed", false, e.message)
      return []
    ensure
      begin
        detached.setup(detached.id) if detached != nil && detached.respond_to?(:id)
      rescue
      end
    end

    def p44c_run_invocation_count_convergence_audit
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      actor_id = 1
      detached = Game_Actor.new(actor_id)
      baseline = p44c_actor_baseline(detached)
      assert("Invocation audit detached Actor created without replacing formal Actor",
             detached != nil && $game_actors[actor_id].object_id != detached.object_id,
             "detached=#{detached == nil ? nil : detached.object_id} formal=#{$game_actors[actor_id].object_id}")

      traces = {}
      traces[:setup] = p44c_probe_setup(detached, actor_id)
      detached.setup(actor_id)
      traces[:skills] = p44c_probe_skills(detached)
      traces[:skill_can_use] = p44c_probe_skill_can_use(detached)
      detached.setup(actor_id)
      traces[:change_equip] = p44c_probe_change_equip(detached)
      detached.setup(actor_id)
      traces[:level_up] = p44c_probe_level_up(detached)
      detached.setup(actor_id)
      traces[:discard_equip] = p44c_probe_discard_equip(detached)
      detached.setup(actor_id)
      p44c_restore_actor_aux(detached, baseline)

      restored = p44c_actor_restored?(detached, baseline)
      assert("Invocation audit detached Actor returns to exact setup baseline", restored,
             "before=#{baseline.inspect} after=#{p44c_actor_baseline(detached).inspect}")
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("Invocation audit leaves Game_Party / $game_actors exact", global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} " +
             "actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")

      traces.each do |scope, events|
        log("[INVOCATION_AUDIT_SUMMARY] scope=#{scope} count=#{events.size} counts=#{p44c_counts(events).inspect}")
      end
      fail_delta = @fail.to_i - fail_before
      @p44c_invocation_audit = {
        :traces=>traces,
        :actor_restored=>restored,
        :global_clean=>global_clean,
        :fail_delta=>fail_delta,
        :ready=>restored && global_clean && fail_delta == 0
      }
      assert("Lifecycle invocation-count convergence audit completed",
             @p44c_invocation_audit[:ready] == true,
             "fail_delta=#{fail_delta} scopes=#{traces.keys.inspect}")
      return @p44c_invocation_audit[:ready] == true
    rescue Exception => e
      @p44c_trace_active = false
      exception(e, "p44c_run_invocation_count_convergence_audit")
      assert("Lifecycle invocation-count convergence audit completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase44c_prepare_battle_fixture_on_map_base)
      alias fs_phase44c_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44c_prepare_battle_fixture_on_map_base
      return p44c_run_invocation_count_convergence_audit
    end

    unless method_defined?(:fs_phase44c_restore_pending_base)
      alias fs_phase44c_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44c_restore_pending_base
      if result
        @p44c_trace_active = false
        @p44c_trace_target_oid = nil
        @p44c_trace_scope = nil
        @p44c_trace_events = []
        @p44c_invocation_audit = nil
      end
      return result
    end
  end
end

#------------------------------------------------------------------------------
# TEST-only trace wrappers。所有記錄都由 target object_id + active scope 隔離；
# 未進 Phase44C probe 時只多一層立即轉呼叫，不改 Formal 回傳值／副作用。
#------------------------------------------------------------------------------
if $TEST
  class Game_Actor < Game_Battler
    # setup formal boundaries
    if method_defined?(:fs_p41d_trace_setup_final_base) && !method_defined?(:fs_p44c_setup_formal_final_base)
      alias fs_p44c_setup_formal_final_base fs_p41d_trace_setup_final_base
      def fs_p41d_trace_setup_final_base(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_formal_final)
        return fs_p44c_setup_formal_final_base(actor_id)
      end
    end
    if method_defined?(:fs_db_runtime_setup) && !method_defined?(:fs_p44c_setup_runtime_base)
      alias fs_p44c_setup_runtime_base fs_db_runtime_setup
      def fs_db_runtime_setup(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_runtime_support)
        return fs_p44c_setup_runtime_base(actor_id)
      end
    end
    if method_defined?(:albert_eqskill_setup_final) && !method_defined?(:fs_p44c_setup_eqskill_base)
      alias fs_p44c_setup_eqskill_base albert_eqskill_setup_final
      def albert_eqskill_setup_final(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_equipment_skill_boundary)
        return fs_p44c_setup_eqskill_base(actor_id)
      end
    end
    if method_defined?(:setup_jpsl) && !method_defined?(:fs_p44c_setup_jpsl_base)
      alias fs_p44c_setup_jpsl_base setup_jpsl
      def setup_jpsl(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_skill_levels)
        return fs_p44c_setup_jpsl_base(actor_id)
      end
    end
    if method_defined?(:setup_eo) && !method_defined?(:fs_p44c_setup_eo_base)
      alias fs_p44c_setup_eo_base setup_eo
      def setup_eo(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_equipment_overhaul)
        return fs_p44c_setup_eo_base(actor_id)
      end
    end
    if method_defined?(:setup_KGC_PassiveSkill) && !method_defined?(:fs_p44c_setup_passive_base)
      alias fs_p44c_setup_passive_base setup_KGC_PassiveSkill
      def setup_KGC_PassiveSkill(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_passive_skill)
        return fs_p44c_setup_passive_base(actor_id)
      end
    end
    if method_defined?(:setup_actor_jpbase) && !method_defined?(:fs_p44c_setup_jpbase_base)
      alias fs_p44c_setup_jpbase_base setup_actor_jpbase
      def setup_actor_jpbase(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_job_base)
        return fs_p44c_setup_jpbase_base(actor_id)
      end
    end
    if method_defined?(:setup_KGC_OverDrive) && !method_defined?(:fs_p44c_setup_od_base)
      alias fs_p44c_setup_od_base setup_KGC_OverDrive
      def setup_KGC_OverDrive(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_overdrive)
        return fs_p44c_setup_od_base(actor_id)
      end
    end
    if method_defined?(:rx_rgss2bs1_setup) && !method_defined?(:fs_p44c_setup_rx_base)
      alias fs_p44c_setup_rx_base rx_rgss2bs1_setup
      def rx_rgss2bs1_setup(actor_id)
        FS_TEST_HARNESS.p44c_record(self, :setup_rx_base)
        return fs_p44c_setup_rx_base(actor_id)
      end
    end

    # shared refresh boundaries
    if method_defined?(:albert_refresh_equipment_teaching_skills) && !method_defined?(:fs_p44c_teaching_refresh_base)
      alias fs_p44c_teaching_refresh_base albert_refresh_equipment_teaching_skills
      def albert_refresh_equipment_teaching_skills
        FS_TEST_HARNESS.p44c_record(self, :teaching_refresh)
        return fs_p44c_teaching_refresh_base
      end
    end
    if method_defined?(:albert_refresh_equipment_passive_skills) && !method_defined?(:fs_p44c_equipment_passive_refresh_base)
      alias fs_p44c_equipment_passive_refresh_base albert_refresh_equipment_passive_skills
      def albert_refresh_equipment_passive_skills
        FS_TEST_HARNESS.p44c_record(self, :equipment_passive_refresh)
        return fs_p44c_equipment_passive_refresh_base
      end
    end
    if method_defined?(:albert_refresh_combo_actor_states) && !method_defined?(:fs_p44c_combo_refresh_base)
      alias fs_p44c_combo_refresh_base albert_refresh_combo_actor_states
      def albert_refresh_combo_actor_states
        FS_TEST_HARNESS.p44c_record(self, :combo_refresh)
        return fs_p44c_combo_refresh_base
      end
    end
    if method_defined?(:restore_passive_rev) && !method_defined?(:fs_p44c_restore_passive_base)
      alias fs_p44c_restore_passive_base restore_passive_rev
      def restore_passive_rev
        FS_TEST_HARNESS.p44c_record(self, :restore_passive)
        return fs_p44c_restore_passive_base
      end
    end

    # change_equip formal boundaries (current public method is wrapped by Phase44B TEST trace)
    if method_defined?(:fs_p44b_change_equip_base) && !method_defined?(:fs_p44c_change_formal_base)
      alias fs_p44c_change_formal_base fs_p44b_change_equip_base
      def fs_p44b_change_equip_base(equip_type, item, test = false)
        FS_TEST_HARNESS.p44c_record(self, :change_formal_final)
        return fs_p44c_change_formal_base(equip_type, item, test)
      end
    end
    if method_defined?(:fs_nitem_change_equip_without_suppress) && !method_defined?(:fs_p44c_change_nitem_base)
      alias fs_p44c_change_nitem_base fs_nitem_change_equip_without_suppress
      def fs_nitem_change_equip_without_suppress(equip_type, item, test = false)
        FS_TEST_HARNESS.p44c_record(self, :change_combo_layer)
        return fs_p44c_change_nitem_base(equip_type, item, test)
      end
    end
    if method_defined?(:albert_combo_change_equip_without_refresh) && !method_defined?(:fs_p44c_change_combo_base)
      alias fs_p44c_change_combo_base albert_combo_change_equip_without_refresh
      def albert_combo_change_equip_without_refresh(equip_type, item, test = false)
        FS_TEST_HARNESS.p44c_record(self, :change_equipment_skill_layer)
        return fs_p44c_change_combo_base(equip_type, item, test)
      end
    end
    if method_defined?(:albert_eqskill_change_equip_final) && !method_defined?(:fs_p44c_change_eqskill_base)
      alias fs_p44c_change_eqskill_base albert_eqskill_change_equip_final
      def albert_eqskill_change_equip_final(equip_type, item, test = false)
        FS_TEST_HARNESS.p44c_record(self, :change_yem_layer)
        return fs_p44c_change_eqskill_base(equip_type, item, test)
      end
    end
    if method_defined?(:change_equip_eo) && !method_defined?(:fs_p44c_change_base_method)
      alias fs_p44c_change_base_method change_equip_eo
      def change_equip_eo(equip_type, item, test = false)
        FS_TEST_HARNESS.p44c_record(self, :change_base)
        return fs_p44c_change_base_method(equip_type, item, test)
      end
    end
    if method_defined?(:fs_p44b_purge_base) && !method_defined?(:fs_p44c_purge_formal_base)
      alias fs_p44c_purge_formal_base fs_p44b_purge_base
      def fs_p44b_purge_base(test = false)
        FS_TEST_HARNESS.p44c_record(self, :purge_formal)
        return fs_p44c_purge_formal_base(test)
      end
    end

    # level_up boundaries
    if method_defined?(:level_up) && !method_defined?(:fs_p44c_level_final_base)
      alias fs_p44c_level_final_base level_up
      def level_up
        FS_TEST_HARNESS.p44c_record(self, :level_database_support)
        return fs_p44c_level_final_base
      end
    end
    if method_defined?(:fsdb_level_up_v21) && !method_defined?(:fs_p44c_level_fsdb_base)
      alias fs_p44c_level_fsdb_base fsdb_level_up_v21
      def fsdb_level_up_v21
        FS_TEST_HARNESS.p44c_record(self, :level_equipment_skill)
        return fs_p44c_level_fsdb_base
      end
    end
    if method_defined?(:albert_eqskill_level_up_final) && !method_defined?(:fs_p44c_level_eqskill_base)
      alias fs_p44c_level_eqskill_base albert_eqskill_level_up_final
      def albert_eqskill_level_up_final
        FS_TEST_HARNESS.p44c_record(self, :level_job_base)
        return fs_p44c_level_eqskill_base
      end
    end
    if method_defined?(:level_up_jpbase) && !method_defined?(:fs_p44c_level_base_method)
      alias fs_p44c_level_base_method level_up_jpbase
      def level_up_jpbase
        FS_TEST_HARNESS.p44c_record(self, :level_base)
        return fs_p44c_level_base_method
      end
    end

    # discard_equip formal boundaries (Phase44A TEST wrapper sits outside CoreSafe final)
    if method_defined?(:fs_p44a_weapon_discard_final_base) && !method_defined?(:fs_p44c_discard_formal_base)
      alias fs_p44c_discard_formal_base fs_p44a_weapon_discard_final_base
      def fs_p44a_weapon_discard_final_base(item)
        FS_TEST_HARNESS.p44c_record(self, :discard_formal_final)
        return fs_p44c_discard_formal_base(item)
      end
    end
    if method_defined?(:discard_equip_eo) && !method_defined?(:fs_p44c_discard_kgc_base)
      alias fs_p44c_discard_kgc_base discard_equip_eo
      def discard_equip_eo(item)
        FS_TEST_HARNESS.p44c_record(self, :discard_kgc_wrapper)
        return fs_p44c_discard_kgc_base(item)
      end
    end
    if method_defined?(:discard_equip_KGC_PassiveSkill) && !method_defined?(:fs_p44c_discard_base_method)
      alias fs_p44c_discard_base_method discard_equip_KGC_PassiveSkill
      def discard_equip_KGC_PassiveSkill(item)
        FS_TEST_HARNESS.p44c_record(self, :discard_base)
        return fs_p44c_discard_base_method(item)
      end
    end

    # skills query chain
    if method_defined?(:skills) && !method_defined?(:fs_p44c_skills_final_base)
      alias fs_p44c_skills_final_base skills
      def skills
        FS_TEST_HARNESS.p44c_record(self, :skills_combo)
        return fs_p44c_skills_final_base
      end
    end
    if method_defined?(:albert_combo_skills_without_combo) && !method_defined?(:fs_p44c_skills_combo_base)
      alias fs_p44c_skills_combo_base albert_combo_skills_without_combo
      def albert_combo_skills_without_combo
        FS_TEST_HARNESS.p44c_record(self, :skills_equipment)
        return fs_p44c_skills_combo_base
      end
    end
    if method_defined?(:albert_equipment_skill_base_skills) && !method_defined?(:fs_p44c_skills_eq_base)
      alias fs_p44c_skills_eq_base albert_equipment_skill_base_skills
      def albert_equipment_skill_base_skills
        FS_TEST_HARNESS.p44c_record(self, :skills_statelearn)
        return fs_p44c_skills_eq_base
      end
    end
    if method_defined?(:skills_KGC_StateLearnSkill) && !method_defined?(:fs_p44c_skills_state_base)
      alias fs_p44c_skills_state_base skills_KGC_StateLearnSkill
      def skills_KGC_StateLearnSkill
        FS_TEST_HARNESS.p44c_record(self, :skills_base)
        return fs_p44c_skills_state_base
      end
    end

    # Actor-side skill_can_use? chain
    if method_defined?(:skill_can_use?) && !method_defined?(:fs_p44c_actor_scu_final_base)
      alias fs_p44c_actor_scu_final_base skill_can_use?
      def skill_can_use?(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_enemy_summon_guard)
        return fs_p44c_actor_scu_final_base(skill)
      end
    end
    if method_defined?(:fs_enemy_summon_guard_skill_can_use) && !method_defined?(:fs_p44c_scu_guard_base)
      alias fs_p44c_scu_guard_base fs_enemy_summon_guard_skill_can_use
      def fs_enemy_summon_guard_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_actor_profile)
        return fs_p44c_scu_guard_base(skill)
      end
    end
    if method_defined?(:albert_profile_old_skill_can_use) && !method_defined?(:fs_p44c_scu_profile_base)
      alias fs_p44c_scu_profile_base albert_profile_old_skill_can_use
      def albert_profile_old_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_equipment_skill)
        return fs_p44c_scu_profile_base(skill)
      end
    end
    if method_defined?(:albert_eqskill_final_skill_can_use?) && !method_defined?(:fs_p44c_scu_eqskill_base)
      alias fs_p44c_scu_eqskill_base albert_eqskill_final_skill_can_use?
      def albert_eqskill_final_skill_can_use?(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_auto_ai_super)
        return fs_p44c_scu_eqskill_base(skill)
      end
    end
  end

  class Game_Battler
    # Game_Battler-side effective skill_can_use? chain reached by AutoAI super.
    if method_defined?(:skill_can_use?) && !method_defined?(:fs_p44c_battler_scu_final_base)
      alias fs_p44c_battler_scu_final_base skill_can_use?
      def skill_can_use?(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_marked_command)
        return fs_p44c_battler_scu_final_base(skill)
      end
    end
    if method_defined?(:fs_mc_original_skill_can_use) && !method_defined?(:fs_p44c_scu_mc_base)
      alias fs_p44c_scu_mc_base fs_mc_original_skill_can_use
      def fs_mc_original_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_skill_cost)
        return fs_p44c_scu_mc_base(skill)
      end
    end
    if method_defined?(:fs_sc_allfix_skill_can_use_without_extra_cost) && !method_defined?(:fs_p44c_scu_cost_base)
      alias fs_p44c_scu_cost_base fs_sc_allfix_skill_can_use_without_extra_cost
      def fs_sc_allfix_skill_can_use_without_extra_cost(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_soulmark)
        return fs_p44c_scu_cost_base(skill)
      end
    end
    if method_defined?(:fs_smre_skill_can_use) && !method_defined?(:fs_p44c_scu_soul_base)
      alias fs_p44c_scu_soul_base fs_smre_skill_can_use
      def fs_smre_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_field_weather)
        return fs_p44c_scu_soul_base(skill)
      end
    end
    if method_defined?(:fs_field_weather_skill_can_use) && !method_defined?(:fs_p44c_scu_weather_base)
      alias fs_p44c_scu_weather_base fs_field_weather_skill_can_use
      def fs_field_weather_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_target_group)
        return fs_p44c_scu_weather_base(skill)
      end
    end
    if method_defined?(:albert_tg_skill_can_use) && !method_defined?(:fs_p44c_scu_target_base)
      alias fs_p44c_scu_target_base albert_tg_skill_can_use
      def albert_tg_skill_can_use(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_skill_delay)
        return fs_p44c_scu_target_base(skill)
      end
    end
    if method_defined?(:usabile_da_delay) && !method_defined?(:fs_p44c_scu_delay_base)
      alias fs_p44c_scu_delay_base usabile_da_delay
      def usabile_da_delay(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_action_seal)
        return fs_p44c_scu_delay_base(skill)
      end
    end
    if method_defined?(:_atb_with_seal__skill_can_use?) && !method_defined?(:fs_p44c_scu_seal_base)
      alias fs_p44c_scu_seal_base _atb_with_seal__skill_can_use?
      define_method(:_atb_with_seal__skill_can_use?) do |skill|
        FS_TEST_HARNESS.p44c_record(self, :scu_use_conditions)
        fs_p44c_scu_seal_base(skill)
      end
    end
    if method_defined?(:dai_skill_can_use?) && !method_defined?(:fs_p44c_scu_condition_base)
      alias fs_p44c_scu_condition_base dai_skill_can_use?
      def dai_skill_can_use?(skill)
        FS_TEST_HARNESS.p44c_record(self, :scu_enemy_summon_core)
        return fs_p44c_scu_condition_base(skill)
      end
    end
    if method_defined?(:moral_caly_skllcnuse_6yh1) && !method_defined?(:fs_p44c_scu_enemy_core_base)
      alias fs_p44c_scu_enemy_core_base moral_caly_skllcnuse_6yh1
      def moral_caly_skllcnuse_6yh1(skill, *args)
        FS_TEST_HARNESS.p44c_record(self, :scu_overdrive)
        return fs_p44c_scu_enemy_core_base(skill, *args)
      end
    end
    if method_defined?(:skill_can_use_KGC_OverDrive?) && !method_defined?(:fs_p44c_scu_od_base)
      alias fs_p44c_scu_od_base skill_can_use_KGC_OverDrive?
      define_method(:skill_can_use_KGC_OverDrive?) do |skill|
        FS_TEST_HARNESS.p44c_record(self, :scu_reproduce_functions)
        fs_p44c_scu_od_base(skill)
      end
    end
    if method_defined?(:skill_can_use_KGC_ReproduceFunctions?) && !method_defined?(:fs_p44c_scu_repro_base)
      alias fs_p44c_scu_repro_base skill_can_use_KGC_ReproduceFunctions?
      define_method(:skill_can_use_KGC_ReproduceFunctions?) do |skill|
        FS_TEST_HARNESS.p44c_record(self, :scu_event_object)
        fs_p44c_scu_repro_base(skill)
      end
    end
    if method_defined?(:tig_eto_skill_can_use?) && !method_defined?(:fs_p44c_scu_event_base)
      alias fs_p44c_scu_event_base tig_eto_skill_can_use?
      define_method(:tig_eto_skill_can_use?) do |skill|
        FS_TEST_HARNESS.p44c_record(self, :scu_base)
        fs_p44c_scu_event_base(skill)
      end
    end
  end

  class Game_Party < Game_Unit
    if method_defined?(:fs_nitem_suppress_begin) && !method_defined?(:fs_p44c_nitem_begin_base)
      alias fs_p44c_nitem_begin_base fs_nitem_suppress_begin
      def fs_nitem_suppress_begin
        FS_TEST_HARNESS.p44c_record_party(:nitem_begin)
        return fs_p44c_nitem_begin_base
      end
    end
    if method_defined?(:fs_nitem_suppress_end) && !method_defined?(:fs_p44c_nitem_end_base)
      alias fs_p44c_nitem_end_base fs_nitem_suppress_end
      def fs_nitem_suppress_end
        FS_TEST_HARNESS.p44c_record_party(:nitem_end)
        return fs_p44c_nitem_end_base
      end
    end
  end
end


#==============================================================================
# Phase44E｜Setup Passive Rebuild Source Diagnostic
#------------------------------------------------------------------------------
# TEST-only。Phase44D1 已將 discard_equip 的 legacy KGC early refresh 封版退休；
# 本階段不修改 Formal Runtime，只替 setup 中每一次 restore_passive_rev 建立 scope provenance。
#==============================================================================

if $TEST
module FS_TEST_HARNESS
  class << self
    def p44e_target?(actor)
      return false unless @p44e_trace_active
      return false if actor == nil || @p44e_trace_target_oid == nil
      return actor.object_id == @p44e_trace_target_oid
    end

    def p44e_scope_push(actor, scope)
      return false unless p44e_target?(actor)
      @p44e_scope_stack = [] if @p44e_scope_stack == nil
      @p44e_scope_stack << scope
      return true
    end

    def p44e_scope_pop(actor, scope, pushed)
      return unless pushed
      return unless p44e_target?(actor)
      return if @p44e_scope_stack == nil || @p44e_scope_stack.empty?
      if @p44e_scope_stack[-1] == scope
        @p44e_scope_stack.pop
      else
        index = nil
        i = @p44e_scope_stack.size - 1
        while i >= 0
          if @p44e_scope_stack[i] == scope
            index = i
            break
          end
          i -= 1
        end
        @p44e_scope_stack.delete_at(index) if index != nil
      end
    end

    def p44e_record(actor, kind, detail = nil)
      return unless p44e_target?(actor)
      @p44e_trace_events = [] if @p44e_trace_events == nil
      scopes = @p44e_scope_stack == nil ? [] : @p44e_scope_stack.clone
      @p44e_trace_events << [kind, scopes, detail]
    end

    def p44e_trace_begin(actor)
      @p44e_trace_target_oid = actor.object_id
      @p44e_trace_events = []
      @p44e_scope_stack = []
      @p44e_trace_active = true
    end

    def p44e_trace_end
      events = @p44e_trace_events == nil ? [] : @p44e_trace_events.clone
      @p44e_trace_active = false
      @p44e_trace_target_oid = nil
      @p44e_trace_events = []
      @p44e_scope_stack = []
      return events
    end

    def p44e_restore_events(events)
      result = []
      events.each do |entry|
        result << entry if entry[0] == :restore_passive
      end
      return result
    end

    def p44e_scope_count(restores, scope)
      count = 0
      restores.each do |entry|
        scopes = entry[1] || []
        count += 1 if scopes.include?(scope)
      end
      return count
    end

    def p44f_plain_equipment_setup_restore_count(restores)
      count = 0
      restores.each do |entry|
        scopes = entry[1] || []
        next unless scopes.include?(:setup_total)
        next unless scopes.include?(:equipment_skill_setup)
        next if scopes.include?(:learn_skill)
        next if scopes.include?(:kgc_setup)
        next if scopes.include?(:equipment_passive_refresh)
        count += 1
      end
      return count
    end

    def p44e_log_sources(events)
      restores = p44e_restore_events(events)
      restores.each_with_index do |entry, index|
        log("[SETUP_PASSIVE_SOURCE] index=#{index + 1} scopes=#{entry[1].inspect} detail=#{entry[2].inspect}")
      end
      log("[SETUP_PASSIVE_SOURCE_SUMMARY] restores=#{restores.size} " +
          "kgc_setup=#{p44e_scope_count(restores, :kgc_setup)} " +
          "learn_skill=#{p44e_scope_count(restores, :learn_skill)} " +
          "state_learn=#{p44e_scope_count(restores, :state_learn_skills)} " +
          "equipment_final=#{p44e_scope_count(restores, :equipment_passive_refresh)} " +
          "purge=#{p44e_scope_count(restores, :purge_unequippable)}")
      return restores
    end

    def p44g_learn_mutation_events(events)
      result = []
      events.each do |entry|
        result << entry if entry[0] == :learn_skill_mutation
      end
      return result
    end

    def p44j_forget_mutation_events(events)
      result = []
      events.each do |entry|
        result << entry if entry[0] == :forget_skill_mutation
      end
      return result
    end

    def p44g_log_learn_mutations(events)
      learns = p44g_learn_mutation_events(events)
      changed = 0
      noop = 0
      passive = 0
      learns.each_with_index do |entry, index|
        detail = entry[2] || {}
        changed += 1 if detail[:changed]
        noop += 1 unless detail[:changed]
        passive += 1 if detail[:passive]
        log("[SETUP_LEARN_MUTATION] index=#{index + 1} " +
            "skill=#{detail[:skill_id]}:#{detail[:skill_name]} " +
            "before=#{detail[:before]} after=#{detail[:after]} changed=#{detail[:changed]} " +
            "passive=#{detail[:passive]} scopes=#{entry[1].inspect}")
      end
      log("[SETUP_LEARN_MUTATION_SUMMARY] calls=#{learns.size} changed=#{changed} noop=#{noop} passive=#{passive}")
      return learns
    end

    def p44e_probe_setup_passive_sources
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      actor_id = 1
      detached = Game_Actor.new(actor_id)
      baseline = p44c_actor_baseline(detached)

      p44e_trace_begin(detached)
      detached.setup(actor_id)
      events = p44e_trace_end
      restores = p44e_log_sources(events)
      learn_mutations = p44g_log_learn_mutations(events)

      plain_setup_final = p44f_plain_equipment_setup_restore_count(restores)
      learn_count = p44e_scope_count(restores, :learn_skill)
      equipment_final_count = p44e_scope_count(restores, :equipment_passive_refresh)

      assert("Non-Passive learn_skill retirement leaves only EquipmentSkill final setup rebuild",
             restores.size == 1,
             "expected=1 actual=#{restores.size} restores=#{restores.inspect}")

      # Phase44H 已實機封版：setup 三次 learn_skill = 2 changed(non-passive) + 1 no-op。
      # Phase44I 退休兩次 changed/non-passive KGC rebuild；唯一保留的 setup rebuild
      # 必須是 EquipmentSkill final convergence。
      runtime_learn_restore_count = 0
      restores.each do |entry|
        scopes = entry[1] || []
        runtime_learn_restore_count += 1 if scopes.include?(:learn_skill)
      end
      source_profile =
        learn_count == 0 &&
        equipment_final_count == 1 &&
        plain_setup_final == 0 &&
        runtime_learn_restore_count == 0
      assert("Non-Passive learn_skill retirement preserves EquipmentSkill final Authority only",
             source_profile,
             "learn_skill_restores=#{learn_count} equipment_final=#{equipment_final_count} " +
             "runtime_learn_restore=#{runtime_learn_restore_count} " +
             "plain_setup_final=#{plain_setup_final} restores=#{restores.inspect}")
      log("[SETUP_PASSIVE_RETIREMENT] restores=#{restores.size} learn_skill=#{learn_count} " +
          "equipment_final=#{equipment_final_count} runtime_learn_restore=#{runtime_learn_restore_count} " +
          "plain_setup_final=#{plain_setup_final}")

      mutation_changed = 0
      mutation_noop = 0
      learn_mutations.each do |entry|
        detail = entry[2] || {}
        if detail[:changed]
          mutation_changed += 1
        else
          mutation_noop += 1
        end
      end
      mutation_profile = learn_mutations.size == 3 && mutation_changed == 2 && mutation_noop == 1
      assert("Setup learn_skill mutation profile remains 3 calls / 2 changed / 1 no-op",
             mutation_profile,
             "calls=#{learn_mutations.size} changed=#{mutation_changed} noop=#{mutation_noop} " +
             "learns=#{learn_mutations.inspect}")

      mutation_scope_ok = true
      learn_mutations.each do |entry|
        scopes = entry[1] || []
        detail = entry[2] || {}
        mutation_scope_ok = false unless scopes.include?(:setup_total) && scopes.include?(:learn_skill)
        mutation_scope_ok = false if detail[:skill_id].to_i <= 0
      end
      assert("Setup learn_skill mutation diagnostic records valid skill/scope metadata",
             mutation_scope_ok,
             "learns=#{learn_mutations.inspect}")

      detached.setup(actor_id)
      p44c_restore_actor_aux(detached, baseline)
      restored = p44c_actor_restored?(detached, baseline)
      assert("Setup Passive source diagnostic detached Actor exact restore",
             restored,
             "before=#{baseline.inspect} after=#{p44c_actor_baseline(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("Setup Passive source diagnostic leaves Game_Party / $game_actors exact",
             global_clean,
             "party=#{party_before == nil ? nil : party_before.size}->#{party_after == nil ? nil : party_after.size} " +
             "actors=#{actors_before == nil ? nil : actors_before.size}->#{actors_after == nil ? nil : actors_after.size}")

      fail_delta = @fail.to_i - fail_before
      @p44e_setup_source_diagnostic = {
        :events=>events,
        :restores=>restores,
        :actor_restored=>restored,
        :global_clean=>global_clean,
        :source_profile=>source_profile,
        :mutation_profile=>mutation_profile && mutation_scope_ok,
        :learn_mutations=>learn_mutations,
        :fail_delta=>fail_delta,
        :ready=>restored && global_clean && source_profile && mutation_profile && mutation_scope_ok && fail_delta == 0
      }
      assert("Non-Passive learn_skill Passive refresh retirement setup gate completed",
             @p44e_setup_source_diagnostic[:ready] == true,
             "fail_delta=#{fail_delta} restores=#{restores.size}")
      return @p44e_setup_source_diagnostic[:ready] == true
    rescue Exception => e
      @p44e_trace_active = false
      @p44e_trace_target_oid = nil
      @p44e_scope_stack = []
      exception(e, "p44e_probe_setup_passive_sources")
      assert("Non-Passive learn_skill Passive refresh retirement setup gate completed", false, e.message)
      return false
    end

    def p44i_probe_learn_skill_refresh_semantics
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      actor_id = 1
      detached = Game_Actor.new(actor_id)
      baseline = p44c_actor_baseline(detached)
      raw = detached.instance_variable_get(:@skills) rescue []
      raw = [] if raw == nil

      # A. no-op：既有 Skill 重複 learn，仍須 0 rebuild。
      existing_id = raw[0] if raw.size > 0
      assert("Non-Passive learn probe has existing learned Skill", existing_id != nil,
             "raw=#{raw.inspect}")
      return false if existing_id == nil
      p44e_trace_begin(detached)
      detached.learn_skill(existing_id)
      noop_events = p44e_trace_end
      noop_restores = p44e_restore_events(noop_events)
      noop_mutations = p44g_learn_mutation_events(noop_events)
      noop_ok = noop_restores.empty? && noop_mutations.size == 1 &&
                (noop_mutations[0][2] || {})[:changed] == false
      assert("Repeated learn_skill keeps API call and skips Passive rebuild", noop_ok,
             "skill=#{existing_id} restores=#{noop_restores.inspect} mutations=#{noop_mutations.inspect}")

      # B. changed + non-passive：ownership 必須新增，但 KGC Passive rebuild 應為 0。
      nonpassive_id = nil
      i = 1
      while i < $data_skills.size
        skill = $data_skills[i] rescue nil
        if skill != nil && !raw.include?(i) && skill.passive != true
          nonpassive_id = i
          break
        end
        i += 1
      end
      assert("Changed non-Passive learn probe resolves unlearned Skill", nonpassive_id != nil,
             "raw=#{raw.inspect}")
      return false if nonpassive_id == nil
      p44e_trace_begin(detached)
      detached.learn_skill(nonpassive_id)
      nonpassive_events = p44e_trace_end
      nonpassive_restores = p44e_restore_events(nonpassive_events)
      nonpassive_mutations = p44g_learn_mutation_events(nonpassive_events)
      nonpassive_raw = detached.instance_variable_get(:@skills) rescue []
      nonpassive_ok = nonpassive_restores.empty? && nonpassive_mutations.size == 1 &&
                      (nonpassive_mutations[0][2] || {})[:changed] == true &&
                      nonpassive_raw.include?(nonpassive_id)
      assert("Changed non-Passive learn_skill mutates ownership with zero Passive rebuild", nonpassive_ok,
             "skill=#{nonpassive_id} restores=#{nonpassive_restores.inspect} " +
             "mutations=#{nonpassive_mutations.inspect} raw=#{nonpassive_raw.inspect}")
      detached.forget_skill(nonpassive_id) if nonpassive_raw.include?(nonpassive_id)

      # C. changed + Passive：用 TEST-only synthetic clone 證明真正 Passive Skill 仍 rebuild 一次，
      # 並且 Passive Authority 實際進入 actor cache。
      skill_slot = p42h_prepare_synthetic_skill_slot(nonpassive_id)
      assert("Passive learn probe synthetic Skill clone prepared", skill_slot != nil,
             "skill=#{nonpassive_id}")
      return false if skill_slot == nil
      synthetic = skill_slot[:synthetic]
      passive_injected = p42f_apply_synthetic_passive(synthetic)
      slot_active = passive_injected && p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Passive learn probe synthetic Skill parses and owns database slot", slot_active,
             "skill=#{nonpassive_id} passive=#{passive_injected}")
      return false unless slot_active

      passive_before = p42f_passive_signature(detached)
      p44e_trace_begin(detached)
      detached.learn_skill(nonpassive_id)
      passive_events = p44e_trace_end
      passive_restores = p44e_restore_events(passive_events)
      passive_mutations = p44g_learn_mutation_events(passive_events)
      passive_after = p42f_passive_signature(detached)
      passive_delta = p42f_assert_passive_temp_delta("changed learn activates synthetic Passive",
                                                      passive_before, passive_after, true)
      passive_raw = detached.instance_variable_get(:@skills) rescue []
      passive_ok = passive_restores.size == 1 && passive_mutations.size == 1 &&
                   (passive_mutations[0][2] || {})[:changed] == true &&
                   (passive_mutations[0][2] || {})[:passive] == true &&
                   passive_raw.include?(nonpassive_id) && passive_delta
      assert("Changed Passive learn_skill still rebuilds Passive exactly once", passive_ok,
             "skill=#{nonpassive_id} restores=#{passive_restores.inspect} " +
             "mutations=#{passive_mutations.inspect} before=#{passive_before.inspect} after=#{passive_after.inspect}")

      # Cleanup 時 synthetic slot 仍 active，正式 forget_skill 會把 Passive cache 回復到 baseline。
      detached.forget_skill(nonpassive_id) if passive_raw.include?(nonpassive_id)
      passive_clean = p42f_assert_passive_temp_delta("forget after synthetic Passive learn restores baseline",
                                                     passive_before, p42f_passive_signature(detached), false)
      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Passive learn probe restores original Skill database slot exactly", skill_restored,
             "skill=#{nonpassive_id}")

      p44c_restore_actor_aux(detached, baseline)
      restored = p44c_actor_restored?(detached, baseline)
      assert("Non-Passive learn standalone probe restores detached Actor exactly", restored,
             "before=#{baseline.inspect} after=#{p44c_actor_baseline(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("Non-Passive learn standalone probe leaves globals exact", global_clean,
             "party=#{party_before == party_after} actors=#{actors_before == actors_after}")
      log("[NONPASSIVE_LEARN_RETIREMENT] existing=#{existing_id} noop_restores=#{noop_restores.size} " +
          "nonpassive=#{nonpassive_id} nonpassive_restores=#{nonpassive_restores.size} " +
          "passive=#{nonpassive_id} passive_restores=#{passive_restores.size} passive_delta=#{passive_delta}")

      fail_delta = @fail.to_i - fail_before
      ready = noop_ok && nonpassive_ok && passive_ok && passive_clean && skill_restored &&
              restored && global_clean && fail_delta == 0
      assert("Non-Passive learn_skill standalone retirement gate completed", ready,
             "fail_delta=#{fail_delta}")
      return ready
    rescue Exception => e
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      @p44e_trace_active = false
      @p44e_trace_target_oid = nil
      @p44e_scope_stack = []
      exception(e, "p44i_probe_learn_skill_refresh_semantics")
      assert("Non-Passive learn_skill standalone retirement gate completed", false, e.message)
      return false
    end

    def p44j_probe_forget_skill_refresh_semantics
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      actor_id = 1
      detached = Game_Actor.new(actor_id)
      baseline = p44c_actor_baseline(detached)
      raw = detached.instance_variable_get(:@skills) rescue []
      raw = [] if raw == nil

      # 共用一個原本未學的 non-Passive Skill，後半再用 database-slot clone 暫時轉成 Passive。
      target_id = nil
      i = 1
      while i < $data_skills.size
        skill = $data_skills[i] rescue nil
        if skill != nil && !raw.include?(i) && skill.passive != true
          target_id = i
          break
        end
        i += 1
      end
      assert("Forget probe resolves unlearned non-Passive Skill", target_id != nil,
             "raw=#{raw.inspect}")
      return false if target_id == nil

      # A. no-op + non-passive：不存在 ownership，底層 API 照跑，但不得 rebuild。
      p44e_trace_begin(detached)
      noop_result = detached.forget_skill(target_id)
      noop_events = p44e_trace_end
      noop_restores = p44e_restore_events(noop_events)
      noop_mutations = p44j_forget_mutation_events(noop_events)
      noop_ok = noop_result == nil && noop_restores.empty? && noop_mutations.size == 1 &&
                (noop_mutations[0][2] || {})[:changed] == false
      assert("No-op non-Passive forget_skill keeps API call and skips Passive rebuild", noop_ok,
             "skill=#{target_id} result=#{noop_result.inspect} restores=#{noop_restores.inspect} " +
             "mutations=#{noop_mutations.inspect}")

      # B. changed + non-passive：先正式 learn，再 trace forget；ownership 要消失但 rebuild=0。
      detached.learn_skill(target_id)
      learned_raw = detached.instance_variable_get(:@skills) rescue []
      assert("Changed non-Passive forget probe learns target prerequisite", learned_raw.include?(target_id),
             "skill=#{target_id} raw=#{learned_raw.inspect}")
      p44e_trace_begin(detached)
      nonpassive_result = detached.forget_skill(target_id)
      nonpassive_events = p44e_trace_end
      nonpassive_restores = p44e_restore_events(nonpassive_events)
      nonpassive_mutations = p44j_forget_mutation_events(nonpassive_events)
      nonpassive_raw = detached.instance_variable_get(:@skills) rescue []
      nonpassive_ok = nonpassive_result == nil && nonpassive_restores.empty? &&
                      nonpassive_mutations.size == 1 &&
                      (nonpassive_mutations[0][2] || {})[:changed] == true &&
                      !nonpassive_raw.include?(target_id)
      assert("Changed non-Passive forget_skill removes ownership with zero Passive rebuild", nonpassive_ok,
             "skill=#{target_id} result=#{nonpassive_result.inspect} restores=#{nonpassive_restores.inspect} " +
             "mutations=#{nonpassive_mutations.inspect} raw=#{nonpassive_raw.inspect}")

      # C. changed + Passive：synthetic clone 啟用真正 Passive Authority；forget 必須 rebuild 一次並撤回效果。
      skill_slot = p42h_prepare_synthetic_skill_slot(target_id)
      assert("Forget Passive probe synthetic Skill clone prepared", skill_slot != nil,
             "skill=#{target_id}")
      return false if skill_slot == nil
      synthetic = skill_slot[:synthetic]
      passive_injected = p42f_apply_synthetic_passive(synthetic)
      slot_active = passive_injected && p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Forget Passive probe synthetic Skill parses and owns database slot", slot_active,
             "skill=#{target_id} passive=#{passive_injected}")
      return false unless slot_active

      passive_before = p42f_passive_signature(detached)
      detached.learn_skill(target_id)
      passive_active = p42f_passive_signature(detached)
      passive_delta_on = p42f_assert_passive_temp_delta("forget probe prerequisite Passive learn activates effect",
                                                        passive_before, passive_active, true)
      p44e_trace_begin(detached)
      passive_result = detached.forget_skill(target_id)
      passive_events = p44e_trace_end
      passive_restores = p44e_restore_events(passive_events)
      passive_mutations = p44j_forget_mutation_events(passive_events)
      passive_after = p42f_passive_signature(detached)
      passive_delta_off = p42f_assert_passive_temp_delta("changed Passive forget restores baseline",
                                                         passive_before, passive_after, false)
      passive_raw = detached.instance_variable_get(:@skills) rescue []
      passive_ok = passive_result == nil && passive_restores.size == 1 &&
                   passive_mutations.size == 1 &&
                   (passive_mutations[0][2] || {})[:changed] == true &&
                   (passive_mutations[0][2] || {})[:passive] == true &&
                   !passive_raw.include?(target_id) && passive_delta_on && passive_delta_off
      assert("Changed Passive forget_skill rebuilds exactly once and removes Passive effect", passive_ok,
             "skill=#{target_id} result=#{passive_result.inspect} restores=#{passive_restores.inspect} " +
             "mutations=#{passive_mutations.inspect} before=#{passive_before.inspect} after=#{passive_after.inspect}")

      # D. no-op + Passive：database Skill 仍是 Passive，但 ownership 已不存在，不得 rebuild。
      p44e_trace_begin(detached)
      noop_passive_result = detached.forget_skill(target_id)
      noop_passive_events = p44e_trace_end
      noop_passive_restores = p44e_restore_events(noop_passive_events)
      noop_passive_mutations = p44j_forget_mutation_events(noop_passive_events)
      noop_passive_ok = noop_passive_result == nil && noop_passive_restores.empty? &&
                        noop_passive_mutations.size == 1 &&
                        (noop_passive_mutations[0][2] || {})[:changed] == false
      assert("No-op Passive forget_skill skips Passive rebuild", noop_passive_ok,
             "skill=#{target_id} result=#{noop_passive_result.inspect} " +
             "restores=#{noop_passive_restores.inspect} mutations=#{noop_passive_mutations.inspect}")

      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Forget Passive probe restores original Skill database slot exactly", skill_restored,
             "skill=#{target_id}")

      p44c_restore_actor_aux(detached, baseline)
      restored = p44c_actor_restored?(detached, baseline)
      assert("forget_skill standalone probe restores detached Actor exactly", restored,
             "before=#{baseline.inspect} after=#{p44c_actor_baseline(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("forget_skill standalone probe leaves globals exact", global_clean,
             "party=#{party_before == party_after} actors=#{actors_before == actors_after}")
      log("[FORGET_REFRESH_RETIREMENT] target=#{target_id} " +
          "noop_nonpassive_restores=#{noop_restores.size} nonpassive_restores=#{nonpassive_restores.size} " +
          "passive_restores=#{passive_restores.size} noop_passive_restores=#{noop_passive_restores.size} " +
          "passive_delta=#{passive_delta_on && passive_delta_off}")

      fail_delta = @fail.to_i - fail_before
      ready = noop_ok && nonpassive_ok && passive_ok && noop_passive_ok &&
              skill_restored && restored && global_clean && fail_delta == 0
      assert("forget_skill Passive refresh retirement standalone gate completed", ready,
             "fail_delta=#{fail_delta}")
      return ready
    rescue Exception => e
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      @p44e_trace_active = false
      @p44e_trace_target_oid = nil
      @p44e_scope_stack = []
      exception(e, "p44j_probe_forget_skill_refresh_semantics")
      assert("forget_skill Passive refresh retirement standalone gate completed", false, e.message)
      return false
    end

    def p44k_flag_defined?(actor)
      return false if actor == nil
      return actor.instance_variables.include?("@albert_equipment_teaching_passive_deferred")
    rescue
      return false
    end

    def p44k_find_unlearned_nonnatural_skill(actor)
      raw = actor.instance_variable_get(:@skills) rescue []
      raw = [] if raw == nil
      i = 1
      while i < $data_skills.size
        skill = $data_skills[i] rescue nil
        if skill != nil && !raw.include?(i)
          natural = actor.respond_to?(:albert_natural_level_skill?) && actor.albert_natural_level_skill?(i)
          return i unless natural
        end
        i += 1
      end
      return nil
    rescue
      return nil
    end

    def p44k_probe_deferred_teaching_passive_refresh
      fail_before = @fail.to_i
      skill_slot = nil
      detached = nil
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      actor_id = 1
      detached = Game_Actor.new(actor_id)
      baseline = p44c_actor_baseline(detached)
      target_id = p44k_find_unlearned_nonnatural_skill(detached)
      assert("Deferred Teaching probe resolves unlearned non-natural Skill", target_id != nil,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      return false if target_id == nil

      skill_slot = p42h_prepare_synthetic_skill_slot(target_id)
      assert("Deferred Teaching probe synthetic Skill clone prepared", skill_slot != nil,
             "skill=#{target_id}")
      return false if skill_slot == nil
      synthetic = skill_slot[:synthetic]
      passive_injected = p42f_apply_synthetic_passive(synthetic)
      slot_active = passive_injected && p42h_activate_synthetic_skill_slot(skill_slot)
      assert("Deferred Teaching probe synthetic Skill parses Passive", slot_active,
             "skill=#{target_id} passive=#{passive_injected}")
      return false unless slot_active

      passive_baseline = p42f_passive_signature(detached)
      marker_before = p44k_flag_defined?(detached)

      # A. standalone Teaching：既有 public/no-arg semantics 必須即時 forget + rebuild 一次。
      detached.learn_skill(target_id)
      detached.instance_variable_set(:@unnatural_skills, [target_id])
      active_a = p42f_passive_signature(detached)
      active_a_ok = p42f_assert_passive_temp_delta("standalone Teaching prerequisite Passive active",
                                                   passive_baseline, active_a, true)
      p44e_trace_begin(detached)
      detached.albert_refresh_equipment_teaching_skills
      standalone_events = p44e_trace_end
      standalone_restores = p44e_restore_events(standalone_events)
      standalone_after = p42f_passive_signature(detached)
      standalone_marker = detached.instance_variable_get(:@unnatural_skills) rescue []
      standalone_raw = detached.instance_variable_get(:@skills) rescue []
      standalone_ok = standalone_restores.size == 1 && !standalone_raw.include?(target_id) &&
                      !standalone_marker.include?(target_id) && standalone_after == passive_baseline &&
                      active_a_ok
      assert("Standalone Teaching keeps immediate Passive rebuild semantics", standalone_ok,
             "skill=#{target_id} restores=#{standalone_restores.inspect} raw=#{standalone_raw.inspect} " +
             "markers=#{standalone_marker.inspect} before=#{passive_baseline.inspect} after=#{standalone_after.inspect}")

      # B. deferred Teaching：inner forget mutation 要 0 rebuild；cache 在 explicit final 前故意維持舊值。
      detached.learn_skill(target_id)
      detached.instance_variable_set(:@unnatural_skills, [target_id])
      active_b = p42f_passive_signature(detached)
      p44e_trace_begin(detached)
      detached.albert_refresh_equipment_teaching_skills_deferred
      deferred_events = p44e_trace_end
      deferred_restores = p44e_restore_events(deferred_events)
      deferred_stale = p42f_passive_signature(detached)
      deferred_raw = detached.instance_variable_get(:@skills) rescue []
      deferred_markers = detached.instance_variable_get(:@unnatural_skills) rescue []
      flag_after_deferred = p44k_flag_defined?(detached)
      deferred_inner_ok = deferred_restores.empty? && !deferred_raw.include?(target_id) &&
                          !deferred_markers.include?(target_id) && deferred_stale == active_b &&
                          flag_after_deferred == marker_before
      assert("Deferred Teaching suppresses inner Passive rebuild and cleans transaction flag exactly",
             deferred_inner_ok,
             "skill=#{target_id} restores=#{deferred_restores.inspect} raw=#{deferred_raw.inspect} " +
             "markers=#{deferred_markers.inspect} flag_before=#{marker_before} flag_after=#{flag_after_deferred} " +
             "active=#{active_b.inspect} stale=#{deferred_stale.inspect}")

      p44e_trace_begin(detached)
      detached.albert_refresh_equipment_passive_skills
      final_events = p44e_trace_end
      final_restores = p44e_restore_events(final_events)
      final_after = p42f_passive_signature(detached)
      final_ok = final_restores.size == 1 && final_after == passive_baseline
      assert("Deferred Teaching explicit final Passive Authority rebuilds exactly once", final_ok,
             "restores=#{final_restores.inspect} baseline=#{passive_baseline.inspect} final=#{final_after.inspect}")

      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      assert("Deferred Teaching probe restores original Skill database slot exactly", skill_restored,
             "skill=#{target_id}")
      skill_slot = nil if skill_restored

      p44c_restore_actor_aux(detached, baseline)
      restored = p44c_actor_restored?(detached, baseline)
      flag_final = p44k_flag_defined?(detached)
      assert("Deferred Teaching probe restores detached Actor exact shape", restored && flag_final == marker_before,
             "before=#{baseline.inspect} after=#{p44c_actor_baseline(detached).inspect} " +
             "flag_before=#{marker_before} flag_final=#{flag_final}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && actors_before != nil &&
                     party_before == party_after && actors_before == actors_after
      assert("Deferred Teaching probe leaves Game_Party / $game_actors exact", global_clean,
             "party=#{party_before == party_after} actors=#{actors_before == actors_after}")
      log("[TEACHING_PASSIVE_DEFER] target=#{target_id} standalone_restores=#{standalone_restores.size} " +
          "deferred_inner_restores=#{deferred_restores.size} final_restores=#{final_restores.size} " +
          "flag_exact=#{flag_after_deferred == marker_before && flag_final == marker_before} passive_clean=#{final_after == passive_baseline}")

      fail_delta = @fail.to_i - fail_before
      ready = standalone_ok && deferred_inner_ok && final_ok && skill_restored && restored &&
              global_clean && flag_final == marker_before && fail_delta == 0
      assert("Deferred Teaching Passive refresh retirement gate completed", ready,
             "fail_delta=#{fail_delta}")
      return ready
    rescue Exception => e
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
      @p44e_trace_active = false
      @p44e_trace_target_oid = nil
      @p44e_scope_stack = []
      exception(e, "p44k_probe_deferred_teaching_passive_refresh")
      assert("Deferred Teaching Passive refresh retirement gate completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase44e_prepare_battle_fixture_on_map_base)
      alias fs_phase44e_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44e_prepare_battle_fixture_on_map_base
      return false unless p44e_probe_setup_passive_sources
      return false unless p44i_probe_learn_skill_refresh_semantics
      return false unless p44j_probe_forget_skill_refresh_semantics
      return p44k_probe_deferred_teaching_passive_refresh
    end

    unless method_defined?(:fs_phase44e_restore_pending_base)
      alias fs_phase44e_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44e_restore_pending_base
      if result
        @p44e_trace_active = false
        @p44e_trace_target_oid = nil
        @p44e_trace_events = []
        @p44e_scope_stack = []
        @p44e_setup_source_diagnostic = nil
      end
      return result
    end
  end
end

class Game_Actor < Game_Battler
  if method_defined?(:setup) && !method_defined?(:fs_p44e_setup_base)
    alias fs_p44e_setup_base setup
    def setup(actor_id)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :setup_total)
      begin
        return fs_p44e_setup_base(actor_id)
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :setup_total, pushed)
      end
    end
  end

  if method_defined?(:fs_db_runtime_setup) && !method_defined?(:fs_p44e_runtime_setup_base)
    alias fs_p44e_runtime_setup_base fs_db_runtime_setup
    def fs_db_runtime_setup(actor_id)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :equipment_skill_setup)
      begin
        return fs_p44e_runtime_setup_base(actor_id)
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :equipment_skill_setup, pushed)
      end
    end
  end

  if method_defined?(:setup_KGC_PassiveSkill) && !method_defined?(:fs_p44e_kgc_setup_base)
    alias fs_p44e_kgc_setup_base setup_KGC_PassiveSkill
    def setup_KGC_PassiveSkill(actor_id)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :kgc_setup)
      begin
        return fs_p44e_kgc_setup_base(actor_id)
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :kgc_setup, pushed)
      end
    end
  end

  if method_defined?(:learn_skill) && !method_defined?(:fs_p44e_learn_skill_base)
    alias fs_p44e_learn_skill_base learn_skill
    def learn_skill(skill_id)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :learn_skill)
      before = (@skills != nil && @skills.include?(skill_id))
      skill = ($data_skills[skill_id] rescue nil)
      FS_TEST_HARNESS.p44e_record(self, :learn_skill_enter,
        {:skill_id=>skill_id, :before=>before,
         :skill_name=>(skill == nil ? nil : skill.name),
         :passive=>(skill == nil ? nil : (skill.passive rescue nil))})
      begin
        return fs_p44e_learn_skill_base(skill_id)
      ensure
        after = (@skills != nil && @skills.include?(skill_id))
        FS_TEST_HARNESS.p44e_record(self, :learn_skill_mutation,
          {:skill_id=>skill_id, :before=>before, :after=>after,
           :changed=>(before != after),
           :skill_name=>(skill == nil ? nil : skill.name),
           :passive=>(skill == nil ? nil : (skill.passive rescue nil))})
        FS_TEST_HARNESS.p44e_record(self, :learn_skill_exit, skill_id)
        FS_TEST_HARNESS.p44e_scope_pop(self, :learn_skill, pushed)
      end
    end
  end

  if method_defined?(:forget_skill) && !method_defined?(:fs_p44j_forget_skill_base)
    alias fs_p44j_forget_skill_base forget_skill
    def forget_skill(skill_id)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :forget_skill)
      before = (@skills != nil && @skills.include?(skill_id))
      skill = ($data_skills[skill_id] rescue nil)
      FS_TEST_HARNESS.p44e_record(self, :forget_skill_enter,
        {:skill_id=>skill_id, :before=>before,
         :skill_name=>(skill == nil ? nil : skill.name),
         :passive=>(skill == nil ? nil : (skill.passive rescue nil))})
      begin
        return fs_p44j_forget_skill_base(skill_id)
      ensure
        after = (@skills != nil && @skills.include?(skill_id))
        FS_TEST_HARNESS.p44e_record(self, :forget_skill_mutation,
          {:skill_id=>skill_id, :before=>before, :after=>after,
           :changed=>(before != after),
           :skill_name=>(skill == nil ? nil : skill.name),
           :passive=>(skill == nil ? nil : (skill.passive rescue nil))})
        FS_TEST_HARNESS.p44e_record(self, :forget_skill_exit, skill_id)
        FS_TEST_HARNESS.p44e_scope_pop(self, :forget_skill, pushed)
      end
    end
  end

  if method_defined?(:state_learn_skills) && !method_defined?(:fs_p44e_state_learn_base)
    alias fs_p44e_state_learn_base state_learn_skills
    def state_learn_skills
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :state_learn_skills)
      begin
        return fs_p44e_state_learn_base
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :state_learn_skills, pushed)
      end
    end
  end

  if method_defined?(:purge_unequippable) && !method_defined?(:fs_p44e_purge_base)
    alias fs_p44e_purge_base purge_unequippable
    def purge_unequippable(test = false)
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :purge_unequippable)
      begin
        return fs_p44e_purge_base(test)
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :purge_unequippable, pushed)
      end
    end
  end

  if method_defined?(:albert_refresh_equipment_passive_skills) &&
     !method_defined?(:fs_p44e_equipment_passive_refresh_base)
    alias fs_p44e_equipment_passive_refresh_base albert_refresh_equipment_passive_skills
    def albert_refresh_equipment_passive_skills
      pushed = FS_TEST_HARNESS.p44e_scope_push(self, :equipment_passive_refresh)
      begin
        return fs_p44e_equipment_passive_refresh_base
      ensure
        FS_TEST_HARNESS.p44e_scope_pop(self, :equipment_passive_refresh, pushed)
      end
    end
  end

  if method_defined?(:restore_passive_rev) && !method_defined?(:fs_p44e_restore_passive_base)
    alias fs_p44e_restore_passive_base restore_passive_rev
    def restore_passive_rev
      FS_TEST_HARNESS.p44e_record(self, :restore_passive, nil)
      return fs_p44e_restore_passive_base
    end
  end

  if method_defined?(:skills) && !method_defined?(:fs_p44e_skills_base)
    alias fs_p44e_skills_base skills
    def skills
      FS_TEST_HARNESS.p44e_record(self, :skills_query, nil)
      return fs_p44e_skills_base
    end
  end
end
end


#==============================================================================
# ■ Phase44L TEST-only｜Skills Query Provenance Diagnostic
#------------------------------------------------------------------------------
# Phase44K 已把 lifecycle 內 Passive rebuild 收斂到單一 final Authority。
# Phase44C invocation count 仍顯示部分 lifecycle 有 2 次 skills chain；本診斷只記 caller，
# 不修改任何 Formal Runtime，也不更動既有 trace expectation。
#==============================================================================
if $TEST
module FS_TEST_HARNESS
  class << self
    def p44l_reset_skills_provenance
      @p44l_skills_provenance = {}
    end

    def p44l_skills_wrapper_frame?(line)
      return false if line == nil
      names = [
        "skills",
        "fs_p44l_skills_provenance_base",
        "fs_p44e_skills_base",
        "fs_p44c_skills_final_base",
        "albert_combo_skills_without_combo",
        "fs_p44c_skills_combo_base",
        "albert_equipment_skill_base_skills",
        "fs_p44c_skills_eq_base",
        "skills_KGC_StateLearnSkill",
        "fs_p44c_skills_state_base"
      ]
      names.each do |name|
        return true if line.include?("in `#{name}'")
      end
      return false
    rescue
      return false
    end

    def p44l_record_skills_provenance(actor)
      return unless @p44c_trace_active
      return if actor == nil
      return unless actor.object_id == @p44c_trace_target_oid

      scope = @p44c_trace_scope
      @p44l_skills_provenance = {} if @p44l_skills_provenance == nil
      @p44l_skills_provenance[scope] = [] if @p44l_skills_provenance[scope] == nil

      stack = caller rescue []
      useful = []
      stack.each do |line|
        next if p44l_skills_wrapper_frame?(line)
        useful << line
        break if useful.size >= 6
      end

      root = useful.empty? ? "(unresolved)" : useful[0]
      @p44l_skills_provenance[scope] << {
        :root=>root,
        :stack=>useful
      }
    rescue Exception => e
      @p44l_skills_provenance_error = "#{e.class}: #{e.message}"
    end

    def p44l_log_skills_provenance
      data = @p44l_skills_provenance || {}
      [:setup, :skills, :skill_can_use, :change_equip, :level_up, :discard_equip].each do |scope|
        rows = data[scope] || []
        rows.each_with_index do |row, index|
          stack = row[:stack] || []
          log("[SKILLS_PROVENANCE] scope=#{scope} index=#{index + 1} root=#{row[:root]} stack=#{stack.join(' <= ')}")
        end
      end
      counts = {}
      data.each_pair do |scope, rows|
        counts[scope] = rows == nil ? 0 : rows.size
      end
      log("[SKILLS_PROVENANCE_SUMMARY] counts=#{counts.inspect} error=#{@p44l_skills_provenance_error.inspect}")
      return counts
    end

    unless method_defined?(:fs_p44l_p44c_audit_base)
      alias fs_p44l_p44c_audit_base p44c_run_invocation_count_convergence_audit
    end
    def p44c_run_invocation_count_convergence_audit
      p44l_reset_skills_provenance
      @p44l_skills_provenance_error = nil
      result = fs_p44l_p44c_audit_base
      p44l_log_skills_provenance
      return result
    end

    def p44l_probe_skills_query_provenance
      fail_before = @fail.to_i
      data = @p44l_skills_provenance || {}
      expected = {
        :setup=>3,
        :skills=>1,
        :skill_can_use=>1,
        :change_equip=>2,
        :level_up=>2,
        :discard_equip=>2
      }

      counts_ok = true
      roots_ok = true
      expected.each_pair do |scope, expected_count|
        rows = data[scope] || []
        counts_ok = false unless rows.size == expected_count
        rows.each do |row|
          root = row[:root]
          roots_ok = false if root == nil || root == "" || root == "(unresolved)"
        end
      end

      no_error = (@p44l_skills_provenance_error == nil)
      assert("Skills provenance diagnostic preserves sealed invocation counts",
             counts_ok,
             "expected=#{expected.inspect} actual=#{data.keys.inject({}) { |h,k| h[k]=(data[k]||[]).size; h }.inspect}")
      assert("Skills provenance diagnostic resolves every caller root",
             roots_ok && no_error,
             "error=#{@p44l_skills_provenance_error.inspect} data=#{data.inspect}")

      fail_delta = @fail.to_i - fail_before
      ready = counts_ok && roots_ok && no_error && fail_delta == 0
      log("[SKILLS_PROVENANCE_GATE] ready=#{ready} counts_ok=#{counts_ok} roots_ok=#{roots_ok} no_error=#{no_error}")
      assert("Skills Query Provenance diagnostic completed", ready,
             "fail_delta=#{fail_delta}")
      return ready
    rescue Exception => e
      exception(e, "p44l_probe_skills_query_provenance")
      assert("Skills Query Provenance diagnostic completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase44l_prepare_battle_fixture_on_map_base)
      alias fs_phase44l_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44l_prepare_battle_fixture_on_map_base
      return p44l_probe_skills_query_provenance
    end

    unless method_defined?(:fs_phase44l_restore_pending_base)
      alias fs_phase44l_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44l_restore_pending_base
      if result
        @p44l_skills_provenance = nil
        @p44l_skills_provenance_error = nil
      end
      return result
    end
  end
end

class Game_Actor < Game_Battler
  if method_defined?(:skills) && !method_defined?(:fs_p44l_skills_provenance_base)
    alias fs_p44l_skills_provenance_base skills
    def skills
      FS_TEST_HARNESS.p44l_record_skills_provenance(self)
      return fs_p44l_skills_provenance_base
    end
  end
end
end

#==============================================================================
# ■ Phase44M TEST-only｜ALVD Cache Invalidation Diagnostic
#------------------------------------------------------------------------------
# Phase44L caller provenance 已定位：restore_passive_rev 之外的第二次 skills query
# 來自 ALVD#alvd_make。此處不改 Formal，只驗證 ALVD tag usage 與 raw ownership
# mutation 後 cache invalidation 語意。
#==============================================================================
if $TEST
module FS_TEST_HARNESS
  class << self
    def p44m_alvd_tag?(skill)
      return false if skill == nil
      note = skill.note.to_s rescue ""
      return note =~ /<レベル依存[：:][^>]+>/ ? true : false
    rescue
      return false
    end

    def p44m_scan_alvd_usage
      rows = []
      if $data_skills != nil
        i = 1
        while i < $data_skills.size
          skill = $data_skills[i] rescue nil
          if skill != nil && p44m_alvd_tag?(skill)
            rows << [i, skill.name.to_s, (skill.passive == true rescue nil)]
          end
          i += 1
        end
      end
      ids = rows.collect { |row| row[0] }
      passive = rows.select { |row| row[2] == true }.collect { |row| row[0] }
      nonpassive = rows.select { |row| row[2] != true }.collect { |row| row[0] }
      log("[ALVD_USAGE] count=#{rows.size} ids=#{ids.inspect} passive_ids=#{passive.inspect} nonpassive_ids=#{nonpassive.inspect}")
      rows.each do |row|
        log("[ALVD_USAGE_SKILL] id=#{row[0]} name=#{row[1]} passive=#{row[2].inspect}")
      end
      return rows
    rescue Exception => e
      exception(e, "p44m_scan_alvd_usage")
      return []
    end

    def p44m_find_unlearned_nonpassive_skill(actor)
      return nil if actor == nil || $data_skills == nil
      raw = actor.instance_variable_get(:@skills) rescue []
      raw = [] if raw == nil
      i = 1
      while i < $data_skills.size
        skill = $data_skills[i] rescue nil
        if skill != nil && !raw.include?(i) && skill.passive != true && !p44m_alvd_tag?(skill)
          return i
        end
        i += 1
      end
      return nil
    rescue
      return nil
    end

    def p44m_apply_synthetic_alvd(skill)
      return false if skill == nil
      note = skill.note.to_s
      tag = "<レベル依存:2,0,0,0>"
      skill.note = note + (note.empty? ? "" : "\n") + tag
      p42f_clear_skill_passive_cache(skill) if respond_to?(:p42f_clear_skill_passive_cache)
      passive = (skill.passive == true rescue false)
      return !passive && p44m_alvd_tag?(skill)
    rescue
      return false
    end

    def p44m_alvd_snapshot(actor)
      return nil if actor == nil
      data = {:flag=>(actor.instance_variable_get(:@alvd_flag) rescue nil)}
      [:@alvd1, :@alvd2, :@alvd3, :@alvd4].each do |ivar|
        value = actor.instance_variable_get(ivar) rescue nil
        data[ivar] = value == nil ? nil : (value.clone rescue value)
      end
      return data
    rescue
      return nil
    end

    def p44m_probe_alvd_cache_invalidation
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      usage = p44m_scan_alvd_usage

      actor_id = 1
      detached = Game_Actor.new(actor_id)
      actor_baseline = p44c_actor_baseline(detached)
      alvd_baseline_shape = p44m_alvd_snapshot(detached)
      target_id = p44m_find_unlearned_nonpassive_skill(detached)
      assert("ALVD diagnostic resolves unlearned non-Passive Skill slot", target_id != nil,
             "raw=#{(detached.instance_variable_get(:@skills) rescue []).inspect}")
      return false if target_id == nil

      skill_slot = p42h_prepare_synthetic_skill_slot(target_id)
      assert("ALVD diagnostic synthetic Skill clone prepared", skill_slot != nil,
             "skill=#{target_id}")
      return false if skill_slot == nil
      synthetic = skill_slot[:synthetic]
      alvd_injected = p44m_apply_synthetic_alvd(synthetic)
      slot_active = alvd_injected && p42h_activate_synthetic_skill_slot(skill_slot)
      assert("ALVD diagnostic synthetic Skill is non-Passive but owns level-dependent tag",
             slot_active && synthetic.passive != true && p44m_alvd_tag?(synthetic),
             "skill=#{target_id} passive=#{(synthetic.passive rescue nil).inspect} note=#{synthetic.note.inspect}")
      return false unless slot_active

      # 先建立「未學 synthetic ALVD Skill」的有效 cache baseline。
      detached.instance_variable_set(:@alvd_flag, false)
      baseline_atk = detached.base_atk.to_i
      baseline_flag = detached.instance_variable_get(:@alvd_flag) rescue nil
      level = detached.level.to_i
      expected_active_atk = baseline_atk + level
      assert("ALVD diagnostic baseline cache builds before synthetic ownership",
             baseline_flag == true,
             "flag=#{baseline_flag.inspect} atk=#{baseline_atk} level=#{level}")

      # A. changed non-Passive ALVD learn：Formal API 應立即讓下一次參數 query 看見新 ALVD。
      p44e_trace_begin(detached)
      detached.learn_skill(target_id)
      learn_events = p44e_trace_end
      learn_restores = p44e_restore_events(learn_events)
      learn_flag_before_query = detached.instance_variable_get(:@alvd_flag) rescue nil
      learn_atk_immediate = detached.base_atk.to_i
      learn_raw = detached.instance_variable_get(:@skills) rescue []

      # TEST-only manual invalidate 作 reference，證明 ALVD parser / synthetic tag 本身有效。
      detached.instance_variable_set(:@alvd_flag, false)
      learn_atk_reference = detached.base_atk.to_i
      learn_reference_ok = learn_atk_reference == expected_active_atk
      assert("ALVD synthetic reference rebuild applies level-dependent ATK delta",
             learn_reference_ok,
             "baseline=#{baseline_atk} level=#{level} expected=#{expected_active_atk} actual=#{learn_atk_reference}")

      learn_immediate_ok = learn_raw.include?(target_id) &&
                           learn_flag_before_query == false &&
                           learn_restores.size == 0 &&
                           learn_atk_immediate == expected_active_atk
      assert("Changed non-Passive ALVD learn_skill invalidates cache immediately",
             learn_immediate_ok,
             "skill=#{target_id} raw=#{learn_raw.inspect} restores=#{learn_restores.size} " +
             "flag_before_query=#{learn_flag_before_query.inspect} baseline=#{baseline_atk} " +
             "immediate=#{learn_atk_immediate} reference=#{learn_atk_reference} expected=#{expected_active_atk}")

      # B. changed non-Passive ALVD forget：在 active cache 下移除 ownership，下一次 query 應回 baseline。
      # 目前 cache 已由 reference rebuild 為 active=true 狀態。
      p44e_trace_begin(detached)
      forget_result = detached.forget_skill(target_id)
      forget_events = p44e_trace_end
      forget_restores = p44e_restore_events(forget_events)
      forget_flag_before_query = detached.instance_variable_get(:@alvd_flag) rescue nil
      forget_atk_immediate = detached.base_atk.to_i
      forget_raw = detached.instance_variable_get(:@skills) rescue []

      detached.instance_variable_set(:@alvd_flag, false)
      forget_atk_reference = detached.base_atk.to_i
      forget_reference_ok = forget_atk_reference == baseline_atk
      assert("ALVD synthetic reference rebuild removes level-dependent ATK after forget",
             forget_reference_ok,
             "baseline=#{baseline_atk} immediate=#{forget_atk_immediate} reference=#{forget_atk_reference}")

      forget_immediate_ok = !forget_raw.include?(target_id) &&
                            forget_result == nil &&
                            forget_flag_before_query == false &&
                            forget_restores.size == 0 &&
                            forget_atk_immediate == baseline_atk
      assert("Changed non-Passive ALVD forget_skill invalidates cache immediately",
             forget_immediate_ok,
             "skill=#{target_id} raw=#{forget_raw.inspect} result=#{forget_result.inspect} restores=#{forget_restores.size} " +
             "flag_before_query=#{forget_flag_before_query.inspect} baseline=#{baseline_atk} " +
             "immediate=#{forget_atk_immediate} reference=#{forget_atk_reference}")

      skill_restored = p42h_restore_synthetic_skill_slot(skill_slot)
      skill_slot = nil if skill_restored
      assert("ALVD diagnostic restores original Skill database slot exactly", skill_restored,
             "skill=#{target_id}")

      detached.setup(actor_id)
      p44c_restore_actor_aux(detached, actor_baseline)
      actor_restored = p44c_actor_restored?(detached, actor_baseline)
      assert("ALVD diagnostic restores detached Actor behavioral baseline", actor_restored,
             "before=#{actor_baseline.inspect} after=#{p44c_actor_baseline(detached).inspect} " +
             "alvd_before=#{alvd_baseline_shape.inspect} alvd_after=#{p44m_alvd_snapshot(detached).inspect}")

      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && party_after == party_before &&
                     actors_before != nil && actors_after == actors_before
      assert("ALVD diagnostic leaves Game_Party / $game_actors exact", global_clean,
             "party=#{party_before == party_after} actors=#{actors_before == actors_after}")

      fail_delta = @fail.to_i - fail_before
      semantics_ready = learn_immediate_ok && forget_immediate_ok
      infrastructure_ready = learn_reference_ok && forget_reference_ok &&
                             skill_restored && actor_restored && global_clean
      ready = semantics_ready && infrastructure_ready && fail_delta == 0
      log("[ALVD_CACHE_FIX] usage_count=#{usage.size} target=#{target_id} passive=false level=#{level} " +
          "learn_flag=#{learn_flag_before_query.inspect} learn_immediate=#{learn_atk_immediate} learn_reference=#{learn_atk_reference} " +
          "forget_flag=#{forget_flag_before_query.inspect} forget_immediate=#{forget_atk_immediate} forget_reference=#{forget_atk_reference} " +
          "learn_restores=#{learn_restores.size} forget_restores=#{forget_restores.size} " +
          "semantics_ready=#{semantics_ready} infrastructure_ready=#{infrastructure_ready} ready=#{ready}")
      # 語意 FAIL 已由上方兩個精確 ASSERT 記錄；此 gate 只檢查診斷工具本身是否可靠，
      # 避免 substantive FAIL 阻斷後續 Battle suite，讓同一份 LOG 仍能完成全回歸。
      assert("ALVD Cache Invalidation Formal fix completed", infrastructure_ready,
             "fail_delta=#{fail_delta} semantics_ready=#{semantics_ready}")
      return infrastructure_ready
    rescue Exception => e
      exception(e, "p44m_probe_alvd_cache_invalidation")
      assert("ALVD Cache Invalidation Formal fix completed", false, e.message)
      return false
    ensure
      begin
        p42h_restore_synthetic_skill_slot(skill_slot) if skill_slot != nil
      rescue
      end
    end

    unless method_defined?(:fs_phase44m_prepare_battle_fixture_on_map_base)
      alias fs_phase44m_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase44m_prepare_battle_fixture_on_map_base
      return p44m_probe_alvd_cache_invalidation
    end

    unless method_defined?(:fs_phase44m_restore_pending_base)
      alias fs_phase44m_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase44m_restore_pending_base
      return result
    end
  end
end
end

#==============================================================================
# ■ Phase45A TEST-only｜Skill Cost Authority Contract Diagnostic
#------------------------------------------------------------------------------
# Phase44M1 已封閉 Equipment/Setup 主線的 ALVD ownership cache defect。
# 本階段 Formal Runtime 0 修改，開始驗證既有 Phase24 Skill Cost Authority 在現行
# alias chain 下的「計算 → 可用條件 → Battle payment policy」契約。
# 使用 detached Actor + 本地 RPG::Skill，不改正式 $data_skills；Party gold / variable /
# item 只做短暫 formal API mutation，結束後 exact restore inventory Hash slot / NEW flag。
#==============================================================================
if $TEST
module FS_TEST_HARNESS
  class << self
    def p45a_set_party_gold_exact(value)
      return false if $game_party == nil
      value = [value.to_i, 0].max
      current = $game_party.gold.to_i
      if current < value
        $game_party.gain_gold(value - current)
      elsif current > value
        $game_party.lose_gold(current - value)
      end
      return $game_party.gold.to_i == value
    rescue
      return false
    end

    def p45a_set_party_item_count(item, value)
      return false if $game_party == nil || item == nil
      value = [value.to_i, 0].max
      current = $game_party.item_number(item).to_i
      delta = value - current
      $game_party.gain_item(item, delta) if delta != 0
      return $game_party.item_number(item).to_i == value
    rescue
      return false
    end

    def p45a_safe_state_id
      return 55 if $data_states != nil && $data_states[55] != nil
      return nil if $data_states == nil
      i = 1
      while i < $data_states.size
        state = $data_states[i] rescue nil
        if state != nil
          restriction = state.respond_to?(:restriction) ? state.restriction.to_i : 0
          return i if restriction == 0
        end
        i += 1
      end
      return nil
    rescue
      return nil
    end

    def p45a_local_cost_skill(state_id, item_id)
      return nil unless defined?(RPG::Skill)
      base = ($data_skills != nil ? $data_skills[100] : nil) rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.name = "Phase45A1 Cost Contract"
      skill.occasion = 0 if skill.respond_to?(:occasion=)
      skill.note = skill.note.to_s + "\n# FS_PHASE45A1_COST_CONTRACT\n" +
                   "<costo hp:12>\n" +
                   "<costo mp:15>\n" +
                   "<costo oro:30>\n" +
                   "<costo var:7>\n" +
                   "<usa oggetto:#{item_id}>\n" +
                   "<costo angry:11>\n" +
                   "<costo state:#{state_id}>"
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      return skill
    rescue
      return nil
    end

    def p45a_probe_skill_cost_contract
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      gold_before = $game_party.gold.to_i rescue nil
      var_id = defined?(Skill_Costs) ? Skill_Costs::Variabile.to_i : nil
      var_before = (var_id != nil && $game_variables != nil) ? $game_variables[var_id] : nil

      actor_id = 1
      detached = Game_Actor.new(actor_id)
      actor_baseline = p44c_actor_baseline(detached)
      state_id = p45a_safe_state_id
      item_id = 5
      item = $data_items[item_id] rescue nil
      item_slot = item != nil ? p42e_inventory_slot_snapshot(item) : nil
      item_new = item != nil ? p41c_new_flag(item) : nil
      item_count_before = item != nil ? $game_party.item_number(item).to_i : nil

      assert("Skill Cost contract Authority exists", defined?(FS_SKILL_COST_ALLFIX) != nil)
      assert("Skill Cost contract detached Actor exists", detached != nil, "actor=#{actor_id}")
      assert("Skill Cost contract safe State resolved", state_id != nil, "state=#{state_id.inspect}")
      assert("Skill Cost contract Item fixture exists", item != nil, "item_id=#{item_id}")
      return false if !defined?(FS_SKILL_COST_ALLFIX) || detached == nil || state_id == nil || item == nil

      skill = p45a_local_cost_skill(state_id, item_id)
      assert("Skill Cost contract local Skill prepared", skill != nil,
             "state=#{state_id} item=#{item_id}")
      return false if skill == nil

      # 準備充足資源。Actor 為 detached；Party mutation 之後會 exact restore。
      detached.hp = detached.maxhp
      detached.mp = detached.maxmp
      detached.overdrive = 100 if detached.respond_to?(:overdrive=)
      detached.add_state(state_id)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100 if var_id != nil && $game_variables != nil
      p45a_set_party_item_count(item, 2)

      costs = {
        :hp=>detached.calc_hp_cost(skill),
        :mp=>detached.calc_mp_cost(skill),
        :gold=>detached.calc_gold_cost(skill),
        :var=>detached.calc_var_cost(skill),
        :item=>detached.calc_item_cost(skill),
        :angry=>detached.calc_angry_cost(skill),
        :state=>detached.calc_state_cost(skill)
      }
      calc_ok = costs == {:hp=>12, :mp=>15, :gold=>30, :var=>7,
                          :item=>item_id, :angry=>11, :state=>state_id}
      assert("Skill Cost final calculators return exact fixed costs", calc_ok,
             "costs=#{costs.inspect}")

      baseline_usable = detached.skill_can_use?(skill)
      assert("Skill Cost full skill_can_use chain accepts sufficient resources",
             baseline_usable,
             "hp=#{detached.hp} mp=#{detached.mp} gold=#{$game_party.gold} var=#{var_id == nil ? nil : $game_variables[var_id]} item=#{$game_party.item_number(item)} od=#{detached.respond_to?(:overdrive) ? detached.overdrive : nil}")

      gates = {}

      detached.remove_state(state_id)
      gates[:state] = !detached.skill_can_use?(skill)
      detached.add_state(state_id)

      hp_ok = detached.hp
      detached.hp = 11
      gates[:hp] = !detached.skill_can_use?(skill)
      detached.hp = hp_ok

      mp_ok = detached.mp
      detached.mp = 14
      gates[:mp] = !detached.skill_can_use?(skill)
      detached.mp = mp_ok

      p45a_set_party_gold_exact(29)
      gates[:gold] = !detached.skill_can_use?(skill)
      p45a_set_party_gold_exact(1000)

      if var_id != nil && $game_variables != nil
        $game_variables[var_id] = 6
        gates[:var] = !detached.skill_can_use?(skill)
        $game_variables[var_id] = 100
      else
        gates[:var] = false
      end

      p45a_set_party_item_count(item, 0)
      gates[:item] = !detached.skill_can_use?(skill)
      p45a_set_party_item_count(item, 2)

      if detached.respond_to?(:overdrive=) && detached.respond_to?(:overdrive)
        detached.overdrive = 10
        gates[:angry] = !detached.skill_can_use?(skill)
        detached.overdrive = 100
      else
        gates[:angry] = false
      end

      gate_ok = true
      gates.each_value { |value| gate_ok = false unless value }
      assert("Skill Cost skill_can_use gates every configured resource", gate_ok,
             "gates=#{gates.inspect}")

      # Battle legacy policy 只支付 HP/Gold/Var/Item；MP/Angry 由 final Scene_Battle wrapper 擁有。
      detached.hp = detached.maxhp
      detached.mp = detached.maxmp
      detached.overdrive = 100 if detached.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100 if var_id != nil && $game_variables != nil
      p45a_set_party_item_count(item, 2)

      pay_before = {
        :hp=>detached.hp.to_i, :mp=>detached.mp.to_i,
        :gold=>$game_party.gold.to_i,
        :var=>(var_id == nil ? nil : $game_variables[var_id].to_i),
        :item=>$game_party.item_number(item).to_i,
        :angry=>(detached.respond_to?(:overdrive) ? detached.overdrive.to_i : nil)
      }
      FS_SKILL_COST_ALLFIX.pay_battle_legacy_costs(detached, skill)
      pay_after = {
        :hp=>detached.hp.to_i, :mp=>detached.mp.to_i,
        :gold=>$game_party.gold.to_i,
        :var=>(var_id == nil ? nil : $game_variables[var_id].to_i),
        :item=>$game_party.item_number(item).to_i,
        :angry=>(detached.respond_to?(:overdrive) ? detached.overdrive.to_i : nil)
      }
      legacy_pay_ok = pay_after[:hp] == pay_before[:hp] - 12 &&
                      pay_after[:mp] == pay_before[:mp] &&
                      pay_after[:gold] == pay_before[:gold] - 30 &&
                      pay_after[:var] == pay_before[:var] - 7 &&
                      pay_after[:item] == pay_before[:item] - 1 &&
                      pay_after[:angry] == pay_before[:angry]
      assert("Skill Cost Battle legacy bridge policy pays HP/Gold/Var/Item only",
             legacy_pay_ok,
             "before=#{pay_before.inspect} after=#{pay_after.inspect}")

      # Final battle owner 的 MP / Angry policy 以同一 Authority 計算器驗證；
      # Scene_Battle 實際 MP once-payment 仍由既有 Skill100 core fixture 在本輪後段驗證。
      mp_before = detached.mp.to_i
      angry_before = detached.respond_to?(:overdrive) ? detached.overdrive.to_i : 0
      detached.mp -= detached.calc_mp_cost(skill)
      FS_SKILL_COST_ALLFIX.lose_angry(detached, detached.calc_angry_cost(skill))
      mp_angry_ok = detached.mp.to_i == mp_before - 15 &&
                    (!detached.respond_to?(:overdrive) || detached.overdrive.to_i == angry_before - 11)
      assert("Skill Cost final MP/Angry payment policy uses exact calculators",
             mp_angry_ok,
             "mp=#{mp_before}->#{detached.mp} angry=#{angry_before}->#{detached.respond_to?(:overdrive) ? detached.overdrive : nil}")

      log("[SKILL_COST_CONTRACT] costs=#{costs.inspect} baseline_usable=#{baseline_usable} gates=#{gates.inspect} " +
          "legacy_pay_ok=#{legacy_pay_ok} mp_angry_ok=#{mp_angry_ok}")

      # Cleanup：先用正式 API 回原數量，再移除 fixture tombstone / NEW side effect。
      p45a_set_party_gold_exact(gold_before) if gold_before != nil
      $game_variables[var_id] = var_before if var_id != nil && $game_variables != nil
      p45a_set_party_item_count(item, item_count_before) if item_count_before != nil
      slot_restored = p42e_restore_inventory_slot(item, item_slot)
      p41c_set_new_flag(item, item_new) if item_new != nil && respond_to?(:p41c_set_new_flag)

      detached.setup(actor_id)
      p44c_restore_actor_aux(detached, actor_baseline)
      actor_restored = p44c_actor_restored?(detached, actor_baseline)
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      global_clean = party_before != nil && party_after == party_before &&
                     actors_before != nil && actors_after == actors_before
      assert("Skill Cost contract restores inventory Hash slot / NEW flag exactly",
             slot_restored && p41c_new_flag(item) == item_new,
             "slot=#{slot_restored} new=#{item_new.inspect}->#{p41c_new_flag(item).inspect}")
      assert("Skill Cost contract restores detached Actor exactly", actor_restored,
             "before=#{actor_baseline.inspect} after=#{p44c_actor_baseline(detached).inspect}")
      assert("Skill Cost contract leaves Game_Party / $game_actors exact", global_clean,
             "party=#{party_before == party_after} actors=#{actors_before == actors_after}")

      fail_delta = @fail.to_i - fail_before
      ready = calc_ok && baseline_usable && gate_ok && legacy_pay_ok && mp_angry_ok &&
              slot_restored && actor_restored && global_clean && fail_delta == 0
      log("[SKILL_COST_CONTRACT_GATE] ready=#{ready} fail_delta=#{fail_delta}")
      assert("Skill Cost Authority contract diagnostic completed", ready,
             "fail_delta=#{fail_delta}")
      return ready
    rescue Exception => e
      exception(e, "p45a_probe_skill_cost_contract")
      assert("Skill Cost Authority contract diagnostic completed", false, e.message)
      return false
    ensure
      begin
        p45a_set_party_gold_exact(gold_before) if defined?(gold_before) && gold_before != nil
        $game_variables[var_id] = var_before if defined?(var_id) && var_id != nil && $game_variables != nil
        if defined?(item) && item != nil && defined?(item_count_before) && item_count_before != nil
          p45a_set_party_item_count(item, item_count_before)
          p42e_restore_inventory_slot(item, item_slot) if defined?(item_slot) && item_slot != nil
          p41c_set_new_flag(item, item_new) if defined?(item_new) && item_new != nil && respond_to?(:p41c_set_new_flag)
        end
      rescue
      end
    end

    unless method_defined?(:fs_phase45a_prepare_battle_fixture_on_map_base)
      alias fs_phase45a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase45a_prepare_battle_fixture_on_map_base
      return p45a_probe_skill_cost_contract
    end
  end
end
end

#==============================================================================
# ■ Phase45B TEST-only｜Skill Cost Real Battle Execution Diagnostic
#------------------------------------------------------------------------------
# 【目的】Phase45A1 已實機證明 calculator / skill_can_use? / policy helper 契約正確。
#         本階段把 multi-cost synthetic Skill 真正送入 Scene_Battle#execute_action_skill，
#         驗證一次正式 Action 中 HP / MP / Gold / Variable / Item / Angry 各自只支付一次。
# 【機制】最後一個 Core Fixture 執行前，暫時以已初始化且已 PASS 的 Skill100 深複製建立
#         synthetic Skill，放入一個短暫資料庫 slot；只追加固定成本 Notetag，並把 KGC OD
#         gain/cost 設為 0，避免攻擊所得 OD 汙染自訂 Angry cost 的付款觀測。
#         TEST trace 同時包住 Scene_Battle 外層、FS_SKILL_COST_ALLFIX.pay_battle_legacy_costs
#         與 lose_angry，分別驗證整體資源差額、legacy policy exact-once、Angry exact-once。
# 【依賴／順序】必須位於既有 Battle Harness / Phase45A1 後；Formal Runtime 0 修改。
# 【清理】synthetic Skill slot 於 Fixture 完成即還原；若中途例外，Snapshot restore 後仍會
#         強制還原原 object。Party / Actor mutation 由既有 Battle Snapshot exact restore。
# 【素材】只使用現有 Skill100、Item5、Actor1 與當前 Troop；不新增正式資料。
# 【安全】$TEST=true 才生效；禁止 Class Change；不修改正式 Skill Cost Authority。
#==============================================================================
if $TEST
module FS_TEST_HARNESS
  class << self
    P45B_SKILL_SLOT = 1 unless const_defined?(:P45B_SKILL_SLOT)

    def p45b_multi_cost_fixture?
      fixture = @core_current_fixture
      return fixture != nil && fixture[:p45b_multi_cost] == true
    rescue
      return false
    end

    def p45b_scope?(battler, skill = nil)
      return false unless p45b_multi_cost_fixture?
      subject = core_current_subject rescue nil
      return false if battler == nil || subject == nil
      return false unless battler.object_id == subject.object_id
      if skill != nil
        return false if @p45b_skill_id == nil
        return false unless skill.id.to_i == @p45b_skill_id.to_i
      end
      return true
    rescue
      return false
    end

    def p45b_var_id
      return nil unless defined?(Skill_Costs)
      return Skill_Costs::Variabile.to_i
    rescue
      return nil
    end

    def p45b_resource_snapshot(battler)
      item = (@p45b_item_id != nil && $data_items != nil) ? ($data_items[@p45b_item_id] rescue nil) : nil
      var_id = p45b_var_id
      return {
        :hp=>(battler != nil && battler.respond_to?(:hp) ? battler.hp.to_i : nil),
        :mp=>(battler != nil && battler.respond_to?(:mp) ? battler.mp.to_i : nil),
        :gold=>($game_party != nil ? $game_party.gold.to_i : nil),
        :var=>(var_id != nil && $game_variables != nil ? $game_variables[var_id].to_i : nil),
        :item=>(item != nil && $game_party != nil ? $game_party.item_number(item).to_i : nil),
        :angry=>(battler != nil && battler.respond_to?(:overdrive) ? battler.overdrive.to_i : nil)
      }
    rescue
      return {}
    end

    def p45b_make_battle_skill(slot_id, item_id)
      return nil if $data_skills == nil
      base = $data_skills[100] rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.instance_variable_set(:@id, slot_id.to_i)
      skill.name = "Phase45B Multi Cost"
      skill.occasion = 1 if skill.respond_to?(:occasion=)
      # Phase45B2：只借用 Skill100 的完整 runtime shape，不繼承任何角色專屬 Note。
      # Skill100 本身帶喬伊 resonance pull，若 append 會在本成本 fixture 命中 State40 時
      # 合法先支付 conditional OD，污染 Angry exact-once 驗證。
      skill.note = "# FS_PHASE45B2_SKILL_COST_ONLY\n" +
                   "<costo hp:12>\n" +
                   "<costo mp:15>\n" +
                   "<costo oro:30>\n" +
                   "<costo var:7>\n" +
                   "<usa oggetto:#{item_id}>\n" +
                   "<costo angry:11>"
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      # 隔離 KGC OverDrive：本 probe 只驗自訂 Angry cost，不讓命中所得 OD 混入淨差額。
      skill.instance_variable_set(:@__od_cost, 0)
      skill.instance_variable_set(:@__od_gain_rate, 0)
      skill.instance_variable_set(:@__is_overdrive, false)
      skill.instance_variable_set(:@turn_delay, 0)
      skill.instance_variable_set(:@battle_delay, 0)
      skill.instance_variable_set(:@step_delay, 0)
      return skill
    rescue
      return nil
    end

    def p45b_install_battle_skill(subject)
      return false if $data_skills == nil
      return true if @p45b_slot_snapshot != nil
      slot_id = P45B_SKILL_SLOT
      original = $data_skills[slot_id] rescue nil
      return false if original == nil
      original_bytes = Marshal.dump(original) rescue nil
      item_id = 5
      item = $data_items[item_id] rescue nil
      return false if item == nil
      skill = p45b_make_battle_skill(slot_id, item_id)
      return false if skill == nil

      @p45b_slot_snapshot = {
        :slot=>slot_id, :object=>original, :object_id=>original.object_id,
        :bytes=>original_bytes, :array_oid=>$data_skills.object_id
      }
      @p45b_skill_id = slot_id
      @p45b_item_id = item_id
      $data_skills[slot_id] = skill

      @p45b_raw_learned_before = false
      begin
        raw = subject.instance_variable_get(:@skills)
        @p45b_raw_learned_before = (raw != nil && raw.include?(slot_id))
      rescue
        @p45b_raw_learned_before = false
      end
      subject.learn_skill(slot_id) unless @p45b_raw_learned_before

      costs = {
        :hp=>subject.calc_hp_cost(skill), :mp=>subject.calc_mp_cost(skill),
        :gold=>subject.calc_gold_cost(skill), :var=>subject.calc_var_cost(skill),
        :item=>subject.calc_item_cost(skill), :angry=>subject.calc_angry_cost(skill)
      }
      @p45b_expected_costs = costs
      exact = costs == {:hp=>12, :mp=>15, :gold=>30, :var=>7, :item=>item_id, :angry=>11}
      note_isolated = (skill.note.to_s =~ /<joey_resonance_pull\s+/i) == nil
      assert("Phase45B synthetic battle Skill exact costs", exact,
             "skill=#{slot_id} costs=#{costs.inspect}")
      assert("Phase45B2 synthetic Skill strips inherited Joey conditional-OD Notetag",
             note_isolated, "note=#{skill.note.inspect}")
      return exact && note_isolated
    rescue Exception => e
      exception(e, "p45b_install_battle_skill")
      return false
    end

    def p45b_restore_battle_skill_slot
      snap = @p45b_slot_snapshot
      return true if snap == nil
      ok = false
      begin
        slot = snap[:slot].to_i
        # 成功路徑先在 synthetic Skill 仍位於資料庫時撤銷 TEST-only raw learning，
        # 避免還原 slot 後有極短時間把原 Skill1 誤視為本次 learned Skill。
        subject = core_current_subject rescue nil
        if subject != nil && @p45b_raw_learned_before == false
          raw = subject.instance_variable_get(:@skills) rescue nil
          subject.forget_skill(slot) if raw != nil && raw.include?(slot)
        end
        $data_skills[slot] = snap[:object] if $data_skills != nil
        current = $data_skills[slot] rescue nil
        bytes = Marshal.dump(current) rescue nil
        ok = current != nil && current.object_id == snap[:object_id] &&
             (snap[:bytes] == nil || bytes == snap[:bytes]) &&
             $data_skills.object_id == snap[:array_oid]
      rescue
        ok = false
      end
      @p45b_slot_snapshot = nil
      @p45b_skill_id = nil
      @p45b_item_id = nil
      @p45b_raw_learned_before = nil
      return ok
    end

    def p45b_prepare_resources(subject)
      return false if subject == nil || @p45b_item_id == nil
      item = $data_items[@p45b_item_id] rescue nil
      var_id = p45b_var_id
      return false if item == nil || var_id == nil || $game_variables == nil
      subject.hp = subject.maxhp
      subject.mp = subject.maxmp
      subject.overdrive = 100 if subject.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      p45a_set_party_item_count(item, 2)
      @p45b_legacy_traces = []
      @p45b_angry_traces = []
      @p45b_execute_trace = nil
      @p45b_resource_before = p45b_resource_snapshot(subject)
      skill = $data_skills[@p45b_skill_id] rescue nil
      usable = skill != nil && subject.skill_can_use?(skill)
      assert("Phase45B multi-cost Skill usable before formal Battle action", usable,
             "resources=#{@p45b_resource_before.inspect} skill=#{@p45b_skill_id}")
      return usable
    rescue Exception => e
      exception(e, "p45b_prepare_resources")
      return false
    end

    def p45b_record_legacy_payment(battler, skill, before, after)
      return unless p45b_scope?(battler, skill)
      @p45b_legacy_traces ||= []
      @p45b_legacy_traces << {:before=>before, :after=>after}
    rescue
    end

    def p45b_record_angry_payment(battler, amount, before, after)
      return unless p45b_scope?(battler, nil)
      @p45b_angry_traces ||= []
      @p45b_angry_traces << {:amount=>amount.to_i, :before=>before.to_i, :after=>after.to_i}
    rescue
    end

    def p45b_record_execute_trace(battler, skill, before, after)
      return unless p45b_scope?(battler, skill)
      @p45b_execute_trace = {:before=>before, :after=>after}
    rescue
    end

    unless method_defined?(:fs_phase45b_core_build_fixture_plan_base)
      alias fs_phase45b_core_build_fixture_plan_base core_build_fixture_plan
    end
    def core_build_fixture_plan
      plan = fs_phase45b_core_build_fixture_plan_base
      return plan if plan == nil
      return plan if plan.any? { |f| f.is_a?(Hash) && f[:p45b_multi_cost] }
      enemies = $game_troop.members.select { |e| e != nil && e.exist? }
      target = enemies.sort_by { |e| -(e.maxhp.to_i rescue 0) }[0]
      if target != nil
        plan << {
          :name=>"PHASE45B_MULTI_COST_REAL_BATTLE", :kind=>:skill,
          :skill_id=>P45B_SKILL_SLOT, :boost_hp=>true,
          :p45b_multi_cost=>true,
          :target_index=>target.index, :target_oid=>target.object_id
        }
      end
      @core_fixture_plan = plan
      log("[FIXTURE] PHASE45B action-plan=#{plan.collect { |f| f[:name] }.inspect}")
      return plan
    end

    unless method_defined?(:fs_phase45b_core_prepare_action_state_base)
      alias fs_phase45b_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45b_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:p45b_multi_cost]
        installed = p45b_install_battle_skill(subject)
        assert("Phase45B synthetic Skill database slot installed", installed,
               "slot=#{P45B_SKILL_SLOT}")
        prepared = installed && p45b_prepare_resources(subject)
        assert("Phase45B real Battle payment resources prepared", prepared,
               "resources=#{@p45b_resource_before.inspect}")
      end
      return result
    end

    unless method_defined?(:fs_phase45b_core_finalize_fixture_base)
      alias fs_phase45b_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45b_core_finalize_fixture_base
      if fixture != nil && fixture[:p45b_multi_cost]
        subject = core_current_subject
        execute = @p45b_execute_trace
        legacy = @p45b_legacy_traces || []
        angry = @p45b_angry_traces || []
        costs = @p45b_expected_costs || {}

        before = execute == nil ? {} : execute[:before]
        after = execute == nil ? {} : execute[:after]
        deltas = {}
        [:hp, :mp, :gold, :var, :item, :angry].each do |key|
          if before[key] != nil && after[key] != nil
            deltas[key] = before[key].to_i - after[key].to_i
          else
            deltas[key] = nil
          end
        end
        exact_deltas = deltas[:hp] == 12 && deltas[:mp] == 15 &&
                       deltas[:gold] == 30 && deltas[:var] == 7 &&
                       deltas[:item] == 1 && deltas[:angry] == 11
        assert("Phase45B one real execute_action_skill pays every resource exactly once",
               exact_deltas,
               "before=#{before.inspect} after=#{after.inspect} deltas=#{deltas.inspect}")

        legacy_ok = legacy.size == 1
        if legacy_ok
          lb = legacy[0][:before]
          la = legacy[0][:after]
          legacy_ok = lb[:hp].to_i - la[:hp].to_i == 12 &&
                      lb[:mp].to_i - la[:mp].to_i == 0 &&
                      lb[:gold].to_i - la[:gold].to_i == 30 &&
                      lb[:var].to_i - la[:var].to_i == 7 &&
                      lb[:item].to_i - la[:item].to_i == 1 &&
                      lb[:angry].to_i - la[:angry].to_i == 0
        end
        assert("Phase45B legacy payment bridge runs exactly once and owns HP/Gold/Var/Item only",
               legacy_ok, "traces=#{legacy.inspect}")

        angry_ok = angry.size == 1 && angry[0][:amount].to_i == 11 &&
                   angry[0][:before].to_i - angry[0][:after].to_i == 11
        assert("Phase45B final Angry payment runs exactly once",
               angry_ok, "traces=#{angry.inspect}")

        mp_ok = deltas[:mp] == costs[:mp].to_i
        assert("Phase45B final MP payment equals Authority calculator exactly once",
               mp_ok, "expected=#{costs[:mp].inspect} delta=#{deltas[:mp].inspect}")

        slot_ok = p45b_restore_battle_skill_slot
        assert("Phase45B synthetic Skill database slot restored exactly", slot_ok,
               "slot=#{P45B_SKILL_SLOT}")

        ready = exact_deltas && legacy_ok && angry_ok && mp_ok && slot_ok
        log("[SKILL_COST_BATTLE_EXECUTION] costs=#{costs.inspect} deltas=#{deltas.inspect} " +
            "legacy_calls=#{legacy.size} angry_calls=#{angry.size} slot_restored=#{slot_ok} ready=#{ready}")
        assert("Phase45B real Battle multi-cost execution diagnostic completed", ready,
               "deltas=#{deltas.inspect} legacy=#{legacy.size} angry=#{angry.size}")
      end
      return result
    rescue Exception => e
      exception(e, "p45b_core_finalize_current_fixture")
      p45b_restore_battle_skill_slot rescue nil
      assert("Phase45B real Battle multi-cost execution diagnostic completed", false, e.message)
      return result
    end

    unless method_defined?(:fs_phase45b_restore_pending_base)
      alias fs_phase45b_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45b_restore_pending_base
      if result && @p45b_slot_snapshot != nil
        restored = p45b_restore_battle_skill_slot
        assert("Phase45B emergency Skill slot cleanup after Snapshot restore", restored,
               "slot=#{P45B_SKILL_SLOT}")
      end
      return result
    end
  end
end

# TEST-only trace：觀察正式 payment helper 的呼叫次數與資源 ownership。
if defined?(FS_SKILL_COST_ALLFIX)
module FS_SKILL_COST_ALLFIX
  class << self
    unless method_defined?(:fs_phase45b_pay_battle_legacy_base)
      alias fs_phase45b_pay_battle_legacy_base pay_battle_legacy_costs
    end
    def pay_battle_legacy_costs(battler, skill)
      scoped = FS_TEST_HARNESS.p45b_scope?(battler, skill)
      before = scoped ? FS_TEST_HARNESS.p45b_resource_snapshot(battler) : nil
      result = fs_phase45b_pay_battle_legacy_base(battler, skill)
      if scoped
        after = FS_TEST_HARNESS.p45b_resource_snapshot(battler)
        FS_TEST_HARNESS.p45b_record_legacy_payment(battler, skill, before, after)
      end
      return result
    end

    unless method_defined?(:fs_phase45b_lose_angry_base)
      alias fs_phase45b_lose_angry_base lose_angry
    end
    def lose_angry(battler, amount)
      scoped = FS_TEST_HARNESS.p45b_scope?(battler, nil)
      before = scoped ? FS_SKILL_COST_ALLFIX.angry_value(battler).to_i : nil
      result = fs_phase45b_lose_angry_base(battler, amount)
      if scoped
        after = FS_SKILL_COST_ALLFIX.angry_value(battler).to_i
        FS_TEST_HARNESS.p45b_record_angry_payment(battler, amount, before, after)
      end
      return result
    end
  end
end
end

# 最外層 Scene_Battle trace：取得一次正式 execute_action_skill 的整體資源淨差額。
if defined?(Scene_Battle)
class Scene_Battle < Scene_Base
  unless method_defined?(:fs_phase45b_execute_action_skill_base)
    alias fs_phase45b_execute_action_skill_base execute_action_skill
  end
  def execute_action_skill(*args)
    battler = @active_battler
    skill = nil
    begin
      skill = battler.action.skill if battler != nil && battler.action != nil
    rescue
      skill = nil
    end
    scoped = FS_TEST_HARNESS.p45b_scope?(battler, skill)
    before = scoped ? FS_TEST_HARNESS.p45b_resource_snapshot(battler) : nil
    result = fs_phase45b_execute_action_skill_base(*args)
    if scoped
      after = FS_TEST_HARNESS.p45b_resource_snapshot(battler)
      FS_TEST_HARNESS.p45b_record_execute_trace(battler, skill, before, after)
    end
    return result
  end
end
end
end

#==============================================================================
# ■ Phase45B1 TEST-only｜Angry / KGC OverDrive Gauge Provenance Diagnostic
#------------------------------------------------------------------------------
# 【用途】
#   Phase45B 實機已證明 HP / MP / Gold / Variable / Item 均 exact-once，唯獨
#   Angry 在 FS_SKILL_COST_ALLFIX.lose_angry 前已由 100 變成 0。本診斷只追蹤
#   這次 multi-cost fixture 的 OD 寫入與 KGC consume_od_gauge，不修改正式邏輯。
#
# 【機制】
#   1. 在正式 Action 前記錄 synthetic Skill 的 overdrive? / od_cost / calc_od_cost。
#   2. TEST-only 包裝 Game_Battler#overdrive=，記錄每次 OD 寫入及 caller stack。
#   3. TEST-only 包裝 Scene_Battle#consume_od_gauge，記錄 KGC OD cost 與前後值。
#   4. Skill slot 還原前輸出 [SKILL_COST_OD_PROVENANCE] 摘要；只驗診斷基礎設施。
#
# 【依賴／載入順序】
#   依賴既有 Phase45B TEST helper 與 KGC OverDrive；本段位於 page480 最末端。
#
# 【Formal Runtime】
#   0 修改。所有 alias 僅存在 AutoRegression TEST page480。
#==============================================================================

if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p45b1_subject_scope?(battler)
      return false if battler == nil
      return false unless p45b_multi_cost_fixture?
      return false if @p45b_skill_id == nil
      begin
        subject = core_current_subject
        return false if subject == nil
        return subject.object_id == battler.object_id
      rescue
        return false
      end
    end

    def p45b1_record_od_write(battler, requested, before_raw, after_raw, stack)
      return unless p45b1_subject_scope?(battler)
      @p45b1_od_writes ||= []
      @p45b1_od_writes << {
        :requested=>requested.to_i,
        :before=>before_raw == nil ? nil : before_raw.to_i,
        :after=>after_raw == nil ? nil : after_raw.to_i,
        :stack=>stack
      }
    rescue
    end

    def p45b1_record_consume(data)
      @p45b1_consume_traces ||= []
      @p45b1_consume_traces << data
    rescue
    end

    unless method_defined?(:fs_phase45b1_prepare_resources_base)
      alias fs_phase45b1_prepare_resources_base p45b_prepare_resources
    end
    def p45b_prepare_resources(subject)
      @p45b1_od_writes = []
      @p45b1_consume_traces = []
      @p45b1_pre_od = nil
      result = fs_phase45b1_prepare_resources_base(subject)
      if result && @p45b_skill_id != nil
        skill = $data_skills[@p45b_skill_id] rescue nil
        if skill != nil
          is_od = skill.respond_to?(:overdrive?) ? (skill.overdrive? rescue nil) : nil
          od_cost = skill.respond_to?(:od_cost) ? (skill.od_cost rescue nil) : nil
          calc = subject.respond_to?(:calc_od_cost) ? (subject.calc_od_cost(skill) rescue nil) : nil
          raw_is = skill.instance_variable_get(:@__is_overdrive) rescue nil
          raw_cost = skill.instance_variable_get(:@__od_cost) rescue nil
          raw_gain = skill.instance_variable_get(:@__od_gain_rate) rescue nil
          @p45b1_pre_od = {
            :is_overdrive=>is_od, :od_cost=>od_cost, :calc_od_cost=>calc,
            :raw_is=>raw_is, :raw_cost=>raw_cost, :raw_gain=>raw_gain,
            :angry=>(subject.respond_to?(:overdrive) ? subject.overdrive.to_i : nil)
          }
          pre_ok = (is_od == false && od_cost.to_i == 0 && calc.to_i == 0)
          log("[SKILL_COST_OD_PRE] skill=#{skill.id}:#{skill.name} data=#{@p45b1_pre_od.inspect}")
          assert("Phase45B1 synthetic Skill enters Battle with zero KGC OD cost", pre_ok,
                 "data=#{@p45b1_pre_od.inspect}")
        end
      end
      return result
    rescue Exception => e
      exception(e, "p45b1_prepare_resources")
      return result
    end

    unless method_defined?(:fs_phase45b1_restore_slot_base)
      alias fs_phase45b1_restore_slot_base p45b_restore_battle_skill_slot
    end
    def p45b_restore_battle_skill_slot
      begin
        if @p45b_slot_snapshot != nil
          writes = @p45b1_od_writes || []
          consumes = @p45b1_consume_traces || []
          zero_write = nil
          writes.each do |w|
            if w[:before] != nil && w[:before].to_i > 0 && w[:after] != nil && w[:after].to_i == 0
              zero_write = w
              break
            end
          end
          execute = @p45b_execute_trace
          angry_delta = nil
          if execute != nil && execute[:before] != nil && execute[:after] != nil &&
             execute[:before][:angry] != nil && execute[:after][:angry] != nil
            angry_delta = execute[:before][:angry].to_i - execute[:after][:angry].to_i
          end
          consume_zero = !consumes.empty?
          consumes.each do |c|
            consume_zero = false unless c[:calc_od_cost].to_i == 0 && c[:before].to_i == c[:after].to_i
          end
          diag_ready = (angry_delta == 11 && zero_write == nil && consume_zero)
          log("[SKILL_COST_OD_PROVENANCE] pre=#{@p45b1_pre_od.inspect} angry_delta=#{angry_delta.inspect} " +
              "writes=#{writes.inspect} consumes=#{consumes.inspect} zero_write=#{zero_write.inspect} ready=#{diag_ready}")
          log("[SKILL_COST_OD_ISOLATION] angry_delta=#{angry_delta.inspect} zero_write=#{zero_write.inspect} " +
              "consume_zero=#{consume_zero} ready=#{diag_ready}")
          assert("Phase45B2 Angry/OD fixture isolation leaves only final Angry cost", diag_ready,
                 "angry_delta=#{angry_delta.inspect} zero_write=#{zero_write.inspect} consumes=#{consumes.inspect}")
        end
      rescue Exception => e
        exception(e, "p45b1_restore_slot_diagnostic")
      end
      return fs_phase45b1_restore_slot_base
    end
  end
end
end

# TEST-only：追蹤本次 fixture subject 的所有 overdrive= 寫入。
if defined?(Game_Battler)
class Game_Battler
  unless method_defined?(:fs_phase45b1_overdrive_set_base)
    alias fs_phase45b1_overdrive_set_base overdrive=
  end
  def overdrive=(value)
    scoped = defined?(FS_TEST_HARNESS) && FS_TEST_HARNESS.p45b1_subject_scope?(self)
    before_raw = scoped ? (instance_variable_get(:@overdrive) rescue nil) : nil
    stack = scoped ? (caller[0, 8] rescue []) : nil
    result = fs_phase45b1_overdrive_set_base(value)
    if scoped
      after_raw = instance_variable_get(:@overdrive) rescue nil
      FS_TEST_HARNESS.p45b1_record_od_write(self, value, before_raw, after_raw, stack)
    end
    return result
  end
end
end

# TEST-only：直接包住 KGC Scene_Battle#consume_od_gauge，確認其當下 Skill 與 OD cost。
if defined?(Scene_Battle)
class Scene_Battle < Scene_Base
  if method_defined?(:consume_od_gauge) && !method_defined?(:fs_phase45b1_consume_od_gauge_base)
    alias fs_phase45b1_consume_od_gauge_base consume_od_gauge
    def consume_od_gauge(*args)
      battler = @active_battler
      skill = nil
      begin
        skill = battler.action.skill if battler != nil && battler.action != nil
      rescue
        skill = nil
      end
      scoped = defined?(FS_TEST_HARNESS) && FS_TEST_HARNESS.p45b_scope?(battler, skill)
      data = nil
      if scoped
        data = {
          :before=>(battler.respond_to?(:overdrive) ? battler.overdrive.to_i : nil),
          :skill_id=>(skill != nil ? skill.id.to_i : nil),
          :skill_oid=>(skill != nil ? skill.object_id : nil),
          :is_overdrive=>(skill != nil && skill.respond_to?(:overdrive?) ? (skill.overdrive? rescue nil) : nil),
          :od_cost=>(skill != nil && skill.respond_to?(:od_cost) ? (skill.od_cost rescue nil) : nil),
          :calc_od_cost=>(battler != nil && battler.respond_to?(:calc_od_cost) ? (battler.calc_od_cost(skill) rescue nil) : nil),
          :raw_is=>(skill != nil ? (skill.instance_variable_get(:@__is_overdrive) rescue nil) : nil),
          :raw_cost=>(skill != nil ? (skill.instance_variable_get(:@__od_cost) rescue nil) : nil),
          :stack=>(caller[0, 8] rescue [])
        }
      end
      result = fs_phase45b1_consume_od_gauge_base(*args)
      if scoped
        data[:after] = battler.respond_to?(:overdrive) ? battler.overdrive.to_i : nil
        FS_TEST_HARNESS.p45b1_record_consume(data)
        FS_TEST_HARNESS.log("[SKILL_COST_OD_CONSUME] #{data.inspect}")
      end
      return result
    end
  end
end
end

#==============================================================================
# ■ Phase45C TEST-only｜Skill Cost Percentage / Half / Clamp / Menu Diagnostic
#------------------------------------------------------------------------------
# 【用途】
#   Phase45B2 已實機封住 Battle multi-cost exact-once。本段補齊成本數值邊界與
#   Scene_Skill 最終支付路徑，驗證固定＋百分比混合、Half Cost 選擇性減半、
#   上限 clamp、等額可用邊界，以及選單一次技能支付六種資源 exact-once。
#
# 【機制】
#   1. 以已初始化 Skill100 deep clone 建立 local synthetic Skill，但 Note 完全隔離。
#   2. mixed percent：HP/MP/Gold/Variable 使用固定＋百分比；Angry 固定值。
#   3. Half Cost：依現行政策驗證 HP/MP/Gold/Variable 減半、Angry 不減半。
#   4. clamp：驗證 HP/MP/Angry=999999、Gold/Variable=99999999 上限。
#   5. Scene_Skill#use_skill_nontarget：trace pay_menu_standard_costs、lose_angry、
#      KGC menu consume_od_gauge，確認 HP/MP/Gold/Variable/Item/Angry 各扣一次。
#
# 【依賴／順序】依賴 page312 Legacy Skill Cost Provider 與 page411 Final Authority；
#   位於 page480 AutoRegression 最末端，僅 $TEST=true 生效。
# 【清理】所有 Actor 均 detached；Party Gold/Variable/Item 與 NEW/Hash tombstone、
#   $scene identity 全部 exact restore，不改正式資料庫 Skill。
# 【Formal Runtime】0 修改。禁止 Class Change；不修改 page312 / page411。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p45c_local_skill(note_text, name)
      return nil if $data_skills == nil
      base = $data_skills[100] rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.name = name.to_s
      skill.occasion = 0 if skill.respond_to?(:occasion=)
      skill.common_event_id = 0 if skill.respond_to?(:common_event_id=)
      skill.note = note_text.to_s
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      # 本 probe 不驗 KGC OD Skill cost，只驗 Skill Cost Authority 的 Angry cost。
      skill.instance_variable_set(:@__od_cost, 0)
      skill.instance_variable_set(:@__od_gain_rate, 0)
      skill.instance_variable_set(:@__is_overdrive, false)
      skill.instance_variable_set(:@turn_delay, 0)
      skill.instance_variable_set(:@battle_delay, 0)
      skill.instance_variable_set(:@step_delay, 0)
      return skill
    rescue
      return nil
    end

    def p45c_cost_snapshot(actor, skill)
      return {} if actor == nil || skill == nil
      return {
        :hp=>actor.calc_hp_cost(skill),
        :mp=>actor.calc_mp_cost(skill),
        :gold=>actor.calc_gold_cost(skill),
        :var=>actor.calc_var_cost(skill),
        :angry=>actor.calc_angry_cost(skill)
      }
    rescue
      return {}
    end

    def p45c_set_half_flag(actor, value)
      return false if actor == nil || !actor.respond_to?(:passive_effects)
      effects = actor.passive_effects
      return false unless effects.is_a?(Hash)
      effects[:half_mp_cost] = value ? true : false
      return FS_SKILL_COST_ALLFIX.half?(actor) == (value ? true : false)
    rescue
      return false
    end

    def p45c_boundary_usable(actor, skill, costs, gold_value, var_value)
      return false if actor == nil || skill == nil
      actor.hp = costs[:hp].to_i
      actor.mp = costs[:mp].to_i
      actor.overdrive = costs[:angry].to_i if actor.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(gold_value.to_i)
      var_id = p45b_var_id
      $game_variables[var_id] = var_value.to_i if var_id != nil && $game_variables != nil
      return actor.skill_can_use?(skill)
    rescue
      return false
    end

    def p45c_menu_resource_snapshot(actor)
      item_id = @p45c_menu_item_id
      item = (item_id != nil && $data_items != nil) ? ($data_items[item_id] rescue nil) : nil
      var_id = p45b_var_id
      return {
        :hp=>(actor != nil && actor.respond_to?(:hp) ? actor.hp.to_i : nil),
        :mp=>(actor != nil && actor.respond_to?(:mp) ? actor.mp.to_i : nil),
        :gold=>($game_party != nil ? $game_party.gold.to_i : nil),
        :var=>(var_id != nil && $game_variables != nil ? $game_variables[var_id].to_i : nil),
        :item=>(item != nil && $game_party != nil ? $game_party.item_number(item).to_i : nil),
        :angry=>(actor != nil && actor.respond_to?(:overdrive) ? actor.overdrive.to_i : nil)
      }
    rescue
      return {}
    end

    def p45c_menu_scope?(actor, skill)
      return false unless @p45c_menu_active
      return false if actor == nil || skill == nil
      return false if @p45c_menu_actor_oid == nil || @p45c_menu_skill_oid == nil
      return actor.object_id == @p45c_menu_actor_oid && skill.object_id == @p45c_menu_skill_oid
    rescue
      return false
    end

    def p45c_menu_actor_scope?(actor)
      return false unless @p45c_menu_active
      return false if actor == nil || @p45c_menu_actor_oid == nil
      return actor.object_id == @p45c_menu_actor_oid
    rescue
      return false
    end

    def p45c_record_menu_standard(before, after)
      @p45c_menu_standard_traces ||= []
      @p45c_menu_standard_traces << {:before=>before, :after=>after}
    rescue
    end

    def p45c_record_menu_angry(amount, before, after)
      @p45c_menu_angry_traces ||= []
      @p45c_menu_angry_traces << {:amount=>amount.to_i, :before=>before.to_i, :after=>after.to_i}
    rescue
    end

    def p45c_record_menu_od(before, after, calc)
      @p45c_menu_od_traces ||= []
      @p45c_menu_od_traces << {:before=>before.to_i, :after=>after.to_i, :calc_od_cost=>calc.to_i}
    rescue
    end

    def p45c_probe_cost_boundaries_and_menu
      fail_before = @fail.to_i
      party_before = Marshal.dump($game_party) rescue nil
      actors_before = Marshal.dump($game_actors) rescue nil
      scene_before = $scene
      gold_before = $game_party.gold.to_i rescue nil
      var_id = p45b_var_id
      var_before = (var_id != nil && $game_variables != nil) ? $game_variables[var_id] : nil
      item_id = 5
      item = $data_items[item_id] rescue nil
      item_slot = item != nil ? p42e_inventory_slot_snapshot(item) : nil
      item_new = item != nil ? p41c_new_flag(item) : nil
      item_count_before = item != nil ? $game_party.item_number(item).to_i : nil

      actor = Game_Actor.new(1)
      actor_baseline = p44c_actor_baseline(actor)
      half_before = nil
      begin
        half_before = actor.passive_effects[:half_mp_cost] if actor.respond_to?(:passive_effects)
      rescue
        half_before = nil
      end

      assert("Phase45C Skill Cost Authority / detached Actor / Item fixture exists",
             defined?(FS_SKILL_COST_ALLFIX) != nil && actor != nil && item != nil && var_id != nil,
             "actor=#{actor != nil} item=#{item_id} var=#{var_id.inspect}")
      return false if !defined?(FS_SKILL_COST_ALLFIX) || actor == nil || item == nil || var_id == nil

      #--------------------------------------------------------------------
      # A. 固定＋百分比混合成本與 exact resource boundary
      #--------------------------------------------------------------------
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      p45c_set_half_flag(actor, false)
      mixed_note = "# FS_PHASE45C_MIXED_PERCENT\n" +
                   "<costo hp:10>\n<costo hp:10%>\n" +
                   "<costo mp:10>\n<costo mp:20%>\n" +
                   "<costo oro:50>\n<costo oro:10%>\n" +
                   "<costo var:5>\n<costo var:20%>\n" +
                   "<costo angry:15>"
      mixed = p45c_local_skill(mixed_note, "Phase45C Mixed Percent")
      assert("Phase45C mixed percent synthetic Skill prepared", mixed != nil)
      return false if mixed == nil

      normal = p45c_cost_snapshot(actor, mixed)
      expected_normal = {
        :hp=>10 + actor.maxhp.to_i * 10 / 100,
        :mp=>10 + actor.maxmp.to_i * 20 / 100,
        :gold=>150,
        :var=>25,
        :angry=>15
      }
      normal_ok = normal == expected_normal
      assert("Phase45C fixed + percentage calculators are exact", normal_ok,
             "maxhp=#{actor.maxhp} maxmp=#{actor.maxmp} expected=#{expected_normal.inspect} actual=#{normal.inspect}")

      gates = {}
      # HP / MP / Angry 的 cost 不依目前資源本身，直接測 exact 與 one-below。
      actor.hp = normal[:hp].to_i
      actor.mp = normal[:mp].to_i
      actor.overdrive = normal[:angry].to_i if actor.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      exact_usable = actor.skill_can_use?(mixed)
      actor.hp = normal[:hp].to_i - 1
      gates[:hp] = !actor.skill_can_use?(mixed)
      actor.hp = normal[:hp].to_i
      actor.mp = normal[:mp].to_i - 1
      gates[:mp] = !actor.skill_can_use?(mixed)
      actor.mp = normal[:mp].to_i
      actor.overdrive = normal[:angry].to_i - 1 if actor.respond_to?(:overdrive=)
      gates[:angry] = !actor.skill_can_use?(mixed)
      actor.overdrive = normal[:angry].to_i if actor.respond_to?(:overdrive=)

      # Gold / Variable 的百分比 cost 依「目前資源」計算，不能拿 1000 時的 cost
      # 直接當 exact threshold。逐點求出第一個 cost <= resource 的真正臨界值。
      gold_threshold = nil
      n = 0
      while n <= 500
        p45a_set_party_gold_exact(n)
        if actor.calc_gold_cost(mixed).to_i <= n
          gold_threshold = n
          break
        end
        n += 1
      end
      p45a_set_party_gold_exact(gold_threshold.to_i)
      $game_variables[var_id] = 100
      gates[:gold_equal] = gold_threshold != nil && actor.skill_can_use?(mixed)
      if gold_threshold != nil && gold_threshold > 0
        p45a_set_party_gold_exact(gold_threshold - 1)
        gates[:gold_below] = !actor.skill_can_use?(mixed)
      else
        gates[:gold_below] = false
      end

      p45a_set_party_gold_exact(1000)
      var_threshold = nil
      n = 0
      while n <= 500
        $game_variables[var_id] = n
        if actor.calc_var_cost(mixed).to_i <= n
          var_threshold = n
          break
        end
        n += 1
      end
      $game_variables[var_id] = var_threshold.to_i
      gates[:var_equal] = var_threshold != nil && actor.skill_can_use?(mixed)
      if var_threshold != nil && var_threshold > 0
        $game_variables[var_id] = var_threshold - 1
        gates[:var_below] = !actor.skill_can_use?(mixed)
      else
        gates[:var_below] = false
      end

      boundary_ok = exact_usable && gates.values.all? { |v| v == true }
      assert("Phase45C percentage costs accept exact resources and reject one-below boundaries",
             boundary_ok, "exact=#{exact_usable} gold_threshold=#{gold_threshold.inspect} " +
             "var_threshold=#{var_threshold.inspect} gates=#{gates.inspect} costs=#{normal.inspect}")

      #--------------------------------------------------------------------
      # B. Half Cost policy：HP/MP/Gold/Var 半減，Angry 依 Dimezza_C_A=false 不減。
      #--------------------------------------------------------------------
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      half_enabled = p45c_set_half_flag(actor, true)
      half = p45c_cost_snapshot(actor, mixed)
      expected_half = {
        :hp=>expected_normal[:hp] / 2,
        :mp=>expected_normal[:mp] / 2,
        :gold=>expected_normal[:gold] / 2,
        :var=>expected_normal[:var] / 2,
        :angry=>expected_normal[:angry]
      }
      half_ok = half_enabled && half == expected_half &&
                defined?(Skill_Costs) && Skill_Costs::Dimezza_C_HP == true &&
                Skill_Costs::Dimezza_C_G == true && Skill_Costs::Dimezza_C_V == true &&
                Skill_Costs::Dimezza_C_A == false
      assert("Phase45C Half Cost selectively halves HP/MP/Gold/Variable but not Angry",
             half_ok, "enabled=#{half_enabled} expected=#{expected_half.inspect} actual=#{half.inspect}")
      p45c_set_half_flag(actor, false)

      #--------------------------------------------------------------------
      # C. Calculator hard clamp
      #--------------------------------------------------------------------
      clamp_note = "# FS_PHASE45C_CLAMP\n" +
                   "<costo hp:2000000>\n<costo mp:2000000>\n" +
                   "<costo oro:200000000>\n<costo var:200000000>\n" +
                   "<costo angry:2000000>"
      clamp_skill = p45c_local_skill(clamp_note, "Phase45C Clamp")
      clamp = p45c_cost_snapshot(actor, clamp_skill)
      expected_clamp = {:hp=>999999, :mp=>999999, :gold=>99999999,
                        :var=>99999999, :angry=>999999}
      clamp_ok = clamp_skill != nil && clamp == expected_clamp
      assert("Phase45C Skill Cost calculator hard clamps are exact", clamp_ok,
             "expected=#{expected_clamp.inspect} actual=#{clamp.inspect}")

      log("[SKILL_COST_BOUNDARY] normal=#{normal.inspect} expected=#{expected_normal.inspect} " +
          "exact_usable=#{exact_usable} gates=#{gates.inspect} half=#{half.inspect} " +
          "expected_half=#{expected_half.inspect} clamp=#{clamp.inspect} ready=#{normal_ok && boundary_ok && half_ok && clamp_ok}")

      #--------------------------------------------------------------------
      # D. 真正 Scene_Skill#use_skill_nontarget exact-once
      #--------------------------------------------------------------------
      menu_note = "# FS_PHASE45C_MENU_ONLY\n" +
                  "<costo hp:12>\n<costo mp:15>\n<costo oro:30>\n" +
                  "<costo var:7>\n<usa oggetto:#{item_id}>\n<costo angry:11>"
      menu_skill = p45c_local_skill(menu_note, "Phase45C Menu Cost")
      menu_costs = menu_skill != nil ? {
        :hp=>actor.calc_hp_cost(menu_skill), :mp=>actor.calc_mp_cost(menu_skill),
        :gold=>actor.calc_gold_cost(menu_skill), :var=>actor.calc_var_cost(menu_skill),
        :item=>actor.calc_item_cost(menu_skill), :angry=>actor.calc_angry_cost(menu_skill)
      } : {}
      menu_costs_ok = menu_costs == {:hp=>12, :mp=>15, :gold=>30, :var=>7,
                                     :item=>item_id, :angry=>11}
      assert("Phase45C Menu synthetic Skill exact fixed costs", menu_costs_ok,
             "costs=#{menu_costs.inspect}")

      actor.hp = actor.maxhp
      actor.mp = actor.maxmp
      actor.overdrive = 100 if actor.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      p45a_set_party_item_count(item, 2)
      menu_usable = menu_skill != nil && actor.skill_can_use?(menu_skill)
      assert("Phase45C Menu synthetic Skill is formally usable before payment", menu_usable,
             "hp=#{actor.hp} mp=#{actor.mp} gold=#{$game_party.gold} var=#{$game_variables[var_id]} item=#{$game_party.item_number(item)} od=#{actor.overdrive}")

      @p45c_menu_standard_traces = []
      @p45c_menu_angry_traces = []
      @p45c_menu_od_traces = []
      @p45c_menu_actor_oid = actor.object_id
      @p45c_menu_skill_oid = menu_skill.object_id
      @p45c_menu_item_id = item_id
      @p45c_menu_active = true
      before_menu = p45c_menu_resource_snapshot(actor)
      scene = Scene_Skill.new(0)
      scene.instance_variable_set(:@actor, actor)
      scene.instance_variable_set(:@skill, menu_skill)
      scene.instance_variable_set(:@status_window, nil)
      scene.instance_variable_set(:@skill_window, nil)
      scene.instance_variable_set(:@target_window, nil)
      scene.use_skill_nontarget
      after_menu = p45c_menu_resource_snapshot(actor)
      @p45c_menu_active = false

      menu_delta = {}
      [:hp, :mp, :gold, :var, :item, :angry].each do |key|
        menu_delta[key] = before_menu[key].to_i - after_menu[key].to_i
      end
      standard = @p45c_menu_standard_traces || []
      angry = @p45c_menu_angry_traces || []
      od = @p45c_menu_od_traces || []
      menu_exact = menu_delta == {:hp=>12, :mp=>15, :gold=>30, :var=>7, :item=>1, :angry=>11}
      standard_once = standard.size == 1
      angry_once = angry.size == 1 && angry[0][:amount].to_i == 11 &&
                   angry[0][:before].to_i - angry[0][:after].to_i == 11
      od_zero = od.size == 1 && od[0][:calc_od_cost].to_i == 0 &&
                od[0][:before].to_i == od[0][:after].to_i
      scene_same = $scene.object_id == scene_before.object_id
      assert("Phase45C Scene_Skill pays every configured resource exactly once",
             menu_exact, "before=#{before_menu.inspect} after=#{after_menu.inspect} delta=#{menu_delta.inspect}")
      assert("Phase45C Scene_Skill standard payment policy executes exactly once",
             standard_once, "traces=#{standard.inspect}")
      assert("Phase45C Scene_Skill final Angry payment executes exactly once",
             angry_once, "traces=#{angry.inspect}")
      assert("Phase45C Scene_Skill KGC OD consume is zero-cost and non-interfering",
             od_zero, "traces=#{od.inspect}")
      assert("Phase45C Scene_Skill synthetic execution does not replace current Scene",
             scene_same, "before=#{scene_before.class} after=#{$scene.class}")
      log("[SKILL_COST_MENU_EXECUTION] costs=#{menu_costs.inspect} delta=#{menu_delta.inspect} " +
          "standard_calls=#{standard.size} angry_calls=#{angry.size} od_calls=#{od.size} " +
          "scene_same=#{scene_same} ready=#{menu_exact && standard_once && angry_once && od_zero && scene_same}")

      # exact cleanup to the pre-probe state (which already includes earlier prebattle fixture prep)
      p45a_set_party_gold_exact(gold_before) if gold_before != nil
      $game_variables[var_id] = var_before if var_before != nil
      p45a_set_party_item_count(item, item_count_before) if item_count_before != nil
      p42e_restore_inventory_slot(item, item_slot) if item_slot != nil
      p41c_set_new_flag(item, item_new) if item_new != nil && respond_to?(:p41c_set_new_flag)
      begin
        actor.passive_effects[:half_mp_cost] = half_before if actor.respond_to?(:passive_effects)
      rescue
      end
      actor.setup(1)
      actor_restored = p44c_actor_restored?(actor, actor_baseline)
      party_after = Marshal.dump($game_party) rescue nil
      actors_after = Marshal.dump($game_actors) rescue nil
      globals_clean = party_before != nil && party_after == party_before &&
                      actors_before != nil && actors_after == actors_before &&
                      $scene.object_id == scene_before.object_id
      assert("Phase45C boundary/menu diagnostic restores detached Actor exactly",
             actor_restored, "before=#{actor_baseline.inspect} after=#{p44c_actor_baseline(actor).inspect}")
      assert("Phase45C boundary/menu diagnostic restores Party / Actors / Scene exactly",
             globals_clean, "party=#{party_before == party_after} actors=#{actors_before == actors_after} scene=#{$scene.object_id == scene_before.object_id}")

      fail_delta = @fail.to_i - fail_before
      boundary_ready = normal_ok && boundary_ok && half_ok && clamp_ok
      menu_ready = menu_costs_ok && menu_usable && menu_exact && standard_once && angry_once && od_zero && scene_same
      ready = boundary_ready && menu_ready && actor_restored && globals_clean && fail_delta == 0
      log("[SKILL_COST_PHASE45C_GATE] boundary_ready=#{boundary_ready} menu_ready=#{menu_ready} " +
          "actor_restored=#{actor_restored} globals_clean=#{globals_clean} fail_delta=#{fail_delta} ready=#{ready}")
      assert("Phase45C Skill Cost boundary / Half / clamp / Menu diagnostic completed", ready,
             "fail_delta=#{fail_delta} boundary=#{boundary_ready} menu=#{menu_ready}")
      return ready
    rescue Exception => e
      exception(e, "p45c_probe_cost_boundaries_and_menu")
      assert("Phase45C Skill Cost boundary / Half / clamp / Menu diagnostic completed", false, e.message)
      return false
    ensure
      @p45c_menu_active = false
      @p45c_menu_actor_oid = nil
      @p45c_menu_skill_oid = nil
      @p45c_menu_item_id = nil
      begin
        p45a_set_party_gold_exact(gold_before) if defined?(gold_before) && gold_before != nil
        if defined?(var_id) && var_id != nil && defined?(var_before) && var_before != nil && $game_variables != nil
          $game_variables[var_id] = var_before
        end
        if defined?(item) && item != nil && defined?(item_count_before) && item_count_before != nil
          p45a_set_party_item_count(item, item_count_before)
          p42e_restore_inventory_slot(item, item_slot) if defined?(item_slot) && item_slot != nil
          p41c_set_new_flag(item, item_new) if defined?(item_new) && item_new != nil && respond_to?(:p41c_set_new_flag)
        end
        $scene = scene_before if defined?(scene_before) && scene_before != nil && $scene.object_id != scene_before.object_id
      rescue
      end
    end

    unless method_defined?(:fs_phase45c_prepare_battle_fixture_on_map_base)
      alias fs_phase45c_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      return false unless fs_phase45c_prepare_battle_fixture_on_map_base
      return p45c_probe_cost_boundaries_and_menu
    end
  end
end
end

# TEST-only：trace Scene_Skill 最終 standard payment 與 Angry payment。
if $TEST && defined?(FS_SKILL_COST_ALLFIX) && defined?(FS_TEST_HARNESS)
module FS_SKILL_COST_ALLFIX
  class << self
    unless method_defined?(:fs_phase45c_pay_menu_standard_base)
      alias fs_phase45c_pay_menu_standard_base pay_menu_standard_costs
    end
    def pay_menu_standard_costs(actor, skill)
      scoped = FS_TEST_HARNESS.p45c_menu_scope?(actor, skill)
      before = scoped ? FS_TEST_HARNESS.p45c_menu_resource_snapshot(actor) : nil
      result = fs_phase45c_pay_menu_standard_base(actor, skill)
      if scoped
        after = FS_TEST_HARNESS.p45c_menu_resource_snapshot(actor)
        FS_TEST_HARNESS.p45c_record_menu_standard(before, after)
      end
      return result
    end

    unless method_defined?(:fs_phase45c_lose_angry_base)
      alias fs_phase45c_lose_angry_base lose_angry
    end
    def lose_angry(actor, amount)
      scoped = FS_TEST_HARNESS.p45c_menu_actor_scope?(actor)
      before = scoped ? FS_SKILL_COST_ALLFIX.angry_value(actor).to_i : nil
      result = fs_phase45c_lose_angry_base(actor, amount)
      if scoped
        after = FS_SKILL_COST_ALLFIX.angry_value(actor).to_i
        FS_TEST_HARNESS.p45c_record_menu_angry(amount, before, after)
      end
      return result
    end
  end
end
end

# TEST-only：trace KGC Scene_Skill#consume_od_gauge，必須 calc_od_cost=0 且前後不變。
if $TEST && defined?(Scene_Skill) && defined?(FS_TEST_HARNESS)
class Scene_Skill < Scene_Base
  if method_defined?(:consume_od_gauge) && !method_defined?(:fs_phase45c_menu_consume_od_base)
    alias fs_phase45c_menu_consume_od_base consume_od_gauge
    def consume_od_gauge(*args)
      actor = @actor
      skill = @skill
      scoped = FS_TEST_HARNESS.p45c_menu_scope?(actor, skill)
      before = scoped && actor.respond_to?(:overdrive) ? actor.overdrive.to_i : nil
      calc = scoped && actor.respond_to?(:calc_od_cost) ? (actor.calc_od_cost(skill) rescue nil) : nil
      result = fs_phase45c_menu_consume_od_base(*args)
      if scoped
        after = actor.respond_to?(:overdrive) ? actor.overdrive.to_i : nil
        FS_TEST_HARNESS.p45c_record_menu_od(before, after, calc)
      end
      return result
    end
  end
end
end
#==============================================================================
# ■ Phase45D TEST-only｜KGC Steal MP Payment Ownership Diagnostic
#------------------------------------------------------------------------------
# 【目的】Phase45C 已實機封版 fixed/percent/Half/clamp/Menu 與一般 Battle exact-once。
#         本階段專測 KGC Steal 特殊分支：KGC execute_action_steal 會自行支付 MP，
#         FS_SkillCost_Authority 外層因此必須辨識 steal skill 並跳過第二次 MP 扣除。
# 【機制】以已知完整 runtime shape 的 Skill100 深複製建立 synthetic <steal> Skill，
#         同時配置 HP12 / MP15 / Gold30 / Variable7 / Item5 / Angry11。
#         真正加入 Core Battle Action Plan，完整走 Scene_Battle#execute_action_skill。
#         TEST trace 分別觀察：
#           1. Scene_Battle#execute_action_steal：只能支付 MP15；
#           2. pay_battle_legacy_costs：只能支付 HP/Gold/Variable/Item；
#           3. FS_SKILL_COST_ALLFIX.lose_angry：只能支付 Angry11；
#           4. 最外層 execute_action_skill：六資源總差額必須各自 exact-once。
# 【Steal 隔離】為避免真的偷到 Gold/Item 反向污染成本差額，只暫時把本次 battle-local
#         target 的 @steal_objects 換成空 Array；保留原 object / bytes / @stolen_object，
#         Fixture 完成立即恢復並驗證 exact restore。不修改 RPG::Enemy database。
# 【依賴／順序】位於既有 Phase45B/C TEST 後；Formal page280 KGC Steal、page302 timing bridge、
#         page411 FS_SkillCost_Authority 全部保持 byte-exact。
# 【清理】synthetic Skill database slot、raw learned ownership、target steal runtime、Party/Actor
#         resources 均由 Fixture immediate cleanup + 既有 Battle Snapshot 雙層保護。
# 【Formal Runtime】0 修改。所有 alias / instrumentation 僅存在 $TEST page480。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    P45D_SKILL_SLOT = 1 unless const_defined?(:P45D_SKILL_SLOT)

    def p45d_steal_fixture?
      fixture = @core_current_fixture
      return fixture != nil && fixture[:p45d_steal_cost] == true
    rescue
      return false
    end

    def p45d_scope?(battler, skill = nil)
      return false unless p45d_steal_fixture?
      subject = core_current_subject rescue nil
      return false if battler == nil || subject == nil
      return false unless battler.object_id == subject.object_id
      if skill != nil
        return false if @p45d_skill_id == nil
        return false unless skill.id.to_i == @p45d_skill_id.to_i
      end
      return true
    rescue
      return false
    end

    def p45d_var_id
      return nil unless defined?(Skill_Costs)
      return Skill_Costs::Variabile.to_i
    rescue
      return nil
    end

    def p45d_resource_snapshot(battler)
      item = (@p45d_item_id != nil && $data_items != nil) ? ($data_items[@p45d_item_id] rescue nil) : nil
      var_id = p45d_var_id
      return {
        :hp=>(battler != nil && battler.respond_to?(:hp) ? battler.hp.to_i : nil),
        :mp=>(battler != nil && battler.respond_to?(:mp) ? battler.mp.to_i : nil),
        :gold=>($game_party != nil ? $game_party.gold.to_i : nil),
        :var=>(var_id != nil && $game_variables != nil ? $game_variables[var_id].to_i : nil),
        :item=>(item != nil && $game_party != nil ? $game_party.item_number(item).to_i : nil),
        :angry=>(battler != nil && battler.respond_to?(:overdrive) ? battler.overdrive.to_i : nil)
      }
    rescue
      return {}
    end

    def p45d_make_steal_skill(slot_id, item_id)
      return nil if $data_skills == nil
      base = $data_skills[100] rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.instance_variable_set(:@id, slot_id.to_i)
      skill.name = "Phase45D Steal Cost"
      skill.occasion = 1 if skill.respond_to?(:occasion=)
      skill.scope = 1 if skill.respond_to?(:scope=)
      skill.note = "# FS_PHASE45D_STEAL_COST_ONLY\n" +
                   "<steal>\n" +
                   "<costo hp:12>\n" +
                   "<costo mp:15>\n" +
                   "<costo oro:30>\n" +
                   "<costo var:7>\n" +
                   "<usa oggetto:#{item_id}>\n" +
                   "<costo angry:11>"
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      # KGC Steal cache 必須由本次純 Note 重新解析，不沿用 base Skill 的 cache。
      skill.instance_variable_set(:@__steal, nil)
      steal_parsed = skill.respond_to?(:steal?) ? (skill.steal? rescue false) : false
      # 隔離 KGC OverDrive / cooldown；保留 Skill100 已實機證明的 damage runtime shape。
      skill.instance_variable_set(:@__od_cost, 0)
      skill.instance_variable_set(:@__od_gain_rate, 0)
      skill.instance_variable_set(:@__is_overdrive, false)
      skill.instance_variable_set(:@turn_delay, 0)
      skill.instance_variable_set(:@battle_delay, 0)
      skill.instance_variable_set(:@step_delay, 0)
      return nil unless steal_parsed == true
      return skill
    rescue
      return nil
    end

    def p45d_install_skill(subject)
      return false if subject == nil || $data_skills == nil
      return true if @p45d_slot_snapshot != nil
      slot_id = P45D_SKILL_SLOT
      original = $data_skills[slot_id] rescue nil
      return false if original == nil
      item_id = 5
      item = $data_items[item_id] rescue nil
      return false if item == nil
      skill = p45d_make_steal_skill(slot_id, item_id)
      return false if skill == nil

      @p45d_slot_snapshot = {
        :slot=>slot_id, :object=>original, :object_id=>original.object_id,
        :bytes=>(Marshal.dump(original) rescue nil), :array_oid=>$data_skills.object_id
      }
      @p45d_skill_id = slot_id
      @p45d_item_id = item_id
      raw = subject.instance_variable_get(:@skills) rescue nil
      @p45d_raw_learned_before = (raw != nil && raw.include?(slot_id))
      $data_skills[slot_id] = skill
      subject.learn_skill(slot_id) unless @p45d_raw_learned_before

      costs = {
        :hp=>subject.calc_hp_cost(skill), :mp=>subject.calc_mp_cost(skill),
        :gold=>subject.calc_gold_cost(skill), :var=>subject.calc_var_cost(skill),
        :item=>subject.calc_item_cost(skill), :angry=>subject.calc_angry_cost(skill)
      }
      @p45d_expected_costs = costs
      steal_ok = defined?(FS_SKILL_COST_ALLFIX) && FS_SKILL_COST_ALLFIX.steal_skill?(skill) == true
      exact = costs == {:hp=>12, :mp=>15, :gold=>30, :var=>7, :item=>item_id, :angry=>11}
      note_clean = (skill.note.to_s =~ /<joey_resonance_pull\s+/i) == nil
      assert("Phase45D synthetic Skill is formally recognized as KGC Steal", steal_ok,
             "skill=#{slot_id} note=#{skill.note.inspect}")
      assert("Phase45D Steal Skill exact configured costs", exact,
             "costs=#{costs.inspect}")
      assert("Phase45D Steal Skill strips unrelated inherited character Notetags", note_clean,
             "note=#{skill.note.inspect}")
      return steal_ok && exact && note_clean
    rescue Exception => e
      exception(e, "p45d_install_skill")
      return false
    end

    def p45d_restore_skill_slot
      snap = @p45d_slot_snapshot
      return true if snap == nil
      ok = false
      begin
        slot = snap[:slot].to_i
        subject = core_current_subject rescue nil
        if subject != nil && @p45d_raw_learned_before == false
          raw = subject.instance_variable_get(:@skills) rescue nil
          subject.forget_skill(slot) if raw != nil && raw.include?(slot)
        end
        $data_skills[slot] = snap[:object] if $data_skills != nil
        current = $data_skills[slot] rescue nil
        bytes = Marshal.dump(current) rescue nil
        ok = current != nil && current.object_id == snap[:object_id] &&
             (snap[:bytes] == nil || bytes == snap[:bytes]) &&
             $data_skills.object_id == snap[:array_oid]
      rescue
        ok = false
      end
      @p45d_slot_snapshot = nil
      @p45d_skill_id = nil
      @p45d_item_id = nil
      @p45d_raw_learned_before = nil
      return ok
    end

    def p45d_isolate_target_steal(target)
      return false if target == nil
      begin
        original = target.instance_variable_get(:@steal_objects)
        return false unless original.is_a?(Array)
        @p45d_target_snapshot = {
          :target=>target, :target_oid=>target.object_id,
          :steal_object=>original, :steal_oid=>original.object_id,
          :steal_bytes=>(Marshal.dump(original) rescue nil),
          :stolen_object=>(target.instance_variable_get(:@stolen_object) rescue nil)
        }
        target.instance_variable_set(:@steal_objects, [])
        target.instance_variable_set(:@stolen_object, nil)
        empty = target.instance_variable_get(:@steal_objects)
        assert("Phase45D battle-local Steal reward source isolated", empty.is_a?(Array) && empty.empty?,
               "target=#{object_label(target)}")
        return empty.is_a?(Array) && empty.empty?
      rescue Exception => e
        exception(e, "p45d_isolate_target_steal")
        return false
      end
    end

    def p45d_restore_target_steal
      snap = @p45d_target_snapshot
      return true if snap == nil
      ok = false
      begin
        target = snap[:target]
        if target != nil
          target.instance_variable_set(:@steal_objects, snap[:steal_object])
          target.instance_variable_set(:@stolen_object, snap[:stolen_object])
          current = target.instance_variable_get(:@steal_objects)
          bytes = Marshal.dump(current) rescue nil
          ok = target.object_id == snap[:target_oid] &&
               current.object_id == snap[:steal_oid] &&
               (snap[:steal_bytes] == nil || bytes == snap[:steal_bytes]) &&
               (target.instance_variable_get(:@stolen_object) rescue nil) == snap[:stolen_object]
        end
      rescue
        ok = false
      end
      @p45d_target_snapshot = nil
      return ok
    end

    def p45d_prepare_resources(subject)
      return false if subject == nil || @p45d_item_id == nil
      item = $data_items[@p45d_item_id] rescue nil
      var_id = p45d_var_id
      return false if item == nil || var_id == nil || $game_variables == nil
      subject.hp = subject.maxhp
      subject.mp = subject.maxmp
      subject.overdrive = 100 if subject.respond_to?(:overdrive=)
      p45a_set_party_gold_exact(1000)
      $game_variables[var_id] = 100
      p45a_set_party_item_count(item, 2)
      @p45d_legacy_traces = []
      @p45d_angry_traces = []
      @p45d_steal_traces = []
      @p45d_execute_trace = nil
      @p45d_resource_before = p45d_resource_snapshot(subject)
      skill = $data_skills[@p45d_skill_id] rescue nil
      usable = skill != nil && subject.skill_can_use?(skill)
      assert("Phase45D Steal Skill usable before formal Battle action", usable,
             "resources=#{@p45d_resource_before.inspect}")
      return usable
    rescue Exception => e
      exception(e, "p45d_prepare_resources")
      return false
    end

    def p45d_record_legacy(battler, skill, before, after)
      return unless p45d_scope?(battler, skill)
      @p45d_legacy_traces ||= []
      @p45d_legacy_traces << {:before=>before, :after=>after}
    rescue
    end

    def p45d_record_angry(battler, amount, before, after)
      return unless p45d_scope?(battler, nil)
      @p45d_angry_traces ||= []
      @p45d_angry_traces << {:amount=>amount.to_i, :before=>before.to_i, :after=>after.to_i}
    rescue
    end

    def p45d_record_steal(battler, skill, before, after)
      return unless p45d_scope?(battler, skill)
      @p45d_steal_traces ||= []
      @p45d_steal_traces << {:before=>before, :after=>after}
    rescue
    end

    def p45d_record_execute(battler, skill, before, after)
      return unless p45d_scope?(battler, skill)
      @p45d_execute_trace = {:before=>before, :after=>after}
    rescue
    end

    unless method_defined?(:fs_phase45d_core_build_fixture_plan_base)
      alias fs_phase45d_core_build_fixture_plan_base core_build_fixture_plan
    end
    def core_build_fixture_plan
      plan = fs_phase45d_core_build_fixture_plan_base
      return plan if plan == nil
      return plan if plan.any? { |f| f.is_a?(Hash) && f[:p45d_steal_cost] }
      enemies = $game_troop.members.select { |e| e != nil && e.exist? }
      target = enemies.sort_by { |e| -(e.maxhp.to_i rescue 0) }[0]
      if target != nil
        plan << {
          :name=>"PHASE45D_STEAL_MP_OWNERSHIP", :kind=>:skill,
          :skill_id=>P45D_SKILL_SLOT, :boost_hp=>true,
          :p45d_steal_cost=>true,
          :target_index=>target.index, :target_oid=>target.object_id
        }
      end
      @core_fixture_plan = plan
      log("[FIXTURE] PHASE45D action-plan=#{plan.collect { |f| f[:name] }.inspect}")
      return plan
    end

    unless method_defined?(:fs_phase45d_core_prepare_action_state_base)
      alias fs_phase45d_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45d_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:p45d_steal_cost]
        installed = p45d_install_skill(subject)
        assert("Phase45D synthetic Steal Skill database slot installed", installed,
               "slot=#{P45D_SKILL_SLOT}")
        isolated = installed && p45d_isolate_target_steal(target)
        prepared = isolated && p45d_prepare_resources(subject)
        assert("Phase45D Steal payment resources prepared", prepared,
               "resources=#{@p45d_resource_before.inspect}")
      end
      return result
    end

    unless method_defined?(:fs_phase45d_core_finalize_fixture_base)
      alias fs_phase45d_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45d_core_finalize_fixture_base
      if fixture != nil && fixture[:p45d_steal_cost]
        execute = @p45d_execute_trace
        steal = @p45d_steal_traces || []
        legacy = @p45d_legacy_traces || []
        angry = @p45d_angry_traces || []
        costs = @p45d_expected_costs || {}
        before = execute == nil ? {} : execute[:before]
        after = execute == nil ? {} : execute[:after]
        deltas = {}
        [:hp, :mp, :gold, :var, :item, :angry].each do |key|
          deltas[key] = (before[key] != nil && after[key] != nil) ? before[key].to_i - after[key].to_i : nil
        end

        total_ok = deltas[:hp] == 12 && deltas[:mp] == 15 && deltas[:gold] == 30 &&
                   deltas[:var] == 7 && deltas[:item] == 1 && deltas[:angry] == 11
        assert("Phase45D real Steal action pays all configured resources exact-once", total_ok,
               "before=#{before.inspect} after=#{after.inspect} deltas=#{deltas.inspect}")

        steal_ok = steal.size == 1
        if steal_ok
          sb = steal[0][:before]
          sa = steal[0][:after]
          steal_ok = sb[:mp].to_i - sa[:mp].to_i == 15 &&
                     sb[:hp].to_i - sa[:hp].to_i == 0 &&
                     sb[:gold].to_i - sa[:gold].to_i == 0 &&
                     sb[:var].to_i - sa[:var].to_i == 0 &&
                     sb[:item].to_i - sa[:item].to_i == 0 &&
                     sb[:angry].to_i - sa[:angry].to_i == 0
        end
        assert("Phase45D KGC execute_action_steal owns MP payment exactly once", steal_ok,
               "traces=#{steal.inspect}")

        legacy_ok = legacy.size == 1
        if legacy_ok
          lb = legacy[0][:before]
          la = legacy[0][:after]
          legacy_ok = lb[:hp].to_i - la[:hp].to_i == 12 &&
                      lb[:mp].to_i - la[:mp].to_i == 0 &&
                      lb[:gold].to_i - la[:gold].to_i == 30 &&
                      lb[:var].to_i - la[:var].to_i == 7 &&
                      lb[:item].to_i - la[:item].to_i == 1 &&
                      lb[:angry].to_i - la[:angry].to_i == 0
        end
        assert("Phase45D legacy bridge leaves Steal MP alone and owns HP/Gold/Var/Item", legacy_ok,
               "traces=#{legacy.inspect}")

        angry_ok = angry.size == 1 && angry[0][:amount].to_i == 11 &&
                   angry[0][:before].to_i - angry[0][:after].to_i == 11
        assert("Phase45D Final Authority owns Steal Angry payment exactly once", angry_ok,
               "traces=#{angry.inspect}")

        no_double_mp = total_ok && steal_ok && deltas[:mp] == costs[:mp].to_i
        assert("Phase45D Final Authority skips duplicate MP after KGC Steal payment", no_double_mp,
               "calc=#{costs[:mp].inspect} total_mp_delta=#{deltas[:mp].inspect} steal=#{steal.inspect}")

        target_ok = p45d_restore_target_steal
        assert("Phase45D battle-local Steal target runtime restored exactly", target_ok)
        slot_ok = p45d_restore_skill_slot
        assert("Phase45D synthetic Steal Skill database slot restored exactly", slot_ok,
               "slot=#{P45D_SKILL_SLOT}")

        ready = total_ok && steal_ok && legacy_ok && angry_ok && no_double_mp && target_ok && slot_ok
        log("[SKILL_COST_STEAL_OWNERSHIP] costs=#{costs.inspect} deltas=#{deltas.inspect} " +
            "steal_calls=#{steal.size} legacy_calls=#{legacy.size} angry_calls=#{angry.size} " +
            "target_restored=#{target_ok} slot_restored=#{slot_ok} ready=#{ready}")
        assert("Phase45D KGC Steal MP ownership diagnostic completed", ready,
               "deltas=#{deltas.inspect} steal=#{steal.size} legacy=#{legacy.size} angry=#{angry.size}")
      end
      return result
    rescue Exception => e
      exception(e, "p45d_core_finalize_current_fixture")
      p45d_restore_target_steal rescue nil
      p45d_restore_skill_slot rescue nil
      assert("Phase45D KGC Steal MP ownership diagnostic completed", false, e.message)
      return result
    end

    unless method_defined?(:fs_phase45d_restore_pending_base)
      alias fs_phase45d_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45d_restore_pending_base
      if result
        if @p45d_target_snapshot != nil
          restored_target = p45d_restore_target_steal
          assert("Phase45D emergency Steal target cleanup after Snapshot restore", restored_target)
        end
        if @p45d_slot_snapshot != nil
          restored_slot = p45d_restore_skill_slot
          assert("Phase45D emergency Steal Skill slot cleanup after Snapshot restore", restored_slot,
                 "slot=#{P45D_SKILL_SLOT}")
        end
      end
      return result
    end
  end
end

# TEST-only：Phase45D legacy / Angry payment ownership trace。
if defined?(FS_SKILL_COST_ALLFIX)
module FS_SKILL_COST_ALLFIX
  class << self
    unless method_defined?(:fs_phase45d_pay_battle_legacy_base)
      alias fs_phase45d_pay_battle_legacy_base pay_battle_legacy_costs
    end
    def pay_battle_legacy_costs(battler, skill)
      scoped = FS_TEST_HARNESS.p45d_scope?(battler, skill)
      before = scoped ? FS_TEST_HARNESS.p45d_resource_snapshot(battler) : nil
      result = fs_phase45d_pay_battle_legacy_base(battler, skill)
      if scoped
        after = FS_TEST_HARNESS.p45d_resource_snapshot(battler)
        FS_TEST_HARNESS.p45d_record_legacy(battler, skill, before, after)
      end
      return result
    end

    unless method_defined?(:fs_phase45d_lose_angry_base)
      alias fs_phase45d_lose_angry_base lose_angry
    end
    def lose_angry(battler, amount)
      scoped = FS_TEST_HARNESS.p45d_scope?(battler, nil)
      before = scoped ? FS_SKILL_COST_ALLFIX.angry_value(battler).to_i : nil
      result = fs_phase45d_lose_angry_base(battler, amount)
      if scoped
        after = FS_SKILL_COST_ALLFIX.angry_value(battler).to_i
        FS_TEST_HARNESS.p45d_record_angry(battler, amount, before, after)
      end
      return result
    end
  end
end
end

# TEST-only：直接包住 KGC Steal 的 execute_action_steal，證明 MP 由此路徑支付。
if defined?(Scene_Battle)
class Scene_Battle < Scene_Base
  if method_defined?(:execute_action_steal) && !method_defined?(:fs_phase45d_execute_action_steal_base)
    alias fs_phase45d_execute_action_steal_base execute_action_steal
    def execute_action_steal(*args)
      battler = @active_battler
      skill = nil
      begin
        skill = battler.action.skill if battler != nil && battler.action != nil
      rescue
        skill = nil
      end
      scoped = FS_TEST_HARNESS.p45d_scope?(battler, skill)
      before = scoped ? FS_TEST_HARNESS.p45d_resource_snapshot(battler) : nil
      result = fs_phase45d_execute_action_steal_base(*args)
      if scoped
        after = FS_TEST_HARNESS.p45d_resource_snapshot(battler)
        FS_TEST_HARNESS.p45d_record_steal(battler, skill, before, after)
        FS_TEST_HARNESS.log("[SKILL_COST_STEAL_INNER] before=#{before.inspect} after=#{after.inspect}")
      end
      return result
    end
  end

  unless method_defined?(:fs_phase45d_execute_action_skill_base)
    alias fs_phase45d_execute_action_skill_base execute_action_skill
  end
  def execute_action_skill(*args)
    battler = @active_battler
    skill = nil
    begin
      skill = battler.action.skill if battler != nil && battler.action != nil
    rescue
      skill = nil
    end
    scoped = FS_TEST_HARNESS.p45d_scope?(battler, skill)
    before = scoped ? FS_TEST_HARNESS.p45d_resource_snapshot(battler) : nil
    result = fs_phase45d_execute_action_skill_base(*args)
    if scoped
      after = FS_TEST_HARNESS.p45d_resource_snapshot(battler)
      FS_TEST_HARNESS.p45d_record_execute(battler, skill, before, after)
    end
    return result
  end
end
end
end

#==============================================================================
# 【Phase45E｜Skill Effect Staged-chain Provenance Diagnostic｜TEST-only】
#------------------------------------------------------------------------------
# 【用途】在既有 Skill100 真實 Battle Fixture 上，記錄 Game_Battler#skill_effect
#         從 late-bound AutoSetup 外層一路到 VX Base 的實際 runtime 進入／返回順序。
# 【機制】不修改任何 Formal page；只在 Scene_Map prebattle 安裝透明 wrapper。
#         page479 Combat RNG 明確標記為 TEST-only layer，Formal projection 會排除它。
# 【依賴】既有 Phase45D / Core Battle Fixture、Skill100、AutoSetup late runtime patch。
# 【資產】無。
# 【授權】TEST harness 擴充；原作者／原授權資訊均保留於各 Formal script。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45E_SKILL_ID = 100 unless const_defined?(:P45E_SKILL_ID)

  class << self
    def p45e_runtime_outer_to_base
      [
        :autoset,
        :combat_rng,
        :pokemon_followup,
        :support_state,
        :steal_result,
        :soulmark,
        :field_weather,
        :ivy_clone,
        :state_effects,
        :actor_profile,
        :antagonist,
        :mechanic_expansion,
        :character_mechanic,
        :combo_core,
        :cover,
        :field_effect,
        :kgc_steal,
        :bestiary_scan,
        :enemy_level,
        :kgc_overdrive,
        :sideview,
        :vx_base
      ]
    end

    def p45e_formal_outer_to_base
      p45e_runtime_outer_to_base.reject { |x| x == :combat_rng }
    end

    def p45e_probe_specs
      [
        [:skill_effect,                    :autoset],
        [:fs_db_autoset_skill_effect,      :combat_rng],
        [:fs_phase36_skill_effect_combat_rng, :pokemon_followup],
        [:fs_pfi_old_skill_effect,         :support_state],
        [:fs_ssr_old_skill_effect,         :steal_result],
        [:fs_tankentai_steal_old_skill_effect, :soulmark],
        [:fs_smre_skill_effect,            :field_weather],
        [:fs_field_weather_skill_effect,   :ivy_clone],
        [:albert_ic_old_skill_effect,      :state_effects],
        [:albert_sev2_skill_effect,        :actor_profile],
        [:albert_profile_old_skill_effect, :antagonist],
        [:albert_ant_old_skill_effect,     :mechanic_expansion],
        [:albert_mx_old_skill_effect,      :character_mechanic],
        [:albert_cc_old_skill_effect,      :combo_core],
        [:albert_combo_old_skill_effect,   :cover],
        [:cover_skill_effect,              :field_effect],
        [:skill_effect_sss_field_effects,  :kgc_steal],
        [:skill_effect_KGC_Steal,          :bestiary_scan],
        [:skill_effect_dse,                :enemy_level],
        [:skill_effect_elc,                :kgc_overdrive],
        [:skill_effect_KGC_OverDrive,      :sideview],
        [:skill_effect_n01,                :vx_base]
      ]
    end

    def p45e_probe_base_name(method_name)
      ("fs_p45e_probe_base_" + method_name.to_s).to_sym
    end

    def p45e_install_one(method_name, layer_name)
      base_name = p45e_probe_base_name(method_name)
      return true if Game_Battler.method_defined?(base_name)
      return false unless Game_Battler.method_defined?(method_name)
      Game_Battler.class_eval do
        alias_method base_name, method_name
        define_method(method_name) do |user, skill|
          scoped = FS_TEST_HARNESS.p45e_scope?(self, user, skill)
          FS_TEST_HARNESS.p45e_record_enter(layer_name, self, user, skill) if scoped
          result = nil
          begin
            result = send(base_name, user, skill)
          ensure
            FS_TEST_HARNESS.p45e_record_exit(layer_name, self, user, skill) if scoped
          end
          result
        end
      end
      true
    rescue Exception => e
      exception(e, "p45e_install_one:#{method_name}")
      false
    end

    def p45e_install_probes
      return @p45e_probe_install_ready if @p45e_probe_install_done
      @p45e_probe_install_done = true
      missing = []
      failed = []
      p45e_probe_specs.each do |spec|
        method_name = spec[0]
        layer_name = spec[1]
        unless Game_Battler.method_defined?(method_name)
          missing << method_name
          next
        end
        failed << method_name unless p45e_install_one(method_name, layer_name)
      end
      @p45e_probe_missing = missing
      @p45e_probe_failed = failed
      @p45e_probe_install_ready = missing.empty? && failed.empty?
      log("[SKILL_EFFECT_PROBE_INSTALL] specs=#{p45e_probe_specs.size} missing=#{missing.inspect} failed=#{failed.inspect} ready=#{@p45e_probe_install_ready}")
      assert("Phase45E Skill Effect provenance probes install on every expected runtime layer",
             @p45e_probe_install_ready,
             "missing=#{missing.inspect} failed=#{failed.inspect}")
      @p45e_probe_install_ready
    end

    def p45e_scope?(target, user, skill)
      return false unless @p45e_capture_active
      return false if target == nil || user == nil || skill == nil
      return false unless skill.id.to_i == P45E_SKILL_ID
      return false unless @p45e_target_oid.to_i == target.object_id.to_i
      return false unless @p45e_user_oid.to_i == user.object_id.to_i
      true
    rescue
      false
    end

    def p45e_result_snapshot(target)
      {
        :hp_damage=>(target.instance_variable_get(:@hp_damage) rescue nil),
        :mp_damage=>(target.instance_variable_get(:@mp_damage) rescue nil),
        :missed=>(target.instance_variable_get(:@missed) rescue nil),
        :evaded=>(target.instance_variable_get(:@evaded) rescue nil),
        :skipped=>(target.instance_variable_get(:@skipped) rescue nil),
        :states=>(target.states.collect { |s| s.id } rescue [])
      }
    end

    def p45e_record_enter(layer_name, target, user, skill)
      @p45e_entries ||= []
      @p45e_events ||= []
      @p45e_entries << layer_name
      @p45e_events << [:enter, layer_name, p45e_result_snapshot(target)]
    rescue
    end

    def p45e_record_exit(layer_name, target, user, skill)
      @p45e_exits ||= []
      @p45e_events ||= []
      @p45e_exits << layer_name
      @p45e_events << [:exit, layer_name, p45e_result_snapshot(target)]
    rescue
    end

    def p45e_begin_capture(subject, target)
      @p45e_entries = []
      @p45e_exits = []
      @p45e_events = []
      @p45e_user_oid = subject.object_id
      @p45e_target_oid = target.object_id
      @p45e_capture_active = true
      log("[SKILL_EFFECT_CAPTURE] begin skill=#{P45E_SKILL_ID} user_oid=#{@p45e_user_oid} target_oid=#{@p45e_target_oid}")
      true
    rescue Exception => e
      exception(e, "p45e_begin_capture")
      false
    end

    def p45e_end_capture
      @p45e_capture_active = false
      true
    end

    unless method_defined?(:fs_phase45e_prepare_battle_fixture_on_map_base)
      alias fs_phase45e_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      install_ok = p45e_install_probes
      result = fs_phase45e_prepare_battle_fixture_on_map_base
      assert("Phase45E Skill Effect provenance infrastructure ready before battle",
             install_ok,
             "missing=#{@p45e_probe_missing.inspect} failed=#{@p45e_probe_failed.inspect}")
      result
    end

    unless method_defined?(:fs_phase45e_core_prepare_action_state_base)
      alias fs_phase45e_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45e_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
        ok = p45e_begin_capture(subject, target)
        assert("Phase45E Skill100 real Battle provenance capture armed", ok,
               "subject=#{subject} target=#{target}")
      end
      result
    end

    unless method_defined?(:fs_phase45e_core_finalize_fixture_base)
      alias fs_phase45e_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45e_core_finalize_fixture_base
      if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
        p45e_end_capture
        entries = (@p45e_entries || []).clone
        exits = (@p45e_exits || []).clone
        expected_runtime = p45e_runtime_outer_to_base
        expected_exits = expected_runtime.reverse
        formal_projection = entries.reject { |x| x == :combat_rng }
        expected_formal = p45e_formal_outer_to_base
        runtime_ok = entries == expected_runtime
        exits_ok = exits == expected_exits
        formal_ok = formal_projection == expected_formal
        counts = {}
        entries.each { |x| counts[x] = counts.fetch(x, 0) + 1 }
        count_ok = expected_runtime.all? { |x| counts[x].to_i == 1 } && counts.size == expected_runtime.size

        assert("Phase45E Skill Effect runtime outer-to-base order exact", runtime_ok,
               "expected=#{expected_runtime.inspect} actual=#{entries.inspect}")
        assert("Phase45E Skill Effect return order exact reverse", exits_ok,
               "expected=#{expected_exits.inspect} actual=#{exits.inspect}")
        assert("Phase45E Skill Effect Formal projection excludes only TEST Combat RNG layer", formal_ok,
               "expected=#{expected_formal.inspect} actual=#{formal_projection.inspect}")
        assert("Phase45E every Skill Effect runtime layer executes exactly once", count_ok,
               "counts=#{counts.inspect}")

        base_to_outer = formal_projection.reverse
        expected_base_to_outer = expected_formal.reverse
        ready = runtime_ok && exits_ok && formal_ok && count_ok && base_to_outer == expected_base_to_outer
        log("[SKILL_EFFECT_CHAIN] runtime_outer_to_base=#{entries.inspect} formal_outer_to_base=#{formal_projection.inspect} counts=#{counts.inspect} ready=#{ready}")
        log("[SKILL_EFFECT_CHAIN_BASE_TO_OUTER] formal=#{base_to_outer.inspect} ready=#{ready}")
        assert("Phase45E Skill Effect staged-chain provenance diagnostic completed", ready,
               "base_to_outer=#{base_to_outer.inspect}")
      end
      result
    rescue Exception => e
      p45e_end_capture rescue nil
      exception(e, "p45e_core_finalize_current_fixture")
      assert("Phase45E Skill Effect staged-chain provenance diagnostic completed", false, e.message)
      result
    end
  end
end
end

#==============================================================================
# 【Phase45F｜Skill Effect Semantic Ownership I｜TEST-only】
#------------------------------------------------------------------------------
# 【用途】Phase45E 已證明 21 層 Formal skill_effect staged-chain 的實際順序。
#         本階段不再只看「有沒有經過」，而是用真實 Battle Fixture 鎖定第一批語意 owner：
#           1. Skill101：StateEffects 注入 <state_chance 40:100> → VX Base 真正附加 State40；
#              CharacterMechanic 在內層成功後支付 Joey conditional OD100 並推進 summon ATB +120。
#           2. Skill253：SoulMark post-effect 依實際傷害的 50% 回復使用者 HP。
#           3. synthetic Field Weather：legacy FieldEffect 建立 raw field State153；
#              FieldWeather Authority 建立最終 source ownership。
# 【機制】沿用 Phase45E 已安裝的透明 probes，只擴充 scope 與 snapshot，不再包第二層 skill_effect。
#         因此不改變已驗證 chain shape。Field Skill 使用 Skill slot 1 暫時替換，Fixture 後 exact restore。
# 【隔離】Skill101 的 OD / summon ATB 與 @albert_od_action_start_value 只在該 Fixture 暫時設定並 exact restore；
#         Field state/source 與 synthetic Skill slot 亦在 Fixture 後立即恢復，Battle Snapshot 再做第二層保護。
# 【Formal Runtime】0 修改；所有 Formal Skill Effect / Character / SoulMark / Field pages byte-exact。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45F_FIELD_SKILL_SLOT = 1 unless const_defined?(:P45F_FIELD_SKILL_SLOT)
  P45F_FIELD_STATE_ID = 153 unless const_defined?(:P45F_FIELD_STATE_ID)

  class << self
    #--------------------------------------------------------------------------
    # Phase45E probe reuse：只擴充 scope / recorder，不新增 skill_effect wrapper。
    #--------------------------------------------------------------------------
    def p45f_scope?(target, user, skill)
      return false unless @p45f_capture_active
      return false if target == nil || user == nil || skill == nil
      return false unless skill.id.to_i == @p45f_skill_id.to_i
      return false unless target.object_id.to_i == @p45f_target_oid.to_i
      return false unless user.object_id.to_i == @p45f_user_oid.to_i
      return true
    rescue
      return false
    end

    unless method_defined?(:fs_phase45f_p45e_scope_base)
      alias fs_phase45f_p45e_scope_base p45e_scope?
    end
    def p45e_scope?(target, user, skill)
      return true if p45f_scope?(target, user, skill)
      return fs_phase45f_p45e_scope_base(target, user, skill)
    end

    def p45f_state_ids(battler)
      return [] if battler == nil || !battler.respond_to?(:states)
      return battler.states.compact.collect { |s| s.id.to_i }.uniq.sort
    rescue
      return []
    end

    def p45f_skill_plus_states(skill)
      return [] if skill == nil || !skill.respond_to?(:plus_state_set)
      list = skill.plus_state_set
      return [] if list == nil
      return list.compact.collect { |id| id.to_i }.uniq.sort
    rescue
      return []
    end

    def p45f_field_id
      state = ($game_temp == nil ? nil : $game_temp.field_effect) rescue nil
      return state == nil ? 0 : state.id.to_i
    rescue
      return 0
    end

    def p45f_field_source_oid
      source = ($game_temp == nil ? nil : $game_temp.fs_field_effect_source) rescue nil
      return source == nil ? nil : source.object_id
    rescue
      return nil
    end

    def p45f_snapshot(target, user, skill)
      summon = @p45f_semantic_summon
      return {
        :target_hp=>(target.respond_to?(:hp) ? target.hp.to_i : nil),
        :target_maxhp=>(target.respond_to?(:maxhp) ? target.maxhp.to_i : nil),
        :target_states=>p45f_state_ids(target),
        :hp_damage=>(target.instance_variable_get(:@hp_damage) rescue nil),
        :mp_damage=>(target.instance_variable_get(:@mp_damage) rescue nil),
        :missed=>(target.instance_variable_get(:@missed) rescue nil),
        :evaded=>(target.instance_variable_get(:@evaded) rescue nil),
        :skipped=>(target.instance_variable_get(:@skipped) rescue nil),
        :weak=>(target.instance_variable_get(:@weak) rescue nil),
        :strong=>(target.instance_variable_get(:@strong) rescue nil),
        :state_add_failed=>(target.instance_variable_get(:@fs_ssr_state_add_failed) rescue nil),
        :user_hp=>(user.respond_to?(:hp) ? user.hp.to_i : nil),
        :user_maxhp=>(user.respond_to?(:maxhp) ? user.maxhp.to_i : nil),
        :user_od=>(user.respond_to?(:overdrive) ? user.overdrive.to_i : nil),
        :skill_plus_states=>p45f_skill_plus_states(skill),
        :skill_physical=>(skill.respond_to?(:physical_attack) ? (skill.physical_attack ? true : false) : nil),
        :field_id=>p45f_field_id,
        :field_source_oid=>p45f_field_source_oid,
        :summon_atb=>(summon != nil && summon.respond_to?(:at_count) ? summon.at_count.to_i : nil)
      }
    rescue
      return {}
    end

    def p45f_record(phase, layer_name, target, user, skill)
      @p45f_events ||= []
      @p45f_events << [phase, layer_name, p45f_snapshot(target, user, skill)]
    rescue
    end

    unless method_defined?(:fs_phase45f_p45e_record_enter_base)
      alias fs_phase45f_p45e_record_enter_base p45e_record_enter
    end
    def p45e_record_enter(layer_name, target, user, skill)
      if p45f_scope?(target, user, skill)
        p45f_record(:enter, layer_name, target, user, skill)
      else
        fs_phase45f_p45e_record_enter_base(layer_name, target, user, skill)
      end
    end

    unless method_defined?(:fs_phase45f_p45e_record_exit_base)
      alias fs_phase45f_p45e_record_exit_base p45e_record_exit
    end
    def p45e_record_exit(layer_name, target, user, skill)
      if p45f_scope?(target, user, skill)
        p45f_record(:exit, layer_name, target, user, skill)
      else
        fs_phase45f_p45e_record_exit_base(layer_name, target, user, skill)
      end
    end

    def p45f_begin_capture(label, subject, target, skill_id, summon = nil)
      @p45f_label = label
      @p45f_events = []
      @p45f_skill_id = skill_id.to_i
      @p45f_user_oid = subject.object_id
      @p45f_target_oid = target.object_id
      @p45f_semantic_summon = summon
      @p45f_capture_active = true
      log("[SKILL_EFFECT_SEMANTIC_CAPTURE] begin case=#{label} skill=#{skill_id} user_oid=#{@p45f_user_oid} target_oid=#{@p45f_target_oid}")
      return true
    rescue Exception => e
      exception(e, "p45f_begin_capture")
      return false
    end

    def p45f_end_capture
      @p45f_capture_active = false
      return true
    end

    def p45f_event_snapshot(phase, layer_name)
      events = @p45f_events || []
      entry = events.find { |e| e[0] == phase && e[1] == layer_name }
      return entry == nil ? nil : entry[2]
    rescue
      return nil
    end

    def p45f_semantic_summon
      return nil if $game_party == nil
      for member in $game_party.members.compact
        begin
          return member if member.respond_to?(:albert_summon?) && member.albert_summon? && member.exist?
        rescue
        end
      end
      return nil
    end

    #--------------------------------------------------------------------------
    # Skill101：準備 Joey conditional-OD / summon ATB，Fixture 後 exact restore。
    #--------------------------------------------------------------------------
    def p45f_prepare_skill101_character(subject)
      summon = p45f_semantic_summon
      return false if subject == nil || summon == nil
      @p45f_char_snapshot = {
        :subject=>subject,
        :subject_oid=>subject.object_id,
        :od=>(subject.respond_to?(:overdrive) ? subject.overdrive.to_i : nil),
        :action_start_defined=>p42l_instance_variable_defined_compat?(subject, "@albert_od_action_start_value"),
        :action_start_value=>(subject.instance_variable_get(:@albert_od_action_start_value) rescue nil),
        :summon=>summon,
        :summon_oid=>summon.object_id,
        :summon_atb=>(summon.respond_to?(:at_count) ? summon.at_count.to_i : nil)
      }
      subject.overdrive = 100 if subject.respond_to?(:overdrive=)
      summon.instance_variable_set(:@at_count, 200)
      prepared = subject.respond_to?(:overdrive) && subject.overdrive.to_i == 100 &&
                 summon.respond_to?(:at_count) && summon.at_count.to_i == 200
      assert("Phase45F Skill101 Character semantic resources prepared", prepared,
             "od=#{subject.respond_to?(:overdrive) ? subject.overdrive : nil} summon_atb=#{summon.respond_to?(:at_count) ? summon.at_count : nil}")
      return prepared
    rescue Exception => e
      exception(e, "p45f_prepare_skill101_character")
      return false
    end

    def p45f_restore_skill101_character
      snap = @p45f_char_snapshot
      return true if snap == nil
      ok = false
      begin
        subject = snap[:subject]
        summon = snap[:summon]
        if subject != nil && subject.object_id == snap[:subject_oid]
          subject.overdrive = snap[:od].to_i if snap[:od] != nil && subject.respond_to?(:overdrive=)
          if snap[:action_start_defined]
            subject.instance_variable_set(:@albert_od_action_start_value, snap[:action_start_value])
          else
            if p42l_instance_variable_defined_compat?(subject, "@albert_od_action_start_value")
              subject.send(:remove_instance_variable, :@albert_od_action_start_value) rescue nil
            end
          end
        end
        if summon != nil && summon.object_id == snap[:summon_oid] && snap[:summon_atb] != nil
          summon.instance_variable_set(:@at_count, snap[:summon_atb].to_i)
        end
        subject_ok = subject != nil && subject.object_id == snap[:subject_oid] &&
                     (snap[:od] == nil || !subject.respond_to?(:overdrive) || subject.overdrive.to_i == snap[:od].to_i)
        summon_ok = summon != nil && summon.object_id == snap[:summon_oid] &&
                    (snap[:summon_atb] == nil || !summon.respond_to?(:at_count) || summon.at_count.to_i == snap[:summon_atb].to_i)
        action_ok = false
        if subject != nil
          if snap[:action_start_defined]
            action_ok = p42l_instance_variable_defined_compat?(subject, "@albert_od_action_start_value") &&
                        subject.instance_variable_get(:@albert_od_action_start_value) == snap[:action_start_value]
          else
            action_ok = !p42l_instance_variable_defined_compat?(subject, "@albert_od_action_start_value")
          end
        end
        ok = subject_ok && summon_ok && action_ok
      rescue
        ok = false
      end
      @p45f_char_snapshot = nil
      @p45f_semantic_summon = nil
      return ok
    end

    #--------------------------------------------------------------------------
    # synthetic Field Weather Skill：只保留最小正傷害 + <field effect:153>。
    #--------------------------------------------------------------------------
    def p45f_make_field_skill(slot_id)
      return nil if $data_skills == nil
      base = $data_skills[100] rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.instance_variable_set(:@id, slot_id.to_i)
      skill.instance_variable_set(:@name, "Phase45F Field Ownership")
      skill.instance_variable_set(:@scope, 1)
      skill.instance_variable_set(:@occasion, 1)
      skill.instance_variable_set(:@base_damage, 1)
      skill.instance_variable_set(:@variance, 0)
      skill.instance_variable_set(:@atk_f, 0)
      skill.instance_variable_set(:@spi_f, 0)
      skill.instance_variable_set(:@mp_cost, 0)
      skill.instance_variable_set(:@hit, 100)
      skill.instance_variable_set(:@physical_attack, false)
      skill.instance_variable_set(:@damage_to_mp, false)
      skill.instance_variable_set(:@absorb_damage, false)
      skill.instance_variable_set(:@ignore_defense, false)
      skill.instance_variable_set(:@element_set, [])
      skill.instance_variable_set(:@plus_state_set, [])
      skill.instance_variable_set(:@minus_state_set, [])
      skill.instance_variable_set(:@note, "# FS_PHASE45F_FIELD_ONLY\n<field effect: 153>")
      skill.instance_variable_set(:@field_effect, nil)
      skill.instance_variable_set(:@remove_field_effect, nil)
      skill.instance_variable_set(:@__od_cost, 0)
      skill.instance_variable_set(:@__od_gain_rate, 0)
      skill.instance_variable_set(:@__is_overdrive, false)
      skill.instance_variable_set(:@turn_delay, 0)
      skill.instance_variable_set(:@battle_delay, 0)
      skill.instance_variable_set(:@step_delay, 0)
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      return skill
    rescue
      return nil
    end

    def p45f_install_field_skill(subject)
      return false if subject == nil || $data_skills == nil
      return true if @p45f_slot_snapshot != nil
      slot = P45F_FIELD_SKILL_SLOT
      original = $data_skills[slot] rescue nil
      return false if original == nil
      skill = p45f_make_field_skill(slot)
      return false if skill == nil
      state = $data_states[P45F_FIELD_STATE_ID] rescue nil
      parsed = skill.respond_to?(:field_effect) ? (skill.field_effect rescue nil) : nil
      weather_ok = defined?(FS_FIELD_WEATHER) && state != nil && FS_FIELD_WEATHER.weather_state?(state)
      parse_ok = parsed != nil && parsed.respond_to?(:id) && parsed.id.to_i == P45F_FIELD_STATE_ID
      @p45f_slot_snapshot = {
        :slot=>slot, :object=>original, :object_id=>original.object_id,
        :bytes=>(Marshal.dump(original) rescue nil), :array_oid=>$data_skills.object_id,
        :subject=>subject, :raw_before=>((subject.instance_variable_get(:@skills) rescue []).include?(slot))
      }
      $data_skills[slot] = skill
      subject.learn_skill(slot) unless @p45f_slot_snapshot[:raw_before]
      assert("Phase45F synthetic Field Skill parses legacy + Weather state", parse_ok && weather_ok,
             "parsed=#{parsed == nil ? nil : parsed.id} weather=#{weather_ok}")
      return parse_ok && weather_ok
    rescue Exception => e
      exception(e, "p45f_install_field_skill")
      return false
    end

    def p45f_restore_field_skill
      snap = @p45f_slot_snapshot
      return true if snap == nil
      ok = false
      begin
        slot = snap[:slot].to_i
        subject = snap[:subject]
        if subject != nil && !snap[:raw_before]
          raw = subject.instance_variable_get(:@skills) rescue nil
          subject.forget_skill(slot) if raw != nil && raw.include?(slot)
        end
        $data_skills[slot] = snap[:object] if $data_skills != nil
        current = $data_skills[slot] rescue nil
        bytes = Marshal.dump(current) rescue nil
        ok = current != nil && current.object_id == snap[:object_id] &&
             (snap[:bytes] == nil || bytes == snap[:bytes]) &&
             $data_skills.object_id == snap[:array_oid]
      rescue
        ok = false
      end
      @p45f_slot_snapshot = nil
      return ok
    end

    def p45f_snapshot_field_runtime
      return nil if $game_temp == nil
      return {
        :field=>($game_temp.field_effect rescue nil),
        :field_oid=>(($game_temp.field_effect rescue nil) == nil ? nil : $game_temp.field_effect.object_id),
        :source=>($game_temp.fs_field_effect_source rescue nil),
        :source_oid=>(($game_temp.fs_field_effect_source rescue nil) == nil ? nil : $game_temp.fs_field_effect_source.object_id)
      }
    rescue
      return nil
    end

    def p45f_restore_field_runtime
      snap = @p45f_field_runtime_snapshot
      return true if snap == nil
      ok = false
      begin
        $game_temp.field_effect = snap[:field]
        $game_temp.fs_field_effect_source = snap[:source]
        field = $game_temp.field_effect
        source = $game_temp.fs_field_effect_source
        ok = (field == snap[:field]) && (source == snap[:source]) &&
             (field == nil || field.object_id == snap[:field_oid]) &&
             (source == nil || source.object_id == snap[:source_oid])
      rescue
        ok = false
      end
      @p45f_field_runtime_snapshot = nil
      return ok
    end

    #--------------------------------------------------------------------------
    # Core Fixture 擴充：只新增 Field ownership 一招；Skill101 / Skill253 沿用既有真實案例。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase45f_core_build_fixture_plan_base)
      alias fs_phase45f_core_build_fixture_plan_base core_build_fixture_plan
    end
    def core_build_fixture_plan
      plan = fs_phase45f_core_build_fixture_plan_base
      return plan if plan == nil
      return plan if plan.any? { |f| f.is_a?(Hash) && f[:p45f_field_owner] }
      enemies = $game_troop.members.select { |e| e != nil && e.exist? }
      target = enemies.sort_by { |e| -(e.maxhp.to_i rescue 0) }[0]
      if target != nil
        plan << {
          :name=>"PHASE45F_FIELD_WEATHER_OWNERSHIP", :kind=>:skill,
          :skill_id=>P45F_FIELD_SKILL_SLOT, :boost_hp=>true,
          :p45f_field_owner=>true,
          :target_index=>target.index, :target_oid=>target.object_id
        }
      end
      @core_fixture_plan = plan
      log("[FIXTURE] PHASE45F action-plan=#{plan.collect { |f| f[:name] }.inspect}")
      return plan
    end

    unless method_defined?(:fs_phase45f_core_prepare_action_state_base)
      alias fs_phase45f_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45f_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:name].to_s == "SKILL101_STATE40"
        prepared = p45f_prepare_skill101_character(subject)
        summon = @p45f_char_snapshot == nil ? nil : @p45f_char_snapshot[:summon]
        capture = prepared && p45f_begin_capture(:skill101_state_character, subject, target, 101, summon)
        assert("Phase45F Skill101 State/Character semantic capture armed", capture,
               "prepared=#{prepared}")
      elsif fixture != nil && fixture[:name].to_s == "SOULMARK_DRAIN_SKILL253"
        capture = p45f_begin_capture(:soulmark_post, subject, target, 253, nil)
        assert("Phase45F Skill253 SoulMark semantic capture armed", capture)
      elsif fixture != nil && fixture[:p45f_field_owner]
        @p45f_field_runtime_snapshot = p45f_snapshot_field_runtime
        installed = p45f_install_field_skill(subject)
        capture = installed && p45f_begin_capture(:field_weather, subject, target, P45F_FIELD_SKILL_SLOT, nil)
        assert("Phase45F Field semantic Skill/capture prepared", capture,
               "installed=#{installed} field_before=#{p45f_field_id}")
      end
      return result
    end

    #--------------------------------------------------------------------------
    # Semantic analyzers
    #--------------------------------------------------------------------------
    def p45f_analyze_skill101
      se_enter = p45f_event_snapshot(:enter, :state_effects)
      actor_enter = p45f_event_snapshot(:enter, :actor_profile)
      se_exit = p45f_event_snapshot(:exit, :state_effects)
      vx_enter = p45f_event_snapshot(:enter, :vx_base)
      vx_exit = p45f_event_snapshot(:exit, :vx_base)
      combo_exit = p45f_event_snapshot(:exit, :combo_core)
      char_exit = p45f_event_snapshot(:exit, :character_mechanic)

      inject_ok = se_enter != nil && actor_enter != nil && se_exit != nil &&
                  !se_enter[:skill_plus_states].include?(40) &&
                  actor_enter[:skill_plus_states].include?(40) &&
                  !se_exit[:skill_plus_states].include?(40)
      base_ok = vx_enter != nil && vx_exit != nil &&
                vx_enter[:skill_plus_states].include?(40) &&
                !vx_enter[:target_states].include?(40) &&
                vx_exit[:target_states].include?(40)
      char_od_ok = combo_exit != nil && char_exit != nil &&
                   combo_exit[:user_od] != nil && char_exit[:user_od] != nil &&
                   combo_exit[:user_od].to_i - char_exit[:user_od].to_i == 100
      char_atb_ok = combo_exit != nil && char_exit != nil &&
                    combo_exit[:summon_atb] != nil && char_exit[:summon_atb] != nil &&
                    char_exit[:summon_atb].to_i - combo_exit[:summon_atb].to_i == 120
      snap = @p45f_char_snapshot
      action_start_ok = false
      if snap != nil && snap[:subject] != nil
        value = snap[:subject].instance_variable_get(:@albert_od_action_start_value) rescue nil
        action_start_ok = value.to_i == 100
      end

      assert("Phase45F StateEffects owns Note state injection and restores Skill shape", inject_ok,
             "state_enter=#{se_enter.inspect} actor_enter=#{actor_enter.inspect} state_exit=#{se_exit.inspect}")
      assert("Phase45F VX Base owns actual State40 application", base_ok,
             "vx_enter=#{vx_enter.inspect} vx_exit=#{vx_exit.inspect}")
      assert("Phase45F CharacterMechanic owns Joey conditional OD100 payment", char_od_ok && action_start_ok,
             "combo_exit=#{combo_exit.inspect} char_exit=#{char_exit.inspect} action_start=#{action_start_ok}")
      assert("Phase45F CharacterMechanic owns Joey summon ATB +120", char_atb_ok,
             "combo_exit=#{combo_exit.inspect} char_exit=#{char_exit.inspect}")

      restore_ok = p45f_restore_skill101_character
      assert("Phase45F Skill101 temporary OD / summon ATB context restored exactly", restore_ok)
      ready = inject_ok && base_ok && char_od_ok && char_atb_ok && action_start_ok && restore_ok
      @p45f_state_character_ready = ready
      log("[SKILL_EFFECT_OWNER] case=skill101 state_inject=:state_effects state_apply=:vx_base joey_pull=:character_mechanic " +
          "od_delta=#{combo_exit == nil || char_exit == nil ? nil : combo_exit[:user_od].to_i - char_exit[:user_od].to_i} " +
          "atb_delta=#{combo_exit == nil || char_exit == nil ? nil : char_exit[:summon_atb].to_i - combo_exit[:summon_atb].to_i} ready=#{ready}")
      return ready
    end

    def p45f_analyze_soulmark
      soul_enter = p45f_event_snapshot(:enter, :soulmark)
      inner_exit = p45f_event_snapshot(:exit, :field_weather)
      soul_exit = p45f_event_snapshot(:exit, :soulmark)
      skill = $data_skills[253] rescue nil
      percent = 0
      begin
        art = FS_SOULMARK_RESONANCE.soul_art_from_skill(skill)
        effects = art == nil ? nil : art[:effects]
        percent = effects == nil ? 0 : effects[:drain].to_i
      rescue
        percent = 0
      end
      damage = 0
      gain = 0
      expected = 0
      if soul_enter != nil && inner_exit != nil && soul_exit != nil
        damage = soul_enter[:target_hp].to_i - inner_exit[:target_hp].to_i
        damage = 0 if damage < 0
        gain = soul_exit[:user_hp].to_i - inner_exit[:user_hp].to_i
        missing = inner_exit[:user_maxhp].to_i - inner_exit[:user_hp].to_i
        missing = 0 if missing < 0
        expected = [damage * percent / 100, missing].min
      end
      inner_no_heal = soul_enter != nil && inner_exit != nil && soul_enter[:user_hp].to_i == inner_exit[:user_hp].to_i
      owner_ok = percent > 0 && inner_exit != nil && soul_exit != nil && gain == expected && expected > 0
      target_stable = inner_exit != nil && soul_exit != nil && inner_exit[:target_hp].to_i == soul_exit[:target_hp].to_i
      assert("Phase45F SoulMark inner chain leaves drain heal unapplied", inner_no_heal,
             "soul_enter=#{soul_enter.inspect} inner_exit=#{inner_exit.inspect}")
      assert("Phase45F SoulMark layer owns exact percentage drain post-heal", owner_ok && target_stable,
             "damage=#{damage} percent=#{percent} expected=#{expected} gain=#{gain} target_stable=#{target_stable}")
      ready = inner_no_heal && owner_ok && target_stable
      @p45f_soulmark_ready = ready
      log("[SKILL_EFFECT_OWNER] case=soulmark owner=:soulmark damage=#{damage} drain=#{percent} expected_heal=#{expected} actual_heal=#{gain} ready=#{ready}")
      return ready
    end

    def p45f_analyze_field(subject)
      weather_enter = p45f_event_snapshot(:enter, :field_weather)
      legacy_enter = p45f_event_snapshot(:enter, :field_effect)
      legacy_exit = p45f_event_snapshot(:exit, :field_effect)
      weather_exit = p45f_event_snapshot(:exit, :field_weather)
      old = @p45f_field_runtime_snapshot
      old_id = old == nil || old[:field] == nil ? 0 : old[:field].id.to_i
      old_source_oid = old == nil ? nil : old[:source_oid]

      legacy_ok = legacy_enter != nil && legacy_exit != nil &&
                  legacy_enter[:field_id].to_i == old_id &&
                  legacy_exit[:field_id].to_i == P45F_FIELD_STATE_ID &&
                  legacy_exit[:field_source_oid] == old_source_oid
      weather_ok = weather_enter != nil && weather_exit != nil &&
                   weather_enter[:field_id].to_i == old_id &&
                   weather_exit[:field_id].to_i == P45F_FIELD_STATE_ID &&
                   weather_exit[:field_source_oid] == subject.object_id
      assert("Phase45F legacy FieldEffect owns raw field-state placement only", legacy_ok,
             "legacy_enter=#{legacy_enter.inspect} legacy_exit=#{legacy_exit.inspect} old=#{old.inspect}")
      assert("Phase45F FieldWeather Authority owns final field source", weather_ok,
             "weather_enter=#{weather_enter.inspect} weather_exit=#{weather_exit.inspect}")

      field_restore = p45f_restore_field_runtime
      slot_restore = p45f_restore_field_skill
      assert("Phase45F Field runtime state/source restored exactly", field_restore)
      assert("Phase45F synthetic Field Skill database slot restored exactly", slot_restore,
             "slot=#{P45F_FIELD_SKILL_SLOT}")
      ready = legacy_ok && weather_ok && field_restore && slot_restore
      @p45f_field_ready = ready
      log("[SKILL_EFFECT_OWNER] case=field legacy_owner=:field_effect final_owner=:field_weather state=#{P45F_FIELD_STATE_ID} " +
          "source_oid=#{weather_exit == nil ? nil : weather_exit[:field_source_oid]} ready=#{ready}")
      return ready
    end

    unless method_defined?(:fs_phase45f_core_finalize_fixture_base)
      alias fs_phase45f_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45f_core_finalize_fixture_base
      if fixture != nil && fixture[:name].to_s == "SKILL101_STATE40"
        p45f_end_capture
        p45f_analyze_skill101
      elsif fixture != nil && fixture[:name].to_s == "SOULMARK_DRAIN_SKILL253"
        p45f_end_capture
        p45f_analyze_soulmark
      elsif fixture != nil && fixture[:p45f_field_owner]
        p45f_end_capture
        subject = core_current_subject
        p45f_analyze_field(subject)
        ready = @p45f_state_character_ready == true && @p45f_soulmark_ready == true && @p45f_field_ready == true
        log("[SKILL_EFFECT_SEMANTIC_MAP] state_character=#{@p45f_state_character_ready.inspect} soulmark=#{@p45f_soulmark_ready.inspect} field=#{@p45f_field_ready.inspect} ready=#{ready}")
        assert("Phase45F Skill Effect semantic ownership map I completed", ready,
               "state_character=#{@p45f_state_character_ready.inspect} soulmark=#{@p45f_soulmark_ready.inspect} field=#{@p45f_field_ready.inspect}")
      end
      return result
    rescue Exception => e
      p45f_end_capture rescue nil
      exception(e, "p45f_core_finalize_current_fixture")
      p45f_restore_skill101_character rescue nil
      p45f_restore_field_runtime rescue nil
      p45f_restore_field_skill rescue nil
      assert("Phase45F Skill Effect semantic ownership map I completed", false, e.message)
      return result
    end

    # Snapshot / abort emergency cleanup；正常路徑應在各 Fixture 當場完成。
    unless method_defined?(:fs_phase45f_restore_pending_base)
      alias fs_phase45f_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45f_restore_pending_base
      if result
        p45f_end_capture rescue nil
        if @p45f_slot_snapshot != nil
          ok = p45f_restore_field_skill
          assert("Phase45F emergency synthetic Skill cleanup after Snapshot restore", ok)
        end
        if @p45f_field_runtime_snapshot != nil
          p45f_restore_field_runtime rescue nil
        end
        @p45f_char_snapshot = nil
        @p45f_semantic_summon = nil
        @p45f_state_character_ready = nil
        @p45f_soulmark_ready = nil
        @p45f_field_ready = nil
      end
      return result
    end
  end
end
end

#==============================================================================
# 【Phase45G｜Skill Effect Semantic Ownership II｜TEST-only】
#------------------------------------------------------------------------------
# 【用途】Phase45F1 已實機封版 975/0/0；本階段補齊高價值 Skill Effect semantic owner。
# 【機制】
#   1. 不增加 Core Battle Fixture；沿用既有 8 個真實 action fixture。
#   2. Phase45D 真實 Steal action 追加 StealResult marker provenance。
#   3. 最後一個 Phase45F Field fixture 完成後，在仍處於 Scene_Battle sandbox 時，以 detached battler
#      執行 SupportState / PokemonFollowup / AutoSetup / ActorProfile dedicated semantic fixture。
#   4. 沿用 Phase45E probes + Phase45F capture，不再新增 skill_effect alias layer。
# 【隔離】detached battler 不加入 Party/Troop；temporary context、Skill slot 1、RNG、ivar 均 immediate restore。
# 【Formal Runtime】0 修改；所有 Formal pages byte-exact。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45G_SKILL_SLOT = 1 unless const_defined?(:P45G_SKILL_SLOT)
  P45G_STATE_ID = 40 unless const_defined?(:P45G_STATE_ID)
  P45G_POKEMON_ACTOR_ID = 100 unless const_defined?(:P45G_POKEMON_ACTOR_ID)
  P45G_CLONE_ACTOR_ID = 9 unless const_defined?(:P45G_CLONE_ACTOR_ID)

  class << self
    #--------------------------------------------------------------------------
    # Phase45F recorder extension：只增加 semantic 欄位，不改既有判定。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase45g_p45f_snapshot_base)
      alias fs_phase45g_p45f_snapshot_base p45f_snapshot
    end
    def p45f_snapshot(target, user, skill)
      data = fs_phase45g_p45f_snapshot_base(target, user, skill)
      data = {} unless data.is_a?(Hash)
      context = nil
      begin
        context = user.instance_variable_get(:@fs_pfi_context) if user != nil
      rescue
        context = nil
      end
      used = nil
      context_skill = nil
      support_done = nil
      if context.is_a?(Hash)
        context_skill = context[:skill_id]
        support_done = context[:support_done]
        map = context[:effect_targets]
        used = map.is_a?(Hash) && target != nil ? (map[target.object_id] ? true : false) : false
      end
      data[:user_states] = p45f_state_ids(user)
      data[:skill_oid] = (skill == nil ? nil : skill.object_id)
      data[:skill_base_damage] = (skill != nil && skill.respond_to?(:base_damage) ? skill.base_damage.to_i : nil)
      data[:skill_atk_f] = (skill != nil && skill.respond_to?(:atk_f) ? skill.atk_f.to_i : nil)
      data[:skill_spi_f] = (skill != nil && skill.respond_to?(:spi_f) ? skill.spi_f.to_i : nil)
      begin
        data[:skill_elements] = skill == nil || !skill.respond_to?(:element_set) ? [] : skill.element_set.compact.collect { |x| x.to_i }
      rescue
        data[:skill_elements] = []
      end
      data[:skill_note] = (skill != nil && skill.respond_to?(:note) ? skill.note.to_s : "")
      data[:pfi_context_skill_id] = context_skill
      data[:pfi_used_target] = used
      data[:pfi_support_done] = support_done
      data[:mx_action_success] = (user == nil ? nil : (user.instance_variable_get(:@albert_mx_action_success) rescue nil))
      data[:profile_clone_success] = (user == nil ? nil : (user.instance_variable_get(:@albert_profile_clone_action_success) rescue nil))
      data[:steal_processed] = (target == nil ? nil : (target.instance_variable_get(:@fs_steal_effect_processed) rescue nil))
      data[:steal_checked] = (target == nil ? nil : (target.instance_variable_get(:@fs_steal_result_checked) rescue nil))
      data[:ivy_guarded_serial] = (target == nil ? nil : (target.instance_variable_get(:@albert_ic_guarded_skill_serial) rescue nil))
      return data
    rescue
      return fs_phase45g_p45f_snapshot_base(target, user, skill) rescue {}
    end

    #--------------------------------------------------------------------------
    # Ruby 1.8-safe ivar exact snapshot / restore。
    #--------------------------------------------------------------------------
    def p45g_ivar_snapshot(obj, name)
      return {:defined=>false, :value=>nil} if obj == nil
      defined = p42l_instance_variable_defined_compat?(obj, name)
      value = defined ? (obj.instance_variable_get(name) rescue nil) : nil
      return {:defined=>defined, :value=>value}
    rescue
      return {:defined=>false, :value=>nil}
    end

    def p45g_restore_ivar(obj, name, snap)
      return false if obj == nil || snap == nil
      begin
        if snap[:defined]
          obj.instance_variable_set(name, snap[:value])
          return p42l_instance_variable_defined_compat?(obj, name) &&
                 (obj.instance_variable_get(name) rescue nil) == snap[:value]
        end
        if p42l_instance_variable_defined_compat?(obj, name)
          obj.send(:remove_instance_variable, name) rescue nil
        end
        return !p42l_instance_variable_defined_compat?(obj, name)
      rescue
        return false
      end
    end

    #--------------------------------------------------------------------------
    # 以正式資料庫 Skill100 深拷貝，避免 local RPG::Skill parser 欄位不完整。
    #--------------------------------------------------------------------------
    def p45g_make_skill(skill_id, name, base_damage, physical, note)
      return nil if $data_skills == nil
      base = $data_skills[100] rescue nil
      return nil unless base.is_a?(RPG::Skill)
      skill = Marshal.load(Marshal.dump(base))
      skill.instance_variable_set(:@id, skill_id.to_i)
      skill.instance_variable_set(:@name, name.to_s)
      skill.instance_variable_set(:@scope, 1)
      skill.instance_variable_set(:@occasion, 1)
      skill.instance_variable_set(:@base_damage, base_damage.to_i)
      skill.instance_variable_set(:@variance, 0)
      skill.instance_variable_set(:@atk_f, 0)
      skill.instance_variable_set(:@spi_f, 0)
      skill.instance_variable_set(:@mp_cost, 0)
      skill.instance_variable_set(:@hit, 100)
      skill.instance_variable_set(:@physical_attack, physical ? true : false)
      skill.instance_variable_set(:@damage_to_mp, false)
      skill.instance_variable_set(:@absorb_damage, false)
      skill.instance_variable_set(:@ignore_defense, true)
      skill.instance_variable_set(:@element_set, [])
      skill.instance_variable_set(:@plus_state_set, [])
      skill.instance_variable_set(:@minus_state_set, [])
      skill.instance_variable_set(:@note, note.to_s)
      skill.instance_variable_set(:@__od_cost, 0)
      skill.instance_variable_set(:@__od_gain_rate, 0)
      skill.instance_variable_set(:@__is_overdrive, false)
      skill.instance_variable_set(:@turn_delay, 0)
      skill.instance_variable_set(:@battle_delay, 0)
      skill.instance_variable_set(:@step_delay, 0)
      FS_SKILL_COST_ALLFIX.parse(skill, true) if defined?(FS_SKILL_COST_ALLFIX)
      return skill
    rescue Exception => e
      exception(e, "p45g_make_skill")
      return nil
    end

    def p45g_skill_shape(skill)
      return nil if skill == nil
      return {
        :id=>(skill.respond_to?(:id) ? skill.id.to_i : nil),
        :name=>(skill.respond_to?(:name) ? skill.name.to_s : nil),
        :base_damage=>(skill.respond_to?(:base_damage) ? skill.base_damage.to_i : nil),
        :atk_f=>(skill.respond_to?(:atk_f) ? skill.atk_f.to_i : nil),
        :spi_f=>(skill.respond_to?(:spi_f) ? skill.spi_f.to_i : nil),
        :physical=>(skill.respond_to?(:physical_attack) ? (skill.physical_attack ? true : false) : nil),
        :elements=>(skill.respond_to?(:element_set) && skill.element_set != nil ? skill.element_set.clone : []),
        :plus_states=>(skill.respond_to?(:plus_state_set) && skill.plus_state_set != nil ? skill.plus_state_set.clone : []),
        :minus_states=>(skill.respond_to?(:minus_state_set) && skill.minus_state_set != nil ? skill.minus_state_set.clone : []),
        :note=>(skill.respond_to?(:note) ? skill.note.to_s : "")
      }
    rescue
      return nil
    end

    def p45g_state_enemy_id
      plan = @core_fixture_plan || []
      fixture = plan.find { |f| f.is_a?(Hash) && f[:name].to_s == "SKILL101_STATE40" }
      if fixture != nil
        target = core_target_by_index(fixture[:target_index]) rescue nil
        return target.enemy_id.to_i if target != nil && target.respond_to?(:enemy_id)
      end
      enemy = $game_troop == nil ? nil : $game_troop.members.compact.find { |e| e.respond_to?(:enemy_id) && e.exist? }
      return enemy == nil ? 0 : enemy.enemy_id.to_i
    rescue
      return 0
    end

    def p45g_detached_enemy
      enemy_id = p45g_state_enemy_id
      return nil if enemy_id <= 0
      return Game_Enemy.new(0, enemy_id)
    rescue Exception => e
      exception(e, "p45g_detached_enemy")
      return nil
    end

    def p45g_rng_call(label, target, user, skill)
      enabled_before = defined?(FS_COMBAT_RANDOM) && FS_COMBAT_RANDOM.enabled?
      scene = $scene rescue nil
      active_context = scene != nil &&
                       scene.respond_to?(:active_battler) &&
                       scene.respond_to?(:active_battler=)
      active_before = active_context ? scene.active_battler : nil
      assert("Phase45G dedicated semantic fixture starts with Combat RNG OFF", !enabled_before, label)
      result = nil
      begin
        scene.active_battler = user if active_context
        FS_COMBAT_RANDOM.enable(149) if defined?(FS_COMBAT_RANDOM) && !enabled_before
        armed = p45f_begin_capture(label, user, target, skill.id, nil)
        assert("Phase45G semantic capture armed", armed, label)
        result = target.skill_effect(user, skill) if armed
      ensure
        p45f_end_capture rescue nil
        if defined?(FS_COMBAT_RANDOM) && !enabled_before
          FS_COMBAT_RANDOM.disable rescue nil
        end
        scene.active_battler = active_before if active_context
      end
      rng_restored = !defined?(FS_COMBAT_RANDOM) || FS_COMBAT_RANDOM.enabled? == enabled_before
      active_restored = !active_context || ((scene.active_battler rescue nil).equal?(active_before))
      restored = rng_restored && active_restored
      assert("Phase45G dedicated semantic fixture restores Combat RNG / active battler context exactly",
             restored, "label=#{label} rng=#{rng_restored} active=#{active_restored}")
      return result
    rescue Exception => e
      p45f_end_capture rescue nil
      FS_COMBAT_RANDOM.disable rescue nil if defined?(FS_COMBAT_RANDOM) && !enabled_before
      begin
        scene.active_battler = active_before if active_context
      rescue
      end
      exception(e, "p45g_rng_call:#{label}")
      assert("Phase45G dedicated semantic fixture restores Combat RNG / active battler context exactly",
             false, label)
      return nil
    end

    def p45g_semantic_projection(snap)
      return nil if snap == nil
      keys = [
        :target_hp, :target_states, :user_hp, :user_states,
        :mx_action_success, :profile_clone_success,
        :steal_processed, :steal_checked,
        :pfi_context_skill_id, :pfi_used_target, :pfi_support_done
      ]
      result = {}
      keys.each { |key| result[key] = snap[key] }
      return result
    rescue
      return nil
    end

    #--------------------------------------------------------------------------
    # SupportState：純狀態／零傷害 dedicated fixture。
    # 重要：不塞進 positive-damage Core Fixture contract。
    #--------------------------------------------------------------------------
    def p45g_run_support_state_fixture
      user = Game_Actor.new(1) rescue nil
      target = p45g_detached_enemy
      skill = p45g_make_skill(P45G_SKILL_SLOT, "Phase45G Support Pure State", 0, true,
                              "# FS_PHASE45G_SUPPORT_ONLY\n<state_chance 40:100>")
      ready_objects = user != nil && target != nil && skill != nil
      assert("Phase45G SupportState detached fixture objects ready", ready_objects,
             "user=#{user != nil} target=#{target != nil} skill=#{skill != nil}")
      return false unless ready_objects

      target.remove_state(P45G_STATE_ID) if target.state?(P45G_STATE_ID)
      mx_snap = p45g_ivar_snapshot(user, "@albert_mx_action_success")
      ivy_snap = p45g_ivar_snapshot(target, "@albert_ic_guarded_skill_serial")
      before_skill = p45g_skill_shape(skill)
      p45g_rng_call(:p45g_support_pure_state, target, user, skill)

      support_enter = p45f_event_snapshot(:enter, :support_state)
      steal_enter = p45f_event_snapshot(:enter, :steal_result)
      state_enter = p45f_event_snapshot(:enter, :state_effects)
      actor_enter = p45f_event_snapshot(:enter, :actor_profile)
      vx_enter = p45f_event_snapshot(:enter, :vx_base)
      vx_exit = p45f_event_snapshot(:exit, :vx_base)
      char_exit = p45f_event_snapshot(:exit, :character_mechanic)
      mx_exit = p45f_event_snapshot(:exit, :mechanic_expansion)
      ant_exit = p45f_event_snapshot(:exit, :antagonist)
      profile_exit = p45f_event_snapshot(:exit, :actor_profile)
      state_exit = p45f_event_snapshot(:exit, :state_effects)
      ivy_exit = p45f_event_snapshot(:exit, :ivy_clone)
      soul_exit = p45f_event_snapshot(:exit, :soulmark)
      steal_exit = p45f_event_snapshot(:exit, :steal_result)
      support_exit = p45f_event_snapshot(:exit, :support_state)

      gate_ok = support_enter != nil && steal_enter != nil && support_exit != nil &&
                support_enter[:skill_physical] == true &&
                steal_enter[:skill_physical] == false &&
                support_exit[:skill_physical] == true
      injection_ok = state_enter != nil && actor_enter != nil && state_exit != nil &&
                     !state_enter[:skill_plus_states].include?(P45G_STATE_ID) &&
                     actor_enter[:skill_plus_states].include?(P45G_STATE_ID) &&
                     !state_exit[:skill_plus_states].include?(P45G_STATE_ID)
      base_ok = vx_enter != nil && vx_exit != nil &&
                !vx_enter[:target_states].include?(P45G_STATE_ID) &&
                vx_exit[:target_states].include?(P45G_STATE_ID)
      failure_ok = support_exit != nil && support_exit[:state_add_failed] == false
      mx_ok = char_exit != nil && mx_exit != nil &&
              char_exit[:mx_action_success] != true && mx_exit[:mx_action_success] == true

      antagonist_pass = mx_exit != nil && ant_exit != nil &&
                        p45g_semantic_projection(mx_exit) == p45g_semantic_projection(ant_exit)
      profile_pass = ant_exit != nil && profile_exit != nil &&
                     p45g_semantic_projection(ant_exit) == p45g_semantic_projection(profile_exit)
      ivy_owner = state_exit != nil && ivy_exit != nil &&
                  state_exit[:ivy_guarded_serial] != -1 && ivy_exit[:ivy_guarded_serial].to_i == -1
      steal_pass = soul_exit != nil && steal_exit != nil &&
                   p45g_semantic_projection(soul_exit) == p45g_semantic_projection(steal_exit)

      assert("Phase45G SupportState owns physical-zero-damage gate and restores Skill physical flag", gate_ok,
             "support_enter=#{support_enter.inspect} steal_enter=#{steal_enter.inspect} support_exit=#{support_exit.inspect}")
      assert("Phase45G Support pure-state still delegates Note injection to StateEffects", injection_ok,
             "state_enter=#{state_enter.inspect} actor_enter=#{actor_enter.inspect} state_exit=#{state_exit.inspect}")
      assert("Phase45G Support pure-state delegates actual State40 application to VX Base", base_ok,
             "vx_enter=#{vx_enter.inspect} vx_exit=#{vx_exit.inspect}")
      assert("Phase45G SupportState owns pure-state success/failure semantic result", failure_ok,
             "support_exit=#{support_exit.inspect}")
      assert("Phase45G MechanicExpansion owns successful-action marker on pure-state success", mx_ok,
             "character_exit=#{char_exit.inspect} mechanic_exit=#{mx_exit.inspect}")
      assert("Phase45G selected Support fixture marks Antagonist as pass-through", antagonist_pass,
             "inner=#{mx_exit.inspect} outer=#{ant_exit.inspect}")
      assert("Phase45G selected Support fixture marks ActorProfile as pass-through", profile_pass,
             "inner=#{ant_exit.inspect} outer=#{profile_exit.inspect}")
      assert("Phase45G IvyClone owns guarded-skill serial final reset bookkeeping", ivy_owner,
             "inner=#{state_exit.inspect} outer=#{ivy_exit.inspect}")
      assert("Phase45G selected Support fixture marks StealResult as non-Steal pass-through", steal_pass,
             "inner=#{soul_exit.inspect} outer=#{steal_exit.inspect}")

      skill_restore = before_skill != nil && p45g_skill_shape(skill) == before_skill
      state_applied = target.state?(P45G_STATE_ID) rescue false
      target.remove_state(P45G_STATE_ID) if state_applied
      state_clean = !(target.state?(P45G_STATE_ID) rescue true)
      mx_restore = p45g_restore_ivar(user, "@albert_mx_action_success", mx_snap)
      ivy_restore = p45g_restore_ivar(target, "@albert_ic_guarded_skill_serial", ivy_snap)
      assert("Phase45G Support detached Skill shape restores exactly", skill_restore)
      assert("Phase45G Support detached target state cleanup exact", state_applied && state_clean,
             "applied=#{state_applied} clean=#{state_clean}")
      assert("Phase45G Support detached MechanicExpansion marker cleanup exact", mx_restore)
      assert("Phase45G IvyClone detached guarded-serial cleanup exact", ivy_restore)

      ready = gate_ok && injection_ok && base_ok && failure_ok && mx_ok &&
              antagonist_pass && profile_pass && ivy_owner && steal_pass &&
              skill_restore && state_applied && state_clean && mx_restore && ivy_restore
      @p45g_support_ready = ready
      log("[SKILL_EFFECT_OWNER_II] case=support_pure_state gate=:support_state state_inject=:state_effects state_apply=:vx_base " +
          "action_success=:mechanic_expansion ivy_bookkeeping=:guarded_serial_reset " +
          "pass_through=[:antagonist,:actor_profile,:steal_result_nonsteal] ready=#{ready}")
      return ready
    rescue Exception => e
      exception(e, "p45g_run_support_state_fixture")
      @p45g_support_ready = false
      return false
    end

    #--------------------------------------------------------------------------
    # PokemonFollowup：context trigger / temporary identity / per-target dedupe。
    #--------------------------------------------------------------------------
    def p45g_run_pokemon_followup_fixture
      user = Game_Actor.new(P45G_POKEMON_ACTOR_ID) rescue nil
      skill = p45g_make_skill(P45G_SKILL_SLOT, "Phase45G Pokemon Followup", 1, false,
                              "# FS_PHASE45G_PFI_BASE")
      target_a = p45g_detached_enemy
      target_b = p45g_detached_enemy
      ready_objects = user != nil && skill != nil && target_a != nil && target_b != nil &&
                      defined?(FS_POKEMON_FOLLOWUP_IDENTITY) && FS_POKEMON_FOLLOWUP_IDENTITY.pokemon?(user)
      assert("Phase45G PokemonFollowup detached Pokemon/targets ready", ready_objects,
             "pokemon=#{user != nil && defined?(FS_POKEMON_FOLLOWUP_IDENTITY) ? FS_POKEMON_FOLLOWUP_IDENTITY.pokemon?(user) : false}")
      return false unless ready_objects

      context_snap = p45g_ivar_snapshot(user, "@fs_pfi_context")
      original_shape = p45g_skill_shape(skill)

      # mismatch context：不得改 identity。
      mismatch = {:skill_id=>skill.id.to_i + 99, :effect_targets=>{}, :support_done=>false}
      user.instance_variable_set(:@fs_pfi_context, mismatch)
      p45g_rng_call(:p45g_pfi_mismatch, target_a, user, skill)
      mm_pfi = p45f_event_snapshot(:enter, :pokemon_followup)
      mm_support = p45f_event_snapshot(:enter, :support_state)
      mismatch_ok = mm_pfi != nil && mm_support != nil &&
                    mm_pfi[:skill_oid] == skill.object_id && mm_support[:skill_oid] == skill.object_id &&
                    mm_pfi[:skill_base_damage].to_i == mm_support[:skill_base_damage].to_i

      # matching context：PFI 必須建 temporary Skill identity，且只把成功 target 標記一次。
      context = {:skill_id=>skill.id.to_i, :effect_targets=>{}, :support_done=>false}
      user.instance_variable_set(:@fs_pfi_context, context)
      p45g_rng_call(:p45g_pfi_match_first, target_b, user, skill)
      pfi_enter = p45f_event_snapshot(:enter, :pokemon_followup)
      support_enter = p45f_event_snapshot(:enter, :support_state)
      pfi_exit = p45f_event_snapshot(:exit, :pokemon_followup)
      effect = FS_POKEMON_FOLLOWUP_IDENTITY.effect_for(user)
      effect_note = FS_POKEMON_FOLLOWUP_IDENTITY.note_for_effect(effect)
      element_id = FS_POKEMON_FOLLOWUP_IDENTITY::ELEMENT_SYMBOL_TO_ID[
        FS_POKEMON_FOLLOWUP_IDENTITY.primary_element(user)
      ]
      identity_ok = pfi_enter != nil && support_enter != nil && pfi_exit != nil &&
                    pfi_enter[:skill_oid] == skill.object_id &&
                    support_enter[:skill_oid] != skill.object_id &&
                    support_enter[:skill_base_damage].to_i == FS_POKEMON_FOLLOWUP_IDENTITY::BASE_DAMAGE.to_i &&
                    support_enter[:skill_atk_f].to_i == FS_POKEMON_FOLLOWUP_IDENTITY::ATK_F.to_i &&
                    support_enter[:skill_spi_f].to_i == FS_POKEMON_FOLLOWUP_IDENTITY::SPI_F.to_i &&
                    (element_id == nil || support_enter[:skill_elements] == [element_id.to_i]) &&
                    pfi_exit[:skill_oid] == skill.object_id
      target_owned = context[:effect_targets].is_a?(Hash) && context[:effect_targets][target_b.object_id] == true &&
                     pfi_exit != nil && pfi_exit[:pfi_used_target] == true
      first_note_ok = effect_note.to_s == "" || support_enter[:skill_note].include?(effect_note.to_s.strip)

      # 同 target 第二次：context 已擁有 target，因此不得再附加特色 Note。
      target_b.hp = target_b.maxhp if target_b.respond_to?(:hp=)
      p45g_rng_call(:p45g_pfi_match_repeat, target_b, user, skill)
      repeat_support = p45f_event_snapshot(:enter, :support_state)
      repeat_dedupe_ok = repeat_support != nil &&
                         repeat_support[:skill_note].to_s == skill.note.to_s &&
                         context[:effect_targets][target_b.object_id] == true

      assert("Phase45G PokemonFollowup mismatched context is pass-through", mismatch_ok,
             "pfi=#{mm_pfi.inspect} support=#{mm_support.inspect}")
      assert("Phase45G PokemonFollowup owns temporary attacker identity transform", identity_ok,
             "pfi_enter=#{pfi_enter.inspect} support_enter=#{support_enter.inspect} pfi_exit=#{pfi_exit.inspect}")
      assert("Phase45G PokemonFollowup owns successful effect target identity", target_owned,
             "context=#{context.inspect} pfi_exit=#{pfi_exit.inspect}")
      assert("Phase45G PokemonFollowup first target receives identity effect Note", first_note_ok,
             "effect=#{effect.inspect} note=#{support_enter == nil ? nil : support_enter[:skill_note].inspect}")
      assert("Phase45G PokemonFollowup dedupes repeated target effect", repeat_dedupe_ok,
             "repeat=#{repeat_support.inspect} context=#{context.inspect}")

      shape_ok = original_shape != nil && p45g_skill_shape(skill) == original_shape
      context_restore = p45g_restore_ivar(user, "@fs_pfi_context", context_snap)
      assert("Phase45G PokemonFollowup leaves original Skill semantic shape exact", shape_ok)
      assert("Phase45G PokemonFollowup context restored exactly", context_restore)

      ready = mismatch_ok && identity_ok && target_owned && first_note_ok && repeat_dedupe_ok &&
              shape_ok && context_restore
      @p45g_pfi_ready = ready
      log("[SKILL_EFFECT_OWNER_II] case=pokemon_followup trigger=:matching_context identity=:pokemon_followup " +
          "target_dedupe=:pokemon_followup original_skill_unchanged=#{shape_ok} ready=#{ready}")
      return ready
    rescue Exception => e
      exception(e, "p45g_run_pokemon_followup_fixture")
      @p45g_pfi_ready = false
      return false
    end

    #--------------------------------------------------------------------------
    # AutoSetup late-bound <fs_user_add_state>：outer layer 才新增 user State。
    #--------------------------------------------------------------------------
    def p45g_run_autoset_fixture
      user = Game_Actor.new(1) rescue nil
      target = p45g_detached_enemy
      skill = p45g_make_skill(P45G_SKILL_SLOT, "Phase45G AutoSetup User State", 0, false,
                              "# FS_PHASE45G_AUTOSET_ONLY\n<fs_user_add_state:40>")
      ready_objects = user != nil && target != nil && skill != nil && $data_skills != nil
      assert("Phase45G AutoSetup detached fixture objects ready", ready_objects)
      return false unless ready_objects

      user.remove_state(P45G_STATE_ID) if user.state?(P45G_STATE_ID)
      original = $data_skills[P45G_SKILL_SLOT] rescue nil
      return false if original == nil
      slot_snap = {
        :object=>original, :oid=>original.object_id,
        :bytes=>(Marshal.dump(original) rescue nil), :array_oid=>$data_skills.object_id
      }
      $data_skills[P45G_SKILL_SLOT] = skill

      p45g_rng_call(:p45g_autoset_user_state, target, user, $data_skills[P45G_SKILL_SLOT])
      autoset_enter = p45f_event_snapshot(:enter, :autoset)
      combat_exit = p45f_event_snapshot(:exit, :combat_rng)
      autoset_exit = p45f_event_snapshot(:exit, :autoset)
      ownership_ok = autoset_enter != nil && combat_exit != nil && autoset_exit != nil &&
                     !autoset_enter[:user_states].include?(P45G_STATE_ID) &&
                     !combat_exit[:user_states].include?(P45G_STATE_ID) &&
                     autoset_exit[:user_states].include?(P45G_STATE_ID)
      late_ok = p45e_runtime_outer_to_base[0] == :autoset &&
                Game_Battler.method_defined?(:fs_db_autoset_skill_effect) &&
                ($fs_db_autoset_skill_effect_patch ? true : false)
      assert("Phase45G AutoSetup late-bound outer layer owns fs_user_add_state", ownership_ok,
             "autoset_enter=#{autoset_enter.inspect} inner_exit=#{combat_exit.inspect} autoset_exit=#{autoset_exit.inspect}")
      assert("Phase45G AutoSetup runtime patch remains late-bound outermost", late_ok,
             "chain=#{p45e_runtime_outer_to_base.inspect} patch=#{$fs_db_autoset_skill_effect_patch.inspect}")

      state_added = user.state?(P45G_STATE_ID) rescue false
      user.remove_state(P45G_STATE_ID) if state_added
      state_clean = !(user.state?(P45G_STATE_ID) rescue true)
      $data_skills[P45G_SKILL_SLOT] = slot_snap[:object]
      current = $data_skills[P45G_SKILL_SLOT] rescue nil
      current_bytes = Marshal.dump(current) rescue nil
      slot_restore = current != nil && current.object_id == slot_snap[:oid] &&
                     $data_skills.object_id == slot_snap[:array_oid] &&
                     (slot_snap[:bytes] == nil || current_bytes == slot_snap[:bytes])
      assert("Phase45G AutoSetup temporary user State cleanup exact", state_added && state_clean,
             "added=#{state_added} clean=#{state_clean}")
      assert("Phase45G AutoSetup temporary database Skill slot restored exactly", slot_restore,
             "slot=#{P45G_SKILL_SLOT}")

      ready = ownership_ok && late_ok && state_added && state_clean && slot_restore
      @p45g_autoset_ready = ready
      log("[SKILL_EFFECT_OWNER_II] case=autoset owner=:autoset_late_bound user_state=#{P45G_STATE_ID} " +
          "inner_unchanged=true database_restore=#{slot_restore} ready=#{ready}")
      return ready
    rescue Exception => e
      begin
        $data_skills[P45G_SKILL_SLOT] = slot_snap[:object] if slot_snap != nil && $data_skills != nil
      rescue
      end
      exception(e, "p45g_run_autoset_fixture")
      @p45g_autoset_ready = false
      return false
    end

    #--------------------------------------------------------------------------
    # ActorProfile：Clone successful-action marker owner。
    #--------------------------------------------------------------------------
    def p45g_run_actor_profile_fixture
      user = Game_Actor.new(P45G_CLONE_ACTOR_ID) rescue nil
      target = p45g_detached_enemy
      skill = p45g_make_skill(P45G_SKILL_SLOT, "Phase45G ActorProfile Clone", 1, false,
                              "# FS_PHASE45G_PROFILE_ONLY")
      ready_objects = user != nil && target != nil && skill != nil &&
                      user.respond_to?(:albert_clone?) && user.albert_clone?
      assert("Phase45G ActorProfile detached Clone fixture ready", ready_objects,
             "clone=#{user != nil && user.respond_to?(:albert_clone?) ? user.albert_clone? : false}")
      return false unless ready_objects

      marker_snap = p45g_ivar_snapshot(user, "@albert_profile_clone_action_success")
      p45g_rng_call(:p45g_actor_profile_clone, target, user, skill)
      ant_exit = p45f_event_snapshot(:exit, :antagonist)
      profile_exit = p45f_event_snapshot(:exit, :actor_profile)
      owner_ok = ant_exit != nil && profile_exit != nil &&
                 ant_exit[:profile_clone_success] != true &&
                 profile_exit[:profile_clone_success] == true
      assert("Phase45G ActorProfile owns Clone successful-action marker", owner_ok,
             "antagonist_exit=#{ant_exit.inspect} actor_profile_exit=#{profile_exit.inspect}")
      marker_restore = p45g_restore_ivar(user, "@albert_profile_clone_action_success", marker_snap)
      assert("Phase45G ActorProfile detached Clone marker cleanup exact", marker_restore)
      ready = owner_ok && marker_restore
      @p45g_profile_ready = ready
      log("[SKILL_EFFECT_OWNER_II] case=actor_profile owner=:actor_profile clone_action_success=true ready=#{ready}")
      return ready
    rescue Exception => e
      exception(e, "p45g_run_actor_profile_fixture")
      @p45g_profile_ready = false
      return false
    end

    #--------------------------------------------------------------------------
    # StealResult：借用 Phase45D 真實 Steal Battle action，不造假 steal context。
    # processed 由 page412 skill_effect wrapper 建立；checked 由 page412 make_obj_steal_result
    # authority 在 KGC Steal inner call 時建立。
    #--------------------------------------------------------------------------
    def p45g_analyze_steal_result
      steal_enter = p45f_event_snapshot(:enter, :steal_result)
      soul_enter = p45f_event_snapshot(:enter, :soulmark)
      kgc_enter = p45f_event_snapshot(:enter, :kgc_steal)
      kgc_exit = p45f_event_snapshot(:exit, :kgc_steal)
      steal_exit = p45f_event_snapshot(:exit, :steal_result)
      processed_ok = steal_enter != nil && soul_enter != nil &&
                     steal_enter[:steal_processed] != true && soul_enter[:steal_processed] == true
      checked_ok = kgc_enter != nil && kgc_exit != nil && steal_exit != nil &&
                   kgc_enter[:steal_checked] != true && kgc_exit[:steal_checked] == true &&
                   steal_exit[:steal_checked] == true
      assert("Phase45G StealResult skill_effect wrapper owns processed marker", processed_ok,
             "steal_enter=#{steal_enter.inspect} soul_enter=#{soul_enter.inspect}")
      assert("Phase45G StealResult make_obj_steal_result authority owns checked marker via KGC Steal call", checked_ok,
             "kgc_enter=#{kgc_enter.inspect} kgc_exit=#{kgc_exit.inspect} steal_exit=#{steal_exit.inspect}")
      ready = processed_ok && checked_ok
      @p45g_steal_ready = ready
      log("[SKILL_EFFECT_OWNER_II] case=steal_result processed_owner=:steal_result_skill_effect " +
          "checked_owner=:steal_result_make_obj_steal_result checked_callsite=:kgc_steal ready=#{ready}")
      return ready
    rescue Exception => e
      exception(e, "p45g_analyze_steal_result")
      @p45g_steal_ready = false
      return false
    end

    #--------------------------------------------------------------------------
    # Phase45D 真實 Steal action 前後掛 capture；其他 Fixture 完整委派。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase45g_core_prepare_action_state_base)
      alias fs_phase45g_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45g_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:p45d_steal_cost]
        skill = $data_skills[fixture[:skill_id].to_i] rescue nil
        capture = skill != nil && p45f_begin_capture(:p45g_steal_result_real_battle,
                                                     subject, target, skill.id, nil)
        assert("Phase45G real Steal semantic capture armed", capture,
               "skill=#{skill == nil ? nil : skill.id}")
      end
      return result
    end

    def p45g_run_dedicated_suite
      return @p45g_suite_ready if @p45g_suite_ran
      @p45g_suite_ran = true
      support = p45g_run_support_state_fixture
      pfi = p45g_run_pokemon_followup_fixture
      autoset = p45g_run_autoset_fixture
      profile = p45g_run_actor_profile_fixture
      steal = @p45g_steal_ready == true
      ready = support && pfi && autoset && profile && steal
      @p45g_suite_ready = ready
      log("[SKILL_EFFECT_SEMANTIC_MAP_II] support=#{support} pokemon_followup=#{pfi} autoset=#{autoset} " +
          "mechanic_expansion=#{support} actor_profile=#{profile} ivy_clone_bookkeeping=#{support} steal_result=#{steal} " +
          "selected_pass_through=[:antagonist] ready=#{ready}")
      assert("Phase45G Skill Effect semantic ownership map II completed", ready,
             "support=#{support} pfi=#{pfi} autoset=#{autoset} profile=#{profile} steal=#{steal}")
      return ready
    rescue Exception => e
      exception(e, "p45g_run_dedicated_suite")
      @p45g_suite_ready = false
      assert("Phase45G Skill Effect semantic ownership map II completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase45g_core_finalize_fixture_base)
      alias fs_phase45g_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45g_core_finalize_fixture_base
      if fixture != nil && fixture[:p45d_steal_cost]
        p45f_end_capture
        p45g_analyze_steal_result
      elsif fixture != nil && fixture[:p45f_field_owner]
        p45g_run_dedicated_suite
      end
      return result
    rescue Exception => e
      p45f_end_capture rescue nil
      exception(e, "p45g_core_finalize_current_fixture")
      assert("Phase45G Skill Effect semantic ownership map II completed", false, e.message)
      return result
    end

    # Snapshot / abort 後只清 TEST state；Formal runtime 不受影響。
    unless method_defined?(:fs_phase45g_restore_pending_base)
      alias fs_phase45g_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45g_restore_pending_base
      if result
        p45f_end_capture rescue nil
        FS_COMBAT_RANDOM.disable rescue nil if defined?(FS_COMBAT_RANDOM) && FS_COMBAT_RANDOM.enabled?
        @p45g_support_ready = nil
        @p45g_pfi_ready = nil
        @p45g_autoset_ready = nil
        @p45g_profile_ready = nil
        @p45g_steal_ready = nil
        @p45g_suite_ready = nil
        @p45g_suite_ran = nil
      end
      return result
    end
  end
end
end

#==============================================================================
# 【Phase45H｜make_obj_damage_value Staged-chain Provenance｜TEST-only】
#------------------------------------------------------------------------------
# 【用途】在 Phase45G1 已封版後，以既有 Skill100 真實 Battle Fixture 捕捉
#         Game_Battler#make_obj_damage_value 的 active runtime chain。
# 【重點】page344 Custom Dmg Formulas RD 以直接 def 重新定義 make_obj_damage_value，
#         因此早期 BattleResultStats / SkillActivation / KGC Equipment / VX Base 可能已被 shadow。
#         本 Probe 不把「曾經 alias 過」誤當成「目前仍在 runtime chain」。
# 【Formal Runtime】0 修改。所有 wrapper 僅 $TEST 下安裝，且只在 Skill100 指定 user/target scope 記錄。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45H_SKILL_ID = 100 unless const_defined?(:P45H_SKILL_ID)

  class << self
    # Active runtime outer -> base。每一個 alias method 代表「它被下一個外層保存時」的當時 method body。
    def p45h_active_outer_to_base
      [
        :marked_command,
        :support_state,
        :soulmark,
        :field_weather,
        :ivy_clone,
        :state_effects,
        :actor_profile,
        :battle_integrity,
        :mechanic_expansion,
        :character_mechanic,
        :combo_core,
        :summon_equip,
        :battle_formula,
        :integer_fix,
        :yez_skilllevel,
        :cover,
        :custom_damage
      ]
    end

    # 這些方法仍存在於 Class method table，但若 page344 direct redefine 已截斷舊鏈，
    # 真實 Skill100 current path 應完全不會進入。
    def p45h_shadow_labels
      [:skill_activation_legacy, :battle_result_stats_legacy, :vx_base_legacy]
    end

    # [method_name, semantic_layer, segment]
    def p45h_probe_specs
      [
        [:make_obj_damage_value,                    :marked_command,              :active],
        [:fs_mc_original_make_obj_damage_value,     :support_state,               :active],
        [:fs_ssr_old_make_obj_damage_value,         :soulmark,                    :active],
        [:fs_smre_make_obj_damage_value,             :field_weather,               :active],
        [:fs_field_weather_make_obj_damage_value,    :ivy_clone,                   :active],
        [:albert_ic_old_obj_damage,                  :state_effects,                :active],
        [:albert_sev21_cover_make_obj_damage_value,  :actor_profile,                :active],
        [:albert_profile_old_make_obj_damage_value,  :battle_integrity,             :active],
        [:albert_sc3mh_old_make_obj_damage_value,    :mechanic_expansion,           :active],
        [:albert_mx_old_make_obj_damage_value,       :character_mechanic,           :active],
        [:albert_cc_old_make_obj_damage_value,       :combo_core,                   :active],
        [:albert_combo_old_make_obj_damage_value,    :summon_equip,                 :active],
        [:albert_summon_equip_make_obj_damage_value, :battle_formula,               :active],
        [:albert_bfrt_old_make_obj_damage_value,     :integer_fix,                  :active],
        [:albert_int_damage_make_obj_damage_value,   :yez_skilllevel,               :active],
        [:make_obj_damage_value_jpsl,                :cover,                        :active],
        [:lusitano_cover_make_obj_damage_value,      :custom_damage,                :active],
        # pre-Custom historical aliases。KGC Equipment wrapper 本體被 direct redefine 覆蓋，沒有保存成可呼叫 alias。
        [:make_obj_damage_value_KGC_AddEquipmentOptions, :skill_activation_legacy,  :shadow],
        [:crmsn_make_obj_damage_value,               :battle_result_stats_legacy,   :shadow],
        [:make_obj_damage_value_BBL,                 :vx_base_legacy,               :shadow]
      ]
    end

    def p45h_probe_base_name(method_name)
      ("fs_p45h_probe_base_" + method_name.to_s).to_sym
    end

    def p45h_scope?(target, user, obj)
      return false unless @p45h_capture_active
      return false if target == nil || user == nil || obj == nil
      return false unless obj.is_a?(RPG::Skill)
      return false unless obj.id.to_i == P45H_SKILL_ID
      return false unless @p45h_target_oid.to_i == target.object_id.to_i
      return false unless @p45h_user_oid.to_i == user.object_id.to_i
      true
    rescue
      false
    end

    def p45h_damage_snapshot(target)
      {
        :hp_damage=>(target.instance_variable_get(:@hp_damage) rescue nil),
        :mp_damage=>(target.instance_variable_get(:@mp_damage) rescue nil),
        :weak=>(target.instance_variable_get(:@weak) rescue nil),
        :strong=>(target.instance_variable_get(:@strong) rescue nil),
        :critical=>(target.instance_variable_get(:@critical) rescue nil)
      }
    rescue
      {}
    end

    def p45h_record(phase, layer, segment, target)
      @p45h_events ||= []
      @p45h_entries ||= []
      @p45h_exits ||= []
      @p45h_shadow_entries ||= []
      snap = p45h_damage_snapshot(target)
      @p45h_events << [phase, layer, segment, snap]
      if phase == :enter
        if segment == :active
          @p45h_entries << layer
        else
          @p45h_shadow_entries << layer
        end
      elsif phase == :exit && segment == :active
        @p45h_exits << layer
      end
    rescue
    end

    def p45h_install_one(method_name, layer, segment)
      base_name = p45h_probe_base_name(method_name)
      return true if Game_Battler.method_defined?(base_name)
      return false unless Game_Battler.method_defined?(method_name)
      Game_Battler.class_eval do
        alias_method base_name, method_name
        define_method(method_name) do |user, obj|
          scoped = FS_TEST_HARNESS.p45h_scope?(self, user, obj)
          FS_TEST_HARNESS.p45h_record(:enter, layer, segment, self) if scoped
          result = nil
          begin
            result = send(base_name, user, obj)
          ensure
            FS_TEST_HARNESS.p45h_record(:exit, layer, segment, self) if scoped
          end
          result
        end
      end
      true
    rescue Exception => e
      exception(e, "p45h_install_one:#{method_name}")
      false
    end

    def p45h_install_probes
      return @p45h_probe_install_ready if @p45h_probe_install_done
      @p45h_probe_install_done = true
      missing = []
      failed = []
      p45h_probe_specs.each do |spec|
        method_name = spec[0]
        layer = spec[1]
        segment = spec[2]
        unless Game_Battler.method_defined?(method_name)
          missing << [method_name, layer, segment]
          next
        end
        failed << [method_name, layer, segment] unless p45h_install_one(method_name, layer, segment)
      end
      @p45h_probe_missing = missing
      @p45h_probe_failed = failed
      @p45h_probe_install_ready = missing.empty? && failed.empty?
      log("[DAMAGE_PROBE_INSTALL] specs=#{p45h_probe_specs.size} missing=#{missing.inspect} failed=#{failed.inspect} ready=#{@p45h_probe_install_ready}")
      assert("Phase45H Damage provenance probes install on every expected callable boundary",
             @p45h_probe_install_ready,
             "missing=#{missing.inspect} failed=#{failed.inspect}")
      @p45h_probe_install_ready
    end

    def p45h_begin_capture(subject, target)
      @p45h_events = []
      @p45h_entries = []
      @p45h_exits = []
      @p45h_shadow_entries = []
      @p45h_user_oid = subject.object_id
      @p45h_target_oid = target.object_id
      @p45h_capture_active = true
      log("[DAMAGE_CAPTURE] begin skill=#{P45H_SKILL_ID} user_oid=#{@p45h_user_oid} target_oid=#{@p45h_target_oid}")
      true
    rescue Exception => e
      exception(e, "p45h_begin_capture")
      false
    end

    def p45h_end_capture
      @p45h_capture_active = false
      true
    end

    def p45h_analyze_capture
      p45h_end_capture
      entries = (@p45h_entries || []).clone
      exits = (@p45h_exits || []).clone
      shadow = (@p45h_shadow_entries || []).clone
      expected = p45h_active_outer_to_base
      runtime_ok = entries == expected
      reverse_ok = exits == expected.reverse
      counts = {}
      entries.each { |x| counts[x] = counts.fetch(x, 0) + 1 }
      exact_once = expected.all? { |x| counts[x].to_i == 1 } && counts.size == expected.size
      shadow_ok = shadow.empty?
      damage_exit = nil
      events = @p45h_events || []
      events.reverse_each do |event|
        if event[0] == :exit && event[1] == :marked_command
          damage_exit = event[3]
          break
        end
      end
      damage_ok = damage_exit != nil && damage_exit[:hp_damage].to_i == 102

      assert("Phase45H make_obj_damage_value active runtime outer-to-base order exact", runtime_ok,
             "expected=#{expected.inspect} actual=#{entries.inspect}")
      assert("Phase45H make_obj_damage_value return order exact reverse", reverse_ok,
             "expected=#{expected.reverse.inspect} actual=#{exits.inspect}")
      assert("Phase45H every active Damage layer executes exactly once", exact_once,
             "counts=#{counts.inspect}")
      assert("Phase45H pre-Custom historical aliases are shadowed on current Skill100 path", shadow_ok,
             "unexpected_shadow_entries=#{shadow.inspect}")
      assert("Phase45H Damage provenance preserves sealed Skill100 damage102", damage_ok,
             "outer_exit=#{damage_exit.inspect}")

      base_to_outer = entries.reverse
      ready = runtime_ok && reverse_ok && exact_once && shadow_ok && damage_ok
      log("[DAMAGE_CHAIN] active_outer_to_base=#{entries.inspect} counts=#{counts.inspect} " +
          "shadow_calls=#{shadow.inspect} ready=#{ready}")
      log("[DAMAGE_CHAIN_BASE_TO_OUTER] active=#{base_to_outer.inspect} " +
          "shadowed_pre_custom=[:vx_base_legacy,:battle_result_stats_legacy,:skill_activation_legacy,:kgc_equipment_wrapper] " +
          "boundary=:custom_damage_direct_redefine ready=#{ready}")
      assert("Phase45H make_obj_damage_value staged-chain provenance diagnostic completed", ready,
             "base_to_outer=#{base_to_outer.inspect} shadow=#{shadow.inspect}")
      @p45h_ready = ready
      ready
    rescue Exception => e
      p45h_end_capture rescue nil
      exception(e, "p45h_analyze_capture")
      @p45h_ready = false
      assert("Phase45H make_obj_damage_value staged-chain provenance diagnostic completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase45h_prepare_battle_fixture_on_map_base)
      alias fs_phase45h_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      install_ok = p45h_install_probes
      result = fs_phase45h_prepare_battle_fixture_on_map_base
      assert("Phase45H Damage provenance infrastructure ready before battle", install_ok,
             "missing=#{@p45h_probe_missing.inspect} failed=#{@p45h_probe_failed.inspect}")
      result
    end

    unless method_defined?(:fs_phase45h_core_prepare_action_state_base)
      alias fs_phase45h_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45h_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
        ok = p45h_begin_capture(subject, target)
        assert("Phase45H Skill100 real Battle Damage provenance capture armed", ok,
               "subject=#{subject} target=#{target}")
      end
      result
    end

    unless method_defined?(:fs_phase45h_core_finalize_fixture_base)
      alias fs_phase45h_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45h_core_finalize_fixture_base
      p45h_analyze_capture if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
      result
    rescue Exception => e
      p45h_end_capture rescue nil
      exception(e, "p45h_core_finalize_current_fixture")
      assert("Phase45H make_obj_damage_value staged-chain provenance diagnostic completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase45h_restore_pending_base)
      alias fs_phase45h_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45h_restore_pending_base
      if result
        p45h_end_capture rescue nil
        @p45h_events = []
        @p45h_entries = []
        @p45h_exits = []
        @p45h_shadow_entries = []
      end
      result
    end
  end
end
end


#==============================================================================
# Phase45I — execute_damage Provenance（TEST-only）
#==============================================================================
if $TEST
module FS_TEST_HARNESS
  class << self
    P45I_SKILL_ID = 100 unless const_defined?(:P45I_SKILL_ID)

    def p45i_runtime_outer_to_base
      [
        :test_harness,
        :marked_command,
        :ivy_clone,
        :antagonist,
        :mechanic_expansion,
        :character_mechanic,
        :combo_core,
        :dps_order_fix,
        :integer_fix,
        :counterattack,
        :recovery_block,
        :custom_status_properties,
        :dynamic_threat,
        :kgc_overdrive,
        :sideview,
        :dps,
        :vx_base
      ]
    end

    def p45i_formal_outer_to_base
      list = p45i_runtime_outer_to_base.clone
      list.delete(:test_harness)
      list
    end

    # [method_name, layer, segment]
    # Ruby alias 在建立時保存當下 method body，因此可逐層透明掛 probe。
    def p45i_probe_specs
      [
        [:execute_damage,                       :test_harness,             :test],
        [:fs_test_harness_execute_damage,       :marked_command,           :formal],
        [:fs_mc_original_execute_damage,        :ivy_clone,                :formal],
        [:albert_ic_old_execute_damage,         :antagonist,               :formal],
        [:albert_ant_old_execute_damage,        :mechanic_expansion,       :formal],
        [:albert_mx_old_execute_damage,         :character_mechanic,       :formal],
        [:albert_cc_old_execute_damage,         :combo_core,               :formal],
        [:albert_combo_old_execute_damage,      :dps_order_fix,            :formal],
        [:zyy_kgc_dps_fix,                      :integer_fix,              :formal],
        [:albert_int_damage_execute_damage,     :counterattack,            :formal],
        [:execute_damage_sss_counterattack,     :recovery_block,           :formal],
        [:rx_rgss2b20_execute_damage,           :custom_status_properties, :formal],
        [:execute_damage_csp,                   :dynamic_threat,           :formal],
        [:albert_dynamic21_execute_damage,      :kgc_overdrive,            :formal],
        [:execute_damage_KGC_OverDrive,         :sideview,                 :formal],
        [:execute_damage_n01,                   :dps,                      :formal],
        [:zyynov_execute_damage,                :vx_base,                  :formal]
      ]
    end

    def p45i_probe_base_name(method_name)
      ("fs_p45i_probe_base_" + method_name.to_s).to_sym
    end

    def p45i_scope?(target, user)
      return false unless @p45i_capture_active
      return false if target == nil || user == nil
      return false unless @p45i_target_oid.to_i == target.object_id.to_i
      return false unless @p45i_user_oid.to_i == user.object_id.to_i
      true
    rescue
      false
    end

    def p45i_snapshot(target, user)
      data = {}
      data[:target_hp] = target.respond_to?(:hp) ? target.hp.to_i : nil
      data[:target_mp] = target.respond_to?(:mp) ? target.mp.to_i : nil
      data[:hp_damage] = (target.instance_variable_get(:@hp_damage) rescue nil)
      data[:mp_damage] = (target.instance_variable_get(:@mp_damage) rescue nil)
      data[:absorbed] = (target.instance_variable_get(:@absorbed) rescue nil)
      data[:user_hp] = user.respond_to?(:hp) ? user.hp.to_i : nil
      data[:user_mp] = user.respond_to?(:mp) ? user.mp.to_i : nil
      data[:user_overdrive] = user.respond_to?(:overdrive) ? user.overdrive.to_i : nil
      data[:user_dps] = user.respond_to?(:dps) ? user.dps.to_i : nil
      data[:user_total_damage] = user.respond_to?(:total_damage) ? user.total_damage.to_i : nil
      data[:user_dynamic_damage_raw] = (user.instance_variable_get(:@albert_dynamic21_damage) rescue nil)
      data[:user_hp_damage_raw] = (user.instance_variable_get(:@hp_damage) rescue nil)
      data[:target_counterattack_raw] = (target.instance_variable_get(:@counterattack) rescue nil)
      data[:target_rx_hp_cannot_heal_raw] = (target.instance_variable_get(:@rx_hp_cannot_heal) rescue nil)
      data[:user_mc_command_hit_raw] = (user.instance_variable_get(:@fs_mc_command_hit) rescue nil)
      data[:user_mc_mark_awarded_raw] = (user.instance_variable_get(:@fs_mc_mark_od_awarded) rescue nil)
      data[:target_mx_stored_cover_raw] = (target.instance_variable_get(:@albert_mx_stored_cover_damage) rescue nil)
      data[:target_ic_fatal_cover_raw] = (target.instance_variable_get(:@albert_ic_fatal_cover_used) rescue nil)
      data
    rescue
      {}
    end

    def p45i_record(phase, layer, segment, target, user)
      @p45i_events ||= []
      @p45i_entries ||= []
      @p45i_exits ||= []
      snap = p45i_snapshot(target, user)
      @p45i_events << [phase, layer, segment, snap]
      @p45i_entries << layer if phase == :enter
      @p45i_exits << layer if phase == :exit
    rescue
    end

    def p45i_install_one(method_name, layer, segment)
      base_name = p45i_probe_base_name(method_name)
      return true if Game_Battler.method_defined?(base_name)
      return false unless Game_Battler.method_defined?(method_name)
      Game_Battler.class_eval do
        alias_method base_name, method_name
        define_method(method_name) do |user|
          scoped = FS_TEST_HARNESS.p45i_scope?(self, user)
          FS_TEST_HARNESS.p45i_record(:enter, layer, segment, self, user) if scoped
          result = nil
          begin
            result = send(base_name, user)
          ensure
            FS_TEST_HARNESS.p45i_record(:exit, layer, segment, self, user) if scoped
          end
          result
        end
      end
      true
    rescue Exception => e
      exception(e, "p45i_install_one:#{method_name}")
      false
    end

    def p45i_install_probes
      return @p45i_probe_install_ready if @p45i_probe_install_done
      @p45i_probe_install_done = true
      missing = []
      failed = []
      p45i_probe_specs.each do |spec|
        method_name = spec[0]
        layer = spec[1]
        segment = spec[2]
        unless Game_Battler.method_defined?(method_name)
          missing << [method_name, layer, segment]
          next
        end
        failed << [method_name, layer, segment] unless p45i_install_one(method_name, layer, segment)
      end
      @p45i_probe_missing = missing
      @p45i_probe_failed = failed
      @p45i_probe_install_ready = missing.empty? && failed.empty?
      log("[EXECUTE_DAMAGE_PROBE_INSTALL] specs=#{p45i_probe_specs.size} missing=#{missing.inspect} failed=#{failed.inspect} ready=#{@p45i_probe_install_ready}")
      assert("Phase45I execute_damage provenance probes install on every expected runtime boundary",
             @p45i_probe_install_ready,
             "missing=#{missing.inspect} failed=#{failed.inspect}")
      @p45i_probe_install_ready
    end

    def p45i_begin_capture(subject, target)
      @p45i_events = []
      @p45i_entries = []
      @p45i_exits = []
      @p45i_user_oid = subject.object_id
      @p45i_target_oid = target.object_id
      @p45i_capture_active = true
      log("[EXECUTE_DAMAGE_CAPTURE] begin skill=#{P45I_SKILL_ID} user_oid=#{@p45i_user_oid} target_oid=#{@p45i_target_oid}")
      true
    rescue Exception => e
      exception(e, "p45i_begin_capture")
      false
    end

    def p45i_end_capture
      @p45i_capture_active = false
      true
    end

    def p45i_analyze_capture
      p45i_end_capture
      entries = (@p45i_entries || []).clone
      exits = (@p45i_exits || []).clone
      expected_runtime = p45i_runtime_outer_to_base
      expected_formal = p45i_formal_outer_to_base
      runtime_ok = entries == expected_runtime
      reverse_ok = exits == expected_runtime.reverse
      formal_entries = entries.find_all { |x| x != :test_harness }
      formal_ok = formal_entries == expected_formal
      counts = {}
      entries.each { |x| counts[x] = counts.fetch(x, 0) + 1 }
      exact_once = expected_runtime.all? { |x| counts[x].to_i == 1 } && counts.size == expected_runtime.size

      outer_enter = nil
      outer_exit = nil
      events = @p45i_events || []
      events.each do |event|
        outer_enter = event[3] if outer_enter == nil && event[0] == :enter && event[1] == :test_harness
        outer_exit = event[3] if event[0] == :exit && event[1] == :test_harness
      end
      hp_delta = nil
      if outer_enter != nil && outer_exit != nil && outer_enter[:target_hp] != nil && outer_exit[:target_hp] != nil
        hp_delta = outer_enter[:target_hp].to_i - outer_exit[:target_hp].to_i
      end
      damage_ok = hp_delta.to_i == 102 && outer_enter != nil && outer_enter[:hp_damage].to_i == 102

      assert("Phase45I execute_damage runtime outer-to-base order exact", runtime_ok,
             "expected=#{expected_runtime.inspect} actual=#{entries.inspect}")
      assert("Phase45I execute_damage return order exact reverse", reverse_ok,
             "expected=#{expected_runtime.reverse.inspect} actual=#{exits.inspect}")
      assert("Phase45I execute_damage Formal projection excludes only TEST Harness layer", formal_ok,
             "expected=#{expected_formal.inspect} actual=#{formal_entries.inspect}")
      assert("Phase45I every execute_damage runtime layer executes exactly once", exact_once,
             "counts=#{counts.inspect}")
      assert("Phase45I execute_damage preserves sealed Skill100 HP loss 102", damage_ok,
             "outer_enter=#{outer_enter.inspect} outer_exit=#{outer_exit.inspect} hp_delta=#{hp_delta.inspect}")

      ready = runtime_ok && reverse_ok && formal_ok && exact_once && damage_ok
      log("[EXECUTE_DAMAGE_CHAIN] runtime_outer_to_base=#{entries.inspect} formal_outer_to_base=#{formal_entries.inspect} counts=#{counts.inspect} ready=#{ready}")
      log("[EXECUTE_DAMAGE_CHAIN_BASE_TO_OUTER] formal=#{formal_entries.reverse.inspect} test_outer=[:test_harness] ready=#{ready}")
      assert("Phase45I execute_damage staged-chain provenance diagnostic completed", ready,
             "formal_base_to_outer=#{formal_entries.reverse.inspect}")
      @p45i_ready = ready
      ready
    rescue Exception => e
      p45i_end_capture rescue nil
      exception(e, "p45i_analyze_capture")
      @p45i_ready = false
      assert("Phase45I execute_damage staged-chain provenance diagnostic completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase45i_prepare_battle_fixture_on_map_base)
      alias fs_phase45i_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      install_ok = p45i_install_probes
      result = fs_phase45i_prepare_battle_fixture_on_map_base
      assert("Phase45I execute_damage provenance infrastructure ready before battle", install_ok,
             "missing=#{@p45i_probe_missing.inspect} failed=#{@p45i_probe_failed.inspect}")
      result
    end

    unless method_defined?(:fs_phase45i_core_prepare_action_state_base)
      alias fs_phase45i_core_prepare_action_state_base core_prepare_action_state
    end
    def core_prepare_action_state(fixture, subject, target)
      result = fs_phase45i_core_prepare_action_state_base(fixture, subject, target)
      if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
        ok = p45i_begin_capture(subject, target)
        assert("Phase45I Skill100 real Battle execute_damage provenance capture armed", ok,
               "subject=#{subject} target=#{target}")
      end
      result
    end

    unless method_defined?(:fs_phase45i_core_finalize_fixture_base)
      alias fs_phase45i_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45i_core_finalize_fixture_base
      p45i_analyze_capture if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
      result
    rescue Exception => e
      p45i_end_capture rescue nil
      exception(e, "p45i_core_finalize_current_fixture")
      assert("Phase45I execute_damage staged-chain provenance diagnostic completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase45i_restore_pending_base)
      alias fs_phase45i_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45i_restore_pending_base
      if result
        p45i_end_capture rescue nil
        @p45i_events = []
        @p45i_entries = []
        @p45i_exits = []
      end
      result
    end
  end
end
end


#==============================================================================
# Phase45J — execute_damage Semantic Ownership I（TEST-only）
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45J_STATE_SLOT = 55 unless const_defined?(:P45J_STATE_SLOT)
  P45J_BASE_DAMAGE = 102 unless const_defined?(:P45J_BASE_DAMAGE)

  # TEST-only detached actor that exposes the historical total_damage API so the
  # KGC↔DPS order-fix wrapper can be proven without mutating Formal actor classes.
  class P45J_TotalDamageActor < Game_Actor
    attr_accessor :total_damage
  end

  class << self
    def p45j_event(events, phase, layer)
      list = events || []
      list.each do |event|
        next unless event != nil && event[0] == phase && event[1] == layer
        return event[3]
      end
      nil
    rescue
      nil
    end

    def p45j_projection(snap)
      return nil if snap == nil
      keys = [
        :target_hp, :target_mp, :hp_damage, :mp_damage, :absorbed,
        :user_hp, :user_mp, :user_overdrive, :user_dps, :user_total_damage,
        :user_dynamic_damage_raw, :user_hp_damage_raw, :target_counterattack_raw,
        :target_rx_hp_cannot_heal_raw, :user_mc_command_hit_raw,
        :user_mc_mark_awarded_raw, :target_mx_stored_cover_raw,
        :target_ic_fatal_cover_raw
      ]
      result = {}
      keys.each { |key| result[key] = snap[key] }
      result
    rescue
      nil
    end

    def p45j_boundary_pass?(events, layer, inner)
      outer_enter = p45j_event(events, :enter, layer)
      inner_enter = p45j_event(events, :enter, inner)
      inner_exit = p45j_event(events, :exit, inner)
      outer_exit = p45j_event(events, :exit, layer)
      return false if outer_enter == nil || inner_enter == nil ||
                      inner_exit == nil || outer_exit == nil
      p45j_projection(outer_enter) == p45j_projection(inner_enter) &&
        p45j_projection(inner_exit) == p45j_projection(outer_exit)
    rescue
      false
    end

    def p45j_analyze_skill100_semantics
      events = @p45i_events || []
      dps_enter = p45j_event(events, :enter, :dps)
      vx_enter = p45j_event(events, :enter, :vx_base)
      vx_exit = p45j_event(events, :exit, :vx_base)
      dynamic_enter = p45j_event(events, :enter, :dynamic_threat)
      kgc_enter = p45j_event(events, :enter, :kgc_overdrive)
      kgc_exit = p45j_event(events, :exit, :kgc_overdrive)

      ready_objects = dps_enter != nil && vx_enter != nil && vx_exit != nil &&
                      dynamic_enter != nil && kgc_enter != nil && kgc_exit != nil
      assert("Phase45J Skill100 semantic boundary snapshots ready", ready_objects,
             "events=#{events.size}")

      vx_ok = ready_objects &&
              vx_enter[:target_hp].to_i - vx_exit[:target_hp].to_i == P45J_BASE_DAMAGE &&
              vx_enter[:hp_damage].to_i == P45J_BASE_DAMAGE
      assert("Phase45J VX Base owns final HP application for sealed Skill100", vx_ok,
             "enter=#{vx_enter.inspect} exit=#{vx_exit.inspect}")

      dps_before = dps_enter == nil ? nil : dps_enter[:user_dps]
      dps_after = vx_enter == nil ? nil : vx_enter[:user_dps]
      dps_ok = dps_before != nil && dps_after != nil &&
               dps_after.to_i - dps_before.to_i == P45J_BASE_DAMAGE
      assert("Phase45J DPS layer owns pre-base attacker DPS accumulation", dps_ok,
             "before=#{dps_before.inspect} after=#{dps_after.inspect}")

      threat_before = dynamic_enter == nil ? nil : dynamic_enter[:user_dynamic_damage_raw]
      threat_after = kgc_enter == nil ? nil : kgc_enter[:user_dynamic_damage_raw]
      threat_ok = threat_before != nil && threat_after != nil &&
                  threat_after.to_i - threat_before.to_i == P45J_BASE_DAMAGE
      assert("Phase45J DynamicThreat owns actor damage accumulation before KGC OD", threat_ok,
             "before=#{threat_before.inspect} after=#{threat_after.inspect}")

      od_before = kgc_enter == nil ? nil : kgc_enter[:user_overdrive]
      od_after = kgc_exit == nil ? nil : kgc_exit[:user_overdrive]
      od_ok = od_before != nil && od_after != nil && od_after.to_i > od_before.to_i
      assert("Phase45J KGC OverDrive owns post-damage attacker OD gain", od_ok,
             "before=#{od_before.inspect} after=#{od_after.inspect}")

      pass_pairs = [
        [:marked_command, :ivy_clone],
        [:ivy_clone, :antagonist],
        [:antagonist, :mechanic_expansion],
        [:mechanic_expansion, :character_mechanic],
        [:character_mechanic, :combo_core],
        [:combo_core, :dps_order_fix],
        [:dps_order_fix, :integer_fix],
        [:integer_fix, :counterattack],
        [:counterattack, :recovery_block],
        [:recovery_block, :custom_status_properties],
        [:custom_status_properties, :dynamic_threat],
        [:sideview, :dps]
      ]
      pass_results = {}
      pass_pairs.each do |pair|
        pass_results[pair[0]] = p45j_boundary_pass?(events, pair[0], pair[1])
      end
      pass_ok = pass_results.values.all? { |value| value == true }
      assert("Phase45J Skill100 selected-case non-triggered layers are boundary pass-through",
             pass_ok, "pass=#{pass_results.inspect}")

      ready = ready_objects && vx_ok && dps_ok && threat_ok && od_ok && pass_ok
      @p45j_skill100_ready = ready
      log("[EXECUTE_DAMAGE_OWNER] case=skill100 vx_base=:hp_apply dps=:dps_accumulate " +
          "dynamic_threat=:actor_damage_accumulate kgc_overdrive=:od_gain " +
          "selected_pass_through=#{pass_results.keys.inspect} ready=#{ready}")
      assert("Phase45J Skill100 execute_damage semantic ownership map completed", ready,
             "vx=#{vx_ok} dps=#{dps_ok} threat=#{threat_ok} od=#{od_ok} pass=#{pass_ok}")
      ready
    rescue Exception => e
      exception(e, "p45j_analyze_skill100_semantics")
      @p45j_skill100_ready = false
      assert("Phase45J Skill100 execute_damage semantic ownership map completed", false, e.message)
      false
    end

    def p45j_enemy_id
      return p45g_state_enemy_id if respond_to?(:p45g_state_enemy_id)
      return 1 if $data_enemies != nil && $data_enemies[1] != nil
      i = 1
      while $data_enemies != nil && i < $data_enemies.size
        return i if $data_enemies[i] != nil
        i += 1
      end
      0
    rescue
      0
    end

    def p45j_enemy
      enemy_id = p45j_enemy_id
      return nil if enemy_id.to_i <= 0
      Game_Enemy.new(0, enemy_id)
    rescue Exception => e
      exception(e, "p45j_enemy")
      nil
    end

    def p45j_actor
      Game_Actor.new(1)
    rescue Exception => e
      exception(e, "p45j_actor")
      nil
    end

    def p45j_total_actor
      actor = P45J_TotalDamageActor.new(1)
      actor.total_damage = 0
      actor
    rescue Exception => e
      exception(e, "p45j_total_actor")
      nil
    end

    def p45j_prepare_damage(target, damage, absorbed)
      return false if target == nil
      target.instance_variable_set(:@hp_damage, damage)
      target.instance_variable_set(:@mp_damage, 0)
      target.instance_variable_set(:@absorbed, absorbed ? true : false)
      true
    rescue
      false
    end

    def p45j_call_with_active(user, target, method_name)
      scene = $scene
      old_active = nil
      can_set = scene != nil && scene.respond_to?(:active_battler) &&
                scene.respond_to?(:active_battler=)
      old_active = scene.active_battler if can_set
      scene.active_battler = user if can_set
      result = target.send(method_name, user)
      result
    ensure
      scene.active_battler = old_active if can_set
    end

    def p45j_run_recovery_block_fixture
      user_full = p45j_actor
      target_full = p45j_enemy
      user_bypass = p45j_actor
      target_bypass = p45j_enemy
      ready_objects = user_full != nil && target_full != nil &&
                      user_bypass != nil && target_bypass != nil &&
                      target_full.respond_to?(:rx_rgss2b20_execute_damage)
      assert("Phase45J RecoveryBlock detached fixture ready", ready_objects)
      return false unless ready_objects

      start_full = [target_full.maxhp.to_i / 2, 1].max
      start_bypass = [target_bypass.maxhp.to_i / 2, 1].max
      target_full.hp = start_full
      target_bypass.hp = start_bypass
      target_full.instance_variable_set(:@rx_hp_cannot_heal, true)
      target_bypass.instance_variable_set(:@rx_hp_cannot_heal, true)
      p45j_prepare_damage(target_full, -30, false)
      p45j_prepare_damage(target_bypass, -30, false)

      p45j_call_with_active(user_full, target_full, :execute_damage)
      full_ok = target_full.hp.to_i == start_full &&
                target_full.instance_variable_get(:@hp_damage).to_i == 0
      assert("Phase45J RecoveryBlock full chain zeros prohibited HP recovery", full_ok,
             "hp=#{start_full}->#{target_full.hp} dmg=#{target_full.instance_variable_get(:@hp_damage).inspect}")

      p45j_call_with_active(user_bypass, target_bypass, :rx_rgss2b20_execute_damage)
      bypass_ok = target_bypass.hp.to_i > start_bypass &&
                  target_bypass.instance_variable_get(:@hp_damage).to_i < 0
      assert("Phase45J RecoveryBlock inner alias bypass proves recovery would otherwise occur", bypass_ok,
             "hp=#{start_bypass}->#{target_bypass.hp} dmg=#{target_bypass.instance_variable_get(:@hp_damage).inspect}")

      ready = full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER] case=recovery_block owner=:recovery_block full_block=#{full_ok} inner_heal=#{bypass_ok} ready=#{ready}")
      assert("Phase45J RecoveryBlock semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45j_run_recovery_block_fixture")
      assert("Phase45J RecoveryBlock semantic ownership completed", false, e.message)
      false
    end

    def p45j_run_counter_fixture
      state = $data_states[P45J_STATE_SLOT] rescue nil
      user_full = p45j_actor
      target_full = p45j_enemy
      user_bypass = p45j_actor
      target_bypass = p45j_enemy
      ready_objects = state != nil && user_full != nil && target_full != nil &&
                      user_bypass != nil && target_bypass != nil &&
                      target_full.respond_to?(:execute_damage_sss_counterattack)
      assert("Phase45J Counterattack detached fixture/state ready", ready_objects,
             "state=#{P45J_STATE_SLOT}")
      return false unless ready_objects

      note_before = state.note.to_s
      cache_snap = p45g_ivar_snapshot(state, "@counterattack")
      state.note = "<counterattack>"
      state.send(:remove_instance_variable, "@counterattack") rescue nil
      state_ready = state.respond_to?(:counterattack) && state.counterattack
      assert("Phase45J Counterattack synthetic State parser enabled", state_ready,
             "state=#{P45J_STATE_SLOT}")
      return false unless state_ready

      [target_full, target_bypass].each do |target|
        list = target.instance_variable_get(:@states) rescue nil
        list = [] if list == nil
        list << P45J_STATE_SLOT unless list.include?(P45J_STATE_SLOT)
        target.instance_variable_set(:@states, list)
        target.counterattack = nil if target.respond_to?(:counterattack=)
        p45j_prepare_damage(target, 10, false)
      end

      p45j_call_with_active(user_full, target_full, :execute_damage)
      full_ok = target_full.respond_to?(:counterattack) && target_full.counterattack == true
      assert("Phase45J Counterattack wrapper owns post-damage counter flag creation", full_ok,
             "counter=#{target_full.counterattack.inspect}")

      p45j_call_with_active(user_bypass, target_bypass, :execute_damage_sss_counterattack)
      bypass_ok = !target_bypass.respond_to?(:counterattack) || target_bypass.counterattack != true
      assert("Phase45J Counterattack inner alias bypass leaves counter flag unset", bypass_ok,
             "counter=#{target_bypass.respond_to?(:counterattack) ? target_bypass.counterattack.inspect : nil}")

      state.note = note_before
      cache_restore = p45g_restore_ivar(state, "@counterattack", cache_snap)
      state_restore = state.note.to_s == note_before && cache_restore
      assert("Phase45J Counterattack synthetic State slot/cache restored exactly", state_restore,
             "state=#{P45J_STATE_SLOT}")

      ready = full_ok && bypass_ok && state_restore
      log("[EXECUTE_DAMAGE_OWNER] case=counterattack owner=:counterattack full=#{full_ok} bypass=#{bypass_ok} restore=#{state_restore} ready=#{ready}")
      assert("Phase45J Counterattack semantic ownership completed", ready)
      ready
    rescue Exception => e
      begin
        state.note = note_before if state != nil && note_before != nil
        p45g_restore_ivar(state, "@counterattack", cache_snap) if state != nil && cache_snap != nil
      rescue
      end
      exception(e, "p45j_run_counter_fixture")
      assert("Phase45J Counterattack semantic ownership completed", false, e.message)
      false
    end

    def p45j_run_sideview_absorb_fixture
      user_full = p45j_actor
      target_full = p45j_enemy
      user_bypass = p45j_actor
      target_bypass = p45j_enemy
      ready_objects = user_full != nil && target_full != nil &&
                      user_bypass != nil && target_bypass != nil &&
                      target_full.respond_to?(:execute_damage_KGC_OverDrive) &&
                      target_bypass.respond_to?(:execute_damage_n01)
      assert("Phase45J Sideview absorb detached fixture ready", ready_objects)
      return false unless ready_objects

      user_full.instance_variable_set(:@hp_damage, 0)
      user_bypass.instance_variable_set(:@hp_damage, 0)
      p45j_prepare_damage(target_full, 20, true)
      p45j_prepare_damage(target_bypass, 20, true)

      p45j_call_with_active(user_full, target_full, :execute_damage_KGC_OverDrive)
      full_display = user_full.instance_variable_get(:@hp_damage) rescue nil
      full_ok = full_display.to_i == -20
      assert("Phase45J Sideview owns absorbed user damage popup sign transform", full_ok,
             "user_hp_damage=#{full_display.inspect}")

      p45j_call_with_active(user_bypass, target_bypass, :execute_damage_n01)
      bypass_display = user_bypass.instance_variable_get(:@hp_damage) rescue nil
      bypass_ok = bypass_display.to_i != -20
      assert("Phase45J Sideview inner DPS alias bypass omits absorbed popup transform", bypass_ok,
             "user_hp_damage=#{bypass_display.inspect}")

      ready = full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER] case=sideview_absorb owner=:sideview full=#{full_display.inspect} bypass=#{bypass_display.inspect} ready=#{ready}")
      assert("Phase45J Sideview absorb semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45j_run_sideview_absorb_fixture")
      assert("Phase45J Sideview absorb semantic ownership completed", false, e.message)
      false
    end

    def p45j_run_integer_fix_fixture
      user_full = p45j_actor
      target_full = p45j_enemy
      user_bypass = p45j_actor
      target_bypass = p45j_enemy
      ready_objects = user_full != nil && target_full != nil &&
                      user_bypass != nil && target_bypass != nil &&
                      target_full.respond_to?(:zyy_kgc_dps_fix) &&
                      target_bypass.respond_to?(:albert_int_damage_execute_damage)
      assert("Phase45J IntegerFix detached fixture ready", ready_objects)
      return false unless ready_objects

      p45j_prepare_damage(target_full, 10.75, false)
      p45j_prepare_damage(target_bypass, 10.75, false)

      p45j_call_with_active(user_full, target_full, :zyy_kgc_dps_fix)
      full_value = target_full.instance_variable_get(:@hp_damage) rescue nil
      full_ok = full_value.is_a?(Integer) && full_value == 10
      assert("Phase45J IntegerFix normalizes fractional HP damage before inner execute", full_ok,
             "value=#{full_value.inspect}")

      p45j_call_with_active(user_bypass, target_bypass, :albert_int_damage_execute_damage)
      bypass_value = target_bypass.instance_variable_get(:@hp_damage) rescue nil
      bypass_ok = bypass_value.is_a?(Numeric) && bypass_value.to_i == 10 &&
                  bypass_value != bypass_value.to_i
      assert("Phase45J IntegerFix inner alias bypass preserves fractional damage value", bypass_ok,
             "value=#{bypass_value.inspect}")

      ready = full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER] case=integer_fix owner=:integer_fix full=#{full_value.inspect} bypass=#{bypass_value.inspect} ready=#{ready}")
      assert("Phase45J IntegerFix semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45j_run_integer_fix_fixture")
      assert("Phase45J IntegerFix semantic ownership completed", false, e.message)
      false
    end

    def p45j_run_dps_order_fix_fixture
      user_full = p45j_total_actor
      target_full = p45j_enemy
      user_bypass = p45j_total_actor
      target_bypass = p45j_enemy
      ready_objects = user_full != nil && target_full != nil &&
                      user_bypass != nil && target_bypass != nil &&
                      target_full.respond_to?(:albert_combo_old_execute_damage) &&
                      target_bypass.respond_to?(:zyy_kgc_dps_fix)
      assert("Phase45J KGC-DPS order-fix detached total_damage fixture ready", ready_objects)
      return false unless ready_objects

      p45j_prepare_damage(target_full, 15, false)
      p45j_prepare_damage(target_bypass, 15, false)

      p45j_call_with_active(user_full, target_full, :albert_combo_old_execute_damage)
      full_total = user_full.total_damage.to_i
      full_ok = full_total == 15
      assert("Phase45J KGC-DPS order-fix owns post-inner total_damage accumulation", full_ok,
             "total=#{full_total}")

      p45j_call_with_active(user_bypass, target_bypass, :zyy_kgc_dps_fix)
      bypass_total = user_bypass.total_damage.to_i
      bypass_ok = bypass_total == 0
      assert("Phase45J KGC-DPS order-fix inner IntegerFix alias bypass leaves total_damage unchanged", bypass_ok,
             "total=#{bypass_total}")

      ready = full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER] case=dps_order_fix owner=:dps_order_fix full=#{full_total} bypass=#{bypass_total} ready=#{ready}")
      assert("Phase45J KGC-DPS order-fix semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45j_run_dps_order_fix_fixture")
      assert("Phase45J KGC-DPS order-fix semantic ownership completed", false, e.message)
      false
    end

    def p45j_run_dedicated_suite
      return @p45j_suite_ready if @p45j_suite_ran
      @p45j_suite_ran = true
      recovery = p45j_run_recovery_block_fixture
      counter = p45j_run_counter_fixture
      sideview = p45j_run_sideview_absorb_fixture
      integer_fix = p45j_run_integer_fix_fixture
      dps_order = p45j_run_dps_order_fix_fixture
      skill100 = @p45j_skill100_ready == true

      ready = skill100 && recovery && counter && sideview && integer_fix && dps_order
      @p45j_suite_ready = ready
      log("[EXECUTE_DAMAGE_SEMANTIC_MAP_I] skill100=#{skill100} recovery_block=#{recovery} " +
          "counterattack=#{counter} sideview_absorb=#{sideview} integer_fix=#{integer_fix} " +
          "dps_order_fix=#{dps_order} deferred_conditional=[:combo_core,:character_mechanic,:mechanic_expansion," +
          ":antagonist,:ivy_clone,:marked_command,:custom_status_properties] ready=#{ready}")
      assert("Phase45J execute_damage semantic ownership map I completed", ready,
             "skill100=#{skill100} recovery=#{recovery} counter=#{counter} sideview=#{sideview} integer=#{integer_fix} dps_order=#{dps_order}")
      ready
    rescue Exception => e
      exception(e, "p45j_run_dedicated_suite")
      @p45j_suite_ready = false
      assert("Phase45J execute_damage semantic ownership map I completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase45j_core_finalize_fixture_base)
      alias fs_phase45j_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45j_core_finalize_fixture_base
      if fixture != nil && fixture[:name].to_s == "SKILL100_COST_DAMAGE"
        p45j_analyze_skill100_semantics
      elsif fixture != nil && fixture[:p45f_field_owner]
        p45j_run_dedicated_suite
      end
      result
    rescue Exception => e
      exception(e, "p45j_core_finalize_current_fixture")
      assert("Phase45J execute_damage semantic ownership map I completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase45j_restore_pending_base)
      alias fs_phase45j_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45j_restore_pending_base
      if result
        @p45j_skill100_ready = nil
        @p45j_suite_ready = nil
        @p45j_suite_ran = nil
      end
      result
    end
  end
end
end


#==============================================================================
# Phase45K — execute_damage Conditional Semantic Ownership II（TEST-only）
#==============================================================================
# 【用途】
# 針對 Phase45J 明確 deferred 的條件式 execute_damage wrapper，使用 detached
# battler / synthetic state / exact restore fixture 證明真正語意邊界；Formal Runtime
# 不修改。CharacterMechanic 舊 Ivy Cover OD hook 依現行正式設定為 disabled，故本
# Phase 將它分類為 configuration-disabled legacy hook，而非虛構 active ownership。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P45K_IVY_ACTOR_ID = 5 unless const_defined?(:P45K_IVY_ACTOR_ID)
  P45K_IVY_FATAL_SKILL_ID = 146 unless const_defined?(:P45K_IVY_FATAL_SKILL_ID)

  class << self
    def p45k_ivar_present?(obj, name)
      return false if obj == nil
      target = name.to_s
      obj.instance_variables.each do |ivar|
        return true if ivar.to_s == target
      end
      false
    rescue
      false
    end

    def p45k_clear_state_csp_cache(state)
      return if state == nil
      names = [
        "@max_stack", "@traits", "@state_animation", "@stat_set", "@stat_per",
        "@slip_set", "@slip_per", "@apply_effect", "@erase_effect", "@leave_effect",
        "@react_effect", "@shock_effect", "@begin_effect", "@while_effect", "@close_effect"
      ]
      names.each do |name|
        state.remove_instance_variable(name) if p45k_ivar_present?(state, name)
      end
    rescue
    end

    def p45k_synthetic_state_slot
      active = {}
      battlers = []
      if $game_party != nil
        $game_party.members.compact.each { |battler| battlers.push(battler) }
      end
      if $game_troop != nil
        $game_troop.members.compact.each { |battler| battlers.push(battler) }
      end
      battlers.each do |battler|
        begin
          battler.states.compact.each { |state| active[state.id.to_i] = true }
        rescue
        end
      end
      preferred = [54, 56, 57, 58, 59, 60, 61, 62, 63, 66, 67, 68, 69, 70]
      preferred.each do |id|
        next if active[id]
        return id if $data_states != nil && $data_states[id] != nil
      end
      i = 2
      while $data_states != nil && i < $data_states.size
        if $data_states[i] != nil && !active[i] && i != 40
          return i
        end
        i += 1
      end
      0
    rescue
      0
    end

    def p45k_with_synthetic_state(note_text)
      slot = p45k_synthetic_state_slot
      return [false, 0, false] if slot.to_i <= 0 || $data_states == nil
      original = $data_states[slot]
      return [false, slot, false] if original == nil
      synthetic = original.clone
      synthetic.note = note_text.to_s
      p45k_clear_state_csp_cache(synthetic)
      # Phase45K1: RPG::State#clone 可能保留 YEZ CSP lazy cache 的既有形狀；
      # 直接用正式 parser 重建 synthetic State cache，確保 REACT/SHOCK fixture 測的是 Runtime 語意，
      # 而不是 clone cache 是否剛好已初始化。
      synthetic.yez_cache_state_csp if synthetic.respond_to?(:yez_cache_state_csp)
      result = false
      begin
        $data_states[slot] = synthetic
        result = yield(slot, synthetic)
      ensure
        $data_states[slot] = original
      end
      [result ? true : false, slot, $data_states[slot].equal?(original)]
    rescue Exception => e
      begin
        $data_states[slot] = original if slot != nil && original != nil && $data_states != nil
      rescue
      end
      exception(e, "p45k_with_synthetic_state")
      [false, slot || 0, false]
    end

    def p45k_set_states(target, ids)
      return false if target == nil
      list = ids == nil ? [] : ids.clone
      target.instance_variable_set(:@states, list)
      turns = {}
      list.each { |id| turns[id.to_i] = 5 }
      target.instance_variable_set(:@state_turns, turns)
      true
    rescue
      false
    end

    def p45k_set_od(battler, value)
      return false if battler == nil
      if battler.respond_to?(:overdrive=)
        battler.overdrive = value.to_i
      else
        battler.instance_variable_set(:@overdrive, value.to_i)
      end
      true
    rescue
      false
    end

    def p45k_od(battler)
      return nil if battler == nil
      return battler.overdrive.to_i if battler.respond_to?(:overdrive)
      value = battler.instance_variable_get(:@overdrive)
      value == nil ? nil : value.to_i
    rescue
      nil
    end

    def p45k_disable_drive_gain(battler)
      return false if battler == nil
      battler.instance_variable_set(:@drive_type, [])
      true
    rescue
      false
    end

    def p45k_run_combo_mana_shield_fixture
      result = p45k_with_synthetic_state("<mana_shield 100:50>") do |slot, state|
        user_full = p45j_actor
        user_bypass = p45j_actor
        target_full = p45j_enemy
        target_bypass = p45j_enemy
        ready_objects = user_full != nil && user_bypass != nil &&
                        target_full != nil && target_bypass != nil &&
                        target_full.respond_to?(:albert_cc_old_execute_damage) &&
                        target_bypass.respond_to?(:albert_combo_old_execute_damage)
        assert("Phase45K ComboCore Mana Shield detached fixture ready", ready_objects,
               "state=#{slot}")
        next false unless ready_objects

        [target_full, target_bypass].each do |target|
          p45k_set_states(target, [slot])
          target.hp = [target.maxhp.to_i, 100].min
          target.mp = target.maxmp.to_i
          target.instance_variable_set(:@albert_mana_shield_remaining, {slot => 100})
          p45j_prepare_damage(target, 20, false)
        end
        full_hp_before = target_full.hp.to_i
        full_mp_before = target_full.mp.to_i
        bypass_hp_before = target_bypass.hp.to_i
        bypass_mp_before = target_bypass.mp.to_i

        p45j_call_with_active(user_full, target_full, :albert_cc_old_execute_damage)
        full_hp_loss = full_hp_before - target_full.hp.to_i
        full_mp_loss = full_mp_before - target_full.mp.to_i
        full_remaining = target_full.instance_variable_get(:@albert_mana_shield_remaining)[slot] rescue nil
        full_ok = full_hp_loss == 10 && full_mp_loss == 10 && full_remaining.to_i == 90
        assert("Phase45K ComboCore owns Mana Shield HP-to-MP damage split", full_ok,
               "hp_loss=#{full_hp_loss} mp_loss=#{full_mp_loss} remaining=#{full_remaining.inspect}")

        p45j_call_with_active(user_bypass, target_bypass, :albert_combo_old_execute_damage)
        bypass_hp_loss = bypass_hp_before - target_bypass.hp.to_i
        bypass_mp_loss = bypass_mp_before - target_bypass.mp.to_i
        bypass_ok = bypass_hp_loss == 20 && bypass_mp_loss == 0
        assert("Phase45K ComboCore inner alias bypass omits Mana Shield split", bypass_ok,
               "hp_loss=#{bypass_hp_loss} mp_loss=#{bypass_mp_loss}")

        ready = full_ok && bypass_ok
        log("[EXECUTE_DAMAGE_OWNER_II] case=combo_mana_shield owner=:combo_core full_hp=#{full_hp_loss} full_mp=#{full_mp_loss} bypass_hp=#{bypass_hp_loss} bypass_mp=#{bypass_mp_loss} ready=#{ready}")
        assert("Phase45K ComboCore conditional execute_damage semantic ownership completed", ready)
        ready
      end
      restore_ok = result[2] == true
      assert("Phase45K ComboCore synthetic State database slot restored exact object", restore_ok,
             "state=#{result[1]}")
      result[0] && restore_ok
    rescue Exception => e
      exception(e, "p45k_run_combo_mana_shield_fixture")
      assert("Phase45K ComboCore conditional execute_damage semantic ownership completed", false, e.message)
      false
    end

    def p45k_run_character_disabled_fixture
      user_full = p45j_enemy
      user_bypass = p45j_enemy
      target_full = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      target_bypass = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      ready_objects = user_full != nil && user_bypass != nil &&
                      target_full != nil && target_bypass != nil &&
                      target_full.respond_to?(:albert_cc_ivy?) && target_full.albert_cc_ivy? &&
                      target_full.respond_to?(:albert_mx_old_execute_damage) &&
                      target_bypass.respond_to?(:albert_cc_old_execute_damage)
      assert("Phase45K CharacterMechanic Ivy Cover OD classification fixture ready", ready_objects)
      return false unless ready_objects

      config_disabled = defined?(ALBERT_CHARACTER_CORE::ENABLE_IVY_COVER_OD) &&
                        !ALBERT_CHARACTER_CORE::ENABLE_IVY_COVER_OD &&
                        defined?(ALBERT_CHARACTER_CORE::IVY_OD_PER_COVER) &&
                        ALBERT_CHARACTER_CORE::IVY_OD_PER_COVER.to_i == 0
      assert("Phase45K CharacterMechanic legacy Ivy Cover OD hook is disabled by Formal config", config_disabled,
             "enabled=#{ALBERT_CHARACTER_CORE::ENABLE_IVY_COVER_OD rescue nil} gain=#{ALBERT_CHARACTER_CORE::IVY_OD_PER_COVER rescue nil}")

      [target_full, target_bypass].each do |target|
        p45k_disable_drive_gain(target)
        p45k_set_od(target, 100)
        target.hp = [target.maxhp.to_i, 100].min
        target.instance_variable_set(:@albert_cover_redirect_guard, true)
        p45j_prepare_damage(target, 10, false)
      end
      p45j_call_with_active(user_full, target_full, :albert_mx_old_execute_damage)
      p45j_call_with_active(user_bypass, target_bypass, :albert_cc_old_execute_damage)
      full_od = p45k_od(target_full)
      bypass_od = p45k_od(target_bypass)
      pass_ok = full_od == 100 && bypass_od == 100
      assert("Phase45K CharacterMechanic disabled Cover OD wrapper remains semantic pass-through", pass_ok,
             "full=#{full_od.inspect} bypass=#{bypass_od.inspect}")

      ready = config_disabled && pass_ok
      log("[EXECUTE_DAMAGE_OWNER_II] case=character_cover_od owner=:disabled_by_formal_config enabled=false gain=0 full_od=#{full_od.inspect} bypass_od=#{bypass_od.inspect} ready=#{ready}")
      assert("Phase45K CharacterMechanic execute_damage role classification completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45k_run_character_disabled_fixture")
      assert("Phase45K CharacterMechanic execute_damage role classification completed", false, e.message)
      false
    end

    def p45k_run_mechanic_expansion_fixture
      user_full = p45j_enemy
      user_bypass = p45j_enemy
      target_full = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      target_bypass = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      ready_objects = user_full != nil && user_bypass != nil &&
                      target_full != nil && target_bypass != nil &&
                      target_full.respond_to?(:albert_ant_old_execute_damage) &&
                      target_bypass.respond_to?(:albert_mx_old_execute_damage) &&
                      target_full.respond_to?(:albert_mx_stored_cover_damage) &&
                      target_full.respond_to?(:albert_mx_stored_cover_damage=) &&
                      target_full.respond_to?(:albert_mx_direct_store_rate)
      assert("Phase45K MechanicExpansion Ivy stored-damage fixture ready", ready_objects)
      return false unless ready_objects

      [target_full, target_bypass].each do |target|
        p45k_disable_drive_gain(target)
        target.albert_mx_stored_cover_damage = 0
        target.hp = [target.maxhp.to_i, 100].min
        target.instance_variable_set(:@albert_cover_redirect_guard, false)
        p45j_prepare_damage(target, 20, false)
      end
      rate = target_full.albert_mx_direct_store_rate.to_f
      expected = (20 * rate / 100.0).to_i
      assert("Phase45K MechanicExpansion direct Ivy store rate resolves positive", expected > 0,
             "rate=#{rate} expected=#{expected}")

      p45j_call_with_active(user_full, target_full, :albert_ant_old_execute_damage)
      full_stored = target_full.albert_mx_stored_cover_damage.to_i
      full_ok = full_stored == expected
      assert("Phase45K MechanicExpansion owns post-damage Ivy stored-cover accumulation", full_ok,
             "rate=#{rate} expected=#{expected} actual=#{full_stored}")

      p45j_call_with_active(user_bypass, target_bypass, :albert_mx_old_execute_damage)
      bypass_stored = target_bypass.albert_mx_stored_cover_damage.to_i
      bypass_ok = bypass_stored == 0
      assert("Phase45K MechanicExpansion inner alias bypass leaves stored-cover value unchanged", bypass_ok,
             "stored=#{bypass_stored}")

      ready = expected > 0 && full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER_II] case=ivy_stored_cover owner=:mechanic_expansion rate=#{rate} full=#{full_stored} bypass=#{bypass_stored} ready=#{ready}")
      assert("Phase45K MechanicExpansion conditional execute_damage semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45k_run_mechanic_expansion_fixture")
      assert("Phase45K MechanicExpansion conditional execute_damage semantic ownership completed", false, e.message)
      false
    end

    def p45k_find_detached_actor_ids
      used = {}
      if $game_party != nil
        $game_party.members.compact.each { |actor| used[actor.id.to_i] = true if actor.respond_to?(:id) }
      end
      ids = []
      i = 7
      while $data_actors != nil && i < $data_actors.size && ids.size < 2
        if $data_actors[i] != nil && !used[i]
          ids.push(i)
        end
        i += 1
      end
      ids
    rescue
      []
    end

    def p45k_run_antagonist_link_fixture
      ids = p45k_find_detached_actor_ids
      data = $game_actors == nil ? nil : $game_actors.instance_variable_get(:@data)
      ready_ids = ids.size >= 2 && data.is_a?(Array)
      assert("Phase45K Antagonist double-thread detached actor slots resolved", ready_ids,
             "ids=#{ids.inspect}")
      return false unless ready_ids

      actor_id = ids[0]
      partner_id = ids[1]
      old_actor = data[actor_id]
      old_partner = data[partner_id]
      actor = Game_Actor.new(actor_id)
      partner = Game_Actor.new(partner_id)
      user = p45j_enemy
      ready_objects = actor != nil && partner != nil && user != nil &&
                      actor.respond_to?(:albert_ic_old_execute_damage) &&
                      actor.respond_to?(:albert_ant_old_execute_damage)
      assert("Phase45K Antagonist double-thread execute_damage boundaries ready", ready_objects)
      return false unless ready_objects

      full_mirror = nil
      bypass_mirror = nil
      begin
        data[actor_id] = actor
        data[partner_id] = partner
        p45k_disable_drive_gain(actor)
        p45k_disable_drive_gain(partner)
        actor.instance_variable_set(:@albert_ant_link_actor_id, partner_id)
        actor.instance_variable_set(:@albert_ant_link_rate, 50)
        actor.instance_variable_set(:@albert_ant_link_state_id, 0)
        actor.instance_variable_set(:@albert_ant_link_lethal, false)
        actor.instance_variable_set(:@albert_ant_link_animation_id, 0)
        actor.instance_variable_set(:@albert_ant_link_guard, false)

        actor.hp = [actor.maxhp.to_i, 100].min
        partner.hp = [partner.maxhp.to_i, 100].min
        actor_start = actor.hp.to_i
        partner_start = partner.hp.to_i
        p45j_prepare_damage(actor, 20, false)
        p45j_call_with_active(user, actor, :albert_ic_old_execute_damage)
        actual_loss = actor_start - actor.hp.to_i
        full_mirror = partner_start - partner.hp.to_i
        expected_mirror = (actual_loss.to_f * 50 / 100.0).round
        expected_mirror = 1 if expected_mirror <= 0 && actual_loss > 0
        full_ok = actual_loss == 20 && full_mirror == expected_mirror
        assert("Phase45K Antagonist wrapper owns double-thread mirror damage", full_ok,
               "loss=#{actual_loss} mirror=#{full_mirror} expected=#{expected_mirror}")

        actor.hp = actor_start
        partner.hp = partner_start
        p45j_prepare_damage(actor, 20, false)
        p45j_call_with_active(user, actor, :albert_ant_old_execute_damage)
        bypass_mirror = partner_start - partner.hp.to_i
        bypass_ok = bypass_mirror == 0
        assert("Phase45K Antagonist inner alias bypass omits double-thread mirror damage", bypass_ok,
               "mirror=#{bypass_mirror}")

        ready = full_ok && bypass_ok
        log("[EXECUTE_DAMAGE_OWNER_II] case=antagonist_link owner=:antagonist full_mirror=#{full_mirror} bypass_mirror=#{bypass_mirror} ready=#{ready}")
        assert("Phase45K Antagonist conditional execute_damage semantic ownership completed", ready)
        @p45k_antagonist_local_ready = ready
      ensure
        data[actor_id] = old_actor
        data[partner_id] = old_partner
      end
      slots_ok = data[actor_id].equal?(old_actor) && data[partner_id].equal?(old_partner)
      assert("Phase45K Antagonist temporary Game_Actors slots restored exact objects", slots_ok,
             "ids=#{ids.inspect}")
      (@p45k_antagonist_local_ready == true) && slots_ok
    rescue Exception => e
      begin
        data[actor_id] = old_actor if data != nil && actor_id != nil
        data[partner_id] = old_partner if data != nil && partner_id != nil
      rescue
      end
      exception(e, "p45k_run_antagonist_link_fixture")
      assert("Phase45K Antagonist conditional execute_damage semantic ownership completed", false, e.message)
      false
    ensure
      @p45k_antagonist_local_ready = nil
    end

    def p45k_run_ivy_fatal_cover_fixture
      skill = $data_skills == nil ? nil : $data_skills[P45K_IVY_FATAL_SKILL_ID]
      user_full = p45j_enemy
      user_bypass = p45j_enemy
      target_full = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      target_bypass = Game_Actor.new(P45K_IVY_ACTOR_ID) rescue nil
      ready_objects = skill != nil && user_full != nil && user_bypass != nil &&
                      target_full != nil && target_bypass != nil &&
                      target_full.respond_to?(:fs_mc_original_execute_damage) &&
                      target_bypass.respond_to?(:albert_ic_old_execute_damage)
      assert("Phase45K IvyClone fatal-Cover detached fixture ready", ready_objects,
             "skill=#{P45K_IVY_FATAL_SKILL_ID}")
      return false unless ready_objects

      cost = defined?(ALBERT_IVY_CLONE::IVY_FATAL_COVER_OD_COST) ?
             ALBERT_IVY_CLONE::IVY_FATAL_COVER_OD_COST.to_i : 300
      initial_od = cost + 200
      [target_full, target_bypass].each do |target|
        p45k_disable_drive_gain(target)
        skills = target.instance_variable_get(:@skills)
        skills = [] unless skills.is_a?(Array)
        skills = skills.clone
        skills.push(P45K_IVY_FATAL_SKILL_ID) unless skills.include?(P45K_IVY_FATAL_SKILL_ID)
        target.instance_variable_set(:@skills, skills)
        p45k_set_od(target, initial_od)
        target.instance_variable_set(:@albert_cover_redirect_guard, true)
        target.instance_variable_set(:@albert_ic_fatal_cover_used, false)
      end
      start_hp = [target_full.maxhp.to_i, 50].min
      start_hp = 2 if start_hp < 2
      damage = start_hp + 10
      target_full.hp = start_hp
      target_bypass.hp = start_hp
      p45j_prepare_damage(target_full, damage, false)
      p45j_prepare_damage(target_bypass, damage, false)

      learned = target_full.respond_to?(:skill_learn?) && target_full.skill_learn?(skill)
      assert("Phase45K IvyClone fatal-Cover required Skill prerequisite visible on detached Ivy", learned,
             "skill=#{P45K_IVY_FATAL_SKILL_ID}")

      p45j_call_with_active(user_full, target_full, :fs_mc_original_execute_damage)
      full_flag = target_full.instance_variable_get(:@albert_ic_fatal_cover_used) ? true : false
      full_damage = target_full.instance_variable_get(:@hp_damage) rescue nil
      full_od = p45k_od(target_full)
      full_ok = full_flag && target_full.hp.to_i == 1 && full_damage.to_i == start_hp - 1 &&
                full_od.to_i == initial_od - cost
      assert("Phase45K IvyClone owns lethal Cover save, 1HP clamp, and exact OD payment", full_ok,
             "hp=#{target_full.hp} dmg=#{full_damage.inspect} od=#{full_od.inspect} initial=#{initial_od} cost=#{cost}")

      p45j_call_with_active(user_bypass, target_bypass, :albert_ic_old_execute_damage)
      bypass_flag = target_bypass.instance_variable_get(:@albert_ic_fatal_cover_used) ? true : false
      bypass_ok = !bypass_flag && target_bypass.hp.to_i == 0
      assert("Phase45K IvyClone inner alias bypass permits lethal Cover damage", bypass_ok,
             "hp=#{target_bypass.hp} flag=#{bypass_flag}")

      ready = learned && full_ok && bypass_ok
      log("[EXECUTE_DAMAGE_OWNER_II] case=ivy_fatal_cover owner=:ivy_clone start_hp=#{start_hp} full_hp=#{target_full.hp} full_od=#{full_od.inspect} bypass_hp=#{target_bypass.hp} ready=#{ready}")
      assert("Phase45K IvyClone conditional execute_damage semantic ownership completed", ready)
      ready
    rescue Exception => e
      exception(e, "p45k_run_ivy_fatal_cover_fixture")
      assert("Phase45K IvyClone conditional execute_damage semantic ownership completed", false, e.message)
      false
    end

    def p45k_run_marked_command_fixture
      joey = nil
      if $game_party != nil
        $game_party.members.compact.each do |actor|
          if actor.respond_to?(:id) && actor.id.to_i == 1
            joey = actor
            break
          end
        end
      end
      joey = $game_actors[1] if joey == nil && $game_actors != nil
      summon_full = Game_Actor.new(218) rescue nil
      summon_bypass = Game_Actor.new(218) rescue nil
      target_full = p45j_enemy
      target_bypass = p45j_enemy
      ready_objects = joey != nil && summon_full != nil && summon_bypass != nil &&
                      target_full != nil && target_bypass != nil &&
                      defined?(FS_MARKED_COMMAND) && FS_MARKED_COMMAND.summon?(summon_full) &&
                      target_full.respond_to?(:execute_damage) &&
                      target_bypass.respond_to?(:fs_mc_original_execute_damage)
      assert("Phase45K MarkedCommand detached summon/marked-target fixture ready", ready_objects)
      return false unless ready_objects

      joey_od_before = p45k_od(joey)
      full_flags_before = [
        summon_full.instance_variable_get(:@fs_mc_command_bonus),
        summon_full.instance_variable_get(:@fs_mc_command_hit),
        summon_full.instance_variable_get(:@fs_mc_mark_od_awarded)
      ]
      bypass_flags_before = [
        summon_bypass.instance_variable_get(:@fs_mc_command_bonus),
        summon_bypass.instance_variable_get(:@fs_mc_command_hit),
        summon_bypass.instance_variable_get(:@fs_mc_mark_od_awarded)
      ]
      begin
        p45k_set_states(target_full, [FS_MARKED_COMMAND::MARK_STATE_ID])
        p45k_set_states(target_bypass, [FS_MARKED_COMMAND::MARK_STATE_ID])
        [target_full, target_bypass].each do |target|
          target.hp = [target.maxhp.to_i, 100].min
          target.instance_variable_set(:@missed, false)
          target.instance_variable_set(:@evaded, false)
          target.instance_variable_set(:@skipped, false)
          p45j_prepare_damage(target, 10, false)
        end
        summon_full.instance_variable_set(:@fs_mc_command_bonus, true)
        summon_full.instance_variable_set(:@fs_mc_command_hit, false)
        summon_full.instance_variable_set(:@fs_mc_mark_od_awarded, false)
        summon_bypass.instance_variable_set(:@fs_mc_command_bonus, true)
        summon_bypass.instance_variable_set(:@fs_mc_command_hit, false)
        summon_bypass.instance_variable_set(:@fs_mc_mark_od_awarded, false)

        p45j_call_with_active(summon_full, target_full, :execute_damage)
        full_hit = summon_full.instance_variable_get(:@fs_mc_command_hit) ? true : false
        full_awarded = summon_full.instance_variable_get(:@fs_mc_mark_od_awarded) ? true : false
        full_joey_od = p45k_od(joey)
        gain = defined?(FS_MARKED_COMMAND::MARK_HIT_OD_GAIN) ? FS_MARKED_COMMAND::MARK_HIT_OD_GAIN.to_i : 40
        full_ok = full_hit && full_awarded && full_joey_od.to_i - joey_od_before.to_i == gain
        assert("Phase45K MarkedCommand owns marked summon hit flag and Joey OD award", full_ok,
               "hit=#{full_hit} awarded=#{full_awarded} od=#{joey_od_before}->#{full_joey_od} gain=#{gain}")

        p45k_set_od(joey, joey_od_before)
        p45j_call_with_active(summon_bypass, target_bypass, :fs_mc_original_execute_damage)
        bypass_hit = summon_bypass.instance_variable_get(:@fs_mc_command_hit) ? true : false
        bypass_awarded = summon_bypass.instance_variable_get(:@fs_mc_mark_od_awarded) ? true : false
        bypass_joey_od = p45k_od(joey)
        bypass_ok = !bypass_hit && !bypass_awarded && bypass_joey_od.to_i == joey_od_before.to_i
        assert("Phase45K MarkedCommand inner alias bypass omits mark hit bookkeeping/OD award", bypass_ok,
               "hit=#{bypass_hit} awarded=#{bypass_awarded} od=#{bypass_joey_od}")

        ready = full_ok && bypass_ok
        log("[EXECUTE_DAMAGE_OWNER_II] case=marked_command owner=:marked_command full_hit=#{full_hit} full_awarded=#{full_awarded} bypass_hit=#{bypass_hit} bypass_awarded=#{bypass_awarded} ready=#{ready}")
        assert("Phase45K MarkedCommand conditional execute_damage semantic ownership completed", ready)
        @p45k_marked_local_ready = ready
      ensure
        p45k_set_od(joey, joey_od_before) if joey != nil && joey_od_before != nil
        summon_full.instance_variable_set(:@fs_mc_command_bonus, full_flags_before[0]) if summon_full != nil
        summon_full.instance_variable_set(:@fs_mc_command_hit, full_flags_before[1]) if summon_full != nil
        summon_full.instance_variable_set(:@fs_mc_mark_od_awarded, full_flags_before[2]) if summon_full != nil
        summon_bypass.instance_variable_set(:@fs_mc_command_bonus, bypass_flags_before[0]) if summon_bypass != nil
        summon_bypass.instance_variable_set(:@fs_mc_command_hit, bypass_flags_before[1]) if summon_bypass != nil
        summon_bypass.instance_variable_set(:@fs_mc_mark_od_awarded, bypass_flags_before[2]) if summon_bypass != nil
      end
      restore_ok = p45k_od(joey).to_i == joey_od_before.to_i
      assert("Phase45K MarkedCommand formal Joey OD restored exactly after fixture", restore_ok,
             "od=#{p45k_od(joey)} expected=#{joey_od_before}")
      (@p45k_marked_local_ready == true) && restore_ok
    rescue Exception => e
      exception(e, "p45k_run_marked_command_fixture")
      assert("Phase45K MarkedCommand conditional execute_damage semantic ownership completed", false, e.message)
      false
    ensure
      @p45k_marked_local_ready = nil
    end

    def p45k_run_custom_status_fixture
      result = p45k_with_synthetic_state("<react effect: Invincible>") do |slot, state|
        user_full = p45j_actor
        user_bypass = p45j_actor
        target_full = p45j_enemy
        target_bypass = p45j_enemy
        ready_objects = user_full != nil && user_bypass != nil &&
                        target_full != nil && target_bypass != nil &&
                        target_full.respond_to?(:rx_rgss2b20_execute_damage) &&
                        target_bypass.respond_to?(:execute_damage_csp)
        assert("Phase45K CustomStatusProperties REACT detached fixture ready", ready_objects,
               "state=#{slot}")
        next false unless ready_objects

        [target_full, target_bypass].each do |target|
          p45k_set_states(target, [slot])
          target.hp = [target.maxhp.to_i, 100].min
          p45j_prepare_damage(target, 20, false)
        end
        full_hp_before = target_full.hp.to_i
        bypass_hp_before = target_bypass.hp.to_i

        p45j_call_with_active(user_full, target_full, :rx_rgss2b20_execute_damage)
        full_loss = full_hp_before - target_full.hp.to_i
        full_damage = target_full.instance_variable_get(:@hp_damage) rescue nil
        full_ok = full_loss == 0 && full_damage.to_i == 0
        assert("Phase45K CustomStatusProperties owns pre-damage REACT Invincible mutation", full_ok,
               "loss=#{full_loss} hp_damage=#{full_damage.inspect}")

        p45j_call_with_active(user_bypass, target_bypass, :execute_damage_csp)
        bypass_loss = bypass_hp_before - target_bypass.hp.to_i
        bypass_ok = bypass_loss == 20
        assert("Phase45K CustomStatusProperties inner alias bypass omits REACT mutation", bypass_ok,
               "loss=#{bypass_loss}")

        ready = full_ok && bypass_ok
        log("[EXECUTE_DAMAGE_OWNER_II] case=custom_status_react owner=:custom_status_properties full_loss=#{full_loss} bypass_loss=#{bypass_loss} ready=#{ready}")
        assert("Phase45K CustomStatusProperties conditional execute_damage semantic ownership completed", ready)
        ready
      end
      restore_ok = result[2] == true
      assert("Phase45K CustomStatusProperties synthetic State database slot restored exact object", restore_ok,
             "state=#{result[1]}")
      result[0] && restore_ok
    rescue Exception => e
      exception(e, "p45k_run_custom_status_fixture")
      assert("Phase45K CustomStatusProperties conditional execute_damage semantic ownership completed", false, e.message)
      false
    end

    def p45k_run_dedicated_suite
      return @p45k_suite_ready if @p45k_suite_ran
      @p45k_suite_ran = true
      prior = @p45j_suite_ready == true
      assert("Phase45K starts only after sealed-in-run Phase45J semantic map I", prior,
             "p45j=#{@p45j_suite_ready.inspect}")

      combo = p45k_run_combo_mana_shield_fixture
      character_disabled = p45k_run_character_disabled_fixture
      mechanic = p45k_run_mechanic_expansion_fixture
      antagonist = p45k_run_antagonist_link_fixture
      ivy = p45k_run_ivy_fatal_cover_fixture
      marked = p45k_run_marked_command_fixture
      csp = p45k_run_custom_status_fixture

      ready = prior && combo && character_disabled && mechanic && antagonist && ivy && marked && csp
      @p45k_suite_ready = ready
      log("[EXECUTE_DAMAGE_SEMANTIC_MAP_II] combo_mana_shield=#{combo} " +
          "character_cover_od_disabled=#{character_disabled} mechanic_expansion=#{mechanic} " +
          "antagonist_link=#{antagonist} ivy_fatal_cover=#{ivy} marked_command=#{marked} " +
          "custom_status_properties=#{csp} deferred_to_character_boss_matrix=[] ready=#{ready}")
      assert("Phase45K execute_damage conditional semantic ownership map II completed", ready,
             "combo=#{combo} char_disabled=#{character_disabled} mx=#{mechanic} ant=#{antagonist} ivy=#{ivy} marked=#{marked} csp=#{csp}")
      ready
    rescue Exception => e
      exception(e, "p45k_run_dedicated_suite")
      @p45k_suite_ready = false
      assert("Phase45K execute_damage conditional semantic ownership map II completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase45k_core_finalize_fixture_base)
      alias fs_phase45k_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase45k_core_finalize_fixture_base
      if fixture != nil && fixture[:p45f_field_owner]
        p45k_run_dedicated_suite
      end
      result
    rescue Exception => e
      exception(e, "p45k_core_finalize_current_fixture")
      assert("Phase45K execute_damage conditional semantic ownership map II completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase45k_restore_pending_base)
      alias fs_phase45k_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase45k_restore_pending_base
      if result
        @p45k_suite_ready = nil
        @p45k_suite_ran = nil
        @p45k_antagonist_local_ready = nil
        @p45k_marked_local_ready = nil
      end
      result
    end
  end
end
end

#==============================================================================
# 【Phase46A】Main Character Regression I — Joey Resonance / Ivy Pain Core Loop
#------------------------------------------------------------------------------
# Phase45K1 1112/0/0 封版後，角色 Regression Track 正式開始。
# 本批只用正式角色／技能／State 資料與正式 Runtime API：
#   Joey：Skill100/101 Resonance Pull 的首次標記、刷新標記、起手 OD gate、最高 ATB summon。
#   Ivy ：正式 Skill141/144/145/146/147/148 契約、Cover/Direct 蓄痛倍率、Furnace State85、cap。
# Phase46A1：修正 live Battle fixture 的過度 whole-Marshal global equality，改驗 touched ownership + Party/Actor registry identity；
# 並同步驗證 FS Damage Popup Color Authority 四類顏色契約。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p46a_ivar_snapshot(obj, name)
      return [false, nil] if obj == nil
      present = p45k_ivar_present?(obj, name)
      value = present ? obj.instance_variable_get(name) : nil
      [present, value]
    rescue
      [false, nil]
    end

    def p46a_restore_ivar(obj, name, snapshot)
      return if obj == nil || snapshot == nil
      if snapshot[0]
        obj.instance_variable_set(name, snapshot[1])
      elsif p45k_ivar_present?(obj, name)
        obj.send(:remove_instance_variable, name)
      end
    rescue
    end

    def p46a_party_actors_bytes
      party = nil
      actors = nil
      begin
        party = Marshal.dump($game_party) if $game_party != nil
      rescue
      end
      begin
        actors = Marshal.dump($game_actors) if $game_actors != nil
      rescue
      end
      [party, actors]
    end

    # Live Scene_Battle 內 whole Marshal bytes 會包含非本 fixture 擁有的 runtime cache。
    # Phase46A1 改驗 Party membership + Game_Actors registry object identity；
    # 真正的全域還原仍由 suite 結尾 Battle snapshot restored 負責。
    def p46a_registry_signature
      party_ids = []
      battle_ids = []
      registry = []
      begin
        party_ids = $game_party.actors.clone if $game_party != nil && $game_party.respond_to?(:actors)
      rescue
        party_ids = []
      end
      begin
        battle_ids = $game_party.members.compact.collect { |a| a.id } if $game_party != nil
      rescue
        battle_ids = []
      end
      begin
        data = $game_actors.instance_variable_get(:@data) if $game_actors != nil
        if data.is_a?(Array)
          data.each_with_index do |actor, index|
            next if actor == nil
            registry.push([index, actor.object_id])
          end
        end
      rescue
        registry = []
      end
      [party_ids, battle_ids, registry]
    end

    def p46a_live_summons
      result = []
      return result if $game_party == nil
      for member in $game_party.members.compact
        next unless member.respond_to?(:albert_summon?)
        result.push(member) if member.albert_summon?
      end
      result
    rescue
      []
    end

    def p46a_run_joey_resonance_fixture
      before_globals = p46a_registry_signature
      joey = Game_Actor.new(ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID)
      target = p45j_enemy
      skill100 = $data_skills[100] rescue nil
      skill101 = $data_skills[101] rescue nil
      skills_ok = joey != nil && target != nil && skill100 != nil && skill101 != nil
      assert("Phase46A Joey formal actors/Skill100/Skill101 fixture ready", skills_ok,
             "joey=#{joey == nil ? nil : joey.id} s100=#{skill100 == nil ? nil : skill100.name} s101=#{skill101 == nil ? nil : skill101.name}")
      return false unless skills_ok

      note100 = skill100.note.to_s
      note101 = skill101.note.to_s
      note_ok = note100 =~ /<joey_resonance_pull\s+100\s*:\s*12\s*:\s*18\s*>/i &&
                note101 =~ /<joey_resonance_pull\s+100\s*:\s*12\s*:\s*18\s*>/i
      assert("Phase46A Joey formal resonance pull contracts match 100:12:18", !!note_ok,
             "s100=#{note100.inspect} s101=#{note101.inspect}")

      summons = p46a_live_summons
      summon = nil
      if target.respond_to?(:albert_cc_v13_highest_atb_summon)
        summon = target.albert_cc_v13_highest_atb_summon
      end
      summon_ready = summon != nil && summons.include?(summon) && summon.respond_to?(:at_count)
      assert("Phase46A Joey highest-ATB live summon selector resolves Battle summon", summon_ready,
             "summons=#{summons.collect { |s| s.id }.inspect} selected=#{summon == nil ? nil : summon.id}")
      return false unless summon_ready

      joey_od_before = p45k_od(joey)
      start_od_snapshot = p46a_ivar_snapshot(joey, :@albert_od_action_start_value)
      summon_at_snapshot = p46a_ivar_snapshot(summon, :@at_count)
      target_states_snapshot = p46a_ivar_snapshot(target, :@states)
      target_turns_snapshot = p46a_ivar_snapshot(target, :@state_turns)
      added_snapshot = p46a_ivar_snapshot(target, :@added_states)
      remained_snapshot = p46a_ivar_snapshot(target, :@remained_states)
      missed_snapshot = p46a_ivar_snapshot(target, :@missed)
      evaded_snapshot = p46a_ivar_snapshot(target, :@evaded)
      skipped_snapshot = p46a_ivar_snapshot(target, :@skipped)

      initial_ok = false
      refresh_ok = false
      blocked_ok = false
      begin
        target.instance_variable_set(:@missed, false)
        target.instance_variable_set(:@evaded, false)
        target.instance_variable_set(:@skipped, false)
        p45k_set_states(target, [40])

        p45k_set_od(joey, 200)
        joey.instance_variable_set(:@albert_od_action_start_value, 200)
        summon.instance_variable_set(:@at_count, 200)
        target.instance_variable_set(:@added_states, [40])
        target.instance_variable_set(:@remained_states, [])
        target.albert_cc_v13_process_joey_pull(joey, skill100, false)
        initial_at = summon.at_count.to_i
        initial_od = p45k_od(joey).to_i
        initial_ok = initial_at == 320 && initial_od == 100
        assert("Phase46A Joey first Resonance application pulls summon +12% ATB and pays 100 OD", initial_ok,
               "at=200->#{initial_at} od=200->#{initial_od}")

        p45k_set_od(joey, 200)
        joey.instance_variable_set(:@albert_od_action_start_value, 200)
        summon.instance_variable_set(:@at_count, 200)
        target.instance_variable_set(:@added_states, [])
        target.instance_variable_set(:@remained_states, [40])
        target.albert_cc_v13_process_joey_pull(joey, skill101, true)
        refresh_at = summon.at_count.to_i
        refresh_od = p45k_od(joey).to_i
        refresh_ok = refresh_at == 380 && refresh_od == 100
        assert("Phase46A Joey Resonance refresh pulls summon +18% ATB and pays 100 OD", refresh_ok,
               "at=200->#{refresh_at} od=200->#{refresh_od}")

        p45k_set_od(joey, 200)
        joey.instance_variable_set(:@albert_od_action_start_value, 99)
        summon.instance_variable_set(:@at_count, 200)
        target.instance_variable_set(:@added_states, [40])
        target.instance_variable_set(:@remained_states, [])
        target.albert_cc_v13_process_joey_pull(joey, skill100, false)
        blocked_at = summon.at_count.to_i
        blocked_od = p45k_od(joey).to_i
        blocked_ok = blocked_at == 200 && blocked_od == 200
        assert("Phase46A Joey Resonance respects action-start OD gate before pull/payment", blocked_ok,
               "start_od=99 at=#{blocked_at} od=#{blocked_od}")
      ensure
        p45k_set_od(joey, joey_od_before) if joey_od_before != nil
        p46a_restore_ivar(joey, :@albert_od_action_start_value, start_od_snapshot)
        p46a_restore_ivar(summon, :@at_count, summon_at_snapshot)
        p46a_restore_ivar(target, :@states, target_states_snapshot)
        p46a_restore_ivar(target, :@state_turns, target_turns_snapshot)
        p46a_restore_ivar(target, :@added_states, added_snapshot)
        p46a_restore_ivar(target, :@remained_states, remained_snapshot)
        p46a_restore_ivar(target, :@missed, missed_snapshot)
        p46a_restore_ivar(target, :@evaded, evaded_snapshot)
        p46a_restore_ivar(target, :@skipped, skipped_snapshot)
      end

      summon_restore = p46a_ivar_snapshot(summon, :@at_count) == summon_at_snapshot
      assert("Phase46A Joey live summon ATB restored exactly after Resonance fixture", summon_restore,
             "before=#{summon_at_snapshot.inspect} after=#{p46a_ivar_snapshot(summon, :@at_count).inspect}")
      after_globals = p46a_registry_signature
      globals_ok = before_globals == after_globals
      assert("Phase46A1 Joey Resonance preserves Party membership / Game_Actors registry identity", globals_ok,
             "before=#{before_globals.inspect} after=#{after_globals.inspect}")

      ready = note_ok && initial_ok && refresh_ok && blocked_ok && summon_restore && globals_ok
      log("[CHARACTER_REGRESSION] character=joey resonance_initial=#{initial_ok} resonance_refresh=#{refresh_ok} od_gate=#{blocked_ok} summon_restore=#{summon_restore} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46a_run_joey_resonance_fixture")
      assert("Phase46A Joey Resonance gameplay contract completed", false, e.message)
      false
    end

    def p46a_run_ivy_pain_fixture
      before_globals = p46a_registry_signature
      skills = {}
      [141, 144, 145, 146, 147, 148].each do |id|
        skills[id] = $data_skills[id] rescue nil
      end
      skills_ok = skills.values.compact.size == 6
      assert("Phase46A Ivy formal Skill141/144/145/146/147/148 data exists", skills_ok,
             "skills=#{skills.collect { |k,v| [k, v == nil ? nil : v.name] }.inspect}")
      return false unless skills_ok

      guard_taunt_ok = skills[141].note.to_s =~ /<ig\s*:\s*2\s*,\s*2\s*,\s*20\s*>/i &&
                       skills[141].note.to_s =~ /<io\s*:\s*10\s*>/i &&
                       skills[144].note.to_s =~ /<it\s*:\s*300\s*,\s*15\s*,\s*1\s*>/i &&
                       skills[144].note.to_s =~ /<io\s*:\s*10\s*>/i
      assert("Phase46A Ivy Guard/Taunt formal skill contracts are exact", !!guard_taunt_ok,
             "s141=#{skills[141].note.inspect} s144=#{skills[144].note.inspect}")

      furnace_ok = skills[145].plus_state_set.include?(ALBERT_MECHANIC_EXPANSION::IVY_FURNACE_STATE_ID)
      assert("Phase46A Ivy Pain Furnace formally applies State85", furnace_ok,
             "plus_states=#{skills[145].plus_state_set.inspect}")

      fatal_contract = skills[146].note.to_s =~ /<cover_store_cap_percent\s*:\s*400\s*>/i
      assert("Phase46A Ivy Fatal Cover passive formally raises stored-pain cap to 400%", !!fatal_contract,
             "note=#{skills[146].note.inspect}")

      # Formal DB truth: Skill147 是蓄痛復仇（50% + consume）；
      # Skill148「城牆斷斧」不是 80% 蓄痛技，而是 OD finisher。
      revenge_ok = skills[147].note.to_s =~ /<revenge_from_cover\s*:\s*50\s*>/i &&
                   skills[147].note.to_s =~ /<consume_stored_cover\s*>/i &&
                   skills[148].note.to_s !~ /<revenge_from_cover\s*:/i &&
                   skills[148].note.to_s !~ /<consume_stored_cover\s*>/i &&
                   skills[148].note.to_s =~ /<bonus_if_od\s+70\s*:\s*45\s*>/i &&
                   skills[148].note.to_s =~ /<bonus_per_od_100\s*:\s*5\s*>/i
      assert("Phase46A1 Ivy Skill147 is 50% stored-pain revenge; Skill148 is OD finisher contract", !!revenge_ok,
             "s147=#{skills[147].note.inspect} s148=#{skills[148].note.inspect}")

      ivy = Game_Actor.new(ALBERT_CHARACTER_CORE::IVY_ACTOR_ID)
      enemy = p45j_enemy
      runtime_ready = ivy != nil && enemy != nil && ivy.respond_to?(:albert_mx_stored_cover_damage) &&
                      ivy.respond_to?(:albert_mx_cover_store_rate) && ivy.respond_to?(:albert_mx_direct_store_rate)
      assert("Phase46A Ivy detached gameplay battler/runtime ready", runtime_ready,
             "ivy=#{ivy == nil ? nil : ivy.id}")
      return false unless runtime_ready

      ivy_hp_before = ivy.hp.to_i
      stored_snapshot = p46a_ivar_snapshot(ivy, :@albert_mx_stored_cover_damage)
      states_snapshot = p46a_ivar_snapshot(ivy, :@states)
      turns_snapshot = p46a_ivar_snapshot(ivy, :@state_turns)
      cover_snapshot = p46a_ivar_snapshot(ivy, :@albert_cover_redirect_guard)
      drive_snapshot = p46a_ivar_snapshot(ivy, :@drive_type)
      default_rates_ok = ivy.albert_mx_cover_store_rate.to_f == 100.0 && ivy.albert_mx_direct_store_rate.to_f == 50.0
      assert("Phase46A Ivy default pain-store rates are Cover100% / Direct50%", default_rates_ok,
             "cover=#{ivy.albert_mx_cover_store_rate} direct=#{ivy.albert_mx_direct_store_rate}")

      cover_ok = false
      direct_ok = false
      furnace_rate_ok = false
      furnace_store_ok = false
      cap_ok = false
      begin
        p45k_disable_drive_gain(ivy)
        p45k_set_states(ivy, [])
        ivy.hp = [ivy.maxhp.to_i, 200].min
        ivy.albert_mx_stored_cover_damage = 0
        ivy.instance_variable_set(:@albert_cover_redirect_guard, true)
        cover_hp = ivy.hp.to_i
        p45j_prepare_damage(ivy, 20, false)
        p45j_call_with_active(enemy, ivy, :execute_damage)
        cover_loss = cover_hp - ivy.hp.to_i
        cover_store = ivy.albert_mx_stored_cover_damage.to_i
        cover_ok = cover_loss == 20 && cover_store == 20
        assert("Phase46A Ivy real Cover damage stores 100% of actual HP loss", cover_ok,
               "loss=#{cover_loss} stored=#{cover_store}")

        p45k_set_states(ivy, [])
        ivy.hp = [ivy.maxhp.to_i, 200].min
        ivy.albert_mx_stored_cover_damage = 0
        ivy.instance_variable_set(:@albert_cover_redirect_guard, false)
        direct_hp = ivy.hp.to_i
        p45j_prepare_damage(ivy, 20, false)
        p45j_call_with_active(enemy, ivy, :execute_damage)
        direct_loss = direct_hp - ivy.hp.to_i
        direct_store = ivy.albert_mx_stored_cover_damage.to_i
        direct_ok = direct_loss == 20 && direct_store == 10
        assert("Phase46A Ivy real direct damage stores 50% of actual HP loss", direct_ok,
               "loss=#{direct_loss} stored=#{direct_store}")

        p45k_set_states(ivy, [ALBERT_MECHANIC_EXPANSION::IVY_FURNACE_STATE_ID])
        furnace_rate_ok = ivy.albert_mx_direct_store_rate.to_f == 100.0
        assert("Phase46A Ivy Pain Furnace State85 raises direct-store rate to 100%", furnace_rate_ok,
               "rate=#{ivy.albert_mx_direct_store_rate}")

        ivy.hp = [ivy.maxhp.to_i, 200].min
        ivy.albert_mx_stored_cover_damage = 0
        ivy.instance_variable_set(:@albert_cover_redirect_guard, false)
        furnace_hp = ivy.hp.to_i
        p45j_prepare_damage(ivy, 20, false)
        p45j_call_with_active(enemy, ivy, :execute_damage)
        furnace_loss = furnace_hp - ivy.hp.to_i
        furnace_store = ivy.albert_mx_stored_cover_damage.to_i
        furnace_store_ok = furnace_loss == 20 && furnace_store == 20
        assert("Phase46A Ivy Pain Furnace real direct hit stores 100% actual loss", furnace_store_ok,
               "loss=#{furnace_loss} stored=#{furnace_store}")

        p45k_set_states(ivy, [])
        ivy.albert_mx_stored_cover_damage = ivy.maxhp.to_i * 3
        capped = ivy.albert_mx_stored_cover_damage.to_i
        expected_cap = (ivy.maxhp.to_f * ALBERT_MECHANIC_EXPANSION::IVY_DEFAULT_STORE_CAP_PERCENT / 100.0).to_i
        cap_ok = capped == expected_cap
        assert("Phase46A Ivy default stored-pain cap clamps at 200% MaxHP without passive provider", cap_ok,
               "stored=#{capped} expected=#{expected_cap}")
      ensure
        ivy.hp = ivy_hp_before
        p46a_restore_ivar(ivy, :@albert_mx_stored_cover_damage, stored_snapshot)
        p46a_restore_ivar(ivy, :@states, states_snapshot)
        p46a_restore_ivar(ivy, :@state_turns, turns_snapshot)
        p46a_restore_ivar(ivy, :@albert_cover_redirect_guard, cover_snapshot)
        p46a_restore_ivar(ivy, :@drive_type, drive_snapshot)
      end

      cleanup_ok = p46a_ivar_snapshot(ivy, :@albert_mx_stored_cover_damage) == stored_snapshot &&
                   p46a_ivar_snapshot(ivy, :@states) == states_snapshot && ivy.hp.to_i == ivy_hp_before
      assert("Phase46A Ivy detached pain-store/state/HP fixture restored exactly", cleanup_ok)
      after_globals = p46a_registry_signature
      globals_ok = before_globals == after_globals
      assert("Phase46A1 Ivy detached gameplay preserves Party membership / Game_Actors registry identity", globals_ok,
             "before=#{before_globals.inspect} after=#{after_globals.inspect}")

      ready = guard_taunt_ok && furnace_ok && fatal_contract && revenge_ok && runtime_ready &&
              default_rates_ok && cover_ok && direct_ok && furnace_rate_ok && furnace_store_ok &&
              cap_ok && cleanup_ok && globals_ok
      log("[CHARACTER_REGRESSION] character=ivy guard_taunt=#{!!guard_taunt_ok} furnace=#{furnace_store_ok} cover_store=#{cover_ok} direct_store=#{direct_ok} cap=#{cap_ok} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46a_run_ivy_pain_fixture")
      assert("Phase46A Ivy Pain gameplay contract completed", false, e.message)
      false
    end

    def p46a_run_character_suite
      return @p46a_suite_ready if @p46a_suite_ran
      @p46a_suite_ran = true
      prior = @p45k_suite_ready == true
      assert("Phase46A starts only after sealed-in-run Phase45K conditional semantic map II", prior,
             "p45k=#{@p45k_suite_ready.inspect}")
      joey = p46a_run_joey_resonance_fixture
      ivy = p46a_run_ivy_pain_fixture
      ready = prior && joey && ivy
      @p46a_suite_ready = ready
      log("[CHARACTER_REGRESSION_MAP_I] popup_native_restored=true joey_resonance=#{joey} ivy_pain_core=#{ivy} pending=[:joey_followup_action,:ivy_revenge_consume,:aizhuo,:mia,:vina,:tyler] ready=#{ready}")
      assert("Phase46A Joey + Ivy Main Character Regression map I completed", ready,
             "joey=#{joey} ivy=#{ivy}")
      ready
    rescue Exception => e
      exception(e, "p46a_run_character_suite")
      @p46a_suite_ready = false
      assert("Phase46A Joey + Ivy Main Character Regression map I completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase46a_core_finalize_fixture_base)
      alias fs_phase46a_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase46a_core_finalize_fixture_base
      if fixture != nil && fixture[:p45f_field_owner]
        p46a_run_character_suite
      end
      result
    rescue Exception => e
      exception(e, "p46a_core_finalize_current_fixture")
      assert("Phase46A Main Character Regression I completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase46a_restore_pending_base)
      alias fs_phase46a_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase46a_restore_pending_base
      if result
        @p46a_suite_ready = nil
        @p46a_suite_ran = nil
      end
      result
    end
  end
end
end


#==============================================================================
# 【Phase46B】Main Character Regression II — Joey Follow-up / Ivy Guard-Taunt
#------------------------------------------------------------------------------
# TEST-only。Phase46A2 的 Popup recolor 已依實機視覺驗收撤銷，正式數字回到
# Tankentai 原生 Number+/Number-/MP_Number+/MP_Number- 四素材。
# 本批新增：
#   1. 喬伊 Skill104 鳴刻指令動態 OD parser + Skill107 type:pokemon 單段追擊：
#      target identity / actual Tankentai follow-up action / OD cost / summon action+ATB+MP+OD 保全。
#   2. 艾薇 Skill147 行動快照傷害、Skill148 OD finisher、Skill141 Guard 與 Skill144 Taunt
#      啟動值、OD、action-duration lifecycle。
# consume_stored_cover 的完整 Scene_Battle 成功/失敗 gate 留 Phase46B1。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p46b_native_popup_rollback_contract
      no_color = !defined?(FS_DAMAGE_POPUP_COLOR)
      native = defined?(N01) && N01.const_defined?(:USE_MP_POP_GRAPHICS) &&
               N01::USE_MP_POP_GRAPHICS == true &&
               N01::DAMAGE_GRAPHICS.to_s == "Number+" &&
               N01::RECOVER_GRAPHICS.to_s == "Number-" &&
               N01::MP_DAMAGE_GRAPHICS.to_s == "MP_Number+" &&
               N01::MP_RECOVER_GRAPHICS.to_s == "MP_Number-"
      ready = no_color && native
      assert("Phase46B Popup recolor fully rolled back to native Tankentai four-graphic contract", ready,
             "color_module=#{defined?(FS_DAMAGE_POPUP_COLOR).inspect} hp=#{defined?(N01) ? N01::DAMAGE_GRAPHICS : nil} hp_rec=#{defined?(N01) ? N01::RECOVER_GRAPHICS : nil} mp=#{defined?(N01) ? N01::MP_DAMAGE_GRAPHICS : nil} mp_rec=#{defined?(N01) ? N01::MP_RECOVER_GRAPHICS : nil}")
      log("[DAMAGE_POPUP_NATIVE] hp=Number+ mp=MP_Number+ hp_recover=Number- mp_recover=MP_Number- recolor=false ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b_native_popup_rollback_contract")
      assert("Phase46B native Popup rollback contract completed", false, e.message)
      false
    end

    def p46b_run_joey_followup_fixture
      joey = $game_actors[ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID] rescue nil
      summons = p46a_live_summons
      summon = summons.find { |a| a.respond_to?(:albert_summon_type) && a.albert_summon_type.to_s.downcase == "pokemon" }
      summon = summons[0] if summon == nil
      trigger = $data_skills[107] rescue nil
      follow = $data_skills[190] rescue nil
      target = ($game_troop.existing_members.find { |e| e != nil && e.exist? } rescue nil)
      battle = $scene
      ready0 = joey != nil && summon != nil && trigger != nil && follow != nil && target != nil &&
               battle != nil && battle.respond_to?(:albert_cc_try_summon_followups) &&
               battle.respond_to?(:albert_cc_followup_targets)
      assert("Phase46B Joey live summon / Skill107 / Skill190 follow-up fixture ready", ready0,
             "joey=#{joey == nil ? nil : joey.id} summon=#{summon == nil ? nil : summon.id} trigger=#{trigger == nil ? nil : trigger.name} follow=#{follow == nil ? nil : follow.name}")
      return false unless ready0

      specs = ALBERT_CHARACTER_CORE.summon_followup_specs(trigger)
      spec = specs.find { |x| x && x[0].to_i == summon.id.to_i && x[1].to_i == 190 }
      parser_ok = spec != nil && spec[2].to_i == 600 && spec[3].to_i == 120
      assert("Phase46B Joey Skill107 type:pokemon parser resolves current live summon with 600/120 OD contract", parser_ok,
             "summon=#{summon.id} specs=#{specs.inspect}")

      command = $data_skills[104] rescue nil
      command_specs = command == nil ? [] : ALBERT_CHARACTER_CORE.summon_followup_specs(command)
      command_spec = command_specs.find { |x| x && x[0].to_i == summon.id.to_i && x[1].to_i == 190 }
      command_need = defined?(FS_MARKED_COMMAND) ? FS_MARKED_COMMAND.command_od_need(joey).to_i : -1
      command_cost = defined?(FS_MARKED_COMMAND) ? FS_MARKED_COMMAND.command_od_cost(joey).to_i : -1
      command_role_note = command != nil && command.note.to_s =~ /<summon_followup_role\s+starter\s*:\s*190\s*:/i
      summon_is_starter = summon.respond_to?(:albert_mx_summon_role?) ? summon.albert_mx_summon_role?("starter") : false
      dynamic_specs_ok = command_specs.all? { |x| x != nil && x[2].to_i == command_need && x[3].to_i == command_cost }
      command_ok = command != nil && command_role_note && command_need == 350 && command_cost == 80 &&
                   dynamic_specs_ok && (command_spec != nil || !summon_is_starter)
      assert("Phase46B Joey Skill104 MarkedCommand dynamic OD contract respects starter-role candidate set", command_ok,
             "skill=#{command == nil ? nil : command.name} specs=#{command_specs.inspect} current_summon=#{summon.id} starter=#{summon_is_starter} dynamic=#{[command_need,command_cost].inspect}")

      chosen = battle.albert_cc_followup_targets(summon, follow, [target, target])
      target_ok = chosen.size == 1 && chosen[0].equal?(target)
      assert("Phase46B Joey follow-up target selection preserves original target identity and dedupes to one", target_ok,
             "chosen=#{chosen.collect { |x| x.object_id }.inspect} target=#{target.object_id}")

      joey_od = joey.overdrive.to_i
      summon_at = p46a_ivar_snapshot(summon, :@at_count)
      summon_mp = summon.mp.to_i
      summon_od = summon.respond_to?(:overdrive) ? summon.overdrive.to_i : nil
      summon_action = summon.action
      summon_active = summon.active
      target_hp = target.hp.to_i
      target_states = p46a_ivar_snapshot(target, :@states)
      target_turns = p46a_ivar_snapshot(target, :@state_turns)
      target_added = p46a_ivar_snapshot(target, :@added_states)
      target_remained = p46a_ivar_snapshot(target, :@remained_states)
      scene_active = battle.instance_variable_get(:@active_battler)
      scene_targets = battle.instance_variable_get(:@targets)
      follow_flag = battle.instance_variable_get(:@albert_cc_in_summon_followup)
      executed = false
      od_ok = false
      action_ok = false
      resource_ok = false
      context_ok = false
      begin
        joey.overdrive = 800
        summon.active = false
        target.hp = target.maxhp
        p45k_set_states(target, [])
        p37_with_combat_rng("phase46b_joey_followup_skill190") do
          battle.albert_cc_try_summon_followups(joey, trigger, 800, [target])
        end
        executed = target.hp.to_i < target.maxhp.to_i || target.hp_damage.to_i > 0
        od_ok = joey.overdrive.to_i == 680
        action_ok = summon.action.equal?(summon_action) && summon.active == false
        generic_od_gain = 0
        if summon_od != nil && defined?(KGC::OverDrive)
          generic_od_gain = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ATTACK].to_i
          if summon.action.kind == 1 && summon.action.skill != nil && summon.action.skill.respond_to?(:od_gain_rate)
            generic_od_gain = generic_od_gain * summon.action.skill.od_gain_rate.to_i / 100
            generic_od_gain = [generic_od_gain, 1].max if summon.action.skill.od_gain_rate.to_i > 0
          end
        end
        expected_generic_od_gain = executed ? generic_od_gain : 0
        resource_ok = p46a_ivar_snapshot(summon, :@at_count) == summon_at &&
                      summon.mp.to_i == summon_mp &&
                      (summon_od == nil || summon.overdrive.to_i == summon_od + expected_generic_od_gain)
        context_ok = battle.instance_variable_get(:@active_battler).equal?(scene_active) &&
                     battle.instance_variable_get(:@targets).equal?(scene_targets) &&
                     battle.instance_variable_get(:@albert_cc_in_summon_followup) == false
        assert("Phase46B Joey live type follow-up actually executes Skill190 and pays exactly 120 conditional OD", executed && od_ok,
               "target_hp=#{target.hp}/#{target.maxhp} hp_damage=#{target.hp_damage} joey_od=#{joey.overdrive}")
        assert("Phase46B Joey follow-up preserves summon pre-existing action object and active flag", action_ok,
               "action_same=#{summon.action.equal?(summon_action)} active=#{summon.active}")
        assert("Phase46B Joey follow-up preserves summon ATB/MP and allows only normal KGC attacker OD gain", resource_ok,
               "at=#{summon_at.inspect}->#{p46a_ivar_snapshot(summon,:@at_count).inspect} mp=#{summon_mp}->#{summon.mp} od=#{summon_od}->#{summon.respond_to?(:overdrive) ? summon.overdrive : nil} expected_gain=#{expected_generic_od_gain} executed=#{executed}")
        assert("Phase46B Joey follow-up Scene context and recursion flag restore exactly", context_ok,
               "active_same=#{battle.instance_variable_get(:@active_battler).equal?(scene_active)} targets_same=#{battle.instance_variable_get(:@targets).equal?(scene_targets)} flag=#{battle.instance_variable_get(:@albert_cc_in_summon_followup).inspect}")
        no_action_od = ALBERT_CHARACTER_CORE::FOLLOWUP_COUNTS_AS_SUMMON_ACTION == false && joey.overdrive.to_i == 680
        assert("Phase46B Joey follow-up does not grant duplicate normal summon-action OD", no_action_od,
               "counts=#{ALBERT_CHARACTER_CORE::FOLLOWUP_COUNTS_AS_SUMMON_ACTION} joey_od=#{joey.overdrive}")
      ensure
        joey.overdrive = joey_od
        p46a_restore_ivar(summon, :@at_count, summon_at)
        summon.mp = summon_mp
        summon.overdrive = summon_od if summon_od != nil && summon.respond_to?(:overdrive=)
        summon.instance_variable_set(:@action, summon_action)
        summon.active = summon_active
        target.hp = target_hp
        p46a_restore_ivar(target, :@states, target_states)
        p46a_restore_ivar(target, :@state_turns, target_turns)
        p46a_restore_ivar(target, :@added_states, target_added)
        p46a_restore_ivar(target, :@remained_states, target_remained)
        battle.instance_variable_set(:@active_battler, scene_active)
        battle.instance_variable_set(:@targets, scene_targets)
        battle.instance_variable_set(:@albert_cc_in_summon_followup, follow_flag)
      end
      cleanup = joey.overdrive.to_i == joey_od && p46a_ivar_snapshot(summon,:@at_count) == summon_at && target.hp.to_i == target_hp
      assert("Phase46B Joey live follow-up fixture restores Joey / summon / target runtime baseline", cleanup)
      ready = parser_ok && command_ok && target_ok && executed && od_ok && action_ok && resource_ok && context_ok && cleanup
      log("[CHARACTER_REGRESSION] character=joey followup_type=true command_dynamic=#{command_ok} followup_exec=#{executed} target_identity=#{target_ok} od_cost=#{od_ok} summon_resources=#{resource_ok} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b_run_joey_followup_fixture")
      assert("Phase46B Joey full summon follow-up fixture completed", false, e.message)
      false
    end

    def p46b_run_ivy_guard_taunt_fixture
      before_globals = p46a_registry_signature
      ivy = Game_Actor.new(ALBERT_CHARACTER_CORE::IVY_ACTOR_ID)
      s141 = $data_skills[141] rescue nil
      s144 = $data_skills[144] rescue nil
      s147 = $data_skills[147] rescue nil
      s148 = $data_skills[148] rescue nil
      target = ($game_troop.existing_members[0] rescue nil)
      ready0 = !!(ivy != nil && s141 != nil && s144 != nil && s147 != nil && s148 != nil && target != nil && defined?(ALBERT_IVY_CLONE))
      assert("Phase46B Ivy Skill141/144/147/148 detached lifecycle fixture ready", ready0,
             "ivy=#{ivy == nil ? nil : ivy.id} s141=#{s141 == nil ? nil : s141.name} s144=#{s144 == nil ? nil : s144.name} s147=#{s147 == nil ? nil : s147.name} s148=#{s148 == nil ? nil : s148.name}")
      return false unless ready0

      names = [:@albert_ic_guard_charges, :@albert_ic_guard_actions_left, :@albert_ic_guard_reduce,
               :@albert_ic_guard_activated_serial, :@albert_ic_taunt_percent, :@albert_ic_taunt_reduce,
               :@albert_ic_taunt_actions_left, :@albert_ic_taunt_activated_serial,
               :@albert_mx_stored_cover_damage, :@albert_mx_revenge_action_snapshot,
               :@albert_mx_revenge_action_skill_id]
      snaps = {}
      names.each { |n| snaps[n] = p46a_ivar_snapshot(ivy,n) }
      od0 = ivy.overdrive.to_i
      serial0 = ALBERT_IVY_CLONE.action_serial.to_i
      target_damage = p46a_ivar_snapshot(target, :@hp_damage)
      revenge_ok = finisher_ok = guard_ok = guard_same_ok = guard_expire_ok = taunt_ok = taunt_expire_ok = false
      begin
        # Skill147: 行動開始快照必須固定本次所有 target 的追加傷害基準。
        local = Marshal.load(Marshal.dump(s147))
        local.variance = 0 if local.respond_to?(:variance=)
        # Phase46D3 TEST-only：CustomDamage#critical_chance 第一次存取可能先呼叫
        # yanfly_cache_cdf，而該 cache 會把 @no_crit 初始化回 false。
        # 因此必須先完成 CDF cache，再覆寫 TEST clone 的 @no_crit=true；否則
        # 「先 set @no_crit」會在 damage calculation 中被 parser 重置，造成偶發 2x critical。
        # Formal Skill147 / CustomDamage Runtime 均不修改。
        local.yanfly_cache_cdf if local.respond_to?(:yanfly_cache_cdf)
        local.instance_variable_set(:@no_crit, true)
        ivy.albert_mx_stored_cover_damage = 0
        ivy.instance_variable_set(:@albert_mx_revenge_action_skill_id, local.id)
        ivy.instance_variable_set(:@albert_mx_revenge_action_snapshot, 0)
        target.make_obj_damage_value(ivy, local)
        base = target.hp_damage.to_i
        ivy.albert_mx_stored_cover_damage = 999
        ivy.instance_variable_set(:@albert_mx_revenge_action_snapshot, 200)
        target.make_obj_damage_value(ivy, local)
        boosted = target.hp_damage.to_i
        revenge_ok = boosted - base == 100
        assert("Phase46B Ivy Skill147 uses action-start stored-pain snapshot for exact +50% fixed revenge", revenge_ok,
               "base=#{base} boosted=#{boosted} delta=#{boosted-base} snapshot=200 no_crit=#{local.respond_to?(:no_crit) ? local.no_crit : local.instance_variable_get(:@no_crit)}")

        # Skill148：目前正式 Runtime 是 OD finisher，不消耗 stored pain。
        # OD=700/1000 時：70% threshold +45，另每 100 OD +5，共 +80%。
        ivy.overdrive = 700
        finisher_bonus = target.albert_combo_damage_bonus_percent(ivy, s148)
        finisher_ok = finisher_bonus.to_i == 80 &&
                      s148.note.to_s !~ /<revenge_from_cover\s*:/i &&
                      s148.note.to_s !~ /<consume_stored_cover\s*>/i
        assert("Phase46B Ivy Skill148 OD finisher applies exact +80% bonus at 700 OD without stored-pain consume contract", !!finisher_ok,
               "bonus=#{finisher_bonus} od=#{ivy.overdrive}/#{ivy.max_overdrive} note=#{s148.note.inspect}")

        ivy.overdrive = 0
        ALBERT_IVY_CLONE.action_serial = 100
        ALBERT_IVY_CLONE.apply_action_skill_tags(ivy, s141)
        gain10 = (ivy.max_overdrive.to_f * 0.10).round.to_i
        guard_reduce = (ivy.instance_variable_get(:@albert_ic_guard_reduce) || 0).to_i
        guard_ok = ivy.albert_ic_guard_charges == 2 && ivy.albert_ic_guard_actions_left == 2 &&
                   guard_reduce == 20 && ivy.overdrive.to_i == gain10
        assert("Phase46B Ivy Skill141 activates Guard 2 charges / 2 actions / 20% reduction and +10% OD", guard_ok,
               "charges=#{ivy.albert_ic_guard_charges} actions=#{ivy.albert_ic_guard_actions_left} reduce=#{guard_reduce} od=#{ivy.overdrive}/#{gain10}")
        ALBERT_IVY_CLONE.tick_owner_action(ivy)
        guard_same_ok = ivy.albert_ic_guard_actions_left == 2
        assert("Phase46B Ivy Guard does not consume duration on its activation serial", guard_same_ok,
               "actions=#{ivy.albert_ic_guard_actions_left}")
        ALBERT_IVY_CLONE.action_serial = 101
        ALBERT_IVY_CLONE.tick_owner_action(ivy)
        one_left = ivy.albert_ic_guard_actions_left == 1 && ivy.albert_ic_guard_charges == 2
        ALBERT_IVY_CLONE.action_serial = 102
        ALBERT_IVY_CLONE.tick_owner_action(ivy)
        guard_expire_ok = one_left && ivy.albert_ic_guard_actions_left == 0 && ivy.albert_ic_guard_charges == 0 &&
                          (ivy.instance_variable_get(:@albert_ic_guard_reduce) || 0).to_i == 0
        assert("Phase46B Ivy Guard action-duration decrements once per later action and clears at zero", guard_expire_ok,
               "actions=#{ivy.albert_ic_guard_actions_left} charges=#{ivy.albert_ic_guard_charges} reduce=#{(ivy.instance_variable_get(:@albert_ic_guard_reduce)||0).to_i}")

        ivy.overdrive = 0
        ALBERT_IVY_CLONE.action_serial = 200
        ALBERT_IVY_CLONE.apply_action_skill_tags(ivy, s144)
        taunt_ok = ivy.albert_ic_taunt_actions_left == 1 && ALBERT_IVY_CLONE.taunt_percent(ivy) == 300 &&
                   ALBERT_IVY_CLONE.taunt_reduce(ivy) == 15 && ivy.overdrive.to_i == gain10
        assert("Phase46B Ivy Skill144 activates Taunt 300% / 15% reduction / 1 action and +10% OD", taunt_ok,
               "percent=#{ALBERT_IVY_CLONE.taunt_percent(ivy)} reduce=#{ALBERT_IVY_CLONE.taunt_reduce(ivy)} actions=#{ivy.albert_ic_taunt_actions_left} od=#{ivy.overdrive}")
        ALBERT_IVY_CLONE.tick_owner_action(ivy)
        same = ivy.albert_ic_taunt_actions_left == 1
        ALBERT_IVY_CLONE.action_serial = 201
        ALBERT_IVY_CLONE.tick_owner_action(ivy)
        taunt_expire_ok = same && ivy.albert_ic_taunt_actions_left == 0 &&
                          ALBERT_IVY_CLONE.taunt_percent(ivy) == 100 && ALBERT_IVY_CLONE.taunt_reduce(ivy) == 0
        assert("Phase46B Ivy Taunt keeps activation serial then expires/clears on next owner action", taunt_expire_ok,
               "actions=#{ivy.albert_ic_taunt_actions_left} percent=#{ALBERT_IVY_CLONE.taunt_percent(ivy)} reduce=#{ALBERT_IVY_CLONE.taunt_reduce(ivy)}")
      ensure
        ivy.overdrive = od0
        names.each { |n| p46a_restore_ivar(ivy,n,snaps[n]) }
        ALBERT_IVY_CLONE.action_serial = serial0
        p46a_restore_ivar(target, :@hp_damage, target_damage)
      end
      cleanup = names.all? { |n| p46a_ivar_snapshot(ivy,n) == snaps[n] } &&
                ivy.overdrive.to_i == od0 && ALBERT_IVY_CLONE.action_serial.to_i == serial0 &&
                p46a_registry_signature == before_globals
      assert("Phase46B Ivy revenge/Guard/Taunt detached fixture restores all touched runtime/global state", cleanup)
      ready = revenge_ok && finisher_ok && guard_ok && guard_same_ok && guard_expire_ok && taunt_ok && taunt_expire_ok && cleanup
      log("[CHARACTER_REGRESSION] character=ivy revenge_snapshot=#{revenge_ok} od_finisher=#{!!finisher_ok} guard=#{guard_ok && guard_expire_ok} taunt=#{taunt_ok && taunt_expire_ok} consume_gate=:pending_phase46b1 ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b_run_ivy_guard_taunt_fixture")
      assert("Phase46B Ivy revenge/Guard/Taunt lifecycle fixture completed", false, e.message)
      false
    end

    def p46b_run_character_suite
      return @p46b_suite_ready if @p46b_suite_ran
      @p46b_suite_ran = true
      prior = @p46a_suite_ready == true
      assert("Phase46B starts only after Phase46A Joey Resonance + Ivy Pain Core map I is green in-run", prior,
             "p46a=#{@p46a_suite_ready.inspect}")
      popup = p46b_native_popup_rollback_contract
      joey = p46b_run_joey_followup_fixture
      ivy = p46b_run_ivy_guard_taunt_fixture
      ready = prior && popup && joey && ivy
      @p46b_suite_ready = ready
      log("[CHARACTER_REGRESSION_MAP_II] popup_native=#{popup} joey_followup=#{joey} ivy_revenge_guard_taunt=#{ivy} pending=[:ivy_revenge_consume_success_gate,:ivy_active_cover_od,:ivy_team_self_serial_dedupe,:aizhuo,:mia,:vina,:tyler] ready=#{ready}")
      assert("Phase46B Joey Follow-up + Ivy Revenge/Guard/Taunt map II completed", ready,
             "popup=#{popup} joey=#{joey} ivy=#{ivy}")
      ready
    rescue Exception => e
      exception(e, "p46b_run_character_suite")
      @p46b_suite_ready = false
      assert("Phase46B Character Regression map II completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase46b_core_finalize_fixture_base)
      alias fs_phase46b_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase46b_core_finalize_fixture_base
      if fixture != nil && fixture[:p45f_field_owner]
        p46b_run_character_suite
      end
      result
    rescue Exception => e
      exception(e, "p46b_core_finalize_current_fixture")
      assert("Phase46B Main Character Regression II completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase46b_restore_pending_base)
      alias fs_phase46b_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase46b_restore_pending_base
      if result
        @p46b_suite_ready = nil
        @p46b_suite_ran = nil
      end
      result
    end
  end
end
end


#==============================================================================
# 【Phase46B2】Main Character Regression III — Ivy Lifecycle Tail
#------------------------------------------------------------------------------
# TEST-only；Formal Runtime 零變更。
# 實機 Phase46B1a 已封版 1158/0/0。本批鎖定 Ivy 尚未覆蓋的四個尾項：
#   1. Skill147 <consume_stored_cover>：只在一次成功 action 後清空一次；失敗／skip 不清。
#   2. Skill141 Active Cover：每次成功主動護衛 +6% Max OD；同 action serial 不可重複 redirect。
#   3. 隊友受傷 +2% / Ivy 自傷額外 +2%：同 action serial 各只結算一次，下一 serial 可再結算。
#   4. Fatal Cover：Cover 致死仍維持 1 HP / 300 OD，且實際安全承傷仍進入 stored-pain。
# 注意：consume gate 直接呼叫 page379 被 page382 保存的正式 wrapper
#       albert_ant_old_execute_action_skill；只以 TEST singleton stub 控制「內層 action 是否成功」，
#       不改 Formal method body，也不進行 Tankentai 視覺行動。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p46b2_party_ids
      return [] if $game_party == nil
      begin
        return $game_party.actors.clone if $game_party.respond_to?(:actors)
      rescue
      end
      begin
        return $game_party.members.compact.collect { |a| a.id }
      rescue
        return []
      end
    end

    def p46b2_run_consume_gate_fixture
      before_globals = p46a_registry_signature
      battle = $scene
      ivy = Game_Actor.new(ALBERT_CHARACTER_CORE::IVY_ACTOR_ID)
      skill = ($data_skills[147] rescue nil)
      formal_wrapper = battle != nil && battle.respond_to?(:albert_ant_old_execute_action_skill, true)
      ready0 = !!(battle != nil && ivy != nil && skill != nil && formal_wrapper &&
                  ivy.respond_to?(:albert_mx_stored_cover_damage) &&
                  ivy.respond_to?(:albert_mx_clear_stored_cover_damage))
      assert("Phase46B2 Ivy Skill147 consume gate formal Scene_Battle wrapper fixture ready", ready0,
             "scene=#{battle == nil ? nil : battle.class} ivy=#{ivy == nil ? nil : ivy.id} skill=#{skill == nil ? nil : skill.name} wrapper=#{formal_wrapper}")
      return false unless ready0

      scene_active = p46a_ivar_snapshot(battle, :@active_battler)
      action_success = p46a_ivar_snapshot(ivy, :@albert_mx_action_success)
      revenge_snap = p46a_ivar_snapshot(ivy, :@albert_mx_revenge_action_snapshot)
      revenge_id = p46a_ivar_snapshot(ivy, :@albert_mx_revenge_action_skill_id)
      stored_snap = p46a_ivar_snapshot(ivy, :@albert_mx_stored_cover_damage)
      low_refund = p46a_ivar_snapshot(ivy, :@albert_mx_aizhuo_low_refund_used)
      scene_sc = class << battle; self; end
      ivy_sc = class << ivy; self; end
      clear_calls = [0]
      inner_calls = [0]
      mode = [:success]
      original_clear = ivy.method(:albert_mx_clear_stored_cover_damage)
      success_ok = miss_ok = skip_ok = cleanup = false
      begin
        ivy.action.clear
        ivy.action.set_skill(skill.id)
        battle.instance_variable_set(:@active_battler, ivy)

        ivy_sc.send(:define_method, :albert_mx_clear_stored_cover_damage) do
          clear_calls[0] += 1
          original_clear.call
        end
        scene_sc.send(:define_method, :albert_mx_old_execute_action_skill) do |*args|
          inner_calls[0] += 1
          b = @active_battler
          b.instance_variable_set(:@albert_mx_action_success, mode[0] == :success) if b != nil
          nil
        end

        ivy.albert_mx_stored_cover_damage = 200
        mode[0] = :success
        battle.send(:albert_ant_old_execute_action_skill)
        success_ok = ivy.albert_mx_stored_cover_damage.to_i == 0 && clear_calls[0] == 1 && inner_calls[0] == 1
        assert("Phase46B2 Ivy Skill147 successful action consumes stored pain exactly once after action", success_ok,
               "stored=#{ivy.albert_mx_stored_cover_damage} clear_calls=#{clear_calls[0]} inner=#{inner_calls[0]}")

        ivy.albert_mx_stored_cover_damage = 200
        mode[0] = :miss
        battle.send(:albert_ant_old_execute_action_skill)
        miss_ok = ivy.albert_mx_stored_cover_damage.to_i == 200 && clear_calls[0] == 1 && inner_calls[0] == 2
        assert("Phase46B2 Ivy Skill147 failed/missed action preserves stored pain", miss_ok,
               "stored=#{ivy.albert_mx_stored_cover_damage} clear_calls=#{clear_calls[0]} inner=#{inner_calls[0]}")

        ivy.albert_mx_stored_cover_damage = 200
        mode[0] = :skip
        battle.send(:albert_ant_old_execute_action_skill)
        skip_ok = ivy.albert_mx_stored_cover_damage.to_i == 200 && clear_calls[0] == 1 && inner_calls[0] == 3
        assert("Phase46B2 Ivy Skill147 skipped action preserves stored pain", skip_ok,
               "stored=#{ivy.albert_mx_stored_cover_damage} clear_calls=#{clear_calls[0]} inner=#{inner_calls[0]}")
      ensure
        begin scene_sc.send(:remove_method, :albert_mx_old_execute_action_skill); rescue; end
        begin ivy_sc.send(:remove_method, :albert_mx_clear_stored_cover_damage); rescue; end
        p46a_restore_ivar(battle, :@active_battler, scene_active)
        p46a_restore_ivar(ivy, :@albert_mx_action_success, action_success)
        p46a_restore_ivar(ivy, :@albert_mx_revenge_action_snapshot, revenge_snap)
        p46a_restore_ivar(ivy, :@albert_mx_revenge_action_skill_id, revenge_id)
        p46a_restore_ivar(ivy, :@albert_mx_stored_cover_damage, stored_snap)
        p46a_restore_ivar(ivy, :@albert_mx_aizhuo_low_refund_used, low_refund)
      end
      cleanup = p46a_registry_signature == before_globals &&
                p46a_ivar_snapshot(battle, :@active_battler) == scene_active &&
                p46a_ivar_snapshot(ivy, :@albert_mx_stored_cover_damage) == stored_snap
      assert("Phase46B2 Ivy consume-gate TEST singleton overrides and touched context restore exactly", cleanup,
             "globals=#{p46a_registry_signature == before_globals} active=#{p46a_ivar_snapshot(battle,:@active_battler) == scene_active}")
      ready = success_ok && miss_ok && skip_ok && cleanup
      log("[IVY_CONSUME_GATE] success_once=#{success_ok} miss_preserve=#{miss_ok} skip_preserve=#{skip_ok} clear_calls=#{clear_calls[0]} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b2_run_consume_gate_fixture")
      assert("Phase46B2 Ivy Skill147 consume success/fail/skip gate completed", false, e.message)
      false
    end

    def p46b2_run_active_cover_fixture
      before_globals = p46a_registry_signature
      party_before = p46b2_party_ids
      ivy = ($game_actors[ALBERT_CHARACTER_CORE::IVY_ACTOR_ID] rescue nil)
      target = ($game_actors[ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID] rescue nil)
      enemy = ($game_troop.existing_members[0] rescue nil)
      skill141 = ($data_skills[141] rescue nil)
      source = ($data_skills[100] rescue nil)
      added = false
      serial0 = ALBERT_IVY_CLONE.action_serial.to_i
      ivy_hp0 = ivy == nil ? nil : ivy.hp.to_i
      ivy_od0 = ivy == nil ? nil : ivy.overdrive.to_i
      ivy_names = [:@albert_ic_guard_charges, :@albert_ic_guard_actions_left, :@albert_ic_guard_reduce,
                   :@albert_ic_guard_activated_serial, :@albert_ic_team_hit_serial, :@albert_ic_self_hit_serial,
                   :@albert_ic_fatal_cover_used, :@albert_mx_stored_cover_damage, :@hp_damage,
                   :@albert_ic_cover_guard, :@albert_ic_internal_guard_damage,
                   :@albert_ic_skip_personal_reduce, :@covered, :@states, :@state_turns,
                   :@albert_ic_cover_motion_busy, :@albert_ic_cover_motion_offset_x,
                   :@albert_ic_cover_motion_offset_y]
      target_names = [:@hp_damage, :@albert_ic_redirected_serial, :@albert_ic_guarded_skill_serial,
                      :@albert_ic_skip_state_serial, :@protector, :@protector_spr_id, :@protector_index]
      ivy_snaps = {}; target_snaps = {}
      ivy_names.each { |n| ivy_snaps[n] = p46a_ivar_snapshot(ivy,n) } if ivy != nil
      target_names.each { |n| target_snaps[n] = p46a_ivar_snapshot(target,n) } if target != nil
      battle = $scene
      active0 = (battle != nil && battle.respond_to?(:active_battler)) ? battle.active_battler : nil
      motion_session0 = defined?(ALBERT_IVY_CLONE_COVER_MOTION) ?
                        ALBERT_IVY_CLONE_COVER_MOTION.instance_variable_get(:@session) : nil
      redirect_ok = dedupe_ok = cleanup = false
      begin
        if ivy != nil && $game_party != nil && !p46b2_party_ids.include?(ivy.id)
          $game_party.add_actor(ivy.id)
          added = true
        end
        members = target == nil ? [] : ALBERT_IVY_CLONE.guard_members(target)
        ready0 = !!(ivy != nil && target != nil && enemy != nil && skill141 != nil && source != nil && members.include?(ivy))
        assert("Phase46B2 Ivy Active Cover live-party fixture ready", ready0,
               "ivy=#{ivy == nil ? nil : ivy.id} target=#{target == nil ? nil : target.id} party=#{p46b2_party_ids.inspect} guard_members=#{members.collect{|m| m.id}.inspect}")
        return false unless ready0

        local = Marshal.load(Marshal.dump(source))
        local.note = "" if local.respond_to?(:note=)
        local.base_damage = 20 if local.respond_to?(:base_damage=)
        local.atk_f = 0 if local.respond_to?(:atk_f=)
        local.spi_f = 0 if local.respond_to?(:spi_f=)
        local.variance = 0 if local.respond_to?(:variance=)
        local.scope = 1 if local.respond_to?(:scope=)
        local.element_set = [] if local.respond_to?(:element_set=)
        local.plus_state_set = [] if local.respond_to?(:plus_state_set=)
        local.minus_state_set = [] if local.respond_to?(:minus_state_set=)

        ALBERT_IVY_CLONE.action_serial = 400
        ivy.hp = ivy.maxhp.to_i
        ivy.overdrive = 0
        ivy.instance_variable_set(:@albert_ic_team_hit_serial, 400)
        ivy.instance_variable_set(:@albert_ic_self_hit_serial, 400)
        ivy.instance_variable_set(:@albert_ic_fatal_cover_used, false)
        ALBERT_IVY_CLONE.activate_guard(ivy, 2, 2, 20)
        target.instance_variable_set(:@albert_ic_redirected_serial, -1)
        ALBERT_IVY_CLONE.set_hp_damage(target, 20)
        expected_gain = (ivy.max_overdrive.to_f * ALBERT_IVY_CLONE::IVY_ACTIVE_COVER_OD_PERCENT.to_f / 100.0).round.to_i
        hp_before_redirect = ivy.hp.to_i
        battle.active_battler = enemy if battle != nil && battle.respond_to?(:active_battler=)
        redirected = ALBERT_IVY_CLONE.try_redirect(target, enemy, local, :skill)
        od_after = ivy.overdrive.to_i
        charges_after = ivy.albert_ic_guard_charges.to_i
        redirected_loss = [hp_before_redirect - ivy.hp.to_i, 0].max
        generic_defender_od = 0
        if redirected_loss > 0 && ivy.respond_to?(:drive_damage?) && ivy.drive_damage? &&
           defined?(KGC::OverDrive::GAIN_RATE) && defined?(KGC::OverDrive::Type::DAMAGE)
          rate = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::DAMAGE].to_i
          generic_defender_od = redirected_loss * rate / [ivy.maxhp.to_i, 1].max
          generic_defender_od = [generic_defender_od, 1].max if rate > 0
          generic_defender_od = [generic_defender_od, -1].min if rate < 0
        end
        expected_total_od = expected_gain + generic_defender_od
        redirect_ok = redirected && od_after == expected_total_od && charges_after == 1 &&
                      ALBERT_IVY_CLONE.hp_damage(target).to_i == 0 && redirected_loss > 0
        assert("Phase46B2 Ivy successful Active Cover grants exact +6% OD while consuming one Guard charge", redirect_ok,
               "redirected=#{redirected} od=#{od_after}/#{expected_total_od} active_cover=#{expected_gain} kgc_defender=#{generic_defender_od} charges=#{charges_after} hp_loss=#{redirected_loss}")

        # Phase46B2b：本 fixture 的 Ivy 是 battle 開始後才暫加 Party，沒有 Sprite_Battler，
        # 第一次正式 Cover Motion 必然走 fallback 並立即 complete。若直接再 call，
        # 那會是「新的 fallback session」，不是同一 active session 的第二個 target hit。
        # 因此 TEST-only 建立一個同 serial / 同 target / 同 guard 的 active session，
        # 驗證正式 v1.5 session reuse：不再扣 Guard charge、不再給 Active Cover +6%，
        # 但第二次真正承傷仍允許 KGC defender OD。
        od_mark = ivy.overdrive.to_i
        charge_mark = ivy.albert_ic_guard_charges.to_i
        hp_before_second = ivy.hp.to_i
        if defined?(ALBERT_IVY_CLONE_COVER_MOTION)
          fake_session = {
            :serial => ALBERT_IVY_CLONE.action_serial.to_i,
            :target => target,
            :guard => ivy,
            :attacker => enemy,
            :phase => :fallback,
            :done => false,
            :damage_queue => [],
            :fallback => true,
            :cover_pop_shown => false,
            :reduce => (ivy.instance_variable_get(:@albert_ic_guard_reduce) || 0).to_i,
            :guard_type => :main,
            :offset_x => 0.0,
            :offset_y => 0.0
          }
          ALBERT_IVY_CLONE_COVER_MOTION.instance_variable_set(:@session, fake_session)
          ivy.instance_variable_set(:@albert_ic_cover_motion_busy, true)
        end
        ALBERT_IVY_CLONE.set_hp_damage(target, 20)
        battle.active_battler = enemy if battle != nil && battle.respond_to?(:active_battler=)
        second = ALBERT_IVY_CLONE.try_redirect(target, enemy, local, :skill)
        second_loss = [hp_before_second - ivy.hp.to_i, 0].max
        generic_second_od = 0
        if second_loss > 0 && ivy.respond_to?(:drive_damage?) && ivy.drive_damage? &&
           defined?(KGC::OverDrive::GAIN_RATE) && defined?(KGC::OverDrive::Type::DAMAGE)
          rate2 = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::DAMAGE].to_i
          generic_second_od = second_loss * rate2 / [ivy.maxhp.to_i, 1].max
          generic_second_od = [generic_second_od, 1].max if rate2 > 0
          generic_second_od = [generic_second_od, -1].min if rate2 < 0
        end
        dedupe_ok = second && ivy.overdrive.to_i == od_mark + generic_second_od &&
                    ivy.albert_ic_guard_charges.to_i == charge_mark
        assert("Phase46B2 Ivy Active Cover same active session reuses guard without duplicate charge/+6% OD", dedupe_ok,
               "second=#{second} od=#{od_mark}->#{ivy.overdrive} kgc_defender=#{generic_second_od} charges=#{charge_mark}->#{ivy.albert_ic_guard_charges} hp_loss=#{second_loss}")
      ensure
        ivy.hp = ivy_hp0 if ivy != nil && ivy_hp0 != nil
        ivy.overdrive = ivy_od0 if ivy != nil && ivy_od0 != nil
        ivy_names.each { |n| p46a_restore_ivar(ivy,n,ivy_snaps[n]) } if ivy != nil
        target_names.each { |n| p46a_restore_ivar(target,n,target_snaps[n]) } if target != nil
        ALBERT_IVY_CLONE.action_serial = serial0
        battle.active_battler = active0 if battle != nil && battle.respond_to?(:active_battler=)
        if defined?(ALBERT_IVY_CLONE_COVER_MOTION)
          ALBERT_IVY_CLONE_COVER_MOTION.instance_variable_set(:@session, motion_session0)
        end
        if added && $game_party != nil
          $game_party.remove_actor(ivy.id) rescue nil
        end
      end
      cleanup = p46b2_party_ids == party_before && p46a_registry_signature == before_globals &&
                ALBERT_IVY_CLONE.action_serial.to_i == serial0 &&
                (battle == nil || !battle.respond_to?(:active_battler) || battle.active_battler.equal?(active0)) &&
                (!defined?(ALBERT_IVY_CLONE_COVER_MOTION) ||
                 ALBERT_IVY_CLONE_COVER_MOTION.instance_variable_get(:@session).equal?(motion_session0))
      assert("Phase46B2 Ivy Active Cover fixture restores Party/runtime ownership exactly", cleanup,
             "party=#{p46b2_party_ids.inspect} expected=#{party_before.inspect}")
      ready = redirect_ok && dedupe_ok && cleanup
      log("[IVY_ACTIVE_COVER] od_percent=#{ALBERT_IVY_CLONE::IVY_ACTIVE_COVER_OD_PERCENT} redirect=#{redirect_ok} session_reuse=#{dedupe_ok} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b2_run_active_cover_fixture")
      assert("Phase46B2 Ivy Active Cover OD lifecycle completed", false, e.message)
      false
    end

    def p46b2_run_party_od_dedupe_fixture
      before_globals = p46a_registry_signature
      party_before = p46b2_party_ids
      ivy = ($game_actors[ALBERT_CHARACTER_CORE::IVY_ACTOR_ID] rescue nil)
      teammate = ($game_actors[ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID] rescue nil)
      enemy = ($game_troop.existing_members[0] rescue nil)
      added = false
      serial0 = ALBERT_IVY_CLONE.action_serial.to_i
      od0 = ivy == nil ? nil : ivy.overdrive.to_i
      team_snap = p46a_ivar_snapshot(ivy, :@albert_ic_team_hit_serial)
      self_snap = p46a_ivar_snapshot(ivy, :@albert_ic_self_hit_serial)
      team_ok = self_ok = rearm_ok = cleanup = false
      begin
        if ivy != nil && $game_party != nil && !p46b2_party_ids.include?(ivy.id)
          $game_party.add_actor(ivy.id)
          added = true
        end
        ready0 = !!(ivy != nil && teammate != nil && enemy != nil && p46b2_party_ids.include?(ivy.id))
        assert("Phase46B2 Ivy team/self-hit OD serial-dedupe live-party fixture ready", ready0,
               "party=#{p46b2_party_ids.inspect} ivy=#{ivy == nil ? nil : ivy.id} teammate=#{teammate == nil ? nil : teammate.id}")
        return false unless ready0

        team_gain = (ivy.max_overdrive.to_f * ALBERT_IVY_CLONE::IVY_TEAM_HIT_OD_PERCENT.to_f / 100.0).round.to_i
        self_gain = (ivy.max_overdrive.to_f * ALBERT_IVY_CLONE::IVY_SELF_HIT_OD_PERCENT.to_f / 100.0).round.to_i

        ivy.overdrive = 0
        ivy.instance_variable_set(:@albert_ic_team_hit_serial, -1)
        ivy.instance_variable_set(:@albert_ic_self_hit_serial, -1)
        ALBERT_IVY_CLONE.action_serial = 500
        ALBERT_IVY_CLONE.process_party_damage(teammate, enemy, 10)
        first_team = ivy.overdrive.to_i
        ALBERT_IVY_CLONE.process_party_damage(teammate, enemy, 99)
        second_team = ivy.overdrive.to_i
        team_ok = first_team == team_gain && second_team == team_gain
        assert("Phase46B2 Ivy teammate-hit +2% OD awards once per action serial", team_ok,
               "gain=#{team_gain} first=#{first_team} second=#{second_team} serial=#{ALBERT_IVY_CLONE.action_serial}")

        ivy.overdrive = 0
        ALBERT_IVY_CLONE.action_serial = 501
        ALBERT_IVY_CLONE.process_party_damage(ivy, enemy, 10)
        first_self = ivy.overdrive.to_i
        ALBERT_IVY_CLONE.process_party_damage(ivy, enemy, 99)
        second_self = ivy.overdrive.to_i
        expected_self = team_gain + self_gain
        self_ok = first_self == expected_self && second_self == expected_self
        assert("Phase46B2 Ivy self-hit awards team +2% and self +2% exactly once in the same serial", self_ok,
               "expected=#{expected_self} first=#{first_self} second=#{second_self} serial=#{ALBERT_IVY_CLONE.action_serial}")

        ivy.overdrive = 0
        ALBERT_IVY_CLONE.action_serial = 502
        ALBERT_IVY_CLONE.process_party_damage(teammate, enemy, 10)
        rearm_ok = ivy.overdrive.to_i == team_gain
        assert("Phase46B2 Ivy team-hit OD dedupe rearms on the next action serial", rearm_ok,
               "expected=#{team_gain} actual=#{ivy.overdrive} serial=#{ALBERT_IVY_CLONE.action_serial}")
      ensure
        ivy.overdrive = od0 if ivy != nil && od0 != nil
        p46a_restore_ivar(ivy, :@albert_ic_team_hit_serial, team_snap)
        p46a_restore_ivar(ivy, :@albert_ic_self_hit_serial, self_snap)
        ALBERT_IVY_CLONE.action_serial = serial0
        if added && $game_party != nil
          $game_party.remove_actor(ivy.id) rescue nil
        end
      end
      cleanup = p46b2_party_ids == party_before && p46a_registry_signature == before_globals &&
                ALBERT_IVY_CLONE.action_serial.to_i == serial0 && (ivy == nil || ivy.overdrive.to_i == od0.to_i)
      assert("Phase46B2 Ivy team/self-hit OD fixture restores Party/serial/OD exactly", cleanup,
             "party=#{p46b2_party_ids.inspect} expected=#{party_before.inspect} serial=#{ALBERT_IVY_CLONE.action_serial}/#{serial0}")
      ready = team_ok && self_ok && rearm_ok && cleanup
      log("[IVY_HIT_OD_DEDUPE] team_percent=#{ALBERT_IVY_CLONE::IVY_TEAM_HIT_OD_PERCENT} self_percent=#{ALBERT_IVY_CLONE::IVY_SELF_HIT_OD_PERCENT} team=#{team_ok} self=#{self_ok} rearm=#{rearm_ok} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b2_run_party_od_dedupe_fixture")
      assert("Phase46B2 Ivy team/self-hit OD serial dedupe completed", false, e.message)
      false
    end

    def p46b2_run_fatal_cover_compat_fixture
      before_globals = p46a_registry_signature
      ivy = Game_Actor.new(ALBERT_CHARACTER_CORE::IVY_ACTOR_ID)
      enemy = ($game_troop.existing_members[0] rescue nil)
      required = ($data_skills[ALBERT_IVY_CLONE::IVY_FATAL_COVER_REQUIRED_SKILL_ID] rescue nil)
      raw_skills0 = ivy == nil ? nil : p46a_ivar_snapshot(ivy, :@skills)
      battle = $scene
      active0 = (battle != nil && battle.respond_to?(:active_battler)) ? battle.active_battler : nil
      if ivy != nil && required != nil
        skills = ivy.instance_variable_get(:@skills)
        skills = [] unless skills.is_a?(Array)
        skills = skills.clone
        skills.push(required.id.to_i) unless skills.include?(required.id.to_i)
        ivy.instance_variable_set(:@skills, skills)
      end
      learned = false
      begin
        learned = ivy.skill_learn?(required) if ivy != nil && required != nil && ivy.respond_to?(:skill_learn?)
      rescue
        learned = false
      end
      ready0 = !!(ivy != nil && enemy != nil && required != nil && learned)
      assert("Phase46B2 Ivy Fatal Cover compatibility detached fixture ready", ready0,
             "ivy=#{ivy == nil ? nil : ivy.id} required=#{required == nil ? nil : required.id} learned=#{learned}")
      return false unless ready0

      names = [:@albert_cover_redirect_guard, :@albert_ic_fatal_cover_used,
               :@albert_mx_stored_cover_damage, :@hp_damage, :@drive_type]
      snaps = {}; names.each { |n| snaps[n] = p46a_ivar_snapshot(ivy,n) }
      hp0 = ivy.hp.to_i
      od0 = ivy.overdrive.to_i
      fatal_ok = once_ok = cleanup = false
      begin
        p45k_disable_drive_gain(ivy)
        ivy.hp = 50
        ivy.overdrive = 500
        ivy.albert_mx_stored_cover_damage = 0
        ivy.instance_variable_set(:@albert_cover_redirect_guard, true)
        ivy.instance_variable_set(:@albert_ic_fatal_cover_used, false)
        ALBERT_IVY_CLONE.set_hp_damage(ivy, 50)
        battle.active_battler = enemy if battle != nil && battle.respond_to?(:active_battler=)
        ivy.execute_damage(enemy)
        stored_after = ivy.albert_mx_stored_cover_damage.to_i
        fatal_ok = ivy.hp.to_i == 1 && ivy.overdrive.to_i == 200 && stored_after == 49 &&
                   ivy.instance_variable_get(:@albert_ic_fatal_cover_used) == true
        assert("Phase46B2 Ivy Fatal Cover keeps 1 HP, pays exact 300 OD, and stores the actual 49 Cover loss", fatal_ok,
               "hp=#{ivy.hp} od=#{ivy.overdrive} stored=#{stored_after} used=#{ivy.instance_variable_get(:@albert_ic_fatal_cover_used).inspect}")

        ivy.hp = 50
        ivy.overdrive = 500
        ALBERT_IVY_CLONE.set_hp_damage(ivy, 50)
        battle.active_battler = enemy if battle != nil && battle.respond_to?(:active_battler=)
        ivy.execute_damage(enemy)
        once_ok = ivy.hp.to_i == 0 && ivy.instance_variable_get(:@albert_ic_fatal_cover_used) == true
        assert("Phase46B2 Ivy Fatal Cover remains once-per-battle after the first save", once_ok,
               "hp=#{ivy.hp} od=#{ivy.overdrive} stored=#{ivy.albert_mx_stored_cover_damage} used=#{ivy.instance_variable_get(:@albert_ic_fatal_cover_used).inspect}")
      ensure
        ivy.hp = hp0
        ivy.overdrive = od0
        names.each { |n| p46a_restore_ivar(ivy,n,snaps[n]) }
        p46a_restore_ivar(ivy, :@skills, raw_skills0)
        battle.active_battler = active0 if battle != nil && battle.respond_to?(:active_battler=)
      end
      cleanup = p46a_registry_signature == before_globals && ivy.hp.to_i == hp0 && ivy.overdrive.to_i == od0 &&
                p46a_ivar_snapshot(ivy, :@skills) == raw_skills0 &&
                (battle == nil || !battle.respond_to?(:active_battler) || battle.active_battler.equal?(active0))
      assert("Phase46B2 Ivy Fatal Cover detached fixture restores touched state and globals exactly", cleanup)
      ready = fatal_ok && once_ok && cleanup
      log("[IVY_FATAL_COVER_COMPAT] hp1_cost300_stored=#{fatal_ok} once=#{once_ok} ready=#{ready}")
      ready
    rescue Exception => e
      exception(e, "p46b2_run_fatal_cover_compat_fixture")
      assert("Phase46B2 Ivy Fatal Cover compatibility completed", false, e.message)
      false
    end

    def p46b2_run_character_suite
      return @p46b2_suite_ready if @p46b2_suite_ran
      @p46b2_suite_ran = true
      prior = @p46b_suite_ready == true
      assert("Phase46B2 starts only after sealed-in-run Phase46B map II", prior,
             "p46b=#{@p46b_suite_ready.inspect}")
      consume = p46b2_run_consume_gate_fixture
      active = p46b2_run_active_cover_fixture
      dedupe = p46b2_run_party_od_dedupe_fixture
      fatal = p46b2_run_fatal_cover_compat_fixture
      ready = prior && consume && active && dedupe && fatal
      @p46b2_suite_ready = ready
      log("[CHARACTER_REGRESSION_MAP_III] ivy_consume_gate=#{consume} ivy_active_cover_od=#{active} ivy_team_self_serial_dedupe=#{dedupe} ivy_fatal_cover_compat=#{fatal} pending=[:aizhuo,:mia,:vina,:tyler] ready=#{ready}")
      assert("Phase46B2 Ivy lifecycle tail map III completed", ready,
             "consume=#{consume} active=#{active} dedupe=#{dedupe} fatal=#{fatal}")
      ready
    rescue Exception => e
      exception(e, "p46b2_run_character_suite")
      @p46b2_suite_ready = false
      assert("Phase46B2 Ivy lifecycle tail map III completed", false, e.message)
      false
    end

    unless method_defined?(:fs_phase46b2_core_finalize_fixture_base)
      alias fs_phase46b2_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase46b2_core_finalize_fixture_base
      if fixture != nil && fixture[:p45f_field_owner]
        p46b2_run_character_suite
      end
      result
    rescue Exception => e
      exception(e, "p46b2_core_finalize_current_fixture")
      assert("Phase46B2 Main Character Regression III completed", false, e.message)
      result
    end

    unless method_defined?(:fs_phase46b2_restore_pending_base)
      alias fs_phase46b2_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase46b2_restore_pending_base
      if result
        @p46b2_suite_ready = nil
        @p46b2_suite_ran = nil
      end
      result
    end
  end
end
end


#==============================================================================
# 【Phase46C】Main Character Regression IV — Aizhuo ATB Control Core I
#------------------------------------------------------------------------------
# TEST-only；Formal Runtime 零變更。
# Phase46C1：依 1213 PASS / 8 FAIL / 0 WARN 實機結果，只修 TEST contract/context/cleanup；艾卓 actual-reduction/timing/interrupt Runtime 已全數 PASS。
# Phase46B2b 實機 1178 PASS / 0 FAIL / 0 WARN 後，Ivy Main Character Regression SEALED。
# 本批鎖定艾卓正式 ATB Authority：
#   1. Skill120/121/122/123/124/125/127/128/129 正式資料契約。
#   2. CharacterCore 依「實際 before-after ATB 削減」計算 OD，含 0 下限 clamp。
#   3. Skill121 高 ATB 門檻、Skill123 State32 條件幅度。
#   4. Skill122 靜電回收：OD→ATB bonus、低 ATB 目標一次 8% 自身 ATB refund。
#   5. Skill125 打斷：跨越 80% threshold、action-start OD gate、200 OD 支付、State38/2 turns。
#   6. Skill124 超載迴路：下一次 ATB +30% 幅度 / 30% 動態抗性穿透，一次成功削減後消耗。
#   7. 正式 <atb_dynamic_resist> Enemy detached interaction。
#   8. 目前 Scene_Battle live Enemy 的完整 skill_effect chain（local zero-damage clone，Note 保持正式 Skill120）。
# 所有 Actor/Enemy/Skill clone、ATB、OD、State、Scene active_battler 與 runtime ivar 皆 exact restore。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p46c_skill(id)
      return ($data_skills[id] rescue nil)
    end

    def p46c_note?(obj, regexp)
      return false if obj == nil
      return false unless obj.respond_to?(:note)
      return obj.note.to_s =~ regexp ? true : false
    rescue
      return false
    end

    def p46c_reset_special_od(actor)
      return if actor == nil
      actor.instance_variable_set(:@albert_special_od_action_gain, {})
      actor.instance_variable_set(:@albert_mx_aizhuo_low_refund_used, false)
    end

    def p46c_set_atb(battler, value)
      return if battler == nil
      battler.instance_variable_set(:@at_count, value.to_i)
    end

    def p46c_atb(battler)
      return 0 if battler == nil
      return battler.at_count.to_i if battler.respond_to?(:at_count)
      return battler.instance_variable_get(:@at_count).to_i
    rescue
      return 0
    end

    def p46c_apply_aftereffect(target, user, skill, before)
      p46c_set_atb(target, before)
      target.albert_combo_set_effect_context(user, skill)
      begin
        target.albert_combo_process_skill_aftereffects(user, skill)
      ensure
        target.albert_combo_clear_effect_context
      end
      return before.to_i - p46c_atb(target)
    end

    def p46c_inject_skill(actor, skill_id)
      snap = p46a_ivar_snapshot(actor, :@skills)
      skills = actor.instance_variable_get(:@skills)
      skills = [] unless skills.is_a?(Array)
      skills = skills.clone
      skills.push(skill_id.to_i) unless skills.include?(skill_id.to_i)
      actor.instance_variable_set(:@skills, skills)
      return snap
    end

    def p46c_remove_state_safe(battler, state_id)
      return if battler == nil
      battler.remove_state(state_id) if battler.respond_to?(:state?) && battler.state?(state_id)
    rescue
    end

    def p46c_full_ivar_snapshot(obj)
      result = {}
      return result if obj == nil
      for name in obj.instance_variables
        key = name.to_s
        value = obj.instance_variable_get(name)
        begin
          result[key] = [:marshal, Marshal.dump(value)]
        rescue
          result[key] = [:raw, value]
        end
      end
      return result
    rescue
      return {}
    end

    def p46c_restore_full_ivar_snapshot(obj, snap)
      return if obj == nil || !snap.is_a?(Hash)
      current = []
      begin
        current = obj.instance_variables.collect { |name| name.to_s }
      rescue
        current = []
      end
      for key in current
        next if snap.has_key?(key)
        begin
          obj.send(:remove_instance_variable, key.intern)
        rescue
        end
      end
      snap.each do |key, data|
        value = nil
        if data.is_a?(Array) && data[0] == :marshal
          begin
            value = Marshal.load(data[1])
          rescue
            value = nil
          end
        elsif data.is_a?(Array)
          value = data[1]
        end
        begin
          obj.instance_variable_set(key.intern, value)
        rescue
        end
      end
    end

    def p46c_find_dynamic_enemy_id
      return 0 if $data_enemies == nil
      i = 1
      while i < $data_enemies.size
        enemy = $data_enemies[i] rescue nil
        if enemy != nil && enemy.respond_to?(:note) &&
           enemy.note.to_s =~ /<\s*atb_dynamic_resist\s*>/i
          return i
        end
        i += 1
      end
      return 0
    rescue
      return 0
    end

    def p46c_make_dynamic_enemy(enemy_id)
      return nil if enemy_id.to_i <= 0
      # VX Game_Enemy#initialize signature is (index, enemy_id).
      # Phase46C mistakenly used (1, 0) and only changed @enemy_id afterwards,
      # which can fail during initialization before the formal Enemy is bound.
      enemy = Game_Enemy.new(0, enemy_id.to_i) rescue nil
      return enemy
    rescue
      return nil
    end

    def p46c_run_contract_fixture
      actor = Game_Actor.new(ALBERT_CHARACTER_CORE::AIZHUO_ACTOR_ID) rescue nil
      profile_text = ""
      begin
        profile_text = ALBERT_ACTOR_PROFILE.tag_text(ALBERT_CHARACTER_CORE::AIZHUO_ACTOR_ID).to_s
      rescue
        profile_text = ""
      end
      profile_tag_ok = !!(profile_text =~ /<cc_od_atb_per_10\s*:\s*30\s*>/i)
      identity_ok = actor != nil && actor.id == 3 && actor.respond_to?(:albert_cc_aizhuo?) &&
                    actor.albert_cc_aizhuo? && profile_tag_ok
      assert("Phase46C Aizhuo Actor3 identity and formal profile OD tag resolved", identity_ok,
             "actor=#{actor == nil ? nil : actor.id} profile=#{profile_text.inspect}")

      ids = [120,121,122,123,124,125,127,128,129]
      skills = {}
      ids.each { |id| skills[id] = p46c_skill(id) }
      all_exist = ids.all? { |id| skills[id] != nil }
      assert("Phase46C Aizhuo formal Skill set exists", all_exist,
             ids.collect{|id| "#{id}:#{skills[id] == nil ? nil : skills[id].name}"}.join(","))

      s = skills[120]
      ok120 = s != nil && s.name.to_s == "電鋒突刺" && p46c_note?(s, /<atb_shift\s*:\s*-8\s*>/i)
      assert("Phase46C Skill120 電鋒突刺 formal ATB contract", ok120, s == nil ? "nil" : s.note.to_s)

      s = skills[121]
      ok121 = s != nil && s.name.to_s == "截流槍" &&
              p46c_note?(s, /<atb_shift\s*:\s*-16\s*>/i) &&
              p46c_note?(s, /<atb_bonus_if_target_atb_above\s+60\s*:\s*35\s*>/i)
      assert("Phase46C Skill121 截流槍 high-ATB contract", ok121, s == nil ? "nil" : s.note.to_s)

      s = skills[122]
      ok122 = s != nil && s.name.to_s == "靜電回收" &&
              p46c_note?(s, /<mechanic_passive\s*>/i) &&
              p46c_note?(s, /<cc_od_atb_per_10\s*:\s*30\s*>/i)
      assert("Phase46C Skill122 靜電回收 passive contract", ok122, s == nil ? "nil" : s.note.to_s)

      s = skills[123]
      ok123 = s != nil && s.name.to_s == "雷鎖" &&
              p46c_note?(s, /<atb_shift\s*:\s*-14\s*>/i) &&
              p46c_note?(s, /<atb_bonus_vs_state\s+32\s*:\s*60\s*>/i)
      assert("Phase46C Skill123 雷鎖 wet-state ATB contract", ok123, s == nil ? "nil" : s.note.to_s)

      s = skills[124]
      ok124 = s != nil && s.name.to_s == "超載迴路" &&
              p46c_note?(s, /<overdrive\s+250\s*>/i) &&
              p46c_note?(s, /<aizhuo_overload_next_atb\s+30\s*:\s*30\s*>/i) &&
              s.respond_to?(:plus_state_set) && s.plus_state_set.include?(42) && s.plus_state_set.include?(100)
      assert("Phase46C Skill124 超載迴路 OD/next-ATB contract", ok124,
             s == nil ? "nil" : "states=#{s.plus_state_set.inspect} note=#{s.note}")

      s = skills[125]
      ok125 = s != nil && s.name.to_s == "時間斷層" &&
              p46c_note?(s, /<atb_shift\s*:\s*-24\s*>/i) &&
              p46c_note?(s, /<atb_bonus_if_target_atb_above\s+80\s*:\s*50\s*>/i) &&
              p46c_note?(s, /<atb_interrupt_threshold\s*:\s*80\s*>/i) &&
              p46c_note?(s, /<atb_interrupt_cost\s*:\s*200\s*>/i) &&
              p46c_note?(s, /<atb_interrupt_state\s+38\s*:\s*2\s*>/i)
      assert("Phase46C Skill125 時間斷層 threshold/cost/state contract", ok125, s == nil ? "nil" : s.note.to_s)

      s = skills[127]
      ok127 = s != nil && s.name.to_s == "鏈式放電" && s.scope.to_i == 2 &&
              p46c_note?(s, /<atb_shift\s*:\s*-10\s*>/i) &&
              p46c_note?(s, /<atb_bonus_vs_state\s+32\s*:\s*40\s*>/i)
      assert("Phase46C Skill127 鏈式放電 all-target ATB contract", ok127, s == nil ? "nil" : s.note.to_s)

      s = skills[128]
      ok128 = s != nil && s.name.to_s == "零時封鎖" &&
              p46c_note?(s, /<atb_shift\s*:\s*-35\s*>/i) &&
              p46c_note?(s, /<atb_bonus_if_target_atb_above\s+90\s*:\s*80\s*>/i) &&
              p46c_note?(s, /<atb_interrupt_threshold\s*:\s*90\s*>/i) &&
              p46c_note?(s, /<atb_interrupt_cost\s*:\s*350\s*>/i)
      assert("Phase46C Skill128 零時封鎖 high-threshold interrupt contract", ok128, s == nil ? "nil" : s.note.to_s)

      s = skills[129]
      ok129 = s != nil && s.name.to_s == "終端超頻" && s.scope.to_i == 2 &&
              p46c_note?(s, /<atb_shift\s*:\s*-22\s*>/i) &&
              p46c_note?(s, /<atb_bonus_if_target_atb_above\s+70\s*:\s*50\s*>/i)
      assert("Phase46C Skill129 終端超頻 all-target high-ATB contract", ok129, s == nil ? "nil" : s.note.to_s)

      constants_ok = ALBERT_CHARACTER_CORE::AIZHUO_OD_PER_10_ATB_REDUCTION.to_i == 20 &&
                     ALBERT_CHARACTER_CORE::AIZHUO_SPECIAL_OD_ACTION_CAP.to_i == 200 &&
                     ALBERT_MECHANIC_EXPANSION::AIZHUO_TIMING_PASSIVE_SKILL_ID.to_i == 122 &&
                     ALBERT_MECHANIC_EXPANSION::AIZHUO_OD_ATB_BONUS_PER_PERCENT.to_f == 0.2 &&
                     ALBERT_MECHANIC_EXPANSION::AIZHUO_LOW_ATB_THRESHOLD.to_f == 40.0 &&
                     ALBERT_MECHANIC_EXPANSION::AIZHUO_LOW_ATB_REFUND_PERCENT.to_f == 8.0
      assert("Phase46C Aizhuo CharacterCore/MechanicExpansion constants resolved", constants_ok,
             "base_per10=#{ALBERT_CHARACTER_CORE::AIZHUO_OD_PER_10_ATB_REDUCTION} cap=#{ALBERT_CHARACTER_CORE::AIZHUO_SPECIAL_OD_ACTION_CAP} timing=#{ALBERT_MECHANIC_EXPANSION::AIZHUO_TIMING_PASSIVE_SKILL_ID}")
      return identity_ok && all_exist && ok120 && ok121 && ok122 && ok123 && ok124 && ok125 && ok127 && ok128 && ok129 && constants_ok
    rescue Exception => e
      exception(e, "p46c_run_contract_fixture")
      assert("Phase46C Aizhuo formal contract fixture completed", false, e.message)
      return false
    end

    def p46c_run_actual_reduction_fixture
      before_globals = p46a_registry_signature
      actor = Game_Actor.new(3) rescue nil
      target = Game_Actor.new(1) rescue nil
      s120 = p46c_skill(120)
      s121 = p46c_skill(121)
      s123 = p46c_skill(123)
      ready0 = actor != nil && target != nil && s120 != nil && s121 != nil && s123 != nil &&
               target.respond_to?(:albert_combo_process_skill_aftereffects)
      assert("Phase46C Aizhuo detached actual-reduction fixture ready", ready0,
             "actor=#{actor == nil ? nil : actor.id} target=#{target == nil ? nil : target.id}")
      return false unless ready0

      actor_od0 = actor.overdrive.to_i
      actor_at0 = p46a_ivar_snapshot(actor, :@at_count)
      actor_special0 = p46a_ivar_snapshot(actor, :@albert_special_od_action_gain)
      target_at0 = p46a_ivar_snapshot(target, :@at_count)
      flags = [:@act_count, :@act_active, :@at_active, :@atb_count_up]
      flag_snaps = {}; flags.each{|n| flag_snaps[n] = p46a_ivar_snapshot(target,n)}
      state32 = p46a_ivar_snapshot(target, :@states)
      state_turns = p46a_ivar_snapshot(target, :@state_turns)
      ok120 = clamp_ok = flags_ok = low121 = high121 = state123 = cleanup = false
      begin
        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s120, 500)
        ok120 = reduction == 80 && p46c_atb(target) == 420 && actor.overdrive.to_i == 24
        assert("Phase46C Skill120 actual ATB -8% grants OD from exact 80 reduction", ok120,
               "reduction=#{reduction} target=#{p46c_atb(target)} od=#{actor.overdrive}")

        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s120, 50)
        clamp_ok = reduction == 50 && p46c_atb(target) == 0 && actor.overdrive.to_i == 15
        assert("Phase46C Aizhuo OD uses clamped actual ATB reduction, not requested amount", clamp_ok,
               "requested=80 actual=#{reduction} target=#{p46c_atb(target)} od=#{actor.overdrive}")

        target.instance_variable_set(:@act_count, 99)
        target.instance_variable_set(:@act_active, true)
        target.instance_variable_set(:@at_active, true)
        target.instance_variable_set(:@atb_count_up, false)
        actor.overdrive = 0
        p46c_reset_special_od(actor)
        p46c_apply_aftereffect(target, actor, s120, 500)
        flags_ok = target.instance_variable_get(:@act_count).to_i == 0 &&
                   target.instance_variable_get(:@act_active) == false &&
                   target.instance_variable_get(:@at_active) == false &&
                   target.instance_variable_get(:@atb_count_up) == true
        assert("Phase46C negative ATB shift resets action/cast wait flags through ComboCore", flags_ok,
               "act=#{target.instance_variable_get(:@act_count)} act_active=#{target.instance_variable_get(:@act_active).inspect} at_active=#{target.instance_variable_get(:@at_active).inspect} count_up=#{target.instance_variable_get(:@atb_count_up).inspect}")

        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s121, 500)
        low121 = reduction == 160 && p46c_atb(target) == 340 && actor.overdrive.to_i == 48
        assert("Phase46C Skill121 below 60% target ATB uses base -16% and actual-reduction OD", low121,
               "reduction=#{reduction} target=#{p46c_atb(target)} od=#{actor.overdrive}")

        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s121, 700)
        high121 = reduction == 216 && p46c_atb(target) == 484 && actor.overdrive.to_i == 64
        assert("Phase46C Skill121 at >=60% target ATB applies +35% ATB magnitude", high121,
               "reduction=#{reduction} target=#{p46c_atb(target)} od=#{actor.overdrive}")

        p46c_remove_state_safe(target, 32)
        actor.overdrive = 0
        p46c_reset_special_od(actor)
        dry = p46c_apply_aftereffect(target, actor, s123, 600)
        p46c_set_atb(target, 600)
        target.add_state(32)
        actor.overdrive = 0
        p46c_reset_special_od(actor)
        wet = p46c_apply_aftereffect(target, actor, s123, 600)
        state123 = dry == 140 && wet == 224
        assert("Phase46C Skill123 State32 raises ATB reduction magnitude from 14% to 22.4%", state123,
               "dry=#{dry} wet=#{wet} state32=#{target.state?(32)}")
      ensure
        actor.overdrive = actor_od0 if actor != nil
        p46a_restore_ivar(actor, :@at_count, actor_at0)
        p46a_restore_ivar(actor, :@albert_special_od_action_gain, actor_special0)
        p46a_restore_ivar(target, :@at_count, target_at0)
        flags.each{|n| p46a_restore_ivar(target,n,flag_snaps[n])}
        p46a_restore_ivar(target, :@states, state32)
        p46a_restore_ivar(target, :@state_turns, state_turns)
      end
      cleanup = p46a_registry_signature == before_globals && actor.overdrive.to_i == actor_od0
      assert("Phase46C actual-reduction detached fixture restores globals and touched runtime exactly", cleanup)
      return ready0 && ok120 && clamp_ok && flags_ok && low121 && high121 && state123 && cleanup
    rescue Exception => e
      exception(e, "p46c_run_actual_reduction_fixture")
      assert("Phase46C Aizhuo actual reduction fixture completed", false, e.message)
      return false
    end

    def p46c_run_timing_passive_fixture
      before_globals = p46a_registry_signature
      actor = Game_Actor.new(3) rescue nil
      target = Game_Actor.new(1) rescue nil
      s120 = p46c_skill(120)
      s122 = p46c_skill(122)
      skills0 = actor == nil ? nil : p46a_ivar_snapshot(actor, :@skills)
      actor_od0 = actor == nil ? nil : actor.overdrive.to_i
      actor_at0 = p46a_ivar_snapshot(actor, :@at_count)
      low0 = p46a_ivar_snapshot(actor, :@albert_mx_aizhuo_low_refund_used)
      target_at0 = p46a_ivar_snapshot(target, :@at_count)
      ready0 = actor != nil && target != nil && s120 != nil && s122 != nil
      if ready0
        p46c_inject_skill(actor, 122)
        ready0 = actor.skill_learn?(s122) rescue false
      end
      assert("Phase46C Skill122 timing passive TEST prerequisite installed on detached Aizhuo", ready0,
             "skills=#{actor == nil ? nil : actor.instance_variable_get(:@skills).inspect}")
      return false unless ready0

      od_bonus_ok = refund_ok = dedupe_ok = cleanup = false
      begin
        actor.overdrive = 500
        p46c_set_atb(actor, 200)
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s120, 500)
        od_bonus_ok = reduction == 88 && p46c_atb(target) == 412
        assert("Phase46C Skill122 converts 50% OD into +10% ATB reduction magnitude", od_bonus_ok,
               "reduction=#{reduction} target=#{p46c_atb(target)} od_after=#{actor.overdrive}")

        actor.overdrive = 0
        p46c_set_atb(actor, 200)
        actor.instance_variable_set(:@albert_mx_aizhuo_low_refund_used, false)
        p46c_reset_special_od(actor)
        reduction1 = p46c_apply_aftereffect(target, actor, s120, 300)
        at_after1 = p46c_atb(actor)
        refund_ok = reduction1 == 80 && at_after1 == 280 &&
                    actor.instance_variable_get(:@albert_mx_aizhuo_low_refund_used) == true
        assert("Phase46C Skill122 low-target timing refund advances Aizhuo ATB exactly +8%", refund_ok,
               "target_reduction=#{reduction1} actor_at=#{at_after1} used=#{actor.instance_variable_get(:@albert_mx_aizhuo_low_refund_used).inspect}")

        reduction2 = p46c_apply_aftereffect(target, actor, s120, 300)
        at_after2 = p46c_atb(actor)
        dedupe_ok = reduction2 == 80 && at_after2 == at_after1
        assert("Phase46C Skill122 low-target ATB refund is once per action via runtime dedupe flag", dedupe_ok,
               "actor_at=#{at_after1}->#{at_after2} used=#{actor.instance_variable_get(:@albert_mx_aizhuo_low_refund_used).inspect}")
      ensure
        actor.overdrive = actor_od0 if actor != nil && actor_od0 != nil
        p46a_restore_ivar(actor, :@skills, skills0)
        p46a_restore_ivar(actor, :@at_count, actor_at0)
        p46a_restore_ivar(actor, :@albert_mx_aizhuo_low_refund_used, low0)
        p46a_restore_ivar(target, :@at_count, target_at0)
      end
      cleanup = p46a_registry_signature == before_globals &&
                p46a_ivar_snapshot(actor, :@skills) == skills0 &&
                p46a_ivar_snapshot(actor, :@at_count) == actor_at0
      assert("Phase46C Skill122 timing passive fixture restores raw Skill/ATB/OD context exactly", cleanup)
      return ready0 && od_bonus_ok && refund_ok && dedupe_ok && cleanup
    rescue Exception => e
      exception(e, "p46c_run_timing_passive_fixture")
      assert("Phase46C Aizhuo timing passive fixture completed", false, e.message)
      return false
    end

    def p46c_run_interrupt_fixture
      before_globals = p46a_registry_signature
      actor = Game_Actor.new(3) rescue nil
      target = Game_Actor.new(1) rescue nil
      skill = p46c_skill(125)
      state38 = ($data_states[38] rescue nil)
      ready0 = actor != nil && target != nil && skill != nil && state38 != nil
      assert("Phase46C Skill125 interrupt detached fixture ready", ready0,
             "skill=#{skill == nil ? nil : skill.name} state38=#{state38 == nil ? nil : state38.name}")
      return false unless ready0

      actor_od0 = actor.overdrive.to_i
      start0 = p46a_ivar_snapshot(actor, :@albert_od_action_start_value)
      special0 = p46a_ivar_snapshot(actor, :@albert_special_od_action_gain)
      target_at0 = p46a_ivar_snapshot(target, :@at_count)
      states0 = p46a_ivar_snapshot(target, :@states)
      turns0 = p46a_ivar_snapshot(target, :@state_turns)
      crossed_ok = below_ok = insufficient_ok = cleanup = false
      begin
        p46c_remove_state_safe(target, 38)
        actor.overdrive = 300
        actor.instance_variable_set(:@albert_od_action_start_value, 300)
        p46c_reset_special_od(actor)
        p37_with_combat_rng("phase46c_skill125_interrupt") do
          reduction = p46c_apply_aftereffect(target, actor, skill, 900)
          turns = target.instance_variable_get(:@state_turns)
          turn_value = turns == nil ? nil : turns[38]
          crossed_ok = reduction == 360 && actor.overdrive.to_i == 208 &&
                       target.state?(38) && turn_value.to_i == 2
        end
        assert("Phase46C Skill125 crossing 80% threshold pays 200 OD after actual-reduction gain and applies State38/2", crossed_ok,
               "target_at=#{p46c_atb(target)} od=#{actor.overdrive} state38=#{target.state?(38)} turns=#{(target.instance_variable_get(:@state_turns)||{})[38]}")

        p46c_remove_state_safe(target, 38)
        actor.overdrive = 300
        actor.instance_variable_set(:@albert_od_action_start_value, 300)
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, skill, 700)
        below_ok = reduction == 240 && actor.overdrive.to_i == 372 && !target.state?(38)
        assert("Phase46C Skill125 below interrupt threshold does not pay conditional OD or apply State38", below_ok,
               "reduction=#{reduction} od=#{actor.overdrive} state38=#{target.state?(38)}")

        p46c_remove_state_safe(target, 38)
        actor.overdrive = 500
        actor.instance_variable_set(:@albert_od_action_start_value, 100)
        p46c_reset_special_od(actor)
        p37_with_combat_rng("phase46c_skill125_insufficient_start_od") do
          reduction = p46c_apply_aftereffect(target, actor, skill, 900)
          insufficient_ok = reduction == 360 && actor.overdrive.to_i == 608 && !target.state?(38)
        end
        assert("Phase46C Skill125 interrupt cost gates on action-start OD, not OD gained during the same reduction", insufficient_ok,
               "start_od=100 current=#{actor.overdrive} state38=#{target.state?(38)}")
      ensure
        actor.overdrive = actor_od0
        p46a_restore_ivar(actor, :@albert_od_action_start_value, start0)
        p46a_restore_ivar(actor, :@albert_special_od_action_gain, special0)
        p46a_restore_ivar(target, :@at_count, target_at0)
        p46a_restore_ivar(target, :@states, states0)
        p46a_restore_ivar(target, :@state_turns, turns0)
      end
      cleanup = p46a_registry_signature == before_globals && actor.overdrive.to_i == actor_od0
      assert("Phase46C Skill125 interrupt fixture restores OD/State/ATB/globals exactly", cleanup)
      return crossed_ok && below_ok && insufficient_ok && cleanup
    rescue Exception => e
      exception(e, "p46c_run_interrupt_fixture")
      assert("Phase46C Aizhuo interrupt fixture completed", false, e.message)
      return false
    end

    def p46c_run_overload_dynamic_fixture
      before_globals = p46a_registry_signature
      actor = Game_Actor.new(3) rescue nil
      target = Game_Actor.new(1) rescue nil
      s120 = p46c_skill(120)
      s124 = p46c_skill(124)
      state100 = ($data_states[100] rescue nil)
      ready0 = actor != nil && target != nil && s120 != nil && s124 != nil &&
               actor.respond_to?(:albert_mx_od12_capture_skill_effect_context) &&
               actor.respond_to?(:albert_mx_od12_after_skill_effect)
      assert("Phase46C Skill124 overload provider fixture ready", ready0,
             "state100=#{state100 == nil ? nil : state100.name}")
      return false unless ready0

      actor_od0 = actor.overdrive.to_i
      actor_states0 = p46a_ivar_snapshot(actor, :@states)
      actor_turns0 = p46a_ivar_snapshot(actor, :@state_turns)
      bonus0 = p46a_ivar_snapshot(actor, :@albert_od_aizhuo_overload_bonus)
      pierce0 = p46a_ivar_snapshot(actor, :@albert_od_aizhuo_overload_pierce)
      special0 = p46a_ivar_snapshot(actor, :@albert_special_od_action_gain)
      target_at0 = p46a_ivar_snapshot(target, :@at_count)
      arm_ok = one_shot_ok = second_ok = dynamic_exists = dynamic_base_ok = dynamic_pierce_ok = cleanup = false
      begin
        actor.instance_variable_set(:@missed, false)
        actor.instance_variable_set(:@evaded, false)
        actor.instance_variable_set(:@skipped, false)
        context = actor.albert_mx_od12_capture_skill_effect_context(actor, s124)
        actor.albert_mx_od12_after_skill_effect(actor, s124, context)
        actor.add_state(100) if state100 != nil
        arm_ok = actor.instance_variable_get(:@albert_od_aizhuo_overload_bonus).to_f == 30.0 &&
                 actor.instance_variable_get(:@albert_od_aizhuo_overload_pierce).to_f == 30.0
        assert("Phase46C Skill124 successful self effect arms +30% next-ATB magnitude and 30% resistance pierce", arm_ok,
               "bonus=#{actor.instance_variable_get(:@albert_od_aizhuo_overload_bonus)} pierce=#{actor.instance_variable_get(:@albert_od_aizhuo_overload_pierce)} state100=#{state100 == nil ? nil : actor.state?(100)}")

        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction = p46c_apply_aftereffect(target, actor, s120, 500)
        one_shot_ok = reduction == 104 &&
                      actor.instance_variable_get(:@albert_od_aizhuo_overload_bonus).to_f == 0.0 &&
                      actor.instance_variable_get(:@albert_od_aizhuo_overload_pierce).to_f == 0.0 &&
                      (state100 == nil || !actor.state?(100))
        assert("Phase46C overload applies +30% to the next successful ATB reduction then consumes itself", one_shot_ok,
               "reduction=#{reduction} bonus=#{actor.instance_variable_get(:@albert_od_aizhuo_overload_bonus)} pierce=#{actor.instance_variable_get(:@albert_od_aizhuo_overload_pierce)}")

        actor.overdrive = 0
        p46c_reset_special_od(actor)
        reduction2 = p46c_apply_aftereffect(target, actor, s120, 500)
        second_ok = reduction2 == 80
        assert("Phase46C consumed overload does not affect the following ATB reduction", second_ok,
               "reduction=#{reduction2}")

        dyn_id = p46c_find_dynamic_enemy_id
        dyn = p46c_make_dynamic_enemy(dyn_id)
        dynamic_exists = dyn_id > 0 && dyn != nil && dyn.respond_to?(:albert_atb_dynamic_resist?) &&
                         dyn.albert_atb_dynamic_resist?
        assert("Phase46C formal <atb_dynamic_resist> Enemy fixture resolved", dynamic_exists,
               "enemy_id=#{dyn_id} name=#{dyn == nil || dyn.enemy == nil ? nil : dyn.enemy.name}")
        if dynamic_exists
          dyn.instance_variable_set(:@albert_atb_resist_level, 2)
          p46c_set_atb(dyn, 900)
          actor.overdrive = 0
          p46c_reset_special_od(actor)
          rate = dyn.albert_atb_resist_rate.to_f
          expected = (80.0 * rate / 100.0).to_i
          actual = p46c_apply_aftereffect(dyn, actor, s120, 900)
          dynamic_base_ok = actual == expected
          assert("Phase46C dynamic ATB resistance reduces Skill120 by the formal current resistance rate", dynamic_base_ok,
                 "rate=#{rate} expected=#{expected} actual=#{actual} resist_level=#{dyn.albert_atb_resist_level}")

          dyn.instance_variable_set(:@albert_atb_resist_level, 2)
          p46c_set_atb(dyn, 900)
          context = actor.albert_mx_od12_capture_skill_effect_context(actor, s124)
          actor.instance_variable_set(:@missed, false)
          actor.instance_variable_set(:@evaded, false)
          actor.instance_variable_set(:@skipped, false)
          actor.albert_mx_od12_after_skill_effect(actor, s124, context)
          base_rate = dyn.albert_atb_resist_rate.to_f
          adjusted = base_rate + (100.0 - base_rate) * 30.0 / 100.0
          expected_pierced = (104.0 * adjusted / 100.0).to_i
          actor.overdrive = 0
          p46c_reset_special_od(actor)
          actual_pierced = p46c_apply_aftereffect(dyn, actor, s120, 900)
          dynamic_pierce_ok = actual_pierced == expected_pierced &&
                              actor.instance_variable_get(:@albert_od_aizhuo_overload_bonus).to_f == 0.0 &&
                              actor.instance_variable_get(:@albert_od_aizhuo_overload_pierce).to_f == 0.0
          assert("Phase46C overload 30% pierce recovers resisted ATB magnitude and is consumed after actual reduction", dynamic_pierce_ok,
                 "base_rate=#{base_rate} adjusted=#{adjusted} expected=#{expected_pierced} actual=#{actual_pierced}")
        else
          assert("Phase46C dynamic ATB resistance baseline interaction completed", false, "formal dynamic enemy missing")
          assert("Phase46C overload dynamic-resistance pierce interaction completed", false, "formal dynamic enemy missing")
        end
      ensure
        actor.overdrive = actor_od0 if actor != nil
        p46a_restore_ivar(actor, :@states, actor_states0)
        p46a_restore_ivar(actor, :@state_turns, actor_turns0)
        p46a_restore_ivar(actor, :@albert_od_aizhuo_overload_bonus, bonus0)
        p46a_restore_ivar(actor, :@albert_od_aizhuo_overload_pierce, pierce0)
        p46a_restore_ivar(actor, :@albert_special_od_action_gain, special0)
        p46a_restore_ivar(target, :@at_count, target_at0)
      end
      cleanup = p46a_registry_signature == before_globals &&
                p46a_ivar_snapshot(actor, :@albert_od_aizhuo_overload_bonus) == bonus0 &&
                p46a_ivar_snapshot(actor, :@albert_od_aizhuo_overload_pierce) == pierce0
      assert("Phase46C overload/dynamic-resistance detached fixture restores touched context exactly", cleanup)
      return arm_ok && one_shot_ok && second_ok && dynamic_exists && dynamic_base_ok && dynamic_pierce_ok && cleanup
    rescue Exception => e
      exception(e, "p46c_run_overload_dynamic_fixture")
      assert("Phase46C Aizhuo overload/dynamic-resistance fixture completed", false, e.message)
      return false
    end

    def p46c_run_live_skill_effect_fixture
      before_globals = p46a_registry_signature
      battle = $scene
      actor = Game_Actor.new(3) rescue nil
      target = ($game_troop.existing_members[0] rescue nil)
      source = p46c_skill(120)
      ready0 = battle.is_a?(Scene_Battle) && actor != nil && target != nil && source != nil
      assert("Phase46C live Scene_Battle target Skill120 semantic fixture ready", ready0,
             "scene=#{battle == nil ? nil : battle.class} target=#{target == nil ? nil : target.enemy_id}")
      return false unless ready0

      local = Marshal.load(Marshal.dump(source))
      local.base_damage = 0 if local.respond_to?(:base_damage=)
      local.atk_f = 0 if local.respond_to?(:atk_f=)
      local.spi_f = 0 if local.respond_to?(:spi_f=)
      local.variance = 0 if local.respond_to?(:variance=)
      local.physical_attack = false if local.respond_to?(:physical_attack=)
      local.plus_state_set = [] if local.respond_to?(:plus_state_set=)
      local.minus_state_set = [] if local.respond_to?(:minus_state_set=)

      active0 = battle.active_battler
      target_full0 = p46c_full_ivar_snapshot(target)
      actor_od0 = actor.overdrive.to_i
      actor_special0 = p46a_ivar_snapshot(actor, :@albert_special_od_action_gain)
      target_hp0 = target.hp.to_i
      target_mp0 = target.mp.to_i
      target_at0 = p46a_ivar_snapshot(target, :@at_count)
      target_states_bytes0 = (Marshal.dump(target.instance_variable_get(:@states)) rescue nil)
      target_turns_bytes0 = (Marshal.dump(target.instance_variable_get(:@state_turns)) rescue nil)
      effect_ok = cleanup = false
      begin
        battle.active_battler = actor
        actor.overdrive = 0
        p46c_reset_special_od(actor)
        p46c_set_atb(target, 500)
        p37_with_combat_rng("phase46c_live_skill120_effect") do
          target.skill_effect(actor, local)
        end
        effect_ok = p46c_atb(target) == 420 && actor.overdrive.to_i == 24 &&
                    target.hp.to_i == target_hp0
        assert("Phase46C live Battle Enemy full skill_effect chain applies Skill120 ATB -8% / actual OD24 without synthetic damage", effect_ok,
               "target_at=#{p46c_atb(target)} actor_od=#{actor.overdrive} hp=#{target_hp0}->#{target.hp}")
      ensure
        battle.active_battler = active0
        actor.overdrive = actor_od0
        p46a_restore_ivar(actor, :@albert_special_od_action_gain, actor_special0)
        p46c_restore_full_ivar_snapshot(target, target_full0)
      end
      globals_same = p46a_registry_signature == before_globals
      active_same = battle.active_battler.equal?(active0)
      at_same = p46a_ivar_snapshot(target, :@at_count) == target_at0
      hpmp_same = target.hp.to_i == target_hp0 && target.mp.to_i == target_mp0
      states_same = (Marshal.dump(target.instance_variable_get(:@states)) rescue nil) == target_states_bytes0
      turns_same = (Marshal.dump(target.instance_variable_get(:@state_turns)) rescue nil) == target_turns_bytes0
      actor_same = actor.overdrive.to_i == actor_od0 &&
                   p46a_ivar_snapshot(actor, :@albert_special_od_action_gain) == actor_special0
      cleanup = globals_same && active_same && at_same && hpmp_same &&
                states_same && turns_same && actor_same
      assert("Phase46C live Skill120 semantic fixture restores owned Scene/Enemy/Actor context exactly", cleanup,
             "active=#{active_same} globals=#{globals_same} atb=#{at_same} hpmp=#{hpmp_same} states=#{states_same} turns=#{turns_same} actor=#{actor_same}")
      return effect_ok && cleanup
    rescue Exception => e
      exception(e, "p46c_run_live_skill_effect_fixture")
      assert("Phase46C Aizhuo live skill_effect fixture completed", false, e.message)
      return false
    end

    def p46c_run_character_suite
      return @p46c_suite_ready if @p46c_suite_ran
      @p46c_suite_ran = true
      prior = @p46b2_suite_ready == true
      assert("Phase46C starts only after sealed-in-run Phase46B2 Map III", prior,
             "p46b2=#{@p46b2_suite_ready.inspect}")
      contract = p46c_run_contract_fixture
      actual = p46c_run_actual_reduction_fixture
      timing = p46c_run_timing_passive_fixture
      interrupt = p46c_run_interrupt_fixture
      overload = p46c_run_overload_dynamic_fixture
      live = p46c_run_live_skill_effect_fixture
      ready = prior && contract && actual && timing && interrupt && overload && live
      @p46c_suite_ready = ready
      log("[AIZHUO_REGRESSION_I] contract=#{contract} actual_reduction=#{actual} timing_passive=#{timing} interrupt=#{interrupt} overload_dynamic=#{overload} live_skill_effect=#{live} ready=#{ready}")
      log("[CHARACTER_REGRESSION_MAP_IV] aizhuo_atb_core=#{ready} pending=[:mia,:vina,:tyler] ready=#{ready}")
      assert("Phase46C Aizhuo ATB Control Core I / Character Map IV completed", ready,
             "contract=#{contract} actual=#{actual} timing=#{timing} interrupt=#{interrupt} overload=#{overload} live=#{live}")
      return ready
    rescue Exception => e
      exception(e, "p46c_run_character_suite")
      @p46c_suite_ready = false
      assert("Phase46C Aizhuo ATB Control Core I / Character Map IV completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase46c_core_finalize_fixture_base)
      alias fs_phase46c_core_finalize_fixture_base core_finalize_current_fixture
    end
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      result = fs_phase46c_core_finalize_fixture_base
      if fixture != nil && fixture[:p45f_field_owner]
        p46c_run_character_suite
      end
      return result
    rescue Exception => e
      exception(e, "p46c_core_finalize_current_fixture")
      assert("Phase46C Main Character Regression IV completed", false, e.message)
      return result
    end

    unless method_defined?(:fs_phase46c_restore_pending_base)
      alias fs_phase46c_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase46c_restore_pending_base
      if result
        @p46c_suite_ready = nil
        @p46c_suite_ran = nil
      end
      return result
    end
  end
end
end


#==============================================================================
# 【Phase46D2】Main Character Batch II — Multi-Battle Fixture Convergence I
#------------------------------------------------------------------------------
# TEST-only；Formal Runtime 零變更。
# Phase46D 首輪實機 672 PASS / 4 FAIL / 0 WARN；未進戰鬥，三個 substantive FAIL 均發生於 background semantic expectation。
# 本批提升單輪測試密度：
#   1. Scene_Map prebattle wait 期間以 frame-sliced background queue 執行 detached semantic jobs。
#   2. 一次覆蓋 Mia / Vina / Tyler 的資料契約與核心語意，不再每角色單獨要求一次實機。
#   3. 第一場既有 sealed regression 結束後暫不 restore Snapshot，自動排入第二場 Scene_Battle。
#   4. 第二場只跑 Main Character live semantic sandbox，舊 Combo/Summon fixture 暫時停用並在最終 restore 前復原。
#   5. Background semantic RED 改為 soft gate：保留 FAIL，但仍繼續 Battle 1 / Battle 2 蒐證。
#   6. Background OD fixture 改驗目前正式 Actor Profile，不再用 TEST OD rate 覆蓋正式角色 Authority。
#   7. Synthetic RPG::Skill 配置合法既存 Skill ID，讓 YEM SkillLevel 的 $data_skills[id].max_level 可安全通過。
#   8. 第一戰 EnemySummon/Combo observers 延後至第二戰 terminate 完成後才復原，避免第一戰已 dispose 的 Sprite 被第二戰 terminate 再驗一次。
#   9. 不使用 Ruby Thread；所有 RGSS2 / $game_* / Scene / Sprite 仍維持單執緒。
#  10. Phase46D4：Vina live convert 以正式 OD ledger 驗證：State stack +100、KGC ATTACK +10、preserve cost -150，起始200 => 最終160。
#==============================================================================
if $TEST && defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P46D_BACKGROUND_JOBS_PER_FRAME = 2 unless const_defined?(:P46D_BACKGROUND_JOBS_PER_FRAME)
  P46D_BACKGROUND_MIN_WAIT = 8 unless const_defined?(:P46D_BACKGROUND_MIN_WAIT)

  class << self
    def p46d_skill(id)
      return ($data_skills[id] rescue nil)
    end

    def p46d_note_has?(id, regexp)
      skill = p46d_skill(id)
      return false if skill == nil || !skill.respond_to?(:note)
      return skill.note.to_s =~ regexp ? true : false
    rescue
      return false
    end

    def p46d_detached_actor(id)
      return Game_Actor.new(id.to_i) rescue nil
    end

    def p46d_reset_action_od(actor, value = 0)
      return if actor == nil
      actor.overdrive = value.to_i if actor.respond_to?(:overdrive=)
      actor.instance_variable_set(:@albert_od_action_start_value, value.to_i)
      actor.instance_variable_set(:@albert_special_od_action_gain, {})
      actor.instance_variable_set(:@albert_cc_break_tier_cost_paid, false)
      actor.instance_variable_set(:@albert_cc_break_tier_cost, 0)
      actor.instance_variable_set(:@albert_cc_mia_revive_od_paid, false)
    end

    def p46d_stack_count(battler, state_id)
      return 0 if battler == nil
      if defined?(ALBERT_CHARACTER_CORE) && ALBERT_CHARACTER_CORE.respond_to?(:stack_count)
        return ALBERT_CHARACTER_CORE.stack_count(battler, state_id.to_i).to_i
      end
      return battler.stack(state_id.to_i).to_i if battler.respond_to?(:stack)
      return battler.state?(state_id.to_i) ? 1 : 0
    rescue
      return 0
    end

    def p46d_local_skill(note, base_damage = 0)
      skill = RPG::Skill.new
      # YEM SkillLevel 會以 obj.id 回查 $data_skills[id].max_level。
      # Synthetic Skill 必須持有一個存在的 DB ID，但不取代/修改正式 DB slot。
      if skill.respond_to?(:id=)
        skill.id = 1
      else
        skill.instance_variable_set(:@id, 1)
      end
      skill.note = note.to_s
      skill.scope = 1 if skill.respond_to?(:scope=)
      skill.occasion = 1 if skill.respond_to?(:occasion=)
      skill.base_damage = base_damage.to_i if skill.respond_to?(:base_damage=)
      skill.variance = 0 if skill.respond_to?(:variance=)
      skill.atk_f = 0 if skill.respond_to?(:atk_f=)
      skill.spi_f = 0 if skill.respond_to?(:spi_f=)
      skill.hit = 100 if skill.respond_to?(:hit=)
      skill.physical_attack = false if skill.respond_to?(:physical_attack=)
      skill.plus_state_set = [] if skill.respond_to?(:plus_state_set=)
      skill.minus_state_set = [] if skill.respond_to?(:minus_state_set=)
      # CustomDamage#critical_chance 可觸發 yanfly_cache_cdf 並重設 @no_crit。
      # 先完成 cache，再將 TEST synthetic skill 固定為 no-crit。
      skill.yanfly_cache_cdf if skill.respond_to?(:yanfly_cache_cdf)
      skill.instance_variable_set(:@no_crit, true)
      return skill
    end

    #--------------------------------------------------------------------------
    # Background Job 1：正式資料契約（不鎖名稱，避免 DB 顯示名與 MasterSetup 文案差異）
    #--------------------------------------------------------------------------
    def p46d_bg_contract
      mia = p46d_detached_actor(2)
      vina = p46d_detached_actor(4)
      tyler = p46d_detached_actor(6)
      identity = mia != nil && vina != nil && tyler != nil &&
                 mia.respond_to?(:albert_cc_mia?) && mia.albert_cc_mia? &&
                 vina.respond_to?(:albert_cc_vina?) && vina.albert_cc_vina? &&
                 tyler.respond_to?(:albert_cc_tyler?) && tyler.albert_cc_tyler?
      assert("Phase46D Main Character Actor2/4/6 formal role identity", identity,
             "mia=#{mia == nil ? nil : mia.id} vina=#{vina == nil ? nil : vina.id} tyler=#{tyler == nil ? nil : tyler.id}")

      ids = (110..119).to_a + (130..139).to_a + (150..159).to_a
      missing = ids.select { |id| p46d_skill(id) == nil }
      assert("Phase46D Mia/Vina/Tyler formal Skill ID blocks exist", missing.empty?, "missing=#{missing.inspect}")

      mia_contract = p46d_note_has?(110, /<heal_bonus\s*:\s*10\s*>/i) &&
                     p46d_note_has?(111, /<overheal_to_user_state\s+41\s*:\s*10\s*>/i) &&
                     p46d_note_has?(113, /<overheal_to_shield\s+52\s*:\s*75\s*>/i) &&
                     p46d_note_has?(115, /<bonus_per_user_state_stack\s+41\s*:\s*15\s*>/i) &&
                     p46d_note_has?(117, /<consume_user_state\s+41\s*:\s*3\s*>/i) &&
                     p46d_note_has?(118, /<revive_od_upgrade\s+300\s*:\s*60\s*:\s*20\s*>/i) &&
                     p46d_note_has?(119, /<overheal_to_shield\s+52\s*:\s*60\s*>/i)
      assert("Phase46D Mia heal/overheal/shield/resource/revive formal contract", mia_contract)

      vina_contract = p46d_note_has?(130, /<state_chance\s+31\s*:\s*70\s*>/i) &&
                      p46d_note_has?(131, /<state_stack_if_present\s+31\s*:\s*2\s*>/i) &&
                      p46d_note_has?(133, /<spread_state\s+31\s*:\s*2\s*:\s*100\s*>/i) &&
                      p46d_note_has?(134, /<drift_state\s+31\s*:\s*1\s*>/i) &&
                      p46d_note_has?(135, /<convert_state\s+31\s*:\s*37\s*>/i) &&
                      p46d_note_has?(135, /<convert_preserve_state_od\s+31\s*:\s*37\s*:\s*1\s*:\s*150\s*>/i) &&
                      p46d_note_has?(137, /<bonus_per_target_state\s*:\s*12\s*>/i) &&
                      p46d_note_has?(138, /<detonate_state_spi\s+31\s*:\s*90\s*>/i) &&
                      p46d_note_has?(138, /<consume_state\s+31\s*>/i)
      assert("Phase46D Vina stack/spread/drift/convert/detonate formal contract", vina_contract)

      tyler_contract = p46d_note_has?(150, /<break_power\s*:\s*1\s*>/i) &&
                       p46d_note_has?(150, /<break_threshold\s*:\s*5\s*>/i) &&
                       p46d_note_has?(153, /<bonus_vs_state\s+50\s*:\s*35\s*>/i) &&
                       p46d_note_has?(153, /<tyler_break_lock_od\s+100\s*:\s*15\s*>/i) &&
                       p46d_note_has?(155, /<break_bonus_od_tier\s+50\s*:\s*1\s*:\s*150\s*>/i) &&
                       p46d_note_has?(157, /<bonus_vs_state\s+51\s*:\s*80\s*>/i) &&
                       p46d_note_has?(158, /<consume_broken\s*>/i) &&
                       p46d_note_has?(159, /<break_power\s*:\s*2\s*>/i)
      assert("Phase46D Tyler Break/lock/Broken/finisher formal contract", tyler_contract)
      return identity && missing.empty? && mia_contract && vina_contract && tyler_contract
    rescue Exception => e
      exception(e, "p46d_bg_contract")
      assert("Phase46D Main Character formal contract background job", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Background Job 2：Mia 有效治療／溢療／State41／Mana Shield + OD
    #--------------------------------------------------------------------------
    def p46d_bg_mia_healing
      before_globals = p46a_registry_signature
      mia = p46d_detached_actor(2)
      target = p46d_detached_actor(1)
      ready = mia != nil && target != nil && $data_states[41] != nil && $data_states[52] != nil
      assert("Phase46D Mia detached healing fixture ready", ready)
      return false unless ready
      skill = p46d_local_skill("<overheal_to_user_state 41:10>\n<overheal_to_shield 52:50>", -300)
      target.clear_states if target.respond_to?(:clear_states)
      mia.clear_states if mia.respond_to?(:clear_states)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = 1000
      target.instance_variable_set(:@hp_damage, -300)
      target.instance_variable_set(:@missed, false)
      target.instance_variable_set(:@evaded, false)
      target.instance_variable_set(:@skipped, false)
      p46d_reset_action_od(mia, 0)
      target.albert_cc_process_healing(mia, skill, 800)
      ledger = mia.instance_variable_get(:@albert_special_od_action_gain)
      ledger = {} unless ledger.is_a?(Hash)
      special_gain = ledger[:mia_heal].to_i
      od_ok = special_gain == 110 && mia.overdrive.to_i >= special_gain
      stack_ok = p46d_stack_count(mia, 41) == 1
      shield = target.respond_to?(:albert_mana_shield_remaining) ? target.albert_mana_shield_remaining(52).to_i : 0
      shield_ok = target.state?(52) && shield == 50
      assert("Phase46D2 Mia formal Profile heal4/overheal3 records exact special OD ledger110", od_ok,
             "special=#{special_gain} total_od=#{mia.overdrive} ledger=#{ledger.inspect}")
      assert("Phase46D Mia overheal10% creates exactly one State41 resource layer", stack_ok,
             "stack41=#{p46d_stack_count(mia, 41)}")
      assert("Phase46D Mia overheal100 converts 50% into Mana Shield capacity50", shield_ok,
             "state52=#{target.state?(52)} shield=#{shield}")
      clean = p46a_registry_signature == before_globals
      assert("Phase46D Mia detached healing job leaves global registries unchanged", clean)
      return od_ok && stack_ok && shield_ok && clean
    rescue Exception => e
      exception(e, "p46d_bg_mia_healing")
      assert("Phase46D Mia detached healing background job", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Background Job 3：Mia Revive OD upgrade + resource-stack damage projection
    #--------------------------------------------------------------------------
    def p46d_bg_mia_revive_resource
      before_globals = p46a_registry_signature
      mia = p46d_detached_actor(2)
      target = p46d_detached_actor(1)
      ready = mia != nil && target != nil && $data_states[41] != nil && $data_states[52] != nil
      assert("Phase46D Mia detached revive/resource fixture ready", ready)
      return false unless ready
      target.clear_states if target.respond_to?(:clear_states)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = 100
      target.instance_variable_set(:@missed, false)
      target.instance_variable_set(:@evaded, false)
      target.instance_variable_set(:@skipped, false)
      revive = p46d_local_skill("<revive_od_upgrade 300:60:20>", -300)
      p46d_reset_action_od(mia, 500)
      target.albert_cc_v13_process_mia_revive(mia, revive, true)
      shield = target.respond_to?(:albert_mana_shield_remaining) ? target.albert_mana_shield_remaining(52).to_i : 0
      revive_ok = target.hp.to_i == 600 && target.state?(52) && shield == 200 && mia.overdrive.to_i == 200
      assert("Phase46D Mia revive OD300 upgrades target to 60% HP + 20% shield and pays once", revive_ok,
             "hp=#{target.hp} shield=#{shield} od=#{mia.overdrive}")

      mia.clear_states if mia.respond_to?(:clear_states)
      3.times { mia.add_state(41) }
      dmg_skill = p46d_local_skill("<bonus_per_user_state_stack 41:20>", 10)
      bonus = target.albert_combo_damage_bonus_percent(mia, dmg_skill).to_f
      resource_ok = p46d_stack_count(mia, 41) == 3 && bonus >= 60.0
      assert("Phase46D Mia State41 x3 contributes at least +60% damage bonus before consume", resource_ok,
             "stack=#{p46d_stack_count(mia, 41)} bonus=#{bonus}")
      clean = p46a_registry_signature == before_globals
      assert("Phase46D Mia revive/resource job leaves global registries unchanged", clean)
      return revive_ok && resource_ok && clean
    rescue Exception => e
      exception(e, "p46d_bg_mia_revive_resource")
      assert("Phase46D Mia revive/resource background job", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Background Job 4：Vina existing-state extra stack + exact OD economy
    #--------------------------------------------------------------------------
    def p46d_bg_vina_stack
      before_globals = p46a_registry_signature
      vina = p46d_detached_actor(4)
      target = p46d_detached_actor(1)
      ready = vina != nil && target != nil && $data_states[31] != nil
      assert("Phase46D Vina detached stack/OD fixture ready", ready)
      return false unless ready
      skill = p46d_local_skill("<state_chance 31:100>\n<state_stack_if_present 31:2>", 0)
      target.clear_states if target.respond_to?(:clear_states)
      target.add_state(31)
      p46d_reset_action_od(vina, 0)
      p37_with_combat_rng("phase46d1_bg_vina_stack") { target.skill_effect(vina, skill) }
      stack = p46d_stack_count(target, 31)
      ledger = vina.instance_variable_get(:@albert_special_od_action_gain)
      ledger = {} unless ledger.is_a?(Hash)
      special_gain = ledger[:vina_state].to_i
      ok = stack == 3 && special_gain == 100 && vina.overdrive.to_i >= special_gain
      assert("Phase46D2 Vina formal Profile state-stack50 gains +2 layers and special OD ledger100", ok,
             "stack31=#{stack} special=#{special_gain} total_od=#{vina.overdrive} ledger=#{ledger.inspect}")
      clean = p46a_registry_signature == before_globals
      assert("Phase46D Vina detached stack job leaves global registries unchanged", clean)
      return ok && clean
    rescue Exception => e
      exception(e, "p46d_bg_vina_stack")
      assert("Phase46D Vina stack background job", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Background Job 5：Tyler Break threshold / Broken / OD economy
    #--------------------------------------------------------------------------
    def p46d_bg_tyler_break
      before_globals = p46a_registry_signature
      tyler = p46d_detached_actor(6)
      target = p46d_detached_actor(1)
      ready = tyler != nil && target != nil && $data_states[50] != nil && $data_states[51] != nil
      assert("Phase46D Tyler detached Break fixture ready", ready)
      return false unless ready
      skill = p46d_local_skill("<break_power:2>\n<break_state:50>\n<broken_state:51>\n<break_threshold:5>", 1)
      target.clear_states if target.respond_to?(:clear_states)
      target.instance_variable_set(:@missed, false)
      target.instance_variable_set(:@evaded, false)
      target.instance_variable_set(:@skipped, false)
      target.albert_cc_add_break_points(50, 4)
      p46d_reset_action_od(tyler, 0)
      target.albert_cc_process_break(tyler, skill)
      points = target.albert_cc_break_points(50).to_i
      ledger = tyler.instance_variable_get(:@albert_special_od_action_gain)
      ledger = {} unless ledger.is_a?(Hash)
      special_gain = ledger[:tyler_break].to_i
      ok = target.state?(51) && points == 0 && special_gain == 220 && tyler.overdrive.to_i >= special_gain
      assert("Phase46D2 Tyler formal Profile break-point35/break150 -> Broken51, clears progress, special OD ledger220", ok,
             "broken=#{target.state?(51)} points=#{points} special=#{special_gain} total_od=#{tyler.overdrive} ledger=#{ledger.inspect}")
      clean = p46a_registry_signature == before_globals
      assert("Phase46D Tyler detached Break job leaves global registries unchanged", clean)
      return ok && clean
    rescue Exception => e
      exception(e, "p46d_bg_tyler_break")
      assert("Phase46D Tyler Break background job", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Background Tail 1：Mia 正式 support target pool
    #   Skill110 scope7 = 單體友方；114 scope8 = 全體友方；118 scope9 = 倒地友方。
    #   使用正式 AutoBattleAI target-pool helper 驗證 scope 解析，不要求 Mia 處於 battle members。
    #--------------------------------------------------------------------------
    def p46e_bg_mia_targeting_tail
      before_globals = p46a_registry_signature
      mia = p46d_detached_actor(2)
      s110 = p46d_skill(110)
      s114 = p46d_skill(114)
      s118 = p46d_skill(118)
      ready = mia != nil && s110 != nil && s114 != nil && s118 != nil &&
              mia.respond_to?(:albert_ai_targets_for_skill)
      assert("Phase46E Mia targeting formal Skill/helper fixture ready", ready,
             "mia=#{mia == nil ? nil : mia.id} s110=#{s110 == nil ? nil : s110.scope} s114=#{s114 == nil ? nil : s114.scope} s118=#{s118 == nil ? nil : s118.scope}")
      return false unless ready

      scope_ok = s110.scope.to_i == 7 && s110.for_friend? && !s110.for_all? &&
                 s114.scope.to_i == 8 && s114.for_friend? && s114.for_all? &&
                 s118.scope.to_i == 9 && s118.for_dead_friend?
      assert("Phase46E Mia Skill110/114/118 formal single/all/dead-friend scopes exact", scope_ok,
             "scopes=#{[s110.scope,s114.scope,s118.scope].inspect}")

      alive_expected = $game_party.existing_members.collect { |a| a.id }
      one_targets = mia.albert_ai_targets_for_skill(s110).collect { |a| a.id }
      all_targets = mia.albert_ai_targets_for_skill(s114).collect { |a| a.id }
      alive_ok = one_targets == alive_expected && all_targets == alive_expected
      assert("Phase46E Mia live support target pool follows current alive Party for single/all heal", alive_ok,
             "expected=#{alive_expected.inspect} single=#{one_targets.inspect} all=#{all_targets.inspect}")

      victim = $game_party.existing_members[0] rescue nil
      dead_ok = false
      if victim != nil
        snap = p46c_full_ivar_snapshot(victim)
        begin
          victim.hp = 0
          expected_dead = $game_party.dead_members.collect { |a| a.id }
          dead_targets = mia.albert_ai_targets_for_skill(s118).collect { |a| a.id }
          dead_ok = expected_dead.include?(victim.id) && dead_targets == expected_dead &&
                    !dead_targets.include?(mia.id)
          assert("Phase46E Mia revive target pool selects dead Party members only", dead_ok,
                 "victim=#{victim.id} expected=#{expected_dead.inspect} targets=#{dead_targets.inspect}")
        ensure
          p46c_restore_full_ivar_snapshot(victim, snap)
        end
      else
        assert("Phase46E Mia revive target pool selects dead Party members only", false, "no alive victim")
      end

      clean = p46a_registry_signature == before_globals
      assert("Phase46E Mia targeting background fixture restores Party/Actors exact", clean)
      return scope_ok && alive_ok && dead_ok && clean
    rescue Exception => e
      exception(e, "p46e_bg_mia_targeting_tail")
      assert("Phase46E Mia targeting background tail", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Background Tail 2：Vina Skill138 detonate contract + provider presence
    #--------------------------------------------------------------------------
    def p46e_bg_vina_detonate_contract
      s138 = p46d_skill(138)
      ready = s138 != nil && defined?(ALBERT_MECHANIC_EXPANSION) != nil
      assert("Phase46E Vina Skill138 detonate contract fixture ready", ready)
      return false unless ready
      note = s138.note.to_s
      contract = s138.scope.to_i == 1 &&
                 !!(note =~ /<detonate_state_spi\s+31\s*:\s*90\s*>/i) &&
                 !!(note =~ /<detonate_state_percent\s+31\s*:\s*0\.8\s*>/i) &&
                 !!(note =~ /<detonate_cap\s*:\s*6000\s*>/i) &&
                 !!(note =~ /<detonate_od_bonus\s*:\s*20\s*>/i) &&
                 !!(note =~ /<detonate_preserve_state\s+31\s*:\s*1\s*>/i) &&
                 !!(note =~ /<consume_state\s+31\s*>/i)
      provider = Game_Enemy.method_defined?(:albert_mx_state_resist_rate) &&
                 Game_Enemy.method_defined?(:albert_mx_recover_state_resist_after_action) &&
                 Game_Enemy.method_defined?(:albert_mx_add_state_resist_level)
      assert("Phase46E Vina Skill138 formal detonate SPI/percent/cap/OD/preserve contract exact", contract,
             note)
      assert("Phase46E Boss dynamic State resistance providers loaded for Vina tail", provider)
      return contract && provider
    rescue Exception => e
      exception(e, "p46e_bg_vina_detonate_contract")
      assert("Phase46E Vina detonate contract background tail", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Background Tail 3：Tyler enemy Break resistance + natural recovery
    #   TEST-only 暫時替換一個 Enemy DB slot 的 Note，finally 還原原物件。
    #--------------------------------------------------------------------------
    def p46e_bg_tyler_break_resist_tail
      before_globals = p46a_registry_signature
      tyler = p46d_detached_actor(6)
      source = ($game_troop.existing_members[0] rescue nil)
      ready = tyler != nil && source != nil && source.respond_to?(:enemy_id) &&
              $data_enemies[source.enemy_id] != nil && $data_states[50] != nil && $data_states[51] != nil
      assert("Phase46E Tyler Break resistance background fixture ready", ready,
             "tyler=#{tyler == nil ? nil : tyler.id} enemy=#{source == nil ? nil : source.enemy_id}")
      return false unless ready

      enemy_id = source.enemy_id
      original = $data_enemies[enemy_id]
      original_bytes = Marshal.dump(original)
      clone = original.clone
      clone.note = "<break_resist:50>\n<break_recover:1>\n<break_recover_state:50>"
      $data_enemies[enemy_id] = clone
      target = Game_Enemy.new(0, enemy_id)
      skill = p46d_local_skill("<break_power:4>\n<break_state:50>\n<broken_state:51>\n<break_threshold:5>", 1)
      data_ok = false
      break_ok = false
      recover_ok = false
      begin
        data = target.albert_cc_break_data(tyler, skill)
        data_ok = data != nil && data[0].to_i == 2 && data[3].to_i == 5
        assert("Phase46E Tyler enemy break_resist50 converts power4 -> power2", data_ok,
               "data=#{data.inspect}")

        target.clear_states if target.respond_to?(:clear_states)
        target.albert_cc_add_break_points(50, 3)
        p46d_reset_action_od(tyler, 0)
        target.instance_variable_set(:@missed, false)
        target.instance_variable_set(:@evaded, false)
        target.instance_variable_set(:@skipped, false)
        target.albert_cc_process_break(tyler, skill)
        break_ok = target.state?(51) && target.albert_cc_break_points(50).to_i == 0
        assert("Phase46E Tyler resisted Break still crosses 3/5 +2 -> Broken51 exactly", break_ok,
               "broken=#{target.state?(51)} points=#{target.albert_cc_break_points(50)}")

        target.clear_states if target.respond_to?(:clear_states)
        target.albert_cc_add_break_points(50, 3)
        recovered = target.albert_mx_recover_break_after_action
        recover_ok = recovered.to_i == 1 && target.albert_cc_break_points(50).to_i == 2
        assert("Phase46E enemy natural Break recovery removes exactly one progress layer", recover_ok,
               "recovered=#{recovered} points=#{target.albert_cc_break_points(50)}")
      ensure
        $data_enemies[enemy_id] = original
      end
      db_ok = $data_enemies[enemy_id].equal?(original) && Marshal.dump($data_enemies[enemy_id]) == original_bytes
      globals = p46a_registry_signature == before_globals
      assert("Phase46E Tyler Break-resist TEST Enemy database slot restored exact", db_ok,
             "enemy_id=#{enemy_id}")
      assert("Phase46E Tyler Break resistance background fixture leaves registries exact", globals)
      return data_ok && break_ok && recover_ok && db_ok && globals
    rescue Exception => e
      begin
        $data_enemies[enemy_id] = original if enemy_id != nil && original != nil
      rescue
      end
      exception(e, "p46e_bg_tyler_break_resist_tail")
      assert("Phase46E Tyler Break resistance background tail", false, e.message)
      return false
    end

    def p46d_background_job_names
      return [:contract, :mia_heal, :mia_revive_resource, :vina_stack, :tyler_break,
              :mia_targeting_tail, :vina_detonate_contract, :tyler_break_resist_tail]
    end

    def p46d_run_background_job(name)
      case name
      when :contract
        return p46d_bg_contract
      when :mia_heal
        return p46d_bg_mia_healing
      when :mia_revive_resource
        return p46d_bg_mia_revive_resource
      when :vina_stack
        return p46d_bg_vina_stack
      when :tyler_break
        return p46d_bg_tyler_break
      when :mia_targeting_tail
        return p46e_bg_mia_targeting_tail
      when :vina_detonate_contract
        return p46e_bg_vina_detonate_contract
      when :tyler_break_resist_tail
        return p46e_bg_tyler_break_resist_tail
      end
      return false
    end

    def p46d_background_tick
      return true if @p46d_bg_done
      jobs = @p46d_bg_jobs
      return false unless jobs.is_a?(Array)
      per = P46D_BACKGROUND_JOBS_PER_FRAME.to_i
      per = 1 if per <= 0
      count = 0
      while count < per && @p46d_bg_index.to_i < jobs.size
        index = @p46d_bg_index.to_i
        name = jobs[index]
        log("[BACKGROUND] START index=#{index + 1}/#{jobs.size} job=#{name} frame=#{Graphics.frame_count}")
        before = @fail_count.to_i
        ok = p46d_run_background_job(name)
        delta = @fail_count.to_i - before
        @p46d_bg_results[name] = (ok == true && delta == 0)
        log("[BACKGROUND] END job=#{name} ok=#{@p46d_bg_results[name]} fail_delta=#{delta} frame=#{Graphics.frame_count}")
        @p46d_bg_index = index + 1
        count += 1
      end
      if @p46d_bg_index.to_i >= jobs.size
        @p46d_bg_done = true
        all = jobs.all? { |name| @p46d_bg_results[name] == true }
        @p46d_background_ready = all
        log("[BACKGROUND_BATCH] jobs=#{jobs.size} results=#{@p46d_bg_results.inspect} ready=#{all}")
      end
      return @p46d_bg_done == true
    rescue Exception => e
      exception(e, "p46d_background_tick")
      @p46d_bg_done = true
      @p46d_background_ready = false
      return false
    end

    unless method_defined?(:fs_phase46d_prepare_battle_fixture_on_map_base)
      alias fs_phase46d_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      base = fs_phase46d_prepare_battle_fixture_on_map_base
      return false unless base == true
      @p46d_bg_jobs = p46d_background_job_names
      @p46d_bg_index = 0
      @p46d_bg_results = {}
      @p46d_bg_done = false
      @p46d_background_ready = false
      @p46d_bg_fail_before = @fail_count.to_i
      @p46d_bg_gate_asserted = false
      @p46d_chain_stage = 1
      @p46d_chain_pending = false
      @p46d_chain_launch_pending = false
      @p46d_live_batch_ready = false
      assert("Phase46E frame-sliced background queue created", @p46d_bg_jobs.size == 8,
             "jobs=#{@p46d_bg_jobs.inspect}")
      log("[BACKGROUND] queue_created jobs=#{@p46d_bg_jobs.inspect} per_frame=#{P46D_BACKGROUND_JOBS_PER_FRAME}")
      return true
    end

    unless method_defined?(:fs_phase46d_prebattle_wait_frames_base)
      alias fs_phase46d_prebattle_wait_frames_base prebattle_wait_frames
    end
    def prebattle_wait_frames
      base = fs_phase46d_prebattle_wait_frames_base.to_i
      return [base, P46D_BACKGROUND_MIN_WAIT.to_i].max
    end

    unless method_defined?(:fs_phase46d_update_prebattle_transition_base)
      alias fs_phase46d_update_prebattle_transition_base update_prebattle_transition
    end
    def update_prebattle_transition(scene)
      if @battle_transition_pending && !@p46d_bg_done
        p46d_background_tick
      end
      if @p46d_bg_done && !@p46d_bg_gate_asserted
        @p46d_bg_gate_asserted = true
        ready = @p46d_background_ready == true
        assert("Phase46E background semantic batch completed before Scene_Battle transition", ready,
               "results=#{@p46d_bg_results.inspect} external_fail_delta=#{@fail_count.to_i - @p46d_bg_fail_before.to_i}")
        unless ready
          log("[BACKGROUND_GATE] semantic_red_continue=true results=#{@p46d_bg_results.inspect} fail_delta=#{@fail_count.to_i - @p46d_bg_fail_before.to_i}")
        end
      end
      return fs_phase46d_update_prebattle_transition_base(scene)
    end

    #--------------------------------------------------------------------------
    # 第二場 Live Semantic Sandbox
    #--------------------------------------------------------------------------
    def p46d_disable_first_battle_fixture_observers
      @p46d_saved_p39_ready = nil
      data39 = @p39_combo_fixture
      if data39.is_a?(Hash)
        @p46d_saved_p39_ready = data39[:ready]
        data39[:ready] = false
      end
      @p46d_saved_p40_summon = @p40_summon_lifecycle
      @p46d_saved_p40_enemy = @p40b_enemy_fixture
      @p40_summon_lifecycle = nil
      @p40b_enemy_fixture = nil
      @p40b_enemy_gate_active = false
      @p39_combo_gate_active = false
      log("[MULTI_BATTLE] old fixture observers suspended for battle2")
    end

    def p46d_restore_first_battle_fixture_observers
      data39 = @p39_combo_fixture
      if data39.is_a?(Hash) && @p46d_saved_p39_ready != nil
        data39[:ready] = @p46d_saved_p39_ready
      end
      @p40_summon_lifecycle = @p46d_saved_p40_summon
      @p40b_enemy_fixture = @p46d_saved_p40_enemy
      @p46d_saved_p39_ready = nil
      @p46d_saved_p40_summon = nil
      @p46d_saved_p40_enemy = nil
      log("[MULTI_BATTLE] old fixture observers restored before final snapshot")
    end

    def p46d_reset_battle_driver_transients
      @battle_frame = 0
      @battle_result = nil
      @battle_fixture_queued = false
      @battle_action_executed = false
      @battle_action_complete_frame = nil
      @battle_forced_subject_object_id = nil
      @battle_forced_target_object_id = nil
      @battle_damage_seen = false
      @battle_combat_rng_count = 0
      @battle_combat_rng_trace = []
      @battle_exit_requested_by_harness = false
      @battle_exit_in_progress = false
      @core_fixture_plan = nil
      @core_fixture_index = 0
      @core_current_fixture = nil
      @core_next_queue_frame = nil
    end

    def p46d_launch_second_battle
      troop_id = respond_to?(:core_first_valid_troop_id) ? core_first_valid_troop_id(3) : first_valid_troop_id
      assert("Phase46D multi-battle second Troop resolved", troop_id != nil, "troop=#{troop_id}")
      return false if troop_id == nil
      $game_troop.setup(troop_id)
      $game_troop.can_escape = true
      $game_troop.can_lose = true
      p46d_reset_battle_driver_transients
      @battle_active = true
      @p46d_chain_stage = 2
      @p46d_chain_launch_pending = false
      $game_temp.battle_proc = Proc.new { |result| FS_TEST_HARNESS.on_battle_result(result) }
      $game_temp.next_scene = "battle"
      log("[MULTI_BATTLE] launch battle=2 troop=#{troop_id} enemies=#{$game_troop.members.collect { |e| e.enemy_id rescue 0 }.inspect}")
      return true
    rescue Exception => e
      exception(e, "p46d_launch_second_battle")
      @pending_restore = true
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46D3 TEST-only：direct skill_effect 在 Scene_Battle sandbox 中必須補齊
    # 正式 action 原本會提供的 active_battler context。Counterattack Runtime
    # 會讀 $scene.active_battler.actor?；detached fixture 若不暫設 user 會得到 nil。
    # ensure 中 exact restore，Formal Runtime 不修改。
    #--------------------------------------------------------------------------
    def p46d_with_active_battler(user)
      scene = $scene rescue nil
      can_set = scene != nil && scene.respond_to?(:active_battler) &&
                scene.respond_to?(:active_battler=)
      old_active = can_set ? scene.active_battler : nil
      scene.active_battler = user if can_set
      result = yield
      result
    ensure
      scene.active_battler = old_active if can_set
    end

    def p46d_live_mia_fixture
      mia = p46d_detached_actor(2)
      target = p46d_detached_actor(1)
      ready = mia != nil && target != nil && $scene.is_a?(Scene_Battle)
      assert("Phase46D battle2 Mia live skill_effect fixture ready", ready)
      return false unless ready
      target.clear_states if target.respond_to?(:clear_states)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = 950
      p46d_reset_action_od(mia, 0)
      skill = p46d_local_skill("<cc_od_heal_percent:0>\n<cc_od_overheal_percent:0>\n<overheal_to_shield 52:50>", -200)
      p46d_with_active_battler(mia) do
        p37_with_combat_rng("phase46d_battle2_mia_heal") { target.skill_effect(mia, skill) }
      end
      shield = target.respond_to?(:albert_mana_shield_remaining) ? target.albert_mana_shield_remaining(52).to_i : 0
      ok = target.hp.to_i == 1000 && target.state?(52) && shield == 75
      assert("Phase46D battle2 Mia full skill_effect overheal150 -> live Mana Shield75", ok,
             "hp=#{target.hp} shield=#{shield}")
      return ok
    rescue Exception => e
      exception(e, "p46d_live_mia_fixture")
      assert("Phase46D battle2 Mia live semantic", false, e.message)
      return false
    end

    def p46d_live_vina_fixture
      vina = p46d_detached_actor(4)
      target = ($game_troop.existing_members[0] rescue nil)
      ready = vina != nil && target != nil && $data_states[31] != nil && $data_states[37] != nil
      assert("Phase46D battle2 Vina live convert fixture ready", ready)
      return false unless ready
      snap = p46c_full_ivar_snapshot(target)
      begin
        target.clear_states if target.respond_to?(:clear_states)
        target.add_state(31)
        target.add_state(31)
        p46d_reset_action_od(vina, 200)
        skill = p46d_local_skill("<convert_state 31:37>\n<convert_preserve_state_od 31:37:1:150>", 1)
        p46d_with_active_battler(vina) do
          p37_with_combat_rng("phase46d_battle2_vina_convert") { target.skill_effect(vina, skill) }
        end
        source_stack = p46d_stack_count(target, 31)
        target_stack = p46d_stack_count(target, 37)
        ledger = vina.instance_variable_get(:@albert_special_od_action_gain)
        ledger = {} unless ledger.is_a?(Hash)
        special_gain = ledger[:vina_state].to_i
        kgc_attack_gain = 0
        if defined?(KGC::OverDrive::GAIN_RATE) && defined?(KGC::OverDrive::Type::ATTACK)
          kgc_attack_gain = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ATTACK].to_i
        end
        expected_od = 200 + special_gain + kgc_attack_gain - 150
        ok = target.state?(37) && target_stack >= 2 && target.state?(31) && source_stack == 1 &&
             special_gain == 100 && kgc_attack_gain == 10 && vina.overdrive.to_i == expected_od
        assert("Phase46D4 battle2 Vina convert preserves poison, gains formal State OD + KGC attack OD, then pays OD150", ok,
               "s31=#{source_stack} s37=#{target_stack} special=#{special_gain} kgc_attack=#{kgc_attack_gain} expected_od=#{expected_od} actual_od=#{vina.overdrive} ledger=#{ledger.inspect}")
        return ok
      ensure
        p46c_restore_full_ivar_snapshot(target, snap)
      end
    rescue Exception => e
      exception(e, "p46d_live_vina_fixture")
      assert("Phase46D battle2 Vina live semantic", false, e.message)
      return false
    end

    def p46d_live_tyler_fixture
      tyler = p46d_detached_actor(6)
      target = p46d_detached_actor(1)
      ready = tyler != nil && target != nil && $data_states[51] != nil
      assert("Phase46D battle2 Tyler live finisher fixture ready", ready)
      return false unless ready
      target.clear_states if target.respond_to?(:clear_states)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = 1000
      target.add_state(51)
      skill = p46d_local_skill("<bonus_vs_state 51:120>\n<consume_broken>", 10)
      p46d_with_active_battler(tyler) do
        p37_with_combat_rng("phase46d_battle2_tyler_finisher") { target.skill_effect(tyler, skill) }
      end
      ok = target.hp_damage.to_i > 10 && !target.state?(51)
      assert("Phase46D battle2 Tyler full skill_effect gains Broken bonus then consumes Broken51", ok,
             "damage=#{target.hp_damage} broken_after=#{target.state?(51)}")
      return ok
    rescue Exception => e
      exception(e, "p46d_live_tyler_fixture")
      assert("Phase46D battle2 Tyler live semantic", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Battle2 Tail 1：Mia Skill117 success-gated State41 consume
    #   直接驗正式 Scene_Battle wrapper 的「成功後消耗」責任，不偽造 learn_skill。
    #--------------------------------------------------------------------------
    def p46e_live_mia_support_consume_tail
      battle = $scene rescue nil
      mia = p46d_detached_actor(2)
      skill = p46d_skill(117)
      ready = battle != nil && battle.is_a?(Scene_Battle) && mia != nil && skill != nil &&
              $data_states[41] != nil && battle.respond_to?(:albert_ant_old_execute_action_skill, true)
      assert("Phase46E Mia Skill117 Scene_Battle consume wrapper fixture ready", ready)
      return false unless ready

      scene_active = p46a_ivar_snapshot(battle, :@active_battler)
      mia_snap = p46c_full_ivar_snapshot(mia)
      scene_sc = class << battle; self; end
      ok = false
      begin
        mia.clear_states if mia.respond_to?(:clear_states)
        5.times { mia.add_state(41) }
        before = p46d_stack_count(mia, 41)
        mia.action.clear
        mia.action.set_skill(skill.id)
        battle.instance_variable_set(:@active_battler, mia)
        scene_sc.send(:define_method, :albert_mx_old_execute_action_skill) do |*args|
          b = @active_battler
          b.instance_variable_set(:@albert_mx_action_success, true) if b != nil
          nil
        end
        battle.send(:albert_ant_old_execute_action_skill)
        after = p46d_stack_count(mia, 41)
        ok = before == 5 && after == 2
        assert("Phase46E Mia Skill117 successful action consumes exactly 3 State41 layers", ok,
               "stack=#{before}->#{after}")
      ensure
        begin scene_sc.send(:remove_method, :albert_mx_old_execute_action_skill); rescue; end
        p46a_restore_ivar(battle, :@active_battler, scene_active)
        p46c_restore_full_ivar_snapshot(mia, mia_snap)
      end
      cleanup = p46a_ivar_snapshot(battle, :@active_battler) == scene_active
      assert("Phase46E Mia consume wrapper restores Scene active_battler exact", cleanup)
      return ok && cleanup
    rescue Exception => e
      exception(e, "p46e_live_mia_support_consume_tail")
      assert("Phase46E Mia support consume live tail", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Battle2 Tail 2：Vina detonate exact formula + dynamic State resistance
    #--------------------------------------------------------------------------
    def p46e_live_vina_detonate_resist_tail
      vina = p46d_detached_actor(4)
      target = p46d_detached_actor(1)
      enemy = ($game_troop.existing_members[0] rescue nil)
      ready = vina != nil && target != nil && enemy != nil && $data_states[31] != nil &&
              enemy.respond_to?(:enemy_id) && $data_enemies[enemy.enemy_id] != nil
      assert("Phase46E Vina detonate/dynamic-resist live fixture ready", ready)
      return false unless ready

      # A. Detonate exact formula and preserve-one behavior.
      target.clear_states if target.respond_to?(:clear_states)
      target.maxhp = 1000 if target.respond_to?(:maxhp=)
      target.hp = 1000
      3.times { target.add_state(31) }
      p46d_reset_action_od(vina, 0)
      skill = p46d_local_skill("<detonate_state_spi 31:90>\n<detonate_state_percent 31:0.8>\n<detonate_cap:6000>\n<detonate_od_bonus:20>\n<detonate_preserve_state 31:1>\n<consume_state 31>", 0)
      stacks = p46d_stack_count(target, 31)
      spi_part = (vina.spi.to_f * 90.0 / 100.0 * stacks).to_i
      hp_part = (target.maxhp.to_f * 0.8 / 100.0 * stacks).to_i
      expected = ((spi_part + hp_part).to_f * 1.20).to_i
      expected = [expected, 6000].min
      p46d_with_active_battler(vina) do
        p37_with_combat_rng("phase46e_battle2_vina_detonate") { target.skill_effect(vina, skill) }
      end
      detonate_ok = stacks == 3 && target.hp_damage.to_i == expected &&
                    p46d_stack_count(target, 31) == 1
      assert("Phase46E Vina detonate exact SPI+0.8%MaxHP per stack, +20% OD bonus, preserve1", detonate_ok,
             "stacks=#{stacks} spi_part=#{spi_part} hp_part=#{hp_part} expected=#{expected} damage=#{target.hp_damage} final_stack=#{p46d_stack_count(target,31)}")

      # B. Boss dynamic resistance: successful state -> level+1 / 75% rate -> recover one level.
      enemy_snap = p46c_full_ivar_snapshot(enemy)
      enemy_id = enemy.enemy_id
      original = $data_enemies[enemy_id]
      original_bytes = Marshal.dump(original)
      clone = original.clone
      clone.note = "<state_dynamic_resist_states:31>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>"
      $data_enemies[enemy_id] = clone
      resist_ok = false
      recover_ok = false
      begin
        enemy.clear_states if enemy.respond_to?(:clear_states)
        enemy.instance_variable_set(:@albert_mx_state_resist_levels, {})
        base_prob = enemy.state_probability(31).to_i
        p46d_with_active_battler(vina) { enemy.add_state(31) }
        level1 = enemy.albert_mx_state_resist_level(31).to_i
        prob1 = enemy.state_probability(31).to_i
        expected_prob = (base_prob.to_f * 75.0 / 100.0).to_i
        resist_ok = enemy.state?(31) && level1 == 1 && prob1 == expected_prob
        assert("Phase46E Vina successful Boss State31 application raises dynamic resistance one level", resist_ok,
               "base=#{base_prob} level=#{level1} probability=#{prob1}/#{expected_prob}")
        recovered = enemy.albert_mx_recover_state_resist_after_action
        level0 = enemy.albert_mx_state_resist_level(31).to_i
        prob0 = enemy.state_probability(31).to_i
        recover_ok = recovered.to_i == 1 && level0 == 0 && prob0 == base_prob
        assert("Phase46E Boss dynamic State resistance recovers one level after effective action", recover_ok,
               "recovered=#{recovered} level=#{level0} probability=#{prob0}/#{base_prob}")
      ensure
        p46c_restore_full_ivar_snapshot(enemy, enemy_snap)
        $data_enemies[enemy_id] = original
      end
      db_ok = $data_enemies[enemy_id].equal?(original) && Marshal.dump($data_enemies[enemy_id]) == original_bytes
      assert("Phase46E Vina dynamic-resist TEST Enemy DB slot restored exact", db_ok,
             "enemy_id=#{enemy_id}")
      return detonate_ok && resist_ok && recover_ok && db_ok
    rescue Exception => e
      begin
        p46c_restore_full_ivar_snapshot(enemy, enemy_snap) if enemy != nil && enemy_snap != nil
        $data_enemies[enemy_id] = original if enemy_id != nil && original != nil
      rescue
      end
      exception(e, "p46e_live_vina_detonate_resist_tail")
      assert("Phase46E Vina detonate/dynamic resistance live tail", false, e.message)
      return false
    end

    #--------------------------------------------------------------------------
    # Phase46E Battle2 Tail 3：Tyler Break Lock OD / skip-once recovery lifecycle
    #--------------------------------------------------------------------------
    def p46e_live_tyler_break_lock_tail
      tyler = p46d_detached_actor(6)
      target = ($game_troop.existing_members[0] rescue nil)
      ready = tyler != nil && target != nil && target.respond_to?(:enemy_id) &&
              $data_enemies[target.enemy_id] != nil && $data_states[50] != nil
      assert("Phase46E Tyler Break Lock live fixture ready", ready)
      return false unless ready

      snap = p46c_full_ivar_snapshot(target)
      enemy_id = target.enemy_id
      original = $data_enemies[enemy_id]
      original_bytes = Marshal.dump(original)
      clone = original.clone
      clone.note = "<break_recover:1>\n<break_recover_state:50>"
      $data_enemies[enemy_id] = clone
      ok = false
      begin
        target.clear_states if target.respond_to?(:clear_states)
        target.albert_cc_add_break_points(50, 3)
        target.hp = target.maxhp
        p46d_reset_action_od(tyler, 150)
        skill = p46d_local_skill("<tyler_break_lock_od 100:15>", 10)
        bonus = target.albert_combo_damage_bonus_percent(tyler, skill).to_i
        p46d_with_active_battler(tyler) do
          p37_with_combat_rng("phase46e_battle2_tyler_break_lock") { target.skill_effect(tyler, skill) }
        end
        skip_armed = target.instance_variable_get(:@albert_mx_skip_break_recover_once) ? true : false
        after_skill_points = target.albert_cc_break_points(50).to_i
        first = target.albert_mx_recover_break_after_action
        after_first = target.albert_cc_break_points(50).to_i
        flag_after_first = target.instance_variable_get(:@albert_mx_skip_break_recover_once) ? true : false
        second = target.albert_mx_recover_break_after_action
        after_second = target.albert_cc_break_points(50).to_i
        kgc_attack = 0
        if defined?(KGC::OverDrive::GAIN_RATE) && defined?(KGC::OverDrive::Type::ATTACK)
          kgc_attack = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ATTACK].to_i
        end
        expected_od = 150 + kgc_attack - 100
        ok = bonus == 15 && target.hp_damage.to_i > 10 && skip_armed &&
             after_skill_points == 3 && first.to_i == 0 && after_first == 3 && !flag_after_first &&
             second.to_i == 1 && after_second == 2 && tyler.overdrive.to_i == expected_od
        assert("Phase46E Tyler Break Lock +15%, pays100 OD, skips one recovery then next recovery -1", ok,
               "bonus=#{bonus} damage=#{target.hp_damage} skip=#{skip_armed} points=#{after_skill_points}->#{after_first}->#{after_second} recover=#{first}/#{second} od=#{tyler.overdrive}/#{expected_od}")
      ensure
        p46c_restore_full_ivar_snapshot(target, snap)
        $data_enemies[enemy_id] = original
      end
      db_ok = $data_enemies[enemy_id].equal?(original) && Marshal.dump($data_enemies[enemy_id]) == original_bytes
      assert("Phase46E Tyler Break Lock TEST Enemy DB slot restored exact", db_ok,
             "enemy_id=#{enemy_id}")
      return ok && db_ok
    rescue Exception => e
      begin
        p46c_restore_full_ivar_snapshot(target, snap) if target != nil && snap != nil
        $data_enemies[enemy_id] = original if enemy_id != nil && original != nil
      rescue
      end
      exception(e, "p46e_live_tyler_break_lock_tail")
      assert("Phase46E Tyler Break Lock live tail", false, e.message)
      return false
    end

    def p46d_run_live_batch
      return @p46d_live_batch_ready if @p46d_live_batch_ran
      @p46d_live_batch_ran = true
      before_globals = p46a_registry_signature
      mia = p46d_live_mia_fixture
      vina = p46d_live_vina_fixture
      tyler = p46d_live_tyler_fixture
      mia_tail = p46e_live_mia_support_consume_tail
      vina_tail = p46e_live_vina_detonate_resist_tail
      tyler_tail = p46e_live_tyler_break_lock_tail
      globals = p46a_registry_signature == before_globals
      assert("Phase46E battle2 live batch restores touched global registry context", globals)
      prior_main = @p46c_suite_ready == true
      ready = @p46d_background_ready == true && prior_main && mia && vina && tyler &&
              mia_tail && vina_tail && tyler_tail && globals
      @p46d_live_batch_ready = ready
      log("[MAIN_CHARACTER_BATCH_III] background=#{@p46d_background_ready} prior_main=#{prior_main} mia_core=#{mia} vina_core=#{vina} tyler_core=#{tyler} mia_tail=#{mia_tail} vina_tail=#{vina_tail} tyler_tail=#{tyler_tail} multibattle=true ready=#{ready}")
      log("[CHARACTER_REGRESSION_MAP_VI] joey_ivy_aizhuo=#{prior_main} mia_targeting_support=#{mia_tail} vina_detonate_resistance=#{vina_tail} tyler_break_resist_lock=#{tyler_tail} pending=[] ready=#{ready}")
      log("[MAIN_CHARACTER_REGRESSION_COMPLETE] joey=true ivy=true aizhuo=true mia=#{mia && mia_tail} vina=#{vina && vina_tail} tyler=#{tyler && tyler_tail} ready=#{ready}")
      assert("Phase46E Main Character Tail Batch I completed", ready,
             "prior=#{prior_main} mia=#{mia}/#{mia_tail} vina=#{vina}/#{vina_tail} tyler=#{tyler}/#{tyler_tail} globals=#{globals}")
      return ready
    rescue Exception => e
      exception(e, "p46d_run_live_batch")
      @p46d_live_batch_ready = false
      assert("Phase46E Main Character Tail Batch I completed", false, e.message)
      return false
    end

    # 第一場照既有完整 Regression；第二場改走專用 live sandbox，不重跑 1221 baseline。
    unless method_defined?(:fs_phase46d_on_battle_scene_start_base)
      alias fs_phase46d_on_battle_scene_start_base on_battle_scene_start
    end
    def on_battle_scene_start(scene)
      if @p46d_chain_stage.to_i == 2
        log("[MULTI_BATTLE] Scene_Battle start battle=2")
        assert("Phase46D battle2 real Scene_Battle entered", scene.is_a?(Scene_Battle))
        assert("Phase46D battle2 has live Enemy troop", $game_troop.existing_members.size > 0,
               "enemies=#{$game_troop.existing_members.size}")
        return true
      end
      return fs_phase46d_on_battle_scene_start_base(scene)
    end

    unless method_defined?(:fs_phase46d_on_battle_scene_update_base)
      alias fs_phase46d_on_battle_scene_update_base on_battle_scene_update
    end
    def on_battle_scene_update(scene)
      if @p46d_chain_stage.to_i == 2
        @battle_frame = @battle_frame.to_i + 1
        if @battle_frame == 1
          log("[MULTI_BATTLE] battle2 update begin")
        end
        if @battle_frame == 2 && !@p46d_live_batch_ran
          p46d_run_live_batch
          request_battle_smoke_exit(scene, "phase46e_main_character_tail_batch_complete")
        elsif @battle_frame >= 120 && !@battle_exit_in_progress
          assert("Phase46D battle2 live batch timeout", false, "frame=#{@battle_frame}")
          request_battle_smoke_exit(scene, "phase46d_timeout")
        end
        return
      end
      fs_phase46d_on_battle_scene_update_base(scene)
    end

    unless method_defined?(:fs_phase46d_on_battle_result_base)
      alias fs_phase46d_on_battle_result_base on_battle_result
    end
    def on_battle_result(result)
      stage = @p46d_chain_stage.to_i
      value = fs_phase46d_on_battle_result_base(result)
      if stage == 1 && @p46d_bg_done == true
        @p46d_chain_pending = true
        log("[MULTI_BATTLE] battle1 result=#{result} captured; defer snapshot restore and schedule battle2 background_ready=#{@p46d_background_ready}")
      elsif stage == 2
        @p46d_restore_observers_after_battle2_terminate = true
        @p46d_chain_stage = 3
        log("[MULTI_BATTLE] battle2 result=#{result} captured; final snapshot restore armed after terminate")
      end
      return value
    end

    unless method_defined?(:fs_phase46d_restore_pending_base)
      alias fs_phase46d_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      if @pending_restore && @p46d_chain_stage.to_i == 3 && @p46d_restore_observers_after_battle2_terminate
        log("[MULTI_BATTLE] final snapshot restore waiting for battle2 terminate")
        return false
      end
      if @pending_restore && @p46d_chain_pending && @p46d_chain_stage.to_i == 1
        @pending_restore = false
        @battle_active = false
        @p46d_chain_pending = false
        @p46d_chain_launch_pending = true
        p46d_reset_battle_driver_transients
        p46d_disable_first_battle_fixture_observers
        log("[MULTI_BATTLE] snapshot restore deferred between battle1 -> battle2")
        return false
      end
      result = fs_phase46d_restore_pending_base
      if result
        @p46d_bg_jobs = nil
        @p46d_bg_index = 0
        @p46d_bg_results = nil
        @p46d_bg_done = false
        @p46d_background_ready = false
        @p46d_bg_gate_asserted = false
        @p46d_chain_stage = 0
        @p46d_chain_pending = false
        @p46d_chain_launch_pending = false
        @p46d_live_batch_ran = false
        @p46d_live_batch_ready = false
        @p46d_restore_observers_after_battle2_terminate = false
      end
      return result
    end

    def p46d_after_second_battle_terminate(scene)
      return false unless @p46d_chain_stage.to_i == 3
      return false unless @p46d_restore_observers_after_battle2_terminate
      p46d_restore_first_battle_fixture_observers
      @p46d_restore_observers_after_battle2_terminate = false
      log("[MULTI_BATTLE] battle2 terminate complete; old fixture observers restored")
      return true
    end

    def p46d_map_update_chain(scene)
      return false unless @p46d_chain_launch_pending
      return false unless scene.is_a?(Scene_Map)
      return p46d_launch_second_battle
    end
  end
end

if defined?(Scene_Battle)
class Scene_Battle < Scene_Base
  unless method_defined?(:fs_phase46d2_multibattle_terminate_base)
    alias fs_phase46d2_multibattle_terminate_base terminate
  end
  def terminate
    fs_phase46d2_multibattle_terminate_base
    FS_TEST_HARNESS.p46d_after_second_battle_terminate(self) if defined?(FS_TEST_HARNESS)
  end
end
end

if defined?(Scene_Map)
class Scene_Map < Scene_Base
  unless method_defined?(:fs_phase46d_multibattle_map_update_base)
    alias fs_phase46d_multibattle_map_update_base update
  end
  def update
    FS_TEST_HARNESS.p46d_map_update_chain(self) if defined?(FS_TEST_HARNESS)
    fs_phase46d_multibattle_map_update_base
  end
end
end
end


#==============================================================================
# 【Phase47A】Formal Boss Roster Enumeration / Regression Matrix I
# TEST-only v1.0a
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8 compatible.
# Formal Runtime：0 修改。本批只擴充 AutoRegression TEST evidence。
#
# 已由 2026-08-17 現行正式資料交叉枚舉：
# - FS_MasterSetup 11：500-511 / 520-524 / 530-531 / 540-550 為 30 名
#   Boss/Elite principal；551-565 為 15 名核心／模組／召喚 add。
# - 現行 Troops.rvdata 無 500-565 member；因此 Phase47 使用 TEST-only
#   live troop sandbox，不把「尚未配置 Troop」誤當作 Runtime 缺陷。
# - SetupRuntime_09 / MasterSetup15 的 START_SUMMONS / CORE_GROUPS /
#   PHASE_WEATHER 納入 contract regression。
#
# 本批 Live Boss Matrix I：
# 1. 524 賽勒斯：150 -> 151 -> 152 phase、law cycle cadence。
# 2. 520 / 547：HP threshold summon + core exposure lifecycle。
# 3. 530：start core x2、State77 shield、45% State128、core death State129。
# 4. 548 / 549 / 550：55% weather phase + field authority。
#
# Phase47A1：實機已證明正式 <law_cycle_interval:3> 曾被舊 parser 誤讀為 1；
# 本候選 Formal parser 已以 interval 為 Authority 並保留 actions alias，Live fixture 鎖定 3 次才換律。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  P47A_BACKGROUND_JOBS_PER_FRAME = 2 unless const_defined?("P47A_BACKGROUND_JOBS_PER_FRAME")

  class << self
    def p47a_principal_ids
      return (500..511).to_a + (520..524).to_a + [530,531] + (540..550).to_a
    end

    def p47a_add_ids
      return (551..565).to_a
    end

    def p47a_expected_names
      return {
        500=>"毒霧培養師", 501=>"棘甲守衛", 502=>"雷序追兵", 503=>"雙生療癒師",
        504=>"裂地拳士", 505=>"夢魘術士", 506=>"鋼翼哨兵", 507=>"腐蝕工兵",
        508=>"共鳴獵手", 509=>"時律審判官", 510=>"天候祭司", 511=>"失序指揮官",
        520=>"莉瑟・觀律者", 521=>"赫薩・雙弦", 522=>"諾維亞・改譜師",
        523=>"赫克托・召喚獵手", 524=>"賽勒斯・大諧律",
        530=>"城塞主機 BASTION-Ω", 531=>"諧律殲滅機 ORCHESTRA-0",
        540=>"妙蛙花・古樹主", 541=>"耿鬼・夢魘鐘", 542=>"班基拉斯・沙海暴君",
        543=>"巨金怪・磁星核心", 544=>"美納斯・鏡潮祭主", 545=>"暴飛龍・蒼翼災禍",
        546=>"夢幻・萬象原型", 547=>"超夢・基因王座", 548=>"固拉多・原始陸地",
        549=>"蓋歐卡・始源之海", 550=>"烈空座・德爾塔天穹"
      }
    end

    def p47a_note_number(text, tag)
      return nil if text == nil
      re = Regexp.new("<" + tag.to_s + "\\s*:\\s*(\\d+)\\s*>", Regexp::IGNORECASE)
      return nil unless text =~ re
      return $1.to_i
    rescue
      return nil
    end

    def p47a_state_dynamic_ids(text)
      return [] if text == nil
      return [] unless text =~ /<state_dynamic_resist_states\s*:\s*([0-9,\s]+)\s*>/i
      result = []
      $1.to_s.scan(/\d+/) { |value| result.push(value.to_i) }
      return result
    rescue
      return []
    end

    def p47a_bg_roster_contract
      principals = p47a_principal_ids
      adds = p47a_add_ids
      names = p47a_expected_names
      setup = defined?(FS_MASTER_SETUP::ENEMIES::DATA) ? FS_MASTER_SETUP::ENEMIES::DATA : nil
      keys = setup.is_a?(Hash) ? setup.keys.sort : []
      exact_keys = (principals + adds).sort
      boss_keys = keys.select { |enemy_id| exact_keys.include?(enemy_id) }
      key_ok = (boss_keys == exact_keys)
      runtime_ok = true
      for enemy_id in principals
        data = ($data_enemies[enemy_id] rescue nil)
        row = setup == nil ? nil : setup[enemy_id]
        expected_name = names[enemy_id]
        if data == nil || row == nil || data.name.to_s != expected_name.to_s ||
           row[:name].to_s != expected_name.to_s || data.note.to_s !~ /<fs_fixed_enemy_stats>/i
          runtime_ok = false
          break
        end
      end
      add_ok = true
      for enemy_id in adds
        data = ($data_enemies[enemy_id] rescue nil)
        row = setup == nil ? nil : setup[enemy_id]
        if data == nil || row == nil || data.name.to_s == ""
          add_ok = false
          break
        end
      end
      assert("Phase47A formal Boss principal roster is exact 30 + 15 adds", key_ok && runtime_ok && add_ok,
             "principals=#{principals.size} adds=#{adds.size} boss_keys=#{boss_keys.inspect}")
      log("[BOSS_ROSTER] principals=#{principals.inspect} adds=#{adds.inspect} ready=#{key_ok && runtime_ok && add_ok}")
      return key_ok && runtime_ok && add_ok
    rescue Exception => e
      exception(e, "p47a_bg_roster_contract")
      assert("Phase47A formal Boss principal roster is exact 30 + 15 adds", false, e.message)
      return false
    end

    def p47a_bg_troop_wiring_contract
      refs = {}
      principals = p47a_principal_ids
      adds = p47a_add_ids
      ids = principals + adds
      if $data_troops != nil
        $data_troops.each_with_index do |troop, troop_id|
          next if troop == nil || !troop.respond_to?(:members)
          for member in troop.members
            next if member == nil
            enemy_id = member.enemy_id.to_i
            next unless ids.include?(enemy_id)
            refs[enemy_id] = [] if refs[enemy_id] == nil
            refs[enemy_id].push(troop_id) unless refs[enemy_id].include?(troop_id)
          end
        end
      end
      current_empty = refs.empty?
      assert("Phase47A current Troop database Boss wiring baseline enumerated", $data_troops != nil,
             "boss_refs=#{refs.inspect}")
      log("[BOSS_TROOP_MAP] current_refs=#{refs.inspect} no_formal_boss_members=#{current_empty}")
      return $data_troops != nil
    rescue Exception => e
      exception(e, "p47a_bg_troop_wiring_contract")
      assert("Phase47A current Troop database Boss wiring baseline enumerated", false, e.message)
      return false
    end

    def p47a_bg_runtime_tables_contract
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) && defined?(FS_MASTER_SETUP::BOSS_RUNTIME))
      assert("Phase47A Boss Runtime table providers loaded", ready)
      return false unless ready
      runtime_start = FS_DB_AUTOSET_BOSS_RUNTIME::START_SUMMONS
      master_start = FS_MASTER_SETUP::BOSS_RUNTIME::START_SUMMONS
      runtime_core = FS_DB_AUTOSET_BOSS_RUNTIME::CORE_GROUPS
      master_core = FS_MASTER_SETUP::BOSS_RUNTIME::CORE_GROUPS
      runtime_weather = FS_DB_AUTOSET_BOSS_RUNTIME::PHASE_WEATHER
      master_weather = FS_MASTER_SETUP::BOSS_RUNTIME::PHASE_WEATHER
      exact = Marshal.dump(runtime_start) == Marshal.dump(master_start) &&
              Marshal.dump(runtime_core) == Marshal.dump(master_core) &&
              Marshal.dump(runtime_weather) == Marshal.dump(master_weather) &&
              runtime_weather == {548=>[122,125,153,156], 549=>[123,126,154,157], 550=>[124,127,155,158]} &&
              runtime_core[530] == [561] && runtime_core[531] == [562,563,564,565] &&
              runtime_core[520] == [557] && runtime_core[547] == [558]
      assert("Phase47A MasterSetup15 and SetupRuntime09 Boss tables are byte-semantic aligned", exact,
             "start=#{runtime_start.keys.sort.inspect} core=#{runtime_core.keys.sort.inspect} weather=#{runtime_weather.inspect}")
      log("[BOSS_RUNTIME_TABLES] start_keys=#{runtime_start.keys.sort.inspect} core_keys=#{runtime_core.keys.sort.inspect} weather=#{runtime_weather.inspect} ready=#{exact}")
      return exact
    rescue Exception => e
      exception(e, "p47a_bg_runtime_tables_contract")
      assert("Phase47A MasterSetup15 and SetupRuntime09 Boss tables are byte-semantic aligned", false, e.message)
      return false
    end

    def p47a_bg_defense_interaction_contract
      tyler = {}
      dynamic31 = []
      dynamic40 = []
      all_ok = true
      for enemy_id in p47a_principal_ids
        data = ($data_enemies[enemy_id] rescue nil)
        if data == nil
          all_ok = false
          next
        end
        note = data.note.to_s
        threshold = p47a_note_number(note, "break_threshold")
        resist = p47a_note_number(note, "break_resist")
        recover = p47a_note_number(note, "break_recover")
        dyn = p47a_state_dynamic_ids(note)
        tyler[enemy_id] = [threshold,resist,recover]
        dynamic31.push(enemy_id) if dyn.include?(31)
        dynamic40.push(enemy_id) if dyn.include?(40)
        all_ok = false if threshold == nil || resist == nil || recover != 1
        all_ok = false if note !~ /<atb_dynamic_resist>/i || note !~ /<state_dynamic_resist>/i
      end
      assert("Phase47A all 30 Boss principals expose Break + ATB/State resistance contracts", all_ok,
             "tyler=#{tyler.inspect}")
      log("[BOSS_CHARACTER_MATRIX] aizhuo=atb_dynamic_all tyler=#{tyler.inspect} vina_state31_dynamic=#{dynamic31.inspect} joey_state40_dynamic=#{dynamic40.inspect}")
      return all_ok
    rescue Exception => e
      exception(e, "p47a_bg_defense_interaction_contract")
      assert("Phase47A all 30 Boss principals expose Break + ATB/State resistance contracts", false, e.message)
      return false
    end

    def p47a_bg_cyrus_static_contract
      data = ($data_enemies[524] rescue nil)
      ready = !!(data != nil && defined?(ALBERT_ANTAGONIST_CORE))
      assert("Phase47A Cyrus static contract fixture ready", ready)
      return false unless ready
      note = data.note.to_s
      formal_tag = note =~ /<law_cycle_interval\s*:\s*3\s*>/i ? 3 : 0
      parser = Game_Enemy.new(0, 524)
      actual = ALBERT_ANTAGONIST_CORE.law_cycle_actions(parser).to_i
      contract = formal_tag == 3 && actual == formal_tag &&
                 note =~ /<law_cycle_states\s*:\s*140,141,142,143\s*>/i &&
                 note =~ /<law_cycle_if_state\s*:\s*151\s*>/i
      assert("Phase47A Cyrus formal tags and Runtime parser are aligned", !!contract,
             "formal_interval=#{formal_tag} parser_actual=#{actual}")
      log("[BOSS_CYRUS_STATIC] formal_tag=law_cycle_interval:#{formal_tag} runtime_parser_actual=#{actual} suspected_parser_mismatch=#{formal_tag > 0 && actual != formal_tag}")
      return !!contract
    rescue Exception => e
      exception(e, "p47a_bg_cyrus_static_contract")
      assert("Phase47A Cyrus formal phase/law tags are present", false, e.message)
      return false
    end

    def p47a_background_job_names
      return [:roster, :troop_wiring, :runtime_tables, :defense_interactions, :cyrus_static]
    end

    def p47a_run_background_job(name)
      case name
      when :roster
        return p47a_bg_roster_contract
      when :troop_wiring
        return p47a_bg_troop_wiring_contract
      when :runtime_tables
        return p47a_bg_runtime_tables_contract
      when :defense_interactions
        return p47a_bg_defense_interaction_contract
      when :cyrus_static
        return p47a_bg_cyrus_static_contract
      end
      return false
    end

    def p47a_background_tick
      return true if @p47a_bg_done
      jobs = @p47a_bg_jobs
      return false unless jobs.is_a?(Array)
      per = P47A_BACKGROUND_JOBS_PER_FRAME.to_i
      per = 1 if per <= 0
      count = 0
      while count < per && @p47a_bg_index.to_i < jobs.size
        index = @p47a_bg_index.to_i
        name = jobs[index]
        log("[BOSS_BACKGROUND] START index=#{index + 1}/#{jobs.size} job=#{name} frame=#{Graphics.frame_count}")
        before = @fail_count.to_i
        ok = p47a_run_background_job(name)
        delta = @fail_count.to_i - before
        @p47a_bg_results[name] = (ok == true && delta == 0)
        log("[BOSS_BACKGROUND] END job=#{name} ok=#{@p47a_bg_results[name]} fail_delta=#{delta} frame=#{Graphics.frame_count}")
        @p47a_bg_index = index + 1
        count += 1
      end
      if @p47a_bg_index.to_i >= jobs.size
        @p47a_bg_done = true
        all = jobs.all? { |name| @p47a_bg_results[name] == true }
        @p47a_background_ready = all
        log("[BOSS_BACKGROUND_BATCH] jobs=#{jobs.size} results=#{@p47a_bg_results.inspect} ready=#{all}")
      end
      return @p47a_bg_done == true
    rescue Exception => e
      exception(e, "p47a_background_tick")
      @p47a_bg_done = true
      @p47a_background_ready = false
      return false
    end

    unless method_defined?(:fs_phase47a_prepare_battle_fixture_on_map_base)
      alias fs_phase47a_prepare_battle_fixture_on_map_base prepare_battle_fixture_on_map
    end
    def prepare_battle_fixture_on_map
      base = fs_phase47a_prepare_battle_fixture_on_map_base
      return false unless base == true
      @p47a_bg_jobs = p47a_background_job_names
      @p47a_bg_index = 0
      @p47a_bg_results = {}
      @p47a_bg_done = false
      @p47a_background_ready = false
      @p47a_bg_gate_asserted = false
      @p47a_live_batch_ran = false
      @p47a_live_batch_ready = false
      assert("Phase47A Boss frame-sliced background queue created", @p47a_bg_jobs.size == 5,
             "jobs=#{@p47a_bg_jobs.inspect}")
      log("[BOSS_BACKGROUND] queue_created jobs=#{@p47a_bg_jobs.inspect} per_frame=#{P47A_BACKGROUND_JOBS_PER_FRAME}")
      return true
    end

    unless method_defined?(:fs_phase47a_update_prebattle_transition_base)
      alias fs_phase47a_update_prebattle_transition_base update_prebattle_transition
    end
    def update_prebattle_transition(scene)
      if @battle_transition_pending && !@p47a_bg_done
        p47a_background_tick
      end
      if @p47a_bg_done && !@p47a_bg_gate_asserted
        @p47a_bg_gate_asserted = true
        ready = @p47a_background_ready == true
        assert("Phase47A Boss background matrix completed before Scene_Battle transition", ready,
               "results=#{@p47a_bg_results.inspect}")
        log("[BOSS_BACKGROUND_GATE] ready=#{ready} soft_continue=#{!ready}")
      end
      return fs_phase47a_update_prebattle_transition_base(scene)
    end

    def p47a_with_troop_sandbox(enemy_ids)
      return nil if $game_troop == nil
      enemies_snap = p46a_ivar_snapshot($game_troop, :@enemies)
      flags_snap = p46a_ivar_snapshot($game_troop, :@fs_db_autoset_boss_flags)
      field_snap = p46a_ivar_snapshot($game_temp, :@field_effect)
      source_snap = p46a_ivar_snapshot($game_temp, :@fs_field_effect_source)
      old_members = enemies_snap[1]
      fresh = []
      index = 0
      for enemy_id in enemy_ids
        fresh.push(Game_Enemy.new(index, enemy_id))
        index += 1
      end
      $game_troop.instance_variable_set(:@enemies, fresh)
      $game_troop.instance_variable_set(:@fs_db_autoset_boss_flags, {})
      $game_temp.field_effect = nil if $game_temp != nil && $game_temp.respond_to?(:field_effect=)
      $game_temp.fs_field_effect_source = nil if $game_temp != nil && $game_temp.respond_to?(:fs_field_effect_source=)
      result = yield(fresh)
      return result
    ensure
      p46a_restore_ivar($game_troop, :@enemies, enemies_snap) if $game_troop != nil && enemies_snap != nil
      p46a_restore_ivar($game_troop, :@fs_db_autoset_boss_flags, flags_snap) if $game_troop != nil && flags_snap != nil
      p46a_restore_ivar($game_temp, :@field_effect, field_snap) if $game_temp != nil && field_snap != nil
      p46a_restore_ivar($game_temp, :@fs_field_effect_source, source_snap) if $game_temp != nil && source_snap != nil
      if old_members != nil && $game_troop != nil
        restored = $game_troop.instance_variable_get(:@enemies)
        assert("Phase47A live Boss sandbox restores original Troop member array identity", restored.equal?(old_members))
      end
    end

    def p47a_live_cyrus_phase_law
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) && defined?(ALBERT_ANTAGONIST_CORE))
      assert("Phase47A Cyrus live phase/law fixture ready", ready)
      return false unless ready
      result = false
      p47a_with_troop_sandbox([524]) do |members|
        boss = members[0]
        boss.hp = boss.maxhp
        $game_troop.fs_db_autoset_phase_states
        p1 = boss.state?(150) && !boss.state?(151) && !boss.state?(152)
        boss.hp = [boss.maxhp * 69 / 100, 1].max
        $game_troop.fs_db_autoset_phase_states
        interval = boss.albert_ant_law_interval.to_i
        phase2_state = boss.state?(151)
        first_law_state = boss.state?(140)
        mid_start = phase2_state && first_law_state
        boss.albert_ant_after_completed_action
        after1 = [boss.state?(140), boss.state?(141), boss.state?(142), boss.state?(143)]
        boss.albert_ant_after_completed_action
        after2 = [boss.state?(140), boss.state?(141), boss.state?(142), boss.state?(143)]
        boss.albert_ant_after_completed_action
        after3 = [boss.state?(140), boss.state?(141), boss.state?(142), boss.state?(143)]
        cadence = interval == 3 && after1 == [true,false,false,false] &&
                  after2 == [true,false,false,false] && after3 == [false,true,false,false]
        assert("Phase47A Cyrus formal law_cycle_interval3 changes law only after third effective action", cadence,
               "interval=#{interval} after1=#{after1.inspect} after2=#{after2.inspect} after3=#{after3.inspect}")
        boss.hp = [boss.maxhp * 34 / 100, 1].max
        $game_troop.fs_db_autoset_phase_states
        p3 = boss.state?(152) && !boss.state?(150) && !boss.state?(151) &&
             !boss.state?(140) && !boss.state?(141) && !boss.state?(142) && !boss.state?(143)
        assert("Phase47A Cyrus HP phase lifecycle 150 -> 151/140 -> 152 clears law", p1 && mid_start && p3,
               "p1=#{p1} phase151=#{phase2_state} law140=#{first_law_state} mid=#{mid_start} p3=#{p3}")
        result = p1 && mid_start && cadence && p3
      end
      return result
    rescue Exception => e
      exception(e, "p47a_live_cyrus_phase_law")
      assert("Phase47A Cyrus live phase/law fixture completed", false, e.message)
      return false
    end

    def p47a_live_threshold_summons
      ready = defined?(FS_DB_AUTOSET_BOSS_RUNTIME) && $game_troop.respond_to?(:fs_db_autoset_boss_update)
      assert("Phase47A threshold summon live fixture ready", ready)
      return false unless ready
      liser = false
      mewtwo = false
      p47a_with_troop_sandbox([520]) do |members|
        boss = members[0]
        boss.hp = [boss.maxhp * 69 / 100, 1].max
        $game_troop.fs_db_autoset_boss_update(nil)
        cores = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == 557 }
        summoned = cores.size == 1
        for core in cores; core.hp = 0; end
        $game_troop.fs_db_autoset_boss_update(nil)
        exposed = boss.state?(129)
        liser = summoned && exposed
        assert("Phase47A Liser HP70 threshold summons one 557 then core death exposes State129", liser,
               "cores=#{cores.size} exposed=#{exposed}")
      end
      p47a_with_troop_sandbox([547]) do |members|
        boss = members[0]
        boss.hp = [boss.maxhp * 59 / 100, 1].max
        $game_troop.fs_db_autoset_boss_update(nil)
        cores = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == 558 }
        mewtwo = cores.size == 2
        assert("Phase47A Mewtwo HP60 threshold summons exactly two 558", mewtwo,
               "cores=#{cores.size}")
      end
      return liser && mewtwo
    rescue Exception => e
      exception(e, "p47a_live_threshold_summons")
      assert("Phase47A threshold summon live fixture completed", false, e.message)
      return false
    end

    def p47a_live_machine_core
      ready = defined?(FS_DB_AUTOSET_BOSS_RUNTIME) && $game_troop.respond_to?(:fs_db_autoset_boss_update)
      assert("Phase47A BASTION live core fixture ready", ready)
      return false unless ready
      result = false
      p47a_with_troop_sandbox([530]) do |members|
        boss = members[0]
        boss.hp = boss.maxhp
        $game_troop.fs_db_autoset_boss_update(nil)
        cores = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == 561 }
        start_ok = cores.size == 2 && boss.state?(77)
        boss.hp = [boss.maxhp * 44 / 100, 1].max
        $game_troop.fs_db_autoset_boss_update(nil)
        overheat = boss.state?(128)
        for core in cores; core.hp = 0; end
        $game_troop.fs_db_autoset_boss_update(nil)
        exposed = !boss.state?(77) && boss.state?(129)
        result = start_ok && overheat && exposed
        assert("Phase47A BASTION start cores/shield -> 45% overheat -> core death exposure exact", result,
               "cores=#{cores.size} shield_start=#{start_ok} overheat=#{overheat} exposed=#{exposed}")
      end
      return result
    rescue Exception => e
      exception(e, "p47a_live_machine_core")
      assert("Phase47A BASTION live core fixture completed", false, e.message)
      return false
    end

    def p47a_live_weather_trio
      ready = !!(defined?(FS_FIELD_WEATHER) && defined?(FS_DB_AUTOSET_BOSS_RUNTIME))
      assert("Phase47A weather trio live fixture ready", ready)
      return false unless ready
      table = {
        548=>[122,125,153,156],
        549=>[123,126,154,157],
        550=>[124,127,155,158]
      }
      all = true
      table.each do |enemy_id, states|
        one = false
        p47a_with_troop_sandbox([enemy_id]) do |members|
          boss = members[0]
          boss.hp = boss.maxhp
          $game_troop.fs_db_autoset_phase_states
          high = boss.state?(states[0]) && !boss.state?(states[1]) &&
                 FS_FIELD_WEATHER.current_id.to_i == states[2]
          boss.hp = [boss.maxhp * 54 / 100, 1].max
          $game_troop.fs_db_autoset_phase_states
          low = !boss.state?(states[0]) && boss.state?(states[1]) &&
                FS_FIELD_WEATHER.current_id.to_i == states[3]
          one = high && low
          assert("Phase47A weather Boss #{enemy_id} 55% state/field transition exact", one,
                 "high=#{high} low=#{low} field=#{FS_FIELD_WEATHER.current_id}")
        end
        all = false unless one
      end
      return all
    rescue Exception => e
      exception(e, "p47a_live_weather_trio")
      assert("Phase47A weather trio live fixture completed", false, e.message)
      return false
    end

    def p47a_run_live_boss_batch
      return @p47a_live_batch_ready if @p47a_live_batch_ran
      @p47a_live_batch_ran = true
      cyrus = p47a_live_cyrus_phase_law
      thresholds = p47a_live_threshold_summons
      machine = p47a_live_machine_core
      weather = p47a_live_weather_trio
      ready = @p47a_background_ready == true && cyrus && thresholds && machine && weather
      @p47a_live_batch_ready = ready
      log("[BOSS_REGRESSION_MATRIX_I] roster=30 adds=15 troop_db_refs=0 cyrus=#{cyrus} threshold_summons=#{thresholds} machine_core=#{machine} weather_trio=#{weather} ready=#{ready}")
      log("[BOSS_REGRESSION_PENDING] tested=[520,524,530,547,548,549,550] pending_principals=#{(p47a_principal_ids - [520,524,530,547,548,549,550]).inspect}")
      assert("Phase47A Boss Regression Matrix I live batch completed", ready,
             "background=#{@p47a_background_ready} cyrus=#{cyrus} thresholds=#{thresholds} machine=#{machine} weather=#{weather}")
      return ready
    rescue Exception => e
      exception(e, "p47a_run_live_boss_batch")
      @p47a_live_batch_ready = false
      assert("Phase47A Boss Regression Matrix I live batch completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase47a_p46d_run_live_batch_base)
      alias fs_phase47a_p46d_run_live_batch_base p46d_run_live_batch
    end
    def p46d_run_live_batch
      main_ready = fs_phase47a_p46d_run_live_batch_base
      boss_ready = p47a_run_live_boss_batch
      log("[PHASE47A_INTEGRATED] phase46e_main=#{main_ready} boss_matrix_i=#{boss_ready} ready=#{main_ready && boss_ready}")
      return main_ready && boss_ready
    end

    unless method_defined?(:fs_phase47a_restore_pending_snapshot_base)
      alias fs_phase47a_restore_pending_snapshot_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase47a_restore_pending_snapshot_base
      if result
        @p47a_bg_jobs = nil
        @p47a_bg_index = 0
        @p47a_bg_results = nil
        @p47a_bg_done = false
        @p47a_background_ready = false
        @p47a_bg_gate_asserted = false
        @p47a_live_batch_ran = false
        @p47a_live_batch_ready = false
      end
      return result
    end
  end
end
end

#==============================================================================
# 【Phase47B】Formal Boss Regression Matrix II — Remaining 23 Principals
# TEST-only v1.0a
#------------------------------------------------------------------------------
# 基準：Phase47A1 使用者 RPG Maker VX 實機 1311 PASS / 0 FAIL / 0 WARN。
# Formal Runtime：0 修改；page382 / page401 維持 Phase47A1 已封版修正。
#
# 本批在既有 Battle2 live troop sandbox 內一次覆蓋 Phase47A pending 23 名 principal：
# - 500..509、521..523：固定開場召喚、100% runtime scale、idempotence；
#   507..509 / 521..523 同時驗證 shared core 的 boss-context AI action table。
# - 510：天候祭司只抽 554/555/556 其中一顆祭壇核心，flag/idempotence 與
#   對應 core context action 皆精確；FS_AI_RANDOM 狀態 TEST-only exact restore。
# - 511：從 500..510 抽兩名不同菁英，各 72% scale；不得重複召喚。
# - 531：四模組 562..565、State77 shield、HP<=45% State128、全核心死亡 State129，
#   並驗證四模組 context AI action table。
# - 540..546：各 Boss 開場核心數量、core context AI action、核心存活不暴露、
#   全核心死亡後 State129 exposure。
#
# 不新增 Scene_Battle session、不建立 Ruby Thread、不修改正式 Enemy/Troop Data。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  class << self
    def p47b_action_signature(enemy)
      return [] if enemy == nil
      holder = enemy.candidate_actions_enemy
      return [] if holder == nil || !holder.respond_to?(:actions)
      result = []
      for action in holder.actions
        next if action == nil
        result.push([action.kind.to_i, action.skill_id.to_i, action.rating.to_i])
      end
      return result
    rescue
      return []
    end

    def p47b_runtime_random_snapshot
      return nil unless defined?(FS_AI_RANDOM)
      names = [:@enabled, :@seed, :@state, :@count, :@trace]
      result = {}
      for name in names
        result[name] = p46a_ivar_snapshot(FS_AI_RANDOM, name)
      end
      return result
    end

    def p47b_runtime_random_restore(snapshot)
      return if snapshot == nil || !defined?(FS_AI_RANDOM)
      snapshot.each do |name, data|
        p46a_restore_ivar(FS_AI_RANDOM, name, data)
      end
    end

    def p47b_runtime_random_matches_snapshot?(snapshot)
      return false if snapshot == nil || !defined?(FS_AI_RANDOM)
      snapshot.each do |name, data|
        present = p45k_ivar_present?(FS_AI_RANDOM, name)
        return false unless present == data[0]
        if data[0]
          current = FS_AI_RANDOM.instance_variable_get(name)
          return false unless current == data[1]
        end
      end
      return true
    rescue
      return false
    end

    def p47b_live_fixed_start_summons
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) &&
                 $game_troop != nil &&
                 $game_troop.respond_to?(:fs_db_autoset_initial_summons))
      assert("Phase47B fixed start-summon fixture ready", ready)
      return false unless ready

      table = {
        500=>[600,2], 501=>[659,2], 502=>[664,2], 503=>[503,2],
        504=>[708,2], 505=>[671,2], 506=>[742,1], 507=>[551,2],
        508=>[552,1], 509=>[553,2], 521=>[558,2], 522=>[559,2],
        523=>[560,2]
      }
      contexts = {
        507=>[[1,316,7],[1,317,9]],
        508=>[[1,318,7],[1,319,9]],
        509=>[[1,306,7],[1,307,8]],
        521=>[[1,333,7],[1,334,9]],
        522=>[[1,336,9]],
        523=>[[1,338,8],[1,339,9]]
      }
      all = true
      table.keys.sort.each do |boss_id|
        target_id, expected_total = table[boss_id]
        one = false
        p47a_with_troop_sandbox([boss_id]) do |members|
          before_oids = $game_troop.members.collect { |enemy| enemy.object_id }
          $game_troop.fs_db_autoset_initial_summons(nil)
          matches = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == target_id }
          spawned = matches.select { |enemy| !before_oids.include?(enemy.object_id) }
          existing_before = (target_id == boss_id ? 1 : 0)
          expected_new = [expected_total - existing_before, 0].max
          count_ok = (matches.size == expected_total && spawned.size == expected_new)
          scale_ok = spawned.all? { |enemy| enemy.fs_boss_runtime_scale.to_i == 100 }
          flag_ok = ($game_troop.fs_db_autoset_flags[[:start,boss_id]] == true)
          size_before_repeat = $game_troop.members.size
          $game_troop.fs_db_autoset_initial_summons(nil)
          idempotent = ($game_troop.members.size == size_before_repeat)
          context_ok = true
          context_actual = nil
          if contexts.has_key?(boss_id)
            core = $game_troop.members.find { |enemy| enemy != nil && enemy.enemy_id == target_id }
            context_actual = p47b_action_signature(core)
            context_ok = (context_actual == contexts[boss_id])
          end
          one = count_ok && scale_ok && flag_ok && idempotent && context_ok
          assert("Phase47B Boss #{boss_id} fixed opening summon/context contract exact", one,
                 "target=#{target_id} total=#{matches.size}/#{expected_total} spawned=#{spawned.size}/#{expected_new} scale100=#{scale_ok} flag=#{flag_ok} idempotent=#{idempotent} context=#{context_actual.inspect}")
        end
        all = false unless one
      end
      return all
    rescue Exception => e
      exception(e, "p47b_live_fixed_start_summons")
      assert("Phase47B fixed start-summon fixture completed", false, e.message)
      return false
    end

    def p47b_live_random_command_bosses
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) && defined?(FS_AI_RANDOM) &&
                 $game_troop != nil && $game_troop.respond_to?(:fs_db_autoset_initial_summons))
      assert("Phase47B random command Boss fixture ready", ready)
      return false unless ready
      random_snap = p47b_runtime_random_snapshot
      altar_ok = false
      pair_ok = false
      begin
        FS_AI_RANDOM.enable(47010)
        p47a_with_troop_sandbox([510]) do |members|
          boss = members[0]
          $game_troop.fs_db_autoset_initial_summons(nil)
          chosen = $game_troop.fs_db_autoset_flags[[:altar,510]]
          altar = $game_troop.members.select { |enemy| enemy != nil && [554,555,556].include?(enemy.enemy_id) }
          count_ok = altar.size == 1 && [554,555,556].include?(chosen)
          source_ok = altar.size == 1 && altar[0].enemy_id == chosen
          context_expected = [[0,0,5],[1,320,8]]
          context_actual = altar.empty? ? [] : p47b_action_signature(altar[0])
          context_ok = (context_actual == context_expected)
          size_before_repeat = $game_troop.members.size
          $game_troop.fs_db_autoset_initial_summons(nil)
          idempotent = ($game_troop.members.size == size_before_repeat)
          altar_ok = count_ok && source_ok && context_ok && idempotent
          assert("Phase47B Boss510 altar random core / context / idempotence exact", altar_ok,
                 "chosen=#{chosen.inspect} altar_ids=#{altar.collect{|e| e.enemy_id}.inspect} context=#{context_actual.inspect} idempotent=#{idempotent}")
        end

        FS_AI_RANDOM.reset(47011)
        p47a_with_troop_sandbox([511]) do |members|
          boss = members[0]
          before_oids = $game_troop.members.collect { |enemy| enemy.object_id }
          $game_troop.fs_db_autoset_initial_summons(nil)
          chosen = $game_troop.fs_db_autoset_flags[[:elite_pair,511]]
          spawned = $game_troop.members.select { |enemy| enemy != nil && !before_oids.include?(enemy.object_id) }
          ids = spawned.collect { |enemy| enemy.enemy_id }
          ids_ok = spawned.size == 2 && ids.uniq.size == 2 && ids.all? { |id| id >= 500 && id <= 510 }
          flag_ok = chosen.is_a?(Array) && chosen.size == 2 && chosen.sort == ids.sort
          scale_ok = spawned.all? { |enemy| enemy.fs_boss_runtime_scale.to_i == 72 }
          # Phase47B1 TEST-only correction:
          # Boss511 的第二次 update 可能合法啟動它剛召出的 Elite 子 Boss Runtime
          # （例如 509 的 start summon、510 的 altar），因此 Troop 總 size 不是
          # 511 自身 idempotence 的合法觀察面。真正要驗的是：511 不得再建立
          # 第二組 72% Elite pair，且 pair flag 必須保持完全一致。
          pair_flag_before = chosen.dup
          pair72_before = $game_troop.members.select do |enemy|
            enemy != nil && enemy.enemy_id >= 500 && enemy.enemy_id <= 510 &&
              enemy.fs_boss_runtime_scale.to_i == 72
          end.collect { |enemy| enemy.object_id }.sort
          size_before_repeat = $game_troop.members.size
          $game_troop.fs_db_autoset_initial_summons(nil)
          size_after_repeat = $game_troop.members.size
          pair72_after = $game_troop.members.select do |enemy|
            enemy != nil && enemy.enemy_id >= 500 && enemy.enemy_id <= 510 &&
              enemy.fs_boss_runtime_scale.to_i == 72
          end.collect { |enemy| enemy.object_id }.sort
          pair_flag_after = $game_troop.fs_db_autoset_flags[[:elite_pair,511]]
          idempotent = (pair72_after == pair72_before &&
                        pair_flag_after == pair_flag_before)
          pair_ok = ids_ok && flag_ok && scale_ok && idempotent
          assert("Phase47B Boss511 distinct elite pair / 72% scale / idempotence exact", pair_ok,
                 "spawned=#{ids.inspect} flag=#{chosen.inspect} scale=#{spawned.collect{|e| e.fs_boss_runtime_scale}.inspect} idempotent=#{idempotent} pair72=#{pair72_before.inspect}->#{pair72_after.inspect} child_growth=#{size_after_repeat-size_before_repeat}")
        end
      ensure
        p47b_runtime_random_restore(random_snap)
      end
      random_restored = p47b_runtime_random_matches_snapshot?(random_snap)
      assert("Phase47B TEST-only FS_AI_RANDOM state restored exactly after Boss510/511", random_restored)
      return altar_ok && pair_ok && random_restored
    rescue Exception => e
      p47b_runtime_random_restore(random_snap) if random_snap != nil
      exception(e, "p47b_live_random_command_bosses")
      assert("Phase47B random command Boss fixture completed", false, e.message)
      return false
    end

    def p47b_live_orchestra_modules
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) &&
                 $game_troop != nil && $game_troop.respond_to?(:fs_db_autoset_boss_update))
      assert("Phase47B ORCHESTRA-0 module fixture ready", ready)
      return false unless ready
      result = false
      expected_context = {
        562=>[[0,0,5],[1,353,9]],
        563=>[[1,350,8]],
        564=>[[1,355,9]],
        565=>[[1,308,7],[1,352,9]]
      }
      p47a_with_troop_sandbox([531]) do |members|
        boss = members[0]
        boss.hp = boss.maxhp
        $game_troop.fs_db_autoset_boss_update(nil)
        modules = {}
        [562,563,564,565].each do |id|
          modules[id] = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == id }
        end
        counts_ok = modules.keys.all? { |id| modules[id].size == 1 }
        shield_start = boss.state?(77)
        context_ok = modules.keys.all? do |id|
          p47b_action_signature(modules[id][0]) == expected_context[id]
        end
        boss.hp = [boss.maxhp * 44 / 100, 1].max
        $game_troop.fs_db_autoset_boss_update(nil)
        overheat = boss.state?(128)
        modules.each_value do |list|
          for core in list; core.hp = 0; end
        end
        $game_troop.fs_db_autoset_boss_update(nil)
        exposed = !boss.state?(77) && boss.state?(129)
        result = counts_ok && shield_start && context_ok && overheat && exposed
        assert("Phase47B Boss531 four modules / context AI / shield / overheat / exposure exact", result,
               "counts=#{modules.keys.sort.collect{|id| [id,modules[id].size]}.inspect} shield=#{shield_start} context=#{context_ok} overheat=#{overheat} exposed=#{exposed}")
      end
      return result
    rescue Exception => e
      exception(e, "p47b_live_orchestra_modules")
      assert("Phase47B ORCHESTRA-0 module fixture completed", false, e.message)
      return false
    end

    def p47b_live_core_bosses_540_546
      ready = !!(defined?(FS_DB_AUTOSET_BOSS_RUNTIME) &&
                 $game_troop != nil && $game_troop.respond_to?(:fs_db_autoset_boss_update))
      assert("Phase47B Boss540-546 core lifecycle fixture ready", ready)
      return false unless ready
      table = {
        540=>[551,2,[[1,300,7],[1,302,8]]],
        541=>[552,2,[[1,312,8]]],
        542=>[553,2,[[0,0,5],[1,304,8]]],
        543=>[554,2,[[1,406,8]]],
        544=>[555,2,[[1,308,7],[1,408,9]]],
        545=>[556,2,[[0,0,5],[1,410,9]]],
        546=>[557,3,[[1,413,9]]]
      }
      all = true
      table.keys.sort.each do |boss_id|
        core_id, expected_count, expected_actions = table[boss_id]
        one = false
        p47a_with_troop_sandbox([boss_id]) do |members|
          boss = members[0]
          $game_troop.fs_db_autoset_boss_update(nil)
          cores = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == core_id }
          start_ok = cores.size == expected_count && !boss.state?(129)
          context_ok = !cores.empty? && p47b_action_signature(cores[0]) == expected_actions
          for core in cores; core.hp = 0; end
          $game_troop.fs_db_autoset_boss_update(nil)
          exposure = boss.state?(129)
          one = start_ok && context_ok && exposure
          assert("Phase47B Boss #{boss_id} core count/context/exposure lifecycle exact", one,
                 "core=#{core_id} count=#{cores.size}/#{expected_count} context=#{cores.empty? ? [] : p47b_action_signature(cores[0]).inspect} exposed=#{exposure}")
        end
        all = false unless one
      end
      return all
    rescue Exception => e
      exception(e, "p47b_live_core_bosses_540_546")
      assert("Phase47B Boss540-546 core lifecycle fixture completed", false, e.message)
      return false
    end

    def p47b_run_live_boss_batch
      return @p47b_live_batch_ready if @p47b_live_batch_ran
      @p47b_live_batch_ran = true
      fixed = p47b_live_fixed_start_summons
      randoms = p47b_live_random_command_bosses
      orchestra = p47b_live_orchestra_modules
      cores = p47b_live_core_bosses_540_546
      tested = (500..511).to_a + [521,522,523,531] + (540..546).to_a
      ready = fixed && randoms && orchestra && cores && tested.size == 23
      @p47b_live_batch_ready = ready
      log("[BOSS_REGRESSION_MATRIX_II] fixed_start=#{fixed} random_command=#{randoms} orchestra=#{orchestra} core_bosses=#{cores} tested=#{tested.inspect} ready=#{ready}")
      log("[BOSS_REGRESSION_COMPLETE] matrix_i=[520,524,530,547,548,549,550] matrix_ii=#{tested.inspect} pending=[] ready=#{ready}")
      assert("Phase47B Boss Regression Matrix II remaining 23 principals completed", ready,
             "fixed=#{fixed} randoms=#{randoms} orchestra=#{orchestra} cores=#{cores} pending=[]")
      return ready
    rescue Exception => e
      exception(e, "p47b_run_live_boss_batch")
      @p47b_live_batch_ready = false
      assert("Phase47B Boss Regression Matrix II remaining 23 principals completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase47b_p47a_run_live_boss_batch_base)
      alias fs_phase47b_p47a_run_live_boss_batch_base p47a_run_live_boss_batch
    end
    def p47a_run_live_boss_batch
      matrix_i = fs_phase47b_p47a_run_live_boss_batch_base
      matrix_ii = p47b_run_live_boss_batch
      ready = matrix_i && matrix_ii
      log("[PHASE47B_INTEGRATED] matrix_i=#{matrix_i} matrix_ii=#{matrix_ii} all_30_principals=#{ready} ready=#{ready}")
      return ready
    end

    unless method_defined?(:fs_phase47b_restore_pending_snapshot_base)
      alias fs_phase47b_restore_pending_snapshot_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase47b_restore_pending_snapshot_base
      if result
        @p47b_live_batch_ran = false
        @p47b_live_batch_ready = false
      end
      return result
    end
  end
end
end


#==============================================================================
# 【Phase48A】AI Edge Coverage / Forced-Action Authority I
# TEST-only v1.0
#------------------------------------------------------------------------------
# 基準：Phase47B1 使用者 RPG Maker VX 實機 1363 PASS / 0 FAIL / 0 WARN SEALED。
# Formal Runtime：0 修改。本批只增加 deterministic AI / target / force-action evidence。
#
# Coverage：
# 1. Actor AI State priority：18 > 22 > 23 > 17 > 25。
# 2. Actor target preference equal-score tie：FS_AI_RANDOM deterministic target tie-break。
# 3. EnemyActionPattern equal-rating roulette：兩個 rating=5 basic actions 以 deterministic
#    :enemy_action_roulette 精確重播，不經 FinalDistribution 改寫。
# 4. EnemyActionDistribution replacement policy：urgent friend skill 不可被普通攻擊取代；
#    offensive skill 可取代；final-action damage recorder 與 normal non-forcing semantic 精確。
# 5. FS_ForceAction_Bridge + Boss summon interaction：Boss507 正式召喚 551 後，live add
#    可入 ATB forcing queue、重複 queue entry 去重、死亡 add 被 drain 拒絕；Scene/Troop queue exact restore。
#
# 永久規則：Fixture failure 只改 TEST；沒有實機證據不得修改 Formal Runtime。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  @p48a_ai_edge_ran = false
  @p48a_ai_edge_ready = false

  class << self
    def p48a_detached_actor_priority
      ready = !!(defined?(AutoBattleAI) && defined?(ALBERT_AUTO_BATTLE_AI_FIX))
      assert("Phase48A Actor AI priority fixture providers ready", ready)
      return false unless ready
      actor = Game_Actor.new(1)
      formal = ($game_actors[1] rescue nil)
      detached = formal == nil || !actor.equal?(formal)
      assert("Phase48A Actor AI priority uses detached Actor identity", detached,
             "detached=#{actor.object_id} formal=#{formal == nil ? 'nil' : formal.object_id}")
      for state_id in [18,22,23,17,25]
        actor.add_state(state_id)
      end
      p1 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(18)
      p2 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(22)
      p3 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(23)
      p4 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(17)
      p5 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(25)
      p6 = AutoBattleAI.get_actor_ai(actor)
      exact = p1 == :healy && p2 == :protect && p3 == :support &&
              p4 == :wild && p5 == :balanced && p6 == nil
      assert("Phase48A Actor AI multi-State priority chain exact", exact,
             "packages=#{[p1,p2,p3,p4,p5,p6].inspect} priority=#{ALBERT_AUTO_BATTLE_AI_FIX::AI_STATE_PRIORITY.inspect}")
      log("[AI_EDGE_ACTOR_PRIORITY] packages=#{[p1,p2,p3,p4,p5,p6].inspect} ready=#{exact}")
      return detached && exact
    rescue Exception => e
      exception(e, "p48a_detached_actor_priority")
      assert("Phase48A Actor AI priority fixture completed", false, e.message)
      return false
    end

    def p48a_actor_target_tie
      ready = !!(defined?(FS_AI_RANDOM) && defined?(ALBERT_MECHANIC_EXPANSION) &&
                 $game_troop != nil && $game_troop.existing_members.size >= 2)
      assert("Phase48A Actor deterministic target-tie fixture ready", ready,
             "targets=#{$game_troop == nil ? 0 : $game_troop.existing_members.size}")
      return false unless ready
      actor = Game_Actor.new(1)
      skill = RPG::Skill.new
      skill.instance_variable_set(:@scope, 1)
      skill.instance_variable_set(:@note, "<ai_bonus_vs_state 9999:100>")
      targets = actor.albert_mx_ai_valid_targets(skill)
      seed = 48002
      expected_roll = FS_AI_RANDOM.preview(seed, [targets.size])[0]
      expected = targets[expected_roll]
      actor.action.clear
      FS_AI_RANDOM.reset(seed)
      actor.albert_auto_ai_apply_mx_target_preference(skill)
      actual = targets.find { |target| target.index.to_i == actor.action.target_index.to_i }
      trace = FS_AI_RANDOM.trace
      tagged = trace.find { |entry| entry[1] == :actor_ai_best_target_tie }
      exact = targets.size >= 2 && expected != nil && actual != nil &&
              actual.equal?(expected) && tagged != nil && tagged[3].to_i == expected_roll.to_i
      assert("Phase48A Actor equal-score target tie follows deterministic RNG exactly", exact,
             "seed=#{seed} count=#{targets.size} expected_roll=#{expected_roll} target=#{actual == nil ? 'nil' : object_label(actual)} trace=#{trace.inspect}")
      log("[AI_EDGE_TARGET_TIE] seed=#{seed} count=#{targets.size} roll=#{expected_roll} target_index=#{actor.action.target_index} ready=#{exact}")
      actor.action.clear
      return exact
    rescue Exception => e
      exception(e, "p48a_actor_target_tie")
      assert("Phase48A Actor deterministic target-tie fixture completed", false, e.message)
      return false
    end

    def p48a_enemy_equal_rating_roulette
      ready = !!(defined?(FS_AI_RANDOM) && defined?(Extension_Action_Condition) &&
                 $data_enemies != nil && $data_enemies[609] != nil)
      assert("Phase48A Enemy equal-rating roulette fixture ready", ready)
      return false unless ready
      original = $data_enemies[609]
      original_bytes = Marshal.dump(original)
      exact = false
      replay = false
      roll_value = nil
      expected_basic = nil
      begin
        test_enemy = original.clone
        a1 = RPG::Enemy::Action.new
        a1.instance_variable_set(:@kind, 0)
        a1.instance_variable_set(:@basic, 0)
        a1.instance_variable_set(:@skill_id, 0)
        a1.instance_variable_set(:@condition_type, 0)
        a1.instance_variable_set(:@condition_param1, 0)
        a1.instance_variable_set(:@condition_param2, 0)
        a1.instance_variable_set(:@rating, 5)
        a1.conditions_arrays = []
        a2 = RPG::Enemy::Action.new
        a2.instance_variable_set(:@kind, 0)
        a2.instance_variable_set(:@basic, 1)
        a2.instance_variable_set(:@skill_id, 0)
        a2.instance_variable_set(:@condition_type, 0)
        a2.instance_variable_set(:@condition_param1, 0)
        a2.instance_variable_set(:@condition_param2, 0)
        a2.instance_variable_set(:@rating, 5)
        a2.conditions_arrays = []
        test_enemy.instance_variable_set(:@actions, [a1,a2])
        $data_enemies[609] = test_enemy
        p47a_with_troop_sandbox([609]) do |members|
          enemy = members[0]
          seed = 48003
          expected_roll = FS_AI_RANDOM.preview(seed, [10])[0]
          expected_basic = expected_roll.to_i < 5 ? 0 : 1
          FS_AI_RANDOM.reset(seed)
          enemy.eac_make_action(609)
          sig1 = p41a_action_signature(enemy)
          trace1 = FS_AI_RANDOM.trace
          roulette = trace1.find { |entry| entry[1] == :enemy_action_roulette }
          roll_value = roulette == nil ? nil : roulette[3].to_i
          exact = roulette != nil && roulette[2].to_i == 10 &&
                  roll_value.to_i == expected_roll.to_i &&
                  enemy.action.kind.to_i == 0 && enemy.action.basic.to_i == expected_basic.to_i &&
                  enemy.action.forcing != true
          enemy.action.clear
          FS_AI_RANDOM.reset(seed)
          enemy.eac_make_action(609)
          sig2 = p41a_action_signature(enemy)
          replay = (sig1 == sig2)
          assert("Phase48A Enemy equal-rating roulette follows deterministic 5-vs-5 tie exactly", exact,
                 "roll=#{roll_value.inspect}/#{expected_roll} basic=#{enemy.action.basic}/#{expected_basic} trace=#{trace1.inspect}")
          assert("Phase48A Enemy equal-rating roulette same-seed action replay exact", replay,
                 "first=#{sig1.inspect} second=#{sig2.inspect}")
          enemy.action.clear
        end
      ensure
        $data_enemies[609] = original
      end
      db_ok = $data_enemies[609].equal?(original) && Marshal.dump($data_enemies[609]) == original_bytes
      assert("Phase48A Enemy roulette TEST database slot restored exact", db_ok, "enemy_id=609")
      log("[AI_EDGE_ENEMY_TIE] roll=#{roll_value.inspect} expected_basic=#{expected_basic.inspect} exact=#{exact} replay=#{replay} db=#{db_ok}")
      return exact && replay && db_ok
    rescue Exception => e
      begin
        $data_enemies[609] = original if original != nil
      rescue
      end
      exception(e, "p48a_enemy_equal_rating_roulette")
      assert("Phase48A Enemy equal-rating roulette fixture completed", false, e.message)
      return false
    end

    def p48a_enemy_replacement_policy
      ready = !!(defined?(FS_ENEMY_ACTION_DIST) && $data_skills != nil)
      assert("Phase48A Enemy replacement-policy fixture provider ready", ready)
      return false unless ready
      urgent = nil
      offensive = nil
      for skill in $data_skills
        next if skill == nil
        urgent = skill if urgent == nil && FS_ENEMY_ACTION_DIST.urgent_friend_skill?(skill)
        offensive = skill if offensive == nil && skill.for_opponent? && skill.base_damage.to_i > 0
        break if urgent != nil && offensive != nil
      end
      candidates = urgent != nil && offensive != nil
      assert("Phase48A Enemy replacement-policy skill candidates resolved", candidates,
             "urgent=#{urgent == nil ? 'nil' : urgent.id} offensive=#{offensive == nil ? 'nil' : offensive.id}")
      return false unless candidates
      exact = false
      recorder = false
      normal_nonforcing = false
      p47a_with_troop_sandbox([609]) do |members|
        enemy = members[0]
        old_last = enemy.instance_variable_get(:@fs_ead_last_damage_skill)
        enemy.action.set_skill(urgent.id)
        urgent_replace = FS_ENEMY_ACTION_DIST.can_replace_with_attack?(enemy)
        enemy.action.set_skill(offensive.id)
        offensive_replace = FS_ENEMY_ACTION_DIST.can_replace_with_attack?(enemy)
        normal_nonforcing = enemy.action.forcing != true
        FS_ENEMY_ACTION_DIST.record_final_action(enemy)
        damage_record = enemy.instance_variable_get(:@fs_ead_last_damage_skill) == true
        enemy.action.set_attack
        FS_ENEMY_ACTION_DIST.record_final_action(enemy)
        attack_record = enemy.instance_variable_get(:@fs_ead_last_damage_skill) == false
        recorder = damage_record && attack_record
        exact = urgent_replace == false && offensive_replace == true
        assert("Phase48A Enemy Distribution preserves urgent friend skill but allows offensive replacement", exact,
               "urgent=#{urgent.id}:#{urgent.name} replace=#{urgent_replace} offensive=#{offensive.id}:#{offensive.name} replace=#{offensive_replace}")
        assert("Phase48A Enemy final-action recorder distinguishes damage skill vs normal attack", recorder,
               "damage=#{damage_record} attack=#{attack_record}")
        assert("Phase48A normal Enemy AI action remains non-forcing", normal_nonforcing,
               "forcing=#{enemy.action.forcing}")
        enemy.action.clear
        enemy.instance_variable_set(:@fs_ead_last_damage_skill, old_last)
      end
      log("[AI_EDGE_REPLACEMENT] urgent=#{urgent.id} offensive=#{offensive.id} policy=#{exact} recorder=#{recorder} normal_nonforcing=#{normal_nonforcing}")
      return exact && recorder && normal_nonforcing
    rescue Exception => e
      exception(e, "p48a_enemy_replacement_policy")
      assert("Phase48A Enemy replacement-policy fixture completed", false, e.message)
      return false
    end

    def p48a_force_action_summon_interaction
      scene = $scene
      ready = !!(defined?(FS_FORCE_ACTION_BRIDGE) && defined?(FS_DB_AUTOSET_BOSS_RUNTIME) &&
                 scene.is_a?(Scene_Battle) && scene.respond_to?(:fs_drain_force_action_queue))
      assert("Phase48A ForceAction / Boss summon interaction fixture ready", ready,
             "scene=#{scene == nil ? 'nil' : scene.class}")
      return false unless ready
      live_ok = false
      dedupe_ok = false
      dead_reject = false
      restore_ok = false
      forcing_snap = p46a_ivar_snapshot(scene, :@forcing_battlers)
      queue_snap = p46a_ivar_snapshot($game_troop, :@fs_force_action_queue)
      begin
        p47a_with_troop_sandbox([507]) do |members|
          boss = members[0]
          $game_troop.fs_db_autoset_boss_update(nil)
          adds = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == 551 }
          add = adds[0]
          assert("Phase48A Boss507 formal Runtime produces live 551 summon for ForceAction probe", add != nil && add.exist?,
                 "adds=#{adds.collect { |enemy| enemy.enemy_id }.inspect}")
          next if add == nil
          scene.instance_variable_set(:@forcing_battlers, [])
          $game_troop.fs_force_action_queue = []
          live_ok = FS_FORCE_ACTION_BRIDGE.setup_action(add, 0, 0, FS_FORCE_ACTION_BRIDGE::RANDOM_TARGET) &&
                    add.action.forcing == true
          assert("Phase48A ForceAction Bridge marks live summoned add action as forcing", live_ok,
                 "action=#{p41a_action_signature(add).inspect}")
          $game_troop.fs_force_action_queue << add
          $game_troop.fs_force_action_queue << add
          scene.fs_drain_force_action_queue
          forcing = scene.instance_variable_get(:@forcing_battlers)
          dedupe_ok = $game_troop.fs_force_action_queue.empty? &&
                      forcing.select { |battler| battler.equal?(add) }.size == 1
          assert("Phase48A ForceAction drain dedupes duplicate live summoned battler", dedupe_ok,
                 "queue=#{$game_troop.fs_force_action_queue.size} forcing=#{forcing.collect { |b| b.object_id }.inspect}")
          scene.instance_variable_set(:@forcing_battlers, [])
          add.hp = 0
          $game_troop.fs_force_action_queue = [add]
          scene.fs_drain_force_action_queue
          dead_forcing = scene.instance_variable_get(:@forcing_battlers)
          dead_reject = $game_troop.fs_force_action_queue.empty? &&
                        !dead_forcing.any? { |battler| battler.equal?(add) }
          assert("Phase48A ForceAction drain rejects dead summoned battler without queue leak", dead_reject,
                 "queue=#{$game_troop.fs_force_action_queue.size} forcing=#{dead_forcing.collect { |b| b.object_id }.inspect}")
        end
      ensure
        p46a_restore_ivar(scene, :@forcing_battlers, forcing_snap) if scene != nil && forcing_snap != nil
        p46a_restore_ivar($game_troop, :@fs_force_action_queue, queue_snap) if $game_troop != nil && queue_snap != nil
      end
      forcing_after = p46a_ivar_snapshot(scene, :@forcing_battlers)
      queue_after = p46a_ivar_snapshot($game_troop, :@fs_force_action_queue)
      restore_ok = forcing_after == forcing_snap && queue_after == queue_snap
      assert("Phase48A ForceAction TEST Scene/Troop queue state restored exact", restore_ok,
             "forcing=#{forcing_snap.inspect}->#{forcing_after.inspect} queue=#{queue_snap.inspect}->#{queue_after.inspect}")
      log("[AI_EDGE_FORCE_SUMMON] live=#{live_ok} dedupe=#{dedupe_ok} dead_reject=#{dead_reject} restore=#{restore_ok}")
      return live_ok && dedupe_ok && dead_reject && restore_ok
    rescue Exception => e
      begin
        p46a_restore_ivar(scene, :@forcing_battlers, forcing_snap) if scene != nil && forcing_snap != nil
        p46a_restore_ivar($game_troop, :@fs_force_action_queue, queue_snap) if $game_troop != nil && queue_snap != nil
      rescue
      end
      exception(e, "p48a_force_action_summon_interaction")
      assert("Phase48A ForceAction / Boss summon interaction fixture completed", false, e.message)
      return false
    end

    def p48a_run_ai_edge_batch
      return @p48a_ai_edge_ready if @p48a_ai_edge_ran
      @p48a_ai_edge_ran = true
      random_snap = p47b_runtime_random_snapshot
      priority = false
      target_tie = false
      enemy_tie = false
      replacement = false
      force_summon = false
      rng_restored = false
      begin
        priority = p48a_detached_actor_priority
        target_tie = p48a_actor_target_tie
        enemy_tie = p48a_enemy_equal_rating_roulette
        replacement = p48a_enemy_replacement_policy
        force_summon = p48a_force_action_summon_interaction
      ensure
        p47b_runtime_random_restore(random_snap)
      end
      rng_restored = p47b_runtime_random_matches_snapshot?(random_snap)
      assert("Phase48A AI deterministic RNG state restored exactly", rng_restored)
      ready = priority && target_tie && enemy_tie && replacement && force_summon && rng_restored
      @p48a_ai_edge_ready = ready
      log("[AI_EDGE_COVERAGE_I] actor_priority=#{priority} actor_target_tie=#{target_tie} enemy_rating_tie=#{enemy_tie} replacement=#{replacement} force_summon=#{force_summon} rng_restore=#{rng_restored} ready=#{ready}")
      assert("Phase48A AI Edge Coverage / Forced-Action Authority I completed", ready,
             "priority=#{priority} target=#{target_tie} enemy_tie=#{enemy_tie} replacement=#{replacement} force=#{force_summon} rng=#{rng_restored}")
      return ready
    rescue Exception => e
      p47b_runtime_random_restore(random_snap) if random_snap != nil
      exception(e, "p48a_run_ai_edge_batch")
      @p48a_ai_edge_ready = false
      assert("Phase48A AI Edge Coverage / Forced-Action Authority I completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase48a_p46d_run_live_batch_base)
      alias fs_phase48a_p46d_run_live_batch_base p46d_run_live_batch
    end
    def p46d_run_live_batch
      retained = fs_phase48a_p46d_run_live_batch_base
      ai_edge = p48a_run_ai_edge_batch
      ready = retained && ai_edge
      log("[PHASE48A_INTEGRATED] retained_phase47b1=#{retained} ai_edge_i=#{ai_edge} ready=#{ready}")
      return ready
    end

    unless method_defined?(:fs_phase48a_restore_pending_snapshot_base)
      alias fs_phase48a_restore_pending_snapshot_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase48a_restore_pending_snapshot_base
      if result
        @p48a_ai_edge_ran = false
        @p48a_ai_edge_ready = false
      end
      return result
    end
  end
end
end
