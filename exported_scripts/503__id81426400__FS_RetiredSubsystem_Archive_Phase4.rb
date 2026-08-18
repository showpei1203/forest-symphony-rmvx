#==============================================================================
# ■ FS_RetiredSubsystem_Archive_Phase4
#------------------------------------------------------------------------------
# Forest Symphony Script Cleanup Phase 4
#
# 用途：記錄本階段自正式 Runtime 退休的 Legacy 子系統。
# 完整原始碼不重複塞回 Scripts.rvdata，改保存在外部 FS_SCRIPT_ARCHIVE_PHASE4.zip。
# 這樣保留可追溯性與說明，同時真正降低 Runtime 腳本負擔。
#
# 退休原因：Dismantle / 解體屋在目前 Data、Map、Common Event 與其他
# Runtime Script 中均找不到實際入口；原本唯一外部引用是非破壞式驗證器。
#============================================================================== 

# ORIGINAL PAGE 137 | 解体屋
#   SHA-256: 55bdc7801e29f81d32777ab55d0ed1c76e072b198d1740ccd5e1d44774440828
#   BYTES: 3129
# ORIGINAL PAGE 138 | 解体屋[ウィンドウ]   
#   SHA-256: 019769858e4997e26e651b9c94ffe286bf58c91395ac444dffafd4e105bbdf5e
#   BYTES: 16040
# ORIGINAL PAGE 139 | 解体屋[シーン] 
#   SHA-256: 04717619a220c4a2269bfba6e5483f72fa4772206a21692e69d92312c04f014c
#   BYTES: 4872

# 專用素材：無。Sword2 SE 為共用素材，鍛冶屋與 Data 仍在使用，禁止刪除。
