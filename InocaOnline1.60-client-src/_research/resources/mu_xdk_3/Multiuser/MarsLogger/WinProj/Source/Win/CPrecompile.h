/*************************************************************************
* Copyright © 1994-2001 Macromedia, Inc. All Rights Reserved
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
 *	Name:       CPrecompile.h
 *	Purpose:	include file for standard system include files,
 *              or project specific include files that are used
 *              frequently, but are changed infrequently
 ****************************************************************************/

#ifndef __CPrecompile__
#define __CPrecompile__

#if defined( MAC )
#error	This is a Windows-only file
#endif

#define SERVER		0
#define	WINDOWS		1
#define WIN32		1


// Don't use min() or max() functions, use STL
#ifndef NOMINMAX
#define NOMINMAX
#endif

// Disable all the warnings from Mac specific pragmas...
#pragma warning( disable : 4068 )

#include "Windows.h"

#include "istream.h"
#include "stdio.h"

#endif		// __CPrecompile__



