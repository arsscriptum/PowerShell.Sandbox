$hostname = hostname
$os = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
 write-host "Memory Percent free: $pctFree on $hostname"
if ($pctFree -le 20) {
Restart-Service -Name "SomeCollectionService`$Default" -force
Restart-Service -Name "SomeManagementService`$Default" -force
write-host "Alert memory percent is high" -Fore Red
$strTo = "someone1@somewhere.com,someone2@somewhere.com"
$strFrom = "$hostname@somewhere.com"
$strSubject = "Idera Memory Alert on $hostname"
$strBody = "Idera Services were recycled on: $hostname the memory percent free is: $pctFree"
$objMessage = New-Object System.Net.Mail.MailMessage –ArgumentList $strFrom, $strTo, $strSubject, $strBody

# Define the SMTP server
$strSMTPServer = "SMTP_ServerHere"
$objSMTP = New-Object System.Net.Mail.SMTPClient –ArgumentList $strSMTPServer

# Send the message
$objSMTP.Send($objMessage)
}
 

#Schedule from Win task Scheduler: PowerShell –File "C:\Scripts\Hello.ps1"