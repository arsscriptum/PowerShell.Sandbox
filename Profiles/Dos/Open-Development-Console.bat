@echo off

SET VCVARSCRIPT="%MSDEVENVPATH%\VC\vcvarsall.bat"



call %VCVARSCRIPT% amd64
IF "%VisualStudioVersion%" == "" (goto vcerror) else (goto success)
:success
color 0A
echo ========================================================
echo DOS DEVELOPMENT COMMAND PROMPT 
echo ========================================================
echo Environment configured for Visual Studio %VisualStudioVersion%
echo.
echo Ready!
goto done

:vcerror
color 04
echo ERROR! when calling %VCVARSCRIPT%. 
echo Visual Path is %MSDEVENVPATH%
goto done



:done
popd
popd

