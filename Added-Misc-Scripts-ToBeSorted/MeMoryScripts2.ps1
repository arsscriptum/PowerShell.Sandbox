
####################################################################################
# Abdurrahim YILDIRIM #
# Service Memory Usage Control #
####################################################################################
# How to run on CMD #
#powershell -ExecutionPolicy ByPass C:\HPOOconfig\SystemControl\MemoryControl.ps1 -serviceName <ServiceName> -virtsize <VirtualMemorySize(MB)> -control <ControlName> -grup <AlertOwner>
#Output Parameters which sent by user
Param(
[string]$serviceName,
[string]$virtsize,
[string]$control,
[string]$grup
)
#Server Environment#
$FilePATH = "C:\HPOOconfig\SystemControl\$serviceName"
$Servername = $env:computername
####Control function
$varService=Get-WmiObject Win32_Service -Filter "name = '$serviceName'"
$PROCESSPIDs = $varService.ProcessID
$varProcessMem = Get-WmiObject Win32_Process -Filter "ProcessId = '$PROCESSPIDs'"
$MemSizeBy = $varProcessMem.WS
$MemSizeFl = $MemSizeBy/1MB
$MemSize = [int]$MemSizeFl
#Test and alert function for HP Operation Manager#
write-host "$MemSize : $virtsize"
If ($MemSize -gt $virtsize) {
If (Test-Path $FilePATH)
{
Write-Host "Alert"
}
else
{
Add-Content $FilePATH "$serviceName Memory Usage bigger than $virtsize MB : $MemSize MB"
opcmsg a=$control o=$control s=Critical msg_text="$Servername server  $serviceName memory problem. Threshold: $virtsize MB - Calculated: $MemSize MB. $grup - call  !!!" node=$Servername
}
}
else
{
If (Test-Path $FilePATH)
{
del $FilePATH
opcmsg a=$control o=$control s=Normal msg_text="$Servername server  $serviceName memory problem fixed. Threshold: $virtsize MB - Calculated: $MemSize MB !!!" node=$Servername
}
}
#powershell -ExecutionPolicy ByPass C:\HPOOconfig\SystemControl\MemoryControl.ps1 -serviceName <ServiceName> -virtsize <VirtualMemorySize(MB)> -control <ControlName> -grup <AlertOwner> 