
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
        [switch]$EnableTestMode,
        [Parameter(Mandatory=$false)]
        [switch]$DisableTestMode,
        [Parameter(Mandatory=$false)]
        [switch]$DebugMode
    )  



################################################################################################
# ON LOAD I Get the TEST MODE and DEBUG MODE STATUS
################################################################################################
[Boolean]$Script:Debug                          = $False
if($DebugMode){
    [Boolean]$Script:Debug = $True
}
Set-Variable -Name 'PSAutoUpdateDEBUGMODE' -Value $Script:Debug -Scope Global -Option AllScope -Visibility Public -Force -ErrorAction Ignore  
if($DisableTestMode){
    $Script:TestMode = $False
   Set-Variable -Name 'PSAutoUpdateTESTMODE' -Value $False -Scope Global -Option AllScope -Visibility Public -Force -ErrorAction Ignore  
}elseif($EnableTestMode){

    $Script:TestMode = $True
   Set-Variable -Name 'PSAutoUpdateTESTMODE' -Value $True -Scope Global -Option AllScope -Visibility Public -Force -ErrorAction Ignore  
}else{
    $TmpValue = Get-Variable -Name 'PSAutoUpdateTESTMODE' -ValueOnly -ErrorAction Ignore
    if($TmpValue -eq $Null){
        [Boolean]$Script:TestMode                       = $False
    }else{
        [Boolean]$Script:TestMode = $TmpValue
    } 
}


################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:RootPath                        = (Get-Location).Path
[string]$Script:ScriptFile                      = Join-Path $PSScriptRoot 'PSAutoUpdate.ps1'
[string]$Script:BackupFile                      = Join-Path $ENV:TEMP 'Backup.ps1'
[string]$Script:TmpScriptFile                   = Join-Path $ENV:TEMP 'PSAutoUpdate.ps1'
[string]$Script:VersionFile                     = Join-Path $Script:RootPath 'Version.nfo'
[string]$Script:TestVersionFile                 = Join-Path $Script:RootPath 'test/TestVersion.nfo'
# IMPORTANT : When runnig in TEST MODE, the version filename is overridden so that the test version 
# is used instead, without changing thecode
if($Script:TestMode){
    [string]$Script:VersionFile                 = Join-Path $Script:RootPath 'test/TestVersion.nfo'
    [string]$Script:TestVersionFile             = Join-Path $Script:RootPath 'test/TestVersion.nfo'
    if(-not(Test-Path $Script:TestVersionFile -PathType Leaf)){
        $Null = New-Item -Path $Script:TestVersionFile -ItemType 'File' -Force -ErrorAction Ignore
        Set-Content -Path $Script:TestVersionFile -Value $Script:DEFAULT_VERSION
    }
    
}

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
if($Script:TestMode){
    [string]$Script:OnlineScriptFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/test/PSAutoUpdate.ps1'
}


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
    [string]$Script:LatestVersionString  = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
}catch{
    Write-Warning "Error while fetching latest version Id on server. Using UNKNOWN_VERSION $script:UNKNOWN_VERSION"
    [string]$Script:LatestVersionString = $script:UNKNOWN_VERSION
    [string]$Script:LatestVersion = $Script:LatestVersionString
}
    
[Version]$Script:LatestVersion = $Script:LatestVersionString

$Script:IsOnline = Get-NetworkStatus -Quick
Write-Host "✅ Updating Network Status"


Write-Host "Development Setting: DEBUG: "
Write-Host "✅ Updating Network Status"



Write-Host -n -f Yellow "Development Setting: DEBUG: "
if($Script:Debug){ Write-Host -f Red "ENABLED" ; }else { Write-Host -f DarkGreen "DISABLED" ; }
Write-Host  -n -f Yellow "Development Setting: TEST : "
if($Script:TestMode){ Write-Host -f Red "ENABLED" ; }else { Write-Host -f DarkGreen "DISABLED" ; }

