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
*   Filename:   OperatorNew.cpp
*
*	Purpose:  Override operator new and delete so we can check for memory leaks
*
*****************************************************************************/

#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif


#if defined( MACINTOSH )
//++------------------------------------------------------------------------------
// On the Mac, we have to provide our own placement operator new
//++------------------------------------------------------------------------------
void *	operator new(size_t, void * ptr)	throw();
void *	operator new(size_t, void * ptr)	throw()
{
	return(ptr);
}
#endif

// Some prototypes to make the compiler happy.
void * DoNew( size_t size );
void DoDelete( void* ptr ) ;


// General enable/disable switch for overriding operator new and delete.
#if (1)

#include	"moaxtra.h"
#include	"Assert.h"

// This must be defined elsewhere to return the IMoaCalloc interface.
extern	PIMoaCalloc	GetCalloc( void );

// XTRA_MEMORY_DEBUGGING enables memory debugging features.
// FILL_DELETED_MEMORY fills deleted memory with 0xA5 on XTRA_MEMORY_DEBUGGING builds only.
#if defined( DEBUG )
	#ifndef XTRA_MEMORY_DEBUGGING
		#define	XTRA_MEMORY_DEBUGGING	1
	#endif
	#ifndef FILL_DELETED_MEMORY
		#define	FILL_DELETED_MEMORY		1
	#endif
#else
	#define	XTRA_MEMORY_DEBUGGING	0
#endif


//++------------------------------------------------------------------------------
//	Debugging code for leak checking.
//++------------------------------------------------------------------------------
#if XTRA_MEMORY_DEBUGGING

#include	<vector.h>

#define		kAllocListSize 	10000

// Structure to hold info about each allocation
typedef	struct	AllocInfo
{
	char *	mMemoryTag;
	void *	mPtr;
	size_t	mSize;
}	AllocInfo;

AllocInfo	sAllocList[ kAllocListSize ];	// Data to track allocations.

long		sNumBlockAllocations = 0;		// Number of blocks currently allocated, and our array pointer.
long		sTotalBlockAllocations = 0;		// Total number of blocks we've ever allocated.
long		sTotalBytesAllocated = 0;		// Total number of bytes we've ever allocated.
long		sBytesAllocated = 0;			// Current number of bytes we've allocated.
long		sMemoryHighWaterMark = 0;		// Most we've ever allocated.
long		sBlocksHighWaterMark = 0;		// Most blocks we've ever allocated.
void *		sTargetPtr = 0;					// Pointer we want to break into debugger when allocated.
char *		sCurrentMemTag = NULL;			// Pointer to global string showing where allocation was made
long		sAnnoyingAssertCount = 0;		// How many times we've annoyed the programmer

//++------------------------------------------------------------------------------
//	CheckForXtraMemoryLeaks()
//++------------------------------------------------------------------------------
void	CheckForXtraMemoryLeaks( void );
void	CheckForXtraMemoryLeaks( void )
{
	// If these are non-zero, check sAllocList to see what's leaked.

	Assert_( sNumBlockAllocations == 0 && sBytesAllocated == 0 );
}




//++------------------------------------------------------------------------------
//	SetMemoryTag()
//++------------------------------------------------------------------------------
void	SetMemoryTag( char * str );
void	SetMemoryTag( char * str )
{
	sCurrentMemTag = str;
}


#endif		// XTRA_MEMORY_DEBUGGING


