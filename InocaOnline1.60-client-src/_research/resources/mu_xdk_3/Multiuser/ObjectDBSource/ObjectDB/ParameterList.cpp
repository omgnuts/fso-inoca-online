// ParameterList.cpp: implementation of the ParameterList class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DebugException.h"
#include "ParameterList.h"
#include "SvrContent.h"
#include "mmtypes.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

ParameterList::ParameterList(ParameterList &parent)
{
	mMsg.SetContent(parent.getMsgContents());
}

ParameterList::ParameterList(PISWServerContent msg)
{
	mMsg.SetContent(msg);
}

ParameterList::ParameterList()
{
}

ParameterList::~ParameterList()
{
}

long ParameterList::setPosition(const char *attrName)
{
	BString attr(attrName);
	for (int indx = mAttrs.size() - 1; indx >= 0; indx--)
	{
		if (attr.Matches(mAttrs[indx]))
		{
			mMsg.SetPosition( mValues[indx] );
			return mValues[indx];
		}
	}
	throw DebugException("No such parameter defined.",
				COMMERR_WRONG_NUMBER_OF_PARAMS);
}

long ParameterList::setPosition(const char *attrName, MoaError *err)
{
	BString attr(attrName);
	for (int indx = mAttrs.size() - 1; indx >= 0; indx--)
	{
		if (attr.Matches(mAttrs[indx]))
		{
			mMsg.SetPosition( mValues[indx] );
			return mValues[indx];
		}
	}
	*err = COMMERR_WRONG_NUMBER_OF_PARAMS;
	return 0;
}

void ParameterList::getString(const char *attrName, BString *outVal)
{
	setPosition(attrName);
	mMsg.readString(*outVal);
}

void ParameterList::getString(const char *attrName, BString *outVal, MoaError *err)
{
	setPosition(attrName, err);
	if (*err != kMoaErr_NoErr)
		return;
	mMsg.readString(*outVal);
}

void ParameterList::getData(const char *attrName, char **outVal, long *outSize)
{
	long pos = setPosition(attrName);
	mMsg.GetValueInfo( NULL, NULL, outSize );
	
	// Get the pointer to the data
	*outVal = (char *) mMsg.GetBufferPointer();
	*outVal += pos;
}

long ParameterList::getInteger(const char *attrName)
{
	(void) setPosition(attrName);
	return mMsg.readInteger();
}

long ParameterList::getInteger(const char *attrName, MoaError *err)
{
	(void) setPosition(attrName, err);
	if (*err != kMoaErr_NoErr)
		return 0;
	return mMsg.readInteger();
}

double ParameterList::getNumber(const char *attrName)
{
	(void) setPosition(attrName);
	return mMsg.readNumber();
}

double ParameterList::getNumber(const char *attrName, MoaError *err)
{
	(void) setPosition(attrName, err);
	if (*err != kMoaErr_NoErr)
		return 0;
	return mMsg.readNumber();
}

void ParameterList::parse()
{	// to parse out parameter lists in this message
	readParameters(mMsg, &mAttrs, &mValues);
}
void ParameterList::parse(SvrContent &msg)
{	// used by "getParamList()" to parse out a sub-list.
	readParameters(msg, &mAttrs, &mValues);
}

void ParameterList::getParamList(const char *attrName, ParameterList *outVal)
{	// to parse a parameter whose contents are a list
	(void) setPosition(attrName);
	outVal->parse(mMsg);
}

void ParameterList::getParamList(const char *attrName, ParameterList *outVal, MoaError *err)
{	// to parse a parameter whose contents are a list
	(void) setPosition(attrName, err);
	if (*err != kMoaErr_NoErr)
		return;
	outVal->parse(mMsg);
}


//=======================================================================
//	readParameters
//		Utility routine that scans the content and returns a list
//		of attrib:value pairs
//=======================================================================
void ParameterList::readParameters(
									SvrContent &msg, 
									BStringList * outAttrNames,
									AttrValueOffsetList * outAttrValueOffsets
								)
{
	if ( (outAttrNames == NULL) && (outAttrValueOffsets == NULL) )
	{	// Don't have a string list or offset list to add to, so just skip it.

		msg.SkipValue();
		throw DebugException("Missing output lists for attribute name/value pairs.",
					COMMERR_SERV_INTERNAL_ERROR);
	}
	
	long valueType = 0;
	long valueSize = 0;
	msg.GetValueInfo( &valueType, &valueSize, NULL );

	BString		tmpStr;

	int indx;

	switch (valueType) {
		case kMoaMmValueType_Symbol:
		case kMoaMmValueType_String:
			msg.readString(tmpStr);
			IMMEMTAG( "ParameterList::readParameters - outAttrNames->push_back 1" );
			outAttrNames->push_back(tmpStr);
			break;
		case kMoaMmValueType_PropList:
			msg.SkipListStart();
			for (indx = valueSize; indx > 0; indx--)
			{
				msg.readString(tmpStr);
				IMMEMTAG( "ParameterList::readParameters - outAttrNames->push_back 2" );
				outAttrNames->push_back(tmpStr);

				long curPosition = msg.GetPosition();
				IMMEMTAG( "ParameterList::readParameters - outAttrValueOffsets->push_back" );
				outAttrValueOffsets->push_back( curPosition );
				// Skip past the value
				msg.SkipValue();
			}
			break;
		case kMoaMmValueType_List:
			msg.SkipListStart();
			for (indx = valueSize; indx > 0; indx--)
			{
				msg.readString(tmpStr);
				IMMEMTAG( "ParameterList::readParameters - outAttrNames->push_back 3" );
				outAttrNames->push_back(tmpStr);
			}
			break;
		default:
			throw DebugException("Unexpected value in parameter list",
						COMMERR_BAD_PARAMETER);
			break;
	}
}


//=======================================================================
//	scanParameters
//		Utility routine that scans the message content for a list
//      of given attributes.  The input message *must* be a property
//      list.
//=======================================================================
void ParameterList::scanParameters( 
								SvrContent &msg,
								BStringList * validParams,
								BStringList * outAttrNames,
								AttrValueOffsetList * outAttrValueOffsets
								)
{
	long valueType = 0;
	long listSize = 0;
	msg.GetValueInfo( &valueType, &listSize, NULL );
	if ( valueType != kMoaMmValueType_PropList)
		throw DebugException("Was expecting a property list during scan.",
					COMMERR_BAD_PARAMETER);

	// First skip the list start and get to the first value
	msg.SkipListStart();

	BString symbolString( MAXSERVEROBJECTTAGSIZE + 2 );

	for ( long curProp = listSize; curProp > 0; curProp-- )
	{	// We need to read N #symbol : value pairs from the prop list.
		msg.readString(symbolString);

		int found = 0;
		for (int indx = validParams->size() - 1; indx >= 0; indx--)
		{
			if (symbolString.Matches( (*validParams)[indx] ) )
			{
				outAttrNames->push_back(symbolString);

				long curPosition = msg.GetPosition();
				IMMEMTAG( "ParameterList::scanParameters - outAttrValueOffsets->push_back" );
				outAttrValueOffsets->push_back( curPosition );
				// Skip past the value
				msg.SkipValue();
				found = 1;
				break;
			}
		}
		if (! found)
		{
			// Skip past the value
			msg.SkipValue();
		}
	}
}


void ParameterList::addAttr(const char *val)
{
	IMMEMTAG( "ParameterList::addAttr - mAttrs.push_back" );
	mAttrs.push_back(val);
}