Start-Sleep 4


if($EnableTestMode){
    Clear-Host
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " Setting current script version to $Script:DEFAULT_VERSION."
    Set-Content -Path $Script:TestVersionFile -Value $Script:DEFAULT_VERSION
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " Start the script with no argument to test the local vs remote version detection"
    Write-Host -n -f DarkCyan "[SETUP TEST] " ; Write-Host " USAGE INFORMATION"
    Write-Host "No arguments`n`t$PSCommandPath (Use the menu)"

    $HelpStr ="`t1) Start PSAutoUpdate.ps1
        2) Get the current script version ```Get-CurrentScriptVersion```
        3) Get the latest script version that is available on the server (no update) -- ```Get-LatestScriptVersion```
        4) Update the currently running script with latest -- ```Update-ScriptVersion```
"
    # Write-Host -f Blue "$HelpStr"
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
        
        Copy-Item $Script:ScriptFile $Script:BackupFile
        
        Get-OnlineFileNoCache $Script:OnlineScriptFileUrl $Script:ScriptFile
        Write-Host "✅ Updated Script $Script:ScriptFile"
        
        Get-OnlineFileNoCache $Script:OnlineVersionFileUrl $Script:VersionFile
        Write-Host "✅ Updated Version File"
        
        Write-Host "You can restart the script now..."
        return

    }else{
        Write-Host "No Update Required"
    }
}else{

#####################################################################
# MANUAL MODE :  TEST FUNCTIONALITIES USING THE MENU
#####################################################################
    $SoundsPlayed = $False
    do
    {
        if($Script:IsOnline -eq $False){
            Request-OnlineState
            continue
        }
        
        Show-Menu
        $BannerMI = '
 _   _  _  __  __  _  _  _  _   _  _   _  ___  _  __  __  _  ___ _    ___ 
| \_/ || |/ _|/ _|| |/ \| \| | | || \_/ || o \/ \/ _|/ _|| || o ) |  | __|
| \_/ || |\_ \\_ \| ( o ) \\ | | || \_/ ||  _( o )_ \\_ \| || o \ |_ | _| 
|_| |_||_||__/|__/|_|\_/|_|\_| |_||_| |_||_|  \_/|__/|__/|_||___/___||___|
                                                                          
'
        $Banner = '
    ___       _   _________       __   _____ __________  ________  ______   _    ____________  _____ ________  _   __
   /   |     / | / / ____/ |     / /  / ___// ____/ __ \/  _/ __ \/_  __/  | |  / / ____/ __ \/ ___//  _/ __ \/ | / /
  / /| |    /  |/ / __/  | | /| / /   \__ \/ /   / /_/ // // /_/ / / /     | | / / __/ / /_/ /\__ \ / // / / /  |/ / 
 / ___ |   / /|  / /___  | |/ |/ /   ___/ / /___/ _, _// // ____/ / /      | |/ / /___/ _, _/___/ // // /_/ / /|  /  
/_/  |_|  /_/ |_/_____/  |__/|__/   /____/\____/_/ |_/___/_/     /_/       |___/_____/_/ |_|/____/___/\____/_/ |_/   

'
        if($SoundsPlayed -eq $False){
            $job = $j =  New-MissionImpossibleJob
            Set-DisplayColoredText $BannerMI
            $SoundsPlayed = $True
            
        }else{
            Set-DisplayColoredText $Banner
           
        }

        $Position=$HOST.UI.RawUI.CursorPosition
        $ValueX = $Position.X
        $ValueY = $Position.Y + 3
        $a = @($ValueX,$ValueY)
        Invoke-SlidingMessage " THIS SCRIPT WAS RECENTLY UPDATED TO THE LATEST VERSION $Script:LatestVersion" -OverrideTextPosition $a
        $Option = Read-Host -Prompt 'Please select an option'
        switch ($Option)
        {
            0 {Invoke-Hidden}
            
            1 {Invoke-UpdatedScript}
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




