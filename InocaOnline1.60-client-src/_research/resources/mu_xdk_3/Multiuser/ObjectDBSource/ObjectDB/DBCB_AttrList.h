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
// DBCB_AttrList.h: defines the database functionality for the
// AttributeList, which is a list of all available attributes for
// objects, and an ID number representing each attribute name.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_AttrList__
#define __DBCB_AttrList__

#include "DBCBTable.h"

class DBCB_AttrList : public DBCBTable  
{
	public:
		DBCB_AttrList(SvrObject *, DBGeneric *);
		virtual ~DBCB_AttrList();

		void Create( SvrObject * );

		virtual	void	UpdateFileStructure( void );
		virtual void	MakeTagInfo( Tag4info & outInfo );

		IDNUM	GetAttr( SvrObjectPtr, const char *, MoaError *err );
		void	GetAttrName( SvrObjectPtr, const IDNUM, BString &outName, MoaError *err );

		void	CreateAttr( SvrObjectPtr, const IDNUM, const char *, MoaError * err );

	protected:

		virtual void	ZapIndexField( void );
};

#endif // __DBCB_AttrList__