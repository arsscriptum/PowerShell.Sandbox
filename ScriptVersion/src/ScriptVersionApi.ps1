

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>





######################################################################################################################
#
# TOOLS : BELOW, YOU WILL FIND MISC TOOLS RELATED TO THE PSAUTOUPDATE SCRIPT. WHEN IN THE GUI YOU ARE CALLING 
#         FUNCTION, IT WILL BE ASSOCIATED TO A FUNCTION HERE.
#
# FUNCTIONS:  - Get-CurrentScriptVersion
#             - Get-LatestScriptVersion
#             - Update-ScriptVersion
#
######################################################################################################################



<#
.SYNOPSIS
   Call this function to get the current, local script version.
.NOTES   
#>
function Get-CurrentScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
   


    [string]$Script:CurrentVersionString = Get-Content -Path $Script:VersionFile
    try{
        [string]$Script:CurrentVersion = $Script:CurrentVersionString
    }catch{
        Write-Warning "Version Error: $Script:CurrentVersionString in file $Script:VersionFile. Using DEFAULT $script:DEFAULT_VERSION"
        [string]$Script:CurrentVersionString = $script:DEFAULT_VERSION
        [string]$Script:CurrentVersion = $Script:CurrentVersionString
    }

    

    #===============================================================================
    # Show our data in the menu...
    #===============================================================================
    Write-Host -f DarkYellow "`tCURRENT VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";
    Write-Host "✅ Current Version detection: $Script:CurrentVersionString"
    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Script:CurrentVersion";
    Write-Host -n -f DarkYellow "`tVersion String`t`t"; Write-Host -f DarkRed "$Script:CurrentVersionString`n`n";

    Read-Host -Prompt 'Press any key to return to main menu'
}


<#
.SYNOPSIS
   Call this function to get the latest script version, the version available online
.NOTES   
#>
function Get-LatestScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 

    try{
        [string]$Script:LatestVersionString         = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    }catch{
        Write-Warning "Error while fetching latest version Id on server. Using UNKNOWN_VERSION $script:UNKNOWN_VERSION"
        [string]$Script:LatestVersionString = $script:UNKNOWN_VERSION
        [string]$Script:LatestVersion = $Script:LatestVersionString
    }
    
    [Version]$Script:LatestVersion              = $Script:LatestVersionString


    #===============================================================================
    # Show our data in the menu...
    #===============================================================================
    Write-Host -f DarkYellow "`tLATEST VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";
    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Current";
    Write-Host -n -f DarkYellow "`tLatest Version`t`t"; Write-Host -f DarkRed "$Script:LatestVersionString";
    Write-Host -n -f DarkYellow "`tLatest Object`t`t"; Write-Host -f DarkRed "$Script:LatestVersion";


    Read-Host -Prompt 'Press any key to return to main menu'
}



<#
.SYNOPSIS
   This function actually implement the steps required when auto-updating this PS Script. See Below for details.

.DESCRIPTION
   This function is pretty straightforward, but still, here's short explanation:
   1) Connect to our script server and get the latest script version. If it has been recently updatedm and that we have an earlier version, Update!
   2) The version check is done with the following variables $Script:CurrentVersion $Script:LatestVersion
   3) We download the script and the version file

   Debug: in DEBUG Mode, I start a compare tool to validate changes

   We reload the script by runnig powershell with thesame argument that was passed in this script.
.NOTES   
#>
function Update-ScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    [Version]$Script:LatestVersion = $Script:LatestVersionString
    if($Script:CurrentVersion -lt $Script:LatestVersion){
        Write-Host -f DarkYellow "`t NEW SCRIPT VERSION AVAILABLE!"; Write-Host -f DarkRed "`t===============================`n";
        
        Copy-Item $Script:ScriptFile $Script:BackupFile
        
        Get-OnlineFileNoCache $Script:OnlineScriptFileUrl $Script:ScriptFile
        Write-Host "✅ Updated Script $Script:ScriptFile"
        
        Get-OnlineFileNoCache $Script:OnlineVersionFileUrl $Script:VersionFile
        Write-Host "✅ Updated Version File"

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

