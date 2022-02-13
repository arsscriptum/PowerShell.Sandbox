#   Filecheck.ps1
#   Version 1.0
#   Use this to simply test for the existance of an input file... Servers.txt.
#   I want to then call another script if the input file exists where the
#   servers.txt is neded to the other script.
#

$workpath="C:\Scripts\tmp"

#   Created a functon that I could call as part of a loop.

function Filecheck
{
    if (test-path $workpath\file.txt)
    {
        #rename-item $workpath\file.txt $workpath\backup.txt
        #"Servers.txt exist... invoking an instance of your script agains the list of servers"
        #"action taken!"
        Invoke-Expression .\SendEmail.ps1
    }
    Else
    {
        "sleeping"
        Start-Sleep -Seconds 60
    }
}
function SendEmail
{

    Invoke-Expression .\SendEmail.ps1
    Start-Sleep -Seconds 60
}

Do
{
    Filecheck
    $fred=0
    # Needed to set a variabe that I could check in the while loop.
    # Probably a better way but this was my way.
}
While( $fred -lt 1 )