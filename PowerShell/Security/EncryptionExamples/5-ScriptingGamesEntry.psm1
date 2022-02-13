#requires -Version 4.0

#
# Protect-File and Unprotect-File produce and read encrypted binary files in a proprietary format, to keep file size to a minimum.  The format is as follows:
# 
# 10-byte fixed header:  0x54 0x72 0x6F 0x6C 0x6C 0x20 0x42 0x61 0x69 0x74
# 4 bytes: Number of copies of RSA-encrypted AES key / IV.  (Int32 in Little-Endian order.)
# 
# <count> repeat instances of key blobs in the following format:
#   4 bytes: Byte count of certificate thumbprint used to protect this copy of the key.  (Int32 in Little-Endian order)
#   <count> bytes:  Certificate Thumbprint
#   4 bytes: Byte count of RSA-encrypted AES key. (Int32 in Little-Endian order)
#   <count> bytes:  RSA-encrypted AES key.
#   4 bytes: Byte count of RSA-encrypted AES IV. (Int32 in Little-Endian order)
#   <count> bytes:  RSA-encrypted AES IV.
#
# The remainder of the file is the AES-encrypted payload.
#

function Protect-File
{
    <#
    .Synopsis
       Produces an encrypted copy of a file.
    .DESCRIPTION
       Encrypts the contents of a file using AES, and protects the randomly-generated AES encryption keys using one or more RSA public keys.  The original file is not modified; this command produces a new, encrypted copy of the file.
    .PARAMETER FilePath
       The original, decrypted file.
    .PARAMETER OutputFile
       The new encrypted file that is to be created.
    .PARAMETER CertificateThumbprint
       One or more RSA certificate thumbprints that will be used to protect the file.  The public keys of these certificates will be used in the encryption process, and their private keys will be required when calling the Unprotect-File command later.
       The certificates must be present somewhere in the current user's certificate store, and must be valid (not expired.)  For this command, only the public key is required.
    .PARAMETER NoClobber
       If the file specified by OutputFile already exists, the NoClobber switch causes the command to produce an error.
    .PARAMETER Force
       If the file specified by OutputFile already exists and is read-only, the NoClobber switch causes the command to overwrite it anyway.
    .EXAMPLE
       Protect-File -FilePath c:\SensitiveData.zip -OutputFile c:\SensitiveData.bin -CertificateThumbprint 'AB06BF2C9B61D687FFB445003C2AFFAB0C81DFF9' -NoClobber

       Encrypts C:\SensitiveData.zip into a new file C:\SensitiveData.bin.  The private key of RSA certificate AB06BF2C9B61D687FFB445003C2AFFAB0C81DFF9 will be required to decrypt the file.  If C:\SensitiveData.bin already exists, the command will produce an error and abort.
    .EXAMPLE
       Protect-File -FilePath c:\SensitiveData.zip -OutputFile c:\SensitiveData.bin -CertificateThumbprint 'AB06BF2C9B61D687FFB445003C2AFFAB0C81DFF9','8E6A22DB9C6A56324E63F86F231765CC8B1A52C8' -Force

       Like example 1, except the SensitiveData.bin file will be overwritten (even if it exists and is read-only), and the SensitiveData.bin file can be decrypted by either one of the two specified RSA certificates' private keys.
    .INPUTS
       None.  This command does not accept pipeline input.
    .OUTPUTS
       None.  This command does not produce pipeline output.
    .NOTES
       If any error occurs with parameter validation or with the file encryption, the command will produce a terminating error.
    .LINK
       Unprotect-File
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
            ValidateInputFileSystemParameter -Path $_ -ParameterName FilePath
        })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [string]
        $OutputFile,

        [Parameter(Mandatory)]
        [string[]]
        $CertificateThumbprint,

        [switch]
        $NoClobber,

        [switch]
        $Force
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $_filePath = (Resolve-Path -LiteralPath $FilePath).Path
    $_outputFile = ValidateAndResolveOutputFileParameter -Path $OutputFile -ParameterName OutputFile -NoClobber:$NoClobber -Force:$Force

    try
    {
        $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider

        $keys = New-Object System.Collections.ArrayList

        #region Validate Input

        foreach ($thumbprint in $CertificateThumbprint)
        {
            $cert = Get-ChildItem -LiteralPath 'Cert:\CurrentUser' -Include $thumbprint -Recurse |
                    Where-Object {
                        $null -ne $_.PublicKey.Key -and $_.PublicKey.Key -is [System.Security.Cryptography.RSACryptoServiceProvider] -and
                        $_.NotBefore -lt (Get-Date) -and $_.NotAfter -gt (Get-Date)
                    } |
                    Select-Object -First 1

            if ($null -eq $cert)
            {
                throw "No valid RSA certificate with thumbprint '$thumbprint' was found in the current user's store."
            }
            
            try
            {
                $null = $keys.Add([pscustomobject] @{
                    Thumbprint = Get-ByteArrayFromString -String $cert.Thumbprint
                    Key        = $cert.PublicKey.Key.Encrypt($aes.Key, $true)
                    IV         = $cert.PublicKey.Key.Encrypt($aes.IV, $true)
                })
            }
            catch
            {
                $exception = Get-InnerException -ErrorRecord $_
                throw "Error using certificate '$thumbprint' to encrypt key info: $($exception.Message)"
            }
        }

        #endregion

        try
        {
            #region Create output file, write header and key blobs

            $outputStream = New-Object System.IO.FileStream($_outputFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            $binaryWriter = New-Object System.IO.BinaryWriter($outputStream, [System.Text.Encoding]::ASCII, $true)

            $header = [System.Text.Encoding]::ASCII.GetBytes('Troll Bait')
            $binaryWriter.Write($header)

            $binaryWriter.Write($keys.Count)

            foreach ($key in $keys)
            {
                $binaryWriter.Write($key.Thumbprint.Count)
                $binaryWriter.Write($key.Thumbprint)

                $binaryWriter.Write($key.Key.Count)
                $binaryWriter.Write($key.Key)

                $binaryWriter.Write($key.IV.Count)
                $binaryWriter.Write($key.IV)
            }

            #endregion

            #region AES encrypt payload

            $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($outputStream, $aes.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)
            $inputStream = New-Object System.IO.FileStream($_filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            $buffer = New-Object byte[](1mb)

            while (($read = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0)
            {
                $cryptoStream.Write($buffer, 0, $read)
            }

            #endregion
        }
        catch
        {
            $exception = Get-InnerException -ErrorRecord $_
            throw "Error encrypting file '$FilePath' to '$OutputFile': $($exception.Message)"
        }
    }
    finally
    {
        if ($null -ne $binaryWriter) { $binaryWriter.Dispose() }
        if ($null -ne $cryptoStream) { $cryptoStream.Dispose() }
        if ($null -ne $inputStream)  { $inputStream.Dispose() }
        if ($null -ne $outputStream) { $outputStream.Dispose() }
        if ($null -ne $aes)          { $aes.Dispose() }
    }
}

function Unprotect-File
{
    <#
    .Synopsis
       Decrypts a file that was encrypted using Protect-File.
    .DESCRIPTION
       Using the private key of one of the certificates that was used when calling Protect-File, Unprotect-File decrypts its contents.  As with Protect-File, the original file is left intact, and the decrypted contents are stored in a new file.
    .PARAMETER FilePath
       The encrypted file.
    .PARAMETER OutputFile
       The new decrypted file that is to be created.
    .PARAMETER CertificateThumbprint
       An RSA certificate thumbprint that will be used to decrypt the file.  This certificate, including its public key, must be in the current user's certificate store, and this must be one of the certificates used when the file was originally encrypted with Protect-File.
    .PARAMETER NoClobber
       If the file specified by OutputFile already exists, the NoClobber switch causes the command to produce an error.
    .PARAMETER Force
       If the file specified by OutputFile already exists and is read-only, the NoClobber switch causes the command to overwrite it anyway.
    .EXAMPLE
       Unprotect-File -FilePath c:\SensitiveData.bin -OutputFile c:\SensitiveData.zip -CertificateThumbprint 'AB06BF2C9B61D687FFB445003C2AFFAB0C81DFF9' -NoClobber

       Decrypts C:\SensitiveData.bin into a new file C:\SensitiveData.zip.  The private key of RSA certificate AB06BF2C9B61D687FFB445003C2AFFAB0C81DFF9 will be used to decrypt the file.  If C:\SensitiveData.zip already exists, the command will produce an error and abort.
    .EXAMPLE
       Unprotect-File -FilePath c:\SensitiveData.bin -OutputFile c:\SensitiveData.zip -CertificateThumbprint '8E6A22DB9C6A56324E63F86F231765CC8B1A52C8' -Force

       Like example 1, except the SensitiveData.zip file will be overwritten (even if it exists and is read-only.)
    .INPUTS
       None.  This command does not accept pipeline input.
    .OUTPUTS
       None.  This command does not produce pipeline output.
    .NOTES
       If any error occurs with parameter validation or with the file decryption, the command will produce a terminating error.
    .LINK
       Protect-File
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
            ValidateInputFileSystemParameter -Path $_ -ParameterName FilePath
        })]
        [string]
        $FilePath,

        [Parameter(Mandatory)]
        [string]
        $OutputFile,

        [Parameter(Mandatory)]
        [string]
        $CertificateThumbprint,

        [switch]
        $NoClobber,

        [switch]
        $Force
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $_filePath = (Resolve-Path -LiteralPath $FilePath).Path
    $_outputFile = ValidateAndResolveOutputFileParameter -Path $OutputFile -ParameterName OutputFile -NoClobber:$NoClobber -Force:$Force

    try
    {
        #region Validate input

        $cert = Get-ChildItem -LiteralPath 'Cert:\CurrentUser' -Include $CertificateThumbprint -Recurse |
                Where-Object {
                    $_.HasPrivateKey -and $_.PrivateKey -is [System.Security.Cryptography.RSACryptoServiceProvider] -and
                    $_.NotBefore -lt (Get-Date) -and $_.NotAfter -gt (Get-Date)
                } |
                Select-Object -First 1

        if ($null -eq $cert)
        {
            throw "No valid RSA certificate with thumbprint '$CertificateThumbprint' with a private key was found in the current user's store."
        }

        #endregion

        #region Parse header and key blobs

        $inputStream = New-Object System.IO.FileStream($_filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
        $binaryReader = New-Object System.IO.BinaryReader($inputStream, [System.Text.Encoding]::ASCII, $true)

        try
        {
            $header = $binaryReader.ReadBytes(10)
        }
        catch
        {
            throw "File '$FilePath' contains invalid data."
        }

        if ([System.Text.Encoding]::ASCII.GetString($header) -ne 'Troll Bait')
        {
            throw "File '$FilePath' contains invalid data."
        }

        try
        {
            $certCount = $binaryReader.ReadInt32()
        }
        catch
        {
            throw "File '$FilePath' contains invalid data."
        }

        $matchingKey = $null

        for ($i = 0; $i -lt $certCount; $i++)
        {
            $object = [pscustomobject] @{
                Thumbprint = $null
                Key = $null
                IV = $null
            }

            try
            {
                $count = $binaryReader.ReadInt32()
                $thumbprintBytes = $binaryReader.ReadBytes($count)
                
                $count = $binaryReader.ReadInt32()
                $object.Key = $binaryReader.ReadBytes($count)

                $count = $binaryReader.ReadInt32()
                $object.IV = $binaryReader.ReadBytes($count)
            }
            catch
            {
                throw "File '$FilePath' contains invalid data."
            }

            $object.Thumbprint = Get-StringFromByteArray -ByteArray $thumbprintBytes
            
            if ($object.Thumbprint -eq $CertificateThumbprint)
            {
                $matchingKey = $object
            }
        }

        if ($null -eq $matchingKey)
        {
            throw "No key protected with certificate '$CertificateThumbprint' was found in protected file '$FilePath'"
        }

        #endregion

        #region Decrypt AES payload and save to decrypted output file.

        try
        {
            $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider
            $aes.Key = $cert.PrivateKey.Decrypt($matchingKey.Key, $true)
            $aes.IV = $cert.PrivateKey.Decrypt($matchingKey.IV, $true)
        }
        catch
        {
            $exception = Get-InnerException -ErrorRecord $_
            throw "Error decrypting file with certificate '$CertificateThumbprint': $($exception.Message)"
        }

        try
        {
            $outputStream = New-Object System.IO.FileStream($_outputFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)        
            $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($inputStream, $aes.CreateDecryptor(), [System.Security.Cryptography.CryptoStreamMode]::Read)

            $buffer = New-Object byte[](1mb)

            while (($read = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0)
            {
                $outputStream.Write($buffer, 0, $read)
            }
        }
        catch
        {
            $exception = Get-InnerException -ErrorRecord $_
            throw "Error decrypting file '$FilePath' to '$OutputFile': $($exception.Message)"
        }

        #endregion
    }
    finally
    {
        if ($null -ne $binaryReader) { $binaryReader.Dispose() }
        if ($null -ne $cryptoStream) { $cryptoStream.Dispose() }
        if ($null -ne $inputStream)  { $inputStream.Dispose() }
        if ($null -ne $outputStream) { $outputStream.Dispose() }
        if ($null -ne $aes)          { $aes.Dispose() }
    }
}

function Get-InnerException
{
    <#
    .Synopsis
       Returns the innermost Exception from either an Exception or ErrorRecord object.
    .DESCRIPTION
       Returns the innermost Exception from either an Exception or ErrorRecord object.
    .PARAMETER ErrorRecord
       An object of type [System.Management.Automation.ErrorRecord]
    .PARAMETER Exception
       An object of type [System.Exception] or any derived type.
    .EXAMPLE
       $exception = Get-InnerException -ErrorRecord $_

       Retrieves the original exception associated with the ErrorRecord in the $_ variable, as would be found in a Catch block.
    .EXAMPLE
       $innerException = Get-InnerException -Exception $exception

       Retrieves the original exception associated with the $exception variable.  If no InnerExceptions are found, $exception is returned.
    .INPUTS
       None.  This command does not accept pipeline input.
    .OUTPUTS
       System.Exception
    #>

    [CmdletBinding(DefaultParameterSetName = 'ErrorRecord')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ErrorRecord')]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [Parameter(Mandatory, ParameterSetName = 'Exception')]
        [System.Exception]
        $Exception
    )

    if ($PSCmdlet.ParameterSetName -eq 'ErrorRecord')
    {
        $_exception = $ErrorRecord.Exception
    }
    else
    {
        $_exception = $Exception
    }

    while ($null -ne $_exception.InnerException)
    {
        $_exception = $_exception.InnerException
    }

    return $_exception
}

function Get-CallerPreference
{
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]
        $Name
    )

    begin
    {
        $filterHash = @{}
    }
    
    process
    {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end
    {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator())
        {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name)))
            {
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable)
                {
                    if ($SessionState -eq $ExecutionContext.SessionState)
                    {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -WhatIf:$false -Confirm:$false
                    }
                    else
                    {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered')
        {
            foreach ($varName in $filterHash.Keys)
            {
                if (-not $vars.ContainsKey($varName))
                {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -WhatIf:$false -Confirm:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }

    } # end

}

function ValidateInputFileSystemParameter
{
    # Ensures that the Path parameter is valid, exists, and is of the proper type (either File or Directory, depending on the
    # value of the PathType parameter).
    #
    # Either returns $true or throws an error; intended for use in ValidateScript blocks.
    
    # This function is not exported to the module's consumer.

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $ParameterName,

        [ValidateSet('Leaf','Container')]
        [string]
        $PathType = 'Leaf'
    )

    if ($Path.IndexOfAny([System.IO.Path]::InvalidPathChars) -ge 0)
    {
        throw "$ParameterName argument contains invalid characters."
    }
    elseif (-not (Test-Path -LiteralPath $Path -PathType $PathType))
    {
        throw "$ParameterName '$Path' does not exist."
    }
    else
    {
        try
        {
            $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        }
        catch
        {
            $exception = Get-InnerException -ErrorRecord $_

            throw "Error reading ${ParameterName}: $($exception.Message)"
        }

        if ($PathType -eq 'Leaf')
        {
            $type = [System.IO.FileInfo]
            $name = 'File'
        }
        else
        {
            $type = [System.IO.DirectoryInfo]
            $name = 'Directory'
        }

        if ($item -isnot $type)
        {
            throw "$ParameterName '$Path' does not refer to a valid $name."
        }
        else
        {
            return $true
        }
    }
}

function ValidateAndResolveOutputFileParameter
{
    # Ensures that the Path is a valid FileSystem path.  Enforces typical behavior for -NoClobber and -Force parameters.
    # Attempts to create the parent directory of Path, if it does not already exist.
    # Also resolves relative paths according to PowerShell's current file system location.
    #
    # Either returns the resolved path, or throws an error (intended for use in Begin blocks.)

    # This function is not exported to the module's consumer.

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $ParameterName,

        [switch]
        $NoClobber,

        [switch]
        $Force
    )

    if ($Path.IndexOfAny([System.IO.Path]::InvalidPathChars) -ge 0)
    {
        throw "$ParameterName argument contains in valid characters."
    }

    if (-not (Split-Path -Path $Path -IsAbsolute))
    {
        $_file = Join-Path -Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation -ChildPath ($Path -replace '^\.?\\?')
    }
    else
    {
        $_file = $Path
    }

    try
    {
        $fileInfo = [System.IO.FileInfo]$_file
    }
    catch
    {
        $exception = Get-InnerException -ErrorRecord $_
        throw "Error parsing $ParameterName path '$Path': $($exception.Message)"
    }

    if ($fileInfo.Exists)
    {
        if ($NoClobber)
        {
            throw "$ParameterName '$Path' already exists, and the NoClobber switch was passed."
        }
        else
        {
            try
            {
                Remove-Item -LiteralPath $_file -Force:$Force -ErrorAction Stop
            }
            catch
            {
                $exception = Get-InnerException -ErrorRecord $_
                throw "$ParameterName '$Path' already exists, and the following error occurred when attempting to delete it: $($exception.Message)"
            }
        }
    }

    if (-not $fileInfo.Directory.Exists)
    {
        try
        {
            $null = New-Item -Path $fileInfo.Directory.FullName -ItemType Directory -ErrorAction Stop
        }
        catch
        {
            $exception = Get-InnerException -ErrorRecord $_
            throw "Parent folder of $ParameterName '$Path' does not exist, and the following error occurred when attempting to create it: $($exception.Message)"
        }
    }

    return $fileInfo.FullName
}

