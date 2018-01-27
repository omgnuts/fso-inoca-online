// SvrObject.cpp: implementation of the SvrObject class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif


#include "SrvXtnUtils.h"
#include "Assert.h"


#include <stdlib.h>

#include "SrvXtnUtils.h"
#include "SvrObject.h"
#include "DebugException.h"
#include "UpdateTime.h"
#include "ODBAdmin.h"
#include "localize.h"

#include "BString.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
SvrObject::SvrObject()
{
	_name = NULL;
	_numMethods = 0;
	_methods = NULL;
	mMovie = NULL;
	mServer = NULL;
	mRoot = NULL;
	mOptions = NULL;
}

SvrObject::~SvrObject()
{
    _name = NULL;
	_methods = NULL;
	int indx;
	for (indx = mChildren.size() - 1; indx >= 0; indx--)
	{
		delete mChildren[indx];
		mChildren.pop_back();
	}
	for (indx = mContentList.size() - 1; indx >= 0; indx--)
	{
		delete mContentList[indx];
		mContentList.pop_back();
	}
	mMovie = NULL;
	mServer = NULL;
}

/*
 * SvrObjects are organized in an heirarchy based on the
 * name.  With the current (20-Oct-1999) commands, the
 * "System" object is the root of the command tree, and
 * all other objects are children of that one object.
 * When incoming messages are parsed, they traverse this
 * tree looking for an object to handle the message.
 */
void SvrObject::addChild(SvrObjectPtr child)
{
	// Each parent object creates its children and adds them
	// as part of the constructor.  If we receive a NULL here,
	// it's because the memory routines are not initialized.

	if (child == NULL)
		throw Exception(LOCALIZE_MemoryError, COMMERR_SERV_INTERNAL_ERROR);

	IMMEMTAG( "SvrObject::addChild - mChildren.push_back" );
	mChildren.push_back(child);
}


/*
 * Set the name of the object.  This name will be used
 * later while parsing the command of an incoming message.
 * A command like "System.DBAdmin.CreateUser" is parsed out
 * as "System" and "DBAdmin" objects (System being a parent
 * of DBAdmin), and a final "CreateUser" command.  See
 * SvrObject::dispatch() for how this works.
 */
void SvrObject::setName(const char *name) {
	// Boy, this is icky -- we just store the pointer passed
	// to us, and we never free it later.  The expectation is
	// that a string constant was used to define us, since
	// memory allocation routines aren't available until
	// after we've been initialized by the application...
	AssertNotNull_(name);
	_name = name;
}

SvrObject	*SvrObject::findObject(const char *name)
{
	// locate an object by name in the object tree
	const char *objName = getName();
	Assert_( objName != NULL );
	int	objNameLen = strlen(objName);
	if (! StringStartsWith( (char *)name, (char *)objName, objNameLen) )
		return NULL;

	const char *nextObjName = name + objNameLen;

	if (*nextObjName == '\0')
		return this;			// exact match
	if (*nextObjName != '.')
		return NULL;			// no match here...
	nextObjName++;

	int indx;
	SvrObject *child = NULL;
	if (*nextObjName)
	{
		for (indx = mChildren.size()-1; indx >= 0; indx--)
		{
			child = mChildren[indx]->findObject(nextObjName);
			if (child != NULL)
				break;
		}
	}
	else
		child = this;			// no sub-object in recipientID
    return child;
}

/*
 * given the details of an incoming message, send it to the
 * appropriate object.
 */
