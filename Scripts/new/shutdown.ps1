<#
  setup powershell script
#>

Function Lock
{
	Lock-BitLocker -MountPoint "G:" -ForceDismount
}

Function Unlock
{
	$SecureString = ConvertTo-SecureString "TooManySecret23" -AsPlainText -Force
	Unlock-BitLocker -MountPoint "G:" -Password $SecureString
}

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

function Clear-AllEventLogs
{
	Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log } 
	wevtutil el | Foreach-Object {wevtutil cl "$_"}
}

Function SetFolderPermission($mypath, $who){
	$myacl = Get-Acl $mypath
	$myaclentry = $who,"FullControl","Allow"
	$myaccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($myaclentry)
	$myacl.SetAccessRule($myaccessrule)
	Get-ChildItem -Path "$mypath" -Recurse -Force | Set-Acl -AclObject $myacl -Verbose
}


Clear-AllEventLogs
Lock