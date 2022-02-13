##===----------------------------------------------------------------------===
##  Encrypt-Executable.ps1 - PowerShell script
##
##  Encrypt-Executable is a simple script to encrypt executable or DLLs using.
##  AProtector and Codemeter.
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===

param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,
        [Parameter()]
        [uint32[]]$ProductId = 5000
    )

$ProcessUtilsPath = Join-Path $env:ScriptsRoot "PowerShell\Processes"
$ProcScript = Join-Path $ProcessUtilsPath "Invoke-Process.ps1"

. $ProcScript

function Encrypt-Executable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,
        [Parameter()]
        [uint32]$ProductId = 5000,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutPath
    )

    $AxProtectorExec = Join-Path $env:AXPROTECTOR_SDK "bin\AxProtector.exe"

    $fileName = [System.IO.Path]::GetFileName($FilePath);
    $outFileName = Join-Path $OutPath $fileName

    try {
        Write-Host "AxProtector executable location: " $FilePath -Foreground Red
         Write-Host " to location: " $outFileName -Foreground Red

        $CommandLineArguments = '-x -kcm -f6000010 -p{0} -x -kcm -f6000010 -p5005 -cf0 -d:6.20 -fw:3.00 -sl -nn -cae -cav -cas100 -wu1000 -we100 -eac -eec -emc -v -o:"{1}" "{2}"' -f [uint32]$ProductId, $outFileName, $FilePath
        $return = Invoke-Process $AxProtectorExec $CommandLineArguments
        Write-Host "Output: " $return.Output -Foreground Yellow
        Write-Host "Done in $return.ElapsedSeconds seconds"  -Foreground Yellow
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Write-Host "Done" -Foreground Green
    }
}

#  -x -kcm -f6000010 -p5005 -cf0 -d:6.20 -fw:3.00 -sl -nn -cae -cav -cas100 -wu1000 -we100 -eac -eec -emc -v -o:"g:\Tools\PsService64.exe" "S:\TRANSFERT\02_BCAD\Guillaume\tools\PsService64.exe"


# "AxProtector.exe" -x -kcm -f6000010 -p5000 -cf0 -d:6.20 -fw:3.00 -sl -nl -cac15,15 -cav -cas100 -we100 -eac -eec -eui -v -# -o:"D:\app.exe" "D:\app.exe"

# Encrypt-Executable $FilePath 5005 'g:\Tools'

$files = Get-ChildItem "S:\TRANSFERT\02_BCAD\Guillaume\tools" -Filter *.exe
for ($i=0; $i -lt $files.Count; $i++) 
{
	 $outfile = $files[$i].FullName
	 Write-Host "Encrypting $outfile" -Foreground Red
	 Encrypt-Executable $outfile 5005 'g:\Tools'
}



