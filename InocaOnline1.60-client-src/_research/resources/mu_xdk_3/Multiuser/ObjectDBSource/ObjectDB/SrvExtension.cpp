/*==========================================================================\
|                                                                           |
|                     Copyright 1999 Macromedia, Inc.                       |
|                                                                           |
|      This material is the confidential trade secret and proprietary       |
|      information of Macromedia, Inc.  It may not be reproduced, used,     |
|      sold or transferred to any third party without the prior written     |
|      consent of Macromedia, Inc.  All rights reserved.                    |
|                                                                           |
\==========================================================================*/

/****************************************************************************
/ Filename
/   SrvExtension.cpp
/
/ Version:
/   $Revision: 17 $
/
/ Purpose:
/   Shockwave Server Extension Xtra
/	This file contains the entry points for server xtra functions.
/
//	Change History (most recent first):
//	===================================
//  $Log: /Mars/ServerXtras/ObjectDB/SrvExtension.cpp $
//  
//  17    3/21/00 11:17a Dsimmons
//  Fixed up namespace weirdness
//  
//  16    3/20/00 12:06p Dsimmons
//  Windows fixes
//  
//  15    2/09/00 6:47p Dsimmons
//  Use BString functions to compare strings
//  
//  14    10/27/99 10:54a Dsimmons
//  Lots of asserts, final bug fixes
//  
//  12    10/07/99 11:48a Dsimmons
//  Fixed global string ref counting, make sure return messages always have
//  some content
//  
//  11    10/4/99 3:03 PM Dsimmons
//  Fix where FreeGlobalStrings() is called from
//  
//  10    9/29/99 11:43a Dsimmons
//  Removed static "configOnce" flag
//  
//  9     9/27/99 11:13a Dsimmons
//  Bo's code - extra messages for debug version
//  
//  7     9/15/99 11:24a Dsimmons
//  
//  6     9/13/99 12:31p Dsimmons
//  Localized strings
//  
//  5     9/08/99 5:50p Dsimmons
//  Bo's 8.3 code
//  
//  3     8/23/99 12:47p Dsimmons
//  
*/  


/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 *****************************************************************************/ 
#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif


#include "SrvExtension.h"
#include "SrvXtnUtils.h"
#include "Assert.h"
#include "GlobalStrings.h"

#include <stdlib.h>

#include "OSystem.h"
#include "DBCodeBase.h"
#include "DebugException.h"
#include "Localize.h"

static void	DisplayMessage( CSrvXtn_IMoaSWServerExtension FAR * This, char * message );


//=======================================================================
//	Message map voodoo
//=======================================================================
MessageMapImplement( CSrvXtn );



#if defined( WINDOWS )
//=======================================================================
//	Routine for Windows so we can access resources.
//=======================================================================
HINSTANCE	GetResourceInstance( void )
{
	return gXtraFileRef;
}
#endif



//=======================================================================
//	Special global accessor required for overriding operator new and delete
//=======================================================================
static	PIMoaCalloc		gIMoaCalloc = NULL;
static	long			gCallocRefCount = 0;

PIMoaCalloc	GetCalloc( void )
{
	return gIMoaCalloc;
}




/*****************************************************************************
 *  CLASS INTERFACE(S)
 ****************************************************************************/ 
BEGIN_DEFINE_CLASS_INTERFACE(CSrvXtn, IMoaSWServerExtension)
END_DEFINE_CLASS_INTERFACE



/*****************************************************************************
 *  CREATE AND DESTROY METHODS
 *  --------------------------
 *
 * Class Syntax:
 * STDMETHODIMP MoaCreate_<class-name>(<class-name> FAR * This)
 * STDMETHODIMP MoaDestroy_<class-name>(<class-name> FAR * This)
 *
 * Interface Syntax:
 * <class_name>_<if_name>::<class_name>_<if_name>(MoaError FAR * pErr)
 * <class_name>_<if_name>::~<class_name>_<if_name>()
 ****************************************************************************/ 

