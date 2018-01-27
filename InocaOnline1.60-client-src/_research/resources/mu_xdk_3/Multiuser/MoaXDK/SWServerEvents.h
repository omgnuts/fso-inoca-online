/*************************************************************************
* Copyright � 1994-2001 Macromedia, Inc. All Rights Reserved
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
*	File:		SWServerEvents.h
*
*	Purpose:	Shockwave server event codes
******************************************************************************/

#ifndef __SWServerEvents__
#define __SWServerEvents__

#undef 	CINTERFACE
#define	CPLUS

// Notification codes
enum							// Object level
{								// ============
	kSrvEventIdle = 0,			// Server, movie
	kSrvEventLogonAttempt,		// Server, movie
	kSrvEventUserLogon,			// Movie
	kSrvEventUserLogoff,		// Movie
	kSrvEventMovieCreated,		// Server
	kSrvEventMovieDeleted,		// Server
	kSrvEventGroupCreated,		// Movie
	kSrvEventGroupDeleted,		// Movie
	kSrvEventJoinGroup,			// Group
	kSrvEventLeaveGroup,		// Group
	kSrvEventNumEvents
};


#endif //__SWServerEvents__

