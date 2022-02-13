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

clear-host
 
# Encode

$File = [System.IO.File]::ReadAllBytes($FilePath);
 
# returns the base64 string
$Base64String = [System.Convert]::ToBase64String($File);

$FileInfo = New-Object System.IO.FileInfo($FilePath)

$NewFilePath = -f "{0}.b64", FileInfo.BaseName

FilePath

# Decode
 
function Convert-StringToBinary {
[CmdletBinding()]
param (
[string] $EncodedString
, [string] $FilePath = (‘{0}\{1}’ -f $env:TEMP, [System.Guid]::NewGuid().ToString())
)
 
try {
if ($EncodedString.Length -ge 1) {
 
# decodes the base64 string
$ByteArray = [System.Convert]::FromBase64String($EncodedString);
[System.IO.File]::WriteAllBytes($FilePath, $ByteArray);
}
}
catch {
}
 
Write-Output -InputObject (Get-Item -Path $FilePath);
}
 
$DecodedFile = Convert-StringToBinary -EncodedString $Base64String -FilePath C:\setup\foo.exe
}


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Encryption of binary file" $FilePath -Foreground Cyan


# "AxProtector.exe" -x -kcm -f6000010 -p5000 -cf0 -d:6.20 -fw:3.00 -sl -nl -cac15,15 -cav -cas100 -we100 -eac -eec -eui -v -# -o:"D:\app.exe" "D:\app.exe"

Encrypt-Executable $FilePath 5000

