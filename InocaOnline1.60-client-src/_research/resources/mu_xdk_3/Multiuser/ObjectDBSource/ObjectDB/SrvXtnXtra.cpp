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
/   SrvXtnXtra.cpp
/
 Purpose:
/     
/	This file contains the member declarations for the CSrvXtn class,
/	which is the heart of the community client Xtra.
/
/
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

#include "SrvXtnGUIDs.h"
#include "SrvExtension.h"
#include "SrvXtnReg.h"
#include "xversion.h"


/*****************************************************************************
 *  XTRA DEFINITION
 *  ---------------
 *  The Xtra definition specfies the classes and interfaces defined by your
 *  MOA Xtra.
 *
 *  Syntax:
 *	BEGIN_XTRA_DEFINES_CLASS(<class-name>,<version>)
 *	CLASS_DEFINES_INTERFACE(<class-name>, <interface-name>,<version>) 
 ****************************************************************************/ 
BEGIN_XTRA

	BEGIN_XTRA_DEFINES_CLASS(CSrvXtnReg, XTRA_INTERNAL_VER_NUMBER)
		CLASS_DEFINES_INTERFACE(CSrvXtnReg, IMoaRegister, XTRA_INTERNAL_VER_NUMBER)
	END_XTRA_DEFINES_CLASS
	
	BEGIN_XTRA_DEFINES_CLASS(CSrvXtn, XTRA_INTERNAL_VER_NUMBER)
		CLASS_DEFINES_INTERFACE(CSrvXtn, IMoaSWServerExtension, XTRA_INTERNAL_VER_NUMBER)		
	END_XTRA_DEFINES_CLASS
	
END_XTRA

