/*++------------------------------------------------------------------------------
//	File:		SrvXtnConfig.h
//
//	$Revision: 6 $
//
//	Purpose:	Set flags for build configurations	
//
//	Unpublished Copyright:	CONFIDENTIAL - ©1996 Macromedia Inc.  This material
//	                      	contains certain trade secrets and confidential and
//	                      	proprietary information of Macromedia Inc..  
//	                      	Use,reproduction, disclosure and distribution by 
//	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   	any means are prohibited, except pursuant to a written
//	                      	license from Macromedia Inc..  Use of a copyright notice
//	                      	is precautionary and does not imply publication or 
//	                      	disclosure.
//
//	Change History (most recent first):
//	===================================
//  $Log: /Mars/ServerXtras/ObjectDB/SrvXtnConfig.h $
/   
/   6     3/21/00 11:17a Dsimmons
/   #include file madness
/   
/   5     3/20/00 5:31p Dsimmons
/   Added #include for Windows so IMMEMTAG files get it right
/   
/   4     9/08/99 2:45p Dsimmons
/   
/   3     8/23/99 12:47p Dsimmons
/   
//++------------------------------------------------------------------------------*/

#pragma once
#if	!defined(_h_SrvXtnConfig_)
#define	_h_SrvXtnConfig_

#include	"stdio.h"

// Set flags for build configurations
#if defined( RELEASE )

	// Release builds - all should be off !
	#undef DEBUG
	#undef	__STL_DEBUG

#else
	// Development builds
	#ifndef DEBUG
		#define	DEBUG				1
	#endif

	#define	__STL_DEBUG				1

#endif



//--------------------------------------------------------------------------
// Configurations for Macintosh builds:
//--------------------------------------------------------------------------
#if defined( MACINTOSH )
#undef OLDROUTINENAMES

#if defined(__MC68K__)
#error No 68K builds !
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

#endif		// Win


//--------------------------------------------------------------------------
// Cross-platform include files that are generally useful...
//--------------------------------------------------------------------------
#include "OperatorNew.h"
#include "Assert.h"

#endif		// _h_SrvXtnConfig_

