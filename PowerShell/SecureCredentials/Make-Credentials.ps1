

<#


lack
DarkBlue
DarkGreen
DarkCyan
DarkRed
DarkMagenta
DarkYellow
Gray
DarkGray
Blue
Green
Cyan
Red
Magenta
Yellow
White
Black
DarkBlue
DarkGreen
DarkCyan
DarkRed
DarkMagenta
DarkYellow
Gray
DarkGray
Blue
Green
Cyan
Red
Magenta
Yellow
White


$myMap = @{"UserName" = "server1"; "name2" = "server2"}

$myMap = @{"UserName" = "server1"; "name2" = "server2"}

$Cred.UserName 
$Cred.Password | ConvertFrom-SecureString

 | ConvertFrom-SecureString



 $VMList = @()
foreach($VM in $VMs)
{
 ...some calculations
 $VMList += [PSCustomObject]@{"Name"=$VM.Name; "Status"=$VMStatusDetail; "ResourceGroup" = $VM.ResourceGroupName}
}
$VMList



$creds_library = @()
$creds_library += [PSCustomObject]@{"UserName"=$cred_username; "EncryptedPassword"=$cred_password; "ResourceGroup" = $cred_resgroup}
#>

# Get a username / password pair
# $Cred = Get-Credential


#CHECK THIS
#https://github.com/PowerShell


KEY CREATEIOà
PowerShell
$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file C:\passwords\aes.key
1
2
3
$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file C:\passwords\aes.key
Write-Host "Make-Credential - Tools to work on credentials" -BackgroundColor DarkGray -ForegroundColor Blue
Write-Host ""

$cred_username=$Cred.UserName
$cred_password=($Cred.Password | ConvertFrom-SecureString)

$creds_library = @{}
$creds_library.add($cred_username, $cred_password)

Write-Host "credentials library - number of items: " -BackgroundColor DarkGray -ForegroundColor Blue -NoNewline

Write-Host $creds_library.length
Write-Host "Dump" -BackgroundColor DarkGray -ForegroundColor Blue 
$creds_library

# Write-Host "" -BackgroundColor DarkGray -ForegroundColor Blue

### To get an encrypted, useable password,   
# Convert to secure string
[SecureString]$securePwd = $pwdTxt | ConvertTo-SecureString 

# Create credential object
[PSCredential]$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePwd




# Convert to secure string
#[SecureString]$securePwd = $pwdTxt | ConvertTo-SecureString 

# Create credential object
#[PSCredential]$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePwd0