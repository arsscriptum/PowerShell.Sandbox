<#
.Synopsis
 PowerShell Multi-Threading Broadcast Using MSG
   Sends a message to all users in the specified serverlist parallelly\multi-threaded.
.DESCRIPTION
   Calls each msg independent of the other msg.exe call irrespective of the completion state.
   The script can be easily modified to send it to specific users instead locally.
.EXAMPLE
   Msg-TSUsersMultiThreaded.ps1
.EXAMPLE
Use notepad to list each server in a new line
Serverlist.txt - Put it in the same location as the PS Script.
Server1
Server2
Server3

.EXAMPLE
Msg-TSUsersMultiThreaded.ps1
#With KeepErrors = $True

------------------------
Server: localhost1
Error 1722 getting session names
PS system32>
------------------------

.EXAMPLE
Msg-TSUsersMultiThreaded.ps1
A common log is visible on the progress, but it doesn't state if the msg.exe call was success or failure

Executing: 'Server: localhost'
 msg.exe *  /server:localhost 'Server will be down at 1PM today'
Executing: 'Server: localhost1'
 msg.exe *  /server:localhost1 'Server will be down at 1PM today'

#>
#Set this to $True to view errors, note all windows will remain open.
$ErrorVisible = $False #$True

#$userlist = Get-content .\Userlist.txt
$Serverlist = Get-content .\Serverlist.txt

$Msgtext = 'Server will be down at 1PM today`, please save your work and logoff before that.'

#$Userlist = "User1","User2","User3","User4","User5"
#$Serverlist = "localhost","localhost1"#"localhost","localhost","localhost","localhost"
#$Serverlist = "localhost"

#Looping through the server list
foreach ($Server in $Serverlist)
#foreach ($User in $Userlist)
{
    #Forming the msg.exe expression\ command

        #Msg specific users in the local server
        #$Mssg = "msg $User 'Lets meet at 1PM today'"

        #Send msg to all users in the server
        $MsgArg = "'Server: $Server'`n msg.exe *  /server:$Server $Msgtext"

    #Calling new PSsession for executing each MSG.exe command parallelly
    Write-Output "Executing: $MsgArg"

    if(-not $ErrorVisible)
    {    Start-Process powershell.exe $MsgArg}
    else
    {
    #Keep window open after execution, to see any errors.
    Start-Process powershell.exe -ArgumentList "-NoExit $MsgArg"
    }
}