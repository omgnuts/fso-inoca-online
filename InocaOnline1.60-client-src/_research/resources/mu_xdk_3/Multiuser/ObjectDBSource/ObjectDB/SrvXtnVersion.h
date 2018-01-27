
#ifndef _H_SrvXtnVersion
#define _H_SrvXtnVersion


/*****************************************************************************
 *  UTILITY MACROS
 *  --------------
 *	These macros calculate a precise version for your Xtra to be used in the
 *	Xtra definition below.  The first 4 #defines represent the release types
 *	you can choose when assembling your version.
 ****************************************************************************/ 

#define STRINGIZE(x)  #x
#define VERSION_DEVELOPMENT  0
#define VERSION_ALPHA        1
#define VERSION_BETA         2
#define VERSION_RELEASE      3

#define MAKE_VERSION(major, minor, sub, releaseType, releaseVersion) \
	                  (unsigned long)(((unsigned long)major << 24) + \
	                  ((unsigned long)minor << 16) + \
	                  ((unsigned long)sub << 8) + \
	                  ((unsigned long)releaseType << 6) + \
	                  (unsigned long)releaseVersion )

/*****************************************************************************
 *	VERSION DEFINITION
 *	------------------
 *	Fill in your version numbers below.
 ****************************************************************************/ 
#define XTRA_MAJOR_VERSION    0
#define XTRA_MINOR_VERSION    0
#define XTRA_SUB_VERSION      0
#define XTRA_RELEASE          VERSION_DEVELOPMENT
#define XTRA_RELEASE_VERSION  1
 
#define XTRA_VERSION_NUMBER MAKE_VERSION(XTRA_MAJOR_VERSION, \
                                        XTRA_MINOR_VERSION, \
                                         XTRA_SUB_VERSION, \
                                         XTRA_RELEASE_VERSION, \
                                         XTRA_RELEASE)

#endif // _H_SrvXtnVersion
