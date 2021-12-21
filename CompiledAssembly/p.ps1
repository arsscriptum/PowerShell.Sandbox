
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Privilege

    )




function Convert-ToBase64CompressedScriptBlock {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        $ScriptBlock
    )

    # Script block as String to Byte array
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    [Byte[]] $ScriptBlockEncoded = $Encoding.GetBytes($ScriptBlock)

    # Compress Byte array (gzip)
    [System.IO.MemoryStream] $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $MemoryStream, ([System.IO.Compression.CompressionMode]::Compress)
    $GzipStream.Write($ScriptBlockEncoded, 0, $ScriptBlockEncoded.Length)
    $GzipStream.Close()
    $MemoryStream.Close()
    $ScriptBlockCompressed = $MemoryStream.ToArray()

    # Byte array to Base64
    [System.Convert]::ToBase64String($ScriptBlockCompressed)
}

function Convert-FromBase64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Base64 to Byte array of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Decompress data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $GzipStream.CopyTo($MemoryStream)
    $GzipStream.Close()
    $MemoryStream.Close()
    $InputStream.Close()
    [Byte[]] $ScriptBlockEncoded = $MemoryStream.ToArray()

    # Byte array to String
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    $Encoding.GetString($ScriptBlockEncoded) | Out-String
}


function Show-ExceptionDetails{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor DarkGreen
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor DarkGreen       
    }
}  


class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'PRIVILEGES'
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Global:ChannelProps = [ChannelProperties]::new()

function New-CustomAssembly{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [switch]$Dll
    )    
       
    if($Dll){
        [string]$NewFile = (New-TemporaryFile).Fullname
        [string]$NewDllPath = (Get-Item $NewFile).DirectoryName
        [string]$NewDllName = (Get-Item $NewFile).Basename
        [string]$NewDllName += '.dll'
        $NewDll = Join-Path $NewDllPath $NewDllName
        Rename-Item $NewFile $NewDll
        Remove-Item $NewDll -Force
 
    }
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'

    Try {
        if($Dll){
          $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru 
          if(Test-Path $NewDll){
            return $NewDll
          }
        }
        else{
          return Add-Type $Source -PassThru 
        }

        return $null
    }  
    Catch {
        Write-Error "Failed to create $NewDll $_"
    }    
}

Function Get-MemberFromTypeObj
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [System.Object]$TypeObj
    )
   
    $RawMembers = $TypeObj.GetMembers()

    [System.Collections.ArrayList]$OutputMembers = @()
    Foreach ( $RawMember in $RawMembers ) {
        
        $OutputProps = [ordered]@{
            'Name'= $RawMember.Name
            'MemberType'= $RawMember.MemberType
        }
        $OutputMember = New-Object -TypeName psobject -Property $OutputProps
        $OutputMembers += $OutputMember
    }
    $OutputMembers | Select-Object -Property * -Unique
}

function Invoke-AssemblyCreation{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Dll,        
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Import        
    ) 

    $Source = Convert-FromBase64CompressedScriptBlock $Script:PrivilegesCsCode
    $Source = $Source.Replace('___CLASS_NAME___', $Script:CLASSNAME)

    try{
      $SourceLen = $Source.Length

      if($Dll){
        $Result = New-CustomAssembly $Source -Dll
        if($Result -eq $Null) { throw "Error on Dll creation" }
        if($Import){
            $Obj = Add-Type -LiteralPath "$Result" -Passthru -ErrorAction Stop  

            return $Obj
        }
        
      }else{
        $Result = New-CustomAssembly $Source
        if($Result -eq $Null) { throw "Error on Dll creation" }
        $Obj = $Result
      }
    }
    catch{
      Write-Host "Custom Type initialisation error : $_"
    }
}

$Script:CLASSNAME = 'TokenMod'
$Script:PrivilegesCsCode = "H4sIAAAAAAAACu1X3WsjNxB/P7j/QeTJgcXk0pdCuAcn3gb3nMTndQJtKUbendhby9JWH45Nm/+9o9V+aO04Jw761AZCovnNl2ZmRzNG5XxJkr3SsLn6+MF4x/7UcJ1voD/iGqQoEpDbPAWFbB8/kMIsWJ6SlFGlyHw+vxkPkmR+P7iL8YD4X/hLfhsyNtoUQureGc22tMh/uOxnjJ1FJN7RVCcFMGYtfiZaGohIAnpMlY6lFLIinv9uNeXWB04ZUZpqtAs7eyYLIRgZZH8YpWdiDXwi823OYAmqh15PtCQrLdaR48tyRRmLrDoJzwQFLPunsckzwuFF6ciaIQx4RCrpQsK2OUhA6Pzq8GJrdATYuxd79w6V9lvQN0ZKwJMUGGbVOzb178XwobDBK+2WgWzC52JC0zQqg+bIVlthI/tNF7/LmbEQa1M0uXyizEBPaWlvuRI2T9WB0w00+WQCKQXDbFZeJWgtRfN7YXTP/fmS86yfwJ8Gw5xTFpEJTdfo16cjp6xop0QsXhZ1Xfo2LjcCv5Ern1p6YfmvDnkHWsuS+NoxlQqudMmQxPPJdPQ0Gse38Xw4SgbX43iIzl3sLqqfqxDJ+P5I8PKU4OzhS3w///oYT3/x+X98n38w/PkxmbUmE0/20jlZt4dSssrWjQSqoSwvjIz7+UzOEvCAJulnJ9UMlMqXlnFD5b6jrVR2DHs6ySmlY5Gu72Aj5L5xzalrgRA1I57iXRR8NUJTX00HCLjkI1cCibmGbMQLoxtFh0CIV3c0XeUcBmlqy9XzqgsEuDWT2GkhuxEbNI2Ea7ySp2+WLgKUJJAameu9J1iTQlyga3h44SDVKi/8EHeAsJzTbIh8II9yXgMhtykfS+ydz8joa+kAIf44gRk+uQf+OMC+xSFqKosJ/m/tlj3dU/YWHHDNuoBtxpFdHCTwLTjEWffpT+gSfmrC5/UECxyE7xuaQG4ox+5+pKkGAlRd46Ng6tpyShwpQHYKSgvZKYSKFFQCK6Mz8cL95FekANtDWJhlt3RKUojlgcnyqjU0ndSSwgs35ttcCr6pg39Qvh4cks0V5Uu4Fzp/bjqyy6YHhPg2xd6tmyB2suIDQS05w7eg44wjBTUJng6WfmSa2FRAgJKY0wXDjCIXjkyCN0oOgbA3geO39SSYadtN9Sa0QEhf2BTYcQXHT6x7Mw8IbwS3TCxw4Ogk3ANCFNVPlITMDXnuQhIfubIRureiZULYQWEfNy5BddfEidb7xDvACUerWbfaWrKGqx5ui5pw3k6bWu7Lv+7kZCVoHIrdhNndY3RRUev5vUCX0MdT20XLiNM88rlT/1dc+Crc2ULoaEUodUcnZ8K//enSbQ/tyoD3Kvrl9Gyn75ZUXgKnyZZix2akvDXiHnr45t7ADe58bWSdI5Wl80MNb6+Sbod8pkw14hG5iPxgdQ6eWoM7jZ+tcvYnKdXpivTiXQpF+SXD7txPsl5J8YJET+b1RBnZNmYL7/9K+q5KGlZr1n+tlF7/AdNtqUb5EQAA"
   
