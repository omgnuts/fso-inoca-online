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
*   Filename:   BString.h
*
*	Purpose:  a platform neutral string class
*****************************************************************************/

#pragma once
#if	!defined(__BString__)
#define __BString__

//++------------------------------------------------------------------------------
// includes
#include "BExcpton.h"
#include "BTypes.h"
#include <vector.h>
#include <string.h>
//#include <set.h>
#include "Assert.h"

#if defined( MACINTOSH )
#include <CType.h>
#endif

//++------------------------------------------------------------------------------
const Int32	kMaxPStrLength = 255;



//--------------------------------------------------------------------------------
// BStrings have hybrid data storage.   They all contain space in the object
// itself for storage, based on this constant.   If the object needs more
// storage, it turns to the heap to get it.

#define		kBStringObjectStorageSize	64
#define		kBStringMaxStrLen			kBStringObjectStorageSize - 1

class	BString;
typedef	vector< BString >	BStringList;

//--------------------------------------------------------------------------------
// the object

class	BString
{
	//	constants
	public:
		enum
		{
			kPStringLengthByteIndex = -1,
			kNotFound = -1
		};

		enum	// These must match the arrays in BString.cpp
		{
			kLangUnknown = -1,
			kLangEnglish = 0,
			kLangFrench,
			kLangGerman,
			kLangItalian,
			kLangDutch,
			kLangSwedish,
			kLangSpanish,
			kLangDanish,
			kLangPortuguese,
			kLangKorean,
			kLangJapanese,
			kLangChinese,
			kLangRussian,
			kLangLimit
		};

	//	constructors/destructors
	public:
						BString();
						BString(Int32 size);
						BString(ConstRawCString inCString);
		 				BString(ConstRawPString inPString);
						BString(const BString& inString);

		virtual			~BString();

		void			InitFromNull( void );

	//	conversions
	public:
						operator RawCString ();
						operator ConstRawCString () const;
						operator RawPString ();
						operator ConstRawPString () const;

		#if defined ( MACINTOSH )
		void			GetStr255(Str255 outString)	const;
		#endif	// MACINTOSH

		void			GetCStr( char * outString ) const;

		#if 0
		void			GetLPSTR(LPSTR outString, Int32 maxChars);
		#endif

		void			SetFromBuffer( const char * inBuffer, Int32 length );

		void			ConvertToLowerCase( void );
		void			ConvertToUpperCase( void );

	// number munging
	public:
		Int32			Integer() const;
		void			SetToInteger( Int32 value, char type = 'd' );

		double			Double() const;
		void			SetToDouble( double value, Int32 digits = 0, Int32 precision = -1 );

		void			SetSMPTEString( Int32 hours, Int32 minutes, Int32 seconds, Int32 frames );
		void			SetTimeString(	Int32 hours,
										Int32 minutes,
										Int32 seconds,
										Int32 remainder,
										bool forceMinutes = false );

	//	properties
	public:
		Int32			Length() const;			// Returns characters in string.
		bool			IsEmpty() const;		// Returns true if it's a null string.
		bool			ContainsControls() const;	// Returns true if it has any control characters

	//	assignment operations
	public:
		BString&		operator = (ConstRawCString inCString);
		BString&		operator = (ConstRawPString inPString);
		BString&		operator = (const BString& inString);
		BString&		operator += (const BString& inString);
		BString&		operator += (const unsigned char c);

	//	access operations
	public:
		char			operator [] (Int32 inIndex) const;
		char	&		operator [] (Int32 inIndex);
		void			Delete(Int32 inIndex, Int32 inLength);

		// Warning - don't use this !  This is provided for some debugging
		// asserts only.
		#if defined( DEBUG )
		RawCString		GetBuffer( void ) const;
		#endif

	//	substring operations
	public:
		Int32			Find1st( const BString& inSubString ) const;
		Int32			FindNext( Int32 inIndex, const BString& inSuBString ) const;
		Int32			FindLast( const BString & inSubString ) const;

		void			Insert( Int32 inIndex, const BString& inString );
		// void			Insert( Int32 inIndex, char inChar );

		void			Replace1st( const BString& inSuBString, const BString& inReplacement );
		void			ReplaceAll( const BString& inSuBString, const BString& inReplacement );
		void			Delete1st( const BString& inSuBString );
		void			DeleteAll( const BString& inSuBString );

