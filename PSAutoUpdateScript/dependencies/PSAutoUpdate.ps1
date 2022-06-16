
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
        [switch]$AutoCheck
    )  



#===============================================================================
# Variables
#===============================================================================

[string]$Script:VarsFile = Join-Path $PSScriptRoot 'dependencies/Vars.ps1'
[string]$Script:DepsFile = Join-Path $PSScriptRoot 'dependencies/Deps.ps1'
$Script:OnlineVersionFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/Version.nfo'
$Script:OnlineScriptFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/PSAutoUpdate.ps1'
$Script:Debug = $false
Write-Host "Loading system information. Please wait . . ."
[string]$script:DEFAULT_VERSION = '1.0.0.0'
[string]$Script:CurrentVersionString = "2.0.1.2"
if($Script:CurrentVersionString -eq '__CURRENT_VERSION_STRING__'){
    [string]$Script:CurrentVersionString = $script:DEFAULT_VERSION
}




#===============================================================================
# Check dependencies
#===============================================================================
if(-not(Test-Path -Path $Script:VarsFile -PathType Leaf)){
    Write-Host -f DarkRed "[ERROR] " -NoNewline
    Write-Host " + Missing dependencies File '$Script:VarsFile'" -f DarkGray
    return
}

if(-not(Test-Path -Path $Script:DepsFile -PathType Leaf)){
    Write-Host -f DarkRed "[ERROR] " -NoNewline
    Write-Host " + Missing dependencies File '$Script:DepsFile'" -f DarkGray
    return
}


#===============================================================================
# dependencies
#===============================================================================


. "$Script:DepsFile"
. "$Script:VarsFile"


Update-AllVersionValues -CheckOnline
Update-NetworkStatus

Start-Sleep 5
function Invoke-Hidden{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Invoke-Script{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Get-CurrentScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
   
    [Version]$Script:CurrentVersion =  $Script:CurrentVersionString
    $Current = $Script:CurrentVersion.ToString()
    Write-Host -f DarkYellow "`tCURRENT VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";

    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Current";
    Write-Host -n -f DarkYellow "`tVersion String`t`t"; Write-Host -f DarkRed "$Script:CurrentVersionString`n`n";

    Read-Host -Prompt 'Press any key to return to main menu'
}

function Get-LatestScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 

    [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    $Current = $Script:CurrentVersion.ToString()

    [Version]$Script:LatestVersion = $Script:LatestVersionString
    Write-Host -f DarkYellow "`tLATEST VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";
    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Current";
    
    Write-Host -n -f DarkYellow "`tLatest Version`t`t"; Write-Host -f DarkRed "$Script:LatestVersionString";
    Write-Host -n -f DarkYellow "`tLatest Object`t`t"; Write-Host -f DarkRed "$Script:LatestVersion";


    Read-Host -Prompt 'Press any key to return to main menu'

    


}

function Update-ScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    [Version]$Script:LatestVersion = $Script:LatestVersionString
    if($Script:CurrentVersion -lt $Script:LatestVersion){
        Write-Host -f DarkYellow "`t VERSION UPDATE"; Write-Host -f DarkRed "`t===============================`n";
        Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$CurrentVersion";
        Write-Host -n -f DarkYellow "`tLatest Version`t`t"; Write-Host -f DarkRed "$Script:LatestVersion";
        Write-Host -n -f DarkYellow "`tLocal Script Path`t`t"; Write-Host -f DarkRed "$Script:ScriptFile`n";
        Write-Host -n -f DarkGray "Backup Current Script. $Script:ScriptFile to $Script:BackupFile   "
        Copy-Item $Script:ScriptFile $Script:BackupFile
        Write-Host -f DarkGreen "Done";
        Write-Host -n -f DarkGray "Download Latest...   "
        Get-OnlineFileNoCache $Script:OnlineScriptFileUrl $Script:TmpScriptFile
        Write-Host -f DarkGreen "Done";
        Write-Host -n -f DarkGray "Update Version String in script...   "
        $Script:FileContent = (Get-Content -Path $Script:TmpScriptFile -Encoding "windows-1251" -Raw)
        $Script:FileContent = $Script:FileContent -replace "CurrentVersionString = `"__CURRENT_VERSION_STRING__`"", "CurrentVersionString = `"$Script:LatestVersionString`"" 
        Set-Content -Path $Script:TmpScriptFile -Value $Script:FileContent -Encoding "windows-1251" 
        Write-Host -f DarkGreen "Done";

        if($Script:Debug){
            Read-Host -Prompt 'Press any key to check diffs'
            &"C:\Programs\Shims\Compare.exe" "$Script:BackupFile" "$Script:TmpScriptFile"
        }

        Read-Host -Prompt 'Press any key to reload script'
        Copy-Item $Script:TmpScriptFile $Script:ScriptFile
  
        $PwshExe = (Get-Command 'pwsh.exe').Source
        Write-Host -f DarkYellow "`n$PwshExe -NoProfile -File `"$PSCommandPath`"`n`n"
        Start-Sleep 3
        Start-Process $PwshExe -ArgumentList "-NoProfile -File `"$PSCommandPath`""

    }else{
        Write-Host "No Update Required"
    }
}

