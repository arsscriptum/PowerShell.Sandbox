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

set outpath=%solutiondir%\bin\Debug
pushd %outpath%
bccmhost-srv-runner.exe debug
popd
