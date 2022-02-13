IE7_InjectJS(MainWindow_Title, JS_to_Inject, VarNames_to_Return="",CheckState=False) 
{    
pwb := getwin(MainWindow_Title) 
   If JS_to_Inject
      execScript(pwb,JS_to_Inject)
   If VarNames_to_Return { 
      StringSplit, Vars_, VarNames_to_Return, `, 
      Loop, %Vars_0% 
         Ret .= getVar(pwb,Vars_%A_Index%)
      StringTrimRight, Ret, Ret, 1 
   } 
   IfEqual,CheckState,1
      complete(pwb)
   COM_Release(pwb),	VarSetCapacity(pwb,	0)
   Return Ret 
}
newGui(top=0,left=0,width=500,hieght=600)
{
	If Not	DllCall("GetModuleHandle", "str", "atl" . Version)
		DllCall("LoadLibrary"    , "str", "atl" . Version)
	DllCall("atl" . Version . "\AtlAxWinInit")
	Gui,	+LastFound	+Resize 
	pwb := COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(),	top,	left,	width,	hieght,	"Shell.Explorer")) 
	gui,show, w%width% h%hieght% ,Gui Browser
	Return	pwb	?	pwb	:	"Error"
}

newIe()
{
	pwb := COM_CreateObject("InternetExplorer.Application")
	COM_Invoke(pwb , "Visible=", "True") ;"False" ;"True" ;uncomment to show
	Return	pwb	?	pwb	:	"Error"
}

getwin(t)
{
	Loop, %	COM_Invoke(psw	:=	COM_Invoke(psh	:=	COM_CreateObject("Shell.Application"),	"Windows"),	"Count")
	{
		LocationName	:=	COM_Invoke(pwb	:=	COM_Invoke(psw,	"Item",	A_Index-1),	"LocationName")
 		IfInString,LocationName,%t%
		{
			COM_Release(psw),	VarSetCapacity(psw,	0),	COM_Release(psh),	VarSetCapacity(psh,	0)
			Return	pwb	
		}
		COM_Release(pwb),	VarSetCapacity(pwb,	0) ;didnt break so release the one we didnt use
	}
	COM_Release(psw),	VarSetCapacity(psw,	0),	COM_Release(psh),	VarSetCapacity(psh,	0)
	Return	0
}

IETabWindow(pwb)
{
   psb  :=   COM_QueryService(pwb,IID_IShellBrowser:="{000214E2-0000-0000-C000-000000000046}")
   DllCall(NumGet(NumGet(1*psb)+12), "Uint", psb, "UintP", hwndTab)
   DllCall(NumGet(NumGet(1*psb)+ 8), "Uint", psb)
   Return	hwndTab
}

nav(pwb,url)						; returns bool 
{
	If not pwb is Integer			;	test to see if we have a valid interface pointer
		ExitApp						;	ExitApp if we dont
;~ 	http://msdn.microsoft.com/en-us/library/aa752133(VS.85).aspx
	navTrustedForActiveX	=	0x0400 
	COM_Invoke(pwb,	"Navigate",	url,	0x0400,	"_self")
	Return							;	return the result(bool) of the complete function 
}									;	nav function end

complete(pwb)						;	returns bool for success or failure
{	
	If not pwb is Integer			;	test to see if we have a valid interface pointer
		ExitApp						;	ExitApp if we dont
	loop 80							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
	{	
		If (rdy:=COM_Invoke(pwb,"readyState") = 4)
			Return 	1				;	return success
		Sleep,500					;	sleep half second between cycles
	}
	Return 0						;	lets face it if it got this far it failed
}									;	end complete
getDomObj(pwb,obj)
{
/*********************************************************************
pwb	-	browser object
obj	-	object reference optionally a comma delimited list of references a name, id, or index of all value can be used
example of useage
the below will take a browser object and try get an object called username
getDomObj(pwb,"username")
This will cycle thru objects username pass and 3 
getDomObj(pwb,"username,pass,3")


*/
	col		:=	collection(pwb)
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	Loop,Parse,obj,`,
	{
		If	itm		:=	item(col,	A_LoopField)	;if this fails there really isnt any need to do below
		{
			tx		:=	COM_Invoke(itm,	T	:=	inpt(itm)	?	"value"	:	"innerHTML")
			StringReplace,tx,tx,`,,[color=darkblue]&[/color][color=darkblue]#44;[/color],all	;	escape all commas in text extracted always
			rslt	.=	tx ","
		}
		COM_Release(itm),	VarSetCapacity(itm,	0)	; release the item reference
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	StringTrimRight, rslt, rslt, 1	;strip trailing coma
	Return	rslt
}
inpt(i)
{
;~ 			http://msdn.microsoft.com/en-us/library/ms534657(VS.85).aspx tagname property
	typ		:=	COM_Invoke(i,	"tagName")
	inpt	:=	"BUTTON,INPUT,OPTION,SELECT,TEXTAREA" ; these things all have value attribute and is likely what i need instead of innerHTML
	Loop,Parse,inpt,`,
		if (typ	=	A_LoopField	?	1	:	"")
			Return 1
	Return
}


clickDomObj(pwb,obj)
{
/*********************************************************************
pwb	-	browser object
obj	-	object reference optionally a comma delimited list of references a name, id, or index of all value can be used
example of useage
the below will take a browser object and try click an object called username
getDomObj(pwb,"username")
This will cycle thru objects username pass and 3 
clickDomObj(pwb,"username,pass,3")


*/
	col		:=	collection(pwb)
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	If	itm		:=	item(col,	obj)	;if this fails there really isnt any need to do below
	{
		COM_Invoke(itm,	"click")
;~ 			release and clear out any objects
		d=1
		COM_Release(itm),	VarSetCapacity(itm,	0)
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	Return	d
}
clickText(pwb,t)
{
/*********************************************************************
pwb	-	browser object
obj	-	object reference optionally a comma delimited list of references a name, id, or index of all value can be used
example of useage
the below will take a browser object and try get an link called username
clickText(pwb,"username")
This will cycle thru objects username pass and 3 
clickText(pwb,"username,pass,3")

*/
	col		:=	collection(pwb,	"links")
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	lnklen	:=	COM_Invoke(col,		"length")
	Loop,%	lnklen
	{
		If	itm		:=	item(col,	A_Index-1)	;if this fails there really isnt any need to do below
		{
			rslt	:=	COM_Invoke(itm,	"innerHTML")
			IfInString,rslt,%t%
			{
				COM_Invoke(itm,	"click")
				d=1
				COM_Release(itm),	VarSetCapacity(itm,	0)
				Break
			}
	;~ 			release and clear out any objects
		}
			COM_Release(itm),	VarSetCapacity(itm,	0)
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	Return	d
}
clickHref(pwb,t)
{
/*********************************************************************
pwb	-	browser object
obj	-	object reference optionally a comma delimited list of references a name, id, or index of all value can be used
example of useage
the below will take a browser object and try get an link called username
clickText(pwb,"username")
This will cycle thru objects username pass and 3 
clickText(pwb,"username,pass,3")

*/
	col		:=	collection(pwb,	"links")
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	lnklen	:=	COM_Invoke(col,	"length")
	Loop,%	lnklen
	{
		If	itm		:=	item(col,	A_Index-1)	;if this fails there really isnt any need to do below
		{
			rslt	:=	COM_Invoke(itm,	"href")
			IfInString,rslt,%t%
			{
				rslt	:=	COM_Invoke(itm,	"click")	
	;~ 			release and clear out any objects
				COM_Release(itm),	VarSetCapacity(itm,	0)
				Break
			}
		}
		COM_Release(itm),	VarSetCapacity(itm,	0)
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	Return	0
}
clickValue(pwb,t)
{
/*********************************************************************
pwb	-	browser object
t	-	text to match from visible button
example of useage
the below will take a browser object and try get an object called username
clickValue(pwb,"submit")


*/
	col		:=	collection(pwb)
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	lnklen	:=	COM_Invoke(col,	"length")
	Loop,%	lnklen
	{
		If	itm		:=	item(col,	A_Index-1)	;if this fails there really isnt any need to do below
		{
			If r:=inpt(itm)
			{
				rslt	:=	COM_Invoke(itm,	"value")
				IfInString,rslt,%t%
				{	
					COM_Invoke(itm,	"click")
					d=1
					COM_Release(itm),	VarSetCapacity(itm,	0)
					break
				}
			}
		}
		COM_Release(itm),	VarSetCapacity(itm,	0)
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	Return	d
}

setDomObj(pwb,obj,t)
{
/*********************************************************************
pwb	-	browser object
obj	-	object reference optionally a comma delimited list of references a name, id, or index of all value can be used
t	-	text to replace existing contents with optionally a comma delimited list of references a name, id, or index of all value can be used
example of useage
the below will take a browser object and try get an object called username and set its value or innerHTML to john
setDomObj(pwb,"username","john")
This will cycle thru objects username pass and 3 and set them in that order to john sam and paul
setDomObj(pwb,"username,pass,3","john,sam,paul")


*/
	col		:=	collection(pwb)
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return	0	
	}
	StringSplit,tt,t,`,
	Loop,Parse,obj,`,
	{
		If	itm		:=	item(col,	A_LoopField)	;if this fails there really isnt any need to do below
		{
			StringReplace,tt%A_Index%,tt%A_Index%,[color=darkblue]&[/color][color=darkblue]#44;[/color],`,,all	;	unescape all commas in text extracted always
;~ 			making invoke take integers as Strings  ",	VT_BSTR:=8"
;~ 			http://www.autohotkey.com/forum/viewtopic.php?p=221631#221631
			COM_Invoke_(itm,	v	:=	inpt(itm)	?	"Value="	:	"innerHTML=",	VT_BSTR:=8,	tt%A_Index%)
			COM_Release(itm),	VarSetCapacity(itm,	0)
			d=1
			Break
		}
		COM_Release(itm),	VarSetCapacity(itm,	0)
	}
	COM_Release(col),	VarSetCapacity(col,	0)
	Return d
}

execScript(pwb,js)
{
	If not pwb is Integer			;	test to see if we have a valid interface pointer
		ExitApp						;	ExitApp if we dont
	If js=
		Return	"js is null"
	IID_IHTMLWindow2   	:=	"{332C4427-26CB-11D0-B483-00C04FD90119}"
	pwin 				:=	COM_QueryService(pwb,	IID_IHTMLWindow2,	IID_IHTMLWindow2)
	COM_Invoke(pwin,	"execScript",	js)
	COM_Release(pwin),	VarSetCapacity(pwin,	0)
	Return
}
getVar(pwb,var)
{
	If not pwb is Integer			;	test to see if we have a valid interface pointer
		ExitApp						;	ExitApp if we dont
	IID_IHTMLWindow2   	:= "{332C4427-26CB-11D0-B483-00C04FD90119}"
	pwin 	:= COM_QueryService(pwb,	IID_IHTMLWindow2,	IID_IHTMLWindow2)
	rslt	:=	var	?	COM_Invoke(pwin,	var)	:	""
	COM_Release(pwin),	VarSetCapacity(pwin,	0)
	Return rslt
	
}
gettext(obj)
{
	Return (obj	Is	Integer	?	(inpt(obj)	?	COM_Invoke(obj,	"value")	:	COM_Invoke(obj,	"innerHTML"))	:	"Error")
}

settext(obj,t)
{
	if obj	Is	Integer
		COM_Invoke_(obj,	v	:=	inpt(typ)	?	"Value="	:	"innerHTML=",	VT_BSTR:=8,	t)
}



collection(pwb,col="all")
{
	pdoc 	:= pdoc(pwb)
	If not pdoc is Integer
	{
		COM_Release(pdoc),	VarSetCapacity(pdoc,	0)
		Return
	}
	c		:=	COM_Invoke(pdoc,	col)
	COM_Release(pdoc),	VarSetCapacity(pdoc,	0)
	Return	c
}

item(col,i)
{
	If not col is Integer
	{
		COM_Release(col),	VarSetCapacity(col,	0)
		Return
	}
	c		:=	COM_Invoke(col,	"Item",	i)
	Return	c
}

pdoc(pwb)
{
	If not pwb is Integer			;	test to see if we have a valid interface pointer
		Return						;	ExitApp if we dont
	IID_IHTMLWindow2   	:= "{332C4427-26CB-11D0-B483-00C04FD90119}"
	pwin 				:= COM_QueryService(pwb,	IID_IHTMLWindow2,	IID_IHTMLWindow2)
	pdoc 				:= COM_Invoke(pwin,			"Document")
	If not pdoc is Integer
	{
		COM_Release(pdoc),	VarSetCapacity(pdoc,	0),	COM_Release(pwin),	VarSetCapacity(pwin,	0)
		Return
	}
	COM_Release(pwin),	VarSetCapacity(pwin,	0)
	Return	pdoc
}


striphtml(txt)
{
	
x = %txt% 
Loop Parse, x, <>
   If (A_Index & 1) 
      y = %y%%A_LoopField% 
	  return y
}

escape_text(txt)
{
	
StringReplace,txt,txt,',\',ALL
StringReplace,txt,txt,"",\"",ALL
;~ StringReplace,txt,txt,`.`.,`.,ALL
StringReplace,txt,txt,`r,%a_space%,ALL
StringReplace,txt,txt,`n,%a_space%,ALL
StringReplace,txt,txt,`n`r,%a_space%,ALL
StringReplace,txt,txt,%a_space%%a_space%,%a_space%,ALL
return txt	
}
; Usage:
;   res := COM_InvokeDeep(res, dotted-path, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
; Example:
;   pBody2 := COM_InvokeDeep(pweb, "document.frames[1].document.body")
;   (returns pointer to the body portion of the HTML document located in the second frame on the
;   loaded web page, where pweb is a pointer to the parent IID_IHTMLWindow2.
;	http://www.autohotkey.com/forum/post-182062.html#182062 and modified to handle 64 bit numbers by me 10/5
COM_InvokeDeep(obj, path, arg1="vT_NoNe", arg2="vT_NoNe", arg3="vT_NoNe", arg4="vT_NoNe", arg5="vT_NoNe", arg6="vT_NoNe", arg7="vT_NoNe", arg8="vT_NoNe")
{
   res := obj
   COM_AddRef(res) ; compensate for loop's Release()
   PathCt := 0
   Loop, Parse, Path, .
   {
	  PathCt++
   }
   Loop, Parse, Path, ., ]
   {
      prop := A_LoopField
      value =
      StringGetPos, i, A_LoopField, [
      IfEqual, ErrorLevel, 0 ; contains index
      {
         StringLeft, prop, A_LoopField, %i%
         StringMid, value, A_LoopField, % i+2
      }
      If (value != "") ; contains index or parameter passed to a method, enclosed in "[]"
      {
         If (prop = "item") or (RegExMatch(value, "^[0-9]+$") = false) ; "item" already specified, or method call
         {
            If (A_Index < PathCt)
               propobj := COM_Invoke(res, prop, value)
            Else
               propobj := COM_Invoke(res, prop, value, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
            COM_Release(res),	VarSetCapacity(res,		0)
            res := propobj
         }
         Else
         {
            propobj := COM_Invoke(res, prop)
            If (A_Index < PathCt)
               itemobj := COM_Invoke(propobj, "Item", value)
            Else
               itemobj := COM_Invoke(propobj, "Item", value, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
            COM_Release(res),	VarSetCapacity(res,		0)
            COM_Release(propobj),	VarSetCapacity(propobj,		0)
            res := itemobj
         }
      }
      Else
      {
         If (A_Index < PathCt)
            propobj := COM_Invoke(res, prop)
         Else
         {
			sParams	:= 12345678
			int:=False
			Loop,	Parse,	sParams
				If	arg%A_LoopField% is Integer
				{
					int:=true
					Break
				}
			If int
			{	
				Loop,	Parse,	sParams
				{	
						If	(arg%A_LoopField% == "vT_NoNe")
						{	
							arg%A_LoopField% := ""
							VT_BSTR%A_LoopField%:=""
						}
						Else
							VT_BSTR%A_LoopField%:=8
				}
				propobj := COM_Invoke_(res, prop, VT_BSTR1,arg1,VT_BSTR2,arg2, VT_BSTR3,arg3, VT_BSTR4,arg4, VT_BSTR5,arg5, VT_BSTR6,arg6, VT_BSTR7,arg7, VT_BSTR8,arg8)
			}
			Else
				propobj := COM_Invoke(res, prop, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
		 }
         COM_Release(res),	VarSetCapacity(res,		0)
         res := propobj
      }
      if !res ; no sense in continuing - object not found (returns 0 or null)
         break
   }
   Return res
}really breife example of use
COM_Init()
pwb	:=	newGui()
nav(pwb,"http://www.google.com")
complete(pwb)
doc	:= 	pdoc(pwb)
q	:=	COM_InvokeDeep(doc,  "getElementsByName[q].item[0].value","123456789132456789")
COM_InvokeDeep(doc,  "parentwindow.execScript","alert('hi')")
COM_Term()
exitappFor the most part i tested most of this extensively but im sure i missed something enjoy kids	