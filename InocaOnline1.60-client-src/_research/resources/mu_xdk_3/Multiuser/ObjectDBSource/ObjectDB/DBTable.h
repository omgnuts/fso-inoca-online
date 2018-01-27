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
// DBTable.h: the baseic table interface.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBTable__
#define __DBTable__

#include "SvrObject.h"

class DBTable  
{
public:
	DBTable();
	virtual ~DBTable();
	void setTablename(const char *table)
	{
		// the tablename will either come from a #define or the Options
		// object, so we don't need a local copy of the string...
		mTablename = table;
	}
	const char *getTablename() const { return mTablename; }

	virtual void Open(SvrObject *) = 0;
	virtual void Create(SvrObject *) = 0;

private:

	const char *mTablename;

};

#endif // __DBTable__