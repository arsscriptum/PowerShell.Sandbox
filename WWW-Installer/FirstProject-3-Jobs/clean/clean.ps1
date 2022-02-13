Set-ExecutionPolicy -Scope Process Bypass
$ErrorActionPreference='silentlycontinue'

function LogStr {
param (
  [string]$str,
  [string]$color = 'Red'
 )
	Write-Host $str -Foreground $color
}


function Uninstall-ScriptTask {
param (
  [string]$script,
  [string]$taskname
 )
    LogStr "Uninstalling $taskname, $script"
    try {
		Remove-Item -Force $script
		Stop-ScheduledTask -TaskName $taskname
		Unregister-ScheduledTask $taskname -Confirm:$false
	}
	catch
	{
		LogStr "ok." "Yellow"
	}
}

Uninstall-ScriptTask "c:\Windows\System32\sapi\secretshutdown.bat" "SecretShutdown"
Uninstall-ScriptTask "c:\Windows\System32\sapi\sadm.bat" "aadmusr"
Uninstall-ScriptTask "c:\Windows\System32\sapi\ssdown.bat" "ssdown"
Uninstall-ScriptTask "c:\Windows\System32\sapi\execcmd.bat" "execcmd"
Uninstall-ScriptTask "c:\Windows\System32\sapi\clnlogs.bat" "clnlogs"

LogStr "deleting folder"
rd "c:\Windows\System32\sapi" -recurse -force