MoaError SvrObject::dispatch( ConstPMoaChar recipientID, SvrMessage &msgParams)
{
	if (recipientID == NULL)
	{
		// This isn't likely to happen, but it *can*, if someone
		// sends up an unknown command, and also happens to send
		// a null subject (since we test the subject as a last
		// resort...  eg, "System"/"Logon").
		return kMoaErr_FuncNotFound;
	}

	MoaError err = kMoaErr_FuncNotFound;
	// get the name of the object and the length of the name
	const char *objName = getName();
	Assert_( objName != NULL );
	int	objNameLen = strlen(objName);
	if (! StringStartsWith( (char *)recipientID, (char *)objName, objNameLen) )
	{
		// message wasn't intended for this object, so let's just
		// ignore it.
		return err;
	}
	// get the next part of the recipientID
	ConstPMoaChar nextObjName = recipientID + objNameLen;

	// If the next char is neither a period nor the end of String
	// marker, then the recipientID just contains this object...
	// For instance, "SystemMgr" contains "System" as a substring.
	switch (*nextObjName) {
	case '.':
		// there's still more to go, so skip over the period
		// and try to match the next part
		nextObjName++;
		break;
	case '\0':
		// if the recipientID named only the object and not
		// the subject, then let's assume that the subject
		// contains the method name.  Oy!
		// This is so that "System"/"Logon" will work, while
		// all other commands are something like:
		//     "System.DBAdmin.CreateUser".
		// WARNING: the subject might be NULL!
		nextObjName = msgParams.subject;
		break;
	default:
		return err;
	}


	// Otherwise

	// Check each of the children first, to see if
	// they want to handle the incoming message;
	int indx;
	for (indx = mChildren.size()-1; indx >= 0; indx--)
	{
		// Count down, on the off chance we're on a processor where
		// this can be optimized
		err = mChildren[indx]->dispatch(nextObjName, msgParams);
		if (err != kMoaErr_FuncNotFound)
		{
			// someone handled it, so let's get out of here
			return err;
		}
	}

	// after checking the children, let's check the methods we
	// know about...
	for (indx = _numMethods - 1; indx >= 0; indx--)
	{
		// Count down, on the off chance that we're on a processor
		// where this can be optimized
		PMoaChar	methodName = _methods[indx].name;
		Assert_( methodName != NULL );
		if ( StringMatches((char *)nextObjName, methodName) )
		{
			// found a match!!
			// call the handler for the method!
			return ( *( _methods[indx].handler ) )(this, msgParams);
		}
	}
	return err;
}

void SvrObject::DisplayMessage(const char *message) const
{
	if( mMovie != NULL )
	{
		mMovie->DisplayMessage( (char *) message );
	}
	else if ( mServer != NULL )
	{
		mServer->DisplayMessage( (char *) message );
	}
}

void SvrObject::setMovieServer(PISWServerMovie movie, PISWServer server)
{
	mMovie = movie;
	mServer = server;
	for (int indx = mChildren.size() - 1; indx >= 0; indx--)
		mChildren[indx]->setMovieServer( movie, server );
}
void SvrObject::setOptions(Options *opt)
{
	mOptions = opt;
	for (int indx = mChildren.size() - 1; indx >= 0; indx--)
		mChildren[indx]->setOptions(opt);
}

void SvrObject::setRoot(SvrObject *root)
{
	mRoot = root;
	for (int indx = mChildren.size() - 1; indx >= 0; indx--)
		mChildren[indx]->setRoot(root);
}

void SvrObject::setDBConnection(DBGeneric *db)
{
	mDB = db;
	for (int indx = 0; indx < mChildren.size(); indx++)
		mChildren[indx]->setDBConnection(db);
}

// doInitializations()  - traverse the whole tree and initialize everything
// This will end up getting called several times (in SvrExtension.cpp),
// because we don't know
// precisely when we've read all the options, and many objects depend on
// the options to know what they're doing.
void SvrObject::doInitializations()
{
	this->initialize();
	for (int indx = 0; indx < mChildren.size(); indx++)
		mChildren[indx]->initialize();
}

PISWServerContent SvrObject::CreateContent()
{
	return (PISWServerContent) mServer->CreateContent();
}

void SvrObject::GetSetting(const char *attr, char *data, long size)
{
	if (mServer == NULL)
		throw DebugException("There is no server to query setting from.",
					COMMERR_SERV_INTERNAL_ERROR);
	MoaError err = mServer->GetSetting((char *) attr, data, size);
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while retrieving attribute from server.",
					COMMERR_SERV_INTERNAL_ERROR);
}


// AllocContent() :
// maintains a list of "pre-allocated" SvrContent objects
// and returns one from that list (removing it from the list).
// If there are no available pre-allocated SvrContent objects,
// then a new one is created with an empty message object.
SvrContent	*SvrObject::AllocContent()
{
	if (mRoot != this)
		return mRoot->AllocContent();		// only allocate from the
											// root object (OSystem)
	int numObjs = mContentList.size();
	if (numObjs == 0)
	{
		IMMEMTAG( "SvrObject::AllocContent" );
		SvrContent	*tmpContent = new SvrContent();
		if (tmpContent == NULL)
			throw Exception("Out of memory!", COMMERR_SERV_INTERNAL_ERROR);
		tmpContent->CreateContent(this);
		return tmpContent;
	}
	SvrContent *tmpContent = mContentList[numObjs-1];
	mContentList.pop_back();
	return tmpContent;
}

