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
// DBCB_RawData.cpp: implementation of the DBCB_RawData class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_RawData.h"
#include "Options.h"
#include "DebugException.h"
#include "MarsErrors.h"
#include "Localize.h"

#define CONFIG_OPTION	LOCALIZE_db_rawdata
#define TABLENAME		"RawData"

#define	ID_FLD			"ID"
#define	DATA_FLD		"DATA"

#define	ID_TAG			"ID_TAG"


//++------------------------------------------------------------------------------
//	DBCB_RawData::
//++------------------------------------------------------------------------------
DBCB_RawData::DBCB_RawData(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	// initialize data used for packing the memo file
	mIndexTag = ID_TAG;
	mDataPackPeriod = svrObj->getOptions()->getOption(LOCALIZE_DataPackPeriod, 50);
	mPackCountdown = mDataPackPeriod;

	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);

}



//++------------------------------------------------------------------------------
//	DBCB_RawData::
//++------------------------------------------------------------------------------
DBCB_RawData::~DBCB_RawData()
{
}



//++------------------------------------------------------------------------------
//	DBCB_RawData::
//++------------------------------------------------------------------------------
void DBCB_RawData::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException("No code4 object!", COMMERR_SERV_INTERNAL_ERROR);

	// Data file is one numeric field with the ID and a memo field with the data
	Field4info	fields( *code4 );
	fields.add( ID_FLD,	'N',	MAX_NUM_LEN, 0 );
	fields.add( DATA_FLD,		'M');

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper(svrObj, fields, tags);
}


//++------------------------------------------------------------------------------
//	DBCB_RawData::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_RawData::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( ID_TAG, ID_FLD, NULL, e4unique );	// attribute names are unique
}



//++------------------------------------------------------------------------------
//	DBCB_RawData::GetData
//++------------------------------------------------------------------------------
void DBCB_RawData::GetData(SvrObject *svrObj, const IDNUM id, DBData &outData, MoaError *err)
{
	// Seek the data
	Select( ID_TAG );
	SeekFirst( svrObj, id, err );

	if ( *err == kMoaErr_NoErr )
	{
		Field4memo	fData( mData4, DATA_FLD );

		outData.mLen = fData.len();
		IMMEMTAG( "DBCB_RawData::GetData" );
		outData.mData = new char[outData.mLen];
		
		#if defined( MACINTOSH )
			::BlockMoveData( fData.ptr(), outData.mData, outData.mLen );
		#elif defined( WINDOWS )
			::memcpy( outData.mData, fData.ptr(), outData.mLen );
		#else
		#error "No system defined??"
		#endif
	}
	else
	{	// Didn't find the record
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
	}
}



//++------------------------------------------------------------------------------
//	DBCB_RawData::GetData
//++------------------------------------------------------------------------------
void DBCB_RawData::GetData(SvrObject *svrObj, const IDNUM id, DBData &outData)
{
	MoaError err = kMoaErr_NoErr;
	GetData(svrObj, id, outData, &err);

	if (err != kMoaErr_NoErr)
		throw DebugException("Unable to get raw attribute data.", err);
}



//++------------------------------------------------------------------------------
//	DBCB_RawData::DeleteData
//++------------------------------------------------------------------------------
void DBCB_RawData::DeleteData( SvrObject *svrObj, const IDNUM id, MoaError *err )
{
	// Seek the data
	Select( ID_TAG );
	SeekFirst( svrObj, id, err );

	if ( *err == kMoaErr_NoErr )
	{	// Found the data, so delete it
		DeleteRecord( svrObj, err );

		// Decide if we should pack or not
		if ( mPackCountdown > 0 )
		{
			// To avoid packing, just set DataPackInterval to -1
			mPackCountdown--;
			if (mPackCountdown == 0)
			{
				mPackCountdown = mDataPackPeriod;
				Compress();
			}
		}
	}
}



//++------------------------------------------------------------------------------
//	DBCB_RawData::CreateData
//++------------------------------------------------------------------------------
void DBCB_RawData::CreateData(SvrObject *svrObj, const IDNUM id, const char *rawdata, const unsigned int len, MoaError *err)
{
	GetDeletedOrNewRecord( svrObj, err );
	if ( *err == kMoaErr_NoErr)
	{
		Field4 field1( mData4, ID_FLD);
		field1.assignLong(id);

		Field4memo field2( mData4, DATA_FLD);
		field2.assign(rawdata, len);

		UnlockRecord(err);
	}
}


//++------------------------------------------------------------------------------
//	DBCB_RawData::Open
//++------------------------------------------------------------------------------
void DBCB_RawData::Open(SvrObject *svrObj)
{
	// we always want to pack on open...
	DBCBTable::Open(svrObj);

	Compress();
}




//++------------------------------------------------------------------------------
//	DBCB_RawData::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_RawData::ZapIndexField( void )
{
	ZapNumericIndexField( ID_FLD );
}

