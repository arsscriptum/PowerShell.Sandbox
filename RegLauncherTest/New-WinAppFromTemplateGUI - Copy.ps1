                        <#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [Alias('test', 't', 'var')]
    [switch]$ShowVariables        
        
)




# ------------------------------------
# Script file - Assemblies - 
# ------------------------------------
$ScriptBlockAssemblies = "H4sIAAAAAAAACtVXbW/bNhD+HiD/4eAKsIRazqd96RCgiR1v2WLHiINmRWAUjHWO2dKkSlIwjK7/fUeJkmXHL3GwD5sQCDF5rw+fO55OT4LRRPPUfnjgMlELc2EMzp/E8g6nqFFO0MA5fAyj01cIvj+H5lCjQWmZ5Ur2NJvjQulvzbdod5TGVyv63UtmXq8zWhqL87YXaveUnptjlbuaLbh8PlKtCUe6+WsunA6fhsHQfEJtCJ979iSwXf1s99lXpSHG7/BL9OP0BOg5yscoRZzMKJOfpyfTTE7cGcBophbxSz1v/0FzizEF8KQMQuOGGwtMCJhkmuQs6JUjLmFnFA2Ip9BZMvnaqP8GOqwrNpnFt09fcWLBx7MlplL7A1ReIB6oAS5uuMSdavAYDEfXBMs4V+uzZ0fLQpzwob8aSBdJ8hIjCqkQf+zME4H2krIhpoSjLE2VtoaQzUQy1IoSMtG4kE0ZlUy4iupx6BbQog77TCbMKr08D6zOsPWJiQx7Ws2HPEVBufh1WGm753cUaZ88UALnFRggyWgjgnHNE9nj5AAHyg4yIW711Ty1yzCqy1wIzkzYlM21VWM1JTYOSuutQ/FPmTBvS2Di2EVw3y/Tzfh9bHwjtgW3k9k4uJ470IuN6IjiqJKqE74zY1Ki8FFBoxJqFFKuTAuHZSG6x7HExQ0VVwYEzaaH3V4Ki4Q01PRh03fOzHV6Etd3l/C/z863n+4+epYkG6lMT/A/TzH3Kv4t3tfTEKijXKpMJlXApt1R1FW4NH/iMmwWqTWjvIcHPZcB1Ankc3f3sT9s92TGUaLo4b+ulh2EJmUk3l86L1qJ1WbN6NkZQOcdFKZXy8SgxsfyR8WsPIrdE8Ku7fWL77BUcd2tPAfE4B4XLvPQkfkeHdRML91i1O5Ru3LproS7QgyZnTn539DGro9XRqJ2l2u6M4gmg02lvCC3K7nJwjmB99BsJ0I01xRJ6Q/FZZx7rUdQM1wo3OVW1q2XUt5kR81TWtW3qStfh27zLJOGTd1ok0vcZjbNbN5MaPOGPzkw/Ob25uHD9I4a+0Q33W/Gs1e5Flktyr0qntWe3XtFu5iiTIgunPiyhUNe+V4v900EVR927y5OueR5nyzrKy4Cr7pRecbxIWQgrkJJvPaOQEsfm0ABMciY+5nOahUe3KHJhKWj/n+Evu3Ku6Ej0GytJiC+0lrpCz9oWpXuuAF9+o3AA1GDRqPNtFyvn59l2+gw6ssvifDAtHQtM65o1WOERAJWAc97OARfytu0aELr9+kdPtOgizpeAVUNe+9uFEsorO8ZNZkERF6aDkm/vWMI2PrV1ILNz6FWOUO7btSCbR8w1ar/Msn9Fs5pH2lmhpBwnLqB/OAEFNXR26iqw7N2l+lvdwTCtnF7izaN3OS5mLed6mcUQi3WVXbNUKRYu7vKhLeS4DgikOEa3fwVWGfFyT+4S7xdQg8AAA=="

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

$ScriptList = @( 'Assemblies', 'Miscellaneous', 'MessageBox' )
$ScriptList | ForEach-Object {
    $ScriptBlock = "`$ScriptBlock$($_)" | Invoke-Expression
    Write-Verbose "Loading $ScriptBlock"
    ConvertFrom-Base64CompressedScriptBlock -ScriptBlock $ScriptBlock | Invoke-Expression
}

Add-Type -AssemblyName 'System' 
Add-Type -AssemblyName 'System.Xml' 
Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'
Add-Type -AssemblyName 'PresentationFramework'
Add-Type -AssemblyName 'PresentationCore'
Add-Type -AssemblyName 'WindowsBase'


#===============================================================================
# Utils
#===============================================================================

