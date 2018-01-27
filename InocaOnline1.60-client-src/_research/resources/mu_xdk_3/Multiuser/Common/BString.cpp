/*************************************************************************
* Copyright © 1994-2001 Macromedia, Inc. All Rights Reserved
*
* THE CODE IS PROVIDED TO YOU ON AN "AS IS" BASIS AND "WITH ALL FAULTS,"
* WITHOUT ANY TECHNICAL SUPPORT OR WARRANTY OF ANY KIND FROM MACROMEDIA. YOU
* ASSUME ALL RISKS THAT THE CODE IS SUITABLE OR ACCURATE FOR YOUR NEEDS AND
* YOUR USE OF THE CODE IS AT YOUR OWN DISCRETION AND RISK. MACROMEDIA
* DISCLAIMS ALL EXPRESS AND IMPLIED WARRANTIES FOR CODE INCLUDING, WITHOUT
* LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
* PURPOSE. ALSO, THERE IS NO WARRANTY OF NON-INFRINGEMENT, TITLE OR QUIET
* ENJOYMENT.
*
* YOUR USE OF THIS CODE IS SUBJECT TO THE TERMS, CONDITIONS AND RESTRICTIONS
* SET FORTH IN THE CORRESPONDING LICENSE AGREEMENT BETWEEN YOU AND MACROMEDIA.
*
*   Filename:   BString.cpp
*
*	Purpose:  Platform neutral string class
*****************************************************************************/

#if defined( WINDOWS )
#include "CPrecompile.h"
#endif

// Define for all Xtra source code modules.
#ifndef IN_X_CODE
#define IN_X_CODE
#endif

#include 	"BString.h"

#if defined ( MACINTOSH )
#include <stdio.h>
#include <Resources.h>
#else
#include <mbstring.h>
#endif


#ifdef TARGET_PRECARBON
#define IdenticalText(aPtr, bPtr, aLen, bLen, itl2Handle) \
		 IUMagIDPString(aPtr, bPtr, aLen, bLen, itl2Handle)
EXTERN_API( short ) IUMagIDPString (const void * aPtr, const void * bPtr, short aLen, short bLen, Handle itl2Handle);
#endif


//++------------------------------------------------------------------------------
// BString 	BString::kNullString("");
long		BString::sCurrentLangauge = kLangUnknown;
bool		BString::sCurrentIsDoubleByte = false;

char		BString::sDubByteTable[256];


#if defined( WINDOWS )
const MoaLong 		kScriptToMessagePoolMap[] =
{
	LANG_ENGLISH,	// 0
	LANG_FRENCH,	// 1
	LANG_GERMAN,	// 2
	LANG_ITALIAN,	// 3
	LANG_DUTCH,		// 4
	LANG_SWEDISH,	// 5
	LANG_SPANISH,	// 6
	LANG_DANISH,	// 7
	LANG_PORTUGUESE,// 8
	LANG_KOREAN,	// 9

	LANG_JAPANESE,	// 10
	LANG_CHINESE,	// 11
	LANG_RUSSIAN,	// 12

	// Add new languages here

	-1
};
#endif	// WINDOWS

#if defined( MACINTOSH )
const MoaLong 		kScriptToMessagePoolMap[] =
{
	langEnglish,	// 0
	langFrench,		// 1
	langGerman,		// 2
	langItalian,	// 3
	langDutch,		// 4
	langSwedish,	// 5
	langSpanish,	// 6
	langDanish,		// 7
	langPortuguese,	// 8
	langKorean,		// 9

	langJapanese,	// 10
	langChinese,	// 11
	langRussian,	// 12

	// Add new languages here

	-1
};
#endif		// MACINTOSH



//++------------------------------------------------------------------------------
//	BString::BString
//		Notes:	default constructor
//++------------------------------------------------------------------------------
BString::BString() :
	mBuffer( &mStringData[0] ),
	mMaxLength( kBStringMaxStrLen ),
	mStorageFromHeap( false )
{
	mStringData[0] = 0;
}


//++------------------------------------------------------------------------------
//	BString::InitFromNull
//		Notes:	does the same as the default constructor.  This is used in the
//		special case where Moa isn't calling constructors for our objects.
//++------------------------------------------------------------------------------
void
BString::InitFromNull( void )
{
	mBuffer = &mStringData[0];
	mMaxLength = kBStringMaxStrLen;
	mStorageFromHeap = false;
	mStringData[0] = 0;
}


//++------------------------------------------------------------------------------
//	BString::BString
//		Input:	size value
//		Ouptut:	none
//		Notes:	default constructor
//++------------------------------------------------------------------------------
BString::BString( Int32 size ):
	mBuffer( &mStringData[0] ),
	mMaxLength( kBStringMaxStrLen ),
	mStorageFromHeap( false )
{
	mStringData[0] = 0;
	AllocateEnoughStringSpace(size);
	Assert_(mBuffer != nil);
}


//++------------------------------------------------------------------------------
//	BString::BString
//		Input:	inCString:	string to copy from
//		Ouptut:	none
//		Notes:	constructor
//++------------------------------------------------------------------------------
BString::BString(ConstRawCString inCString) :
	mBuffer( &mStringData[0] ),
	mMaxLength( kBStringMaxStrLen ),
	mStorageFromHeap( false )
{
	mStringData[0] = 0;
	long strLen = RawCStringLength(inCString);
	AllocateEnoughStringSpace(strLen + 1);
	Assert_(mBuffer != nil);
	CopyRawCString(inCString, mBuffer, strLen);
}


