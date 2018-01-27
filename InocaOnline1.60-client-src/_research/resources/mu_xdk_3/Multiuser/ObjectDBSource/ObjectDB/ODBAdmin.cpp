// ODBAdmin.cpp: implementation of the ODBAdmin class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "ODBAdmin.h"
#include "ParameterList.h"
#include "DebugException.h"
#include "Localize.h"
#include "GlobalStrings.h"

static MoaError CreateUser(SvrObject *recipient, SvrMessage &msgParams)
{	// redirect to the DBUser object
	msgParams.recipientID = "System.DBUser.Create";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError DeleteUser(SvrObject *recipient, SvrMessage &msgParams)
{	// redirect to the DBUser object
	msgParams.recipientID = "System.DBUser.Delete";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError GetUserCount(SvrObject *recipient, SvrMessage &msgParams)
{	// redirect to the DBUser object
	msgParams.recipientID = "System.DBUser.GetUserCount";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError GetUserNames(SvrObject *recipient, SvrMessage &msgParams)
{	// redirect to the DBUser object
	msgParams.recipientID = "System.DBUser.GetUserNames";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError CreateApplication(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBApplication.Create";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError DeleteApplication(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBApplication.Delete";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError CreateApplicationData(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBApplicationData.Create";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError DeleteApplicationData(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBApplicationData.Delete";
	SvrObject	*root = recipient->getRoot();
	return root->dispatch(msgParams.recipientID, msgParams);
}

static MoaError DeclareAttribute(SvrObject *recipient, SvrMessage &msgParams)
{
	// the response back always mirrors the input, so
	// let's set that up first.
	msgParams.msgSend.SetContent(msgParams.msgRecv.GetContent());

	// now parse the incoming message
	ParameterList	params(msgParams.msgRecv.GetContent());	
	params.parse();

	// get mandatory parameters 
	BString		attr;
	params.getString(LOCALIZE_attribute, &attr);

	ODBAdmin *dbAdmin = (ODBAdmin *) recipient;
	MoaError err = dbAdmin->declareAttribute(msgParams.sender, (char *)attr);

	return err;
}


static SvrMethod methodList[] =
{
	{ "CreateUser", &CreateUser },
	{ "DeleteUser", &DeleteUser },
	{ "GetUserCount", &GetUserCount },
	{ "GetUserNames", &GetUserNames },
	{ "DeclareAttribute", &DeclareAttribute },
	{ "CreateApplication", &CreateApplication },
	{ "DeleteApplication", &DeleteApplication },
	{ "CreateApplicationData", &CreateApplicationData },
	{ "DeleteApplicationData", &DeleteApplicationData },
};

ODBAdmin::ODBAdmin()
{
	setName("DBAdmin");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	mIDTable = NULL;
    mAttrList = NULL;
	mAttributes = NULL;
	mRawData = NULL;
	mDeclareAttrLevel = 0;
}

ODBAdmin::~ODBAdmin()
{
	if (mRawData != NULL)
	{
		delete mRawData;
		mRawData = NULL;
	}
	if (mAttributes != NULL)
	{
		delete mAttributes;
		mAttributes = NULL;
	}
	if (mAttrList != NULL)
	{
		delete mAttrList;
		mAttrList = NULL;
	}
	if (mIDTable != NULL)
	{
		delete mIDTable;
		mIDTable = NULL;
	}
}

void ODBAdmin::initialize()
{
	// called by the methods to make sure that the
	// database is: created, opened, filled with system defined values

	MoaError err = kMoaErr_NoErr;

	if (mIDTable == NULL)
	{
		IMMEMTAG( "ODBAdmin::initialize new DBCB_ID" );
		mIDTable = new DBCB_ID( this, getDBConnection() );
		AssertNotNull_(mIDTable);

		char	*IDnames[] =
		{
					"GlobalID",			// users, applications, players  all use this ID
					"AttrID",			// there is a string able for Attribute
										// names, which this is the ID for
					"RawID",			// raw data has its own ID tag.
		};
		for (int indx = sizeof(IDnames)/sizeof(char *) - 1; indx >= 0; indx--)
		{
			// try to get the value first.
			IDNUM curID = mIDTable->getID(this, IDnames[indx], &err);
			if (err == COMMERR_SERV_RECORD_DOESNT_EXIST)
			{			// must be that this ID entry doesn't exist
				err = kMoaErr_NoErr;
				mIDTable->CreateID(this, IDnames[indx], 0, &err);
			}
			if (err != kMoaErr_NoErr)
				throw Exception( (char *) gStrODBAccessErr, err);
		}
	}
	if (mAttrList == NULL)
	{
		IMMEMTAG( "ODBAdmin::initialize new DBCB_AttrList" );
		mAttrList = new DBCB_AttrList( this, getDBConnection() );
		AssertNotNull_(mAttrList);

		char *attrNames[] =
		{
			LOCALIZE_lastLoginTime,
			LOCALIZE_lastUpdateTime,
			LOCALIZE_password,
			LOCALIZE_description,
			LOCALIZE_userlevel,
			LOCALIZE_status,
			LOCALIZE_creationTime,
		};
		for (int indx = sizeof(attrNames)/sizeof(char *) - 1; indx >= 0; indx--)
			declareAttribute(NULL, attrNames[indx]);
	}
	if (mRawData == NULL)
	{
		IMMEMTAG( "ODBAdmin::initialize new DBCB_RawData" );
		mRawData = new DBCB_RawData( this, getDBConnection() );
		// RawData is really part of attributes, but is separated
		// to try and conserve on space.
		AssertNotNull_(mRawData);
	}
	if (mAttributes == NULL)
	{
		IMMEMTAG( "ODBAdmin::initialize new DBCB_Attributes" );
		mAttributes = new DBCB_Attributes( this, getDBConnection(), mRawData );
		// Default attributes for objects are created by the objects
		// directly.  For instance, when ODBUser creates the default
		// "Admin" account, it creates extra attributes as required.
		AssertNotNull_(mAttributes);
	}

	// Declare any attributes from the config file
	int searchPos = 0;
	const char * optVal;
	while ( (optVal = getOptions()->getOption(LOCALIZE_declareAttribute, &searchPos)) != NULL )
	{
		declareAttribute( NULL, optVal );
	}
	
	mDeclareAttrLevel = getOptions()->getOption(LOCALIZE_DBAdmin_DeclareAttribute, ADMIN_USERLEVEL);
}



//++------------------------------------------------------------------------------
//	ODBAdmin::GetNewID
//++------------------------------------------------------------------------------
IDNUM ODBAdmin::getNewID( const char *idtype, MoaError *err )
{
	AssertNotNull_( mIDTable );
	
	IDNUM maxID = mIDTable->GetNewID( this, idtype, err );
	
	if (*err != kMoaErr_NoErr)
		maxID = 0;

	return maxID;
}



IDNUM ODBAdmin::getAttrID(const char *attrName, MoaError *err)
{
	AssertNotNull_(mAttrList);
	return mAttrList->GetAttr(this, attrName, err);
}

void ODBAdmin::setAttribute(const IDNUM ownerID, const IDNUM attrID, const char *value, unsigned long size, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err)
{
	AssertNotNull_(mAttributes);
	mAttributes->setAttribute(this, ownerID, attrID, value, size, creatorPriv, attrPriv, err);
}

void ODBAdmin::getAttribute(const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size)
{
	*value = NULL;				// make sure no one gets confused by random values
	*size = 0;
	AssertNotNull_(mAttributes);
	mAttributes->getAttribute(this, ownerID, attrID, value, size);
}

void ODBAdmin::getAttribute(const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size, MoaError *err)
{
	*value = NULL;				// make sure no one gets confused by random values
	*size = 0;
	AssertNotNull_(mAttributes);
	mAttributes->getAttribute(this, ownerID, attrID, value, size, err);
}


void ODBAdmin::getAttributeNames(const IDNUM ownerID, BStringList &attrNames, MoaError *err)
{
	AssertNotNull_(err);

	// first, get the list of attribute IDs which have been assigned
	IDList	attrIDs;
	AssertNotNull_(mAttributes);
	mAttributes->GetAttributeList(this, ownerID, attrIDs, err);
	if (*err != kMoaErr_NoErr)
		return;

	// and then go through the list and convert the IDs to names
	AssertNotNull_(mAttrList);
	for (int indx = attrIDs.size() - 1; indx >= 0; indx--)
	{
		BString		name;
		mAttrList->GetAttrName(this, attrIDs[indx], name, err);
		if (*err != kMoaErr_NoErr)
			return;

		IMMEMTAG( "ODBAdmin::getAttributeNames - attrNames.push_back" );
		attrNames.push_back(name);
	}
}



//++------------------------------------------------------------------------------
//	ODBAdmin::declareAttribute
//++------------------------------------------------------------------------------
MoaError ODBAdmin::declareAttribute( PISWServerUser sender, const char *attr )
{
	AssertNotNull_(attr);

	unsigned long declarorPriv = 0;
	if (sender == NULL)
	{
		// declare some attributes during xtra initialization
		declarorPriv = mDeclareAttrLevel;
	}
	else
		sender->GetSetting("userLevel", (char *) &declarorPriv, sizeof(declarorPriv) );
	if (declarorPriv < mDeclareAttrLevel)
		return COMMERR_SERV_NOT_PERMITTED;

	MoaError err = kMoaErr_NoErr;
	
	// try to get the value first.
	AssertNotNull_(mAttrList);
	IDNUM idVal = mAttrList->GetAttr(this, attr, &err);
	// if it does exist, this has been defined to not be an error
	if ( err == kMoaErr_NoErr )
		return err;

	if (err != COMMERR_SERV_RECORD_DOESNT_EXIST)
		return err;

	// OK, the attribute doesn't exist
	err = kMoaErr_NoErr;			// reset err


	// ah -- so we have to create this entry.
	// But first, is it an illegal name?
	if ( BString::IndCompare(attr, LOCALIZE_errorCode) == 0 )
		return COMMERR_BAD_PARAMETER;

	// Otherwise, create it...
	IDNUM newAttrID = getNewID("AttrID", &err);
	if (err != kMoaErr_NoErr)
		return err;

	mAttrList->CreateAttr( this, newAttrID, attr, &err );

	return err;
}



void ODBAdmin::deleteAttribute(const IDNUM ownerID, const IDNUM attrID, const unsigned long priv, MoaError *err)
{
	AssertNotNull_(mAttributes);
	mAttributes->deleteAttribute(this, ownerID, attrID, priv, err);
}

void ODBAdmin::getAttrMatches(const IDNUM attrID, IDList &ownerIDs, IDList &matches, MoaError *err)
{
	AssertNotNull_(mAttributes);
	mAttributes->getMatches(this, attrID, ownerIDs, matches, err);
}