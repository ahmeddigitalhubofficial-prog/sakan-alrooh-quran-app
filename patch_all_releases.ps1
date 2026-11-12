# Shorebird Interactive Release Patching Script
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$env:Path += ";C:\Users\ahmed\.shorebird\bin"
if (-not $env:SHOREBIRD_TOKEN) {
    $env:SHOREBIRD_TOKEN = [System.Environment]::GetEnvironmentVariable("SHOREBIRD_TOKEN", "User")
}
if (-not $env:SHOREBIRD_TOKEN) {
    $env:SHOREBIRD_TOKEN = "sb_api_Umrd7G3GSx8sOq-TKQN-qlNhpPKFXCup1LTEqI3nCqg"
}

function Read-HostWithTimeout {
    param(
        [string]$Prompt,
        [string]$Default = "0",
        [int]$TimeoutSeconds = 10
    )

    try {
        $startTime = [DateTime]::Now
        $inputString = ""

        while ($true) {
            $elapsed = ([DateTime]::Now - $startTime).TotalSeconds
            $remaining = [math]::Max(0, [int]($TimeoutSeconds - $elapsed))

            Write-Host -NoNewline "`r$Prompt (auto-select [$Default] in ${remaining}s): $inputString "

            if ($elapsed -ge $TimeoutSeconds) {
                Write-Host "`n[+] Timeout reached. Auto-selected default: [$Default]" -ForegroundColor Cyan
                return $Default
            }

            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::Enter) {
                    Write-Host ""
                    if ([string]::IsNullOrWhiteSpace($inputString)) {
                        return $Default
                    }
                    return $inputString
                } elseif ($key.Key -eq [ConsoleKey]::Backspace) {
                    if ($inputString.Length -gt 0) {
                        $inputString = $inputString.Substring(0, $inputString.Length - 1)
                        Write-Host -NoNewline "`r$(' ' * 85)"
                    }
                } else {
                    $inputString += $key.KeyChar
                }
            }
            Start-Sleep -Milliseconds 150
        }
    } catch {
        # Fallback if KeyAvailable is unsupported in current console host
        Write-Host "`n$Prompt [default: $Default]: " -NoNewline
        $ans = Read-Host
        if ([string]::IsNullOrWhiteSpace($ans)) { return $Default }
        return $ans
    }
}

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "       Shorebird Multi-Release Patch Manager       " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ">>> Fetching registered releases from Shorebird..." -ForegroundColor Yellow

$releasesRaw = shorebird releases list
$releases = $releasesRaw | Select-String -Pattern '\d+\.\d+\.\d+(\+\d+)?' | ForEach-Object { $_.Matches.Value } | Select-Object -Unique

if (-not $releases) {
    Write-Host "[!] No registered releases found in Shorebird." -ForegroundColor Red
    exit
}

Write-Host "`nSelect target release(s) to patch:" -ForegroundColor White
Write-Host " [1] $($releases[0]) (Latest / Default)" -ForegroundColor Green

for ($i = 1; $i -lt $releases.Count; $i++) {
    $num = $i + 1
    Write-Host " [$num] $($releases[$i])" -ForegroundColor Cyan
}

Write-Host " [0] Deploy patch to ALL releases" -ForegroundColor Magenta
Write-Host "---------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Tip: Press Enter for [1] (latest release), or type 0 for all releases" -ForegroundColor Gray
Write-Host "---------------------------------------------------" -ForegroundColor DarkGray

# 10 seconds timeout for version selection (default 1 = Latest Release)
$choice = Read-HostWithTimeout -Prompt "Enter choice" -Default "1" -TimeoutSeconds 10

$selectedVersions = @()

if ($choice.Trim() -eq "0") {
    $selectedVersions = $releases
} else {
    $indices = $choice -split '[, ]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
    foreach ($idx in $indices) {
        if ($idx -eq 0) {
            $selectedVersions = $releases
            break
        }
        $realIdx = $idx - 1
        if ($realIdx -ge 0 -and $realIdx -lt $releases.Count) {
            $selectedVersions += $releases[$realIdx]
        }
    }
    $selectedVersions = $selectedVersions | Select-Object -Unique
}

if (-not $selectedVersions -or $selectedVersions.Count -eq 0) {
    Write-Host "[!] Invalid choice. Defaulting to latest release: $($releases[0])" -ForegroundColor Yellow
    $selectedVersions = @($releases[0])
}

Write-Host "`n[+] Patches will be deployed to the following releases:" -ForegroundColor Green
foreach ($v in $selectedVersions) {
    Write-Host "   • $v" -ForegroundColor White
}
Write-Host ""

# Confirmation with 5s timeout, defaulting to Y
$confirm = Read-HostWithTimeout -Prompt "Proceed with deployment? [Y/n]" -Default "Y" -TimeoutSeconds 5
if ($confirm.Trim().ToUpper() -ne "Y") {
    Write-Host "[!] Deployment cancelled by user." -ForegroundColor Yellow
    exit
}

Write-Host "`n>>> Starting automated deployment..." -ForegroundColor Green

$successful = @()
$failed = @()

foreach ($ver in $selectedVersions) {
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "--> Deploying patch for release version: $ver" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    # Automatically reply y to any confirmation prompt from shorebird
    "y`ny`ny`n" | shorebird patch android --release-version=$ver --allow-native-diffs --allow-asset-diffs
    if ($LASTEXITCODE -eq 0) {
        $successful += $ver
        Write-Host "[✓] Successfully patched $ver" -ForegroundColor Green
    } else {
        $failed += $ver
        Write-Host "[✗] Failed to patch $ver (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    }
}

Write-Host "`n===================================================" -ForegroundColor Cyan
if ($failed.Count -eq 0) {
    Write-Host "[SUCCESS] All selected patches deployed successfully to Shorebird!" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Deployment finished with errors!" -ForegroundColor Red
    if ($successful.Count -gt 0) {
        Write-Host "Successful: $($successful -join ', ')" -ForegroundColor Green
    }
    Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Red
}
Write-Host "===================================================" -ForegroundColor Cyan
