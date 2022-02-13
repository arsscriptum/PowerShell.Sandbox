#**************************************************************************************************************************************
# Install softwares in silent mode 1.0
# Prepared by Ramkumar Natararajan on 19-6-2017 
#**************************************************************************************************************************************
#you can configure it in Group policy as a scheduled job.

$path=split-path $MyInvocation.MyCommand.path
$spath= "$path\setup.x64.msi"
function checksoftware
{
$softwares = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$global:availability=$softwares | %{Get-ItemProperty $_.PSPath | ?{$_.Displayname -eq "Local Administrator"}}
}
checksoftware
Start-Transcript $path\Lap_log.log -Append
If($global:availability -eq $null)
{
	"1. Local Administrator software is not installed in this computer"
	If(Test-Path $spath)
    	{
        	"2. MSI file is accessible from the directory "
	        $status=Start-Process -FilePath msiexec.exe -ArgumentList '/i',$spath,'/q' -Wait -PassThru -Verb "RunAs"
        	If($?)
		{
			checksoftware
	            	"3.  $($Global:availability.DisplayName)--$($Global:availability.DisplayVersion) has been installed"
		}
		else{"3. Unable to install the software"}
    	}   
	Else
    	{
       		"2. Unable to access the MSI file form directory"
    	}
}
Else
{
    "1. Local Administrator software is already existing"
}
Stop-Transcript
#**************************************************************************************************************************************