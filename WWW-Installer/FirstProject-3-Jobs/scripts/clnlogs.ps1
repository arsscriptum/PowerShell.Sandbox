Set-ExecutionPolicy -Scope Process Bypass

function Clear-AllEventLogs
{
    Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log } 
    wevtutil el | Foreach-Object {wevtutil cl "$_"}
}

Clear-AllEventLogs