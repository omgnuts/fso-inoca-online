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
*	Name: SrvExtension.cpp
*
* 	Purpose: This file contains the entry points for server xtra functions.
*
****************************************************************************/

/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 *****************************************************************************/
#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif


#include "SrvExtension.h"
#include "SrvXtnUtils.h"
#include "SrvXtnDefs.h"
#include "Assert.h"
#include "BString.h"
#include "Logger.h"

#include <stdlib.h>



static long CommandStringToCommandNumber( const BString & commandString );
static long SetAllNotifications( CSrvXtn_IMoaSWServerExtension FAR * This, bool doNotifications );




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
	}

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

	//Take care of our global IMoaCalloc interface ref counting
	if(	gIMoaCalloc )
	{
		gCallocRefCount--;
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

	pObj->mMovie = NULL;
	pObj->mServer = NULL;

	pObj->mLoggingEnabled = true;
	pObj->mLastLogDay = 0;				// Can't call GetServerDay() yet
	pObj->mIdleCounter= 0;

	pObj->mMovieDataList = NULL;

	// Init the BString objects since Moa won't do it for us
	pObj->mLogFilePath.InitFromNull();
	pObj->mServerStartupTime.InitFromNull();
	pObj->mLogStartTime.InitFromNull();

	// All command permissions for the logging function default to 80
	long cmdNumber = 0;
	while ( cmdNumber < kNumPermissions )
	{
		pObj->mPermissions[ cmdNumber ] = 80;
		cmdNumber++;
	}

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

	// Clear the log data list
	if ( pObj->mMovieDataList != NULL )
	{
		pObj->mMovieDataList->erase( pObj->mMovieDataList->begin(), pObj->mMovieDataList->end() );
		delete pObj->mMovieDataList;
		pObj->mMovieDataList = NULL;
	}
}



