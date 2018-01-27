// Options.cpp: implementation of the Options class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include <stdio.h>
#include "Options.h"
#include "Exception.h"
#include "Localize.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Options::Options(SvrObject *svrObj) :	mDebugLevel( 0 ),
										mSvrObj( NULL )
{
	// Normally we are initialized with the root of the command
	// tree ("System"), but it might be null if there was a problem
	// during construction of the command tree.
	if (svrObj == NULL)
		throw Exception(LOCALIZE_MemoryError, COMMERR_SERV_INTERNAL_ERROR);
	mSvrObj = svrObj;
}

Options::~Options()
{
	mSvrObj = NULL;
}

void Options::parseOption(const char *line)
{
	AssertNotNull_(line);

	// first word is the option name, the rest is the value...
	BString	localLine(line);
	localLine.TrimSpaces();

	char *name = (char *) localLine;
	char *value = name;			// start at the beginning
	while (*value && !isspace(*value))		// search for the first space
		value++;
	if (*value)
	{							// it's some kind of space
		*value++ = '\0';		// terminate the key string
								// advance to next character

		while (*value && isspace(*value))
			value++;			// search for first non-space
		// and now we have our value!
	}
	setOption(name, value);
}

/*
 * Set an option to a value.  The passed-in values are copied
 * to BStrings; no reference is kept to the original strings.
 */
void Options::setOption(const char *name, const char *value)
{
	BString localName(name);
	BString localValue(value);
	BString debug("DebugLevel");

	if (localName.Matches(debug))
	{	// set the debug level!
		sscanf((char *)localValue, "%d", &mDebugLevel);
	}
	else
	{
#ifdef DEBUG
		if ( ((mDebugLevel & DEBUG_CONFIG) > 0) && (mSvrObj))
		{
			mSvrObj->DisplayMessage("Option: ");
			mSvrObj->DisplayMessage((char *) localName);
			mSvrObj->DisplayMessage(" --> ");
			mSvrObj->DisplayMessage((char *) localValue);
			mSvrObj->DisplayMessage("\n");
		}
#endif
		IMMEMTAG( "Options::setOption - mNames.push_back" );
		mNames.push_back(localName);
		IMMEMTAG( "Options::setOption - mValues.push_back" );
		mValues.push_back(localValue);
	}
}

const char *Options::getOption(const char *name) const
{
	BString localName(name);
	for (int indx = mNames.size() - 1; indx >= 0; indx--)
	{
		if (localName.Matches(mNames[indx]))
			return (const char *) mValues[indx];
	}
	return NULL;
}

// Allow caller to specify where in the option table to begin
// searching -- and modifies the "startPos" argument so that it
// can be used in the next call to getOption().  Use repeatedly
// to get the value(s) of an option that can be defined multiple
// times.
const char *Options::getOption(const char *name, int *startPos) const
{
	BString localName(name);
	for (int indx = *startPos; indx < mNames.size(); indx++)
	{
		if (localName.Matches(mNames[indx]))
		{
			*startPos = indx+1;		// set where the next search should begin
			return (const char *) mValues[indx];
		}
	}
	return NULL;
}

const char *Options::getOption(const char *name, const char *defval) const
{
	const char *val = getOption(name);
	if (val == NULL)
		return defval;
	else
		return val;
}

int Options::getOption(const char *name, int defval) const
{
	const char *val = getOption(name);
	if (val == NULL)
		return defval;
	else
	{
		int	value;
		sscanf(val, "%d", &value);
		return value;
	}
}