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
// Exception.h: interface for the Exception class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __Exception__
#define __Exception__

#include "moatypes.h"
#include "MarsErrors.h"

class Exception  
{
public:
	Exception(const char *msg, const MoaError err, const char *file, const int line);	// only use static strings!!
	virtual ~Exception();

	const char *getMessage() const { return mMessage; }
	const MoaError getError() const { return mError; }
	const char *getFile() const { return mFile; }
	const int getLine() const { return mLine; }
private:
	const char	*mMessage;			// not locally allocated
	MoaError	mError;				// error to send back
	const char  *mFile;				// not locally allocated
	int			mLine;
};

#define Exception(msg, err)		Exception(msg, err, __FILE__, __LINE__)

#endif // __Exception__