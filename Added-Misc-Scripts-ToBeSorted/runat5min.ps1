# =====================================================================
# =====================================================================
#$ErrorActionPreference = 'SilentlyContinue'

$RemoteScriptsPath = $env:REMOTESCRIPTS
$VarIsLocal = [System.Environment]::GetEnvironmentVariable('IsLocal',[System.EnvironmentVariableTarget]::Process) ;
$VarIsRemote = [System.Environment]::GetEnvironmentVariable('IsRemote',[System.EnvironmentVariableTarget]::Process) ;


Function OutString
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$String,
        [string]$FgColor = "w",
        [string]$BgColor ="b"
    )

    Write-Host $String
}


Function CheckForLocalOrRemote
{
    OutString "=============================================="
    OutString "CheckForLocalOrRemote..."

    $LocalConnResult = Test-NetConnection -ComputerName 'localhost' -Port 80
    if($LocalConnResult.TcpTestSucceeded -eq $True)
    {
        [System.Environment]::SetEnvironmentVariable('IsLocal', $True,[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('IsRemote', $False,[System.EnvironmentVariableTarget]::Process)
        $VarIsLocal = $True;
        $VarIsRemote = $False
    }
    else 
    {
        [System.Environment]::SetEnvironmentVariable('IsLocal', $False,[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('IsRemote', $True,[System.EnvironmentVariableTarget]::Process)
        $VarIsLocal = $False;
        $VarIsRemote = $True
    }
    
}




Function ConfigureRemoteScriptsPath
{
    if ($env:REMOTESCRIPTS -eq $null) 
    {
        $RemoteScriptsPath = Join-Path $env:TEMP "RemoteScripts"
        $env:REMOTESCRIPTS = $RemoteScriptsPath
        Set-Item -Path Env:REMOTESCRIPTS -Value $RemoteScriptsPath
    }

    if((Test-Path -Path $RemoteScriptsPath) -eq $False)
    {
        New-Item -Type 'directory' -Path c:\TmpTmpTmp\test -Force
    }

    OutString "=============================================="
    OutString "RemoteScriptsPath is $RemoteScriptsPath"
}


# PowerShell v2/3 caches the output stream. Then it throws errors due
# to the FileStream not being what is expected. Fixes "The OS handle's
# position is not what FileStream expected. Do not use a handle
# simultaneously in one FileStream and in Win32 code or another
# FileStream."
function Fix-PowerShellOutputRedirectionBug {
  $poshMajorVerion = $PSVersionTable.PSVersion.Major

  if ($poshMajorVerion -lt 4) {
    try{
      # http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
      $objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
      $consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
      [void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
      $field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
      $field.SetValue($consoleHost, [Console]::Out)
      [void] $consoleHost.GetType().GetProperty("IsStandardErrorRedirected", $bindingFlags).GetValue($consoleHost, @())
      $field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
      $field2.SetValue($consoleHost, [Console]::Error)
    } catch {
      Write-Output "Unable to apply redirection fix."
    }
  }
}

Fix-PowerShellOutputRedirectionBug

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

Clear-Host
ConfigureRemoteScriptsPath
CheckForLocalOrRemote


$LatestUrl='http://localhost/remote.txt'

if ($VarIsLocal -eq $true -or $VarIsRemote -eq $false) 
{
  OutString "Using **LOCAL** configuration"
  $LatestUrl='http://localhost/remote.txt'
}
if ($VarIsRemote -eq $true) 
{
  OutString "Using **REMOTE** configuration"
  $LatestUrl='http://69.173.128.122/remote.txt'
}

if ($env:REMOTESCRIPTS -eq $null) {
  $env:REMOTESCRIPTS = Join-Path $env:TEMP New-Guid
}


$localFile = Join-Path $RemoteScriptsPath "check.txt"
Write-Output "Getting scripts from $LatestUrl."

$webclient = New-Object Net.WebClient
$remotecheck = $webclient.DownloadString($LatestUrl)


if($remotecheck -like "EXECUTE-REMOTE")
{
    if ($VarIsLocal -eq $true -or $VarIsRemote -eq $false) 
    {
      OutString "Using **LOCAL** configuration" 
      $LatestUrl='http://localhost/exec.ps1'
    }
    if ($VarIsRemote -eq $true) 
    {
      OutString "Using **REMOTE** configuration" 
      $LatestUrl='http://69.173.128.122/exec.ps1'
    }

    OutString "Downloading $LatestUrl,$localFile"
    $ScriptCode = $webclient.DownloadString($LatestUrl)

    OutString "=========================================="
    OutString "==========================================" 
    OutString "=========================================="
    OutString "$ScriptCode"
}
else {
    exit 1
}


