<#
	Installing OpenSSH package Option 2) using PowerShell
	Open the PowerShell command prompt as Administrator
	Run the command: Get-WindowsCapability -Online | ? Name -like ‘OpenSSH*’
	Verify that the “State” displays “NotPresent
	Name : OpenSSH.Client~~~~0.0.1.0
	State : NotPresent
	Name : OpenSSH.Server~~~~0.0.1.0
	State : NotPresent

	Run the following commands to install the OpenSSH client and server.
	Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
	Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

	After the command prompt returns and the install is completed, verify the returned output as:
	Path :
	Online : True
	RestartNeeded : False
#>


Function Quit($Text) {
    Write-Host "Quiting because: " $Text
    Break Script
} 

Function SetupFirewall() {
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

Function InstallPackages(){
	choco feature enable -n=allowGlobalConfirmation
	choco install curl
	choco install wget
	choco install putty
	choco install winscp.install
	choco install wireshark
	choco install procexp
	choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
	choco install cmder
	choco install nodejs.install
	choco install totalcommander
	choco install poshgit
	choco install winpcap
	choco install git-credential-manager-for-windows
	choco install terminals
	choco install baretail
	choco install cppcheck
	choco install beyondcompare
	choco install jenkins
	choco install poshtools-visualstudio2015
	choco install oh-my-posh
	choco install poshadmin
	choco install apache-httpd --params '"/serviceName:daswebserver /installLocation:D:\Server\apache-httpd /port:7070"' --force
}


Write-Host "Setup process was not running, we are starting it." -Foreground Green
	echo "running" > $statefilepath

	InstallPackages

	# set jenkins folder permissions
	$jenkinsinstallpath = "C:\Program Files (x86)\Jenkins"

	if (Test-Path -LiteralPath $jenkinsinstallpath) {
		"Setting permission to directory '$jenkinsinstallpath'."
		SetFolderPermission $jenkinsinstallpath "BQC\gplante"
    }

    echo "done" > $statefilepath
    Exit 0