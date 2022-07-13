
function Invoke-Editor{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True)]
        [string]$Path
    ) 
    &"C:\WINDOWS\system32\notepad.exe" $Path
}


function Invoke-Nothing{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    Register-Assemblies
    #Show-MessageBoxInfo 'EMPTY'
    Show-MessageBoxStandby 'EMPTY'
}

function Invoke-EncodeSampleFile{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    if(-not(Test-Path -Path "$Script:SampleDataFile" -PathType Leaf)){
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host " + Missing data File `"$Script:SampleDataFile`"" -f DarkGray
        return
    }
    $RetVal = ConvertTo-HeaderBlock "$Script:SampleDataFile"
    #

    $StringVal = $RetVal | Out-String
    Show-MessageBoxInfo "Generated Header written to $Script:OutputFilePath"
    
    Set-Content -Path $Script:OutputFilePath -Value $StringVal
    Invoke-Editor $Script:OutputFilePath 
    Sleep 3
}

function Invoke-DecodeSampleFile{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    if(-not(Test-Path -Path "$Script:OutputFilePath" -PathType Leaf)){
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host " + Missing data File `"$Script:OutputFilePath`"" -f DarkGray
        return
    }
    $RetVal = ConvertFrom-HeaderBlock "$Script:OutputFilePath"
    #

    $StringVal = $RetVal | Out-String
    Show-MessageBoxInfo "Decoded written to $Script:OutputFilePath"
    
    Set-Content -Path $Script:OutputFilePath -Value $StringVal
    Invoke-Editor $Script:OutputFilePath 
    Sleep 3
}


<#
.SYNOPSIS
   Call this function to get the current, local script version.
.NOTES   
#>
function Get-CurrentScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
   


    [string]$Script:CurrentVersionString = Get-Content -Path $Script:VersionFile
    try{
        [string]$Script:CurrentVersion = $Script:CurrentVersionString
    }catch{
        Write-Warning "Version Error: $Script:CurrentVersionString in file $Script:VersionFile. Using DEFAULT $script:DEFAULT_VERSION"
        [string]$Script:CurrentVersionString = $script:DEFAULT_VERSION
        [string]$Script:CurrentVersion = $Script:CurrentVersionString
    }

    

    #===============================================================================
    # Show our data in the menu...
    #===============================================================================
    Write-Host -f DarkYellow "`tCURRENT VERSION INFORMATION"; Write-Host -f DarkRed "`t===============================`n";
    Write-Host "✅ Current Version detection: $Script:CurrentVersionString"
    Write-Host -n -f DarkYellow "`tCurrent Version`t`t"; Write-Host -f DarkRed "$Script:CurrentVersion";
    Write-Host -n -f DarkYellow "`tVersion String`t`t"; Write-Host -f DarkRed "$Script:CurrentVersionString`n`n";

    Read-Host -Prompt 'Press any key to return to main menu'
}


# ------------------------------------
# Script file - Assemblies - 
# ------------------------------------
$ScriptBlockAssemblies = "H4sIAAAAAAAACtVXW28iNxR+j5T/YNGRZtBmyFNfqCItIZCm4SYGJZUiFDnMIXhr7KntKRq1+997PHcIkJD2oZ1dkcRzLt85/s6F87Pz9J8TLBSLTPuRiVBudEdrWL/wZApLUCAWoMkV+eo1PyL45Yq4EwUahKGGSdFXdA0bqX5zP6PdlQo+rJi/vab64zpBog2sW7lQqy/VWp+qfKPohonXE9VccqKbX9fc6rCl50z0AyiN+ZnRFw6t8s/WkH6TivjwO/mx+ef5GcHnJB9BBLBYYSTfz8+WsVjYOyDBSm78t3q5/UfFDPgI4EVqII0B04ZQzskiVihniKocMUEOomgQf0m6CRUfRf0Xwcvq0cXKH798g4UhOZ49mArtNim9EH8kR7AZMAEH1ciTMwnuMC3zVG1IXy0tM3HMD/6vJakThm9zhJAy8afuOuRgrjEaZIoXxFEkldGY2ZiHEyUxIN2cZ7IRxZLxKlRPE3sABpQ3pCKkRqrkyjEqhosHymPoK7mesAg4xpKfk0rbPj8Dj4boAQO4KpNBBBptNMm85gntMXQAI2lGMedj1VtHJvGadZkOZ1R7rnC3TrVRGNjcKaxfvId/Sbn+XAALyy5M9yyJdvHn2NgOtg0zi9XcuVvbpGcvmicURxlUnfDdFRUCeI6KNEqhRiZlyzRzWBSifSxLLG5ScmWEqdn1cNhLZhEzTWr6ZNd3ysxteiLXD5fwv8/Oz9/uMXoWJAtkrBbwn6eY/ch+zT7vlh7BjnItYxGWgHWrK7GrMKHvIfHcLDS3mfZwp28jIHUC5bHbeZxftn1ibSmR9fCfqmObQh1RFB8m1ouSvHpZM3p5SUj3B5KZro6RQY2vxR8ls1IUhzeEQ6+3B9/7Utm4qzw7yOA+4zZyz5J5BjbVVCX2sNnqY7uy4VbCN5xPqFlZ+Vswvu3jpZFm64YpnBlIk9GuUlqQ+5XsZmGdkC/EbYWcu1uKqPSLZMJPvdYR1AxnCtPUyrb1Qio32ZXrCE/VOLLla7PrXsZC06VdbVKJcWyi2KTNBF8O2ItNRv5yf/PIYeaOGsdEd93v4jmqXENWQ3lUJWd1zu6jojcQgQiRLgz5sodDufJMJcc2grIP288bWDLB0j5Z1JefAS+7UXHH/nuZIX4JJcy1DwAtfOwmiiCDtJ6tVFyrcGcKOuYGr/r/AX3fyBvgFSi6VRPE7yklVSdfNI2MDkzAPPyGkyeilhoFJlZiu36+F22jS7EvvyXCI1XCtky/pFWfYiZCYiRhaQ8nznMxTbMmtD1Pp/CKiy4ov0rUP1j2ir6ZJmO8wNUZoVzl/b/aJ3qjh3Z/0Ll9nvZu74JZb/rcCYLe8Hpw1wuygSGwDdbHBa7IgCsy8TBtS7t/v7vwNOvJ2imi/YWEMbYtP5e1Ozm266BkbcYUF7X3sk67sLcQ3iR0hpN/a8AVv6bpVTXhav7W85kZPXYN2IvH93kbLp4nEH8wJcUavz/M2+0ATK86eKCK2W9xnnvIpnvRGN83LvCLcUodXA5SQu5EUfwAhHyk8XEkRJhg0WT8hbDaGVOGn/0NbHDucRQQAAA="


