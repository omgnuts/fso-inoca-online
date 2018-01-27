#ifndef _h_SrvExtension
#define _h_SrvExtension


/*==========================================================================\
|                                                                           |
|                     Copyright 1997-98 Macromedia, Inc.                    |
|                                                                           |
|      This material is the confidential trade secret and proprietary       |
|      information of Macromedia, Inc.  It may not be reproduced, used,     |
|      sold or transferred to any third party without the prior written     |
|      consent of Macromedia, Inc.  All rights reserved.                    |
|                                                                           |
\==========================================================================*/


/****************************************************************************
/ Filename
/   SrvExtension.h
/
/ Version:
/   $Revision: 3 $
/
/ Purpose:
/     
/	This file contains the member declarations for the CSrvXtn class,
/	which is the heart of the server extension Xtra.
/
/
//	Change History (most recent first):
//	===================================
//  $Log: /Mars/ServerXtras/ObjectDB/SrvExtension.h $
/   
/   3     8/23/99 12:47p Dsimmons
/   
//
*/  

/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 ****************************************************************************/ 

#include "MessageMap.h"

#ifndef _H_moaxtra		  
	#include "moaxtra.h"
#endif

#include	"SWServerXtra.h"

#if defined( MACINTOSH )
	#include <windows.h>
	#include <string.h>
#endif

#include "OSystem.h"
#include "Options.h"
#include "DBGeneric.h"


 /*****************************************************************************
 *	CLASS SPECIFIC DEFINE(S)
 *	-----------------------
 *	Any #define's specific to this class 
 ****************************************************************************/ 
#ifndef UNUSED
	#define UNUSED(x) x
#endif



/*****************************************************************************
 *	CLSID
 *	-----
 *	The CLSID is a GUID that unquely identifies your MOA class.  To generate a
 *	GUID, use the genUID.app utility (Mac) or the GUIDGEN.EXE utility (Win).
 *	The following line will produce a pre-compiler error if not replaced with
 *	a valid CLSID.
 ****************************************************************************/ 
// guid defined in SrvXtnGUIDs.h
#include "SrvXtnGUIDs.h"


//=======================================================================
// Global routines.
//=======================================================================
PIMoaCalloc	GetCalloc( void );


 

/*****************************************************************************
 *  CLASS INSTANCE VARIABLES
 *  ------------------------
 *  Class instance variable are variables whose scope is exclusive to the
 *  methods implemented by your MOA class.  Variables necessary for the
 *  implementation of your MOA class should be placed here.
 ****************************************************************************/ 
	

EXTERN_BEGIN_DEFINE_CLASS_INSTANCE_VARS(CSrvXtn)

	PISWServerMovie		mMovie;		// Interface to the movie we are a part of
	PISWServer			mServer;	// Interface to the server we are a part of
	OSystem				*mSystem;	// pointer to the object tree of commands recognized
	Options				*mOptions;	// maintains list of configuration options
	DBGeneric			*mDB;		// pointer to the database routines

	// Declare the message maps
	MsgMapBegin( CSrvXtn )
		MsgMapDeclare( kMsgODBAuthenErr,	"/MultiuserServer/Console/Error/Object Database/AuthenticationError" )			// "* An invalid option was provided to the Authentication configuration command for the DatabaseObjects xtra."
		MsgMapDeclare( kMsgODBAdminErr,		"/MultiuserServer/Console/Error/Object Database/AdminCreationError" )			// "* An error was encountered while creating the 'Admin' account for the DatabaseObjects xtra."
		MsgMapDeclare( kMsgODBOpenErr,		"/MultiuserServer/Console/Error/Object Database/DatabaseOpenError" )			// "* Error while opening DatabaseObjects database."
		MsgMapDeclare( kMsgODBAccessErr,	"/MultiuserServer/Console/Error/Object Database/DatabaseAccessError" )			// "* Error accessing DatabaseObjects database."
		MsgMapDeclare( kMsgODBLockErr,		"/MultiuserServer/Console/Error/Object Database/DatabaseLockingError" )			// "* Error while locking DatabaseObjects database."
		MsgMapDeclare( kMsgODBUnlockErr,	"/MultiuserServer/Console/Error/Object Database/DatabaseUnlockingError" )		// "* Error while unlocking DatabaseObjects database."
		MsgMapDeclare( kMsgODBBadWrite,		"/MultiuserServer/Console/Error/Object Database/DatabaseWriteError" )			// "* Error while writing data to DatabaseObjects database."
		MsgMapDeclare( kMsgODBDBError,		"/MultiuserServer/Console/Error/Object Database/DatabaseOperationError" )		// "* Error during DatabaseObjects database operation."
		MsgMapDeclare( kMsgODBInternalErr,	"/MultiuserServer/Console/Error/Object Database/InternalError" )				// "* An internal error occured in the DatabaseObjects xtra."
		MsgMapDeclare( kMsgODBTooLongAtr,	"/MultiuserServer/Console/Error/Object Database/TooLongAttributeName" )			// "* Attribute name is too long for the DatabaseObjects xtra."
		MsgMapDeclare( kMsgODBCreateErr,	"/MultiuserServer/Console/Error/Object Database/ConfigurationCommandError" )	// "* Error in DatabaseObjects configuration command 'create_user'."
		MsgMapDeclare( kMsgODBException,	"/MultiuserServer/Console/Error/Object Database/Exception" )					// "    Exception in DatabaseObjects xtra from file %s, line %d\n"
		MsgMapDeclare( kMsgODBLoaded,		"/MultiuserServer/Console/Error/Object Database/XtraHasBeenLoaded" )			// "\n* DatabaseObjects xtra has been loaded.\n"
	MsgMapEnd

	long		hack;

EXTERN_END_DEFINE_CLASS_INSTANCE_VARS



/*****************************************************************************
 *  CLASS INTERFACE(S)
 *  ------------------
 * 
 *  Syntax:
 *  EXTERN_BEGIN_DEFINE_CLASS_INTERFACE(<class-name>, <interface-name>) 
 *		EXTERN_DEFINE_METHOD(<return-type>, <method-name>,(<argument-list>)) 
 *	EXTERN_END_DEFINE_CLASS_INTERFACE
 ****************************************************************************/ 
EXTERN_BEGIN_DEFINE_CLASS_INTERFACE(CSrvXtn, IMoaSWServerExtension)

	IMOASWSERVEREXTENSION_EXTERNS

EXTERN_END_DEFINE_CLASS_INTERFACE


#endif 


