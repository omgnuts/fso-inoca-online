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
*  File:		SWServerGroup.h
*
*	Purpose:	Shockwave server object public interface.  This is the
*				interface used by xtras to access server user objects.
****************************************************************************/

#ifndef __SWServerGroup__
#define __SWServerGroup__

#undef 	CINTERFACE
#define	CPLUS

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

#include	"SWServerEvents.h"
#include	"SWServerContent.h"
#include	"SWServerObject.h"
#include	"SWServerUser.h"

// ---------------------------------------------------------------------------
// Define the public interface for the SWServerGroup object
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE ISWServerGroup

DECLARE_INTERFACE_(ISWServerGroup, ISWServerObject)
{
	STD_IUNKNOWN_METHODS

	ISWSERVEROBJECT_METHODS

	STDMETHOD(EnableNotification) 				(THIS_ 	PMoaVoid xtra,
														MoaLong eventCode,
														MoaBool on )	PURE;

	STDMETHOD(SendMessageToGroup) 				(THIS_ 	ConstPMoaChar recipient,
														MoaLong errorCode,
														ConstPMoaChar subject,
														ConstPMoaChar sender,
														MoaBool isUDP,
														PISWServerUser senderInterface,
														PISWServerContent msgContents )	PURE;

	STDMETHOD_(PMoaVoid, GetUser)				(THIS_ 	ConstPMoaChar userID )	PURE;

	STDMETHOD_(PMoaVoid, GetUserAt)				(THIS_ 	MoaLong zeroBasedindex )		PURE;

	STDMETHOD(AddUser)							(THIS_ 	PMoaVoid userObject, ConstPMoaChar userName )	PURE;

	STDMETHOD(RemoveUser)						(THIS_ 	PMoaVoid userObject, ConstPMoaChar userName )	PURE;
};
typedef ISWServerGroup * PISWServerGroup;

// {D240A2B3-0E14-11d3-8109-00A0C92398EC}
DEFINE_GUID(IID_ISWServerGroup, 0xd240a2b3, 0xe14, 0x11d3, 0x81, 0x9, 0x0, 0xa0, 0xc9, 0x23, 0x98, 0xec);


#endif //__SWServerGroup__

