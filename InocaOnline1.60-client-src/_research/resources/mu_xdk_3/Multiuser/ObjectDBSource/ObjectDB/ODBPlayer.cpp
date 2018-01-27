// ODBPlayer.cpp: implementation of the ODBPlayer class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "ODBPlayer.h"
#include "ODBUser.h"
#include "DebugException.h"
#include "Localize.h"


static MoaError GetAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	// create empty return message
	msgParams.msgSend.CreateContent(recipient);

	MoaError err = kMoaErr_NoErr;

	// and parse incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 

	ParameterList	attribs;
	params.getParamList(LOCALIZE_attribute, &attribs);

	// and optional parameters
	BString			appname;
	params.getString(LOCALIZE_application, &appname, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// allow "application" to not be defined
		// the default is the current app's name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		appname = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	ParameterList	users;
	params.getParamList(LOCALIZE_user, &users, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		// the default is the current user's name
		users.addAttr(msgParams.senderID);
		err = kMoaErr_NoErr;
	}
	if (err != kMoaErr_NoErr)
		return err;

	// then do the deed
	ODBPlayer	*dbPlayer = (ODBPlayer *) recipient;
	return dbPlayer->GetAttribute(msgParams.msgSend, msgParams.sender, users, (char *) appname, attribs);
}


static MoaError SetAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	// duplicate input message for initial errors
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent());

	MoaError err = kMoaErr_NoErr;

	// and parse incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 

	ParameterList	attribs(msgParams.msgRecv.GetContent());
	params.getParamList(LOCALIZE_attribute, &attribs);

	// and optional parameters
	BString		user, app, lastUpdateTime;
	
	params.getString(LOCALIZE_user, &user, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		user = msgParams.senderID;
		err = kMoaErr_NoErr;
	}
	if (err != kMoaErr_NoErr)
		return err;

	params.getString(LOCALIZE_application, &app, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// the default is the current app's name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		app = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	params.getString(LOCALIZE_lastUpdateTime, &lastUpdateTime, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		lastUpdateTime = "";
		err = kMoaErr_NoErr;
	}
	if (err != kMoaErr_NoErr)
		return err;


	// create empty return message
	msgParams.msgSend.CreateContent(recipient);

	// then do the deed
	ODBPlayer	*dbPlayer = (ODBPlayer *) recipient;
	return dbPlayer->SetAttribute(msgParams.msgSend, msgParams.sender, (char *) user, (char *)app, attribs, lastUpdateTime);
}

