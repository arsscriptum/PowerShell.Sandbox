
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false,Position=0)]
    [string[]]$Arguments,
    [switch]$Urgent
)




class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'AUTOELEVATE'
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()


function Write-Message{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Urgent
    )
    Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
    if($Urgent -eq $False){
        Write-Host "$Message" -f $($Script:ChannelProps.MessageColor)
    }else{
        Write-Host "$Message" -f $($Script:ChannelProps.ErrorColor)
    }
}



$RegPath = "$ENV:OrganizationHKCU\Powershell\Scripts\AdminAutoElevate"
$Cmd = Get-RegistryValue $RegPath "Command" 
if($Cmd -eq $Null){
  Write-Message "Creating Registry Value $RegPath"
  $Null = New-Item -Path $RegPath -ItemType Directory -Force 
  
}else{
  Write-Message "Cmd is $Cmd"
}
Write-Message "PSCommandPath is $PSCommandPath" -Urgent

Write-Message "Arguments is $Arguments"
$null = New-RegistryValue $RegPath "Script" "$PSCommandPath" String
$null = New-RegistryValue $RegPath "Command" "$PSCommandPath" String
$null = New-RegistryValue $RegPath "Arguments" "$Arguments" String
    Write-Host "5, " -n -f DarkGreen;Start-Sleep 1;
    Write-Host "4, " -n -f DarkGreen;Start-Sleep 1;
    Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
    Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
    Write-Host "2, " -n -f DarkRed;Start-Sleep 1;
    Write-Host "1, " -n -f DarkRed;Start-Sleep 1;

function Invoke-AutoElevate
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    #This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Message "You didn't run this script as an Administrator." -Urgent
    Write-Message "This script will self elevate to run as an Administrator and continue." -Urgent
    Start-Sleep 1
    Write-Host "5, " -n -f DarkGreen;Start-Sleep 1;
    Write-Host "4, " -n -f DarkGreen;Start-Sleep 1;
    Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
    Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
    Write-Host "2, " -n -f DarkRed;Start-Sleep 1;
    Write-Host "1, " -n -f DarkRed;Start-Sleep 1;

    Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

   
}
