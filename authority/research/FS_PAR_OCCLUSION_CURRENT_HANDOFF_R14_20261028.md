# R14 CURRENT_HANDOFF | Godot Layer-first FS Pilot 2026-10-28

使用者不滿R13 PAR混入大量地板會蓋住角色，並要求實際操作Tiled或Godot。實機 Windows Godot4.7.2、AMD RX6700XT OpenGL GPU已運行，產生真正可編輯Godot 544x416場景`godot_project/LayeredPilot.tscn`（GROUND229、CONTACT4、PAR13、ACTOR1）。使用FS舊未封版候選透明素材，不用R12合成Master或以全格索引切前景。原4棵樹把接地32px單格分CONTACT、其餘在PAR，alpha source守恆。House/Market/Lamp/Fence等是單獨源Sprite2D在PAR，純地板Ground從場景結構隔離。
Godot真GPU匯出：`godot_project/exported/GODOT_FULL.png` (=FS完整Ground)、`GODOT_BASE.png`、`GODOT_PAR.png`、`GODOT_ACTOR_BACK.png`、`GODOT_ACTOR_FRONT.png`，RGBA544x416。PIL复合 BASE + PAR vs FULL RGB差異=0px；五個純地面32格PAR alpha都=0；221地板tile Nodes全在GROUND。Actor在Godot z=185/230前後景結果已輸出；暫時不宣稱VX實機或40x29大圖Art F。
原生Godot分層展示對照`R14_GODOT_REAL_RENDER_4PANEL.png`、`R14_REAL_ACTOR_FRONT_BACK.png`。Godot source材質本身舊tree sprites可能內含褐色泥土，仍要由素材生產階段分離乾淨Alpha，否則PAR會因不純元件漏出地面；這不能靠Godot自動修。對於R12高美術全圖，不能假設Godot自動逆切良好，本輪的驗證是「從頭分層放素材」。
Godot headless第一次卡於frame_post_draw；已停止僅R14測試的2進程，改GUI OpenGL render +定時frame後正常輸出。QA初次抽查選錯object佔據的地板格及PIL RGBA diff.getbbox受alpha=0干擾，已修正工具與重跑Gate。正式K4 Source/Map不動。
詳細`R14_RESEARCH_AND_AUTHORITY.md`、`R14_GODOT_EXPORT_GATE.json`、`SOURCE_ASSET_MANIFEST.json`、`SCENE_LAYER_MANIFEST.json`。
下一步：用AI/Pixelorama建立一致透視和pixel-crisp的房屋／樹／燈／欄杆**獨立透明**乾淨源素材→Godot作者場景先全部擺齊(40x29)、動態水、光影和collision→同一scene Ground Full+PAR+Light/Shadow+Loop輸出→RGSS2 VX native smoke→人眼Gate F。不可以回到R13 whole-tile alpha rescue。