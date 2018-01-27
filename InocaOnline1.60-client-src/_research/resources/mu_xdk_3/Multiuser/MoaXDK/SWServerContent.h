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
*	File:		SWServerContent.h
*
*	Purpose:	Interfaces definitions for SWServer Xtras.  This defines the
*				interface into content objects, used to create and read messages.*
*
******************************************************************************/


#ifndef __SWServerContent__
#define __SWServerContent__

#undef 	CINTERFACE
#define	CPLUS

#ifndef _H_moastdif
#include "moastdif.h"
#endif

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif


// ---------------------------------------------------------------------------
// Define the interface for the message stream object
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE ISWServerContent

DECLARE_INTERFACE_(ISWServerContent, IMoaUnknown)
{
	STD_IUNKNOWN_METHODS

	STDMETHOD(GetPosition)	(THIS_		MoaLong * pPos	) PURE;

	STDMETHOD(SetPosition)	(THIS_		MoaLong pos	) PURE;

	STDMETHOD(ReserveSpace) (THIS_		MoaLong size ) PURE;

	STDMETHOD(Reset)		(THIS)		PURE;

	STDMETHOD_(PMoaVoid, GetBufferPointer) (THIS) PURE;

	// Routines for reading and writing values from the content buffer
	STDMETHOD(GetValueInfo) (THIS_		MoaLong * pValueType,
										MoaLong * pValueSize,
										MoaLong * pValueStreamSize ) PURE;

	STDMETHOD(ReadValue)	(THIS_		PMoaVoid pValueData ) PURE;

	STDMETHOD(WriteValue)	(THIS_		MoaLong valueType,
										MoaLong valueSize,
										PMoaVoid pValueData ) PURE;

	STDMETHOD(SkipValue)		(THIS) PURE;

	STDMETHOD(SkipListStart)	(THIS) PURE;
};
typedef ISWServerContent * PISWServerContent;

// {882103EB-EC6A-11d2-A798-0060085393E5}
DEFINE_GUID(IID_ISWServerContent,	0x882103eb, 0xec6a, 0x11d2, 0xa7, 0x98, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);


#endif // __SWServerContent__

