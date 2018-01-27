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
// DBCB_Player.cpp: implementation of the DBCB_Player class.
//
//	This database maps between a user ID, an application ID, and
//	a player ID
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DBCB_Player.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"


#define CONFIG_OPTION	LOCALIZE_db_player
#define TABLENAME		"Players"

#define	PLAYERID_FLD		"ID"

#define	PLAYERUSERID_FLD	"USERID"
#define	PLAYERUSERID_TAG	"USERID_TAG"

#define	PLAYERAPPID_FLD		"APPID"

#define	OLD_ID_TAG			"ID_TAG"
#define	OLD_APPID_TAG		"APPID_TAG"


//++------------------------------------------------------------------------------
//	DBCB_Player::DBCB_Player
//++------------------------------------------------------------------------------
DBCB_Player::DBCB_Player(SvrObject *svrObj, DBGeneric *db) : DBCBTable(db)
{
	mIndexTag = PLAYERUSERID_TAG;
	setTablename( svrObj->getOptions()->getOption(CONFIG_OPTION, TABLENAME) );
	Create(svrObj);
	Open(svrObj);
}



//++------------------------------------------------------------------------------
//	DBCB_Player::~DBCB_Player
//++------------------------------------------------------------------------------
DBCB_Player::~DBCB_Player()
{
}



//++------------------------------------------------------------------------------
//	DBCB_Player::Create
//++------------------------------------------------------------------------------
void DBCB_Player::Create(SvrObject *svrObj)
{
	Code4	*code4 = getDBConnection()->getCode4();
	if (code4 == NULL)
		throw DebugException( "No code4 object!", COMMERR_SERV_INTERNAL_ERROR );

	Field4info	fields( *code4 );
	fields.add( PLAYERID_FLD,		'N',	MAX_NUM_LEN, 0 );
	fields.add( PLAYERUSERID_FLD,	'N',	MAX_NUM_LEN, 0 );
	fields.add( PLAYERAPPID_FLD,	'N',	MAX_NUM_LEN, 0 );

	Tag4info	tags( *code4 );
	MakeTagInfo( tags );

	CreateHelper( svrObj, fields, tags );
}




//++------------------------------------------------------------------------------
//	DBCB_Player::MakeTagInfo
//++------------------------------------------------------------------------------
void DBCB_Player::MakeTagInfo( Tag4info & outInfo )
{
	outInfo.add( PLAYERUSERID_TAG, PLAYERUSERID_FLD, NULL, 0 );
}



//++------------------------------------------------------------------------------
//	DBCB_Player::createPlayer
//++------------------------------------------------------------------------------
void DBCB_Player::createPlayer(SvrObject *svrObj, const IDNUM playerID, const IDNUM userid, const IDNUM appid, MoaError *err)
{
	GetDeletedOrNewRecord( svrObj, err );
	if (*err != kMoaErr_NoErr)
		return;

	Field4 field1( mData4, PLAYERID_FLD );
	field1.assignLong( playerID );

	Field4 field2( mData4, PLAYERUSERID_FLD );
	field2.assignLong( userid );

	Field4	field3( mData4, PLAYERAPPID_FLD );
	field3.assignLong( appid );

	UnlockRecord( err );
}



//++------------------------------------------------------------------------------
//	DBCB_Player::getPlayer
//++------------------------------------------------------------------------------
IDNUM DBCB_Player::getPlayer( SvrObject *svrObj, const IDNUM userid, const IDNUM appid, MoaError *err )
{
	IDNUM	playerID = 0;

	FindRecordWithNumericMatches( svrObj, userid, appid, PLAYERAPPID_FLD, err );
	if ( *err == kMoaErr_NoErr )
	{
		Field4 field1( mData4, PLAYERID_FLD );
		playerID = long( field1 );
	}

	return playerID;
}



//++------------------------------------------------------------------------------
//	DBCB_Player::deletePlayer
//++------------------------------------------------------------------------------
void DBCB_Player::deletePlayer( SvrObject *svrObj, const IDNUM playerID, MoaError * err )
{
	FindFirstWithoutIndex( svrObj, playerID, PLAYERID_FLD, err );
	if ( *err == kMoaErr_NoErr )
	{
		DeleteRecord( svrObj, err );
	}
}


//++------------------------------------------------------------------------------
//	DBCB_Player::FindPlayersWithUserID
//++------------------------------------------------------------------------------
void DBCB_Player::FindPlayersWithUserID( SvrObject *svrObj, const IDNUM userID, IDList &matches, MoaError *err)
{
	GetIDList( svrObj, userID, PLAYERUSERID_TAG, PLAYERID_FLD, matches, err );
}



//++------------------------------------------------------------------------------
//	DBCB_Player::findPlayers
//++------------------------------------------------------------------------------
void DBCB_Player::FindPlayersWithAppID( SvrObject *svrObj, const IDNUM appID, IDList &matches, MoaError *err)
{
	GetIDListWithoutIndex( svrObj, appID, PLAYERAPPID_FLD, PLAYERID_FLD, matches, err );
}



//++------------------------------------------------------------------------------
//	DBCB_Player::ZapIndexField
//++------------------------------------------------------------------------------
void DBCB_Player::ZapIndexField( void )
{
	ZapNumericIndexField( PLAYERUSERID_FLD );
}



//++------------------------------------------------------------------------------
//	DBCB_Player::UpdateFileStructure
//++------------------------------------------------------------------------------
void DBCB_Player::UpdateFileStructure( void )
{
	RemoveTag( OLD_ID_TAG );
	RemoveTag( OLD_APPID_TAG );
}

