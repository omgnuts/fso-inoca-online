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
// DBCodeBase.cpp: implementation of the DBCodeBase class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "DebugException.h"
#include "DBCodeBase.h"
#include "Options.h"
#include "Localize.h"
#include "GlobalStrings.h"

#if defined( MACINTOSH )
#define LOCAL_CODE4 1
#else
#undef LOCAL_CODE4				// define if we should create the code4 object
#endif

Code4	* DBCodeBase::sCode4 = NULL;
long	  DBCodeBase::sCode4Usage = 0;


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

DBCodeBase::DBCodeBase(PISWServer server)
{
	if (sCode4 == NULL)
	{
#ifdef LOCAL_CODE4
		// create our own CodeBase Code4 object.
		IMMEMTAG( "DBCodeBase::DBCodeBase" );
		sCode4 = new Code4;
		code4unlockAutoSet( sCode4, LOCK4OFF );
		c4setLockEnforce( sCode4, 1 );
		c4setLockAttempts( sCode4, 10 );	// Number of retrys waiting for a lock.
		c4setAccessMode( sCode4, OPEN4DENY_NONE );	// Allow multiple usage
		c4setSingleOpen( sCode4, OPEN4DENY_NONE );
		c4setAutoOpen( sCode4, true );	// Automatically open index files.
		// sCode4->lockDelay = 100;		// 100ths of a second between retry.

		sCode4->errOff = 1;				// Turn off error messages, we deal with them.
		sCode4->compatibility = 30;		// FoxPro 3.0 compatibility

		sCode4->errDefaultUnique = e4unique;
#else
		// try to get it from the server...
		if (server != NULL)
		{
			MoaError err = server->GetSetting("code4", (char *)&sCode4, sizeof(sCode4));
			if (err != kMoaErr_NoErr)
				throw DebugException("Error getting database object.", err);
			if (sCode4 == NULL)
				throw DebugException("Database object not created by server.", COMMERR_SERV_INTERNAL_ERROR);
#if 1
			// Everything is supposed to work with e4unique, but
			// it turns out that deleted records still hang around
			// in the index, breaking this.  This should be turned
			// back on once garbage collection of deleted records
			// is supported.
			sCode4->errDefaultUnique = e4unique;
#endif
			// Bug #51585 -- multiple opens of the same file required
			// because a movie cfg file might use the same DB as
			// the regular multiuser.cfg
			sCode4->singleOpen = 0;
		}
		else
			throw DebugException("No server object??", COMMERR_SERV_INTERNAL_ERROR);
#endif
    }

	sCode4Usage++;
}

DBCodeBase::~DBCodeBase()
{
	sCode4Usage--;
	
	if (sCode4 != NULL)
	{	// Only clear sCode4 if there are no other instances using it
		if ( sCode4Usage <= 0 )
		{
			#ifdef LOCAL_CODE4
			// if we created our own Code4 object, then close down
			// everything and remove it.
			sCode4->closeAll();
			delete sCode4;
			#endif

			sCode4 = NULL;
		}
	}
}

void DBCodeBase::Create(SvrObject *svrObj, const char *filename,
						  Data4 &data, Field4info &fields, Tag4info &tags)
{
	if (checkDebug(DEBUG_DB))
	{
		svrObj->DisplayMessage("Creating database: ");
		svrObj->DisplayMessage(filename);
		svrObj->DisplayMessage("\n");
	}
	if (sCode4 == NULL)
		throw Exception( (char *) gStrODBAccessErr, COMMERR_SERV_INTERNAL_ERROR);

	int saveSafety = sCode4->safety;
	sCode4->safety = 1;				// don't allow overwrites of files
	int saveCreate = sCode4->errCreate;
	sCode4->errCreate = 0;
	int saveUnique = sCode4->errDefaultUnique;
	sCode4->errDefaultUnique = e4unique;
	try
	{
		int rc = data.create( *sCode4, filename, fields, tags );
		if ((rc != r4success) && (rc != r4noCreate))
		{
			// a different error than just that the file already existed...
			if (checkDebug(DEBUG_VERBOSEDB))
			{
				char msg[100];
				sprintf(msg, "DBCodeBase create() returned %d\n", rc);
				svrObj->DisplayMessage(msg);
			}
			throw Exception( (char *) gStrODBAccessErr, COMMERR_SERV_CANT_WRITE_DATABASE);
		}
		if ((rc == r4noCreate) && checkDebug(DEBUG_DB))
		{
			svrObj->DisplayMessage("Database already created.\n");
		}
	}
	catch (Exception e)
	{
		sCode4->safety = saveSafety;
		sCode4->errCreate = saveCreate;
		sCode4->errDefaultUnique = saveUnique;
		throw e;
	}
	catch (...)
	{
		sCode4->safety = saveSafety;
		sCode4->errCreate = saveCreate;
		sCode4->errDefaultUnique = saveUnique;
		throw Exception((char *) gStrODBAccessErr, COMMERR_SERV_CANT_WRITE_DATABASE);
	}
	sCode4->safety = saveSafety;
	sCode4->errCreate = saveCreate;
	sCode4->errDefaultUnique = saveUnique;
}

void DBCodeBase::Open(SvrObject *pSvrObj, const char *filename,
						  Data4 &data)
{
	if ( data.isValid() )
	{
		// undoubtably, the call to Create() must have succeeded!
		return;
	}

#ifdef DEBUG
	if ((pSvrObj->getOptions()->getDebugLevel() & DEBUG_DB) > 0)
	{
		pSvrObj->DisplayMessage("Opening database: ");
		pSvrObj->DisplayMessage(filename);
		pSvrObj->DisplayMessage("\n");
	}
#endif

	try
	{
		int rc = data.open( *sCode4, filename );
		if (rc != r4success)
		{
#ifdef DEBUG
			{
				char msg[100];
				sprintf(msg, "DBCodeBase open() returned %d\n", rc);
				DebugStr_(msg);
			}
#endif
			pSvrObj->DisplayMessage( "\n" );
			pSvrObj->DisplayMessage( gStrODBOpenErr );
			BString tempMsg( "\n    " );
			tempMsg += filename;
			tempMsg += "\n\n";
			pSvrObj->DisplayMessage( tempMsg );

			throw Exception((char *) gStrODBAccessErr, COMMERR_SERV_BAD_DATABASE);
		}
		if (!data.isValid())
			throw Exception((char *) gStrODBAccessErr, COMMERR_SERV_BAD_DATABASE);
	}
	catch (Exception e)
	{
		throw e;
	}
	catch (...)
	{
		throw Exception((char *) gStrODBAccessErr, COMMERR_SERV_CANT_WRITE_DATABASE);
	}
}

//++------------------------------------------------------------------------
// error4hook
//          Our Codebase error function, used to intercept error processing.
//++------------------------------------------------------------------------
void S4FUNCTION error4hook( CODE4 S4PTR * c4,
							int errCode,
							long errCode2,
							const char * /* desc1 */,
							const char * /* desc2 */,
							const char * /* desc3 */ )
{
	#ifdef DEBUG
	if (DBCodeBase::getCode4() != NULL)
	{
		const char * errorTet = DBCodeBase::getCode4()->errorText( errCode );
		Assert_( 0 );
	}
	#endif
}