//++------------------------------------------------------------------------------
//	BString::BString
//		Input:	inPString:	string to copy from
//		Ouptut:	none
//		Notes:	constructor
//++------------------------------------------------------------------------------
BString::BString(ConstRawPString inPString) :
	mBuffer( &mStringData[0] ),
	mMaxLength( kBStringMaxStrLen ),
	mStorageFromHeap( false )
{
	mStringData[0] = 0;
	*this = inPString;
	Assert_(mBuffer != nil);
}


//++------------------------------------------------------------------------------
//	BString::BString
//		Input:	inString:	string to copy from
//		Ouptut:	none
//		Notes:	copy constructor
//++------------------------------------------------------------------------------
BString::BString(const BString& inString) :
	mBuffer( &mStringData[0] ),
	mMaxLength( kBStringMaxStrLen ),
	mStorageFromHeap( false )
{
	mStringData[0] = 0;

	Int32	inLength = inString.Length();
	if ( inLength > 0 )
	{
		AllocateEnoughStringSpace(inLength+1);
		CopyRawCString(inString.mBuffer, mBuffer, inLength );
	}
}


//++------------------------------------------------------------------------------
//	BString::~BString
//		Input:	none
//		Ouptut:	none
//		Notes:	destructor
//++------------------------------------------------------------------------------
BString::~BString()
{
	if(mStorageFromHeap && (mBuffer != nil))
	{
		delete[] mBuffer;
		mStorageFromHeap = false;
		mBuffer = NULL;
	}
}




//++------------------------------------------------------------------------------
//	BString::FindNext
//		Input:	inIndex:	index of character to start search
//				inString:	string to find
//		Ouptut:	the index at which inString occurs or kNotFound if not found
//		Notes:
//++------------------------------------------------------------------------------
Int32	BString::FindNext(Int32 inIndex, const BString& inString) const
{
	Assert_(mBuffer != nil);

	Int32 	lFound 	= kNotFound;
	Int32 	lIndex = inIndex;
	Int32 	lLength = Length();

	Assert_( inString.Length() > 0 );
	unsigned char firstChar = inString[ (Int32) 0];
	long inLength = inString.Length();
	if ( HaveDoubleByteLanguage() )
	{	// Japanese/Korean - parse with double bytes in mind
		while((lIndex < lLength) && (lFound == kNotFound))
		{
			unsigned char c = mBuffer[lIndex];
			if( c == firstChar )
			{
				#if defined( WINDOWS )
				if( _mbsncmp( (const unsigned char *) &mBuffer[lIndex], inString, inLength ) == 0 )
				#else
				if( strncmp( &mBuffer[lIndex], inString, inLength ) == 0 )
				#endif
				{
					lFound = lIndex;
					break;
				}
			}

			// Move one or two bytes
			if ( sDubByteTable[ c ] )
				lIndex++;

			lIndex++;
		}
	}
	else
	{	// Single byte languages
		while((lIndex < lLength) && (lFound == kNotFound))
		{
			if( mBuffer[lIndex] == firstChar )
			{
				if( strncmp(&mBuffer[lIndex], inString, inLength ) == 0)
				{
					lFound = lIndex;
				}
			}
			lIndex++;
		}
	}

	return(lFound);
}


//++------------------------------------------------------------------------------
//	BString::FindLast
//		Input:	inSubString:	string to find the last occurance of
//		Ouptut:	the index of the first occurance of inSuBString or kNotFound if not found
//++------------------------------------------------------------------------------
Int32	BString::FindLast(const BString& inSubString) const
{
	Assert_(mBuffer != nil);
	Int32	findIndex = Find1st( inSubString );
	Int32	retIndex = findIndex;
	while ( findIndex != kNotFound )
	{
		retIndex = findIndex;
		findIndex = FindNext( findIndex + 1, inSubString );
	}

	return retIndex;
}

//++------------------------------------------------------------------------------
//	BString::Replace1st
//		Input:	inSubString:	suBString to replace
//				inReplacement:	string to replace with
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
void	BString::Replace1st(const BString& inSubString, const BString& inReplacement)
{
	Assert_(mBuffer != nil);
	Int32 lIndex = Find1st(inSubString);
	if(lIndex != kNotFound)
	{
		Delete(lIndex, inSubString.Length());
		Insert(lIndex, inReplacement);
	}
}

//++------------------------------------------------------------------------------
//	BString::ReplaceAll
//		Input:	inSubString:	suBString to replace
//				inReplacement:	string to replace with
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
void	BString::ReplaceAll(const BString& inSubString, const BString& inReplacement)
{
	Assert_(mBuffer != nil);
	Int32 lIndex = Find1st(inSubString);
	if(lIndex != kNotFound)
	{
		do
		{
			Delete(lIndex, inSubString.Length());
			Insert(lIndex, inReplacement);
			lIndex += inReplacement.Length();
			lIndex = FindNext(lIndex, inSubString);
		}
		while((lIndex < Length()) && (lIndex != kNotFound));
	}
}

//++------------------------------------------------------------------------------
//	BString::Delete1st
//		Input:	inSubString:	suBString to delete
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
void	BString::Delete1st(const BString& inSubString)
{
	Assert_(mBuffer != nil);
	Int32 lIndex = Find1st(inSubString);
	if(lIndex != kNotFound)
	{
		Delete(lIndex, inSubString.Length());
	}
}

