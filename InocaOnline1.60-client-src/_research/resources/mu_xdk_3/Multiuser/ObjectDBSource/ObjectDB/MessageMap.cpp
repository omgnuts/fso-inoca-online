///////////////////////////////////////////////////////////////////////////////
//
// MessageMap.cpp
//
// Copyright 2000 Macromedia, Inc.  All rights reserved.
//      This material is the confidential trade secret and proprietary
//      information of Macromedia, Inc.  It may not be reproduced, used,
//      sold or transferred to any third party without the prior written
//      consent of Macromedia, Inc.  All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

/*	Purpose:
	
	Stolen from Alex's XSupport code to provide message map for multiuser modules.
	This was seperated so it could be used easily with the BString class,
	the server application and without all the XSupport stuff.
*/



///////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
///////////////////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "CPrecompile.h"
#endif

#if ( SERVER )
#include "IMLGlue.h"
#endif

#include "MessageMap.h"
#include "BString.h"


#ifdef MACINTOSH
#define MACORWIN(mac,win) mac
#endif

#ifdef WINDOWS
#define MACORWIN(mac,win) win
#endif


///////////////////////////////////////////////////////////////////////////////////
//
// Definitions
//
///////////////////////////////////////////////////////////////////////////////////

const char* kMessageMapStringError = "** String Not Available! **";

const long	kMessageMapLangBuffSize	 = 64;

#ifdef WINDOWS
const char* kMsgPoolMapName = "MessagePoolMap";
#endif

//#define SEARCH_ONE_DEEP

#ifdef SEARCH_ONE_DEEP
#define GrabIndexedResource		Get1IndResource
#define GrabNamedResource		Get1NamedResource
#else
#define GrabIndexedResource		GetIndResource
#define GrabNamedResource		GetNamedResource
#endif


///////////////////////////////////////////////////////////////////////////////////
//
// Message Pool Implementation
//
///////////////////////////////////////////////////////////////////////////////////
MsgPool::MsgPool() :
		mContext( 0 ),
		mMessageMap( kDefaultMessageMap )
{
}


		
void MsgPool::Initialize( MessageMapContext context, long forceToEnglish )
{
	mContext = context;
	// don't do any of the fancy shmancy stuff unless we find the Map resource
	// look in both the current and common files.
	// also do nothing if they are forcing the pool to use English
	if( forceToEnglish )
		return;

	// we also copy the data so that we can access 
	// it below with the resource file closed
	bool	gotMap = false;
	MessagePoolMap 		 poolMap;
	memset( &poolMap, 0, sizeof( poolMap ) );
	{
#ifdef MACINTOSH
		// Set the resource file
		short currentResFile = ::CurResFile();
		
		// if we have a resource file make sure it is on top
		if( mContext != -1 )
			::UseResFile( mContext );

		// We can only have one of these so grab the first one we find.
		
		// FWIW, on the Mac server, this ends up coming from the IML's resource file
		Handle resHandle = ::GetResource( kMsgPoolMapID, 1000 );
		AssertNotNull_( resHandle );
		
		// only deal with current version of message pool map -- for now
		if( resHandle && (**((MoaLong**)resHandle) == kCurrentMessagePoolMapVersion) )
		{
			::BlockMoveData( *resHandle, &poolMap, sizeof( MessagePoolMap ) );
			::ReleaseResource( resHandle );
			gotMap = true;
		}

		// switch back
		::UseResFile( currentResFile );
#endif	// MACINTOSH

#ifdef WINDOWS
		// find that resource!
		HRSRC	hRSRC = ::FindResource( (HMODULE)mContext, kMsgPoolMapName, MAKEINTRESOURCE( kMsgPoolMapID ) );

		if ( hRSRC ) 
		{
			HGLOBAL aResource = ::LoadResource( (HMODULE)mContext, hRSRC );
			if ( aResource ) 
			{
				LPVOID messagePoolMap = ::LockResource( aResource );

				// only deal with current version of message pool map -- for now
				if( messagePoolMap && *((MoaLong*)messagePoolMap) == kCurrentMessagePoolMapVersion )
					::memmove( &poolMap, messagePoolMap, sizeof( MessagePoolMap ) );

				::FreeResource( aResource );
				gotMap = true;
			}
		}
#endif // WINDOWS
	}
	
	if ( gotMap )
	{	// Get the map index based on the desired language
		mMessageMap = GetLanguageMap( &poolMap );
	}
}



