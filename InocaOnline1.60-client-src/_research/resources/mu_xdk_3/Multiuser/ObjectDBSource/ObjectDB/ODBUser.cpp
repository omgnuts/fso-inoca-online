// ODBUser.cpp: implementation of the ODBUser class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "ODBUser.h"
#include "ODBPlayer.h"
#include "ParameterList.h"
#include "DebugException.h"
#include "SvrContent.h"
#include "mmtypes.h"

#include "Localize.h"

static MoaError Logon(SvrObject *recipient, SvrMessage &msgParams)
{
	ODBUser		*dbUser = (ODBUser *) recipient;
	if (dbUser->getAuthScheme() == AUTH_NONE)
	{	// if we weren't asked to provide authentication services,
		// then just pretend like we don't exist.
		DebugStr_("LOGON: No authentication.\n");
		return kMoaErr_FuncNotFound;
	}
	try
	{
		msgParams.msgSend.CreateContent(recipient);

		ParameterList	params(msgParams.msgRecv.GetContent());	
		params.parse();

		return dbUser->Logon(msgParams.msgSend, msgParams.sender, params);
	}
	catch (...)
	{
		DebugStr_("Error encountered during login sequence.\n");
		// if there are any problems at all, we want to
		// default to no authentication.  PR#50531
		// Oops.  Dave wants different behaviour!
		switch (dbUser->getAuthScheme())
		{
		case -1:
			DebugStr_("No auth scheme selected.  Did you remember 'Config Done'?\n");
			return COMMERR_SERV_INTERNAL_ERROR;
		case AUTH_NONE:
		case AUTH_USER_OPT:
			// allow users on in this case
			return kMoaErr_FuncNotFound;
		case AUTH_USER_REQ:
			return COMMERR_SERV_NOT_PERMITTED;
		}
		return kMoaErr_FuncNotFound;
	}
}


static MoaError Create(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 
	BString		name;
	BString		password;
	params.getString(LOCALIZE_user, &name);
	params.getString(LOCALIZE_password, &password);

	// build the rest of the reply message
	msgParams.msgSend.WriteValue( kMoaMmValueType_PropList, 1, NULL );
	msgParams.msgSend.WriteValue( kMoaMmValueType_Symbol, NULL, LOCALIZE_user );
	msgParams.msgSend.WriteValue( kMoaMmValueType_String, NULL, (char *) name );

	// now fetch the optional arguments
	long		userlevel = 0;

	MoaError err = kMoaErr_NoErr;
	userlevel = params.getInteger(LOCALIZE_userlevel, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
		err = kMoaErr_NoErr;
	if (err != kMoaErr_NoErr)
		return err;
	
	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->Create(msgParams.sender, (char *)name, (char *)password, userlevel);
}

static MoaError Delete(SvrObject *recipient, SvrMessage &msgParams)
{
	// the reply message always mirrors the input message
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent() );

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 
	BString		name;
	params.getString(LOCALIZE_user, &name);

	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->Delete(msgParams.sender, (char *)name);
}


static MoaError GetUserCount(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);

	MoaError err = kMoaErr_NoErr;

	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->GetUserCount( msgParams.msgSend, msgParams.sender );
}


