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
 *	Filename:	SrvExtension.cpp
 *
 *  Purpose:	Shockwave Server Extension Xtra
 *				This file contains the entry points for server xtra functions.
 *
/****************************************************************************/  

/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 *****************************************************************************/
#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif


#include "SrvExtension.h"
#include "SrvXtnDefs.h"
#include "SrvXtnUtils.h"
#include "Assert.h"
#include "mmtypes.h"

#include <stdlib.h>



static void	DisplayMessage( CSrvXtn_IMoaSWServerExtension FAR * This, const char * message );

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

	// Clear all member variables

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

	// Clean up any member variables as needed

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
	}

	// Display a message in the console window so we know the xtra has been loaded.
	//#if defined( DEBUG )
	DisplayMessage( this, "\n* Template server xtra has been loaded.\n" );
	//#endif

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

	//#if defined( DEBUG )
	// Dump out the command so we can see what the xtra is getting.
	DisplayMessage( this, "TEST:  HelloWorld xtra config command:  " );
	DisplayMessage( this, cmd );
	DisplayMessage( this, "\n" );
	//#endif

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

	// Add your code here to handle server events.  To get events, you must
	// first call EnableNotification() for the server object (server, movie, etc)
	// to identify the events you are interested in.

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
														MoaBool isUDP,
														MoaLong cmdNumber,
														PISWServerContent msgContents,
														PISWServerUser sender,
														PISWServerMovie recipientMovie )
{
	X_ENTER

	// Return kMoaErr_FuncNotFound if we don't handle the command
	MoaError err = kMoaErr_FuncNotFound;

	// Modify this section to match your xtra commands.  Use the cmdNumber
	// and recipientID to determine what to do.

	// The following are some simple example commands
	switch( cmdNumber )
	{	// System.Hello.Say just puts a message onto the server console window
		case kCmdSayHello:
			//#if defined ( DEBUG )
			DisplayMessage( this, "DEBUG:  System.Hello.Say command:\n" );
			//#endif
			DisplayMessage( this, "* The server says hello !\n" );
			DisplayMessage( this, "        Message sent by : " );
			DisplayMessage( this, senderID );
			DisplayMessage( this, "        Subject is : " );
			DisplayMessage( this, subject );
			DisplayMessage( this, "\n" );
			err = kMoaErr_NoErr;	// Return no error since we handled the command
			break;

		case kCmdEcho:
			{
				long contentPos = 0;

				// Save original content position
				msgContents->GetPosition( &contentPos );

				// Get info about the value in the contents
				long valueType = 0;
				long stringSize = 0;
				err = msgContents->GetValueInfo( &valueType, &stringSize, NULL );
				if ( err == kMoaErr_NoErr && valueType == kMoaMmValueType_String && stringSize < 300 )
				{	// Get the string
					char	temp[ 300 ];
					err = msgContents->ReadValue( &temp );
					if ( err == kMoaErr_NoErr )
					{
						DisplayMessage( this, temp );
						DisplayMessage( this, "\n" );
					}
				}

				// Restore the content position
				msgContents->SetPosition( contentPos );
				err = kMoaErr_NoErr;	// Return no error since we handled the command
			}
			break;
	}


	X_STD_RETURN(err);
	X_EXIT
}




//=======================================================================
//	DisplayMessage
//		Static helper routine
//=======================================================================
static void	DisplayMessage( CSrvXtn_IMoaSWServerExtension FAR * This, const char * message )
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
