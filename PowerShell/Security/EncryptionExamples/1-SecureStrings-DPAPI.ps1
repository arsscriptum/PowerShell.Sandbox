# Demonstrates how to create a SecureString, save its data to a file (encrypted with DPAPI), and read / decrypt the data later.

# First, we'll create our SecureString:

$secureString = ConvertTo-SecureString -String "This is my super secret text." -AsPlainText -Force

# Now, convert the SecureString to an encrypted string.

$encryptedSecureString = ConvertFrom-SecureString -SecureString $secureString

# View the encrypted value

Write-Host "Encrypted secure string: $encryptedSecureString"

# Save to a file.
$encryptedSecureString | Out-File -FilePath .\1-SecureStrings-DPAPI.txt

# To obtain the original SecureString later, reverse this process:

$encryptedSecureString = Get-Content -Path .\1-SecureStrings-DPAPI.txt

$secureString = ConvertTo-SecureString -String $encryptedSecureString

# We now have our Secure String.  To verify that it contains the correct data, we'll use one of the simpler methods of converting it back to a plain text string:

$cred = New-Object System.Management.Automation.PSCredential('UserName', $secureString)
$plainText = $cred.GetNetworkCredential().Password

Write-Host
Write-Host "Plain text: $plainText"