//++------------------------------------------------------------------------------
//	File:		DBCBTable.cpp: 
//
//	Version:
//		$Revision: 14 $
//
//	Purpose:	Implementation of the DBCBTable class.   This is a base class
//				for various Codebase tables.
//
//	Unpublished Copyright:	CONFIDENTIAL - ©1999 Macromedia Inc.  This material
//	                      	contains certain trade secrets and confidential and
//	                      	proprietary information of Macromedia Inc..  
//	                      	Use,reproduction, disclosure and distribution by 
//	                      	any means are prohibited, except pursuant to a written
//	                      	license from Macromedia Inc..  Use of a copyright notice
//	                      	is precautionary and does not imply publication or 
//	                      	disclosure.
//
//	Change History (most recent first):
//	===================================
//  $Log: /Mars/ServerXtras/ObjectDB/DBCBTable.cpp $
//  
//  14    3/27/00 12:07p Dsimmons
//  Added MakeTagInfo() usage so RemoveTag() works right
//  
//  13    3/22/00 5:07p Dsimmons
//  Added ScanAndSetDeleteCount() to set delete count properly so that
//  adding data will work right if we don't pack on startup.
//  
//  12    3/20/00 5:30p Dsimmons
//  Added #include for Windows so IMMEMTAG files get it right
//  
//  11    3/20/00 12:06p Dsimmons
//  Windows fixes
//  
//  10    3/08/00 12:36p Dsimmons
//  Optimization
//  
//++------------------------------------------------------------------------------
#if defined( WINDOWS )
#include "SrvXtnPrecompile.h"
#endif


#include "DBCBTable.h"
#include "Options.h"
#include "DebugException.h"
#include "Localize.h"
#include "GlobalStrings.h"

//++------------------------------------------------------------------------------
//
//++------------------------------------------------------------------------------
DBCBTable::DBCBTable( DBGeneric *db )
{
	// we know that the DBGeneric object must be a DBCodeBase.
	// No obvious abstraction (without lots of work) of the
	// database connection object presents itself --
	// CodeBase and ODBC are just pretty different.
	if (db == NULL)
		throw DebugException("DBCBTable - passed illegal argument",
				COMMERR_SERV_INTERNAL_ERROR);
	mDB = (DBCodeBase *) db;
									// of itself very well
	mIndexIsString = false;
	mDeleteCount = 0;
	mUpdateStatus = kTableUpdateDontKnow;
}



