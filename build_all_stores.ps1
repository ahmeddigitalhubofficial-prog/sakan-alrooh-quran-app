# ============================================================
# 🚀 Build & Automation Script for All App Stores - Sakan Al-Rooh
# ============================================================

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   🚀 Preparing Release Packages for Sakan Al-Rooh   " -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Check project path and ensure dist directory exists
$ProjectRoot = Get-Location
$DistDir = Join-Path $ProjectRoot "dist"

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

# 2. Clean project and build packages
Write-Host "`n[1/3] 🧹 Cleaning previous build..." -ForegroundColor Green
flutter clean
flutter pub get

Write-Host "`n[2/3] 📦 Building Google Play package (App Bundle AAB with Google TARGET_STORE)..." -ForegroundColor Green
flutter build appbundle --release --dart-define=TARGET_STORE=google

Write-Host "`n[3/3] 📱 Building alternative stores package (Release APK with Huawei TARGET_STORE)..." -ForegroundColor Green
flutter build apk --release --dart-define=TARGET_STORE=huawei

# 3. Copy artifacts to organized dist directory
$AabSource = "build/app/outputs/bundle/release/app-release.aab"
$ApkSource = "build/app/outputs/flutter-apk/app-release.apk"

$AabDest = "$DistDir/GooglePlay_app-release.aab"
$ApkDest = "$DistDir/Stores_Huawei_Xiaomi_Samsung_app-release.apk"

if (Test-Path $AabSource) {
    Copy-Item $AabSource -Destination $AabDest -Force
    Write-Host "`n✅ Google Play AAB ready: $AabDest" -ForegroundColor Cyan
}

if (Test-Path $ApkSource) {
    Copy-Item $ApkSource -Destination $ApkDest -Force
    Write-Host "✅ Alternative stores APK (Huawei/Xiaomi/Samsung) ready: $ApkDest" -ForegroundColor Cyan
}

Write-Host "`n=================================================" -ForegroundColor Yellow
Write-Host "🎉 All packages generated successfully in dist/ !" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Yellow
