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
// DBCB_User.h: interface for the DBCB_User class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_User__
#define __DBCB_User__

#include "DBCBTable.h"

class DBCB_User : public DBCBTable  
{
	public:

		DBCB_User(SvrObject *, DBGeneric *);
		virtual ~DBCB_User();

		void Create(SvrObject *);

		virtual	void	UpdateFileStructure( void );
		virtual void	MakeTagInfo( Tag4info & outInfo );

		IDNUM	getID(SvrObjectPtr, const char *username, MoaError *err);

		void	GetPassword( BString & outPassWord );
		void	GetPassword( BString & outPassWord, const IDNUM id, MoaError * err );
		void	SetPassword( const BString & inPassWord, const IDNUM id, MoaError * err );

		void	createUser(SvrObjectPtr, const IDNUM, const char *, const char *, MoaError *);
		void	deleteUser(SvrObjectPtr, const char *, MoaError *);

		void	GetUserNameList( long startRecNum, long endRecNum, BStringList & outStringList );

	protected:

		virtual void	ZapIndexField( void );
};

#endif // __DBCB_User__