//++------------------------------------------------------------------------------
//	BString::DeleteAll
//		Input:	inSubString:	suBString to delete
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
void	BString::DeleteAll(const BString& inSubString)
{
	Assert_(mBuffer != nil);
	Int32 lIndex = Find1st(inSubString);
	if(lIndex != kNotFound)
	{
		do
		{
			Delete(lIndex, inSubString.Length());
			lIndex = FindNext(lIndex, inSubString);
		}
		while((lIndex < Length()) && (lIndex != kNotFound));
	}
}

//++------------------------------------------------------------------------------
//	BString::operator =
//		Input:	inCString:	string to assign from
//		Ouptut:	a reference to this object
//		Notes:	Storage is never reallocated
//++------------------------------------------------------------------------------
BString&	BString::operator = (ConstRawCString inCString)
{
 	Assert_(inCString != nil);
	Int32 lLength = RawCStringLength(inCString);
	AllocateEnoughStringSpace( lLength );
	CopyRawCString(inCString, mBuffer, lLength);

	return(*this);
}


//++------------------------------------------------------------------------------
//	BString::SetFromBuffer
//		Input:	buffer and length to read from.  Buffer may not be null terminated.
//++------------------------------------------------------------------------------
void	BString::SetFromBuffer( const char * inBuffer, Int32 length )
{
 	Assert_(inBuffer != nil);
	AllocateEnoughStringSpace( length + 1 );
	CopyRaw( inBuffer, mBuffer, length );
	mBuffer[ length ] = 0;
}


//++------------------------------------------------------------------------------
//	BString::operator =
//		Input:	inPString:	string to assign from
//		Ouptut:	a reference to this object
//		Notes:	Storage may be reallocated
//++------------------------------------------------------------------------------
BString&	BString::operator = (ConstRawPString inPascalString)
{
	Assert_(inPascalString != nil);
	Int32 	numChars = RawPStringLength(inPascalString);

	numChars = min(numChars, kMaxPStrLength);


	AllocateEnoughStringSpace( numChars );				// Allocate buffer.

	#if defined ( MACINTOSH )
	::BlockMove((void *)(&(inPascalString[1])), 	// Copy chars.
					mBuffer,
					numChars);
	#elif defined ( WINDOWS )
	::memmove( mBuffer, 									// Copy chars.
			(void *)(&(inPascalString[1])),
			numChars);
	#endif

	mBuffer[numChars] = 0;								// Null terminate.

	return(*this);
}

//++------------------------------------------------------------------------------
//	BString::operator =
//		Input:	inString:	string to assign from
//		Ouptut:	a reference to this object
//		Notes:	Storage may be reallocated
//++------------------------------------------------------------------------------
BString&	BString::operator = (const BString& inString)
{
	Int32 lLength = inString.Length();
	AllocateEnoughStringSpace( lLength );
	if (inString.mBuffer != nil)
	{
		CopyRawCString(inString.mBuffer, mBuffer, lLength);
	}
	else
	{
		mBuffer[0] = 0;
	}

	return( *this );
}

//++------------------------------------------------------------------------------
//	BString::operator +=
//		Input:	inString:	string to concatenate
//		Ouptut:	a reference to this object
//++------------------------------------------------------------------------------
BString&	BString::operator += (const BString& inThatString)
{
	if (inThatString.mBuffer != nil)
	{
		Int32 lThatLength 	= inThatString.Length();
		Int32 lThisLength 	= Length();
		Int32 resultLength 	= lThisLength + lThatLength;

		AllocateEnoughStringSpace(resultLength);
		CopyRawCString(inThatString.mBuffer, mBuffer + lThisLength, lThatLength);
	}
	return(*this);
}


//++------------------------------------------------------------------------------
//	BString::operator +=
//		Input:	character to concatinate
//		Ouptut:	a reference to this object
//++------------------------------------------------------------------------------
BString&	BString::operator += (const unsigned char c)
{
	Int32 lThisLength = Length();

	AllocateEnoughStringSpace(lThisLength + 1);

	if( lThisLength < mMaxLength )
	{
		mBuffer[lThisLength]		= c;
		mBuffer[lThisLength + 1]	= 0;
	}

	return(*this);
}


//++------------------------------------------------------------------------------
//	BString::operator []
//		Input:	inIndex:	index of character to get (zero based)
//		Ouptut:	the character at inIndex
//++------------------------------------------------------------------------------
char	BString::operator [] (Int32 inIndex) const
{
	Assert_(mBuffer != nil);
	Assert_( ((inIndex >= 0) && (inIndex < mMaxLength + 1)) );
	if ( inIndex < 0 )
	{
		inIndex = 0;
	}

	return(mBuffer[inIndex]);
}


//++------------------------------------------------------------------------------
//	BString::operator []
//		Input:	inIndex:	index of character to get (zero based)
//		Ouptut:	the character at inIndex
//		This version allows assignment as well.
//++------------------------------------------------------------------------------
char	&		BString::operator [] (Int32 inIndex)
{
	Assert_(mBuffer != nil);
	Assert_( ((inIndex >= 0) && (inIndex < mMaxLength + 1)) );
	if ( inIndex < 0 )
	{
		inIndex = 0;
	}

	return(mBuffer[inIndex]);
}



//++------------------------------------------------------------------------------
//	BString::TrimSpaces
//		Remove any trailing spaces from the string.
//++------------------------------------------------------------------------------
void	BString::TrimSpaces( void )
{
	Int32	curLen = Length();
	Int32	index;
	if ( curLen > 0 )
	{
		index = curLen - 1;
		while ( index >= 0 && mBuffer[ index ] == ' ' )
		{
			index--;
		}

		// We did move back, so index is the last non-space character.
		if ( index < (curLen - 1) )
		{
			mBuffer[index + 1] = 0;
		}
	}
}


