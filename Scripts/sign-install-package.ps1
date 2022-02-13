# FROMM https://weblog.west-wind.com/posts/2016/oct/25/automating-installation-builds-and-chocolatey-packaging

$cur="$PSScriptRoot"
$source="$PSScriptRoot\..\MarkdownMonster"
$target="$PSScriptRoot\Distribution"

robocopy ${source}\bin\Release ${target} /MIR
copy ${cur}\mm.bat ${target}\mm.bat
del ${target}\*.vshost.*
del ${target}\*.pdb
del ${target}\*.xml

del ${target}\addins\*.pdb
del ${target}\addins\*.xml

cd $PSScriptRoot

& "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\signtool.exe" sign /v /n "West Wind Technologies" /sm /s MY /tr "http://timestamp.digicert.com" /td SHA256 /fd SHA256 ".\Distribution\MarkdownMonster.exe"


"Running Inno Setup..."
& "C:\Program Files (x86)\Inno Setup 5\iscc.exe" "MarkdownMonster.iss" 

& "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\signtool.exe" sign /v /n "West Wind Technologies" /sm  /tr "http://timestamp.digicert.com" /td SHA256 /fd SHA256 ".\Builds\CurrentRelease\MarkdownMonsterSetup.exe"


"Zipping up setup file..."
7z a -tzip "$PSScriptRoot\Builds\CurrentRelease\MarkdownMonsterSetup.zip" ".\Builds\CurrentRelease\MarkdownMonsterSetup.exe"