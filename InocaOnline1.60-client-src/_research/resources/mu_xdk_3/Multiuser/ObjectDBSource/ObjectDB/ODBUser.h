// ODBUser.h: object to receive messages to "System.DBUser.*"
//
//////////////////////////////////////////////////////////////////////

#ifndef __ODBUser__
#define __ODBUser__

#include "SvrObject.h"
#include "ODBAdmin.h"
#include "DBCB_User.h"
#include "ParameterList.h"
#include "SvrContent.h"

class ODBUser : public SvrObject  
{
public:
	ODBUser();
	virtual ~ODBUser();

	virtual	void initialize();					// insures that DBs exist and are init'd

	MoaError Logon(SvrContent &, PISWServerUser sender, ParameterList &args);

	MoaError Create(PISWServerUser sender, const char *username, const char *password, long userlevel);
	MoaError Delete(PISWServerUser sender, const char *username);

	MoaError GetUserCount( SvrContent &, PISWServerUser sender );
	MoaError GetUserNames( SvrContent &, PISWServerUser sender, long startRecNum, long endRecNum );

	MoaError GetAttributeNames(SvrContent &, PISWServerUser sender, ParameterList &users);

	MoaError SetAttribute(SvrContent &msgReturn, PISWServerUser sender, const char *user, ParameterList &attribs, BString & lastUpdateTime);
	MoaError GetAttribute(SvrContent &, PISWServerUser sender, ParameterList &users, ParameterList &attribs);
	MoaError DeleteAttribute(SvrContent &msgReturn, PISWServerUser sender, ParameterList &users, ParameterList &attribs);

	unsigned long	GetUserLevel( const char * username, MoaError *err );
	void			SetUserLevel( IDNUM userID, long level, MoaError *err );

	IDNUM getID(const char *username, MoaError *err);

	int getAuthScheme() const { return mAuthScheme; }

	virtual bool	HaveCustomAttribute( const char * attrName );
	virtual void	SetCustomAttribute( const IDNUM ownerID, const char * attrName, ParameterList & attribs, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err) ;
	virtual void	GetCustomAttribute( const IDNUM ownerID, const char * attrName, SvrContent * dstContent, MoaError * err );

private:
	ODBAdmin		*mDBAdmin;			// for quick access to ID values

	DBCB_User		*mUserTable;		// table of users

	int				mAuthScheme;	// defines which auth scheme is being used
#define AUTH_NONE		0			// 0 - none
#define AUTH_USER_REQ	1			// 1 - user_record_required
#define AUTH_USER_OPT	2			// 2 - user_record_optional

	int				mCreateLevel;	// the userlevel required for DBUser.Create
	int				mSetAttrLevel;
	int				mGetAttrLevel;
	int				mGetAttrNamesLevel;
	int				mDeleteAttrLevel;
	int				mDeleteLevel;
	int				mGetPasswordLevel;	// the userlevel required for DBUser.GetAttribute gettig #password
	int				mSetPasswordLevel;	// the userlevel required for DBUser.SetAttribute setting #password
	int				mGetUserCountLevel;	// the userlevel required for System.DBAdmin.GetUserCount
	int				mGetUserNamesLevel;	// the userlevel required for System.DBAdmin.GetUserNames

	unsigned long	mDefUserLevel;	// the default userlevel in authScheme=2

};

#endif // __ODBUser__