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
	choco install apache-httpd --params '"/serviceName:daswebserver /installLocation:D:\Server\apache-httpd /port:80"' --force
}



$statefilename = "process.state";
$currentdirectory = (Get-Location).Path;

Write-Host "Starting setup script in " $currentdirectory

$statefilepath = Join-Path $currentdirectory $statefilename
$state = (Get-Content $statefilepath -First 1)

if($state -Eq 'stopped')
{
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

}
elseif($state -Eq 'done')
{
	Write-Host "Setup process was done! kill remainng processes..." -Foreground Red
	Exit 1
}
# elseif($state -Eq 'running')
else
{
	Write-Host "Setup process was running, disregard and exit!" -Foreground Red
	Exit 2
}