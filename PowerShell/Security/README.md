# Encryption and Security in PowerShell Scripts

This folder contains scripts that I us to protect data in my operations.
We need to encrypt data for different reasons: 
 - storing credentials for scripting and automated tasks
 - encryption of communication
 - storing important data


## Create an Encrypted Password File 
https://dennisspan.com/encrypting-passwords-in-a-powershell-script/

### This will popup a user/password window and create a credentials object
(get-credential) 

Password is stored as a 'secure string'

## Take the password extract the secure strng and convert to normal string

`(get-credential).password | ConvertFrom-SecureString`

Save to a file
`(get-credential).password | ConvertFrom-SecureString | set-content "e:\pass.txt"`


## Creating a Key File

`$Key = New-Object Byte[] 32`
`[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)`
`$Key | out-file e:\aes.key`

## Create a Password File with key

$password = Get-Content C:\Passwords\password.txt | ConvertTo-SecureString -Key (Get-Content C:\Passwords\aes.key)
$credential = New-Object System.Management.Automation.PsCredential("Luke",$password)

 ## Password Manager
 https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Credentials-d44c3cde

