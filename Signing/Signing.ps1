<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Signature Functions
  ║
  ║   Guillaume Plante <guillaumeplante.qc@gmail.com>
  ║   https://github.com/arsscriptum/
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

#===============================================================================
# SignatureProperties
#===============================================================================

class SignatureProperties
{
    [string]$ValidCertificate = '5784C51A025A7E42DD96B95D8F54AA240BE4C98E'
}

function Get-LocalSigningCert{
    <#
    .SYNOPSIS
        Get signing certificate
    .LINK
        https://github.com/arsscriptum/PowerShell.Sandbox/blob/main/Signing/Signing.ps1
    #>    
    
    $SignProps = [SignatureProperties]::new()
    $Instance=gci Cert:\CurrentUser\My -CodeSigningCert | where Thumbprint -eq "$($SignProps.ValidCertificate)"
    return $Instance
}

function Add-Signature{
    <#
    .SYNOPSIS
        Sign a script
    .DESCRIPTION
        Sign a script using a self-signed certificate
    .PARAMETER Path
        The Path of the script to sign
    .EXAMPLE
         Add-Signature -Path .\helloworld.ps1
    .LINK
        https://github.com/arsscriptum/PowerShell.Sandbox/blob/main/Signing/Signing.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    try{
        $Ok = $False
        $ExceptMsg = ''
        $cert = Get-LocalSigningCert
        if($cert -eq $Null){ throw "Cannot find signing Certificate" }
        Write-Host "✅ Get Signing Certificate"
        $Res = Set-AuthenticodeSignature $Path -Certificate $cert 
        $Status = $Res.Status
        $StatusMessage = $Res.StatusMessage
        Write-Host "✅ Set-AuthenticodeSignature on $Path. Status: $Status, $StatusMessage"
        $Ok = $True
    }catch {
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "[ERROR] Signing {0} : {1}"
        $fields = $Path,$Record.FullyQualifiedErrorId
        $ExceptMsg=($formatstring -f $fields)
        $Ok = $False
        
    }
    if (-not $Ok) {
        $Exception = [System.InvalidOperationException]::new("$ExceptMsg")
        throw $Exception
    }
}

function Check-Signature{
    <#
    .SYNOPSIS
        Validate a script signature
    .PARAMETER Path
        The Path of the script to validate
    .EXAMPLE
         Check-Signature -Path .\helloworld.ps1
    .LINK
        https://github.com/arsscriptum/PowerShell.Sandbox/blob/main/Signing/Signing.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )    
    try{
        $Ok = $False
        $ExceptMsg = ''        

        $cert = Get-LocalSigningCert
        if($cert -eq $Null){ throw "Cannot find signing Certificate" }
        Write-Host "✅ Get Signing Certificate"
        $Res = Get-AuthenticodeSignature $Path 
        $Status = $Res.Status
        $StatusMessage = $Res.StatusMessage
        $SignerCertificate = $Res.SignerCertificate
        if($Status -ne 'Valid'){ throw "Script not signed or invalid signature!" }
        if($cert -ne $SignerCertificate){ throw "Script signed with wrong certificate ($SignerCertificate)" }
        Write-Host "✅ Signature $Path. Status: $Status, $StatusMessage"
        $Ok = $True
    }catch {
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "[ERROR] Verification failed for {0} : {1}"
        $fields = $Path,$Record.FullyQualifiedErrorId
        $ExceptMsg=($formatstring -f $fields)
        $Ok = $False
        
    }
    if (-not $Ok) {
        $Exception = [System.InvalidOperationException]::new("$ExceptMsg")
        throw $Exception
    }
}

