
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>





################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:CurrPath                        = (Get-Location).Path
[string]$Script:RootPath                        = (Resolve-Path .).Path
[string]$Script:TestRoot                        = Join-Path $Script:RootPath 'test'
[string]$Script:DependenciesRoot                = Join-Path $Script:RootPath 'dep'
[string]$Script:ImagesRoot                = Join-Path $Script:TestRoot 'img'

[string]$Script:MainGui                = Join-Path $Script:DependenciesRoot 'MainGui.ps1'
[string]$Script:MainConsole                = Join-Path $Script:DependenciesRoot 'MainConsole.ps1'

[string]$Script:ConsoleUi                        = Join-Path $Script:DependenciesRoot 'ConsoleUi.ps1'
[string]$Script:RegistryFunct                        = Join-Path $Script:DependenciesRoot 'Registry.ps1'

[string]$Script:TestRunner                        = Join-Path $Script:TestRoot 'RunTest.ps1'

[string]$Script:DepsFile                        = Join-Path $Script:DependenciesRoot 'fn.ps1'
[string]$Script:OutputFilePath                        = Join-Path $ENV:Temp 'TestOutput.txt'

[string]$Script:SampleDataFile                        = Join-Path $Script:TestRoot 'Sample.ver'

[datetime]$Script:UpdatedLast = (gi $Script:ConverterScript).LastWriteTime
[string]$Script:UpdatedString = $Script:UpdatedLast.GetDateTimeFormats()[9]




function ctr {
    Write-Host -n "`t`t`t`t`t"
}

function StartMenu {

    $c1 = 'Blue'
    $c2 = 'Cyan'
    $c3 = 'White'
    $c4 = 'Gray'
    $c5 = 'Magenta'
    $c6 = 'Yellow'

    cls
    ctr;Write-Host -f $c1 "╔══════════════════════════════╗"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c5 "          LAUNCH MENU         ";Write-Host -f $c1 "║"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c6 "------------------------------";Write-Host -f $c1 "║"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c2 "     1    |    2    |    X    ";Write-Host -f $c1 "║"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c4 "  Text Ui | Run Gui |  Close  ";Write-Host -f $c1 "║"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c3 "------------------------------";Write-Host -f $c1 "║"
    ctr;Write-Host -n -f $c1 "║";Write-Host -n -f $c4 "        Press 1 / 2 / X       ";Write-Host -f $c1 "║"
    ctr;Write-Host -f $c1 "╚══════════════════════════════╝"
    ctr;$a=Read-Host "`t`t>"
    switch ($a){
        1 {cls;. "$Script:MainConsole"}
        2 {cls;. "$Script:MainGui"}
        X {Exit}
    }
}

#==============================================================================================================================================================
#                                             --------------  SYSTEM INITIALIZATION AND UNINITIALIZATION  --------------
#==============================================================================================================================================================

StartMenu