<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
##
#>




function Script:AutoUpdateProgress {                           # NOEXPORT
    $Script:ProgressMessage = "Installing $Script:Program... (Method $Script:StepNumber on $Script:TotalSteps)"
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    $Script:StepNumber++
}




function Get-ChocoPath {                            # NOEXPORT

     $ChocoPath = (get-command "choco" -ErrorAction Ignore).Source
     
     if(( $ChocoPath -ne $null ) -And (Test-Path -Path $ChocoPath)){
        return $ChocoPath
     }
     $RegRootPath = "$ENV:OrganizationHKCU\chocolatey"
     $ChocoPath = (Get-ItemProperty -Path $RegRootPath -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     
     if(( $ChocoPath -ne $null ) -And (Test-Path -Path $ChocoPath -PathType Leaf)){
        return $ChocoPath
    } 
}



function Set-ModuleConfiguration {                          
    $RegRootPath = "$ENV:OrganizationHKCU\chocolatey"
    $ChocoPath = (Get-Command choco).Source 
    New-Item -Path $RegRootPath -ErrorAction Ignore
    Set-ItemProperty -Path $RegRootPath -Name 'InstallPath' -Value $ChocoPath

    Set-ChocoLogPath "c:\Temp\Chocolatey\Logs"
    Set-ChocoPackagePath "c:\Temp\Chocolatey\Packages"
}


function Set-ChocoPackagePath{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Path
    )

    if(-not(Test-Path $Path)){
       New-Item -Path $Path -ItemType Directory -Force -ErrorAction Ignore | Out-null 
    }

    Set-Variable -Name ChocoPackagePath -Value $Path -Scope Global -Option readonly,allscope -Force
}


function Set-ChocoLogPath{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Path
    )

    $LogFile = ((Get-Date).GetDateTimeFormats()[8]).Replace(' ','_').ToString() + '.log'
    $LogPath = $Path
    $LogFilePath = Join-Path $LogPath $LogFile
    if(-not(Test-Path $LogPath)){
       New-Item -Path $LogPath -ItemType Directory -Force -ErrorAction Ignore  | Out-null 
    }
    Set-Variable -Name ChocoLogPath -Value $Path -Scope Global -Option readonly,allscope -Force
}


function Add-ChocoPackage{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Package
    )

    $Pkgs = Get-Variable -Name ChocoPackages -ValueOnly -Scope Global -ErrorAction Ignore
    if($Pkgs -eq $null){
        $Pkgs = [System.Collections.ArrayList]::new()
    }
    $null = $Pkgs.Add($Package)

    Set-Variable -Name ChocoPackages -Scope Global -Value $Pkgs
}


function List-ChocoPackage{
    $Pkgs = Get-Variable -Name ChocoPackages -ValueOnly -Scope Global -ErrorAction Ignore
    $Pkgs 
}


function Install-ChocoPackage{

    $Pkgs = Get-Variable -Name ChocoPackages -ValueOnly -Scope Global -ErrorAction Ignore
    $Script:ProgressTitle = 'INSTALLING PACKAGES'
    $Script:StepNumber = 0
    $Script:TotalSteps = $Pkgs.Count

    
    Foreach( $program in $Pkgs ){
        $Script:Program = $program 
        Write-Host "Installing $program [cache-location] , [logs] $Global:ChocoLogPath" -ForegroundColor DarkGray
        choco install $program -y --acceptlicense --cache-location="$Global:ChocoPackagePath" --log-file="$Global:ChocoLogPath"
        Write-Host "[INSTALLED] -> " -NoNewLine -ForegroundColor DarkGreen; 
        Write-Host "$program" -ForegroundColor Yellow
        AutoUpdateProgress
    }


}






