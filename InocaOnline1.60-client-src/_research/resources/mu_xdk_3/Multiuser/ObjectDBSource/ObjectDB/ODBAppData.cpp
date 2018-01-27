// ODBAppData.cpp: implementation of the ODBAppData class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "ODBAppData.h"
#include "DebugException.h"
#include "Localize.h"


static MoaError Create(SvrObject *recipient, SvrMessage &msgParams)
{
	MoaError err = kMoaErr_NoErr;

	// First, start the return message, in case there's some heinous error
	// NOTE: we create the return message here as empty, and fill it in later.
	// If an exception gets thrown before we finish the reply message, then
	// an empty message might get sent back.
	msgParams.msgSend.CreateContent(recipient);

	// and parse the incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get the #application argument
	BString		appname;
	params.getString(LOCALIZE_application, &appname, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		// default is the current application name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		appname = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	// now that we have #application, create the reply message
	msgParams.msgSend.WriteValue(kMoaMmValueType_PropList, 1, NULL);
	msgParams.msgSend.WriteValue(kMoaMmValueType_Symbol, 0, LOCALIZE_application );
	msgParams.msgSend.WriteValue(kMoaMmValueType_String, 0, (char *) appname);

	// and get mandatory argument #attribute
	ParameterList	attribs(params);
	params.getParamList(LOCALIZE_attribute, &attribs);

	// then do the deed
	ODBAppData	*dbAppData = (ODBAppData *) recipient;
	return dbAppData->Create(msgParams.sender, (char *) appname, attribs);
}



static MoaError Get(SvrObject *recipient, SvrMessage &msgParams)
{
	MoaError err = kMoaErr_NoErr;

	// Start the return message, which might be empty if an error happens
	// too soon.
	msgParams.msgSend.CreateContent(recipient);

	// and parse the incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get the #application argument
	BString		appname;
	params.getString(LOCALIZE_application, &appname, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		// default is the current application name
		char data[MAX_STR_LEN+1];
		err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		appname = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	ODBAppData	*dbAppData = (ODBAppData *) recipient;
	return dbAppData->Get(msgParams.msgSend, msgParams.sender, (char *)appname, params);
}


static MoaError Delete(SvrObject *recipient, SvrMessage &msgParams)
{
	MoaError err = kMoaErr_NoErr;

	// the reply message always mirrors the input message
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent() );


	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	BString	appname;
	params.getString(LOCALIZE_application, &appname, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{	// the default is the current app's name
		char data[MAX_STR_LEN+1];
		MoaError err = msgParams.movie->GetSetting("movieID", data, sizeof(data));
		if (err != kMoaErr_NoErr)
			return err;
		appname = data;
	}
	if (err != kMoaErr_NoErr)
		return err;

	ODBAppData	*dbAppData = (ODBAppData *) recipient;
	return dbAppData->Delete(msgParams.sender, (char *)appname, params);
}

static SvrMethod methodList[] =
{
	{ "Create",			&Create },
	{ "Get",			&Get },
	{ "Delete",			&Delete },
};

ODBAppData::ODBAppData()
{
	setName("DBApplicationData");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	mDBAdmin = NULL;
	mDBApp = NULL;
	mAppDataTable = NULL;
}

ODBAppData::~ODBAppData()
{
	if (mAppDataTable != NULL)
	{
		delete mAppDataTable;
		mAppDataTable = NULL;
	}
	mDBAdmin = NULL;
	mDBApp = NULL;
}

void ODBAppData::initialize()
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
	if (mDBApp == NULL)
	{
		mDBApp = (ODBApplication *) getRoot()->findObject("System.DBApplication");
		AssertNotNull_(mDBApp);
	}

	if (mAppDataTable == NULL)
	{
		IMMEMTAG( "ODBAppData::initialize" );
		mAppDataTable = new DBCB_AppData( this, getDBConnection() );
		AssertNotNull_(mAppDataTable);
	}

	mCreateLevel = getOptions()->getOption(LOCALIZE_DBAdmin_CreateApplicationData, ADMIN_USERLEVEL);
	mGetLevel = getOptions()->getOption(LOCALIZE_DBApplication_GetApplicationData, 20);
	mDeleteLevel = getOptions()->getOption(LOCALIZE_DBAdmin_DeleteApplicationData, ADMIN_USERLEVEL);
}


MoaError ODBAppData::Create(PISWServerUser sender, const char *appname, ParameterList &attribs)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;
#undef checkError
#define checkError() if (err != kMoaErr_NoErr) return err;

	unsigned long creatorPriv = 0;
	sender->GetSetting("userLevel", (char *)&creatorPriv, sizeof(creatorPriv));
	if (creatorPriv < mCreateLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	unsigned long privs = ATTR_WPRIVS_NONE;
	if (creatorPriv >= ADMIN_USERLEVEL)
		privs |= ATTR_WPRIVS_SYSTEM;


	AssertNotNull_(mDBApp);
	IDNUM	appID = mDBApp->getID((char *)appname, &err);
	checkError();

	// verify that all of the attributes have been declared
	AssertNotNull_(mDBAdmin);
	int		listSize = attribs.attrSize();
	int		indx;
	for (indx = listSize - 1; indx >= 0; indx--)
	{
		const char *attrName = attribs.getAttrName(indx);
		IDNUM attrID= mDBAdmin->getAttrID(attrName, &err);
		checkError();
	}

	// get a new AppDataID for this data, from the GlobalID sequence
	IDNUM appdataID = mDBAdmin->getNewID("GlobalID", &err);
	checkError();

	AssertNotNull_(mAppDataTable);
	mAppDataTable->CreateAppData(this, appdataID, appID, &err);
	checkError();

	// and finally set each of the attributes in turn...
	for (indx = listSize - 1; indx >= 0; indx--)
	{
		// lookup the name
		const char *attrName = attribs.getAttrName(indx);
		AssertNotNull_(attrName);
		// get the data
		char	*data;
		long	dataSize;
		attribs.getData(attrName, &data, &dataSize);
		AssertNotNull_(data);
		// and write it to the database...
		IDNUM attrID = mDBAdmin->getAttrID(attrName, &err);
		checkError();	// no errors expected since we already checked them above
		mDBAdmin->setAttribute(appdataID, attrID, data, dataSize, privs, ATTR_WPRIVS_NONE, &err);
		checkError();
	}
	return err;
}



void ODBAppData::getMatches(const char *appname, ParameterList &args, IDList &matches, MoaError *err)
{
	AssertNotNull_(appname);
	AssertNotNull_(err);

#undef checkError
#define checkError() if (*err != kMoaErr_NoErr) return;

#undef checkErr
#define checkErr(msg)									\
	if (*err != kMoaErr_NoErr)							\
	{													\
		DebugStr_("DBApplicationData.getMatches - appname '");		\
		DebugStr_(appname);								\
		DebugStr_("' : ");								\
		DebugStr_(msg);									\
		DebugStr_("\n");								\
		return;										\
	}


	AssertNotNull_(mDBApp);
	IDNUM appID = mDBApp->getID(appname, err);
	checkErr("Error looking up appID for application.");

	BString		attrName;			// get the attribute name
	args.getString(LOCALIZE_attribute, &attrName, err);
	checkErr("Error getting #attribute parameter.");

	AssertNotNull_(mDBAdmin);
    // convert the attr name to an attrID
	IDNUM attrID = mDBAdmin->getAttrID((char *) attrName, err);
	checkErr("Error converting #attribute to attrID.");

	// Test to see if #text was specified
	int			canMatchText = 1;
	BString		matchText;
	args.getString(LOCALIZE_text, &matchText, err);
	if (*err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		canMatchText = 0;
		*err = kMoaErr_NoErr;
	}
	checkErr("Error getting #text parameter.");

	// Test to see if #number was specified
	int			canMatchExactNum = 1;
	double		exactNum = 0;
	exactNum = args.getNumber(LOCALIZE_number, err);
	if (*err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		canMatchExactNum = 0;
		*err = kMoaErr_NoErr;
	}
	checkErr("Error getting #number parameter.");

	// check to see if a range was specified...
	int			canMatchRangeNum = 1;
	double		lowNum, highNum;
	lowNum = args.getNumber(LOCALIZE_lowNum, err);
	if (*err == kMoaErr_NoErr)
		highNum = args.getNumber(LOCALIZE_highNum, err);
	if (*err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		canMatchRangeNum = 0;
		*err = kMoaErr_NoErr;
	}
	checkErr("Error getting #lowNum or #highNum.");


	if (!canMatchText && !canMatchExactNum && !canMatchRangeNum)
	{
		*err = COMMERR_WRONG_NUMBER_OF_PARAMS;
		return;
	}

	IDList	secondaryMatches;
	{
		// use a local scope so that primary Matches goes away
		// after we're done with it.

		IDList		primaryMatches;
		AssertNotNull_(mAppDataTable);
		mAppDataTable->GetMatches(this, appID, primaryMatches, err);
					// gets the list of all AppData objects (for the given
					// application)
		checkErr("Error performing primary matches.");

		mDBAdmin->getAttrMatches(attrID, primaryMatches, secondaryMatches, err);
					// now go through and get only AppData objects which have the attribute
		checkErr("Error performing secondary matches.");
	}

	// now go through the AppData matches and build a real list
	// of IDs of AppData objects which match the specified criteria
	for (int indx = secondaryMatches.size() - 1; indx >= 0; indx--)
	{
		char *value = NULL;
		unsigned long size = 0;
		mDBAdmin->getAttribute(secondaryMatches[indx], attrID, (const char **) &value, &size, err);
		checkErr("Error while getting attribute values.");
		AssertNotNull_(value);
		SvrContent tmpMsg;
		tmpMsg.CreateContent(this);
		tmpMsg.WriteValue(-1, size, value);
		delete [] value;

		// now that we have it, let's determine the type and
		// test against it
		MoaLong	dataType;
		tmpMsg.GetValueInfo(&dataType, NULL, NULL);
		switch (dataType)
		{
		case kMoaMmValueType_String:
			if (canMatchText)
			{
				BString		candidate;
				tmpMsg.readString(candidate);
				if (matchText.Matches(candidate))
				{
					IMMEMTAG( "ODBAppData::getMatches - matches.push_back 1" );
					matches.push_back(secondaryMatches[indx]);
				}
			}
			break;
		case kMoaMmValueType_Integer:
		case kMoaMmValueType_Float:
			double	candidate = tmpMsg.readNumber();
			if ((canMatchExactNum) && (exactNum == candidate))
			{
					IMMEMTAG( "ODBAppData::getMatches - matches.push_back 2" );
					matches.push_back(secondaryMatches[indx]);
					break;
			}
			if (canMatchRangeNum)
			{
				if ((lowNum <= candidate) && (candidate <= highNum))
				{
					IMMEMTAG( "ODBAppData::getMatches - matches.push_back 3" );
					matches.push_back(secondaryMatches[indx]);
					break;
				}
			}
			break;
		}
	}
}

MoaError ODBAppData::Get(SvrContent &msgReturn, PISWServerUser sender, const char *appname, ParameterList &args)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;
#undef checkError
#define checkError() if (err != kMoaErr_NoErr) return err;

#undef checkErr
#define checkErr(msg)									\
	if (err != kMoaErr_NoErr)							\
	{													\
		DebugStr_("System.DBApplication.GetApplicationData -  requesting in '");					\
		DebugStr_(appname);							\
		DebugStr_("' : ");								\
		DebugStr_(msg);									\
		DebugStr_("\n");								\
		return err;										\
	}


	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *)&requestorPriv, sizeof(requestorPriv));
	if (requestorPriv < mGetLevel)
	{
		DebugStr_("System.DBApplicationData.Get - insufficient priviledge\n");
		return COMMERR_SERV_NOT_PERMITTED;
	}

	IDList matches;
	getMatches(appname, args, matches, &err);
	checkErr("Error while getting matches.");

	// return back all the attributes associated with each AppData object

	int indx = matches.size() - 1;
	if (indx > 99)
		indx = 99;			// limit to only 100 return values

	msgReturn.WriteValue( kMoaMmValueType_List, indx+1, NULL );

	AssertNotNull_(mDBAdmin);

	for (; indx >= 0; indx--)
	{
		MoaError subErr = kMoaErr_NoErr;

		// For each matching AppData object, do a GetAttrNames
		BStringList		attrNames;
		mDBAdmin->getAttributeNames(matches[indx], attrNames, &subErr);

		// and then write out the attrs as a property list
		SvrContent	*subMsg = AllocContent();
		subMsg->WriteValue( kMoaMmValueType_PropList, attrNames.size(), NULL );

		for (int attrnum = attrNames.size() - 1; (subErr == kMoaErr_NoErr) && (attrnum >= 0); attrnum--)
		{
			IDNUM attrID = mDBAdmin->getAttrID((char *)attrNames[attrnum], &subErr);
			if (subErr != kMoaErr_NoErr)
			{
				continue;			// terminate inner loop
			}
			char *value = NULL;
			unsigned long size = 0;
			mDBAdmin->getAttribute(matches[indx], attrID, (const char **) &value, &size, &subErr);
			if (subErr != kMoaErr_NoErr)
				continue;
			AssertNotNull_(value);
			subMsg->WriteValue( kMoaMmValueType_Symbol, 0, (char *) attrNames[attrnum] );
			subMsg->WriteValue( -1, size, value );
			delete [] value;
		}

		if (subErr == kMoaErr_NoErr)
		{
			// if there was no error during the whole loop, then copy the data in
			msgReturn.WriteValue(-1, subMsg->getRawSize(), subMsg->getRawData());
		}
		else
		{
			// let's write an error code for this one...
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteValue( kMoaMmValueType_Symbol, 0, LOCALIZE_errorCode );
			msgReturn.WriteValue( kMoaMmValueType_Integer, 0, &subErr );
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			// If we made it this far, then the error was successfully
			// written to the return message, so let's just forget it ever happened.
			subErr = kMoaErr_NoErr;
		}
		FreeContent(subMsg);
	}
	return err;
}

