// ParameterList.h: interface for the ParameterList class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __ParameterList__
#define __ParameterList__

#include	"SWServerXtra.h"
#include "SvrContent.h"
#include "BString.h"
#include <vector.h>

typedef vector< long >		AttrValueOffsetList;


class ParameterList  
{
public:
	ParameterList(PISWServerContent msg);
	ParameterList(ParameterList &parent);

	ParameterList();
	virtual ~ParameterList();

	long setPosition(const char *attrName);
	long setPosition(const char *attrName, MoaError *err);

	void parse(SvrContent & msg);
	void parse();

	void getString(const char *attrName, BString *outVal);
	void getString(const char *attrName, BString *outVal, MoaError *err);
	void getData(const char *attrName, char **outVal, long *outSize);
	void getParamList(const char *attrName, ParameterList *outVal);
	void getParamList(const char *attrName, ParameterList *outVal, MoaError *err);
	long getInteger(const char *attrName);
	long getInteger(const char *attrName, MoaError *err);
	double getNumber(const char *attrName);
	double getNumber(const char *attrName, MoaError *err);

	// helper functions for reading messages:
	void readParameters(
					SvrContent &msg, 
					BStringList * outAttrNames,
					AttrValueOffsetList * outAttrValueOffsets
					);
	static long readNumber(PISWServerContent msgContents);
	static void readString(
					SvrContent &msg, 
					BString & outAttrName
					);
	void scanParameters( 
					SvrContent &msg,
					BStringList * validParams,
					BStringList * outAttrNames,
					AttrValueOffsetList * outAttrValueOffsets
					);

	int	attrSize() { return mAttrs.size(); }
	int valueSize() { return mValues.size(); }
	const char *getAttrName(int indx) { return (char *)mAttrs[indx]; }
	void addAttr(const char *val);

	PISWServerContent getMsgContents() { return mMsg.getMsgContents(); }

private:
	SvrContent					mMsg;
	AttrValueOffsetList			mValues;
	BStringList					mAttrs;
};

#endif // __ParameterList__