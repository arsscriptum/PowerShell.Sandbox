. "P:\Scripts\PowerShell.Sandbox.Local\ScriptVersion\src\ScriptVersionApi.ps1"
$i = Initialize-ScriptVersionSystem
Write-Host -n -f DarkRed "[ScriptVersionSystem] " ; Write-Host -f DarkYellow "init   `t$i" 

$s = Get-ScriptVersionSystemStatus
Write-Host -n -f DarkRed "[ScriptVersionSystem] " ; Write-Host -f DarkYellow "status `t$s" 

cd "P:\Scripts\PowerShell.Sandbox.Local\ScriptVersion\testdata"
$p = New-ScriptVersionFile "P:\Scripts\PowerShell.Sandbox.Local\ScriptVersion\testdata\Script.ps1"

Write-Host -n -f DarkRed "[ScriptVersionSystem] " ; Write-Host -f DarkYellow "path `t$p" 

