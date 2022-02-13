function Update-SecurityProtocol() {
    <#
        .SYNOPSIS
        Attemps to set the highest encryption available for the
        SerivePointManager's SecurityProtocol. e.g. TLS 1.2
 
        .DESCRIPTION
        Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192), finally SSL 3.0 (48)
        Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
        exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
        installed (.NET 4.5 is an in-place upgrade).
 
        PowerShell will not set this by default (until maybe .NET 4.6.x). This
        will typically produce a message for PowerShell v2 (just an info
        message though)
    #>
    
  
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192 -bor 48
    } catch {
        Write-Warning 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3, (2) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (3) use the Download + PowerShell method of install. See https://chocolatey.org/install for all install options.'
    }    
}