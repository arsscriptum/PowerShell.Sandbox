

$ScriptsRoot = $env:ScriptsRoot
if(!(Test-Path $ScriptsRoot))
{
    $Current = (Get-Location).Path
    Set-Location ../..
    $ScriptsRoot = (Get-Location).Path
    Set-Item -Path Env:ScriptsRoot -Value $ScriptsRoot
}

$EmailScript = Join-Path $env:ScriptsRoot 'PowerShell\Send-Email.ps1'

. $EmailScript


Set-Item -Path Env:MESSAGEBODY -Value 'Update'

Send-Email