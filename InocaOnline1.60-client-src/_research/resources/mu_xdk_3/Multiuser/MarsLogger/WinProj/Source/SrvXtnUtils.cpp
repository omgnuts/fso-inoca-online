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
*	Name: SrvXtnUtils.cpp
*
* 	Purpose: This file contains utility routines.
*
****************************************************************************/


#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif


#include "SrvXtnUtils.h"
#include "Assert.h"


#include <stdlib.h>

#ifdef TARGET_PRECARBON
#define IdenticalText(aPtr, bPtr, aLen, bLen, itl2Handle) \
		 IUMagIDPString(aPtr, bPtr, aLen, bLen, itl2Handle)
EXTERN_API( short ) IUMagIDPString (const void * aPtr, const void * bPtr, short aLen, short bLen, Handle itl2Handle);
#endif


//++------------------------------------------------------------------------------
//	StringMatches
//		Return true if we have a case independant match
//++------------------------------------------------------------------------------
bool	StringMatches( const char * strOne, const char * strTwo )
{
	#if defined( MACINTOSH )

	short lenOne = strlen( strOne );
	short lenTwo = strlen( strTwo );
	return( ::IdenticalText( strOne, strTwo, lenOne, lenTwo, NULL ) == 0 );

	#elif defined( WINDOWS )

	return( _stricmp( strOne, strTwo ) == 0 );

	#endif
}


//++------------------------------------------------------------------------------
//	StringStartsWith
//		Return true if we have a case independant match for a string starting
//		with another one
//++------------------------------------------------------------------------------
bool	StringStartsWith( const char * strOne, const char * startTarget, long len )
{
	#if defined( MACINTOSH )

	short lenOne = strlen( strOne );
	short lenTwo = (short) len;
	bool startsWith = false;
	if( lenTwo <= lenOne )
	{
		startsWith = (::IdenticalText( strOne, startTarget, lenTwo, lenTwo, NULL ) == 0);
	}
	return( startsWith );

	#elif defined( WINDOWS )

	return( _strnicmp( strOne, startTarget, len ) == 0 );

	#endif
}



