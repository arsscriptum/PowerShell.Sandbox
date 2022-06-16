
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
        [Alias('l')]
        [switch]$ListVersions
    )  



$Script:OnlineVersionFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/Version.nfo'
$Script:OnlineScriptFileUrl = 'https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/PSAutoUpdateScript/PSAutoUpdate.ps1'


# Gather System Info
#/======================================================================================/
Write-Host "Loading system information. Please wait . . ."
[string]$Script:CurrentVersionString = '__CURRENT_VERSION_STRING__'
#[string]$Script:CurrentVersionString = '1.1.2.2'
[Version]$Script:CurrentVersion =  $Script:CurrentVersionString
[string]$Script:RootPath                       = (Get-Location).Path
[string]$script:CurrentGitRev = '' 
[string]$script:LatestScriptVersionString = '0.0.0.0'
[string]$script:LatestScriptRevision = New-Object -TypeName System.Version -ArgumentList $Script:LatestScriptVersionString.Major,$Script:LatestScriptVersionString.Minor,$Script:LatestScriptVersionString.Revision
[string]$Script:ScriptFile = Join-Path $PSScriptRoot 'PSAutoUpdate.ps1'
[string]$Script:TmpScriptFile = Join-Path $ENV:TEMP 'PSAutoUpdate.ps1'
[string]$Script:VersionFile = Join-Path $Script:RootPath 'Version.nfo'
[string]$script:UserName = ((query user | findstr 'Active').split('>')[1]).split('')[0]
[string]$script:User = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
[string]$script:HostName = $ENV:hostname
[string]$script:IsAdmin = $False
[string]$script:IPv4 = (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 1
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
 
}


#===============================================================================
# Check Folders
#===============================================================================

#if(-not(Test-Path -Path $Script:VersionFile -PathType Leaf)){
#    Write-Host -f DarkRed "[ERROR] " -NoNewline
#    Write-Host " + Missing Version File '$Script:VersionFile' (are you in a Module directory)" -f DarkGray
#    return
#}



function uimi{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [switch]$SysOptions
    ) 
    if($Title){
        Write-Host -f Gray "$Message"    
    }elseif($SysOptions){
        Write-Host -n -f Red "$Message"
    }else{

        Write-Host -f Cyan "$Message"
    }
    
}

function uimt{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title
    ) 
    if($Title){
        Write-Host -n -f DarkRed "$Message"    
    }else{
        Write-Host -n -f DarkYellow "$Message"
    }
    
}



function uiml{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    ) 

    Write-Host -n -f White "$Message"
}




function Get-OnlineFileNoCache{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$false)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [string]$ProxyAddress,
        [Parameter(Mandatory=$false)]
        [string]$ProxyUser,
        [Parameter(Mandatory=$false)]
        [string]$ProxyPassword,
        [Parameter(Mandatory=$false)]
        [string]$UserAgent=""
    )

    if( -not ($PSBoundParameters.ContainsKey('Path') )){
        $Path = (Get-Location).Path
        [Uri]$Val = $Url;
        $Name = $Val.Segments[$Val.Segments.Length-1]
        $Path = Join-Path $Path $Name
        Write-Warning ("NetGetFileNoCache using path $Path")
    }
    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ("NetGetFileNoCache''s -ProxyAddress parameter is not tested.")
        $proxy = New-object System.Net.WebProxy "$ProxyAddress"
        $proxy.Credentials = New-Object System.Net.NetworkCredential ($ProxyUser, $ProxyPassword) 
        $client.proxy=$proxy
    }
    
    if($UserAgent -ne ""){
        $Client.Headers.Add("user-agent", "$UserAgent")     
    }else{
        $Client.Headers.Add("user-agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1") 
    }

    $RequestUrl = "$Url"

    if ($ForceNoCache) {
        # doesn’t use the cache at all
        $client.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)

        $RandId=(new-guid).Guid
        $RandId=$RandId -replace "-"
        $RequestUrl = "$Url" + "?id=$RandId"
    }
    Write-Host "NetGetFileNoCache: Requesting $RequestUrl"
    $client.DownloadFile($RequestUrl,$Path)
}

