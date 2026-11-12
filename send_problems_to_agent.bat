@echo off
setlocal
echo ============================================================
echo  Antigravity Diagnostics Harvester (Send Problems to Agent)
echo ============================================================
echo.

python scripts\send_problems_to_agent.py %*

echo.
echo Process finished.

