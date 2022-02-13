Write-Host "*******************" -Foreground Yellow
Write-Host "unlocking G: Drive!" -Foreground Red
Write-Host "*******************" -Foreground Yellow
$SecureString = ConvertTo-SecureString "TooManySecret23" -AsPlainText -Force
Unlock-BitLocker -MountPoint "G:" -Password $SecureString