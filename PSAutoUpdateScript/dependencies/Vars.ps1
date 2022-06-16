
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



# Gather System Info
#/======================================================================================/

Start-Sleep -Milliseconds 250 ; Write-Host -n " . " ; 


[string]$Script:RootPath                       = (Get-Location).Path
[string]$script:CurrentGitRev = git rev-parse --short HEAD
[string]$Script:ScriptFile = Join-Path $PSScriptRoot 'PSAutoUpdate.ps1'
[string]$Script:BackupFile = Join-Path $ENV:TEMP 'Backup.ps1'
[string]$Script:TmpScriptFile = Join-Path $ENV:TEMP 'PSAutoUpdate.ps1'
[string]$Script:VersionFile = Join-Path $Script:RootPath 'Version.nfo'
[string]$script:UserName = ((query user | findstr 'Active').split('>')[1]).split('')[0]
[string]$script:User = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
[string]$script:HostName = $ENV:COMPUTERNAME
[string]$script:IsAdmin = $False

$script:IPv4 = (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 1
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
 $script:IsAdmin = $True
}