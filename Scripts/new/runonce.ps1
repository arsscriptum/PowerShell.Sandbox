<#
  setup powershell script
#>


function Clear-AllEventLogs
{
	Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log } 
	wevtutil el | Foreach-Object {wevtutil cl "$_"}
}

Function SetupFirewall() 
{
    Write-Host "Configuring firewall..."
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
	netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
} 

Function SetFolderPermission($mypath, $who){
	$myacl = Get-Acl $mypath
	$myaclentry = $who,"FullControl","Allow"
	$myaccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($myaclentry)
	$myacl.SetAccessRule($myaccessrule)
	Get-ChildItem -Path "$mypath" -Recurse -Force | Set-Acl -AclObject $myacl -Verbose
}


Clear-AllEventLogs