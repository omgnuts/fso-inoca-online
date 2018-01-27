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
// DBCodeBase.h: interface for the DBCodeBase class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCodeBase__
#define __DBCodeBase__

// Set Codebase flags
#if defined( DEBUG )
#define	E4DEBUG
#endif	// DEBUG

#include "d4all.hpp"


#include "DBGeneric.h"
#include "SvrObject.h"

class DBCodeBase : public DBGeneric  
{
public:
	DBCodeBase(PISWServer);
	virtual ~DBCodeBase();

	void Create(SvrObject *pSvrObj, const char *filename,
						  Data4 &data, Field4info &fields, Tag4info &tags);

	void Open(SvrObject *svrObj, const char *filename, Data4 &data);

	static Code4	*getCode4() { return sCode4; }

private:
	static Code4	*sCode4;		// Pointer to Codebase object
	static long		sCode4Usage;	// Counter for usage
};


// maximum length of field types
#define MAX_STR_LEN		240
#define MAX_NUM_LEN		19

#endif // __DBCodeBase__
