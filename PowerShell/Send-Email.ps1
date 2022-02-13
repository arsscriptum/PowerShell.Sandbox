$email = "radicaltronic@gmail.com"

$recipients = "radicaltronic@gmail.com"
$pass = "SecretTest123"

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
#$msg.BodyEncoding = [system.Text.Encoding]::Unicode
#$msg.SubjectEncoding = [system.Text.Encoding]::Unicode
$msg.IsBodyHTML = $true 
$msg.Subject = "Automatic notification ($host_val)"


$msg.Body = $env:MESSAGEBODY

$SMTP.Credentials = New-Object System.Net.NetworkCredential("$email", "$pass");
$smtp.Send($msg)