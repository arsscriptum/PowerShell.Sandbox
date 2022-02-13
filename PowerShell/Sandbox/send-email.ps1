$email = "gplante@bodycad.com"

$recipients = "radicaltronic@gmail.com"
$pass = "Born33ToFrag"

$smtpServer = "smtp.gmail.com"

$ip_val = Get-NetIPAddress | Sort-Object -Property InterfaceIndex | Format-Table
$host_val = $env:computername | Select-Object


Get-Date -UFormat “%A %B/%d/%Y %T %Z”
$Time_val = Get-Date
$Time_val.ToUniversalTime()


$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.EnableSsl = $true
$msg.From = "$email" 
$msg.To.Add("$recipients")
$msg.BodyEncoding = [system.Text.Encoding]::Unicode
$msg.SubjectEncoding = [system.Text.Encoding]::Unicode
$msg.IsBodyHTML = $true 
$msg.Subject = "Automatic notification ($host_val)"


$msg.Body = "<h2> Automatic email notification from $host_val</h2>
</br>
Ip address: <b>$ip_val</b></br>
Time: <b>$Time_val</b>
" 
$SMTP.Credentials = New-Object System.Net.NetworkCredential("$email", "$pass");
$smtp.Send($msg)