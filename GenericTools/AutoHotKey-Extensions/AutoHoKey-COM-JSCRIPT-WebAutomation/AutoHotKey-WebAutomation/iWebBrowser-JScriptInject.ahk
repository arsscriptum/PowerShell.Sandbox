/*
Function written exclusively by Tank with thanks to Sean for creating the COM library
Parameters
pTitle				- 	Input (string) full or partial title case insensitive
URL					-	Input (string) navigates to a Fully qualified URL
DocumentComplete	-	Input (Bool) true advises the function to pause till any navigation is complete
WebBrowser2			-	Output (integer) Interface pointer
left				-	Input/Output (integer) pixels from left of screen that leftmost point of browser occupies 
top					-	Input/Output (integer) pixels from top of screen that topmost point of browser occupies 
height				-	Input/Output (integer) height in pixels
width				-	Input/Output (integer) width in pixels
MenuBar				-	Input/Output (Bool) returns -1 if true any value other than 0 sets to vis
AddressBar			-	Input/Output (Bool) returns -1 if true any value other than 0 sets to vis
StatusBar			-	Input/Output (Bool) returns -1 if true any value other than 0 sets to vis
Visible				-	Input/Output (Bool) returns -1 if true any value other than 0 sets to vis
Returns 			-	iHTMLDocument2	
*/
;; Returns an iHTMLDocument2 object
iWebBrowser2(pTitle="",URL="",DocumentComplete=0,ByRef	WebBrowser2="",ByRef	left="",ByRef	top="",ByRef	height="",ByRef	width="",ByRef	MenuBar="",ByRef	AddressBar="",ByRef	StatusBar="",ByRef	Visible="")
{
	static ShellWindows 											;;	no need to create and destroy this if your automation is going to use the same one all the time
	static iWebBrowser2												;;	no need to create and destroy this if your automation is going to use the same one all the time
	static LocationName												;;	Store the page title of the current window
	If	!ShellWindows	{											;; 	no need to re invent the wheal each time
		oShell 			:= 	COM_CreateObject("Shell.Application")	;; 	there is no need to constantly create and destroy this object
		ShellWindows 	:= 	COM_Invoke(oShell,	"Windows")			;;	leaving a copy of the windows collection avail for future calls just makes sence
		If	!ShellWindows	{										;; 	failure generate an error and exit
			MsgBox, 262160, Windows Collection, Creation of ShellWindows collection failed
			WebBrowser2:=iWebBrowser2
			Return
		}
		COM_Release(oShell)											;;	Now useless no need for it any more
	}
	/* /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	the conditions under which we need to create a new browser bariable are as follows
	the static iWebBrowser2 is blank
	the static LocationName variable has changed
	*/ ;;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If	!iWebBrowser2	{											;;	create a new handle
		
		Gosub,Title
		If	!LocationName	{
			If	!iWebBrowser2	{									;;	No way to continue
				MsgBox, 262160, Error, Without some reference to a valid Internet Explorer window the script cannot continue
				WebBrowser2:=iWebBrowser2
				Return
			}														;;	while it doesnt make sense all w care about is the browser object
			
		}
		Else	{
			Gosub,GetBrowser
		}
	}
	Else	If	(pTitle <> LocationName && pTitle) {				;;	assume this is a request for a new browser handle
		Gosub,GetBrowser
	}
	
	
	If	!iWebBrowser2	{											;;	create a new handle
										;;	No way to continue
		MsgBox, 262160, Error, Without some reference to a valid Internet Explorer window the script cannot continue
		WebBrowser2:=iWebBrowser2
		Return
	}
	Else	{
		WebBrowser2:=iWebBrowser2
		If	URL	{
			COM_Invoke(iWebBrowser2,"Navigate",URL)
			Gosub,Ready
		}
		If	DocumentComplete	{									;;	there are times when outside of sending a URL you need to check the page is fully loaded
			Gosub,Ready
		}
																	;; if you cant create a document it may be something is wrong with your browser object
		If	!iHTMLDocument2	:=	COM_Invoke(iWebBrowser2,"document") {
			MsgBox, 262160, Error, Could not get an iHTMLDocument2`nPlease pass a page title and retry
			iWebBrowser2:=
			Return
		}		
		
		If	StrLen(top) {
			COM_Invoke(iWebBrowser2,"top",top)
		}
		If	StrLen(left) {
			COM_Invoke(iWebBrowser2,"left",left)
		}
		If	height {
			COM_Invoke(iWebBrowser2,"height",height)
		}
		If	width {
			COM_Invoke(iWebBrowser2,"width",width)
		}
		If	StrLen(MenuBar) {
			COM_Invoke(iWebBrowser2,"MenuBar",MenuBar)
		}
		If	StrLen(AddressBar) {
			COM_Invoke(iWebBrowser2,"AddressBar",AddressBar)
		}
		If	StrLen(StatusBar) {
			COM_Invoke(iWebBrowser2,"StatusBar",StatusBar)
		}
		If	StrLen(Visible) {
			COM_Invoke(iWebBrowser2,"Visible",Visible)
		}
		top:=COM_Invoke(iWebBrowser2,"top")
		left:=COM_Invoke(iWebBrowser2,"left")
		height:=COM_Invoke(iWebBrowser2,"height")
		width:=COM_Invoke(iWebBrowser2,"width")
		MenuBar:=COM_Invoke(iWebBrowser2,"MenuBar")
		AddressBar:=COM_Invoke(iWebBrowser2,"AddressBar")
		StatusBar:=COM_Invoke(iWebBrowser2,"StatusBar")
		Visible:=COM_Invoke(iWebBrowser2,"Visible")
	}
	Return	iHTMLDocument2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; function ends	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	Title:															;;	this internal sub will do the job of working out a title to search for
	{
		If	!pTitle	{
			If	!iWebBrowser2	{ 									;;	to prevent ambiguity
				IfWinNotExist,ahk_class IEFrame,,,					;;	No IE window exists
				{
					MsgBox, 262180, No Internet Explorer, No instance of  Internet Explorer has been found `nWould you like to Open your homepage?
					IfMsgBox,yes
					{
						If	!iWebBrowser2 	:= (iWebBrowser2 := COM_CreateObject("InternetExplorer.Application") ) ? (iWebBrowser2,COM_Invoke(iWebBrowser2 , "Visible=", "True")) :
						{
							MsgBox, 262160, Error, Could not start Internet Explorer
							Return									;;	return to the function	
						}
						Else	{
							COM_Invoke(iWebBrowser2,	"GoHome")
							Gosub,Ready
							LocationName	:=	COM_Invoke(iWebBrowser2,	"LocationName")
							Return									;;	return to the function		
						}
					}
					Else	{
						MsgBox, 262160, Error, No active Internet Explorer window was found
						Return
					}
				}
				Else	{
					WinGetTitle,LocationName,ahk_class IEFrame
					StringSplit,LocationName,LocationName,-			;;	ensure no crazy browser suffixes
					LocationName=%LocationName1%
					Return											;;	return to the function	
				}
			}
			Else	{
				LocationName	:=	COM_Invoke(iWebBrowser2,	"LocationName")
				Return												;;	return to the function		
			}
		}
		Else	{
			StringSplit,LocationName,pTitle,-						;;	ensure no crazy browser suffixes
			LocationName=%LocationName1%
			Return													;;	return to the function
		}
	}
	
	
	Ready:
	{
		loop 10							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
		{	
			If not (rdy:=COM_Invoke(iWebBrowser2,"readyState") = 4)
				Break					;	return success
			Sleep,100					;	sleep .1 second between cycles
		}
		loop 80							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
		{	
			If (rdy:=COM_Invoke(iWebBrowser2,"readyState") = 4)
				Return					;	Done
			Sleep,500					;	sleep half second between cycles
		}
		MsgBox, 262160, Error, While waiting for IE to return to a DocumentComplete the script exceeded the wait time
		Return
	}
	
	
	GetBrowser:
	{
	If	LocationName	{										;; conditions for when to create a new browser handle
			Loop, %	COM_Invoke(ShellWindows,	"Count")			;;	loop thru all the windows and find a match
			{
				Name	:=	COM_Invoke(ShellWindows,"Item[" A_Index-1 "].LocationName")
				IfInString,Name,%LocationName%
				{
					iWebBrowser2	:=	COM_Invoke(ShellWindows,"Item",A_Index-1)
					LocationName	:=	COM_Invoke(iWebBrowser2,"LocationName")
					Return
				}
			}
		}
		Else	{
			MsgBox, 262160, Error, Without some reference to a valid Internet Explorer window the script cannot continue
			Return
		}
		If	!iWebBrowser2	{
			MsgBox, 262160, Error, No instance of Internet Explorer matches the page title %LocationName% `nThe script cannot continue
			Return
		}
		
	}	
}I am hoping this simplifies for many accessing an Internet Explorer window
works well on versions 6-8 probably 5.x as well but cant test that

Sending a blank title will use the topmost avail IE browser in the absence of an open instance of IE will prompt the user to create one

Please remember to uninitialise COM when you are done

Why did I write this
My current library of functions still seems to confuse many

This new function handles
waiting for a page load
navigating to a web site
manipulating the visibility position and size of the intended browser

gives a wide range of example of the ability to use MSDN references to manipulate the browser

Use like this
iWebBrowser2("auto","http://google.com") ; auto for title of an autohotkey page sorry that was confusing to me too a month later
Injecting Javascript done like so
COM_CoInitialize()
iHTMLDocument2:=iWebBrowser2("IE7","","",iWebBrowser2)
js=
(
alert("Hi this was javascript");
var xx="I just retreived a javascript variable";
)
COM_Invoke(iHTMLDocument2,	"parentwindow.execscript",js)
MsgBox	% COM_Invoke(iHTMLDocument2,	"parentwindow.xx")
COM_Release(iHTMLDocument2)	
COM_Release(iWebBrowser2)	
COM_CoUnInitialize()
ExitApp