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
*	File:		SWServerMovie.h
*
*	Purpose:	Shockwave server movie object public interface.  This is the
*				interface used by xtras to access movie objects.
*****************************************************************************/

#ifndef __BSWServerMovie__
#define __BSWServerMovie__

#undef 	CINTERFACE
#define	CPLUS

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

#include	"SWServerXtra.h"
#include	"SWServerContent.h"
#include	"SWServerEvents.h"
#include	"SWServerObject.h"
#include	"SWServerUser.h"

// ---------------------------------------------------------------------------
// Define the public interface for the SWServer movie object
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE ISWServerMovie

DECLARE_INTERFACE_(ISWServerMovie, ISWServerObject)
{
	STD_IUNKNOWN_METHODS

	ISWSERVEROBJECT_METHODS

	STDMETHOD(DisplayMessage) 					(THIS_ 	ConstPMoaChar message ) PURE;

	STDMETHOD(EnableNotification) 				(THIS_ 	PMoaVoid xtra,
														MoaLong eventCode,
														MoaBool on )	PURE;

	STDMETHOD(SendMessage)		 				(THIS_ 	ConstPMoaChar recipient,
														MoaLong errorCode,
														ConstPMoaChar subject,
														ConstPMoaChar sender,
														MoaBool isUDP,
														PISWServerUser senderInterface,
														PISWServerContent msgContents )	PURE;

	STDMETHOD(SendMessageToList)				(THIS_ 	ConstPMoaChar * recipientList,
														MoaLong errorCode,
														ConstPMoaChar subject,
														ConstPMoaChar sender,
														MoaBool isUDP,
														PISWServerUser senderInterface,
														PISWServerContent msgContents )	PURE;

	STDMETHOD_(PMoaVoid, GetGroup)				(THIS_ 	ConstPMoaChar groupName )	PURE;

	STDMETHOD_(PMoaVoid, GetGroupAt)			(THIS_ 	MoaLong zeroBasedindex )		PURE;

	STDMETHOD_(PMoaVoid, CreateGroup)			(THIS_ 	ConstPMoaChar groupName )	PURE;

	STDMETHOD(DeleteGroup)						(THIS_ 	ConstPMoaChar groupName )	PURE;

	STDMETHOD_(PMoaVoid, GetMoviesServer)		(THIS) PURE;
};

typedef ISWServerMovie * PISWServerMovie;

// {883103E6-EC6A-11d2-A798-0060085393E5}
DEFINE_GUID(IID_ISWServerMovie,	0x883103e6, 0xec6a, 0x11d2, 0xa7, 0x98, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);



#endif //__BSWServerMovie__

