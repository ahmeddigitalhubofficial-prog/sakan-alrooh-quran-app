Add-Type -AssemblyName System.Drawing
$srcPath = Resolve-Path "lib/assets/images/app_icon.png"
$src = [System.Drawing.Image]::FromFile($srcPath)

# 512x512
$b512 = New-Object System.Drawing.Bitmap 512, 512
$g512 = [System.Drawing.Graphics]::FromImage($b512)
$g512.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g512.DrawImage($src, 0, 0, 512, 512)
$b512.Save("store_assets/app_icon_512x512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g512.Dispose()
$b512.Dispose()

# 216x216
$b216 = New-Object System.Drawing.Bitmap 216, 216
$g216 = [System.Drawing.Graphics]::FromImage($b216)
$g216.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g216.DrawImage($src, 0, 0, 216, 216)
$b216.Save("store_assets/app_icon_216x216.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g216.Dispose()
$b216.Dispose()

$src.Dispose()
Write-Host "Done! Created 512x512 and 216x216 icons in store_assets!"