Function ReplaceStrings($DestinationPath)
{
        $NewGuid = (new-guid).Guid
        $AnchorQt5 = 'xxxUSINGQT5xxx'
        $AnchorWinsock = 'xxxUSINGWINSOCKxxx'
        $AnchorSubSystem = 'xxxTEMPLATESUBSYSTEMxxx'
        $AnchorGuid = 'xxxPROJECTGUIDxxx'
        $AnchorCharSet = 'xxxCHARACTERSETxxx'
        $AnchorProjectName = 'xxxPROJECTNAMExxx'

        $FileList = [System.Collections.ArrayList]::new()

       
        $FileList.Add("$DestinationPath\vs\app.vcxproj") | Out-null
        $FileList.Add("$DestinationPath\vs\cfg\app.props") | Out-null
        ForEach($File in $FileList)
        {
            if(-not(Test-Path $File)){
                Write-Error "could not find file $File"
                return
            }
            $FileContent = Get-Content $File
            Write-Output "Updating $File..."
            # File Content is replaced by the correct values 
            $FileContent = ($FileContent -replace $AnchorGuid, $NewGuid)
            $FileContent = ($FileContent -replace $AnchorQt5, $Opt_UseQT)
            $FileContent = ($FileContent  -Replace $AnchorWinsock, $Opt_UseWinSock)    
            $FileContent = ($FileContent -replace $AnchorCharSet, $Opt_Charset) 
            $FileContent = ($FileContent -replace $AnchorSubSystem, $Opt_Subsystem) 
            $FileContent = ($FileContent -replace $AnchorProjectName, $Opt_ProjectName)

            Set-Content -Path $File -Value $FileContent 
        }
}
Function Get-Folder($initialDirectory="$Env:DevelopmentRoot")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a destination folder..."
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory
    $folder = ""
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}


Function Show-MsgWarning($message="")
{
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Script:ImageWarning
    $Image.Height = 50
    $Image.Width = 50
    $Image.Margin = 5
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = $message
    $TextBlock.Padding = 10
    $TextBlock.FontFamily = "Verdana"
    $TextBlock.FontSize = 16
    $TextBlock.VerticalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Orientation = "Horizontal"
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
    Show-MessageBox -Content $StackPanel -Title "WARNING" -TitleFontSize 28 -TitleBackground Orange
}


function Show-Error
{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Text
        
    )
   
    $ErrorMsgParams = @{
        Title = "Error"
        TitleBackground = "Red"
        TitleTextForeground = "Yellow"
        TitleFontWeight = "UltraBold"
        TitleFontSize = 20
    }

    Show-MessageBox @ErrorMsgParams -Content $Text
}



Function Show-Success($message="")
{
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Script:ImageSuccess
    $Image.Height = 50
    $Image.Width = 50
    $Image.Margin = 5
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = $message
    $TextBlock.Padding = 10
    $TextBlock.FontFamily = "Verdana"
    $TextBlock.FontSize = 16
    $TextBlock.VerticalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Orientation = "Horizontal"
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
    Show-MessageBox -Content $StackPanel -Title "SUCCESS" -TitleFontSize 28 -TitleBackground White
}

function PopupBanner([string]$BannerImagePath)
{
        $Code = {
            Write-Verbose 'Loaded'
        }
        $Source = $BannerImagePath
        $Image = New-Object System.Windows.Controls.Image
        $Image.Source = $Source
        $Image.Height = [System.Drawing.Image]::FromFile($Source).Height
        $Image.Width = [System.Drawing.Image]::FromFile($Source).Width
        $Params = @{
   
            Content = $Image
            TitleBackground ='Navy'
            TitleTextForeground = 'Navy'
            FontFamily = 'Lucida Console'
            ButtonType = 'None'
            Timeout = 5
            CornerRadius = 40
            ShadowDepth = 0
            BlurRadius = 0
            BorderThickness = 0
            BorderBrush = 'Navy'
            ContentBackground = "Navy"
            OnLoaded = $Code
        }       
        Show-MessageBox @Params
}

