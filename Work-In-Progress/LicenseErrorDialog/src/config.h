#pragma once
// Copyright © 2015 Alf P. Steinbach
#undef  STRICT
#define STRICT
#undef  NOMINMAX
#define NOMINMAX
#undef  UNICODE
#undef  MBCS        // Treat MBCS as an unsupported no-effect symbol.
#define UNICODE
#undef  WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#undef  OEMRESOURCE
#define OEMRESOURCE
//#include <windows.h>

#if defined( __cplusplus )
#define USRMSG_EXPORT extern "C" __declspec(dllexport)
#else
#define USRMSG_EXPORT __declspec(dllexport)
#endif // __cplusplus



// define constant
#define MB_MASK_BUTTON           0x00000007L
#define MB_MASK_ICON             0x00000070L
