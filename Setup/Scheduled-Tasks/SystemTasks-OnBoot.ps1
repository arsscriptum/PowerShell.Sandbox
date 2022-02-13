##  SystemTasks-OnBoot.ps1
##
##  create scheduled tasks that will be executed
##  at bool time by the system.
##
##  Guillaume Plante <gplante@bodycad.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===//

. "$SetupScriptsRoot\Common\SystemConfig-Credentials.ps1"
. "$SetupScriptsRoot\Scheduled-Tasks\ScheduledTasks-Toolbox.ps1"


# Credentials to be configured in the scheduled task

$USER = $local_administrator_user
$PASS = $local_administrator_pass

# Scheduled task information / task folder

$TASKNAME     = "Sophos-Service"
$TASKPATH     = "Private Tasks - Startup"
$DESCRIPTION  = "script that runs at system startup, launching the Sophos service"

# Script to schedule
$SCRIPT="C:\Programs\BodycadSoftware\Services\Sophos-Srv\sophos.exe"

CreateScheduledTaskFolder $TASKNAME $TASKPATH
CreateScheduledTask $TASKNAME $TASKPATH | Out-Null
ConfigureScheduledTaskSettings $TASKNAME $TASKPATH | Out-Null

$PASSWORD = ConvertTo-SecureString "$PASS" -AsPlainText -Force
$CREDENTIALS = New-Object -typename System.Management.Automation.PSCredential -argumentlist $USER, $PASSWORD
 
Set-ScheduledTask -TaskName "$TASKNAME" -TaskPath "$TASKPATH" -User "$USER" -Password "$PASS" | Out-Null