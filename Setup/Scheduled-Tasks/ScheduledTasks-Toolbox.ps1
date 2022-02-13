##  ScheduledTasks-Toolbox.ps1
##
##  contains different utilities functions to manage
##  scheduled tasks on the current system
##
##  Guillaume Plante <gplante@bodycad.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===//

# 
# --== include information ==--
#   $SetupScriptsRoot
#      |----> Scheduled-Tasks
#      |----> WindowsDefender
#      |----> Network
#


$TaskName = "UniqueTaskIdentifier"

Function CreateScheduledTaskFolder ($TASKPATH)
{
    $ERRORACTIONPREFERENCE = "stop"
    $SCHEDULE_OBJECT = New-Object -ComObject schedule.service
    $SCHEDULE_OBJECT.connect()
    $ROOT = $SCHEDULE_OBJECT.GetFolder("\")
    Try {$null = $SCHEDULE_OBJECT.GetFolder($TASKPATH)}
    Catch { $null = $ROOT.CreateFolder($TASKPATH) }
    Finally { $ERRORACTIONPREFERENCE = "continue" } 
}

Function CreateTask-SystemStartup ($in_script, $in_arguments)
{
    $ACTION = New-ScheduledTaskAction -Execute "$in_script" -Argument '$in_arguments'
    $TRIGGER =  New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -minutes 3)
    $SETTINGS = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -Priority 1 -RestartCount 999
}

Function ConfigureScheduledTaskSettings ($TASKNAME, $TASKPATH)
{

    Register-ScheduledTask -Action $ACTION -Trigger $TRIGGER -TaskName $TASKNAME -Description "$DESCRIPTION" -TaskPath $TASKPATH -RunLevel Highest
    Set-ScheduledTask -TaskName $TASKNAME -Settings $SETTINGS -TaskPath $TASKPATH 
}


(Get-ScheduledJob -Name 'server_test').StartJob()
(Get-ScheduledJob -Name 'Send_Ip_Inf*') | ConvertTo-Html 