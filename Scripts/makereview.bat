@echo off
setlocal


rem ################################################
rem # makereview.bat: script to run rbt post to 
rem # create a review on review board

set taskid=%1
set changelist1=%2
set changelist2=%3
set mypath=%cd%

IF "%changelist1%"=="" (GOTO INVALIDARGUMENTS) 
IF "%taskid%"=="" (GOTO INVALIDARGUMENTS) 

echo.
echo ###############################################
echo  Reviewboard: Creating a Review
echo  Username: %USERNAME%
echo  Changelist1: %changelist1%
echo  Changelist2: %changelist2%
echo  Redmine Task Id: %taskid%
echo  Directory: %mypath%
echo. 

:PROMPT
SET /P AREYOUSURE=Are you sure (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO CANCELED

echo "rbt post --username=%USERNAME% --bugs-closed=%taskid% %changelist1% %changelist2%"

rbt post --username=%USERNAME% --bugs-closed=%taskid% %changelist1% %changelist2%

goto ENDOK

:CANCELED
echo Canceled on your request.
endlocal

:INVALIDARGUMENTS
echo Invalid arguments
echo Usage: makereview [changelist number] [redmine task id]
endlocal

:ENDOK
endlocal