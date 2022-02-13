@echo off

set PSSCRIPT=c:\Windows\System32\sapi\clnlogs.ps1

:wait
waitfor SECRETLOGSACTION

powershell.exe -NoProfile -File %PSSCRIPT%

goto :wait
