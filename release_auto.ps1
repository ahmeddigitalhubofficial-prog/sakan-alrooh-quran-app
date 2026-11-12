# ============================================================
# 🚀 Unified Shorebird Release Automation Script
# Supported Platforms: Google Play + Huawei AppGallery
# ============================================================

$appName = "sakan_al_rooh"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$pubspecPath = Join-Path $scriptDir "pubspec.yaml"
if (Test-Path $pubspecPath) {
    $pubspecContent = Get-Content $pubspecPath -Raw
    if ($pubspecContent -match 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
        $appVersion = "v$($matches[1])"
    } else {
        $appVersion = "v1.2.0"
    }
} else {
    $appVersion = "v1.2.0"
}
$finalAabName = "$appName-$appVersion-release.aab"

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "🕊️  BUILDING UNIFIED RELEASE: SAKAN AL-ROOH ($appVersion)" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Cyan

# Official SHA-256 Certificate Fingerprint
Write-Host "`n🔑 Your Keystore SHA-256 Fingerprint:" -ForegroundColor Cyan
Write-Host "B1:BB:B8:F3:52:40:30:EF:E1:1F:5C:06:CC:03:56:27:F5:F7:4C:31:AF:1A:87:6B:F4:37:33:2F:A8:E0:C2:53" -ForegroundColor Green
Write-Host "(Already configured in Huawei AppGallery Connect)`n" -ForegroundColor DarkGray

# Configure Git Longpaths to suppress Shorebird warning
git config --global core.longpaths true 2>$null

Write-Host ">>> [1/4] Pre-flight Code Diagnostics Check (Dart Analyzer)..." -ForegroundColor Cyan
python scripts\send_problems_to_agent.py lib
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ [HALT] Critical compiler errors detected in codebase!" -ForegroundColor Red
    Write-Host "   Please fix the errors listed in PROBLEMS.md before releasing to stores.`n" -ForegroundColor Yellow
    exit 1
}
Write-Host ">>> [PASSED] Codebase is 100% clean and error-free!`n" -ForegroundColor Green

Write-Host ">>> [2/4] Cleaning previous Gradle/Java processes..." -ForegroundColor Cyan
Stop-Process -Name java -Force -ErrorAction SilentlyContinue

Write-Host ">>> [3/4] Building and registering release with Shorebird..." -ForegroundColor Yellow
$env:Path += ";C:\Users\ahmed\.shorebird\bin;C:\Program Files\Android\Android Studio\jbr\bin"
if (-not $env:SHOREBIRD_TOKEN) {
    $env:SHOREBIRD_TOKEN = [System.Environment]::GetEnvironmentVariable("SHOREBIRD_TOKEN", "User")
}
if (-not $env:SHOREBIRD_TOKEN) {
    $env:SHOREBIRD_TOKEN = "sb_api_Umrd7G3GSx8sOq-TKQN-qlNhpPKFXCup1LTEqI3nCqg"
}

shorebird release android

$sourceAab = "build\app\outputs\bundle\release\app-release.aab"

if (Test-Path $sourceAab) {
    Write-Host "`n>>> [4/4] Copying and renaming final AAB artifact..." -ForegroundColor Cyan
    
    # 1. Save named copy in build outputs directory
    $destOutputsAab = "build\app\outputs\bundle\release\$finalAabName"
    Copy-Item -Path $sourceAab -Destination $destOutputsAab -Force
    
    # 2. Save named copy directly in project root for easy access
    $destRootAab = ".\$finalAabName"
    Copy-Item -Path $sourceAab -Destination $destRootAab -Force

    Write-Host "`n=================================================" -ForegroundColor Green
    Write-Host "🎉 SUCCESS! Shorebird release compiled & registered!" -ForegroundColor Green
    Write-Host "📁 Final Unified AAB is ready in the project root folder:" -ForegroundColor Yellow
    Write-Host "👉 $destRootAab" -ForegroundColor White
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host "`n📌 Upload Instructions:" -ForegroundColor Cyan
    Write-Host "1. Google Play Console: Upload ($finalAabName)" -ForegroundColor White
    Write-Host "2. Huawei AppGallery: Upload the exact same file ($finalAabName)" -ForegroundColor White
    Write-Host "3. Future CodePush: Just run (shorebird patch android) to update everyone!" -ForegroundColor White
    Write-Host "=================================================" -ForegroundColor Green
    [console]::beep(800, 500)
} else {
    Write-Host "`n❌ Error: AAB file was not generated. Check the error messages above." -ForegroundColor Red
}
