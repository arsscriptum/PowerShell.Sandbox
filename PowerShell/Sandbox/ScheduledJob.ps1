
$t_now = Get-Date -UFormat "%m/%d/%Y %T"
Register-ScheduledJob -Name 'Send_Ip_Info_Min' -FilePath 'c:\Scripts\SendIpInfo.ps1' -Trigger (New-JobTrigger -Once -At $t_now -RepetitionInterval (New-TimeSpan -Minutes 30 ) -RepetitionDuration ([TimeSpan]::MaxValue))

$t_now = Get-Date -UFormat "%m/%d/%Y %T"
Register-ScheduledJob -Name 'server_test' -FilePath 'c:\Scripts\server_test.ps1' -Trigger (New-JobTrigger -Once -At $t_now -RepetitionInterval (New-TimeSpan -Minutes 30 ) -RepetitionDuration ([TimeSpan]::MaxValue))

# Force with
(Get-ScheduledJob -Name 'Send_Ip_Info_Min').StartJob()
(Get-ScheduledJob -Name 'Send_Ip_Info_Min_Min').RemoveJob()
(Get-ScheduledJob -Name 'server_test').StartJob()
(Get-ScheduledJob -Name 'Send_Ip_Inf*') | ConvertTo-Html 


(Get-ScheduledJob -Name 'Send_Ip_*')

schtasks /create /tn myTask /tr "powershell -NoLogo -WindowStyle hidden -file myScript.ps1" /sc minute /mo 1 /ru System


start /min powershell -WindowStyle Hidden -Command C:\ROM\_110106_022745\Invoke-MyScript.ps1



for(;;) {
 try {
  # invoke the worker script
  C:\ROM\_110106_022745\MyScript.ps1
 }
 catch {
  # do something with $_, log it, more likely
 }

 # wait for a minute
 Start-Sleep 60
}


powershell -File myScript.ps1 -WindowStyle Hidden