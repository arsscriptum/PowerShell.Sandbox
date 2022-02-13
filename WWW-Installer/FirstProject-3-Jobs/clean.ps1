# =====================================================================
# =====================================================================

$VarIsLocal = [System.Environment]::GetEnvironmentVariable('IsLocal',[System.EnvironmentVariableTarget]::Process) ;
$VarIsRemote = [System.Environment]::GetEnvironmentVariable('IsRemote',[System.EnvironmentVariableTarget]::Process) ;

Clear-Host;
Write-Host "====================================================================" -Foreground Yellow
Write-Host "====================" -NoNewLine -Foreground Yellow
Write-Host ">>>>>> " -NoNewLine -Foreground Red
Write-Host "Install Scripts" -NoNewLine -Foreground Blue
Write-Host "<<<<<" -NoNewLine -Foreground Red
Write-Host "====================" -NoNewLine -Foreground Yellow
Write-Host "====================================================================" -Foreground Yellow

Write-Host "====================================================================" -Foreground Yellow
Write-Host "IsLocal" -NoNewLine -Foreground Yellow
Write-Host "$VarIsLocal" -NoNewLine -Foreground Red
Write-Host " net status " -NoNewLine -Foreground Blue
Write-Host "IsRemote" -NoNewLine -Foreground Red
Write-Host "$VarIsRemote" -NoNewLine -Foreground Yellow
Write-Host "====================================================================" -Foreground Yellow

$LatestUrl='http://localhost/clean/clean.ps1'

if ($VarIsLocal -eq $true -or $VarIsRemote -eq $false) 
{
  Write-Output "Using **LOCAL** configuration" -Foreground Red
  $LatestUrl='http://localhost/clean/clean.ps1'
}
if ($VarIsRemote -eq $true) 
{
  Write-Output "Using **REMOTE** configuration" -Foreground Red
  $LatestUrl='http://69.173.128.122/clean/clean.ps1'
}

if ($env:TEMPTEMP -eq $null) {
  $env:TEMPTEMP = Join-Path $env:SystemDrive 'temptemptemp'
}

$tempDir = Join-Path $env:TEMPTEMP "clean"

if (![System.IO.Directory]::Exists($tempDir)) {[void][System.IO.Directory]::CreateDirectory($tempDir)}

$file = Join-Path $tempDir "clean.ps1"


# Attempt to set highest encryption available for SecurityProtocol.
# PowerShell will not set this by default (until maybe .NET 4.6.x). This
# will typically produce a message for PowerShell v2 (just an info
# message though)
try {
  # Set TLS 1.2 (3072) as that is the minimum required by Chocolatey.org.
  # Use integers because the enumeration value for TLS 1.2 won't exist
  # in .NET 4.0, even though they are addressable if .NET 4.5+ is
  # installed (.NET 4.5 is an in-place upgrade).
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
} catch {
  Write-Output 'Unable to set PowerShell to use TLS 1.2. This is required for contacting Chocolatey as of 03 FEB 2020. https://chocolatey.org/blog/remove-support-for-old-tls-versions. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3+, (2) Call [System.Net.ServicePointManager]::SecurityProtocol = 3072; in PowerShell prior to attempting installation, (3) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (4) use the Download + PowerShell method of install. See https://chocolatey.org/docs/installation for all install options.'
}

function Get-Downloader {
param (
  [string]$url
 )

  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null) {
    $downloader.Credentials = $defaultCreds
  }

  $ignoreProxy = $env:chocolateyIgnoreProxy
  if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
    Write-Debug "Explicitly bypassing proxy due to user environment variable"
    $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
  } else {
    # check if a proxy is required
    $explicitProxy = $env:chocolateyProxyLocation
    $explicitProxyUser = $env:chocolateyProxyUser
    $explicitProxyPassword = $env:chocolateyProxyPassword
    if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
      # explicit proxy
      $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
      if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
        $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
        $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
      }

      Write-Debug "Using explicit proxy server '$explicitProxy'."
      $downloader.Proxy = $proxy

    } elseif (!$downloader.Proxy.IsBypassed($url)) {
      # system proxy (pass through)
      $creds = $defaultCreds
      if ($creds -eq $null) {
        Write-Debug "Default credentials were null. Attempting backup method"
        $cred = get-credential
        $creds = $cred.GetNetworkCredential();
      }

      $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
      Write-Debug "Using system proxy server '$proxyaddress'."
      $proxy = New-Object System.Net.WebProxy($proxyaddress)
      $proxy.Credentials = $creds
      $downloader.Proxy = $proxy
    }
  }

  return $downloader
}

function Download-String {
param (
  [string]$url
 )
  $downloader = Get-Downloader $url

  return $downloader.DownloadString($url)
}

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  #Write-Output "Downloading $url to $file"
  $downloader = Get-Downloader $url

  $downloader.DownloadFile($url, $file)
}

if ($url -eq $null -or $url -eq '') 
{
  Download-File $LatestUrl 'address.txt'
  $url = Get-Content 'address.txt'
  remove-item 'address.txt'
}

Write-Output "Getting scripts from $LatestUrl."
Download-File $LatestUrl $file

& $file
