# Run the one-off Pixellab test on the authorized computer.
# Secret is not written into files or echoed. This script has no retries.
$ErrorActionPreference = "Stop"
$secure = Read-Host "PixelLab API token (hidden input)" -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $env:PIXELLAB_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    python "E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF\a16_r4_pixellab_pilot.py" --run
} finally {
    Remove-Item Env:PIXELLAB_API_KEY -ErrorAction SilentlyContinue
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}
