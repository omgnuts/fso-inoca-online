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

// DBCB_AppData.cpp: implementation of the DBCB_AppData class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_AppData.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"

#define CONFIG_OPTION	LOCALIZE_db_appdata
#define TABLENAME		"AppData"


#define	DATAID_FLD		"ID"
#define DATAID_TAG		"ID_TAG"

#define	APPID_FLD		"APPID"
#define OLD_APPID_TAG	"APPID_TAG"


//++------------------------------------------------------------------------------
//	DBCB_AppData::DBCB_AppData
//++------------------------------------------------------------------------------
DBCB_AppData::DBCB_AppData(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = DATAID_TAG;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);

}


//++------------------------------------------------------------------------------
//	DBCB_AppData::~DBCB_AppData
//++------------------------------------------------------------------------------
DBCB_AppData::~DBCB_AppData()
{
}




//++------------------------------------------------------------------------------
//	DBCB_AppData::Create
//++------------------------------------------------------------------------------
void DBCB_AppData::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No Code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( DATAID_FLD,	'N',	MAX_NUM_LEN, 0 );
	fields.add( APPID_FLD,	'N',	MAX_NUM_LEN, 0 );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}


//++------------------------------------------------------------------------------
//	DBCB_AppData::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_AppData::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( DATAID_TAG, DATAID_FLD, NULL, e4unique );
}



//++------------------------------------------------------------------------------
//	DBCB_AppData::CreateAppData
//++------------------------------------------------------------------------------
void DBCB_AppData::CreateAppData( SvrObject *svrObj, const IDNUM id, const IDNUM appid, MoaError *err )
{
	GetDeletedOrNewRecord( svrObj, err );
	if ( *err == kMoaErr_NoErr )
	{
		Field4 field1( mData4, DATAID_FLD );
		field1.assignLong(id);

		Field4	field2( mData4, APPID_FLD );
		field2.assignLong(appid);

		UnlockRecord(err);
	}
}



//++------------------------------------------------------------------------------
//	DBCB_AppData::DeleteAppData
//++------------------------------------------------------------------------------
void DBCB_AppData::DeleteAppData( SvrObject *svrObj, const IDNUM appdataID, MoaError *err )
{
	// Seek the data
	Select( DATAID_TAG );
	SeekFirst( svrObj, appdataID, err );
	if ( *err == kMoaErr_NoErr )
	{	// Got it ?  Delete it then
		DeleteRecord( svrObj, err );
	}
	else
	{	// Didn't find the record
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
	}
}



//++------------------------------------------------------------------------------
//	DBCB_AppData::GetMatches
//		Return a list of AppData IDs that match the given AppID
//++------------------------------------------------------------------------------
void DBCB_AppData::GetMatches( SvrObject *svrObj, const IDNUM appid, IDList &matches, MoaError *err)
{
	GetIDListWithoutIndex( svrObj, appid, APPID_FLD, DATAID_FLD, matches, err );
}



//++------------------------------------------------------------------------------
//	DBCB_AppData::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_AppData::ZapIndexField( void )
{
	ZapNumericIndexField( DATAID_FLD );
}




//++------------------------------------------------------------------------------
//	DBCB_AppData::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_AppData::UpdateFileStructure( void )
{
	RemoveTag( OLD_APPID_TAG );
}

