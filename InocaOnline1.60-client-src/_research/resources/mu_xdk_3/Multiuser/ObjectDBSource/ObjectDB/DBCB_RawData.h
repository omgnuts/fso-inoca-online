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
// DBCB_RawData.h: interface for the DBCB_RawData class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCB_RawData__
#define __DBCB_RawData__

#include "DBCBTable.h"

class DBCB_RawData : public DBCBTable  
{
	public:
		DBCB_RawData(SvrObject *, DBGeneric *);
		virtual ~DBCB_RawData();

		virtual void	MakeTagInfo( Tag4info & outInfo );

		void Create(SvrObject *);
		void Open(SvrObject *);

		void GetData(SvrObjectPtr, const IDNUM, DBData &);
		void GetData(SvrObjectPtr, const IDNUM, DBData &, MoaError *err);

		void CreateData(SvrObjectPtr, const IDNUM, const char *, const unsigned int, MoaError *);

		void DeleteData(SvrObjectPtr, const IDNUM, MoaError *err);

	protected:

		virtual void	ZapIndexField( void );

	private:
		
		int	mDataPackPeriod;		// number of deletions between packs
		int mPackCountdown;			// deletions left before next pack
};

#endif // __DBCB_RawData__