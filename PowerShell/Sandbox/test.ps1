#   SendEmail.ps1
#   Version 1.0
#
#   Use this to send an email
#

$outgoing_address =(Test-Connection -ComputerName (hostname) -Count 1)  | ConvertTo-Html  -Property IPV4Address -Title "ip address"
$local_ip = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$host_val = $env:computername | Select-Object

Get-Date -UFormat "%A %B/%d/%Y %T %Z"
$Time_val = Get-Date
$Time_val = $Time_val.ToUniversalTime()

$smtpServer = "smtp.gmail.com"
$EmailFrom = "gplante@bodycad.com"
$EmailTo = "radicaltronic@gmail.com"
$EmailPassword = "Born33ToFrag"
$Subject = "Automatic notification ($host_val)"
$Body = "<h2> Automatic email notification from $host_val</h2><br>Ip address: <b>$outgoing_address</b><br>Time: <b>$Time_val</b><br>Local ip: <b>$local_ip</b>" 

#  $SMTPServer = "smtp.gmail.com"
#  $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
#  $SMTPClient.EnableSsl = $true
#  $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("gplante@bodycad.com", "Born33ToFrag");
#  $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

#  $credentials = New-Object Management.Automation.PSCredential $EmailFrom, ($EmailPassword | ConvertTo-SecureString -AsPlainText -Force)
$credentials = New-Object Management.Automation.PSCredential $EmailFrom, ($EmailPassword | ConvertTo-SecureString -AsPlainText -Force)

echo "Sending to $EmailTo..."
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $smtpServer -Credential $credentials -BodyAsHtml -Verbose -UseSsl