function Get-OnlineStringNoCache{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
       
        [Parameter(Mandatory=$false)]
        [string]$ProxyAddress,
        [Parameter(Mandatory=$false)]
        [string]$ProxyUser,
        [Parameter(Mandatory=$false)]
        [string]$ProxyPassword,
        [Parameter(Mandatory=$false)]
        [string]$UserAgent=""
    )

    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ('NetGetStringNoCache''s -ProxyAddress parameter is not tested.')
        $proxy = New-object System.Net.WebProxy "$ProxyAddress"
        $proxy.Credentials = New-Object System.Net.NetworkCredential ($ProxyUser, $ProxyPassword) 
        $client.proxy=$proxy
    }
    
    if($UserAgent -ne ""){
        $Client.Headers.Add("user-agent", "$UserAgent")     
    }else{
        $Client.Headers.Add("user-agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1") 
    }

    $RequestUrl = "$Url"

    if ($ForceNoCache) {
        # doesn’t use the cache at all
        $client.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)

        $RandId=(new-guid).Guid
        $RandId=$RandId -replace "-"
        $RequestUrl = "$Url" + "?id=$RandId"
    }
    Write-Verbose "NetGetStringNoCache: Requesting $RequestUrl"
    $client.DownloadString($RequestUrl)
}


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
        Write-Host -n -f DarkGray "Download Latest...   "
        Get-OnlineFileNoCache $Script:OnlineScriptFileUrl $Script:TmpScriptFile
        Write-Host -f DarkGreen "Done";
        Write-Host -n -f DarkGray "Update Version String in script...   "
        $Script:FileContent = (Get-Content -Path $Script:TmpScriptFile -Encoding "windows-1251" -Raw)
        $Script:FileContent = $Script:TmpScriptFile -replace "__CURRENT_VERSION_STRING__", $Script:LatestVersionString
        Set-Content -Path $Script:TmpScriptFile -Value $Script:FileContent
        Set-Content -Path $Script:ScriptFile -Value $Script:FileContent
        Write-Host -f DarkGreen "Done";
        Read-Host -Prompt 'Press any key to reload script'

         Start-Process PowerShell.exe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -

    }else{
        Write-Host "No Update Required"
    }
}

function Get-AllPreviousVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

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
            Start-Process PowerShell.exe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
          Exit
        }
}

function Update-NetworkSTatus{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}



# Display Main Menu
#/======================================================================================/
function Show-Menu
{
    Clear-Host

    uimt 'General Functions                                                  ' -t; uimt "System Info`n" -t
    uimt '=======================================================            '; uimt "======================================`n" ; 
    uiml " 1. Run Local Script                                               "; uimi "Hostname:                 $HostName" -t;
    uiml " 2. Get Current Version Information                                "; uimi "Administrarot             $IsAdmin" -t;
    uiml " 3. Get Latest Script Version (no update)                          "; uimi "Network Status            $IsOffline" -t;
    uiml " 4. Update Local Script file if new version available              "; uimi "IPv4 Address:             $IPv4" -t;
    uiml " 5. Update Network Status                                          "; uimi "`n"
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








# Main menu selections
#/======================================================================================/
do
{
    Show-Menu
    $Option = Read-Host -Prompt 'Please select an option'
    switch ($Option)
    {
        0 {Invoke-Hidden}
        1 {Invoke-Script}
        2 {Get-CurrentScriptVersion}
        3 {Get-LatestScriptVersion}
        4 {Update-ScriptVersion}
        5 {Get-CurrentScriptVersion}
        6 {Get-AllPreviousVersion}
        A {Start-Admin}
        N {Update-NetworkSTatus}
        X {Exit}
    }
} until ($Option -eq 'X')
#//====================================================================================//

