# As with the previous two AES / RSA examples, we need at least one valid certificate with a private key to actually run the sample.

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

# The functions that do the work are in the 5-ScriptingGamesEventEntry.psm1 module file.

Import-Module -Name .\5-ScriptingGamesEntry.psm1 -ErrorAction Stop

# The Protect-File and Unprotect-File functions in the module create a binary file which contains the RSA-protected AES keys and the AES-encrypted payload,
# all in one binary output file.  This keeps file size to a minimum, which might come in handy if you're trying to encrypt / decrypt very large data.

# These functions do not destroy the original file; they create an encrypted / decrypted copy in the location you specify.

Protect-File -FilePath $MyInvocation.MyCommand.Path -OutputFile .\5-FullSample.bin -CertificateThumbprint ($validCerts | Select-Object -ExpandProperty Thumbprint)

Unprotect-File -FilePath .\5-FullSample.bin -OutputFile .\5-Decrypted.ps1 -CertificateThumbprint $validCerts[0].Thumbprint