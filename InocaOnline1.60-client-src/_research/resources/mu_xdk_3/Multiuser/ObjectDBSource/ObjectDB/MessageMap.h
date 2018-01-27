
#ifndef _H_MessageMap
#define _H_MessageMap

///////////////////////////////////////////////////////////////////////////////
//
// MessageMap.h
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

// on WINDOWS, include windows.h before any moa files
#ifdef _WINDOWS
	#ifndef _WINDOWS_
	#include <windows.h>
	#endif
#endif

#ifndef _H_mmtypes
#include "mmtypes.h"
#endif

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

#ifdef 	MACINTOSH
#ifndef _H_XMacHelp
#include "XMacHelp.h"
#endif
#ifndef __RESOURCES__
#include <Resources.h>
#endif
#ifndef __SCRIPT__
#include <Script.h>
#endif
#endif	// MACINTOSH


// ANSI
//#include <stdio.h>
//#include <string.h>


// Define the message map pre-processor macros


// The className is used by the Perl processor, not C.

#define MsgMapBegin( className )\
	public:\
		static const char *sMessageMapClassName;\
		enum {\
			MessageMapBegin = 0,

#define MsgMapDeclare( id, symbolOrStringTableKey )\
			id,

#define MsgMapDeclare2( id, winSymbol, macSymbol )\
			id,

// Note: The 2nd parameter of MsgMapDeclare, and the 2nd and 3rd parameters
// of MsgMapDeclare2, are not used by the C compiler. They are parsed by the
// project setup scripts to create message map resources.

#define MsgMapEnd\
			MessageMapEnd\
		};

#define MessageMapImplement( className )\
	const char *className::sMessageMapClassName = #className

#define MessageMapClassName( className )\
	( className::sMessageMapClassName )

#define MessageMapMeta( className, id ) MessageMapClassName( className ), className::id


///////////////////////////////////////////////////////////////////////////////////
//
// Message Pool Declares
//
///////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////
// NOTE Regarding multiple language Message Pools within one Xtra/App:
//
// If you intend to add new languages you also need to update the parser so that
// it can assign that language a message map ID.
// Make sure that both Windows and Mac tables match as well as the number of 
// supported languages all match. (kMaxMessageMapLanguages)
//
// --> Search for: 	// Add new language HERE     in this .h and possibly in .cpp
// this string will point you to all the
// places the new language constants belong
//
// YOU MUST UPDATE MakeMsgs.cpp IN ORDER TO GET NEW LANGUAGES MAPPED.
////////////////////////////////////////////////////////////////////////////////////

#ifdef WINDOWS
typedef HINSTANCE	MessageMapContext;
const MoaLong		kDefaultMessageMap = 256;
const MessageMapContext	kDefaultMessageMapArgument = NULL;

const MoaLong 		kMsgPoolMapID = 200;
const MoaLong 		kMessageMapNotAvailable = -1;

#endif	// WINDOWS

#ifdef MACINTOSH
typedef	MoaShort 	MessageMapContext;
const MoaLong		kDefaultMessageMap = 'MSMP';
const MessageMapContext	kDefaultMessageMapArgument = -1;

const MoaLong 		kMsgPoolMapID = 'Mmap';
const MoaLong 		kMessageMapNotAvailable = '****';
#endif	// MACINTOSH

const MoaLong 		kCurrentMessagePoolMapVersion = 0x00000001;
extern const char* 	kMessageMapStringError;


// Structure we load from resources
typedef struct tagMessagePoolMap
{
	MoaLong 	version;		// required in BCD --> set to kCurrentMessagePoolMapVersion
	MoaLong 	english;
	MoaLong 	french;
	MoaLong 	german;
	MoaLong 	italian;
	MoaLong 	dutch;
	MoaLong 	swedish;
	MoaLong 	spanish;
	MoaLong 	danish;
	MoaLong 	portuguese;
	MoaLong 	korean;
		
	MoaLong 	japanese;
	MoaLong 	chinese;
	MoaLong 	russian;
	
	// Add new language HERE	
} MessagePoolMap;
typedef MessagePoolMap* 	PMessagePoolMap;
typedef PMessagePoolMap* 	MsgPoolMapHandle;

#define kMaxMessageMapLanguages 13



class	BString;

// The source pool of messages; maps to platform resource file.
class MsgPool
{
// --------------------------------------------------------------------------------
// Construction and Destruction
// --------------------------------------------------------------------------------
	public:

		MsgPool();
		~MsgPool( void );

		// Get setup - must be called
		virtual void	Initialize( MessageMapContext context = kDefaultMessageMapArgument, long forceToEnglish = false );

		// Get a string from the pool
		virtual long	GetString( const char* className, long id, BString & theString ) const;

		// Simpler way of using the same function
		#define			GetClassString( className, id, theString ) \
						GetString( MessageMapClassName( className ), className::id, theString );


	protected:

		MessageMapContext	GetContext( void ) const { return mContext; }
		void				SetContext( MessageMapContext newContext ) { mContext = newContext; }

		long				GetLanguageMap( PMessagePoolMap pPoolMap );

		MessageMapContext	mContext;

		long				mMessageMap;
};



#endif // _H_MessageMap

// EOF
