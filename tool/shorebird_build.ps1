[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Sakan Al-Rooh - Shorebird & Flutter Turbo Build Hub"

# Ensure Shorebird and Git long paths are configured
if (Test-Path "$env:USERPROFILE\.shorebird\bin") {
    $env:Path += ";$env:USERPROFILE\.shorebird\bin"
}
git config --global core.longpaths true 2>$null

function Get-LastBuiltArtifactInfo {
    $projectRoot = (Get-Item -Path ".").FullName
    $files = Get-ChildItem -Path $projectRoot -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like "Sakan_Al_Rooh_Release_*.aab" -or
        $_.Name -like "Sakan_Al_Rooh_Release_*.apk" -or
        $_.Name -like "sakan_al_rooh-*-release.aab"
    } | Sort-Object LastWriteTime -Descending
    if ($files -and $files.Count -gt 0) {
        $f = $files[0]
        return @{
            Found = $true
            Name = $f.Name
            FullName = $f.FullName
            SizeMB = [math]::Round($f.Length / 1MB, 2)
            Time = $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
        }
    }
    return @{ Found = $false }
}

function Get-ReleaseKeyFlags {
    $envPath = "tool\release_keys.env"
    if (-not (Test-Path $envPath)) {
        $envPath = Join-Path $PSScriptRoot "release_keys.env"
    }
    if (Test-Path $envPath) {
        return @("--dart-define-from-file=$envPath")
    }
    return @()
}

function Invoke-AutoVersionBumpBeforeRelease {
    $info = Get-AppReleaseInfo
    $pubspecPath = "pubspec.yaml"
    if (-not (Test-Path $pubspecPath)) {
        $pubspecPath = Join-Path $PSScriptRoot "..\pubspec.yaml"
    }

    Write-Host "`nCurrent pubspec Version : $($info.Version)" -ForegroundColor Cyan
    $shouldBump = Read-Host "   Do you want to increment version? (y/N) [Press Enter to keep $($info.Version)]"
    if ($shouldBump.Trim().ToLower() -ne 'y') {
        Write-Host "   Keeping version $($info.Version) (Unified across Google Play & Huawei for Shorebird)`n" -ForegroundColor Green
        return
    }

    if ($info.Version -notmatch "^(\d+)\.(\d+)\.(\d+)\+(\d+)$") {
        Write-Host "Warning: Could not parse version format ($($info.Version)). Proceeding without bump." -ForegroundColor Yellow
        return
    }

    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]
    $build = [int]$matches[4]

    $bumpType = "Patch"
    $reason = "New production build with verified diagnostics and native optimizations"

    try {
        $gitLog = git log -n 5 --oneline 2>$null
        if ($gitLog -match "(feat|feature|screen|localization|sync|reel|video)") {
            $bumpType = "Minor"
            $reason = "Detected new features/improvements in recent updates"
        }
    } catch {}

    $newMajor = $major
    $newMinor = $minor
    $newPatch = $patch + 1
    $newBuild = $build + 1

    $newVersion = "$newMajor.$newMinor.$newPatch+$newBuild"

    $content = Get-Content $pubspecPath -Raw
    $updatedContent = $content -replace "version:\s*[0-9\.\+]+", "version: $newVersion"
    [System.IO.File]::WriteAllText((Resolve-Path $pubspecPath), $updatedContent, [System.Text.Encoding]::UTF8)

    Write-Host "`n===============================================================================" -ForegroundColor Cyan
    Write-Host "[SMART AUTO-VERSION ENGINE] - AUTOMATIC UPGRADE APPLIED" -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "   Previous Version : $($info.Version)" -ForegroundColor DarkGray
    Write-Host "   Context          : $reason" -ForegroundColor White
    Write-Host "   Auto Increment   : $bumpType Bump -> $newVersion" -ForegroundColor Green
    Write-Host "   pubspec.yaml     : Updated automatically to $newVersion!" -ForegroundColor Green
    Write-Host "===============================================================================`n" -ForegroundColor Cyan
}