$obj = Invoke-AssemblyCreation -Dll -Import
#Get-MemberFromTypeObj $Obj


function Convert-SIDtoName([String[]] $SIDs, [bool] $OnErrorReturnSID) {
    foreach ($sid in $SIDs) {
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid) 
            $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
            $objUser.Value
        } catch { if ($OnErrorReturnSID) { $sid } else { "" } }
    }
}

function Get-SIDUSerTable {
    [CmdletBinding(SupportsShouldProcess)]
    param ()  
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    $UserTable = [System.Collections.ArrayList]::new()
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $username = $UsersSIDs[$i].SubString(0,$SidIndex)
        $username = $username.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $res = [PSCustomObject]@{
                Username            = $username
                SID                 = $sid
        }
        $UserTable.Add($res)
    }
    return $UserTable
}

function Get-SIDValueForUSer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $usr = $UsersSIDs[$i].SubString(0,$SidIndex)
        $usr = $usr.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $sid = $sid.trim()
        $res = [PSCustomObject]@{
                Username            = $usr
                SID                 = $sid
        }
        if($Username -eq $usr){
            return $res
        }
    }
   
    return $null
}

function Get-USerSID
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = Get-SIDValueForUSer $Username
        return $sid
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}

function Get-UserNtAccount
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = (Get-USerSID $Username).SID
        $value = (Convert-SIDtoName $sid)
        $obj = $(new-object security.principal.ntaccount "$value")
        [System.Security.Principal.IdentityReference]$Principal = $(new-object security.principal.ntaccount "$value")
        return $Principal
       
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}
 
 
function Set-Owner {

<#
    .SYNOPSIS
    Set-Ownership of a file / folder

    .DESCRIPTION
    Invoke [TokenMod]::AddPrivilege (privileges.ps1) to add the privileges then change the ownership

    .PARAMETER Path
    The search term to query

    .PARAMETER Principel
    $u = $(new-object security.principal.ntaccount "$env:computername\MyUSer")
    or
    Get-UserNtAccount MyUSer
    .EXAMPLE 
       Set-Owner -Path "c:\Tmp" -Principal $(new-object security.principal.ntaccount "$env:computername\MyUSer")



#>


    [CmdletBinding()]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [System.Security.Principal.IdentityReference]$Principal
    )  

    $errPref = $ErrorActionPreference
    $ErrorActionPreference= "silentlycontinue"
    $type = [TokenMod]
    $ErrorActionPreference = $errPref
    if($type -eq $null){
        throw "NO TYPE TokenMod registered"
    }
    $acl = Get-Acl $Path
    $acl.psbase.SetOwner($Principal)
    [void][TokenMod]::AddPrivilege("SeRestorePrivilege")
    set-acl -Path $Path -AclObject $acl -passthru
    [void][TokenMod]::RemovePrivilege("SeRestorePrivilege")
}



function Set-OwnerU {

<#
    .SYNOPSIS
    Set-Ownership of a file / folder

    .DESCRIPTION
    Invoke [TokenMod]::AddPrivilege (privileges.ps1) to add the privileges then change the ownership

    .PARAMETER Path
    The search term to query

    .PARAMETER Username

    .EXAMPLE 
       Set-Owner -Path "c:\Tmp" -Username $(new-object security.principal.ntaccount "$env:computername\MyUSer")



#>


    [CmdletBinding()]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Username
    )  

    try{
        Write-Host '[Set-OwnerU] ' -n -f DarkRed
        Write-Host "$Path to Owner $Username" -f DarkYellow        
        [System.Security.Principal.IdentityReference]$Principal = Get-UserNtAccount $Username
        if($Principal -eq $NUll) { throw "CANNOT FIND Principal.IdentityReference for $Username" }
        Set-Owner -Path $Path -Principal $Principal
    }
    catch{
         Show-ExceptionDetails $_
    }
}
    