static MoaError GetUserNames(SvrObject *recipient, SvrMessage & msgParams)
{
	MoaError err = kMoaErr_NoErr;

	msgParams.msgSend.CreateContent(recipient);

	// Set the defaults for the start and end records
	long startRecNum = 0;
	long endRecNum = startRecNum + 99;

	// See if we have a prop list in the parameters
	SvrContent msg;
	msg.SetContent( msgParams.msgRecv.GetContent() );

	long valueType = 0;
	long valueSize = 0;
	msg.GetValueInfo( &valueType, &valueSize, NULL );

	switch (valueType) 
	{
		case kMoaMmValueType_Symbol:
		case kMoaMmValueType_String:
		case kMoaMmValueType_PropList:
			{
				ParameterList	params(msgParams.msgRecv.GetContent());	
				params.parse();

				// Get the optional parameters
				startRecNum = params.getInteger( LOCALIZE_lowNum, &err );
				if ( err == COMMERR_WRONG_NUMBER_OF_PARAMS )
				{
					err = kMoaErr_NoErr;
					startRecNum = 0;		// Default to zero
				}
				else if (err != kMoaErr_NoErr)
					return err;

				endRecNum = params.getInteger( LOCALIZE_highNum, &err );
				if ( err == COMMERR_WRONG_NUMBER_OF_PARAMS )
				{
					err = kMoaErr_NoErr;
					endRecNum = startRecNum + 99;		// Default to 100
				}
				else if (err != kMoaErr_NoErr)
					return err;
			}
			break;
		default:
			break;
	}

	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->GetUserNames( msgParams.msgSend, msgParams.sender, startRecNum, endRecNum );
}


