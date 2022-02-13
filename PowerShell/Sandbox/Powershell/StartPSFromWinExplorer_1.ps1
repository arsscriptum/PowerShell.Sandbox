


<############################################################################
 ############################################################################
How to start PowerShell from Windows Explorer

Introduction

This sample provides a script for IT pro or windows customers to quickly start PowerShell from Windows Explorer.

For VBScript version, please visit How to start PowerShell from Windows Explorer by VBScript.

Scenarios

IT pro or windows customers might want to start PowerShell in a specific folder from Windows Explorer, e.g. to right-click in a folder and have an option like "Open PowerShell in this Folder".
############################################################################
############################################################################>

<#
  if((Test-Path -Path "HKCR:\Directory\shell\$KeyName")) 
    {
        Write-Warning "The specified key name already exists. Will delete..."
        Try 
        { 
            Set-Location HKCR:\Directory\shell
            Remove-Item -Path "powershell_shell" -Recurse
        }
        Catch 
        { 
             Write-Error $_.Exception.Message 
        } 
    }
    #>

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT 
  

    if(-not (Test-Path -Path "HKCR:\Directory\shell\$KeyName")) 
    { 
        Try 
        { 
            New-Item -itemType String "HKCR:\Directory\shell\$KeyName" -value "Open PowerShell in this Folder" -ErrorAction Stop 
            New-Item -itemType String "HKCR:\Directory\shell\$KeyName\command" -value "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe -noexit -command Set-Location '%V'" -ErrorAction Stop 
            Write-Host "Successfully!" 
         } 
         Catch 
         { 
             Write-Error $_.Exception.Message 
         } 
    } 
    else 
    { 
        Write-Warning "The specified key name already exists. Type another name and try again." 
    }