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
/////////////////////////////////////////////////////////////////////////////
//
//	$Workfile: CommonVersion.h $
//
//	$Revision: 11 $
//
/////////////////////////////////////////////////////////////////////////////


#ifndef VER_RELEASESTAGE_FINAL
#define VER_RELEASESTAGE_PREALPHA	0x20
#define VER_RELEASESTAGE_ALPHA		0x40
#define VER_RELEASESTAGE_BETA		0x60
#define VER_RELEASESTAGE_FINAL		0x80
#endif



#define	VER_COPYRIGHTYEAR			"1998-2000"

/////////////////////////////////////////////////////////////////////////////
//
// PER-BUILD CUSTOMIZATION
//
//    Edit the items in this section before each build.
//
/////////////////////////////////////////////////////////////////////////////
// Use one of the following:
//		VER_RELEASESTAGE_PREALPHA	
//		VER_RELEASESTAGE_ALPHA
//		VER_RELEASESTAGE_BETA
//		VER_RELEASESTAGE_FINAL
#define VER_RELEASESTAGE		VER_RELEASESTAGE_BETA

// This defines a public release number, like "Beta 2"
#define VER_RELEASENUM			 1
#define VER_RELEASENUM_STRING	"1"


// Increment VER_BUILDNUM for each build.  The build number increases
// throughout an entire release -- it should _not_ be reset when the 
// release stage changes.
//
#if ( VER_RELEASESTAGE != VER_RELEASESTAGE_FINAL )
	#define VER_BUILDNUM			 1
	#define VER_BUILDNUM_STRING		"1"
#else
	#define VER_BUILDNUM			 0
	#define VER_BUILDNUM_STRING		"0"
#endif



/*****************************************************************************
 *	Internal version definition
 *	------------------
 *	Generates the internal version number used in xtra.cpp
 ****************************************************************************/ 
#define MAKE_VERSION(major, minor, sub, releaseType, releaseVersion) \
	                  (unsigned long)(((unsigned long)major << 24) + \
	                  ((unsigned long)minor << 16) + \
	                  ((unsigned long)sub << 8) + \
	                  ((unsigned long)releaseType << 6) + \
	                  (unsigned long)releaseVersion )

// Note - this has problems if VER_BUILDNUM goes above 64.  With actual
// releases, however, it shouldn't be a problem since we probably won't have
// 64 builds of the final release candidate.
#define XTRA_INTERNAL_VER_NUMBER MAKE_VERSION(VER_MAJORVERSION, \
                                        VER_MINORVERSION,		\
                                         VER_BUGFIXVERSION,		\
                                         VER_RELEASESTAGE,		\
                                         VER_BUILDNUM)