static MoaError GetAttributeNames(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.msgSend.CreateContent(recipient);

	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	MoaError err = kMoaErr_NoErr;

	// get optional parameters 
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

	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->GetAttributeNames(msgParams.msgSend, msgParams.sender, users);
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
	BString		user, lastUpdateTime;
	params.getString(LOCALIZE_user, &user, &err);
	if (err == COMMERR_WRONG_NUMBER_OF_PARAMS)
	{
		user = msgParams.senderID;
		err = kMoaErr_NoErr;
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

	// then do the deed
	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->SetAttribute(msgParams.msgSend, msgParams.sender, (char *)user, attribs, lastUpdateTime);
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
	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->GetAttribute(msgParams.msgSend, msgParams.sender, users, attribs);
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
	ODBUser		*dbUser = (ODBUser *) recipient;
	return dbUser->DeleteAttribute(msgParams.msgSend, msgParams.sender, users, attribs);
}

static SvrMethod methodList[] =
{
	{ "Logon",	&Logon },
	{ "Create", &Create },
	{ "Delete", &Delete },
	{ "GetAttributeNames", &GetAttributeNames },
	{ "SetAttribute", &SetAttribute },
	{ "GetAttribute", &GetAttribute },
	{ "DeleteAttribute", &DeleteAttribute },
	{ "GetUserCount", &GetUserCount },
	{ "GetUserNames", &GetUserNames },
};

ODBUser::ODBUser()
{
	setName("DBUser");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	mDBAdmin = NULL;
	mUserTable = NULL;
	mAuthScheme = -1;

	mCreateLevel = ADMIN_USERLEVEL;		// the userlevel required for DBUser.Create
	mSetAttrLevel = 0;
	mGetAttrLevel = 0;
	mGetAttrNamesLevel = 0;
	mDeleteAttrLevel = ADMIN_USERLEVEL;
	mDeleteLevel = ADMIN_USERLEVEL;
	mGetPasswordLevel = ADMIN_USERLEVEL;
	mSetPasswordLevel = ADMIN_USERLEVEL;
	mGetUserCountLevel = ADMIN_USERLEVEL;
	mGetUserNamesLevel = ADMIN_USERLEVEL;

	mDefUserLevel = 0;	// the default userlevel in authScheme=2

}

ODBUser::~ODBUser()
{
	if (mUserTable != NULL)
	{
		delete mUserTable;
		mUserTable = NULL;
	}
	mDBAdmin = NULL;
}

void ODBUser::initialize()
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

	if (mUserTable == NULL)
	{
		IMMEMTAG( "ODBUser::initialize" );
		mUserTable = new DBCB_User( this, getDBConnection() );
		AssertNotNull_(mUserTable);

		// Check the config file for other user accounts to create
		int searchPos = 0;
		const char *optVal;
		while ( (optVal = getOptions()->getOption(LOCALIZE_create_user, &searchPos)) != NULL )
		{
			// Something was defined... should be    "create_user  <username> <passwd>  <userlevel>
			char username[MAX_STR_LEN+1];
			char password[MAX_STR_LEN+1];
			unsigned long userlevel = 0;
			int parsed = sscanf( optVal, "%s %s %d", username, password, &userlevel);
			if ( parsed == 3 )
			{
				// only create the user if the command was specified correctly
				MoaError err = Create( NULL, username, password, userlevel );

				// If the record already exists, make sure the password and userlevel match
				if ( err == COMMERR_SERV_DATA_RECORD_NOT_UNIQUE )
				{
					BString passwordFromDB;
					mUserTable->GetPassword( passwordFromDB );

					err = kMoaErr_NoErr;
					unsigned long userLevelFromDB = GetUserLevel( username, &err );
					if ( err == kMoaErr_NoErr )
					{
						if ( BString::Compare( password, passwordFromDB ) != 0 )
						{
							mUserTable->SetPassword( password, -1, &err );
						}

						if ( userlevel > 100 )
							userlevel = 100;		// server doesn't like anything higher than 100
						if ( userLevelFromDB != userlevel )
						{
							IDNUM userID = mUserTable->getID( this, username, &err );
							if ( err == kMoaErr_NoErr )
							{
								SetUserLevel( userID, userlevel, &err );
							}
						}
					}
				}

				if ((err != kMoaErr_NoErr) && (err != COMMERR_SERV_DATA_RECORD_NOT_UNIQUE))
				{
					DebugStr_("Error while trying to create account from config file.\n");
					throw DebugException( (char *) gStrODBAdminErr, err);
				}
			}
			else
			{
				throw Exception( (char *) gStrODBCreateErr, COMMERR_SERV_BAD_MESSAGE);
			}
		}
	}
	
	const char *authScheme = getOptions()->getOption(LOCALIZE_authentication, LOCALIZE_none);
	if ( BString::IndCompare(authScheme, LOCALIZE_none) == 0 )
		mAuthScheme = 0;
	else if ( BString::IndCompare(authScheme, LOCALIZE_user_record_required) == 0 )
		mAuthScheme = 1;
	else if ( BString::IndCompare(authScheme, LOCALIZE_user_record_optional) == 0 )
		mAuthScheme = 2;
	else
		throw DebugException( (char *) gStrODBAuthenErr, COMMERR_SERV_INTERNAL_ERROR);

	mCreateLevel = getOptions()->getOption(LOCALIZE_DBAdmin_CreateUser, ADMIN_USERLEVEL);
	mGetAttrLevel = getOptions()->getOption(LOCALIZE_DBUser_GetAttribute, 20);
	mSetAttrLevel = getOptions()->getOption(LOCALIZE_DBUser_SetAttribute, 20);
	mGetAttrNamesLevel = getOptions()->getOption(LOCALIZE_DBUser_GetAttributeNames, 20);
	mDeleteAttrLevel = getOptions()->getOption(LOCALIZE_DBUser_DeleteAttribute, 20);
	mDeleteLevel = getOptions()->getOption(LOCALIZE_DBAdmin_DeleteUser, ADMIN_USERLEVEL);
	mGetPasswordLevel = getOptions()->getOption(LOCALIZE_DBUser_GetPassword, ADMIN_USERLEVEL);
	mSetPasswordLevel = getOptions()->getOption(LOCALIZE_DBUser_SetPassword, ADMIN_USERLEVEL);
	mGetUserCountLevel = getOptions()->getOption(LOCALIZE_DBAdmin_GetUserCount, ADMIN_USERLEVEL);
	mGetUserNamesLevel = getOptions()->getOption(LOCALIZE_DBAdmin_GetUserNames, ADMIN_USERLEVEL);

}

