
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
.SYNOPSIS
    Script with auto update
.DESCRIPTION
   From the PowerShell forums at https://www.reddit.com/r/PowerShell/comments/vdgush/best_way_to_selfupdate_a_script/ where

.NOTES
   a user is asking for help with a script that will auto update if new version is available.
   
   Have the script hosted on a revision server, like GIT. In the script repository have a small text file with only the latest script version In your script, add the current script version number.
   When you launch the script, you have the following argument available:
   Argument -SkipVersionCheck ; no version check, run local script.
   Argument -ForceUpdate : Update the script from server, no version check.
   Argument -CheckUpdate : do a version check and exit
   Argument -AcceptUpdate : automatically accept the update if a new version is available.
   If the script detects that there's no internet connection available, it will print a warning and run the local script version, no update.
#>


[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [switch]$SkipVersionCheck,
        [Parameter(Mandatory=$false)]
        [Alias('u')]
        [switch]$ForceUpdate,
        [Parameter(Mandatory=$false)]
        [Alias('c')]
        [switch]$CheckUpdate,
        [Parameter(Mandatory=$false)]
        [Alias('y')]
        [switch]$AcceptUpdate,
        [Parameter(Mandatory=$false)]
        [Alias('a')]
        [switch]$AutoCheck,
        [Parameter(Mandatory=$false)]
        [switch]$SetupTest
    )  



################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:RootPath                        = (Get-Location).Path
[string]$Script:ScriptFile                      = Join-Path $PSScriptRoot 'PSAutoUpdate.ps1'
[string]$Script:BackupFile                      = Join-Path $ENV:TEMP 'Backup.ps1'
[string]$Script:TmpScriptFile                   = Join-Path $ENV:TEMP 'PSAutoUpdate.ps1'
[string]$Script:VersionFile                     = Join-Path $Script:RootPath 'Version.nfo'

[string]$script:HostName                        = $ENV:COMPUTERNAME
[string]$script:IsAdmin                         = $False

[string]$Script:NetConnectionVerbosity          = 'Quiet'

[string]$script:UNKNOWN_VERSION                 = '99.99.99.99'
[string]$script:DEFAULT_VERSION                 = '1.0.0.0'


################################################################################################
# FILENAMES
################################################################################################

[string]$Script:DepsFile                        = Join-Path $PSScriptRoot 'dependencies/Deps.ps1'
[string]$Script:UiFile                          = Join-Path $PSScriptRoot   'dependencies/ui.ps1'
$Dependencies = @($Script:DepsFile,$Script:UiFile,$Script:VersionFile)


################################################################################################
# IMPORTANT : URL FRO ONLINE VERSION FILE and SCRIPT
################################################################################################

[string]$Script:OnlineVersionFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/Version.nfo'
[string]$Script:OnlineScriptFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/PSAutoUpdate.ps1'


$Script:Debug = $false
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



#===============================================================================
# Check dependencies
#===============================================================================

ForEach($dep in $Dependencies){
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
# PARSE CURRENT SCRIPT VERSION
#===============================================================================

[string]$Script:CurrentVersionString = Get-Content -Path $Script:VersionFile
try{
    [string]$Script:CurrentVersion = $Script:CurrentVersionString
}catch{
    Write-Warning "Version Error: $Script:CurrentVersionString in file $Script:VersionFile. Using DEFAULT $script:DEFAULT_VERSION"
    [string]$Script:CurrentVersionString = $script:DEFAULT_VERSION
    [string]$Script:CurrentVersion = $Script:CurrentVersionString
}

Write-Host "✅ Current Version detection: $Script:CurrentVersionString"

try{
    [string]$Script:LatestVersionString         = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
}catch{
    Write-Warning "Error while fetching latest version Id on server. Using UNKNOWN_VERSION $script:UNKNOWN_VERSION"
    [string]$Script:LatestVersionString = $script:UNKNOWN_VERSION
    [string]$Script:LatestVersion = $Script:LatestVersionString
}
    
[Version]$Script:LatestVersion              = $Script:LatestVersionString

$Script:IsOnline = Get-NetworkStatus -Quick
Write-Host "✅ Updating Network Status"


if($SetupTest){
    Clear-Host
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " Setting current script version to $Script:DEFAULT_VERSION."
    Set-Content -Path $Script:VersionFile -Value $Script:DEFAULT_VERSION
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " Start the script with no argument to test the local vs remote version detection"
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " USAGE INFORMATION"
    Write-Host "No arguments`n`t$PSCommandPath (Use the menu)"

    $HelpStr ="`t1) Start PSAutoUpdate.ps1
        2) Get the current script version ```Get-CurrentScriptVersion```
        3) Get the latest script version that is available on the server (no update) -- ```Get-LatestScriptVersion```
        4) Update the currently running script with latest -- ```Update-ScriptVersion```
