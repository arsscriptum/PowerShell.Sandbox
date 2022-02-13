@echo off

:: sublime may be located either in

:: ProgramsPath: c:\Programs\Git
:: ProgramsPath: c:\Program File\Git

set sublime1="%ProgramFiles64%\Sublime Text 3\sublime_text.exe"
set sublime2="%ProgramsPath%\SublimeText3\sublime_text.exe"

IF EXIST %sublime1% ( set sublime_exec=%sublime1% ) ELSE ( set sublime_exec=%sublime2% )

cmd.exe /c %sublime_exec%