// FreeContent() :
// returns a SvrContent object back to the "pre-allocated"
// list used by AllocContent().  SvrContents are Reset()
// to eliminate any gross memory usage in the buffer.
// Performance improvements are expected from this preallocated
// list.
void SvrObject::FreeContent(SvrContent *obj)
{
	if (mRoot != this)
	{
		mRoot->FreeContent(obj);		// only dealloc in root obj
		return;
	}
	obj->Reset();
	IMMEMTAG( "SvrObject::FreeContent - mContentList.push_back" );
	mContentList.push_back(obj);
}




MoaError SvrObject::SetAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, unsigned long creatorPriv, unsigned long attrPriv, IDNUM objID, ParameterList & attribs, BString &lastUpdateTime)
{
	// this base method assumes that the reply message only
	// requires either  [ #lastUpdateTime: <...> ]
	// or [#errorCode: <...> ]
	msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );

	// first, make sure that we have a proper parameter list
	int		listSize = attribs.attrSize();
	if (listSize != attribs.valueSize())
	{
		msgReturn.WriteErrorCode(COMMERR_BAD_PARAMETER);
		return COMMERR_CONTENT_HAS_ERROR_INFO;
	}

	MoaError err = kMoaErr_NoErr;

	// then, verify that each attribute actually exists
	IDList	attrIDList;
	int indx;
	for (indx = 0; indx < listSize; indx++)
	{
		const char *attrName = attribs.getAttrName(indx);
		if ( !HaveCustomAttribute( attrName ) )
		{
			IDNUM attrID = dbAdmin->getAttrID(attrName, &err);
			if (err != kMoaErr_NoErr)
			{
				msgReturn.WriteErrorCode(err);
				return COMMERR_CONTENT_HAS_ERROR_INFO;
			}
			IMMEMTAG( "SvrObject::SetAttribute - attrIDList.push_back" );
			attrIDList.push_back(attrID);
		}
	}

	//     check for concurrency problems
	// We have to write to #lastUpdateTime later, so get
	// the attrID unconditionally.
	IDNUM lastUpdateTimeID = dbAdmin->getAttrID(LOCALIZE_lastUpdateTime, &err);
	if (err != kMoaErr_NoErr)
	{
		msgReturn.WriteErrorCode(err);
		return COMMERR_CONTENT_HAS_ERROR_INFO;
	}
	if (! lastUpdateTime.IsEmpty() )
	{

		char *value = NULL;
		unsigned long size = 0;
		dbAdmin->getAttribute(objID, lastUpdateTimeID, (const char **) &value, &size, &err);
		if (err != kMoaErr_NoErr)
		{
			msgReturn.WriteErrorCode(err);
			return COMMERR_CONTENT_HAS_ERROR_INFO;
		}
		SvrContent *tmpMsg = AllocContent();
		tmpMsg->WriteValue(-1, size, value);
		delete [] value;
		BString		realUpdateTime(size+1);
		tmpMsg->readString(realUpdateTime);
		if (! lastUpdateTime.Matches(realUpdateTime) )
			err = COMMERR_CONCURRENCY_EXCEPTION;

		FreeContent(tmpMsg);

		if (err != kMoaErr_NoErr)
		{
			msgReturn.WriteErrorCode(err);
			return COMMERR_CONTENT_HAS_ERROR_INFO;
		}


	}


	// and finally set each of the attributes in turn...
	for (indx = listSize - 1; indx >= 0; indx--)
	{
		// lookup the name
		const char *attrName = attribs.getAttrName( indx );

		// get the data
		char	*data;
		long	dataSize;
		attribs.getData( attrName, &data, &dataSize );
		
		if ( HaveCustomAttribute( attrName ) )
		{	// Set it
			SetCustomAttribute( objID, attrName, attribs, creatorPriv, attrPriv, &err );
		}
		else
		{
			// Normal write it to the database...
			IDNUM attrID = attrIDList[indx];
			dbAdmin->setAttribute( objID, attrID, data, dataSize, creatorPriv, attrPriv, &err);
		}

		if (err != kMoaErr_NoErr)
		{
			msgReturn.WriteErrorCode(err);
			return COMMERR_CONTENT_HAS_ERROR_INFO;
		}
	}

	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();
	dbAdmin->setAttribute(objID, lastUpdateTimeID, nowRaw->getRawData(),
				nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr)
	{
		msgReturn.WriteErrorCode(err);
		return COMMERR_CONTENT_HAS_ERROR_INFO;
	}
	// also put it in the reply message
	msgReturn.WriteValue( kMoaMmValueType_Symbol, 0, LOCALIZE_lastUpdateTime );
	msgReturn.WriteValue(-1, nowRaw->getRawSize(), nowRaw->getRawData());
	nowRaw = NULL;

	return err;
}

