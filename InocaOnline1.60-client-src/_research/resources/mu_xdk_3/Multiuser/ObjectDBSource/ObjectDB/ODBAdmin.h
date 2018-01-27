// ODBAdmin.h: object to handle messages directed to System.DBAdmin
//
//////////////////////////////////////////////////////////////////////

#ifndef __ODBAdmin__
#define __ODBAdmin__

#include "SvrObject.h"
#include "DBCB_ID.h"
#include "DBCB_AttrList.h"
#include "DBCB_Attributes.h"
#include "DBCB_RawData.h"

#include "UpdateTime.h"

class ODBAdmin : public SvrObject  
{
public:
	ODBAdmin();
	virtual ~ODBAdmin();

	virtual void initialize();				// insures that DBs are created and init'd
									// Should be called from all users of the DB

	IDNUM	getNewID(const char *, MoaError *err);	// get a new ID number for the named table/property

	IDNUM	getAttrID(const char *, MoaError *err);
									// get the ID of a predefined attribute

	void setAttribute(const IDNUM ownerID, const IDNUM attrID, const char *value, unsigned long size, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err);
									// will set or create a new attribute.  It the attrib already exists,
									// then the priv is checked against the existing priv.  In any case,
									// the new priv is always assigned.
	void getAttribute(const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size);
									// get the value of an attribute
	void getAttribute(const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size, MoaError *err);
									// get the value of an attribute
	void getAttributeNames(const IDNUM ownerID, BStringList &attrNames, MoaError *err);
									// builds a list of all the attribute names which this object
									// has defined.
	void deleteAttribute(const IDNUM ownerID, const IDNUM attrID, const unsigned long priv, MoaError *err);
									// deletes a single attribute
	MoaError declareAttribute(PISWServerUser sender, const char *);
									// globally declares an attribute name as valid by assigning
									// an attrID to it.

	void getAttrMatches(const IDNUM attrID, IDList &ownerIDs, IDList &matches, MoaError *err);

private:
	DBCB_ID			*mIDTable;		// the table of all IDs
	DBCB_AttrList	*mAttrList;		// list of defined attributes

	DBCB_Attributes	*mAttributes;	// table of attributes for objects.
									// There's only a single table of attributes, so the
									// "ownerid" needs to be unique over *all* types of objects
	DBCB_RawData	*mRawData;		// table of raw data for objects.
									// As with "attributes", there is only a single table for
									// *all* types of objects.

	unsigned long	mDeclareAttrLevel;	// userlevel required to user DeclareAttribute()
};

#endif // __ODBAdmin__
