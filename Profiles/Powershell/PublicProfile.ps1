###########################################################################################
# Powershell Profile
# All Users, Current Host	
# Location: $PSHOME\Microsoft.PowerShell_profile.ps1
# C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1

# Create frequent commands
New-Alias -Name vsc -Value "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe";
New-Alias -Name subl -Value "C:\Programs\SublimeText3\sublime_text.exe";
New-Alias -Name edit -Value "C:\Programs\SublimeText3\sublime_text.exe";

$HOSTS = "$env:SystemRoot\system32\drivers\etc\hosts";
$Desktop = "$env:USERPROFILE\Desktop";
$Documents = "$env:USERPROFILE\Documents";
$TimestampServer = "http://timestamp.digicert.com";

function prompt {
    Write-Host ("PS " + $(Get-Location) +">") -NoNewLine `
     -ForegroundColor Cyan
    return " "
}