function Get-AllPreviousVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
       
    ) 
Clear-Host
        Write-Host -f DarkRed  "`tGIT REVISIONS"
        Write-Host -f DarkYellow  "`t===============`n`n"
     $val = git log --oneline
     $val
        Read-Host -Prompt 'Press any key to go back'
}

function Start-Admin{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

        
        
        # Prompt for Administrator rights
        #/======================================================================================/
        # Check if the shell is running as Administrator. If not, call itself with "Run as
        # Admin", then quit
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
           $PwshExe = (Get-Command 'pwsh.exe').Source
            Write-Host -f DarkYellow "`n$PwshExe -NoProfile -File `"$PSCommandPath`"`n`n"
           Start-Sleep 3
            Start-Process $PwshExe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
          Exit
        }
}



# Display Main Menu
#/======================================================================================/
function Show-Menu
{
    Clear-Host

    uimt 'General Functions                                                  ' -t; uimt "System Info`n" -t
    uimt '=======================================================            '; uimt "======================================`n" ; 
    uiml " 1. Run Local Script                                               "; uimi "Hostname:                    $HostName" -t;
    uiml " 2. Get Current Version Information                                "; uimi "Administrarot                $IsAdmin" -t;
    uiml " 3. Get Latest Script Version (no update)                          "; uimi "Network Status (is online)   $Script:IsOnline" -t;
    uiml " 4. Update Local Script file if new version available              "; uimi "IPv4 Address:                $IPv4" -t;
    uiml " 5. List Revisions                                                 "; uimi "`n"
    uiml "                                                                   "; uimt " Script Information`n" -t
    uimt "                                                                   "; uimt "======================================`n"
    uimi "A) Admin Mode                                                      " -s; uimi "Current Script Version:   $Script:CurrentVersion"
    uimi "N) Update Network Status                                           " -s; uimi "Current Script GIT rev    $Script:CurrentGitRev"
    uimi "X) Exit                                                            " -s; uimi "Latest Script Version     $Script:LatestVersion"
    uiml "                                                                   "; uimi "Latest Script GIT rev        $Script:LatestGitRevision"
   
}
#//====================================================================================//


# Prompt to show at the end of each function
#/======================================================================================/
function Show-End
{
    Write-Host ""
    Write-Host "Operation complete."
    Write-Host "Press any key to return to the menu."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}
#//====================================================================================//

function Invoke-NetTest
{
        return
    if($Script:IsOnline -eq $False){
        Clear-Host
        Write-Host -f DarkRed  "`tYOU ARE OFFLINE"
        Write-Host -f DarkYellow  "`t===============`n`n"
        Write-Host -f Yellow  "You are not connected to the internet. You cannot update the script!`n`n"
        Start-Sleep 2
            do{
                Read-Host -Prompt 'Press any key to test network'
                $Script:IsOnline = (Test-CustomNetConnection -ComputerName 'github.com')
            }while($Script:IsOnline -eq $False)
            cls
    }


}


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




# Main menu selections
#/======================================================================================/
    do
    {
        if($Script:IsOnline -eq $False){
            Invoke-NetTest
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





