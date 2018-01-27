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
*
*   Filename:  OperatorNew.h
*
*	Purpose:   Include file for overriding operator new and tracking memory allocations
*****************************************************************************/

#pragma once
#if	!defined(_h_OperatorNew_)
#define	_h_OperatorNew_

#ifndef IMMEMTAG

	#if defined( DEBUG )

	extern	void	SetMemoryTag( char * str );
	#define	IMMEMTAG( s )	SetMemoryTag( s )

	#else

	#define	IMMEMTAG( s )

	#endif

#endif

// Make certain the STL will use operator new and not malloc()
#ifndef	__STL_USE_NEWALLOC
#define	__STL_USE_NEWALLOC
#endif

#endif		// _h_OperatorNew_

