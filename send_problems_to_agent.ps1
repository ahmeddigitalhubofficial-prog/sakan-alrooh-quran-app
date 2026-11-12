# ============================================================
# Antigravity Diagnostics Harvester (Send Problems to Agent)
# ============================================================

$target = if ($args.Count -gt 0) { $args[0] } else { "lib" }

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Antigravity Diagnostics Harvester: Scanning Problems..." -ForegroundColor Yellow
Write-Host "============================================================`n" -ForegroundColor Cyan

python scripts/send_problems_to_agent.py $target

