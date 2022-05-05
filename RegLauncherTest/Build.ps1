
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (
      [Parameter(Mandatory = $false)]
      [switch]$Uninstall
    )




# ------------------------------------
# Script file - MessageBox - 
# ------------------------------------
$ScriptBlockMessageBox = "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"

# ------------------------------------
# Script file - Miscellaneous - 
# ------------------------------------
$ScriptBlockMiscellaneous = "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"

# ------------------------------------
# Loader
# ------------------------------------
function ConvertFrom-Base64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Take my B64 string and do a Base64 to Byte array conversion of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Then decompress script's data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $StreamReader = New-Object System.IO.StreamReader($GzipStream)
    $ScriptBlockDecompressed = $StreamReader.ReadToEnd()
    # And close the streams
    $GzipStream.Close()
    $InputStream.Close()

    $ScriptBlockDecompressed
}

# For each scripts in the module, decompress and load it.

$ScriptList = @( 'Miscellaneous')
$ScriptList | ForEach-Object {
    $ScriptBlock = "`$ScriptBlock$($_)" | Invoke-Expression
    ConvertFrom-Base64CompressedScriptBlock -ScriptBlock $ScriptBlock | Invoke-Expression
}


try{

    $AppTitle = "New App From Template"
    $AppOrg = "Guillaume Plante"
    Import-Module PowerShell.Module.Compiler
    $CCPs2ExeMod = Get-Module PowerShell.Module.Compiler
    if($CCPs2ExeMod -eq $Null){
       Import-Module PowerShell.Module.Compiler
        $Ps2ExeMod = Get-Module PS2EXE
        if($CCPs2ExeMod -eq $Null){ throw "Module import error" ; }
    }


    $ClCommand = Get-Command Invoke-ps2exe
    if($ClCommand -eq $Null){ throw "No Invoke-ps2exe in scope" ; }

    Write-ChannelMessage  "====================================="
    Write-ChannelMessage  "Compile"
    Write-ChannelMessage  "====================================="

    $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
    $BinPath = Join-Path $RootPath 'bin'
   
    $ScriptsPath = Join-Path $RootPath 'app'
    $ScriptFilePath = Join-Path $ScriptsPath 'RegistryEditorThunderLauncher.ps1'
     $ImgPath = Join-Path $ScriptsPath 'img'
    $IconPath = Join-Path $ImgPath 'Generate.ico'
    $OutPath = Join-Path $BinPath 'RegistryEditorThunderLauncher.exe'
    $FinalAppPath = Join-Path $ScriptsPath 'RegistryEditorThunderLauncher.exe'
    Remove-Item $BinPath -Force -Recurse | Out-Null
    New-Item -Path $BinPath -ItemType Directory -Force | Out-Null
    Write-ChannelMessage  "RootPath $RootPath"
    Write-ChannelMessage  "BinPath $BinPath"
    Write-ChannelMessage  "IconPath $IconPath"
    Write-ChannelMessage  "App Path $OutPath"
# 
    Invoke-ps2exe -inputFile $ScriptFilePath -outputFile "$OutPath" -iconFile "$IconPath" -noOutput -noConsole -noError 

    Write-ChannelResult "SUCCESS!"  
    Write-ChannelResult "$OutPath ==> $FinalAppPath"  
    Move-Item "$OutPath" "$FinalAppPath" -Force
    $ExpExe = (Get-Command explorer.exe).Source
    &"$ExpExe" "$ScriptsPath"
 }catch {
        Show-ExceptionDetails($_) -ShowStack
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPbJRRSiq0lYawAtSYaMSvCiy
# XuigggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUK7+6r+3geK6piRIA7ZZn
# rcR9NnUwDQYJKoZIhvcNAQEBBQAEggEATTFEISBGkd2/jvv2q5yGzHJR9hIP90AF
# iZJHL/MVhUSL0vAGLqaynw0cUs6AcZgODY7U9bAL9LpIRviEhnS39ENpHaBmXG8d
# vU7mZFsLTEos+JIe6MUyff1IlRKYyfQnw0dCYOzYeGq/GF83NAilMiUMvAvzaCoK
# n6G6BG+U8kYKs6vSUfBiBmC0RSrat5ZuaIv9XI2tUELmSIt8QxyVwg+N8zfx7L7o
# pVImquxHU51mgAFzUEY4YTCD6+UFTtjsTrjk0qE+rzffKUydH/Ns/0MGjYWKKakW
# KFD2UXztaexgZdcemN/oDOEI2EroMTCMgP+quq2uwttDHTcXJ6msEQ==
# SIG # End signature block