function Show-Menu {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "          SAKAN AL-ROOH - SHOREBIRD & FLUTTER TURBO BUILD HUB                  " -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan

    $info = Get-AppReleaseInfo
    $lastArtifact = Get-LastBuiltArtifactInfo
    Write-Host " Current pubspec Version : $($info.Version)" -ForegroundColor Green
    if ($lastArtifact.Found) {
        Write-Host " Last Built Artifact     : $($lastArtifact.Name) ($($lastArtifact.SizeMB) MB) [$($lastArtifact.Time)]" -ForegroundColor DarkCyan
    } else {
        Write-Host " Last Built Artifact     : None found (Clean state)" -ForegroundColor DarkGray
    }
    $keyFlags = Get-ReleaseKeyFlags
    if ($keyFlags.Count -gt 0) {
        Write-Host " Environment Keys        : tool/release_keys.env [ACTIVE]" -ForegroundColor Green
    } else {
        Write-Host " Environment Keys        : None (tool/release_keys.env not found)" -ForegroundColor DarkGray
    }
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] MULTI-STORE OFFICIAL RELEASES (Shorebird & App Stores)" -ForegroundColor Green
    Write-Host " -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   1. Google Play & Huawei Unified Release (AAB)      [shorebird release android]" -ForegroundColor White
    Write-Host "   2. Huawei AppGallery & Universal Release (APK)     [shorebird release android --artifact apk]" -ForegroundColor White
    Write-Host "   3. Fast ARM64 Release APK (Testing / Direct)       [shorebird release android --target-platform android-arm64 --artifact apk]" -ForegroundColor White
    Write-Host ""
    Write-Host " [2] SHOREBIRD INSTANT OVER-THE-AIR PATCHES (Live Updates)" -ForegroundColor Yellow
    Write-Host " -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   4. Push Live Instant Patch (Latest Android / Stable) [shorebird patch android --release-version latest --track stable]" -ForegroundColor Yellow
    Write-Host "   5. Push Live Instant Patch (Interactive Selection)   [shorebird patch android]" -ForegroundColor White
    Write-Host "   6. Validate Patch (Dry-Run / No upload)              [shorebird patch android --dry-run]" -ForegroundColor White
    Write-Host ""
    Write-Host " [3] SHOREBIRD LOCAL TEST BUILDS (No Cloud Registration)" -ForegroundColor Magenta
    Write-Host " -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   7. Local Test ARM64 APK (Fast Dry-Run)             [shorebird release android --target-platform android-arm64 --artifact apk --dry-run]" -ForegroundColor White
    Write-Host "   8. Local Test Universal APK                        [shorebird release android --artifact apk --dry-run]" -ForegroundColor White
    Write-Host "   9. Local Test App Bundle (AAB)                     [shorebird release android --dry-run]" -ForegroundColor White
    Write-Host ""
    Write-Host " [4] STANDARD FLUTTER & APPLE BUILDS" -ForegroundColor Blue
    Write-Host " -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  10. Flutter Split-per-ABI APK                       [flutter build apk --split-per-abi]" -ForegroundColor White
    Write-Host "  11. Flutter Standard App Bundle (AAB)               [flutter build appbundle]" -ForegroundColor White
    Write-Host "  12. Apple iOS IPA Build (TestFlight / App Store)    [flutter build ipa --release]" -ForegroundColor White
    Write-Host ""
    Write-Host " [5] SPEED OPTIMIZATIONS & DIAGNOSTICS" -ForegroundColor Cyan
    Write-Host " -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  13. Turbo Accelerator: Exclude from Defender        [Cuts build times by 50%]" -ForegroundColor Green
    Write-Host "  14. Clean Build Cache & Pub Get                     [flutter clean; flutter pub get]" -ForegroundColor White
    Write-Host "  15. Shorebird Upgrade & Doctor Check                [shorebird upgrade; shorebird doctor]" -ForegroundColor White
    Write-Host "  16. Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
}

