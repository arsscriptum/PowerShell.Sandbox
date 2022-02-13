##  install-my-task.ps1
##
##  install a scheduled task that will run at every X minutes
##  that will fetch a file on a web server, the file will define the
##  actions to be taken on the remote computer

##  Guillaume Plante <gplante@bodycad.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===//



function ConvertTo-EncodedScript
{
  param
  (
    $Path,
    
    [Switch]$Open
  )
  
  $Code = Get-Content -Path $Path -Raw
  $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Code) 
  $Base64 = [Convert]::ToBase64String($Bytes) 
  
  $NewPath = [System.IO.Path]::ChangeExtension($Path, '.b64')
  $Base64 | Set-Content -Path $NewPath

  if ($Open) { notepad $NewPath }
}


function Install-ScriptTask {
param (
  [string]$scriptpath
 )
    $action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Unrestricted -NoProfile -WindowStyle Hidden -NonInteractive -EncodedCommand $c64data"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -Hidden -Priority 3
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings

    $taskname='RemoteExecCheck'
    Register-ScheduledTask $taskname -InputObject $task

    Start-ScheduledTask -TaskName $taskname
}

$currentPath = Get-Location
$script_clear = Join-Path $currentPath "runat5min.ps1"
ConvertTo-EncodedScript $script_clear $false
$script_coded = Join-Path $RemoteScriptsPath "runat5min.b64"
$c64data = get-content $script_coded -Raw
Write-Host "$c64data"

Install-ScriptTask $c64data