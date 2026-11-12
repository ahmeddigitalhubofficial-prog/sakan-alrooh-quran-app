@echo off
chcp 65001 >nul
echo ========================================================
echo   YouTube Connection Check (Read-Only - No Publishing)
echo ========================================================
echo.
cd /d "%~dp0"
python specialists\youtube_publisher.py --test-connection
echo.
pause
