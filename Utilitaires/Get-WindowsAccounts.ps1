Function Get-WindowsAccounts {
	[CmdletBinding()]
	param ()
	(Get-CimInstance -ClassName Win32_Account -Namespace root\cimv2 | Sort-Object Caption).Caption
	Get-Service | ForEach-Object {"NT Service\$($_.Name)"}
	try {
		Get-WebConfiguration system.applicationHost/applicationPools/* /* | `
			Where-Object {$_.ProcessModel.identitytype -eq 'ApplicationPoolIdentity'} | `
			ForEach-Object {"IIS APPPOOL\$($_.Name)"}
	}
	catch {}
	if (Get-Command Get-VM -ea:si) {
		Get-VM | ForEach-Object {"NT VIRTUAL MACHINE\$($_.Id):$($_.VMName)"}
	}
}

# SIG # Begin signature block
# MIIFnQYJKoZIhvcNAQcCoIIFjjCCBYoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPPSJ0soZFzl+YX2zK6giSoVf
# MBCgggMoMIIDJDCCAgygAwIBAgIQUyrEq9zpNLhO3wfvnTvEyDANBgkqhkiG9w0B
# AQUFADAqMSgwJgYDVQQDDB9OaWNrIEJpc3NlbGwgUG93ZXJTaGVsbCBTaWduaW5n
# MB4XDTIwMDMwNjE2NDUzNloXDTIxMDMwNjE3MDUzNlowKjEoMCYGA1UEAwwfTmlj
# ayBCaXNzZWxsIFBvd2VyU2hlbGwgU2lnbmluZzCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAKLpRRN1BCq4oDv9LUyG7HVY6+7F/tIh96mUQ2IJg2JvvO+u
# hSBPeLT7BHgRNE9IJ8+xPfn82s7+BHroxkgbXPHL4Lkq/+l1RIlNGPpn2btBGBvJ
# BWQaKxQ2x5ALdKSjfHuvvd+Q+lLBqZhe4i3rI2qhIeltq7KA5HiGpNJTmOZTLbqz
# 5IeXx92WvuffT2lFYELyWS0G8LXuQVkLSAyVs+rqUfklXYWoqGjKXsvfqUOUhsEn
# /JLKGMv9hcYSfnVgcpASz9dL2qxxbEkK+ctxhB2LumLLjaPBlnW2e9eoB3hQqNI9
# Rt4Yy73AkkTJeemjJkLoW3HZARFqGBUAFoSjMZkCAwEAAaNGMEQwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBR3Z1DEjTfXkAg6
# zlwTlsV8xaQxfDANBgkqhkiG9w0BAQUFAAOCAQEAoGimDR9sO5mi/DL9R0dPENjg
# EWhyB4yxUmCwrzJMCsoLnx0Iz5ioWdQbJewjVbqf9wUbUv2uAdsBBHHN/8LG7Xtc
# P7tssbEmjjBukBj+rWnW4s2l5u6E9SveN8rovIvhKrsfluiyz1Uli+UVpVRlGBLe
# c0DQhDGw62qzll42vHt2T/5bgVweost8wJRgMyRCXW9Q6F+2+YZeG//rYEwyt93b
# nkn9Aaw0flmfuFakig0poqAFJeA0kH/zcSKsfute5fPtOzx+jQ33REcvEBhqz9PJ
# xAozElCr1eQmdFU9zHmvgVYu6PLZH3rhAcmWQrFljYR8ZZLzXViff2l2sv48VTGC
# Ad8wggHbAgEBMD4wKjEoMCYGA1UEAwwfTmljayBCaXNzZWxsIFBvd2VyU2hlbGwg
# U2lnbmluZwIQUyrEq9zpNLhO3wfvnTvEyDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUtD4pXDjX
# s+moFODZWlXlPv9wyXIwDQYJKoZIhvcNAQEBBQAEggEAny0WJnHSRQMLUIvN4OnZ
# UQ6ZpAqq+dYOP8+5/jZAm4D8WASEFbkbq+tzm6a7HF2UDlmhViFBYgGZ+h/vyKyx
# ILSRn8oRy3skI41tkIYei7ou/a7+yC97QryOqhuklUpvUvLX18LuqiVfyMSf9mzZ
# TIlKy2Ov7/XfEhIiGxxQku+slsHoe4P/7/O4zcYkBnLUeTqmpm5MBaXPpczgwYNv
# 1Db1/Bp8R71nMo13sxv1KJccWgr1S3GYZsDVPxQ2mleTwCAudSuK+80nD3EBJSoR
# IzEYnjOYpMWoD6Mwx1MkjO6vhmCFrLysIKxAyeLODGr05lrwqMx9oEC14MXzMjAL
# ug==
# SIG # End signature block
