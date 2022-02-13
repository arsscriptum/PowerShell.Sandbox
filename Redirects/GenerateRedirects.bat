@echo off

:: ===================================================================
@rem GenerateRedirects
@rem Create different executables that will be used by the auto-hotkey program

:: ===================================================================
@rem powershell command prompt
@rem executable: "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"

:: ===================================================================
@rem "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"

setlocal enableextensions

set toolsroot=%cd%\..
set MiscTools=D:\Programs\MiscInPath

rmdir /S /Q %SystemToolsRedirects%
if not exist %SystemToolsRedirects% ( mkdir %SystemToolsRedirects% )

pushd %toolsroot%
set working_directory=%DevelopmentRoot%
set runas_privilege=%SystemRoot%\system32\runas.exe
set shimgen=%ScriptsRoot%\Helpers\tools\shimgen.exe
set admin_exe=%MiscTools%\adminshell.exe
set powershell_exe=%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
set hyper_exe="C:\Users\gplante\AppData\Local\hyper\Hyper.exe"
set reviewtool_exe=%MiscTools%\CreateReview.exe
set cygwin_exe=C:\cygwin\bin\mintty.exe

:: %toolsroot%\start-git-bash.bat - script to star bash,use this if we cant use the exe directly
call "%ScriptsRoot%\get-gitbash-path.bat"
echo Git is in %GIT_PATH%
set git_exe="%GIT_PATH%"

:: ===================================================================
set cmd_exe=%SystemRoot%\system32\cmd.exe
set psise_exe=%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe

:: ===================================================================
set conemu1="%ProgramFiles64%\ConEmu\ConEmu64.exe"
set conemu2="%ProgramsPath%\ConEmu\ConEmu64.exe"
if exist %conemu1% ( set conemu_exe=%conemu1% ) else ( set conemu_exe=%conemu2% )

echo Looking for ConEmu...
echo       -- emulator found at %conemu_exe%

:: ===================================================================
set sublime1="%ProgramFiles64%\Sublime Text 3\sublime_text.exe"
set sublime2="%ProgramsPath%\SublimeText3\sublime_text.exe"
if exist %sublime1% ( set sublime_exec=%sublime1% ) else ( set sublime_exec=%sublime2% )

FOR /F "tokens=*" %%g IN ('whoami') do (SET current_username=%%g)


echo Looking for Sublime...
echo       -- editor found at %sublime_exec%

:: ===================================================================
del /F /Q %SystemTools%\Redirects\*.exe

:: ===================================================================
echo "Generating sublimetext redirect"
%shimgen% --output=%SystemToolsRedirects%\sublimetext3.exe --path=%sublime_exec%
%shimgen% --output=%SystemToolsRedirects%\subl.exe --path=%sublime_exec%

:: ===================================================================
echo "Generating powershell redirects"
%shimgen% --output=%SystemToolsRedirects%\shell-ps.exe --path=%powershell_exe%
%shimgen% --output=%SystemToolsRedirects%\shell-admin-ps.exe --path=%admin_exe% --command="%powershell_exe%"


:: ===================================================================
echo "Generating bash redirects"
%shimgen% --output=%SystemToolsRedirects%\shell-bash.exe --path="%git_exe%"
%shimgen% --output=%SystemToolsRedirects%\shell-admin-bash.exe --path=%admin_exe% --command="%git_exe%"


:: ===================================================================
echo "Generating cygwin redirects"
%shimgen% --output=%SystemToolsRedirects%\shell-cygwin.exe --path=%cygwin_exe% --command="-i /Cygwin-Terminal.ico -T %current_username% -"
%shimgen% --output=%SystemToolsRedirects%\shell-admin-cygwin.exe --path=%admin_exe% --command="%cygwin_exe% -i /Cygwin-Terminal.ico  -T Administrator -"


:: ===================================================================
echo "Generating cmd/dos redirects"
%shimgen% --output=%SystemToolsRedirects%\shell-cmd.exe --path=%cmd_exe% --command="/T:0A /s /k pushd %working_directory% && title Running shell under %USERNAME%"
%shimgen% --output=%SystemToolsRedirects%\shell-admin-cmd.exe --path=%admin_exe% --command="%SystemRoot%\system32\cmd.exe%"


:: ===================================================================
echo "Generating pise redirects"
%shimgen% --output=%SystemToolsRedirects%\pise.exe --path=%psise_exe%
%shimgen% --output=%SystemToolsRedirects%\pise-admin.exe --path=%admin_exe% --command="%psise_exe%"



:: ===================================================================
echo "Generating con emu redirect"
%shimgen% --output=%SystemToolsRedirects%\Redirects\conemu.exe --path=%conemu_exe%

%shimgen% --output=%reviewtool_exe% --path=%makereview_exe%
%shimgen% --output=%SystemToolsRedirects%\git-send.exe --path=%ScriptsRoot%\GenericTools\git-send.bat
%shimgen% --output=%SystemToolsRedirects%\hyper.exe --path=%hyper_exe%

%shimgen% --output=%SystemToolsRedirects%\code.exe --path=%ScriptsRoot%\GenericTools\gotodir.bat --command="%BodycadDevBranch%"
%shimgen% --output=%SystemToolsRedirects%\gobc.exe --path=%ScriptsRoot%\GenericTools\gotodir.bat --command="%BodycadDevBranch%"
%shimgen% --output=%SystemToolsRedirects%\goscripts.exe --path=%ScriptsRoot%\GenericTools\gotodir.bat --command="%Scripts%"

popd
