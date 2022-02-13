Function Test-MemoryUsage {
[cmdletbinding()]
Param()
 
$os = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
 
if ($pctFree -ge 45) {
$Status = "OK"
}
elseif ($pctFree -ge 15 ) {
$Status = "Warning"
}
else {
$Status = "Critical"
}
 
$os | Select @{Name = "Status";Expression = {$Status}},
@{Name = "PctFree"; Expression = {$pctFree}},
@{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
@{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}
 
}

Function Show-MemoryUsage {
 
[cmdletbinding()]
Param()
 
#get memory usage data
$data = Test-MemoryUsage
 
Switch ($data.Status) {
"OK" { $color = "Green" }
"Warning" { $color = "Yellow" }
"Critical" {$color = "Red" }
}
 
$title = @"
 
Memory Check
------------
"@
 
Write-Host $title -foregroundColor Cyan
 
$data | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Red
 
}
 
set-alias -Name smu -Value Show-MemoryUsage

$data = Test-MemoryUsage
Switch ($data.Status) {
 "OK" { $color = "Green" }
 "Warning" { $color = "Yellow" }
 "Critical" { $color = "Red" }
}

$data