"
    Write-Host -f Blue "$HelpStr"
    return
}

#==============================================================================================================================================================
#                                             -------------- MAIN ENTRY POINT FOR OUR SCRIPT --------------
#==============================================================================================================================================================


#####################################################################
# AUTOMATIC MODE :  CHECK VERSION AND UPDATE IF NEW VERSION AVAILABLE
#####################################################################
if($AutoCheck){
  [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    [Version]$Script:LatestVersion = $Script:LatestVersionString
    if($Script:CurrentVersion -lt $Script:LatestVersion){

        Write-Host -f DarkYellow "`t NEW SCRIPT VERSION AVAILABLE!"; Write-Host -f DarkRed "`t===============================`n";
        Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$CurrentVersion";
        Write-Host -n -f DarkYellow "`tLatest Version`t`t"; Write-Host -f DarkRed "$Script:LatestVersion";
        Write-Host -n -f DarkYellow "`tLocal Script Path`t`t"; Write-Host -f DarkRed "$Script:ScriptFile`n";
        Write-Host -n -f DarkGray "Backup Current Script. $Script:ScriptFile to $Script:BackupFile   "
        Copy-Item $Script:ScriptFile $Script:BackupFile
        Write-Host -f DarkGreen "Done";
        Write-Host -n -f DarkGray "Download Latest...   "
        Get-OnlineFileNoCache $Script:OnlineScriptFileUrl $Script:TmpScriptFile
        Write-Host -f DarkGreen "Done";
        Write-Host -n -f DarkGray "Update Version String in script... $Script:LatestVersionString  "
        $Script:FileContent = (Get-Content -Path $Script:TmpScriptFile -Encoding "windows-1251" -Raw)
        $Script:FileContent = $Script:FileContent -replace "CurrentVersionString = `"__CURRENT_VERSION_STRING__`"", "CurrentVersionString = `"$Script:LatestVersionString`"" 
        Set-Content -Path $Script:TmpScriptFile -Value $Script:FileContent -Encoding "windows-1251" 
        Write-Host -f DarkGreen "Done";
        Copy-Item $Script:TmpScriptFile $Script:ScriptFile
        Write-Host "You can restart the script now..."
        return

    }else{
        Write-Host "No Update Required"
    }
}else{

#####################################################################
# MANUAL MODE :  TEST FUNCTIONALITIES USING THE MENU
#####################################################################
    
    do
    {
        if($Script:IsOnline -eq $False){
            Request-OnlineState
            continue
        }
        Show-Menu
        $Option = Read-Host -Prompt 'Please select an option'
        switch ($Option)
        {
            0 {Invoke-Hidden}
            1 {Invoke-Script}
            2 {Get-CurrentScriptVersion}
            3 {Get-LatestScriptVersion}
            4 {Update-ScriptVersion}
        
            5 {Get-AllPreviousVersion}
            A {Start-Admin}
            N {Update-NetworkSTatus}
            X {Exit}
        }
    } until ($Option -eq 'X')
    #//====================================================================================//
}




