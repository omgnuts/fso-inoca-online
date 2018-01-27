// ODBPlayer.h: object to handle server messages directed
// to the "System.DBPlayer" object.
//
//////////////////////////////////////////////////////////////////////

#ifndef __ODBPlayer__
#define __ODBPlayer__

#include "SvrObject.h"
#include "ODBAdmin.h"
#include "ODBUser.h"
#include "ODBApplication.h"
#include "DBCB_Player.h"
#include "ParameterList.h"

class ODBPlayer : public SvrObject  
{
	public:
		ODBPlayer();
		virtual ~ODBPlayer();

		virtual void initialize();

		void Create(const char *user, const char *appname, MoaError *err);
		MoaError GetAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *appname, ParameterList &attribs);
		MoaError SetAttribute(SvrContent &msgReturn, PISWServerUser sender, const char *user, const char *app, ParameterList &attribs, BString &lastUpdateTime);
		MoaError GetAttributeNames(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *app);
		MoaError DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, const char *app, ParameterList &attribs);

		void DeletePlayersWithUserID( const IDNUM userID, MoaError *err);
		void DeletePlayersWithAppID( const IDNUM appID, MoaError *err);

	private:

		long			DeleteAllMatches( IDList & matches );

		ODBAdmin		*mDBAdmin;			// for quick access to ID values
		ODBUser			*mDBUser;
		ODBApplication	*mDBApp;

		DBCB_Player		*mPlayerTable;			// table of apps

		// local copies of userlevels required to perform actions
		int				mSetAttrLevel;
		int				mGetAttrLevel;
		int				mGetAttrNamesLevel;
		int				mDeleteAttrLevel;
};

#endif // __ODBApplication__