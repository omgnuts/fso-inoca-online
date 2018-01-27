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
// DBCB_AttrList.cpp: implementation of the DBCB_AttrList class.
//
//	This database maps between attribute names and an ID number
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_AttrList.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"
#include "GlobalStrings.h"

#define CONFIG_OPTION	LOCALIZE_db_attrid
#define TABLENAME		"AttrList"

//   Reduce size of attribute name to 100, to match
//   restriction imposed by mpath
#define ATTRNAME_LEN	100

#define	ATTRNAME_FLD	"NAME"
#define	ATTRNAME_TAG	"NAME_TAG"

#define	ATTRID_FLD		"ID"
#define	OLD_ATTRID_TAG	"ID_TAG"


//++------------------------------------------------------------------------------
//	DBCB_AttrList::DBCB_AttrList
//++------------------------------------------------------------------------------
DBCB_AttrList::DBCB_AttrList(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = ATTRNAME_TAG;
	mIndexIsString = true;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);
}


//++------------------------------------------------------------------------------
//	DBCB_AttrList::~DBCB_AttrList
//++------------------------------------------------------------------------------
DBCB_AttrList::~DBCB_AttrList()
{
}


//++------------------------------------------------------------------------------
//	DBCB_AttrList::Create
//++------------------------------------------------------------------------------
void DBCB_AttrList::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( ATTRID_FLD,		'N',	MAX_NUM_LEN, 0 );
	fields.add( ATTRNAME_FLD,	'C',	ATTRNAME_LEN );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}



//++------------------------------------------------------------------------------
//	DBCB_AttrList::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_AttrList::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( ATTRNAME_TAG, ATTRNAME_FLD, NULL, e4unique );
}



//++------------------------------------------------------------------------------
//	DBCB_AttrList::GetAttr
//++------------------------------------------------------------------------------
IDNUM DBCB_AttrList::GetAttr( SvrObject *svrObj, const char *attrname, MoaError *err )
{
	AssertNotNull_(attrname);

	IDNUM attrID = GetNumberFromName( svrObj, 
							attrname,			// Name we're finding
							ATTRNAME_LEN,		// Length of field
							ATTRNAME_TAG,		// Tag name 
							ATTRID_FLD,			// Field number is in
							err );

	return attrID;
}


//++------------------------------------------------------------------------------
//	DBCB_AttrList::GetAttrName
//++------------------------------------------------------------------------------
void DBCB_AttrList::GetAttrName( SvrObjectPtr svrObj, const IDNUM attrID, BString & outName, MoaError *err )
{
	FindFirstWithoutIndex( svrObj, attrID, ATTRID_FLD, err );
	if ( *err == kMoaErr_NoErr )
	{
		Field4	fName( mData4, ATTRNAME_FLD );
		outName = fName.str();
		outName.TrimSpaces();
	}
}



//++------------------------------------------------------------------------------
//	DBCB_AttrList::CreateAttr
//		Create a new attribute, which we know doesn't exist
//++------------------------------------------------------------------------------
void DBCB_AttrList::CreateAttr( SvrObject *svrObj, const IDNUM id, const char *attrname, MoaError *err )
{
	AssertNotNull_(attrname);

	if (strlen(attrname) > ATTRNAME_LEN)
	{
#ifdef DEBUG
		{
			DebugStr_("DBCB_AttrList: Attribute name is too long:\n");
			DebugStr_("  \"");
			DebugStr_(attrname);
			DebugStr_("\"\n");
		}
#endif
		throw Exception((char *) gStrODBTooLongAtr, COMMERR_BAD_PARAMETER);
	}

	// The data entry doesn't exist, so create a new record
	int rc = mData4.appendBlank();
	if ( rc != r4success )
	{
		#ifdef DEBUG
		char msg[100];
		sprintf(msg, "DBCB_AttrList::CreateAttr() - appendBlank() returned %d\n", rc);
		DebugStr_(msg);
		#endif
		*err = COMMERR_SERV_INTERNAL_ERROR;
		return;
	}

	LockRecord( err );
	if (*err != kMoaErr_NoErr)
		return;

	mData4.blank();			// clears data, and undeletes

	// Fill in the name and ID
	BString	newAttrName( attrname );
	newAttrName.ConvertToUpperCase();

	Field4 field1( mData4, ATTRNAME_FLD );
	field1.assign( newAttrName );

	Field4 field2( mData4, ATTRID_FLD );
	field2.assignLong( id );

	UnlockRecord(err);
}



//++------------------------------------------------------------------------------
//	DBCB_AttrList::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_AttrList::ZapIndexField( void )
{
	ZapTextIndexField( ATTRNAME_FLD );
}



//++------------------------------------------------------------------------------
//	DBCB_AttrList::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_AttrList::UpdateFileStructure( void )
{
	RemoveTag( OLD_ATTRID_TAG );
	UppercaseField( ATTRNAME_FLD );
}

