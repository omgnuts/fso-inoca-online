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
//
// DBCB_App.cpp: implementation of the DBCB_App class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_App.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"

#define CONFIG_OPTION	LOCALIZE_db_app
#define TABLENAME		"Applications"

#define APPNAME_LEN	100

#define	APPNAME_FLD			"NAME"
#define	APPNAME_TAG			"NAME_TAG"

#define	APPID_FLD			"ID"
#define	OLD_APPID_TAG		"ID_TAG"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

DBCB_App::DBCB_App(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = APPNAME_TAG;
	mIndexIsString = true;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);
}



DBCB_App::~DBCB_App()
{

}

void DBCB_App::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No Code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( APPID_FLD,		'N',	MAX_NUM_LEN, 0 );
	fields.add( APPNAME_FLD,	'C',	APPNAME_LEN );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}



//++------------------------------------------------------------------------------
//	DBCB_App::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_App::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( APPNAME_TAG, APPNAME_FLD, NULL, e4unique );
}



void DBCB_App::deleteApp(SvrObject *svrObj, const char *appname, MoaError *err)
{
	(void) getID(svrObj, appname, err);		// just to set the current record
	if (*err != kMoaErr_NoErr)
		return;
	DeleteRecord(svrObj, err);
}


void DBCB_App::createApp(SvrObject *svrObj, const IDNUM id, const char *appname, MoaError *err)
{
	AssertNotNull_(appname);

	if (strlen(appname) > APPNAME_LEN)
	{
#ifdef DEBUG
		{
			DebugStr_("DBCB_App: Application name is too long:\n");
			DebugStr_("    \"");
			DebugStr_(appname);
			DebugStr_("\"\n");
		}
#endif
		*err = COMMERR_BAD_PARAMETER;
		return;
	}

	BString app(appname);
	
	BString badChar( "#" );
	if ( app.Find1st( badChar ) >= 0 )
	{
		DebugStr_("DBCB_App: '#' not allowed in app names.\n");
		*err = COMMERR_BAD_PARAMETER;
		return;
	}

	badChar = "@";
	if ( app.Find1st( badChar ) >= 0 )
	{
		DebugStr_("DBCB_App: '@' not allowed in app names.\n");
		*err = COMMERR_BAD_PARAMETER;
		return;
	}
	
	if ( app.StartsWith("System.") )
	{
		DebugStr_("DBCB_App: application names must not start with 'System.'\n");
		*err = COMMERR_BAD_PARAMETER;
		return;
	}

	// Get an empty record we can use
	GetDeletedOrNewRecord( svrObj, err );
	if (*err != kMoaErr_NoErr)
		return;

	// Save the application name and it's ID number
	app.ConvertToUpperCase();
	app.PadWithSpacesToFitSize( APPNAME_LEN );

	Field4 field1( mData4, APPNAME_FLD );
	field1.assign( app );

	Field4 field2( mData4, APPID_FLD );
	field2.assignLong(id);

	UnlockRecord(err);
}


IDNUM DBCB_App::getID(SvrObject *svrObj, const char *appname, MoaError *err)
{
	AssertNotNull_(appname);

	IDNUM appID = GetNumberFromName( svrObj, 
							appname,			// Name we're finding
							APPNAME_LEN,		// Size of field
							APPNAME_TAG,		// Tag name 
							APPID_FLD,			// Field number is in
							err );

	if ( *err == COMMERR_SERV_RECORD_DOESNT_EXIST )
		*err = COMMERR_INVALID_MOVIEID;		// change the error code
	
	return appID;
}


//++------------------------------------------------------------------------------
//	DBCB_App::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_App::ZapIndexField( void )
{
	ZapTextIndexField( APPNAME_FLD );
}



//++------------------------------------------------------------------------------
//	DBCB_App::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_App::UpdateFileStructure( void )
{
	RemoveTag( OLD_APPID_TAG );
	UppercaseField( APPNAME_FLD );
}

