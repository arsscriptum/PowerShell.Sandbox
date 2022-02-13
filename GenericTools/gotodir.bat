@echo off
set newpath=%1
setLocal EnableExtensions
if [%1]==[] (echo gotodir: please specify the directory! -- 'gotodir [path]' && exit /B -1)

echo 'chdir /d %newpath%'

chdir /d %newpath%

