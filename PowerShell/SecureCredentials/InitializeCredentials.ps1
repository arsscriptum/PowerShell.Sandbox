<#

Make my credential files
#>

$test_path=E:\scripts\Setup\Scheduled-Tasks\tests
$pass_file=$test_path\password.txt


(get-credential).password | ConvertFrom-SecureString | set-content "E:\scripts\Setup\Scheduled-Tasks\tests\password.txt"



$password = Get-Content "E:\scripts\Setup\Scheduled-Tasks\tests\password.txt" | ConvertTo-SecureString 
$credential = New-Object System.Management.Automation.PsCredential("Luke",$password)