function Get-StringFromByteArray
{
    # Converts byte array into a string of hexadecimal characters in the same order as the byte array
    # This function is not exported to the module's consumer.

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]
        $ByteArray
    )

    $sb = New-Object System.Text.StringBuilder

    for ($i = 0; $i -lt $ByteArray.Length; $i++)
    {
        $null = $sb.Append($ByteArray[$i].ToString('x2', [Globalization.CultureInfo]::InvariantCulture))
    }

    return $sb.ToString()
}

function Get-ByteArrayFromString
{
    # Converts a string containing an even number of hexadecimal characters into a byte array.
    # This function is not exported to the module's consumer.

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            # Could use ValidatePattern for this, but ValidateScript allows for a more user-friendly error message.
            if ($_ -match '[^0-9A-F]')
            {
                throw 'String must only contain hexadecimal characters (0-9 and A-F).'
            }

            if ($_.Length % 2 -ne 0)
            {
                throw 'String must contain an even number of characters'
            }

            return $true
        })]
        [string]
        $String
    )

    $length = $String.Length / 2
    
    try
    {
        $bytes = New-Object byte[]($length)
    }
    catch
    {
        $exception = Get-InnerException -ErrorRecord $_
        throw "Error allocating byte array of size ${length}: $($exception.Message)"
    }

    for ($i = 0; $i -lt $length; $i++)
    {
        $bytes[$i] = [byte]::Parse($String.Substring($i * 2, 2), [Globalization.NumberStyles]::AllowHexSpecifier, [Globalization.CultureInfo]::InvariantCulture)
    }

    return ,$bytes
}

$functions = (
    'Protect-File', 'Unprotect-File', 'Get-InnerException', 'Get-CallerPreference'
)

Export-ModuleMember -Function $functions

