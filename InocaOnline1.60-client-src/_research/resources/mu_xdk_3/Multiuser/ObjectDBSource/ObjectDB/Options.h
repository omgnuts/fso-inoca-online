// Options.h: interface for the Options class, which parses commands
// from the configuration file.
//
//////////////////////////////////////////////////////////////////////

#ifndef __Options__
#define __Options__

#include "BString.h"
#include "SvrObject.h"

class SvrObject;

class Options  
{
public:
	Options(SvrObject *);
	virtual ~Options();

	void parseOption(const char *line);
	void setOption(const char *name, const char *value);
	const char *getOption(const char *name, int *startPos) const;
	const char *getOption(const char *) const;
	const char *getOption(const char *, const char *) const ;	// lookup option, with default specified
	int	getOption(const char *, int) const;						// lookup an integer option
	int getDebugLevel() const { return mDebugLevel; }

private:
	BStringList		mNames;
	BStringList		mValues;
	int				mDebugLevel;
	SvrObject		*mSvrObj;			// for displaying messages
};


// define various debugging bits below

#ifdef DEBUG
#define checkDebug(level)  ((svrObj->getOptions()->getDebugLevel() & level) > 0)
#else
#define checkDebug(level)	(0)
#endif

#define	DEBUG_CONFIG	(1L<<0)			// = 1
#define DEBUG_DB		(1L<<1)			// = 2
#define DEBUG_VERBOSEDB	(1L<<2)			// = 4
#define DEBUG_OLDCLIENT	(1L<<3)			// = 8
	// DEBUG_OLDCLIENT - forces Xtra to always send back "kMoaErr_NoErr"
	//					on a reply with content, overriding the possible
	//					CONTENTS_HAS_ERRORS.  This allows the message to
	//					make sense to Director7, which hasn't heard of the
	//					CONTENTS_HAS_ERRORS error.
#define DEBUG_PACKDB	(1L<<4)			// = 16
	// DEBUG_PACKDB - a hack to tell CodeBase to pack the
	//					the databases as they are opened.


#endif // __Options__