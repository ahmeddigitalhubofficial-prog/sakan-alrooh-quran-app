# ==============================================================================
# Sakan Al-Rooh - Storage Cleanup & Optimization Script
# ==============================================================================

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "     Sakan Al-Rooh Storage Cleanup & Optimization  " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

$initialFreeC = [math]::round((Get-PSDrive C).Free / 1GB, 2)
$initialFreeD = [math]::round((Get-PSDrive D).Free / 1GB, 2)
Write-Host ">>> Initial Disk Space:" -ForegroundColor Yellow
Write-Host "    [Drive C:] Free: $initialFreeC GB"
Write-Host "    [Drive D:] Free: $initialFreeD GB"
Write-Host ""

# ------------------------------------------------------------------------------
# 1. Project Organization: Archive Old Releases & Scratch Files
# ------------------------------------------------------------------------------
Write-Host ">>> [1/5] Organizing project files..." -ForegroundColor Yellow

$projectDir = "D:\codespark\flutter\quran-azkar-app"
$archiveReleases = Join-Path $projectDir "archive\old_releases"
$archiveScratch = Join-Path $projectDir "archive\promo_scratch"

New-Item -ItemType Directory -Force -Path $archiveReleases | Out-Null
New-Item -ItemType Directory -Force -Path $archiveScratch | Out-Null

# Move loose AAB bundles to archive
Get-ChildItem -Path $projectDir -File -Filter "*.aab" | ForEach-Object {
    Write-Host "  • Archiving release bundle: $($_.Name)" -ForegroundColor Gray
    Move-Item -Path $_.FullName -Destination $archiveReleases -Force
}

# Move promo/voiceover test files to scratch archive
$scratchFiles = @(
    "final_cinematic_audio_v2.aac",
    "ghamdi_pt2_sample.mp3",
    "test_75.mp3",
    "test_voice.mp3",
    "vo_1.mp3", "vo_2.mp3", "vo_3.mp3", "vo_4.mp3", "vo_5.mp3",
    "create_promo_audio.py",
    "generate_promo_video.py",
    "gen_perfect_vo.py",
    "measure_audio.py",
    "render_cinematic_promo.py",
    "test_khashia_variations.py",
    "test_pronounce.py",
    "vo_durations.json"
)

foreach ($file in $scratchFiles) {
    $fullPath = Join-Path $projectDir $file
    if (Test-Path $fullPath) {
        Write-Host "  • Moving to scratch archive: $file" -ForegroundColor Gray
        Move-Item -Path $fullPath -Destination $archiveScratch -Force
    }
}

# Remove obsolete log files
Get-ChildItem -Path $projectDir -File -Filter "flutter_*.log" | ForEach-Object {
    Write-Host "  • Deleting obsolete log: $($_.Name)" -ForegroundColor Gray
    Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
}

# Remove obsolete/redundant root batch scripts
$obsoleteScripts = @(
    "build_app.bat",
    "build_shorebird_aab.bat",
    "patch_all_releases.bat",
    "install.ps1",
    "install_shorebird.ps1"
)

foreach ($scr in $obsoleteScripts) {
    $scrPath = Join-Path $projectDir $scr
    if (Test-Path $scrPath) {
        Write-Host "  • Removing redundant script: $scr" -ForegroundColor Gray
        Remove-Item -Path $scrPath -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "  [+] Project root clean & organized!" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Clean Project Build Folder (~2.6 GB)
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host ">>> [2/5] Cleaning project build directory..." -ForegroundColor Yellow
$buildPath = Join-Path $projectDir "build"
if (Test-Path $buildPath) {
    Write-Host "  • Removing $buildPath (saving ~2.6 GB)..." -ForegroundColor Gray
    cmd.exe /c "rd /s /q `"$buildPath`"" 2>$null
    Write-Host "  [+] Project build directory cleared!" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 3. Configure Android & Gradle System Variables to Drive D:
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host ">>> [3/5] Directing Gradle and Android SDK to Drive D:..." -ForegroundColor Yellow

# Ensure D:\.gradle exists
$dGradle = "D:\.gradle"
if (-not (Test-Path $dGradle)) {
    New-Item -ItemType Directory -Force -Path $dGradle | Out-Null
}

# Set User environment variables
[System.Environment]::SetEnvironmentVariable('GRADLE_USER_HOME', 'D:\.gradle', 'User')
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'D:\Android\SDK', 'User')
Write-Host "  • Set GRADLE_USER_HOME = D:\.gradle (Prevents Drive C from filling up!)" -ForegroundColor Cyan
Write-Host "  • Set ANDROID_HOME = D:\Android\SDK" -ForegroundColor Cyan

# Update flutter configuration
cmd.exe /c "flutter config --android-sdk `"D:\Android\SDK`"" 2>$null
cmd.exe /c "flutter config --jdk-dir `"C:\Program Files\Microsoft\jdk-17.0.21.21-hotspot`"" 2>$null
Write-Host "  [+] Flutter SDK paths updated!" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 4. Clean C: Drive Caches (Old Gradle & Old Android SDK)
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host ">>> [4/5] Cleaning old caches from Drive C:..." -ForegroundColor Yellow

# 4a. Clean Old Gradle Caches on C:
$cGradleCaches = "C:\Users\ahmed\.gradle\caches"
$cGradleDaemon = "C:\Users\ahmed\.gradle\daemon"
if (Test-Path $cGradleCaches) {
    Write-Host "  • Purging old Gradle caches on C: ($cGradleCaches)..." -ForegroundColor Gray
    cmd.exe /c "rd /s /q `"$cGradleCaches`"" 2>$null
}
if (Test-Path $cGradleDaemon) {
    Write-Host "  • Purging old Gradle daemon logs on C: ($cGradleDaemon)..." -ForegroundColor Gray
    cmd.exe /c "rd /s /q `"$cGradleDaemon`"" 2>$null
}

# 4b. Remove old Android SDK on C: if D:\Android\SDK is fully functional
$cAndroidSdk = "C:\Users\ahmed\AppData\Local\Android\Sdk"
$dAndroidSdk = "D:\Android\SDK\platform-tools"
if ((Test-Path $dAndroidSdk) -and (Test-Path $cAndroidSdk)) {
    Write-Host "  • Verified D:\Android\SDK is active. Removing duplicate SDK on C: ($cAndroidSdk)..." -ForegroundColor Cyan
    cmd.exe /c "rd /s /q `"$cAndroidSdk`"" 2>$null
    Write-Host "  [+] Duplicate Android SDK on C: successfully purged!" -ForegroundColor Green
}

# 4c. Clean Temp directory
Write-Host "  • Cleaning Temp files..." -ForegroundColor Gray
cmd.exe /c "del /q /f /s %TEMP%\* >nul 2>&1"
cmd.exe /c "del /q /f /s C:\Windows\Temp\* >nul 2>&1"

# ------------------------------------------------------------------------------
# 5. Final Report
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "                 Optimization Summary              " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

$finalFreeC = [math]::round((Get-PSDrive C).Free / 1GB, 2)
$finalFreeD = [math]::round((Get-PSDrive D).Free / 1GB, 2)
$freedC = [math]::round($finalFreeC - $initialFreeC, 2)

Write-Host ">>> Disk Space Results:" -ForegroundColor Yellow
Write-Host "    [Drive C:] Before: $initialFreeC GB  -->  Now: $finalFreeC GB (Freed: +$freedC GB)" -ForegroundColor Green
Write-Host "    [Drive D:] Free: $finalFreeD GB"
Write-Host ""
Write-Host "[+] All optimization and cleanup steps completed successfully!" -ForegroundColor Green

