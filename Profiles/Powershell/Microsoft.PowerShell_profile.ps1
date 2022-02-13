###########################################################################################
# Powershell Profile
# All Users, Current Host	
# Location: $PSHOME\Microsoft.PowerShell_profile.ps1
# C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1

  #
    #   Function to enable or disable Event channels in Windows
    #
    function ConfigureEventChannel
    {
        param(
            [string] $logName,
            [switch] $Disable
        )

        $bIsDotNet35Above = IsDotNetVersion35
        Write-host "ConfigureEventChannel: $($LogNameArray.Count) channels in array..."  | Out-Null
        #foreach($logName in $LogNameArray)
        #{
        if([string]::IsNullOrEmpty($logName))
        {
            Write-host "ConfigureEventChannel: Logname was empty..."  | Out-Null
            continue
        }

        try {
            if( $bIsDotNet35Above ) {
                $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName

                if($Disable)
                {
                    Write-host "ConfigureEventChannel: Setting $logName to disabled state..."  | Out-Null
                    $log.IsEnabled=$false
                } else {
                    Write-host "ConfigureEventChannel: Setting $logName to enabled state..."  | Out-Null
                    $log.IsEnabled=$true
                }

                $log.SaveChanges()
                Write-host "ConfigureEventChannel: Operation completed..."  | Out-Null
            } 
            else {
                if($Disable)
                {
                    Write-host "ConfigureEventChannel: Setting $logName to disabled state..."  | Out-Null
                    Execute-Cmd -CmdTool "C:\Windows\System32\wevtutil.exe" -ArgumentsToExecute "sl $logName /e:false"
                } else {
                    Write-host "ConfigureEventChannel: Setting $logName to enabled state..."  | Out-Null
                    Execute-Cmd -CmdTool "C:\Windows\System32\wevtutil.exe" -ArgumentsToExecute "sl $logName /e:true"
                }
                Write-host "ConfigureEventChannel: Operation completed..."  | Out-Null
            }
        }
        catch {
            Write-host "ConfigureEventChannel: Exception when trying to enable $logName channel -- Details: $($_.Exception.Message)"  | Out-Null
        }
    } 

    # Sample Usage:
    #
    # To enable admin logging for Windows print Service
    #   ConfigureEventChannel -Logname "Microsoft-Windows-PrintService/Admin"
    #
    # To disable
    #   ConfigureEventChannel -Logname "Microsoft-Windows-PrintService/Admin" -Disable
    #

Function Remove-PowerShellEventLog {
    Write-ToLog -Message 'Remove the PowerShell event log'
    # Function constants
    $PowerShellKey = 'SYSTEM\CurrentControlSet\Services\EventLog\Windows PowerShell'
    $Admins = 'BUILTIN\Administrators'
    $ReadWriteSubTree = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree
    $TakeOwnership = [System.Security.AccessControl.RegistryRights]::TakeOwnership
    $ChangePermissions = [System.Security.AccessControl.RegistryRights]::ChangePermissions

    # Define a C# type using P/Invoke and add it
    # Code borrowed from https://www.remkoweijnen.nl/blog/2012/01/16/take-ownership-of-a-registry-key-in-powershell/
    $Definition = @"
    using System;
    using System.Runtime.InteropServices; 

    namespace Win32Api
    {

        public class NtDll
        {
            [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
            public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
        }
    }
"@
    Add-Type -TypeDefinition $Definition -PassThru

    # Enable SeTakeOwnershipPrivilege
    $Res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $True, $False, [ref]$False)

    # Open the registry key with Take Ownership rights and change the owner to Administrators
    $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("$PowerShellKey\PowerShell", $ReadWriteSubTree, $TakeOwnership)
    $Acl = $Key.GetAccessControl()
    $Acl.SetOwner([System.Security.Principal.NTAccount]$Admins)
    $Key.SetAccessControl($Acl)

    # Re-open the key with Change Permissions rights and grant Administrators Full Control rights
    $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("$PowerShellKey\PowerShell", $ReadWriteSubTree, $ChangePermissions)
    $Acl = $Key.GetAccessControl()
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule ($Admins, 'FullControl', 'Allow')
    $Acl.SetAccessRule($Rule)
    $Key.SetAccessControl($Acl)

    # Remove the parent and subkeys
    Remove-Item -Path "HKLM:\$PowerShellKey" -Force -Recurse

    # Restart the Event Log service to enforce changes
    Restart-Service EventLog -Force
}
    
Function screenshot
{
	iex 'E:\Programs\Screenshot\screenshot.exe'
}
function Sc-Perm
{
	param(
        [string] $scname = "<servicename>"
    )
    clear-host
	write-host "sc sdset $scname D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWRPWPDTLOCRRC;;;SY)" -Foreground Yellow -Nonewline
	write-host "(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;<SID>)" -Foreground Red -Nonewline
	write-host "S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)" -Foreground Yellow
	write-host "Example:"
	write-host "sc sdset $scname D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;S-1-5-21-1948577906-1661106202-805397239-1794)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)" -Foreground Cyan

	Write-Host 'SID: wmic useraccount where name="gplante" or Get-AdUser gplante'
	Get-AdUser gplante
	wmic useraccount where name="gplante"
}
function goto($val)
{
	$path = [System.Environment]::GetEnvironmentVariable($val,'machine')
	$cmd = 'Set-Location $path'
	Write-Host "Changing to $path" -Foreground Yellow
	iex $cmd
}

