##===----------------------------------------------------------------------===
##  Test-Screenshot.ps1 - PowerShell script
##
##  The purpose of this script is to test our functionalities
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
# Includes
. (Join-Path $env:PowerShellScriptsRoot "\System\New-ScreenShot.ps1")

$screenshot_path += 'e:\Tmp\'
$screenshot_files = @()
$screenshot_files += 'Screenshot.jpg'
$screenshot_files += 'Screenshot.bmp'
$screenshot_files += 'Screenshot.jpeg'


$screenshot_files.ForEach({
    $file=Join-Path $screenshot_path $_
    Write-Host "Taking screenshot: " $file -Foreground Cyan
    New-ScreenShot -FilePath $file
})
