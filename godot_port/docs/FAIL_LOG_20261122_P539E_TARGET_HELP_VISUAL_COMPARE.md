# Forest Symphony P539E｜來源選敵 Help 與 State Stack/Turn 真實失敗記錄
2026-11-22 Godot4.7.2，原VX E:唯讀。

R0 原 Roadmap 曾誤稱要做 #269數字滾動。實讀原 #269 Sprite_strNumbers lines589-656 後確認只有 src_rect 四位數字當次更新，完全沒有 easing。沒有硬加非來源的數字動畫，避免偏離原FS。

R1 真 #372 FSTargetPriority 因 state.note 不可驗證而擋選敵：P539E第一次原生功能測試雖通過Stack/Turn/Help metadata，但呼叫 _player_attack 後來源安全邏輯回不出目標，source_target_help.header={}。診斷發現測試用State30/31 note缺真正來源 target_priority 語義，#372依法 fail closed。修復synthetic測試資料 explicit target_priority:0，不破壞source fail-closed；改後Godot Win64 native及公開CI PASS。原實際500 alias複雜狀態造成的target priority仍需來源對照。

R2 private capture guard 一開始仍沿用上輪 P539D 目錄，不能寫入正確的G: FS_PRIVATE_P539E_TARGET_HELP_DETAIL_20261122，Godot在截圖前直接拒絕。修成獲授權目錄，仍絕不寫 E: VX 原來源。

R3 真GPU首輪畫面美術錯誤：雖然#462 Help已 render，544實際截圖中MENU/BATTLE tabs與Godot開發用標題佔上方，target名位於怪物臉旁、State detail壓在怪物身體，選敵按鈕位置混亂。不能因為GPU pixel delta>0 就宣稱畫面合格。修私人原圖source mode只隱藏非原作debug chrome並保留可點ScrollContainer；Header name移到頂部、State detail移到怪物下方、Button靠右避免原 #269左下角色肖像。真RX6700XT 544/1088再次各7張實機圖檢視，比較修正後已避開重疊。Before壞圖2張仍存在ZIP保存，沒有刪失敗證據。

R4 為確保顯示是真的戰鬥流程而非宣告式觀賞，新增真 Button.pressed 回歸：選敵前 ACT pending 0、HP不變；按合法目標後ACT pending只能有1、source Help結束、ATB wait reset，HP不能提早減少。Godot 4.7.2 owner native PASS，官方CI #44996910206 95/95 PASS。

保留 ART HOLD：#462 Capturerate原生公式/元素 icon/#381特殊extra_detail、原505 alias/11 boot-final DB、原 ACT F7傷害、全部角色動作/全MENU及 VX 1:1外觀。真GPU 14/14檔、失敗前2圖、來源SHA及Godotlogs在 owner-private Drive https://drive.google.com/file/d/1znQPh_XiT64zp6EmfW9GEk-4b2YJYzZb/view，SHA e1d855f9b0900b1aa88a9ceb569aa4d74a9ef2417b77f05f271ef436738dbce3，ZIP 6372214 bytes CRC PASS 30 entries。Phase1 SEAL NO。
