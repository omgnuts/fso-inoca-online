/*==========================================================================\
|                                                                           |
|                     Copyright 1999 Macromedia, Inc.                  |
|                                                                           |
|      This material is the confidential trade secret and proprietary       |
|      information of Macromedia, Inc.  It may not be reproduced, used,     |
|      sold or transferred to any third party without the prior written     |
|      consent of Macromedia, Inc.  All rights reserved.                    |
|                                                                           |
\==========================================================================*/


/****************************************************************************
/ Filename
/   SrvXtnDefs.h
/
/ Version:
/   $Revision: 1 $
/
/ Purpose:
/   Definitions specific to this xtra
/
//	Change History (most recent first):
//	===================================
//  $Log: /Mars/ServerXtras/ServerAttrs/SrvXtnDefs.h $
/   
/   1     7/06/99 5:08p Dsimmons
/   
//
/
*/  


#ifndef _H_SrvXtnDefs
#define _H_SrvXtnDefs
												


/*****************************************************************************
 *  XTRA SPECIFIC DEFINE(S)
 *  -----------------------
 *	Any #define's specific to this Xtra.  
 *****************************************************************************/ 


// This lists the commands this xtra responds to.
// Modify this to set the userIDs you xtra will respond to.  List
// multiple names with a space between them.
#define DBApp		"System.DBApplication."
#define DBAppData	"System.DBApplicationData."
#define DBPlayer	"System.DBPlayer."
#define DBUser		"System.DBUser."
#define DBAdmin		"System.DBAdmin."


// Modify this to set the commands you xtra will respond to.
static char userIDTable[] = 
{
	"* "	DBAdmin		"\n"
	"* "	DBUser		"\n"
	"* "	DBApp		"\n"
	"* "	DBAppData	"\n"
	"* "	DBPlayer	"\n"
	"*      System"
};



// Modify this to name the xtra
#define		ServerXtraName		"DatabaseObjects"


#endif 
