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
*	File:		SWServerObject.h
*
*	Purpose:	Shockwave server object public interface.  This is the
*				interface used by xtras to access server objects.
*
*****************************************************************************/
#ifndef __SWServerObject__
#define __SWServerObject__

#undef 	CINTERFACE
#define	CPLUS

#ifndef _H_moaxtra
#include "moaxtra.h"
#endif

// ---------------------------------------------------------------------------
// Define the public interface for the SWServerObject base interface class
// ---------------------------------------------------------------------------
#undef INTERFACE
#define INTERFACE ISWServerObject

#define	ISWSERVEROBJECT_METHODS															\
																						\
	STDMETHOD( SetData ) 						(THIS_ 	ConstPMoaChar dataTag,			\
														PMoaChar data,					\
														MoaLong dataSize ) PURE;		\
																						\
	STDMETHOD( DeleteData )						(THIS_ 	ConstPMoaChar dataTag ) PURE;	\
																						\
	STDMETHOD( GetData )	 					(THIS_ 	ConstPMoaChar dataTag,			\
														PMoaChar data,					\
														MoaLong dataSize ) PURE;		\
																						\
	STDMETHOD( GetDataAt ) 						(THIS_ 	MoaLong index,					\
														PMoaChar dataTag,				\
														PMoaChar data,					\
														MoaLong dataSize ) PURE;		\
																						\
	STDMETHOD_(MoaLong, CountData)				(THIS) PURE;							\
																						\
	STDMETHOD( GetDataInfo ) 					(THIS_ 	ConstPMoaChar dataTag,			\
														PMoaChar * pData,				\
														MoaLong * pDataSize ) PURE;		\
																						\
	STDMETHOD( GetLastModTime ) 				(THIS_ 	PMoaChar pLastModTime ) PURE;	\
																						\
	STDMETHOD( ChangeSetting ) 					(THIS_ 	ConstPMoaChar settingTag,		\
														PMoaChar data,					\
														MoaLong dataSize ) PURE;		\
																						\
	STDMETHOD( GetSetting ) 					(THIS_ 	ConstPMoaChar settingTag,		\
														PMoaChar data,					\
														MoaLong maxDataSize ) PURE;

DECLARE_INTERFACE_(ISWServerObject, IMoaUnknown)
{
	STD_IUNKNOWN_METHODS

	ISWSERVEROBJECT_METHODS
};
typedef ISWServerObject * PISWServerObject;


// {617A6BD2-0976-11d3-A7AD-0060085393E5}
DEFINE_GUID(IID_ISWServerObject, 0x617a6bd2, 0x976, 0x11d3, 0xa7, 0xad, 0x0, 0x60, 0x8, 0x53, 0x93, 0xe5);



#define ISWSERVEROBJECT_EXTERN_METHODS													\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 SetData( ConstPMoaChar dataTag,		\
														PMoaChar data,					\
														MoaLong dataSize );		 		\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 DeleteData( ConstPMoaChar dataTag );	\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 GetData( ConstPMoaChar dataTag,		\
														PMoaChar data,					\
														MoaLong dataSize );		 		\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 GetDataAt( MoaLong index,				\
														PMoaChar dataTag,				\
														PMoaChar data,					\
														MoaLong dataSize );				\
																						\
	virtual MoaLong			STDMETHODCALLTYPE	 CountData();	 						\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 GetDataInfo( ConstPMoaChar dataTag,	\
														PMoaChar * pData,				\
														MoaLong * pDataSize );			\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 GetLastModTime( PMoaChar pLastModTime ); \
																						\
	virtual MoaError		STDMETHODCALLTYPE	 ChangeSetting( ConstPMoaChar settingTag,	\
														PMoaChar data,					\
														MoaLong dataSize );		 		\
																						\
	virtual MoaError		STDMETHODCALLTYPE	 GetSetting( ConstPMoaChar settingTag,	\
														PMoaChar data,					\
														MoaLong maxDataSize );



#define	MAXSERVEROBJECTTAGSIZE		60

#endif //__SWServerObject__

