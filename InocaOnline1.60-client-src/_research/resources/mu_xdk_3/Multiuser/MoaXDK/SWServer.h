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
*	File:		SWServer.h
*
*	Purpose:	Shockwave server object public interface.  This is the
*				interface used by xtras to access server objects.
*
*******************************************************************************/

#ifndef __BSWServer__
#define __BSWServer__

#undef 	CINTERFACE
#define	CPLUS

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

#include	"SWServerXtra.h"
#include	"SWServerEvents.h"
#include	"SWServerContent.h"
#include	"SWServerObject.h"
#include	"SWServerUser.h"

// ---------------------------------------------------------------------------
// Define the public interface for the SWServer movie object
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE ISWServer

DECLARE_INTERFACE_(ISWServer, ISWServerObject)
{
	STD_IUNKNOWN_METHODS

	ISWSERVEROBJECT_METHODS

	STDMETHOD(DisplayMessage) 					(THIS_ 	ConstPMoaChar message ) PURE;

	STDMETHOD(EnableNotification) 				(THIS_ 	PMoaVoid xtra,
														MoaLong eventCode,
														MoaBool on )	PURE;

	STDMETHOD_(PMoaVoid, GetMovie)				(THIS_ 	ConstPMoaChar movieName )	PURE;

	STDMETHOD_(PMoaVoid, GetMovieAt)			(THIS_ 	MoaLong zeroBasedindex )	PURE;

	STDMETHOD_(PMoaVoid, CreateMovie)			(THIS_ 	ConstPMoaChar movieName )	PURE;

	STDMETHOD(DeleteMovie)						(THIS_ 	ConstPMoaChar movieName )	PURE;

	STDMETHOD_(PMoaVoid, CreateContent)			(THIS_ 	)	PURE;

};
typedef ISWServer * PISWServer;

// {FB86CE11-01A1-11d3-A7A8-0060085393E5}
DEFINE_GUID(IID_ISWServer,	0xfb86ce11, 0x1a1, 0x11d3, 0xa7, 0xa8, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);


#endif //__BSWServer__

