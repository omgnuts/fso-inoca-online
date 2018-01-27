// SvrContent.cpp: implementation of the SvrContent class.
//
//////////////////////////////////////////////////////////////////////
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif

#include "SvrContent.h"
#include "DebugException.h"
#include "SvrObject.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

SvrContent::SvrContent()
{
	mMsg = NULL;
	mOwnContent = 0;
	mStartPos = 0;
}

SvrContent::~SvrContent()
{
	cleanup();
}

void SvrContent::cleanup()
{
	if (mOwnContent && (mMsg != NULL))
	{
		mMsg->Reset();
		mMsg->Release();
	}
	mMsg = NULL;
}

void SvrContent::Reset()
{
	if (mMsg != NULL)
		mMsg->Reset();
}

void SvrContent::CreateContent(SvrObject *svrObj)
{
	cleanup();
	mMsg = svrObj->CreateContent();
	mOwnContent = 1;
	mStartPos = GetPosition();
}

void SvrContent::SetContent(PISWServerContent msg)
{
	cleanup();
	mMsg = msg;
	mOwnContent = 0;
	mStartPos = GetPosition();
}

void SvrContent::ResetPosition()
{
	SetPosition(mStartPos);
}

char *SvrContent::getRawData()
{
	if (mMsg == NULL)
		throw DebugException("No data object.", COMMERR_SERV_INTERNAL_ERROR);
	return (char *)mMsg->GetBufferPointer();
}

MoaLong SvrContent::getRawSize()
{
	if (mMsg == NULL)
		throw DebugException("No data object.", COMMERR_SERV_INTERNAL_ERROR);
	MoaLong		size;
	MoaError	err = mMsg->GetValueInfo(NULL, NULL, &size);
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while trying to size data object.",
					err);
	return size;
}

void SvrContent::WriteValue(MoaLong valueType, MoaLong valueSize, PMoaVoid pValueData)
{
	MoaError err = mMsg->WriteValue(valueType, valueSize, pValueData);
	if (err != kMoaErr_NoErr)
		throw DebugException("Unable to write value to data object.", err);
}

void SvrContent::GetValueInfo(MoaLong *valueType, MoaLong *valueSize, PMoaVoid pValueData)
{
	MoaError err = mMsg->GetValueInfo(valueType, valueSize, (long *)pValueData);
	if (err != kMoaErr_NoErr)
		throw DebugException("Unable to determine type of data object.", err);
}

void SvrContent::readString(BString & outAttrName)
{
	long	valueType, valueSize;
	MoaError err = mMsg->GetValueInfo( &valueType, &valueSize, NULL );
	if (err != kMoaErr_NoErr)
		throw DebugException("Error decoding value", err);
	if ( (valueType != kMoaMmValueType_String) && (valueType != kMoaMmValueType_Symbol) )
		throw DebugException("Bad value (Expecting string or value).", COMMERR_BAD_PARAMETER);
	
	// Read the string or symbol from the contents
	outAttrName = "";
	outAttrName.AllocateEnoughStringSpace( valueSize + 1 );
	err = mMsg->ReadValue( (char *) outAttrName );
	if ( err != kMoaErr_NoErr )
		throw DebugException("Error reading string.", err);
	if ( !outAttrName.IsEmpty() && (valueType == kMoaMmValueType_Symbol) )
	{
		// symbols always have a leading '#' which we can strip off
		if ( outAttrName[ 0L ] == '#' )
			outAttrName.Delete( 0, 1 );
	} 
}

long SvrContent::readInteger()
{
	long	valueType, valueSize;
	MoaError err = mMsg->GetValueInfo( &valueType, &valueSize, NULL );
	if (err != kMoaErr_NoErr)
		throw DebugException("Error decoding parameter", err);
	if ( valueType != kMoaMmValueType_Integer)
		throw DebugException("Bad parameter (Expecting integer).", COMMERR_BAD_PARAMETER);
	long	actualValue;
	if ( valueSize != sizeof(actualValue) )
		throw DebugException("There is some misconception here about typing.",
					COMMERR_SERV_INTERNAL_ERROR);
	err = mMsg->ReadValue( &actualValue );
	if ( err != kMoaErr_NoErr )
		throw DebugException("Error reading integer.", err);
	return actualValue;
}

double SvrContent::readDouble()
{
	long	valueType, valueSize;
	MoaError err = mMsg->GetValueInfo( &valueType, &valueSize, NULL );
	if (err != kMoaErr_NoErr)
		throw DebugException("Error decoding parameter", err);
	if ( valueType != kMoaMmValueType_Float)
		throw DebugException("Bad parameter (Expecting float).", COMMERR_BAD_PARAMETER);
	double	actualValue;
	if ( valueSize != sizeof(actualValue) )
		throw DebugException("There is some misconception here about typing.",
					COMMERR_SERV_INTERNAL_ERROR);
	err = mMsg->ReadValue( &actualValue );
	if ( err != kMoaErr_NoErr )
		throw DebugException("Error reading float.", err);
	return actualValue;
}

double SvrContent::readNumber()
{
	long	valueType;
	MoaError err = mMsg->GetValueInfo( &valueType, NULL, NULL );
	if (err != kMoaErr_NoErr)
		throw DebugException("Error decoding parameter", err);
	if (valueType == kMoaMmValueType_Float)
		return readDouble();
	if (valueType == kMoaMmValueType_Integer)
		return readInteger();
	throw DebugException("Bad parameter (expecting a number).",
				COMMERR_BAD_PARAMETER);
}

void SvrContent::SkipValue()
{
	MoaError err = mMsg->SkipValue();
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while skipping value.", err);
}

void SvrContent::SkipListStart()
{
	MoaError err = mMsg->SkipListStart();
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while skipping list start.", err);
}

long SvrContent::GetPosition()
{
	long	pos;
	MoaError err = mMsg->GetPosition(&pos);
	if (err != kMoaErr_NoErr)
		throw DebugException("Error while getting msg position.", err);
	return pos;
}

void SvrContent::SetPosition(long pos)
{
	MoaError err = mMsg->SetPosition(pos);
	if (err != kMoaErr_NoErr)
		throw DebugException("Error setting position.", err);
}

char *SvrContent::GetBufferPointer()
{
	return (char *) mMsg->GetBufferPointer();
}

void SvrContent::WriteErrorCode(MoaError errorCode)
{
	WriteValue( kMoaMmValueType_Symbol, 0, "errorCode");
	WriteValue( kMoaMmValueType_Integer, 0, &errorCode);
}