//=======================================================================
//	MoaCreate_CSrvXtn - constructor
//=======================================================================
STDMETHODIMP MoaCreate_CSrvXtn(CSrvXtn FAR * This)
{
	UNUSED(This);
	X_ENTER

	MoaError err = kMoaErr_NoErr;

	XtraResourceCookie myCookie, saveCookie;
	myCookie = This->pCallback->MoaBeginUsingResources( gXtraFileRef, &saveCookie );

	// Clear all member variables

	// Get or ref count our global allocator interface
	// (used in our override of new and delete to use IMoaCalloc
	if( gIMoaCalloc != NULL )
	{
		gIMoaCalloc->AddRef();
		gCallocRefCount++;
	}
	else
	{
		err = This->pCallback->QueryInterface( &IID_IMoaCalloc, (PMoaVoid *) &gIMoaCalloc );
		if ( err == kMoaErr_NoErr )
		{
			gCallocRefCount = 1;
		}

		// Must be first time through, so initialize the global strings
		InitGlobalStrings();
	}

	try
	{
		This->mDB = NULL;
		This->mSystem = NULL;
		This->mOptions = NULL;
		// the following will throw exceptions if there are memory
		// errors...

		IMMEMTAG( "ObjectDB - MoaCreate_CSrvXtn new OSystem" );
		This->mSystem = new OSystem();

		IMMEMTAG( "ObjectDB - MoaCreate_CSrvXtn new Options" );
		This->mOptions = new Options(This->mSystem);
		if (This->mOptions == NULL)
			err = kMoaErr_InternalError;
	}
	catch (...)
	{
		err = kMoaErr_InternalError;
	}

	This->pCallback->MoaEndUsingResources( gXtraFileRef, saveCookie );

	X_STD_RETURN(err);	
	X_EXIT
}


//=======================================================================
//	MoaDestroy_CSrvXtn - destructor
//=======================================================================
STDMETHODIMP_(void) MoaDestroy_CSrvXtn(CSrvXtn FAR * This)
{
	UNUSED(This);
	X_ENTER

	if ( This->mOptions != NULL )
	{
		delete This->mOptions;
		This->mOptions = NULL;
	}
	if ( This->mSystem != NULL )
	{
		This->mSystem->setMovieServer( NULL, NULL );
		delete This->mSystem;
		This->mSystem = NULL;
	}
	if ( This->mDB != NULL )
	{	// should come after OSystem, since the DB objects
		// need to shutdown...
		delete This->mDB;
		This->mDB = NULL;
	}

	//Take care of our global IMoaCalloc interface ref counting
	if(	gIMoaCalloc )
	{
		gCallocRefCount--;
		if( gCallocRefCount <= 0 )
		{	// Release the global strings before we get rid of gIMoaCalloc
			FreeGlobalStrings();
		}

		gIMoaCalloc->Release();
		if( gCallocRefCount <= 0 )
		{
			gIMoaCalloc = NULL;	
			
			#if defined( DEBUG )
			void	CheckForXtraMemoryLeaks( void );
			CheckForXtraMemoryLeaks();
			#endif
		}
	}

	X_RETURN_VOID;
	X_EXIT
}


//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::CSrvXtn_IMoaSWServerExtension - interface constructor
//=======================================================================
CSrvXtn_IMoaSWServerExtension::CSrvXtn_IMoaSWServerExtension(MoaError FAR * pErr)
{ 
	MoaError err = kMoaErr_NoErr;

	*pErr = err; 
}


//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::~CSrvXtn_IMoaSWServerExtension - interface destructor
//=======================================================================
CSrvXtn_IMoaSWServerExtension::~CSrvXtn_IMoaSWServerExtension() 
{
	if ( pObj->mMovie != NULL )
	{
		pObj->mMovie->Release();
		pObj->mMovie = NULL;
	}
	if ( pObj->mServer != NULL )
	{
		pObj->mServer->Release();
		pObj->mServer = NULL;
	}
}