MoaError ODBAppData::Delete(PISWServerUser sender, const char *appname, ParameterList &args)
{
	AssertNotNull_(sender);
	AssertNotNull_(appname);

	MoaError err = kMoaErr_NoErr;
#undef checkError
#define checkError() if (err != kMoaErr_NoErr) return err;

	unsigned long deletorPriv = 0;
	sender->GetSetting("userLevel", (char *)&deletorPriv, sizeof(deletorPriv));
	if (deletorPriv < mDeleteLevel)
	{
#ifdef DEBUG
		char msg[256];
		sprintf(msg, "System.DBApplication.DeleteAppData - your userlevel [%d] is below the system setting allowed to use this command [%d]\n",
					deletorPriv, mDeleteLevel);
		DebugStr_(msg);
#endif
		return COMMERR_SERV_NOT_PERMITTED;
	}

	IDList matches;
	getMatches(appname, args, matches, &err);
	checkError();

	// delete all the attributes associated with each AppData object
	// and then delete the AppData object itself.
	AssertNotNull_(mDBAdmin);
	AssertNotNull_(mAppDataTable);
	for (int indx = matches.size() - 1; indx >= 0; indx--)
	{
		// For each matching AppData object, delete it
		BStringList		attrNames;
		mDBAdmin->getAttributeNames(matches[indx], attrNames, &err);
		checkError();

		BStringList::iterator nameIter = attrNames.begin();
		while( nameIter != attrNames.end() )
		{
			IDNUM	attrID = mDBAdmin->getAttrID((char *) (*nameIter), &err);
			checkError();
			mDBAdmin->deleteAttribute(matches[indx], attrID, ATTR_WPRIVS_SYSTEM, &err);
			checkError();
			nameIter++;
		}
		mAppDataTable->DeleteAppData(this, matches[indx], &err);
		checkError();
	}
	return err;
}

