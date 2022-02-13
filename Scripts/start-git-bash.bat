@echo off

:: git bash may be located either in

:: ProgramsPath: c:\Programs\Git
:: ProgramsPath: c:\Program File\Git

IF EXIST %ProgramsPath%\Git\git-bash.exe ( set bash_exec=%ProgramsPath%\Git\git-bash.exe ) ELSE ( set bash_exec=%ProgramFiles64%\Git\git-bash.exe )

cmd.exe /c "%bash_exec%"