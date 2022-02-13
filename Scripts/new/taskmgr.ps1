
$passwd = ConvertTo-SecureString 'MaMemoireEstMaCle7955' -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ('Administrateur', $passwd)
Start-Process taskmgr.exe -Credential $creds