//=======================================================================
//	CSrvXtn_IMoaSWServerExtension::Initialize
//		Called when xtra is first loaded.
//=======================================================================
STDMETHODIMP CSrvXtn_IMoaSWServerExtension::Initialize( PISWServerUser user, PISWServerMovie movie, PISWServer server )
{
	X_ENTER

	MoaError err = kMoaErr_NoErr;

	// This xtra can be loaded at either the movie or server level
	if( movie != NULL )
	{
		DisplayMessage( this, "\n* Initialize, movie: Logger xtra has been loaded.\n" );
		pObj->mMovie = movie;
		pObj->mMovie->AddRef();
	}

	if ( server != NULL )
	{
		DisplayMessage( this, "\n* Initialize,server: Logger xtra has been loaded.\n" );
		pObj->mServer = server;
		pObj->mServer->AddRef();

		pObj->mLastLogDay = GetServerDay( this );
		GetServerTimeString( this, pObj->mServerStartupTime );
		GetServerTimeString( this, pObj->mLogStartTime );

	}

	// Display a message in the console window so we know the xtra has been loaded.
	DisplayMessage( this, "\n* Logger xtra has been loaded.\n" );

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

	XtraResourceCookie myCookie, saveCookie;
	myCookie = pObj->pCallback->MoaBeginUsingResources( gXtraFileRef, &saveCookie );

	MoaError err = kMoaErr_NoErr;

	//amk edit#if defined( DEBUG )
	// Dump out the command so we can see what the xtra is getting.
	DisplayMessage( this, "Logger xtra config command:  " );
	DisplayMessage( this, cmd );
	DisplayMessage( this, "\n" );
	//amk end edit #endif

	BString configCmd( cmd ), word, params, serverPath;
	bool showErrMsg = true;
	if ( configCmd.Matches( "ConfigDone" ) )
	{
		SetAllNotifications( this, true );
		SyncLogData( this );
		showErrMsg = false;
	}
	else
	{	// Look for something like "System.Logger.GetCurrentLog 30"
		long start, len;
		configCmd.Token( 0, &start, &len, word );		// Get first word

		configCmd.Token( len, &start, &len, params );	// Get second word

		if ( configCmd.Matches( "LogFolder" ) )
		{
			// Replace "@" with the server path
			BString atSign( "@" );
			if ( params.Find1st( atSign ) >= 0 )
			{
				pObj->mServer->GetSetting( "serverPath", (char *) serverPath, serverPath.MaxLength() );
				params.Replace1st( atSign, serverPath );
			}

			pObj->mLogFilePath = params;
		}
		else if ( configCmd.Matches( "ConfigDone" ) )
		{	// If we didn't get a path name for log files, write to the server application folder
			if ( pObj->mLogFilePath.IsEmpty() )
			{
				pObj->mServer->GetSetting( "serverPath", (char *) serverPath, serverPath.MaxLength() );
				pObj->mLogFilePath = serverPath;
			}
		}
		else
		{
			long cmdNumber = CommandStringToCommandNumber( word );
			if ( cmdNumber >= 0 && cmdNumber < kNumPermissions )
			{
				long level = params.Integer();
				if ( level >= 0 )
				{
					pObj->mPermissions[ cmdNumber ] = level;
					showErrMsg = false;
				}
			}
		}
	}

	if ( showErrMsg )
	{
		BString errMsg;
		errMsg = "*** Invalid configuration command for the Logger xtra: \"<1>\"\n";
		//errMsg.LoadFromResources( kMsgRTInvalidConfig );		// "Invalid configuration command for the Logger xtra: \"<1>\"\n"
		errMsg.Replace1st( BString( "<1>" ), cmd );
		DisplayMessage( this, errMsg );
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

	//amk edit #if defined ( DEBUG )
	char	temp[200];
	//end amk edit #endif

	AssertNotNull_( pObj->mServer );

	PISWServerMovie movie = NULL;
	PISWServerUser user = NULL;

	MoaError err = kMoaErr_NoErr;

	switch( eventCode )
	{
		case kSrvIdle:
			HandleServerIdle( this );
			break;

		case kSrvMovieCreated:

			// to do - add notifications needed for this movie

			movie = (PISWServerMovie) data;
			err = LogMovieCreated( this, movie );

		//amk edit 	#if defined ( DEBUG )
			pObj->mServer->DisplayMessage( "Logger ServerEvent>   Movie created: " );
			movie->GetSetting( "movieID", temp, 200 );
			pObj->mServer->DisplayMessage( temp );
			pObj->mServer->DisplayMessage( "\n" );
	   //end amk edit		#endif
			break;

		case kSrvMovieDelete:

			// to do - remove notifications needed for this movie ??

			movie = (PISWServerMovie) data;
			err = LogMovieDeleted( this, movie );

			//amk edit#if defined ( DEBUG )
			pObj->mServer->DisplayMessage( "Logger ServerEvent>   Movie deleted: " );
			movie->GetSetting( "movieID", temp, 200 );
			pObj->mServer->DisplayMessage( temp );
			pObj->mServer->DisplayMessage( "\n" );
			//end amk edit#endif
			break;

		case kSrvUserLogon:
			user = (PISWServerUser) object;
			err = LogUserLogon( this, user );

			//amk edit #if defined ( DEBUG )
			pObj->mServer->DisplayMessage( "Logger ServerEvent>   User logon: " );
			user->GetSetting( "userID", temp, 200 );
			pObj->mServer->DisplayMessage( temp );
			pObj->mServer->DisplayMessage( "\n" );
			//end amk edit #endif
			break;

		case kSrvUserLogoff:
			user = (PISWServerUser) object;
			err = LogUserLogoff( this, user );

			//amk edit #if defined ( DEBUG )
			pObj->mServer->DisplayMessage( "Logger ServerEvent>   User logoff: " );
			user->GetSetting( "userID", temp, 200 );
			pObj->mServer->DisplayMessage( temp );
			pObj->mServer->DisplayMessage( "\n" );
			//end amk edit #endif
			break;

		default:
			break;
	}

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
														PISWServerMovie recipientMovie )
{
	X_ENTER

	MoaError err = kMoaErr_FuncNotFound;

	switch ( cmdNumber )
	{
		case kCmdLoggerGetCurrentLog:
			err = DoGetCurrentLog( this, subject, senderID, recipientID, msgContents, sender, recipientMovie );
			break;

		case kCmdLoggerGetCurrentLogData:
			err = DoGetCurrentLogData( this, subject, senderID, recipientID, msgContents, sender, recipientMovie );
			break;

		case kCmdLoggerClearLogData:
			err = DoClearLogData( this, subject, senderID, recipientID, msgContents, sender, recipientMovie );
			break;

		case kCmdLoggerGetResponseTime:
			err = DoGetResponseTime( this, subject, senderID, recipientID, msgContents, sender, recipientMovie );
			break;

		case kCmdLoggerGetSwitchResponseTime:
			err = DoSwitchResponseTime( this, subject, senderID, recipientID, msgContents, sender, recipientMovie );
			break;

		default:
			break;
	}

	X_STD_RETURN(err);
	X_EXIT
}


//=======================================================================
//	SetAllNotifications
//		Turn on or off all notifications
//=======================================================================
static long SetAllNotifications( CSrvXtn_IMoaSWServerExtension FAR * This, bool doNotifications )
{
	MoaError err = kMoaErr_NoErr;

	if ( This->pObj->mServer != NULL )
	{
		This->pObj->mLoggingEnabled = doNotifications;

		This->pObj->mServer->EnableNotification( This, kSrvIdle, true );		// Always on
		This->pObj->mServer->EnableNotification( This, kSrvMovieCreated, doNotifications );
		This->pObj->mServer->EnableNotification( This, kSrvMovieDelete, doNotifications );

		MoaLong numMovies = 0;
		This->pObj->mServer->GetSetting( "numMovies", (char *) &numMovies, sizeof( numMovies ) );

		// Loop for all movies and set the event notifications
		MoaLong curMovieIndex = 0;
		while ( curMovieIndex < numMovies )
		{
			PISWServerMovie curMovie = (PISWServerMovie) This->pObj->mServer->GetMovieAt( curMovieIndex );
			if ( curMovie != NULL )
			{
				curMovie->EnableNotification( This, kSrvUserLogon, doNotifications );
				curMovie->EnableNotification( This, kSrvUserLogoff, doNotifications );
			}

			curMovieIndex++;
		}
	}

	return err;
}




//=======================================================================
//	CommandStringToCommandNumber
//		Static helper routine.  This is used for config commands,
//		so speed doesn't really matter.
//=======================================================================
static long CommandStringToCommandNumber( const BString & commandString )
{
	long command = -1;

	if ( commandString == BString( kSystemLoggerGetCurrentLog ) )
	{
		command = kCmdLoggerGetCurrentLog;
	}
	else if ( commandString == BString( kSystemLoggerGetCurrentLogData ) )
	{
		command = kCmdLoggerGetCurrentLogData;
	}
	else if ( commandString == BString( kSystemLoggerClearLogData ) )
	{
		command = kCmdLoggerClearLogData;
	}
	else if ( commandString == BString( kSystemLoggerGetResponseTime ) )
	{
		command = kCmdLoggerGetResponseTime;
	}
	else if ( commandString == BString( kSystemLoggerSwitchResponseTime ) )
	{
		command = kCmdLoggerGetSwitchResponseTime;
	}

	return command;
}


