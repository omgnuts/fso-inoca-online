// OSystem.cpp: object that receives server messages targeted
// for the "System" object.  Since the system object doesn't have
// any methods of its own, this is really just a container class
// for other server objects.
//
// Correction: The "System" object has a "Logon" method, but it
// is indicated through the subject...
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "OSystem.h"
#include "ODBApplication.h"
#include "ODBAdmin.h"
#include "ODBUser.h"
#include "ODBPlayer.h"
#include "ODBAppData.h"


static MoaError Logon(SvrObject *recipient, SvrMessage &msgParams)
{
	msgParams.recipientID = "System.DBUser.Logon";
	// System is the root, so we don't need to locate it.
	return recipient->dispatch(msgParams.recipientID, msgParams);
}


static SvrMethod methodList[] =
{
	{ "Logon", &Logon },
};


OSystem::OSystem() 
{
	setName("System");
	setMethods(methodList, sizeof(methodList)/sizeof(SvrMethod));

	// Build the command heirarchy.
	// The order that these objects are created in is mandatory.
	// Later objects depend on earlier ones for their initialize()
	// routine, which is called in SvrObject::setDBConnection().
	IMMEMTAG( "OSystem::OSystem - addChild( new ODBAdmin )" );
	addChild( new ODBAdmin() );

	IMMEMTAG( "OSystem::OSystem - addChild( new ODBUser )" );
	addChild( new ODBUser() );
	
	IMMEMTAG( "OSystem::OSystem - addChild( new ODBApplication )" );
	addChild( new ODBApplication() );
	
	IMMEMTAG( "OSystem::OSystem - addChild( new ODBPlayer )" );
	addChild( new ODBPlayer() );
	
	IMMEMTAG( "OSystem::OSystem - addChild( new ODBAppData )" );
	addChild( new ODBAppData() );
}

void OSystem::initialize() { }