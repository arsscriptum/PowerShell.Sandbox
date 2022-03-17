    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = '',   
        [Parameter(Mandatory=$false)]
        [string]$ProgramName  = 'SpeedTest',  
        [Parameter(Mandatory=$false)]
        [switch]$CreateShim
    )


if($Path -eq ""){
    $Path = [Environment]::GetFolderPath("ProgramFiles")
    $Path = Join-Path $Path $Script:ProgramName 
    New-Item -Path $Path -ItemType Directory -Force -ErrorAction Ignore | Out-Null 
}else{
    $Path = Join-Path $Path $Script:ProgramName
    If(test-path $Path -PathType 'Container'){
        throw "Path already exist: $Path"
    }
}

$Script:CurrentPath  = $PSScriptRoot
$Script:InstallPath  = $Path
$Script:SpeedTestExe = Join-Path $Script:InstallPath 'speedtest.exe'
$Script:ArchiveFile  = New-RandomFilename -Extension 'zip'
$Script:Url          = 'https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip'


Write-Host "===============================================================================" -f DarkRed
Write-Host "SETUP of SPEED TEST" -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed    
Write-Host "Current Path  `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CurrentPath" -f Gray 
Write-Host "ProgramName   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ProgramName" -f Gray 
Write-Host "InstallPath   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:InstallPath" -f Gray 
Write-Host "Url           `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:Url" -f Gray 
Write-Host "ArchiveFile   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ArchiveFile" -f Gray 


class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'Install'
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()


function Write-SLog{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$Optional
    )

    Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
    if($PSBoundParameters.ContainsKey('Optional')){
        Write-Host "$Message" -f $($Script:ChannelProps.MessageColor) -NoNewLine
        Write-Host "$Optional" -f $($Script:ChannelProps.SuccessColor)
    }else{
        Write-Host "$Message" -f $($Script:ChannelProps.MessageColor)
    }
}

function New-RandomFilename{
<#
    .SYNOPSIS
            Create a RandomFilename 
    .DESCRIPTION
            Create a RandomFilename 
#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$ENV:Temp",
        [Parameter(Mandatory=$false)]
        [string]$Extension = 'tmp',
        [Parameter(Mandatory=$false)]
        [int]$MaxLen = 6,
        [Parameter(Mandatory=$false)]
        [switch]$CreateFile,
        [Parameter(Mandatory=$false)]
        [switch]$CreateDirectory
    )    
    try{
        if($MaxLen -lt 4){throw "MaxLen must be between 4 and 36"}
        if($MaxLen -gt 36){throw "MaxLen must be between 4 and 36"}
        [string]$filepath = $Null
        [string]$rname = (New-Guid).Guid
        Write-Verbose "Generated Guid $rname"
        [int]$rval = Get-Random -Minimum 0 -Maximum 9
        Write-Verbose "Generated rval $rval"
        [string]$rname = $rname.replace('-',"$rval")
        Write-Verbose "replace rval $rname"
        [string]$rname = $rname.SubString(0,$MaxLen) + '.' + $Extension
        Write-Verbose "Generated file name $rname"
        if($CreateDirectory -eq $true){
            [string]$rdirname = (New-Guid).Guid
            $newdir = Join-Path "$Path" $rdirname
            Write-Verbose "CreateDirectory option: creating dir: $newdir"
            $Null = New-Item -Path $newdir -ItemType "Directory" -Force -ErrorAction Ignore
            $filepath = Join-Path "$newdir" "$rname"
        }
        $filepath = Join-Path "$Path" $rname
        Write-Verbose "Generated filename: $filepath"

        if($CreateFile -eq $true){
            Write-Verbose "CreateFile option: creating file: $filepath"
            $Null = New-Item -Path $filepath -ItemType "File" -Force -ErrorAction Ignore 
        }
        return $filepath
        
    }catch{
        Show-ExceptionDetails $_ -ShowStack
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


Write-SLog "Download Arhive from $Script:Url to $Script:ArchiveFile"
Get-OnlineFileNoCache -Url $Url -Path $ArchiveFile

If(test-path $ArchiveFile -PathType 'leaf'){
    Write-SLog "Expand Arhive to $Script:InstallPath"
    $Null = Expand-Archive $Script:ArchiveFile -DestinationPath $Script:InstallPath -ErrorAction Ignore


    If(test-path $Script:SpeedTestExe -PathType 'leaf'){
        Write-SLog "$Script:SpeedTestExe installed!"
    }else{
        Write-SLog "Speed Test Exe install error! $Script:SpeedTestExe not found"
        return
    }

    $RegPath = "$ENV:OrganizationHKCU\$Script:ProgramName"
    $null = (New-Item $RegPath -Force).Name
    $null = New-ItemProperty -Path $RegPath -Name 'SpeedTestExe' -Value "$Script:SpeedTestExe" -Force
    Write-SLog "Added $RegPath\SpeedTestExe $Script:SpeedTestExe"
    $null = New-ItemProperty -Path $RegPath -Name 'InstallPath' -Value "$Script:InstallPath" -Force
    Write-SLog "Added $RegPath\InstallPath $Script:InstallPath"

    if($CreateShim){
        New-Shim -Target "$Script:SpeedTestExe" -Force
    }
}

Write-SLog "Done"