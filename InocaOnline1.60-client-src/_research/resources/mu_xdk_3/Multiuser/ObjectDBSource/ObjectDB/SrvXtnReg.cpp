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


/****************************************************************************
/ Filename
/   SrvXtnReg.cpp
/
/
/ Purpose:
/   Server extension registration
/	class definition for the CSrvXtnReg class
/
//  
//
*/  


/*****************************************************************************
 *  INCLUDE FILE(S)
 *  ---------------
 *	This .cpp file should automatically include all the support files needed
 *	for this particular class. In addition, this file may include other .h
 *	files defining additional callback interfaces for use by a third party.   
 ****************************************************************************/ 

#if defined( WINDOWS )
#include	"SrvXtnPrecompile.h"
#endif



#ifndef	MMISERVC_H
	#include "mmiservc.h"
#endif

#include "SWServerXtra.h"
#include "SrvXtnReg.h"


/*****************************************************************************
 *  INTERNAL PROTOTYPES(S)
 *  ----------------------
 *  Declarations for functions used specifically in this file.
 ****************************************************************************/

/*****************************************************************************
 *  INTERNAL ROUTINE(S)
 *  -------------------
 *  Definition of file-specific functions
 ****************************************************************************/

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
BEGIN_DEFINE_CLASS_INTERFACE(CSrvXtnReg, IMoaRegister) 
END_DEFINE_CLASS_INTERFACE

/*****************************************************************************
 *  Data needed for Registering
 *	---------------------------
 *	Server extensions need to register information for the server
 *
 *	kSrvXtraName	String - contains the xtra name
 *	kSrvXtraUserID	String - contains the user ID for the xtra
 *
 *	These values can be set by changing the definitions below
 *
 *****************************************************************************/ 



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

/* ---------------------------------------------------- MoaCreate_SrvXtnReg */
STDMETHODIMP MoaCreate_CSrvXtnReg(CSrvXtnReg FAR * This)
{
	UNUSED(This);
	X_ENTER

	MoaError		err = kMoaErr_NoErr;

	X_RETURN(MoaError, err);	
	X_EXIT
}

/* --------------------------------------------------- MoaDestroy_SrvXtnReg */
STDMETHODIMP_(void) MoaDestroy_CSrvXtnReg(CSrvXtnReg FAR * This)
{
	UNUSED(This);
	X_ENTER


	X_RETURN_VOID;
	X_EXIT
}

/* ---------------------------------- CSrvXtnReg_IMoaRegister Create/Destroy */
CSrvXtnReg_IMoaRegister::CSrvXtnReg_IMoaRegister(MoaError FAR * pErr)
{ 
	*pErr = (kMoaErr_NoErr); 
}


CSrvXtnReg_IMoaRegister::~CSrvXtnReg_IMoaRegister() 
{
}



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
 *****************************************************************************/ 

/* ------------------------------------------- CSrvXtnReg_IMoaRegister::Register */
STDMETHODIMP_(MoaError) CSrvXtnReg_IMoaRegister::Register(PIMoaCache pCache, 
	PIMoaDict pXtraDict)
{
	X_ENTER

	MoaError 	err = kMoaErr_NoErr;
	PIMoaDict 	pRegDict;

	// Create a new registry entry
	err = pCache->AddRegistryEntry(pXtraDict, &CLSID_CSrvXtn, &IID_IMoaSWServerExtension, &pRegDict);
			
	if ( err == kMoaErr_NoErr)
	{
		// Register the xtra's name
		err = pRegDict->Put(kMoaDictType_CString, ServerXtraName, 0, kSrvXtnName);
	}

    if ( err == kMoaErr_NoErr )
    {
		// Register the xtra's userID
		err = pRegDict->Put( kMoaDictType_CString, userIDTable, 0, kSrvXtnUserIDs );
    }

	X_STD_RETURN(err);
	X_EXIT
}