MoaError SvrObject::GetAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, IDNUM objID, ParameterList &attribs)
{
	MoaError err = kMoaErr_NoErr;

	// this method writes a reply of the form:
	//     [ #attrName: <attrVal>, #attrName2: <attrVal>, ... ]
	// or  [ #errorCode: <...> ]


	// Start looking up attributes, but write all the data
	// into a temporary SvrContent, in case an error happens
	// in mid-stream.
	SvrContent	* tmpMsg = AllocContent();


	// process the list of attribute names
	int listSize = attribs.attrSize();
	int numValidAttrs = 0;
	int indx;
	for (indx = 0; indx < listSize; indx++)
	{
		char *value = NULL;
		unsigned long size = 0;

		const char *attrName = attribs.getAttrName(indx);
		if ( HaveCustomAttribute( attrName ) )
		{
			tmpMsg->WriteValue( kMoaMmValueType_Symbol, 0, (char *) attrName );
			GetCustomAttribute( objID, attrName, tmpMsg, &err );
			if (err != kMoaErr_NoErr)
			{	// an error looking up an attrID is just way bad
				FreeContent(tmpMsg);
				msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
				msgReturn.WriteErrorCode(err);
				return COMMERR_CONTENT_HAS_ERROR_INFO;
			}
		}
		else
		{	// Lookup the attrID of an attrName
			IDNUM attrID = dbAdmin->getAttrID(attrName, &err);
			if (err != kMoaErr_NoErr)
			{	// an error looking up an attrID is just way bad
				FreeContent(tmpMsg);
				msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
				msgReturn.WriteErrorCode(err);
				return COMMERR_CONTENT_HAS_ERROR_INFO;
			}

			// see if the attrID is defined for the object
			dbAdmin->getAttribute(objID, attrID, (const char **) &value, &size, &err);
			if (err == COMMERR_SERV_RECORD_DOESNT_EXIST)
			{
				// it's not an error if the attribute isn't defined on the object
				err = kMoaErr_NoErr;
				continue;
			}
			if (err != kMoaErr_NoErr)
			{
				FreeContent(tmpMsg);
				msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
				msgReturn.WriteErrorCode(err);
				return COMMERR_CONTENT_HAS_ERROR_INFO;
			}
			tmpMsg->WriteValue( kMoaMmValueType_Symbol, 0, (char *) attrName );
			tmpMsg->WriteValue( -1, size, value );
			delete [] value;
		}

		numValidAttrs++;
	}

	// now that we know how many defined attrs there were, we can
	// build a real list
	msgReturn.WriteValue( kMoaMmValueType_PropList, numValidAttrs, NULL );
	msgReturn.WriteValue(-1, tmpMsg->getRawSize(), tmpMsg->getRawData());
	FreeContent(tmpMsg);
	return err;
}



// ================================================================================
// SvrObject::HaveCustomAttribute
// Other classes will normally override this
// ================================================================================
bool	SvrObject::HaveCustomAttribute( const char * /* attrName */)
{
	return false;
}


// ================================================================================
// SvrObject::SetCustomAttribute
// Other classes will normally override this
// ================================================================================
void	SvrObject::SetCustomAttribute( const IDNUM /* ownerID */, 
									  const char * /* attrName */, 
									  ParameterList & /* attribs */, 
									  unsigned long /* creatorPriv */, 
									  unsigned long /* attrPriv */,
									  MoaError * err ) 
{
	if ( err )
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
}


