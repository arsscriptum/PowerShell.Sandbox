; ########################################
; Nvizzio Auto Hot Key Script
; Author: Guillaume Plante
; ########################################
;
; Usefull key binding:
;	#	Win (Windows logo key)
;	!	Alt
;	^	Control
;	+	Shift
;

;;  #################################################################
;; USEFULL PATH
;; 'ScriptsRoot' = 'K:\scripts'
;; 'ToolsRoot' = 'C:\Programs\SystemTools'
;; 'SystemTools' = 'C:\Programs\SystemTools'        
;; 'SystemToolsRedirects' = 'C:\Programs\SystemTools\Redirects'   

^!t::
   Run, "powershell.exe" -File c:\Windows\System32\taskmgr.ps1
Return

^!0::
   Run, "E:\Programs\Screenshot\screenshot.exe"
Return

^!l::
   Run, "powershell.exe" -File c:\Windows\System32\lock.ps1
Return

^!u::
   Run, "powershell.exe" -File c:\Windows\System32\unlock.ps1
Return

^!g::
   Run, "C:\Users\gplante.BQC\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe"
Return

^!s::
   Run, "C:\Program Files\Sublime Text 3\subl.exe" 
Return

^!d::
   Run, "cmd.exe" 
Return

^!p::
   Run, "%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"
Return

^!z::
   Run, "C:\Programs\Scripts\go-secret.bat" 
Return

^!x::
   Run, "C:\Programs\Scripts\go-discret.bat" 
Return