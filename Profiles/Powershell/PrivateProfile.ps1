###########################################################################################
# Powershell Profile
# All Users, Current Host	
# Location: $PSHOME\Microsoft.PowerShell_profile.ps1
# C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1

function Info()
{
	Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -UseBasicParsing  -uri "http://ifconfig.me/ip").Content)
	$modpath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

	$HOSTS = "$env:SystemRoot\system32\drivers\etc\hosts";
	$Desktop = "$env:USERPROFILE\Desktop";
	$Documents = "$env:USERPROFILE\Documents";
	$TimestampServer = "http://timestamp.digicert.com";

	Write-Host 'Welcome to' "$env:computername" -ForegroundColor Green
	Write-Host "You are logged in as" "$env:username"
	Write-Host "Today:" (Get-Date)
}


$myipaddress=(Invoke-WebRequest -UseBasicParsing -uri "http://ifconfig.me/ip").Content
$administrator_tag=""
$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE)
{
	$administrator_tag=" Regular User Account"
}
Else
{
	$administrator_tag=" Running as ADMINISTRATOR"
}

# Personalize the console
$Host.UI.RawUI.WindowTitle = "Windows Powershell " + $administrator_tag + " ( " + $myipaddress + " ) ";


setx toolsroot d:\Scripts > $null
setx toolspath d:\Scripts > $null

Write-Host "Configuring Aliases..." -Foreground Green

Set-Alias -Name ex -Value 'exporer `pwd`' -Description "custom Set-Location command"
Set-Alias -Name dev -Value 'Set-Location $env:DevelopmentRoot' -Description "custom Set-Location command"
Set-Alias -Name code -Value 'Set-Location $env:DevelopmentRoot' -Description "custom Set-Location command"
Set-Alias -Name bcad -Value 'Set-Location $env:BodycadDevMain' -Description "custom Set-Location command"
Set-Alias -Name bcadgp -Value 'Set-Location $env:BodycadDevBranch' -Description "custom Set-Location command"
Set-Alias -Name logdir -Value 'Set-Location $env:APPDATA/../Local/Temp/Bodycad/' -Description "custom Set-Location command"
Set-Alias -Name scripts -Value 'Set-Location $env:ScriptsRoot' -Description "custom Set-Location command"
Set-Alias -Name tools -Value 'Set-Location $env:ToolsRoot' -Description "custom Set-Location command"
Set-Alias -Name radsrc -Value 'Set-Location $env:RadicalRoot' -Description "custom Set-Location command"
Set-Alias -Name goto1 -Value 'Set-Location $env:RadicalRoot' -Description "custom Set-Location command"
Set-Alias -Name home -Value 'Set-Location ~' -Description "custom Set-Location command"
Set-Alias -Name subl -Value "C:\Programs\sublime-text\subl.exe"

Write-Host "-----------------------------------------" -Foreground Magenta
Write-Host "powershell - current user: $env:USERNAME" -Foreground Magenta
date
Write-Host "useful env variables" -Foreground Magenta
Write-Host "   SystemScriptsPath = $env:SystemScriptsPath"
Write-Host "   ScreenshotFolder = $env:ScreenshotFolder"
Write-Host "   DevelopmentRoot = $env:DevelopmentRoot"
Write-Host "   BodycadDevMain = $env:BodycadDevMain"
Write-Host "   BodycadDevBranch = $env:BodycadDevBranch"
Write-Host "   ScriptsRoot = $env:ScriptsRoot"
Write-Host "   wwwroot = $env:wwwroot"
Write-Host "commands"  -Foreground Green
Write-Host "   dev, code = go in dev dir"
Write-Host "   bcad, bcadgp = bcad path"
Write-Host "   steps = go to steps designer"


Write-Host "PowerShell"($PSVersionTable.PSVersion.Major)"awaiting your commands."


Write-Host "Set location to ScriptsRoot..." -Foreground Red
Set-Location $env:ScriptsRoot