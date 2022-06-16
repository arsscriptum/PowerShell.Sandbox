
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


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


function Update-NetworkStatus{
    [CmdletBinding(SupportsShouldProcess)]
    param(

    ) 
        Clear-Host
        Write-Host -f DarkRed  "`tPLEASE WAIT - UPDATING NETWORK STATUS"
        Write-Host -f DarkYellow  "`t==================================`n`n"
        $Script:IsOnline = (Test-NetConnection -ComputerName 'github.com')
        Start-Sleep 2
    

}


function uiml{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    ) 

    Write-Host -n -f White "$Message"
}

$Script:NetConnectionVerbosity = 'Quiet'
Remove-Alias -Name 'Test-NetConnection' -ErrorAction Ignore
function Test-CustomNetConnection {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = 'localhost',

        [Parameter(Mandatory=$false)]
        [string]$InformationLevel = 'Quiet'
    )

    $f = Get-Command -Name 'Test-NetConnection' -CommandType Function
    & $f -ComputerName $ComputerName -InformationLevel 'Quiet'
}

New-Alias -Name 'Test-NetConnection' -Value 'Test-CustomNetConnection' -ErrorAction Ignore


function Update-AllVersionValues{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$CurrentVersionUpdate,
        [Parameter(Mandatory=$false)]
        [switch]$LatestVersionUpdate,
        [Parameter(Mandatory=$false)]
        [switch]$CheckOnline
    ) 


    [string]$Script:CurrentVersionString = "__CURRENT_VERSION_STRING__"
    if($Script:CurrentVersionString -eq '__CURRENT_VERSION_STRING__'){
        [string]$Script:CurrentVersionString = $Script:DEFAULT_VERSION
    }
    

    if ( ($PSBoundParameters.ContainsKey('CurrentVersionUpdate')) -And ($CurrentVersionUpdate -ne $Null) -And   ($CurrentVersionUpdate -ne '')){ 
        #Write-Host -n -f Cyan "[Update-AllVersionValues] "
        #Write-Host "CurrentVersionUpdate ==> $CurrentVersionUpdate"
        $Script:CurrentVersionString = $CurrentVersionUpdate
    }
    if ( ($PSBoundParameters.ContainsKey('LatestVersionUpdate')) -And ($LatestVersionUpdate -ne $Null) -And   ($LatestVersionUpdate -ne '')){ 
        #Write-Host -n -f Cyan "[Update-AllVersionValues] "
        #Write-Host "LatestVersionUpdate ==> $LatestVersionUpdate"
        $Script:LatestScriptVersionString = $LatestVersionUpdate
    }

    if($CheckOnline){
        [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
    }
    [Version]$Script:CurrentVersion =  $Script:CurrentVersionString
    [string]$script:LatestScriptRevision = $Script:LatestScriptVersionString

    #Write-Host -n -f Yellow "[Update-AllVersionValues] "
    #Write-Host "CurrentVersion ==> $Script:CurrentVersion"

    #Write-Host -n -f Yellow "[Update-AllVersionValues] "
    #Write-Host "LatestScriptRevision ==> $Script:LatestScriptRevision"
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
