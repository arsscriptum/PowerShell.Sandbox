##===----------------------------------------------------------------------===
##  Invoke-AxProtector.ps1 - PowerShell script
##
##  Invoke-AxProtector to protect an executable using CodeMeter
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 

. (Join-Path $env:PowerShellScriptsRoot "\CodeMeter\Invoke-AxProtector.ps1")

$exec_path="D:\Programs\nirsoft-utils"
$archives_path="D:\Programs\nirsoft-packages"
$protector="C:\Program Files (x86)\WIBU-SYSTEMS\AxProtector\Devkit\bin\AxProtector.exe"

#$protect_args += '-u:\"CustomMsg\"'

# Clear the screen
[System.Console]::Clear()

$execfiles=((get-childitem -file $exec_path -filter *.exe) | Select-Object FullName, Name, Directory )
$execfiles.ForEach({
    $protecteddir=Join-Path $_.Directory "protected"
    $protectedname=Join-Path $protecteddir $_.Name

    Write-Host "Invoke-AxProtector on" $_.FullName -Foreground Cyan -NoNewLine

    $res=(Invoke-AxProtector $_.FullName)

    if ($res.ExitCode -ne 0) 
    {
         Write-Host " Error!" $_.Name -Foreground Red
         exit
    }
    else 
    {
        Write-Host "Ok"
        #exit
    }
})