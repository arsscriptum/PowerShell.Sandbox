@echo off
:: Run a command as admin

:: parameters
IF %1.==. GOTO nocommand

set command=%1

:: variables
set adminuser=superrad
set adminpass=secrettest
set nircmdexe=%NirsoftRoot%\nircmdc.exe

:: set NirsoftRoot=d:\scripts\Helpers\nirsoft
:: setx NirsoftRoot d:\scripts\Helpers\nirsoft
:: 'NirsoftRoot' = 'd:\scripts\Helpers\nirsoft'

if exist %nircmdexe% (
    goto runcmd
) else (
    goto error
)

:runcmd
echo running %command%
%nircmdexe% runas %adminuser% %adminpass% %command%
goto :EOF

:nocommand
echo error: no command given...
exit /b 1

:error
echo error occured...
echo nirsoft roots is %NirsoftRoot%
echo nirsoft executable is %nircmdexe%
exit /b 1


