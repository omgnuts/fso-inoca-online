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
// DBCBTable.h: interface for the DBCBTable class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __DBCBTable__
#define __DBCBTable__

#if defined( DEBUG )
#define	E4DEBUG
#endif	// DEBUG

#include "d4all.hpp"

#include "DBTable.h"
#include "DBCodeBase.h"
#include "DBException.h"
#include "GlobalStrings.h"
#include "vector.h"

typedef long	IDNUM;
typedef	vector<long>	IDList;


// Simple class used to pass raw data around
class DBData 
{
	public:
		
		DBData() { mData = NULL; }
		virtual ~DBData()
		{
			if (mData != NULL)
				delete[] mData;
			mData = NULL;
		}

		char			*mData;
		unsigned int	mLen;
};



class DBCBTable : public DBTable
{
	public:
		DBCBTable(DBGeneric *);
		virtual			~DBCBTable();

		void			CreateHelper( SvrObject *, Field4info &, Tag4info & );
		virtual void	Open( SvrObject * );

		void			Compress( void );

		virtual	void	UpdateFileStructure( void );

		virtual void	MakeTagInfo( Tag4info & outInfo ) = 0;


		// Looking up an ID number
		long			GetNumberFromNumber( SvrObject * obj,
								long targetNumber,				// Number we're finding
								const char * targetTag,			// Index tag to use
								const char * numFieldName,		// Field output number is in
								MoaError * err );

		long			GetNumberFromName( SvrObject * obj,
								const char * targetName,		// Name we're finding
								long tagLength,					// Size of tag field
								const char * targetTag,			// Index tag to use
								const char * numFieldName,		// Field number is in
								MoaError * err );
								
		// Finding data using the index field
		void			SeekFirst( SvrObject *, char * target, MoaError *err );	// Seeks to the first undeleted record in index tag

		void			SeekFirst( SvrObject *, double target, MoaError *err );	// Seeks to the first undeleted record in index tag
		
		void			SeekNext( SvrObject *, char * target, MoaError *err );	// Seeks to the next undeleted record in index tag

		void			SeekNext( SvrObject *, double target, MoaError *err );	// Seeks to the next undeleted record in index tag


		// Find data without index
		void			FindFirstWithoutIndex( SvrObject *, double target, const char * fieldName, MoaError *err );
		
		// Get a list of fields
		void			GetIDList( SvrObject *svrObj, const IDNUM idToMatch, const char * tagToUse, const char * fieldToGet, IDList &attrIDList, MoaError *err );
		
		void			GetIDListWithoutIndex( SvrObject *svrObj, const IDNUM idToMatch, const char * fldToSearch, const char * fieldToGet, IDList &attrIDList, MoaError *err );

		// Getting data
		void			GetString( const char * fldToGet, BString & outFieldContents );
		
		void			GetStrings( const char * fieldToGet, long startRecNum, long endRecNum, BStringList & outStringList );
		
		// Locking
		void			LockRecord( MoaError *err );		// locks the current record

		void			UnlockRecord( MoaError *err );		// unlocks the current record

		// Record count
		long			GetUndeletedRecordCount( MoaError *err );

		// Delete a record
		void			DeleteRecord( SvrObject *, MoaError * err );

		void			GetFilePath( SvrObject *svrObj, BString & path ) const;

		bool			GetDeletedOrNewRecord( SvrObject *, MoaError * err );

		DBCodeBase	*	getDBConnection() const	{ return mDB; }

	protected:
		
		void			Select( const char *tagName );

		void			LockAndBlank( MoaError * err );

		virtual void	ZapIndexField( void ) = 0;

		void			ZapNumericIndexField( const char * fldName );

		void			ZapTextIndexField( const char * fldName );

		void			GetZappedTextFieldString( BString & outString );

		void			FindRecordWithNumericMatches( SvrObject *svrObj, IDNUM numberToSeek, const IDNUM numberToMatch, const char * otherField, MoaError *err );

		void			RemoveTag( const char * tagName );
	
		void			UppercaseField( const char * fieldName );

		void			ScanAndSetDeleteCount( void );

		void			GoToTop( MoaError * err );

		void			Skip( long numRecords, MoaError * err );


		long			mUpdateStatus;
		enum
		{
			kTableUpdateDontKnow = 0,
			kTableUpdateYes,
			kTableUpdateNo
		};

		Data4			mData4;
		DBCodeBase		*mDB;			// *sigh* -- couldn't abstract the connection
		long			mDeleteCount;	// Minor goofiness - we use negative numbers here
		BString			mFileName;
		BString			mIndexTag;
		bool			mIndexIsString;
};

#endif // __DBCBTable__