//++------------------------------------------------------------------------------
//	BString::TrimLeadingWhitespace
//		Remove any leading white space from the string.
//++------------------------------------------------------------------------------
void	BString::TrimLeadingWhitespace( void )
{
	Int32 oldLen = Length();
	if ( oldLen > 0 )
	{
		Int32 count = 0;
		while ( count < oldLen )
		{
			char c = mBuffer[0];
			if ( c == ' ' || c == '\t' )
			{	// Starts with space or tab, so delete it
				Delete( 0, 1 );
			}
			else
			{	// Not a space or tab, so exit the loop
				break;
			}

			count++;
		}
	}
}



//++------------------------------------------------------------------------------
//	BString::PadWithSpacesToFitSize
//		Add trailing spaces to the string to reach the desired size.
//++------------------------------------------------------------------------------
void	BString::PadWithSpacesToFitSize( long finalLength )
{
	long curLen = Length();
	long neededLen = finalLength - curLen;
	if ( neededLen > 0 )
	{
		AllocateEnoughStringSpace( finalLength + 1 );

		char * curPtr = mBuffer + curLen;
		while ( neededLen > 0 )
		{
			*curPtr++ = ' ';
			neededLen--;
		}

		// Add a null terminator
		*curPtr = 0;
	}
}


//++------------------------------------------------------------------------------
//	BString::Delete
//		Input:	inIndex:	index to start deletion from
//				inLength:	number of characters to delete
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
void	BString::Delete(Int32 inIndex, Int32 inLength)
{
	Assert_(mBuffer != nil);
	Assert_((inIndex 	>= 0));
	Assert_((inLength 	>= 0));

	if ( (inIndex>=0) && (inLength>0))
	{
		Int32 lLength = Length();
		if(inIndex < lLength)
		{
			if((inIndex + inLength) >= lLength)
			{
				mBuffer[inIndex] = 0;
			}
			else
			{
				Int32 lToCopy = lLength - (inIndex + inLength);
				CopyRawCString(mBuffer + inIndex + inLength, mBuffer + inIndex, lToCopy);
			}
		}
	}
}

//++------------------------------------------------------------------------------
//	BString::Insert
//++------------------------------------------------------------------------------
void	BString::Insert(Int32 inIndex, const BString& inSubString)
{
	Int32 lLength = Length();
	if( inIndex >= lLength )
	{
		// degenerate case is concatenation
		operator += (inSubString);
	}
	else
	{
		Int32 lInsertLength = inSubString.Length();

		AllocateEnoughStringSpace(lInsertLength + lLength);	//  First make room for the sub string,

		CopyRawCString( mBuffer + inIndex, 					//	then move what's already there out
						mBuffer + inIndex + lInsertLength, 	//	of the way,
						lLength - inIndex );

		CopyRaw(	inSubString, 							//	finally copy inSubString
					mBuffer + inIndex,
					lInsertLength);
	}
}



#if (0)
// Not used, but here in case we need it...
//++------------------------------------------------------------------------------
//	BString::Insert
//++------------------------------------------------------------------------------
void	BString::Insert( Int32 inIndex, char inChar )
{
	Int32 lLength = Length();
	if( inIndex >= lLength )
	{
		// degenerate case is concatenation
		this += inChar;
	}
	else
	{
		AllocateEnoughStringSpace( lLength + 1 );	//  First make room for the character,

		CopyRawCString( mBuffer + inIndex, 			//	then move what's already there out
						mBuffer + inIndex + 1, 		//	of the way,
						lLength - inIndex );

		*(mBuffer + inIndex) = inChar;				// finally set the character
	}
}
#endif



#if defined ( MACINTOSH ) // && DEBUG_ON
//++------------------------------------------------------------------------------
//	StringExists
//		DEBUGGING CODE!!!
//		Input:	listID:		STR# list number.
//				stringID:	STR# item number, or STR resource ID
//		Ouptut:	TRUE if we found a string OK.
//		Notes:
//++------------------------------------------------------------------------------
bool StringExists(short listID, short stringID);  // prototype
bool StringExists(short listID, short stringID)
{
	bool result = false;
	Handle stringListRsrc = ::GetResource('STR#', listID);
	if (stringListRsrc != nil)
	{
		short numStrings = **((short**)stringListRsrc);
		if ((stringID <= numStrings) && (stringID > 0))
		{
			result = true;
		}

		::ReleaseResource( stringListRsrc );
	}
	return result;
}
#endif // MACINTOSH



//++------------------------------------------------------------------------------
//	BString::GetCurrentLanguage
//		Return sCurrentLangauge
//++------------------------------------------------------------------------------
long	BString::GetCurrentLanguage( void )
{
	InitializeLanguage();
	return sCurrentLangauge;
}


//++------------------------------------------------------------------------------
//	BString::SetCurrentLanguage
//		Sets sCurrentLangauge
//++------------------------------------------------------------------------------
void	BString::SetCurrentLanguage( long languageID )
{
	sCurrentLangauge = languageID;
	if ( sCurrentLangauge < 0 || sCurrentLangauge >= kLangLimit )
	{	// Something wrong, so clear the setting and we'll fix it later
		BString::sCurrentLangauge = kLangUnknown;
	}

	sCurrentIsDoubleByte = (sCurrentLangauge == kLangKorean ||
							sCurrentLangauge == kLangJapanese ||
							sCurrentLangauge == kLangChinese );
}



