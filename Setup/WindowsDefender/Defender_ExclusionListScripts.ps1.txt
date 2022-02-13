# Remember to run the script "as Administrator"

$pathExclusions = New-Object System.Collections.ArrayList
$processExclusions = New-Object System.Collections.ArrayList

$pathExclusions.Add('C:\Windows\Microsoft.NET') > $null
$pathExclusions.Add('C:\Windows\assembly') > $null
$pathExclusions.Add($env:USERPROFILE + '\AppData\Local\Microsoft\VisualStudio') > $null
$pathExclusions.Add($env:USERPROFILE + '\.nuget\packages') > $null
$pathExclusions.Add('C:\ProgramData\Microsoft\VisualStudio\Packages') > $null
$pathExclusions.Add('C:\Program Files (x86)\MSBuild') > $null
$pathExclusions.Add('C:\Program Files (x86)\Microsoft Visual Studio') > $null
$pathExclusions.Add('C:\Program Files (x86)\Microsoft SDKs') > $null
$pathExclusions.Add('C:\Program Files\Microsoft VS Code') > $null
$pathExclusions.Add($env:USERPROFILE + '\AppData\Roaming\npm-cache') > $null

foreach ($exclusion in $pathExclusions)
{
    Write-Host "Adding Path Exclusion: " $exclusion
    Add-MpPreference -ExclusionPath $exclusion
}

$processExclusions.Add('devenv.exe') > $null
$processExclusions.Add('dotnet.exe') > $null
$processExclusions.Add('msbuild.exe') > $null
$processExclusions.Add('node.exe') > $null
$processExclusions.Add('node.js') > $null
$processExclusions.Add('perfwatson2.exe') > $null
$processExclusions.Add('ServiceHub.Host.Node.x86.exe') > $null
$processExclusions.Add('vbcscompiler.exe') > $null

foreach ($exclusion in $processExclusions)
{
    Write-Host "Adding Process Exclusion: " $exclusion
    Add-MpPreference -ExclusionProcess $exclusion
}

Write-Host ""
$projectsFolder = Read-Host 'What is your path for projects?'

Write-Host ""
Write-Host "Adding project path to exclusion..."
Add-MpPreference -ExclusionPath $projectsFolder

Write-Host ""
Write-Host "Your Exclusions Path:"

$prefs = Get-MpPreference
$prefs.ExclusionPath
$prefs.ExclusionProcess

Write-Host ""
Write-Host "Your machine is ready to work faster."
Write-Host ""