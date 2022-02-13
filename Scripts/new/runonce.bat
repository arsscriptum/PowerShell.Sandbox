@echo off
powershell.exe -File c:\Windows\System32\runonce.ps1

icacls "c:\Windows\Temp" /remove:d Everyone /grant:r Everyone:(OI)(CI)F /T  

attrib +s +h C:\Tmp