Function Lock
{
	Lock-BitLocker -MountPoint "G:" -ForceDismount
}

Function Unlock
{
	$SecureString = ConvertTo-SecureString "TooManySecret23" -AsPlainText -Force
	Unlock-BitLocker -MountPoint "G:" -Password $SecureString
}

function ff
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [string] $Pattern
    )
	Write-Host "ff: find file with pattern $Pattern in $Path" -Foreground Red
	Get-ChildItem -Path $Path -Filter $Pattern -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}
	#dir -Path $Path -Filter $Pattern -Recurse | %{$_.FullName}
}

function ex
{
	$path = (Get-Location).Path
	$cmd = 'C:\Windows\explorer.exe $path'
	Write-Host "Opening explorer in $path" -Foreground Yellow
	iex $cmd
}

function Clear-AllEventLogs
{
	Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log } 
	wevtutil el | Foreach-Object {wevtutil cl "$_"}
}

Function SetFolderPermission
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $mypath,
        [string] $who = 'bqc\gplante'
    )
    Write-Host "Setting folder permission on $mypath -> $who" -Foreground Green
	$myacl = Get-Acl $mypath
	$myaclentry = $who,"FullControl","Allow"
	$myaccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($myaclentry)
    Write-Host "Set : $myaclentry" -Foreground Red
	$myacl.SetAccessRule($myaccessrule)
	Get-ChildItem -Path "$mypath" -Recurse -Force | Set-Acl -AclObject $myacl -Verbose
}

Function AddFolderPermission
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $mypath,
        [string] $who = 'bqc\gplante'
    )
    Write-Host "Setting folder permission on $mypath -> $who" -Foreground Green
    $myacl = Get-Acl $mypath
    $myaclentry = $who,"FullControl","Allow"
    $myaccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($myaclentry)
    Write-Host "Add : $myaclentry" -Foreground Red
    $myacl.AddAccessRule($myaccessrule)
    Get-ChildItem -Path "$mypath" -Recurse -Force | Set-Acl -AclObject $myacl -Verbose
}

function Info()
{
	Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -UseBasicParsing  -uri "http://ifconfig.me/ip").Content)
	$modpath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

	$HOSTS = "$env:SystemRoot\system32\drivers\etc\hosts";
	$Desktop = "$env:USERPROFILE\Desktop";
	$Documents = "$env:USERPROFILE\Documents";
	$TimestampServer = "http://timestamp.digicert.com";

	Write-Host 'Welcome to' "$env:computername" -ForegroundColor Green
	Write-Host "You are logged in as" "$env:username"
	Write-Host "Today:" (Get-Date)
}


$myipaddress=(Invoke-WebRequest -UseBasicParsing -uri "http://ifconfig.me/ip").Content
$administrator_tag=""
$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE)
{
	$administrator_tag=" Regular User Account"
}
Else
{
	$administrator_tag=" Running as ADMINISTRATOR"
}

# Personalize the console
$Host.UI.RawUI.WindowTitle = "Windows Powershell " + $administrator_tag + " ( " + $myipaddress + " ) ";


setx toolsroot g:\Scripts > $null
setx toolspath g:\Scripts > $null

Write-Host "Configuring Aliases..." -Foreground Green

function scripts
{
	goto ScriptsRoot
}
function dev
{
	goto DevelopmentRoot
}
function code
{
	goto DevelopmentRoot
}
function tools
{
	goto ToolsRoot
}
function bcadgp
{
	goto BodycadDevBranch
}
function bcad
{
	goto BodycadDevMain
}
function home
{
	cd ~
}
function logs
{
	$path = "$env:APPDATA/../Local/Temp/Bodycad/"
	Set-Location $path
}

Set-Alias -Name subl -Value "C:\Program Files\Sublime Text 3\subl.exe"

Write-Host "-----------------------------------------" -Foreground Magenta
Write-Host "powershell - current user: $env:USERNAME" -Foreground Magenta
date
Write-Host "useful env variables" -Foreground Magenta
Write-Host "   SystemScriptsPath = $env:SystemScriptsPath"
Write-Host "   ScreenshotFolder = $env:ScreenshotFolder"
Write-Host "   DevelopmentRoot = $env:DevelopmentRoot"
Write-Host "   BodycadDevMain = $env:BodycadDevMain"
Write-Host "   BodycadDevBranch = $env:BodycadDevBranch"
Write-Host "   ScriptsRoot = $env:ScriptsRoot"
Write-Host "   wwwroot = $env:wwwroot"
Write-Host "commands"  -Foreground Green
Write-Host "   dev, code = go in dev dir"
Write-Host "   bcad, bcadgp = bcad path"


Write-Host "PowerShell"($PSVersionTable.PSVersion.Major)"awaiting your commands."


# Write-Host "Set location to ScriptsRoot..." -Foreground Red
# Set-Location $env:ScriptsRoot
