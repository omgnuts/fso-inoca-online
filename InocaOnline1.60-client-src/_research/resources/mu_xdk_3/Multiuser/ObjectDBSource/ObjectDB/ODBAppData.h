// ODBAppData.h: interface for the ODBAppData class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __ODBAppData__
#define __ODBAppData__

#include "SvrObject.h"
#include "ODBAdmin.h"
#include "ODBUser.h"
#include "ODBApplication.h"
#include "DBCB_AppData.h"
#include "ParameterList.h"

class ODBAppData : public SvrObject  
{
public:
	ODBAppData();
	virtual ~ODBAppData();

	virtual void initialize();

	MoaError Create(PISWServerUser sender, const char *appname, ParameterList &args);
	MoaError Delete(PISWServerUser sender, const char *appname, ParameterList &args);
	MoaError Get(SvrContent &msgReturn, PISWServerUser sender, const char *appname, ParameterList &args);
	void getMatches(const char *appname, ParameterList &args, IDList &matches, MoaError *err);
	void deleteAppData(const IDNUM appID, MoaError *err);

private:
	ODBAdmin		*mDBAdmin;			// for quick access to ID values
	ODBApplication	*mDBApp;

	DBCB_AppData		*mAppDataTable;	// table of AppData objects

	int				mCreateLevel;	// the userlevel required for DBUser.Create
	int				mGetLevel;
	int				mDeleteLevel;

};

#endif // __ODBApplication__