// ================================================================================
// SvrObject::GetCustomAttribute
// ================================================================================
void	SvrObject::GetCustomAttribute( const IDNUM /* ownerID */, 
									  const char * /* attrName */, 
									  SvrContent * /* dstContent */,
									  MoaError * err )
{
	if ( err )
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
}



// GetAttributeNames - given an object ID, does the actual
// work for GetAttributeNames and adds "[ attrname1, attrname2, ...]"
// to the message buffer.  The caller is responsible for prefixing
// this with the name of the object in question.
MoaError SvrObject::GetAttributeNames(SvrContent &msgReturn, ODBAdmin *dbAdmin, IDNUM objID)
{
	MoaError err = kMoaErr_NoErr;

	BStringList		attrNames;
	dbAdmin->getAttributeNames(objID, attrNames, &err);
	if (err != kMoaErr_NoErr)
	{	// an error looking up attribute names is bad
		msgReturn.WriteValue( kMoaMmValueType_PropList, 1, NULL );
		msgReturn.WriteErrorCode(err);
		return COMMERR_CONTENT_HAS_ERROR_INFO;
	}

	msgReturn.WriteValue( kMoaMmValueType_List, attrNames.size(), NULL );

	BStringList::iterator nameIter = attrNames.begin();
	while( nameIter != attrNames.end() )
	{
		msgReturn.WriteValue( kMoaMmValueType_Symbol, NULL, (char *) (*nameIter) );
		nameIter++;
	}
	return err;
}

MoaError SvrObject::DeleteAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, unsigned long deletorPrivs, IDNUM objID, ParameterList &attribs)
{
	MoaError err = kMoaErr_NoErr;

	// this base method assumes that the reply message only
	// requires either  [ ]
	// or [#errorCode: <...> ]

	// process the list of attribute names
	int listSize = attribs.attrSize();
	int numValidAttrs = 0;
	int indx;
	for (indx = 0; indx < listSize; indx++)
	{
		// lookup the attrID of an attrName
		const char *attrName = attribs.getAttrName(indx);
		IDNUM attrID = dbAdmin->getAttrID(attrName, &err);
		if (err != kMoaErr_NoErr)
		{	// an error looking up an attrID is just way bad
			// but now our caller is responsible for writing the error msg
			return err;
		}

		dbAdmin->deleteAttribute(objID, attrID, deletorPrivs, &err);
		if (err == COMMERR_SERV_RECORD_DOESNT_EXIST)
			err = kMoaErr_NoErr;	// non-defined attrs are okay!
		if (err != kMoaErr_NoErr)
		{	// our caller is responsible for writing the error out
			return err;
		}
	}

	UpdateTime now;
	now.setToNow(this);
	SvrContent	*nowRaw = now.getContent();
	IDNUM lastUpdateTimeID = dbAdmin->getAttrID(LOCALIZE_lastUpdateTime, &err);
	if (err != kMoaErr_NoErr)
	{	// an error looking up an attrID is just way bad
		return err;
	}
	dbAdmin->setAttribute(objID, lastUpdateTimeID, nowRaw->getRawData(),
				nowRaw->getRawSize(), ATTR_WPRIVS_SYSTEM, ATTR_WPRIVS_SYSTEM, &err);
	if (err != kMoaErr_NoErr)
	{	// an error writing to the database is also bad...
		return err;
	}
	nowRaw = NULL;

	return err;
}

MoaError SvrObject::Delete(ODBAdmin *dbAdmin, unsigned long deletorPrivs, IDNUM objID)
{
	MoaError err = kMoaErr_NoErr;

	// Go through and delete all the attributes, first.
	BStringList		attrNames;
	dbAdmin->getAttributeNames(objID, attrNames, &err);
	if (err != kMoaErr_NoErr)
		return err;

	BStringList::iterator nameIter = attrNames.begin();
	while( nameIter != attrNames.end() )
	{
		IDNUM	attrID = dbAdmin->getAttrID((char *) (*nameIter), &err);
		if (err != kMoaErr_NoErr)
			return err;
		dbAdmin->deleteAttribute(objID, attrID, deletorPrivs, &err);
		if (err != kMoaErr_NoErr)
			return err;
		nameIter++;
	}
	return err;
}