//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::Initialize
//		Called when xtra is first loaded.
//=======================================================================
STDMETHODIMP CSrvXtn_IMoaSWServerExtension::Initialize( PISWServerUser user, PISWServerMovie movie, PISWServer server )
{
	X_ENTER
	
	XtraResourceCookie myCookie, saveCookie;
	myCookie = pObj->pCallback->MoaBeginUsingResources( gXtraFileRef, &saveCookie );

	MoaError err = kMoaErr_NoErr;

	// This xtra can be loaded at either the movie or server level
	if( movie != NULL )
	{
		pObj->mMovie = movie;
		pObj->mMovie->AddRef();
	}

	if ( server != NULL )
	{
		pObj->mServer = server;
		pObj->mServer->AddRef();

		// Get and match the current language setting of the server
		long curLanguage = 0;
		MoaError tempErr = server->GetSetting( "language", (char *) &curLanguage, sizeof(long) );
		if ( tempErr == kMoaErr_NoErr )
		{
			BString::SetCurrentLanguage( curLanguage );
		}


		// Get the path to the server
		char serverPath[2048];
		tempErr = server->GetSetting("serverPath", serverPath, sizeof(serverPath) );
		if (tempErr == kMoaErr_NoErr)
		{
			pObj->mOptions->setOption(LOCALIZE_ServerRoot, serverPath);
		}
	}

	LoadGlobalStrings( myCookie );

	try {
		if (pObj->mDB == NULL)
		{
			DebugStr_("DBObjects: Creating codebase object.\n");
			IMMEMTAG( "ObjectDB - CSrvXtn_IMoaSWServerExtension::Initialize new DBCodebase" );
			pObj->mDB = new DBCodeBase(server);
		}
		else
			DebugStr_("DBObjects xtra object was already initialized.\n");

		if (pObj->mSystem != NULL)
		{
			// pass the object tree the movie/server so it can print out messages.
			pObj->mSystem->setMovieServer( movie, server );
			pObj->mSystem->setOptions(pObj->mOptions);
			pObj->mSystem->setRoot(pObj->mSystem);
			pObj->mSystem->setDBConnection(pObj->mDB);
		}
	}
	catch (DebugException de)
	{
#ifdef DEBUG
		DisplayMessage(this, (char *) de.getMessage() );
		DisplayMessage(this, "\n");
		char msg[200];
		sprintf(msg, (char *) gStrODBException, de.getFile(), de.getLine());
		DisplayMessage(this, msg);
#endif
	}
	catch (Exception e)
	{
		DisplayMessage(this, (char *) e.getMessage() );
		DisplayMessage(this, "\n");
#ifdef DEBUG
		char msg[200];
		sprintf(msg, (char *) gStrODBException, e.getFile(), e.getLine());
		DisplayMessage(this, msg);
#endif
	}
	catch (...)
	{
#ifdef DEBUG
		DisplayMessage(this, "ERROR: Caught exception while dispatching.\n");
#endif
	}


	// Display a message in the console window so we know the xtra has been loaded.
	DisplayMessage( this, (char *) gStrODBLoaded );

	pObj->pCallback->MoaEndUsingResources( gXtraFileRef, saveCookie );

	X_STD_RETURN(err);
	X_EXIT
}




//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::ConfigCommand
//		Called for configuration commands.
//=======================================================================
STDMETHODIMP CSrvXtn_IMoaSWServerExtension::ConfigCommand( ConstPMoaChar cmd )
{
	X_ENTER

	MoaError err = kMoaErr_NoErr;

	XtraResourceCookie myCookie, saveCookie;
	myCookie = pObj->pCallback->MoaBeginUsingResources( gXtraFileRef, &saveCookie );

	try
	{
		if ( BString::IndCompare(cmd, LOCALIZE_ConfigDone) == 0 )
		{
			pObj->mSystem->doInitializations();
		}
		else
		{
			pObj->mOptions->parseOption(cmd);
		}
	}
	catch (...)
	{
		// that's weird... we weren't expecting anything like that...
		err = COMMERR_SERV_INTERNAL_ERROR;
	}

	pObj->pCallback->MoaEndUsingResources( gXtraFileRef, saveCookie );
	
	X_STD_RETURN(err);
	X_EXIT
}




//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::ServerEvent
//		Called when something happens on the server
//=======================================================================
STDMETHODIMP CSrvXtn_IMoaSWServerExtension::ServerEvent( MoaLong eventCode, 
														 PMoaVoid data,
														 PMoaVoid object )
{
	X_ENTER
	
	MoaError err = kMoaErr_NoErr;
	
	X_STD_RETURN(err);
	X_EXIT
}



