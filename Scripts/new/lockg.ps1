Write-Host "********************************" -Foreground Yellow
Write-Host "Locking and Unmounting G: Drive!" -Foreground Red
Write-Host "********************************" -Foreground Yellow
Lock-BitLocker -MountPoint "g:" -ForceDismount