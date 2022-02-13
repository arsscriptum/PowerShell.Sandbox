##===----------------------------------------------------------------------===
##  Test-Screenshot.ps1 - PowerShell script
##
##  The purpose of this script is to test our functionalities
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
# Includes
# . (Join-Path $env:PowerShellScriptsRoot "\GUI\New-WPFMessageBox.ps1")

. 'D:\Scripts\PowerShell\GUI\New-WPFMessageBox.ps1'


$ErrorMsgParams = @{
    TitleBackground = "Red"
    TitleTextForeground = "Yellow"
    TitleFontWeight = "UltraBold"
    TitleFontSize = 28
    ContentBackground = 'Red'
    ContentFontSize = 18
    ContentTextForeground = 'White'
    ButtonTextForeground = 'White'
    Sound = 'Windows Hardware Fail'
}
$WarningParams = @{
    Title = "SUCCESS"
    TitleFontSize = 18
    TitleBackground = 'Green'
    TitleTextForeground = 'White'
     TitleFontWeight = "UltraBold"
}


$ComputerName = "www.google.com"

$test_connection = Test-NetConnection -ComputerName $ComputerName -Port 81 -EA SilentlyContinue

$test_online = $test_connection.TcpTestSucceeded

if($test_online -eq $false)
{
    New-WPFMessageBox @ErrorMsgParams -Content "OFFLINE" -Title "Network Error!"
}
else {
    New-WPFMessageBox @WarningParams -Content "You are online"
}
