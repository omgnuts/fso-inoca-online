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
// DBCB_ID.cpp: implementation of the DBCB_ID class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_ID.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"

#define		TABLENAME_LEN	20

#define		CONFIG_OPTION	LOCALIZE_db_id
#define		TABLENAME		"IDTable"

#define		IDTABLE_FLD		"TABLENAME"
#define		IDTABLE_TAG		"TABLE_TAG"

#define		IDMAX_FLD		"MAXID"



//++------------------------------------------------------------------------------
//	DBCB_ID::DBCB_ID
//++------------------------------------------------------------------------------
DBCB_ID::DBCB_ID(SvrObject	*svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = IDTABLE_TAG;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);
}


//++------------------------------------------------------------------------------
//	DBCB_ID::~DBCB_ID
//++------------------------------------------------------------------------------
DBCB_ID::~DBCB_ID()
{
}



//++------------------------------------------------------------------------------
//	DBCB_ID::Create
//++------------------------------------------------------------------------------
void DBCB_ID::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( IDTABLE_FLD,	'C',	TABLENAME_LEN );
	fields.add( IDMAX_FLD,		'N',	MAX_NUM_LEN, 0 );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}



//++------------------------------------------------------------------------------
//	DBCB_ID::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_ID::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( IDTABLE_TAG, IDTABLE_FLD, NULL, e4unique );
}


//++------------------------------------------------------------------------------
//	DBCB_ID::getID
//++------------------------------------------------------------------------------
IDNUM DBCB_ID::getID( SvrObject *svrObj, const char *idname, MoaError *err )
{
	AssertNotNull_(idname);

	IDNUM idNum = GetNumberFromName( svrObj,
							idname,					// Name we're finding
							TABLENAME_LEN,			// Size of field
							IDTABLE_TAG,			// Index tag to use
							IDMAX_FLD,				// Field number is in
							err );

	return idNum;
}



//++------------------------------------------------------------------------------
//	DBCB_ID::GetNewID
//++------------------------------------------------------------------------------
long DBCB_ID::GetNewID( SvrObject * svrObj, const char * idName, MoaError *err )
{
	IDNUM curMax = getID( svrObj, idName, err );

	if ( *err == kMoaErr_NoErr )
	{	// We're already positioned correctly, so update the number
		curMax++;

		LockRecord( err );
		if ( *err == kMoaErr_NoErr )
		{
			Field4	valField( mData4, IDMAX_FLD );
			valField.assignLong( curMax );
			// rely on auto-write to write data back to file
			UnlockRecord( err );
		}
	}

	return curMax;
}



//++------------------------------------------------------------------------------
//	DBCB_ID::CreateID
//++------------------------------------------------------------------------------
void DBCB_ID::CreateID( SvrObject *svrObj, const char *idname, IDNUM value, MoaError *err )
{
	AssertNotNull_(idname);

	if ( strlen(idname) > TABLENAME_LEN )
	{
		*err = COMMERR_SERV_INTERNAL_ERROR;
		return;
	}

	// The data entry doesn't exist, so create a new record
	int rc = mData4.appendBlank();
	if ( rc != r4success )
	{
		#ifdef DEBUG
		char msg[100];
		sprintf(msg, "DBCBTable::CreateID() - appendBlank() returned %d\n", rc);
		DebugStr_(msg);
		#endif
		*err = COMMERR_SERV_INTERNAL_ERROR;
		return;
	}

	LockRecord( err );
	if (*err != kMoaErr_NoErr)
		return;

	mData4.blank();			// clears data, and undeletes

	BString	newIDName( idname );
	newIDName.ConvertToUpperCase();

	Field4 field1( mData4, IDTABLE_FLD );
	field1.assign( newIDName );

	Field4 field2( mData4, IDMAX_FLD );
	field2.assignLong( value );

	UnlockRecord( err );
}



//++------------------------------------------------------------------------------
//	DBCB_ID::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_ID::ZapIndexField( void )
{
	ZapTextIndexField( IDTABLE_FLD );
}



//++------------------------------------------------------------------------------
//	DBCB_ID::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_ID::UpdateFileStructure( void )
{
	UppercaseField( IDTABLE_FLD );
}