//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::IncomingMessage
//		Called when a message arrives addressed to this xtra.
//=======================================================================
STDMETHODIMP CSrvXtn_IMoaSWServerExtension::IncomingMessage( ConstPMoaChar recipientID,
														ConstPMoaChar subject,
														ConstPMoaChar senderID,
														MoaLong errorCode,
														MoaLong timeStamp,
														MoaBool /* isUDP */,
														MoaLong cmdNumber,
														PISWServerContent msgContents,
														PISWServerUser sender,
														PISWServerMovie movie )
{
	X_ENTER
	
	XtraResourceCookie myCookie, saveCookie;
	myCookie = pObj->pCallback->MoaBeginUsingResources( gXtraFileRef, &saveCookie );

	MoaError err = kMoaErr_FuncNotFound;

	AssertNotNull_(recipientID);
	// let subject be null?
	AssertNotNull_(senderID);
	AssertNotNull_(msgContents);
	AssertNotNull_(sender);
	// Movie might be null at logon time

	// move message parameters into a single object, to make adding
	// and deleting parameters easier.  (also uses less registers.)
	SvrMessage	msgParam;
	msgParam.recipientID = recipientID;
	msgParam.subject = subject;
	msgParam.senderID = senderID;;
	msgParam.sender = sender;
	msgParam.movie = movie;
	msgParam.msgRecv.SetContent(msgContents);

	try
	{
		err = pObj->mSystem->dispatch(recipientID, msgParam);
		// all methods are responsible for sending back their own
		// messages to the client.  If an exception is thrown, however,
		// this routine will send back whatever message has been
		// accumulated.
	}
	catch (DebugException de)
	{
#ifdef DEBUG
		DisplayMessage(this, (char *) de.getMessage() );
		DisplayMessage(this, "\n");
		char msg[200];
		sprintf(msg, (char *) gStrODBException, de.getFile(), de.getLine());
		DisplayMessage(this, msg);
#endif
		err = de.getError();
	}
	catch (Exception e)
	{
		DisplayMessage(this, (char *) e.getMessage() );
		DisplayMessage(this, "\n");
		err = e.getError();

#ifdef DEBUG
		char msg[200];
		sprintf(msg, (char *) gStrODBException, e.getFile(), e.getLine());
		DisplayMessage(this, msg);
#endif
	}
	catch (...)
	{
#ifdef DEBUG
		DisplayMessage(this, "ERROR: Caught exception while dispatching.\n");
#endif
		err = COMMERR_SERV_INTERNAL_ERROR;
	}

	if (err != kMoaErr_FuncNotFound)
	{
		if ((err == COMMERR_CONTENT_HAS_ERROR_INFO) && ((pObj->mSystem->getOptions()->getDebugLevel() & DEBUG_OLDCLIENT) > 0))
			err = kMoaErr_NoErr;

		// All messages must send a reply back to the client
		msgParam.msgSend.ResetPosition();
		PISWServerContent replyMsg = msgParam.msgSend.GetContent();

		// Do a quick test to make certain we're returning something in the contents
		if ( replyMsg != NULL )
		{
			long valueType = 0;
			long testErr = replyMsg->GetValueInfo( &valueType, NULL, NULL );
			if ( testErr != COMMERR_NO_ERROR || valueType == -1 )
			{
				valueType = 0;
				msgParam.msgSend.WriteValue( kMoaMmValueType_Integer, sizeof(valueType), (char *) &valueType );
			}
		}

		bool sendBackMsg = true;
		if ( BString::IndCompare( subject, LOCALIZE_Logon ) == 0 )
		{
			if ( BString::IndCompare( recipientID, LOCALIZE_System ) == 0 )
			{
				sendBackMsg = false;
			}
		}
		
		if ( sendBackMsg )
		{
			sender->SendMessage( senderID, err, subject, recipientID, false, replyMsg );
		}
	}

	pObj->pCallback->MoaEndUsingResources( gXtraFileRef, saveCookie );

	X_STD_RETURN(err);
	X_EXIT
}




//=======================================================================
//	DisplayMessage
//		Static helper routine
//=======================================================================
static void	DisplayMessage( CSrvXtn_IMoaSWServerExtension FAR * This, char * message )
{
	// This xtra can be loaded at either the movie or server level
	if( This->pObj->mMovie != NULL )
	{
		This->pObj->mMovie->DisplayMessage( message );
	}
	else if ( This->pObj->mServer != NULL )
	{
		This->pObj->mServer->DisplayMessage( message );
	}
}


#if defined( DEBUG )
//=======================================================================
//	__stl_error_report
//		Debug function called from STL
//=======================================================================
__STL_BEGIN_NAMESPACE
void __stl_error_report(const char* file, int line, const char* diagnostic );
void __stl_error_report(const char* file, int line, const char* diagnostic )
{
	Assert_( 0 );
	file;
	line;
	diagnostic;
}
__STL_END_NAMESPACE
#endif 	// DEBUG
