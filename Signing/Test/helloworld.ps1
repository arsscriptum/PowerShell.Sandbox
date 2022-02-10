<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Profile
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



    <#
    .SYNOPSIS
        Updates the environment variables for the current PowerShell session with any environment variable changes that may have occurred during script execution.
    .DESCRIPTION
        Environment variable changes that take place during script execution are not visible to the current PowerShell session.
        Use this Function Script:to refresh the current PowerShell session with all environment variable settings.
    .PARAMETER LoadLoggedOnUserEnvironmentVariables
        If script is running in SYSTEM context, this option allows loading environment variables from the active console user. If no console user exists but users are logged in, such as on terminal servers, then the first logged-in non-console user.
    .PARAMETER ContinueOnError
        Continue if an error is encountered. Default is: $true.
    .EXAMPLE
        Update-SessionEnvironmentVariables
    .NOTES
        This Function Script:has an alias: Refresh-SessionEnvironmentVariables
    .LINK
        http://psappdeploytoolkit.com
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [switch]$ContinueOnError = $true
    )

    
    

    $a = 'a'
    while($a -ne 'q'){
        Write-Host "`n`n"
        Write-Host -n -f DarkRed "`t`t`tHELLO" ; Write-Host -f DarkYellow " WORLD"
        Write-Host -n -f DarkMagent "`t`t`t-----" ; Write-Host -n -f DarkCyan " -----`n`n"
        $a = Read-Host '"q" to quit: '    
    }


    Write-Host -n -f Red "`t`t`tGOOD" ; Write-Host -f Yellow " BYE"
    Write-Host -n -f Magenta "`t`t`t----" ; Write-Host -f Cyan " ---`n`n"

    
