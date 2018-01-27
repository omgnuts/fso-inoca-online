/***************************************************************************
**
* Copyright © 1994-2001 Macromedia, Inc. All Rights Reserved
*
* THE CODE IS PROVIDED TO YOU ON AN "AS IS" BASIS AND "WITH ALL FAULTS,"
WITHOUT ANY TECHNICAL SUPPORT OR WARRANTY OF ANY KIND FROM MACROMEDIA. YOU
ASSUME ALL RISKS THAT THE CODE IS SUITABLE OR ACCURATE FOR YOUR NEEDS AND
YOUR USE OF THE CODE IS AT YOUR OWN DISCRETION AND RISK. MACROMEDIA
DISCLAIMS ALL EXPRESS AND IMPLIED WARRANTIES FOR CODE INCLUDING, WITHOUT
LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE. ALSO, THERE IS NO WARRANTY OF NON-INFRINGEMENT, TITLE OR QUIET
ENJOYMENT.

YOUR USE OF THIS CODE IS SUBJECT TO THE TERMS, CONDITIONS AND RESTRICTIONS
SET FORTH IN THE CORRESPONDING LICENSE AGREEMENT BETWEEN YOU AND
MACROMEDIA.

****************************************************************************/
// DBCB_Player.h: interface for the DBCB_Player class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_Player__
#define __DBCB_Player__

#include "DBCBTable.h"
#include "SvrObject.h"
#include "DBGeneric.h"

class DBCB_Player : public DBCBTable  
{
	public:
		DBCB_Player(SvrObject *, DBGeneric *);
		virtual ~DBCB_Player();

		void Create(SvrObject *);
		virtual	void	UpdateFileStructure( void );
		virtual void	MakeTagInfo( Tag4info & outInfo );

		IDNUM	getPlayer(SvrObjectPtr, const IDNUM userid, const IDNUM appid, MoaError *err);

		void createPlayer(SvrObjectPtr, const IDNUM playerID, const IDNUM user, const IDNUM app, MoaError *err);
		void deletePlayer(SvrObjectPtr, const IDNUM playerID, MoaError *err);

		void FindPlayersWithUserID( SvrObject *svrObj, const IDNUM userID, IDList &matches, MoaError *err);
		void FindPlayersWithAppID( SvrObject *svrObj, const IDNUM appID, IDList &matches, MoaError *err);

	protected:

		virtual void	ZapIndexField( void );
};

#endif // __DBCB_Player__