// --------------------------------------------------------------------------------
// MsgPool::~MsgPool
//		Destructor
// --------------------------------------------------------------------------------
MsgPool::~MsgPool( void )
{
}



// --------------------------------------------------------------------------------
// MsgPool::GetString
//		Get a copy of the string from resources.  Returns non-zero on error.
// --------------------------------------------------------------------------------
long MsgPool::GetString( const char * className, long id, BString & outString ) const
{
	// Clear it out
	outString = "";
	
	// Create the class name and shove the index number on the end
	BString	msgName( className );
	BString temp;
	temp.SetToInteger( id );
	msgName += temp;

#ifdef MACINTOSH

	Str255	resName;
	msgName.GetStr255( resName );

	short currentResFile = ::CurResFile();
	
	// if we have a resource file make sure it is on top
	if( mContext != -1 )
		::UseResFile( mContext );
	
	Handle	aHandle = ::GrabNamedResource( mMessageMap, resName );


	// if the message map is set to something other than the default and 
	// we still haven't found the string, look in the default map for the string
	if( !aHandle && mMessageMap != kDefaultMessageMap )
	{
		// if we have a resource file make sure it is on top
		if( mContext != -1 )
			::UseResFile( mContext );
		
		aHandle = ::GrabNamedResource( kDefaultMessageMap, resName );
	}
	
	// switch back
	::UseResFile( currentResFile );
	
	if( aHandle )
	{
		// copy the string
		{		
			HandleLocker locked( aHandle );
			char* string = *aHandle;
			outString = string;
		}
		
		// release
		::ReleaseResource( aHandle );
		return 0;
	}
	else
	{	// copy generic unlocalizable error string
		outString = kMessageMapStringError;
	}
#endif // MACINTOSH

#ifdef WINDOWS
	// the resource file context is already setup
			
	// find that resource!
	HRSRC	hRSRC = ::FindResource( (HMODULE) mContext, (const char*) msgName, MAKEINTRESOURCE( mMessageMap ) );

	// if we still can't find it and the map isn't the default map, 
	// look in the default map for the string
	if( !hRSRC )
	{
		hRSRC = ::FindResource( (HMODULE) mContext, (const char*) msgName, MAKEINTRESOURCE( kDefaultMessageMap ) );
	}
	
	if ( hRSRC ) 
	{
		HGLOBAL aResource = ::LoadResource( (HMODULE)mContext, hRSRC );
		if ( aResource ) 
		{
			char * aString = (char*)::LockResource( aResource );
			outString = aString;
			::FreeResource( aResource );
			return 0;
		}
	}
	else
	{
		// Copy generic unlocalizable error string
		outString = kMessageMapStringError;
	}
#endif // WINDOWS

	return 1;	// Error return
}




//++------------------------------------------------------------------------------
//	MsgPool::GetLanguageMap
//		Return a messagemap index...
//++------------------------------------------------------------------------------
long MsgPool::GetLanguageMap( PMessagePoolMap pPoolMap )
{
	long mapIndex = BString::GetCurrentLanguage();
	long map = kDefaultMessageMap;

	// to lookup the message pool resource type from the message pool map resource
	if( mapIndex >= 0 && mapIndex < kMaxMessageMapLanguages )
	{
		// mapIndex (language number) is 0 based but 
		// the first long in the structure is the version
		
		// call it evil: coerse the structure to an array of longs
		map = ((long*)pPoolMap)[mapIndex + 1];
		
		// check to see if we got the "not available" ID 
		if( map == kMessageMapNotAvailable )
			map = kDefaultMessageMap;
	}
	
	return map;
}
