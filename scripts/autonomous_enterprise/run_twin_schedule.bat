@echo off
chcp 65001 >nul
echo ========================================================
echo   Sakan Al-Rooh - Twin Schedule Engine (YouTube + Buffer)
echo ========================================================
echo.
cd /d "%~dp0"
python twin_sync_engine.py
echo.
echo ========================================================
echo   Twin Schedule Execution Finished.
echo ========================================================
pause

