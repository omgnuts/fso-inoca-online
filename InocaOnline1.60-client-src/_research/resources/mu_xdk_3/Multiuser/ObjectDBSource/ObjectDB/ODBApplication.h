// ODBApplication.h: object to handle server messages directed
// to the "System.DBApplication" object.
//
//////////////////////////////////////////////////////////////////////

#ifndef __ODBApplication__
#define __ODBApplication__

#include "SvrObject.h"
#include "ODBAdmin.h"
#include "ODBUser.h"
#include "DBCB_App.h"
#include "ParameterList.h"

class ODBApplication : public SvrObject  
{
public:
	ODBApplication();
	virtual ~ODBApplication();

	virtual void initialize();

	MoaError Create(PISWServerUser sender, const char *appname, const char *description);
	MoaError Delete(PISWServerUser sender, const char *appname);
	MoaError GetAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps, ParameterList &attribs);
	MoaError SetAttribute(SvrContent &msgReturn, PISWServerUser sender, const char *app, ParameterList &attribs, BString &lastUpdateTime);
	MoaError GetAttributeNames(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps);
	MoaError DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &apps, ParameterList &attribs);

	IDNUM getID(const char *appname, MoaError *err);

private:
	ODBAdmin		*mDBAdmin;			// for quick access to ID values

	DBCB_App		*mAppTable;			// table of apps

	int				mCreateLevel;		// the userlevel required for DBUser.Create
	int				mSetAttrLevel;
	int				mGetAttrLevel;
	int				mGetAttrNamesLevel;
	int				mDeleteAttrLevel;
	int				mDeleteLevel;


};

#endif // __ODBApplication__