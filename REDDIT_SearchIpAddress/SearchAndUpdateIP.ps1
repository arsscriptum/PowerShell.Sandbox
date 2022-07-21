
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Test-RegistryValue{
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()]$Name
    )

    if(-not(Test-Path $Path)){
        return $false
    }
    $props = Get-ItemProperty -Path $Path -ErrorAction Ignore
    if($props -eq $Null){return $False}
    $value =  $props.$Name
    if($null -eq $value -or $value.Length -eq 0) { return $false }

    return $true
   
}



function Get-EntriesRecursively {
<#
    .Synopsis
     Get the list of entries recursively from the registry
    .Description
    Get the list of entries recursively from the registry, given a property name and root path
    .Parameter Path
     Registry path
    .Parameter Name
    The entry name to search
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$true)]
     [string]$Path,
     [parameter(Mandatory=$true)]
     [string]$Name,
     [parameter(Mandatory=$false)]
     [System.Collections.ArrayList]$Results

    )

    try{
        if($Results -eq $Null){
            $Results = [System.Collections.ArrayList]::new()
            Write-Verbose "Created Results"
        }
        $AllChilds=(Get-Item "$Path\*").PSChildName
        $AllChildsCount=$AllChilds.Count

        foreach($Entry in $AllChilds){
            $exists=Test-RegistryValue "$Path\$Entry" "$Name"
            if($exists){
                $Value=(Get-ItemProperty "$Path\$Entry")."$Name"
                Write-Verbose "Found $Name [$Value]"
                [pscustomobject]$o = @{
                    Path = "$Path\$Entry"
                    Name = $Name
                    Value = $Value
                }

                $Null = $Results.Add($o)    
            }

            $c = (Get-Item "$Path\$Entry\*").Count
            if($c -gt 0){
               $Null = Get-EntriesRecursively -Path "$Path\$Entry" -Name $Name -Results $Results
            }
        }
    return $Results
        
    }catch{
        Write-Error "$_"

    }
}



function Update-IPs {

    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$true)]
     [string]$Path,
     [parameter(Mandatory=$true)]
     [string]$NewIP
    )

    try{
        $IPs = Get-EntriesRecursively $Path -Name 'IP Address'

        foreach($ip in $IPs){
            Write-Verbose "Update IP $($ip.Value) ==> $NewIP [$($ip.Path)]"
            Set-ItemProperty -Path $($ip.Path) -Name $($ip.Name) -Value $NewIP
        }
    }catch{
        Write-Error "$_"

    }        



}