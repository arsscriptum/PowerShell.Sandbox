
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
.SYNOPSIS
    
.DESCRIPTION
   
#> 





################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:CurrPath                        = (Get-Location).Path
[string]$Script:RootPath                        = (Resolve-Path ..).Path
[string]$Script:SrcRoot                         = Join-Path $Script:RootPath 'src'
[string]$Script:TestRoot                        = Join-Path $Script:RootPath 'test'


[string]$Script:ScriptVersionDef                = Join-Path $Script:SrcRoot 'ScriptVersionDef.ps1'
[string]$Script:ScriptVersionApi                = Join-Path $Script:SrcRoot 'ScriptVersionApi.ps1'

[string]$Script:TestMain                        = Join-Path $Script:TestRoot 'TestMain.ps1'
[string]$Script:TestImpl                        = Join-Path $Script:TestRoot 'TestImpl.ps1'
[string]$Script:NetConnectionVerbosity          = 'Quiet'

[string]$script:UNKNOWN_VERSION                 = '99.99.99.99'
[string]$script:DEFAULT_VERSION                 = '1.0.0.0'


[System.Collections.ArrayList]$script:ScriptVerFiles = [System.Collections.ArrayList]::new()
[System.Collections.ArrayList]$script:Dependencies   = [System.Collections.ArrayList]::new()


$Null = $script:ScriptVerFiles.Add($Script:ScriptVersionDef)
$Null = $script:ScriptVerFiles.Add($Script:ScriptVersionApi)

$Null = $script:Dependencies.Add($Script:TestImpl)




Write-Host "Loading system information. Please wait . . ."


################################################################################################
# THOSE VARIABLES ASSIGNATION ARE OPERATIONS, NOT ASSIGNMENTS, THEY TAKE A COUPLE ms
################################################################################################

[string]$script:CurrentGitRev                   = git rev-parse --short HEAD
Write-Host "✅ Git Revision Loaded"
[string]$script:UserName                        = ((query user | findstr 'Active').split('>')[1]).split('')[0]
[string]$script:UserName                        = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
Write-Host "✅ Local Username information detected"
$script:IPv4 = (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 1
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
 $script:IsAdmin = $True
}
Write-Host "✅ User privileges detected"
Write-Host "✅ System information loaded"





ForEach($dep in $script:ScriptVerFiles){
    if(-not(Test-Path -Path $dep -PathType Leaf)){
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host " + Missing dependencies File '$dep'" -f DarkGray
        return
    }
    # In all my dependencies, if it s PS1, load it. The other is the version file
    $ext = (Get-Item $dep).Extension
    if($ext -eq '.ps1') { . "$dep" ; }
    
    Write-Host "✅ Dependency: $dep"  
}


#===============================================================================
# Check dependencies
#===============================================================================

ForEach($dep in $script:Dependencies){
    if(-not(Test-Path -Path $dep -PathType Leaf)){
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host " + Missing dependencies File '$dep'" -f DarkGray
        return
    }
    # In all my dependencies, if it s PS1, load it. The other is the version file
    $ext = (Get-Item $dep).Extension
    if($ext -eq '.ps1') { . "$dep" ; }
    
    Write-Host "✅ Dependency: $dep"  
}



function Start-ScriptVersionTest{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('a')]
        [switch]$Automatic,
        [Parameter(Mandatory=$false)]
        [switch]$DebugMode
    )  




    Show-AsciiArt

}







Start-ScriptVersionTest