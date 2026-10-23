# 森林交響曲與共用像素工具｜v3 實機驗證與操作指南
日期：2026-10-24｜設備：DESKTOP-90VT437，Windows/RX 6700 XT
**狀態：V3_EXTENDED_TOOL_SMOKE_PASS_WITH_LAIGTER_WARNINGS_FORMAL_ART_PENDING**。
本次全部在 `E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024`，為工具測試，不更改 K4/N5 SEALED Runtime、Map900 或 Rich Pilot。
## 先讀地圖專案的暫停檢查點
https://docs.google.com/document/d/1Fwwert2ILfA2MLWdgQQJXMo9Sqhg-20Z5bjqWcYrdBY/edit
170筆來源素材/資料夾 exact Drive IDs：https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
舊版11/11工具測試：`E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023`，仍保留原始 log。
## 一鍵回歸
在原 Windows：雙擊 `RUN_TOOL_V3.cmd` 或命令 `python scripts/run_v3_all.py`。
會從 B0 OWNED source 重新複製tree/rock/sign，產生4影格岩石動畫，接著測 Rust SpriteNormals / Laigter / Pixelorama PXO / LibreSprite真四影格ASE / Godot真正OpenGL渲染，最後驗證尺寸、Alpha、RGBA、Sprite區域差異與1px負向案例，輸出reports/V3_ALL_TOOL_GATES.json及全部LOG。
2026-10-24 本輪**9個獨立自動化步驟，9/9 PASS，8.5秒**。此數字不包含既有v2完整11/11（已另外實際重跑43秒，PASS）。T09–T13是五組測試，每組可能包含多個子命令/輸出。
工具位置：E:\GameAssetToolLab_20261023\tools\；Godot：E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe。所有權限未明素材禁止進Public GitHub或發行。
## T09 Sprite Fusion Sprite Normals MIT / Rust CLI
來源：B0 自行產生樹64×96、岩石32×24、路牌32×40及32×32的4幀像素動圖，無他人來源圖。
Rust CLI binary位於tools/SpriteNormalsSource/.../target/release/spritefusion-sprite-normals.exe。
範例：`spritefusion-sprite-normals.exe INPUT.png -o OUTPUT_n.png --normal-format opengl --force`；
動畫：`spritefusion-sprite-normals.exe rock_animation_4x32.png --output-dir OUT --frame-size 32x32 --normal-format opengl --force`
4 frame分別生成→合成 vs整張生成：將完全透明Alpha=0像素的RGB正規化後相同。4-frame的Alpha與原sheet相同；tree/rock/sign個別Alpha與尺寸保持。刻意把第3格source向右偏1px，Normal結果偵測**519 changed pixels**。報告reports/T09_SPRITENORMALS_B0.json。Normal不是 Ground/PAR語義分層。
## T10 Laigter 1.14 GPL-3.0
命令：`laigter.exe --no-gui --diffuse INPUT_DIR --normal --specular --occlusion --parallax --location OUT_DIR`
樹/岩石/路牌/4格Sheet，四種材質共**16張PNG**。原生16/16 Alpha**全部不等**於來源，必須以Pillow複製SOURCE Alpha再存。修復後**16/16 Alpha exact**；法線4/4具RGB變化。樹木與路牌Parallax材質只有1種可見RGB（平坦），記作**品質WARN**，不當作形狀有立體起伏。初始過嚴的「16張都需RGB變化」FAIL另外保留在reports/T10_LAIGTER_B0_INITIAL_FAIL.json，不掩蓋。
報告reports/T10_LAIGTER_B0.json。此工具產生的parallax material與地圖Ground/PAR分層是不同概念。
## T11 Pixelorama 1.2.3
已用本套B0自產rock (32×24)輸入6個原生PXO cels，保留全部幀格獨立色彩識別，headless匯出384×64 spritesheet，**六個標記6/6相符，6個幀格內容皆不同**。CLI形式：
`Pixelorama.exe --headless --quit -- --spritesheet --export b0_rock_6frames.pxo`
本地 inputs/animated_no_effects_private_test_template.pxo 是上輪官方範例的**已移除Shader效果**私有腳手架，script在內部替換frame layer_1的rawRGBA；不可把它說成從零自動產製的完整多Layer動畫。原含Shader Layer Effects專案在headless曾0xC0000005 crash，尚未修復，詳見v2。輸出正常並不代表Shader可批量保真。
報告reports/T11_PIXELORAMA_B0.json。
## T12 LibreSprite 1.3
根據ASE開放規格，用**四張B0 rock原生32×32**建立真四幀`inputs/b0_rock_4frames.aseprite`，幀長[100,120,140,160]毫秒。LibreSprite原生CLI：
`libresprite.exe --batch --sheet outputs/libresprite/b0_rock_4frames.png --data outputs/libresprite/b0_rock_4frames.json --format json-array --sheet-type horizontal inputs/b0_rock_4frames.aseprite`
實際產出128×32 sheet：原始四個frame逐格RGBA bytes **4/4完全相同**；metadata JSON中的frame duration也**100/120/140/160**完全正確。這次是原生動畫專案匯出，不再僅是Pillow裁切PNG。並未測複雜tag/layer合成及Aseprite其餘全部格式。
報告reports/T12_LIBRESPRITE_ANIMATION.json。
## T13 Godot 4.7.2 真GPU渲染
同一B0樹64×96＋T09 SpriteNormals Normal、T10修正Alpha的Laigter Normal，放入Godot CanvasTexture＋PointLight2D＋nearest filter。Radeon RX6700XT/OpenGL 3.3真實GPU，**非headless**輸出五張160×160 SubViewport PNG（CLI左/右、Laigter左/右、Flat左）。核對原圖及兩normal map Alpha相同。
樹木Sprite ROI像素差異：CLI左右2627、Laigter左右2622、CLI vs flat 2288、Laigter vs flat 2288、CLI vs Laigter左1247；Sprite ROI以外每組**0像素差異**。故兩種normal輸入均真正生效，結果不同，但不能推論哪個比較漂亮。
圖：godot/B0NormalCrossTool/captures/T13_CROSS_TOOL_CONTACT.png 及五張截圖；報告reports/T13_CROSS_TOOL_GODOT_GPU.json。
## 已通過之外的限制與下一批測試目標
- 所有Material Normal/Parallax不會自動生成地圖Ground/PAR、遮擋、Collision、HeightRegion；仍需同一Scene Blueprint/Manifest才可通過地圖門檻。
- Pixelorama保留效果時需GUI或可靠效果烘焙策略；可以另開T14風格效果保真/批次失敗基準。
- T15以正式LPC、SBS、PMD或B0動畫原始合法Source測多方向幀格與JSON frame-duration、SpriteNormals/Laigter偏移，檢查角色透明邊與動圖連續性。
- T16分割/遮罩開源工具（SAM2, OpenCV GrabCut, rembg等）須有source-first幾何與無損分層標註基準，不可把AI分割遮罩直接當原始被遮擋底圖；未實測前記 NOT RUN。
- 全部屬私人工作目錄，工具本身License與輸入藝術來源License分別判定，現在不是整體遊戲FORMAL PASS。
