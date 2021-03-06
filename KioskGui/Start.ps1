
<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
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
    ctr;Write-Host -f $c1 "โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c5 "          LAUNCH MENU         ";Write-Host -f $c1 "โ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c6 "------------------------------";Write-Host -f $c1 "โ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c2 "     1    |    2    |    X    ";Write-Host -f $c1 "โ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c4 "  Text Ui | Run Gui |  Close  ";Write-Host -f $c1 "โ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c3 "------------------------------";Write-Host -f $c1 "โ"
    ctr;Write-Host -n -f $c1 "โ";Write-Host -n -f $c4 "        Press 1 / 2 / X       ";Write-Host -f $c1 "โ"
    ctr;Write-Host -f $c1 "โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ"
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