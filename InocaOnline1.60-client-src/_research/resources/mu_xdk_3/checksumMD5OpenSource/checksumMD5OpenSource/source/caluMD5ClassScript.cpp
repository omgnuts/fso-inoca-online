/*****************************************************************************
 * Copyright © 1994-1999 Macromedia, Inc.  All Rights Reserved
 *
 * You may utilize this source file to create and compile object code for use 
 * within products you create.  THIS CODE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, AND MACROMEDIA DISCLAIMS ALL IMPLIED WARRANTIES 
 * INCLUDING, BUT NOT LIMITED TO, MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT.  IN NO EVENT WILL MACROMEDIA BE LIABLE TO YOU 
 * FOR ANY CONSEQUENTIAL, INDIRECT OR INCIDENTAL DAMAGES ARISING OUT OF YOUR 
 * USE OR INABILITY TO USE THIS CODE.
 *
 *	Name: caluMD5ClassScript.cpp
 *	
 * 	Purpose: Definitions of scripting class interface(s) and methods for the 
 *           Scripting Xtra skeleton project.
 *
 *
 *  HOW TO CUSTOMIZE THIS FILE
 *  --------------------------
 *  1. Save this file under a different file name.
 *  2. Use a search and replace utility (case sensitive) to replace the
 *     following:
 *
 *     Replace         With	
 *     -------         ----
 *     caluMD5ClassScript      <this file name>
 *     caluMD5Class      <name of the class you defined>
 *
 *  3. Add and modify source code by looking for '--> insert -->' comment
 ****************************************************************************/ 

/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 *	This .cpp file should automatically include all the support files needed
 *	for this particular class. In addition, this file may include other .h
 *	files defining additional callback interfaces for use by a third party.   
 ****************************************************************************/ 
#ifndef _H_caluMD5ClassScript
	#include "caluMD5ClassScript.h"
#endif

#ifdef MACINTOSH
	// consider testing this on the mac later. calu. 12.30.02
	#include <windows.h>
	#include <string.h>
#endif

// #include <string>

#define MAX_PATH_SIZE	260 // the max path size allowed 
#define MAX_STRING_SIZE	255
#define MY_BUF_SIZE		32

#include "caluMD5_utilities.h"

/*****************************************************************************
 *  Private Methods
 *  -------------------
 *  Implementation of Private Class Methods
 ****************************************************************************/

/* ------------------------------------------------------ XScrpChildHandler */
MoaError caluMD5Class_IMoaMmXScript::XX_caluFileMD5(PMoaDrCallInfo callPtr)
{
	// gets MD5 value from a file	
	MoaError err = kMoaErr_NoErr;	

	// external data types
	CString md5 = "";

	// macromedia data types
	MoaChar caluMoaChar_filePath[MAX_PATH_SIZE];
	MoaMmValue argList;
	MoaLong bufferlen = 0;

	// set error
	setFileHashingError(0);
	
	GetArgByIndex(2, &argList);
	pObj->pMmValue->ValueStringLength(&argList, &bufferlen);	

	// check that user don't pass in really long string
	if ( bufferlen > MAX_PATH_SIZE ) {
		setFileHashingError(-1);
		pObj->pMmValue->StringToValue(md5, &callPtr->resultValue);
		return err;
	}
	
	// +1 for trailing null character
	pObj->pMmValue->ValueToString(&argList, caluMoaChar_filePath, bufferlen+1);

	// consider using InitFromString if we find a error

	// set the file path
	if ((err = pObj->pMoaFile->SetSpec(caluMoaChar_filePath)) != kMoaErr_NoErr) {
		setFileHashingError(-2);
		pObj->pMmValue->StringToValue(md5, &callPtr->resultValue);
		return err;
	}
	// weird in that pObj->pMoaFile->IsDirectory() will return false for "c:\"
	if ( bufferlen <= 3 ){
		setFileHashingError(-2);
		pObj->pMmValue->StringToValue(md5, &callPtr->resultValue);
		return err;
	}

	// check if file exist
	if (pObj->pMoaFile->IsExisting()) {
		// check that isExisting wasn't pointing to a directory
		if ( pObj->pMoaFile->IsDirectory() == FALSE ){
			try 
			{
				md5 = CMD5Checksum::GetMD5(caluMoaChar_filePath);	
			}
			//
			catch(...)
			{
				setFileHashingError(-4);
				md5 = "";
			}
		}
	}

	// always return md5.  if error on code we will return empty string
	pObj->pMmValue->StringToValue(md5, &callPtr->resultValue);
	return err;

}