		void			SubString( Int32 startOffset, Int32 length, BString & outString ) const;
		void			EndOfString( Int32 startOffset, BString & outString ) const;
		void			Token( Int32 startOffset, Int32 * outStart, Int32 * outLen ) const;
		void			Token( Int32 startOffset, Int32 * outStart, Int32 * outLen, BString & outWord ) const;

		void			TrimSpaces( void );
		void			TrimLeadingWhitespace( void );
		void			PadWithSpacesToFitSize( long finalLength );
		void			AppendIfNotEndingWith( const BString & terminator );

		// Case independent matching.
		bool			Matches( const BString & otherString ) const;

		bool			LessThan( const BString & otherString ) const;

		bool			StartsWith( const BString & otherString ) const;

		// Funky utility
		
		bool			FindStringInList( BStringList & strList ) const;
		bool			FindAndRemoveStringFromList( BStringList & strList ) const;
		bool			FindAndAddStringToList( BStringList & strList ) const;
		
		virtual void	AllocateEnoughStringSpace( const Int32 stringLen );

		Int32			MaxLength() const;		// 	Returns current character capacity.

		// Static functions
		static Int32	RawCStringLength(ConstRawCString inCString);

		static long		IndCompare( const char *str1, const char *str2 );
		static long		Compare( const char *str1, const char *str2 );

	//	implementation
	protected:
		static void		CopyRaw(ConstRawCString inCString, RawCString outCString, Int32 inLength);
		static void		CopyRawCString(ConstRawCString inCString, RawCString outCString, Int32 inLength);
		static void		CopyRawPString(ConstRawPString inPString, RawPString outPString);
		static Int32	RawPStringLength(ConstRawPString inCString);

		RawCString		mBuffer;				//  Pointer to the string data
		Int32			mMaxLength;				// 	Actual size of mBuffer in bytes minus null
												//	byte.
		bool			mStorageFromHeap;		//  True if we allocated from heap

		char			mStringData[kBStringObjectStorageSize];

	// Static routines
	public:

		static		long	GetCurrentLanguage( void );
		static		void	SetCurrentLanguage( long languageID );

		static		bool	HaveDoubleByteLanguage( void )		{ return sCurrentIsDoubleByte;	}


	protected:
		static		void	InitializeLanguage( void );

		static		long	sCurrentLangauge;
		static		bool	sCurrentIsDoubleByte;

		static		char	sDubByteTable[256];
};


//	Logical operations
bool			operator == 	(const BString& inString1, const BString& inString2);
bool			operator != 	(const BString& inString1, const BString& inString2);
bool			operator < 		(const BString& inString1, const BString& inString2);
bool			operator <= 	(const BString& inString1, const BString& inString2);
bool			operator > 		(const BString& inString1, const BString& inString2);
bool			operator >= 	(const BString& inString1, const BString& inString2);



//--------------------------------------------------------------------------------
// Comparitor class for stl maps, etc.
class	LessBString
{
	public:
		bool operator()( const BString & inStringOne, const BString & inStringTwo ) const;
};


//--------------------------------------------------------------------------------
// String set for associative lists -- not used in MarsLogger
//--------------------------------------------------------------------------------
  // typedef		set< BString, LessBString >			BStringSet;
  // typedef		pair< BStringSet::iterator, bool >	BStringSetPair;

//--------------------------------------------------------------------------------
// inlining

//++------------------------------------------------------------------------------
//	BString::BString::CopyRaw
//		Input:	inCString:	source string
//				outCString:	destination string
//				inLength:	number of bytes to copy
//		Ouptut:	none
//		Notes:	this call does not necessarily include the nil terminator
//++------------------------------------------------------------------------------
inline void	BString::CopyRaw(ConstRawCString inCString, RawCString outCString, Int32 inLength)
{
	Assert_(inCString != nil);
	Assert_(outCString != nil);
	#if defined( WINDOWS )
	memmove( outCString, (void *) inCString, inLength);
	#else
	::BlockMove(inCString, outCString, inLength);
	#endif
}

//++------------------------------------------------------------------------------
//	BString::CopyRawCString
//		Input:	inCString:	source string
//				outCString:	destination string
//				inLength:	size of inCString, including NULL
//		Ouptut:	none
//		Notes:	Adds a null at the end of destination string.
//++------------------------------------------------------------------------------
inline void	BString::CopyRawCString(ConstRawCString inCString, RawCString outCString, Int32 inLength)
{
	CopyRaw(inCString, outCString, inLength);
	outCString[ inLength ] = 0;
}

