#Requires -Module @{ ModuleName = 'Microsoft.PowerShell.LocalAccounts'; ModuleVersion = '1.0.0.0' }

Function Get-LocalGroupMembership {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Please enter a local username e.g. Administrator'
        )]
        [ValidateScript({$null -ne (Get-LocalUser $_ -ea:si)})]
        [Alias('Username', 'Member', 'User', 'u')]
        [String]$User
    )
    return (Get-LocalGroup | ForEach-Object { if ($null -ne (Get-LocalGroupMember -Member $User -Group $_ -ea:si)) {$_.Name}})
}

# SIG # Begin signature block
# MIIFnQYJKoZIhvcNAQcCoIIFjjCCBYoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUgI8jy6h6n9HuA39t3NBFpDL
# ZXmgggMoMIIDJDCCAgygAwIBAgIQUyrEq9zpNLhO3wfvnTvEyDANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU6DBc/FpG
# OSl8/Hh1NCLEMpOnHKcwDQYJKoZIhvcNAQEBBQAEggEAoWNxMehv8u6Udys7VWxr
# L1b8zsK8wQmY2DcumHuo570UtJALLEGQOW9DmIjk0V7ydP7+Vs41Gmzj5LdDsPvj
# EwfvZwcw+LoieguoCqMAqjkAVz+XRyOlj0/jHXmOnJoYAKsm4OlUGprZdzpw5FLn
# eDMJ125I4nCUwY/xdXCYuJY0pcDkYeO7a7bkwDIhzqhiQ1XL3Z84om8Naq6Rhas0
# p70bsKLhnPrwofyF4pQF9zxkmBk9ARuYDkrE0jaZmrk72C1czsVbAqUHPbwLGydu
# R+TNcIE4QSldmUQf7UrDr35wWsqj5GFv/svHRKxuof7eewxtEfhgWVGRleuzzyQq
# nw==
# SIG # End signature block
