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
// DBCB_ID.h: interface for the DBCB_ID class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_ID__
#define __DBCB_ID__

#include "DBCBTable.h"
#include "SvrObject.h"

class DBCB_ID : public DBCBTable  
{
	public:
		DBCB_ID(SvrObject *, DBGeneric *);
		virtual ~DBCB_ID();

		void Create( SvrObject * );

		virtual	void	UpdateFileStructure( void );
		virtual void	MakeTagInfo( Tag4info & outInfo );

		IDNUM	getID( SvrObjectPtr, const char *, MoaError * );

		IDNUM	GetNewID( SvrObjectPtr, const char *, MoaError * );

		void	CreateID( SvrObjectPtr, const char *, IDNUM, MoaError * );

	protected:

		virtual void	ZapIndexField( void );

};

#endif // __DBCB_ID__