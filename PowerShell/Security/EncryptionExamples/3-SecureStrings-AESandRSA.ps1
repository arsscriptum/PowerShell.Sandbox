# Actually executing this example requires at least one certificate installed in the user's Personal store which includes an RSA Private Key.

$validCerts = @(
    Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object {
        $_.PrivateKey -is [System.Security.Cryptography.RSACryptoServiceProvider] -and
        $_.NotBefore -lt (Get-Date) -and $_.NotAfter -gt (Get-Date)
    }
)

if ($validCerts.Count -eq 0)
{
    throw "No RSA certificates with usable private keys were found in the current user's store."
}

try
{
    # This time, we'll have the user enter secure data directly in SecureString form, so the plain text version isn't floating around in memory.

    $secureString = Read-Host -Prompt 'Enter some sample, secret text.' -AsSecureString

    # As before, generate a new random encryption key.

    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $key = New-Object byte[](32)

    $rng.GetBytes($key)

    # Protect the data using our new key.

    $encryptedSecureString = ConvertFrom-SecureString -SecureString $secureString -Key $key

    # Generate a collection of copies of the AES key, each protected with one of the RSA certificates.

    $encryptedKeys = New-Object object[]($validCerts.Count)

    for ($i = 0; $i -lt $validCerts.Count; $i++)
    {
        $encryptedKeys[$i] = New-Object psobject -Property @{
            Thumbprint = $validCerts[$i].Thumbprint

            # To encrypt the key using RSA, we use the PublicKey.Key.Encrypt() method on the certificate.

            Key = $validCerts[$i].PublicKey.Key.Encrypt($key, $true)
        }
    }

    # Save the encrypted data and all of our protected copies of the AES key to a file.  In this case, Export-CliXml is a handy way to do this,
    # though the text representation does take up a fair amount of space.

    $outputObject = New-Object psobject -Property @{
        Payload = $encryptedSecureString
        Keys    = $encryptedKeys
    }

    $outputObject | Export-Clixml -Path .\3-SecureStrings-AESandRSA.txt

    Write-Host "Encrypted secure string: $encryptedSecureString"
}
finally
{
    if ($null -ne $key)
    {
        [array]::Clear($key, 0, $key.Length)
        $key = $null
    }
}

# To read the data back in later, you need one of the certificates that was used to encrypt the AES key (with that certificate's private key).
# For this example, we already know that the $validCerts array contains at least one such certificate.

# As with the encryption portion of the code, we'll use try/finally to make sure that the cleanup code executes.
try
{
    $object = Import-Clixml -Path .\3-SecureStrings-AESandRSA.txt

    $targetCertificate = $validCerts[0]

    # Check our data to make sure this certificate was used to encrypt a copy of the AES key, and that we can decrypt it

    $key = $null

    foreach ($encryptedKey in $object.Keys)
    {
        if ($targetCertificate.Thumbprint -eq $encryptedKey.Thumbprint)
        {
            # To decrypt the AES key, we use the PrivateKey.Decrypt() method on the certificate object.

            $key = $targetCertificate.PrivateKey.Decrypt($encryptedKey.Key, $true)
            break
        }
    }

    if ($null -eq $key)
    {
        throw "No certificate matching thumbprint '$($targetCertificate.Thumbprint)' was used to protect the data."
    }

    # Now we have our original AES key, and can use it to decrypt the data back into SecureString form.

    $secureString = ConvertTo-SecureString -String $object.Payload -Key $key

    # As before, we'll display the decrypted version of the string, to make sure it's correct (though this does violate our "don't leave sensitive data lying around in memory" practice, for demonstration purposes only.)

    $cred = New-Object System.Management.Automation.PSCredential('UserName', $secureString)
    $plainText = $cred.GetNetworkCredential().Password

    Write-Host
    Write-Host "Plain text: $plainText"
}
finally
{
    if ($null -ne $key)
    {
        [array]::Clear($key, 0, $key.Length)
        $key = $null
    }
}