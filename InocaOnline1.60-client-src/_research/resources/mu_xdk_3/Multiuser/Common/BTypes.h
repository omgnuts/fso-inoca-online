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
*   Filename:  BTypes.h
*
*	Purpose:   define common types
*****************************************************************************/

#pragma once
#if	!defined( _BTypes_ )
#define _BTypes_


//++------------------------------------------------------------------------------
// includes

//++------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// types

typedef unsigned char	UInt8;
typedef char			Int8;
typedef unsigned short	UInt16;
typedef short			Int16;
typedef unsigned long	UInt32;
typedef long			Int32;
typedef float			Float32;
//typedef double			Float64;

typedef Int8			CChar;
typedef UInt8			PChar;
typedef CChar*			RawCString;
typedef const CChar*	ConstRawCString;
typedef PChar*			RawPString;
typedef const PChar*	ConstRawPString;

typedef long			BMessage;


//--------------------------------------------------------------------------------
// constants

const Int8				min_Int8 =  (Int8)  0x0080;
const Int8				max_Int8 =  (Int8)  0x007F;
const UInt8				min_UInt8 = (UInt8) 0x0000;
const UInt8				max_UInt8 = (UInt8) 0x00FF;

const Int16				min_Int16 =  (Int16)  0x8000;
const Int16				max_Int16 =  (Int16)  0x7FFF;
const UInt16			min_UInt16 = (UInt16) 0x0000;
const UInt16			max_UInt16 = (UInt16) 0xFFFF;

const Int32				min_Int32 =  (Int32)  0x80000000;
const Int32				max_Int32 =  (Int32)  0x7FFFFFFF;
const UInt32			min_UInt32 = (UInt32) 0x00000000;
const UInt32			max_UInt32 = (UInt32) 0xFFFFFFFF;



// These are defined for PowerPlant, but aren't for MFC.
#if defined( WINDOWS )
#ifndef Boolean
typedef	bool			Boolean;
#endif
#endif	// WINDOWS

//--------------------------------------------------------------------------------
//	constants

#if	!defined(NULL)
	#define NULL	0
#endif

#if	!defined(nil)
	#define nil	NULL
#endif


#endif		// _BTypes_

