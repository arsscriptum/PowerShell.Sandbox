@echo off

if /i "%~1"=="/v"         set "OptVerbose=yes"
if /i "%~1"=="-v"         set "OptVerbose=yes"
if /i "%~1"=="--verbose"  set "OptVerbose=yes"

if defined OptVerbose (
   echo **** DEBUG IS ON
)


set batdir=%~dp0

pushd %~dp0..\..
set solutiondir=%cd%
popd

set outpath=%solutiondir%\external\netlib\examples\bin
pushd %outpath%
netclient.exe
popd
