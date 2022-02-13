1##===----------------------------------------------------------------------===
##  ┌─┐┬ ┬┌┐ ┌─┐┬─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐ 
##  │  └┬┘├┴┐├┤ ├┬┘│  ├─┤└─┐ │ │ │├┬┘ 
##  └─┘ ┴ └─┘└─┘┴└─└─┘┴ ┴└─┘ ┴ └─┘┴└─ 
##  ┌┬┐┌─┐┬  ┬┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┐┌┌┬┐
##   ││├┤ └┐┌┘├┤ │  │ │├─┘│││├┤ │││ │ 
##  ─┴┘└─┘ └┘ └─┘┴─┘└─┘┴  ┴ ┴└─┘┘└┘ ┴ 
##===----------------------------------------------------------------------===

<#
    .SYNOPSIS
        EventManager class: Windows Events Helper for different scripts

    .DESCRIPTION

    .EXAMPLE 
        $AppEventMgr = [EventManager]::new()
        $AppEventMgr.Initialize($Source)
        $AppEventMgr.Write-AppEventLog($Id,$Msg)
    
#>




$rand=New-RandomString 5
$logpath='C:\tmp\logfiles\firewall'
$tmppath="C:\tmp\logfiles\$rand"
new-item -Path $tmppath -ItemType 'Directory' -Force
copy-item "$logpath\*.*" $tmppath
$acl = Get-Acl $tmppath

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("enigma\gplante","FullControl","Allow")

$acl.AddAccessRule($AccessRule)

$acl | Set-Acl $tmppath

explorer $tmppath