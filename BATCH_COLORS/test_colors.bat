@echo off

:: ==============================================================================
:: 
::   out.bat
:: 	 wrote this to help out u/yyingh on reddit
::
::   https://www.reddit.com/r/PowerShell/comments/uaeqon/command_line_program_output_color/
::   Based on my BuildAutomation scripts
::   https://github.com/arsscriptum/BuildAutomation
:: ==============================================================================
::   arsccriptum - made in quebec 2020 <guillaumeplante.qc@gmail.com>
:: ==============================================================================

call :test_colors
call :__out_d_red "Hi This is a test... wrote this to help out u/yyingh on reddit"
call :__out_d_grn "https://www.reddit.com/r/PowerShell/comments/uaeqon/command_line_program_output_color/"
call :__out_d_yel "Here is dark RED, GREEN and YELLOW, but other escap codes exists:"
call :__out_d_mag "like MAGENTA, and"
call :__out_d_cya "CYAN"
call :__out_l_blu "Based on my BuildAutomation scripts @ https://github.com/arsscriptum/BuildAutomation"
goto :eof

:: ==============================================================================
::   Test colors..
:: ==============================================================================
:test_colors
    echo.
    call :__out_d_red "    RED THIS IS A TEST OF THE OUTPUT COLORS.... 1 2 3 4 5 6 7 8 9"
    call :__out_d_grn "    GREEN THIS IS A TEST OF THE OUTPUT COLORS.... 1 2 3 4 5 6 7 8 9"
    call :__out_d_yel "    YELLOW THIS IS A TEST OF THE OUTPUT COLORS.... 1 2 3 4 5 6 7 8 9"
    echo.
    goto :eof

:: ===========
:: light blue
:__out_l_blu
    echo [94m%~1[0m
    goto :eof

:: ===========
:: dark magena
:__out_d_mag
    echo [35m%~1[0m
    goto :eof
:: ===========
:: dark cyan
:__out_d_cya
    echo [36m%~1[0m
    goto :eof

:: ===========
:: dark red
:__out_d_red
    echo [31m%~1[0m
    goto :eof
:: ===========
:: dark green
:__out_d_grn
    echo [32m%~1[0m
    goto :eof
:: ===========
:: dark yellow
:__out_d_yel
    echo [33m%~1[0m
    goto :eof


::
:: Write the literal string Str to stdout without a terminating
:: carriage return or line feed. Enclosing quotes are stripped.
::
:: This routine works by calling :writeVar
::
:write  Str
  setlocal disableDelayedExpansion
  set "str=%~1"
  call :writeVar str
  exit /b
      :writeVar  StrVar
    if not defined %~1 exit /b
    setlocal enableDelayedExpansion
    if not defined $write.sub call :writeInitialize
    set $write.special=1
    if "!%~1:~0,1!" equ "^!" set "$write.special="
    for /f delims^=^ eol^= %%A in ("!%~1:~0,1!") do (
      if "%%A" neq "=" if "!$write.problemChars:%%A=!" equ "!$write.problemChars!" set "$write.special="
    )
    if not defined $write.special (
      <nul set /p "=!%~1!"
      exit /b
    )
    set string=%~1
    set string=%string:"=%
    set %~1=%string%
    >"%$write.temp%_1.txt" (echo !str!!$write.sub!)
    copy "%$write.temp%_1.txt" /a "%$write.temp%_2.txt" /b >nul
    type "%$write.temp%_2.txt"
    del "%$write.temp%_1.txt" "%$write.temp%_2.txt"
    set "str2=!str:*%$write.sub%=%$write.sub%!"
    if "!str2!" neq "!str!" <nul set /p "=!str2!"
    exit /b


::
:: Defines 3 variables needed by the :write and :writeVar routines
::
::   $write.temp - specifies a base path for temporary files
::
::   $write.sub  - contains the SUB character, also known as <CTRL-Z> or 0x1A
::
::   $write.problemChars - list of characters that cause problems for SET /P
::      <carriageReturn> <formFeed> <space> <tab> <0xFF> <equal> <quote>
::      Note that <lineFeed> and <equal> also causes problems, but are handled elsewhere
::
:writeInitialize
    set "$write.temp=%temp%\writeTemp%random%"
    copy nul "%$write.temp%.txt" /a >nul
    for /f "usebackq" %%A in ("%$write.temp%.txt") do set "$write.sub=%%A"
    del "%$write.temp%.txt"
    for /f %%A in ('copy /z "%~f0" nul') do for /f %%B in ('cls') do (
      set "$write.problemChars=%%A%%B    ""
      REM the characters after %%B above should be <space> <tab> <0xFF>
    )
    exit /b

:: ==============================================================================
::   The end game end / exit
:: ==============================================================================
:end
    exit /B