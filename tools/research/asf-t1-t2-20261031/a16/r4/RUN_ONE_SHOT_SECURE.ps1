# Single PixelLab v3 generation on authorized Windows PC.
# Token typed locally, never pasted into chat, printed or saved.
$ErrorActionPreference = "Stop"
$root = "E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF"
$py = Join-Path $root "a16_r4_pixellab_pilot_v2.py"
$secure = Read-Host "PixelLab API Token (input hidden)" -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
  $env:PIXELLAB_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  & python $py --submit
  if ($LASTEXITCODE -ne 0) { throw "Submit runner exited with error" }
  & python $py --poll
} finally {
  Remove-Item Env:PIXELLAB_API_KEY -ErrorAction SilentlyContinue
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}