//++------------------------------------------------------------------------------
//	BString::InitializeLanguage
//		Sets sCurrentLangauge to the proper value.
//++------------------------------------------------------------------------------
void
BString::InitializeLanguage( void )
{
	if ( sCurrentLangauge == kLangUnknown )
	{
		sCurrentLangauge = kLangEnglish;

		long	systemLangaugeID = 0;

		// Get the system language tag.
		#if defined ( MACINTOSH )
		systemLangaugeID = langEnglish;
		if( ::GetScriptManagerVariable( smEnabled ) != 0 )
		{
			systemLangaugeID = ::GetScriptVariable( ::GetScriptManagerVariable( smSysScript ), smScriptLang );
		}
		#endif

		#if defined ( WINDOWS )
		systemLangaugeID = PRIMARYLANGID( ::GetSystemDefaultLangID() );
		#endif

		// Find the system language ID in our table, and set the current language
		long curLang = kLangEnglish;
		while ( kScriptToMessagePoolMap[ curLang ] != -1 )
		{
			if ( kScriptToMessagePoolMap[ curLang ] == systemLangaugeID )
			{
				SetCurrentLanguage( curLang );
				break;
			}
			curLang++;
		}

		// Set up the double byte language table as needed.
		if ( HaveDoubleByteLanguage() )
		{
			#if defined( WINDOWS )

			long i = 0;
			while ( i < 256 )
			{
				if( _ismbblead( (unsigned int) i ) )
					sDubByteTable[ i ] = true;
				else
					sDubByteTable[ i ] = false;
				i++;
			}

			#else		// Windows / Mac

			::FillParseTable( sDubByteTable, smSystemScript );

			#endif
		}
	}
}



//++------------------------------------------------------------------------------
//	BString::SetToInteger
//		Input:	value:		numberic value to set string to.
//				radix:		number base to use.
//		Ouptut:	None
//		Notes:
//++------------------------------------------------------------------------------
void
BString::SetToInteger( Int32 value, char type )
{
	AllocateEnoughStringSpace( 12 );
	if(mBuffer != nil)
	{
		switch ( type )
		{
			case 'd':
				sprintf( mBuffer, "%d", value );
				break;

			case 'x':
				sprintf( mBuffer, "%x", value );
				break;

			case '2':
				sprintf( mBuffer, "%02d", value );
				break;

			case '3':
				sprintf( mBuffer, "%03d", value );
				break;

			case '6':
				sprintf( mBuffer, "%06d", value );
				break;

			default:
				Assert_(0);
				break;
		}
	}
}


//++------------------------------------------------------------------------------
//	BString::SetToDouble
//		Input:	value:		numberic value to set string to.
//++------------------------------------------------------------------------------
void
BString::SetToDouble( double value, Int32 digits, Int32 precision )
{
	AllocateEnoughStringSpace( 20 );
	if(mBuffer != nil)
	{
		if ( digits == 0 || precision < 0 )
		{
			sprintf( mBuffer, "%f", value );
		}
		else
		{
			BString	format( "%" );
			BString	tempNum;
			tempNum.SetToInteger( digits );
			format += tempNum;
			format += '.';
			tempNum.SetToInteger( precision );
			format += tempNum;
			// format += 'l';
			format += 'f';
			sprintf( mBuffer, format, value );
		}
	}
}


//++------------------------------------------------------------------------------
//	BString::AllocateEnoughStringSpace
//		Input:	Number of text bytes we want to be able to support.  Does
//				not include nulls or size bytes.
//		Ouptut:	None
//		Notes:	May reallocate pointers to text data.  If so, the current
//				string contents are lost.
//
//		Dave note:  This isn't currently used.  It should be useful if you
//				need to assign a string to one that doesn't have enough
//				storage space.
//
//++------------------------------------------------------------------------------
void
BString::AllocateEnoughStringSpace( const Int32 stringLen )
{
	// It is important for the '+=' operator that the current
	// contents of mBuffer be preserved when reallocating.

	AssertNotNull_( mBuffer );		// We should always have our local storage available.

	if ( stringLen > mMaxLength )
	{
		RawCString 	oldBuffer 			= mBuffer;
		Int32		oldMaxLength 		= mMaxLength;
		bool		oldBufferFromHeap 	= mStorageFromHeap;

		mBuffer 	= NULL;
		mMaxLength 	= 0;

		IMMEMTAG( "BString::AllocateEnoughStringSpace" );
		mBuffer = new CChar[stringLen + 1];		// Allocate new buffer, will throw exception on memory failure
		mBuffer[0] 	= 0;
		mMaxLength 	= stringLen;
		mStorageFromHeap = true;				// Set our allocation flag

		// Copy old buffer to new buffer.
		#if defined ( MACINTOSH )
		::BlockMoveData( oldBuffer, mBuffer, oldMaxLength + 1 );
		#elif defined ( WINDOWS )
		::memcpy( mBuffer, oldBuffer, oldMaxLength + 1 );
		#endif

		if ( oldBufferFromHeap )
		{									// If old one was from the heap,
			delete[] oldBuffer;				// get rid of it.
		}

		AssertNotNull_( mBuffer );
	}
	else if ( stringLen <= 0 )
	{
		if(mStorageFromHeap && (mBuffer != nil))
		{
			delete[] mBuffer;
		}
		InitFromNull();
	}
}



//++------------------------------------------------------------------------------
//	BString::Integer
//		Input:	none
//		Ouptut:	this string as interpreted as an integer
//		Notes:
//++------------------------------------------------------------------------------
Int32	BString::Integer() const
{
	Int32 value = 0;
	if (mBuffer)
	{
		value = ::atoi(mBuffer);
	}

	return value;
}

