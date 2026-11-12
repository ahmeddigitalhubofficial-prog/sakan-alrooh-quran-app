@echo off
chcp 65001 >nul
echo ===================================================
echo     Shorebird Multi-Release Patch Deployment
echo     Deploying Patches to Active and Future Releases
echo ===================================================
echo.

echo [1/2] Deploying Patch to Live Google Play Release (1.1.5+33)...
(echo y & echo y & echo y) | shorebird patch android --release-version=1.1.5+33 --allow-native-diffs --allow-asset-diffs
echo.

echo [2/2] Deploying Patch to In-Review Release (1.1.6+34)...
(echo y & echo y & echo y) | shorebird patch android --release-version=1.1.6+34 --allow-native-diffs --allow-asset-diffs
echo.

echo ===================================================
echo     All Patches deployed successfully!
echo     Please open the app to download the latest patch.
echo ===================================================
pause