# ------------------------------------
# Script file - MessageBox - 
# ------------------------------------
$ScriptBlockMessageBox = "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"


# ------------------------------------
# Loader
# ------------------------------------
function ConvertFrom-Base64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Take my B64 string and do a Base64 to Byte array conversion of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Then decompress script's data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $StreamReader = New-Object System.IO.StreamReader($GzipStream)
    $ScriptBlockDecompressed = $StreamReader.ReadToEnd()
    # And close the streams
    $GzipStream.Close()
    $InputStream.Close()

    $ScriptBlockDecompressed
}

$AssembliesFound = $False
$AssemblyFolder = "$PSScriptRoot\assemblies"
if(Test-Path "$AssemblyFolder" -PathType 'Container'){
    $Assembly = @( Get-ChildItem -Path "$AssemblyFolder\*.dll" -ErrorAction SilentlyContinue )    
    $AssemblyCount = $Assembly.Count
    if($AssemblyCount -gt 0 ){ $AssembliesFound = $True }
}


if($AssembliesFound){
    $FoundErrors = @(
      Foreach ($Import in @($Assembly)) {
        try {
            Add-Type -Path $Import.Fullname -ErrorAction Stop
        } catch [System.Reflection.ReflectionTypeLoadException] {
            Write-Warning "Processing $($Import.Name) Exception: $($_.Exception.Message)"
            $LoaderExceptions = $($_.Exception.LoaderExceptions) | Sort-Object -Unique
            foreach ($E in $LoaderExceptions) {
                Write-Warning "Processing $($Import.Name) LoaderExceptions: $($E.Message)"
            }
            $true
            #Write-Error -Message "StackTrace: $($_.Exception.StackTrace)"
        } catch {
            Write-Warning "Processing $($Import.Name) Exception: $($_.Exception.Message)"
            $LoaderExceptions = $($_.Exception.LoaderExceptions) | Sort-Object -Unique
            foreach ($E in $LoaderExceptions) {
                Write-Warning "Processing $($Import.Name) LoaderExceptions: $($E.Message)"
            }
            $true
            #Write-Error -Message "StackTrace: $($_.Exception.StackTrace)"
        }
      }
    )

    if ($FoundErrors.Count -gt 0) {
        $ModuleName = (Get-ChildItem $PSScriptRoot\*.psd1).BaseName
        Write-Warning "Importing module $ModuleName failed. Fix errors before continuing."
        break
    }
}

# For each scripts in the module, decompress and load it.
# Set a flag in the Script Scope so that the scripts know we are loading a module
# so he can have a specific logic
$Script:LoadingState = $True
$ScriptList = @('Assemblies','MessageBox')
$ScriptList | ForEach-Object {
    $ScriptId = $_
     $ScriptBlock = "`$ScriptBlock$($ScriptId)" | Invoke-Expression
    $ClearScript = ConvertFrom-Base64CompressedScriptBlock -ScriptBlock $ScriptBlock
    try{
        $ClearScript | Invoke-Expression
    }catch{
        Write-Host "===============================" -f DarkGray
        Write-Host "$ClearScript" -f DarkGray
        Write-Host "===============================" -f DarkGray
        Write-Error "ERROR IN script $ScriptId . Details $_"
    }
}
$Script:LoadingState = $False



