@echo off
setlocal
chcp 65001 >nul
title PixelLab safe token diagnostic - no generation
cd /d "%~dp0"
echo PixelLab AUTH ONLY diagnostic
echo Only GET /v2/balance; NO image-generation request.
echo Token is hidden and will not be saved.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CHECK_PIXEL_LAB_AUTH_ONLY.ps1"
echo.
echo Copy only RESULT and NEXT text, NEVER paste your token.
pause
endlocal
