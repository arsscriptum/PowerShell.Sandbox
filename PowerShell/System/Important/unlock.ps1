
$passwd = ConvertTo-SecureString 'MaMemoireEstMaCle7955' -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ('Administrateur', $passwd)
Start-Process powershell.exe -Credential $creds -ArgumentList '-noprofile -File c:\Windows\System32\unlockg.ps1'
Start-Sleep -Seconds 3
Set-Location G:
explorer g:\
