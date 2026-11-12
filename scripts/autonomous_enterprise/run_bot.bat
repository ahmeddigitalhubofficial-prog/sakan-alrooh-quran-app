@echo off
chcp 65001 > nul
title Sakan Al-Rooh Executive Office - Telegram Master Bot
echo ========================================================
echo    🚀 Sakan Al-Rooh Executive Automation Engine
echo    Autonomous Marketing Campaigns & Cloud Deployment
echo ========================================================
echo.

cd /d "%~dp0"

:loop
echo [%date% %time%] Starting Telegram Master Bot...
python master_telegram_bot.py
echo.
echo [WARNING] Bot process exited. Auto-restarting in 5 seconds...
timeout /t 5 /nobreak > nul
goto loop
