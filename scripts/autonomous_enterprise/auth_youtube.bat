@echo off
chcp 65001 >nul
echo ========================================================
echo   YouTube Channel Authentication - Sakan Al-Rooh
echo ========================================================
echo.
cd /d "%~dp0"
python auth_youtube.py
echo.
pause
