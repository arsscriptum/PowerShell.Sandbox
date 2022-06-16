
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
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




function Get-CurrentScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
   
    [Version]$Script:CurrentVersion =  $Script:CurrentVersionString
    $Current = $Script:CurrentVersion.ToString()

    #===============================================================================
    # Show our data in the menu...
    #===============================================================================
    Write-Host -f DarkYellow "`tCURRENT VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";
    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Current";
    Write-Host -n -f DarkYellow "`tVersion String`t`t"; Write-Host -f DarkRed "$Script:CurrentVersionString`n`n";

    Read-Host -Prompt 'Press any key to return to main menu'
}

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
    ) 

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $PwshExe = (Get-Command 'pwsh.exe').Source
        Write-Host -f DarkYellow "`n$PwshExe -NoProfile -File `"$PSCommandPath`"`n`n"
        Start-Sleep 3
        Start-Process $PwshExe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
}

