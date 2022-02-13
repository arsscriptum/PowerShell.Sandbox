@echo off

set SETTINGS_FILE=settings.json
set NEWSETTINGS=settings.json.secret

set TERMINAL_PATH="C:\Users\gplante.BQC\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
pushd %TERMINAL_PATH%

:: if the replacement exists, delete original and replace it
IF EXIST %NEWSETTINGS% (
	echo replacing settings file...
	del /F /Q %SETTINGS_FILE%
	copy %NEWSETTINGS% %SETTINGS_FILE%
	goto :ok
) ELSE (
	echo error
	goto :error
)

:error
popd
exit /b -1


:ok
popd
exit /b 0
