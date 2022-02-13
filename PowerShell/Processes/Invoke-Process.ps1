##===----------------------------------------------------------------------===
##  Invoke-Process.ps1 - PowerShell script
##
##  Invoke-Process is a simple wrapper function that aims to "PowerShellyify" 
##  launching typical external processes. There are lots of ways to invoke 
##  processes in PowerShell with Start-Process, Invoke-Expression, & and others
##  but none account well for the various streams and exit codes that an external 
##  process returns. Also, it's hard to write good tests when launching external 
##  proceses.
##
##  This function ensures any errors are sent to the error stream, standard output is 
##  sent via the Output stream and any time the process returns an exit code other 
##  than 0, treat it as an error.
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
function Invoke-Process {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,
        [string[]]$ArgumentList
    )

    $ErrorActionPreference = 'Stop'

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $OutTempPath = "$env:TEMP\$(( New-Guid ).Guid)"
        New-Item -ItemType directory -Path $OutTempPath -Force

        $stdOutTempFile = Join-Path $OutTempPath "out.txt"
        $stdErrTempFile = Join-Path $OutTempPath "err.txt"

        Write-Host "StdOut to $stdOutTempFile" -b r -f y
        Write-Host "StdErr to $stdErrTempFile" -b r -f y

        Set-Item -Path Env:StdOutTempFile -Value $stdOutTempFile
        Set-Item -Path Env:StdErrTempFile -Value $stdErrTempFile

        $MyTmpWorkSpace = Join-Path $env:LOCALAPPDATA "Scripts"
        New-Item -ItemType directory -Path $MyTmpWorkSpace -Force
        
        $TmpFile = Join-Path $MyTmpWorkSpace "stdOutTempFile.txt"
        Set-Content -Path $TmpFile -Value $stdOutTempFile -Encoding ASCII
        $TmpFile = Join-Path $MyTmpWorkSpace "stdErrTempFile.txt"
        Set-Content -Path $TmpFile -Value $stdErrTempFile -Encoding ASCII

        $startProcessParams = @{
            FilePath               = $FilePath
            RedirectStandardError  = $stdErrTempFile
            RedirectStandardOutput = $stdOutTempFile
            Wait                   = $true
            PassThru               = $true
            NoNewWindow            = $true
        }
        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run with args: [$($ArgumentList)]")) {
            if ($ArgumentList) {
                Write-Verbose -Message "$FilePath $ArgumentList"
                $cmd = Start-Process @startProcessParams -ArgumentList $ArgumentList
            }
            else {
                Write-Verbose $FilePath
                $cmd = Start-Process @startProcessParams
            }
            $stdOut = Get-Content -Path $stdOutTempFile -Raw
            $stdErr = Get-Content -Path $stdErrTempFile -Raw
            if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
                $stdOut = $stdOut.Trim()
            }
            if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
                $stdErr = $stdErr.Trim()
            }
            $return = [PSCustomObject]@{
                Name            = $cmd.Name
                Id              = $cmd.Id
                ExitCode        = $cmd.ExitCode
                Output          = $stdOut
                Error           = $stdErr
                ElapsedSeconds  = $stopwatch.Elapsed.Seconds
                ElapsedMs       = $stopwatch.Elapsed.Milliseconds
            }
            if ($return.ExitCode -ne 0) {
                throw $return
            }
            else {
                $return
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        #Remove-Item -Path $stdOutTempFile, $stdErrTempFile -Force -ErrorAction Ignore
    }
}

