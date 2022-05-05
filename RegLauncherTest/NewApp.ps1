
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (
      [Parameter(Mandatory = $false)]
      [switch]$Compile
    )

try{
    $AppScriptPath = (Resolve-UnverifiedPath "App.ps1")
    $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
    $OutPath = (Resolve-Path "$PSScriptRoot\..\out").Path
    $PSM1Path = (Resolve-Path "$PSScriptRoot\..\out\CodeCastor.PowerShell.Core.psm1").Path    

    if($Compile){

        $AppTitle = "RegEd.exe"
        $AppOrg = "SysTechnica - www.sysinternals.com"
        $AppDesc = "Launches RegEdit and Jumps to Key in Clipboard"
        $AppProduct = 
        $AppCopyRight = 'Copyright (C) 2000-2021 Guillaume Plante'
        $TradeMark = 
        $AppVersion = '1.0'
        Import-Module CodeCastor.PowerShell.PS2EXE
        $CCPs2ExeMod = Get-Module CodeCastor.PowerShell.PS2EXE
        if($CCPs2ExeMod -eq $Null){
            Import-Module PS2EXE
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
       
        $ScriptsPath = (Resolve-Path "$PSScriptRoot").Path
        $ImgPath = Join-Path $ScriptsPath 'img'
        $IconPath = Join-Path $ImgPath 'HPOSCheck.ico'
        $OutPath = Join-Path $BinPath 'reged.exe'
        
        Remove-Item $OutPath -Force -Recurse | Out-Null
        New-Item -Path $BinPath -ItemType Directory -Force | Out-Null
        Write-ChannelMessage  "RootPath $RootPath"
        Write-ChannelMessage  "BinPath $BinPath"
        Write-ChannelMessage  "IconPath $IconPath"
        Write-ChannelMessage  "App Path $OutPath"
    # 
        Invoke-ps2exe -inputFile $AppScriptPath -outputFile "$OutPath" -iconFile "$IconPath" -noOutput -noConsole -noError -title $AppTitle -description $AppDesc -company $AppOrg -product $AppProduct -copyright $AppCopyRight -trademark $TradeMark -version $AppVersion

        Write-ChannelResult "SUCCESS!"  
        Write-ChannelResult "$OutPath ==> $FinalAppPath"  
        Copy-Item  "$OutPath" "$ENV:ToolsRoot"
        $ExpExe = (Get-Command explorer.exe).Source
        &"$ExpExe" "$ENV:ToolsRoot"
    

    }else{

        if(-not(Test-Path $PSM1Path)){throw "PSM1 File doesnt exists!"}

        Copy-Item "$PSM1Path" "$AppScriptPath"
        $script = $PSCommandPath
        subl "$AppScriptPath"
        Write-Host "When finished editing compile with $script"    
    }    
}catch {
        Show-ExceptionDetails($_) -ShowStack
}



# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUROQN2e3gk7sME7IZcxmEzlbv
# Wi+gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUOmI8Ve6QUc9Dp01EoZkT
# E8cO8KcwDQYJKoZIhvcNAQEBBQAEggEAXn8iwm7YgthJ/i0s2HnDDuieohe6A/qI
# pAuBsdnxRXOxiQ+NdxRJ8rMCVSo6X1O2S4gPYF7KQm7E2Z2Z9sYBLolclXpZfIL9
# +YXARfm7A+fONJLTWJALuKw4Ct5PVHtcRcPDx+1cqo+D4ziwKp5i5guY8w59cQ4g
# rv1JnLgWDF4Nkhwy+WE391qqrtv5mBSCW9kwQEYT2k3FEsvx7jDZnxD74WpVhddX
# crGIf153t1JGfJHk+UWaLHBx2pwyPljkKGbNiG+6qxgs19W53evjjDhyCIReeDhH
# narjP0Zd+GozP25iKU+gHijBjavMuFE/fre352XEhtE6Sp0YHEGw6g==
# SIG # End signature block
