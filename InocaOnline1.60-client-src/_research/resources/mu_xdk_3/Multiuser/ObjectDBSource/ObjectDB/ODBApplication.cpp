// ODBApplication.cpp: implementation of the ODBApplication class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "ODBApplication.h"
#include "ODBUser.h"
#include "ODBPlayer.h"
#include "ODBAppData.h"
#include "DebugException.h"

#include "Localize.h"

static MoaError Create(SvrObject *recipient, SvrMessage &msgParams)
{
	// the reply message always mirrors the input message
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent() );

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters : an exception will be thrown if they
	// aren't defined.
	BString		name;
	BString		description;
	params.getString(LOCALIZE_application, &name);
	params.getString(LOCALIZE_description, &description);

	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->Create(msgParams.sender, (char *)name, (char *)description);
}

static MoaError Delete(SvrObject *recipient, SvrMessage &msgParams)
{
	// the reply message always mirrors the input message
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent() );

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 
	BString		name;
	params.getString(LOCALIZE_application, &name);

	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->Delete(msgParams.sender, (char *)name);
}

static MoaError GetAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);
			// the message may return empty if there's an early error

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	MoaError err = kMoaErr_NoErr;


	// get mandatory parameters 

	ParameterList	attribs;
	params.getParamList(LOCALIZE_attribute, &attribs);

	// and optional parameters
	ParameterList	apps;
	params.getParamList(LOCALIZE_application, &apps, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// default to our current application
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		apps.addAttr(data);
	}
	if (err != kMoaErr_NoErr)
		return err;

	// then do the deed
	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->GetAttribute(msgParams.msgSend, msgParams.sender, apps, attribs);
}


static MoaError SetAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);
				// message may remain empty if there's an early error

	MoaError err = kMoaErr_NoErr;


	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 

	ParameterList	attribs(msgParams.msgRecv.GetContent());
	params.getParamList(LOCALIZE_attribute, &attribs);

	// and optional parameters
	BString		app, lastUpdateTime;

	params.getString(LOCALIZE_application, &app, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// the default is the current app's name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		app = data;
	}

	params.getString(LOCALIZE_lastUpdateTime, &lastUpdateTime, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		err = kMoaErr_NoErr;
		lastUpdateTime = "";
	}

	// then do the deed
	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->SetAttribute(msgParams.msgSend, msgParams.sender, (char *)app, attribs, lastUpdateTime);
}

static MoaError GetAttributeNames(SvrObject *recipient, SvrMessage &msgParams)
{
	// mirror the input message, until later, when we build the real reply
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent() );

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	MoaError err = kMoaErr_NoErr;

	// get optional parameters 
	ParameterList	apps;
	params.getParamList(LOCALIZE_application, &apps, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// default to our current application
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		apps.addAttr(data);
	}
	if (err != kMoaErr_NoErr)
		return err;

	// clear out the message for a real return value
	msgParams.msgSend.CreateContent(recipient);

	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->GetAttributeNames(msgParams.msgSend, msgParams.sender, apps);

}

static MoaError GetApplicationData(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBApplicationData.Get";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
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
	ParameterList	apps;
	params.getParamList(LOCALIZE_application, &apps, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// default to our current application
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		apps.addAttr(data);
	}
	if (err != kMoaErr_NoErr)
		return err;

	// then do the deed
	ODBApplication	*dbApp = (ODBApplication *) recipient;
	return dbApp->DeleteAttribute(msgParams.msgSend, msgParams.sender, apps, attribs);
}

static SvrMethod methodList[] =
{
	{ "Create",			&Create },
	{ "Delete",			&Delete },
	{ "SetAttribute",	&SetAttribute },
	{ "GetAttribute",	&GetAttribute },
	{ "GetAttributeNames",	&GetAttributeNames },
	{ "DeleteAttribute",	&DeleteAttribute },
	{ "GetApplicationData", &GetApplicationData },
};

ODBApplication::ODBApplication()
{
	setName("DBApplication");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	mDBAdmin = NULL;
	mAppTable = NULL;
}

ODBApplication::~ODBApplication()
{
	if (mAppTable != NULL)
	{
		delete mAppTable;
		mAppTable = NULL;
	}
	mDBAdmin = NULL;
}