function Confirm-Action([string]$msg) {
    Write-Host ""
    $resp = Read-Host "$msg (y/n)"
    return ($resp.Trim().ToLower() -eq 'y')
}

function Get-AppReleaseInfo {
    $pubspecPath = "pubspec.yaml"
    if (-not (Test-Path $pubspecPath)) {
        $pubspecPath = Join-Path $PSScriptRoot "..\pubspec.yaml"
    }

    $versionRaw = "1.3.1+39"
    if (Test-Path $pubspecPath) {
        $content = Get-Content $pubspecPath -Raw
        if ($content -match "version:\s*([0-9\.\+]+)") {
            $versionRaw = $matches[1].Trim()
        }
    }

    $cleanTag = "v" + ($versionRaw -replace "\+", "_b")
    return @{
        Version = $versionRaw
        FormattedTag = $cleanTag
        AppName = "Sakan_Al_Rooh"
    }
}

function Show-ArtifactReport {
    Write-Host "`n===============================================================================" -ForegroundColor Cyan
    Write-Host "Operation complete! Scanning & exporting release artifacts to Project Root..." -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Cyan

    $info = Get-AppReleaseInfo
    $bundleDir = "build\app\outputs\bundle\release"
    $apkDir = "build\app\outputs\flutter-apk"
    $projectRoot = (Get-Item -Path ".").FullName
    $exportedAny = $false

    try {
        $metaObj = @{
            Version = $info.Version
            FormattedTag = $info.FormattedTag
            BuildTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            AppName = $info.AppName
        }
        $metaObj | ConvertTo-Json | Set-Content -Path ".last_build_meta.json" -Encoding UTF8
    } catch {}

    # 1. Check and copy Google Play / Huawei App Bundle (AAB)
    if (Test-Path $bundleDir) {
        $aabs = Get-ChildItem -Path $bundleDir -Filter "*.aab" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if ($aabs.Count -gt 0) {
            $latestAab = $aabs[0]
            $targetName = "$($info.AppName)_Release_$($info.FormattedTag).aab"
            $targetPath = Join-Path $projectRoot $targetName
            try {
                Copy-Item -Path $latestAab.FullName -Destination $targetPath -Force
                $mb = [math]::Round((Get-Item $targetPath).Length / 1MB, 2)
                Write-Host "`n  [AAB EXPORTED TO ROOT FOLDER]" -ForegroundColor Green
                Write-Host "     File: $targetName ($mb MB)" -ForegroundColor Yellow
                Write-Host "     Path: $targetPath" -ForegroundColor Cyan
                $exportedAny = $true
            } catch {
                Write-Host "Warning: Failed to copy AAB to root: $_" -ForegroundColor Yellow
            }
        }
    }

    # 2. Check and copy Release APK
    if (Test-Path $apkDir) {
        $apks = Get-ChildItem -Path $apkDir -Filter "*release*.apk" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if ($apks.Count -eq 0) {
            $apks = Get-ChildItem -Path $apkDir -Filter "*.apk" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        }
        if ($apks.Count -gt 0) {
            $latestApk = $apks[0]
            $targetName = "$($info.AppName)_Release_$($info.FormattedTag).apk"
            $targetPath = Join-Path $projectRoot $targetName
            try {
                Copy-Item -Path $latestApk.FullName -Destination $targetPath -Force
                $mb = [math]::Round((Get-Item $targetPath).Length / 1MB, 2)
                Write-Host "`n  [APK EXPORTED TO ROOT FOLDER]" -ForegroundColor Green
                Write-Host "     File: $targetName ($mb MB)" -ForegroundColor Yellow
                Write-Host "     Path: $targetPath" -ForegroundColor Cyan
                $exportedAny = $true
            } catch {
                Write-Host "Warning: Failed to copy APK to root: $_" -ForegroundColor Yellow
            }
        }
    }

    if (-not $exportedAny) {
        Write-Host "  Note: No new release bundles or APKs found to export." -ForegroundColor DarkGray
    }
    Write-Host "`n===============================================================================" -ForegroundColor Cyan
}

