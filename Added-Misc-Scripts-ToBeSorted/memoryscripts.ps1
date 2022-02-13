


$ScriptsRoot = $env:ScriptsRoot
if(!(Test-Path $ScriptsRoot))
{
    exit -1
}


$EmailScript = Join-Path $env:ScriptsRoot 'PowerShell\Send-Email-Func.ps1'
$GuiScript = Join-Path $env:ScriptsRoot 'PowerShell\GUI\New-WPFMessageBox.ps1'
$ProcessScript = Join-Path $env:ScriptsRoot 'PowerShell\Processes\Invoke-Process.ps1'

$MemUsageScript = Join-Path $env:ScriptsRoot 'Show-MemoryUsage'

. $GuiScript
. $ProcessScript
. $EmailScript

Clear-Host


$os = Get-Ciminstance Win32_OperatingSystem

$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

$os | Select @{Name = "PctFree"; Expression = {$pctFree}},
@{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
@{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}