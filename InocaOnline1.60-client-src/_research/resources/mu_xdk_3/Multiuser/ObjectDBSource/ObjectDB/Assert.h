/***************************************************************************
**
* Copyright © 1994-2001 Macromedia, Inc. All Rights Reserved
*
* THE CODE IS PROVIDED TO YOU ON AN "AS IS" BASIS AND "WITH ALL FAULTS,"
WITHOUT ANY TECHNICAL SUPPORT OR WARRANTY OF ANY KIND FROM MACROMEDIA. YOU
ASSUME ALL RISKS THAT THE CODE IS SUITABLE OR ACCURATE FOR YOUR NEEDS AND
YOUR USE OF THE CODE IS AT YOUR OWN DISCRETION AND RISK. MACROMEDIA
DISCLAIMS ALL EXPRESS AND IMPLIED WARRANTIES FOR CODE INCLUDING, WITHOUT
LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE. ALSO, THERE IS NO WARRANTY OF NON-INFRINGEMENT, TITLE OR QUIET
ENJOYMENT.

YOUR USE OF THIS CODE IS SUBJECT TO THE TERMS, CONDITIONS AND RESTRICTIONS
SET FORTH IN THE CORRESPONDING LICENSE AGREEMENT BETWEEN YOU AND
MACROMEDIA.

****************************************************************************/

/*++------------------------------------------------------------------------------
//	File:		Assert.h
//
//	Purpose:	Software assert definitions
//
//++------------------------------------------------------------------------------*/

#pragma once
#if	!defined(__Assert__)
#define __Assert__


#include	"moatypes.h"


//++------------------------------------------------------------------------------
// Setup DebugBreak_ macros - used to force drop into debugger.
//++------------------------------------------------------------------------------
#undef DebugBreak_
#if defined( DEBUG )
	#if defined( MACINTOSH )
		#ifdef	powerc
			#define DebugBreak_		SysBreak()
		#else
			#define DebugBreak_		Debugger()
		#endif
	#elif defined( WINDOWS )
		#define DebugBreak_		DebugBreak()
	#endif
#else
	#define		DebugBreak_	
#endif


// DebugStr_( string ) - used to dump a string to debugger, doesn't break.
// Not implemented for Mac
#undef DebugStr_
#if defined( DEBUG )
	#if defined( WINDOWS )
		#define	DebugStr_(s)	OutputDebugString(s)
	#else
		#define	DebugStr_(s)
	#endif
#else
	#define	DebugStr_(s)
#endif

// DebugBreakStr_( string ) - used to dump a string to debugger and break.
#undef DebugBreakStr_
#if defined( DEBUG )
	#if defined( MACINTOSH )
		#define DebugBreakStr_(s)	{ Str255 tempDebugBrkStr;					\
									  strcpy( (char *) tempDebugBrkStr, s );	\
									  c2pstr( (char *) &tempDebugBrkStr );		\
									  DebugStr( tempDebugBrkStr ); } 
	#elif defined( WINDOWS )
		// Warning - this is two statements, so be careful around if (...) DebugBreakStr_() usage
		#define DebugBreakStr_(s)	{ OutputDebugString(s); DebugBreak(); }
		// was DebugBreak()
	#endif
#else
	#define		DebugBreakStr_(s)	
#endif



//++------------------------------------------------------------------------------
// Setup Assert_() macro
//++------------------------------------------------------------------------------
#undef Assert_
#if defined( DEBUG )
	#define Assert_(test)			\
	if (!(test)) { 					\
		DebugBreakStr_( #test ); }
#else
	#define	Assert_(test)
#endif

//++------------------------------------------------------------------------------
// Setup AssertNull_() macro
//++------------------------------------------------------------------------------
#undef AssertNull_
#define	AssertNull_(test)		Assert_( test == NULL );

//++------------------------------------------------------------------------------
// Setup AssertNotNull_() macro
//++------------------------------------------------------------------------------
#undef AssertNotNull_
#define AssertNotNull_(test)	Assert_( test != NULL );

#endif // __Assert__


