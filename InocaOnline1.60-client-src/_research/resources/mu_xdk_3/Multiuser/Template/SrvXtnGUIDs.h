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
****************************************************************************/

#ifndef H_SrvXtnGUIDS
#define H_SrvXtnGUIDS

/****************************************************************************
/ Filename
/   SrvXtnGUIDSs.h
/
/ Purpose:
/   GUID definitions
/
/
******************************************************************************/
#include	"moaxtra.h"



// You will need to create your own GUIDs with GuidGen from VC++.   Copy them
// into this file and replace the name with CLSID_CSrvXtn and CLSID_CSrvXtnReg.


// {31BA5923-66EF-11d4-8C20-00104BED44B0}
DEFINE_GUID(CLSID_CSrvXtn, 0x31ba5923, 0x66ef, 0x11d4, 0x8c, 0x20, 0x0, 0x10, 0x4b, 0xed, 0x44, 0xb0);

// {31BA5925-66EF-11d4-8C20-00104BED44B0}
DEFINE_GUID(CLSID_CSrvXtnReg, 0x31ba5925, 0x66ef, 0x11d4, 0x8c, 0x20, 0x0, 0x10, 0x4b, 0xed, 0x44, 0xb0);

#endif H_SrvXtnGUIDS