void ODBApplication::initialize()
{
	// called by the static msg methods to make sure that the
	// database is: created, opened, filled with system defined values
	if (mDBAdmin == NULL)
	{
		// locate the ODBAdmin object and store it, because we'll
		// need to look up ID values all the time
		mDBAdmin = (ODBAdmin *) getRoot()->findObject("System.DBAdmin");
		AssertNotNull_(mDBAdmin);
	}

	if (mAppTable == NULL)
	{
		IMMEMTAG( "ODBApplication::initialize" );
		mAppTable = new DBCB_App( this, getDBConnection() );
		AssertNotNull_(mAppTable);
	}

	mCreateLevel = getOptions()->getOption(LOCALIZE_DBAdmin_CreateApplication, ADMIN_USERLEVEL);
	mGetAttrLevel = getOptions()->getOption(LOCALIZE_DBApplication_GetAttribute, 20);
	mSetAttrLevel = getOptions()->getOption(LOCALIZE_DBApplication_SetAttribute, 20);
	mGetAttrNamesLevel = getOptions()->getOption(LOCALIZE_DBApplication_GetAttributeNames, 20);
	mDeleteAttrLevel = getOptions()->getOption(LOCALIZE_DBApplication_DeleteAttribute, 20);
	mDeleteLevel = getOptions()->getOption(LOCALIZE_DBAdmin_DeleteApplication, ADMIN_USERLEVEL);

}


MoaError ODBApplication::Create(PISWServerUser sender, const char *appname, const char *description)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);
	AssertNotNull_(description);

	MoaError err = kMoaErr_NoErr;
#undef checkErr
#define checkErr()		if (err != kMoaErr_NoErr) return err;

	unsigned long	creatorPriv = 0;
	sender->GetSetting("userLevel", (char *)&creatorPriv, sizeof(creatorPriv));
	if (creatorPriv < mCreateLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	AssertNotNull_(mAppTable);
	IDNUM	appID = mAppTable->getID(this, appname, &err);
	if (err == kMoaErr_NoErr)
		err = COMMERR_SERV_DATA_RECORD_NOT_UNIQUE;
					// was: COMMERR_APPLICATION_ALREADY_EXISTS
	if (err == COMMERR_INVALID_MOVIEID)
		err = kMoaErr_NoErr;
	checkErr();

	// enforce an mpath restriction
	if (strlen((char *) description) > 255)
		return COMMERR_BAD_PARAMETER;

	// first, get a new userID for this person, from the GlobalID counter
	AssertNotNull_(mDBAdmin);
	appID = mDBAdmin->getNewID("GlobalID", &err);
	checkErr();
	// and then add this user to the user table
	mAppTable->createApp(this, appID, appname, &err);
	checkErr();

	// if we reach this point, we must have a valid appID.
	// Anything else would've resulted in an exception, which
	// we'll just pass up the call chain.

	// Now let's add the predefined attributes
	// First, we add the time based ones
	char	*TimeAttributes[] =
	{	// predefined attributes for each application
		LOCALIZE_lastUpdateTime
	};
	// but we need to create a lingo-compatible string of
	// bytes representing the time...
	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();

	for (int attr = sizeof(TimeAttributes)/sizeof(char *) - 1; attr >= 0; attr--)
	{
		IDNUM attrID = mDBAdmin->getAttrID(TimeAttributes[attr], &err);
		checkErr();
		mDBAdmin->setAttribute(appID, attrID, (const char *)nowRaw->getRawData(),
						nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
		checkErr();
	}
	nowRaw = NULL;			// just to make sure we forget about it.

	IDNUM attrID = mDBAdmin->getAttrID(LOCALIZE_description, &err);
	checkErr();

	SvrContent		tmpMsg;
	tmpMsg.CreateContent(this);
	tmpMsg.WriteValue(kMoaMmValueType_String, 0, (char *)description);
	mDBAdmin->setAttribute(appID, attrID, tmpMsg.getRawData(), tmpMsg.getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	checkErr();

	return err;
}

MoaError ODBApplication::GetAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps, ParameterList &attribs)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long	requestorPriv = 0;
	sender->GetSetting("userLevel", (char *)&requestorPriv, sizeof(requestorPriv));
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

	msgReturn.WriteValue( kMoaMmValueType_PropList, apps.attrSize(), NULL );

	AssertNotNull_(mAppTable);
	for (indx = 0; indx < apps.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) apps.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM appID = mAppTable->getID(this, apps.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttribute(msgReturn, mDBAdmin, appID, attribs);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}

MoaError ODBApplication::SetAttribute(SvrContent &msgReturn, PISWServerUser sender, const char *app, ParameterList &attribs, BString &lastUpdateTime)
{
	MoaError err = kMoaErr_NoErr;

	unsigned long creatorPriv = 0;
	sender->GetSetting("userLevel", (char *)&creatorPriv, sizeof(creatorPriv));
	if (creatorPriv < mSetAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	unsigned long privs = ATTR_WPRIVS_NONE;
	if (creatorPriv >= ADMIN_USERLEVEL)
		privs |= ATTR_WPRIVS_SYSTEM;

	// make a list, so we can return the results for each
	// object that was specified...  In this case, only
	// a single object is allowed.
	msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );

	AssertNotNull_(mAppTable);
	do
	{	// this marks the looping point, if there were multiple
		// objects specified...

		// reply message is always either:  [ "obj": [ #lastUpdateTime : <...> ] ]
		// or    [ "obj": [ #errorCode: <...> ] ]
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (void *) app);


		IDNUM appID = mAppTable->getID(this, app, &err);
		if (err != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(err);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			break;
		}

		// always create the attribute with no special privs
		MoaError subErr = SvrObject::SetAttribute(msgReturn, mDBAdmin, privs, ATTR_WPRIVS_NONE, appID, attribs, lastUpdateTime);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	} while (0);

	return err;
}