//++------------------------------------------------------------------------------
//	BString::Double
//		Input:	none
//		Ouptut:	this string as interpreted as an 64 bit floating point number
//		Notes:
//++------------------------------------------------------------------------------
double	BString::Double() const
{
	double value = 0;
	if (mBuffer != nil)
	{
		value = ::atof(mBuffer);
	}

	return value;
}


//++------------------------------------------------------------------------------
//	BString::SetSMPTEString
//		Sets the string to a standard SMPTE format HH:MM:SS:frames
//++------------------------------------------------------------------------------
void	BString::SetSMPTEString( Int32 hours, Int32 minutes, Int32 seconds, Int32 frames )
{
	if (mBuffer != nil)
	{
		sprintf( mBuffer, "%02d:%02d:%02d.%02d", hours, minutes, seconds, frames );
	}
}


//++------------------------------------------------------------------------------
//	BString::SetTimeString
//		Sets the string to a standard time format HH:MM:SS.remainder
//++------------------------------------------------------------------------------
void	BString::SetTimeString( Int32 hours,
								Int32 minutes,
								Int32 seconds,
								Int32 remainder,
								bool forceMinutes )
{
	if (mBuffer != nil)
	{
		if ( hours == 0 && minutes == 0 && seconds == 0 )
		{
			if ( remainder != 0 )
				sprintf( mBuffer, "0.%2d", remainder );
			else
				sprintf( mBuffer, "0" );
		}
		else if ( hours == 0 && minutes == 0 && forceMinutes == false )
		{
			if ( remainder != 0 )
				sprintf( mBuffer, "%02d.%2d", seconds, remainder );
			else
				sprintf( mBuffer, "%02d", seconds );
		}
		else if ( hours == 0 )
		{
			if ( remainder != 0 )
				sprintf( mBuffer, "%02d:%02d.%2d", minutes, seconds, remainder );
			else
				sprintf( mBuffer, "%02d:%02d", minutes, seconds );
		}
		else
		{
			if ( remainder != 0 )
				sprintf( mBuffer, "%02d:%02d:%02d.%2d", hours, minutes, seconds, remainder );
			else
				sprintf( mBuffer, "%02d:%02d:%02d", hours, minutes, seconds );
		}
	}
}




//++------------------------------------------------------------------------------
//	BString::RawCStringLength
//		Input:	inCString:	string to find the length of
//		Ouptut:	the length of inCString
//		Notes:
//++------------------------------------------------------------------------------
Int32	BString::RawCStringLength(ConstRawCString inCString)
{
	Int32	length = 0;
	if ( inCString != NULL )
	{
		length = strlen( inCString );
	}

	return length;
}


#if defined ( MACINTOSH )
//++------------------------------------------------------------------------------
//	BString::GetStr255
//		Input:	None
//		Ouptut:	Macintosh Str255.
//		Notes:	Mac only. Use this when you need to pass get the value of a BString
//				as a Str255
//
//++------------------------------------------------------------------------------
void
BString::GetStr255(Str255 outString)	const
{
	// This is a MACINTOSH only method.
	if (mBuffer != nil)
	{
		outString[0] = min(kMaxPStrLength, Length());
		::BlockMoveData(mBuffer, (void*)(&(outString[1])), outString[0]);
	}
	else
	{
		outString = "\p";
	}
}
#endif

//++------------------------------------------------------------------------------
//	BString::GetCStr
//		Copies the string into the given buffer.   The caller must ensure
//		the buffer is large enough.
//++------------------------------------------------------------------------------

void
BString::GetCStr( char * outString ) const
{
	CopyRawCString( mBuffer, outString, Length() );		// Copy the chars, will add null.
}


#if 0
//++------------------------------------------------------------------------------
//	BString::GetLPSTR
//		Input:	None
//		Ouptut:	LPSTR.
//		Notes:	Windows only. Use this when you need to get the value of a
//				BString as a LPSTR
//
//++------------------------------------------------------------------------------

void
BString::GetLPSTR(LPSTR outString, Int32 maxChars)
{
	// This is a WINDOWS only method.
	CopyRawCString(mBuffer, outString, maxLength);	// Copy the chars
	outString[maxLength-1] = 0;						// Null terminate.
}
#endif



//++------------------------------------------------------------------------------
//	BString::Matches
//		Return true if we have a case independant match
//++------------------------------------------------------------------------------
bool	BString::Matches( const BString & otherString ) const
{
	Assert_( mBuffer != nil );
	Assert_( otherString.mBuffer != nil );

	#if defined ( MACINTOSH )

	const void * thisPtr = (const void *) ((const char *) *this);
	short thisLen = Length();
	const void * otherPtr = (const void *) ((const char *) otherString);
	short otherLen = otherString.Length();
	return( ::IdenticalText( thisPtr, otherPtr, thisLen, otherLen, NULL ) == 0 );

	#elif defined ( WINDOWS )

	return ( BString::IndCompare( *this, otherString ) == 0 );

	#endif
}


