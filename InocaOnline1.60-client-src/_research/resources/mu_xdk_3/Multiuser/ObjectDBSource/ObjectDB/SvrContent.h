// SvrContent.h: interface for the SvrContent class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __SvrContent__
#define __SvrContent__

#include "mmtypes.h"
#include	"SWServerXtra.h"
#include "BString.h"
#include <vector.h>


class SvrObject;
class SvrContent;
typedef SvrContent	*SvrContentPtr;
typedef vector<SvrContentPtr>	SvrContentList;

class SvrContent  
{
public:
	SvrContent();
	virtual ~SvrContent();
	void cleanup();

	void CreateContent(SvrObject *);
	void SetContent(PISWServerContent);
	void Reset();				// resets message buffer
	void ResetPosition();
	PISWServerContent	GetContent() { return mMsg; }

	char *getRawData();
	MoaLong getRawSize();

	void WriteValue(MoaLong valueType, MoaLong valueSize, PMoaVoid pValueData);
	void GetValueInfo(MoaLong *valueType, MoaLong *valueSize, PMoaVoid pValueData);
    void SkipValue();
	void SkipListStart();
	long GetPosition();
	void SetPosition(long pos);
	char *GetBufferPointer();

	long readInteger();
	double readDouble();
	double readNumber();
	void readString(BString & outAttrName);

	PISWServerContent	getMsgContents() { return mMsg; }

	void WriteErrorCode(MoaError errorCode);

private:
	PISWServerContent	mMsg;
	int					mOwnContent;
	long				mStartPos;

};

#endif // __SvrContent__