MoaError ODBApplication::GetAttributeNames(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long	requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetAttrNamesLevel)
		return COMMERR_SERV_NOT_PERMITTED;


	// the reply is a property list for each object that
	// was requested...
	msgReturn.WriteValue( kMoaMmValueType_PropList, apps.attrSize(), NULL );

	AssertNotNull_(mAppTable);
	for (int indx = 0; indx < apps.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) apps.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;

		IDNUM appID = mAppTable->getID(this, apps.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttributeNames(msgReturn, mDBAdmin, appID);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}

MoaError ODBApplication::DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps, ParameterList &attribs)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long	deletorPriv = 0;
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

	AssertNotNull_(mAppTable);
	for (indx = 0; indx < apps.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM appID = mAppTable->getID(this, apps.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) apps.getAttrName(indx) );
			tmpMsg->WriteValue( kMoaMmValueType_PropList, 1, NULL );
			tmpMsg->WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			numErrors++;
			continue;
		}

		// our parent method will do the rest of the work...
		// NOTE: We never want to allow ATTR_WPRIVS_SYSTEM to be passed in, because
		// then an Admin user could delete system attributes, which we never want to
		// happen!
		subErr = SvrObject::DeleteAttribute(msgReturn, mDBAdmin, ATTR_WPRIVS_NONE, appID, attribs);
		if (subErr != kMoaErr_NoErr)
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, 0, (char *) apps.getAttrName(indx) );
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


MoaError ODBApplication::Delete(PISWServerUser sender, const char *appname)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;
#undef checkErr
#define checkErr()	if (err != kMoaErr_NoErr) return err;

	unsigned long	deletorPriv = 0;
	sender->GetSetting("userLevel", (char *) &deletorPriv, sizeof(deletorPriv) );
	if (deletorPriv < mDeleteLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	ODBPlayer *dbPlayer = (ODBPlayer *) getRoot()->findObject("System.DBPlayer");
	AssertNotNull_(dbPlayer);
	ODBAppData *dbAppData = (ODBAppData *) getRoot()->findObject("System.DBApplicationData");
	AssertNotNull_(dbAppData);

	AssertNotNull_(mAppTable);
	IDNUM appID = mAppTable->getID(this, appname, &err);
	checkErr();

	
	err = SvrObject::Delete(mDBAdmin, ATTR_WPRIVS_SYSTEM, appID);
	checkErr();

	AssertNotNull_(mAppTable);
	mAppTable->deleteApp(this, appname, &err);
	checkErr();

	dbPlayer->DeletePlayersWithAppID( appID, &err );
	checkErr();
	dbAppData->deleteAppData(appID, &err);
	checkErr();

	return err;
}

IDNUM ODBApplication::getID(const char *appname, MoaError *err)
{
	AssertNotNull_(mAppTable);
	return mAppTable->getID(this, appname, err);
}