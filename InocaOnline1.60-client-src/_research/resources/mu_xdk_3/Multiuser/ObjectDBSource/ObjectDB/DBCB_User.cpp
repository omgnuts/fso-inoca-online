/***************************************************************************
**
* Copyright © 1994-2001 Macromedia, Inc. All Rights Reserved
*
* THE CODE IS PROVIDED TO YOU ON AN "AS IS" BASIS AND "WITH ALL FAULTS,"
WITHOUT ANY TECHNICAL SUPPORT OR WARRANTY OF ANY KIND FROM MACROMEDIA. YOU
ASSUME ALL RISKS THAT THE CODE IS SUITABLE OR ACCURATE FOR YOUR NEEDS AND
YOUR USE OF THE CODE IS AT YOUR OWN DISCRETION AND RISK. MACROMEDIA
DISCLAIMS ALL EXPRESS AND IMPLIED WARRANTIES FOR CODE INCLUDING, WITHOUT
LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE. ALSO, THERE IS NO WARRANTY OF NON-INFRINGEMENT, TITLE OR QUIET
ENJOYMENT.

YOUR USE OF THIS CODE IS SUBJECT TO THE TERMS, CONDITIONS AND RESTRICTIONS
SET FORTH IN THE CORRESPONDING LICENSE AGREEMENT BETWEEN YOU AND
MACROMEDIA.

****************************************************************************/
// DBCB_User.cpp: implementation of the DBCB_User class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_User.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"

#include <string.h>

#define CONFIG_OPTION	LOCALIZE_db_user
#define TABLENAME		"Users"

#define USERNAME_LEN	40
#define PASSWORD_LEN	40

#define	USERNAME_FLD	"NAME"
#define USERNAME_TAG	"NAME_TAG"

#define	USERID_FLD		"ID"
#define OLD_USERID_TAG	"ID_TAG"

#define	USERPASS_FLD	"PASSWORD"



//++------------------------------------------------------------------------------
//	DBCB_User::DBCB_User
//++------------------------------------------------------------------------------
DBCB_User::DBCB_User(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = USERNAME_TAG;
	mIndexIsString = true;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);
}



//++------------------------------------------------------------------------------
//	DBCB_User::~DBCB_User
//++------------------------------------------------------------------------------
DBCB_User::~DBCB_User()
{
}


//++------------------------------------------------------------------------------
// Create - create the database and indexes
//++------------------------------------------------------------------------------
void DBCB_User::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( USERID_FLD,		'N',	MAX_NUM_LEN, 0 );
	fields.add( USERNAME_FLD,	'C',	USERNAME_LEN );
	fields.add( USERPASS_FLD,	'C',	PASSWORD_LEN );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}


//++------------------------------------------------------------------------------
//	DBCB_User::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_User::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( USERNAME_TAG, USERNAME_FLD, NULL, e4unique );	// attribute names are unique
}


//++------------------------------------------------------------------------------
//	getID - get the user's ID number
//++------------------------------------------------------------------------------
IDNUM DBCB_User::getID( SvrObject *svrObj, const char *username, MoaError *err )
{
	AssertNotNull_(username);

	IDNUM userID = GetNumberFromName( svrObj, 
							username,			// Name we're finding
							USERNAME_LEN,		// Size of field
							USERNAME_TAG,		// Tag name 
							USERID_FLD,			// Field number is in
							err );


	if ( *err == COMMERR_SERV_RECORD_DOESNT_EXIST )
	{
		userID = 0;
		*err = COMMERR_INVALID_USERID;		// change the error code
	}

	return userID;
}


//++------------------------------------------------------------------------------
//	DBCB_User::GetUserIDList
//		Get a list of users
//++------------------------------------------------------------------------------
void DBCB_User::GetUserNameList( long startRecNum, long endRecNum, BStringList & outStringList )
{
	GetStrings( USERNAME_FLD, startRecNum, endRecNum, outStringList );
}




//++------------------------------------------------------------------------------
//	DBCB_User::GetPassword
//		Get the password from the current record
//++------------------------------------------------------------------------------
void DBCB_User::GetPassword( BString & outPassWord )
{
	GetString( USERPASS_FLD, outPassWord );
}



