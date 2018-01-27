/*++------------------------------------------------------------------------------
//	File:		ObjectDBConfig.h
//
//	$Revision: 3 $
//
//	Purpose:	Set flags for build configurations - Macintosh version
//
//	Unpublished Copyright:	CONFIDENTIAL - ©1999 Macromedia Inc.  This material
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
//  $Log: /Mars/ServerXtras/ObjectDB/ObjectDBConfig.h $
/   
/   3     3/20/00 3:32 PM Dsimmons
/   #include "OperatorNew.h"
/   
/   2     9/08/99 2:45p Dsimmons
/   
/   1     8/30/99 11:24a Dsimmons
/   
//
//++------------------------------------------------------------------------------*/

#pragma once
#if	!defined(_h_ObjectDBConfig_)
#define	_h_ObjectDBConfig_

#include	"stdio.h"

#define	SERVER		0
#define	MARSXTRA	0

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

	// Have to set up Assert_ macros for STL debugging
	// #define	__STL_DEBUG				1
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

#endif		// MACINTOSH


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
#include	"Assert.h"
#include	<limits.h>
#include	"OperatorNew.h"

#endif		// _h_ObjectDBConfig_

