
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Privilege

    )



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
       
    [string]$NewFile = (New-TemporaryFile).Fullname
    [string]$NewDllPath = (Get-Item $NewFile).DirectoryName
    [string]$NewDllName = (Get-Item $NewFile).Basename
    [string]$NewDllName += '.dll'
    $NewDll = Join-Path $NewDllPath $NewDllName
    Rename-Item $NewFile $NewDll
    Remove-Item $NewDll -Force
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'
    Write-ChannelMessage "NewDll $NewDll"
    Write-ChannelMessage "CompilerOptions $CompilerOptions"
    Write-ChannelMessage "OutputType $OutputType"
   
    Try {
        if($Dll){
          $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru  
        }
        else{
          $Result = Add-Type -TypeDefinition $Source -PassThru 
        }
        if(Test-Path $NewDll){
            return $NewDll
        }
        return $null
    }  
    Catch {
        Write-Error "Failed to create $NewDll"
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

function New-TcpServerAssembly{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [switch]$ListMembers
    ) 

    $SourceFile = Join-Path $PSScriptRoot "CSharpSource"
    $SourceFile = Join-Path $SourceFile 'TcpClientServer.cs'
    Write-ChannelMessage "Source File $SourceFile"
    $Source = Get-Content -Path $SourceFile -Raw

    try{
      $Result = New-CustomAssembly $Source -Dll
      if($Result -eq $Null) { throw "Error on Dll creation" }
      $Obj = Add-Type -LiteralPath "$Result" -Passthru -ErrorAction Stop  
      Write-Host "Custom Type Added: $Result"
      if($ListMembers){
        Get-MemberFromTypeObj $Obj
      }
    }
    catch{
      Write-Host "Custom Type initialisation error : $_"
    }
}


New-TcpServerAssembly
#[void][TcpAssembly]::StartServer(22001) 
#[void][TcpAssembly]::Connect("127.0.0.1", 22001) 