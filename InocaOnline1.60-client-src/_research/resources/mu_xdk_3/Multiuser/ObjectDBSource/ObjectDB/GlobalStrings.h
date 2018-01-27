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
//////////////////////////////////////////////////////////////////////
// GlobalStrings.h: Globally available strings
//////////////////////////////////////////////////////////////////////

#ifndef __GlobalStrings__
#define __GlobalStrings__

#include "BString.h"

extern	BString		gStrODBAuthenErr;	// "* An invalid option was provided to the Authentication configuration command for the DatabaseObjects xtra."
extern	BString		gStrODBAdminErr;	// "* An error was encountered while creating the 'Admin' account for the DatabaseObjects xtra."
extern	BString		gStrODBOpenErr;		// "* Error while opening DatabaseObjects database."
extern	BString		gStrODBAccessErr;	// "* Error accessing DatabaseObjects database."
extern	BString		gStrODBLockErr;		// "* Error while locking DatabaseObjects database."
extern	BString		gStrODBUnlockErr;	// "* Error while unlocking DatabaseObjects database."
extern	BString		gStrODBBadWrite;	// "* Error while writing data to DatabaseObjects database."
extern	BString		gStrODBDBError;		// "* Error during DatabaseObjects database operation."
extern	BString		gStrODBInternalErr;	// "* An internal error occured in the DatabaseObjects xtra."
extern	BString		gStrODBTooLongAtr;	// "* Attribute name is too long for the DatabaseObjects xtra."
extern	BString		gStrODBCreateErr;	// "* Error in DatabaseObjects configuration command 'create_user'."
extern	BString		gStrODBException;	// "    Exception in DatabaseObjects xtra from file %s, line %d\n"
extern	BString		gStrODBLoaded;		// "\n* DatabaseObjects xtra has been loaded.\n"


void	InitGlobalStrings();
void	LoadGlobalStrings( XtraResourceCookie resCookie );
void	FreeGlobalStrings();

#endif // __GlobalStrings__