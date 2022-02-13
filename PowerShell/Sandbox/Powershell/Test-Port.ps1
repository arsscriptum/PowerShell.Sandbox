

$servername = BCADD0260
$serverport = 3389;

# Test connection on RDP port - 3389
$resConnection = test-netconnection -ComputerName $servername -Port $serverport

<#
$port_arr = @(139,3389,5040)
$mac = @("myComputer")

foreach ($mc in $mac){
    foreach ($i in $port_arr) {
        Test-NetConnection  $mc -port $i

    }
}
#>