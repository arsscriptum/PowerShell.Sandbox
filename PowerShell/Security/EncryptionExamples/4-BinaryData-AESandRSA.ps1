#requires -Version 3.0

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
    # For this sample, we're going to encrypt a copy of this script file, rather than dealing with just a simple string in memory.
    $originalFile = $MyInvocation.MyCommand.Path

    # This time, we'll create a new instance of AesCryptoServiceProvider.  It automatically generates a random Key and IV (Initialization Vector)
    $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider

    # Using .NET Streams, make a new, encrypted copy of the file.  This is a buffered approach that doesn't have to hold the
    # entire file in memory at any time, even if it is very large.

    $inputStream = New-Object System.IO.FileStream($originalFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
    $outputStream = New-Object System.IO.FileStream("$pwd\4-BinaryData-AESandRSA.data.bin", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

    # .NET Streams use this "Decorator" pattern.  After obtaining the low-level stream (such as a FileStream or MemoryStream), you then wrap it
    # in one or more layers of higher-level streams, such as this CryptoStream.  CryptoStream transforms the data for us into an encrypted
    # form, and writes it to the underlying FileStream.

    $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($outputStream, $aes.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)

    # Now we perform our buffered read / write on the streams.  In this case, we'll read 256 bytes at a time, though you can use just about any size buffer you like.
    $buffer = New-Object byte[](256)

    # $inputStream.Read() returns the number of bytes that were read into the buffer, which can be anywhere from 0 to $buffer.Length.
    # As long as this return value is greater than zero, we write that many bytes to the CryptoStream (and from there, automatically to the output FileStream.)
    
    while (($read = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0)
    {
        $cryptoStream.Write($buffer, 0, $read)
    }

    # Generate a collection of copies of the AES key and IV, each protected with one of the RSA certificates.

    $encryptedKeys = New-Object object[]($validCerts.Count)

    for ($i = 0; $i -lt $validCerts.Count; $i++)
    {
        $encryptedKeys[$i] = New-Object psobject -Property @{
            Thumbprint = $validCerts[$i].Thumbprint

            # To encrypt the key and IV using RSA, we use the PublicKey.Key.Encrypt() method on the certificate.

            Key = $validCerts[$i].PublicKey.Key.Encrypt($aes.Key, $true)
            IV  = $validCerts[$i].PublicKey.Key.Encrypt($aes.IV, $true)
        }
    }

    # Save all of our protected copies of the AES key/IV to a file.

    $outputObject = New-Object psobject -Property @{
        Keys    = $encryptedKeys
    }

    $outputObject | Export-Clixml -Path .\4-BinaryData-AESandRSA.txt
}
finally
{
    # This time, our cleanup consists of calling Dispose() on the various streams and other .NET objects which implement the IDisposable interface.
    # These objects automatically take care of clearing out sensitive data like encryption keys from memory when you call Dispose().

    if ($null -ne $cryptoStream)
    {
        $cryptoStream.Dispose()
        $cryptoStream = $null
    }

    if ($null -ne $outputStream)
    {
        $outputStream.Dispose()
        $outputStream = $null
    }

    if ($null -ne $inputStream)
    {
        $inputStream.Dispose()
        $inputStream = $null
    }

    if ($null -ne $aes)
    {
        $aes.Dispose()
        $aes = $null
    }
}

# To read the data back in later, you need one of the certificates that was used to encrypt the AES key (with that certificate's private key).
# For this example, we already know that the $validCerts array contains at least one such certificate.

# As with the encryption portion of the code, we'll use try/finally to make sure that the cleanup code executes.
try
{
    $object = Import-Clixml -Path .\4-BinaryData-AESandRSA.txt

    $targetCertificate = $validCerts[0]

    # Check our data to make sure this certificate was used to encrypt a copy of the AES key, and that we can decrypt it

    $found = $false
    $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider

    foreach ($encryptedKey in $object.Keys)
    {
        if ($targetCertificate.Thumbprint -eq $encryptedKey.Thumbprint)
        {
            # To decrypt the AES key, we use the PrivateKey.Decrypt() method on the certificate object.

            $aes.Key = $targetCertificate.PrivateKey.Decrypt($encryptedKey.Key, $true)
            $aes.IV  = $targetCertificate.PrivateKey.Decrypt($encryptedKey.IV, $true)

            $found = $true

            break
        }
    }

    if (-not $found)
    {
        throw "No certificate matching thumbprint '$($targetCertificate.Thumbprint)' was used to protect the data."
    }

    # Now we can use the $aes object and .NET Streams to decrypt our file back to its original form.  The code is very similar to that used in the encryption process.

    $inputStream = New-Object System.IO.FileStream("$pwd\4-BinaryData-AESandRSA.data.bin", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
    $outputStream = New-Object System.IO.FileStream("$pwd\4-BinaryData-AESandRSA.decrypted.ps1", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

    # The difference is that this time, the CryptoStream is doing the reading, and is wrapped around $inputStream.  $outputStream is doing the writing.

    $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($inputStream, $aes.CreateDecryptor(), [System.Security.Cryptography.CryptoStreamMode]::Read)

    $buffer = New-Object byte[](256)
    
    while (($read = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0)
    {
        $outputStream.Write($buffer, 0, $read)
    }
}
finally
{
    if ($null -ne $cryptoStream)
    {
        $cryptoStream.Dispose()
        $cryptoStream = $null
    }

    if ($null -ne $outputStream)
    {
        $outputStream.Dispose()
        $outputStream = $null
    }

    if ($null -ne $inputStream)
    {
        $inputStream.Dispose()
        $inputStream = $null
    }

    if ($null -ne $aes)
    {
        $aes.Dispose()
        $aes = $null
    }
}

# When this script finishes executing, you can look at the encrypted file (4-BinaryData-AESandRSA.data.bin) and the decrypted file (4-BinaryData.AESandRSA.decrypted.ps1).
# The decrypted PS1 will be identical to this original script file.