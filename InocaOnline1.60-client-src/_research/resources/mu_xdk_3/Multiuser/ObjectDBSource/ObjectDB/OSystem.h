// OSystem.h: the "System" object -- intended to receive server
// messages with a recipientID of "System.*".  There's no real
// reason to have a "System" object which is distinct from
// the SvrObject base class, since there are no operations
// performed directly on this object by Lingo.
//
//////////////////////////////////////////////////////////////////////

#ifndef __OSystem__
#define __OSystem__

#include "SvrObject.h"

class OSystem : public SvrObject  
{
public:
	OSystem();
	virtual ~OSystem() { }

	virtual void initialize();
};

#endif // __OSystem__