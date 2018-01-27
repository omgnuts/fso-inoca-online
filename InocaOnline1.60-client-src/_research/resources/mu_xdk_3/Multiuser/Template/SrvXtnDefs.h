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
* Filename:   SrvXtnDefs.h
* Purpose:    Definitions specific to this xtra
****************************************************************************/

#ifndef _H_SrvXtnDefs
#define _H_SrvXtnDefs


/*****************************************************************************
 *  XTRA SPECIFIC DEFINE(S)
 *  -----------------------
 *	Any #define's specific to this Xtra.
 *****************************************************************************/

// These are command numbers that correspond to the commands your xtra will recognize
enum
{
	kCmdSayHello = 0,
	kCmdEcho
};


// Modify this to set the commands you xtra will respond to.

// If you want an complete match, begin the line with a plus "+"
// If you want to only match the start of message recipients, use
// the asterix "*" at the beginning of the line.
static char userIDTable[] =
{
	"+ System.Hello.Say\n"
	"+ System.Hello.Echo"
};


// Modify this to name the xtra
#define		ServerXtraName		"HelloWorld"


#endif