//++------------------------------------------------------------------------------
//	StartsWith
//		Return true if we have a case independant match for this string starting
//		with another one
//++------------------------------------------------------------------------------
bool
BString::StartsWith( const BString & otherString ) const
{
	Assert_( mBuffer != nil );
	Assert_( otherString.mBuffer != nil );

	#if defined( MACINTOSH )

	const void * thisPtr = (const void *) ((const char *) *this);
	const void * otherPtr = (const void *) ((const char *) otherString);
	short lenOne = (short) Length();
	short lenTwo = (short) otherString.Length();
	bool startsWith = false;
	if( lenTwo <= lenOne )
	{
		startsWith = (::IdenticalText( thisPtr, otherPtr, lenTwo, lenTwo, NULL ) == 0);
	}
	return( startsWith );

	#elif defined( WINDOWS )

	if ( HaveDoubleByteLanguage() )
	{
		return( _mbsnicmp( *this, otherString, otherString.Length() ) == 0 );
	}
	else
	{
		return( _strnicmp( *this, otherString, otherString.Length() ) == 0 );
	}

	#endif
}


//++------------------------------------------------------------------------------
//	operator ==
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the two strings are the same
//		Notes:
//++------------------------------------------------------------------------------
bool	operator == (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) == 0 );
}


//++------------------------------------------------------------------------------
//	operator !=
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the two strings are not the same
//		Notes:
//++------------------------------------------------------------------------------
bool	operator != (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) != 0 );
}

//++------------------------------------------------------------------------------
//	operator <
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically less than inString2
//		Notes:
//++------------------------------------------------------------------------------
bool	operator < (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) < 0 );
}

//++------------------------------------------------------------------------------
//	operator <=
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically less than or equal to inString2
//		Notes:
//++------------------------------------------------------------------------------
bool	operator <= (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) <= 0 );
}

//++------------------------------------------------------------------------------
//	operator >
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically greater than inString2
//		Notes:
//++------------------------------------------------------------------------------
bool	operator > (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) > 0 );
}

//++------------------------------------------------------------------------------
//	operator >=
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically greater than or equal to inString2
//		Notes:
//++------------------------------------------------------------------------------
bool	operator >= (const BString& inString1, const BString& inString2)
{
	Assert_(inString1.GetBuffer() != nil);
	Assert_(inString2.GetBuffer() != nil);

	return ( BString::Compare( inString1, inString2 ) >= 0 );
}



//++------------------------------------------------------------------------------
//	BString::ConvertToLowerCase
//		Converts the string to lower case
//++------------------------------------------------------------------------------
void	BString::ConvertToLowerCase( void )
{
	#if defined ( MACINTOSH )

	::LowercaseText( mBuffer, (short) Length(), smSystemScript );

	#elif defined ( WINDOWS )

	if ( HaveDoubleByteLanguage() )
	{
		_mbslwr( (unsigned char *) mBuffer );
	}
	else
	{
		_strlwr( mBuffer );
	}

	#endif
}

//++------------------------------------------------------------------------------
//	BString::ConvertToUpperCase
//		Converts the string to upper case
//++------------------------------------------------------------------------------
void	BString::ConvertToUpperCase( void )
{
	#if defined ( MACINTOSH )

	::UppercaseText( mBuffer, (short) Length(), smSystemScript );

	#elif defined ( WINDOWS )

	if ( HaveDoubleByteLanguage() )
	{
		_mbsupr( (unsigned char *) mBuffer );
	}
	else
	{
		_strupr( mBuffer );
	}

	#endif
}


//++------------------------------------------------------------------------------
//	BString::Token
//		Given the startOffset, returns a start offset and byte length
//		of the next whitespace delimted run of characters.
//++------------------------------------------------------------------------------
void	BString::Token( Int32 startOffset, Int32 * outStart, Int32 * outLen ) const
{
	AssertNotNull_( outStart );
	AssertNotNull_( outLen );

	if ( IsEmpty() || startOffset >= Length() )
	{
		*outStart = NULL;
		*outLen = 0;
	}

	// Skip whitespaces before the token.
	Int32	count = startOffset;
	while( mBuffer[count] != 0 && (mBuffer[count] == ' ' || mBuffer[count] == '\t' ) )
	{
		count++;
	}

	// Find the end of the run of text
	Int32 start = count;
	while( mBuffer[count] != ' ' && mBuffer[count] != '\t' && mBuffer[count] != 0 )
	{
		count++;
	}

	*outLen = count - start;
	*outStart = start;
}


//++------------------------------------------------------------------------------
//	BString::Token
//		Given the startOffset, returns the first word in the text.
//++------------------------------------------------------------------------------
void	BString::Token( Int32 startOffset, Int32 * outStart, Int32 * outLen, BString & outWord ) const
{
	outWord = "";

	long start, len;
	Token( startOffset, &start, &len );
	if ( len > 0 )
	{
		outWord.SetFromBuffer( mBuffer + start, len );
	}

	if ( outStart != NULL )
	{
		*outStart = start;
	}

	if ( outLen != NULL )
	{
		*outLen = len;
	}
}



//++------------------------------------------------------------------------------
//	BString::ContainsControls
//		Returns true if it has any control characters
//++------------------------------------------------------------------------------
bool	BString::ContainsControls() const
{
	bool hasControls = false;

	Int32 index = 0;
	while( mBuffer[index] != 0 )
	{
		if ( (unsigned char) mBuffer[index] < ' ' )
		{
			hasControls = true;
			break;
		}

		index++;
	}

	return hasControls;
}



//++------------------------------------------------------------------------------
//	BString::SubString
//		Given the startOffset and length, sets a new string
//++------------------------------------------------------------------------------
void	BString::SubString( Int32 startOffset, Int32 length, BString & outString ) const
{
	outString = "";
	if ( startOffset >= 0 && length >= 0 && startOffset + length <= Length() )
	{
		outString.SetFromBuffer( mBuffer + startOffset, length );
	}
}


