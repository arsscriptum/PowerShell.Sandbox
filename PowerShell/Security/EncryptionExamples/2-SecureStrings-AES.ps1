# As before, set up our SecureString.

$secureString = ConvertTo-SecureString -String "This is my super secret text." -AsPlainText -Force

# Demonstrating how to securely generate a new, random 32-byte AES key.

$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
$key = New-Object byte[](32)

$rng.GetBytes($key)

# Now, you can use this key when calling ConvertTo-SecureString and ConvertFrom-SecureString

$encryptedSecureString = ConvertFrom-SecureString -SecureString $secureString -Key $key

# So long as you use the same bytes as your key later, you can decrypt the value back into a SecureString object.

$newSecureString = ConvertTo-SecureString -String $encryptedSecureString -Key $key

# The SecureKey parameter uses a SecureString to represent the same array of bytes as a Unicode string.  Using this method,
# you can have each user who needs to access the data protect their copy of the key using the same DPAPI / SecureString methods
# that were shown in script 1.  For example:

# Set up our SecureString version of the AES key.

$keyString = [System.Text.Encoding]::Unicode.GetString($key)
$secureKey = ConvertTo-SecureString -String $keyString -AsPlainText -Force

# Use the SecureKey to encrypt our $secureString

$encryptedSecureString = ConvertFrom-SecureString -SecureString $secureString -SecureKey $secureKey

# Because we're not using the -Key or -SecureKey parameters here, the $secureKey variable will be protected with DPAPI.

$encryptedSecureKey = ConvertFrom-SecureString -SecureString $secureKey

# Save both the encrypted string and key to disk.

$encryptedSecureString | Out-File -FilePath .\2-SecureStrings-AES.SecureString.txt
$encryptedSecureKey | Out-File -FilePath .\2-SecureStrings-AES.Key.txt

# Display the encrypted secure string:

Write-Host "Encrypted secure string: $encryptedSecureString"

# To read the data back later (which anyone can do, provided they have been given the key and saved it with DPAPI):

$encryptedSecureKey = Get-Content .\2-SecureStrings-AES.Key.txt
$encryptedSecureString = Get-Content .\2-SecureStrings-AES.SecureString.txt

$secureKey = ConvertTo-SecureString -String $encryptedSecureKey
$secureString = ConvertTo-SecureString -String $encryptedSecureString -SecureKey $secureKey

# As before, we'll decrypt our SecureString to make sure it contains the correct data:

$cred = New-Object System.Management.Automation.PSCredential('UserName', $secureString)
$plainText = $cred.GetNetworkCredential().Password

Write-Host
Write-Host "Plain text: $plainText"