// Time.cpp: implementation of the Time class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "UpdateTime.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

UpdateTime::UpdateTime()
{
}

UpdateTime::~UpdateTime()
{
}

void UpdateTime::setToNow(SvrObject *svrObj)
{
	mContent.cleanup();			// get rid of previous settings

	mTime[0] = '\0';
	svrObj->GetSetting( "currentTime", mTime, sizeof(mTime) );

	// and turn it into a Lingo-compatible stream...
	mContent.CreateContent(svrObj);
	mContent.WriteValue(kMoaMmValueType_String, 0, mTime);
}