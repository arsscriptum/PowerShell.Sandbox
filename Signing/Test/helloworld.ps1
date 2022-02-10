<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Profile
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



    <#
    .SYNOPSIS
        Updates the environment variables for the current PowerShell session with any environment variable changes that may have occurred during script execution.
    .DESCRIPTION
        Environment variable changes that take place during script execution are not visible to the current PowerShell session.
        Use this Function Script:to refresh the current PowerShell session with all environment variable settings.
    .PARAMETER LoadLoggedOnUserEnvironmentVariables
        If script is running in SYSTEM context, this option allows loading environment variables from the active console user. If no console user exists but users are logged in, such as on terminal servers, then the first logged-in non-console user.
    .PARAMETER ContinueOnError
        Continue if an error is encountered. Default is: $true.
    .EXAMPLE
        Update-SessionEnvironmentVariables
    .NOTES
        This Function Script:has an alias: Refresh-SessionEnvironmentVariables
    .LINK
        http://psappdeploytoolkit.com
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [switch]$ContinueOnError = $true
    )

    
    

    $a = 'a'
    while($a -ne 'q'){
        Write-Host "`n`n"
        Write-Host -n -f DarkRed "`t`t`tHELLO" ; Write-Host -f DarkYellow " WORLD"
        Write-Host -n -f DarkMagent "`t`t`t-----" ; Write-Host -n -f DarkCyan " -----`n`n"
        $a = Read-Host '"q" to quit: '    
    }


    Write-Host -n -f Red "`t`t`tGOOD" ; Write-Host -f Yellow " BYE"
    Write-Host -n -f Magenta "`t`t`t----" ; Write-Host -f Cyan " ---`n`n"

    

    
#===============================================================================
# TEMPLATE FUNCTION
#===============================================================================

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU59ZMK1ro4M14cS2c1QLGjNoX
# 2I2gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUhBoCcNvBLmGkrNVp+J2C
# UonFt78wDQYJKoZIhvcNAQEBBQAEggEAerl2tu4MIl/2clKme6Sv6a0GYCKoSDoP
# hqbtAAWn/0w3qjsVxd5IIQklutjfNl01fgvJCD+Uo0IC3xYk8BvfBkHCZQns/Zok
# 5yBDTCy/XyYbpc0VEenXKwH1fFH9habz4Rt0Yly5iydBUYkl6i/ExD3RWHkU9Eit
# i9ywgwKpCktlIUdHlUqnbx4QlsOz0UdqU23904EF0Y8Igrq6pbJvZ/k6r9ljtXw9
# 7vqT37aNqG9FYiKB+2L2OgAIe7IAP1MtBNea6PkIhnZv+xMVWqm4VyZrsKbl9ao5
# vHJ4ckksfdZUg2LIxnt9pY5UH8BdFg8yMlx/K3K7+zIUVyswizCuCA==
# SIG # End signature block
