// UpdateTime.h -- a dummy class for allocating memory for 
// retrieving the system time.
//
//////////////////////////////////////////////////////////////////////

#ifndef __UpdateTime__
#define __UpdateTime__

#include "SvrObject.h"
#include "SvrContent.h"

class UpdateTime  
{
public:
	UpdateTime();
	~UpdateTime();

	void setToNow(SvrObject *);
	SvrContent *getContent() { return &mContent; }

private:
	char				mTime[128];
	SvrContent			mContent;
};

#endif // __UpdateTime__