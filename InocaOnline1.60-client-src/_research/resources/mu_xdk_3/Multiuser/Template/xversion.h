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
 *		Filename:   xversion.h
 *		Purpose:    Set the major and minor version strings for the server  
 *					extension xtra.
 ***************************************************************************/


#define	VER_FILETYPE				VFT_DLL

/////////////////////////////////////////////////////////////////////////////
//
// PER-PRODUCT CUSTOMIZATION
//
//    Edit the items in this section for each product.
//
/////////////////////////////////////////////////////////////////////////////
//  Server extension Xtra developers should replace any instances of
//  "Template Xtra" with their xtra's name.

#define	VER_PRODUCTNAME				"Shockwave Multiuser Server Template Xtra"

/////////////////////////////////////////////////////////////////////////////
//
// PER-RELEASE CUSTOMIZATION
//
//    Edit the items in this section for each release.
//
/////////////////////////////////////////////////////////////////////////////

#define	VER_MAJORVERSION			 1
#define	VER_MAJORVERSION_STRING		"1"
#define	VER_MINORVERSION			 0
#define	VER_MINORVERSION_STRING		"0"
#define	VER_BUGFIXVERSION			 0
#define	VER_BUGFIXVERSION_STRING	"0"


// Include the common Mars version file.
#include	"CommonVersion.h"

#undef	VER_BUILDNUM
#undef  VER_BUILDNUM_STRING
#include	"dversion.h"

/////////////////////////////////////////////////////////////////////////////
//
// PER-COMPONENT CUSTOMIZATION
//
//    Edit the items in this section for each executable or library built.
//
/////////////////////////////////////////////////////////////////////////////
//
//Multiuser Server Xtra developers should replace the following
//template filenames with the name of their xtra:
//       VER_COMPONENTNAME
//       VER_WINFILENAME
//       VER_MINMODULENAME

#define	VER_COMPONENTNAME			"XDK Template Xtra"

#ifdef	WIN16
	#error There is no Win16 build !
#else
	#define	VER_WINFILENAME			"TemplateXtra.x32"
	#define	VER_MINMODULENAME		"TemplateXtra"
#endif


