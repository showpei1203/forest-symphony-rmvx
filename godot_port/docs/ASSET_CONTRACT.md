# FS asset reuse / compatibility contract

Original (read-only) source: `FS project/Graphics/`. **Do not add source PNG to the public GitHub repo without verifying its license.** Binary assets go to the private Drive authority, then a cloud-side assembled runnable snapshot.

| Original asset | Godot target under `res://assets` | Use | Gate |
|---|---|---|---|
| `Graphics/Menu/Menu01..08.png`, `Battle01..05[a].png` | `ui/menu/` | MENU/BATTLE icon and state sprites | verify original dimensions, native screenshot, navigation |
| `Graphics/Menu/menu_喬伊/泰勒/米亞/艾卓/艾薇/薇娜.png` | `ui/menu/` | six portrait/status visuals | character ID mapping |
| `Graphics/System/MenuBack_*.png` | `ui/system/` | menu page backgrounds | correct screen crop/alignment |
| `Graphics/System/HUD_*.png`, `Btskin_*.png` | `ui/system/` | battle party HUD | HP/MP/OD overlay fidelity |
| `Graphics/System/atb_bar*.png`, `GaugeHP/MP/OD*.png` | `ui/system/` | gauges | frame source and fill semantics |
| `Graphics/System/battle_*windowbg.png` | `ui/system/` | command windows | actual 9-slice dimensions |
| `Graphics/Windows/window*.png` | `ui/windows/` | WindowSkin candidates | verify draw/padding/cursor |
| `Graphics/Characters/$001[_1.._3].png` etc. | `characters/` | Kaduki 4 sheets × 3×4, 32px cells | dimensions plus script mapping (NOT assumed for every sheet) |
| `Graphics/Battlers/*.png` | `battlers/` | enemy sprites | verify static/sprite sheet semantics |
| `Graphics/Animations/*.png` | `animations/` | VX animation image atlases | map animation database cells/frames |
| `Graphics/System/iconset.png` | `ui/system/` | VX 24px IconSet atlas | source atlas dimension and index map |
| `Audio/*` | `audio/` | BGM, SE, ME, BGS | file support and usage/license |

Unconverted input images remain frozen and source-hashed; use importer-side configuration to map Unicode names. No upscaling / recoloring. All UI gates require direct original-VX vs Godot same-state screenshot comparison. Current status **asset pointers planned, zero original binary assets added to this branch**.
