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
// GlobalStrings.cpp: Globally available strings
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "GlobalStrings.h"
#include "MessageMap.h"
#include "SrvExtension.h"


BString		gStrODBAuthenErr;	// "* An invalid option was provided to the Authentication configuration command for the DatabaseObjects xtra."
BString		gStrODBAdminErr;	// "* An error was encountered while creating the 'Admin' account for the DatabaseObjects xtra."
BString		gStrODBOpenErr;		// "* Error while opening DatabaseObjects database."
BString		gStrODBAccessErr;	// "* Error accessing DatabaseObjects database."
BString		gStrODBLockErr;		// "* Error while locking DatabaseObjects database."
BString		gStrODBUnlockErr;	// "* Error while unlocking DatabaseObjects database."
BString		gStrODBBadWrite;	// "* Error while writing data to DatabaseObjects database."
BString		gStrODBDBError;		// "* Error during DatabaseObjects database operation."
BString		gStrODBInternalErr;	// "* An internal error occured in the DatabaseObjects xtra."
BString		gStrODBTooLongAtr;	// "* Attribute name is too long for the DatabaseObjects xtra."
BString		gStrODBCreateErr;	// "* Error in DatabaseObjects configuration command 'create_user'."
BString		gStrODBException;	// "    Exception in DatabaseObjects xtra from file %s, line %d\n"
BString		gStrODBLoaded;		// "\n* DatabaseObjects xtra has been loaded.\n"


// Called at startup to load all the strings
void	InitGlobalStrings()
{
	gStrODBAuthenErr.InitFromNull();
	gStrODBAdminErr.InitFromNull();
	gStrODBOpenErr.InitFromNull();
	gStrODBAccessErr.InitFromNull();
	gStrODBLockErr.InitFromNull();
	gStrODBUnlockErr.InitFromNull();
	gStrODBBadWrite.InitFromNull();
	gStrODBDBError.InitFromNull();
	gStrODBInternalErr.InitFromNull();
	gStrODBTooLongAtr.InitFromNull();
	gStrODBCreateErr.InitFromNull();
	gStrODBException.InitFromNull();
	gStrODBLoaded.InitFromNull();
}


// Load strings from resources
void	LoadGlobalStrings( XtraResourceCookie resCookie )
{
	if ( gStrODBAuthenErr.Length() == 0 ) 
	{
		MsgPool stringPool;
		stringPool.Initialize( resCookie );

		long msgError = stringPool.GetClassString( CSrvXtn, kMsgODBAuthenErr, gStrODBAuthenErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBAdminErr, gStrODBAdminErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBOpenErr, gStrODBOpenErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBAccessErr, gStrODBAccessErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBLockErr, gStrODBLockErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBUnlockErr, gStrODBUnlockErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBBadWrite, gStrODBBadWrite );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBDBError, gStrODBDBError );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBInternalErr, gStrODBInternalErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBTooLongAtr, gStrODBTooLongAtr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBCreateErr, gStrODBCreateErr );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBException, gStrODBException );
		AssertNull_( msgError );

		msgError = stringPool.GetClassString( CSrvXtn, kMsgODBLoaded, gStrODBLoaded );
		AssertNull_( msgError );
	}
}



// Called at shutdown to free the strings.
void	FreeGlobalStrings()
{
	gStrODBAuthenErr.AllocateEnoughStringSpace(0);
	gStrODBAdminErr.AllocateEnoughStringSpace(0);
	gStrODBOpenErr.AllocateEnoughStringSpace(0);
	gStrODBAccessErr.AllocateEnoughStringSpace(0);
	gStrODBLockErr.AllocateEnoughStringSpace(0);
	gStrODBUnlockErr.AllocateEnoughStringSpace(0);
	gStrODBBadWrite.AllocateEnoughStringSpace(0);
	gStrODBDBError.AllocateEnoughStringSpace(0);
	gStrODBInternalErr.AllocateEnoughStringSpace(0);
	gStrODBTooLongAtr.AllocateEnoughStringSpace(0);
	gStrODBCreateErr.AllocateEnoughStringSpace(0);
	gStrODBException.AllocateEnoughStringSpace(0);
	gStrODBLoaded.AllocateEnoughStringSpace(0);
}

