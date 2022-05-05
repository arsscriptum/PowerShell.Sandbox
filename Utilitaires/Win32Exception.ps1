#Requires -Assembly Microsoft.Win32.Primitives.dll

Function Find-Win32Exception {
    [CmdletBinding()]
    param (
        [SupportsWildcards()]
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [Alias("Word","Find","Query","String","Name","Description")]
        [String]$Search
    )
    $(
        for ($i=0; $i -lt 16000; $i++) { [System.ComponentModel.Win32Exception]::new($i) }
    ) | Where-Object {$_ -like $Search} | Where-Object Message -NotLike 'Unknown error (*' | Select-Object NativeErrorCode, Message
}

Function Resolve-Win32Exception {
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [Alias("Code","Exception","ID","Number")]
        [Int32]$ErrorID
    )
    $ErrorObj = [System.ComponentModel.Win32Exception]::new($ErrorID)
    if ($ErrorObj.Message -notlike 'Unknown error (*') {$ErrorObj}
}

# SIG # Begin signature block
# MIIFnQYJKoZIhvcNAQcCoIIFjjCCBYoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGxzwcAkHi2zTgr4x2y3wkdl5
# NkWgggMoMIIDJDCCAgygAwIBAgIQUyrEq9zpNLhO3wfvnTvEyDANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUqxKVgdsf
# Be/c+NLKNdOoyABMkxcwDQYJKoZIhvcNAQEBBQAEggEAIuoxJTYfQ41xTdMtfjlS
# CPMWH2gLy74XULhuJELS4pP/pTCZr4rSjqjqIweWK0qU7xCwX7eEknuub32YhBdt
# L97D0LDkBFFBAee5nsnba3FYhUDvoSKdB37+WP0puvct17SD4on/rguazMmgzEHY
# IOhuWzDvPnPBQPUOE8ZsFc69uOH0eSXzNRM0Ur+k02Dd+u/1dQot9YKolsmgzisw
# HIPLKCy2IaJVAnTBZJ8UrWTG/zR8mhg2SGJ+36nQPxvpuC+MqfKWAftnDROnbHpE
# SED7qqYxoGNkyM/zBz+YoUa5WV9joDenqjCu8ofW542iS/GLwyYkRXV3o97i7SSR
# bQ==
# SIG # End signature block