static MoaError GetAttributeNames(SvrObject *recipient, SvrMessage &msgParams)
{
	// create empty return message
	msgParams.msgSend.CreateContent(recipient);

	MoaError err = kMoaErr_NoErr;

	// and parse incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get optional parameters 
	BString		app;
	params.getString(LOCALIZE_application, &app, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// the default is the current app's name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		app = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	ParameterList	users;
	params.getParamList(LOCALIZE_user, &users, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		// the default is the current user's name
		users.addAttr(msgParams.senderID);
		err = kMoaErr_NoErr;
	}
	if (err != kMoaErr_NoErr)
		return err;


	ODBPlayer	*dbPlayer = (ODBPlayer *) recipient;
	return dbPlayer->GetAttributeNames(msgParams.msgSend, msgParams.sender, users, (char *)app);
}

static MoaError DeleteAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	MoaError err = kMoaErr_NoErr;

	// get mandatory parameters 

	ParameterList	attribs;
	params.getParamList(LOCALIZE_attribute, &attribs);

	// and optional parameters
	BString		app;
	params.getString(LOCALIZE_application, &app, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// the default is the current app's name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		app = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	ParameterList	users;
	params.getParamList(LOCALIZE_user, &users, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		// the default is the current user's name
		users.addAttr(msgParams.senderID);
		err = kMoaErr_NoErr;
	}
	if (err != kMoaErr_NoErr)
		return err;

	// then do the deed
	ODBPlayer		*dbPlayer = (ODBPlayer *) recipient;
	return dbPlayer->DeleteAttribute(msgParams.msgSend, msgParams.sender, users, app, attribs);
}

static SvrMethod methodList[] =
{
	{ "SetAttribute",	&SetAttribute },
	{ "GetAttribute",	&GetAttribute },
	{ "GetAttributeNames",	&GetAttributeNames },
	{ "DeleteAttribute",	&DeleteAttribute },
};

ODBPlayer::ODBPlayer()
{
	setName("DBPlayer");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	mDBAdmin = NULL;
	mDBUser = NULL;
	mDBApp = NULL;
	mPlayerTable = NULL;
}

ODBPlayer::~ODBPlayer()
{
	if (mPlayerTable != NULL)
	{
		delete mPlayerTable;
		mPlayerTable = NULL;
	}
	mDBAdmin = NULL;
	mDBUser = NULL;
	mDBApp = NULL;
}

void ODBPlayer::initialize()
{
	// called by the static msg methods to make sure that the
	// database is: created, opened, filled with system defined values
	if (mDBAdmin == NULL)
	{
		// locate the ODBAdmin object and store it, because we'll
		// need to look up ID values all the time
		mDBAdmin = (ODBAdmin *) getRoot()->findObject("System.DBAdmin.");
		AssertNotNull_(mDBAdmin);
	}
	if (mDBUser == NULL)
	{
		mDBUser = (ODBUser *) getRoot()->findObject("System.DBUser.");
		AssertNotNull_(mDBUser);
	}
	if (mDBApp == NULL)
	{
		mDBApp = (ODBApplication *) getRoot()->findObject("System.DBApplication.");
		AssertNotNull_(mDBApp);
	}

	if (mPlayerTable == NULL)
	{
		IMMEMTAG( "ODBPlayer::initialize" );
		mPlayerTable = new DBCB_Player( this, getDBConnection() );
		AssertNotNull_(mPlayerTable);
	}
	mGetAttrLevel = getOptions()->getOption(LOCALIZE_DBPlayer_GetAttribute, 20);
	mSetAttrLevel = getOptions()->getOption(LOCALIZE_DBPlayer_SetAttribute, 20);
	mGetAttrNamesLevel = getOptions()->getOption(LOCALIZE_DBPlayer_GetAttributeNames, 20);
	mDeleteAttrLevel = getOptions()->getOption(LOCALIZE_DBPlayer_DeleteAttribute, 20);
}


void ODBPlayer::Create(const char *user, const char *appname, MoaError *err)
{
	AssertNotNull_(user);
	AssertNotNull_(appname);
	AssertNotNull_(err);

	AssertNotNull_(mDBApp);
	IDNUM	appID = mDBApp->getID(appname, err);
	if (*err != kMoaErr_NoErr)
		return;
	AssertNotNull_(mDBUser);
	IDNUM	userID = mDBUser->getID(user, err);
	if (*err != kMoaErr_NoErr)
		return;

	AssertNotNull_(mPlayerTable);
	IDNUM	playerID = mPlayerTable->getPlayer(this, userID, appID, err);
	if (*err == kMoaErr_NoErr)
	{
		DebugStr_("ODBPlayer::Create - player already exists.\n");
		*err = COMMERR_SERV_DATA_RECORD_NOT_UNIQUE;
		return;
	}
	if (*err == COMMERR_SERV_RECORD_DOESNT_EXIST)
		*err = kMoaErr_NoErr;		// we expect this...
	if (*err != kMoaErr_NoErr)
	{
		DebugStr_("ODBPlayer::Create - unusual error while looking for pre-existing player.\n");
		return;
	}

	// first, get a new playerID for this person, from the GlobalID counter
	AssertNotNull_(mDBAdmin);
	playerID = mDBAdmin->getNewID("GlobalID", err);
	if (*err != kMoaErr_NoErr)
		return;
	// and then add this user to the user table
	mPlayerTable->createPlayer(this, playerID, userID, appID, err);
	if (*err != kMoaErr_NoErr)
	{
		DebugStr_("ODBPlayer::Create - error in record creation.\n");
		return;
	}


	// Now let's add the predefined attributes
	// First, we add the time based ones
	char	*TimeAttributes[] =
	{
		LOCALIZE_creationTime,
		LOCALIZE_lastUpdateTime
	};
	// but we need to create a lingo-compatible string of
	// bytes representing the time...
	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();

	for (int attr = sizeof(TimeAttributes)/sizeof(char *) - 1; attr >= 0; attr--)
	{
		IDNUM attrID = mDBAdmin->getAttrID(TimeAttributes[attr], err);
		if (*err != kMoaErr_NoErr)
			return;
		mDBAdmin->setAttribute(playerID, attrID, (const char *)nowRaw->getRawData(),
						nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, err);
		if (*err != kMoaErr_NoErr)
			return;
	}
	nowRaw = NULL;			// just to make sure we forget about it.

}

MoaError ODBPlayer::GetAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *appname, ParameterList &attribs)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// add #lastUpdateTime if it wasn't already there...
	int indx;
	int foundLastUpdateTime = 0;
	for (indx = attribs.attrSize() - 1; indx >= 0; indx--)
	{
		if ( BString::IndCompare( attribs.getAttrName(indx), LOCALIZE_lastUpdateTime) == 0 )
		{
			foundLastUpdateTime = 1;
			indx = 0;
		}
	}
	if (!foundLastUpdateTime)
		attribs.addAttr(LOCALIZE_lastUpdateTime);

	// the reply is a property list for each object that
	// was requested...

	msgReturn.WriteValue( kMoaMmValueType_PropList, users.attrSize(), NULL );

	AssertNotNull_(mDBUser);
	AssertNotNull_(mDBApp);
	AssertNotNull_(mPlayerTable);
	for (indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mDBUser->getID(users.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// the specification is not super defined for what happens when
		// the application isn't in the database.  It seems like it should
		// be a global error.  To try and fit what is defined, we move the
		// lookup into the #user loop.
		IDNUM	appID = mDBApp->getID(appname, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// using the userID and appID, we can get at the playerID
		IDNUM playerID = mPlayerTable->getPlayer(this, userID, appID, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}



		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttribute(msgReturn, mDBAdmin, playerID, attribs);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}

MoaError ODBPlayer::SetAttribute(SvrContent &msgReturn, PISWServerUser sender, const char *user, const char *appname, ParameterList &attribs, BString &lastUpdateTime)
{
	AssertNotNull_(sender);
	AssertNotNull_(user);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;

	unsigned long creatorPriv = 0;
	sender->GetSetting("userLevel", (char *) &creatorPriv, sizeof(creatorPriv) );
	if (creatorPriv < mSetAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	unsigned long privs = ATTR_WPRIVS_NONE;
	if (creatorPriv >= ADMIN_USERLEVEL)
		privs |= ATTR_WPRIVS_SYSTEM;

	// make a list, so we can return the results for each
	// object that was specified...  In this case, only
	// a single object is allowed.
	msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );

	AssertNotNull_(mDBApp);
	AssertNotNull_(mPlayerTable);
	do
	{	// this marks the looping point, if there were multiple
		// objects specified...

		// reply message is always either:  [ "obj": [ #lastUpdateTime : <...> ] ]
		// or    [ "obj": [ #errorCode: <...> ] ]
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (void *) user);

		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mDBUser->getID(user, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			DebugStr_("ODBPlayer::SetAttribute - unable to determine user ID.\n");
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			break;
		}

		IDNUM appID = mDBApp->getID(appname, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			DebugStr_("ODBPlayer::SetAttribute - unable to determine application ID.\n");
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			break;
		}

		// using the userID and appID, we can get at the playerID
		IDNUM playerID = mPlayerTable->getPlayer(this, userID, appID, &subErr);
		if (subErr == COMMERR_SERV_RECORD_DOESNT_EXIST)
		{	// if the record doesn't exist, we have to create it
			subErr = kMoaErr_NoErr;
			Create(user, appname, &subErr);
			if (subErr != kMoaErr_NoErr)
			{
				DebugStr_("Unable to create player object.\n");

				msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
				msgReturn.WriteErrorCode(subErr);
				err = COMMERR_CONTENT_HAS_ERROR_INFO;
				continue;
			}
			playerID = mPlayerTable->getPlayer(this, userID, appID, &subErr);
		}
		if (subErr != kMoaErr_NoErr)
		{
			DebugStr_("Unable to determine player ID number.");

			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}


		subErr = SvrObject::SetAttribute(msgReturn, mDBAdmin, privs, ATTR_WPRIVS_NONE, playerID, attribs, lastUpdateTime);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	} while (0);

	return err;
}

MoaError ODBPlayer::GetAttributeNames(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *app)
{
	AssertNotNull_(sender);
	AssertNotNull_(app);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetAttrNamesLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// the reply is a property list for each object that
	// was requested...

	msgReturn.WriteValue( kMoaMmValueType_PropList, users.attrSize(), NULL );

	AssertNotNull_(mDBApp);
	AssertNotNull_(mPlayerTable);
	for (int indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mDBUser->getID(users.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}
		IDNUM appID = mDBApp->getID(app, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}
		IDNUM playerID = mPlayerTable->getPlayer(this, userID, appID, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}


		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttributeNames(msgReturn, mDBAdmin, playerID);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}


MoaError ODBPlayer::DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *app, ParameterList &attribs)
{
	AssertNotNull_(sender);
	AssertNotNull_(app);

	MoaError err = kMoaErr_NoErr;

	AssertNotNull_(mDBUser);
	unsigned long deletorPriv = 0;
	sender->GetSetting("userLevel", (char *) &deletorPriv, sizeof(deletorPriv) );
	if (deletorPriv < mDeleteAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// Also check to make sure that all attributes were defined...
	// process the list of attribute names
	int listSize = attribs.attrSize();
	int indx;
	for (indx = 0; indx < listSize; indx++)
	{
		// lookup the attrID of an attrName
		const char *attrName = attribs.getAttrName(indx);
		IDNUM attrID = mDBAdmin->getAttrID(attrName, &err);
		if (err != kMoaErr_NoErr)
		{	// an error looking up an attrID is just way bad
			return err;
		}
	}

	// the reply is a property list for each object that
	// was requested...

	SvrContent *tmpMsg = AllocContent();
	int numErrors = 0;

	AssertNotNull_(mDBApp);
	AssertNotNull_(mPlayerTable);
	for (indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mDBUser->getID(users.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
			tmpMsg->WriteValue( kMoaMmValueType_PropList, 1, NULL );
			tmpMsg->WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			numErrors++;
			continue;
		}
		IDNUM appID = mDBApp->getID(app, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
			tmpMsg->WriteValue( kMoaMmValueType_PropList, 1, NULL );
			tmpMsg->WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			numErrors++;
			continue;
		}
		IDNUM playerID = mPlayerTable->getPlayer(this, userID, appID, &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
			tmpMsg->WriteValue( kMoaMmValueType_PropList, 1, NULL );
			tmpMsg->WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			numErrors++;
			continue;
		}


		// our parent method will do the rest of the work...
		// NOTE: Never allow ATTR_WPRIVS_SYSTEM through, because then Admin
		// users could delete system attributes!  System attributes are
		// required by this xtra in various places.
		subErr = SvrObject::DeleteAttribute(msgReturn, mDBAdmin, ATTR_WPRIVS_NONE, playerID, attribs);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
			tmpMsg->WriteValue( kMoaMmValueType_PropList, 1, NULL );
			tmpMsg->WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			numErrors++;
		}
	}

	msgReturn.WriteValue( kMoaMmValueType_PropList, numErrors, NULL );
	msgReturn.WriteValue(-1, tmpMsg->getRawSize(), tmpMsg->getRawData());
	FreeContent(tmpMsg);

	return err;
}


//++------------------------------------------------------------------------------
//	ODBPlayer::DeletePlayersWithUserID - delete a player based on userID
//++------------------------------------------------------------------------------
void ODBPlayer::DeletePlayersWithUserID( const IDNUM userID, MoaError *err)
{
	AssertNotNull_(err);

	IDList	matches;
	AssertNotNull_(mPlayerTable);
	mPlayerTable->FindPlayersWithUserID( this, userID, matches, err );
	if (*err != kMoaErr_NoErr)
		return;

	*err = DeleteAllMatches( matches );
}

	
//++------------------------------------------------------------------------------
//	ODBPlayer::DeletePlayersWithAppID
//++------------------------------------------------------------------------------
void ODBPlayer::DeletePlayersWithAppID( const IDNUM appID, MoaError *err )
{
	AssertNotNull_(err);

	IDList	matches;
	AssertNotNull_( mPlayerTable );
	mPlayerTable->FindPlayersWithAppID(this, appID, matches, err);
	if (*err != kMoaErr_NoErr)
		return;

	*err = DeleteAllMatches( matches );
}



//++------------------------------------------------------------------------------
//	ODBPlayer::DeleteAllMatches - utility routine
//++------------------------------------------------------------------------------
long ODBPlayer::DeleteAllMatches( IDList & matches )
{
	long err = kMoaErr_NoErr;

	for (int indx = matches.size() - 1; indx >= 0; indx--)
	{
		err = SvrObject::Delete( mDBAdmin, ATTR_WPRIVS_SYSTEM, matches[indx] );
		if ( err != kMoaErr_NoErr )
			break;

		mPlayerTable->deletePlayer( this, matches[indx], &err );
		if ( err != kMoaErr_NoErr )
			break;
	}

	return err;
}

