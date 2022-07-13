



<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



######################################################################################################################
#
# TOOLS : BELOW, YOU WILL FIND MISC TOOLS RELATED TO THE PSAUTOUPDATE SCRIPT. WHEN IN THE GUI YOU ARE CALLING 
#         FUNCTION, IT WILL BE ASSOCIATED TO A FUNCTION HERE.
#
# FUNCTIONS:  - Get-CurrentScriptVersion
#             - Get-LatestScriptVersion
#             - Update-ScriptVersion
#
######################################################################################################################



################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:CurrPath                        = (Get-Location).Path
[string]$Script:RootPath                        = (Resolve-Path ..).Path
[string]$Script:TestRoot                        = Join-Path $Script:RootPath 'test'
[string]$Script:DependenciesRoot                = Join-Path $Script:TestRoot 'dependencies'


[string]$Script:ConverterScript                = Join-Path $Script:RootPath 'Converter.ps1'
[string]$Script:TestRunner                        = Join-Path $Script:TestRoot 'RunTest.ps1'
[string]$Script:UiFile                        = Join-Path $Script:DependenciesRoot 'ui.ps1'
[string]$Script:DepsFile                        = Join-Path $Script:DependenciesRoot 'fn.ps1'
[string]$Script:OutputFilePath                        = Join-Path $ENV:Temp 'TestOutput.txt'

[string]$Script:SampleDataFile                        = Join-Path $Script:TestRoot 'Sample.ver'

[datetime]$Script:UpdatedLast = (gi $Script:ConverterScript).LastWriteTime
[string]$Script:UpdatedString = $Script:UpdatedLast.GetDateTimeFormats()[9]


# BASIC INCLUSION OF CONVERTER

. "$Script:ConverterScript"

#==============================================================================================================================================================
#                                             --------------  SYSTEM INITIALIZATION AND UNINITIALIZATION  --------------
#==============================================================================================================================================================



[string]$script:HostName                        = $ENV:COMPUTERNAME
[string]$script:IsAdmin                         = $False
[string]$script:DEFAULT_VERSION                 = '1.0.0.0'


################################################################################################
# FILENAMES
################################################################################################


$Script:TestDependencies = @($Script:ConverterScript,$Script:UiFile,$Script:DepsFile)


Write-Host "Loading system information. Please wait . . ."


################################################################################################
# THOSE VARIABLES ASSIGNATION ARE OPERATIONS, NOT ASSIGNMENTS, THEY TAKE A COUPLE ms
################################################################################################

[string]$script:CurrentGitRev                   = git rev-parse --short HEAD
Write-Host "✅ Git Revision Loaded"
[string]$script:UserName                        = ((query user | findstr 'Active').split('>')[1]).split('')[0]
[string]$script:UserName                        = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
Write-Host "✅ Local Username information detected"
$script:IPv4 = (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 1
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
 $script:IsAdmin = $True
}
Write-Host "✅ User privileges detected"
Write-Host "✅ System information loaded"



#===============================================================================
# Check dependencies
#===============================================================================

ForEach($dep in $Script:TestDependencies){
    if(-not(Test-Path -Path $dep -PathType Leaf)){
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host " + Missing dependencies File '$dep'" -f DarkGray
        return
    }
    # In all my dependencies, if it s PS1, load it. The other is the version file
    $ext = (Get-Item $dep).Extension
    if($ext -eq '.ps1') { . "$dep" ; }
    
    Write-Host "✅ Dependency: $dep"  
}


Register-Assemblies


#####################################################################
# MANUAL MODE :  TEST FUNCTIONALITIES USING THE MENU
#####################################################################
    
    do
    {
        if($Script:IsOnline -eq $False){
            Request-OnlineState
            continue
        }
        Show-Menu
        $Option = Read-Host -Prompt 'Please select an option'
        switch ($Option)
        {
            0 {Invoke-Nothing}
            # In the updated script version, this line calls Invoke-UpdatedScript
            1 {Invoke-EncodeSampleFile}
            2 {Invoke-DecodeSampleFile}
            3 {Invoke-Editor $Script:SampleDataFile}
            4 {Invoke-Editor $Script:OutputFilePath}
        
            
            A {Start-Admin}
            N {}
            X {Exit}
        }
    } until ($Option -eq 'X')
    #//====================================================================================//