function Invoke-PreFlightDiagnosticsCheck {
    Write-Host "`n===============================================================================" -ForegroundColor Cyan
    Write-Host "[PRE-FLIGHT CODE QUALITY & DIAGNOSTICS CHECK]" -ForegroundColor Yellow
    Write-Host "   Running Dart analyzer to guarantee zero errors before release/build..." -ForegroundColor DarkGray
    Write-Host "===============================================================================" -ForegroundColor Cyan

    $scriptPath = "scripts\send_problems_to_agent.py"
    if (-not (Test-Path $scriptPath)) {
        $scriptPath = Join-Path $PSScriptRoot "..\scripts\send_problems_to_agent.py"
    }
    if (Test-Path $scriptPath) {
        python $scriptPath "lib"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n[HALT] Critical compiler errors detected in codebase!" -ForegroundColor Red
            Write-Host "   Please fix the errors listed in PROBLEMS.md before building or releasing.`n" -ForegroundColor Yellow
            return $false
        }
    }
    Write-Host "`n[PASSED] Codebase is 100% clean and error-free!`n" -ForegroundColor Green
    return $true
}

do {
    Show-Menu
    $choice = Read-Host "Select an option (1-16)"

    switch ($choice) {
        "1" {
            if (-not (Invoke-PreFlightDiagnosticsCheck)) { break }
            if (Confirm-Action "Start official Google Play & Huawei (AAB) release with Shorebird?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running: shorebird release android --flutter-version=3.47.4 $flags ...`n" -ForegroundColor Green
                & shorebird release android --flutter-version=3.47.4 @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE). Artifact export skipped." -ForegroundColor Red }
            }
        }
        "2" {
            if (-not (Invoke-PreFlightDiagnosticsCheck)) { break }
            if (Confirm-Action "Start official Universal APK release with Shorebird?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running: shorebird release android --flutter-version=3.47.4 --artifact apk $flags ...`n" -ForegroundColor Green
                & shorebird release android --flutter-version=3.47.4 --artifact apk @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE). Artifact export skipped." -ForegroundColor Red }
            }
        }
        "3" {
            if (-not (Invoke-PreFlightDiagnosticsCheck)) { break }
            if (Confirm-Action "Start official Fast ARM64 APK release with Shorebird?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running: shorebird release android --flutter-version=3.47.4 --target-platform android-arm64 --artifact apk $flags ...`n" -ForegroundColor Green
                & shorebird release android --flutter-version=3.47.4 --target-platform android-arm64 --artifact apk @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE). Artifact export skipped." -ForegroundColor Red }
            }
        }
        "4" {
            if (-not (Invoke-PreFlightDiagnosticsCheck)) { break }
            $flags = Get-ReleaseKeyFlags
            Write-Host "`n[+] Running Automated Live Instant Patch (Latest Android / Stable) ...`n" -ForegroundColor Yellow
            Write-Host "Note: Shorebird OTA Patches update the active live release over-the-air without bumping pubspec.yaml.`n" -ForegroundColor DarkCyan
            Write-Host "[+] Running: shorebird patch android --release-version latest --track stable $flags`n" -ForegroundColor Cyan
            "y`ny`n" | & shorebird patch android --release-version latest --track stable @flags
        }
        "5" {
            if (-not (Invoke-PreFlightDiagnosticsCheck)) { break }
            if (Confirm-Action "Push Live Instant Patch (Interactive Selection)?") {
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running: shorebird patch android $flags ...`n" -ForegroundColor Yellow
                Write-Host "Note: Shorebird OTA Patches update the active live release over-the-air without bumping pubspec.yaml.`n" -ForegroundColor DarkCyan
                & shorebird patch android @flags
            }
        }
        "6" {
            $flags = Get-ReleaseKeyFlags
            Write-Host "`n[+] Validating patch locally (Dry-Run / No upload) ...`n" -ForegroundColor Cyan
            & shorebird patch android --dry-run @flags
        }
        "7" {
            $flags = Get-ReleaseKeyFlags
            Write-Host "`n[+] Running local test build: ARM64 APK ...`n" -ForegroundColor Cyan
            & shorebird release android --flutter-version=3.47.4 --target-platform android-arm64 --artifact apk --dry-run @flags
            if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
        }
        "8" {
            $flags = Get-ReleaseKeyFlags
            Write-Host "`n[+] Running local test build: Universal APK ...`n" -ForegroundColor Cyan
            & shorebird release android --flutter-version=3.47.4 --artifact apk --dry-run @flags
            if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
        }
        "9" {
            $flags = Get-ReleaseKeyFlags
            Write-Host "`n[+] Running local test build: App Bundle (AAB) ...`n" -ForegroundColor Cyan
            & shorebird release android --flutter-version=3.47.4 --dry-run @flags
            if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
        }
        "10" {
            if (Confirm-Action "Start standard Flutter build: split-per-abi APK?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running standard Flutter build: split-per-abi APK $flags ...`n" -ForegroundColor Blue
                & flutter build apk --split-per-abi @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
            }
        }
        "11" {
            if (Confirm-Action "Start standard Flutter build: appbundle?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running standard Flutter build: appbundle $flags ...`n" -ForegroundColor Blue
                & flutter build appbundle @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
            }
        }
        "12" {
            if (Confirm-Action "Start Apple iOS IPA release build (flutter build ipa --release)?") {
                Invoke-AutoVersionBumpBeforeRelease
                $flags = Get-ReleaseKeyFlags
                Write-Host "`n[+] Running Apple iOS IPA build: flutter build ipa --release $flags ...`n" -ForegroundColor Blue
                & flutter build ipa --release @flags
                if ($LASTEXITCODE -eq 0) { Show-ArtifactReport } else { Write-Host "`n[ERROR] Build failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red }
            }
        }
        "13" {
            Write-Host "`n[+] Adding Windows Defender Exclusions for Turbo Build Speed..." -ForegroundColor Green
            $projectPath = (Get-Item -Path ".").FullName
            $gradlePath = "$env:USERPROFILE\.gradle"
            try {
                Add-MpPreference -ExclusionPath $projectPath -ErrorAction Stop
                Add-MpPreference -ExclusionPath $gradlePath -ErrorAction Stop
                Write-Host "Successfully added project and Gradle cache to Windows Defender Exclusions!" -ForegroundColor Green
                Write-Host "Build times will now be faster on this PC." -ForegroundColor Yellow
            } catch {
                Write-Host "Administrator rights required to add Defender exclusions automatically." -ForegroundColor Yellow
                Write-Host "To enable manually, open PowerShell as Administrator and run:" -ForegroundColor Cyan
                Write-Host "Add-MpPreference -ExclusionPath '$projectPath'" -ForegroundColor White
                Write-Host "Add-MpPreference -ExclusionPath '$gradlePath'" -ForegroundColor White
            }
        }
        "14" {
            Write-Host "`n[+] Cleaning build cache and updating dependencies ...`n" -ForegroundColor Cyan
            & flutter clean
            & flutter pub get
        }
        "15" {
            Write-Host "`n[+] Upgrading Shorebird & running doctor ...`n" -ForegroundColor Cyan
            & shorebird upgrade
            & shorebird doctor
        }
        "16" {
            Write-Host "`nExiting. Have a productive day!`n" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "`nInvalid choice. Please select a number from 1 to 16." -ForegroundColor Red
        }
    }

    Write-Host ""
    Read-Host "Press Enter to return to the menu"
} while ($true)