MoaError caluMD5Class_IMoaMmXScript::XX_caluStringMD5(PMoaDrCallInfo callPtr)
{
	
	MoaError err = kMoaErr_NoErr;	
	CString md5_returnValue = "";
	BYTE* md5required;
	const MoaChar* hashingSourceText;
	MoaLong bufferlen = 0;
	MoaMmValue value;

	// file hashing error
	setFileHashingError(0);
	
	// get length
	GetArgByIndex(2, &value);	
	pObj->pMmValue->ValueStringLength(&value, &bufferlen);	

	// get the pointer to the string array. CONST
	pObj->pMmValue->ValueToStringPtr( &value, &hashingSourceText);

	// copy char array into BYTE array
	md5required = new BYTE[bufferlen+1];
	memcpy(md5required,hashingSourceText,bufferlen+1);

	// call external md5 function
	md5_returnValue = CMD5Checksum::GetMD5( md5required, bufferlen);

	// release array
	delete [] md5required;

	pObj->pMmValue->ValueReleaseStringPtr(&value);

	// return value
	pObj->pMmValue->StringToValue(md5_returnValue, &callPtr->resultValue);
	
	return err;

}

MoaError caluMD5Class_IMoaMmXScript::XX_caluLastErrorInt(PMoaDrCallInfo callPtr)
{
	
	MoaError err = kMoaErr_NoErr;	
	int hashError = 0;
	hashError =	getFileHashingError();

	pObj->pMmValue->IntegerToValue(hashError, &callPtr->resultValue);
	
	return err;

}

MoaError caluMD5Class_IMoaMmXScript::XX_caluRegister(PMoaDrCallInfo callPtr)
{
	MoaError err = kMoaErr_NoErr;	
	bool registeredSuccessfully = true;

	// Chieh An Lu, 11/9/2003
	// removed the registration code prior to making this open source
	pObj->pMmValue->IntegerToValue(registeredSuccessfully, &callPtr->resultValue);	

	return err;
}

/*****************************************************************************
 *  CLASS INTERFACE(S)
 *  ------------------
 *  The interface(s) implemented by your MOA class are specified here.  Note
 *	that at least one class in your Xtra should implement the IMoaRegister
 *	interface.
 *  NOTE: Because C++ does not use a lpVtbl to reference an interface's
 *	methods, the actual method declaration is done in the .h file.
 *
 *  Syntax:
 *  BEGIN_DEFINE_CLASS_INTERFACE(<class-name>, <interface-name>) 
 ****************************************************************************/ 
BEGIN_DEFINE_CLASS_INTERFACE(caluMD5Class, IMoaMmXScript)
END_DEFINE_CLASS_INTERFACE

#ifdef USING_INIT_FROM_DICT
BEGIN_DEFINE_CLASS_INTERFACE(caluMD5Class, IMoaInitFromDict)
END_DEFINE_CLASS_INTERFACE
#endif

#ifdef USING_NOTIFICATION_CLIENT
BEGIN_DEFINE_CLASS_INTERFACE(caluMD5Class, IMoaNotificationClient)
END_DEFINE_CLASS_INTERFACE
#endif

/*
 * --> insert additional method(s) -->
 */
 
/*****************************************************************************
 *  CREATE AND DESTROY METHODS
 *  --------------------------
 *  Every interface and class has an associated 'Create' and 'Destroy' pair.
 *  'Create' methods are typically used to acquire interface(s), allocate 
 *  memory, and intialize variables. 'Destroy' methods are typically used to 
 *  release interfaces and free memory.
 *
 * NOTE:  In C++, the local variable 'This' is provided implicitly within 
 * a method implementation.  Thus, there is no need explicitly declare 'This' 
 * as a function parameter. However, this implementation detail doesn’t apply 
 * to the MOA class creator and destructor functions, which are standard C 
 * functions, coded exactly as in like they are in C examples.  
 *
 * Class Syntax:
 * STDMETHODIMP MoaCreate_<class-name>(<class-name> FAR * This)
 * STDMETHODIMP MoaDestroy_<class-name>(<class-name> FAR * This)
 *
 * Interface Syntax:
 * <class_name>_<if_name>::<class_name>_<if_name>(MoaError FAR * pErr)
 * <class_name>_<if_name>::~<class_name>_<if_name>()
 ****************************************************************************/ 

