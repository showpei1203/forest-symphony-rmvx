# Read-only PixelLab token test. No paid generation, no token logs.
$ErrorActionPreference = "Stop"
$path = Join-Path $PSScriptRoot "CHECK_PIXEL_LAB_AUTH_ONLY.py"
$secret = Read-Host "Paste PixelLab API Token (input hidden)" -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
try {
  $env:PIXELLAB_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  & python $path
} finally {
  Remove-Item Env:PIXELLAB_API_KEY -ErrorAction SilentlyContinue
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}
