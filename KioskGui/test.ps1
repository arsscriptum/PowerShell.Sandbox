
$c1 = 'Blue'
$c2 = 'Cyan'
$c3 = 'White'
$c4 = 'Gray'
$c5 = 'Magenta'
$c6 = 'Yellow'


function ctr {
    Write-Host -n "`t`t`t`t`t"
}
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
