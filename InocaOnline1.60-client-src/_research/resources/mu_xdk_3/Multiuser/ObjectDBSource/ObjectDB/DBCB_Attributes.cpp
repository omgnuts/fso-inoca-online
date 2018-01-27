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
// DBCB_Attributes.cpp: implementation of the DBCB_Attributes class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_Attributes.h"
#include "DebugException.h"
#include "MarsErrors.h"
#include "ODBADmin.h"
#include "Localize.h"

#define CONFIG_OPTION	LOCALIZE_db_attr
#define TABLENAME		"Attributes"


#define	OWNERID_FLD		"OWNERID"
#define ATTRID_FLD		"ATTRID"
#define SIZE_FLD        "SIZE"
#define	VALUE_FLD		"VALUE"
#define	RAWID_FLD		"RAWID"
#define	WPRIVS_FLD		"WPRIVS"

// The goofy spelling here is intentional to keep compatible with earlier files
// that should have the original tag name truncated.
#define	OWNERID_TAG		"OWNERID_TA"
#define	OLD_ATTRID_TAG	"ATTRID_TAG"

//++------------------------------------------------------------------------------
//	DBCB_Attributes::DBCB_Attributes
//++------------------------------------------------------------------------------
DBCB_Attributes::DBCB_Attributes(SvrObject *svrObj, DBGeneric *db, DBCB_RawData *rawData) : DBCBTable(db)
{
	mIndexTag = OWNERID_TAG;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);

	mRawData = rawData;
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::~DBCB_Attributes
//++------------------------------------------------------------------------------
DBCB_Attributes::~DBCB_Attributes()
{
	mRawData = NULL;			// ODBAdmin is responsible for deallocation
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::Create
//++------------------------------------------------------------------------------
void DBCB_Attributes::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	Field4info	fields( *code4 );
	fields.add( OWNERID_FLD,	'N',	MAX_NUM_LEN, 0 );
				// OWNERID = the unique ID of the owner.
				//     The owner can be a DBUser, DBApplication,
				//     DBApplicationData, or DBPlayer
	fields.add( ATTRID_FLD,		'N',	MAX_NUM_LEN, 0 );
				// ATTRID = the string table ID for the
				//     attribute name.  Lookup via DBCB_AttrList.
	fields.add( SIZE_FLD,		'N',	MAX_NUM_LEN, 0 );
				// SIZE = the size of the data/value
	fields.add( VALUE_FLD,		'C',	ATTR_VALUE_LEN );
				// VALUE = the actual value of the attribute
	fields.add( RAWID_FLD,		'N',	MAX_NUM_LEN, 0 );
				// RAWID = the unique ID pointing into
				//     the raw data table
	fields.add( WPRIVS_FLD,		'N',	ATTR_WPRIVS_LEN, 0 );
				// WPRIVS = the priviledge level require
				//     by a user to be able to set this attribute

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_Attributes::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( OWNERID_TAG, OWNERID_FLD, NULL, 0 );
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::setAttribute
//		Checks for the existance of the ownerID/attrID pair, and updates
//		the record, otherwise creates a new record.
//++------------------------------------------------------------------------------
void DBCB_Attributes::setAttribute(SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, const char *value, unsigned long size, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err)
{
	Field4		fSize( mData4, SIZE_FLD);
	Field4		fValue( mData4, VALUE_FLD);
	Field4		fRawid( mData4,	RAWID_FLD);
	Field4		fWPrivs( mData4, WPRIVS_FLD);

	if (getDBConnection()->getCode4()->errorCode != r4success)
	{
		getDBConnection()->getCode4()->errorSet();		// reset error
		*err = COMMERR_SERV_INTERNAL_ERROR;
		return;
	}

	FindAttribute( svrObj, ownerID, attrID, err );
	if (*err == COMMERR_SERV_RECORD_DOESNT_EXIST)
	{
		*err = kMoaErr_NoErr;
		// need to create the attribute
		CreateAttribute(svrObj, ownerID, attrID, attrPriv, err);
	}
	if (*err != kMoaErr_NoErr)
		return;

	// check to make sure that there are enough privs, by matching the bits
	// The passed in priv must have *at least* the same bits set, if not more
	unsigned long recordPriv = long(fWPrivs);
	if ((recordPriv & creatorPriv) != recordPriv)
	{
		*err = COMMERR_SERV_NOT_PERMITTED;
		return;
	}
	attrPriv |= recordPriv;			// users can't decrease the security of an attribute


	LockRecord(err);
	if (*err != kMoaErr_NoErr)
		return;

	do
	{
		fWPrivs.assignLong(attrPriv);
		fSize.assignLong(size);

		IDNUM oldRawID = long(fRawid);
		if (oldRawID != 0)
		{
			// we need to delete the old raw data
			mRawData->DeleteData(svrObj, oldRawID, err);
			if (*err != kMoaErr_NoErr)
				break;
		}
		fRawid.assignLong(0);			// assume no raw data
		if (size > ATTR_VALUE_LEN)
		{
			// if the new value doesn't fit within a record,
			// we have to write it out to the raw data table.
			// Might as well reuse the old rawID.
			IDNUM	newRawID = oldRawID;
			if (newRawID == 0)
			{
				// yuck, but the obvious alternatives
				// all seem ickier
				ODBAdmin *dbAdmin = (ODBAdmin *) svrObj;
				newRawID = dbAdmin->getNewID(RAWID_FLD, err);
				if (*err != kMoaErr_NoErr)
					break;				// break out of do-loop
			}
			mRawData->CreateData(svrObj, newRawID, value, size, err);
			if (*err != kMoaErr_NoErr)
				break;					// break out of this block
			fRawid.assignLong(newRawID);
		}
		else
		{
			fValue.assign(value, size);
		}
	} while (0);

	UnlockRecord(err);
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::CreateAttribute
//++------------------------------------------------------------------------------
void DBCB_Attributes::CreateAttribute(SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, unsigned long priv, MoaError *err)
{
	GetDeletedOrNewRecord( svrObj, err );
	if (*err != kMoaErr_NoErr)
		return;

	Field4 fOwnerID( mData4, OWNERID_FLD);
	Field4 fAttrID( mData4, ATTRID_FLD );
	Field4 fSize( mData4, SIZE_FLD);
	Field4 fValue( mData4, VALUE_FLD);
	Field4 fRawID( mData4, RAWID_FLD);
	Field4 fWPrivs( mData4, WPRIVS_FLD);


	fOwnerID.assignLong(ownerID);
	fAttrID.assignLong(attrID);
	fSize.assignLong(0);			// use a dummy value for now
	fValue.assign(" ");				// correct value will be assigned in "setAttribute"
	fWPrivs.assignLong(priv);
	fRawID.assignLong(0);

	UnlockRecord(err);
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::getAttribute
//++------------------------------------------------------------------------------
void DBCB_Attributes::getAttribute(SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size)
{
	MoaError err = kMoaErr_NoErr;
	getAttribute(svrObj, ownerID, attrID, value, size, &err);
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while getting attribute.", err);
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::getAttribute
//++------------------------------------------------------------------------------
void DBCB_Attributes::getAttribute(SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size, MoaError *err)
{
	Field4		fSize( mData4, SIZE_FLD);
	Field4		fValue( mData4, VALUE_FLD);
	Field4		fRawid( mData4,	RAWID_FLD);

	FindAttribute( svrObj, ownerID, attrID, err );
	if (*err != kMoaErr_NoErr)
		return;

	*size = long(fSize);
	long	allocSize = *size;
	if (allocSize <= 0)
		allocSize = 1;		// always allocate at least one byte
	long	rawID = long(fRawid);
	if (rawID != 0)
	{
		DBData		data;
		mRawData->GetData(svrObj, rawID, data, err);
		if (*err != kMoaErr_NoErr)
			return;
		*value = data.mData;
		data.mData = NULL;			// our caller will take over
									// responsibility for deallocation
		return;
	}
	
	IMMEMTAG( "DBCB_Attributes::getAttribute" );
	*value = new char[allocSize];
	if (*size > 0)
	{
#if defined( MACINTOSH )
		::BlockMoveData( fValue.ptr(), (void *) *value, *size );
#elif defined( WINDOWS )
		::memcpy( (void *) *value, fValue.ptr(), *size );
#else
#error "No system defined?"
#endif

	}
}


//++------------------------------------------------------------------------------
//	DBCB_Attributes::GetAttributeList
//		Builds a list of all the attribute names available to an owner object
//++------------------------------------------------------------------------------
void DBCB_Attributes::GetAttributeList(SvrObject *svrObj, const IDNUM ownerID, IDList &attrIDs, MoaError *err)
{
	GetIDList( svrObj, ownerID, OWNERID_TAG, ATTRID_FLD, attrIDs, err );
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::deleteAttribute
//++------------------------------------------------------------------------------
void DBCB_Attributes::deleteAttribute(SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, const unsigned long priv, MoaError *err)
{
	Field4		fRawid( mData4,	RAWID_FLD);
	Field4		fWPrivs( mData4, WPRIVS_FLD);

	FindAttribute( svrObj, ownerID, attrID, err );
	if (*err != kMoaErr_NoErr)
		return;

	// check to make sure that there are enough privs, by matching the bits
	// The passed in priv must have *at least* the same bits set, if not more
	unsigned long recordPriv = long(fWPrivs);
	if ((recordPriv & priv) != recordPriv)
	{
		*err = COMMERR_SERV_NOT_PERMITTED;
		return;
	}

	if (long(fRawid) != 0)
		mRawData->DeleteData(svrObj, long(fRawid), err);

	DeleteRecord(svrObj, err);

	if ( *err == COMMERR_SERV_RECORD_DOESNT_EXIST )
	{	// If the attribute doesn't exist (or is already deleted) that's no problem
		*err = kMoaErr_NoErr;
	}
}




//++------------------------------------------------------------------------------
//	DBCB_Attributes::FindAttribute
//++------------------------------------------------------------------------------
void DBCB_Attributes::FindAttribute( SvrObject *svrObj, IDNUM ownerID, const IDNUM attrID, MoaError *err )
{
	FindRecordWithNumericMatches( svrObj, ownerID, attrID, ATTRID_FLD, err );
}



//++------------------------------------------------------------------------------
//	DBCB_Attributes::getMatches
//++------------------------------------------------------------------------------
void DBCB_Attributes::getMatches(SvrObject *svrObj, const IDNUM attrID, IDList &ownerID, IDList &matches, MoaError *err)
{
	for (int indx = ownerID.size() - 1; indx >= 0; indx--)
	{
		char query[128];
		sprintf(query, "ATTRID = %lu .AND. OWNERID = %lu", attrID, ownerID[indx]);

		// Find the first (and only) match
		FindAttribute( svrObj, ownerID[indx], attrID, err );
		if (*err == COMMERR_SERV_RECORD_DOESNT_EXIST)
		{	// no matches are okay
			*err = kMoaErr_NoErr;
			return;
		}
		if (*err != kMoaErr_NoErr)
			return;
		
		IMMEMTAG( "DBCB_Attributes::getMatches - matches.push_back" );
		matches.push_back( ownerID[indx] );
	}
}


//++------------------------------------------------------------------------------
//	DBCB_Attributes::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_Attributes::ZapIndexField( void )
{
	ZapNumericIndexField( OWNERID_FLD );
}




//++------------------------------------------------------------------------------
//	DBCB_Attributes::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_Attributes::UpdateFileStructure( void )
{
	RemoveTag( OLD_ATTRID_TAG );
}


