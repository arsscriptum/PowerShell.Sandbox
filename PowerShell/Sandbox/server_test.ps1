
function TestConnection($servername)
{
	 $value = ""
	 if(Test-Connection $servername -Quiet -Count 1)
	 {
	 	$value = "Server $servername is reachable."
	 }
	 else
	 {
	 	$value = "Server $servername is NOT reachable."
	 }
	 return $value
}

$outgoing_address =(Test-Connection -ComputerName (hostname) -Count 1)  | ConvertTo-Html  -Property IPV4Address -Title "ip address"
$local_ip = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$host_val = $env:computername | Select-Object


$computers = @('10.242.2.2', '10.1.31.147','192.168.0.1')
#$computers.ForEach('TestConnection') 


Get-Date -UFormat "%A %B/%d/%Y %T %Z"
$Time_val = Get-Date
$Time_val = $Time_val.ToUniversalTime()
$job_info = (Get-ScheduledJob -Name 'Send_Ip_Inf*') | ConvertTo-Html 

$string1 = TestConnection '10.242.2.2'
$string2 = TestConnection '10.1.31.147'
$string3 = TestConnection 'BCADD0260'
$string4 = TestConnection '10.1.31.170'
$string5 = TestConnection 'BCADD0254'
$string6 = TestConnection 'BCADLX03'

$smtpServer = "smtp.gmail.com"
$EmailFrom = "gplante@bodycad.com"
$EmailTo = "gplante@bodycad.com"
$EmailPassword = "Born33ToFrag"
$Subject = "Automatic notification ($host_val)"
$Body = "<h2> Automatic email notification from $host_val</h2><br>Ip address: <b>$outgoing_address</b><br>Time: <b>$Time_val</b><br>Local ip: <b>$local_ip</b><br><br>$string1<br>$string2<br>$string3<br>$string4<br>$string5<br>$string6" 

$credentials = New-Object Management.Automation.PSCredential $EmailFrom, ($EmailPassword | ConvertTo-SecureString -AsPlainText -Force)

echo "Sending to $EmailTo... at $Time_val"
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $smtpServer -Credential $credentials -BodyAsHtml -Verbose -UseSsl