//++------------------------------------------------------------------------------
//	BString::EndOfString
//		Given the startOffset, sets a new string with the remainder
//++------------------------------------------------------------------------------
void	BString::EndOfString( Int32 startOffset, BString & outString ) const
{
	outString = "";
	long len = Length();
	if ( startOffset >= 0 && len >= 0 && startOffset < (len - 1) )
	{
		outString.SetFromBuffer( mBuffer + startOffset, len - startOffset );
	}
}



//++------------------------------------------------------------------------------
//	BString::AppendIfNotEndingWith
//		Add the given string to the end if it's not already there.
//++------------------------------------------------------------------------------
void	BString::AppendIfNotEndingWith( const BString & terminator )
{
	long findIndex = FindLast( terminator );
	if ( findIndex != Length() - terminator.Length() )
	{
		(*this) += terminator;
	}
}




//++------------------------------------------------------------------------------
//	LessBString	operator ()
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically less than inString2
//++------------------------------------------------------------------------------
bool	LessBString::operator () (const BString & inStringOne, const BString & inStringTwo ) const
{
	return ( inStringOne.LessThan( inStringTwo ) );
}


//++------------------------------------------------------------------------------
//	BString::LessThan
//		Input:	inString1:	first string
//				inString2:	second string
//		Ouptut:	whether or not the inString1 is lexically less than inString2
//++------------------------------------------------------------------------------
bool
BString::LessThan( const BString & otherString ) const
{
	AssertNotNull_( GetBuffer() );
	AssertNotNull_( otherString.GetBuffer() );

	return ( BString::IndCompare( (const char *) *this, otherString ) < 0 );
}



//++------------------------------------------------------------------------------
// Same as stricmp, but does the right thing for Japanese
//++------------------------------------------------------------------------------
long		BString::IndCompare( const char *str1, const char *str2 )
{
	#if defined ( MACINTOSH )

	if ( HaveDoubleByteLanguage() )
	{	// Japanese/Korean - compare with double bytes in mind

		// Use the same method as the IML - convert to lower case first
		BString copyOne( str1 );
		BString copyTwo( str2 );

		long lenOne = copyOne.Length();
		long lenTwo = copyTwo.Length();

		::LowercaseText( copyOne, (short) lenOne, smSystemScript );
		::LowercaseText( copyTwo, (short) lenTwo, smSystemScript );

		return ::CompareText( (char *) copyOne, (char *) copyTwo, lenOne, lenTwo, NULL );
	}
	else	// Roman language comparison
	{
		while ( *str1 != '\0' && *str2 != '\0' )
		{
			char c1 = (char)tolower( *str1++ );
			char c2 = (char)tolower( *str2++ );

			if ( c1 < c2 )
				return -1;

			if ( c1 > c2 )
				return 1;
		}
	}

	if ( *str1 == '\0' && *str2 == '\0' )
		return 0;

	if ( *str1 == '\0' )
		return -1;

	return 1;

	#elif defined ( WINDOWS )

	if ( HaveDoubleByteLanguage() )
	{
		return _mbsicmp( (const unsigned char *) str1, (const unsigned char *) str2 );
	}
	else
	{
		return _stricmp( str1, str2 );
	}

	#endif
}


//++------------------------------------------------------------------------------
// Same as strcmp, but does the right thing for Japanese
//++------------------------------------------------------------------------------
long		BString::Compare( const char *str1, const char *str2 )
{
	#if defined ( MACINTOSH )

	return( strcmp(str1, str2) );

	#elif defined ( WINDOWS )

	if ( HaveDoubleByteLanguage() )
	{
		return _mbscmp( (const unsigned char *) str1, (const unsigned char *) str2 );
	}
	else
	{
		return strcmp( str1, str2 );
	}

	#endif
}


//++------------------------------------------------------------------------------
// FindStringInList - utility function
//++------------------------------------------------------------------------------
/*bool BString::FindStringInList( BStringList & strList ) const
{
	bool foundIt = false;

	// See if we can find this object in the list
	BStringList::iterator iter = strList.begin();
	while ( iter != strList.end() )
	{
		if ( Matches( *iter ) )
		{
			foundIt = true;
			break;
		}
		iter++;
	}

	return foundIt;
}

*/

//++------------------------------------------------------------------------------
// FindAndRemoveStringFromList - utility function
//++------------------------------------------------------------------------------
/*bool BString::FindAndRemoveStringFromList( BStringList & strList ) const
{
	bool didRemoval = false;

	// See if we can find this object in the list, and remove it
	BStringList::iterator iter = strList.begin();
	while ( iter != strList.end() )
	{
		if ( Matches( *iter ) )
		{
			strList.erase( iter );
			didRemoval = true;
			break;
		}
		iter++;
	}

	return didRemoval;
}

*/

//++------------------------------------------------------------------------------
// FindAndAddStringToList - utility function
//++------------------------------------------------------------------------------
/*bool BString::FindAndAddStringToList( BStringList & strList ) const
{
	bool didAdd = true;

	// See if we can find this object in the list, and remove it
	BStringList::iterator iter = strList.begin();
	while ( iter != strList.end() )
	{
		if ( Matches( *iter ) )
		{
			strList.erase( iter );
			didAdd = false;
			break;
		}
		iter++;
	}

	// If we didn't find it, then add the string
	if ( didAdd )
	{
		IMMEMTAG( "push_back 7" );
		strList.push_back( *this );
	}

	return didAdd;
}

*/
