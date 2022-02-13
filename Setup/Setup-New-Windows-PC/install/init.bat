@echo off

set workingdir=%cd%
set statefile=%workingdir%\process.state
set poshscript=%workingdir%\setup.ps1
set poshoptions=-NoLogo -Mta -NonInteractive -ExecutionPolicy Unrestricted

pushd %workingdir%
net stop daswebserver
powershell.exe %poshoptions% -File %poshscript%

if errorlevel 2 (
   echo Exit Reason Given is %errorlevel% . Already running...
   exit /b %errorlevel%
)

if errorlevel 0 (
   echo Successfully executed!
   net start daswebserver
   exit /b %errorlevel%
)

if errorlevel 1 (
   echo Done
   taskkill /im powershell.exe /f
   taskkill /im cmd.exe /f
   exit /b %errorlevel%
)

popd
