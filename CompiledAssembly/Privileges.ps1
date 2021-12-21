
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Privilege

    )


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

    #Try {
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
   # }  
   # Catch {
   #     Write-Error "Failed to create $NewDll $_"
   # }    
}

Function Get-TokenManipulatorMembers
{
    [CmdletBinding()]
    Param ()
    $TypeObj = [TokenManipulator]
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

   # try{
      $SourceLen = $Source.Length
      if($Dll){
        $Result = New-CustomAssembly $Source -Dll
        if($Result -eq $Null) {  $Result = [TokenManipulator] ; return $Result}
        if($Import){
            $Obj = Add-Type -LiteralPath "$Result" -Passthru -ErrorAction Stop  
            Write-Host "Custom Type Added: $Result"    
            
            return $Obj
        }

        
      }else{
        $Result = New-CustomAssembly $Source
        if($Result -eq $Null) {  $Result = [TokenManipulator] ; return $Result}
        $Obj = $Result
      }
    #}
    #catch{
    #  Write-Host "Custom Type initialisation error : $_"
    #}
}

$Script:CLASSNAME = 'TokenManipulator'
$Script:PrivilegesCsCode = "H4sIAAAAAAAACu1X3WsjNxB/P7j/QeTJgcXk0pdCuAcn3gb3nMTndQJtKUbendhby9JWH45Nm/+9o9V+aO04Jw761AZCovnNl2ZmRzNG5XxJkr3SsLn6+MF4x/7UcJ1voD/iGqQoEpDbPAWFbB8/kMIsWJ6SlFGlyHw+vxkPkmR+P7iL8YD4X/hLfhsyNtoUQureGc22tMh/uOxnjJ1FJN7RVCcFMGYtfiZaGohIAnpMlY6lFLIinv9uNeXWB04ZUZpqtAs7eyYLIRgZZH8YpWdiDXwi823OYAmqh15PtCQrLdaR48tyRRmLrDoJzwQFLPunsckzwuFF6ciaIQx4RCrpQsK2OUhA6Pzq8GJrdATYuxd79w6V9lvQN0ZKwJMUGGbVOzb178XwobDBK+2WgWzC52JC0zQqg+bIVlthI/tNF7/LmbEQa1M0uXyizEBPaWlvuRI2T9WB0w00+WQCKQXDbFZeJWgtRfN7YXTP/fmS86yfwJ8Gw5xTFpEJTdfo16cjp6xop0QsXhZ1Xfo2LjcCv5Ern1p6YfmvDnkHWsuS+NoxlQqudMmQxPPJdPQ0Gse38Xw4SgbX43iIzl3sLqqfqxDJ+P5I8PKU4OzhS3w///oYT3/x+X98n38w/PkxmbUmE0/20jlZt4dSssrWjQSqoSwvjIz7+UzOEvCAJulnJ9UMlMqXlnFD5b6jrVR2DHs6ySmlY5Gu72Aj5L5xzalrgRA1I57iXRR8NUJTX00HCLjkI1cCibmGbMQLoxtFh0CIV3c0XeUcBmlqy9XzqgsEuDWT2GkhuxEbNI2Ea7ySp2+WLgKUJJAameu9J1iTQlyga3h44SDVKi/8EHeAsJzTbIh8II9yXgMhtykfS+ydz8joa+kAIf44gRk+uQf+OMC+xSFqKosJ/m/tlj3dU/YWHHDNuoBtxpFdHCTwLTjEWffpT+gSfmrC5/UECxyE7xuaQG4ox+5+pKkGAlRd46Ng6tpyShwpQHYKSgvZKYSKFFQCK6Mz8cL95FekANtDWJhlt3RKUojlgcnyqjU0ndSSwgs35ttcCr6pg39Qvh4cks0V5Uu4Fzp/bjqyy6YHhPg2xd6tmyB2suIDQS05w7eg44wjBTUJng6WfmSa2FRAgJKY0wXDjCIXjkyCN0oOgbA3geO39SSYadtN9Sa0QEhf2BTYcQXHT6x7Mw8IbwS3TCxw4Ogk3ANCFNVPlITMDXnuQhIfubIRureiZULYQWEfNy5BddfEidb7xDvACUerWbfaWrKGqx5ui5pw3k6bWu7Lv+7kZCVoHIrdhNndY3RRUev5vUCX0MdT20XLiNM88rlT/1dc+Crc2ULoaEUodUcnZ8K//enSbQ/tyoD3Kvrl9Gyn75ZUXgKnyZZix2akvDXiHnr45t7ADe58bWSdI5Wl80MNb6+Sbod8pkw14hG5iPxgdQ6eWoM7jZ+tcvYnKdXpivTiXQpF+SXD7txPsl5J8YJET+b1RBnZNmYL7/9K+q5KGlZr1n+tlF7/AdNtqUb5EQAA"

$type = Invoke-AssemblyCreation -Dll -Import   

return $type
