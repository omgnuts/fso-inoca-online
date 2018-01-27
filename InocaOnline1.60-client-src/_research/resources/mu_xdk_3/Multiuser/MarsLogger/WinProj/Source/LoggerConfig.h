/*************************************************************************
* Copyright � 1994-2001 Macromedia, Inc. All Rights Reserved
*
* THE CODE IS PROVIDED TO YOU ON AN "AS IS" BASIS AND "WITH ALL FAULTS,"
* WITHOUT ANY TECHNICAL SUPPORT OR WARRANTY OF ANY KIND FROM MACROMEDIA. YOU
* ASSUME ALL RISKS THAT THE CODE IS SUITABLE OR ACCURATE FOR YOUR NEEDS AND
* YOUR USE OF THE CODE IS AT YOUR OWN DISCRETION AND RISK. MACROMEDIA
* DISCLAIMS ALL EXPRESS AND IMPLIED WARRANTIES FOR CODE INCLUDING, WITHOUT
* LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
* PURPOSE. ALSO, THERE IS NO WARRANTY OF NON-INFRINGEMENT, TITLE OR QUIET
* ENJOYMENT.
*
* YOUR USE OF THIS CODE IS SUBJECT TO THE TERMS, CONDITIONS AND RESTRICTIONS
* SET FORTH IN THE CORRESPONDING LICENSE AGREEMENT BETWEEN YOU AND MACROMEDIA.
*	Name: LoggerConfig.h
*
* 	Purpose: Definitions of Actor class interface(s) and methods for the
*           Sprite Oval Xtra example.
*
****************************************************************************/

#pragma once
#if	!defined(_h_ServerAttrConfig_)
#define	_h_ServerAttrConfig_

#include	"stdio.h"

#define	SERVER		0
#define	MARSXTRA	0

#if defined( DEBUG )
	// Development builds
	#define	__STL_DEBUG				1
#else
	// Release builds - all should be off !
	#undef	__STL_DEBUG
#endif



// Don't include the STL in the precompiled header, since the Mac
// version chokes on some static data members.  We do, however,
// include the configuration info.
#include <stlconf.h>

//--------------------------------------------------------------------------
// Configurations for Macintosh builds:
//--------------------------------------------------------------------------
#if defined ( MACINTOSH )
#undef OLDROUTINENAMES

#if defined(__MC68K__)
#error No 68K versions !
#endif

// Include Metrowerks Mac headers
#include "MacHeaders.c"

#endif		// Mac


//--------------------------------------------------------------------------
// Configurations for Windows builds:
//--------------------------------------------------------------------------
#if defined( WINDOWS )

// DAS:  we get some very, very long names with the STL
#pragma warning (disable : 4786)

const double _PI = 3.14159265359;
const double PI = 3.14159265359;

#include	"iostream.h"

#endif		// Win


//--------------------------------------------------------------------------
// Cross-platform include files that are generally useful...
//--------------------------------------------------------------------------
#include	"OperatorNew.h"


#endif		// _h_ServerAttrConfig_

