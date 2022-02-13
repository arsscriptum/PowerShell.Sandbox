@echo off

SET PWSH_EXE="C:\Programs\PowerShell\7\pwsh.exe"
SET PWSH_SCRIPT="D:\Development\cybercastor\Powershell-Sandbox\Sudo\Invoke-ElevatedPrivilege.ps1"

%PWSH_EXE% %PWSH_SCRIPT% %PWSH_EXE%
