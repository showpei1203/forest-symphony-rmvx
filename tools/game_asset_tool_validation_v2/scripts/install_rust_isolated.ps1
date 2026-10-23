$ErrorActionPreference = 'Stop'
$ProgressPreference='SilentlyContinue'
$root='E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023'
$env:RUSTUP_HOME=Join-Path $root 'rust_portable\rustup'
$env:CARGO_HOME=Join-Path $root 'rust_portable\cargo'
$env:RUSTUP_IO_THREADS='2'
$installer=Join-Path $root 'rust_portable\rustup-init.exe'
New-Item -ItemType Directory -Force (Split-Path $installer) | Out-Null
if(!(Test-Path $installer)){Invoke-WebRequest -Uri 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe' -OutFile $installer -TimeoutSec 70}
Write-Output ('RUSTUP_INIT_BYTES '+(Get-Item $installer).Length)
Write-Output ('RUSTUP_SHA256 '+(Get-FileHash $installer -Algorithm SHA256).Hash)
& $installer -y --no-modify-path --profile minimal --default-toolchain stable-x86_64-pc-windows-msvc 2>&1
Write-Output ('RUSTUP_EXIT '+$LASTEXITCODE)
$binary=Join-Path $env:CARGO_HOME 'bin\cargo.exe'
if(Test-Path $binary){& $binary --version;Write-Output ('PORTABLE_CARGO='+$binary)}else{Write-Output 'PORTABLE_CARGO_NOT_FOUND'}
