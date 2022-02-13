@echo off


set kill_exe=%windir%\system32\taskkill.exe

%kill_exe% /im shortcuts.exe /f
del /F /Q %ToolsRoot%\shortcuts.exe