/* ------------------------------------------------------ MoaCreate_caluMD5Class */
STDMETHODIMP MoaCreate_caluMD5Class(caluMD5Class FAR * This)
{
	UNUSED(This);

	/* variable declarations */
	MoaError err = kMoaErr_NoErr;
	
	This->pCallback->QueryInterface(&IID_IMoaMmValue, (PPMoaVoid)&This->pMmValue);
	This->pCallback->MoaCreateInstance(&CLSID_CMoaFile2, &IID_IMoaFile2,(PPMoaVoid)&This->pMoaFile);

	if(  !This->pMoaFile || !This->pMmValue )
	{
		err = kMoaErr_BadInterface;		
	}

	return(err);
}

/* ----------------------------------------------------- MoaDestroy_caluMD5Class */
STDMETHODIMP_(void) MoaDestroy_caluMD5Class(caluMD5Class FAR * This)
{
	UNUSED(This);
	
	if (This->pMmValue) 
	{
		This->pMmValue->Release();
		This->pMmValue = NULL;
	}	
	
	if (This->pMoaFile) This->pMoaFile->Release();
	This->pMoaFile = NULL;

	return;
}

/* ----------------------------------- caluMD5Class_IMoaMmXScript Create/Destroy */
caluMD5Class_IMoaMmXScript::caluMD5Class_IMoaMmXScript(MoaError FAR * pErr)
	{ *pErr = (kMoaErr_NoErr); }
caluMD5Class_IMoaMmXScript::~caluMD5Class_IMoaMmXScript() {}

#ifdef USING_INIT_FROM_DICT
/* -------------------------------- caluMD5Class_IMoaInitFromDict Create/Destroy */
caluMD5Class_IMoaInitFromDict::caluMD5Class_IMoaInitFromDict(MoaError FAR * pErr)
	{ *pErr = (kMoaErr_NoErr); }
caluMD5Class_IMoaInitFromDict::~caluMD5Class_IMoaInitFromDict() {}
#endif

#ifdef USING_NOTIFICATION_CLIENT
/* -------------------------- caluMD5Class_IMoaNotificationClient Create/Destroy */
caluMD5Class_IMoaNotificationClient::caluMD5Class_IMoaNotificationClient(MoaError FAR * pErr)
	{ *pErr = (kMoaErr_NoErr); }
caluMD5Class_IMoaNotificationClient::~caluMD5Class_IMoaNotificationClient() {}
#endif

/*
 * --> insert additional create/destroy method(s) -->
 */

/*****************************************************************************
 *  METHOD IMPLEMENTATION(S)
 *  ------------------------
 *  This is where the methods to be defined by your MOA class are implemented.
 *  The bulk of the work in implementing Xtras is done here.  NOTE: 'This' is 
 *  implemented implicitly in C++, therefore it isn't used in the argument-
 *	list.
 *
 *  Syntax:
 *  STDMETHODIMP <class-name>_<interface-name>::<method-name>(<argument-list>)
 ****************************************************************************/ 

/* -------------------------------------------- caluMD5Class_IMoaMmXScript::Call */
STDMETHODIMP caluMD5Class_IMoaMmXScript::Call(PMoaMmCallInfo callPtr)
{

	/* variable declarations */
	MoaError err = kMoaErr_NoErr;
	
	switch	( callPtr->methodSelector ) 
	{
		case m_new:
			break;

		case m_fileGetMD5:
			err = XX_caluFileMD5(callPtr);
			break;
		

		case m_getStringMD5:
			err = XX_caluStringMD5(callPtr);
			break;

		case m_getLastError:
			err = XX_caluLastErrorInt(callPtr);
			break;

		case m_caluMD5_register:
			err = XX_caluRegister(callPtr);
			break;
	}

	return(err);
}

#ifdef USING_INIT_FROM_DICT
/* --------------------------------- caluMD5Class_IMoaInitFromDict::InitFromDict */
STDMETHODIMP caluMD5Class_IMoaInitFromDict::InitFromDict(PIMoaRegistryEntryDict pRegistryDict)
{
	UNUSED(pRegistryDict);
	
	/* variable declarations */
	MoaError err = kMoaErr_NoErr;

	return(err);
}
#endif

#ifdef USING_NOTIFICATION_CLIENT
/* --------------------------------- caluMD5Class_IMoaNotificationClient::Notify */
STDMETHODIMP caluMD5Class_IMoaNotificationClient::Notify(ConstPMoaNotifyID nid, PMoaVoid pNData, PMoaVoid pRefCon)
{
	UNUSED(nid);
	UNUSED(pNData);
	UNUSED(pRefCon);
	
	/* variable declarations */
	MoaError err = kMoaErr_NoErr;

	return(err);
}
#endif