MoaError ODBUser::Create(PISWServerUser sender, const char *username, const char *password, long userlevel)
{
	// creator may be NULL!!!
	AssertNotNull_(username);
	AssertNotNull_(password);

	MoaError	err = kMoaErr_NoErr;

	unsigned long creatorPriv = 100;		// default to Super User abilities
	if (sender != NULL)
	{
		// is null during call to initialize(), when "Admin"
		// account is first created.  Normal users will fall
		// into this block and have creatorPriv set properly.
		sender->GetSetting("userLevel", (char *) &creatorPriv, sizeof(creatorPriv) );
	}
	if (creatorPriv < mCreateLevel)
	{
#ifdef DEBUG
		char msg[256];
		sprintf(msg, "System.DBAdmin.CreateUser - your userlevel [%d] is below the system requirement [%d]\n", creatorPriv, mCreateLevel);
		DebugStr_(msg);
#endif
		return COMMERR_SERV_NOT_PERMITTED;
	}

	// Dave says that you can't create a user with a userlevel
	// higher than the one you have, either.  PR#50536
	if (creatorPriv < userlevel)
	{
		DebugStr_("System.DBAdmin.CreateUser - can't create a user with higher permissions than your own.\n");
		return COMMERR_SERV_NOT_PERMITTED;
	}

	// see if the user already exists...
	AssertNotNull_(mUserTable);
	IDNUM	userID = mUserTable->getID(this, username, &err);
	if (err == kMoaErr_NoErr)
		return COMMERR_SERV_DATA_RECORD_NOT_UNIQUE;
	if (err != COMMERR_INVALID_USERID)
		return err;

	// must be that this user entry doesn't exist
	err = kMoaErr_NoErr;
	// first, get a new userID for this person, from the GlobalID counter
	AssertNotNull_(mDBAdmin);
	userID = mDBAdmin->getNewID("GlobalID", &err);
	if (err != kMoaErr_NoErr) 
		return err;

	// and then add this user to the user table
	mUserTable->createUser(this, userID, username,
									password, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	// Now let's add the predefined attributes

	// #lastUpdateTime
	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();

	IDNUM attrID = mDBAdmin->getAttrID(LOCALIZE_lastUpdateTime, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	mDBAdmin->setAttribute(userID, attrID, (const char *)nowRaw->getRawData(),
						nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	nowRaw = NULL;			// just to make sure we forget about it.

	// #userlevel
	SetUserLevel( userID, userlevel, &err );
	if (err != kMoaErr_NoErr) 
		return err;

	// #status
	int status = getOptions()->getOption(LOCALIZE_default_user_status, 0);
	attrID = mDBAdmin->getAttrID(LOCALIZE_status, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	SvrContent		tmpMsg;
	tmpMsg.CreateContent(this);
	tmpMsg.WriteValue(kMoaMmValueType_Integer, 0, &status);
	mDBAdmin->setAttribute(userID, attrID, tmpMsg.getRawData(), tmpMsg.getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	// #lastLoginTime
	attrID = mDBAdmin->getAttrID(LOCALIZE_lastLoginTime, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	tmpMsg.CreateContent(this);
	tmpMsg.WriteValue(kMoaMmValueType_String, 0, "");
	mDBAdmin->setAttribute(userID, attrID, tmpMsg.getRawData(), tmpMsg.getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	return err;
}

MoaError ODBUser::GetAttributeNames(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetAttrNamesLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// the reply is a property list for each object that
	// was requested...

	msgReturn.WriteValue( kMoaMmValueType_PropList, users.attrSize(), NULL );

	AssertNotNull_(mUserTable);
	for (int indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mUserTable->getID(this, users.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttributeNames(msgReturn, mDBAdmin, userID);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}

MoaError ODBUser::SetAttribute( SvrContent & msgReturn, PISWServerUser sender, const char * user, ParameterList & attribs, BString & lastUpdateTime )
{
	AssertNotNull_(sender);
	AssertNotNull_(user);

	MoaError err = kMoaErr_NoErr;

	unsigned long creatorPriv = 0;
	sender->GetSetting("userLevel", (char *)&creatorPriv, sizeof(creatorPriv) );
	if (creatorPriv < mSetAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// Search for #password and make sure we have permission to set it.
	int indx;
	for (indx = attribs.attrSize() - 1; indx >= 0; indx--)
	{
		if ( BString::IndCompare( attribs.getAttrName(indx), LOCALIZE_password) == 0 )
		{
			if ( creatorPriv < mSetPasswordLevel )
			{	// Ooops, user's not allowed to get the password
				return COMMERR_SERV_NOT_PERMITTED;
			}
		}
	}

	unsigned long privs = ATTR_WPRIVS_NONE;
	if (creatorPriv >= ADMIN_USERLEVEL)
		privs |= ATTR_WPRIVS_SYSTEM;

	// make a list, so we can return the results for each
	// object that was specified...  In this case, only
	// a single object is allowed.
	msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );

	AssertNotNull_(mUserTable);
	do
	{	// this marks the looping point, if there were multiple
		// objects specified...

		// reply message is always either:  [ "obj": [ #lastUpdateTime : <...> ] ]
		// or    [ "obj": [ #errorCode: <...> ] ]
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (void *) user);


		IDNUM userID = mUserTable->getID(this, user, &err);
		if (err != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(err);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			break;
		}

		MoaError subErr = SvrObject::SetAttribute(msgReturn, mDBAdmin, privs, ATTR_WPRIVS_NONE, userID, attribs, lastUpdateTime);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	} while (0);

	return err;
}

MoaError ODBUser::GetAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, ParameterList &attribs)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *)&requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// Add #lastUpdateTime if it wasn't already there.  Also search for #password
	// and make sure we have permission to get it.
	int indx;
	int foundLastUpdateTime = 0;
	for (indx = attribs.attrSize() - 1; indx >= 0; indx--)
	{
		if ( BString::IndCompare( attribs.getAttrName(indx), LOCALIZE_lastUpdateTime) == 0 )
		{
			foundLastUpdateTime = 1;
			indx = 0;
		}
		if ( BString::IndCompare( attribs.getAttrName(indx), LOCALIZE_password) == 0 )
		{
			if ( requestorPriv < mGetPasswordLevel )
			{	// Ooops, user's not allowed to get the password
				return COMMERR_SERV_NOT_PERMITTED;
			}
		}
	}
	if (!foundLastUpdateTime)
		attribs.addAttr(LOCALIZE_lastUpdateTime);

	// the reply is a property list for each object that
	// was requested...

	msgReturn.WriteValue( kMoaMmValueType_PropList, users.attrSize(), NULL );

	AssertNotNull_(mUserTable);
	for (indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) users.getAttrName(indx) );
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mUserTable->getID(this, users.getAttrName(indx), &subErr);
		if (subErr != kMoaErr_NoErr)
		{
			msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
			msgReturn.WriteErrorCode(subErr);
			err = COMMERR_CONTENT_HAS_ERROR_INFO;
			continue;
		}

		// our parent method will do the rest of the work...
		subErr = SvrObject::GetAttribute(msgReturn, mDBAdmin, userID, attribs);
		if (subErr != kMoaErr_NoErr)
			err = subErr;
	}
	return err;
}



// ================================================================================
// ODBUser::HaveCustomAttribute
//		We support password as a custom attribute
// ================================================================================
bool	ODBUser::HaveCustomAttribute( const char * attrName )
{
	return ( BString::IndCompare( attrName, LOCALIZE_password) == 0 );
}


// ================================================================================
// Set password.
// ================================================================================
void	ODBUser::SetCustomAttribute( const IDNUM ownerID, 
									  const char * attrName, 
									  ParameterList & attribs, 
									  unsigned long creatorPriv, 
									  unsigned long attrPriv,
									  MoaError * err ) 
{
	if ( BString::IndCompare( attrName, LOCALIZE_password) == 0 )
	{	// Extract the string from the content at value
		BString newPassword;
		attribs.getString( attrName, &newPassword );
		mUserTable->SetPassword( newPassword, ownerID, err );
	}
	else
	{
		Assert_( 0 );	// This shouldn't happen
		SvrObject::SetCustomAttribute( ownerID, attrName, attribs, creatorPriv, attrPriv,err );
	}
}


// ================================================================================
// ODBUser::GetCustomAttribute
// ================================================================================
void	ODBUser::GetCustomAttribute( const IDNUM ownerID, 
									const char * attrName, 
									SvrContent * dstContent, 
									MoaError * err )
{
	if ( BString::IndCompare( attrName, LOCALIZE_password) == 0 )
	{
		BString passWord;
		long err = 0;
		mUserTable->GetPassword( passWord, ownerID, &err );
		AssertNotNull_( dstContent );
		dstContent->WriteValue( kMoaMmValueType_String, 0, (char *) passWord );
	}
	else
	{
		Assert_( 0 );	// This shouldn't happen
		SvrObject::GetCustomAttribute( ownerID, attrName, dstContent, err );
	}
}

MoaError ODBUser::DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, ParameterList &attribs)
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

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
	// returns an error...

	SvrContent *tmpMsg = AllocContent();
	int numErrors = 0;

	AssertNotNull_(mUserTable);
	for (indx = 0; indx < users.attrSize(); indx++)
	{	// note that the index counts *up*, to preserve
		// the order that the client requested the data in
		
		MoaError subErr = kMoaErr_NoErr;
		IDNUM userID = mUserTable->getID(this, users.getAttrName(indx), &subErr);
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
		// NOTE: Never allow ATTR_WPRIVS_SYSTEM through!  This xtra
		// requires the system attributes to be defined.
		subErr = SvrObject::DeleteAttribute(*tmpMsg, mDBAdmin, ATTR_WPRIVS_NONE, userID, attribs);
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

MoaError ODBUser::Delete(PISWServerUser sender, const char *username)
{
	AssertNotNull_(username);

	MoaError err = kMoaErr_NoErr;

	// Sender may be NULL during startup
	unsigned long deletorPriv = 100;
	if ( sender != NULL )
	{
		sender->GetSetting("userLevel", (char *) &deletorPriv, sizeof(deletorPriv) );
	}

	if (deletorPriv < mDeleteLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	ODBPlayer *dbPlayer = (ODBPlayer *) getRoot()->findObject("System.DBPlayer");
	AssertNotNull_(dbPlayer);

	AssertNotNull_(mUserTable);
	IDNUM userID = mUserTable->getID(this, username, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	err = SvrObject::Delete(mDBAdmin, ATTR_WPRIVS_SYSTEM, userID);
	if (err != kMoaErr_NoErr) 
		return err;
	
	mUserTable->deleteUser(this, username, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	dbPlayer->DeletePlayersWithUserID( userID, &err );

	return err;
}



//++------------------------------------------------------------------------------
//	ODBUser::GetUserCount
//		Server command to return the number of users in the database
//++------------------------------------------------------------------------------
MoaError ODBUser::GetUserCount( SvrContent & msgReturn, PISWServerUser sender )
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetUserCountLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	// The reply is a simple integer with the number of users in the database
	AssertNotNull_(mUserTable);
	long numUsers = mUserTable->GetUndeletedRecordCount( &err );

	msgReturn.WriteValue( kMoaMmValueType_Integer, 0, &numUsers );

	return err;
}



//++------------------------------------------------------------------------------
//	ODBUser::GetUserNames
//		Server command to return the list of users in the database
//++------------------------------------------------------------------------------
MoaError ODBUser::GetUserNames( SvrContent & msgReturn, PISWServerUser sender, long startRecNum, long endRecNum )
{
	AssertNotNull_(sender);

	MoaError err = kMoaErr_NoErr;

	unsigned long requestorPriv = 0;
	sender->GetSetting("userLevel", (char *) &requestorPriv, sizeof(requestorPriv) );
	if (requestorPriv < mGetUserNamesLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	SvrContent	* tmpMsg = AllocContent();

	try
	{
		// Get the list from the database
		BStringList userList;
		mUserTable->GetUserNameList( startRecNum, endRecNum, userList );

		// The reply is a list with the user IDs
		tmpMsg->WriteValue( kMoaMmValueType_List, userList.size(), NULL );
		BStringList::iterator nameIter = userList.begin();
		while( nameIter != userList.end() )
		{
			tmpMsg->WriteValue( kMoaMmValueType_String, NULL, (char *) (*nameIter) );
			nameIter++;
		}
	}
	catch(...)
	{
		err = COMMERR_SERV_INTERNAL_ERROR;
	}

	// If we have an error, clear whatever we already wrote
	if ( err != kMoaErr_NoErr )
	{	
		FreeContent( tmpMsg );		// Put something in the return
		tmpMsg->WriteValue( kMoaMmValueType_List, 0, NULL );
	}

	msgReturn.WriteValue( -1, tmpMsg->getRawSize(), tmpMsg->getRawData() );
	
	FreeContent(tmpMsg);
	
	return err;
}




MoaError ODBUser::Logon(SvrContent &msgReturn, PISWServerUser sender, ParameterList &args)
{
	// the arguments are a simple list: [movie, username, password]
	MoaError	err = kMoaErr_NoErr;

	// always return back a message!
	msgReturn.CreateContent(this);
	if (args.attrSize() > 0)
		msgReturn.WriteValue( kMoaMmValueType_String, 0, (char *) args.getAttrName(0) );
	else
		msgReturn.WriteValue( kMoaMmValueType_String, 0, "");

	if (mUserTable == NULL)
	{
		// PR#51049 -- even if there is trouble opening the database,
		// we'd at least like users to be able to log on...
		switch (mAuthScheme)
		{
			case -1:
				DebugStr_("DBUser object failed to initialize.  Did you remember 'ConfigDone'?\n");
				return kMoaErr_FuncNotFound;		// default to allow logons
			case AUTH_NONE:
				// this was short-circuited earlier...
				return kMoaErr_FuncNotFound;
			case AUTH_USER_OPT:
				// if there was an error, default to allowing logins
				// with default privs
				return kMoaErr_FuncNotFound;
			case AUTH_USER_REQ:
				// this is the only case where we should allow logins
				return COMMERR_SERV_INTERNAL_ERROR;
		}
	}
	AssertNotNull_(mUserTable);

	// We either have a prop list, or a simple 3 element list
	BString		user, password;
	IDNUM	userID = 0;
	if (args.attrSize() == 3)
	{
		user = BString( args.getAttrName(1) );
		password = BString( args.getAttrName(2) );
	}
	else
	{
		args.getString(LOCALIZE_banguser, &user);
		args.getString(LOCALIZE_bangpassword, &password);
	}


	userID = mUserTable->getID( this, user, &err );
	switch (mAuthScheme)
	{
		case -1:		// initialization didn't happen?
			DebugStr_("DBUser object failed to initialize.  Did you remember 'ConfigDone'?\n");
			err = COMMERR_SERV_INTERNAL_ERROR;		// should be this
			err = kMoaErr_FuncNotFound;				// but everyone wants this...
			break;
		case AUTH_NONE:
			break;		// this is short-circuited earlier, anyway
		case AUTH_USER_REQ:
			break;	// just fall through
		case AUTH_USER_OPT:
			if (err == COMMERR_INVALID_USERID)
			{	// this is okay... just override and don't check the password
				// DebugStr_("LOGON: Anonymous logon allowed.\n");
				return kMoaErr_NoErr;
			}
			// anything else falls through to either be an err, or checks the pass
			break;
	}
	if (err != kMoaErr_NoErr) 
		return err;

	BString passwordFromDB;
	mUserTable->GetPassword( passwordFromDB );
	
	if ( BString::Compare( password, passwordFromDB ) != 0 )
	{
		err = COMMERR_INVALID_PASSWORD;
		return err;
	}

	// users who are authenticated should have their userlevel updated
	unsigned long userLevel = GetUserLevel(user, &err);
	if (err != kMoaErr_NoErr) 
		return err;

	if (userLevel > 100)
		userLevel = 100;		// server doesn't like anything higher than 100
	sender->ChangeSetting("userLevel", (char *)&userLevel, sizeof(userLevel));

#if ( 0 )
	// #status doesn't affect logon ability

	IDNUM statusID = mDBAdmin->getAttrID(LOCALIZE_status);
	char *value = NULL;
	unsigned long size = 0;
	mDBAdmin->getAttribute(userID, statusID, (const char **) &value, &size);
	SvrContent tmpMsg;
	tmpMsg.CreateContent(this);
	tmpMsg.WriteValue(-1, size, value);
	delete [] value;


	long status = tmpMsg.readInteger();
	if (status != 0)
	{	// 0 - Activated
		// 1 - Deactivated
		// 2 - Suspended
		// Don't allow logins except for activated accounts.
		err = COMMERR_SERV_NOT_PERMITTED;
	}
#endif

	// since we're about to let them log in, we better
	// update the #lastLoginTime

	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();
	IDNUM lastLoginTimeID = mDBAdmin->getAttrID(LOCALIZE_lastLoginTime, &err);
	if (err != kMoaErr_NoErr)
	{	// an error looking up an attrID is just way bad
		return err;
	}
	AssertNotNull_(mDBAdmin);
	mDBAdmin->setAttribute(userID, lastLoginTimeID, nowRaw->getRawData(),
				nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr)
	{	// an error writing into the database??
		return err;
	}
	nowRaw = NULL;

	return err;
}


//++------------------------------------------------------------------------------
//	ODBUser::SetUserLevel
//		Set the userlevel for the given username
//++------------------------------------------------------------------------------
void		ODBUser::SetUserLevel( IDNUM userID, long level, MoaError *err )
{
	AssertNotNull_( err );
	AssertNotNull_( mDBAdmin );

	IDNUM userlevelID = mDBAdmin->getAttrID( LOCALIZE_userlevel, err );
	if ( *err == kMoaErr_NoErr )
	{
		SvrContent		tmpMsg;
		tmpMsg.CreateContent(this);
		tmpMsg.WriteValue( kMoaMmValueType_Integer, 0, &level );
		mDBAdmin->setAttribute( userID, userlevelID, tmpMsg.getRawData(), tmpMsg.getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, err );
	}
}





//++------------------------------------------------------------------------------
//	DBCB_User::GetUserLevel
//		Get the userlevel for the given username
//++------------------------------------------------------------------------------
unsigned long ODBUser::GetUserLevel(const char *username, MoaError *err)
{
	AssertNotNull_(username);
	AssertNotNull_(err);

	IDNUM userID;
	switch ( mAuthScheme )
	{
		case AUTH_NONE:
			// let's not bother even looking up a userID, since it's a waste of time
			*err = kMoaErr_NoErr;
			return mDefUserLevel;
			break;
		case AUTH_USER_OPT:
			userID = mUserTable->getID(this, username, err);
			if (*err == COMMERR_INVALID_USERID)
			{	// then reset the error and return the default userlevel
				*err = kMoaErr_NoErr;
				return mDefUserLevel;
			}
			break;
		case -1:				// We may not be fully initialized yet
		case AUTH_USER_REQ:
			userID = mUserTable->getID(this, username, err);
			break;
	}
	if ( *err != kMoaErr_NoErr ) 
		return 0;

	AssertNotNull_(mDBAdmin);
	IDNUM userlevelID = mDBAdmin->getAttrID(LOCALIZE_userlevel, err);
	if ( *err != kMoaErr_NoErr ) 
		return 0;

	char *value = NULL;
	unsigned long size = 0;
	mDBAdmin->getAttribute(userID, userlevelID, (const char **) &value, &size, err);
	if ( *err != kMoaErr_NoErr ) 
		return 0;

	SvrContent tmpMsg;
	tmpMsg.CreateContent(this);
	tmpMsg.WriteValue(-1, size, value);
	delete [] value;
	return tmpMsg.readInteger();
}


IDNUM ODBUser::getID(const char *username, MoaError *err)
{
	AssertNotNull_(mUserTable);
	return mUserTable->getID(this, username, err);
}
