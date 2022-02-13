/*!
* \warning     Copyright (c) 2019 Laboratoires Bodycad inc., All rights reserved
*
* \date        2019-10-21
* \author      Guillaume Plante
*
* \file        main.cpp
* \brief       This project is a very simple strainghforward DLL with one purpose: display a messagebox
*              with codemeter-specific messages.
*/

#include <windows.h>
#include <commctrl.h>       // InitCommonControlsEx, etc.
#include <stdexcept>

using std::runtime_error;

static int const init = []() -> int
{
	DWORD const icc_flags = ICC_WIN95_CLASSES;  // Minimum that works.
	INITCOMMONCONTROLSEX const params = { sizeof(params), icc_flags };
	bool const ok = !!InitCommonControlsEx(&params);
	if (not ok)
	{
		throw std::runtime_error("InitCommonControlsEx failed");
	}
	return 42;
}();



auto main() -> int
{
    MessageBox( 0, L"This is merely an example.", L"I say…", MB_ICONINFORMATION );
}



/*****************************************************************************
ShowMessageDialog
==============================================================================

The ShowMessageDialog function is called whenever a message is to be output.
These can be purely informational messages, warnings or error messages.
Correspondingly, the further sequence can be controlled (with warnings and errors)
via the return value of the function.

*****************************************************************************/
USRMSG_EXPORT UINT __cdecl ShowMessageDialog(
	HWND hWnd, UINT ulStyle, CHAR *pszTitle, CHAR *pszMsg, UINT idError, void *pvCtrl)
{
	switch (idError) 
	{
		case 100000: //Driver version too old
		case 100001: //Expiration Time Warning
		case 100002: //Pay per Use Warning
		case 100004: //Time difference Error
		case 100006: //Certified Time Error
		default:   //other CodeMeter Error codes
	}

	UINT guiElements = 0;
	//set buttons
	guiElements |= (ulStyle & MB_MASK_BUTTON);
	//set icon
	guiElements |= (ulStyle & MB_MASK_ICON);

	INT_PTR nReturn = IDCANCEL;
	nReturn = MessageBox(0, L"What the fuck bro!.", L"I say…", guiElements);


	return (UINT)nReturn;
}

/*****************************************************************************
ExecuteUserStartup
==============================================================================

This function is executed before any copy protection specific things are done.

*****************************************************************************/
USRMSG_EXPORT void __cdecl  ExecuteUserStartup()
{
}