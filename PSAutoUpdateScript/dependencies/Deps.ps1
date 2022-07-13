
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





######################################################################################################################
#
# TOOLS : BELOW, YOU WILL FIND MISC TOOLS AND GENERIC UTILS THAT ARE NOT SPECIFICALLY RELATED TO THE PSAUTOUPDATE
#         SCRIPT, BUT THEY ARE USED FOR DEMO PURPOSES
#
######################################################################################################################


<#
.SYNOPSIS
   Get the current Network Status: ONLINE (True) or OFFLINE (FALSE)
.DESCRIPTION
   Check if we are online by attempting a connection to 'github.com'
   
   It works in 2 modes: the reason is that I was using Test-NetConnection previously and that legacy call sucks in that it always print a message on screen
   So I changed it so that it was using a parallel job, then I was getting the job status. It was quiet without message on screen
   But then after all that, I became less stupid and used Test-Connection, which is the newest iteration of the connection tester. It can be Quiet and it's fast.
   I kept my code that was using jobs, but added Test-Connection.

   Quick argument : Uses Test-Connection directly --> quite fast.
   Else : Uses jobs and get the connection status after running a few pings
.NOTES
   
#>


function Get-NetworkStatus{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Quick
    ) 
    # Method 1, retarded
    if($Quick){
        try{
            $Connected =  Test-Connection -TargetName 'github.com' -ErrorAction Ignore -Quiet -IPv4 -Count 1
            return $Connected
        }catch{
            return $False
        }   
    }

     # Method 2
    $ReceivedStatus = 0
    $InitialDelay = 1500
    While($ReceivedStatus -eq 0){
        Write-Verbose "Start Job -- Test-Connection -TargetName `"github.com`""
        try{
            $job = Start-Job -ScriptBlock { Test-Connection -TargetName 'github.com' -EA Stop }
        }catch{
            return $False
        }
        
        Write-Verbose "Waiting for $InitialDelay ms"
        Start-Sleep -Milliseconds $InitialDelay
        $NetStatus = (Receive-Job $job).Status
        $ReceivedStatus = $NetStatus.Count
        Write-Verbose "NetStatus: $NetStatus"
        Write-Verbose "ReceivedStatus $ReceivedStatus"

        if($ReceivedStatus -gt 0) { 
            $NetStatusTruncated = $NetStatus[0] 
            if(($NetStatusTruncated -eq 'Success') -Or ($NetStatusTruncated -eq 'Failed') ) { 
                break; 
            }else{
                $InitialDelay += 1000
                Write-Verbose "Will try again with InitialDelay: $InitialDelay"
                $ReceivedStatus = 0
            } 
        }else{
            $InitialDelay += 1000
            Write-Verbose "Will try again with InitialDelay: $InitialDelay"
            $ReceivedStatus  = 0
        }
    }
        
    $NetStatusTruncated = $NetStatus[0]
    Write-Verbose "NetStatusTruncated :  $NetStatusTruncated"
    if($NetStatusTruncated -eq 'Success'){
        return $True
    }
    return $False

}


<#
.SYNOPSIS
   Runs the Get-NetworkStatus function. Then will Update the current Network Status: ONLINE (True) or OFFLINE (FALSE) variable
.DESCRIPTION
   Runs the Get-NetworkStatus function. Then will Update the current Network Status: ONLINE (True) or OFFLINE (FALSE) variable, it is used when we call for this
   function in the GUI.

   Quick argument : Uses Test-Connection directly --> quite fast.
   Else : Uses jobs and get the connection status after running a few pings
.NOTES
   
#>

function Update-NetworkStatus{
    [CmdletBinding(SupportsShouldProcess)]
    
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Quick
    ) 
    if($Quick){
        $Script:IsOnline = Get-NetworkStatus -Quick 
    }else{
        Clear-Host
        Write-Host -f DarkRed  "`tPLEASE WAIT - UPDATING NETWORK STATUS"
        Write-Host -f DarkYellow  "`t==================================`n`n"
        $Script:IsOnline = Get-NetworkStatus
    }   
}


<#
.SYNOPSIS
   NETWORK DOWNLOAD
   Download a file from a server using WebClient. Does magic to make sure that the file is always downloaded even if in local cache.
   Save the file to the local path
.DESCRIPTION
   Download a file from a server using WebClient. Does magic to make sure that the file is always downloaded even if in local cache.
   Support Proxy Server and the UserAgent modification
.NOTES
   
#>


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




<#
.SYNOPSIS
   NETWORK DOWNLOAD
   Download a file in a text stream format. No data is saved locally. 
.DESCRIPTION
   Download a file from a server using WebClient. Does magic to make sure that the file is always downloaded even if in local cache.
   The file is download in a text stream format. No data is saved locally. Does magic to make sure that the file is always downloaded even if in local cache.
   Support Proxy Server and the UserAgent modification.

   This is useful when you don't want to save the downloaded transiant information like the LATEST APP VERSION string stored in an online file
.NOTES
   
#>

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






<#
.SYNOPSIS
   Dump all previous git checksum of thie directory

.DESCRIPTION
   Useful sometimes.
.NOTES   
#>
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



<#
.SYNOPSIS
   Restart this script in with Admin privileges.

.DESCRIPTION
   Useful sometimes.
.NOTES   
#>
function Start-Admin{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $PwshExe = (Get-Command 'pwsh.exe').Source
        Write-Host -f DarkYellow "`n$PwshExe -NoProfile -File `"$PSCommandPath`"`n`n"
        Start-Sleep 3
        Start-Process $PwshExe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
}

function Invoke-Nothing{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    Register-Assemblies
    Show-MessageBox 'EMPTY'
}


{}