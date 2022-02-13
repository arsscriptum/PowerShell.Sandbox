@echo off

set FOLDER=%1
echo Will grant full permissions to everyone on this folder: %FOLDER%

set /p Input=Enter Yes or No:
If /I "%Input%"=="y" goto yes
goto no
:yes
echo "--> icacls %FOLDER% /remove:d Everyone /grant:r Everyone:(OI)(CI)F /T  "
icacls %FOLDER% /remove:d Everyone /grant:r Everyone:(OI)(CI)F /T  
:no
pause