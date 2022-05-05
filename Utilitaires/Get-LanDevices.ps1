#Requires -Module @{ ModuleName = 'NetTCPIP'; ModuleVersion = '1.0.0.0' }

Function Get-LanDevices {
    [CmdletBinding()]
    param (
        [switch]
        $Resolve
    )
    $AdapterAliases = (Get-NetAdapter -Physical | Where-Object Status -EQ Up).InterfaceAlias
    foreach ($alias in $AdapterAliases) {
        Write-Host "Interface: $alias"
        $List = Get-NetNeighbor -IPAddress 192.168.* -InterfaceAlias $alias | Sort-Object {[UInt16]($_.IPAddress.Split(".")[-1])}
        $Listv6 = Get-NetNeighbor -IPAddress fe80:* -InterfaceAlias $alias | Sort-Object {[string]($_.IPAddress.Split(":")[-1])}
        if ($Resolve) {
            Write-Progress -Activity "Resolving Hostnames" -Status "Resolving"
            $List,$Listv6 | Select-Object @{Label = 'IP Address'; Expression = {$_.IPAddress}},
            @{Label = 'MAC Address'; Expression = {$_.LinkLayerAddress}},
            @{Label = 'State'; Expression = {$_.State}},
            @{Label = 'Device Name'; Expression = {if ($_.State -eq 'Reachable' -or $_.State -eq 'Stale') {[System.Net.Dns]::GetHostByAddress($_.IPAddress).HostName -replace '.Home$',''}}}
            Write-Progress -Activity "Resolving Hostnames" -Status "Resolving" -Completed
        } else {
            $List | Select-Object @{Label = 'IP Address'; Expression = {$_.IPAddress}},
            @{Label = 'MAC Address'; Expression = {$_.LinkLayerAddress}},
            @{Label = 'State'; Expression = {$_.State}}
        }
    }
}

# SIG # Begin signature block
# MIIFnQYJKoZIhvcNAQcCoIIFjjCCBYoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0kSQbnI+FB5CLtzdidk+KMPb
# D4egggMoMIIDJDCCAgygAwIBAgIQUyrEq9zpNLhO3wfvnTvEyDANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUeJdrWWSF
# Qguke534iBWyZNDoICAwDQYJKoZIhvcNAQEBBQAEggEAGKjpdDGTTiiy0gZwbhoI
# TYc5+2XzzjIIbeOvgvnZOdyQwnYFCrFU77g4D99bR4S1cRBaTqZUMmhKsOwXq4ti
# 6yZqWh8iU0mETmUEFzD6ZWGXPI9FCcInEKj2rtVgRnnc/UTsuNfTaIKAvrpIqsxB
# 33viUqqY0yOc2NyiCe0C2Xx9CJxjHjocwbiPlUUZe4WJ8C1RKg9auAZWs7CeVPz9
# D96aqfz/915FC65VcGf2WCMhrmyV+zFcWr0UNlUivSy07ZMzRR+XM1c2BxzEcfs6
# 3HC2bmUFYdBecQNZYtPewGK2tlVexzsc5opT7PggrCB+QuG2RvrwKL95i2UaTKYb
# /A==
# SIG # End signature block
