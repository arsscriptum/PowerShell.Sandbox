@echo off

set kill_exe=%windir%\system32\taskkill.exe

set PROCESS_LIST=(ncat.exe Bodycad.exe)

color 09

call:header Looking for processes to kill...

:main
for %%i in %PROCESS_LIST% do %kill_exe% /im %%i /f

call:header Operation Finished Successfully

goto Exit

:: Functions

:header
ECHO ================================================= 
ECHO %*
ECHO ================================================= 
EXIT /B 0

:Exit
exit /B 0



