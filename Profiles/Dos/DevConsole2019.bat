@echo off

set vs_2019_build_tools="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools"
pushd %vs_2019_build_tools%
call LaunchDevCmd.bat
popd

