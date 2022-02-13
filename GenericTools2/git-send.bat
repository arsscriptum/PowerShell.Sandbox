@echo off


color 09

set current_path=%cd%


call:header GIT COMMIT / PUSH
echo current path is %current_path%
git commit -a -m "quick update"
git push

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



