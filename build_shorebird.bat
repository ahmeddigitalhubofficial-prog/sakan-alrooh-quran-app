@echo off
chcp 65001 >nul
title Sakan Al-Rooh - Shorebird and Flutter Turbo Build Hub
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\shorebird_build.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Process exited with code %errorlevel%.
    pause
)
