@echo off
set PSSCRIPT=c:\Programs\Scripts\Send-Email.ps1

waitfor SECRETSHUTDOWN
set PSSCRIPT=c:\Programs\Scripts\Send-Email.ps1

set SUBJECT="Secret Shutdown"
powershell.exe -NoProfile -File %PSSCRIPT%
shutdown /r /t 01
