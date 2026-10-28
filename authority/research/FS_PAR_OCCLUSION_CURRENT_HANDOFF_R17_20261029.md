# CURRENT_HANDOFF_R17｜Forest Symphony｜2026-10-29

**R17 Stage1 已實作，A Pair Generation NOT_RUN；B Master-first / C Continuous-plate reconstruction各自真 Windows Godot4.7.2 GPU五種模式，10張原生544×416 PNG，雙方TECH PASS但美術/Mask ART HOLD。正式K4封版、R12–R16沒有任何覆寫。**

## 必先閱讀
1. `R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md`：禁止整格PAR/低細節平鋪、完整Ground、雙軌美術+Mask+Engine Gate、85分且任何硬Gate都不可FAIL。
2. `R17_RESEARCH_REPORT.md`：本輪B/C真正實測與A未跑理由。
3. `R17_NATIVE_GODOT_AND_ART_GATE.json`、`R17_STAGE1_EVIDENCE_GATE.json`與`R17_B_C_TRUE_GODOT_6_PANEL.png`。
4. `B_MASTER_FIRST/OBJECT_REGISTER.json`、`C_OBJECT_FIRST_CONTINUOUS_PLATE/OBJECT_REGISTER.json`。
5. 前一輪 `R16_MODEL_TOOL_EVAL_20261028/CURRENT_HANDOFF_R16.md`，SAM2+GrabCut樹/燈有2/3局部candidate accept，紅屋因地面誤收回退，模型藝術Gate HOLD。

## Authority input and actual outputs
- 來源：R12原本1280×928美術Master SHA256 `eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80`；抽固定區域 [155,175,544,416]，成品不是本輪重新AI生成，而是具有足夠美術細節的參考切片。不曾縮放。
- B：五個局部候選原位source mask (樹/燈R16+屋/雕像/花叢R12)、PAR53064 alpha、R12暫標Ground-only重疊0，但漏全場其他物件、三棵完整樹與欄杆等Benchmark完整規格未完成；仍ART HOLD。
- C：以同一美術Master Inpaint那5個物件作候選地面Plate（**不等於真的新生成連續純地面**），移除處65090px改變；同5透明物件放回後比R12藝術參考仍12026px差。Inpaint破壞美術，其他物件仍烘焙在Plate→C技術可行但此例ART FAIL/HOLD。
- A：沒有真正生成雙向透明AI圖，`A_PAIR_GENERATION/PAIR_GENERATION_CONTRACT.json`明確NOT_RUN，不能造假複製Master作A。
- 真 Godot B/C：`*/godot_project/project.godot` + `StreetCorner.tscn`可編輯、各輸出`exported/PLATE,PAR,FULL,ACTOR_BACK,ACTOR_FRONT.png`，分層同源RGB、PAR RGBA同作者檔、各自完整合成0px差，角色選在樹遮罩1024/1024像素區域，後方在原圖完全遮住、前方271pixels可見。B對原Master0差，C對原Master12026差。尚無原生VX Game.exe跑測（Art Gate先HOLD，不浪費native）。
- R17成品不是正式精靈村美術、沒有通過ground3同等藝術/使用者Gate F，不能Seal。

## 目前待做的真正下個命令
請在新對話以「接續R17 Stage2，讀CURRENT_HANDOFF_R17.md和R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md，不回滾任何SEALED」開始。
從真正全新高精度544×416街角**原生生成而不是R12裁片**開始，完成主屋、3種完整樹、路燈、欄杆、彎路、精緻小物。對照B/C，不得只用2種地板tile；有真RGBA獨立生圖器再測A。將新物件建立真 Alpha 逐項對照，保存來源圖與透明獨立PNG。Artist沒過先修美術，Mask沒過修Alpha；全部合格後再進RPG Maker VX原生Game.exe。

## 守衛
SHA formal K4 Scripts505: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`；
K4 Map003 SHA: `118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4`。
未改兩個正式檔。ART=HOLD，PAR semantic=HOLD，native VX=NOT_RUN，Final Seal=NO。