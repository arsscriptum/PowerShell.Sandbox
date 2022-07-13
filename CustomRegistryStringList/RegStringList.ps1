<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   
#̷𝓍   Optional Copy. Powershell Reddit
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#>

$Global:LogEnabled = $False


function Write-RegLog {

    <#
    .SYNOPSIS
        Copy one or 2 files to a destination folder
    .DESCRIPTION
        Copy one or 2 files to a destination folder 
            - if file size is less than pre-defined value (Threshold) 
            - after asking the user for copy confirmation   
       
    .PARAMETER Message (-m)
        Log Message
    .PARAMETER Type 'wrn','nrm','err','don'
        Message Type
            'wrn' : Warning
            'nrm' : Normal
            'err' : Error
            'don' : Done

    .EXAMPLE 
        log "Copied $Src to $Dst" -t 'don'  
        log "$Src ==> $Destination" -t 'wrn'
        log "test error" -t 'err'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('m')]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [ValidateSet('wrn','nrm','err','don')]
        [String]$Type='nrm',
        [Parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NoReturn
    )

    if($Global:LogEnabled -eq $False){return}
    if( ($PSBoundParameters.ContainsKey('Verbose')) -Or ( $Global:LogVerbose )  ){
        Write-Verbose "$Message"
        return
    }
    switch ($Type) {
        'nrm'  {
            Write-Host -n -f DarkCyan "[REG] " ; if($NoReturn) { Write-Host -n -f DarkGray "$Message"} else {Write-Host -f DarkGray "$Message"}
        }
        'don'  {
            Write-Host -n -f DarkGreen "[DONE] " ; Write-Host -f DarkGray "$Message"  
        }
        'wrn'  {
            Write-Host -n -f DarkYellow "[WARN] " ; Write-Host -f White "$Message" 
        }
        'err'  {
            Write-Host -n -f DarkRed "[ERROR] " ; Write-Host -f DarkYellow "$Message" 
        }
    }
}

New-Alias -Name 'log' -Value 'Write-RegLog' -ErrorAction Ignore -Force


function Get-RegListRootPath{
    return "$ENV:OrganizationHKCU\windows.terminal\tmppaths"
}


function Get-LastIndexForId{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )

    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $LastId = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

        if($Found -eq $False){ return $LastId }
        $LastId = $num
        $num++
        
    }
    log "Return $LastId"
    return $LastId
}

function Get-NextIndexForId{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )
    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Items = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"
        if($Found -eq $True){ $Items++ }
        $num++
        
    }
    $Ret = $Items 
    log "Return $Ret"
    return $Ret
}

function New-RegListItem{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('s')]
        [String]$String,
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('i')]
        [String]$Id
    )

    $Script:RegistryPath = Get-RegListRootPath

    $i = Get-NextIndexForId "$Id"
    log "Get-NextIndexForId `"$Id`" ==> $i "
    
    $NumId = $Id + "_$i"

    
    log "New-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
    $null=New-RegistryValue "$Script:RegistryPath" "$NumId" "$String" "string"


    
}


function Get-RegListLastItem{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id,
        [Parameter(Mandatory=$false)]
        [Alias('d')]
        [switch]$Delete
    )

    $Script:RegistryPath = Get-RegListRootPath

    try{

        if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
        $i = Get-LastIndexForId "$Id"
        log "Get-LastIndexForId `"$Id`" ==> $i "
        
        $NumId = $Id + "_$i"

        
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
        $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

        if($Exists){
            $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
            if($Delete){
                log "Delete Key..."
                $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
            }
            return $Value
        }else{
            throw "Key doesn't exists"
        }      
    }catch{
        log "$_" -t 'err'
    }

    
}


function Get-RegListItemList{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )
    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Id + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
            log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($Found -eq $True){  

                $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

                if($Exists){
                    $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
                    $Null = $Ret.Add($Value)
                }else{
                    break;
                }
                $num++ 
            }    
        } 
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}



function Remove-RegListItemList{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )

    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Id + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
            log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($Found -eq $True){  

                $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

                if($Exists){
                    $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
                    log "Remove-RegistryValue `"$Script:RegistryPath`" `"$NumId`""
                }else{
                    break;
                }
                $num++ 
            }    
        } 
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}