//++------------------------------------------------------------------------------
//	DBCB_User::GetPassword
//		Get the password 
//++------------------------------------------------------------------------------
void DBCB_User::GetPassword( BString & outPassWord, const IDNUM id, MoaError * err )
{
	Field4		fIDNum( mData4, USERID_FLD );

	// We're probably already on the proper record
	if ( id != long( fIDNum ) )
	{
		FindFirstWithoutIndex( NULL, (double) id, USERID_FLD, err );
	}
	if ( *err == kMoaErr_NoErr )
	{
		GetPassword( outPassWord );
	}
}


//++------------------------------------------------------------------------------
//	DBCB_User::SetPassword
//		Set the password for the given ID
//++------------------------------------------------------------------------------
void DBCB_User::SetPassword( const BString & inPassWord, const IDNUM id, MoaError * err )
{
	Field4		fIDNum( mData4, USERID_FLD );

	// We're probably already on the proper record
	if ( id != -1 && id != long( fIDNum ) )
	{
		FindFirstWithoutIndex( NULL, (double) id, USERID_FLD, err );
	}

	if ( *err == kMoaErr_NoErr )
	{
		LockRecord( err );
		if ( *err == kMoaErr_NoErr )
		{
			Field4 passField( mData4, USERPASS_FLD );
			passField.assign( inPassWord );
			UnlockRecord( err );
		}
	}
}



//++------------------------------------------------------------------------------
//	DBCB_User::deleteUser - delete the user record.
//++------------------------------------------------------------------------------
void DBCB_User::deleteUser(SvrObject *svrObj, const char *username, MoaError *err)
{
	AssertNotNull_(username);

	(void) getID(svrObj, username, err);		// just to set the current record
	if (*err != kMoaErr_NoErr)
		return;
	DeleteRecord(svrObj, err);
}



//++------------------------------------------------------------------------------
//	DBCB_User::createUser - create a new record
//++------------------------------------------------------------------------------
void DBCB_User::createUser(SvrObject *svrObj, const IDNUM id, const char *username,
						   const char *password, MoaError *err)
{
	AssertNotNull_(username);
	AssertNotNull_(password);

	if (strlen(username) > USERNAME_LEN)
	{
#ifdef DEBUG
		DebugStr_("DBCB_User::createUser - Username is too long: \"");
		DebugStr_(username);
		DebugStr_("\" [INVALID_USERID]\n");
#endif
		*err = COMMERR_INVALID_USERID;
		return;
	}

	BString user(username);

	BString badChar( "#" );
	if ( user.Find1st( badChar ) >= 0 )
	{
		if (checkDebug(DEBUG_DB))
			svrObj->DisplayMessage("DBCB_User: '#' not allowed in usernames.\n");
		*err = COMMERR_INVALID_USERID;
		return;
	}

	badChar = "@";
	if ( user.Find1st( badChar ) >= 0 )
	{
		if (checkDebug(DEBUG_DB))
			svrObj->DisplayMessage("DBCB_User: '@' not allowed in usernames.\n");
		*err = COMMERR_INVALID_USERID;
		return;
	}

	if ( user.StartsWith("System.") )
	{
		*err = COMMERR_INVALID_USERID;
		return;
	}

	if (strlen(password) > PASSWORD_LEN)
	{
		#ifdef DEBUG
		{
			DebugStr_("DBCB_User: Password is too long:\n");
			DebugStr_("    \"");
			DebugStr_(password);
			DebugStr_("\"\n");
		}
		#endif
		*err = COMMERR_INVALID_PASSWORD;
		return;
	}

	// Store user name in upper case
	user.ConvertToUpperCase();
	user.PadWithSpacesToFitSize( USERNAME_LEN );

	// Get a record we can add to
	GetDeletedOrNewRecord( svrObj, err );

	if ( *err == kMoaErr_NoErr )
	{
		Field4 field1( mData4, USERNAME_FLD );
		field1.assign( user );

		Field4 field2( mData4, USERID_FLD );
		field2.assignLong( id );

		Field4 field3( mData4, USERPASS_FLD );
		field3.assign( password );

		UnlockRecord(err);
	}
}




//++------------------------------------------------------------------------------
//	DBCB_User::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_User::ZapIndexField( void )
{
	ZapTextIndexField( USERNAME_FLD );
}





//++------------------------------------------------------------------------------
//	DBCB_User::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_User::UpdateFileStructure( void )
{
	RemoveTag( OLD_USERID_TAG );
	UppercaseField( USERNAME_FLD );
}

