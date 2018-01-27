// SvrObject.h: SvrObjects are objects which can be the target
// of a server message.  ie, they can be specifically named as
// the recipientID of a message.  The "recipientID" is
// compared against the "name" of the object to determine if there
// is actually a match.
//
//////////////////////////////////////////////////////////////////////

#ifndef __SvrObject__
#define __SvrObject__

#include <vector.h>
#include	"SWServerXtra.h"
#include "DBGeneric.h"
#include "Options.h"
#include "SvrContent.h"
#include "ParameterList.h"


typedef long	IDNUM;
typedef	vector<long>	IDList;


class SvrObject;
class ODBAdmin;
class Options;
typedef SvrObject * SvrObjectPtr;
typedef vector<SvrObjectPtr>	SvrObjectList;

struct SvrMessage
{
	SvrContent		msgSend;
	SvrObject		*recipient;
	ConstPMoaChar	recipientID;
	ConstPMoaChar	subject;
	ConstPMoaChar	senderID;
	SvrContent		msgRecv;
	PISWServerUser	sender;
	PISWServerMovie	movie;
};

typedef MoaError (*MsgHandler)(SvrObject *recipient, SvrMessage &msgParam);
struct SvrMethod
{
	char *name;
	MsgHandler	handler;
};

typedef SvrMethod *SvrMethodPtr;

class SvrObject  
{
public:
	SvrObject();
	virtual ~SvrObject();

	void setName(const char *);
	const char *getName() const { return _name; };

	// addChild() - given a pointer to a SvrObject, adds it to this
	// SvrObject's child list.
	void addChild(SvrObjectPtr child);

	// setMethods() - allows SvrObject inheritors to build a static
	// table of functions to enumerate methods available on the object.
	void setMethods(const SvrMethodPtr methods, int size)
		{
			_methods = methods;
			_numMethods = size;
		}

	void DisplayMessage(const char *) const;

	SvrObject	*findObject(const char *name);

	MoaError dispatch(ConstPMoaChar recipientID, SvrMessage &msgParam);			// dispatches to children, or self
	void setMovieServer(PISWServerMovie movie, PISWServer server);

	void setOptions(Options *opt);		// give all objects easy access to options
	Options *getOptions() const
	{
		AssertNotNull_(mOptions);
		return mOptions;
	}

	void setRoot(SvrObject *root);		// all objects need to know about OSystem
	SvrObject *getRoot() const { return mRoot; }

	void setDBConnection(DBGeneric *db);
	DBGeneric *getDBConnection() const
	{
		AssertNotNull_(mDB);
		return mDB;
	}

	void doInitializations();			// initialize all the children objects, and self

	virtual void initialize() = 0;		// to be called by msg methods.

	PISWServerContent CreateContent();

	SvrContent	*AllocContent();
	void FreeContent(SvrContent *);

	void GetSetting(const char *, char *, long);

	MoaError SetAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, unsigned long creatorPriv, unsigned long attrPriv, IDNUM objID, ParameterList &attribs, BString &lastUpdateTime);
	MoaError GetAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, IDNUM objID, ParameterList &attribs);
	MoaError GetAttributeNames(SvrContent &msgReturn, ODBAdmin *dbAdmin, IDNUM objID);
	MoaError DeleteAttribute(SvrContent &msgReturn, ODBAdmin *dbAdmin, unsigned long deletorPrivs, IDNUM objID, ParameterList &attribs);
	MoaError Delete(ODBAdmin *dbAdmin, unsigned long deletorPrivs, IDNUM objID);

	virtual bool	HaveCustomAttribute( const char * attrName );
	virtual void	SetCustomAttribute( const IDNUM ownerID, const char * attrName, ParameterList & attribs, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err) ;
	virtual void	GetCustomAttribute( const IDNUM ownerID, const char * attrName, SvrContent	* dstContent, MoaError * err );


private:
	const char *	_name;			// name of this object

	SvrObjectList	mChildren;		// list of children SvrObjects

	int				_numMethods;	// number of methods defined for this obj
	SvrMethodPtr	_methods;		// methods are tracked here

	PISWServerMovie	mMovie;			// pointer to controlling movie
	PISWServer		mServer;		// pointer to controlling server

	Options			*mOptions;		// pointer to options object
	SvrObject		*mRoot;			// pointer to the root object	
	DBGeneric		*mDB;			// pointer to the DB connection object

	SvrContentList	mContentList;	// list of pre-allocated content objects.
};

#endif // __SvrObject__
