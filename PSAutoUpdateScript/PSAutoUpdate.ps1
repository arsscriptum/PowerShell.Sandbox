<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   
#̷𝓍   From the PowerShell forums at https://www.reddit.com/r/PowerShell/comments/vdgush/best_way_to_selfupdate_a_script/ where
#̷𝓍   a user is asking for help with a script that will auto update if new version is available.
#̷𝓍   
#̷𝓍   Have the script hosted on a revision server, like GIT. In the script repository have a small text file with only the latest script version In your script, add the current script version number.
#̷𝓍   When you launch the script, you have the following argument available:
#̷𝓍   Argument -SkipVersionCheck ; no version check, run local script.
#̷𝓍   Argument -ForceUpdate : Update the script from server, no version check.
#̷𝓍   Argument -CheckUpdate : do a version check and exit
#̷𝓍   Argument -AcceptUpdate : automatically accept the update if a new version is available.
#̷𝓍   If the script detects that there's no internet connection available, it will print a warning and run the local script version, no update.
#>

[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Overwrite
    )  



function uimi{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [switch]$SysOptions
    ) 
    if($Title){
        Write-Host -f Gray "$Message"    
    }elseif($SysOptions){
        Write-Host -n -f Red "$Message"
    }else{

        Write-Host -f Cyan "$Message"
    }
    
}

function uimt{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title
    ) 
    if($Title){
        Write-Host -n -f DarkRed "$Message"    
    }else{
        Write-Host -n -f DarkYellow "$Message"
    }
    
}



function uiml{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    ) 

    Write-Host -n -f White "$Message"
}




function Invoke-Hidden{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Invoke-Script{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Get-CurrentScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Get-LatestScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Update-ScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Get-AllPreviousVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Start-Admin{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}

function Update-NetworkSTatus{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Option
    ) 

}



# Display Main Menu
#/======================================================================================/
function Show-Menu
{
    Clear-Host

    uimt 'General Functions                                                  ' -t; uimt "System Info`n" -t
    uimt '=======================================================            '; uimt "======================================`n" ; 
    uiml " 1. Run Local Script                                               "; uimi "Hostname:                 $HostName" -t;
    uiml " 2. Check for latest script version                                "; uimi "Administrarot             $IsAdmin" -t;
    uiml " 3. Update to latest script version                                "; uimi "Network Status            $IsOffline" -t;
    uiml " 4. List all previous script version and GIT hashes                "; uimi "IPv4 Address:             $IPv4" -t;
    uiml " 5. Update Network Status                                          "; uimi "`n"
    uimt "                                                                   Script Information" -t
    uimt "                                                                 `t`t`t`t`t   ======================================`n"
    uimi "A) Admin Mode                                                      " -s; uimi "Current Script Version:   $OSver"
    uimi "N) Update Network Status                                           " -s; uimi "Current Script GIT rev    $GitRev"
    uimi "X) Exit                                                            " -s; uimi "Latest Script Version     $OSbuild"
    uiml "                                                                   "; uimi "Latest Script GIT rev     $OSbuild"
   
}
#//====================================================================================//


# Prompt to show at the end of each function
#/======================================================================================/
function Show-End
{
    Write-Host ""
    Write-Host "Operation complete."
    Write-Host "Press any key to return to the menu."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}
#//====================================================================================//








# Main menu selections
#/======================================================================================/
do
{
    Show-Menu
    $Option = Read-Host -Prompt 'Please select an option'
    switch ($Option)
    {
        0 {Invoke-Hidden}
        1 {Invoke-Script}
        2 {Get-CurrentScriptVersion}
        3 {Get-LatestScriptVersion}
        4 {Update-ScriptVersion}
        5 {Get-AllPreviousVersion}
        A {Start-Admin}
        N {Update-NetworkSTatus}
        X {Exit}
    }
} until ($Option -eq 'X')
#//====================================================================================//