//++------------------------------------------------------------------------------
//	operator new overrides to use IMoaCalloc interface
//++------------------------------------------------------------------------------
void * DoNew( size_t size )
{
	void* pMem = NULL;

	PIMoaCalloc pCalloc = ::GetCalloc();

	if ( pCalloc != NULL )
	{
		pMem = pCalloc->NRAlloc( size );

		#if XTRA_MEMORY_DEBUGGING

		// If first allocation, clear the table.
		if ( sTotalBlockAllocations == 0 )
		{
			long index = 0;
			while ( index < kAllocListSize )
			{
				sAllocList[ index ].mMemoryTag = NULL;
				sAllocList[ index ].mPtr = NULL;
				sAllocList[ index ].mSize = 0;
				index++;
			}
		}

		// Put the pointer into our static table.
		if ( sCurrentMemTag == NULL )
		{
			sAnnoyingAssertCount++;
			if ( sAnnoyingAssertCount < 5 )
				Assert_( sCurrentMemTag != NULL );		// Make sure we have a valid tag set
			sCurrentMemTag = "Unknown allocation";
		}

		sAllocList[ sNumBlockAllocations ].mMemoryTag = sCurrentMemTag;
		sAllocList[ sNumBlockAllocations ].mPtr = pMem;
		sAllocList[ sNumBlockAllocations ].mSize = size;

		sCurrentMemTag = NULL;

		// Adjust our statistics
		sTotalBytesAllocated += size;
		sBytesAllocated += size;
		if ( sBytesAllocated > sMemoryHighWaterMark )
		{	// Adjust our high water mark as needed.
			sMemoryHighWaterMark = sBytesAllocated;
		}

		sTotalBlockAllocations++;

		sNumBlockAllocations++;
		if ( sNumBlockAllocations > sBlocksHighWaterMark )
		{
			sBlocksHighWaterMark = sNumBlockAllocations;
		}

		// The memory array has a hardcoded size, which is a hack, but it's to avoid
		// allocating the memory block via the mechanism that uses it.
		Assert_( sNumBlockAllocations < kAllocListSize );

		// Check that it's not one we want to break into the debugger for.
		Assert_( sTargetPtr != pMem );

		#endif		// XTRA_MEMORY_DEBUGGING
	}

	return pMem;

}



//++------------------------------------------------------------------------------
//	operator delete overrides to use IMoaCalloc interface
//		Allows deleteing of NULL pointer
//++------------------------------------------------------------------------------
void DoDelete( void* ptr )
{
	if( ptr != NULL )
	{
		PIMoaCalloc pCalloc = ::GetCalloc();

		if ( pCalloc != NULL )
		{
			#if XTRA_MEMORY_DEBUGGING

			// Find the pointer in our static table
			long	index = 0;
			long	foundIndex = -1;
			while ( index < sNumBlockAllocations )
			{
				if ( sAllocList[ index ].mPtr == ptr )
				{
					foundIndex = index;
					break;
				}
				index++;
			}

			// Make sure we found it
			Assert_( foundIndex >= 0 && foundIndex < sNumBlockAllocations );

			#if FILL_DELETED_MEMORY
			// Fill memory with junk
			char * pJunk = (char *) ptr;
			long fillSize = sAllocList[ foundIndex ].mSize;
			while ( fillSize-- > 0 )
			{
				*pJunk++ = (char) 0xA5;
			}
			#endif

			// Adjust our numbers
			sBytesAllocated -= sAllocList[ foundIndex ].mSize;
			sNumBlockAllocations--;

			// Now move the table down.
			while ( foundIndex < sNumBlockAllocations )
			{
				sAllocList[ foundIndex ] = sAllocList[ foundIndex + 1 ];
				foundIndex++;
			}
			sAllocList[ foundIndex ].mMemoryTag = NULL;
			sAllocList[ foundIndex ].mPtr = NULL;
			sAllocList[ foundIndex ].mSize = 0;

			#endif	// XTRA_MEMORY_DEBUGGING

			pCalloc->NRFree( ptr );
		}
	}
}




//++------------------------------------------------------------------------------
//	operator new overrides to use IMoaCalloc interface
//++------------------------------------------------------------------------------
#if defined ( MACINTOSH )

void* operator new( size_t size )

#elif defined ( WINDOWS )

void *__cdecl operator new( size_t size )

#endif
{
	return DoNew( size );
}


//++------------------------------------------------------------------------------
//	operator delete overrides to use IMoaCalloc interface
//		Allows deleteing of NULL pointer
//++------------------------------------------------------------------------------
#if defined ( MACINTOSH )

void operator delete( void* ptr )

#elif defined ( WINDOWS )

void __cdecl operator delete( void* ptr )

#endif
{
	DoDelete( ptr );
}



#if (1)
//++------------------------------------------------------------------------------
//	Array operator new
//++------------------------------------------------------------------------------
#if defined ( MACINTOSH )

void * operator new[]( size_t size )

#elif defined ( WINDOWS )

void * __cdecl operator new[]( size_t size )

#endif
{
	return DoNew( size );
}


//++------------------------------------------------------------------------------
//	Array delete
//++------------------------------------------------------------------------------
#if defined ( MACINTOSH )

void operator delete[]( void* ptr )

#elif defined ( WINDOWS )

void __cdecl operator delete[]( void* ptr )

#endif
{
	DoDelete( ptr );
}
#endif		// Override for operator new

#endif

