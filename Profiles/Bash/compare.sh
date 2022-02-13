#!/bin/sh


# BCompare.exe 
# This is the main application.  
# Only one copy will run at a time, regardless of how many windows you have open.  
# If you launch a second copy it will tell the existing copy to start a comparison and exit immediately.

# BComp.exe 
# This is a Win32 GUI program.  
# If launched from a version control system, it should work just fine.  
# If launched from a console window, the console (or batch file) will not wait for it.

# BComp.com 
# This is a Win32 console program.  It has to have a console.  
# If you launch it from one (or a batch file) that console will wait for the comparison to complete before returning.  
# If you launch it from a version control system interactively, it will show a console window while it's waiting.

# "C:\Users\gplante\AppData\Local\Beyond Compare 4\BCompare.exe"
# /cygdrive/c/Users/gplante/AppData/Local/Beyond Compare 4/BCompare.exe


# echo "/c/Users/gplante/AppData/Local/Beyond Compare 4/BCompare.exe" "`cygpath -aw $1`" "`cygpath -aw $2`" "`cygpath -aw $3`"

"/c/Users/gplante/AppData/Local/Beyond Compare 4/BCompare.exe" "`cygpath -aw $1`" "`cygpath -aw $2`" "`cygpath -aw $3`"