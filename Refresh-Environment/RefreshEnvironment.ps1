



Function Global:Update-SessionEnvironmentVariables {
<#
.SYNOPSIS
    Updates the environment variables for the current PowerShell session with any environment variable changes that may have occurred during script execution.
.DESCRIPTION
    Environment variable changes that take place during script execution are not visible to the current PowerShell session.
    Use this function to refresh the current PowerShell session with all environment variable settings.
.PARAMETER LoadLoggedOnUserEnvironmentVariables
    If script is running in SYSTEM context, this option allows loading environment variables from the active console user. If no console user exists but users are logged in, such as on terminal servers, then the first logged-in non-console user.
.PARAMETER ContinueOnError
    Continue if an error is encountered. Default is: $true.
.EXAMPLE
    Update-SessionEnvironmentVariables
.NOTES
    This function has an alias: Refresh-SessionEnvironmentVariables
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [switch]$LoadLoggedOnUserEnvironmentVariables = $false,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [boolean]$ContinueOnError = $true
    )

    Begin {
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name

        [scriptblock]$GetEnvironmentVar = {
            Param (
                $Key,
                $Scope
            )
            [Environment]::GetEnvironmentVariable($Key, $Scope)
        }
    }
    Process {
        Try {
            Write-Host 'Refreshing the environment variables for this PowerShell session.'

            If ($LoadLoggedOnUserEnvironmentVariables -and $RunAsActiveUser) {
                [string]$CurrentUserEnvironmentSID = $RunAsActiveUser.SID
            }
            Else {
                [string]$CurrentUserEnvironmentSID = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
            }
            [string]$MachineEnvironmentVars = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            [string]$UserEnvironmentVars = "Registry::HKEY_USERS\$CurrentUserEnvironmentSID\Environment"

            ## Update all session environment variables. Ordering is important here: $UserEnvironmentVars comes second so that we can override $MachineEnvironmentVars.
            $MachineEnvironmentVars, $UserEnvironmentVars | Get-Item | ForEach-Object { if($_){$envRegPath = $_.PSPath; $_.Property | ForEach-Object { Set-Item -LiteralPath "env:$($_)" -Value (Get-ItemProperty -LiteralPath $envRegPath -Name $_).$_ } } }

            ## Set PATH environment variable separately because it is a combination of the user and machine environment variables
            [string[]]$PathFolders = 'Machine', 'User' | ForEach-Object { $EachPathFolder = (& $GetEnvironmentVar -Key 'PATH' -Scope $_); if($EachPathFolder){ $EachPathFolder.Trim(';').Split(';').Trim().Trim('"') } } | Select-Object -Unique
            $env:PATH = $PathFolders -join ';'
        }
        Catch {
            Write-Host "Failed to refresh the environment variables for this PowerShell session. `r`n$(Resolve-Error)" 
            If (-not $ContinueOnError) {
                Throw "Failed to refresh the environment variables for this PowerShell session: $($_.Exception.Message)"
            }
        }
    }

}

Write-Host "===============================================================================" -f DarkRed
Write-Host "Update-SessionEnvironmentVariables" -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed  
Update-SessionEnvironmentVariables


Write-Host "===============================================================================" -f DarkRed
Write-Host "Refresh Environment in Session " -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed  
$RefreshEnvScript=(get-command "RefreshEnv.cmd").Source

if(($RefreshEnvScript -ne $null) -And ($RefreshEnvScript.Length -gt 0)){
   $RefreshEnvScript='C:\ProgramData\chocolatey\bin\RefreshEnv.cmd'
}


Write-Host "[RefreshEnvScript] -> " -NoNewLine -ForegroundColor DarkRed; 
Write-Host "$RefreshEnvScript" -ForegroundColor DarkYellow

&"$Env:ComSpec" /c $RefreshEnvScript

Write-Host "[DONE] " -NoNewLine -ForegroundColor DarkGreen; 
Write-Host " Environment Refreshed!" -ForegroundColor Gray
Write-Host "===============================================================================" -ForegroundColor Gray