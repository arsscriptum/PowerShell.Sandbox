##===----------------------------------------------------------------------===
##  Invoke-AxProtector.ps1 - PowerShell script
##
##  Invoke-AxProtector to protect an executable using CodeMeter
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
. (Join-Path $env:PowerShellScriptsRoot "\Processes\Invoke-Process.ps1")

function Get-AxProtector-Options {
    [OutputType([Array])]
    [Array] $argOpts
    
    $argOpts = @()
    $argOpts += '-x'
    $argOpts += '-kcm'
    $argOpts += '-f6000010'
    $argOpts += '-p399002'
    $argOpts += '-cf0'
    $argOpts += '-d:6.20'
    $argOpts += '-fw:3.00'
    $argOpts += '-swl'

    # user limit (nn | nl | nx)
    $argOpts += '-nn' # no limit
    # $argOpts += '-nl' # normal user limit
    # $argOpts += '-nx' # exclusive mode

    $argOpts += '-cav'
    $argOpts += '-cas100'
    $argOpts += '-wu1000'
    $argOpts += '-we100'
    $argOpts += '-eac'
    $argOpts += '-eec'
    $argOpts += '-eusc1'
    $argOpts += '-emc'

    # *** Security here ***
    # advanced protection
    # -caa3 1|2|  4|8 (full=13)
    # anti-debug scheme
    # -cag1 1|2|4|8|16|32|64

    $argOpts += '-v'
    $argOpts += '-#'

    # Write-Host $argOpts -Foreground Red
    
    # Actually returning
    $argOpts
}


function Invoke-AxProtector {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ProtectedFilePath
    )

    $ErrorActionPreference = 'Stop'

    try {
        $axProtectorPath = "$env:AXPROTECTOR_SDK\bin"
        $axProtectorExec = Join-Path $axProtectorPath "AxProtector.exe"
        $cmSdkBinPath    = "$env:CODEMETER_SDK\bin"
        $sourceDirectory = [System.IO.Path]::GetDirectoryName($FilePath)
        $sourceFileName  = [System.IO.Path]::GetFileName($FilePath)
        $outputDirectory = Join-Path $sourceDirectory "\protected\"
        $outputFilePath  = Join-Path $outputDirectory $sourceFileName

        if ([string]::IsNullOrEmpty($ProtectedFilePath) -eq $false) 
        {
            $outputFilePath = $ProtectedFilePath
        }

        $args = @()
        $args = Get-AxProtector-Options 
        
        $out='-o:"' + $outputFilePath + '"'
        $in='"' + $FilePath + '"'
        $args += $out
        $args += $in

        $args

        #Write-Host "-AxProtector Input:" $args -Foreground Cyan
        #Write-Host "-AxProtector Output:" $outputFilePath -Foreground Cyan

        $res=(Invoke-Process $axProtectorExec $args)
        $return = [PSCustomObject]@{
                Name            = $FilePath
                OutputFileName  = $outputFilePath
                ExitCode        = $res.ExitCode
                ElapsedSeconds  = $res.ElapsedSeconds
        }

        if ($return.ExitCode -ne 0) {
                throw $return
        }
        else {
            $return
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        
    }
}