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
*	File:		MOASWServerXtra.h
*
*	Purpose:	Interfaces definitions for SWServer Xtras.  This defines the main
*				interface into xtras, and the main callback into SWServer.
******************************************************************************/


#ifndef __MOASWServerXtra__
#define __MOASWServerXtra__

#undef 	CINTERFACE
#define	CPLUS


#ifndef _H_moastdif
#include "moastdif.h"
#endif

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

#include	"SWServer.h"
#include	"SWServerMovie.h"
#include	"SWServerUser.h"


// ---------------------------------------------------------------------------
// Definitions for the server's MOA classes
// ---------------------------------------------------------------------------
// {883103E0-EC6A-11d2-A798-0060085393E5}
DEFINE_GUID(CLSID_SWServerCallback,	0x883103e0,	0xec6a, 0x11d2, 0xa7, 0x98, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);


// ---------------------------------------------------------------------------
// Interface for calling into Xtras plug-ins.
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE IMoaSWServerExtension

DECLARE_INTERFACE_(IMoaSWServerExtension, IMoaUnknown)
{
	STD_IUNKNOWN_METHODS

	STDMETHOD(Initialize)						(THIS_ 	PISWServerUser, PISWServerMovie movie, PISWServer server ) PURE;

	STDMETHOD(ConfigCommand)					(THIS_ 	ConstPMoaChar cmd ) PURE;

	STDMETHOD(ServerEvent) 						(THIS_ 	MoaLong eventCode,
														PMoaVoid object,
														PMoaVoid container )	PURE;

	STDMETHOD(IncomingMessage)					(THIS_ 	ConstPMoaChar recipientID,
														ConstPMoaChar subject,
														ConstPMoaChar senderID,
														MoaLong errorCode,
														MoaLong timeStamp,
														MoaBool isUDP,
														MoaLong cmdNumber,
														PISWServerContent msgContents,
														PISWServerUser sender,
														PISWServerMovie recipientMovie )	PURE;
};
typedef IMoaSWServerExtension * PIMoaSWServerExtension;

// Preprocessor macro so you don't have to write all the functions out
#define		IMOASWSERVEREXTENSION_EXTERNS														\
																								\
	EXTERN_DEFINE_METHOD(MoaError, Initialize, (PISWServerUser user,							\
												PISWServerMovie movie, PISWServer server))		\
																								\
	EXTERN_DEFINE_METHOD(MoaError, ConfigCommand, (ConstPMoaChar cmd))							\
																								\
	EXTERN_DEFINE_METHOD(MoaError, ServerEvent, (MoaLong eventCode,								\
												 PMoaVoid object,								\
												 PMoaVoid container))							\
																								\
	EXTERN_DEFINE_METHOD(MoaError, IncomingMessage, (ConstPMoaChar recipientID,					\
														ConstPMoaChar subject,					\
														ConstPMoaChar senderID,					\
														MoaLong errorCode,						\
														MoaLong timeStamp,						\
														MoaBool isUDP,							\
														MoaLong cmdNumber,						\
														PISWServerContent msgContents,			\
														PISWServerUser sender,					\
														PISWServerMovie recipientMovie ))



// {883103E8-EC6A-11d2-A798-0060085393E5}
DEFINE_GUID(IID_IMoaSWServerExtension,	0x883103e8, 0xec6a, 0x11d2, 0xa7, 0x98, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);


// ---------------------------------------------------------------------------
// Registry entries the Server Extension xtra must provide.
// ---------------------------------------------------------------------------

// The server extension name, a string
#define	kSrvXtnName		"xSXName"

// The userID for the server extension, a string
#define	kSrvXtnUserIDs	"xSXUserIDs"



// ---------------------------------------------------------------------------
// Event codes sent from the server to the xtra
// ---------------------------------------------------------------------------
#define		kSrvIdle			0
#define		kSrvUserLogon		1
#define		kSrvUserLogoff		2
#define		kSrvGroupCreated	3
#define		kSrvGroupDelete		4
#define		kSrvJoinGroup		5
#define		kSrvLeaveGroup		6
#define		kSrvMovieCreated	7
#define		kSrvMovieDelete		8
#define		kSrvServerShutdown	9


#endif // __MOASWServerXtra__

