
$MainColor = 'Magenta'
$SpecialColor = 'Red'
$ScriptsPath = $env:ScriptsRoot
$ModulePath = Join-Path $ScriptsPath "PowerShell\Invoke-MsBuild\src\Invoke-MsBuild\Invoke-MsBuild.psm1"

Clear-Host
Write-Host "Importing Module Invoke-MsBuild..." -f $MainColor
Import-Module -Name $ModulePath

$SolutionPath="D:\LatestCode\service.station.mgr"
$ServiceProject = "bccmhost-srv.vcxproj"
$ServiceTesterProject = "bccmhost-srv-runner.vcxproj"

$SolutionFilePath = Join-Path $SolutionPath "bccmhost-srv-runner.sln"
$MainBuildProjectsPath = Join-Path $SolutionPath "build"
$ExternalPath = Join-Path $SolutionPath "external"
$NetlibPath = Join-Path $ExternalPath "netlib"

$ClientProjectPath = Join-Path $NetlibPath "examples\netclient.vcxproj"

$ServiceProjectFilePath = Join-Path $MainBuildProjectsPath $ServiceProject


$Configurations = @('Clean','Debug','Release')
$Platforms = @('x86','x64')

Function CleanAll
{
    Write-Host "============================================"  -f $MainColor
    Write-Host "Cleaning previous build files..."  -f $MainColor
    $Platforms | ForEach-Object {
        Write-Host "Clean " -Nonewline -f $MainColor
        Write-Host "$PSItem"  -Nonewline -f $SpecialColor
         Write-Host " .... " -f $MainColor
        $Parameters = "/target:Clean /property:Configuration=Debug;Platform=$PSItem;BuildInParallel=true /verbosity:Normal /maxcpucount"
        Invoke-MsBuild -Path $SolutionFilePath -MsBuildParameters $Parameters > $null
    }
}

Function BuildAll
{
param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Configuration = 'Debug',
        [string]$Platform = 'x86'
    )

    $Parameters = "/target:Build /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $SolutionFilePath -ShowBuildOutputInNewWindow -PromptForInputBeforeClosing -MsBuildParameters $Parameters
}

Function BuildClient
{

    $Parameters = "/target:Build /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $ClientProjectPath -ShowBuildOutputInNewWindow -PromptForInputBeforeClosing -MsBuildParameters $Parameters
}


#$CleanParameters =  "/target:Clean /property:Configuration=Debug;Platform=x86;BuildInParallel=true /maxcpucount"
#

#
CleanAll
BuildAll 'Debug'
BuildClient 