try
{
    $ScriptReturnValue = 0
    $OrigError = $ErrorActionPreference
    $ErrorActionPreference = "Ignore"

    $Script:CurrentPath = (Get-Location).Path
    $Script:RootPath = (Resolve-Path "$Script:CurrentPath\..").Path
    $Script:SourcePath = $Script:RootPath

    Write-Verbose "Looked up Ui files in path $CurrentPath"

    $Script:ImageWarning = Join-Path $Script:CurrentPath '\img\warning.png'
    $Script:ImageError = Join-Path $Script:CurrentPath '\img\error.png'
    $Script:ImageSuccess = Join-Path $Script:CurrentPath '\img\success_1.png'

    Write-Verbose "SourcePath $Script:SourcePath"
    Write-Verbose "ImageWarning $Script:ImageWarning"
    Write-Verbose "ImageSuccess $Script:ImageSuccess"
    # where is the XAML file?
    $xamlFile = "$Script:CurrentPath\ui.xaml"
    Write-Verbose "Loading $xamlFile..."

    if(-not(Test-Path -Path $xamlFile))
    {
        Show-Error 'NOT IN SCRIPTS FOLDER !!'
        Show-Error 'Please Run from DEVPATH/Templates/Template.Cpp.WindowsApp/scripts'
        exit
    }

    Write-Verbose "Loading xaml file: $xamlFile"
    Write-Verbose "Loading xaml file: $xamlFile"

    #create window
    $inputXML = Get-Content $xamlFile -Raw
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    [XML]$XAML = $inputXML

    #Read XAML
    $Script:reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $Script:window = [Windows.Markup.XamlReader]::Load( $reader )

    # Create variables based on form control names.
    # Variable will be named as 'var_<control name>'

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name "var_$($_.Name)" -Value $Script:window.FindName($_.Name) -ErrorAction Stop
    }

    if($ShowVariables){
        Get-Variable var_*    
    }
    
    $var_ComboSubSystem.Text = ""
    $Null=$var_ComboSubSystem.Items.Add("Console");
    $Null=$var_ComboSubSystem.Items.Add("Windows");
    $Null=$var_ComboCharSet.Text = ""
    $Null=$var_ComboCharSet.Items.Add("Unicode");
    $Null=$var_ComboCharSet.Items.Add("Multibyte");
    $Null=$var_ComboCharSet.Items.Add("NotSet");

    $Ready = $True

    $var_BtnBrowse.Add_Click( {
       #clear the result box
       # & $MsgBox17
       $var_TextPath.Text = Get-Folder
       
       })
    $var_BtnCancel.Add_Click( {
        $Script:window.CLose()
       })

    $var_BtnGenerate.Add_Click( {
        if($var_TextName.Text -eq ""){
            Write-Verbose "Please Specify Project Name"
            Show-MsgWarning "Please Specify Project Name"
            return;
        }
        if($var_TextPath.Text -eq ""){
             Write-Verbose "Please Specify Project Path"
            Show-MsgWarning "Please Specify Project Path"
            return;
        }
        if($var_ComboCharSet.Text -eq ""){
             Write-Verbose "Please Specify Character Set"
            Show-MsgWarning "Please Specify Character Set"
            return;
        }
        if($var_ComboSubSystem.Text -eq ""){
             Write-Verbose "Please Specify a Sub System"
            Show-MsgWarning "Please Specify a Sub System"
            return;
        }
        $Opt_ProjectName = $var_TextName.Text
        
        $DestinationPath =  $var_TextPath.Text
        if($DestinationPath[-1] -ne "\") {$DestinationPath += "\"}
        $DestinationPath = $DestinationPath + $Opt_ProjectName
        if(Test-Path -Path $DestinationPath){
             Write-Verbose "Destination Folder Already Exists! $DestinationPath"
            Show-MsgWarning "Destination Folder Already Exists! $DestinationPath"
            return;
        }
        $Opt_Charset = $var_ComboCharSet.Text
        $Opt_Subsystem = $var_ComboSubSystem.Text
        $Opt_UseQT = 0
        $Opt_UseWinSock = 0
        
        If ($var_CheckQt.Checked)
        {
            $Opt_UseQT = 1
        }
        If ($var_CheckWinsock.Checked)
        {
            $Opt_UseWinSock = 1
        }
        $XcopyExe = (Get-Command xcopy.exe).Source
        New-Item -Path $DestinationPath -ItemType Directory -Force
        & "$XcopyExe" /d /e /s /y $SourcePath $DestinationPath
        ReplaceStrings $DestinationPath
        Show-Success "New project created in $DestinationPath"
        $ExpExe = (Get-Command explorer.exe).Source
        $Ready = $False
        &"$ExpExe" $DestinationPath
        #$DevConsole = "$DestinationPath\scripts\DevConsole.bat"
        #$CmdExe = $Env:ComSpec
        #Start-Process $CmdExe -ArgumentList "/c call `"$DevConsole`""
        $Script:window.Close()
       })

    if($Ready){
       
        $Script:window.Title = "Visual Studio Project Generator"

        $PopupBanner = Join-Path $Script:CurrentPath 'img\banner.jpg'
        PopupBanner $PopupBanner

        $Null = $Script:window.ShowDialog()

        $ErrorActionPreference = $OrigError
        return $true  
    }

    return $false  
     
 }catch {
    write-host $_
        Show-ExceptionDetails($_) -ShowStack
    }
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1X3AJ+nEShvDNePcTUiLgApS
# 7pSgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUmuUsPEHJIvxxddIMOkDJ
# FgM2xR4wDQYJKoZIhvcNAQEBBQAEggEASBR64edeBaHFSdMGUKi8QtCQ/yoyrbG+
# m7GqYjsZmqyl2KjNJgix5jKkPxif6hDKznP6HqkjcPknLCgHTrg4FSInoFjN54J1
# Q676zwg+z6dzy7fw8fqaDPQNromAQuBouOQ1ggXQlyQS3y9kQ/UnHtkJtbkqB3+3
# zV2cZOWozrMitLMn6+6MtivNa9rlroQdxEx7joGjsKRYZFDUEW+viL0OVnVI716D
# U5OM/XsjwmFKcCYv/irWi8QoeVUuV6xXjony2I4JV5De+7HSNTNlCBBcJ1v7fle1
# xaBBVOIiXSyt0MObDfl0XiPIVr2J+LfYD0qFPs0COaJBb8FxSUAlQw==
# SIG # End signature block