//++------------------------------------------------------------------------------
//	BString::CopyRawPString
//		Input:	inPString:	source string
//				outPString:	destination string
//		Ouptut:	none
//		Notes:
//++------------------------------------------------------------------------------
inline void	BString::CopyRawPString(ConstRawPString inPString, RawPString outPString)
{
	Assert_(inPString != nil);
	Assert_(outPString != nil);
	#if defined( WINDOWS )
	memmove( outPString, (void *) inPString, inPString[0] + 1);
	#else
	Int32 numBytes = inPString[0]+1;
	//numBytes = min(numBytes, kMaxPStrLength+1);
	::BlockMove(inPString, outPString, numBytes);
	#endif
}


//++------------------------------------------------------------------------------
//	BString::RawPStringLength
//		Input:	inPString:	string to find the length of
//		Ouptut:	the length of inCString
//		Notes:
//++------------------------------------------------------------------------------
inline Int32	BString::RawPStringLength( ConstRawPString inPString )
{
	Assert_(inPString != nil);
	return( inPString[0] );
}

//++------------------------------------------------------------------------------
//	BString::operator RawCString
//		Input:	none
//		Ouptut:	pointer to the buffer representing a C string
//		Notes:
//++------------------------------------------------------------------------------
inline	BString::operator RawCString ()
{
	if(mBuffer == NULL)
	{
		return "";
	}
	else
	{
		return mBuffer;
	}
}

//++------------------------------------------------------------------------------
//	BString::operator ConstRawCString
//		Input:	none
//		Ouptut:	pointer to the buffer representing a C string
//		Notes:
//++------------------------------------------------------------------------------
inline	BString::operator ConstRawCString () const
{
	if(mBuffer == NULL)
	{
		return "";
	}
	else
	{
		return mBuffer;
	}
}

//++------------------------------------------------------------------------------
//	BString::operator RawPString
//		Input:	none
//		Ouptut:	pointer to the buffer representing a C string
//		Notes:
//++------------------------------------------------------------------------------
inline	BString::operator RawPString ()
{
	if(mBuffer == NULL)
	{
		return (RawPString) "";
	}
	else
	{
		return (RawPString) mBuffer;
	}
}

//++------------------------------------------------------------------------------
//	BString::operator ConstRawPString
//		Input:	none
//		Ouptut:	pointer to the buffer representing a C string
//		Notes:
//++------------------------------------------------------------------------------
inline	BString::operator ConstRawPString () const
{
	if(mBuffer == NULL)
	{
		return (ConstRawPString) "";
	}
	else
	{
		return (ConstRawPString) mBuffer;
	}
}


//++------------------------------------------------------------------------------
//	BString::GetBuffer
//		Input:	none
//		Ouptut:	our buffer pointer
//		Notes:	Don't use this !  Provided for debugging routines only.
//++------------------------------------------------------------------------------
#if defined( DEBUG )
inline 	RawCString		BString::GetBuffer( void ) const
{
	return mBuffer;
}
#endif

//++------------------------------------------------------------------------------
//	BString::Length
//		Input:	none
//		Ouptut:	length of the string
//		Notes:	Calcualtes based on C string length, ingnores pascal string
//++------------------------------------------------------------------------------
inline Int32	BString::Length() const
{
	Int32 result = 0;
	if (mBuffer != nil)
	{
		result = RawCStringLength(mBuffer);
	}
	return result;
}


//++------------------------------------------------------------------------------
//	BString::Length
//		Returns true if it's a null string.
//++------------------------------------------------------------------------------
inline	bool BString::IsEmpty() const
{
	bool result = true;
	if (mBuffer != nil)
	{
		result = (mBuffer[0] == 0);
	}
	return result;
}


//++------------------------------------------------------------------------------
//	BString::MaxLength
//		Input:	none
//		Ouptut:	size of buffer pointed to by mData
//		Notes:
//++------------------------------------------------------------------------------
inline Int32	BString::MaxLength() const
{
	return( mMaxLength );
}

//++------------------------------------------------------------------------------
//	BString::FindFirst
//		Input:	inSuBString:	string to find the first occurance of
//		Ouptut:	the index of the first occurance of inSuBString or kNotFound if not found
//		Notes:
//++------------------------------------------------------------------------------
inline Int32	BString::Find1st(const BString& inSubString) const
{
	Assert_(mBuffer != nil);
	return(FindNext(0, inSubString));
}

//++------------------------------------------------------------------------------
//	Add a default, no-op definition so this can be compiled independantly
//++------------------------------------------------------------------------------
#ifndef IMMEMTAG
		#define	IMMEMTAG( s )
#endif

#endif
