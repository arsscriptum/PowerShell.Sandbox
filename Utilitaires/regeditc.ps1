param (
	[Parameter(
		Mandatory = $true,
		Position = 0,
		ValueFromPipeline = $true,
		ValueFromRemainingArguments = $true,
		HelpMessage = "The registry path to navigate to upon starting the Registry Editor"
	)]
	[string]$Path
)
if (Test-Path "Registry::$Path") {
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -Value "$Path"
}
Start-Process -FilePath "$env:SystemRoot\regedit.exe"

# SIG # Begin signature block
# MIIF1gYJKoZIhvcNAQcCoIIFxzCCBcMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkpwHV5j665T0Gk8ZYIBv6xbE
# yYugggNYMIIDVDCCAkCgAwIBAgIQnhrniYUF/b9AFlLEupZNXDAJBgUrDgMCHQUA
# MDMxMTAvBgNVBAMTKE5pY2stRGVza3RvcCBQb3dlclNoZWxsIENlcnRpZmljYXRl
# IFJvb3QwHhcNMTkwNjE0MTkzMjUxWhcNMzkxMjMxMjM1OTU5WjAiMSAwHgYDVQQD
# ExdOaWNrIEJpc3NlbGwgUG93ZXJTaGVsbDCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAL6+V5seXNfEkZHsrhyweKzBBlM+SsE8rU76Xy9EtEyzwqNnHTiz
# MfkIh9m+uTUJpw/xSTpMQ3pPU6XEGs0cM7hUyNR7MMLfvLSWweKxLnjBi2PYcl6b
# TchEU/PsgUwBPX6VkC5ihntbJbzR6F5ArrMbCtoSHQTmTM1h2Z0wzWit2MIePGVB
# pY62v1yXYjKhoBRqOqrRSPjqsbdZbYu/0tH6NJCpoJhNLhJgtX1sWV+iRsTMqfXC
# dtXusb1UwaBAUQnukXREb1xjWU/BWX3t8oXk/uDbvWUDfoNNQftAa8QdlhsOV+OV
# CxMcYdalpsVL6wmQ1qPmYwPEWrLOqWdZ15ECAwEAAaN9MHswEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwZAYDVR0BBF0wW4AQ3+lSJyM6w2yg/hf4WFL0gqE1MDMxMTAvBgNV
# BAMTKE5pY2stRGVza3RvcCBQb3dlclNoZWxsIENlcnRpZmljYXRlIFJvb3SCEFrg
# UJl66L+hS9tlYNDQHKIwCQYFKw4DAh0FAAOCAQEACPSg1sMtEGbhymL0sxxotJ13
# N92mxKCuHm0vR6Fi7havOorXtYb7N9vKsRaXL2JrmdWSx++ND1TLaWiOL5YMUSdb
# txIggDaQEVMak2h01nKDp0h4BW/Pn8oDMHv8FzhRqqkaK+VXOa4qI/ppl+YFPXW0
# I13FtKnxGZ5Yatg3Y2X39WsUcPFGsL18KJLphNVl0h9g93keS13xbWRX2+4/Qa84
# WcatLJdrRIypT4SOQMrLLd3cRmvThItoIpXtRE+a0TfiJj88PhfOzhM89V5Aig2a
# lBL4fIlGmwwvSSjIoyuHfK7Qa3sVjT3C/ooEsOhu1DobMNHZqc4wt8xqi+23NTGC
# AegwggHkAgEBMEcwMzExMC8GA1UEAxMoTmljay1EZXNrdG9wIFBvd2VyU2hlbGwg
# Q2VydGlmaWNhdGUgUm9vdAIQnhrniYUF/b9AFlLEupZNXDAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUtwhGSzXNgh0KcpyLY/RpnHGOq9cwDQYJKoZIhvcNAQEBBQAEggEAPIhmH0y8
# zhOShHybvx8jJ4yqyRM95HkQCGyTQ73cz5wd7SNVPzBDrvcxQ2QyZnvWfX3EoFsp
# OkSH1Fh4RiZeiazgtM4/PM72MpiBRSm9De+1aqe5XtJ88r+7lEfnZ0DfiKl71kwH
# MoHjbWSqckgfRPZFiuqJ/JESd0zJYJ5ultl62ewVvyy+W+Dr12PmKq31N8mbBaUb
# 8pt2CBUvRT80uf96dSFxhuz1Z+kiIV5ZzxOqp8WSrHgxangj7lqzrhOFKbZgMwfz
# XkoD+lDjGjSpdxdxKWRd80q1CcCd4SG7Dx4wNwZuSh6sdkFP1a07A2Lo8IfZuz7h
# TmWqY13xU7T/iw==
# SIG # End signature block
