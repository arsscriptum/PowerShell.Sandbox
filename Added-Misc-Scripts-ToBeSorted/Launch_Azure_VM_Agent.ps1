##===----------------------------------------------------------------------===
##  ┌─┐┬ ┬┌┐ ┌─┐┬─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐ 
##  │  └┬┘├┴┐├┤ ├┬┘│  ├─┤└─┐ │ │ │├┬┘ 
##  └─┘ ┴ └─┘└─┘┴└─└─┘┴ ┴└─┘ ┴ └─┘┴└─ 
##  ┌┬┐┌─┐┬  ┬┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┐┌┌┬┐
##   ││├┤ └┐┌┘├┤ │  │ │├─┘│││├┤ │││ │ 
##  ─┴┘└─┘ └┘ └─┘┴─┘└─┘┴  ┴ ┴└─┘┘└┘ ┴ 
##
##  Powershell Script (c) by <cybercastor@icloud.com> 
##===----------------------------------------------------------------------===



<#
    .SYNOPSIS
        Launch an Azure VM
        
    .DESCRIPTION
        
        
    .PARAMETER Group
       
        
    .EXAMPLE
    PS C:\> Get-PowershellVerbs
        
    .NOTES
        
 #>


function ElevateAndRestart
{
    $CommandName = $PSCmdlet.MyInvocation.InvocationName;
    $MyScript = $PSCmdlet.MyInvocation.MyCommand
    $FullScriptPath = Force-Resolve-Path $CommandName 
    $MyPath = (Get-Location).Path
    # Get the list of parameters for the command
    #$ParameterList = (Get-Command -Name $CommandName).Parameters;
    $credz=Get-AppCredentials 'AzureVmScript'
    $startProcessParams = @{
        FilePath               = 'C:\Programs\PowerShell\7\pwsh.exe'
        Wait                   = $true
        PassThru               = $true
        NoNewWindow            = $false
        WorkingDirectory       = $MyPath
        Credential             = $credz
    }

    $cmdName=""
    $cmdId=0
    $cmdExitCode=0

    $ProcessArgs = @()

    $ProcessArgs += '-NoProfile'
    $ProcessArgs += '-NonInteractive'
    $ProcessArgs += '-ExecutionPolicy'
    $ProcessArgs += 'Bypass'
    $ProcessArgs += '-NoExit'
    $ProcessArgs += '-Command'
    $str = '" { & ' + $FullScriptPath + ' -AutoRestart"'
    $ProcessArgs += $str


    $ProcessArgs

    $cmd = Start-Process @startProcessParams -ArgumentList $ProcessArgs
}


function Force-Resolve-Path 
{
    <#
    .SYNOPSIS
        Calls Resolve-Path but works for files that don't exist.
    .REMARKS
        From http://devhawk.net/blog/2010/1/22/fixing-powershells-busted-resolve-path-cmdlet
    #>
    param (
        [string] $FileName
    )

    $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue `
                                       -ErrorVariable _frperror
    if (-not($FileName)) {
        $FileName = $_frperror[0].TargetObject
    }

    return $FileName
}

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
$AdminEnabled=$false
if ($PSBoundParameters.ContainsKey('AutoRestart')) 
{
    if (($AutoRestart) -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') ) 
    {
        Write-Host "Restarted with Administrative privileges!"
        $AdminEnabled=$true
    }
}
else 
{

    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) 
    {
        $func=(Get-Module -Name cybercastor.PwshToolsSuite).ExportedCommands['Show-MessageBox']
        if($func -ne $null) 
        { 
            $ErrorMsgParams = @{
                TitleBackground = "Red"
                TitleTextForeground = "Yellow"
                TitleFontWeight = "UltraBold"
                TitleFontSize = 22
                ContentBackground = 'Red'
                ContentFontSize = 14
                ContentTextForeground = 'White'
                ButtonTextForeground = 'White'
                Sound = 'Windows Hardware Fail'
                FontFamily = 'Lucida Console'
                ButtonType = 'None'
                Timeout = 2
            }
            Show-MessageBox @ErrorMsgParams -Content "This Installation script requires Administrator privileges to run. It will auto-elevates the privileges and restart in 3 seconds." -Title "Requires Elevation!"
           
            ElevateAndRestart
            return
        }
        else 
        {
            Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue." -b DarkGray -f DarkRed
            Write-Host "                                               2"
            Start-Sleep 1
            Write-Host "                                               1"
            Start-Sleep 1
            ElevateAndRestart
            return
        }
    }
    else {
        Write-Host "Started with Administrative privileges!"
        $AdminEnabled=$true
    }
}

if(-not $AdminEnabled)
{
    Write-Host "Cannot continue!"
    return ;
}


Write-Host "===-------------------===" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "===--- CYBERCASTOR ---===" -ForegroundColor Blue -BackgroundColor Black         
Write-Host "===-------------------===" -ForegroundColor Blue -BackgroundColor Black                                                                                          

$CurrentPath = (Get-Location).Path   
Write-Host "CurrentPath:  $CurrentPath" -ForegroundColor DarkYellow
$ProjectUrl='https://dev.azure.com/cybercastor/'
$AzureProjectName='Multi-purpose Service - Remote Management'
$PackageUrl='https://vstsagentpackage.azureedge.net/agent/2.191.1/vsts-agent-win-x64-2.191.1.zip'
$AccessToken='vlw6sxn2maacxxoyeqpl57k73vkqehalsmec24jz2w36lsuia67a'
$ErrorActionPreference="Stop";If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")){ throw "Run command in an administrator PowerShell prompt"};If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." };If(-NOT (Test-Path $env:SystemDrive\'azagent')){mkdir $env:SystemDrive\'azagent'}; cd $env:SystemDrive\'azagent'; for($i=1; $i -lt 100; $i++){$destFolder="A"+$i.ToString();if(-NOT (Test-Path ($destFolder))){mkdir $destFolder;cd $destFolder;break;}}; $agentZip="$PWD\agent.zip";$DefaultProxy=[System.Net.WebRequest]::DefaultWebProxy;$securityProtocol=@();$securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;$securityProtocol+=[Net.SecurityProtocolType]::Tls12;[Net.ServicePointManager]::SecurityProtocol=$securityProtocol;$WebClient=New-Object Net.WebClient; $Uri=$PackageUrl;if($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri))){$WebClient.Proxy= New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True);}; $WebClient.DownloadFile($Uri, $agentZip);Add-Type -AssemblyName System.IO.Compression.FileSystem;[System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");.\config.cmd --environment --environmentname "Development" --agent $env:COMPUTERNAME --runasservice --work '_work' --url $ProjectUrl --projectname $AzureProjectName --auth PAT --token $AccessToken; Remove-Item $agentZip;