//++------------------------------------------------------------------------------
//	DBCBTable::~DBCBTable
//++------------------------------------------------------------------------------
DBCBTable::~DBCBTable()
{
	if ( mData4.isValid() )
		mData4.close();
	mDB = NULL;
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetFilePath
//++------------------------------------------------------------------------------
void DBCBTable::GetFilePath( SvrObject *svrObj, BString & path ) const
{
	const char *dbFolder = svrObj->getOptions()->getOption(LOCALIZE_db_folder);
	const char *serverRoot = svrObj->getOptions()->getOption(LOCALIZE_ServerRoot);

	if (dbFolder == NULL)
	{
		// if no DBFolder option was specified, then the final path
		// is just serverRoot+path
		BString fullPath(serverRoot);
		fullPath += path;			// serverRoot already has trailing '\\'
		path = fullPath;
	}
	else
	{
		BString bDBFolder(dbFolder);
		BString fullPath(serverRoot);
		if ( ( bDBFolder.Length() > 0 ) && ( bDBFolder[ (long) 0 ] == '@' ) )
		{
			// Delete the trailing path delimiter
			fullPath.Delete( fullPath.Length() - 1, 1 );

			// Get the input path minus the leading "@"
			BString partialPath;
			bDBFolder.SubString( 1, bDBFolder.Length() - 1, partialPath );

			// Append dbFolder and the actual path
			fullPath += partialPath;
			#if defined( WINDOWS )
			fullPath.AppendIfNotEndingWith( BString("\\") );
			#elif defined ( MACINTOSH )
			fullPath.AppendIfNotEndingWith( BString(":") );
			#endif
			fullPath += path;
			path = fullPath;
		}
		else
		{
			// a DBFolder which didn't include an '@'... must be an
			// absolute or relative path
			if (bDBFolder.Length() > 0)
			{
				fullPath = bDBFolder;
				#if defined( WINDOWS )
				fullPath.AppendIfNotEndingWith( BString("\\") );
				#elif defined ( MACINTOSH )
				fullPath.AppendIfNotEndingWith( BString(":") );
				#endif
				fullPath += path;

				path = fullPath;
			}
			else
			{
				// DBFolder was empty, so it must have been a relative path of '.'
				// fullPath = path;
				// path = fullPath;
			}
		}
	}

#if 0
	DebugStr_("Calculated filename: ");
	DebugStr_((char *) path);
	DebugStr_("\n");
#endif
}



//++------------------------------------------------------------------------------
//	DBCBTable::CreateHelper - does the actual file creation
//		Also sets our saved filename
//++------------------------------------------------------------------------------
void DBCBTable::CreateHelper( SvrObject *svrObj, Field4info &fields, Tag4info &tags )
{
	mFileName = getTablename();
	GetFilePath(svrObj, mFileName);

	mDB->Create(svrObj, (char *) mFileName, mData4, fields, tags);
}



//++------------------------------------------------------------------------------
//	DBCBTable::Open
//++------------------------------------------------------------------------------
void DBCBTable::Open(SvrObject *svrObj)
{
	BString filename;

	filename = getTablename();
	GetFilePath(svrObj, filename);

	// clear out any error info here...
	// As part of bug #51585, I enabled multiple opens of
	// a single file, which revealed a problem with
	// errorCode being 60, which didn't always get cleared out.
	Code4	*code4 = getDBConnection()->getCode4();
	AssertNotNull_( code4 );
	code4->errorSet();

	if (!mData4.isValid())
		mDB->Open(svrObj, filename, mData4);

	long rc = r4success;
	if (svrObj->getOptions()->getOption(LOCALIZE_PackDatabase) == NULL)
	{	// We have to scan the file to find the proper deleted record tag to use
		ScanAndSetDeleteCount();
	}
	else
	{
		Compress();
	}

	// Do any needed file structure updates
	UpdateFileStructure();

	Select( mIndexTag );
}



//++------------------------------------------------------------------------------
//	DBCBTable::ScanAndSetDeleteCount
//++------------------------------------------------------------------------------
void DBCBTable::ScanAndSetDeleteCount( void )
{
	// Start at the top and scan for deleted records
	int rc = mData4.top();
	if ( rc == r4eof )				// Special case for file with no records
		rc = r4success;

	if ( rc == r4success )
	{
		while ( !mData4.eof() )
		{
			if ( mData4.deleted() )
			{
				mDeleteCount--;		// mDeleteCount is a negative number
			}
			rc = mData4.skip( 1 );
			if ( rc != r4success )
			{
				break;
			}
		}
	}

	// Go back to the top
	rc = mData4.top();
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetNumberFromNumber - given one number, find it and return a
//		number from another field.  Used to look up player info.
//++------------------------------------------------------------------------------
long DBCBTable::GetNumberFromNumber( SvrObject * svrObj,
								long targetNumber,				// Number we're finding
								const char * targetTag,			// Index tag to use
								const char * numFieldName,		// Field output number is in
								MoaError * err )
{
	long retID = 0;

	// Seek the data
	Select( targetTag );
	SeekFirst( svrObj, targetNumber, err );

	if ( *err == kMoaErr_NoErr )
	{
		// Identify the field we want to get
		Field4	numField( mData4, numFieldName );
		retID = long(numField); 
	}

	// Return the number we found, 0 if not there
	return retID;
}





//++------------------------------------------------------------------------------
// DBCBTable::GetNumberFromName - given a string field, return a number
//		value from another field in the same record.  Used to look up
//		a name and return an ID number.
//++------------------------------------------------------------------------------
long DBCBTable::GetNumberFromName(	SvrObject *svrObj, 
							const char * targetName,		// Name we're finding
							long tagLength,					// Size of tag field
							const char * targetTag,			// Tag to use
							const char * numFieldName,		// Field number is in
							MoaError * err )
{
	long retID = 0;

	// Seek the data - Convert the target name to upper case first
	Select( targetTag );
	BString	upperName( tagLength );
	upperName = targetName;
	upperName.ConvertToUpperCase();

	// Must pad with spaces so that we don't get partial matches
	upperName.PadWithSpacesToFitSize( tagLength );

	SeekFirst( svrObj, upperName, err );

	if ( *err == kMoaErr_NoErr )
	{
		// Identify the field we want to get
		Field4	numField( mData4, numFieldName );
		retID = long(numField); 
	}

	// Return the number we found, 0 if not there
	return retID;
}





//++------------------------------------------------------------------------------
//	DBCBTable::FindRecordWithNumericMatches
//		Find a record with a number to seek, plus another numeric field to match
//++------------------------------------------------------------------------------
void DBCBTable::FindRecordWithNumericMatches( SvrObject *svrObj, IDNUM numberToSeek, const IDNUM numberToMatch, const char * otherField, MoaError *err )
{
	SeekFirst( svrObj, numberToSeek, err );
	if ( *err == kMoaErr_NoErr )
	{	// Identify the field where the attribute ID is stored
		Field4	numField( mData4, otherField );
		long curID = long( numField );

		while( curID != numberToMatch && *err == kMoaErr_NoErr )
		{
			SeekNext( svrObj, numberToSeek, err );
			curID = long( numField );
		}
	}
}




//++------------------------------------------------------------------------------
//	DBCBTable::Select - utility routine to select index tags
//++------------------------------------------------------------------------------
void DBCBTable::Select( const char * targetTag )
{
	// Select the index tag
	mData4.select( targetTag );
	if ( getDBConnection()->getCode4()->errorCode != r4success )
	{
		getDBConnection()->getCode4()->errorSet();		// reset error
		throw DebugException( "Error selecting index tag.", COMMERR_SERV_INTERNAL_ERROR );
	}
}




//++------------------------------------------------------------------------------
//	DBCBTable::SeekFirst
//		Seeks to the first undeleted record in index tag
//		This variation takes a string target
//++------------------------------------------------------------------------------
void DBCBTable::SeekFirst( SvrObject * svrObj, char * target, MoaError *err )
{
	// Seek the data
	long seekErr = mData4.seek( target );
	if ( seekErr == r4success )
	{
		if ( mData4.deleted() )
		{
			SeekNext( svrObj, target, err );
		}
	}
	else
	{
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::SeekFirst
//		Seeks to the first undeleted record in index tag
//		This variation takes a numeric target
//++------------------------------------------------------------------------------
void DBCBTable::SeekFirst( SvrObject * svrObj, double target, MoaError *err )
{
	// Seek the data
	long seekErr = mData4.seek( target );
	if ( seekErr == r4success )
	{
		if ( mData4.deleted() )
		{
			SeekNext( svrObj, target, err );
		}
	}
	else
	{
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
	}
}
		


//++------------------------------------------------------------------------------
//	DBCBTable::SeekNext
//		Seeks to the next undeleted record in index tag
//		This variation takes a string target
//++------------------------------------------------------------------------------
void DBCBTable::SeekNext( SvrObject *, char * target, MoaError *err )
{
	do
	{
		int rc = mData4.seekNext( target );
		if ( rc == r4eof || rc == r4after || rc == r4entry )
		{
			*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
			break;
		}

		if (rc != r4success)
		{
			throw Exception( (char *) gStrODBDBError, COMMERR_SERV_INTERNAL_ERROR);
		}
	} while ( mData4.deleted() );
}



//++------------------------------------------------------------------------------
//	DBCBTable::SeekNext
//		Seeks to the next undeleted record in index tag
//		This variation takes a numeric target
//++------------------------------------------------------------------------------
void DBCBTable::SeekNext( SvrObject *, double target, MoaError *err )
{
	do
	{
		int rc = mData4.seekNext( target );
		if ( rc == r4eof || rc == r4after || rc == r4entry )
		{
			*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
			break;
		}

		if ( rc != r4success )
		{
			throw Exception( (char *) gStrODBDBError, COMMERR_SERV_INTERNAL_ERROR);
		}
	} while ( mData4.deleted() ); 
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetStrings
//		Get a list from multiple records in the database
//++------------------------------------------------------------------------------
void DBCBTable::GetStrings( const char * fieldToGet, long startRecNum, long endRecNum, BStringList & outStringList )
{
	MoaError err = kMoaErr_NoErr;
	GoToTop( &err );
	
	if ( err == kMoaErr_NoErr )
	{	// Move to the first one we want
		if ( startRecNum > 0 )
		{
			Skip( startRecNum - 1, &err );
		}

		//  Now get the remaining records
		long recordsToGet = endRecNum - startRecNum + 1;
		while ( err == kMoaErr_NoErr && recordsToGet > 0 )
		{
			BString tempStr;
			GetString( fieldToGet, tempStr );
			if ( err == kMoaErr_NoErr )
			{
				IMMEMTAG( "DBCBTable::GetStrings push_back" );
				outStringList.push_back( tempStr );
			}

			// Count and move to the next record
			recordsToGet--;
			if ( recordsToGet > 0 )
			{
				Skip( 1, &err );
			}
		}
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::GoToTop
//		Go to the top of the database
//++------------------------------------------------------------------------------
void DBCBTable::GoToTop( MoaError * err )
{
	int rc = mData4.top();

	while ( rc == r4success && !mData4.eof() )
	{
		if ( mData4.deleted()  )
		{	// Skip all the deleted records at the top
			rc = mData4.skip( 1 );
		}
		else
		{
			break;
		}
	}
	
	if ( rc == r4eof )				
	{	// Special case for file with no records
		rc = r4success;
	}

	if ( err )
	{
		if ( rc == r4success )
		{
			*err = kMoaErr_NoErr;
		}
		else
		{
			*err = COMMERR_SERV_INTERNAL_ERROR;
		}
	}
}


//++------------------------------------------------------------------------------
//	DBCBTable::Skip
//		Move around in the database
//++------------------------------------------------------------------------------
void DBCBTable::Skip( long numRecords, MoaError * err )
{
	int rc = r4success;
	while ( numRecords > 0 && !mData4.eof() )
	{
		rc = mData4.skip( 1 );
		if ( rc != r4success )
		{
			break;
		}
		if ( !mData4.deleted()  )
		{	// Only count undeleted records
			numRecords--;
		}
	}

	if ( err )
	{
		if ( rc == r4success )
		{
			*err = kMoaErr_NoErr;
		}
		else if ( rc == r4eof )
		{
			*err = COMMERR_SERV_BOFEOF;
		}
		else
		{
			*err = COMMERR_SERV_INTERNAL_ERROR;
		}
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetString
//		Get a string record from the database
//++------------------------------------------------------------------------------
void DBCBTable::GetString( const char * fldToGet, BString & outFieldContents )
{
	outFieldContents = "";
	Field4		fieldToGet( mData4, fldToGet );

	outFieldContents = fieldToGet.str();
	outFieldContents.TrimSpaces();
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetIDList
//		Builds a list of all the IDs from one field that match another
//++------------------------------------------------------------------------------
void DBCBTable::GetIDList( SvrObject * svrObj, 
								 const IDNUM idToMatch,
								 const char * tagToUse,
								 const char * fieldToGet,
								 IDList &attrIDList, 
								 MoaError *err )
{
	// Seek the data
	Select( tagToUse );
	SeekFirst( svrObj, idToMatch, err );

	if ( *err == kMoaErr_NoErr )
	{	// Got some ?  Add them all to the list
		Field4		fldWithID( mData4, fieldToGet );

		while ( *err == kMoaErr_NoErr )
		{
			// Save each ID we find on the list
			IMMEMTAG( "DBCBTable::GetIDList - attrIDList.push_back" );
			attrIDList.push_back( long( fldWithID ) );

			// Find the next one
			SeekNext( svrObj, idToMatch, err );
		}

		if ( *err == COMMERR_SERV_RECORD_DOESNT_EXIST )
		{	// If we got to the end of the file, that's not a problem
			*err = kMoaErr_NoErr;
		}
	}
	else
	{	// Didn't find the record, that's OK
		*err = kMoaErr_NoErr;
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetIDListWithoutIndex
//		Builds a list of all the IDs from one field that match another.
//		This uses a brute force search since we don't have an index for this data.
//++------------------------------------------------------------------------------
void DBCBTable::GetIDListWithoutIndex( SvrObject *svrObj, 
								 const IDNUM idToMatch,
								 const char * fieldToSearch,
								 const char * fieldToGet,
								 IDList &attrIDList, 
								 MoaError *err )
{
	// Start at the top
	int rc = mData4.top();
	if ( rc == r4eof )				// Special case for file with no records
		rc = r4success;

	if ( rc == r4success )
	{
		Field4		fldToSearch( mData4, fieldToSearch );
		Field4		fldWithID( mData4, fieldToGet );

		while ( !mData4.eof() )
		{
			if ( !mData4.deleted() && idToMatch == long( fldToSearch ) )
			{
				// Save each ID we find on the list
				IMMEMTAG( "DBCBTable::GetIDListWithoutIndex - attrIDList.push_back" );
				attrIDList.push_back( long( fldWithID ) );
			}
			rc = mData4.skip( 1 );
			if ( rc != r4success )
			{	// If we got to the end of file, clear the error code
				if( rc == r4eof )
				{
					rc = r4success;
				}
				break;
			}
		}
	}

	if ( rc != r4success )
	{
		*err = COMMERR_SERV_INTERNAL_ERROR;
	}
	else
	{	// Didn't find the record, that's OK
		*err = kMoaErr_NoErr;
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::FindFirstWithoutIndex
//++------------------------------------------------------------------------------
void DBCBTable::FindFirstWithoutIndex( SvrObject *, double target, const char * fieldToSearch, MoaError *err )
{
	// Start at the top
	int rc = mData4.top();

	if ( rc == r4success )
	{
		Field4		fldToSearch( mData4, fieldToSearch );

		while ( !mData4.eof() )
		{
			if ( !mData4.deleted() && target == double( fldToSearch ) )
			{	// Found it, so exit the loop
				break;
			}
			rc = mData4.skip( 1 );
			if ( rc != r4success )
			{
				if( rc == r4eof )
				{
					rc = r4success;
				}
				break;
			}
		}
	}

	if ( mData4.eof() )
	{	// Couldn't find the record
		*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
	}
	else if ( rc != r4success )
	{	// Something screwed up
		*err = COMMERR_SERV_INTERNAL_ERROR;
	}
	else
	{	// Must have found it OK
		*err = kMoaErr_NoErr;
	}
}


//++------------------------------------------------------------------------------
//	DBCBTable::DeleteRecord
//++------------------------------------------------------------------------------
void DBCBTable::DeleteRecord(SvrObject *svrObj, MoaError *err)
{
	LockRecord(err);
	if (*err != kMoaErr_NoErr)
		return;

	mData4.deleteRec();

	mDeleteCount--;		// Use negative numbers for the delete counter
	ZapIndexField();

	UnlockRecord(err);
}



//++------------------------------------------------------------------------------
//	DBCBTable::ZapNumericIndexField
//++------------------------------------------------------------------------------
void DBCBTable::ZapNumericIndexField( const char * fldName )
{
	Field4 field1( mData4, fldName );
	field1.assignLong( mDeleteCount );	// mDeleteCount is a negative number
}



//++------------------------------------------------------------------------------
//	DBCBTable::ZapTextIndexField
//		Replace the contents of the given field with something unique
//++------------------------------------------------------------------------------
void DBCBTable::ZapTextIndexField( const char * fldName )
{
	BString newValue;
	GetZappedTextFieldString( newValue );

	Field4 field1( mData4, fldName );
	field1.assign( newValue );
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetZappedTextFieldString
//		Return the text we stuff into a deleted record's string index field
//		This must be unique, so we make it like "!-1", "!-2", "!-3", etc.
//++------------------------------------------------------------------------------
void DBCBTable::GetZappedTextFieldString( BString & outString )
{
	outString = "!";

	BString temp;
	temp.SetToInteger( mDeleteCount );	// mDeleteCount is a negative number

	outString += temp;
}



//++------------------------------------------------------------------------------
//	DBCBTable::UnlockRecord - unlock the current record
//++------------------------------------------------------------------------------
void DBCBTable::UnlockRecord( MoaError * err )
{
	int rc = mData4.unlock();
	if (rc != r4success)
	{
#ifdef DEBUG
		{
			char msg[100];
			sprintf(msg, "DBCBTable::UnlockRecord() - unlock() returned %d\n",
							rc);
			DebugStr_(msg);
		}
#endif
		*err = COMMERR_SERV_CANT_WRITE_DATABASE;
		return;
	}
}



//++------------------------------------------------------------------------------
//	DBCBTable::LockRecord - lock the current record
//++------------------------------------------------------------------------------
void DBCBTable::LockRecord( MoaError * err )
{
	// locks the current record
	long recno = mData4.recNo();
	if (recno <= 0)
	{
#ifdef DEBUG
		{
			char msg[100];
			sprintf(msg, "DBCBTable::LockRecord() - recNo() returned %d\n",
							recno);
			DebugStr_(msg);
		}
#endif
		*err = COMMERR_SERV_INTERNAL_ERROR;
		return;
	}

	int rc = mData4.lock( recno );
	if (rc != r4success)
	{
#ifdef DEBUG
		{
			char msg[100];
			sprintf(msg, "DBCBTable::LockRecord() - lock() returned %d\n",
							rc);
			DebugStr_(msg);
		}
#endif
		*err = COMMERR_SERV_RECORD_NOT_LOCKED;
		return;
	}
}




//++------------------------------------------------------------------------------
//	DBCBTable::GetDeletedOrNewRecord - get any deleted record, or append
//		a new one.  Leave the record locked and blank.
//++------------------------------------------------------------------------------
bool DBCBTable::GetDeletedOrNewRecord( SvrObject * svrObj, MoaError * err )
{
	bool foundDeleted = true;

	if ( mDeleteCount < 0 )		// mDeleteCount is a negative number
	{	// Find a deleted record
		long seekErr = 0;

		if ( mIndexIsString )
		{
			BString targetStr;
			GetZappedTextFieldString( targetStr );
			seekErr = mData4.seek( targetStr );
		}
		else
		{	// Seek the proper number
			seekErr = mData4.seek( mDeleteCount );
		}

		Assert_( mData4.deleted() );
		Assert_( seekErr == r4success );

		if ( seekErr == r4success )
		{
			mDeleteCount++;		// mDeleteCount is a negative number
			LockAndBlank( err );
		}
		else
		{	// We really shouldn't get here...
			*err = COMMERR_SERV_RECORD_DOESNT_EXIST;
		}
	}
	else
	{	// There are no deleted records, so append a new blank one
		foundDeleted = false;

		int rc = mData4.appendBlank();
		if (rc == r4success)
		{
			*err = kMoaErr_NoErr;
			LockRecord( err );
		}
		else
		{
			#ifdef DEBUG
			char msg[100];
			sprintf(msg, "DBCBTable::GetDeletedOrNewRecord() - appendBlank() returned %d\n", rc);
			DebugStr_(msg);
			#endif
			*err = COMMERR_SERV_INTERNAL_ERROR;
		}
	}

	return foundDeleted;
}




//++------------------------------------------------------------------------------
//	DBCBTable::LockAndBlank
//++------------------------------------------------------------------------------
void DBCBTable::LockAndBlank( MoaError * err )
{
	LockRecord( err );
	if ( *err == kMoaErr_NoErr )
	{
		mData4.blank();
	}
}


//++------------------------------------------------------------------------------
//	DBCBTable::Compress
//++------------------------------------------------------------------------------
void DBCBTable::Compress( void )
{
	int	rc = mData4.lockAll();
	if (rc == r4success)
	{
		rc = mData4.pack();
		mDeleteCount = 0;
	}

	if (rc == r4success)
	{
		rc = mData4.memoCompress();
	}

	if (rc == r4success)
	{
		rc = mData4.unlock();
	}

	if (rc != r4success)
	{
		throw Exception((char *) gStrODBAccessErr, COMMERR_SERV_CANT_READ_DATABASE);
	}
}


//++------------------------------------------------------------------------------
//	DBCBTable::UpdateFileStructure
//		Default implementation does nothing
//++------------------------------------------------------------------------------
void DBCBTable::UpdateFileStructure( void )
{
}


//++------------------------------------------------------------------------------
//	DBCBTable::RemoveTag
//++------------------------------------------------------------------------------
void DBCBTable::RemoveTag( const char * tagName )
{
	if ( mUpdateStatus != kTableUpdateNo )
	{
		// Try and find a tag with this name
		Tag4	tag( mData4, tagName );
		if ( tag.isValid() )
		{	// We found it, so remove the tag from the file
			Tag4info	tagInfo( mData4 );
			long rc = tagInfo.del( tagName );
			Assert_( rc == r4success );

			// We have to close and re-open with proper access.
			rc = mData4.close();
			if ( rc == r4success )
			{	// Open with sole access
				Code4	*code4 = getDBConnection()->getCode4();
				AssertNotNull_( code4 );

				long saveAccessMode = c4getAccessMode( code4 );
				c4setAccessMode( code4, OPEN4DENY_RW );	// Don't allow multiple usage

				long saveSafety = c4getSafety( code4 );
				c4setSafety( code4, false );

				c4setAutoOpen( code4, false );	// Don't automatically open index files.

				rc = mData4.open( *code4, mFileName );
				if ( rc == r4success )
				{
					Index4 newIndex;
					Tag4info newTagInfo( *code4 );

					MakeTagInfo( newTagInfo );
			   		rc = newIndex.create( mData4, newTagInfo );

					long ignoreError = mData4.close();		// Close the datbase 
				}

				c4setAccessMode( code4, saveAccessMode );	// Restore access mode.
				c4setSafety( code4, saveSafety );
				c4setAutoOpen( code4, true );				// Automatically open index files.

				// Now reopen with normal modes.
				if ( rc == r4success )
				{
					rc = mData4.open( *code4, mFileName );
				}
			}

			// Set the update status
			mUpdateStatus = kTableUpdateYes;
		
			Compress();
		}
		else
		{	// Can't find the tag, so we don't need other updates
			mUpdateStatus = kTableUpdateNo;
		}
	}
	
	// In any case, reset errors
	getDBConnection()->getCode4()->errorSet();
}


//++------------------------------------------------------------------------------
//	DBCBTable::UppercaseField
//++------------------------------------------------------------------------------
void DBCBTable::UppercaseField( const char * fieldName )
{
	// Since there is no easy way to tell if a field needs to be
	// converted to upper case, we check the status.  The RemoveTag
	// function should be called before this one.  This isn't the 
	// prettiest way to do it, but it seems to work...

	if ( mUpdateStatus == kTableUpdateYes )
	{
		Field4		fldWithString( mData4, fieldName );
		BString		value;

		long rc = mData4.go( 1 );		// Go to the first record
		while ( rc == r4success && !mData4.eof() )
		{
			long recno = mData4.recNo();
			rc = mData4.lock( recno );
			if ( rc == r4success )
			{
				// Get and convert the contents to upper case
				value = fldWithString.str();
				value.ConvertToUpperCase();
			
				rc = fldWithString.assign( value );
				
				if ( rc == r4success )
				{
					rc = mData4.skip( 1 );		// Move to the next record
				}

				mData4.unlock();
			}
		}
	}

	getDBConnection()->getCode4()->errorSet();		// reset error
}



//++------------------------------------------------------------------------------
//	DBCBTable::GetUndeletedRecordCount
//++------------------------------------------------------------------------------
long DBCBTable::GetUndeletedRecordCount( MoaError * err )
{ 
	// mDeleteCount is a negative number or zero
	long numRecords = mData4.recCount() + mDeleteCount;
	if ( numRecords < 0 && err != NULL )
	{
		numRecords = 0;
		*err = COMMERR_SERV_INTERNAL_ERROR;
	}

	return numRecords;
}