void ODBAppData::deleteAppData(const IDNUM appID, MoaError *err)
{
	AssertNotNull_(err);

	IDList		matches;
	AssertNotNull_(mAppDataTable);
	mAppDataTable->GetMatches(this, appID, matches, err);
				// gets the list of AppData objects (for the given
				// application)
	if (*err != kMoaErr_NoErr)
		return;

	AssertNotNull_(mDBAdmin);
	AssertNotNull_(mAppDataTable);
	for (int indx = matches.size() - 1; indx >= 0; indx--)
	{
		// For each matching AppData object, do a GetAttrNames
		BStringList		attrNames;
		mDBAdmin->getAttributeNames(matches[indx], attrNames, err);
		if (*err != kMoaErr_NoErr)
			return;

		BStringList::iterator nameIter = attrNames.begin();
		while( nameIter != attrNames.end() )
		{
			IDNUM	attrID = mDBAdmin->getAttrID((char *) (*nameIter), err);
			if (*err != kMoaErr_NoErr)
				return;
			mDBAdmin->deleteAttribute(matches[indx], attrID, ATTR_WPRIVS_SYSTEM, err);
			if (*err != kMoaErr_NoErr)
				return;
			nameIter++;
		}
		mAppDataTable->DeleteAppData(this, matches[indx], err);
		if (*err != kMoaErr_NoErr)
			return;
	}
}

