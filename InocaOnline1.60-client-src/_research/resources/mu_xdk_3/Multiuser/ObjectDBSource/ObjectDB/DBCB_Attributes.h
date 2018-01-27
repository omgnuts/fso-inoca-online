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

// DBCB_Attributes.h: interface to data holding Attribute information.
// There is only a single table holding attributes for all objects
// (DBUser, DBApplication, etc).  Therefore, IDs used to refer to the
// owner should come from the "GlobalID" sequence defined in DBCB_ID's table.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_Attributes__
#define __DBCB_Attributes__

#include "DBCBTable.h"
#include "DBCB_RawData.h"

#include <vector.h>

// definitions of priviledges...
#define ATTR_VALUE_LEN		64
#define ADMIN_USERLEVEL		80
#define ATTR_WPRIVS_LEN		1
// bits defining properties of individual attributes
#define ATTR_WPRIVS_NONE	0
#define ATTR_WPRIVS_SYSTEM	1
	// the SYSTEM bit means that an attribute can only be
	// set/deleted by SYSTEM commands, unless the whole
	// object is being deleted.

							// make sure that ADMIN_PRIV in DBCB_Attributes.h
							// fits within this length!

class DBCB_Attributes : public DBCBTable  
{
	public:
		DBCB_Attributes(SvrObject *, DBGeneric *, DBCB_RawData *);
		virtual	~DBCB_Attributes();

		void	Create( SvrObject *);

		virtual	void	UpdateFileStructure( void );
		virtual void	MakeTagInfo( Tag4info & outInfo );

		void	setAttribute( SvrObject *, const IDNUM ownerID, const IDNUM attrID, const char *value, unsigned long size, unsigned long creatorPriv, unsigned long attrPriv, MoaError *err);
		void	getAttribute( SvrObject *, const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size);
		void	getAttribute( SvrObject *, const IDNUM ownerID, const IDNUM attrID, const char **value, unsigned long *size, MoaError *err);

		void	CreateAttribute( SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, unsigned long priv, MoaError *err);
		void	GetAttributeList( SvrObject *svrObj, const IDNUM ownerID, IDList &attrIDs, MoaError *err);
		void	deleteAttribute( SvrObject *svrObj, const IDNUM ownerID, const IDNUM attrID, const unsigned long priv, MoaError *err);
		void	getMatches( SvrObject *svrObj, const IDNUM attrID, IDList &ownerID, IDList &matches, MoaError *err);

	protected:
		
		virtual void	ZapIndexField( void );

		void	FindAttribute( SvrObject *svrObj, IDNUM ownerID, const IDNUM attrID, MoaError *err );

		DBCB_RawData		*mRawData;
};

#endif // __DBCB_Attributes__
