<#
  setup powershell script
#>


Function Quit($Text) {
    Write-Host "Quiting because: " $Text
    Break Script
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
	choco install apache-httpd --params '"/serviceName:daswebserver /installLocation:D:\Server\apache-httpd /port:8080"' --force
}

Function SetupApacheFirewall() {
    Write-Host "Configuring firewall..."
    New-NetFirewallRule -Name httpd1 -DisplayName 'jenkins (httpd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 8080
	netsh advfirewall firewall add rule name=httpd1 dir=in action=allow protocol=TCP localport=8080
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

    SetupApacheFirewall
    
    echo "done" > $statefilepath
    Exit 0