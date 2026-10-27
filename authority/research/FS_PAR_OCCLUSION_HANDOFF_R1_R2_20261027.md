# FS FULL MASTER + OCCLUSION PAR | Handoff R1/R2 | 2026-10-27
正式建議：改採使用者原方案「完整地圖 Master 作 Ground（Graphics/Parallaxes）；少量遮擋上層 ParX.png；通行由 ParaPassa；光影依 HK-UOM」，但以 32px格線選區＋局部透明遮罩，避免整格複製地面蓋住角色。
本輪 R1：17x13 SCENE21，3個遮擋候選mask25565px；54個32x32不透明格=55296px，非目標覆蓋29731px (53.77%)；actor腳(160,197) 整格遮271像素，同源alpha遮93，多遮178。
本輪 R2：單人腳點在樹前依 contact_y 方向切換模型，能在離線將固定alpha PAR仍遮住的93角色px修正。不是native VX，多NPC不能使用全域switch切換代替動態深度。
PAR從Master像素同源抽取已可輸出，但語義mask還混灌木，光影、完整PAR、VX腳點回歸、正式視覺均ART HOLD / NOT RUN。
檔案：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027；詳見FS_PAR_OCCLUSION_RESEARCH_R1_R2_20261027.md，且不得覆寫任何sealed/其他對話工程。
正式Ground-exclusive舊Authority必須取得使用者明確核准再調整；此研究只新增報告和隔離程式。